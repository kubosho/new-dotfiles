# Jujutsu (jj) Workflow

Applies when `.jj` exists in the project root.

## Outcome

Every commit carries a single reason and motivation for the change, making the history alone sufficient to trace intent.

## Constraints

- All commands that accept a message use `-m "message"`. No interactive editor.
- Commit message format:
  ```
  type: summary
                          ← blank line
  body                    ← optional: omit if summary alone conveys the reason
                          ← blank line
  trailers                ← optional: e.g. Co-Authored-By
  ```
  - Types: feat, fix, refactor, docs, test, chore, perf, ci
  - Body: why the change was made, in the minimum words needed. No line breaks.

## Invariants

These conditions must hold true at each stage. When violated, the fix restores them.

### Working copy belongs to the current task

**Check**: `jj status` before file modifications.

- Matches current task → proceed
- Empty or different task → `jj new main`

### Bookmarks stay attached after rewrites

`jj squash --into` rewrites the target commit. Bookmarks pointing to the old commit detach. A detached bookmark (`<name>@origin` only, no local counterpart) causes `jj git push` to delete the remote branch.

**Check**: `jj log` after every `jj squash --into`.

- Attached → proceed
- Detached → `jj bookmark set <name> -r <rev>`

### Each commit contains one logical context

Mixing unrelated changes in one commit makes revert, cherry-pick, and review unreliable — reverting one fix silently undoes an unrelated refactor.

**Check**: `jj diff` before `jj describe`. If the diff serves more than one purpose, `jj split` to separate by context.

- Single context → proceed
- Multiple contexts (describable only with "and") → `jj split`, then describe each commit separately

### Git hooks run before push

jj does not execute git hooks. Without manual execution, pre-commit and pre-push checks are skipped silently.

**Check**: Before `jj git push`, if a hook runner config exists (`lefthook.yml`, `.husky/`), run hooks manually. Timing map: `pre-commit` and `pre-push` → before push. `commit-msg` → after `jj describe`.
