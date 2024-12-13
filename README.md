# helm-complete.vim

Vim plugin providing intelligent autocompletion for Helm chart values in template files.

## Features

- Smart detection of Helm files, even with regular .yaml extension
- Autocomplete values from `values.yaml` in Helm template files
- Automatically detects Helm chart structure
- Shows value types in completion menu
- Works with nested YAML structures

## Installation

Using vim-plug:
```vim
Plug 'timraymond/helm-complete.vim'
```

## Usage

The plugin automatically detects Helm template files and enables completion:
- Triggers on regular .yaml files in Helm charts
- Works in template directories
- Detects Helm syntax automatically

Trigger completion with:
- `<C-x><C-o>` (Vim's standard omni-completion)

## Configuration

```vim
" Disable automatic Helm detection
let g:helm_complete_auto_detect = 0

" Change the completion trigger
let g:helm_complete_trigger = '<C-x><C-o>'

" Enable preview window
let g:helm_complete_preview = 1
```
