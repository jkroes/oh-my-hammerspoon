--- Diego Zamboni <diego@zzamboni.org>
-- Window management

local mod = {}

mod.config = {
}

-- Prevent laggy animations (doesn't need to be optionally configured)
hs.window.animationDuration = 0

-- Window cache for window maximize toggler
-- (persists between function calls)
local frameCache = {}

----------------------------------------------------------------------
--- Base window resizing and moving functions
----------------------------------------------------------------------
-- Get the horizontal third of the screen in which a window is at the moment
function get_horizontal_third(win)
   local frame=win:frame()
   local screenframe=win:screen():frame()
   local relframe=hs.geometry(frame.x-screenframe.x, frame.y-screenframe.y, frame.w, frame.h)
   local third = math.floor(3.01*relframe.x/screenframe.w)
   logger.df("Screen frame: %s", screenframe)
   logger.df("Window frame: %s, relframe %s is in horizontal third #%d", frame, relframe, third)
   return third
end

-- Get the vertical third of the screen in which a window is at the moment
function get_vertical_third(win)
   local frame=win:frame()
   local screenframe=win:screen():frame()
   local relframe=hs.geometry(frame.x-screenframe.x, frame.y-screenframe.y, frame.w, frame.h)
   local third = math.floor(3.01*relframe.y/screenframe.h)
   logger.df("Screen frame: %s", screenframe)
   logger.df("Window frame: %s, relframe %s is in vertical third #%d", frame, relframe, third)
   return third
end


-- Resize current window to different parts of the screen
function mod.resizeCurrentWindow(how)
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local x = 0
  local newrect = {}
  local which_third

  if win == nil then
    return
  end

   -- Adjust coordinates for cracked laptop screen
  if screen:name() == "Color LCD" then
    x = 0.075
  end

  newrect.left = function() return {x,0,(1-x)/2,1} end
  newrect.right = function() return {x+(1-x)/2,0,1-(x+(1-x)/2),1} end
  newrect.top = function() return {x,0,1,0.5} end
  newrect.bottom = function() return {x,0.5,1,0.5} end
  newrect.hthird0 = function() return {x,0,(1-x)/3,1} end
  newrect.hthird1 = function() return {x+(1-x)/3,0,(1-x)/3,1} end
  newrect.hthird2 = function() return {x+2*(1-x)/3,0,(1-x)/3,1} end
  newrect.vthird0 = function() return {x,0,1,1/3} end
  newrect.vthird1 = function() return {x,1/3,1,1/3} end
  newrect.vthird2 = function() return {x,2/3,1,1/3} end
  newrect.bottom_left = function() return {x,1/2,(1-x)/2,1/2} end
  newrect.bottom_right = function() return {x+(1-x)/2,1/2,(1-x)/2,1/2} end
  newrect.top_left = function() return {x,0,(1-x)/2,1/2} end
  newrect.top_right = function() return {x+(1-x)/2,0,(1-x)/2,1/2} end
  newrect.maximize = function()
    local subhow
    if win:id() == nil then
      return
    elseif frameCache[win:id()] then
      subhow = frameCache[win:id()]
      --win:setFrame(frameCache[win:id()])
      frameCache[win:id()] = nil
    else
      frameCache[win:id()] = win:frame()
      subhow = {0+x,0,1,1}
    end
    return subhow
  end
  newrect.screen_left = function()
    hs.window.setFrameCorrectness = true
    win:moveOneScreenWest()
    hs.window.setFrameCorrectness = false
  end
  newrect.screen_right = function()
    hs.window.setFrameCorrectness = true
    win:moveOneScreenEast()
    hs.window.setFrameCorrectness = false
  end

  if how == "third_left" then
    local third = get_horizontal_third(win)
    which_third = "hthird" .. math.max(third-1,0)
  elseif how == "third_right" then
    local third = get_horizontal_third(win)
    which_third = "hthird" .. math.min(third+1,2)
  elseif how == "third_up" then
    local third = get_vertical_third(win)
    which_third = "vthird" .. math.max(third-1,0)
  elseif how == "third_down" then
    local third = get_vertical_third(win)
    which_third = "vthird" .. math.min(third+1,2)
  end

  if which_third then
    how = which_third
  end
  result = newrect[how]() -- store value of call for functions (e.g. newrect.maximize) that change state with each call
  if (result) then
    win:move(result)
  end
end

--- Initialize the module
function mod.init()

  local c = mod.config
  local m = c.maximize
  local z = c.zoom
  local s = c.screens -- these will break if the names are ever changed in the config file. Need to make this robust.
  local h = c.halves
  local t = c.thirds
  local q = c.quarters
  local hyper = omh.modes.hyper

  hyper:bind({}, m, function()
    mod.resizeCurrentWindow(omh.find(c,m))
    hyper.watch = nil; hyper:exit()
  end)

  hyper:bind({}, z, function()
    local frontApp = hs.application.frontmostApplication()
    local zoom = {"Window", "Zoom"}
    frontApp:selectMenuItem(zoom)
    --frontApp:selectMenuItem(zoom) -- a second time returns to previous size, but now the window will be on-screen
    hyper.watch = nil; hyper:exit()
  end)

  local function assign(moveType, idx)
    -- Create movement modes and bind to hyper
    local modalKey = moveType.modalKey; moveType.modalKey = nil
    local modalPhrase = omh.find(c, moveType)
    omh.bindMode2Mode(hyper, modalKey, modalPhrase)
    local mode = omh.modes[modalPhrase]
    -- Bind keys to movement modes
    hs.fnutils.each(moveType, function(movement)
      mode:bind({}, movement, function()
        mod.resizeCurrentWindow(omh.find(moveType, movement))
        hyper.watch = nil -- must come before exit()!!!
        mode:exit()
      end)
    end)
  end

  assign(s)
  assign(h)
  assign(t)
  assign(q)

end

return mod
