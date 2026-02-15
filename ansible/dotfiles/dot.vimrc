version 8.2

set nocompatible

let skip_defaults_vim=1

set autoindent
set autoread
set background=dark
set backspace=indent,eol,start
set breakat=80
set breakindent
set cryptmethod=blowfish2
set encoding=utf8
set fileencoding=utf8
set nohlsearch
set incsearch
set linebreak
set mouse=r
set nobackup
set nojoinspaces
set noswapfile
set noundofile
set ruler
set shiftwidth=2
set showcmd
set smartindent
set viminfo=

if has('gui_running')
  set clipboard=exclude:.*
endif
