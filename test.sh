#!/usr/bin/env bash
#
# Verify this configuration actually behaves correctly on this machine.
#
# Runs against a throwaway $HOME, so it never touches your real setup and can
# be run before installing. Checks three things:
#
#   1. the vimrc loads with no errors
#   2. every mapping resolves to what it is supposed to
#   3. the mappings that used to be silently wrong now behave correctly
#
# Point 3 is the reason this file exists. Several mappings in this config's
# history looked right in the file and did the wrong thing at runtime — a
# visual-mode "+yy that swallowed the next keypress, a <C-M> that was secretly
# <CR>, a trailing " that put Vim into register-pending state. A mapping table
# alone does not catch those; you have to press the keys.
#
# Usage:  ./test.sh            test against the repo's vimrc
#         ./test.sh --installed  test whatever is currently at ~/.vimrc
#
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
VIMRC="$REPO/.vimrc"
if [[ "${1:-}" == "--installed" ]]; then
  VIMRC="$HOME/.vimrc"
  [[ -e "$VIMRC" ]] || { printf 'no ~/.vimrc to test\n' >&2; exit 1; }
fi

VIM="${VIM:-vim}"
command -v "$VIM" >/dev/null || { printf '%s not found\n' "$VIM" >&2; exit 1; }

TESTHOME="$(mktemp -d)"
SCRIPT="$TESTHOME/suite.vim"
OUT="$TESTHOME/out.txt"
TARGET="$TESTHOME/qf_target.txt"
trap 'rm -rf "$TESTHOME"' EXIT

printf 'first\nhit here\nthird\n' > "$TARGET"

# Reuse the real plugin dir if there is one, so <Plug> mappings can resolve.
# Without plugins the plugin-dependent checks are skipped rather than failed.
if [[ -d "$HOME/.vim/plugged" ]]; then
  mkdir -p "$TESTHOME/.vim"
  ln -sfn "$HOME/.vim/plugged" "$TESTHOME/.vim/plugged"
  ln -sfn "$HOME/.vim/autoload" "$TESTHOME/.vim/autoload" 2>/dev/null || true
fi

cat > "$SCRIPT" <<VIMEOF
let g:fail = 0
let g:skip = 0
let g:pass = 0

function! Check(name, got, want) abort
  if a:got ==# a:want
    let g:pass += 1
  else
    let g:fail += 1
    echo printf('FAIL  %s', a:name)
    echo printf('        want [%s]', a:want)
    echo printf('        got  [%s]', a:got)
  endif
endfunction

function! CheckUnmapped(name, key, mode) abort
  let l:got = maparg(a:key, a:mode)
  if empty(l:got)
    let g:pass += 1
  else
    let g:fail += 1
    echo printf('FAIL  %s must stay unmapped, but -> [%s]', a:name, l:got)
  endif
endfunction

function! Fresh() abort
  enew!
  call setline(1, ['line1','line2','line3','line4','line5','line6','line7','line8'])
  call cursor(1,1)
endfunction

redir! > $OUT

" ---------------------------------------------------------------- load clean
echo '== startup =='
call Check('vimrc loads without error', v:errmsg, '')
let s:nplug = len(get(g:, 'plugs', {}))
echo printf('   %d plugins registered', s:nplug)
call Check('encoding is utf-8', &encoding, 'utf-8')
call Check('mapleader is set', get(g:, 'mapleader', ''), ',')

" ------------------------------------------------------------ mapping table
echo ''
echo '== mappings resolve correctly =='
for [s:mode, s:lhs, s:want] in [
\ ['n', ';', ':'], ['n', ',;', ';'], ['n', ',.', ','],
\ ['n', '<CR>', 'o<Esc>'],
\ ['i', 'jk', '<Esc>'], ['i', '<C-g>w', '<Esc>viwUgi'], ['n', ',U', 'mzviwU\`z'],
\ ['n', '<Tab>', ':bnext<CR>'], ['n', '<S-Tab>', ':bprevious<CR>'],
\ ['n', '<F2>', ':NERDTreeToggle<CR>'], ['i', '<F2>', '<Esc>:NERDTreeToggle<CR>a'],
\ ['n', '<F3>', ':NERDTreeFocus<CR>'], ['n', '<F4>', ':set wrap!<CR>'],
\ ['n', '<F8>', ':UndotreeToggle<CR>'], ['n', '<F9>', ':set cul!<CR>'],
\ ['n', '<F10>', 'mmgg=G\`m'], ['i', '<F10>', '<Esc>mmgg=G\`ma'],
\ ['n', 'Q', '!!sh<CR>'],
\ ['n', ',y', '"+yy'], ['x', ',y', '"+y'],
\ ['n', ',d', '"+dd'], ['x', ',d', '"+d'],
\ ['n', ',p', '"+p'], ['x', ',p', '"+p'],
\ ['n', ',P', '"+P'], ['x', ',P', '"+P'],
\ ['x', '<C-c>', '"+y'],
\ ['o', 'in(', ':<C-U>normal! f(vi(<CR>'], ['x', 'in(', ':<C-U>normal! f(vi(<CR>'],
\ ['o', 'il(', ':<C-U>normal! F)vi(<CR>'], ['o', 'an{', ':<C-U>normal! f{va{<CR>'],
\ ['o', 'al\`', ':<C-U>normal! F\`va\`<CR>'],
\ ]
  call Check(printf('%smap %s', s:mode, s:lhs), maparg(s:lhs, s:mode), s:want)
endfor

" A mapping RHS runs to end-of-line, so a trailing " comment silently becomes
" part of the mapping. Catch any that creep back in.
echo ''
echo '== no mapping has a leaked trailing comment =='
let s:leaked = 0
if exists('*maplist')
  for s:e in maplist()
    if s:e.rhs =~# '\s\{3,}"'
      echo printf('FAIL  %s %s -> %s', s:e.mode, s:e.lhs, s:e.rhs)
      let s:leaked += 1
    endif
  endfor
  call Check('no leaked comments', string(s:leaked), '0')
else
  let g:skip += 1
endif

" ------------------------------------------------- core keys stay untouched
echo ''
echo '== core Vim keys are not shadowed =='
call CheckUnmapped('i_CTRL-U (delete entered text)', '<C-u>', 'i')
call CheckUnmapped('ip (inner paragraph)', 'ip', 'o')
call CheckUnmapped('ap (a paragraph)', 'ap', 'o')
call CheckUnmapped('/ (search)', '/', 'n')
call CheckUnmapped('w!! in command-line mode', 'w!!', 'c')
call Check('  :W exists instead', string(exists(':W')), '2')

" A mapping is not the only way to break a built-in text object: defining
" 'ip(' makes 'ip' a mapping PREFIX, so dip/yip/cip stall for 'timeoutlen'
" before the built-in fires. maparg('ip') cannot see that, so check for any
" mapping whose lhs merely STARTS with a built-in object's keys.
if exists('*maplist')
  let s:prefixed = []
  for s:e in maplist()
    if s:e.mode =~# '[ox]' && s:e.lhs =~# '^[ia]p.'
      call add(s:prefixed, s:e.lhs)
    endif
  endfor
  call Check('ip/ap are not mapping prefixes either',
  \ empty(s:prefixed) ? 'clear' : join(s:prefixed, ','), 'clear')
endif

" -------------------------------------------------------------- behaviour
echo ''
echo '== behaviour =='

" Visual-mode clipboard maps must not carry the normal-mode doubled operator:
" in visual mode "+y already completes the yank, so a trailing y starts a NEW
" pending operator that eats the next keypress.
call Fresh()
call feedkeys('V,dj', 'x')
call Check('V ,d j deletes exactly one line', string(line('\$')), '7')
call Check('  ...and the j still moved', string(line('.')), '2')

call Fresh()
call feedkeys('V,yj', 'x')
call Check('V ,y j deletes nothing', string(line('\$')), '8')
call Check('  ...and the j still moved', string(line('.')), '2')

call Fresh()
call feedkeys("V\<C-c>jdd", 'x')
call Check('V <C-c> j dd removes line2, not line1', getline(1), 'line1')
call Check('  ...line2 is the one gone', getline(2), 'line3')

" <CR>, <C-M>, <Return> and <Enter> are one key. Nothing else may map any of
" them or this silently loses.
call Fresh()
call feedkeys("\<CR>", 'x')
call Check('<CR> inserts a blank line below', getline(2), '')
call Check('  ...and did not substitute', string(line('\$')), '9')

" Built-in text objects must fire immediately, not be shadowed by ip(/ap(.
enew!
call setline(1, ['para1a','para1b','','para2a'])
call cursor(1,1)
call feedkeys('dip', 'x')
call Check('dip deletes the paragraph', getline(1), '')

enew!
call setline(1, ['foo(bar) baz'])
call cursor(1,1)
call feedkeys('din(', 'x')
call Check('din( empties the next bracket pair', getline(1), 'foo() baz')

enew!
call setline(1, ['foo(bar) baz'])
call cursor(1,12)
call feedkeys('dil(', 'x')
call Check('dil( empties the previous bracket pair', getline(1), 'foo() baz')

" Stripping whitespace must not move the cursor or clobber the search register.
enew!
call setline(1, ['aa   ','bb','cc  ','dd','ee'])
call cursor(4,1)
let @/ = 'MYSEARCH'
call feedkeys(',w', 'x')
call Check(',w strips trailing whitespace', getline(1), 'aa')
call Check('  ...preserves the cursor line', string(line('.')), '4')
call Check('  ...preserves the search register', @/, 'MYSEARCH')

" A global <CR> mapping shadows the quickfix window's built-in <CR>.
cgetexpr ['$TARGET:2:hit here']
copen
let v:errmsg = ''
silent! execute "normal \<CR>"
call Check('<CR> in quickfix jumps to the entry', expand('%:t'), 'qf_target.txt')
call Check('  ...on the right line', string(line('.')), '2')
call Check('  ...with no error', v:errmsg, '')

" ',' is the leader, so bare ',' is a mapping prefix; ,; and ,. restore what
" ; and , normally do.
enew!
call setline(1, ['a.b.c.d'])
call cursor(1,1)
call feedkeys('f.,;', 'x')
call Check(',; repeats f forward', string(col('.')), '4')
call feedkeys(',.', 'x')
call Check(',. repeats f backward', string(col('.')), '2')

" ----------------------------------------------- plugin-dependent mappings
echo ''
echo '== plugin-dependent (skipped when plugins are absent) =='
if s:nplug > 0 && isdirectory(expand('~/.vim/plugged/nerdcommenter'))
  call Check('n ,c -> NERDCommenter', maparg(',c', 'n'), '<Plug>NERDCommenterInvert')
  call Check('x ,c -> NERDCommenter', maparg(',c', 'x'), '<Plug>NERDCommenterInvert')
else
  echo '   SKIP nerdcommenter not installed'
  let g:skip += 2
endif
if s:nplug > 0 && isdirectory(expand('~/.vim/plugged/vim-easymotion'))
  " EasyMotion claims <Leader><Leader> itself; g:EasyMotion_do_mapping=0 must
  " keep our binding from being overwritten when its plugin file loads.
  call Check('n ,, -> easymotion-s', maparg(',,', 'n'), '<Plug>(easymotion-s)')
else
  echo '   SKIP vim-easymotion not installed'
  let g:skip += 1
endif
if s:nplug > 0 && isdirectory(expand('~/.vim/plugged/nerdtree'))
  " nerdtree is lazy-loaded; both commands must be listed in the 'on' spec or
  " <F3> points at a command that was never created.
  call Check('  :NERDTreeToggle defined', string(exists(':NERDTreeToggle')), '2')
  call Check('  :NERDTreeFocus defined', string(exists(':NERDTreeFocus')), '2')
else
  echo '   SKIP nerdtree not installed'
  let g:skip += 2
endif

" ------------------------------------------------------------------ options
echo ''
echo '== options =='
call Check('swap dir is centralized', &directory =~# 'state/vim/swap' ? 'yes' : &directory, 'yes')
call Check('undo dir is centralized', &undodir =~# 'state/vim/undo' ? 'yes' : &undodir, 'yes')
call Check('persistent undo on', string(&undofile), '1')
call Check('tags keeps ./tags', &tags, './tags;,tags;')
call Check('smartindent off', string(&smartindent), '0')
call Check('timeoutlen lowered', string(&timeoutlen), '400')
call Check('a colorscheme loaded', empty(get(g:, 'colors_name', '')) ? 'none' : 'yes', 'yes')
for s:d in ['swap','backup','undo']
  call Check(printf('  ~/.local/state/vim/%s exists', s:d),
  \ isdirectory(expand('~/.local/state/vim/' . s:d)) ? 'yes' : 'no', 'yes')
endfor

echo ''
echo printf('%d passed, %d failed, %d skipped', g:pass, g:fail, g:skip)
redir END

qa!
VIMEOF

printf 'Testing %s\n' "$VIMRC"
printf 'using  %s (%s)\n\n' "$VIM" "$("$VIM" --version | head -1 | cut -d' ' -f1-5)"

HOME="$TESTHOME" "$VIM" -u "$VIMRC" -es -S "$SCRIPT" >/dev/null 2>&1 || true

if [[ ! -s "$OUT" ]]; then
  printf 'test suite produced no output — vim may have failed to start\n' >&2
  exit 1
fi
cat "$OUT"

# The suite's last line is "<n> passed, <m> failed, <k> skipped".
SUMMARY="$(grep -E '^[0-9]+ passed, [0-9]+ failed' "$OUT" | tail -1)"
FAILED="$(printf '%s' "$SUMMARY" | sed -n 's/.*, \([0-9]*\) failed.*/\1/p')"

printf '\n'
if [[ -z "$FAILED" ]]; then
  printf 'could not read a result summary — the suite did not finish\n' >&2
  exit 1
elif [[ "$FAILED" == "0" ]]; then
  printf 'OK\n'
  exit 0
else
  printf 'FAILED (%s checks)\n' "$FAILED"
  exit 1
fi
