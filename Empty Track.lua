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
--require("Empty GFX")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
Proj = 0

function doEmpty(track)
	emptyTrack(track, "Container: ")
end

function main()
	--msg_start() -- Display characters in the console to show you the begining of the script execution.
	reaper.Undo_BeginBlock2(Proj)

	local track = reaper.GetSelectedTrack(Proj, 0)
	doEmpty(track)

	reaper.Undo_EndBlock2(Proj, "Empty Track", 1)
	--msg_end() -- Display characters in the console to show you the end of the script execution.
end

	reaper.PreventUIRefresh(1) --Prevent UI refreshing. Uncomment it only if the script works.
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0, Proj) -- Save view
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0, Proj)-- Save loop
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_SAVE_CURSOR_POS_SLOT_8"), 0, Proj)--


main()

	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0, Proj) -- Restore loop
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_BR_RESTORE_CURSOR_POS_SLOT_8"), 0, Proj)-- Restore current position
	reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_WOL_RESTIREVIEWS5"), 0, Proj) -- Restore view
	-- clean up
	reaper.UpdateTimeline()
	reaper.UpdateArrange() -- Update the arrangement (often needed)
	reaper.TrackList_AdjustWindows(true)
	-- zoom in then out
	reaper.Main_OnCommandEx(1011, 0, Proj)
	reaper.Main_OnCommandEx(1012, 0, Proj)

	reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

