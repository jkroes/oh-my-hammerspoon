obj = {}
obj.modes = {}
obj.modes.hyper = hs.hotkey.modal.new()
obj.notifications = true

-- Notification types:
----Tab, tab: Enter hyper, exit hyper
----Tab,childkey,tab: Enter hyper, enter child, exit child
----Tab, childkey, childkey: Enter hyper, enter child, exit hyper, enter hyper
----Expected behavior for 3+-deep modal chains, such as cheaters
function obj:bindMode2Mode(parent, key, phrase, createHyper, cheats)
  local hyper = self.modes.hyper
  local parent = self.modes[parent]
  local child
  if not createHyper then
    child = hs.hotkey.modal.new()
    self.modes[phrase] = child
    parent:bind({}, key, function() parent:exit(); child:enter() end)
    if cheats then key = "Q" end
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

  -- Prevent exit messages when switching to another mode. To enable exit
  -- messages for completed actions (excluding modal entry or hyper exit)
  -- set hyper.watch = nil, then exit the mode in the key function. This allows
  -- also the next hyper key press to re-enter hyper mode.
  function child:exited()
    print('Exited ' .. phrase .. ' mode', '')
    if (not hyper.watch) and notifications then
        hs.notify.show('Hammerspoon', 'Exited ' .. phrase .. ' mode', '')
    end
    child.active = nil
  end
end

function obj:exitSequentialMode(mode)
  self.modes.hyper.watch = nil
  if type(mode) == 'string' then
    self.modes[mode]:exit()
  elseif type(mode) == 'table' then
    mode:exit()
  end
end

return obj
