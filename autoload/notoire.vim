" --- GENERIC FUNCTIONS ------------------------------------------------------

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


" --- HISTORY RELATED FUNCTIONS ----------------------------------------------

" Open a file and update associated history
function! notoire#open_file(cmd, filename)
  let new_history = getbufvar("%", "history", []) " get history of current buf
  call add (new_history, expand("%:p"))           " append filename of cur buf
  exe a:cmd a:filename
  call setbufvar("%", "history", new_history)     " set history on new buf
endfunction

" Go to the previous note in the history
function! notoire#prev_note(cmd)
  let history = getbufvar("%", "history", []) " get history of current buf
  exe a:cmd history[-1]
  if len(history) > 1                         " pop last item of history
    let history = history[0:-2]
  endif
  call setbufvar("%", "history", history)     " set history on new buf
endfunction


" --- LINK RELATED FUNCTIONS -------------------------------------------------

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


" --- COMMAND FUNCTIONS ------------------------------------------------------

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

function! notoire#create_note(cmd)
  " TODO should do error handling if the variable for the folder isn't correct
  let note_id = notoire#get_next_note_id()
  call notoire#open_file(a:cmd, g:notoire_folder . "/" . note_id . ".note")
endfunction

" Create a link to a new note with the visual selection
" TODO ideally it would ask for the note to link to, instead of creating a new
" note by default
function! notoire#create_link(cmd)
  let new_note_id = notoire#get_next_note_id()
  exe "normal! \ei[\e`>la](" . new_note_id . ")\e"
  write
  call notoire#open_file(a:cmd, g:notoire_folder . "/" . new_note_id . ".note")
endfunction

