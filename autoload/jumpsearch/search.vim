function! jumpsearch#search#run()
  " Set the scroll offset to 0 temporarily to avoid moving the screen
  let initial_scroll_offset = &so
  set so=0

  let initial_cursor = jumpsearch#util#get_cursor()
  if (!jumpsearch#search#do_search())
    call jumpsearch#util#move_cursor(initial_cursor)
  endif

  call jumpsearch#highlighting#clear_highlighting()
  let &so = initial_scroll_offset
endfunction

function! jumpsearch#search#do_search()
  let initial_cursor = jumpsearch#util#get_cursor()

  let search = ""
  let char = nr2char(getchar())
  while char != ""
    let search .= char
    call jumpsearch#highlighting#search_and_highlight(
          \ search, 'JumpSearchPending')
    let char = jumpsearch#util#get_char_with_timeout(
          \ g:jumpsearch_search_complete_timeout)
  endwhile

  if search == ""
    return 0
  endif

  let match_positions = jumpsearch#highlighting#search_and_highlight(
        \ search, 'JumpSearchEnd')
  if len(match_positions) == 0
    return 0
  endif

  let num_jump_tags = len(match_positions)
  let index = 0
  let jump_tags = jumpsearch#tags#get_tags(num_jump_tags)
  for match_position in match_positions
    call jumpsearch#util#move_cursor(match_position)
    let jump_tag = jump_tags[index]
    exec 'normal! R' . jump_tag
    call jumpsearch#highlighting#highlight(
          \ match_position, len(jump_tag), 'JumpSearchJump')
    let index += 1
  endfor
  call jumpsearch#util#move_cursor(initial_cursor)
  nohlsearch
  redraw

  let jump_index = jumpsearch#tags#get_jump_index_from_user(num_jump_tags)
  
  " This reverts all changes made to the buffer when jump tags were added.
  exec 'normal! u'

  if jump_index < 0
    return 0
  endif

  call jumpsearch#util#move_cursor(match_positions[jump_index])
  return 1
endfunction
