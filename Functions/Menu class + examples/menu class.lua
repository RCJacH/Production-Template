----------------
-- Menu class --
----------------

-- To create a new menu instance, call this function like this:
--   menu_name = Menu("menu_name")
local Menu = 
  class(
    function(menu, id)
      menu.id = id    
      menu.items = {}       -- Menu items are collected to this table
      menu.items_str = ""
      menu.curr_item_pos = 1
    end
  )

------------------
-- Menu methods --
------------------

-- True if menu item label starts with "prefix"
function Menu:label_starts_with(label, prefix)
  return string.sub(label, 1, string.len(prefix)) == prefix
end


-- Returns the created table and table index in "menu_obj.items"
function Menu:add_item(...)
  local t = ... or {}
  t._has_submenu = false
  t._last_item_in_submenu = false
  self.items[#self.items+1] = t -- add new menu item at the end of menu
  t.id = self.curr_item_pos
  self.curr_item_pos = self.curr_item_pos + 1
  -- Parse arguments
  for i,v in pairs(t) do
    --msg(i .. " = " .. tostring(v))
    if i == "label" then
      t.label = v
      if string.sub(t.label, 1, 1) == ">" or
         string.sub(t.label, 1, 2) == "<>" or
         string.sub(t.label, 1, 2) == "><" then
        t._has_submenu = true
        t.id = -1
        self.curr_item_pos = self.curr_item_pos - 1
      --end
      elseif string.sub(t.label, 1, 1) == "<" then
        t._has_submenu = false
        t._last_item_in_submenu = true
      end
    elseif i == "selected" then
      t.selected = v
    elseif i == "active" then
      t.active = v
    elseif i == "toggleable" then
      t.toggleable = v
    elseif i == "command" then
      t.command = v
    end
  end
  
  -- Default values for menu items
  -- (Edit these)
  if t.label == nil or t.label == "" then
    t.label = tostring(#self.items) -- if label is nil or "" -> label is set to "table index in menu_obj.items"
  end
  
  if t.selected == nil then
    t.selected = false   -- edit
  end
  
  if t.active == nil then
    t.active = true      -- edit
  end
  
  if t.toggleable == nil then
    t.toggleable = false -- edit
  end
  
  if t.command == nil then
    t.command = function() return end
  end
  --t.command = function() reaper.ShowConsoleMsg(t.id) end
  return t, #self.items
end


-- Get menu item table at index
function Menu:get_item(index)
  if self.items[index] == nil then
    return false
  end
  return self.items[index]
end


-- Show menu at mx, my
function Menu:show(mx, my)
  gfx.x = mx
  gfx.y = my
  for i=1, #self.items do
    if self.items[i].on_menu_show ~= nil then
      self.items[i].on_menu_show()
    end
  end
  self.items_str = self:table_to_string() or ""
  self.val = gfx.showmenu(self.items_str)
  if self.val > 0 then
    self:update(self.val)
  end
end


function Menu:update(menu_item_index)
  for i=1, #self.items do
    if self.items[i].id == menu_item_index then
      menu_item_index = i
      break
    end
  end
  local i = menu_item_index 
  if self.items[i].toggleable then
    self.items[i].selected = not self.items[i].selected
  end
  if self.items[i].command ~= nil then
    self.items[i].command()
  end
end


-- Convert "Menu_obj.items" to string
function Menu:table_to_string()
  if self.items == nil then
    return
  end
  self.items_str = ""
  
  for i=1, #self.items do
    local temp_str = ""
    local menu_item = self.items[i]
    if menu_item.selected then
      temp_str = "!"
    end
    
    if not menu_item.active then
      temp_str = temp_str .. "#"
    end
    
    if #menu_item > 0 then
      --self.items[i]
      temp_str = temp_str .. ">"
    end
    
    if menu_item.label ~= "" then
      temp_str = temp_str .. menu_item.label .. "|"
    end
    
    if i < #self.items then
     -- s = s .. "|"
    end
    self.items_str = self.items_str .. temp_str
  end
  
  return self.items_str
end

--END of Menu class----------------------------------------------------

return Menu

