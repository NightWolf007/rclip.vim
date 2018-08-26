# rclip.vim
Integrates vim clipboard with [RClip server](https://github.com/NightWolf007/rclip).

**Note:** rclip.vim requires `TextYankPost` event and `timer_start` function.
They was added in Vim 8 and NeoVim.

## Installation

```
Plug 'NightWolf007/rclip.vim'
```

## Configuration

```
set clipboard=unnamed

g:rclip#enable_at_startup = 1
g:rclip#executable = '/usr/bin/rclip'
g:rclip#address = 'localhost:9889'
g:rclip#recovery_delay = 5000
```
