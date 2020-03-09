"prevent content of the file to be loaded if it's already good
if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "note"

syntax match md_title /^#\+\ .*$/
highlight link md_title Function

syntax match md_quote /^>.*/
highlight link md_quote Comment

syntax match md_list "^\ *\*\ "
syntax match md_list "^\ *-\ "
syntax match md_list "^\ *\d*\.\ "
highlight link md_list Identifier

syntax match md_italic "\<_.\{-}_\>"
syntax match md_italic "\*.\{-}\*"
highlight link md_italic Conditional

syntax match md_bold "\<__.\{-}__\>"
syntax match md_bold "\*\*.\{-}\*\*"
highlight link md_bold Constant

" see :help 44.5 and :help \zs for details on this
syntax match md_link_text /\[\zs.\{-}\ze\](.\{-})/ contained
highlight link md_link_text Label
syntax match md_link_all /\[.\{-}\](.\{-})/ contains=md_link_text
highlight link md_link_all Comment

syntax match md_hor_rule "^----*$"
highlight link md_hor_rule Statement

syntax match md_inline_code "`.\{-}`"
highlight link md_inline_code String
