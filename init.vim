"                             Neovim configuration
"                    _____________________________________
"                    | _____ |   | ___ | ___ ___ | |   | |
"                    | |   | |_| |__ | |_| __|____ | | | |
"                    | | | |_________|__ |______ |___|_| |
"                    | |_|   | _______ |______ |   | ____|
"                    | ___ | |____ | |______ | |_| |____ |
"                    |___|_|____ | |   ___ | |________ | |
"                    |   ________| | |__ | |______ | | | |
"                    | | | ________| | __|____ | | | __| |
"                    |_| |__ |   | __|__ | ____| | |_| __|
"                    |   ____| | |____ | |__ |   |__ |__ |
"                    | |_______|_______|___|___|___|_____|
"
" -- Plugin Management #plugins ---------------------------------------------{{{
" ---------------------------------------------------------------------------- "
" Path to the plugin location
let g:plugdir = stdpath("data") . "/plugged"

" Begin listing the plugins to load.
call plug#begin(g:plugdir)

" Let plug manage plug.
Plug 'junegunn/vim-plug'
" Commenting code in various languages.
Plug 'tpope/vim-commentary'
" Atom one themes
Plug 'rakr/vim-one'
" A better status line with themes.
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" insert or remove brackets, parens, quotes etc. in pair
Plug 'jiangmiao/auto-pairs'
" Support for editing with surrounding quotes, parens etc.
Plug 'tpope/vim-surround'
" Support for repeat (.) functionality for plugins.
Plug 'tpope/vim-repeat'
" Use * to search for selections.
Plug 'bronson/vim-visual-star-search'
" Fuzzy File Finder in ~/.fzf and run the install script
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Autocomplete engine for neovim.
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Manage the wsp-vim manually as its in private repo.
Plug g:plugdir . '/wsp-vim'
" Initialize all plugins.
call plug#end()

" enable the plugin settings, required.
filetype plugin indent on
"}}}

" -- General Options #general -----------------------------------------------{{{
" ---------------------------------------------------------------------------- "
set nocompatible
" Syntax highlighing on
syntax on
" Highlight search term as you type
set hlsearch
" Show current command in statusbar
set showcmd
" Enable mouse
set mouse=a
" Ignore case while searching
set ignorecase
" Do not create swap files
set noswapfile
" keep buffers loaded when window closes, required by many plugins.
set hidden
" Use spaces instead of tabs.
set expandtab
" Set default indentation size.
set tabstop=2
set shiftwidth=2
" Dont show mode as airline already does.
set noshowmode
" Default coding textwidth
set textwidth=80
" No automatic wrapping of lines.
set nowrap
" Use » to mark Tabs and ° to mark trailing whitespace
set list listchars=tab:»\ ,trail:°
" Enable line-numbers
set number
" Use non-retarded locations when opening new splits.
set splitbelow
set splitright
" Show completion options in a menu.
set wildmenu
" Set the tab-completion for commands to be more similar to shell
set wildmode=longest:full,full
" Ignore these files / dirs when searchig/globbing
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pdf,*.msi,*.exe,*.a,*.o,*.bin,*.out,*.deb
set wildignore+=*/__pycache__/*
" Clear search-highlight when reloading vimrc.
noh
"}}}

" -- Appearance and Themes #themes ------------------------------------------{{{
" ---------------------------------------------------------------------------- "
" Enable truecolor.
set termguicolors
" Dark is power.
set background=dark
" Set colorscheme for vim.
colorscheme one
" colorscheme molokai
" theme for the airline (other good options)
" let g:airline_theme="deus"
" let g:airline_theme="tomorrow"
let g:airline_theme = 'one'
let g:one_allow_italics = 1
" better colors for matchparen highlight
hi MatchParen cterm=underline ctermbg=none ctermfg=yellow
" highlight cursor line
set cursorline
"}}}

" -- FZF config #fzfconfig --------------------------------------------------{{{
" ---------------------------------------------------------------------------- "
" FZF runs in terminal buffer, Disable the modeline for that buffer.
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
"}}}

" -- Autoformat config #autoformatconfig ------------------------------------{{{
" ---------------------------------------------------------------------------- "
" :Autoformat should not perform default formatting if formatter is not available.
" let g:autoformat_autoindent = 0
" let g:autoformat_retab = 0
" let g:autoformat_remove_trailing_spaces = 0
" let g:formatters_python = ['yapf']
"}}}

" -- Deoplete config #deopleteconfig ----------------------------------------{{{
" ---------------------------------------------------------------------------- "
let g:deoplete#enable_at_startup = 1
" " Use tab key for completion
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
"}}}

" -- Airline config #airlineconfig ------------------------------------------{{{
" ---------------------------------------------------------------------------- "
" Currently, This does not seem to work.
let g:airline_exclude_filetypes = ['Terminal']
"}}}

" -- LanguageClient config #langconfig --------------------------------------{{{
" ---------------------------------------------------------------------------- "
" let g:LanguageClient_serverCommands = {}
" let g:LanguageClient_serverCommands.python = ['pyls']
"}}}

" -- vim-lsp config #lspconfig ----------------------------------------------{{{
" ---------------------------------------------------------------------------- "
" if executable('pyls')
"     " pip install python-language-server
"     au User lsp_setup call lsp#register_server({
"         \ 'name': 'pyls',
"         \ 'cmd': {server_info->['pyls']},
"         \ 'whitelist': ['python'],
"         \ })
" endif

" let g:lsp_diagnostics_enabled = 0
" let g:lsp_signs_enabled = 1

"}}}

" -- Custom key bindings #keys ----------------------------------------------{{{
" ---------------------------------------------------------------------------- "
" set space as the map leader key
let mapleader="\<space>"
" space-space = clear search highlight
nnoremap <leader><space> :let @/ = "deadbeef"<CR>:noh<CR>:echo ""<CR>
" edit vimrc file in split
nnoremap <leader>ev :edit $MYVIMRC<cr>
" reload vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>
" better keymap to exit insert mode
inoremap  jk <esc>
" Better shortcuts for pg-up and pg-down.
nnoremap K <c-u>zz
nnoremap J <c-d>zz
" symmetric shortcut for redo (undo-undo)
" nnoremap U <c-r>

" --- window management
" Add leader-w prefix for all window commands.
nnoremap <leader>w <c-w>
" maximize current window
nnoremap <leader>wm <c-w>o
" alias for close window.
nnoremap <leader>q <c-w>c

" -- buffer management
" alias for Ctrl+W
nnoremap <leader>w <c-w>
" next buffer
nnoremap <leader>bn :bn<cr>
" prev buffer
nnoremap <leader>bp :bp<cr>
" list buffers
nnoremap <leader>bb :Buffers<cr>
" delete current buffer
nnoremap <leader>bd :bd<cr>
nnoremap <leader>bdf :bd!<cr>

" better fold-toggle
nnoremap <leader>; zazz0

" Command history
nnoremap <leader>hc :History:<cr>
" File history
nnoremap <leader>hf :History<cr>
" Search history
nnoremap <leader>hs :History/<cr>

" Automatically format code
nnoremap <leader>ll :Autoformat<cr>

" prevent entering Ex mode accidentally
nnoremap Q <Nop>

" Tab/Shift-Tab to indent/un-indent in visual mode.
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" Keep selections when indenting.
vnoremap > >gv
vnoremap < <gv

" Easy switch to normal mode in terminal
tnoremap <leader><esc> <C-\><C-n>0

" Format file.
" nnoremap <leader>ll :LspDocumentFormat<CR>


"}}}

" -- Experimental stuff #experiments ----------------------------------------{{{
" ---------------------------------------------------------------------------- "
" Put experimental settings here.

