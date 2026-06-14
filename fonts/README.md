# Fonts

Put Linux user-installable font files here when needed.

This repository currently includes Adobe Source Code Pro under
`source-code-pro/`. The upstream project is:

```text
https://github.com/adobe-fonts/source-code-pro
```

Keep the upstream `LICENSE.md` with the font files.

Supported file types:

- `.ttf`
- `.otf`
- `.ttc`

Use open-source or otherwise redistributable fonts only. Do not commit
commercial system fonts unless their license explicitly allows it.

Install fonts for the current user:

```bash
./install_fonts.sh
```

The installer links fonts into:

```text
~/.local/share/fonts/my_vimrc/
```

Use `./install_fonts.sh --copy` if you prefer plain copies.

Then it refreshes the font cache with `fc-cache` when available.
