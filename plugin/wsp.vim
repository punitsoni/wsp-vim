" get full absolute path of the plugin root directory. This will be ../../
" from the this script file. We can use this path get access to helper scripts.
let g:prj_plugin_dir = resolve(expand('<sfile>:p:h:h'))

" fzf a list of files. Opens file on selection.
function! g:_prj_fzf_files(files)
    call fzf#run(fzf#wrap({'source': a:files}))
    call feedkeys('i')
endfunction

" General purpose fzf selector. Feed a list of items into fzf. When
" makes a selection, function with name cb is called with selection.
function! g:_prj_fzf_select(items, cb)
    call fzf#run(fzf#wrap({'source': a:items, 'sink': function(a:cb)}))
    call feedkeys('i')
endfunction

function! g:_prj_enable_maps()
    " fzf all files tracked by the project
    nnoremap <leader>pp :ProjectFiles<cr>

    " fzf all directories tracked by the project
    nnoremap <leader>pd :ProjectDirs<cr>

    " Edit project config file.
    nnoremap <leader>pe :PrjEditConfig<cr>

    " Goto definition.
    nnoremap <leader>gd :PrjGotoDef<cr>
    nnoremap <leader>. :PrjGotoDef<cr>

    " Find references.
    nnoremap <leader>gr :PrjFindRefs<cr>
    nnoremap <leader>/ :PrjFindRefs<cr>

    " Go back in jump history
    nnoremap <leader>gb :PrjGoBack<cr>
endfunction

" remote plugin entrypoint.
autocmd VimEnter * call PrjInit()

" Workaround for function not loading issue.
autocmd VimEnter * call _prj_jumptag()

" Indicates existance of this plugin.
let g:prj_plugin_loaded = 1
