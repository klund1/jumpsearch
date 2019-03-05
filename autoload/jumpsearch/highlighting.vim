function! jumpsearch#highlighting#init()
  hi JumpSearchPending ctermfg=0 ctermbg=222 cterm=NONE
  hi JumpSearchEnd ctermfg=0 ctermbg=222 cterm=NONE
  hi JumpSearchJump ctermfg=0 ctermbg=red cterm=NONE
endfunction

function! jumpsearch#highlighting#clear_highlighting()
  let window = winnr()
  windo call jumpsearch#highlighting#clear_highlighting_in_window()
  call jumpsearch#util#move_to_window(window)
endfunction

function! jumpsearch#highlighting#clear_highlighting_in_window()
  if !exists('b:jumpsearch_match_ids')
    return
  endif
  for match_id in b:jumpsearch_match_ids
    call matchdelete(match_id)
  endfor
  let b:jumpsearch_match_ids = []
endfunction

function! jumpsearch#highlighting#highlight(position, length, match_group)
  let pattern = ''
  let pattern .= '\%' . a:position.line . 'l'
  let pattern .= '\%>' . (a:position.collumn-1) . 'c'
  let pattern .= '\%<' . (a:position.collumn+a:length) . 'c'

  let match_id = matchadd(a:match_group, pattern)

  if !exists('b:jumpsearch_match_ids')
    let b:jumpsearch_match_ids = []
  endif
  let b:jumpsearch_match_ids += [match_id]
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
