---
name: sudo
description: Use when a command requires sudo or root privileges.
---

Immediately before requesting authorization, use `notify-send` to explain what needs administrator access and why. Prefer the command's native Polkit support; otherwise use `pkexec --disable-internal-agent` with the executable's absolute path. Elevate only the required operation and let the user authorize it through the graphical prompt. Never request passwords in chat or pass them through tools. If authorization is denied or no graphical agent is available, stop and report it.
