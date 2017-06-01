-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
  path = "~/Documents/cheatsheets/",
  git = {
    key = "g",
  }
}

--- Initialize the module
hypertable = {} -- may not need to be global. Spent hours debugging only to realize I used numbers instead of strings as a keybinding and that was tanking the script.

function winmod.init()
  local c = winmod.config
  local path = c.path
  c.path = nil -- allow easy looping

  hs.fnutils.each(c,
  function(element)
    local key = find(c,element)
    hypertable[key] = hs.hotkey.modal.new()
    local hyper_local = hypertable[key]
    hyper7:bind({}, element.key, function()
      hyper_local:enter()
    end)

    path = path .. key .. "/"
    local files = {}
    local filestring = hs.execute("ls -1 " .. path .. " | grep -v '.md'")
    for file in string.gmatch(filestring, "[%a%.%d_]+") do
      table.insert(files,file)
    end


    --local numfiles = hs.execute("ls -1 " .. element.path .. " | grep -v '.md' | wc -l")
    local numfiles = #files
    for i = 1,numfiles do
      hyper_local:bind({}, string.format(i),
      function()
        ----hs.execute("open " .. element.path .. "/Diagram1.png")
        hs.execute("open " .. path .. files[i])
        print("open " .. path .. files[i])
        hyper_local:exit()
        hyper7:exit() -- must include an exit statement for every binding!!!
        hyper:exit()
      end)
    end
  end)
end

return winmod
