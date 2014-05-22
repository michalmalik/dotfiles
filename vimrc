" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on

" Vundle specific settings
set nocompatible
filetype off

" Use only for dark colorschemes
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"endif

" Enable UTF8 encoding because EasyTree plugin 
" is not happy without it
set encoding=utf8
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden		" Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)
set history=50
set number              " Line numbers
" Tab settings
set expandtab
set smartindent
set softtabstop=8
set shiftwidth=8
" Show tabline only in gVim
set showtabline=2

" Paste
nmap <C-V> "+gP
imap <C-V> <ESC><C-V>i
" Copy
vmap <C-C> "+y

" Set file encryption method to blowfish
set cm=blowfish

" Toggle menu bar
" set guioptions-=m
" Toggle toolbar
" set guioptions-=T
" Toggle scrollbar
" set guioptions-=r
" Turn off all GUI elements in gvim
set guioptions=i
set guifont=Inconsolata\ 11
colorscheme Tomorrow-Night

" Enable Vundle
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" Enable all Go plugins from
" downloaded sources (/usr/src/go/misc/vim)
set rtp+=$GOROOT/misc/vim

" General repos
" Bundle manager
Bundle 'gmarik/vundle'
" File explorer (NERDTree) repo
" Ctrl-w-w to switch between vim windows
Bundle 'scrooloose/nerdtree'
" Syntax checker for various language
Bundle 'scrooloose/syntastic'
" Powerline
Bundle 'Lokaltog/vim-powerline'

" Language-specific repos
" YouCompleteMe plugin for C family languages
Bundle 'Valloric/YouCompleteMe'
" Default vim-golang compiler shucks, so here we go
Bundle 'rjohnsondev/vim-compiler-go'
" Rust VIM
Bundle 'wting/rust.vim'

filetype plugin indent on

" Start NERDTree on startup
autocmd vimenter * NERDTree
autocmd vimenter * if !argc() | NERDTree | endif

" C/C++ settings
" If ycm conf project file is not found, load the global config
autocmd BufNewFile,BufRead *.c,*.cpp let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'

" Golang settings
let g:golang_goroot = $GOROOT
autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd FileType go compiler golang

" Rust settings
autocmd FileType rust compiler rustc
