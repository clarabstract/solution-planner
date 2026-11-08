# Solution planner skill

An agent skill that describes a software solution in a rigid format, setting out ownership, responsibilities and requirements. A solution can span services, skills, libraries, scripts, UIs and workflows. See the [format reference](references/solution-spec-format.md) and the [example spec](references/example-solution-spec.yaml).

It also captures the high-level requirements as high-level Gherkin acceptance tests, designed to be used as holdout tests.

It plans and stops. It doesn't write the components' own specs or any code.

This is an experiment. The format may change between versions, and existing specs stay pinned to the version they link to.

## What you get

A new folder, wherever you choose, with:

- `solution-spec.yaml`: the components, what each one owns, how they connect, constraints and no-gos
- `requirements/`: one Gherkin file per requirement, with draft test cases for you to review
- `AGENTS.md`, `.ignore` and two scripts: these keep the test cases out of later work. They make overfitting less likely, but they won't stop an agent that tries to get around them. `AGENTS.md` also tells agents the folder belongs to this skill and how to report a problem with the plan
- `.gitignore`: keeps `findings/`, where later work reports those problems, out of version control

## Install

Ask your agent to install the skill from `https://github.com/clarabstract/solution-planner`.

Or clone it into your agent's skills folder, keeping the folder name `solution-planner`:

```
git clone https://github.com/clarabstract/solution-planner
```

Or download `solution-planner.zip` or `solution-planner.skill` from [Releases](https://github.com/clarabstract/solution-planner/releases), whichever your agent takes. They're the same zip, with the `solution-planner` folder inside.

The skill follows the [Agent Skills format](https://agentskills.io/specification). The format doesn't say where skills live, so check your agent's docs for the folder.

## Needs

- An agent with web search. Looking for existing tools is part of the job, so the skill stops and says so if it doesn't have it
- PowerShell on Windows, or `sh` and `awk` on macOS and Linux, to run the scripts

I've only really run this with one agent so far, so it may need some tweaking on others. Issues are welcome.

## Use

Ask your agent to plan or break down something new. A rough description is fine.

- It asks questions one at a time, each with a recommendation
- It writes a draft spec, `solution-spec.draft.yaml`, for you to refer to, then summarises the breakdown in plain language and waits for your approval
- The summary lists what it inferred, with where each inference ended up in the draft, so you can object before anything is final
- Once you approve, it renames the draft to `solution-spec.yaml` and writes the requirement files
- You review the draft test cases, then start later work in a new session
- After approval, the plan changes only through the skill. Later work that finds a problem writes it to `findings/` and stops; you then ask the skill to revise the plan in a new session. Bringing a spec written against an older format up to date works the same way

## Versions

Each spec links to the tagged version of the format it was written against, so tags don't move. Changes to the format get a new tag.

## License

[MIT](LICENSE)
