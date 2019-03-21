" Entrypoint script for wsp-vim plugin.

" get full absolute path of the plugin root directory. This will be ../../
" from the this script file. We can use this path get access to helper scripts.
let g:wsp_plugin_dir = resolve(expand('<sfile>:p:h:h'))

" fzf a list of files. Opens file on selection.
function! g:_wsp_fzf_files(files)
    call fzf#run(fzf#wrap({'source': a:files}))
    call feedkeys('i')
endfunction

" General purpose fzf selector. Feed a list of items into fzf. When
" makes a selection, function with name cb is called with selection.
function! g:_wsp_fzf_select(items, cb)
    call fzf#run(fzf#wrap({'source': a:items, 'sink': function(a:cb)}))
    call feedkeys('i')
endfunction

function! g:_wsp_load_keymappings()
    " fzf all files tracked by the project
    nnoremap <leader>pp :WspFiles<cr>

    " fzf all directories tracked by the project
    nnoremap <leader>pd :WspDirs<cr>

    " Edit project config file.
    nnoremap <leader>pe :WspEditConfig<cr>
endfunction

" Source a config file by name.
function! SourceConfig(filepath) abort
  execute 'source ' . '/' . a:filepath
endfunction

call SourceConfig(g:wsp_plugin_dir . '/helpers/core_utils.vim')

" remote plugin entrypoint.
autocmd VimEnter * call WspInit()

" Indicates existance of this plugin.
let g:wsp_plugin_loaded = 1
