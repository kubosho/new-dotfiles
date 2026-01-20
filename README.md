# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Overview

### Features

- macOS support
- Declarative dotfile management with chezmoi
- Development tools managed via devbox
- Starship prompt with Jujutsu VCS integration

## Usage

### Setup

1. Install chezmoi and initialize with this repository:

```bash
chezmoi init https://github.com/kubosho/new-dotfiles.git
```

2. Preview changes:

```bash
chezmoi diff
```

3. Apply dotfiles:

```bash
chezmoi apply
```

4. Restart your shell or run `source ~/.zshrc`

### Adding new dotfiles

```bash
chezmoi add ~/.your-config-file
```

### Editing managed files

```bash
chezmoi edit ~/.your-config-file
```

## License

[WTFPL](LICENSE)
