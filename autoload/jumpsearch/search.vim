function! jumpsearch#search#run(...)
  call jumpsearch#util#save_initial_position()

  " Save settings that need to change
  let initial_scroll_offset = &so
  set so=0
  let initial_conceal_level = {}
  let initial_conceal_cursor = {}
  for window in jumpsearch#util#get_all_windows()
    call jumpsearch#util#move_to_window(window)
    let initial_conceal_level[string(window)] = &conceallevel
    set conceallevel=1
    let initial_conceal_cursor[string(window)] = &concealcursor
    set concealcursor=nc
  endfor
  hi! link Conceal JumpSearchJump

  let search = ""
  if a:0 > 0
    let search = a:1
  endif
  if (!jumpsearch#search#do_search(search))
    call jumpsearch#util#reset_cursor_to_initial_position()
  endif

  call jumpsearch#highlighting#clear_highlighting()
  let &so = initial_scroll_offset
  let initial_window = winnr()
  for window in jumpsearch#util#get_all_windows()
    call jumpsearch#util#move_to_window(window)
    let &conceallevel = initial_conceal_level[string(window)]
    let &concealcursor = initial_conceal_cursor[string(window)]
  endfor
  call jumpsearch#util#move_to_window(initial_window)
  hi! link Conceal Normal
endfunction

function! jumpsearch#search#get_search_from_user()
  let search = ""
  let char = nr2char(getchar())
  echo "> " . search
  while char != ""
    let search .= char
    echo "> " . search
    call jumpsearch#highlighting#search_and_highlight(
          \ search, 'JumpSearchPending')
    let char = jumpsearch#util#get_char_with_timeout(
          \ g:jumpsearch_search_complete_timeout)
  endwhile
  return search
endfunction


function! jumpsearch#search#do_search(search)
  call jumpsearch#highlighting#init()

  let search = a:search
  if search == ""
    let search = jumpsearch#search#get_search_from_user()
  endif

  if search == ""
    return 0
  endif

  echo search
  let match_positions = jumpsearch#highlighting#search_and_highlight(
        \ search, 'JumpSearchEnd')
  if len(match_positions) == 0
    return 0
  endif

  if len(match_positions) > g:jumpsearch_max_tags
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
  echo

  let jump_position = match_positions[jump_index]
  call jumpsearch#util#move_cursor(jump_position)
  return 1
endfunction
