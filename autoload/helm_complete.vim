function! helm_complete#omni(findstart, base)
  if a:findstart
    " Find start of the entire Values reference
    let line = getline('.')
    let start = col('.') - 1
    
    " Search backwards for {{ or space before .Values
    while start > 0
      if line[start - 1] =~ '[{{]\s*'
        break
      endif
      let start -= 1
    endwhile
    
    " Skip any whitespace after {{
    while start < col('.') - 1 && line[start] =~ '\s'
      let start += 1
    endwhile
    
    return start
  else
    " Get all leaf paths from values.yaml
    let values = helm_complete#yaml#parse_values_file()
    let leaf_paths = helm_complete#yaml#get_all_leaf_paths(values)
    
    " Filter based on what user has typed so far
    let matches = []
    let base_parts = split(a:base, '\.')
    
    " If base doesn't start with .Values, prepend it for matching
    let search_base = a:base
    if a:base !~ '^\.Values'
      let search_base = '.Values.' . a:base
    endif
    
    " Filter paths that match what user has typed
    for path in leaf_paths
      if path =~ '^' . escape(search_base, '.')
        call add(matches, {
              \ 'word': path,
              \ 'menu': helm_complete#yaml#get_value_preview(values, path),
              \ 'kind': 'v'
              \ })
      endif
    endfor
    
    return matches
  endif
endfunction
