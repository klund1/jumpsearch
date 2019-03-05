function! jumpsearch#search#run()
  " Set the scroll offset to 0 temporarily to avoid moving the screen
  let initial_scroll_offset = &so
  set so=0

  call jumpsearch#util#save_initial_position()
  if (!jumpsearch#search#do_search())
    call jumpsearch#util#reset_cursor_to_initial_position()
  endif

  call jumpsearch#highlighting#clear_highlighting()
  let &so = initial_scroll_offset
endfunction

function! jumpsearch#search#do_search()
  call jumpsearch#highlighting#init()
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
  let jump_tags = jumpsearch#tags#get_tags(num_jump_tags)

  let modified_windows = []
  for i in range(len(match_positions))
    let window = match_positions[i].window
    call jumpsearch#util#move_to_window(window)
    if count(modified_windows, window) == 0
      let modified_windows += [window]
    endif
    call jumpsearch#tags#add_tag(match_positions[i], jump_tags[i])
  endfor

  call jumpsearch#util#redraw()

  let jump_index = jumpsearch#tags#get_jump_index_from_user(num_jump_tags)
  if jump_index < 0
    return 0
  endif

  let jump_position = match_positions[jump_index]
  call jumpsearch#util#move_cursor(jump_position)
  return 1
endfunction
