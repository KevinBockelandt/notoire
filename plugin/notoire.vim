" --- GENERIC FUNCTIONS ------------------------------------------------------

" Notes are nammed with a UID. We look up the highest name in the note folder
" and return the increment to get a new name. UIDs are in hexadecimal
function NotoireGetNextNoteId()
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


" --- COMMAND FUNCTIONS ------------------------------------------------------

" open or create the index file (always note 0)
function NotoireIndex()
  " TODO should do error handling if the variable for the folder isn't correct
  exe "edit" g:notoire_folder . "/0.note"
endfunction

" check for various potential issues with the current setup
function NotoireCheckHealth()
  " TODO check that there are only .note files in the folder
  " TODO no subfolder
  " TODO a note 0 that is the index
  " TODO only base36 names and no gaps between them
  " TODO find notes that are not linked anywhere (except 0)
  " TODO find links that do not link anywhere
  " TODO check for empty notes
  echo "TODO - Should be performing the check"
endfunction

function NotoireOpenLink()
  exe "vsplit " g:notoire_folder . "1.note"
  
endfunction

function NotoireOpenCreateLink()
  " if we are on a link, we open it
  " if we are not on a link, create one with the current selection. Current
  " word if there is no selection
  " When we decide to create a new link, we need to display a buffer with the
  " list of possible notes to link to or the option for a new note.
  " Possibility of searching through existing notes easily to find the one
endfunction

" --- COMMANDS ---------------------------------------------------------------

command! NotoireIndex call NotoireIndex()
command! NotoireCheckHealth call NotoireCheckHealth()

command! NotoireOpenLink call NotoireOpenLink()
