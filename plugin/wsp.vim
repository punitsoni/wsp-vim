" Make sure plugin is loaded only once.
if exists('g:loaded_wsp') | finish | endif

" Absolute path of the plugin root directory.
let g:wsp_plugin_dir = resolve(expand('<sfile>:p:h:h'))


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

function! g:_wsp_fzf_run()
  let spec = { 'source': 'ls' }

  function! spec.sink(x)
    echo 'hello ' .. a:x
    call append(line('$'), 'hello ' .. a:x)
  endfunction

  call fzf#run(spec)
endfunction




" Indicates existance of this plugin.
let g:loaded_wsp = 1
