"==============================================================================
" File: autoload/peekaboo.vim
" Description: Specially created for a standardized teamwork workflow to manage
"              MOM and knowledge sharing using the Vimwiki+Fugitive.
" Author: Rowan Douglas <rowan.douglass@vimabc.xyz>
" License: BSD
"==============================================================================

if &cp || exists("g:peekaboo_autoload_loaded") && g:peekaboo_autoload_loaded
    finish
endif

let g:peekaboo_autoload_loaded = 1
let s:peekaboo_template_dir = expand('<sfile>:p:h') . '/../templates/'
let s:gitLogFilename = ""

function! peekaboo#log(msg)
    if !exists("g:peekaboo_log_dir")
        let g:peekaboo_log_dir = "/tmp/"
    endif
    let debugFile = g:peekaboo_log_dir . "debug.peekaboo.log"
    if filereadable(debugFile) == 1
        call writefile([strftime("%c") . " - " . a:msg], debugFile, "a")
    endif
endfunc

function! peekaboo#GenerateTexTemplate(templateFile)
    exec '0r ' . s:peekaboo_template_dir . a:templateFile

    let companyId = matchstr(expand('%:t'), '\.\zs[^.]*\ze\.')

    let logoFile = g:peekaboo_sop_tex_company_logo_path .
                \companyId . ".png"

    call writefile(["logoFile = " . logoFile], "/tmp/debug.log", "a")

    if filereadable(logoFile)
        exec "%s/logo\.png/" . companyId . "\.png/g"
        exec "%s/NPL-/" . toupper(companyId) . "-/g"
        exec "%s/-MM-YYYY/-" . strftime("%m-%Y", localtime()) . "/g"
    endif

    exec "normal! Gddgg"
endfunction

" Append the standardized MOM template to the current buffer and mark defined
" placeholders to ease the process of replacing each placeholder with built-in
" Vim motions.
function! peekaboo#GenerateMOMTemplate()
    exec 'r ' . s:peekaboo_template_dir . 'mom.wiki'
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

"Automatically generate the standardized path and naming convention for the
"MOM/SOPI Wiki file, which will auto-increment the numerical counter in the
"filename.
function! peekaboo#GenerateMOMFilename()
    if expand("%:p")[-19:] == "/doc/mom/index.wiki" ||
                \ expand("%:p")[-19:] == "/doc/srs/index.wiki" ||
                \ expand("%:p")[-19:] == "/doc/std/index.wiki" ||
                \ expand("%:p")[-19:] == "/doc/tex/index.wiki" ||
                \ expand("%:p")[-18:] == "/doc/gpgIndex.wiki"
        if expand("%:f") == "gpgIndex.wiki"
            let thePath = expand("%:p:h") . "/../gpg"
            let thePrefix = thePath[-7:]
        else
            let thePath = expand("%:p:h")
            let thePrefix = thePath[-4:]
        endif
    else
        echohl WarningMsg
        echo "Generate MWiki's fullpath only works for MOM, SRS, Tex, GPG & SOP/I Wiki Index files."
        echohl None
        return ""
    endif
    let theCounter = 1
    let theFilename = strftime("%Y/%m/%d") . ".1." . expand("$USER")
    "echom expand("%:h") . "/" . theFilename . ".wiki"
    while filereadable(thePath .  "/" . theFilename . ".wiki")
        let theCounter = theCounter + 1
        let theFilename = strftime("%Y/%m/%d") . "." . string(theCounter) . "." . expand("$USER")
    endwhile
    return thePrefix . "/" . theFilename
endfunction

"Automatically generate the standardized path and naming convention for the
"Touch typing practice Wiki file: yyyy/mm/dd.user.typingPractice
function! peekaboo#GenerateTouchTypingFilename()
    if expand("%:t") == "TouchTyping.wiki"
        let theTTLink = "[[" . strftime("%Y/%m/%d") . "." . expand("$USER") .
                    \ ".typingPractice" . "|" . strftime("%a %b %d, %Y") . "]]"
        return theTTLink
    else
        echohl WarningMsg
        echo "Generate Touch Typing Practice fullpath only works within the Touch Typing file index."
        echohl None
        return ""
    endif
endfunction

function! peekaboo#printStdDateOfToday()
    return strftime("%a %b %d, %Y")
endfunction

"Display the shell's `cal -3` output with today's highlighted date removed, as
"it will be printed messily. Then, assign a default next working date to be
"adjusted by the user.
function! peekaboo#printStdDateOfSpecificDate()
    let currentDate = localtime()
    let nextDate = currentDate + 2 * 24 * 60 * 60

    while strftime("%u", nextDate) =~# '[67]'
        let nextDate = nextDate + 24 * 60 * 60
    endwhile

    let answer = inputdialog(
                \substitute(system('cal -3w'),
                \ '[^\ A-Za-z0-9\n]', '', 'g'
                \) . "\nEnter the meeting date (YYYYMMDD): ",
                \ strftime("%Y%m%d", nextDate)
                \)

    if empty(answer)
        return ""
    else
        return strftime("%a %b %d, %Y", strptime("%Y%m%d", answer))
    endif
endfunction

"Execute the Fugitive's G command and passing accepted GIT's commands, open its
"result in a new tab and reloadable by using the <leader>lbn keybinding.
function! peekaboo#fugitive(params)
    if exists(':G')
        if empty(expand('%'))
            tabe
        else
            tabe %
        endif
        silent! exec "G " . a:params
        only
        call peekaboo#storeGitLogFilename()
    else
        echohl WarningMsg
        echo "The G command is not available. Check your configuration for the Fugitive plugin."
        echohl None
    endif
endfunction

function! peekaboo#storeGitLogFilename()
    if &ft == "git"
        let s:gitLogFilename = expand('%')
    endif
endfunction

function! peekaboo#restoreGitLogInNewTab()
    if !empty(s:gitLogFilename) && filereadable(s:gitLogFilename)
        silent! exe "tabe " . expand(s:gitLogFilename)
    endif
endfunction

function! peekaboo#closeDiffWinsAndRestoreGitLog()
    bw% #
    call peekaboo#restoreGitLogInNewTab()
endfunction

"Automatically generate the standardized path and naming convention for the
"MWiki's Diary, which will auto-increment the numerical counter in the filename.
function! peekaboo#newDiary()
    if exists(':VimwikiDiaryIndex')
        silent! exec ":tabe %|VimwikiDiaryIndex"
        let thePath = expand("%:h")
        let theCounter = 1
        let theFilename = strftime("%Y-%m-%d") . ".1." . expand("$USER") . ".wiki"
        while filereadable(thePath .  "/" . theFilename)
            let theCounter = theCounter + 1
            let theFilename = strftime("%Y-%m-%d") . "." . string(theCounter) . "." . expand("$USER") . ".wiki"
        endwhile
        silent! exec ":e " . thePath . "/" . theFilename
    else
        echo "Peekaboo cannot generate Vimwiki Extended Diary without Vimwiki."
    endif
endfunction

function! peekaboo#renumberVimwikiTableList()
    if getline('.') =~ '^|\s*[0-9]*\.\s*|'
        let currentLine = line('.')
        let currentColumn = col('.')
        exec "?^|\ *--"
        exec "noh"
        exec "normal! jf "
        exec "normal! \<C-v>}kt|"
        exec "normal! c1."
        exec "normal! j\<c-v>}kt|g\<c-a>"
        exec "VimwikiTableAlignW"
        call cursor(currentLine, currentColumn)
    else
        echo "Move cursor to any row of a table that has point number."
    endif
endfunction

function! peekaboo#toggleColorColumn()
    if &colorcolumn == 0
        set cc=80
    else
        set cc=0
    endif
endfunction

function! peekaboo#turnVimwikiTagToLink()
    let currentFile = expand('%')
    exec "normal! \<C-]>"
    if currentFile != expand('%')
        exec "normal! k"
        let theTitle = substitute(getline('.'), '\s*=\s*', '', 'g')
        let thePath = substitute(expand('%:p'), '^.*\/doc\(.*\)\.wiki$', '\1', '')
        exec "normal! \<C-o>"
        if !empty(theTitle)
            let previous_tw=&tw
            set tw=0
            exec "normal! caw [[" . expand(thePath) . "|" . expand(theTitle) . "]]"
            exec "set tw=" . expand(previous_tw)
        else
            echo "Currently only support for tag for MWiki's title."
        endif
    endif
endfunction
