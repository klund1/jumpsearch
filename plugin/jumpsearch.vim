let g:jumpsearch_jump_timeout = get(g:, 'jumpsearch_jump_timeout', 3000)
let g:jumpsearch_search_complete_timeout = get(g:, 'jumpsearch_search_complete_timeout', 300)
let g:jumpsearch_tag_keys = get(g:, 'jumpsearch_tag_keys',
  \ ['a', 's', 'd', 'f', 'j', 'k', 'l', ';', 'g', 'h', 'z', 'x', 'c', 'v', 'b', 'n', 'm', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'])
let g:jumpsearch_inc_search = get(g:, 'jumpsearch_inc_search', 1)
let g:jumpsearch_max_tags = get(g:, 'jumpsearch_max_tags', 100)

command! JumpSearch :noautocmd call jumpsearch#search#run()
command! JumpSearchBrace :noautocmd call jumpsearch#search#run('[{}]')
nnoremap ; :JumpSearch<cr>
