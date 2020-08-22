" Absolute path of the plugin root directory.
let s:plugin_dir = resolve(expand('<sfile>:p:h:h'))

function! g:_wsp_not_available()
  echo 'wsp: action not available'
endfunction

" Default NOP keymappings
nnoremap <leader>pp :call g:_wsp_not_available()<cr>
nnoremap <leader>pd :call g:_wsp_not_available()<cr>
nnoremap <leader>pe :call g:_wsp_not_available()<cr>

" Correct mappings are loaded by the python remote plugin
function! g:_wsp_load_keymappings()
    " fzf all files tracked by the project
    nnoremap <leader>pp :WspFiles<cr>
    " fzf all directories tracked by the project
    nnoremap <leader>pd :WspDirs<cr>
    " Edit project config file.
    nnoremap <leader>pe :WspEditConfig<cr>
endfunction

" If python remote plugin is correctly loaded. Call the initializaiton function
" on VimEnter.
function! g:_wsp_init()
  " if exists('*WspInit')
    " call WspInit()
  " endif
endfunction

augroup augrp_wsp_init
  autocmd!
  autocmd VimEnter * call g:_wsp_init()
augroup END

" Indicates existance of this plugin.
let g:wsp_plugin_loaded = 1
