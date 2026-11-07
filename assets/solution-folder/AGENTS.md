# Solution folder

This folder holds a solution spec and its requirements. Files under `requirements/` include test cases that check later work independently, and that check only means something if the work wasn't shaped by the cases.

Unless you're planning this solution or editing cases at the user's request:

- Don't open or search files under `requirements/`.
- To get the requirement statements, run the script for your system from this folder. It prints all of them at once, without the cases.
  - Windows: `powershell -ExecutionPolicy Bypass -File scripts\list-requirement-statements.ps1`
  - macOS or Linux: `sh scripts/list-requirement-statements.sh`
- If you've seen a case anyway, stop and tell the user, so the work can move to a new session.
