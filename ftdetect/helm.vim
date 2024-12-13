if exists('g:loaded_helm_complete_detect')
  finish
endif
let g:loaded_helm_complete_detect = 1

" Auto-detect Helm files
augroup HelmDetect
  autocmd!
  autocmd BufNewFile,BufRead *.yaml,*.yml call helm_complete#detect#init()
  autocmd BufNewFile,BufRead *.yaml.gotmpl,*.tpl set filetype=yaml.gotmpl
augroup END
