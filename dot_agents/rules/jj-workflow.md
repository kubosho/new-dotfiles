# Jujutsu (jj) Workflow

Applies when `.jj` exists in the project root.

## Outcome

Every commit carries a single reason and motivation for the change, making the history alone sufficient to trace intent.

## Constraints

- Claude Code has no TTY. Commands that open an interactive UI (editor launch, `--interactive` flag) always fail. Use non-interactive alternatives instead: `-m "message"` for commits, fileset arguments for splits, etc.
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
- Empty or different task → `jj new <base>` where `<base>` is the branch the task depends on (default: `main`)

### Bookmarks stay attached after rewrites

`jj squash --into` rewrites the target commit. Bookmarks pointing to the old commit detach. A detached bookmark (`<name>@origin` only, no local counterpart) causes `jj git push` to delete the remote branch.

**Check**: `jj log` after every `jj squash --into`.

- Attached → proceed
- Detached → `jj bookmark set <name> -r <rev>`

### Each commit contains one logical context

Mixing unrelated changes in one commit makes revert, cherry-pick, and review unreliable — reverting one fix silently undoes an unrelated refactor.

**Check**: `jj diff` before `jj describe`. `jj diff -r <rev>` for each commit in the push range before `jj git push`.

- Single context → proceed
- Multiple contexts (describable only with "and") → `jj split -m "type: summary" <filesets>` to separate by context, then describe remaining commit separately
- Changes address multiple review comments → each comment is a separate context, split per comment

### Completed work carries a description

Undescribed commits accumulate silently. Without a message, the history loses the intent that motivated the change.

**Check**: After file modifications are complete and tests pass (if applicable).

- Working copy has meaningful changes → `jj describe -m "type: summary"` (following Constraints above), then `jj new`
- Working copy is empty or already described → proceed

### Push targets a named bookmark

`jj git push` requires a bookmark. Without one, push fails or targets the wrong revision.

**Check**: `jj log` before `jj git push`.

- Bookmark exists on the target revision → proceed
- No bookmark on the target → `jj bookmark create <name> -r <rev>`

### Git hooks run before push

jj does not execute git hooks. Without manual execution, pre-commit and pre-push checks are skipped silently.

**Check**: Before `jj git push`, if a hook runner config exists (`lefthook.yml`, `.husky/`), run hooks manually. Timing map: `pre-commit` and `pre-push` → before push. `commit-msg` → after `jj describe`.
