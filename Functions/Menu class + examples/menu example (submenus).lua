function msg(m)
  reaper.ShowConsoleMsg(tostring(m) .. "\n")
end

-- Returns current script's path
function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end


-- Get "script path"
local script_path = get_script_path()
--msg(script_path)

-- Modify "package.path"
package.path = package.path .. ";" .. script_path .. "?.lua"
--msg(package.path)

          
---------------------------------------------
-- Import files ("classes", functions etc.)--
---------------------------------------------
require "class" -- import "base class"
local mouse = require "mouse"
local Menu = require "menu class"
---------------------------------------------


-- Example ---------------------------------------------------------------------
-------------------------------
-- Create "right click" menu --
-------------------------------

-- Create a "Menu" instance
local rc_menu = Menu("rc_menu")


-- Add menu items to "rc_menu"

-- Top level items
item1 = rc_menu:add_item({label = "Top level - Item 1"})            
item2 = rc_menu:add_item({label = ">Submenu 1"})                   -- ">" at the start spawns a submenu
  -- Submenu 1 items
  item3 = rc_menu:add_item({label = "SM 1 - Item 1"})
  item4 = rc_menu:add_item({label = "<>SM 2 - Last item of SM 1"}) -- End of "submenu 1", and start of "submenu 2"
    -- Submenu 2 items
    item5 = rc_menu:add_item({label = "SM 2 - Item 1"})
    item6 = rc_menu:add_item({label = "SM 2 - Item 2"})            -- "|" at the end adds a separator
    item7 = rc_menu:add_item({label = "<SM 2 - Item 3"})           -- End of "submenu 2" (next items are top level items)
-- Last two top level items
item9 = rc_menu:add_item({label = "Top level - Item 2|"})          -- "|" at the end adds a separator
item10 = rc_menu:add_item({label = "Top level - Item 3"})

-- (Note: it's not necessary to store the created items to item1..item10
-- The items are already stored to "rc_menu.items" -table)

-- Let's add a command to all created items:
for i=1, #rc_menu.items do
  rc_menu.items[i].command = function()
                               msg("Last clicked item: " .. rc_menu.items[i].id)
                               msg("gfx.menushow returns: " .. rc_menu.val)
                               msg("If values match -> everything worked better than expected :)\n")
                             end
end


msg("Menu string - This is passed to 'gfx.showmenu':\n" .. rc_menu:table_to_string() .. "\n") -- show current menu string in reascript console
--END of example ---------------------------------------------------------------


---------------
-- Main loop --
---------------

function mainloop()
  local RMB_state = mouse.cap(mouse.RB)
  local mx = gfx.mouse_x
  local my = gfx.mouse_y
  
  if not mouse.last_RMB_state and gfx.mouse_cap&2 == 2 then
    -- right click pressed down -> show "right click menu" at mouse cursor
    rc_menu:show(mx, my)
  end
  
  mouse.last_RMB_state = RMB_state -- store current right mouse button state

  gfx.update()
  if gfx.getchar() >= 0 then reaper.defer(mainloop) end
end


gfx.init("Menu example", 400, 100)
mainloop()
