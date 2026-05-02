"""""
" VIM configuration
"""
"--------------------
" General
"--------------------
set nocompatible " Annule la compatiblité avec l'ancêtre vi
call pathogen#infect()  " Active Pathogen
syntax on   " Active la coloration syntaxique
filetype plugin indent on " Charge le plugin basé sur le type de fichier et active l'indentation en fonction du type de fichier

" Display
set title       " Met à jour le titre de la fenêtre ou du terminal
set number	" Show line numbers
set nowrap	" Wrap lines
set linebreak	" Break lines at word (requires Wrap lines)
set showbreak=+++ 	" Wrap-broken line prefix
set textwidth=120	" Line wrap (number of cols)
set showmatch	" Highlight matching brace
set nospell	" Enable spell-checking

" Beeper
set visualbell	" Use visual bell (no beeping)
set noerrorbells    "  Empêche Vim de beeper

" Coloration
colorscheme dracula
"colorscheme solarized
"if has('gui_running')
"    set background=light
"else
"    set background=dark
"endif

" Find and replace
set ignorecase	" Always case-insensitive
set smartcase	" Enable smart-case search : Si une recherche contient une majuscule, re-active la sensibilité à la casse
set incsearch	" Searches for strings incrementally : surligne les résultats de recherche pendant la saisie.
set hlsearch	" Highlight all search results

" Indentation
set autoindent	" Auto-indent new lines
set cindent	" Use 'C' style program indenting
set expandtab	" Use spaces instead of tabs
set shiftwidth=4	" Number of auto-indent spaces
set smartindent	" Enable smart-indent
set smarttab	" Enable smart-tabs
set softtabstop=4	" Number of spaces per Tab

" Scroll
set scrolloff=3 " Affiche un minimum de 3 lignes autour du curseur 

"--------------------
" Advanced
"--------------------
" Window
set ruler	" Show row and column ruler information

" Miscellaneous
set undolevels=100	" Number of undo levels
set backspace=indent,eol,start	" Backspace behaviour
set hidden  " Cache les fichiers lors de l'ouverture d'autres fichiers

" <Leader>
let mapleader = ","

"--------------------
" Extra
"--------------------
" YAML
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab foldmethod=indent
au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/plugin/yaml.vim

" IndentLine
let g:indentLine_char = '⦙'

" Vim Airline
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:airline#extensions#nerdtree_statusline = 1

" Ack
" Paramètres par défaut pour ack
let g:ackprg = "ack -H --nocolor --nogroup --column"
" Place un marqueur et cherche
nmap <leader>j mA:Ack<space>
" Place un marqueur et cherche le mot sous le curseur
nmap <leader>ja mA:Ack "<C-r>=expand("<cword>")<cr>"
nmap <leader>ja mA:Ack "<C-r>=expand("<cWORD>")<cr>"
