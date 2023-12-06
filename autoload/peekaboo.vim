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

function! peekaboo#log(msg)
    if !exists("g:peekaboo_log_dir")
        let g:peekaboo_log_dir = "/tmp/"
    endif
    let debugFile = g:peekaboo_log_dir . "debug.peekaboo.log"
    if filereadable(debugFile) == 1
        call writefile([strftime("%c") . " - " . a:msg], debugFile, "a")
    endif
endfunc

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

"Automatically generate the standardized path and naming convention for the MOM
"file, which will auto-increment the numerical counter in the filename.
function! peekaboo#GenerateMOMFilename()
    let momCounter = 1
    let momFilename = strftime("%Y/%m/%d") . ".1." . expand("$USER")
    echom expand("%:h") . "/" . momFilename . ".wiki"
    while filereadable(expand("%:h") . "/" . momFilename . ".wiki")
        let momCounter = momCounter + 1
        let momFilename = strftime("%Y/%m/%d") . "." . string(momCounter) . "." . expand("$USER")
    endwhile
    return momFilename
endfunction

function! peekaboo#printStdDateOfToday()
    return strftime("%a %b %d, %Y")
endfunction

"Display the shell's `cal -3` output with today's highlighted date removed, as
"it will be printed messily. Then, assign a default next working date to be
"adjusted by the user.
function! peekaboo#printStdDateOfSpecificDate()
    let currentDate = localtime()
    let nextDate = currentDate + 24 * 60 * 60

    while strftime("%u", nextDate) =~# '[67]'
        let nextDate = nextDate + 24 * 60 * 60
    endwhile

    let answer = input(substitute(system('cal -3'), '[^\ A-Za-z0-9\n]', '', 'g') . "\n
                \Enter the meeting date (YYYYMMDD): ", strftime("%Y%m%d", nextDate))

    return strftime("%a %b %d, %Y", strptime("%Y%m%d", answer))
endfunction
