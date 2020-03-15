" Notes are nammed with a UID. We look up the highest name in the note folder
" and return the increment to get a new name. UIDs are in hexadecimal
" Return a string representing the ID in hex
function! notoire#get_next_note_id()
  " TODO check the scope of variables
  let paths = globpath(g:notoire_folder, '*.note', 0, 1)
  let biggestId = 0

  for path in paths
    " only keep the id in the filename and convert to decimal for comparison
    let filename = str2nr(fnamemodify(path, ':t:r'), 16)

    if filename > biggestId
      let biggestId = filename
    endif
  endfor

  return printf("%x", biggestId + 1)
endfunction

" Check for various potential issues with the current setup
function! notoire#check_health()
  " TODO check that there are only .note files in the folder
  " TODO no subfolder
  " TODO a note 0 that is the index
  " TODO only hexa names and no gaps between them
  " TODO find links that do not link anywhere
  " TODO check for empty notes
  echo "TODO - Should be performing the check"
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
  " TODO should do error handling if the variable for the folder isn't correct
  let link = notoire#get_link_under_cursor()
  if link != -1
    let note_id = matchstr(link, g:ntr_note_id_rx)

    "if we found the note to open, update the history and open the note
    if note_id != ""
      call notoire#open_file(a:cmd, g:notoire_folder . note_id[1:-2] . ".note")
    elseif
      "TODO display error message
    endif
  endif
endfunction

" Open or create the index file (always note 0)
function! notoire#open_index(cmd)
  " TODO should do error handling if the variable for the folder isn't correct
  call notoire#open_file(a:cmd, g:notoire_folder . "/0.note")
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
  let results = system('rg -e "\[.+?\]\(' . cur_file . '\)" ' . g:notoire_folder)
  let results = split(results, "\n")

  " format the rg results to use as input of fzf
  for i in range(0, len(results) - 1)
    let res_parts = split(results[i], ":")
    let res_filename = split(res_parts[0], "\/")[-1]
    let res_filename = fnamemodify(res_filename, ":r")
    let results[i] = res_filename . " " . res_parts[1]
  endfor

  call notoire#run_fzf(results, a:cmd, 0)
endfunction


" --- FZF RELATED FUNCTIONS --------------------------------------------------

" Return a list where each item is the content of a note. Formatted in a way
" that it can be used as a source for FZF
function! notoire#notes_content()
  let names = system("ls -1 " . g:notoire_folder)
  let names = split(names, "\n")
  let content = []

  for i in range(0, len(names) - 1)
    let toAdd = fnamemodify(names[i], ":r") . " " . system("cat " . g:notoire_folder. names[i])
    call add(content, toAdd)
  endfor
  
  call add(content, "NEW - select to create new note")
  return content
endfunction

" Function called with the selection of FZF
" param cmd is the command used to open the file
" param is_for_link is a boolean to indicate if we create a link or not
" param e is the selection of FZF. The first word is the id of the note
function! notoire#process_fzf_choice(cmd, is_for_link, e)
  let note_id = split(a:e)[0]

  if note_id == "NEW"
    let note_id = notoire#get_next_note_id()
  endif

  " if we use the choice to create a link, edit the visually selected text
  if a:is_for_link > 0
    exe "normal! \ei[\e`>la](" . note_id . ")\e"
  endif

  call notoire#open_file(a:cmd, g:notoire_folder . "/" . note_id . ".note")
endfunction

" Return a string with the options to use when running fzf
function! notoire#get_fzf_opt()
  let o_pw = " --preview-window=down:60%:wrap"
  let o_p = ' --preview="fmt {1}.note"'
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
function! notoire#run_fzf(source, cmd, is_for_link)
  call fzf#run({
    \ 'source': a:source,
    \ 'sink': function('notoire#process_fzf_choice', [a:cmd, a:is_for_link]),
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

" Create a new note and open it
function! notoire#create_note(cmd)
  " TODO should do error handling if the variable for the folder isn't correct
  let note_id = notoire#get_next_note_id()
  call notoire#open_file(a:cmd, g:notoire_folder . "/" . note_id . ".note")
endfunction

" Create link to a note (selected through search or new) out of the
" visual selection
function! notoire#create_link(cmd)
  call notoire#run_fzf(notoire#notes_content(), a:cmd, 1)
endfunction
