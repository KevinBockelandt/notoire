"prevent content of the file to be loaded if it's already good
if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "note"

syntax match md_link "\[.\{-}\](.\{-})"
syntax match md_list "^\ *\*"
syntax match md_title "^#\+\ .*$"

highlight link md_link Label
highlight link md_list Structure
highlight link md_title Function
