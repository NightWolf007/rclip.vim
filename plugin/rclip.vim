let g:rclip#enable_at_startup = get(g:, 'rclip#enable_at_startup', 0)

if g:rclip#enable_at_startup
  call rclip#enable()
endif

command! RClipEnable call rclip#enable()
command! RClipDisable call rclip#disable()
