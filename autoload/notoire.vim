" Return a string representing an ID usable for a new note
function! notoire#get_next_note_id()
  let existing_ids = notoire#get_id_existing_notes()
  let biggest_id = 0

  " go through all existing ids to find the biggest one
  for id_str in existing_ids
    let id_num = str2nr(id_str, 16)
    if id_num > biggest_id
      let biggest_id = id_num
    endif
  endfor

  return printf("%x", biggest_id + 1)
endfunction

" Return the list of IDs matching the notes in the note folder
function! notoire#get_id_existing_notes()
  let note_ids = []

  let filenames = system("ls -1 " . g:notoire_folder)
  let filenames = split(filenames, "\n")

  " check the filename is indeed a note and if yes keep only the id
  for i in range(0, len(filenames) - 1)
    if fnamemodify(filenames[i], ":e") == g:notoire_file_extension[1:-1]
      let root = fnamemodify(filenames[i], ":r")
      let match_hex = matchstr(root, '\x\+')
      if len(match_hex) == len(root)
        call add(note_ids, root)
      endif
    endif
  endfor

  return note_ids
endfunction

" Check for various potential issues with the current setup
function! notoire#check_health()
  " TODO find links that do not link anywhere
  " TODO check for empty notes
  echo "TODO - Should be performing the check"
endfunction

" Return the full path for a note based on the filename
function! notoire#get_full_path(note_name)
  return g:notoire_folder . a:note_name . g:notoire_file_extension
endfunction


" --- LINK FUNCTIONS --------------------------------------------------------

" Move the cursor to the next or previous link in the buffer
function! notoire#go_to_link(search_flags)
  let save_cursor = getcurpos()

  " Searching backward will not exclude the first match as long as it doesn't
  " start directly under the cursor. The following ugly hack is used to
  " position the cursor on the first chara of the link assuming it's on the
  " second, which will be the case after an automatic search
  if a:search_flags == 'b'
    normal! h
  endif

  call search(g:ntr_link_rx, a:search_flags)

  " if we found a link and jumped to it, move cursor to be inside the bracket
  if getcurpos() != save_cursor
    normal! l
  endif
endfunction

" Return the entire link (text included) under the cursor or -1 if there isn't
function! notoire#get_link_under_cursor()
  let cur_col = col('.')
  let cur_line = getline('.')
  let temp_col = 0

  while 1
    let link_str = matchstrpos(cur_line, g:ntr_link_rx, temp_col)

    "if we can't find anymore link, we exit the function with failure
    if link_str[1] == -1
      return -1
    "if we find a link and the cursor is on, return the link
    elseif cur_col > link_str[1] && cur_col <= link_str[2]
      return link_str[0]
    "if we find a link but the cursor is not on, look for next link on line
    else
      let temp_col = link_str[2]
    endif
  endwhile
endfunction

" Go to the next link in the note. Repeated 'count' times
function! notoire#next_link(count)
  let c = str2nr(a:count)
  while c > 0
    call notoire#go_to_link('')
    let c -= 1
  endwhile
endfunction

" Go to the previous link in the note. Repeated 'count' times
function! notoire#prev_link(count)
  let c = str2nr(a:count)
  while c > 0
    call notoire#go_to_link('b')
    let c -= 1
  endwhile
endfunction


" --- OPEN FUNCTIONS --------------------------------------------------------

" Open the link under the cursor
function! notoire#open_link(cmd)
  let link = notoire#get_link_under_cursor()
  if link != -1
    let note_id = matchstr(link, '(\x\+)$')

    "if we found the note to open, update the history and open the note
    if note_id != ""
      call notoire#open_file(a:cmd, notoire#get_full_path(note_id[1:-2]))
    else
      echom "Error: cannot open note for link " . link
    endif
  endif
endfunction

" Open or create the index file (always note 0)
function! notoire#open_index(cmd)
  call notoire#open_file(a:cmd, notoire#get_full_path("/0"))
endfunction


" --- SEARCH FUNCTIONS -------------------------------------------------------

" Search or create a new note with FZF
function! notoire#search_notes(cmd)
  call notoire#run_fzf(notoire#notes_content(), a:cmd, 0)
endfunction

" List all the links present in the current note
function! notoire#search_links_in_note(cmd)
  let cur_file = expand('%:p')
  if cur_file == ""
    return
  endif

  " use an external command to get the list of links in the current file
  let links = system('rg -o -e "\[.+?\]\(.+?\)" ' . cur_file)
  let links = split(links, "\n")

  " format each link match to use it as input for fzf
  for i in range(0, len(links) - 1)
    let link = links[i]

    " get informations about the id part of the link. Return an array
    " [0] the string matching the pattern
    " [1] index of first char of the match
    " [2] index of last char of the match
    let id_info = matchstrpos(link, '(\x\{-})$')

    let id_part = id_info[0][1:-2] . " "
    let text_part = link[0:id_info[1] - 1]
    let links[i] = id_part . text_part
  endfor

  call notoire#run_fzf(links, a:cmd, 0)
endfunction

" List all the notes linking to the current one
function! notoire#search_notes_linking_here(cmd)
  let cur_file = expand('%:t:r')
  if cur_file == ""
    return
  endif

  " use external command rg to find links to the current note
  let results = system('rg -e "\[.+?\]\('.cur_file.'\)" '.g:notoire_folder.'/*'.g:notoire_file_extension)
  let results = split(results, "\n")

  " format the rg results to use as input of fzf
  for i in range(0, len(results) - 1)
    echom results[i]
    let res_parts = split(results[i], ":")
    let res_parts[1] = join(res_parts[1:-1], '')
    let res_filename = split(res_parts[0], "\/")[-1]
    let res_filename = fnamemodify(res_filename, ":r")
    let results[i] = res_filename . " " . res_parts[1]
  endfor

  call notoire#run_fzf(results, a:cmd, 0)
endfunction

" List all the notes that are not linked anywhere
function! notoire#search_orphan_notes(cmd)
  let linked_ids = []   " note ids that are present in a link somewhere
  let orphan_ids = []   " ids for notes that are not linked to anywhere
  let fzf_source = []   " list of strings used as source for fzf

  " perform a regex search once to get all links in every note
  let links = system('rg -oIN -e "\[.+?\]\([0-9a-f]+?\)" '.g:notoire_folder.'/*'.g:notoire_file_extension)
  let links = split(links, "\n")

  " strip those links to keep only the note id
  for i in range(0, len(links) - 1)
    let note_id = matchstr(links[i], '(\x\{-})$')
    let note_id = note_id[1:-2]
    call add(linked_ids, note_id)
  endfor

  " check for each note if it is referenced in a link or not
  let note_ids = notoire#get_id_existing_notes()
  for i in range(0, len(note_ids) - 1)
    if index(linked_ids, note_ids[i]) == -1
      call add(orphan_ids, note_ids[i])
    endif
  endfor

  " format the results to be used as source for fzf
  for i in range(0, len(orphan_ids) - 1)
    let id = orphan_ids[i]
    let entry = id . " " . system('head -n 1 ' . g:notoire_folder.id.g:notoire_file_extension)
    call add(fzf_source, entry)
  endfor

  call notoire#run_fzf(fzf_source, a:cmd, 0)
endfunction


" --- FZF RELATED FUNCTIONS --------------------------------------------------

" Return a list where each item is the content of a note. Formatted in a way
" that it can be used as a source for FZF
function! notoire#notes_content()
  let note_ids = notoire#get_id_existing_notes()
  let content = []

  for i in range(0, len(note_ids) - 1)
    let toAdd = note_ids[i]." ".system("cat ".g:notoire_folder.note_ids[i].g:notoire_file_extension)
    call add(content, toAdd)
  endfor
  
  call add(content, "NEW - select to create new note")
  return content
endfunction

" Function called with the selection of FZF
" param cmd is the command used to open the file
" param link_creation indicates what to do regarding link creation
" 0 - no link creation
" 1 - create link with visual selection
" 2 - create link without visual selection
" param e is the selection of FZF. The first word is the id of the note
function! notoire#process_fzf_choice(cmd, link_creation, e)
  let note_id = split(a:e)[0]

  if note_id == "NEW"
    let note_id = notoire#get_next_note_id()
  endif

  " if we choose to create a link with visual selection
  if a:link_creation == 1
    echom "about to execute in visual"
    exe "normal! \ei[\e`>la](" . note_id . ")\e"
  " if we choose to create a link without visual selection
  elseif a:link_creation == 2
    exe "normal! \ei[](" . note_id . ")\eF]"
  endif

  call notoire#open_file(a:cmd, g:notoire_folder."/".note_id.g:notoire_file_extension)
endfunction

" Return a string with the options to use when running fzf
function! notoire#get_fzf_opt()
  let o_pw = " --preview-window=down:60%:wrap"
  let o_p_base = "fmt {1}" . g:notoire_file_extension
  let o_p = ' --preview="' . o_p_base . '"'
  let o_base = ' -e +m --cycle'
  let o_dsp = ' --no-bold --info="inline"'
  let o_col = " --color=border:#FF8888,hl:#FFF714,hl+:#FFF714"

  " apply user defined color scheme if it exists
  if exists('g:notoire_color')
    let o_col = " " . g:notoire_color
  endif

  return o_base . o_dsp . o_p . o_pw . o_col
endfunction

" Search for a note in all notes
function! notoire#run_fzf(source, cmd, link_creation)
  call fzf#run({
    \ 'source': a:source,
    \ 'sink': function('notoire#process_fzf_choice', [a:cmd, a:link_creation]),
    \ 'dir': g:notoire_folder,
    \ 'options': notoire#get_fzf_opt()
  \ })
endfunction


" --- HISTORY FUNCTIONS -----------------------------------------------------

" Open a file and update associated history
function! notoire#open_file(cmd, filename)
  let new_history = getbufvar("%", "history", []) " get history of current buf
  call add (new_history, expand("%:p"))           " append filename of cur buf

  " always save the current buffer before opening the new one. Except when the
  " current buffer doesn't have a name
  if expand('%:t') != ""
    write
  endif

  exe a:cmd a:filename
  write
  call setbufvar("%", "history", new_history)     " set history on new buf
endfunction

" Go to the previous note in the history
function! notoire#prev_note(cmd)
  let history = getbufvar("%", "history", []) " get history of current buf
  if len(history) <= 0                        " if no history we quit
    return
  endif
  exe a:cmd history[-1]
  if len(history) > 1                         " pop last item of history
    let history = history[0:-2]
  endif
  call setbufvar("%", "history", history)     " set history on new buf
endfunction


" --- CREATE FUNCTIONS ------------------------------------------------------

" Create a new note from selection and open it
function! notoire#create_note(cmd)
  let note_id = notoire#get_next_note_id()

  " delete the visual selection and write the empty link in place of
  let save_a = @a
  exe "normal! gv\"ad"
  exe "normal! \ei[](" . note_id . ")\eF]"

  " open the new note and paste content
  call notoire#open_file(a:cmd, notoire#get_full_path("/".note_id))
  exe "normal! \"ap"
  write

  let @a = save_a
endfunction

" Create a new empty note and open it
function! notoire#create_empty_note(cmd)
  let note_id = notoire#get_next_note_id()
  call notoire#open_file(a:cmd, notoire#get_full_path("/".note_id))
endfunction

" Create link to a note (selected through search or new) where the text is the
" visual selection
function! notoire#create_link(cmd)
  call notoire#run_fzf(notoire#notes_content(), a:cmd, 1)
endfunction

" Create link without text to a note (selected through search or new)
function! notoire#create_empty_link(cmd)
  call notoire#run_fzf(notoire#notes_content(), a:cmd, 2)
endfunction
