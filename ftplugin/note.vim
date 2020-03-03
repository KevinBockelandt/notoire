let b:link_regex = '\[.\+\](.\+)'

" --- GENERIC FUNCTIONS ------------------------------------------------------

function NotoireGoToLink(search_flags)
  let save_cursor = getcurpos()
  call search(b:link_regex, a:search_flags)

  " if we found a link and jumped to it, move cursor to be inside the bracket
  if getcurpos() != save_cursor
    normal! l
  endif
endfunction


" --- COMMAND FUNCTIONS ------------------------------------------------------

function NotoireNextLink()
  call NotoireGoToLink('')
endfunction

function NotoirePrevLink()
  call NotoireGoToLink('b')
endfunction


" --- COMMANDS ---------------------------------------------------------------                                             

command! -buffer NotoireNextLink call NotoireNextLink()
command! -buffer NotoirePrevLink call NotoirePrevLink()
