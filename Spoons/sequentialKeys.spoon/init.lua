obj = {}
obj.modes = {}
obj.modes.hyper = hs.hotkey.modal.new()
obj.notifications = true

-- Notification types:
----Tab, tab: Enter hyper, exit hyper
----Tab,childkey,tab: Enter hyper, enter child, exit child
----Tab, childkey, childkey: Enter hyper, enter child, enter hyper
----Expected behavior for 3+-deep modal chains, such as cheaters
----If a key is mapped to a childkey, the child mode will only be exited with
----hyperkey
function obj:bindModes(arg)
  local modes = self.modes
  local hyper = modes.hyper
  local parent = arg.parent
  if type(parent) == 'string' then parent = modes[arg.parent] end
  local child -- forward declaration
  local key = arg.key
  local phrase = arg.phrase
  local altEscapeKey = arg.altEscapeKey

  if parent then
    child = hs.hotkey.modal.new(); self.modes[phrase] = child
    parent:bind({}, key, function() parent:exit(); child:enter() end)
    if altEscapeKey then key = altEscapeKey end
    child:bind({}, key, function() child:exit(); parent:enter() end)
  else
    hs.hotkey.bind({}, key, function()
      if not hyper.watch then hyper:enter(); hyper.watch = true
      else
        hyper.watch = nil; hs.fnutils.each(self.modes, function(element)
          if element.active then element:exit() end
        end)
      end
    end)
    child = hyper
  end

  -- Overwrite modal objects' enter-exit methods
  local notifications = self.notifications
  function child:entered()
    print('Entered ' .. phrase .. ' mode', '')
    if notifications then
      hs.notify.show('Hammerspoon', 'Entered ' .. phrase .. ' mode','')
    end
    child.active = true
  end

  function child:exited()
    print('Exited ' .. phrase .. ' mode', '')
    if (not hyper.watch) and notifications then
        hs.notify.show('Hammerspoon', 'Exited ' .. phrase .. ' mode', '')
    end
    child.active = nil
  end
end

function obj:exitSequentialMode(mode, withoutMsg)
  local hyper = self.modes.hyper
  if not withoutMsg then hyper.watch = nil end
  if type(mode) == 'string' then mode = self.modes[mode] end
  mode:exit()
  if withoutMsg then hyper.watch = nil end
end

return obj
