"""Exercise firewall and routing policy in an isolated network namespace."""

import errno
import shutil
import socket
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

import pytest

from pia_vpn.models import Config
from pia_vpn.system import Runner, SystemNetwork


def test_firewall_coexistence() -> None:
    if not all(
        shutil.which(command) for command in ("unshare", "ip", "nft", "wg", "wg-quick")
    ):
        pytest.skip("network namespace tools are unavailable")
    isolation = ["unshare", "--user", "--map-root-user", "--net"]
    probe = subprocess.run([*isolation, "true"], capture_output=True, check=False)
    if probe.returncode:
        pytest.skip("unprivileged network namespaces are unavailable")
    result = subprocess.run(
        [*isolation, sys.executable, __file__],
        capture_output=True,
        text=True,
        timeout=30,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def can_send(address: str, *, mark: int = 0, port: int = 443) -> bool:
    family = socket.AF_INET6 if ":" in address else socket.AF_INET
    with socket.socket(family, socket.SOCK_DGRAM) as connection:
        if mark:
            connection.setsockopt(socket.SOL_SOCKET, socket.SO_MARK, mark)
        try:
            connection.sendto(b"firewall probe", (address, port))
        except OSError as error:
            if error.errno in (errno.EPERM, errno.EACCES, errno.ECONNREFUSED):
                return False
            raise
    return True


def exercise_firewall() -> None:
    runner = Runner()
    runner.run(["ip", "link", "set", "lo", "up"])
    for interface, address in (
        ("wan-test", "203.0.113.1/24"),
        ("pia", "198.51.100.1/24"),
        ("tailnet-test", "100.64.0.1/24"),
    ):
        runner.run(["ip", "link", "add", interface, "type", "dummy"])
        runner.run(["ip", "address", "add", address, "dev", interface])
        runner.run(["ip", "link", "set", interface, "up"])
    runner.run(
        [
            "ip",
            "-6",
            "address",
            "add",
            "fd7a:115c:a1e0::1/64",
            "dev",
            "tailnet-test",
            "nodad",
        ]
    )
    runner.run(["nft", "--file", "-"], input=b"table inet unrelated {}\n")

    # Model the dedicated PIA service UID, distinct from these test sockets.
    with patch("pia_vpn.system.os.geteuid", return_value=65534):
        network = SystemNetwork(Config(default_region="nz", allow_lan=False))
        network.protect()
        assert can_send("198.51.100.2"), "PIA tunnel traffic must be allowed"
        assert not can_send("203.0.113.2"), "ordinary WAN egress must be blocked"
        assert not can_send("100.64.0.2"), "Tailscale exceptions must be opt-in"
        assert not can_send("203.0.113.2", mark=0x80000)

        network = SystemNetwork(
            Config(
                default_region="nz", allow_lan=False, tailscale_interface="tailnet-test"
            )
        )
        network.protect()
        assert can_send("100.64.0.2"), "policy must update an existing table"
        assert can_send("fd7a:115c:a1e0::2"), "IPv6 overlay traffic must be allowed"
        assert can_send("203.0.113.2", mark=0x80000), "Tailscale transport must work"
        assert can_send("203.0.113.2", mark=0x80001), (
            "only Tailscale's mark bits matter"
        )
        assert not can_send("203.0.113.2", mark=0x40000)
        assert not can_send("203.0.113.2")

        network.protect(("203.0.113.2", 51820))
        assert can_send("203.0.113.2", port=51820), "PIA endpoint must be reachable"
        network.protect(("203.0.113.3", 51820))
        assert not can_send("203.0.113.2", port=51820), "old endpoint must be removed"
        assert can_send("203.0.113.3", port=51820)

        runner.run(["ip", "link", "delete", "pia"])
        assert can_send("100.64.0.2"), "tailnet must survive loss of the PIA interface"
        assert can_send("203.0.113.2", mark=0x80000)
        assert not can_send("203.0.113.2"), "loss of PIA must not open WAN egress"

        network = SystemNetwork(Config(default_region="nz", allow_lan=False))
        network.protect()
        assert not can_send("100.64.0.2"), "removing integration must revoke exceptions"
        assert not can_send("203.0.113.2", mark=0x80000)
        runner.run(["nft", "list", "table", "inet", "unrelated"])
        network.unprotect()
        assert can_send("203.0.113.2"), "intentional disconnect must remove protection"

    exercise_routing(runner)


def exercise_routing(runner: Runner) -> None:
    runner.run(["ip", "route", "add", "default", "dev", "wan-test"])
    runner.run(
        ["ip", "route", "add", "100.89.202.27/32", "dev", "tailnet-test", "table", "52"]
    )
    tailscale_rules = (
        ("5210", "fwmark", "0x80000/0xff0000", "table", "main"),
        ("5230", "fwmark", "0x80000/0xff0000", "table", "default"),
        ("5250", "fwmark", "0x80000/0xff0000", "type", "unreachable"),
        ("5270", "table", "52"),
    )

    def tailnet_rules(action: str) -> None:
        for priority, *arguments in tailscale_rules:
            runner.run(["ip", "-4", "rule", action, "priority", priority, *arguments])

    def route(address: str, *, mark: int = 0) -> str:
        return runner.run(
            ["ip", "-4", "route", "get", address, "mark", str(mark)]
        ).stdout.decode()

    private_key = runner.run(["wg", "genkey"]).stdout.decode().strip()
    public_key = runner.run(["wg", "genkey"]).stdout
    public_key = runner.run(["wg", "pubkey"], input=public_key).stdout
    with TemporaryDirectory() as directory:
        configuration = Path(directory) / "pia.conf"
        configuration.write_text(f"""[Interface]
Address = 198.51.100.1/32
PrivateKey = {private_key}

[Peer]
PublicKey = {public_key.decode().strip()}
AllowedIPs = 0.0.0.0/0
Endpoint = 203.0.113.2:51820
""")
        configuration.chmod(0o600)

        # Both startup orders must preserve overlay, transport, LAN, and internet routes.
        for tailscale_first in (True, False):
            if tailscale_first:
                tailnet_rules("add")
            runner.run(["wg-quick", "up", str(configuration)])
            if not tailscale_first:
                tailnet_rules("add")
            assert "dev tailnet-test" in route("100.89.202.27")
            assert "dev pia" in route("198.18.0.2")
            assert "dev wan-test" in route("198.18.0.2", mark=0x80000)
            assert "dev wan-test" in route("203.0.113.2", mark=51820)

            runner.run(["wg-quick", "down", str(configuration)])
            assert "dev tailnet-test" in route("100.89.202.27")
            assert "dev wan-test" in route("198.18.0.2")
            tailnet_rules("delete")


if __name__ == "__main__":
    exercise_firewall()
