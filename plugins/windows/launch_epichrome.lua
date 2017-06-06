-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
}

--- Initialize the module
function winmod.init()

  local c = winmod.config
  local modalPhrase = c.modalPhrase; c.modalPhrase = nil
  local modalKey = c. modalKey; c.modalKey = nil
  local hyper = omh.modes.hyper
  omh.bindMode2Mode(hyper, modalKey, modalPhrase)
  local launchMode = omh.modes[modalPhrase]

  hs.fnutils.ieach(c,
  function(element)
    launchMode:bind({}, element[1],
    function()
      hs.application.launchOrFocus(element[2])
      hyper.watch = nil -- must come before exit()!!!
      launchMode:exit()
    end)
  end)

end

return winmod
