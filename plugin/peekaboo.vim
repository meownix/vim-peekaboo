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

let g:peekaboo_loaded = 1

if !exists("g:peekaboo_template_dir")
    let g:peekaboo_template_dir = expand('%:h') . '/../../templates/'
endif

" Remove FoxPro-generated text in diff mode so that VimDiff will only diff
" actual lines of code written by programmers.
function! s:PeekabooRemoveGeneratedCode()
    call peekaboo#log("Calling PeekabooRemoveGeneratedCode()")
    if matchstr(getline(1), '^\*       Ö') ==  '*       Ö'
        set ft=foxpro
        let isFoxGCode = 1
    else
        let isFoxGCode = 0
    endif
    if &diff && isFoxGCode && !exists('b:cleaned')
        call peekaboo#log("Cleaning garbage in [" .. bufname() .. "]")
        silent! set modifiable|set bt=
        silent! 1,18d
        silent! g/_[0-9,a-z,A-Z]\{9\}/d
        silent! g/^\*.*From\ Screen:/d
        silent! set nomodifiable|set bt=nofile|let b:cleaned = 1
        call peekaboo#log("PeekabooRemoveGeneratedCode() condition matches:Garbage removed.")
    else
        call peekaboo#log("PeekabooRemoveGeneratedCode() condition unmatch:Does nothing.")
    endif
endfunction

augroup peekabooHatesFoxpro
    au!
    autocmd BufEnter *.spr,*.prg,*.mpr,*.SPR,*.PRG,*.MPR,svn-* |
                \call s:PeekabooRemoveGeneratedCode()
augroup END

" Generate the top heading title for a newly created Vimwiki Diary file.
function! s:PeekabooGenerateNewVwkDiaryFileTitle()
    let Ymd = matchstr(expand('%:t'), '\d\{4\}-\d\{2\}-\d\{2\}')
    if Ymd != ''
        let vwkTitle = "= " .. strftime("%a %b %d, %Y", strptime("%Y-%m-%d", Ymd)) ..
                    \ " - ... press s to begin typing the title ... ="
        call append(0, vwkTitle)
        2,$ d _
        exec "normal! f.v5f."
    endif
endfunction

" Append the standardized MOM template to the current buffer and mark defined
" placeholders to ease the process of replacing each placeholder with built-in
" Vim motions.
function! s:PeekabooGenerateMOMTemplate()
    exec 'r ' . g:peekaboo_template_dir . 'mom.wiki'
    exec '0,0 d _'
    "Mark the MOM's subject placeholder to registry a.
    exec "normal! wma"
    "Mark the MOM tag name placeholder to registry b.
    exec 'normal! j0fTmb'
    "Mark the Date, time, & venue placeholder to registry c.
    exec 'normal! 4j0wmc'
    "Mark the 1st participant's name placeholder to registry d.
    exec 'normal! 4j02f[md'
    "Mark the 1st agenda point placeholder to registry e.
    exec 'normal! 4j0f[me'
    "Mark the 1st MOM point placeholder to registry f.
    exec 'normal! 4j0f[mf'
    "Mark the Acknowledgment & Comments placeholder to registry g.
    exec 'normal! 4j0f[mg'
    "Jump to the marker a
    exec 'normal! `a'
endfunction

augroup peekabooAutoLoadTemplates
    au!
    autocmd BufNewFile *.html 0r ~/.vim/templates/page.html
    autocmd BufNewFile *.sh 0r ~/.vim/templates/script.sh
    autocmd BufNewFile *.zsh 0r ~/.vim/templates/script.zsh
    autocmd BufNewFile *.sop.tex 0r ~/.vim/templates/latex.sop.tex
    autocmd BufNewFile *.mom.tex 0r ~/.vim/templates/latex.mom.tex
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

nmap <silent> <unique> <leader>td <Plug>PeekabooNPrintTheStdDateTime
nmap <silent> <unique> <Plug>PeekabooNPrintTheStdDateTime "=strftime("%a %b %d, %Y")<CR>P

imap <silent> <unique> <leader>td <Plug>PeekabooIPrintTheStdDateTime
imap <silent> <unique> <Plug>PeekabooIPrintTheStdDateTime <C-R>=strftime("%a %b %d, %Y")<CR>

nmap <silent> <unique> <leader>tt <Plug>PeekabooNPrintYMD
nmap <silent> <unique> <Plug>PeekabooNPrintYMD "=strftime("%Y/%m/%d") . "." . expand("$USER")<CR>P

imap <silent> <unique> <leader>tt <Plug>PeekabooIPrintYMD
imap <silent> <unique> <Plug>PeekabooIPrintYMD <C-R>=strftime("%Y/%m/%d") . "." . expand("$USER")<CR>

command! PeekabooGenerateMOMTemplate call s:PeekabooGenerateMOMTemplate()
