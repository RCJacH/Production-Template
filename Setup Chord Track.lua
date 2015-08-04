--[[
 * ReaScript Name: Setup Chord Track
 * Description: This script sets up a chord track by inserting empty items and adding notes to them, also changing the color of the item according to the chord functions.
 * Instructions: Here is how to use it. (optional)
 * Author: RCJacH
 * Author URl: 
 * Repository: 
 * Repository URl: 
 * File URl: 
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URl: 
 * Version: 0.1
 * Version Date: YYYY-MM-DD
 * REAPER: 5.0 RC10
 * Extensions: SWS/S&M 2.6.0 (optional)
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
require("Track Functions")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
-- <==== DEBUGGING -----
Proj = 0
i_a = {}

function setup()
	local chordOri, userChord, trackID, key, track	

	-- YOUR CODE BELOW
	reaper.Main_OnCommandEx(40297, 0, Proj) -- deselect all tracks
	trackID, track = getTrack("ChordTrack", 1)
	retval, chord_Count = reaper.GetUserInputs("How Many Chords?", 1, "Chords", "")
	if not chord_Count or chord_Count == "" then return end
	userChord = inputChord(chord_Count)
	chordOri = emptyTrack(track) -- delete all items and get their name.pos
	if userChord then tableMerge(chordOri,userChord) end
	setChord(chordOri)

	-- LOOP THROUGH REGIONS
	--[[
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if bIsrgnOut == true then
				-- ACTION ON REGIONS HERE
			end
			i = i+1
		end
	until iRetval == 0
	--]]
end

function main() -- local (i, j, item, take, track)
	--msg_start() -- Display characters in the console to show you the begining of the script execution.

	reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0, Proj) -- Save view
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0, Proj)-- Save loop
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_SAVE_CURSOR_POS_SLOT_8"), 0, Proj)-- Save current position

	setup()

	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0, Proj) -- Restore loop
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_RESTORE_CURSOR_POS_SLOT_8"), 0, Proj)-- Restore current position
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_WOL_RESTIREVIEWS5"), 0, Proj) -- Restore view
	reaper.Main_OnCommandEx(40289, 0, Proj)
	reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
	reaper.UpdateTimeline()
	reaper.UpdateArrange() -- Update the arrangement (often needed)

	--msg_end() -- Display characters in the console to show you the end of the script execution.

end

function inputChord(numbers)
	if not numbers or numbers == "" then numbers = 1 end
	local retval, chord_string, chordName, length, s_pos, time, measure, beat
	local list = {}
	for i=1, numbers do
		retval, chord_string = reaper.GetUserInputs("Chord "..i, 2, "Chords,s_pos", "")
		if chord_string == "" then return end
		chordName, time = string.match(chord_string, "(.*),(.*)")
		measure, beat = string.match(time, "(%d*):(%d*)")
		if not measure then measure = time end
		if not beat then beat = 0 else beat = string.gsub(beat, ":", "")end
		s_pos = convertTimeBeats(convertTimeBeats(tonumber(beat), tonumber(measure)))
		list[tostring(s_pos)] = chordName
	end
	return list
end


function setChord(index)
	local name, s_pos, e_pos
	 outList = {}
	for k,v in pairs(index) do
		-- reaper.ShowConsoleMsg(k)
		-- reaper.ShowConsoleMsg("\n")
		name = v
		s_pos = k
		outList[#outList+1]={name,s_pos}
	end
	table.sort(outList, sortListPos)
	for i=1, #outList do
		name = outList[i][1]
		s_pos = outList[i][2]
		if i > 1 then
			e_pos = outList[i-1][2]
		else
			e_pos = s_pos+8
		end
		createItem(s_pos, e_pos, name, 1)
	end
end
reaper.Undo_BeginBlock2(Proj) -- Begining of the undo block. Leave it at the top of your main function.
main() -- Execute your main function
reaper.Undo_EndBlock2(Proj, "Setup Chord Track", 1) -- End of the undo block. Leave it at the bottom of your main function.