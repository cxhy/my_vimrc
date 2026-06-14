# my_vimrc

Personal Vim and Git configuration repository.

## Architecture

![my_vimrc architecture](docs/my_vimrc-architecture.svg)

This repository manages:

- `vimrc` -> installs to `~/.vimrc`
- `gitconfig` -> installs to `~/.gitconfig`
- `gitignore_global` -> installs to `~/.gitignore_global`
- `autoload/plug.vim` -> installs to `~/.vim/autoload/plug.vim`
- Source Code Pro in `fonts/source-code-pro/` -> links to `~/.local/share/fonts/my_vimrc/`
- Vim plugins declared in `vimrc` through `vim-plug`

## Requirements

Install these tools on the new machine first:

- `bash`
- `git`
- `vim`
- `fontconfig`, recommended when installing fonts on Linux
- `curl` or `wget`, only needed when `autoload/plug.vim` is missing from this repository

Do not run the installer with `sudo`. The script is intended to configure the
current user account only.

## Clone

Clone the repository to the place where you want to keep the managed
configuration:

```bash
git clone <repo-url> ~/my_vimrc
cd ~/my_vimrc
```

If this repository is managed as `~/.vim`, clone it there instead:

```bash
git clone <repo-url> ~/.vim
cd ~/.vim
```

## Preview

Always preview the changes on a new machine:

```bash
./install.sh --dry-run --skip-plugins
```

The preview shows the files that would be backed up, replaced, linked, or
copied. It does not modify `HOME`.

## Install Vim And Git Config

Recommended first install:

```bash
./install.sh --skip-plugins
```

This installs:

- `~/.vimrc`
- `~/.gitconfig`
- `~/.gitignore_global`
- `~/.vim/autoload/plug.vim`

By default, `~/.vimrc`, `~/.gitconfig`, and `~/.gitignore_global` are installed
as symlinks to this repository. This keeps later repository edits effective
immediately.

If you prefer plain files instead of symlinks:

```bash
./install.sh --copy --skip-plugins
```

## Linux Fonts

The Vim config no longer depends on Monaco on Linux. GUI Vim uses Source Code
Pro on Linux and Monaco on macOS. This repository includes Adobe Source Code Pro
under `fonts/source-code-pro/`.

Terminal Vim does not use `guifont`; set the font in your terminal application
instead after installing the font.

To install the repository fonts for the current Linux user:

```bash
./install_fonts.sh
```

Or include it in the main install:

```bash
./install.sh --install-fonts --skip-plugins
```

By default, fonts are linked into:

```text
~/.local/share/fonts/my_vimrc/
```

For example, a repository font at `fonts/source-code-pro/SourceCodePro-Regular.ttf`
is linked as:

```text
~/.local/share/fonts/my_vimrc/SourceCodePro-Regular.ttf -> /path/to/this/repo/fonts/source-code-pro/SourceCodePro-Regular.ttf
```

If you prefer copies instead of symlinks:

```bash
./install_fonts.sh --copy
```

The script refreshes the user font cache with `fc-cache` when available. It is
fine to download an open-source font into `fonts/` and link it from there. Do
not commit commercial fonts unless their license explicitly allows
redistribution.

## Install Vim Plugins

After confirming that Vim starts correctly, install plugins:

```bash
vim +'PlugInstall --sync' +qa
```

Or run the full installer:

```bash
./install.sh
```

The full installer runs `PlugInstall --sync`. This downloads plugin repositories
and may execute plugin install hooks declared in `vimrc`, such as LeaderF's
`./install.sh` hook.

## Backup And Restore

Before replacing existing config files, `install.sh` creates a timestamped
backup directory:

```text
~/.config_backup/my_vimrc/YYYYmmdd-HHMMSS/
```

Typical backup contents:

```text
.vimrc
.vimrc.replaced
.gitconfig
.gitconfig.replaced
.gitignore_global
.gitignore_global.replaced
```

To restore manually:

```bash
cp -a ~/.config_backup/my_vimrc/<timestamp>/.vimrc ~/.vimrc
cp -a ~/.config_backup/my_vimrc/<timestamp>/.gitconfig ~/.gitconfig
cp -a ~/.config_backup/my_vimrc/<timestamp>/.gitignore_global ~/.gitignore_global
```

If the current files are symlinks and you want to replace them with the backups,
move the symlinks away first:

```bash
mv ~/.vimrc ~/.vimrc.from-my_vimrc
mv ~/.gitconfig ~/.gitconfig.from-my_vimrc
mv ~/.gitignore_global ~/.gitignore_global.from-my_vimrc
cp -a ~/.config_backup/my_vimrc/<timestamp>/.vimrc ~/.vimrc
cp -a ~/.config_backup/my_vimrc/<timestamp>/.gitconfig ~/.gitconfig
cp -a ~/.config_backup/my_vimrc/<timestamp>/.gitignore_global ~/.gitignore_global
```

## Installer Options

```text
./install.sh [options]

Options:
  --link            Install config files as symlinks (default).
  --copy            Install config files as plain file copies.
  --install-fonts   Link font files from fonts/ into the user font directory.
  --skip-vim-plug   Do not install ~/.vim/autoload/plug.vim.
  --skip-plugins    Do not run Vim PlugInstall.
  --dry-run         Print actions without changing files.
  -h, --help        Show help.
```

## Safety Notes

`install.sh` only writes under the current user's `HOME`:

```text
~/.vimrc
~/.gitconfig
~/.gitignore_global
~/.vim/autoload/plug.vim
~/.local/share/fonts/my_vimrc/
~/.config_backup/my_vimrc/
```

It does not write system directories and does not remove existing config files
without first placing a backup under `~/.config_backup/my_vimrc/`.

Plugin installation has a wider trust boundary because Vim plugins are cloned
from the network and plugin install hooks may execute code. Use
`./install.sh --skip-plugins` first if you want to inspect the environment
before installing plugins.

## Verification

After installation:

```bash
readlink ~/.vimrc
readlink ~/.gitconfig
readlink ~/.gitignore_global
test -f ~/.vim/autoload/plug.vim
vim +'PlugStatus' +qa
git config --global --list
```

If config files are installed with `--copy`, `readlink` will not print anything
for those files. In that case, compare the files directly:

```bash
cmp vimrc ~/.vimrc
cmp gitconfig ~/.gitconfig
cmp gitignore_global ~/.gitignore_global
```
