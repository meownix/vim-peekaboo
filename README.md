Peekaboo
========

This is a specially created plugin to be used in a standardized teamwork
workflow that utilizes Vimwiki+Fugitive for collaborative management of MOM and
technical note-taking.

Configuration
-------------
* If you're using pathogen, cd into the `~/.vim/bundle` directory, then clone
  [vim-peekaboo](http://munchkin.apikkoho.com:3000/Eddy_n00319/vim-peekaboo.git) there.
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

Usage
-----
* Pressing `<leader>tt` either in Normal or Insert modes will print the text
  `YYYY/MM/DD.$USER`
* Pressing `<leader>td` in either Normal or Insert mode will print the day and
  date as follows: Sat Nov 18, 2023.
* Pressing `<leader>nd` in either Normal or Insert mode will prompt for the next
  working day's date. Users are free to enter any date they wish, and it will
  print the day and date for the entered date with the same format as the
  `<leader>td` keybinding mentioned above.
* Pressing `<leader>ga` in normal mode will generate the standard MOM template
  at the current cursor position.
