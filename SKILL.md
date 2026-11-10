---
name: solution-planner
description: Turns a problem description or feature request into a reviewed breakdown of well-sized components (services, skills, libraries, scripts, UIs, workflows) with clear ownership, and writes it as a solution spec with requirement files and draft test cases. Use this before building anything that spans more than one part, whenever someone asks to plan, scope, architect or break down an app, system or feature, asks what to build or how to split it up, or hands over a rough description of something new, even if they don't say "plan".
compatibility: Requires web search.
---

# Solution planner

Take a problem description, ask what you need to, and break the problem into well-sized components with clear ownership. The result is a solution spec, with a file for each requirement, that later work can start from without this conversation.

The most important thing you produce is a boundary someone has actually decided on. Agents tend to pick boundaries silently and move on, and those are the most expensive decisions to undo. So surface them.

This skill plans and stops. Don't write the components' own specs or any code.

It also owns every later change to the plan. Once a spec is approved, nobody edits it by hand: a problem found later comes back as a finding, and bringing a spec up to the current format is a change like any other. See [Revising a plan](#revising-a-plan).

Web search is required, because finding existing tools is part of the job. If you don't have it, stop and say so rather than quietly skipping that step.

## Reference files

- [references/solution-spec-format.md](references/solution-spec-format.md): the format of the output, including component kinds and actions, what makes a good requirement, and the checks. Read it before step 3.
- [references/solution-spec.schema.json](references/solution-spec.schema.json): the machine-readable version of the format's fields. Validate the draft against it in step 8 if you have a validator.
- [references/breakdown-criteria.md](references/breakdown-criteria.md): what makes a good breakdown. Read it before step 4.
- [references/example-solution-spec.yaml](references/example-solution-spec.yaml): a finished spec for an unrelated problem. It shows the shape; don't borrow its components.
- [assets/solution-folder/](assets/solution-folder/): files to copy into the solution folder in step 10. They keep test cases out of later work and tell other agents the folder belongs to this skill.

## Flow

If there's no request yet, ask for the problem before reading anything, because what's worth reading depends on it. If instead you're given an approved solution folder, with a finding in it or a change the person wants, go to [Revising a plan](#revising-a-plan).

1. **Read the request and the repo,** to learn what already exists, so you don't ask what you can find out for yourself. The request stays in the session only. The spec replaces it and doesn't include a copy, because later stages read the spec and requests often contain examples they shouldn't see.

2. **Understand the problem.** Cover anything the request doesn't: who has the problem, how much human attention it's worth (`budget`), what happens if it goes wrong (`stakes`), what's out (no-gos), existing systems, and anything already decided about the solution.

3. **Sort the request.** Every part becomes a constraint, a requirement or a no-go, gets asked about, or is left out because it isn't about the solution.

4. **Draft a breakdown** using the criteria.

5. **Look for what could replace or shrink each component:** existing components first, then external tools. Confirm that any tool you name really exists, because invented dependencies are a common agent failure. This often changes the draft.

6. **Settle the boundaries.** For each one that's hard to reverse or could reasonably go another way, state the closest alternative and what would make it the better choice. If there isn't a real alternative, say so. An invented one looks rigorous and tells the reader nothing. These go in the summary, not the spec. If a choice wouldn't otherwise show in the spec, write it as a requirement, constraint or no-go, so later work can't quietly re-decide it. A rule the person stated is a requirement and isn't a choice to present, and implementation choices, like hosting, libraries and protocols, wait for each component's own spec unless a constraint dictates them.

7. **Write the draft.** Ask which folder to use. Its name and location are up to the person, but it has to be new or empty, because the files you'll write could clash with anything already there. If it isn't, ask for another. Write only `spec/solution-spec.draft.yaml`, copying its first line and the `format` value from the top of the format reference. Set `solution` to the solution's name in kebab-case, using one the person has given or proposing one in the summary, because other repos refer to the plan by it and it can't change after approval. The draft gives the person something to refer to during review. Its name keeps it from being mistaken for an approved spec, because later stages only read `spec/solution-spec.yaml`.

8. **Run the checks** in the format reference against the draft, except the ones on requirement files, which don't exist yet. Nothing enforces them except you, so go through each one.

9. **Summarise in plain language and wait for approval.** People approve a breakdown more carefully in prose than in YAML, so the draft is for reference and the summary is what they decide on. Cover:
   - the solution's name, if you proposed it
   - the components and what each owns
   - the requirement and integration statements, since the draft only holds references to them
   - the boundary choices they might want to overrule
   - anything you left out of the request, since a wrongly dropped part can't be caught later
   - what you inferred rather than were told, each with its key, its statement and a `path:line` citation in the draft, found by searching the file. Keep track of these throughout the run
   - any provisional decisions and anything unresolved

   This is the only place inferences, provisional decisions and unresolved points get reviewed, because the spec holds the result and not how it was reached. If the person objects to anything, go back to the earliest step affected and revise the draft. If they edit the draft themselves, read it again before going on. Write nothing else before they approve.

10. **Write the solution folder.** Once the person approves:
    - Rename `spec/solution-spec.draft.yaml` to `spec/solution-spec.yaml`.
    - Write a requirement file under `spec/requirements/` with draft test cases for each requirement and integration.
    - Copy everything in [assets/solution-folder/](assets/solution-folder/) into the solution folder, keeping its layout and including `.ignore` and `.gitignore`.
    - Run the checks on requirement files.

11. **Hand the cases over for review.** The test cases are drafts until a person has reviewed them, and you can't stand in for that review. Ask them to read the spec first, then the requirement files, and to add any cases they think are missing, by hand or with your help. Tell them to start later stages in a new session, because a chat can't forget the cases it has seen.

## Revising a plan

The plan stays live after approval. A later stage, or the person, can find that part of it is wrong: a boundary that has to move, stakes that turn out higher, a missing requirement. Or the format has moved on and the spec is pinned to an older version. Either way you make the change, rather than anyone editing the spec by hand, so the same questions and checks apply.

**Findings.** A later stage reports a problem as a short Markdown file in `findings/` at the root of the solution folder, then stops. It holds the component it came from, if any; what was found, with a `path:line` citation in the work that found it; what it affects, such as `stakes`, a component's `owns` or `does-not`, a connection, a requirement, or whether a component should exist at all; and a suggested change, optionally. A finding sits outside `spec/`, so it names parts of the plan by [reference](references/solution-spec-format.md#references) from `spec/`, such as `solution-spec.components.billing-service.owns` or `requirements.remind.at-most-weekly`. A plan with a file in `findings/` isn't usable until you've dealt with it. Findings are working files, not part of the record, so the folder's `.gitignore` keeps them out of version control.

Run in a fresh session, because you'll read requirement files and the finder's session has to stay clear of cases.

1. **Read the spec, the finding and what it cites.** With no finding, the person tells you what to change. If `format` points at an older version of the format reference, read that version too, so you know what changed between them.
2. **Work out what it changes,** asking questions as in [Asking questions](#asking-questions). A finding is evidence, not a decision: the person decides, and you can recommend against it. A format update changes only what the new format requires. Anything else it tempts you to improve is a separate change to propose.
3. **Write the change** to the spec, against the current format reference, with `format` and the schema comment updated, and to every requirement file it touches: a new requirement or integration gets a file with draft test cases, a changed statement gets its cases reworked to match, and a removed one's file goes.
   - If the solution folder is tracked by git, edit the files in place, add new ones under their final names and delete removed ones, so the person reviews the change as a diff. If any file you'll change or delete has uncommitted changes, first ask whether they'll commit or stash them or would rather you write drafts, because your edits would mix with theirs in the diff and undoing yours could lose theirs.
   - Otherwise write drafts. First copy in any file from [assets/solution-folder/scripts/](assets/solution-folder/scripts/) that has changed, because older statement scripts don't skip drafts. Then write `solution-spec.draft.yaml` beside the approved spec and each new or changed requirement as a `.draft.feature` sibling, such as `spec/requirements/remind/at-most-weekly.draft.feature`. Leave removed files in place until approval.
4. **Run the checks** against the changed spec and requirement files. A draft stands in for the file it sits beside, and a file the change removes doesn't count.
5. **Summarise and wait for approval:** what changes and why, and what it knocks on to. That means components whose own specs may now be out of date, requirement files added, removed or with a changed statement, and anything already built that may break. Cases under a changed statement go back to draft and need review again. Point to the change: the `git diff` command plus any new files for an in-place edit, or the drafts' paths and the files to be removed. If the person edits a file themselves, read it again before going on.
6. **On approval,** if you wrote drafts, rename each over the file it sits beside and delete the files the change removes. Then copy in anything from [assets/solution-folder/](assets/solution-folder/) the folder is missing or that has changed, delete the finding, and run the requirement-file checks. A removed key is never reused.
7. **Report** which components need their specs revisited, so the finder knows where to pick up.

If the person rejects the change, undo it, and delete the finding, which makes the plan usable again. For an in-place edit, `git restore` the files you changed or deleted and delete the ones you added; otherwise delete the drafts. The finder carries on within the approved plan, or writes a new finding if it can't.

As with the first plan, the spec holds the result, not how it was reached. The reason for a revision lives in your summary, and in the commit if the folder is under version control.

## Asking questions

Questions aren't a step. Ask as soon as an answer could change the breakdown, at any stage, and go back to an earlier step if it does.

- Ask one at a time, each with a recommendation, so answering is cheap.
- Only ask if the answer could change the breakdown. Everything else is noise, and it uses up the person's patience for the questions that matter.
- Ask about hard-to-reverse choices first.
- Look up facts you can check, such as what a tool supports, rather than asking or assuming.
- Don't guess at unfinished or contradictory parts of the request. Ask if the answer could change the breakdown, and otherwise list them as unresolved in the final report.
- Don't seek approval while an answer that could change the breakdown is missing, and don't pick a default for the person. Keep asking until they answer or explicitly call their answer a provisional decision.

| Stage | Typical question |
| --- | --- |
| Understanding the problem | "How much is this worth to you?" |
| Sorting the request | "This line stops mid-sentence. What did you mean?" |
| Drafting the breakdown | "Should this rule live in the service or in its caller?" |
| Looking for what exists | "This tool covers most of it but is paid. Adopt or build?" |
| Running the checks | "Nothing owns this requirement. Is it still needed?" |

## Constraints

When a request dictates part of the solution, follow it and build the breakdown on top of it. Don't reopen it as a design question.

First check that what the constraint refers to actually exists. "Use our framework" means something very different if the framework isn't built yet, so raise that early. It can change the whole plan.

You can still challenge a constraint when it looks like a bad fit: "You asked for a service, but a file would meet every requirement here. Do you want to keep the service?" Never override one quietly. The person decides, and the constraint is kept or changed to match.
