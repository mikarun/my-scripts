set nocompatible               " be iMproved
call pathogen#infect()

"  ---------------------------------------------------------------------------
"  Plugins
"  ---------------------------------------------------------------------------

silent! runtime bundles.vim

"  ---------------------------------------------------------------------------
"  General
"  ---------------------------------------------------------------------------

filetype plugin indent on     
let mapleader = ","
let g:mapleader = ","
set modelines=0
set history=1000
set nobackup
set nowritebackup
set noswapfile
syntax enable
set autoread
set clipboard=unnamed

"  ---------------------------------------------------------------------------
"  UI
"  ---------------------------------------------------------------------------

set title
set encoding=utf-8
set scrolloff=3
set autoindent
set smartindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set number
"set relativenumber
"set undofile
set cpoptions+=$

" Auto adjust window sizes when they become current
"set winwidth=84
"set winheight=5
"set winminheight=5
"set winheight=999

"colorscheme solarized
set background=light " or dark

set splitbelow splitright
"  ---------------------------------------------------------------------------
"  Text Formatting
"  ---------------------------------------------------------------------------

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set tags:tags,./tmp/tags;

"set nowrap
"set textwidth=79
"set formatoptions=n
"
"" check to make sure vim has been compiled with colorcolumn support
"" before enabling it
"if exists("+colorcolumn")
"  set colorcolumn=80
"endif

"  ---------------------------------------------------------------------------
"  Status Line
"  ---------------------------------------------------------------------------

" path
set statusline=%f
" flags
set statusline+=%m%r%h%w
" git branch
"set statusline+=\ %{fugitive#statusline()}
" encoding
set statusline+=\ [%{strlen(&fenc)?&fenc:&enc}]
" rvm
"set statusline+=\ %{rvm#statusline()}
" line x of y
set statusline+=\ [Line\ %l\/%L\ %P]
" col
set statusline+=\ [Col\ %c\/%v]
" Buff
set statusline+=\ [Buf\ #\%n]

" Colour
hi StatusLine ctermfg=Black ctermbg=White

" Change colour of statusline in insert mode
au InsertEnter * hi StatusLine ctermbg=DarkBlue
au InsertLeave * hi StatusLine ctermfg=Black ctermbg=White

"  ---------------------------------------------------------------------------
"  Mappings
"  ---------------------------------------------------------------------------

" Searching / moving
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch

" Center screen when scrolling search results
nmap n nzz
nmap N Nzz

" ACK
set grepprg=ack

" ,a to Ack (search in files)
nnoremap <leader>a :Ack 

" Ack settings: https://github.com/krisleech/vimfiles/wiki/Make-ack-ignore-files

" Edit/View files relative to current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" Ignore some binary, versioning and backup files when auto-completing
set wildignore=.svn,CVS,.git,*.swp,*.jpg,*.png,*.gif,*.pdf,*.bak

"  ---------------------------------------------------------------------------
"  Plugins
"  ---------------------------------------------------------------------------
"#FuzzyFinder
map <leader>F :FufFile<CR>
map <leader>f :FufTaggedFile<CR>
map <leader>s :FufTag<CR>
map <leader>b :FufBuffer<CR>

" AutoClose
let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']', '"': '"', "'": "'", '#{': '}'} 
let g:AutoCloseProtectedRegions = ["Character"] 

let my_home = expand("$HOME/")

"  ---------------------------------------------------------------------------
"  Ruby/Rails
"  ---------------------------------------------------------------------------
" Leader shortcuts for Rails commands
map <Leader>m :Rmodel 
map <Leader>c :Rcontroller 
map <Leader>v :Rview 
map <Leader>u :Runittest 
map <Leader>ff :Rfunctionaltest 
map <Leader>tm :RTmodel 
map <Leader>tc :RTcontroller 
map <Leader>tv :RTview 
map <Leader>tu :RTunittest 
map <Leader>tf :RTfunctionaltest 
map <Leader>sm :RSmodel 
map <Leader>sc :RScontroller 
map <Leader>sv :RSview 
map <Leader>su :RSunittest 
map <Leader>sf :RSfunctionaltest 

" Hide search highlighting
map <Leader>h :set invhls <CR>

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled
" in
" Normal mode: <Leader>t
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
" Execute current buffer as ruby
map <S-r> :w !ruby<CR>

" Other files to consider Ruby
au BufRead,BufNewFile Gemfile,Rakefile,Thorfile,config.ru,Vagrantfile,Guardfile,Capfile set ft=ruby

"  ---------------------------------------------------------------------------
"  GUI
"  ---------------------------------------------------------------------------

if has("gui_running")
  set guioptions-=T " no toolbar set guioptions-=m " no menus
  set guioptions-=r " no scrollbar on the right
  set guioptions-=R " no scrollbar on the right
  set guioptions-=l " no scrollbar on the left
"  set guioptions-=b " no scrollbar on the bottom
"  set guioptions=aiA 
"  set mouse=v
"  set guifont=Monaco:h11 "<- Maybe a good idea when using mac
endif
"set guifont=Monaco:h11

"  ---------------------------------------------------------------------------
"  Directories
"  ---------------------------------------------------------------------------

set backupdir=~/tmp,/tmp
"set undodir=~/.vim/.tmp,~/tmp,~/.tmp,/tmp

" Ctags path (brew install ctags)
let Tlist_Ctags_Cmd = 'ctags'

" Make Vim use RVM correctly when using Zsh
" https://rvm.beginrescueend.com/integration/vim/
set shell=/bin/bash

" Finally, load custom configs
if filereadable(my_home . '.vimrc.local')
  source ~/.vimrc.local
endif

"  ---------------------------------------------------------------------------
"  Misc
"  ---------------------------------------------------------------------------
"
"  white spaces handling

function! ShowSpaces(...)
  let @/='\v(\s+$)|( +\ze\t)'
  let oldhlsearch=&hlsearch
  if !a:0
    let &hlsearch=!&hlsearch
  else
    let &hlsearch=a:1
  end
  return oldhlsearch
endfunction

function! TrimSpaces() range
  let oldhlsearch=ShowSpaces(1)
  execute a:firstline.",".a:lastline."substitute ///gec"
  let &hlsearch=oldhlsearch
endfunction

"command -bar -nargs=? ShowSpaces call ShowSpaces(<args>)
"command -bar -nargs=0 -range=% TrimSpaces <line1>,<line2>call TrimSpaces()
"nnoremap <F12>     :ShowSpaces 1<CR>
"nnoremap <S-F12>   m`:TrimSpaces<CR>``
"vnoremap <S-F12>   :TrimSpaces<CR>
"
" list methods
function! ShowFunc(sort)
  let gf_s = &grepformat
  let gp_s = &grepprg
  if ( &filetype == "c" || &filetype == "php" || &filetype == "python" ||
        \ &filetype == "sh" )
    let &grepformat='%*\k%*\sfunction%*\s%l%*\s%f %m'
    let &grepprg = 'ctags -x --'.&filetype.'-types=f --sort='.a:sort
  elseif ( &filetype == "perl" )
    let &grepformat='%*\k%*\ssubroutine%*\s%l%*\s%f %m'
    let &grepprg = 'ctags -x --perl-types=s --sort='.a:sort
  elseif ( &filetype == "vim" )
    let &grepformat='%*\k%*\sfunction%*\s%l%*\s%f %m'
    let &grepprg = 'ctags -x --vim-types=f --language-force=vim --sort='.a:sort
  endif
  if (&readonly == 0) | update | endif
  silent! grep %
  cwindow 10
  redraw
  let &grepformat = gf_s
  let &grepprg = gp_s
endfunc


" When vimrc, either directly or via symlink, is edited, automatically reload it
autocmd! bufwritepost .vimrc source %
autocmd! bufwritepost vimrc source %
