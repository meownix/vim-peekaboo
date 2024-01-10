Peekaboo
========

This is a specially created plugin to be used in a standardized teamwork
workflow that utilizes Vimwiki+Fugitive for collaborative management of MOM and
technical note-taking.

Configuration
-------------
* If you're using pathogen, cd into the `~/.vim/bundle` directory, then clone
  [vim-peekaboo](http://munchkin.apikkoho.com:3000/Eddy_n00319/vim-peekaboo.git) there.
* If you're using vim-plug, add this to your `~/.vimrc` or your vimrc's related
  configuration file:
  ```
  Plug 'http://munchkin.apikkoho.com:3000/Eddy_n00319/vim-peekaboo.git', { 'branch': 'main' }
  ```

Usage
-----
* Pressing `<leader>tt` either in Normal or Insert modes will print the text
  `YYYY/MM/DD.N.$USER`
* Pressing `<leader>td` or `<F5>` in either Normal or Insert mode will print the
  day and date as follows: Sat Nov 18, 2023.
* Pressing `<leader>nd` or `<F6>` in either Normal or Insert mode will prompt
  for the next working day's date. Users are free to enter any date they wish,
  and it will print the day and date for the entered date with the same format
  as the `<leader>td` keybinding mentioned above.
* Pressing `<leader>ga` in normal mode will generate the standard MOM template
  at the current cursor position. This feature might be deleted since a newly
  created Agenda & MOM wiki file has been made to automatically loaded with its
  standardized template.
* Specially defined to work with Fugitive's temporary files:
    - Pressing `<leader>ebn` or `<F7>` in normal mode will copy the current
      displayed buffer number to register `l` and display the number below the
      statusline. This is used to get the Fugitive commit log window buffer
      number and save it in the register `l` to be used later by the next
      keybinding below.
    - Pressing `<leader>lbn` or `<F8>` in normal mode to jump back to the
      buffer number saved in register `l` -- to jump back to the Fugitive commit
      log window.
    - Pressing `<leader>bwd` or `<F10>` in normal mode will wipe out the diff
      window's buffers. This is designed to close the side-by-side diff window
      created by Fugitive and wipe the buffers.
* `:PeekabooDiff` displays changes made side by side on an unsaved file.
