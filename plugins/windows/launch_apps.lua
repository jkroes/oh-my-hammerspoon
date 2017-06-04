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
  local hyper = omh.modes[1]
  parent = omh.modes[2]

  hs.fnutils.ieach(c,
  function(element)
    parent:bind({}, element[1],
    function()
      hs.application.launchOrFocus(element[2])
      hyper.watch = nil -- must come before exit()!!!
      parent:exit()
    end)
  end)

end

return winmod
