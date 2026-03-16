# OMZ

One-line installer for [Oh My Zsh](https://ohmyz.sh/) with a custom theme and curated plugins. Works on Alpine, Arch, Debian, and Fedora based systems.

## Install

```bash
bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/zeevdukeman/omz/main/install.sh?nocache=1')"
```

The installer will prompt you to choose a theme and plugins, with sensible defaults pre-selected.

## What it does

1. Installs `zsh`, `curl`, and `git` if missing (via apk, apt, pacman, or dnf)
2. Sets zsh as your default shell
3. Installs Oh My Zsh (unattended)
4. Lets you choose between the **ohmyz** and **ohmyz-classic** themes
5. Configures `~/.zshrc` with your chosen theme and plugins
6. Clones any third-party plugins that need it

## Default plugins

| Plugin | Description |
|--------|-------------|
| git | Git aliases and functions |
| z | Fast directory jumping |
| sudo | Press `Esc` twice to prefix previous command with `sudo` |
| extract | Extract any archive with a single `extract` command |
| history | History search shortcuts |
| colored-man-pages | Adds color to man pages |
| zsh-autosuggestions | Fish-like command suggestions |
| zsh-syntax-highlighting | Syntax highlighting for commands |

## Themes

Both themes are based on [steeef](https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/steeef.zsh-theme) with git integration, virtualenv display, distrobox indicator, and 256-color support.

### ohmyz (default)

Compact prompt with timestamp:

```
[14:30:05] user@hostname:~/projects/myrepo (main●●)
>
```

### ohmyz-classic

Colorful multi-word prompt:

```
username at hostname in ~/projects/myrepo (main●●)
$
```

### Git status indicators

- Turquoise branch name
- Orange dot: unstaged changes
- Green dot: staged changes
- Pink dot: untracked files

## Prerequisites

The installer automatically installs missing dependencies (`zsh`, `curl`, `git`) using your system's package manager. Supported package managers: `apk`, `apt`, `pacman`, `dnf`.

You'll need `sudo` access if any dependencies are missing.

## License

MIT
