---
name: temp-lib
description: Provide missing libraries for temporary scripts (May provision temporary libraries without asking).
---

For project scripts, use the project's existing dependency environment. For one-off Python, use `uv run --no-project --isolated --with <package> python -`. For JavaScript/TypeScript, use `bun run --install=fallback -`. Both accept stdin, including heredocs, or a script path in place of `-`.
