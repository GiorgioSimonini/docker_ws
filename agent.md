# Agent Instructions (Coding / Autonomy)

## Overview

This file defines the **rules and workflow** for an autonomous agent operating in this workspace. The agent should be able to execute coding tasks end-to-end without requiring manual intervention, while still being safe, transparent, and easy to audit.

The key principles are:
- ✅ **Never guess**: if uncertain, ask or record the uncertainty in `questions.md`.
- ✅ **Top-down + bottom-up reasoning**: plan the overall task, then implement concrete pieces.
- ✅ **Track state** using explicit files (`context.md`, `tasks.md`, `iteration_k.md`, `questions.md`).
- ✅ **Respect user persistence**: do not stop waiting for the user unless there are unresolved questions after a timeout.

---

## 1. Workflow Overview (Top-down + Bottom-up)

### 1.1 Top-down planning (Big picture)

1. **Define the overall goal** in `tasks.md` as a set of high-level tasks.
2. **Decompose each high-level task** into subtasks, milestones, and checkpoints.
3. **Continue to decompose** untill single subtask is feasible in one-shoot.
4. **Design the architecture**: identify the main modules, classes, scripts, and tools needed.
5. **Record the plan** in `tasks.md` and optionally `implementation_plan.md` if the task requires user intervention.

### 1.2 Bottom-up execution (Implementation)

1. **For each task**:
   - Look for user replies in `questions.md` if the task requires it.
   - Identify the required **instruments** (libraries, scripts, tools, APIs).
   - Identify the required **classes/structures** (data models, helpers, interfaces).
   - Implement each component incrementally.
2. **After implementing a component**, update the task state and create an `iteration_k.md` summary.
3. **Merge everything** into a working solution gradually and continuously.

---

## 2. Tracking Progress (Files)

### 2.1 `tasks.md` (overall task list)

This is the **single source of truth** for what the agent is doing.

- Format:
  ```markdown
  # Tasks

  - [ ] High-level task 1
    - [ ] Subtask A
    - [ ] Subtask B
  - [ ] High-level task 2
  ```
- Always append; never delete previous entries.
- Update statuses as work progresses:
  - `[ ]` pending
  - `[/]` in-progress
  - `[x]` done
- If a task is split or shelved, add notes explaining why.
- If a task is difficult or unclear, add a subtask for investigation/research so the agent can revisit it later.
- If the task requires human intervention, identify the task with a key and link it in `questions.md`.

### 2.2 `iterations/iteration_k.md` (iteration reports)

For each major iteration (a coherent work session), create a file named `iteration_<k>.md`, into the `iterations` folder, where `<k>` is an incrementing number.

Each iteration file must include:
- **What was achieved** (what tasks moved forward or completed).
- **What remains** (open connected tasks, blockers, open questions).
- **Next steps** (what to do next and why).

Template:
```markdown
# Iteration N — Summary

## Completed
- [x] ...

## In progress
- [/] ...

## Blockers / Questions
- (see `questions.md`)

## Next steps
1. ...
```

### 2.3 `questions.md` (user interactions)

When the agent is uncertain or needs input, do **not** proceed by guessing. Instead:
- Add a question entry to `questions.md`.
- Keep the workspace runnable for any possible answer.
- Structure the implementation so it remains correct regardless of which option the user selects.
- If the question involves installing software or requiring root, add the needed commands in `questions.md` so the user can run them.

Questions file format:
```markdown
# Questions

1. (context) ...
   - Options:
     - A: ...
     - B: ...
   - Impact: ...
```

### 2.4 Timeouts and Continuation

- If a question is added, **wait up to 5 minutes** for the user to respond.
- After 5 minutes with no response, continue working on any tasks that do **not** depend on user input.
- Only stop waiting if there are no remaining unblocked tasks.

---

## 3. Agent Behavior Rules

### 3.1 Never guess

- If any decision is unclear, **do not make assumptions**.
- Record the uncertainty in `questions.md` (link it in `tasks.md` if it is task-related).
- Provide the user with clear, actionable options.

### 3.2 Always be explicit about assumptions

If you proceed with a best-effort choice, document it in an iteration note and in `tasks.md` and `summary.md`.

### 3.3 Code quality and readability

- Prefer small, testable modules.
- Favor readability and maintainability over cleverness.
- Use clear naming and docstrings/comments, without creating too much long names.
- Write code so that it can be understood without additional explanation, anyway use comments.

### 3.4 Checkpoints and rollbacks

- agents can use `git` for checkpoint if not differently expressed by the user.
- If `git` is used for checkpoints, commit logical progress frequently.
- Each commint sent by the agent have to be in a branch that starts with "agent/" if not differently expressed by the user.
- If a change is experimental or risky, make it in a feature branch (that starts with "agent/").

### 3.5 Subagents and external search

When the task can benefit from external knowledge or parallel exploration:
- You MAY spawn up to **two** subagents (`Raptor mini` or `GPT5 mini`).
- Track subagent use in `tasks.md` and iteration files.
- If a subagent crashes, note it and re-spawn only when essential.
- When a subagent is used, provide him with local context for executing the subtask. The subagent should not operate with the codebase, only reply to you.

---

## 4. Tooling and Permissions

### 4.1 Using tools in the environment

The agent may use any available tool in this workspace (scripts, build tools, language runtimes).

- If a tool must be installed and requires root privileges, stop and add a question to `questions.md` describing:
  - What needs to be installed
  - Why it is needed
  - How to install it (commands)

### 4.2 Git usage

- `git` usage should be allowed by the user. Ask it if you think could be used.
- Keep history clean and meaningful.
- use branches that starts with "agent/".
- Commit at the end of each iteration with a clear message.
- If you need to experiment, create a new branch (or stash) and document it.

---

## 5. Iteration Lifecycle

1. Read `context.md`
2. Review `tasks.md`, `iteration_k.md`, and last `summary.md` to see the current state.
3. Choose the next unblocked task.
4. Implement the necessary code / changes.
5. Update `tasks.md` and create a new `iteration_k.md` describing progress.
6. Add or update documentation in `docs/` folder.
7. If any uncertainty arises, add it to `questions.md`.
8. Update `context.md` with the project actual context.
9. Commit changes if `git` enabled.
10. Continue.

---

## 6. When to Stop

The agent may stop only when:
- All tasks in `tasks.md` are marked complete, and
- There are no unresolved questions in `questions.md`, and
- The workspace is in a runnable state (builds/tests pass), or a clear next action is documented.

If any questions remain, the agent should explicitly note that it is waiting for user input and keep working on other tasks that are not blocked.

---

## 7. File Roles (summary)

- `context.md`: Contains the general context for the agent, only useful informations.
- `agent.md`: This document (agent behavior and workflow rules).
- `tasks.md`: High-level task tracker (append-only). If the file is too big, consider to collapse old closed tasks.
- `iterations/iteration_<k>.md`: Reports per iteration.
- `questions.md`: User-interaction / decision points.
- `continue.md`: Continuation prompt / handoff instructions for the next agent run.
- `implementation_plan.md`: (Optional) Detailed plan for complex changes.

---

## 8. Documentation structure (human-readable)

This workspace uses a **dedicated `docs/` folder** to hold documentation about the project.

The docs are **NOT** meant to be a copy of progress status. Progress tracking is handled by:
- `tasks.md` (backlog)
- `iteration_<k>.md` (progress snapshots)
- `questions.md` (decision points)

Instead, the docs are a set of explanatory markdown files intended to onboard a new agent or human reader.
The agent should add documentation at the end of each iteration, utilizing the `summary.md` as guide.

### 8.1 Documentation—Workspace vs Project

This repository is a **workspace container / tooling environment** (the Docker+DevContainer setup). It also may contain **project-specific code**. The documentation must reflect this distinction:

- **Workspace documentation** (workspace-level setup, build/run instructions, container configuration) belongs in `README.md`.
  - `README.md` should describe how to build/run/attach to the container, tooling expectations, and how to access the project code.

- **Project documentation** (project-specific guides, demo descriptions, feature docs) should live under `docs/`.
  - At minimum, create `docs/init.md` as the project’s entry point.
  - The agent should always generate or update project docs under `docs/` when implementing new features or demos.

When updating docs, ensure the `README.md` references the appropriate `docs/` entry point so users can find the project documentation easily.

### 8.2 Core docs files
- `docs/init.md` — high-level introduction and quickstart instructions
- `docs/<topic>.md` — that contain the specific <topic>. Create new topic for each argument that have to be explained detaily.

---

## 9. Continuing work (handoff)

- When pausing or stopping, update the latest `iteration_<k>.md` and ensure `tasks.md` is accurate.
- Update `continue.md` with clear next steps (what to work on next and why).
