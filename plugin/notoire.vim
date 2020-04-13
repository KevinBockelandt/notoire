let g:ntr_link_rx = '\[.\{-}\](.\{-})'

command! -nargs=1 NotoireNextLink call notoire#next_link(<args>)
command! -nargs=1 NotoirePrevLink call notoire#prev_link(<args>)

command! NotoireOpenLink call notoire#open_link("edit")
command! NotoireOpenLinkS call notoire#open_link("split")
command! NotoireOpenLinkVS call notoire#open_link("vsplit")

command! NotoireOpenIndex call notoire#open_index("edit")
command! NotoireOpenIndexS call notoire#open_index("split")
command! NotoireOpenIndexVS call notoire#open_index("vsplit")

command! NotoirePrevNote call notoire#prev_note("edit")
command! NotoirePrevNoteS call notoire#prev_note("split")
command! NotoirePrevNoteVS call notoire#prev_note("vsplit")

command! NotoireCreateNote call notoire#create_note("edit")
command! NotoireCreateNoteS call notoire#create_note("split")
command! NotoireCreateNoteVS call notoire#create_note("vsplit")

command! NotoireCreateEmptyNote call notoire#create_empty_note("edit")
command! NotoireCreateEmptyNoteS call notoire#create_empty_note("split")
command! NotoireCreateEmptyNoteVS call notoire#create_empty_note("vsplit")

command! NotoireCreateLink call notoire#create_link("edit")
command! NotoireCreateLinkS call notoire#create_link("split")
command! NotoireCreateLinkVS call notoire#create_link("vsplit")

command! NotoireCreateEmptyLink call notoire#create_empty_link("edit")
command! NotoireCreateEmptyLinkS call notoire#create_empty_link("split")
command! NotoireCreateEmptyLinkVS call notoire#create_empty_link("vsplit")

command! NotoireSearchNotes call notoire#search_notes("edit")
command! NotoireSearchNotesS call notoire#search_notes("split")
command! NotoireSearchNotesVS call notoire#search_notes("vsplit")

command! NotoireSearchLinksInNote call notoire#search_links_in_note("edit")
command! NotoireSearchLinksInNoteS call notoire#search_links_in_note("split")
command! NotoireSearchLinksInNoteVS call notoire#search_links_in_note("vsplit")

command! NotoireSearchOrphanNotes call notoire#search_orphan_notes("edit")
command! NotoireSearchOrphanNotesS call notoire#search_orphan_notes("split")
command! NotoireSearchOrphanNotesVS call notoire#search_orphan_notes("vsplit")

command! NotoireSearchNotesLinkingHere call notoire#search_notes_linking_here("edit")
command! NotoireSearchNotesLinkingHereS call notoire#search_notes_linking_here("split")
command! NotoireSearchNotesLinkingHereVS call notoire#search_notes_linking_here("vsplit")


if exists('g:notoire_user_mapping') == 0
  nnoremap <Leader>l :<C-U>NotoireNextLink(v:count1)<cr>
  nnoremap <Leader>h :<C-U>NotoirePrevLink(v:count1)<cr>

  nnoremap <Leader>j :NotoireOpenLink<cr>
  nnoremap <Leader>sj :NotoireOpenLinkS<cr>
  nnoremap <Leader>vj :NotoireOpenLinkVS<cr>

  nnoremap <Leader>m :NotoireCreateEmptyLink<cr>
  nnoremap <Leader>sm :NotoireCreateEmptyLinkS<cr>
  nnoremap <Leader>vm :NotoireCreateEmptyLinkVS<cr>

  vnoremap <Leader>m :<C-U>NotoireCreateLink<cr>
  vnoremap <Leader>sm :<C-U>NotoireCreateLinkS<cr>
  vnoremap <Leader>vm :<C-U>NotoireCreateLinkVS<cr>

  nnoremap <Leader>n :NotoireCreateEmptyNote<cr>
  nnoremap <Leader>sn :NotoireCreateEmptyNoteS<cr>
  nnoremap <Leader>vn :NotoireCreateEmptyNoteVS<cr>

  vnoremap <Leader>n :<C-U>NotoireCreateNote<cr>
  vnoremap <Leader>sn :<C-U>NotoireCreateNoteS<cr>
  vnoremap <Leader>vn :<C-U>NotoireCreateNoteVS<cr>

  nnoremap <Leader>k :NotoirePrevNote<cr>
  nnoremap <Leader>sk :NotoirePrevNoteS<cr>
  nnoremap <Leader>vk :NotoirePrevNoteVS<cr>

  nnoremap <Leader>u :NotoireSearchNotes<cr>
  nnoremap <Leader>su :NotoireSearchNotesS<cr>
  nnoremap <Leader>vu :NotoireSearchNotesVS<cr>

  nnoremap <Leader>o :NotoireSearchLinksInNote<cr>
  nnoremap <Leader>so :NotoireSearchLinksInNoteS<cr>
  nnoremap <Leader>vo :NotoireSearchLinksInNoteVS<cr>

  nnoremap <Leader>y :NotoireSearchNotesLinkingHere<cr>
  nnoremap <Leader>sy :NotoireSearchNotesLinkingHereS<cr>
  nnoremap <Leader>vy :NotoireSearchNotesLinkingHereVS<cr>

  nnoremap <Leader>i :NotoireSearchOrphanNotes<cr>
  nnoremap <Leader>si :NotoireSearchOrphanNotesS<cr>
  nnoremap <Leader>vi :NotoireSearchOrphanNotesVS<cr>

  nnoremap <Leader><Tab> :NotoireOpenIndex<cr>
  nnoremap <Leader>s<Tab> :NotoireOpenIndexS<cr>
  nnoremap <Leader>v<Tab> :NotoireOpenIndexVS<cr>
endif


if exists('g:notoire_file_extension') == 0
  let g:notoire_file_extension = '.note'
elseif g:notoire_file_extension[0] != '.'
  let g:notoire_file_extension = '.' . g:notoire_file_extension
endif

if exists('g:notoire_folder') == 0
  echom "You need to define the g:notoire_folder"
elseif g:notoire_folder[-1] != '.'
  let g:notoire_folder = g:notoire_folder . '/'
endif
