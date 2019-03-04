function! jumpsearch#highlighting#clear_highlighting()
  if !exists('b:jumpsearch_match_ids')
    return
  endif
  for match_id in b:jumpsearch_match_ids
    call matchdelete(match_id)
  endfor
  let b:jumpsearch_match_ids = []
endfunction

function! jumpsearch#highlighting#highlight(position, length, match_group)
  let line = a:position[0]
  let collumn = a:position[1]

  let pattern = ''
  let pattern .= '\%' . line . 'l'
  let pattern .= '\%>' . (collumn-1) . 'c'
  let pattern .= '\%<' . (collumn+a:length) . 'c'

  let match_id = matchadd(a:match_group, pattern)

  if !exists('b:jumpsearch_match_ids')
    let b:jumpsearch_match_ids = []
  endif
  let b:jumpsearch_match_ids += [match_id]
endfunction

function! jumpsearch#highlighting#search_and_highlight(search, match_group)
  call jumpsearch#highlighting#clear_highlighting()

  let top_line = line('w0')
  let bottom_line = line('w$')
  let matches = []
  let escaped_search = jumpsearch#util#escape_all_special_chars(a:search)

  call cursor(top_line, 0)
  while search(escaped_search, '', bottom_line)
    let match_position = jumpsearch#util#get_cursor()
    let matches += [match_position]
    call jumpsearch#highlighting#highlight(
          \ match_position, len(a:search), a:match_group)
  endwhile
  nohlsearch
  redraw
  return matches
endfunction
