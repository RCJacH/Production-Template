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


-- Example ----------------------------------------------------------------------------------------------------
-------------------------------
-- Create "right click" menu --
-------------------------------

local rc_menu = Menu("rc_menu")

---[[
item = rc_menu:add_item(
                  {  
                     label = "Show mixer",
                     selected = true, 
                     active = true,
                     toggleable = true,
                     command = function() reaper.Main_OnCommand(40078, 0) end -- 40078 = toggle mixer visible
                  }
                )

-- Add "on_menu_show" function to last created menu item
-- This function is executed just before the menu is shown           
item.on_menu_show = function()
                      -- 40078 = toggle mixer visible
                      item.selected = reaper.GetToggleCommandState(40078) == 1 -- update this menu item's 'selected' state
                    end
--END of example ---------------------------------------------------------------                    
    
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

                    
-------------------------------------------------------------------------------

gfx.init("Menu example", 300, 300)
mainloop()
