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

  hs.fnutils.ieach(c,
  function(element)
    hyper2:bind({}, element[1],
    function()
      hs.application.launchOrFocus(element[2])
      hyper2:exit() -- must include an exit statement for every binding!!!
      hyper:exit()
    end)
  end)

end

return winmod
