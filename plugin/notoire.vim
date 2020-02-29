" --- DEFINE GENERIC FUNCTIONS -----------------------------------------------

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


" --- DEFINE COMMAND FUNCTIONS -----------------------------------------------

" open or create the index file (always note 0)
function NotoireIndex()
  " TODO should do error handling if the variable for the folder isn't correct
  exe "edit" g:notoire_folder . "/0.note"
endfunction

" check for various potential issues with the current setup
function NotoireCheckIssues()
  " TODO check that there are only .note files in the folder
  " TODO no subfolder
  " TODO a note 0 that is the index
  " TODO only base36 names and no gaps between them
  " TODO find notes that are not linked anywhere (except 0)
  " TODO find links that do not link anywhere
  " TODO check for empty notes
  echo "TODO - Should be performing the check"
endfunction


" --- DEFINE COMMANDS --------------------------------------------------------

command! NotoireIndex call NotoireIndex()
command! NotoireCheckIssues call NotoireCheckIssues()
