command! NotoireNextLink call notoire#next_link()
command! NotoirePrevLink call notoire#prev_link()

command! NotoireOpenLink call notoire#open_link("edit")
command! NotoireOpenLinkSplit call notoire#open_link("split")
command! NotoireOpenLinkVsplit call notoire#open_link("vsplit")

command! NotoireOpenIndex call notoire#open_index("edit")
command! NotoireOpenIndexSplit call notoire#open_index("split")
command! NotoireOpenIndexVsplit call notoire#open_index("vsplit")

command! NotoireCreateNote call notoire#create_note("edit")
command! NotoireCreateNoteSplit call notoire#create_note("split")
command! NotoireCreateNoteVsplit call notoire#create_note("vsplit")

command! NotoireCreateLink call notoire#create_link("edit")
command! NotoireCreateLinkSplit call notoire#create_link("split")
command! NotoireCreateLinkVsplit call notoire#create_link("vsplit")

command! NotoireCheckHealth call notoire#check_health()
