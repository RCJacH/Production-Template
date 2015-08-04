local a_chordPreset = {0,4,7,10,14,17,21}
local a_chordNotes = {}
local Root, Chord, AddTone, extention,alternation= "","","","",""
local b_hd, b_dim, b_minor, b_sus4, b_sus2, b_major7, b_7alt,b_lyd,b_11th,b_6chord = false,false,false,false,false,false,false,false,false,false
local i_alt5,i_alt9,i_alt13=0,0,0

function splitChord(input)
  if input and input ~= "" then
    Root, Chord = string.match(input, "(%u%#)(.*)",1)--detect Root with #s
    if not Root then
     Root, Chord = string.match(input, "(%ub)(.*)",1)--detect Root with bs
      if not Root then
        Root, Chord = string.match(input, "(%u)(.*)",1)--detect Root with no alt
      end
    end
    addTone = string.match(Chord, "add(.-%d+)")
    if not addTone then
    extention, alternation = string.match(Chord, "(%d+)(.*)")
      if not extention then
        extention, alternation = string.match(Chord, "(%d+)")
      end
    else
      extention = nil
    end
    if string.match(Chord, "m7b5", 1) or string.match(Chord, "m9b5", 1) then
     b_hd=true else b_hd=false end
    if string.match(Chord, "o", 1) or string.match(Chord, "dim",1 ) then
     b_dim=true else b_dim=false end
    if not b_hd and not b_dim and (string.match(Chord, "m",1) or string.match(Chord,"-", 1))then
     b_minor = true else b_minor = false end
    if string.match(Chord, "sus4") then
     b_sus4=true b_minor=false else b_sus4=false end
    if string.match(Chord, "sus2") then
     b_sus2=true b_minor=false else b_sus2=false end
    if string.match(Chord, "Maj") or string.match(Chord,"j") then
     b_major7 = true else b_major7 = false end
    if string.match(Chord, "7alt",1) then
     b_7alt=true else b_7alt=false end
    if string.match(Chord, "#11") or string.match(Chord, "lyd") then
     b_lyd=true else b_lyd=false end
    if string.match(Chord, "11") or b_lyd then
     b_11th=true else b_11th=false end
    if extention and string.match(extention, "6") then
     b_6chord = true else b_6chord = false end
    if alternation then
      s_alt5 = string.match(alternation, ".5")
      if s_alt5 then
        if string.match(s_alt5, "(.)5") == '#' then
          i_alt5 = 1 
        elseif string.match(s_alt5, "(.)5") == 'b' then
          i_alt5 = -1 
        end
      else
        i_alt5 = 0
      end
      s_alt9 = string.match(alternation, ".9")
      if s_alt9 then
        if string.match(s_alt9, "(.)") == '#' then
          i_alt9 = 1 
        elseif string.match(s_alt9, "(.)") == 'b' then
          i_alt9 = -1 
        end
      else
        i_alt9 = 0
      end
      s_alt13 = string.match(alternation, ".13")
      if s_alt13 then
        if string.match(s_alt13, "(.)") == 'b' then
          i_alt13 = -1 
        end
      else
        i_alt13 = 0
      end
    else
      i_alt5=0
      i_alt9=0
      i_alt13=0
    end
    Root, a_chordNotes = buildChord()
    return Root, a_chordNotes
  else
    return
  end
end

function buildChord()
  a_chordNotes[1] = a_chordPreset[1]
  a_chordNotes[2] = a_chordPreset[2]
  a_chordNotes[3] = a_chordPreset[3]+i_alt5
  a_chordNotes[4] = a_chordPreset[4]
  a_chordNotes[5] = a_chordPreset[5]+i_alt9
  a_chordNotes[6] = a_chordPreset[6]
  a_chordNotes[7] = a_chordPreset[7]+i_alt13
  -- Check Range ====>
  if (extention=="7" or extention=="6") and not s_alt9 and not s_alt13 then
    a_chordNotes[5] = nil
    a_chordNotes[6] = nil
    a_chordNotes[7] = nil
  elseif extention=="76" then
    a_chordNotes[5] = nil
    a_chordNotes[6] = nil
  elseif extention=="9" or extention=="69" or s_alt9 then
    a_chordNotes[6] = nil
    a_chordNotes[7] = nil
  elseif addTone == "9" or addTone == "2" then
    a_chordNotes[4] = nil
    a_chordNotes[6] = nil
    a_chordNotes[7] = nil
  elseif extention=="11" or b_lyd then
    a_chordNotes[7] = nil
  elseif addTone == "11" or addTone == "#11" or addTone == "#4" then
    a_chordNotes[4] = nil
    a_chordNotes[5] = nil
    a_chordNotes[7] = nil
  elseif extention=="13" or s_alt13 then
    if not b_11th then a_chordNotes[6]=nil end
  else
    a_chordNotes[4] = nil
    a_chordNotes[5] = nil
    a_chordNotes[6] = nil
    a_chordNotes[7] = nil
  end
  -- <==== Check Range
  -- Build Chord Notes ====>
  if b_hd then a_chordNotes[2]=3 a_chordNotes[3]=6 end
  if b_dim then a_chordNotes[2]=3 a_chordNotes[3]=6 a_chordNotes[4]=9 end
  if b_minor then a_chordNotes[2]=3 end
  if b_major7 then a_chordNotes[4]=11 end
  if b_6chord then a_chordNotes[4]=9 end
  if b_sus2 then a_chordNotes[2]=2 end
  if b_sus4 then a_chordNotes[2]=5 end
  if b_lyd then a_chordNotes[6]=18 end
  -- <==== Build Chord Notes
  return Root, a_chordNotes
end

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end