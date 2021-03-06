function! jumpsearch#highlighting#init()
  hi JumpSearchPending ctermfg=green cterm=BOLD
  hi JumpSearchEnd ctermfg=grey cterm=BOLD
  hi JumpSearchBg ctermfg=grey cterm=NONE
  hi JumpSearchJump ctermfg=red cterm=BOLD
endfunction

function! jumpsearch#highlighting#clear_highlighting()
  let window = winnr()
  windo call jumpsearch#highlighting#clear_highlighting_in_window()
  call jumpsearch#util#move_to_window(window)
endfunction

function! jumpsearch#highlighting#clear_highlighting_in_window()
  if !exists('g:jumpsearch_match_ids')
    return
  endif
  if count(keys(g:jumpsearch_match_ids), string(winnr())) == 0
    return
  endif
  for match_id in g:jumpsearch_match_ids[winnr()]
    call matchdelete(match_id)
  endfor
  let g:jumpsearch_match_ids[winnr()] = []
endfunction

function! jumpsearch#highlighting#store_match_id(match_id)
  if !exists('g:jumpsearch_match_ids')
    let g:jumpsearch_match_ids = {}
  endif
  if count(keys(g:jumpsearch_match_ids), string(winnr())) == 0
    let g:jumpsearch_match_ids[winnr()] = []
  endif
  let g:jumpsearch_match_ids[winnr()] += [a:match_id]
endfunction


function! jumpsearch#highlighting#highlight_window(match_group)
  let pattern = '\%>' . line('w0') . 'l' . '\%<' . line('w$') . 'l'
  let match_id = matchadd(a:match_group, pattern)
  call jumpsearch#highlighting#store_match_id(match_id)
endfunction

function! jumpsearch#highlighting#highlight(position, length, match_group, ...)
  let pattern = ''
  let pattern .= '\%' . a:position.line . 'l'
  let pattern .= '\%>' . (a:position.collumn-1) . 'c'
  let pattern .= '\%<' . (a:position.collumn+a:length) . 'c'

  if a:0 > 0
    let conceal_char = a:1
    let match_id = matchadd(a:match_group, pattern, 10, -1, {'conceal': conceal_char})
  else
    let match_id = matchadd(a:match_group, pattern)
  endif

  call jumpsearch#highlighting#store_match_id(match_id)
endfunction

function! jumpsearch#highlighting#search_and_highlight(search, match_group)
  if g:jumpsearch_inc_search
    call jumpsearch#highlighting#clear_highlighting()
  endif
  let matches = []
  for window in jumpsearch#util#get_all_windows()
    call jumpsearch#util#move_to_window(window)
    let matches += jumpsearch#highlighting#search_in_window(a:search, a:match_group)
  endfor
  if g:jumpsearch_inc_search
    call jumpsearch#util#redraw()
  endif
  return matches
endfunction

function! jumpsearch#highlighting#search_in_window(search, match_group)
  call jumpsearch#highlighting#highlight_window('JumpSearchBg')
  let top_line = line('w0')
  let bottom_line = line('w$')
  let matches = []
  let escaped_search = jumpsearch#util#escape_all_special_chars(a:search)
  call cursor(top_line, 0)
  while search(escaped_search, '', bottom_line)
    let match_position = jumpsearch#util#get_cursor()
    let matches += [match_position]
    if g:jumpsearch_inc_search
      call jumpsearch#highlighting#highlight(
            \ match_position, len(a:search), a:match_group)
    endif
  endwhile
  return matches
endfunction
