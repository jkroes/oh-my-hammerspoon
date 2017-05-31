# Oh-my-Hammerspoon!

This repository is a fork of Oh-my-Hammerspoon!

## A self-note on exploring this repository's code
While tracing the code in these files (e.g. to see where `OMH_CONFIG` may be set to a non-empty value), try `grep -r "OMH_CONFIG" ~/.hammerspoon`.

## Instructions

1. Check out this repository onto your `~/.hammerspoon` directory:

   ```
   git clone https://github.com/zzamboni/oh-my-hammerspoon.git ~/.hammerspoon
   ```
2. Edit `init.lua` to enable/disable the plugins you want (at the
   moment they are all enabled by default).
3. Copy `init-local-sample.lua` to `init-local.lua` and modify to
   change plugin configuration parameters or add your own arbitrary
   code. Refer to the configuration block of each plugin (near the top
   of its source file, usually) for the available configuration
   parameters.

## OMH Algorithm and Structure

`init.lua` is loaded first. First `init.lua` loads `oh-my-hammerspoon.lua`, which loads `init-local.lua`. `init-local.lua` calls `omh_config`, which stores configuration values for use by load_plugins. `omh_go` is next called from `init.lua`. `omh_go` calls `load_plugins`. `load_plugins`, well, loads plugins (i.e. calls require on contents of `~/.hammerspoon/plugins`), overrides the default `mod.config` (i.e. the conifigurable values specified in each plugin file) before calling `mod.init`, and sets `omh.plugin_cache`. `mod.init` varies from plugin to plugin but usually sets keybindings (via `omh.bind`, see below) based on the (potentially custom) values stored in `mod.config`.

The reason for init-local.lua is that it allows us to separate user configuration from default configuration. It also forces us to expose configuration options, rather than make users hunt through source code, provided there are no bugs.

Note: plugin files have a general sturcture. A module table is returned at the end of each file. Functions are included as fields in this table if they are bound to keyboard shortcuts. If you create a new plugin module, make sure to follow this structure. For more on module structure, see [this tutorial](http://lua-users.org/wiki/ModulesTutorial). Note that any global variables (including functions) are accessible from the plugin files. Be careful to use local variables in these files as much as possible.

It's not totally clear why modifying package.path at the start of `oh-my-hammerspoon.lua` allows for loading `.lua` files in subdirectories of `./hammerspoon` with require("subdirectory.luafileprefix"). [This link](http://lua-users.org/wiki/LuaModuleFunctionCritiqued) hints that it may be a result of hammerspoon using `module()`, but I don't know enough Lua to comment. I just know that it works.

## List of other core constants, variables, and functions used across multiple files

### Constants/objects
`hostname`

`logger`: instantiation of `hs.logger`

`hs_config_dir`: usually equal to `~/.hammerspoon`

`omh.plugin_cache`: list of loaded plugins

`mod.config` (local): list of plugin-specific configurations

### User Functions
`omh.capture`: Captures input-command output. Consider replacing with built-ins, hs.getConsole or hs.task.
```
function omh.bind(keyspec, fun)
   hs.hotkey.bind(keyspec[1], keyspec[2], fun)
end
```

### Useful built-in functions
`hs.fnutils`: contains helper functions for general use

`hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:title()) end)`: list names, as used in hs, of running applications. The names returned can be used, e.g. in hs.appfinder.appFromName.

## Notes on the Lua language

### Conditionals

If you see variables or functions in a conditional, the conditional body will evaluate so long as the condition doesn't evaluate to `nil` or `false` (`0` WILL trigger the body).

### Scope

Lua 4 seems to have used limited scope, whereby upvalues required a % to access and were read-only. Since Hammerspoon is a fork of Mjolnir, it seems to use at least Lua 5.2. Some of the functionality in OMH (i.e. accessing local variables external to a function) also indicates that the app uses at least Lua 5, and GitHub suggests it's 5.3.4 (see LuaSkin folder).

Anyone familiar with scoping in R should be familiar with scoping in Lua 5. Scoping is lexical. Variables in functions, loops, and conditionals have their own scope (i.e. environment in R), which are ephemeral. Closures are possible. An example from the [lua-users Wiki](http://lua-users.org/wiki/ScopeTutorial):
```
local function f()
  local v = 0
  local function get()
    return v
  end
  local function set(new_v)
    v = new_v
  end
  return {get=get, set=set}
end

local t, u = f(), f()
print(t.get()) --> 0
print(u.get()) --> 0
t.set(5)
u.set(6)
print(t.get()) --> 5
print(u.get()) --> 6
```
"Since the two values returned by the two calls to f are independent, we can see that every time a function is called, it creates a new scope with new variables."

[See more examples](https://gist.github.com/jkroes/7b6f869653de9ceb402ecbc28db5256d)

You've probably noticed the `local` tag. In R, variables are evaluated wherever they are first found. For example, if a variable is evaluated within a function, by default R first looks within the function execution environment, then any enclosing environments (i.e. nested functions), and finally the global environment. When assigning values to a variable using `<-` or `=`, R always creates a local variable. In order to modify variables in parent/enclosing environments, the special `<<-` operator or the assign function must be used. To choose a specific environment, use the `eval` function. The idea of global variables isn't even necessary in R, but by convention we may talk about variables in the global environment--the last environment searched through lexical scoping rules.

In contrast, in Lua variables must be declared local. When evaluating a variable, the innermost variable found will be assigned--same as R. If declaring/assinging a variable, unlike R, an outer variable will be overwritten unless the `local` tag is used. If both local and global variables have been declared with the same name at the same level, the later declaration overwrites the older one.

To create a new scope without using a function, loop, or conditional, use `do ... end`.

### Object types
There are eight basic types in Lua: `nil`, `boolean`, `number`, `string`, `userdata`, `function`, `thread`, and `table`. Modules are loaded as tables. Type `hs` into the console and see what it shows you.

## Functionality included

This config has already replaced my use of the following apps:

- [Breakaway](http://www.macupdate.com/app/mac/23361/breakaway) - automatically pause/unpause music when headphones are unplugged/replugged. Supports Spotify and iTunes at the moment. See [headphones_watcher.lua](plugins/audio/headphones_watcher.lua).

- [ClipMenu](http://www.clipmenu.com) - clipboard history, supporting only text entries for now. See [clipboard.lua](plugins/misc/clipboard.lua).
  - `Shift-Cmd-v` shows the clipboard menu by default.


- [Choosy](https://www.choosyosx.com) and other URL dispatchers -
  allows opening URLs in different applications depending on regular
  expression matching. Great if you use site-specific browsers created
  with [Epichrome](https://github.com/dmarmor/epichrome) or
  [Fluid](http://fluidapp.com). See
  [url_handling.lua](plugins/misc/url_handling.lua).

- [Spectacle](https://www.spectacleapp.com) - window
  manipulation. Only some shortcuts implemented, those that I use, but
  others should be easy to
  add. See [manipulation.lua](plugins/windows/manipulation.lua)
  and [grid.lua](plugins/windows/grid.lua).
  - `Ctrl-Cmd-left/right/up/down` - resize the current window to the
    corresponding half of the screen.
  - `Ctrl-Alt-left/right/up/down` - resize and move the current window
    to the previous/next horizontal/vertical third of the screen.
  - `Ctrl-Alt-Cmd-F` or `Ctrl-Alt-Cmd-up` - maximize the current window.
  - `Ctrl-Alt-Cmd-left/right` - move the current window to the
    previous/next screen (if more than one monitor is plugged in).
  - `Ctrl-Alt-Cmd-g` overlays a grid on top of the current screen -
    press the keys corresponding to the top-left and bottom-right
    corners you want, and the current window will be resized to fit.
- [ShowyEdge](https://pqrs.org/osx/ShowyEdge/index.html.en) - menu bar
  coloring to indicate the currently selected keyboard layout (again,
  only the indicators I use are implemented, but others are very easy
  to add). See
  [menubar_indicator.lua](plugins/keyboard/menubar_indicator.lua).

It additionally provides the following functionality:

- Screen rotation shortcuts
  ([screen_rotate.lua](plugins/windows/screen_rotate.lua)) allows
  quickly toggling the rotation of the screen. It supports multiple
  screens, and you can associate keybindings with each one by name.
  - By default, `Ctrl-Cmd-Alt-F15` toggles the first external monitor
    connected. See `init-local-sample.lua` for examples of more
    complex configuration.
- Automatic/manual configuration reloading ([hammerspoon_config_reload.lua](plugins/apps/hammerspoon_config_reload.lua))
  - `Ctrl-Alt-Cmd-r` - manual reload, or when any `*.lua` file in
    `~/.hammerspoon/` changes.
- A color sampler/picker ([colorpicker.lua](plugins/misc/colorpicker.lua))
  - `Ctrl-Alt-Cmd-c` gives you a menu to choose a color palette, and
    toggles a full-screen color picker of the colors in
    `hs.drawing.color`. Clicking on any color will dismiss the picker
    and copy its name to the clipboard, Cmd-clicking copies its RGB
    code.
- Mouse locator ([mouse/locator.lua](plugins/mouse/locator.lua)).
  - `Ctrl-Alt-Cmd-d` draws a red circle around the mouse for 3 seconds.
- Skype mute/unmute ([skype_mute.lua](plugins/apps/skype_mute.lua))
  - `Ctrl-Alt-Cmd-Shift-v` mutes/unmutes Skype, regardless of whether
    it's the frontmost application.
- Install the Hammerspoon command line interface
  ([hammerspoon_install_cli.lua](plugins/apps/hammerspoon_install_cli.lua)).
- Set up a keybinding (Cmd-Alt-Ctrl-y) to open/close the Hammerspoon
  console
  ([hammerspoon_toggle_console.lua](plugins/apps/hammerspoon_toggle_console.lua))


It has drawn inspiration and code from many other places, including:

- [victorso's clipboard manager](http://github.com/victorso/.hammerspoon)
- [cmsj's hammerspoon config](http://github.com/cmsj/hammerspoon-config)
- [Hammerspoon's sample configurations page](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations)
- [oh-my-zsh](http://github.com/robbyrussell/oh-my-zsh) and
  [oh-my-fish](http://github.com/oh-my-fish/oh-my-fish) for the name inspiration :)
