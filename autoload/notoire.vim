let b:link_regex = '\[.\{-}\](.\{-})'
let b:note_id_regex = '(\(\d\|[a-f]\)\+)$'


" --- GENERIC FUNCTIONS ------------------------------------------------------

" Notes are nammed with a UID. We look up the highest name in the note folder
" and return the increment to get a new name. UIDs are in hexadecimal
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

  " TODO return the biggestId + 1
  echom biggestId
endfunction


" --- LINK RELATED FUNCTIONS -------------------------------------------------

"Move the cursor to the next or previous link in the buffer
function! notoire#go_to_link(search_flags)
  let save_cursor = getcurpos()
  call search(b:link_regex, a:search_flags)

  " if we found a link and jumped to it, move cursor to be inside the bracket
  if getcurpos() != save_cursor
    normal! l
  endif
endfunction

"Return the entire link (text included) under the cursor or -1 if there isn't
function! notoire#get_link_under_cursor()
  let cur_col = col('.')
  let cur_line = getline('.')
  let temp_col = 0

  while 1
    let link_str = matchstrpos(cur_line, b:link_regex, temp_col)

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

function! notoire#next_link()
  call notoire#go_to_link('')
endfunction

function! notoire#prev_link()
  call notoire#go_to_link('b')
endfunction

function! notoire#open_link()
  let link = notoire#get_link_under_cursor()
  if link != -1
    let note_id = matchstr(link, b:note_id_regex)
    if note_id != ""
      exe "vsplit " g:notoire_folder . note_id[1:-2] . ".note"
    endif
  endif
endfunction

" open or create the index file (always note 0)
function! notoire#open_index()
  " TODO should do error handling if the variable for the folder isn't correct
  exe "edit" g:notoire_folder . "/0.note"
endfunction

" check for various potential issues with the current setup
function! notoire#check_health()
  " TODO check that there are only .note files in the folder
  " TODO no subfolder
  " TODO a note 0 that is the index
  " TODO only base36 names and no gaps between them
  " TODO find notes that are not linked anywhere (except 0)
  " TODO find links that do not link anywhere
  " TODO check for empty notes
  echo "TODO - Should be performing the check"
endfunction

function! notoire#open_create_link()
  " if we are on a link, we open it
  " if we are not on a link, create one with the current selection. Current
  " word if there is no selection
  " When we decide to create a new link, we need to display a buffer with the
  " list of possible notes to link to or the option for a new note.
  " Possibility of searching through existing notes easily to find the one
endfunction

