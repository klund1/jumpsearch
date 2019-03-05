let s:get_char_polling_frequency = 10

function! jumpsearch#util#get_char_with_timeout(timeout)
  let elapsed_time = 0
  while elapsed_time <= a:timeout
    " Note: getchar(0) does not block. If no key is available, it returns 0.
    let raw_key = getchar(0)
    if raw_key > 0
      return nr2char(raw_key)
    endif
    exec 'sleep ' . s:get_char_polling_frequency . 'm'
    let elapsed_time += s:get_char_polling_frequency
  endwhile
  return ""
endfunction

function! jumpsearch#util#escape_all_special_chars(string)
  " TODO Actually escape special chars
  return a:string
endfunction

function! jumpsearch#util#get_cursor()
  let position = {}
  let position.window = winnr()
  let position.line = line('.')
  let position.collumn = col('.')
  return position
endfunction

function! jumpsearch#util#get_all_windows()
  return range(1,winnr("$"))
endfunction

function! jumpsearch#util#move_to_window(window)
  exec a:window . 'wincmd w'
endfunction

function! jumpsearch#util#move_cursor(position)
  if winnr() != a:position.window
    call jumpsearch#util#move_to_window(a:position.window)
  endif
  call cursor(a:position.line, a:position.collumn)
endfunction

function! jumpsearch#util#save_initial_position()
  let g:jumpsearch_initial_window = winnr()
  windo let b:jumpsearch_initial_cursor = jumpsearch#util#get_cursor()
endfunction

function! jumpsearch#util#reset_cursor_to_initial_position()
  windo call jumpsearch#util#move_cursor(b:jumpsearch_initial_cursor)
  call jumpsearch#util#move_to_window(g:jumpsearch_initial_window)
endfunction

function! jumpsearch#util#redraw()
  call jumpsearch#util#reset_cursor_to_initial_position()
  nohlsearch
  redraw
endfunction
