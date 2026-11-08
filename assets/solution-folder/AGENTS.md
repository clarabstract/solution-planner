# Solution folder

This folder holds a solution spec and its requirements, written by the solution-planner skill. Files under `requirements/` include test cases that check later work independently, and that check only means something if the work wasn't shaped by the cases.

## Changing the plan

Everything here except `findings/` belongs to the solution-planner skill. Don't edit `solution-spec.yaml` or the requirement files directly, even for a small fix. The one exception is adding test cases when the user asks (see `requirements/AGENTS.md`).

- If something in the plan is wrong or missing, write a short Markdown file in `findings/` and stop: the component it came from, what you found with a `path:line` citation, what part of the plan it affects, and a suggested change if you have one. Then tell the user the plan needs revising.
- If `findings/` has any file in it, the plan isn't usable yet. Stop and tell the user.
- The skill makes the change, in a new session. If it isn't installed, it's at https://github.com/clarabstract/solution-planner.

## Reading requirements

Unless you're the solution-planner skill or editing cases at the user's request:

- Don't open or search files under `requirements/`.
- To get the requirement statements, run the script for your system from this folder. It prints all of them at once, without the cases.
  - Windows: `powershell -ExecutionPolicy Bypass -File scripts\list-requirement-statements.ps1`
  - macOS or Linux: `sh scripts/list-requirement-statements.sh`
- If you've seen a case anyway, stop and tell the user, so the work can move to a new session.
