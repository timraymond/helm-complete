" autoload/helm_complete/yaml.vim

" Main completion helper functions
function! helm_complete#yaml#get_all_leaf_paths(values)
  let paths = []
  call s:collect_leaf_paths(a:values, '.Values', paths)
  return paths
endfunction

" Export the preview function to be callable from helm_complete.vim
function! helm_complete#yaml#get_value_preview(values, path)
  " Remove .Values. prefix and split path
  let path_parts = split(substitute(a:path, '^\.Values\.', '', ''), '\.')
  
  " Navigate to the value
  let current = a:values
  for part in path_parts
    if has_key(current, part)
      let current = current[part]
    else 
      return '(unknown)'
    endif
  endfor
  
  " Format the value preview
  if type(current) == type('')
    return '= ' . current
  elseif type(current) == type([])
    return '= [' . join(current, ', ') . ']'
  else
    return '= ' . string(current)
  endif
endfunction

function! s:collect_leaf_paths(dict, current_path, paths)
  for [key, value] in items(a:dict)
    let new_path = a:current_path . '.' . key
    if type(value) == type({})
      " If it's a dictionary, recurse deeper
      call s:collect_leaf_paths(value, new_path, a:paths)
    else
      " If it's a leaf node, add the path
      call add(a:paths, new_path)
    endif
  endfor
endfunction

function! helm_complete#yaml#parse_values_file()
  let chart_root = s:find_chart_root(expand('%:p:h'))
  if empty(chart_root)
    return {}
  endif
  
  let values_file = chart_root . '/values.yaml'
  if !filereadable(values_file)
    return {}
  endif
  
  let content = join(readfile(values_file), "\n")
  return s:parse_yaml(content)
endfunction

function! s:find_chart_root(start_dir)
  let current = a:start_dir
  while current != '/'
    if filereadable(current . '/Chart.yaml')
      return current
    endif
    let current = fnamemodify(current, ':h')
  endwhile
  return ''
endfunction

function! s:parse_yaml(content)
  let result = {}
  let context_stack = [{'dict': result, 'indent': -1}]
  
  " Process each line
  for line in split(a:content, "\n")
    " Skip empty lines and comments
    if line =~ '^\s*$' || line =~ '^\s*#'
      continue
    endif
    
    " Calculate indent level (count spaces before content)
    let indent = len(matchstr(line, '^\s*'))
    let content = substitute(line, '^\s*', '', '')
    
    " Skip comment lines that start with #
    if content =~ '^#'
      continue
    endif
    
    " Parse the line into key/value
    let matches = matchlist(content, '^\([^:]\+\):\s*\(.*\)$')
    if !empty(matches)
      let key = matches[1]
      let value = matches[2]
      
      " Remove any quotes around the key
      let key = substitute(key, '^\s*''\|''\s*$\|^\s*"\|"\s*$', '', 'g')
      
      " Pop stack until we find the right context level
      while len(context_stack) > 1 && context_stack[-1].indent >= indent
        call remove(context_stack, -1)
      endwhile
      
      " Get current context
      let current = context_stack[-1].dict
      
      " Handle the value
      if value =~ '^\s*$'
        " Empty value means this is a new map
        let new_dict = {}
        let current[key] = new_dict
        " Push new context onto stack
        call add(context_stack, {'dict': new_dict, 'indent': indent})
      else
        " Process the value
        let processed_value = s:process_value(value)
        let current[key] = processed_value
      endif
    endif
  endfor
  
  return result
endfunction

function! s:process_value(value)
  " Store our input value in a local variable
  let value = a:value
  
  " First trim - be explicit about the pattern
  let value = substitute(value, '^[ \t]\+\|[ \t]\+$', '', 'g')
  
  " Handle quoted strings
  if match(value, '^[''"].*[''"]$') >= 0
    if match(value, '^".*"$') >= 0
      let value = substitute(value, '^"\(.*\)"$', '\1', '')
    elseif match(value, '^''.*''$') >= 0
      let value = substitute(value, '^''\(.*\)''$', '\1', '')
    endif
    return value
  endif
  
  " Handle arrays (basic support)
  if match(value, '^\[.*\]$') >= 0
    let inner = substitute(value, '^\[\(.*\)\]$', '\1', '')
    let items = split(inner, ',')
    let cleaned_items = []
    for item in items
      let cleaned = substitute(item, '^[ \t]\+\|[ \t]\+$', '', 'g')
      call add(cleaned_items, cleaned)
    endfor
    return cleaned_items
  endif
  
  " Handle booleans
  if value ==# 'true'
    return 1
  endif
  if value ==# 'false'
    return 0
  endif
  
  " Handle numbers
  if match(value, '^-\?\d\+$') >= 0
    return str2nr(value)
  endif
  
  " Handle floating point numbers
  if match(value, '^-\?\d\+\.\d\+$') >= 0
    return str2float(value)
  endif
  
  " Handle null/empty values
  if value ==# 'null' || value ==# '~'
    return ''
  endif
  
  " Handle Kubernetes resource quantities (like '100Mi', '500m')
  if match(value, '^\d\+\([KMGTPEkmgtpe]\|[KMGTPE]i\)\?$') >= 0
    return value
  endif
  
  " Default: return as string
  return value
endfunction

" Cache for parsed YAML files
let s:yaml_cache = {}

" Function to clear the YAML cache
function! helm_complete#yaml#clear_cache()
  let s:yaml_cache = {}
endfunction

" Function to get or create cached YAML data
function! s:get_cached_yaml(file)
  let mtime = getftime(a:file)
  if has_key(s:yaml_cache, a:file)
    if s:yaml_cache[a:file].mtime == mtime
      return s:yaml_cache[a:file].data
    endif
  endif
  
  let data = s:parse_yaml(join(readfile(a:file), "\n"))
  let s:yaml_cache[a:file] = {'mtime': mtime, 'data': data}
  return data
endfunction
