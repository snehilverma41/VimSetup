if empty(glob('~/.nvim/autoload/plug.vim'))
    !curl -fLo ~/.nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif
set ttimeoutlen=50
let g:python_host_prog='/usr/bin/python2'
call plug#begin('~/.nvim/plugged')
Plug 'kiteco/plugins'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
Plug 'lanox/lanox-vim-theme'
Plug 'scrooloose/nerdcommenter'                                      " Comment fast and professionally
Plug 'scrooloose/nerdtree' , {'on': 'NERDTreeToggle'}                " Proper file explorer inside vim
Plug 'flazz/vim-colorschemes'                                        " All popular Colorscheme
Plug 'tpope/vim-surround'                                            " Quick Surround with tags or Brackets
Plug 'octol/vim-cpp-enhanced-highlight'                              " Enhanced syntax highlight for CPP files
Plug 'Lokaltog/vim-easymotion'                                       " Quick jumping between lines
Plug 'myusuf3/numbers.vim'                                           " Auto Toggle between relative and normal numbering
Plug 'sjl/gundo.vim'                                                 " Graphical undo tree
Plug 'marcweber/vim-addon-mw-utils'                                  " Vim Addons
Plug 'garbas/vim-snipmate'                                           " Snippets for reusable code
Plug 'tpope/vim-fugitive'                                            " Git Wrapper
Plug 'tomtom/tlib_vim'                                               " Needed for SnipMate :(
Plug 'vim-scripts/auto-pairs-gentle'                                 " Auto insert matching brackets
Plug 'vim-scripts/autoswap.vim'                                      " Make vim stop with swap messages intelligently
Plug 'godlygeek/tabular'                                             " Beautiful Alignment when needed
Plug 'plasticboy/vim-markdown'                                       " Better Markdown support for vim (NEEDS TABULAR)
Plug 'jceb/vim-orgmode'                                              " Add OrgMode support like Emacs
Plug 'vim-scripts/cmdalias.vim'                                      " Set up alias for accidental commands
Plug 'vim-scripts/Python-Syntax-Folding'                             " Proper syntax folding for python
Plug 'nvie/vim-flake8'                                               " Point out PEP8 inconsistencies
Plug 'bling/vim-airline'                                             " Who doesn't know about vim airline plugin
Plug 'kien/ctrlp.vim'                                                " Fast fuzzy file searching
Plug 'terryma/vim-multiple-cursors'                                  " Multiple Cursors like Sublime Text
Plug 'kchmck/vim-coffee-script'                                      " Highlighting and syntax for coffeescript
Plug 'fatih/vim-go'                                                  " Go completion and features
Plug 'KabbAmine/zeavim.vim'                                          " Direct documentation access
Plug 'Superbil/llvm.vim', { 'for': 'llvm' }                          " LLVM highlighting
Plug '~/new_proj/vim/autorun'
Plug 'powerline/powerline'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'rust-lang/rust.vim'                                            " Rust highlighting
call plug#end()                                                      " Vundle ends here

set shiftwidth=4                                                     " Indentation
syntax on
filetype plugin indent on
"set background=dark
colorscheme 256-jungle                                              " Set active Colorscheme
nnoremap ,; ;
                                                                     " start commands with ; not :
nnoremap ; :
                                                                     " Turn word to uppercase in insert mode
inoremap <c-u> <Esc>viwUea
                                                                     " Toggle NERDTree without python compile files
inoremap <F2> <Esc>:NERDTreeToggle<CR>a
                                                                     " Toggle NERDTree without python compile files
nnoremap <F2> :NERDTreeToggle<CR>

nnoremap <F3> :NERDTreeFocus<CR>
                                                                    " Turn on/off wrapping
nnoremap <F4> :set wrap!<CR>
                                                                     " Show open buffers and help in quick switching
nnoremap <F5> :buffers<CR>:buffer<Space>
                                                                     " Turn on/off current line highlight
nnoremap <F9> :set cul!<CR>
                                                                     " Indent everything in insert mode
inoremap <F10> <Esc>mmgg=G`ma
                                                                     " Indent everything in normal mode
nnoremap <F10> <Esc>mmgg=G`m
                                                                     " comment current line with //
nmap // <leader>ci
                                                                     " comment current selection with //
vmap // <leader>ci
                                                                     " w!! force write with sudo even if forgot sudo vim
cmap w!! w !sudo tee > /dev/null %
                                                                     " Easy Motion shortcut. Try it!
nmap ,, <leader><leader>s

inoremap jk <Esc>
nnoremap <CR> o<Esc>
nnoremap  <silent>   <tab>  mq:bnext<CR>`q
nnoremap  <silent> <s-tab>  mq:bprevious<CR>`q
                                                                     " Switch buffers with Tab and Shift-Tab
inoremap <// </<C-X><C-O><C-[>m'==`'
nnoremap Q !!sh<CR>
                                                                     " Replace current line with output of shell

                        " --------------------------------CONFIGS----------------------------- "

let NERDTreeIgnore=['\.pyc$', '__pycache__', '\.o']                         " Ignoring .pyc files and __pycache__ folder
let g:go_fmt_command = "goimports"                                   " Rewrite go file with correct imports
set wildignore+=*/bin/*,main,*/__pycache__/*,*.pyc,*.swp
set backspace=indent,eol,start                                       " Make backspace work with end of line and indents
set foldmethod=syntax                                                " Auto Add folds - Trigger with za
set foldlevel=9999                                                   " Keep folds open by default
set scrolloff=10                                                     " Scroll Offset below and above the cursor
set expandtab                                                        " Replace tab with spaces
"set tabstop=4                                                        " Tab = 4 Space
set softtabstop=4                                                    " Act like there are tabs not spaces
set hidden                                                           " Hide abandoned buffers without message
set wildmenu                                                         " Tab command completion in vim
set ignorecase                                                       " Ignore case while searching
set smartcase                                                        " Case sensitive if Capital included in search
set incsearch                                                        " Incremental Searching - Search as you type
set autoindent                                                       " Self explained
set smartindent
set relativenumber                                                   " relative numbering (Current line in line 0)
set number                                                           " Line numbers - Hybrid mode when used with rnu
set nowrap                                                           " I don't like wrapping statements
set laststatus=2                                                     " Show status line for even 1 file
set tags=tags;/                                                  " Path to generated tags
set mouse=nv                                                         " Allow mouse usage in normal and visual modes
set nohlsearch                                                       " Do not highlight all search suggestions.
let g:airline_powerline_fonts = 1                                    " Powerline fonts
let g:airline#extensions#tabline#enabled = 1                         " Show buffers above
let g:airline_theme='jellybeans'
let g:go_version_warning = 0

" Lint Configs


                        "---------------------------SMART CLIPBOARD----------------------------"
vnoremap ,y "+yy
nnoremap ,y "+yy
vnoremap ,d "+dd
nnoremap ,d "+dd
vnoremap ,p "+p
nnoremap ,p "+p
vnoremap ,P "+P
nnoremap ,P "+P
                        "----------------------------ABBREVIATIONS-----------------------------"
iabbrev @@g snehilverma41@gmail.com
iabbrev @@i snehilv@iitk.ac.in
iabbrev @@c snehilv@cse.iitk.ac.in
iabbrev @@u snehilv@utexas.edu

                        "---------------------------HABIT--BREAKING----------------------------"

                        "----------------------------GVIM SPECIFIC-----------------------------"

set directory=.,$TEMP                                                " Gets rid of a windows specific error
set guioptions-=m                                                    " remove menu bar
set guioptions-=T                                                    " remove toolbar
set guioptions-=r                                                    " remove right-hand scroll bar
set guioptions-=L                                                    " remove left-hand scroll bar
set guifont=Source\ Code\ Pro\ for\ Powerline\ 12

                        "--------------------------------HOOKS---------------------------------"
augroup filetype_compile
  autocmd!
  autocmd FileType tex nnoremap <F3> mm:w<CR>:!pdflatex<Space>%<CR><CR><Return>`m
augroup END

"augroup filetype_compile
 " autocmd!
  "autocmd BufWritePre *.c,*.cpp,*.objc,*.h ClangFormat
"augroup END
vmap <C-c> "+y"
                        "---------------------------OPERATOR-PENDING---------------------------"
" Operate inside next block
onoremap in( :<c-u>normal! f(vi(<CR>
onoremap in{ :<c-u>normal! f{vi{<CR>
onoremap in" :<c-u>normal! f"vi"<CR>
onoremap in' :<c-u>normal! f'vi'<CR>
onoremap in` :<c-u>normal! f`vi`<CR>
" Operate inside previous block
onoremap ip( :<c-u>normal! F)vi(<CR>
onoremap ip{ :<c-u>normal! F}vi{<CR>
onoremap ip" :<c-u>normal! F"vi"<CR>
onoremap ip' :<c-u>normal! F'vi'<CR>
onoremap ip` :<c-u>normal! F`vi`<CR>
" Operate around next block
onoremap an( :<c-u>normal! f(va(<CR>
onoremap an{ :<c-u>normal! f{va{<CR>
onoremap an" :<c-u>normal! f"va"<CR>
onoremap an' :<c-u>normal! f'va'<CR>
onoremap an` :<c-u>normal! f`va`<CR>
" Operate around previous block
onoremap ap( :<c-u>normal! F)va(<CR>
onoremap ap{ :<c-u>normal! F}va{<CR>
onoremap ap" :<c-u>normal! F"va"<CR>
onoremap ap' :<c-u>normal! F'va'<CR>
onoremap ap` :<c-u>normal! F`va`<CR>
"
"
" Remove trailing whitespace
nnoremap <C-M> :%s/\s\+$//e<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CSCOPE settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" This file contains some boilerplate settings for vim's cscope interface,
" plus some keyboard mappings that I've found useful.
"
" USAGE:
" -- vim 6:     Stick this file in your ~/.vim/plugin directory (or in a
"               'plugin' directory in some other directory that is in your
"               'runtimepath'.
"
" -- vim 5:     Stick this file somewhere and 'source cscope.vim' it from
"               your ~/.vimrc file (or cut and paste it into your .vimrc).
"
" NOTE:
" These key maps use multiple keystrokes (2 or 3 keys).  If you find that vim
" keeps timing you out before you can complete them, try changing your timeout
" settings, as explained below.
"
" Happy cscoping,
"
" Jason Duell       jduell@alumni.princeton.edu     2002/3/7
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    " else add the database pointed to by environment variable
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " show msg when any other cscope db added
    set cscopeverbose


    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

endif



