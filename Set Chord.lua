local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")
require("split-build Chord Name")
require("Note Functions")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.
msg_clean()

function setChord()
  reaper.Undo_BeginBlock()
  take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, 0))
  if take ~= nil then
    retval, i_midiNotesCount = reaper.MIDI_CountEvts(take)
    for i=i_midiNotesCount-1, 0, -1 do
      retval, sel, muted, s, e, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
      reaper.MIDI_DeleteNote(take, i)
    end
    for i=0, 7, 1 do
      if a_chordNotes[i]~=nil then
      i_setRoot = getRoot{Root}
      i_outNote = 3*12+i_setRoot+a_chordNotes[i]
      reaper.MIDI_InsertNote(take, 0, 0, start_pos, end_pos, 0, i_outNote, 127)
      end
    end
  end -- if take ~= nil
  -- clean up
  reaper.UpdateTimeline()
  reaper.UpdateArrange()
  reaper.TrackList_AdjustWindows(true)
  -- zoom in then out
  reaper.Main_OnCommand(1011, 0)
  reaper.Main_OnCommand(1012, 0)
  --
  reaper.Undo_EndBlock("Set Chord", 0)
end

retval, s_chordName = reaper.GetUserInputs("Root", 1, "Chord Name", "")
splitChord()
buildChord()
start_pos = 240*4
end_pos = 240*8
setChord()
