--- Diego Zamboni <diego@zzamboni.org>
-- Window management

local winmod = {}

winmod.config = {
  maximize = "m",
  screens = {
    screen_right = "l",
    screen_left = "j"
  },
  halves = {
    left = "j",
    right = "l",
    top = "i",
    bottom = "m"
  },
  thirds = {
    third_left = "j",
    third_right = "l",
    third_up = "i",
    third_down = "m"
  },
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
function winmod.resizeCurrentWindow(how)
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
function winmod.init()
  --[[
  local c=winmod.config

  hs.fnutils.each(c,
  function(element)
    hs.hotkey.bind(element[1],element[2],
    function()
      --winmod.resizeCurrentWindow(element[3])
      --print(find(c,element))
      winmod.resizeCurrentWindow(find(c,element))
    end)
  end)
  --]]
  local c = winmod.config
  local m = winmod.config.maximize
  local s = winmod.config.screens
  local h = winmod.config.halves
  local t = winmod.config.thirds

  hyper:bind({}, m,
  function()
    winmod.resizeCurrentWindow(find(c,m))
    hyper:exit()
  end)

  hs.fnutils.each(s,
  function(element)
    hyper3:bind({}, element,
    function()
      winmod.resizeCurrentWindow(find(s,element))
      hyper3:exit()
      hyper:exit()
    end)
  end)

  hs.fnutils.each(h,
  function(element)
    hyper4:bind({}, element,
    function()
      winmod.resizeCurrentWindow(find(h,element))
      hyper4:exit()
      hyper:exit()
    end)
  end)

  hs.fnutils.each(t,
  function(element)
    hyper5:bind({}, element,
    function()
      winmod.resizeCurrentWindow(find(t,element))
      hyper5:exit()
      hyper:exit()
    end)
  end)

end

return winmod
