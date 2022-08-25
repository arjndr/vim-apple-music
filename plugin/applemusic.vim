if exists("g:loaded_applemusic")
  finish
endif

let g:loaded_applemusic = 1

if !exists('g:applemusic_status_template')
  let g:applemusic_status_template = ' {status}  {title} By {artist}'
endif

let g:applemusic_status = ''
"  headless mode (0 = false, 1 = true)
let g:applemusic_headless = 0

let g:applemusic_play_character = ''
let g:applemusic_pause_character = ''

let g:applemusic_loved_character = ''
let g:applemusic_unloved_character = ''

let g:applemusic_disliked_character = ''

if !g:applemusic_headless
  let timer = timer_start(1000, 'applemusic#watch', { 'repeat': -1 })
endif

command! -nargs=0 AMP call applemusic#PlayPause()
command! -nargs=0 AMN call applemusic#Next()
command! -nargs=0 AMPr call applemusic#Previous()
command! -nargs=0 AMF call applemusic#Favorite()
command! -nargs=0 AMD call applemusic#Dislike('false')
command! -nargs=0 AMDS call applemusic#Dislike('true')
