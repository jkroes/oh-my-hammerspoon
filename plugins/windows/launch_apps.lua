-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
  {"g", "Google Chrome"},
}

--- Initialize the module
function winmod.init()
  -- Launch and focus apps
  local c = winmod.config

  -- hs.fnutils.ieach(c,
  -- function(element)
  --   hyper2:bind({}, element[1],
  --   function()
  --     hs.application.launchOrFocus(element[2])
  --     hyper:exit()
  --   end)
  -- end)

  omh.bindKeys2Mode(omh.modes, 2, c, function(x)
    hs.application.launchOrFocus(x)
  end)

end

return winmod

-- Alternative method with activate:
-- http://thume.ca/2016/07/16/advanced-hackery-with-the-hammerspoon-window-manager/
-- see second-to-last chunk that inserts table elements into definitions table before binding
