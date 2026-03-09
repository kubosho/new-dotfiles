# Jujutsu (jj) Workflow

**Applicability**: These rules apply only when the project root contains a `.jj` directory (i.e., the repository is managed by Jujutsu).

## Gates

### Pre-write: `jj status`

Every file modification (Edit/Write) requires `jj status` beforehand.

- Working copy empty or belongs to a different task → `jj new main`
- Working copy has changes for the current task → proceed

### Post-squash: `jj log`

Every `jj squash --into` requires `jj log` afterward. The operation rewrites the target commit and bookmarks may detach.

- Bookmark still attached → proceed
- Bookmark detached → `jj bookmark set <name> -r <rev>`

### Pre-push: `jj log` + git hooks

Every `jj git push` requires two checks beforehand:

1. `jj log` — verify bookmark state
   - Bookmark attached to the target commit → proceed
   - Bookmark shows only `<name>@origin` with no local counterpart → push deletes the remote branch. Run `jj bookmark set <name> -r <rev>` first.
2. Git hook runner — jj does not run git hooks automatically. If a hook runner config exists in the project root (e.g., `lefthook.yml`, `.husky/`), run the hooks that correspond to git hook timing manually. Map: `pre-commit` and `pre-push` both fire before `jj git push`; `commit-msg` fires after `jj describe`.

### Example: squash and push

```bash
jj squash --into kkmpxqrs -m "fix: apply focus-visible outline"
jj log --limit 3                                          # post-squash gate
# → bookmark missing from kkmpxqrs → re-attach
jj bookmark set fix/focus -r kkmpxqrs
jj log --limit 3                                          # pre-push gate (1)
# → bookmark attached
<hook-runner> run pre-push                                # pre-push gate (2)
# → checks passed → safe to push
jj git push -b fix/focus
```

## Commands

All commands that accept a message require `-m "message"`. No interactive editor.

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
