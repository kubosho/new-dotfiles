# Personal Preferences

## Language

- Write code comments and commit messages in English

## Code Comments

- When user presents multiple approaches and one is chosen, add comments explaining why other options were not selected

## Programming Languages

- TypeScript/JavaScript: Web Frontend, Backend
- Python: Data analysis
- Go: Backend
- Rust: Desktop app (Tauri)

## Commit Messages

- Use Conventional Commits format (e.g., `feat:`, `fix:`, `docs:`, `refactor:`)
- Explain "why" (the reason/motivation for the change), not just "what"

## Coding Style Priorities

1. Simplicity - Minimal code to achieve the goal
2. Readability - Clear naming and structure
3. Type Safety - Strict type definitions
4. Performance - Efficient execution

## Testing

- Prefer E2E/integration tests over unit tests
- Focus on testing user-facing behavior

## General Guidelines

- Avoid over-engineering
- No unnecessary abstractions
- Delete unused code completely (no backward-compatibility hacks)

## Pull Requests

- Use the `pr-description` skill when writing PR body text

## Plan Files

- Use human-readable filenames for plan files in ~/.claude/plans/ directory
- Format: `YYYY-MM-DD-task-name.md` (e.g., 2026-01-14-add-user-auth.md)
