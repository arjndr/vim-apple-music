# Vim Apple Music

View Apple Music media playback status, control playback and favorite songs, all while never leaving Vim (**on macOS only**)

### Requirements

1. Vim 8+ or Neovim
2. macOS
3. Apple Music (not iTunes)

### Installation

You can probably use any plugin manager to install, just follow their documentation. Here's an example using [Vim Plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'arjndr/vim-apple-music'
```

##### Manual Installation
TODO

### Setup

You can use `g:applemusic_status` variable to get the Apple Music playback status, which you can inject wherever variables are supported. Like in the default Vim statusline or Lualine's sections. You can skip this if you want to use the plugin in [headless mode](#headless-mode)

- Showing Apple Music in default statusline:

```vim
" Run this in Vim command
set statusline = %{applemusic_status}
```

- Showing Apple Music in lualine:

```lua
-- init.lua
require('lualine').setup{
  sections = {
    lualine_c = { 'filename', 'g:applemusic_status' },
  }
}
```

##### Headless Mode

The plugin's [commands](#commands) can be used without displaying the playback status anywhere.

**Pro tip:** Add this to your `.vimrc` to prevent plugin from polling Apple Music track details:

```vim
let g:applemusic_headless = 1
```

### Customization

Use the `g:applemusic_status` variable to show Apple Music status anywhere that's supported. Custom templates can be used to modify status text if you don't like the default template. Available variables are:

| **Variable**             | **Description**     |
|--------------------------|---------------------|
| `status`                 | Playback status of Apple Music (will be replaced with play / pause icons appropriately) |
| `title`                  | Title of currently playing media               |
| `artist`                 | Artist of currently playing media              |

#### Custom icons:

You can have custom icons (or text) for playback status and liked/disliked status by setting the `g:applemusic_play_character` and `g:applemusic_pause_character` variables

Here's an example:

```vim
" using any nerd font icon would be prettier :)
let g:applemusic_play_character = 'Paused'
let g:applemusic_pause_character = 'Playing'
```

### Commands

- `:amp` - Play/Pause media.

- `:amn` - Equivalent to pressing the next button.

- `:ampr` - Equivalent to pressing the previous button.

- `:ama` - Add currently playing media to library.

- `:amf` - Favorite/heart currently playing media.

- `:amd` - Dislike currently playing media.

- `:amds` - Dislike and skip currently playing media.

### Credits

I probably would've had a really hard time with building this plugin if it weren't for these projects below. I modified some of the code from these projects to suit the needs.

- [vscode-itunes](https://github.com/PsykoSoldi3r/vscode-itunes) - Utilized some AppleScript files
- [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) - Utilized code to run AppleScript files

### License
GPLv3. See [LICENSE](LICENSE).
