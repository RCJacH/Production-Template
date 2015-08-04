gfx.init("Lua Sandbox",200,200)
reaper.atexit(gfx.quit)

BGCOL=0xFFFFFF

function setcolor(i)
  gfx.set(((i>>16)&0xFF)/0xFF, ((i>>8)&0xFF)/0xFF, (i&0xFF)/0xFF)
end


---- editbox ----

editbox={
  x=40, y=100, w=120, h=20, l=4, maxlen=12,
  fgcol=0x000000, fgfcol=0x00FF00, bgcol=0x808080,
  txtcol=0xFFFFFF, curscol=0x000000,
  font=1, fontsz=14, caret=0, sel=0, cursstate=0,
  text="", 
  hasfocus=false
}

function editbox_draw(e)
  setcolor(e.bgcol)
  gfx.rect(e.x,e.y,e.w,e.h,true)
  setcolor(e.hasfocus and e.fgfcol or e.fgcol)
  gfx.rect(e.x,e.y,e.w,e.h,false)
  gfx.setfont(e.font) 
  setcolor(e.txtcol)
  local w,h=gfx.measurestr(e.text)
  local ox,oy=e.x+e.l,e.y+(e.h-h)/2
  gfx.x,gfx.y=ox,oy
  gfx.drawstr(e.text)
  if e.sel ~= 0 then
    local sc,ec=e.caret,e.caret+e.sel
    if sc > ec then sc,ec=ec,sc end
    local sx=gfx.measurestr(string.sub(e.text, 0, sc))
    local ex=gfx.measurestr(string.sub(e.text, 0, ec))
    setcolor(e.txtcol)
    gfx.rect(ox+sx, oy, ex-sx, h, true)
    setcolor(e.bgcol)
    gfx.x,gfx.y=ox+sx,oy
    gfx.drawstr(string.sub(e.text, sc+1, ec))
  end 
  if e.hasfocus then
    if e.cursstate < 8 then   
      w=gfx.measurestr(string.sub(e.text, 0, e.caret))    
      setcolor(e.curscol)
      gfx.line(e.x+e.l+w, e.y+2, e.x+e.l+w, e.y+e.h-4)
    end
    e.cursstate=(e.cursstate+1)%16
  end
end

function editbox_getcaret(e)
  local len=string.len(e.text)
  for i=1,len do
    w=gfx.measurestr(string.sub(e.text,1,i))
    if gfx.mouse_x < e.x+e.l+w then return i-1 end
  end
  return len
end

function editbox_onmousedown(e)
  e.hasfocus=
    gfx.mouse_x >= editbox.x and gfx.mouse_x < editbox.x+editbox.w and
    gfx.mouse_y >= editbox.y and gfx.mouse_y < editbox.y+editbox.h    
  if e.hasfocus then
    e.caret=editbox_getcaret(e) 
    e.cursstate=0
  end
  e.sel=0 
end

function editbox_onmousedoubleclick(e)
  local len=string.len(e.text)
  e.caret=len ; e.sel=-len
end

function editbox_onmousemove(e)
  e.sel=editbox_getcaret(e)-e.caret
end

function editbox_onchar(e, c)
  if e.sel ~= 0 then
    local sc,ec=e.caret,e.caret+e.sel
    if sc > ec then sc,ec=ec,sc end
    e.text=string.sub(e.text,1,sc)..string.sub(e.text,ec+1)
    e.sel=0
  end
  if c == 0x6C656674 then -- left arrow
    if e.caret > 0 then e.caret=e.caret-1 end
  elseif c == 0x72676874 then -- right arrow
    if e.caret < string.len(e.text) then e.caret=e.caret+1 end
  elseif c == 8 then -- backspace
    if e.caret > 0 then 
      e.text=string.sub(e.text,1,e.caret-1)..string.sub(e.text,e.caret+1)
      e.caret=e.caret-1
    end
  elseif c >= 32 and c <= 125 and string.len(e.text) < e.maxlen then
    e.text=string.format("%s%c%s", 
      string.sub(e.text,1,e.caret), c, string.sub(e.text,e.caret+1))
    e.caret=e.caret+1
  end
end

---- generic mouse handling ----

mouse={}

function OnMouseDown()
  editbox_onmousedown(editbox)    
  mouse.down=true ; mouse.capcnt=0
  mouse.ox,mouse.oy=gfx.mouse_x,gfx.mouse_y
end

function OnMouseDoubleClick()
  if editbox.hasfocus then editbox_onmousedoubleclick(editbox) end
end

function OnMouseMove()
  if editbox.hasfocus then editbox_onmousemove(editbox) end  
  mouse.lx,mouse.ly=gfx.mouse_x,gfx.mouse_y
  mouse.capcnt=mouse.capcnt+1
end

function OnMouseUp()
  mouse.down=false
  mouse.uptime=os.clock()
end

---- runloop ----

function runloop()
  gfx.clear=BGCOL
   
  if gfx.mouse_cap&1 == 1 then
    if not mouse.down then
      OnMouseDown()      
      if mouse.uptime and os.clock()-mouse.uptime < 0.25 then 
        OnMouseDoubleClick()
      end
    elseif gfx.mouse_x ~= mouse.lx or gfx.mouse_y ~= mouse.ly then
      OnMouseMove() 
    end
  elseif mouse.down then 
    OnMouseUp() 
  end
      
  local c=gfx.getchar()  
  if editbox.hasfocus then editbox_onchar(editbox, c) end  

  editbox_draw(editbox)

  gfx.update()  
  if c >= 0 and c ~= 27 then reaper.defer(runloop) end
end


gfx.setfont(1,"verdana",editbox.fontsz)

reaper.defer(runloop)