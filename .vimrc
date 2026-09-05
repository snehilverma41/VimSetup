" =============================================================================
"  .vimrc — portable Vim configuration
"  Works on: macOS + Linux, Vim 8.2+ and Neovim, GUI and terminal.
"
"  Layout:  1. bootstrap   2. plugins   3. options   4. appearance
"           5. mappings    6. text objects   7. hooks   8. cscope
"           9. machine-local overrides
"
"  Machine-specific settings do NOT belong in this file. Put them in
"  ~/.vim/local.vim (see section 9) — that file is gitignored.
" =============================================================================

" 'encoding' must be set before any buffer or plugin is loaded, otherwise
" already-loaded text gets re-interpreted. Keep this first.
set encoding=utf-8
scriptencoding utf-8
set nocompatible

" <leader> must be defined before any mapping that uses it, because mappings
" resolve <leader> at definition time, not at press time.
let g:mapleader = ','
let g:maplocalleader = '\'

" =============================================================================
"  1. BOOTSTRAP
" =============================================================================
" Neovim and Vim read different config trees. Resolve ours, then make sure
" vim-plug is present *on the runtimepath Vim actually reads* before using it.
if has('nvim')
  let s:vimdir = stdpath('config')
else
  let s:vimdir = expand('~/.vim')
endif
let s:plugfile = s:vimdir . '/autoload/plug.vim'
let s:plugdir  = s:vimdir . '/plugged'

if empty(glob(s:plugfile))
  if executable('curl')
    silent execute '!curl -fLo ' . shellescape(s:plugfile) . ' --create-dirs'
          \ . ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    " Only schedule the first install if the download actually produced a file.
    " curl -f writes nothing on an HTTP error, so without this check a failed
    " download would leave a VimEnter autocmd calling a :PlugInstall that was
    " never defined (E492) on every subsequent startup.
    if filereadable(s:plugfile)
      augroup plug_bootstrap
        autocmd!
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
      augroup END
    else
      echomsg 'vimrc: could not download vim-plug — plugins are disabled.'
            \ 'Check your network, then restart vim.'
    endif
  else
    echomsg 'vimrc: curl not found — install vim-plug manually, plugins are disabled'
  endif
endif

" =============================================================================
"  2. PLUGINS
" =============================================================================
" Plugins that need an external program or a Vim feature are declared
" conditionally, so this file stays valid on a machine that lacks them.
if filereadable(s:plugfile)
call plug#begin(s:plugdir)

" --- appearance ---
Plug 'vim-airline/vim-airline'                                       " Status/tabline
Plug 'vim-airline/vim-airline-themes'                                " Themes for the above
Plug 'flazz/vim-colorschemes'                                        " Colorscheme grab-bag (provides 256-jungle)
Plug 'altercation/vim-colors-solarized'                              " Solarized
Plug 'lanox/lanox-vim-theme'                                         " Lanox

" --- editing ---
Plug 'preservim/nerdcommenter'                                       " Comment fast and professionally
Plug 'preservim/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFocus']}
                                                                     " ^ both commands must be listed or <F3> is undefined
Plug 'tpope/vim-surround'                                            " Quick surround with tags or brackets
Plug 'easymotion/vim-easymotion'                                     " Quick jumping between lines
Plug 'myusuf3/numbers.vim'                                           " Auto-toggle relative/absolute numbering
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}                     " Graphical undo tree (pure Vimscript)
Plug 'vim-scripts/auto-pairs-gentle'                                 " Auto insert matching brackets
Plug 'gioele/vim-autoswap'                                           " Handle swap-file prompts intelligently
Plug 'godlygeek/tabular'                                             " Alignment (also a vim-markdown dependency)
Plug 'mg979/vim-visual-multi', {'branch': 'master'}                  " Multiple cursors, Sublime style
Plug 'ctrlpvim/ctrlp.vim'                                            " Fast fuzzy file searching
Plug 'vim-scripts/cmdalias.vim'                                      " Aliases for accidental commands
Plug 'tpope/vim-fugitive'                                            " Git wrapper

" --- snippets (snipmate needs both of these) ---
Plug 'marcweber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'                                           " Snippets for reusable code

" --- languages ---
Plug 'octol/vim-cpp-enhanced-highlight', {'for': ['c', 'cpp']}       " Enhanced C++ highlighting
Plug 'preservim/vim-markdown', {'for': 'markdown'}                   " Better Markdown (needs tabular)
Plug 'rhysd/vim-llvm', {'for': ['llvm', 'tablegen', 'mlir', 'mir']}  " LLVM highlighting
Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}                   " CoffeeScript
Plug 'KabbAmine/zeavim.vim', {'on': ['Zeavim', 'Docset']}            " Offline documentation lookup

if executable('go')
  Plug 'fatih/vim-go', {'for': 'go', 'do': ':GoUpdateBinaries'}      " Go tooling (installs gopls, goimports, ...)
endif
if executable('flake8')
  Plug 'nvie/vim-flake8', {'for': 'python'}                          " PEP8 checking
endif
if has('python3')
  Plug 'jceb/vim-orgmode', {'for': 'org'}                            " OrgMode (hard-requires +python3)
endif

call plug#end()
endif

" =============================================================================
"  3. OPTIONS
" =============================================================================
syntax on
filetype plugin indent on

" --- indentation ---
set shiftwidth=4                                                     " Width of one indent level
set softtabstop=4                                                    " <Tab> feels like 4 spaces
set expandtab                                                        " Insert spaces, never a literal tab
set autoindent
" 'smartindent' is deliberately NOT set: the filetype indent plugins enabled
" above supersede it, and where they don't it misindents (it force-outdents
" lines starting with '#', which breaks Python comments).

" --- searching ---
set ignorecase                                                       " Ignore case while searching
set smartcase                                                        " ...unless the pattern has a capital
set incsearch                                                        " Search as you type
set nohlsearch                                                       " Don't leave matches highlighted

" --- display ---
set number                                                           " Line numbers
set relativenumber                                                   " Hybrid numbering with the above
set nowrap
set scrolloff=10                                                     " Keep 10 lines of context around the cursor
set laststatus=2                                                     " Always show the status line
set wildmenu                                                         " Tab-completion menu for commands
set splitbelow splitright                                            " Open splits where the eye expects them
set backspace=indent,eol,start                                       " Make backspace work everywhere
set hidden                                                           " Allow abandoning modified buffers
set mouse=nv                                                         " Mouse in normal and visual modes
set updatetime=300                                                   " Faster swap write / CursorHold

" 'timeoutlen' governs mapping sequences; 'ttimeoutlen' governs terminal key
" codes. This config uses multi-key sequences (,y  ,;  in(  ...) so the default
" 1000ms makes their prefixes feel stuck. Lower the first, keep the second low
" so <Esc> is never mistaken for the start of a key code.
set timeout timeoutlen=400 ttimeoutlen=50

" --- folding ---
set foldmethod=syntax                                                " Syntax-aware folds — toggle with za
set foldlevel=9999                                                   " ...but start fully open

" --- files Vim should never offer ---
" Patterns in 'wildignore' are matched against the tail as well as the path, so
" a bare word like `main` would hide every file named main anywhere. Anchor
" build outputs by extension or by directory instead.
set wildignore+=*/__pycache__/*,*.pyc,*.pyo,*.o,*.so,*.a,*.swp
set wildignore+=*/node_modules/*,*/.git/*,*/bin/*

" --- tags ---
" './tags;' searches upward from the directory of the file being edited (right
" for multi-repo work); 'tags;' searches upward from the cwd as a fallback.
set tags=./tags;,tags;

" --- swap / backup / undo ---
" Keep all state in one place instead of scattering it through the working
" directory. Vim does not create these, so make them first.
let s:state = expand('~/.local/state/vim')
for s:sub in ['swap', 'backup', 'undo']
  if !isdirectory(s:state . '/' . s:sub)
    call mkdir(s:state . '/' . s:sub, 'p', 0700)
  endif
endfor
" The trailing '//' makes Vim encode the file's full path into the state-file
" name, so two files with the same basename can't collide.
set directory=~/.local/state/vim/swap//
set backupdir=~/.local/state/vim/backup//
set undodir=~/.local/state/vim/undo//
if has('persistent_undo')
  set undofile                                                       " Undo survives closing the file
  set undolevels=10000
  set undoreload=100000
endif

" netrw writes a history file into ~/.vim on every exit, which shows up as repo
" churn in a dotfiles checkout. Turn it off.
let g:netrw_dirhistmax = 0

" =============================================================================
"  4. APPEARANCE
" =============================================================================
" On a fresh machine the colorscheme's plugin is not installed yet, so this
" must not be fatal — an unguarded :colorscheme leaves a 'Press ENTER' prompt
" on every startup until :PlugInstall runs. Fall back to a scheme Vim bundles.
silent! colorscheme 256-jungle
if !exists('g:colors_name')
  silent! colorscheme habamax
endif

let g:airline_theme = 'jellybeans'
let g:airline#extensions#tabline#enabled = 1                         " Show buffers along the top
" g:airline_powerline_fonts is NOT set here: the glyphs render as tofu boxes on
" any machine without a patched font. install.sh detects the font and sets it in
" ~/.vim/local.vim. Default to the ASCII separators, which always render.
let g:airline_symbols_ascii = 1

if has('gui_running')
  " Font syntax is toolkit-specific: MacVim wants Name:h<size>, GTK wants
  " 'Name <size>'. Setting the wrong one is a silent no-op.
  if has('gui_macvim')
    set guifont=MesloLGS\ Nerd\ Font:h13
  else
    set guifont=MesloLGS\ Nerd\ Font\ 13
  endif
  set guioptions-=m                                                  " No menu bar
  set guioptions-=T                                                  " No toolbar
  set guioptions-=r                                                  " No right scrollbar
  set guioptions-=L                                                  " No left scrollbar
endif

let g:NERDTreeIgnore = ['\.pyc$', '__pycache__', '\.o$']
let g:go_fmt_command = 'goimports'                                   " Fix imports on save
let g:go_version_warning = 0

" =============================================================================
"  5. MAPPINGS
" =============================================================================
" Start commands with ; instead of :
nnoremap ; :
" ...and keep the two things ; and , normally do (repeat f/t forward and back).
" Both are needed: ',' is the leader here, so bare ',' is a mapping prefix and
" would otherwise stall for 'timeoutlen' before falling back to reverse-find.
nnoremap ,; ;
nnoremap ,. ,

" Enter inserts a blank line below, without entering insert mode.
" NOTE: <CR>, <C-M>, <Return> and <Enter> are four spellings of ONE key (0x0D).
" Nothing else in this file may map any of them, or this mapping is silently
" replaced. The trailing-whitespace strip that used to live on <C-M> is on
" <leader>w below.
nnoremap <CR> o<Esc>

" Enter has a real job in these buffers (jump to the quickfix entry, execute
" the command-line-window line), and the global mapping above shadows it.
" Restore it buffer-locally.
augroup restore_cr
  autocmd!
  autocmd FileType qf     nnoremap <buffer> <CR> <CR>
  autocmd CmdwinEnter *    nnoremap <buffer> <CR> <CR>
augroup END

" Strip trailing whitespace, preserving the search register and the view so the
" cursor doesn't jump and your last search isn't clobbered.
nnoremap <silent> <leader>w :let _s=@/<Bar>let _v=winsaveview()<Bar>
      \ %s/\s\+$//e<Bar>let @/=_s<Bar>call winrestview(_v)<CR>

inoremap jk <Esc>

" Uppercase the word under the cursor.
" This used to sit on insert-mode <C-U>, which is a core Vim key (delete all
" text entered on this line), so it moved here. Of Vim's insert-mode CTRL-G
" submodes only j/k/u/U/CTRL-J/CTRL-K are taken, so <C-G>w is free. 'gi'
" returns to exactly where insert mode left off; 'ea' would not.
inoremap <C-g>w <Esc>viwUgi
nnoremap <leader>U mzviwU`z

" Cycle buffers with Tab / Shift-Tab.
" NOTE: <Tab> IS <C-I> in a terminal, so this gives up the built-in
" jump-forward through the jumplist (the partner of <C-O>). That is a deliberate
" trade. There is no mark round-trip here: lowercase marks are buffer-local, so
" setting one before :bnext and jumping to it after raises E20 — and :bnext
" already restores the target buffer's own last cursor position.
nnoremap <silent> <Tab>   :bnext<CR>
nnoremap <silent> <S-Tab> :bprevious<CR>

" Comment / uncomment. Bound to the plugin's <Plug> target rather than to
" <leader>ci, so a missing plugin is a silent no-op instead of a beep followed
" by a pending change-operator that eats your next keystroke.
nmap <leader>c <Plug>NERDCommenterInvert
xmap <leader>c <Plug>NERDCommenterInvert

" EasyMotion. Bound through <Plug> for the same reason, and because the old
" `nmap ,, <leader><leader>s` becomes infinitely recursive once <leader> is ','.
nmap <leader><leader> <Plug>(easymotion-s)

nnoremap <F2> :NERDTreeToggle<CR>
inoremap <F2> <Esc>:NERDTreeToggle<CR>a
nnoremap <F3> :NERDTreeFocus<CR>
nnoremap <F4> :set wrap!<CR>                                         " Toggle wrapping
nnoremap <F5> :buffers<CR>:buffer<Space>                             " List buffers and switch
nnoremap <F8> :UndotreeToggle<CR>                                    " Undo tree
nnoremap <F9> :set cul!<CR>                                          " Toggle cursor-line highlight
nnoremap <F10> mmgg=G`m                                              " Reindent the whole file
inoremap <F10> <Esc>mmgg=G`ma

" Replace the current line with the output of running it through the shell
nnoremap Q !!sh<CR>

" Close the innermost open HTML/XML tag
inoremap <// </<C-X><C-O><C-[>m'==`'

" Write the current file through sudo.
" This is a command, not a `cmap`: a command-line mapping for `w!!` fires
" everywhere in command-line mode — inside a :s// replacement, a search, an
" expression — not just at the start of a : command.
command! W w !sudo tee > /dev/null %

"                        ---------- CLIPBOARD ----------
" Normal mode needs the doubled operator (yy/dd are line-wise commands);
" visual mode must NOT have it. In visual mode "+y already completes the yank
" and leaves visual mode, so a trailing y starts a *new* pending operator that
" silently swallows your next keypress — pressing V ,d j deleted three lines.
nnoremap <leader>y "+yy
xnoremap <leader>y "+y
nnoremap <leader>d "+dd
xnoremap <leader>d "+d
nnoremap <leader>p "+p
xnoremap <leader>p "+p
nnoremap <leader>P "+P
xnoremap <leader>P "+P
" Visual-mode only, non-recursive, and no stray trailing quote — a `"` on a
" mapping's RHS is part of the mapping, not a comment, and left Vim waiting for
" a register name.
xnoremap <C-c> "+y

" =============================================================================
"  6. TEXT OBJECTS (operator-pending + visual)
" =============================================================================
" in( / an( — operate on the NEXT bracket pair
" il( / al( — operate on the LAST (previous) bracket pair
"
" 'il'/'al' are used rather than 'ip'/'ap' because ip and ap are built-in text
" objects (inner paragraph / a paragraph). Defining ip( would make 'ip' a
" mapping prefix, so dip, yip, cip, dap, yap and cap would each stall for
" 'timeoutlen' before the built-in fired.
for [s:key, s:open, s:close] in [['(', '(', ')'], ['{', '{', '}'],
      \ ['"', '"', '"'], ["'", "'", "'"], ['`', '`', '`']]
  " next block
  execute 'onoremap in' . s:key . ' :<C-u>normal! f' . s:open . 'vi' . s:open . '<CR>'
  execute 'xnoremap in' . s:key . ' :<C-u>normal! f' . s:open . 'vi' . s:open . '<CR>'
  execute 'onoremap an' . s:key . ' :<C-u>normal! f' . s:open . 'va' . s:open . '<CR>'
  execute 'xnoremap an' . s:key . ' :<C-u>normal! f' . s:open . 'va' . s:open . '<CR>'
  " previous block
  execute 'onoremap il' . s:key . ' :<C-u>normal! F' . s:close . 'vi' . s:open . '<CR>'
  execute 'xnoremap il' . s:key . ' :<C-u>normal! F' . s:close . 'vi' . s:open . '<CR>'
  execute 'onoremap al' . s:key . ' :<C-u>normal! F' . s:close . 'va' . s:open . '<CR>'
  execute 'xnoremap al' . s:key . ' :<C-u>normal! F' . s:close . 'va' . s:open . '<CR>'
endfor

" =============================================================================
"  7. ABBREVIATIONS
" =============================================================================
iabbrev @@g snehilverma41@gmail.com
iabbrev @@i snehilv@iitk.ac.in
iabbrev @@c snehilv@cse.iitk.ac.in
iabbrev @@u snehilv@utexas.edu

" =============================================================================
"  8. HOOKS
" =============================================================================
augroup filetype_tweaks
  autocmd!
  " Vim's bundled Python syntax file defines no fold regions, so the global
  " 'foldmethod=syntax' yields no folds at all for Python. Use indent folding
  " there instead. (The old fix was a 2006 plugin that replaced the whole
  " syntax file and took Python-2-era highlighting with it.)
  autocmd FileType python setlocal foldmethod=indent

  " <buffer> matters: without it, opening one .tex file rebinds <F3> for every
  " other buffer in the session and destroys :NERDTreeFocus above.
  if executable('pdflatex')
    autocmd FileType tex nnoremap <buffer> <F3> mm:w<CR>:!pdflatex<Space>%<CR><CR>`m
  endif
augroup END

" =============================================================================
"  9. CSCOPE
" =============================================================================
" Guarded on the binary as well as the feature: adding a stale or foreign
" cscope.out is an error at startup, not a warning.
if has('cscope') && executable('cscope')
  set cscopetag                                                      " Use cscope for <C-]> and :tag
  set csto=0                                                         " Search cscope before ctags
  set cscopeverbose

  if filereadable('cscope.out')
    silent! cs add cscope.out
  elseif !empty($CSCOPE_DB)
    silent! cs add $CSCOPE_DB
  endif

  " <C-\><query>  — search, show the result in this window
  " <C-@><query>  — same, in a horizontal split   (<C-@> is CTRL-Space)
  " <C-@><C-@>    — same, in a vertical split
  "   s symbol   g global definition   c calls to   t text
  "   e egrep    f file                i includers  d called by
  for s:q in ['s', 'g', 'c', 't', 'e', 'd']
    execute 'nnoremap <C-\>' . s:q . ' :cs find ' . s:q . ' <C-R>=expand("<cword>")<CR><CR>'
    execute 'nnoremap <C-@>' . s:q . ' :scs find ' . s:q . ' <C-R>=expand("<cword>")<CR><CR>'
    execute 'nnoremap <C-@><C-@>' . s:q . ' :vert scs find ' . s:q . ' <C-R>=expand("<cword>")<CR><CR>'
  endfor
  " f and i act on the filename under the cursor, not the word
  nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
  nnoremap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
  " '^...$' so #include <time.h> doesn't also match sys/time.h
  nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
  nnoremap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
endif

" =============================================================================
"  10. MACHINE-LOCAL OVERRIDES
" =============================================================================
" Anything that is true of one machine but not the others goes here, so this
" file can stay identical everywhere. install.sh generates it (font detection);
" add your own settings below whatever it writes. Gitignored — sourced last so
" it wins over everything above.
if filereadable(expand('~/.vim/local.vim'))
  source ~/.vim/local.vim
endif
