let g:rclip#executable = get(g:, 'rclip#executable', '/usr/bin/rclip')
let g:rclip#address = get(g:, 'rclip#address', 'localhost:9889')
let g:rclip#recover_delay = get(g:, 'rclip#recover_delay', 5000)

let s:enabled = 0
let s:listenerJob = 0

function! rclip#enable() abort
  let s:enabled = 1
  augroup rclip
    autocmd!
    autocmd TextYankPost * call s:on_text_yank(join(v:event["regcontents"], "\n"))
  augroup END

  call s:start_listener()
endfunction

function! rclip#disable() abort
  let s:enabled = 0
  augroup rclip
    autocmd!
  augroup END

  call s:stop_listener()
endfunction

function! s:on_text_yank(text) abort
  silent! call system(g:rclip#executable . 'copy -a ' . g:rclip#address, a:text)
endfunction

function! s:start_listener() abort
  if has('nvim')
    let s:listenerJob = jobstart(
    \ [g:rclip#executable, "listen", "-a", g:rclip#address, "-b"],
    \ {
      \ "on_stdout": function('s:on_listener_event'),
      \ "on_exit": function('s:on_listener_event'),
    \ }
  \ )
  else
    let s:listenerJob = job_start(
    \ [g:rclip#executable, "listen", "-a", g:rclip#address, "-b"],
    \ {
      \ "out_cb": function('s:on_listener_message'),
      \ "exit_cb": function('s:on_listener_exit'),
    \ }
  \ )
  endif
endfunction

function! s:stop_listener() abort
  if has('nvim')
    jobstop(s:listenerJob)
  else
    job_stop(s:listenerJob)
  endif
endfunction

function! s:recover_listener(timer)
  call s:start_listener()
endfunction

function! s:on_listener_message(channel, msg)
  call setreg('"', s:base16decode(a:msg))
endfunction

function! s:on_listener_exit(job, status)
  if s:enabled && a:status != 0
    timer_start(g:rclip#recover_delay, 's:recover_listener', {'repeat', -1})
  endif
endfunction

function! s:on_listener_event(job_id, data, event)
  if a:event == 'stdout'
    call setreg('*', s:base16decode(join(a:data, "")))
  elseif a:event == 'exit'
    if s:enabled && a:data != 0
      timer_start(g:rclip#recover_delay, 's:recover_listener', {'repeat', -1})
    endif
  endif
endfunction

function! s:base16decode(data) abort
  return silent! call system('xxd -r -p', a:data)
endfunction
