# Jujutsu (jj) Workflow

**Applicability**: These rules apply only when the project root contains a `.jj` directory (i.e., the repository is managed by Jujutsu). If `.jj` does not exist, ignore this file entirely and use git commands as usual.

## Pre-write Gate

**Before modifying any file (Edit/Write tool), always run `jj status` first.**

- If the working copy is empty or belongs to a different task → run `jj new main`
- If the working copy already has changes for the current task → proceed
- Never skip this check. Reading files is fine without it; writing is not.

## Non-interactive only

jj commands that accept a message (describe, squash, split, etc.) will open an interactive editor by default, which fails in this environment. **Always pass `-m "message"` to avoid opening an editor.**

## Commands

| Action | Command |
|--------|---------|
| Create new change | `jj new main` |
| Check status | `jj status` |
| View diff | `jj diff` |
| Set commit message | `jj describe -m "message"` |
| View history | `jj log` |
| Push to remote | `jj git push` |
| Squash into another change | `jj squash --into <rev> -m "message"` |

## Commit Message Format

Use Conventional Commits: `type: description`

Types: feat, fix, refactor, docs, test, chore, perf, ci

Always add co-author line at the end:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```
