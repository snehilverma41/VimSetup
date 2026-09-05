# VimSetup

My Vim configuration, kept in one place so every machine gets the same editor.
Works on macOS and Linux, in Vim 8.2+ and Neovim, terminal and GUI.

## Install

```sh
git clone https://github.com/snehilverma41/VimSetup.git ~/.dotfiles/VimSetup
~/.dotfiles/VimSetup/install.sh
```

That's it — `install.sh` bootstraps vim-plug and installs the plugins itself.
Clone it wherever you like; the script figures out its own location.

Want to see what it would do first?

```sh
./install.sh --dry-run
```

To back out:

```sh
./uninstall.sh              # remove the symlinks, restore any backups
./uninstall.sh --purge      # also delete plugins and undo/swap history
```

## Verifying it works

```sh
./test.sh                   # test the repo's .vimrc
./test.sh --installed       # test whatever is currently at ~/.vimrc
```

77 checks, run against a throwaway `$HOME`, so it's safe before installing.
It checks that the vimrc loads clean, that every mapping resolves to what it
should, and — the part that matters — that the mappings actually *behave*
correctly when the keys are pressed.

That last part is the reason the file exists. Several mappings here used to look
right and do the wrong thing at runtime: a visual-mode `"+yy` that swallowed the
next keypress, a `<C-M>` that was secretly the same key as `<CR>`, a stray `"`
that left Vim waiting for a register name. A mapping table can't catch those —
you have to press the keys and count the lines.

### What install.sh does

- Symlinks `.vimrc` → `~/.vimrc`, and each entry in `.vim/` → `~/.vim/`.
- Symlinks the same `.vimrc` → `~/.config/nvim/init.vim` if Neovim is installed,
  so there is only ever one config file to maintain.
- Writes `~/.vim/local.vim` for machine-specific settings (see below).
- Runs `:PlugInstall`.

It is **safe to re-run**. Correct symlinks are left alone, and anything real
already sitting at a target path is moved to `<name>.backup.<timestamp>` rather
than overwritten. Nothing is ever deleted.

Symlinks matter here: the installed config stays *inside* the git checkout, so
`git pull` updates the machine and `git diff` shows local tweaks. (An earlier
version of this repo did `mv ~/VimSetup/* ~/.`, which severed that connection —
and, because `.git` was the only thing matching `.gi*`, moved the repository's
own git directory into `$HOME`.)

## Machine-local settings

Anything true of one machine but not the others goes in `~/.vim/local.vim`,
which is gitignored and sourced last, so it overrides everything:

```vim
" ~/.vim/local.vim
colorscheme solarized
let g:go_bin_path = '/opt/go/bin'
```

`install.sh` generates the top of this file (it detects whether a patched font
is installed and sets the airline glyphs accordingly). Add your own settings
*below* the marker line it writes — those are preserved when you re-run it.

## Fonts

vim-airline's separators are Powerline glyphs, which need a patched font or they
render as tofu boxes. `install.sh` detects whether you have one and configures
airline to match, so a machine without a font gets a clean ASCII statusline
instead of garbage.

To install one:

```sh
# macOS
brew install --cask font-meslo-lg-nerd-font
# Debian/Ubuntu
sudo apt-get install fonts-powerline
```

Then point your terminal at it (iTerm2: Preferences → Profiles → Text → Font)
and re-run `install.sh` to pick up the change.

## Key mappings

`<leader>` is `,`.

### Getting around

| Key | Does |
| --- | --- |
| `;` | `:` — start a command |
| `,;` / `,.` | repeat last `f`/`t` search forward / backward |
| `<Tab>` / `<S-Tab>` | next / previous buffer |
| `,,` | EasyMotion jump to any character |
| `<F5>` | list buffers, then pick one |
| `<F2>` | toggle NERDTree |
| `<F3>` | focus NERDTree (or, in a `.tex` file, run `pdflatex`) |

`<Tab>` for buffer switching costs you `<C-I>` (jump forward through the
jumplist) — in a terminal they are the same keystroke. `<C-O>` still works.

### Editing

| Key | Does |
| --- | --- |
| `<CR>` | insert a blank line below, staying in normal mode |
| `jk` | leave insert mode |
| `,c` | comment / uncomment (normal and visual) |
| `,w` | strip trailing whitespace from the file |
| `,U` | uppercase the word under the cursor |
| `<C-g>w` | same, from insert mode |
| `<F10>` | reindent the whole file |
| `<F4>` | toggle line wrapping |
| `<F8>` | toggle the undo tree |
| `<F9>` | toggle cursor-line highlight |
| `Q` | replace the current line with the output of running it as a shell command |
| `<//` | close the innermost open HTML/XML tag |
| `:W` | write the current file through `sudo` |

### System clipboard

`,y` `,d` `,p` `,P` yank / cut / paste / paste-before via the `+` register, in
both normal and visual mode. `<C-c>` in visual mode also yanks to the clipboard.

### Text objects

`in(` operates on the **next** bracket pair, `il(` on the **last** one; `an(`
and `al(` include the brackets themselves. Works with `(`, `{`, `"`, `'`, and
`` ` ``, in both operator-pending and visual mode — so `din{`, `yil"`, `can(`.

These use `il`/`al` rather than `ip`/`ap` because `ip` and `ap` are built-in
text objects (inner/a paragraph), and shadowing them would make `dip`, `yap`
and friends stall for a second before firing.

### cscope

Active only when the `cscope` binary is present.
`<C-\>` then a query letter searches in the current window; `<C-@>` (Ctrl-Space)
splits horizontally; `<C-@><C-@>` splits vertically.

| Letter | Finds |
| --- | --- |
| `s` | all references to the symbol under the cursor |
| `g` | its global definition |
| `c` | functions that call it |
| `d` | functions it calls |
| `t` | the text, anywhere |
| `e` | egrep for it |
| `f` | the file under the cursor |
| `i` | files that `#include` the file under the cursor |

## Plugins

Managed by [vim-plug](https://github.com/junegunn/vim-plug), installed into
`~/.vim/plugged` (`~/.config/nvim/plugged` under Neovim). Neither directory is
tracked by git — vim-plug fetches them.

Seventeen plugins, and every one of them does something on every machine. That's
deliberate: anything that only worked given a tool or a Vim feature that isn't
always present has been removed rather than left declared-but-inert.

<details>
<summary>Full list</summary>

**Appearance** — vim-airline, vim-airline-themes, vim-colorschemes
(973 schemes, including `256-jungle` and `solarized`)

**Editing** — nerdcommenter, nerdtree, vim-surround, vim-easymotion,
numbers.vim, undotree, auto-pairs-gentle, vim-autoswap, tabular,
vim-visual-multi, ctrlp.vim, vim-fugitive

**Languages** — vim-markdown, vim-llvm

</details>

<details>
<summary>What was removed, and why</summary>

Non-functional — these never worked, or actively broke things:

| Plugin | Why |
| --- | --- |
| `kiteco/plugins` | Kite is defunct; the repo contains no plugin code at all |
| `powerline/powerline` | A Python package, not a Vim plugin — its root has no `plugin/` or `autoload/`, so adding it to runtimepath did nothing |
| `Python-Syntax-Folding` | Replaced Vim 9.1's bundled Python syntax with a 2006 copy |
| `vim-bracketed-paste` | Native since Vim 8.0.210, and the plugin fights the native handling |
| `rust.vim` | Vim 9.1 bundles newer copies of the same files, and the plugin shadowed them |
| `~/new_proj/vim/autorun` | A local path that exists on no machine |

Replaced — same capability, maintained upstream:

| Was | Now | Why |
| --- | --- | --- |
| `sjl/gundo.vim` | `mbbill/undotree` | gundo requires `+python`, which stock macOS vim lacks; undotree is pure Vimscript |
| `terryma/vim-multiple-cursors` | `mg979/vim-visual-multi` | deprecated by its author, by name |
| `Superbil/llvm.vim` | `rhysd/vim-llvm` | the old one shipped LLVM's *example vimrc* as a `plugin/` file, clobbering global options |

Retargeted to canonical owners (the old paths only worked via GitHub rename
redirects, which break if anyone recreates the old name): nerdtree,
nerdcommenter and vim-markdown → `preservim`; vim-easymotion → `easymotion`;
vim-airline → `vim-airline`; ctrlp.vim → `ctrlpvim`; autoswap.vim →
`gioele/vim-autoswap`.

Dropped as unused: `vim-orgmode` (needs `+python3`, unmaintained since 2019),
`vim-coffee-script`, `zeavim.vim` (Zeal is Linux-only), `cmdalias.vim` (declared
but never called), `vim-snipmate` + `vim-addon-mw-utils` + `tlib_vim` (three
plugins, zero snippets defined), `vim-cpp-enhanced-highlight` (archived; Vim
9.1's bundled C++ syntax is newer), `vim-flake8` (superseded by ruff),
`vim-go` (no Go on any current machine), and `vim-colors-solarized` +
`lanox-vim-theme` (both already in vim-colorschemes).

</details>

## Shell prompt

Not installed by this repo — paste it in yourself. For **bash**, at the end of
`~/.bashrc`:

```bash
if [[ $- == *i* ]]; then
  export PS1="\[\033[38;5;11m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;10m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;6m\][\w\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\]\[\033[38;5;6m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]\\$ \[$(tput sgr0)\]"
fi
```

The `[[ $- == *i* ]]` guard keeps it out of non-interactive shells, where
`tput` has no terminal and
[errors out](https://askubuntu.com/questions/591937/no-value-for-term-and-no-t-specified).

macOS ships **zsh**, where those `\[...\]` escapes are not valid. Use this in
`~/.zshrc` instead:

```zsh
setopt PROMPT_SUBST
PROMPT='%F{11}%n%f%F{15}@%f%F{10}%m%f%F{15}:%f%F{6}[%~]%f%F{15}$%f '
```

## Terminal colors

```
Text:       #C3D0D1
Background: #002B36
```

The default colorscheme is `256-jungle`, from
[vim-colorschemes](https://github.com/flazz/vim-colorschemes). It's a 256-color
scheme, so `termguicolors` is deliberately left off — enabling it would make a
cterm-only scheme render with the wrong colors. If you switch to a truecolor
scheme, turn it on in `~/.vim/local.vim`.
