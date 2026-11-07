---
name: solution-planner
description: Turns a problem description or feature request into a reviewed breakdown of well-sized components (services, skills, libraries, scripts, UIs, workflows) with clear ownership, and writes it as a solution spec with requirement files and draft test cases. Use this before building anything that spans more than one part, whenever someone asks to plan, scope, architect or break down an app, system or feature, asks what to build or how to split it up, or hands over a rough description of something new, even if they don't say "plan".
compatibility: Requires web search.
---

# Solution planner

Take a problem description, ask what you need to, and break the problem into well-sized components with clear ownership. The result is a solution spec, with a file for each requirement, that later work can start from without this conversation.

The most important thing you produce is a boundary someone has actually decided on. Agents tend to pick boundaries silently and move on, and those are the most expensive decisions to undo. So surface them.

This skill plans and stops. Don't write the components' own specs or any code.

Web search is required, because finding existing tools is part of the job. If you don't have it, stop and say so rather than quietly skipping that step.

## Reference files

- [references/solution-spec-format.md](references/solution-spec-format.md): the format of the output, including component kinds and actions, what makes a good requirement, and the checks. Read it before step 3.
- [references/solution-spec.schema.json](references/solution-spec.schema.json): the machine-readable version of the format's fields. Validate against it in step 7 if you have a validator.
- [references/breakdown-criteria.md](references/breakdown-criteria.md): what makes a good breakdown. Read it before step 4.
- [references/example-solution-spec.yaml](references/example-solution-spec.yaml): a finished spec for an unrelated problem. It shows the shape; don't borrow its components.
- [assets/solution-folder/](assets/solution-folder/): files to copy into the solution folder in step 9. They keep test cases out of later work.

## Flow

If there's no request yet, ask for the problem before reading anything, because what's worth reading depends on it.

1. **Read the request and the repo,** to learn what already exists, so you don't ask what you can find out for yourself. The request stays in the session only. The spec replaces it and doesn't include a copy, because later stages read the spec and requests often contain examples they shouldn't see.

2. **Understand the problem.** Cover anything the request doesn't: who has the problem, how much human attention it's worth (`budget`), what happens if it goes wrong (`stakes`), what's out (no-gos), existing systems, and anything already decided about the solution.

3. **Sort the request.** Every part becomes a constraint, a requirement or a no-go, gets asked about, or is left out because it isn't about the solution.

4. **Draft a breakdown** using the criteria.

5. **Look for what could replace or shrink each component:** existing components first, then external tools. Confirm that any tool you name really exists, because invented dependencies are a common agent failure. This often changes the draft.

6. **Settle the boundaries.** For each one that's hard to reverse or could reasonably go another way, state the closest alternative and what would make it the better choice. If there isn't a real alternative, say so. An invented one looks rigorous and tells the reader nothing. These go in the summary, not the spec. If a choice wouldn't otherwise show in the spec, write it as a requirement, constraint or no-go, so later work can't quietly re-decide it. A rule the person stated is a requirement and isn't a choice to present, and implementation choices, like hosting, libraries and protocols, wait for each component's own spec unless a constraint dictates them.

7. **Run the checks** in the format reference. Nothing enforces them except you, so go through each one.

8. **Summarise in plain language and wait for approval.** People approve a breakdown more carefully in prose than in YAML. Cover the components, what each owns, the requirement and integration statements, the boundary choices they might want to overrule, and anything you left out of the request, since a wrongly dropped part can't be caught later. Write nothing final before they approve.

9. **Write the solution folder.** Ask which folder to use. Its name and location are up to the person, but it has to be new or empty, because these files could clash with anything already there. If it isn't, ask for another. Then:
   - Write `solution-spec.yaml`, copying its first line and the `format` value from the top of the format reference.
   - Write a requirement file with draft test cases for each requirement and integration.
   - Copy everything in [assets/solution-folder/](assets/solution-folder/), including `.ignore`.

10. **Report what the spec doesn't show.** Throughout the run, keep track of what you inferred rather than were told, and which entry each inference ended up in. Once the files are written, list each inference with its key, its statement and a `path:line` citation, finding the line by searching the written files. Also list any provisional decisions and anything unresolved. This is the only place these get reviewed, because the spec holds the result and not how it was reached. If the person objects to any of them, go back to the earliest step affected and revise the spec.

11. **Hand the cases over for review.** The test cases are drafts until a person has reviewed them, and you can't stand in for that review. Ask them to read the spec first, then the requirement files, and to add any cases they think are missing, by hand or with your help. Tell them to start later stages in a new session, because a chat can't forget the cases it has seen.

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
