function!jumpsearch#tags#add_tag(position, tag)
  set conceallevel=1
  set concealcursor=nc
  hi! link Conceal JumpSearchJump


  let index = 0
  for c in split(a:tag, '\zs')
    let pattern = ''
    let pattern .= '\%' . a:position.line . 'l'
    let pattern .= '\%>' . (a:position.collumn - 1 + index) . 'c'
    let pattern .= '\%<' . (a:position.collumn + 1 + index) . 'c'

    let match_id = matchadd('Conceal', pattern, 10, -1, {'conceal': c})

    if !exists('g:jumpsearch_match_ids')
      let g:jumpsearch_match_ids = {}
    endif
    if count(keys(g:jumpsearch_match_ids), string(winnr())) == 0
      let g:jumpsearch_match_ids[winnr()] = []
    endif
    let g:jumpsearch_match_ids[winnr()] += [match_id]

    let index += 1
  endfor
endfunction

function!jumpsearch#tags#get_jump_index_from_user(num_tags)
  let starting_key_to_tag_length = 
        \ jumpsearch#tags#get_starting_key_to_tag_length(a:num_tags)

  let starting_key = 
        \ jumpsearch#util#get_char_with_timeout(g:jumpsearch_jump_timeout)
  if starting_key == ""
    return -1
  endif

  let tag_length = get(starting_key_to_tag_length, starting_key, 0)
  if tag_length == 0
    return -1
  endif

  let tag = starting_key
  while len(tag) < tag_length
    " TODO be smarter about timeout here, use elapsed time
    let char = jumpsearch#util#get_char_with_timeout(g:jumpsearch_jump_timeout)
    if char == ""
      return -1
    endif
    let tag .= char
  endwhile

  return index(jumpsearch#tags#get_tags(a:num_tags), tag)
endfunction

function! jumpsearch#tags#get_tags(num_tags)
  let starting_key_to_tag_length = 
        \ jumpsearch#tags#get_starting_key_to_tag_length(a:num_tags)
  let l:tags = []
  for key in g:jumpsearch_tag_keys
    let tag_length = starting_key_to_tag_length[key]
    let l:tags += 
          \ jumpsearch#tags#get_all_tags_with_starting_key(key, tag_length)
  endfor

  return l:tags[:a:num_tags-1]
endfunction

function! jumpsearch#tags#get_starting_key_to_tag_length(num_tags)
  let num_tag_keys = len(g:jumpsearch_tag_keys)
  let min_tag_length = float2nr(floor(log10(a:num_tags)/log10(num_tag_keys)))

  if min_tag_length == 0
    let tags_added_by_extending_tag = 1
    let extra_tags_needed = a:num_tags
  else
    let tags_added_by_extending_tag =
        \ (num_tag_keys - 1) * pow(num_tag_keys, min_tag_length - 1)
    let extra_tags_needed = a:num_tags - pow(num_tag_keys, min_tag_length)
  endif

  let num_starting_keys_with_extended_tags = 
        \ float2nr(ceil(extra_tags_needed / tags_added_by_extending_tag))

  let starting_key_to_tag_length = {}

  let keys = copy(g:jumpsearch_tag_keys)
  if min_tag_length > 0
    call reverse(keys)
  endif
  for key in keys
    let starting_key_to_tag_length[key] = min_tag_length
    if num_starting_keys_with_extended_tags > 0
      let starting_key_to_tag_length[key] += 1
      let num_starting_keys_with_extended_tags -= 1
    endif
  endfor

  return starting_key_to_tag_length
endfunction

function! jumpsearch#tags#get_all_tags_with_starting_key(starting_key, tag_length)
  if a:tag_length == 0
    return []
  endif
  let l:tags = [a:starting_key]
  let tag_length = 1
  while tag_length < a:tag_length
    let tag_length += 1
    let old_tags = l:tags
    let l:tags = []
    for l:tag in old_tags
      for key in g:jumpsearch_tag_keys
        let l:tags += [l:tag . key]
      endfor
    endfor
  endwhile
  return l:tags
endfunction
