Peekaboo
========

This is a specially created plugin to be used in a standardized teamwork
workflow that utilizes Vimwiki+Fugitive for collaborative management of MOM and
technical note-taking.

Configuration
-------------
* Configure the `g:peekaboo_template_dir` within the `~/.vimrc` file like in the
  example below:
    ```
    let myWiki = {}
    let myWiki.path = $HOME.'/Documents/vimwiki/doc/'
    let myWiki.path_html = $HOME.'/Documents/vimwiki/html/'
    let myWiki.template_path = $HOME.'/Documents/vimwiki/templates/'
    let myWiki.auto_toc = 1
    let myWiki.auto_tags = 1
    let myWiki.vimwiki_use_calendar = 1

    let g:vimwiki_list = [myWiki]

    let g:peekaboo_template_dir = myWiki.template_path
    ```
* The `mom.wiki` template file must already exist within Peekaboo's template
  directory. If you have pulled the latest MWiki repository, that template file
  should already exist.
* Define `nnoremap <silent> <leader>lmt :PeekabooGenerateMOMTemplate<cr>` in the
  `~/.vimrc` file.

Usage
-----
* Pressing `<leader>lmt` in normal mode will generate the standard MOM templates
  below the cursor's current position.
* Pressing `<leader>td` either in Normal or Insert modes will print day and date
  like so: Sat Nov 18, 2023.
