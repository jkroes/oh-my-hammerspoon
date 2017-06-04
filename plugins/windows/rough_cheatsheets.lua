-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local mod = {}

mod.config = {
  path = "~/Documents/cheatsheets/",
  navkeys = {"a","s","d","f","g","h","j","k","l",";"},
  git = "g"
}

--- Initialize the module
function mod.init()
  local c = mod.config

  omh.bindKeys2Mode(omh.modes, 7, c, function(x) end, true)

end

return mod

--TODO: Show available shortcuts or at least cheat titles in a window when the mode is entered, likely via hs.notify.show's information parameter.
