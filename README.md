# Notoire

> ⚠️ We are currently in version 0.7, meaning the plugin has reached a usable state but is not complete. Some key features are missing and there are probably some lizards lurking around.


- [Introduction](#introduction)
- [Installation](#installation)
- [Commands](#commands)
- [Setup](#setup)
- [Contributing](#contributing)


TODO: put some screenshot here once everything is done

## Introduction

You could roughly describe a Zettelkasten as being an external brain. It is a **network** of notes where each note contains an **idea**. You can search it, expand it, make new connections, etc. For more details on the concept I recommend checking out:

* the book "How to take smart notes" by Sönke Ahrens
* this introductory video: [youtube.com/watch?v=rOSZOCoqOo8](https://www.youtube.com/watch?v=rOSZOCoqOo8)
* this dedicated subreddit: [reddit.com/r/Zettelkasten/](https://www.reddit.com/r/Zettelkasten/)

In Notoire, the notes are stored in plain text files and interpreted as **Markdown**. There is no hierarchy and no built-in tag system. Notes are connected by **links only** and you can navigate to and between them a number of ways:

* by following a link to open the corresponding note
* by going back to the previous note using an history system
* by performing a search and selecting a note in the result list (⚠️ not implemented yet)
* by listing notes linking to the current one and selecting a result (⚠️ not implemented yet)

Each note is identified by an **hexadecimal number** that is incremented with each one.

> ❓ The name of the plugin comes from the French word `notoire` which can be translated in several ways including `notable` and `noteworthy`. Based on a number of French words ending in `'oire'`, one could also interpret the meaning of notoire as `a place where to put notes`.

## Installation

Notoire follows the traditional vim plugin layout, so you should have no trouble installing it with your plugin manager of choice.

Using [vim-plug](https://github.com/junegunn/vim-plug), add the following line in you vim-plug configuration:

```vim
Plug 'KevinBockelandt/notoire'
```

Then run `:PlugInstall`.


## Commands

```
:NotoireOpenIndex    | Open the index note
:NotoireOpenLink     | Open link under cursor
:NotoirePrevNote     | Go back to previous note. Useful after opening a link
:NotoireCreateNote   | Create a new note
:NotoireCreateLink   | Create a link to a new note out of the visual selection and open that note 
:NotoireNextLink     | Go to the next link in the note
:NotoirePrevLink     | Go to the previous link in the note 
```

* `:NotoireCreateLink` will only work if you have a visual selection when you call it.
* `:NotoireNextLink` and `:NotoirePrevLink` can be prefixed by a number to repeat the operation, like a regular vim navigation shortcut. Please be careful to use the proper [mapping](#setup).
* Every command that opens a new buffer also have a version to open that buffer in a split. See the [documentation](./doc/notoire.txt) for more details.


## Setup

TODO: talk about a proper directory structure

Notoire does not provide a configuration by default, which means you **need** to set it up. Here is a base config that you can adapt to your needs:

```vim
let g:notoire_folder = '~/Dropbox/notes/notoire/' " notes are kept in this folder

nnoremap <Leader>l :<C-U>NotoireNextLink(v:count1)<cr>
nnoremap <Leader>h :<C-U>NotoirePrevLink(v:count1)<cr>

nnoremap <Leader>j :NotoireOpenLink<cr>
nnoremap <Leader>sj :NotoireOpenLinkSplit<cr>
nnoremap <Leader>vj :NotoireOpenLinkVsplit<cr>

vnoremap <Leader>j :<C-U>NotoireCreateLink<cr>
vnoremap <Leader>sj :<C-U>NotoireCreateLinkSplit<cr>
vnoremap <Leader>vj :<C-U>NotoireCreateLinkVsplit<cr>

nnoremap <Leader>k :NotoirePrevNote<cr>
nnoremap <Leader>sk :NotoirePrevNoteSplit<cr>
nnoremap <Leader>vk :NotoirePrevNoteVsplit<cr>

nnoremap <Leader><Tab> :NotoireOpenIndex<cr>
nnoremap <Leader>s<Tab> :NotoireOpenIndexSplit<cr>
nnoremap <Leader>v<Tab> :NotoireOpenIndexVsplit<cr>
```

See the [documentation](./doc/notoire.txt) for an exhaustive list of configuration options.


## Contributing

We are very much open to feedback! If you want to submit an idea for improvement or report a bug you've encountered, you can [open an issue](https://github.com/KevinBockelandt/notoire/issues).
