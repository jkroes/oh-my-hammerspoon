-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
}

--- Initialize the module
function winmod.init()

  local c = winmod.config
  local hyper = omh.modes.hyper

  hyper:bind({"cmd"}, c[1], function()
    -- _,message,_ = hs.osascript.applescript('return "Hello World"')
    hyper.watch = nil
    hyper:exit() -- need to exit before typing input into dialog box
    local as = 'set theResponse to display dialog "Enter message" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue" \
    return (text returned of theResponse)'
    _,message,_ = hs.osascript.applescript(as)
    if message then
      hs.messages.iMessage("9167996697", message)
    end
  end)

end

return winmod
