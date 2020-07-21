set number

set bs=2
set tabstop=2
set shiftwidth=2
set expandtab

call plug#begin()
Plug 'sheerun/vim-polyglot'
Plug 'tomtom/tcomment_vim'
Plug 'w0rp/ale'
call plug#end()

let g:netrw_banner=0
let g:netrw_liststyle=3

let g:ale_sign_column_always=1
let g:ale_fixers={'javascript': ['prettier_standard']}
let g:ale_linters={'javascript': ['']}
let g:ale_fix_on_save=1

inoremap <C-x> <esc>
noremap <silent> <C-c> :TComment<CR>
noremap <C-o> <esc>:Sex<CR>

" :autocmd BufWritePre *.{js,jsx,ts,tsx} :normal gg=G
