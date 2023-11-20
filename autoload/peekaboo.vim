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

function! peekaboo#log(msg)
    if !exists("g:peekaboo_log_dir")
        let g:peekaboo_log_dir = "/tmp/"
    endif
    let debugFile = g:peekaboo_log_dir . "debug.peekaboo.log"
    if filereadable(debugFile) == 1
        call writefile([strftime("%c") . " - " . a:msg], debugFile, "a")
    endif
endfunc
