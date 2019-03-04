highlight JumpSearchPending          ctermfg=0   ctermbg=222   cterm=NONE
highlight JumpSearchEnd              ctermfg=0   ctermbg=222   cterm=NONE
highlight JumpSearchJump             ctermfg=0   ctermbg=red   cterm=NONE

let g:jumpsearch_jump_timeout = get(g:, 'jumpsearch_jump_timeout', 3000)
let g:jumpsearch_search_complete_timeout = get(g:, 'jumpsearch_search_complete_timeout', 300)
let g:jumpsearch_tag_keys=get(g:, 'jumpsearch_tag_keys', ['a', 's', 'd', 'f', 'j', 'k', 'l', ';'])

command! JumpSearch :call jumpsearch#search#run()
nnoremap ; :JumpSearch<cr>
