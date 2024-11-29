"==============================================================================
" File: plugin/peekaboo.vim
" Description: Specially created for a standardized teamwork workflow to manage
"              MOM and knowledge sharing using the Vimwiki+Fugitive.
" Author: Rowan Douglas <rowan.douglass@vimabc.xyz>
" License: BSD
"==============================================================================

if &cp || exists("g:peekaboo_loaded") && g:peekaboo_loaded
    finish
endif

if !exists("g:peekaboo_sop_tex_company_logo_path")
    let g:peekaboo_sop_tex_company_logo_path=$HOME . "/texmf/tex/latex/img/"
endif

let g:peekaboo_loaded = 1

let s:peekaboo_template_dir = expand('<sfile>:p:h') . '/../templates/'

if has('mac')
    silent exec 'language en_US.UTF-8'
elseif has('unix')
    silent exec 'language en_US.utf8'
endif

" Remove FoxPro-generated text in diff mode so that VimDiff will only diff
" actual lines of code written by programmers.
function! s:PeekabooRemoveGeneratedCode()
    call peekaboo#log("Calling PeekabooRemoveGeneratedCode()")
    if matchstr(getline(1), '^\*       Ö') ==  '*       Ö'
        let isFoxGCode = 1
    else
        let isFoxGCode = 0
    endif
    if &diff && isFoxGCode && !exists('b:cleaned')
        call peekaboo#log("Cleaning garbage in [" .. bufname() .. "]")
        silent! set modifiable|set bt=
        silent! 1,18d
        silent! g/\<_[0-9,a-z,A-Z]\{9\}/d
        silent! g/^\*.*From\ Screen:/d
        silent! set nomodifiable|set bt=nofile|let b:cleaned = 1
        call peekaboo#log("PeekabooRemoveGeneratedCode() condition matches:Garbage removed.")
    else
        call peekaboo#log("PeekabooRemoveGeneratedCode() condition unmatch:Does nothing.")
    endif
endfunction

augroup peekabooHatesFoxpro
    au!
    autocmd BufEnter *.spr,*.prg,*.mpr,*.SPR,*.PRG,*.MPR,svn-* set ft=foxpro |
                \set autoindent |
                \call s:PeekabooRemoveGeneratedCode()
augroup END

" Generate the top heading title for a newly created Vimwiki Diary file.
function! s:PeekabooGenerateNewVwkDiaryFileTitle()
    let Ymd = matchstr(expand('%:t'), '\d\{4\}-\d\{2\}-\d\{2\}')
    if Ymd != ''
        let vwkTitle = "= " .. strftime("%a %b %d, %Y", strptime("%Y-%m-%d", Ymd)) ..
                    \ " ="
        call append(0, vwkTitle)
        2,$ d _
        exec "normal! $"
    endif
endfunction

augroup peekabooAutoLoadTemplates
    au!
    autocmd BufNewFile *.html exec '0r ' . s:peekaboo_template_dir . 'page.html|normal! Gddgg'
    autocmd BufNewFile *.sh exec '0r ' . s:peekaboo_template_dir . 'script.sh|normal! Gddgg'
    autocmd BufNewFile *.zsh exec '0r ' . s:peekaboo_template_dir . 'script.zsh|normal! Gddgg'
    autocmd BufNewFile *.id.sop.tex call peekaboo#GenerateTexTemplate('latex.id.sop.tex')
    autocmd BufNewFile *.id.soi.tex call peekaboo#GenerateTexTemplate('latex.id.soi.tex')
    autocmd BufNewFile *.en.sop.tex exec '0r ' . s:peekaboo_template_dir . 'latex.en.sop.tex|normal! Gddgg'
    autocmd BufNewFile *.en.soi.tex exec '0r ' . s:peekaboo_template_dir . 'latex.en.soi.tex|normal! Gddgg'
    autocmd BufNewFile *.mom.tex exec '0r ' . s:peekaboo_template_dir . 'latex.mom.tex|normal! Gddgg'
    autocmd BufNewFile **/mom/**/*.wiki call peekaboo#GenerateMOMTemplate()
    autocmd BufNewFile *.wiki call s:PeekabooGenerateNewVwkDiaryFileTitle()
augroup END

" Below function and the following autocmd were taken from the vimwiki help
" file. I modified the function a little bit so that it will work with the
" vimwiki heading pound character and removed the part that preventing the
" last line before a heading to not folded. I don't quite understand how this
" only 5 lines of code function work yet, but it works perfectly as I wanted
" it to be.
function! s:PeekabooVimwikiFoldLevelCustom(lnum)
    let pounds = strlen(matchstr(getline(a:lnum), '^\ *=\+'))
    if (pounds)
        return '>' . pounds  " start a fold level
    endif
    return '=' " return previous fold level
endfunction

augroup PeekabooVimrcAuGroup
    autocmd!
    autocmd FileType vimwiki setlocal foldmethod=expr |
                \ setlocal foldenable |
                \ set foldexpr=s:PeekabooVimwikiFoldLevelCustom(v:lnum)
augroup END

nnoremap <silent> <leader>td "=peekaboo#printStdDateOfToday()<CR>p
inoremap <silent> <leader>td <C-R>=peekaboo#printStdDateOfToday()<CR>

nnoremap <silent> <leader>nd "=peekaboo#printStdDateOfSpecificDate()<CR>p
inoremap <silent> <leader>nd <C-R>=peekaboo#printStdDateOfSpecificDate()<CR>

nnoremap <silent> <leader>tt "=peekaboo#GenerateMOMFilename()<CR>P
inoremap <silent> <leader>tt <C-R>=peekaboo#GenerateMOMFilename()<CR>

nnoremap <silent> <leader>TT "=peekaboo#GenerateTouchTypingFilename()<CR>P
inoremap <silent> <leader>TT <C-R>=peekaboo#GenerateTouchTypingFilename()<CR>

nnoremap <silent> <leader>ds "=strftime("%Y%m%d")<CR>P
inoremap <silent> <leader>ds <C-R>=strftime("%Y%m%d")<CR>

nnoremap <silent> <leader>ga :PeekabooGenerateMOMTemplate<CR>

" Remove trailing spaces.
nnoremap <leader>rts :%s/\s\+$//g\|noh<cr>

" For slow pokers

nnoremap <f5> "=peekaboo#printStdDateOfToday()<CR>p
inoremap <f5> <C-R>=peekaboo#printStdDateOfToday()<CR>

nnoremap <f6> "=peekaboo#printStdDateOfSpecificDate()<CR>p
inoremap <f6> <C-R>=peekaboo#printStdDateOfSpecificDate()<CR>

"[Load Buffer Number] Load previously saved buffer number.
nnoremap <f8> :call peekaboo#restoreGitLogInNewTab()<cr>

" Default keybinding for PeekabooJournal command.
nnoremap <f9> :PND<cr>

"Buffer Wipeout Diff.
nnoremap <f10> :call peekaboo#closeDiffWinsAndRestoreGitLog()<cr>

" View and edit mode for Vimwiki file
nnoremap <silent><leader>vm :set concealcursor=nvic<cr>
nnoremap <silent><leader>em :set concealcursor=<cr>

nnoremap <silent><leader>lr :call peekaboo#renumberVimwikiTableList()<cr>

nnoremap <silent><leader>tc :call peekaboo#toggleColorColumn()<cr>

nnoremap <silent><leader>Tt :call peekaboo#turnVimwikiTagToLink()<cr>

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
command! PeekabooDiff vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis
command! PD vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis

" Run Fugitive's G command, open its result in new tab and enable reloading the
" output using the <leader>lbn and <F8> keybindings.
command! -nargs=* PeekabooG call peekaboo#fugitive(<q-args>)
command! -nargs=* PG call peekaboo#fugitive(<q-args>)

" Create a standardized MWiki's diary.
command! PeekabooNewDiary call peekaboo#newDiary()
command! PND call peekaboo#newDiary()

command! PeekabooRenumberTableList call peekaboo#renumberVimwikiTableList()
command! PLR call peekaboo#renumberVimwikiTableList()

command! PeekabooToogleColorColumn call peekaboo#toggleColorColumn()
command! PTC call peekaboo#toggleColorColumn()
