--[[
 * ReaScript Name: Setup Bass Track
 * Description: Generate Bass track based on chord track and containers
 * Instructions: Setup Chord Track and Container, then run this script
 * Author: RCJacH
 * Author URl: http://RCJacH.github.io
 * Repository:
 * Repository URl:
 * File URl:
 * Licence: GPL v3
 * Forum Thread:
 * Forum Thread URl:
 * Version:
 * Version Date:
 * REAPER: 5
 * Extensions: SWS/S&M 2.6.0
 --]]
 
--[[
 * Changelog:
 --]]
-- ----- DEBUGGING ====>
local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")
require("Split-Build Chord Name")
require("Bass Grooves")
require("Track Functions")
--require("Empty GFX")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.
local retval
msg_clean()
-- <==== DEBUGGING -----

local bassItems = {}

Proj = 0
function setRhythm(item, input)
  local take = reaper.GetActiveTake(item)
  if take then
    local retval, i_midiNotesCount = reaper.MIDI_CountEvts(take)
    if i_midiNotesCount then
      for i=i_midiNotesCount-1, 0, -1 do
        local retval, sel, muted, s, e, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        reaper.MIDI_DeleteNote(take, i)
      end
    end
    i_outRoot = 12*4+getRoot{s_Root} -- get interger of out pitch
    pushMIDI(take, input)
    getSetItemName(item, "^"..s_rhythm)
    reaper.Main_OnCommandEx(40919, 0, Proj) -- set mix to always mix
  else
    return
  end -- if take

end



function main()
  reaper.Undo_BeginBlock2(Proj)
  local chordTrack, chordTrackID, chordList, chordInfo, bassTrack, bassTrackID, containerList, containerInfo
  chordTrackID, chordTrack = getTrack("ChordTrack")
  chordList = getTrackItems(chordTrack)
  chordInfo = getItemInfoList(chordList)
  bassTrackID, bassTrack = getTrack("Bass", 1)
  emptyTrack(bassTrack, "Container: ")
  containerList = getTrackItems(bassTrack)
  containerInfo = getItemInfoList(containerList, "Container:")
  for i, v in ipairs(containerInfo) do
    groupID = reaper.GetMediaItemInfo_Value(containerList[i], "I_GROUPID")
    for j, v2 in ipairs(chordInfo) do
      if v2[2] >= v[2] and v2[2]< v[3] then
        name = v2[1]
        rhythm = string.gsub(v[1], "Container: ", "")
        if not string.find(rhythm, ";") then rhythm = rhythm..";;_" end
        s_pos = v2[2]
        if v2[3] <= v[3] then
          e_pos = v2[3]
        else e_pos = v[3] end
        bassItems[#bassItems+1] = {name, rhythm, s_pos, e_pos, groupID}
      end
    end
  end
  if bassItems == {} then return end
  for _, v in ipairs(bassItems) do
    s_pos = tonumber(v[3])
    e_pos = tonumber(v[4])
    s_Root, a_chordNotes = splitChord(v[1])
    setScale(a_chordNotes)
    pattern, mute, tech, alt = string.match(v[2],"(%w*);(.*);(.*)_(.*)")
    if not mute then mute = "" end
    if not tech then tech = "" end
    if not alt then alt = "" end
    --retval, s_rhythm = reaper.GetUserInputs("Rhythm Pattern",4,"Pattern, Mute, Tech, Alt","s10,s")
    --local pattern, mute, tech, alt = string.match(s_rhythm, "(.*),(.*),(.*),(.*)")
    i_beats = math.modf(e_pos-s_pos)
    s_rhythm = i_beats.."b_x_"..pattern..";"..mute..";"..tech.."_"..alt
    if s_Root and s_rhythm then
      item = createItem(s_pos-IndentBeat, e_pos, s_rhythm, 0)
      reaper.SetMediaItemInfo_Value(item, "I_GROUPID", v[5])
      setRhythm(item, s_rhythm) -- Execute your main function
    end
  end

  -- s_rhythm = "x_sEB8A;s006;s.s.o4t_..8p5.8851"
  -- nil variable
  s_Root, a_chordNotes = nil, nil
  -- clean up
  reaper.UpdateTimeline()
  reaper.UpdateArrange() -- Update the arrangement (often needed)
  reaper.TrackList_AdjustWindows(true)
  -- zoom in then out
  reaper.Main_OnCommandEx(1011, 0, Proj)
  reaper.Main_OnCommandEx(1012, 0, Proj)
  
  reaper.Undo_EndBlock2(Proj, "Set Bass Groove", 1)
end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0, Proj) -- Save view
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0, Proj) -- Save loop
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_SAVE_CURSOR_POS_SLOT_8"), 0, Proj)-- Save current position

main()


reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0, Proj) -- Restore loop
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_RESTORE_CURSOR_POS_SLOT_8"), 0, Proj)-- Restore current position
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_WOL_RESTIREVIEWS5"), 0, Proj) -- Restore view
--reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

--msg_end() -- Display characters in the console to show you the end of the script execution.



--a = reaper.GetTakeEnvelopeByName(reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, 0)), "Volume")
--b= reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0),"D_LENGTH")
--retval, c,c2,c3 = reaper.TimeMap2_timeToBeats(1, b)
--b = reaper.GetEnvelopePointByTime(a, 1)
--retval, valueOutOptional, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(a, c2, 44100, 0)
