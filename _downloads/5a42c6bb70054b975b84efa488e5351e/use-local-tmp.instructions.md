---
description: >-
  Enforces the use of a local `.tmp/` directory instead of system `/tmp/` across operations, ensuring secure unprivileged temp file usage.
---

# Use Local `.tmp/` Directory

Whenever temporary files, logs, or intermediate structures need to be generated or stored:

1. **Never use the system `/tmp/` directory**, as it frequently causes access-control and isolation issues.
2. **Always prefer a local `.tmp/` folder** anchored at the workspace root (`./.tmp/` or `../../.tmp/` depending on your active shell location).
3. If the `.tmp/` directory does not exist, you must create it and assign **sticky bit permissions (chmod 1777)** before writing into it. Example:
   ```bash
   mkdir -p .tmp && chmod 1777 .tmp
   ```
4. This ensures an unprivileged, secure temporary sandbox directly relative to the active workspace rather than the entire system.

## Application

This instruction applies to:
- Generating temporary build artifacts
- Writing test logs and reports
- Storing intermediate computation results
- Any operation involving ephemeral file I/O
