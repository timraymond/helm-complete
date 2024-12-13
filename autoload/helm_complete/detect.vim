" Detection logic
function! helm_complete#detect#init()
  " Skip if auto-detection is disabled
  if !get(g:, 'helm_complete_auto_detect', 1)
    return
  endif
  
  " Check if we've already detected this file
  if exists('b:helm_detection_done')
    return
  endif
  let b:helm_detection_done = 1
  
  if helm_complete#detect#is_helm_file()
    let b:is_helm = 1
    set filetype=yaml.gotmpl
  endif
endfunction

function! helm_complete#detect#is_helm_file()
  " Cache the result
  if exists('b:is_helm')
    return b:is_helm
  endif
  
  let current_dir = expand('%:p:h')
  
  " Check if we're in a templates directory
  if current_dir =~ '/templates\(/\|$\)'
    return 1
  endif
  
  " Check for Chart.yaml in parent directories
  let check_dir = current_dir
  while check_dir != '/'
    if filereadable(check_dir . '/Chart.yaml')
      return 1
    endif
    let check_dir = fnamemodify(check_dir, ':h')
  endwhile
  
  " Check file contents for Helm template syntax
  let first_lines = getline(1, 20)
  for line in first_lines
    if line =~ '{{\s*\..*}}\|{{\s*include\s\|{{\s*template\s'
      return 1
    endif
  endfor
  
  return 0
endfunction

function! helm_complete#detect#toggle()
  if !exists('b:is_helm')
    let b:is_helm = 1
    set filetype=yaml.gotmpl
    echo "Helm mode enabled"
  else
    unlet b:is_helm
    set filetype=yaml
    echo "Helm mode disabled"
  endif
endfunction
