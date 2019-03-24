" General purpose functions and commands.

" Update remote plugin manifest
command! Urp :UpdateRemotePlugins

" source current buffer as vimscript
" command! SourceBuffer :source %

" Enable folding for vimscript.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

function! s:_command_to_buffer(cmd) abort
  redir @a
  silent execute a:cmd
  redir end
  enew
  put a
  normal! gg
endfunction

" Write output of a given command into new buffer.
command! -nargs=1 C2b call s:_command_to_buffer(<q-args>)

" Config for terminal buffer.
function! s:on_term_open() abort
  setlocal nonumber
  setlocal norelativenumber
  set filetype=Terminal
  startinsert
endfunction
autocmd TermOpen * call s:on_term_open()

" Lists output of a command in fzf. Output is split into a list of
" sorted lines. Each line is an item in FZF selector.
" (cmd:String, [callback:FuncRef]) => Nothing
function! s:cmd_output_in_fzf(cmd, ...) abort
  let Cb = a:0 > 0 ? a:1 : {... -> 0}
  redir => cmd_output
  silent execute a:cmd
  redir END
  let list = sort(split(cmd_output, "\n"))
  return fzf#run(fzf#wrap({'source': list, 'sink': Cb}))
  call feedkeys('i')
endfunction
" Lists all functions in fzf
command! Funcs call s:cmd_output_in_fzf('func')

" Lists all variables in fzf
command! Vars call s:cmd_output_in_fzf('let')

" Use Goyo mode when in markdown files.
" augroup goyo_for_markdown
"   autocmd!
"   autocmd BufEnter *.md Goyo 80x90%
"   autocmd BufLeave *.md Goyo!
" augroup END

" Set filetype correctly for markdown
augroup on_buf_md
  autocmd!
  autocmd BufNewFile,BufRead *.md set filetype=markdown
augroup END

"}}}
