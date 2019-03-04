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
  return [line('.'), col('.')]
endfunction

function! jumpsearch#util#move_cursor(position)
  call cursor(a:position[0], a:position[1])
endfunction

function! jumpsearch#util#redraw()
  call jumpsearch#util#move_cursor(b:jumpsearch_initial_cursor)
  nohlsearch
  redraw
endfunction
