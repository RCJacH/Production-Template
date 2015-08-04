------------- "class.lua" is copied from http://lua-users.org/wiki/SimpleLuaClasses -----------
-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
   local c = {}    -- a new class instance
   if not init and type(base) == 'function' then
      init = base
      base = nil
   elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
      for i,v in pairs(base) do
         c[i] = v
      end
      c._base = base
   end
   -- the class will be the metatable for all its objects,
   -- and they will look up their methods in it.
   c.__index = c

   -- expose a constructor which can be called by <classname>(<args>)
   local mt = {}
   mt.__call = function(class_tbl, ...)
   local obj = {}
   setmetatable(obj,c)
   if init then
      init(obj,...)
   else 
      -- make sure that any stuff from the base class is initialized!
      if base and base.init then
      base.init(obj, ...)
      end
   end
   return obj
   end
   c.init = init
   c.is_a = function(self, klass)
      local m = getmetatable(self)
      while m do 
         if m == klass then return true end
         m = m._base
      end
      return false
   end
   setmetatable(c, mt)
   return c
end
----------------------------------------------------------------------------------------

Rect = class(function(r, x, y, w, h, min_w, max_w)
      		r.x = x
      		r.y = y
      		r.w = w
		r.min_w = min_w
		r.max_w = max_w
      		r.h = h
	     end
)

function Rect:draw()
   gfx.set(1,0,1,1)
   gfx.rect(self.x, self.y, self.w, self.h);
   gfx.set(0,0,1,1)
   x2 = (self.w - self.min_w) / 2 + self.x
   gfx.rect(x2, self.y, self.min_w, self.h);
end
      
function make_rect(h, min_w, max_w)
   return Rect(0, 100, 0, h, min_w, max_w)
end

function arrange_horizontal(cont, gap_h, rects)
   local sum_min_w = 0;
   local sum_grow = 0;
   for i = 1, #rects do
      sum_min_w = sum_min_w + rects[i].min_w
      sum_grow = sum_grow + rects[i].max_w - rects[i].min_w
      rects[i].w = rects[i].min_w
   end

   -- O(n^2)
   function dist(left, rects)
      if #rects > 0 and left > 0 then
	 nr = {}
	 nl = left;
	 dist_w = left / #rects 
	 for i = 1, #rects do
	    old_w = rects[i].w
	    rects[i].w = math.min(rects[i].max_w, rects[i].w + dist_w)
	    if (rects[i].w - old_w) > 0 then
	       table.insert(nr, rects[i])
	       nl = nl - (rects[i].w - old_w) 
	    end 
	 end

	 return dist(nl, nr)
      else
	 return left
      end
   end

   extra_w = cont.w - sum_min_w - (#rects + 1) * gap_h 
   gap_w = math.max(gap_h, dist(extra_w, rects) / (#rects + 1))
   local x = gap_w
   for i = 1, #rects do
      if rects[i].w > 0 then
	 rects[i].x = x
	 x = x + rects[i].w + gap_w
      end 
   end
end


--//////////////////
--// Button class //
--//////////////////

local Button = class(
                      function(btn,x,y,w,h,state_count,state,visual_state,lbl,help_text)
			 btn.label_w, btn.label_h = gfx.measurestr(btn.label)
			 btn.rect = Rect(x,y,w,h,btn.label_w, btn.label_w + 20)
                        btn.x2 = btn.rect.x + btn.rect.w
                        btn.y2 = btn.rect.y + btn.rect.h
                        btn.state = state
                        btn.state_count = state_count - 1
                        btn.vis_state = visual_state
                        btn.label = lbl
                        btn.help_text = help_text
                        btn.mouse_state = 0
                        
                      end
                    )

-- get current state
function Button:get_state()
   return self.state
end

-- cycle through states
function Button:set_next_state()
  if self.state <= self.state_count - 1 then
    self.state = self.state + 1
  else self.state = 0 
  end
end

-- get "button label text" w and h
function Button:measure_lbl()
  self.label_w, self.label_h = gfx.measurestr(self.label)
end

-- draw button and update states
function Button:draw()
  if last_mouse_state == 0 and self.mouse_state == 1 then self.mouse_state = 0 end
  --if last_mouse_state == 0 and self.mouse_state == 1 then self.mouse_state = 0 end
  
  --gfx.x = self.x1;
  --gfx.y = self.y1;
  
  self.a = 0.6;
  self.x2 = self.rect.x + self.rect.w
  self.y2 = self.rect.y + self.rect.h

  -- Is mouse on button ?
  if gfx.mouse_x > self.rect.x and gfx.mouse_x < self.x2 and gfx.mouse_y > self.rect.y and gfx.mouse_y < self.y2 then
    
    -- Draw info/help text
    if help_text ~= "" then
      ----self.a = 1 -- highlight
      gfx.x = self.x2 + 10
      gfx.y = self.rect.y
      gfx.printf(self.rect.help_text)
    end
    
    -- Left mouse btn is pressed on button -> change states
    ----if gfx.mouse_cap == 1 and self.mouse_state == 0 and mouse_state == 0 then
    if last_mouse_state == 0 and gfx.mouse_cap & 1 == 1 and self.mouse_state == 0 then
      self.mouse_state = 1
      self:set_next_state()
      if self.onClick ~= nil then self:onClick() end
    end
  end
  
  -- Draw button rectangles and light, shadow etc. --
  -- Button is pressed down
  ----if self.mouse_state == 1 and mouse_state == 1 then
  if self.mouse_state == 1 or self.vis_state == 1 then
    self.a = self.a - 0.2;
    gfx.set(0.8,0,0.8,self.a)
    gfx.rect(self.rect.x, self.rect.y, self.rect.w, self.rect.h)
  -- Button is not pressed
  elseif self.mouse_state == 0 then
    gfx.set(1,0,1,self.a)
    gfx.rect(self.rect.x, self.rect.y, self.rect.w, self.rect.h)
    gfx.set(1,0,1,1)

    -- light - left
    gfx.line(self.rect.x, self.rect.y, self.rect.x, self.y2-1)
    gfx.line(self.rect.x+1, self.rect.y+1, self.rect.x+1, self.y2-2)
    -- light - top
    gfx.line(self.rect.x+1, self.rect.y, self.x2-1, self.rect.y)
    gfx.line(self.rect.x+2, self.rect.y+1, self.x2-2, self.rect.y+1)

    gfx.set(0.4,0,0.4,1)
    -- shadow - bottom
    gfx.line(self.rect.x+1, self.y2-1, self.x2-2, self.y2-1)
    gfx.line(self.rect.x+2, self.y2-2, self.x2-3, self.y2-2)
    -- shadow - right
    gfx.line(self.x2-1, self.y2-1, self.x2-1, self.rect.y+1)
    gfx.line(self.x2-2, self.y2-2, self.x2-2, self.rect.y+2)
  end

  -- Draw button label
  if self.label ~= "" then
    gfx.x = self.rect.x + math.floor(0.5*self.rect.w - 0.5 * self.label_w) -- center the label
    gfx.y = self.rect.y + 0.5*self.rect.h - 0.5*gfx.texth

    if self.mouse_state == 1 then gfx.y = gfx.y + 1 end
    gfx.set(1,1,1,self.a+0.2)
    gfx.printf(self.label)
    if self.mouse_state == 1 then gfx.y = gfx.y - 1 end
  end
end


--//////////
--// Main //
--//////////

function main()
  local ps = reaper.GetPlayState()
  
  -- Update "Play button" visual state
  if ps == 1 then
    play_btn.vis_state = 1 -- pressed down
  else
    play_btn.vis_state = 0 -- up
  end
  
   -- Update "Stop button" text
  if ps == 0 then
    stop_btn.label = "Stopped"
    stop_btn:measure_lbl()
  else
    stop_btn.label = "Stop"
    stop_btn:measure_lbl()
  end

  container_rect.w = gfx.w
  -- this should be called only when screen size has changed
  arrange_horizontal(container_rect, 5, {play_btn.rect, spacer1, stop_btn.rect})
  

  -- Draw buttons
  play_btn:draw()
  stop_btn:draw()

  -- Check left mouse btn state
  if gfx.mouse_cap & 1 == 0 then
    last_mouse_state = 0
  else last_mouse_state = 1 end
  
  gfx.update()
  if gfx.getchar() >= 0 then reaper.defer(main) end
end


--//////////
--// Init //
--//////////

function init()
  gfx.init("Play and Stop buttons", 200, 100)
  gfx.setfont(1,"Arial", 15)
  
  -- Create "instances" --
  -- parameters: Button(x1,y1,w,h,state_count,state,visual_state,lbl,help_text)
  play_btn = Button(10,20,80,20,2,0,0,"Play", "")
  -- play_btn is pressed -> call reaper.Main_OnCommand(1007, 0)
  play_btn.onClick = function ()
                       reaper.Main_OnCommand(1007, 0)
                     end
  
  stop_btn = Button(10,20,80,20,2,0,0,"Stop","")
  -- stop_btn is pressed -> call reaper.Main_OnCommand(1016, 0)
  stop_btn.onClick = function ()
                       reaper.Main_OnCommand(1016, 0)
                     end

  spacer1 = make_rect(20, 0, 10000)
  container_rect = Rect(0,100,0,20)
  
end

init()
main()
