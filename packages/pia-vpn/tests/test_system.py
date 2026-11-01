import subprocess
import time
from collections.abc import Sequence

from pia_vpn.models import Config
from pia_vpn.system import Runner, SystemNetwork


class Handshake(Runner):
    """Answers `wg show <interface> latest-handshakes` with a fixed timestamp."""

    def __init__(self, timestamp: float) -> None:
        self.timestamp = timestamp

    def run(
        self,
        arguments: Sequence[str],
        *,
        input: bytes | None = None,
        check: bool = True,
        timeout: float = 30,
    ) -> subprocess.CompletedProcess[bytes]:
        output = f"peer-public-key\t{int(self.timestamp)}\n".encode()
        return subprocess.CompletedProcess(arguments, 0, output, b"")


def test_handshake_after_clock_step_back_is_stale() -> None:
    # Boot with the RTC in local time: handshake at 11h fast, then NTP steps back.
    network = SystemNetwork(
        Config(default_region="nz"), Handshake(time.time() + 11 * 3600)
    )
    assert network.handshake_age() == float("inf")
