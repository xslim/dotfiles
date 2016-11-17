" vim: fdm=marker

" Core {{{
set nocompatible                           " Don't need to keep compatibility with Vi
set hidden                                 " Allow hiding buffers with unsaved changes
set fillchars+=vert:\                      " Hide pipes on vertical splits
set nolist                                 " Hide invisibles by default
set autochdir                              " Use current file directory as working dir
set showmode                               " Show current mode down the bottom
set ttyfast                                " More smooth screen redrawing
"set noesckeys                              " Disable extended key support (cursor keys, function keys). Improves <Esc> time dramatically.
set mouse=a 
set linespace=2                            " Spacing between lines

set noswapfile                             " Disable creation of *.swp files
set nobackup
set nowb

set title                                  " Show title in terminal vim

set spelllang=en_us                        " Set default spelling language to English (Australia)
set shortmess+=I                           " Disable splash screen
set noequalalways                          " Don't equalize when opening/closing windows

set clipboard=unnamedplus                  " MacOSX system clipboard
set switchbuf=useopen                      " Don't re-open already opened buffers

" }}}

" Files {{{

syntax on                                  " Turn on syntax highlighting
filetype plugin indent on                  " Enable automatic filetype detection, filetype-specific plugins/indentation
set encoding=utf-8
set modelines=2                            " Check the first line of files for a modeline (tab vs spaces, etc)
"set autoread                               " Automatically reload externally modified files when clean
"set autowriteall                           " Automatically write modified files
set listchars=trail:·,tab:▸\ ,eol:¬        " Change the invisible characters

" }}}


" Indentation {{{
set autoindent                             " Automatic indentation in non-C files + Keep the indent when creating a new line
set smartindent
set smarttab                               " Use shiftwidth and softtabstop to insert or delete (on <BS>) blanks
set shiftwidth=2                           " Number of spaces to use in each autoindent step
set softtabstop=2                          " Number of spaces to skip or insert when <BS>ing or <Tab>ing
set tabstop=2                              " Two tab spaces
set expandtab                              " Spaces instead of tabs for better cross-editor compatibility
set cindent                                " Recommended seting for automatic C-style indentation
set backspace=2                            " Allow backspacing over autoindent, EOL, and BOL
set foldmethod=indent                      " Fold based on source indentation
set foldnestmax=3                          " deepest fold is 3 levels
set foldlevelstart=99                      " Expand all folds by default
" }}}

" Wrap {{{
"set nowrap                                 " I don't always wrap lines...
set wrap
set textwidth=0                            " prevent Vim from automatically inserting line breaks in newly entered text
set wrapmargin=0
set linebreak                              " ...but when I do, I wrap whole words.
" }}}

" Moving around / editing
set nostartofline                          " Avoid moving cursor to BOL when jumping around
set scrolloff=3                            " Keep 3 context lines above and below the cursor
set showmatch                              " Briefly jump to a paren once it's balanced
set matchtime=2                            " (for only .2 seconds).

" Searching {{{
set ignorecase                             " Ignore case by default when searching
set smartcase                              " Switch to case sensitive mode if needle contains uppercase characters
set hlsearch                               " Highlight search results
set incsearch                              " Find the next match as we type the search
nmap <leader>/ :set hlsearch!<cr>
" }}}

" Ruler {{{
set relativenumber                         " Relative line numbers"
set number                                 " Show line numbers
set ruler                                  " Show ruler
"set rulerformat=%l\:%c 
set laststatus=2                           " Always show statusbar

nmap <leader>' :set relativenumber!<cr>
nmap <leader>" :set number! <bar> :set relativenumber!<cr>

" }}}

" Commands {{{
set showcmd                                " Show incomplete cmds down the bottom
set wildmenu                               " Make tab completion act more like bash
set wildmode=list:longest                  " Tab complete to longest common string, like bash
set autoread                               " Automatically reload externally modified files when clean
set history=1000                           " Remember more history for commands and search patterns

" }}}

set background=dark
try
  colorscheme jellybeans 
catch
  colorscheme torte
endtry



let mapleader = ","                        " Remap leader to ',' which is much easier than '\'


" if exists(':AirlineToggle')
"  set noshowmode
" endif


" Auto reload config on .vimrc change
autocmd bufwritepost .vimrc source $MYVIMRC



" Or load from file
"if filereadable($HOME ."/.vim/plugins.vim")
"  source ~/.vim/plugins.vim
"endif

" Plugins {{{

if filereadable(expand("~/.vim/autoload/plug.vim"))

call plug#begin()

"Plug 'tpope/vim-sensible'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }

Plug 'ctrlpvim/ctrlp.vim'

" Shows At match #N out of M matches
Plug 'vim-scripts/IndexedSearch'

call plug#end()


" Plugin config 

" NerdTree
let NERDTreeShowHidden=1
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>

" TagBar, requires ctag!
map <leader>tt :TagbarToggle<cr>

endif

" }}}


autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


" Mapping

