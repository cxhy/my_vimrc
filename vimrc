set nocompatible
set backspace=indent,eol,start
let mapleader = "\<Space>"
set guifont=Monaco:h14
set autoread
filetype on
filetype indent plugin on
autocmd FileType html setlocal et sta sw=2 sts=2 
autocmd FileType python setlocal et sta sw=4 sts=4 ts=2
set ts=2
set sw=2
set expandtab
set autoindent  
set cindent
set hlsearch
set incsearch  
set smartindent
set number
set ruler
set showcmd
set relativenumber
set nowrapscan
augroup relativenumber
    auto!
    autocmd InsertLeave * : set relativenumber
    autocmd InsertEnter * : set norelativenumber
augroup END
set nobackup     
set noswapfile

au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
set tags=./.tags;,.tags

""""""""""""""zhushi
autocmd FileType c,cpp,java,scala let b:comment_leader = '//'
autocmd FileType sh,ruby,python,perl   let b:comment_leader = '#'
autocmd FileType conf,fstab       let b:comment_leader = '#'
autocmd FileType tex              let b:comment_leader = '%'
autocmd FileType mail             let b:comment_leader = '>'
autocmd FileType vim              let b:comment_leader = '"'
autocmd FileType nasm             let b:comment_leader = ';'
 
function! CommentLine()
    execute ':silent! s/^\(.*\)/' . b:comment_leader . ' \1/g'
endfunction
 
function! UncommentLine()
    execute ':silent! s/^' . b:comment_leader . ' //g'
endfunction
 
map <silent> <leader>cc :call CommentLine()<CR>
map <silent> <leader>cu :call UncommentLine()<CR>

"""""""""""""""""""
"tab 配置
noremap <silent><tab>m :tabnew<cr>
noremap <silent><tab>e :tabclose<cr>
noremap <silent><tab>n :tabn<cr>
noremap <silent><tab>p :tabp<cr>
noremap <silent><leader>t :tabnew<cr>
noremap <silent><leader>g :tabclose<cr>
noremap <silent><leader>1 :tabn 1<cr>
noremap <silent><leader>2 :tabn 2<cr>
noremap <silent><leader>3 :tabn 3<cr>
noremap <silent><leader>4 :tabn 4<cr>
noremap <silent><leader>5 :tabn 5<cr>
noremap <silent><leader>6 :tabn 6<cr>
noremap <silent><leader>7 :tabn 7<cr>
noremap <silent><leader>8 :tabn 8<cr>
noremap <silent><leader>9 :tabn 9<cr>
noremap <silent><leader>0 :tabn 10<cr>
noremap <silent><s-tab> :tabnext<CR>
inoremap <silent><s-tab> <ESC>:tabnext<CR>

" make tabline in terminal mode
function! Vim_NeatTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'
        " the label is made by MyTabLabel()
        let s .= ' %{Vim_NeatTabLabel(' . (i + 1) . ')} '
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999XX'
    endif
    return s
endfunc
 
" get a single tab name 
function! Vim_NeatBuffer(bufnr, fullname)
    let l:name = bufname(a:bufnr)
    if getbufvar(a:bufnr, '&modifiable')
        if l:name == ''
            return '[No Name]'
        else
            if a:fullname 
                return fnamemodify(l:name, ':p')
            else
                return fnamemodify(l:name, ':t')
            endif
        endif
    else
        let l:buftype = getbufvar(a:bufnr, '&buftype')
        if l:buftype == 'quickfix'
            return '[Quickfix]'
        elseif l:name != ''
            if a:fullname 
                return '-'.fnamemodify(l:name, ':p')
            else
                return '-'.fnamemodify(l:name, ':t')
            endif
        else
        endif
        return '[No Name]'
    endif
endfunc
 
" get a single tab label
function! Vim_NeatTabLabel(n)
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfunc
 
" get a single tab label in gui
function! Vim_NeatGuiTabLabel()
    let l:num = v:lnum
    let l:buflist = tabpagebuflist(l:num)
    let l:winnr = tabpagewinnr(l:num)
    let l:bufnr = l:buflist[l:winnr - 1]
    return Vim_NeatBuffer(l:bufnr, 0)
endfunc
 
" setup new tabline, just like %M%t in macvim
set tabline=%!Vim_NeatTabLine()
set guitablabel=%{Vim_NeatGuiTabLabel()}

" get a label tips
function! Vim_NeatGuiTabTip()
    let tip = ''
    let bufnrlist = tabpagebuflist(v:lnum)
    for bufnr in bufnrlist
        " separate buffer entries
        if tip != ''
            let tip .= " \n"
        endif
        " Add name of buffer
        let name = Vim_NeatBuffer(bufnr, 1)
        let tip .= name
        " add modified/modifiable flags
        if getbufvar(bufnr, "&modified")
            let tip .= ' [+]'
        endif
        if getbufvar(bufnr, "&modifiable")==0
            let tip .= ' [-]'
        endif
    endfor
    return tip
endfunc
set guitabtooltip=%{Vim_NeatGuiTabTip()}

call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-easy-align'

Plug 'morhetz/gruvbox'

Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }

Plug 'aperezdc/vim-template'

Plug 'jiangmiao/auto-pairs'

" Initialize plugin system
call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"              gruvbox
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme gruvbox
set background=dark

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"              Easy Align
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"              Leaderf    
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_PreviewResult = {'Function':0, 'Colorscheme':1}
let g:Lf_RootMarkers = ['.git']
let g:Lf_WorkingDirectoryMode = 'Ac'

let g:Lf_NormalMap = {
	\ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
	\ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']],
	\ "Mru":    [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
	\ "Tag":    [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>']],
	\ "Function":    [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>']],
	\ "Colorscheme":    [["<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>']],
	\ }

let g:Lf_WildIgnore = {
        \ 'dir': ['.svn','.git','.hg'],
        \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
        \}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"              vim-template
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:templates_user_variables = [['EMAIL', 'GetEamil'], ['FULLPATH', 'GetFullPath'],]

function GetEamil()
    return 'cxhy1981@gmail.com'
endfunction

function GetFullPath()
    return expand('%:p')
endfunction

let g:templates_directory = '~/.vim/templates'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"              auto load modified
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocmd BufWrite,BufWritePre,FileWritePre  *.pl    ks|call LastModified()|'s
" 
" func LastModified()
" 	if line("$") > 20
" 		let l = 20
" 	else 
" 		let l = line("$")
" 	endif
" 	exe "1,".l."g/Last Modified  : /s/Last Modified  : .*/Last Modified  :".
" 			\strftime(" %Y-%m-%d %H:%M" ) . "/e"
" endfunc
autocmd FileWritePre,BufWritePre,BufWrite *.v,*.vp,*pl,[M|m]ake* ks|call DateInsert() |'s

function DateInsert()
  call cursor(20,1)
  if search('Last Modified') != 0
    let line = line(".")
    exe "1,".line."g/Last Modified  : /s/Last Modified  :.*/Last Modified  : ".strftime("%Y-%m-%d %H:%M")
  endif
endfunction
