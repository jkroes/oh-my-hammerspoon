require("oh-my-hammerspoon")

-- Load modules
omh_go({
      "apps.hammerspoon_config_reload",
      --"apps.windowtabs",
      "windows.manipulation",
      "windows.launch_apps",
      "windows.launch_epichrome",
      -------------------------"windows.rough_cheatsheets",
      --"windows.screen_rotate",
      --"windows.grid",
      --"mouse.locator",
      "audio.headphones_watcher",
      --"misc.clipboard", --The code was pretty convoluted. I gave up. No menubar indicator visible for some reason.
      --"misc.colorpicker", --Ignored the rest of these.
      --"misc.statuslets",
      --"misc.url_handling" --Even though this wasn't enabled, every reload would ask to use hs as my default browser. Then it stopped. Chrome has also been crashing. The app wouldn't open, or would throw other weird error msgs. Now that the file's code is commented out, things seem OK.
      --"windows.screen_rotate", -- Give it a whirl sometime!
       })

-- todo: You may end up just using Alfred instead and maybe http://www.packal.org/workflow/hammerspoon-workflow
-- todo: When an exit command is sent to hammerspoon, exit spoons.
-- todo: look into hs.canvas for broken screen, as with RoundedCorners
-- todo: COMPARE SPOONS FOR EQUIVALENCY WITH OMH_GO MODULES. OBVIOUS DUPLICATION.
