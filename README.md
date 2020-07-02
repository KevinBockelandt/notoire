# Notoire

> ⚠️ The plugin is not compatible with Windows systems. It has been successfuly tested on GNU/Linux and MacOS.

[Introduction](#introduction) | [Installation](#installation) | [Commands](#commands) | [Setup](#setup) | [Contributing](#contributing)


# Introduction

You could roughly describe a Zettelkasten as being an external brain. It is a **network** of notes where each note contains an **idea**. You can search it, expand it, make new connections, etc. For more details on the concept I recommend checking out:

* the book "How to take smart notes" by Sönke Ahrens
* this introductory video: [youtube.com/watch?v=rOSZOCoqOo8](https://www.youtube.com/watch?v=rOSZOCoqOo8)
* this dedicated subreddit: [reddit.com/r/Zettelkasten/](https://www.reddit.com/r/Zettelkasten/)

![visual example](https://github.com/KevinBockelandt/notoire/blob/master/doc/visual_example.png)

In Notoire, the notes are stored in plain text files and interpreted as **Markdown**. They are identified by an **hexadecimal number** incremented from one note to the next. There is no hierarchy as notes are connected only by links. You can navigate to and between them via a number of ways:

* by following a link to open the corresponding note
* by going back to the previous note using an history system
* by performing a search and selecting a note in the result list
* by listing the links coming in or out of the current note and selecting one

> ❓ The name of the plugin comes from the French word `notoire` which can be translated in several ways including `notable` and `noteworthy`. Based on a number of French words ending in `'oire'`, one could also interpret the meaning of notoire as `a place where to put notes`.

You can also have several Zettelkasten (called folders in this plugin) set up if you want to take notes on wildly different topics. You then switch from one to another with the `:NotoireSelectFolder` command.


## Installation

Notoire follows the traditional vim plugin layout, so you should have no trouble installing it with your plugin manager of choice. Using [vim-plug](https://github.com/junegunn/vim-plug), add the following line in you vim-plug configuration:

```vim
Plug 'KevinBockelandt/notoire'
```

Then run `:PlugInstall`.


### Dependencies

In order to use all the features of Notoire you **need** two other tools installed on your machine:

* **FZF** in order to present search results
* **ripgrep** to perform efficient searches on notes

FZF can be [easily installed](https://github.com/junegunn/fzf#installation) by vim-plug as well . Ripgrep can be [installed via a number of ways](https://github.com/BurntSushi/ripgrep#installation) including `cargo` if you are a Rust developper.


## Commands

```
:NotoireSelectFolder --------- | Select the folder to use
:NotoireOpenIndex ------------ | Open the index note
:NotoireOpenLink ------------- | Open link under cursor
:NotoirePrevNote ------------- | Go back to the previously opened note
:NotoireCreateNote ----------- | Create a new note from visual selection and place link
:NotoireCreateEmptyNote ------ | Create a new empty note
:NotoireCreateLink ----------- | Create a link to a new or existing note using visual selection as text link
:NotoireCreateEmptyLink ------ | Create a link with empty text to a new or existing note
:NotoireNextLink ------------- | Go to the next link in the note
:NotoirePrevLink ------------- | Go to the previous link in the note 
:NotoireSearchNotes ---------- | Interactively search for a note or create a new one
:NotoireSearchLinksInNote ---- | Interactively search among all links present in the current note and open one
:NotoireSearchOrphanNotes ---- | Interactively search among notes that are not referenced in any link anywhere
:NotoireSearchNotesLinkingHere | Interactively search among notes that
```

* `:NotoireNextLink` and `:NotoirePrevLink` can be prefixed by a number to repeat the operation, like a regular vim navigation shortcut. Please be careful to use the proper [mapping](#setup).
* Every command that opens a new buffer also have a version to open that buffer in a split. See the [documentation](./doc/notoire.txt) for more details.


## Setup

You **need** to define the option `g:notoire_folders` which indicates the list of paths to the folders where the notes should be kept. It's usually a good idea to use folders that will be backed up automatically somehow. Ex:

```vim
let g:notoire_folders = ['~/Dropbox/notes/myZettelkasten', '~/Dropbox/notes/anotherOne']
```

Notoire provides the following mapping by default:

```vim
nnoremap <Leader>l :<C-U>NotoireNextLink(v:count1)<cr>
nnoremap <Leader>h :<C-U>NotoirePrevLink(v:count1)<cr>

nnoremap <Leader>f :NotoireSelectFolder<cr>
 
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
```

Here is a diagram to help you see how it looks on a keyboard:

![diagram hotkeys](https://github.com/KevinBockelandt/notoire/blob/master/doc/hotkeys.png)

If you wish for the plugin **not** to setup default mapping (to avoid conflict for exemple), you can use the `g:notoire_user_mapping`. It is then up to you to provide the mapping you want.

```vim
let g:notoire_user_mapping = 1
```

See the [documentation](./doc/notoire.txt) for an exhaustive list of configuration options.


## Contributing

We are very much open to feedback! If you want to submit an idea for improvement or report a bug you've encountered, you can [open an issue](https://github.com/KevinBockelandt/notoire/issues).
