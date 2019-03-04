let g:jumpsearch_jump_timeout = get(g:, 'jumpsearch_jump_timeout', 3000)
let g:jumpsearch_search_complete_timeout = get(g:, 'jumpsearch_search_complete_timeout', 300)
let g:jumpsearch_tag_keys=get(g:, 'jumpsearch_tag_keys', ['a', 's', 'd', 'f', 'j', 'k', 'l', ';'])

command! JumpSearch :call jumpsearch#search#run()
nnoremap ; :JumpSearch<cr>
