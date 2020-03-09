"prevent content of the file to be loaded if it's already good
if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "note"

syntax match md_title "^#\+\ .*$"
highlight link md_title Function

syntax match md_quote "^>.*"
highlight link md_quote Comment

syntax match md_list "^\ *\*\ "
syntax match md_list "^\ *-\ "
highlight link md_list Identifier

syntax match md_italic "\<_.\{-}_\>"
syntax match md_italic "\*.\{-}\*"
highlight link md_italic Conditional

syntax match md_bold "\<__.\{-}__\>"
syntax match md_bold "\*\*.\{-}\*\*"
highlight link md_bold Constant

syntax match md_link "\[.\{-}\](.\{-})"
highlight link md_link Label

syntax match md_hor_rule "^----*$"
highlight link md_hor_rule Statement

syntax match md_inline_code "`.\{-}`"
highlight link md_inline_code String
