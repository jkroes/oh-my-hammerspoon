-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
}

--- Initialize the module
function winmod.init()
  -- Launch and focus apps
  local c = winmod.config

  omh.bindKeys2Mode(omh.modes, 6, c, function(x)
    hs.application.launchOrFocus(x)
  end)

end

return winmod
