let s:applemusic_toggle_script = ['if application "Music" is running then', 'tell application "Music"', 'playpause', 'end tell', 'end if']
let s:applemusic_next_script = ['if application "Music" is running then', 'tell application "Music"', 'next track', 'end tell', 'end if']
let s:applemusic_previous_script = ['if application "Music" is running then', 'tell application "Music"', 'previous track', 'end tell', 'end if']

let s:applemusic_favorite_script = ['tell application "Music"', 'if loved of current track then', 'set loved of current track to false', 'else', 'set loved of current track to true', 'end if', 'end tell']
let s:applemusic_dislike_script = ['on run argv', 'set skip to item 1 of argv as boolean', 'tell application "Music"', 'if disliked of current track then', 'set disliked of current track to false', 'else', 'set disliked of current track to true', 'if skip then', 'next track', 'end if', 'end if', 'end tell', 'end run']

let s:applemusic_current_track_script = ['if application "Music" is running then', 'tell application "Music"', 'set track_info to "{\"artist\":\""', 'set track_info to track_info & artist of current track & "\",\"title\":\""', 'set track_info to track_info & name of current track & "\",\"album\":\""', 'set track_info to track_info & album of current track & "\",\"kind\":\""', 'set track_info to track_info & media kind of current track & "\",\"state\":\""', 'set track_info to track_info & player state & "\",\"volume\":\""', 'set track_info to track_info & sound volume & "\",\"muted\":\""', 'set track_info to track_info & mute & "\",\"shuffle\":\""', 'set track_info to track_info & shuffle enabled & "\",\"repeat\":\""', 'set track_info to track_info & song repeat & "\",\"loved\":\""', 'set track_info to track_info & loved of current track & "\",\"disliked\": "', 'set track_info to track_info & disliked of current track & ",\"lyrics\": \""', 'set track_info to track_info & lyrics of current track & "\"}"', 'return track_info', 'end tell', 'end if']

function ReplaceIdentifiers(info)
  let track_details = json_decode(a:info)
	if get(track_details, 'state') == 'playing'
		let l:playback_character = g:applemusic_pause_character
	else
		let l:playback_character = g:applemusic_play_character
	endif

	if get(track_details, 'disliked') == 'true'
		let l:disliked_character = g:applemusic_disliked_character
	else
		let l:disliked_character = ''

		"  It can only be loved if it's not disliked, I think?
		if get(track_details, 'loved') == 'true'
			let l:loved_character = g:applemusic_loved_character
		else
			let l:loved_character = g:applemusic_unloved_character
		endif
	endif

  let l:temp_applemusic_status = substitute(g:applemusic_status_template, '{status}', substitute(l:playback_character, '&', '\\&', 'g'), 'g')
  let l:temp_applemusic_status = substitute(l:temp_applemusic_status, '{title}', substitute(get(track_details, 'title'), '&', '\\&', 'g'), 'g')
  let l:temp_applemusic_status = substitute(l:temp_applemusic_status, '{artist}', substitute(get(track_details, 'artist'), '&', '\\&', 'g'), 'g')
  let l:temp_applemusic_status = substitute(l:temp_applemusic_status, '{album}', substitute(get(track_details, 'album'), '&', '\\&', 'g'), 'g')
  let l:temp_applemusic_status = substitute(l:temp_applemusic_status, '{loved}', substitute(l:loved_character, '&', '\\&', 'g'), 'g')
  let l:temp_applemusic_status = substitute(l:temp_applemusic_status, '{disliked}', substitute(l:disliked_character, '&', '\\&', 'g'), 'g')
  return l:temp_applemusic_status
endfunction

"  Credits to https://github.com/skywind3000/asyncrun.vim
function! applemusic#script_write(name, content)
	let tmpname = fnamemodify(tempname(), ':h') . '/' . a:name
	call writefile(a:content, tmpname)
	silent! call setfperm(tmpname, 'rwxrwxrws')
	return tmpname
endfunction

function! applemusic#run_script(filename, content, args)
	let tmpname = applemusic#script_write(a:filename, a:content)
	"  echo tmpname
	let cmd = '/usr/bin/osascript ' . shellescape(tmpname) . shellescape(a:args)
	if has("nvim")
		return jobstart(cmd, s:callbacks)
  else
    return job_start(cmd)
  endif
endfunction

let s:old_result = ''
function! applemusic#watch(args)
	let tmpname = applemusic#script_write('track_details.scpt', s:applemusic_current_track_script)
	let cmd = '/usr/bin/osascript ' . shellescape(tmpname)
	if has("nvim")
		function! s:OnEvent(job_id, data, event) dict
			let result = join(a:data)
			if s:old_result == result
			else
				"  Check if result is empty string.
				if result == ''
				else
					let s:old_result = result
					let g:applemusic_status = ReplaceIdentifiers(result)
					"  Apparently refreshes statusline, not sure tho. (https://vi.stackexchange.com/a/17876)
					let &stl=&stl
				endif
			endif
		endfunction

		let s:callbacks = {
		\ 'on_stdout': function('s:OnEvent'),
		\ }
		let job_id = jobstart(cmd, s:callbacks)
  else
    return job_start(cmd)
  endif
endfunction

function! applemusic#PlayPause()
	call applemusic#run_script('playpause.scpt', s:applemusic_toggle_script, '')
endfunction

function! applemusic#Next()
	call applemusic#run_script('next.scpt', s:applemusic_next_script, '')
endfunction

function! applemusic#Previous()
	call applemusic#run_script('previous.scpt', s:applemusic_previous_script, '')
endfunction

function! applemusic#AddToLibrary()
	echo 'Not implemented yet'
endfunction

function! applemusic#Favorite()
	call applemusic#run_script('toggle_favorite.scpt', s:applemusic_favorite_script, '')
endfunction

function! applemusic#Dislike(skip)
	call applemusic#run_script('toggle_dislike.scpt', s:applemusic_dislike_script, skip)
endfunction
