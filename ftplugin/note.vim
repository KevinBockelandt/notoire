let b:link_regex = '\[.\+\](.\+)'

" --- COMMAND FUNCTIONS ------------------------------------------------------

function NotoireGoNextLink()
  exe "normal! /" . b:link_regex . "\<cr>l"
  noh
endfunction

function NotoireGoPrevLink()
  exe "normal! ?" . b:link_regex . "\<cr>l"
  noh
endfunction


" --- COMMANDS ---------------------------------------------------------------                                             

command! -buffer NotoireGoNextLink call NotoireGoNextLink()
command! -buffer NotoireGoPrevLink call NotoireGoPrevLink()

