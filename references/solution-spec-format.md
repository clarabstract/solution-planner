# Solution spec format

A solution spec is a YAML file describing how a solution breaks down into components: what each one is for, what it owns and how they connect. It's named `solution-spec.yaml` and has a folder to itself. While it's still being reviewed it's named `solution-spec.draft.yaml`, and later stages ignore it until it's renamed. Its requirements are in [separate files](#requirement-files) beside it. If you've found one in a repo, it records the boundaries someone approved before the parts were specified or built. Problems found after approval are raised as files in a `findings/` folder beside it, and the spec itself changes only through the solution planner.

**This version's link:** `https://github.com/clarabstract/solution-planner/blob/v0.2/references/solution-spec-format.md`

**First line of every spec:** this comment points editors that use the [YAML language server](https://github.com/redhat-developer/yaml-language-server) at [the schema](solution-spec.schema.json), which gives them validation, autocomplete and field descriptions.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/clarabstract/solution-planner/v0.2/references/solution-spec.schema.json
```

The spec stays at boundary level: it says what a component owns, not how it works. Implementation choices, like hosting, libraries and protocols, wait for each component's own spec unless a constraint dictates them. It holds what was approved, not how that was reached: where things came from, alternatives and unknowns are reviewed during planning and stay there.

Everything other parts might refer to has a stable key: kebab-case, except requirements, which are grouped by activity as `activity.name` and map to a file path. A key never changes or gets reused once the spec is approved. Empty optional sections are left out.

Keep every line within 70 columns, including indentation, so the file reads well in a split window or on a phone. Write longer strings as folded blocks (`>`), wrapped at column 70, and longer lists as block lists. Only a URL can run over.

For a complete spec, see [the example](example-solution-spec.yaml).

## Top-level fields

Fields appear in this order, so the file reads from what's being built down to the detail behind it.

| Field | Required | Holds |
| --- | --- | --- |
| `format` | Yes | Link to this version of this reference. Always the first field, so anyone who finds the file can tell what it is. An older link means the spec predates this version, and the planner brings it up to date as a revision |
| `problem` | Yes | Who has the problem, how they cope today, and what success looks like, in a few sentences |
| `budget` | Yes | The human attention this is worth. Limits the whole spec, not just the component count |
| `stakes` | Yes | What happens if it goes wrong. Sets how rigorous later specs and tests need to be |
| `components` | Yes | The breakdown. See also [`components`](#components) |
| `connections` | No | Who calls whom |
| `constraints` | No | What the request dictates about the solution. See also [Constraints](#constraints) |
| `no-gos` | No | What's deliberately out of this plan |

## Requirements

A requirement statement is one thing the solution must do or guarantee, written so someone could tell from outside whether it holds.

- **Single:** one behaviour under one key. Related rules with the same owner share a key if they'd be reviewed together, such as a set of naming rules or the rules on which statuses are final.
- **Observable:** you could write a test for it without seeing the code.
- **Solution-neutral:** it names no components, operations or tables. Each component's `requirements` list covers assignment.
- **Example-free:** specific inputs and outputs belong in the requirement's test cases.

| Statement | Verdict |
| --- | --- |
| A client gets a reminder once an invoice is more than a week overdue | Good |
| A client gets at most one reminder per invoice per week | Good |
| Handle late payers sensibly | Not observable |
| The script calls `listOverdue` every Monday | Not solution-neutral |
| Invoice 1042, due 1 March, gets a reminder on 9 March | A test case, not a statement |

## Requirement files

Each requirement is one [Gherkin](https://cucumber.io/docs/gherkin/reference/) file in a `requirements/` folder beside the spec, found from its key: `remind.at-most-weekly` is `requirements/remind/at-most-weekly.feature`. The key is the Feature's title, the statement is its description, and the test cases follow:

```gherkin
Feature: remind.at-most-weekly

A client gets at most one reminder per invoice per week.

Example:
Given a client with two overdue invoices
When the round runs
Then the client gets one reminder for each

Rule:
Background:
Given an invoice reminded on Monday

Example:
When the round runs again on Thursday
Then no reminder goes out

Example:
Given the invoice is still overdue
When the round runs the following Monday
Then one reminder goes out
```

Any Gherkin syntax is allowed. A Background directly under `Feature:` applies to every case in the file. To give only some cases a Background, put them under a `Rule:` with its own. Keep lines within 70 columns.

The statement comes before the first case. None of its lines can start with a step keyword (`Given`, `When`, `Then`, `And`, `But` or `*`) or with a Gherkin keyword and a colon, because the statement scripts stop at the first keyword and report a step as an error.

Good cases:

- **Are concrete:** they use specific inputs and outcomes.
- **Are solution-neutral:** like statements, they name no components, operations or tables.
- **Catch mistakes:** choose the cases a wrong or too-narrow implementation would fail, rather than restating the rule.
- **Are as few as will pin the rule down:** `stakes` can call for more, and `budget` limits how many.
- **Use a table for sets of inputs and outputs:** when cases differ only in their values, write one `Scenario Outline` with an `Examples` table rather than many near-identical cases.
- **Keep Backgrounds short:** [rethink one that runs past 4 lines](https://cucumber.io/docs/gherkin/reference/).

Cases can be drafted with an agent's help, but a person has to review them, so they never become final unattended.

### Integrations

An integration is a cross-component test: a sequence of behaviour that depends on several requirements working together. If it's one behaviour split across components, it's a requirement with shared owners instead.

Each one is a file like any other requirement, in the reserved `requirements/integrations/` group, so no activity can use that name. It's listed in `requirements` on each component involved. If someone outside this plan takes part, such as a future script, the statement names them. `integrations.weekly-round` is `requirements/integrations/weekly-round.feature`:

```gherkin
Feature: integrations.weekly-round

An overdue invoice leads to one reminder, which then shows in what
went out that week.

Example:
Given an invoice eight days overdue with no reminders
When the round runs
And the bookkeeper checks that week's reminders
Then exactly one reminder appears for it
```

These tests can only run once all their components exist, so they run last.

### Keeping cases out of later work

A later chat that loads the cases could overfit to them without meaning to. The files copied from `assets/solution-folder/` make that less likely, but they won't stop an agent trying to get around them:

| File | What it does |
| --- | --- |
| `scripts/list-requirement-statements.ps1` and `.sh` | Print every statement at once, without the cases, so later stages have no need to open the files. One is for Windows, the other for macOS and Linux, and neither needs anything installed |
| `AGENTS.md` | Says the folder belongs to the planner except `findings/`, how to raise a finding and where to get the skill, and asks agents to leave `requirements/` alone unless they're planning the solution or editing cases at the user's request |
| `.ignore` | Keeps cases out of searches by tools that honour it, such as ripgrep. It doesn't stop direct reads |
| `.gitignore` | Keeps `findings/` out of version control. Findings are working files, and the spec diff shows what changed |
| `requirements/AGENTS.md` | Tells an agent that has opened a case to stop and tell the user |

Later stages should start in a new session and repeat the request in their own instructions, because not every agent or subagent loads `AGENTS.md`.

## Constraints

A constraint is a part of the request that dictates how the solution must be done, such as "use our existing billing system". A requirement says what must be true; a constraint says how.

## Sections keyed by name

| Section | Field | Required | Holds |
| --- | --- | --- | --- |
| `connections` | `from`, `to` | Yes | Component keys. `from` depends on `to` |
| | `uses` | Yes | Capabilities used. These aren't final operation names, which come from the component's own spec |
| | `contract-owner` | Yes | Whichever of `from` or `to` defines the contract |
| `constraints` | `statement` | Yes | The constraint. See also [Constraints](#constraints) |
| `no-gos` | `statement` | Yes | What's out |

## `components`

Which fields a component needs depends on its action. "Yes" means required, and "-" means it doesn't apply.

| Field | Holds | `build` | `reuse` | `modify` | `external` |
| --- | --- | --- | --- | --- | --- |
| `kind` | What type of component it is. See also [Component kinds](#component-kinds) | Yes | Yes | Yes | Yes |
| `action` | What this plan does with it. See also [Component actions](#component-actions) | Yes | Yes | Yes | Yes |
| `purpose` | One sentence with no "and" | Yes | Yes | Yes | Yes |
| `owns` | Data and rules it owns | Yes | Yes | Yes | - |
| `does-not` | What it deliberately doesn't do | Yes | Yes | Yes | - |
| `requirements` | Keys of the [requirements and integrations](#requirement-files) it's responsible for. A shared requirement is listed on each component involved. What an `external` component provides goes in `relied-on-for` instead | Yes | Optional | Yes | - |
| `why-separate` | Which split reason applies, and how. Not needed if it's the only component being built | Yes | - | - | - |
| `location` | Where it's found: repo, package or URL | - | Yes | Yes | Yes |
| `changes` | What's different | - | - | Yes | - |
| `affects` | Who already depends on it, whether or not they're in this plan | - | - | Yes | - |
| `breaking` | Whether the change breaks them | - | - | Yes | - |
| `purpose-change` | What the purpose was, if the change alters it | - | - | Optional | - |
| `relied-on-for` | What this plan needs from it | - | - | - | Yes |
| `replace-with` | How you'd replace it, and what would have to change | - | - | - | Yes |

A later stage specifies a `build` component in full and a `modify` component's change only. It writes nothing for `reuse` or `external`.

## Component kinds

A closed list. If a component doesn't fit, the planner stops and says so; a new kind is a change to this format.

| Kind | Test |
| --- | --- |
| `service` | Runs on its own and other things call it over a contract |
| `skill` | Instructions an agent follows, using judgement |
| `library` | Code that runs inside its caller |
| `script` | Someone or something runs it once, and it exits |
| `ui` | People use it directly |
| `workflow` | Steps defined for a workflow engine to run |

A script on a schedule is still a `script`. A workflow is written in its engine's format, so changing engines usually means rewriting it. The planner raises that lock-in for approval.

Not components of their own:

- **A database the owning service runs itself:** it's part of that service. A database hosted by someone else is a `service` with `action: external`.
- **Standing agents:** these are a `skill` plus a `workflow` if an engine runs them, or plus a `script` if not.

## Component actions

| Action | Meaning |
| --- | --- |
| `build` | We make it new |
| `reuse` | We control it and use it unchanged |
| `modify` | We control it and change it |
| `external` | Someone else controls it, and we use it |

A component either already exists or gets built under this plan. Something that might come later, like a script that may one day call a service, isn't a component. If the plan needs to support it, write what it needs as a requirement on the component it would call. If it's explicitly out of this plan, list it as a no-go too.

Only list external tools that shape the architecture, such as an identity provider or a database. Ordinary dependencies, like an HTTP client, belong in the component's own spec.

Adding to something versus changing it isn't a separate action: `breaking` captures that. A plugin or wrapper around someone else's tool is a new component with `action: build`, connected to the `external` one. A fork is `modify`, because you now control your copy.

A change under `modify` must fit the component's stated purpose, or `purpose-change` records that the purpose is changing.

## Checks

An approved spec passes all of these:

- **Schema:** the file matches [the schema](solution-spec.schema.json), which covers fields and values but not the checks below that span keys or files.
- **Format link:** `format` points at a fixed version of this reference, such as a tag, never a moving branch.
- **No open findings:** `findings/` is empty or absent.
- **References:** every key mentioned exists, and points at the right section.
- **Requirement files:** every listed key has a file at its path, every file in a group folder has a key, and each file is valid Gherkin with its key as the Feature title, a statement and at least one case.
- **Fields:** each entry has the fields its section and action require, and no others.
- **Grouping:** no two requirements on the same component would be reviewed together. If they would, merge them.
- **Ownership:** every requirement file is listed on at least one component, and every `build` or `modify` component lists at least one requirement.
- **Shared requirements:** if a requirement is on more than one component, each one's part shows in its `owns`.
- **Used:** every `reuse` or `external` component is the `to` of at least one connection.
- **Dependencies:** connections have no cycles, which is also where build order comes from.
- **Contracts:** `contract-owner` is the connection's `from` or `to`, and is always the `external` side if there is one.
- **Workflows:** every `workflow` connects to its engine, usually an `external` component.
- **Integrations:** each one is listed on at least two components, or on one if its statement names an outside caller.
