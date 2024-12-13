if exists('g:loaded_helm_complete')
  finish
endif
let g:loaded_helm_complete = 1

" Default configuration
let g:helm_complete_trigger = get(g:, 'helm_complete_trigger', '<C-x><C-o>')
let g:helm_complete_preview = get(g:, 'helm_complete_preview', 0)
let g:helm_complete_auto_detect = get(g:, 'helm_complete_auto_detect', 1)

" Set up autocommands for completion
augroup HelmComplete
  autocmd!
  autocmd FileType yaml.gotmpl setlocal omnifunc=helm_complete#omni
  " Also enable for regular yaml files if they're detected as Helm
  autocmd FileType yaml if exists('b:is_helm') | setlocal omnifunc=helm_complete#omni | endif
augroup END

" Commands
command! HelmToggle call helm_complete#detect#toggle()
