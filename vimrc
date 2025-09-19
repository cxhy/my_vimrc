set nocompatible
set backspace=indent,eol,start
let mapleader = "\<Space>"
set guifont=Monaco:h14
set autoread
filetype on
filetype indent plugin on
autocmd FileType html setlocal et sta sw=2 sts=2 
autocmd FileType python setlocal et sta sw=4 sts=4 ts=2
set encoding=utf-8
set termencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr
set fileencoding=utf-8
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
set isfname+={,}
set includeexpr=substitute(v:fname,'{','\{\+','g')


au! BufNewFile,BufRead *.vp  setfiletype verilog

au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
set tags=./.tags;,.tags

function! StarPositionSave()
  let g:star_position_cursor = getpos('.')
  normal! H
  let g:star_position_top = getpos('.')
  call setpos('.', g:star_position_cursor)
endfunction
function! StarPositionRestore()
  call setpos('.', g:star_position_top)
  normal! zt
  call setpos('.', g:star_position_cursor)
endfunction
nnoremap <silent> * :call StarPositionSave()<CR>*:call StarPositionRestore()<CR>

""""""""""""""zhushi
autocmd FileType c,cpp,java,scala，verilog,systemverilog let b:comment_leader = '// '
autocmd FileType sh,ruby,python   let b:comment_leader = '# '
autocmd FileType conf,fstab       let b:comment_leader = '# '
autocmd FileType tex              let b:comment_leader = '% '
autocmd FileType mail             let b:comment_leader = '> '
autocmd FileType vim              let b:comment_leader = '" '
noremap <silent> <leader>cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> <leader>cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

vnoremap // y/<c-r>"<cr>
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

Plug 'honza/vim-snippets'

Plug 'SirVer/ultisnips'

Plug 'tpope/vim-surround'

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
"              vim-surround
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
xmap " S"
xmap ' S'
xmap ( S(
xmap ) S)
xmap [ S[
xmap ] S]
xmap { S{
xmap } S}
xmap ` S`


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"              Leaderf    
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:Lf_WorkingDirectoryMode = 'A'
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', 'package.json', 'pom.xml']
let g:Lf_WindowPosition = 'popup'
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_PreviewResult = {'Function': 0, 'Colorscheme': 1, 'File': 1, 'Buffer': 1}
let g:Lf_RememberLastSearch = 0 
let g:Lf_UseVersionControlTool = 1
let g:Lf_WildIgnore = {
    \ 'dir': ['.git', '.svn', 'node_modules', 'target', 'dist', '.incr', 'work', 'verdi*'],
    \ 'file': ['*.swp', '*.swo', '*.bak', '*.pyc', '*.class', '*.o', '*.svp']
    \ }
let g:Lf_ShowHidden = 0
let g:Lf_SpinSymbols = ['/', '-', '\', '|']
let g:Lf_ShowDevIcons = 0
let g:Lf_QuickSelectAction = 't'
let g:Lf_PopupShowBorder = 1
let g:Lf_PopupBorders = ["═","║","═","║","╔","╗","╝","╚"]

"
"let g:Lf_NormalMap = {
"	\ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
"	\ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']],
"	\ "Mru":    [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
"	\ "Tag":    [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>']],
"	\ "Function":    [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>']],
"	\ "Colorscheme":    [["<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>']],
"	\ }
"



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
function! s:UpdateFileTemplate()
    let l:save_view = winsaveview()
    let l:save_cursor = getpos('.')
    let l:save_search = getreg('/')

    let l:exec_range = '1,' . min([line('$'), 10])
    let l:modify_regex = '\v\C(Last Modified: )\zs\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'

    silent! keepjumps execute l:exec_range . 's/' . l:modify_regex . '/\=strftime("%Y-%m-%d %H:%M:%S")/e'

    call winrestview(l:save_view)
    call setpos('.', l:save_cursor)
    call setreg('/', l:save_search)
endfunction

autocmd BufWritePre *.h,*.c,*.v,*.sv,*.vh,*.svh call s:UpdateFileTemplate()

"function! s:UpdateFileTemplate()
"    let l:exec_line = '1,' . min([line('$'), 10])
"    let l:modify_regex = '(Last Modified: )@<=([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})'
"    let l:eval_func = '\=eval("strftime(\"%Y-%m-%d %H:%M:%S\")")'
"    silent! normal! mm
"    silent! execute l:exec_line . 's/\v\C' . l:modify_regex . '/' . l:eval_func . '/'
"    silent! normal! `m
"    silent! execute 'delmarks m'
"    "silent! normal! zz
"endfunction
"autocmd BufWritePre *.h,*.c,*.v,*.sv,*.vh,*.svh call s:UpdateFileTemplate()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"vim-tempele and ultisnips
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"backup
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set backup
function Bkdir()
    let $BKODIR=expand("$HOME/.vim/backup")
    let $RUNTIMEPATH=expand("%:p:h")
    let $BKDIR=$BKODIR.$RUNTIMEPATH
    if !isdirectory(expand("$BKDIR"))
        call mkdir(expand("$BKDIR"),"p",0750)
    endif
endfunction
au BufWrite * call Bkdir()
autocmd BufWritePre * let &bex = '_'.strftime("%Y%m%d_%H_%M")
let &backupdir=expand("$HOME/.vim/backup").expand("%:p:h")

