local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "Functions/?.lua"
end
require("Item Functions")
require("Functions")

function findSetTrackName(name, newname, add_or_remove)
	local track, retval, s_currentName
	if not newname then newname = "" end
	for i=0, reaper.CountTracks(Proj) -1 do
		track = reaper.GetTrack(Proj, i)
		retval, s_currentName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
		if string.find(s_currentName, name) then
			if newname == "" then
				return i
			else
				if add_or_remove == 1 then -- add item
					name = s_currentName.." "..name
				elseif add_or_remove == -1 then -- remove item
					name = string.gsub(s_currentName, name, "")
				end
				reaper.GetSetMediaTrackInfo_String(track, "P_NAME", newname, true) -- set new name
			end
		end
	end
end

function getTrack(input, sel)
	local trackID, track
	trackID = findSetTrackName(input)
	if trackID then track = reaper.GetTrack(Proj, trackID) end
	if sel == 1 then reaper.Main_OnCommandEx(40939+trackID, 0, Proj) end -- Command select Track ID
	return trackID, track
end

function getTrackItemsInfo(track)
	local item, name, pos, len
	local track = reaper.GetTrack(Proj, track)
	local database = {}
	local retval, s_measure, s_timeSig ,s_beats, l_measure, l_timeSig, l_beats
	if reaper.CountTrackMediaItems(track) < 1 then return end
	for i=0, reaper.CountTrackMediaItems(track)-1 do
		item = reaper.GetTrackMediaItem(track, i)
		name = getSetItemName(item)
		retval, s_measure, s_timeSig, s_beats = reaper.TimeMap2_timeToBeats(Proj, reaper.GetMediaItemInfo_Value(item, "D_POSITION"))
		retval, l_measure, l_timeSig, l_beats = reaper.TimeMap2_timeToBeats(Proj, reaper.GetMediaItemInfo_Value(item, "D_LENGTH"))
		database[#database+1] = {name, s_beats, l_beats}
	end
	return database
end

function createItem(s_pos, e_pos, name, empty)
	if not empty then empty = 0 end
	s_pos = convertTimeBeats(s_pos,"")
	e_pos = convertTimeBeats(e_pos,"")
	reaper.GetSet_LoopTimeRange2(Proj, 1,1,s_pos, e_pos,1);	-- define the time range for the empty item
	reaper.SetEditCurPos2(Proj, s_pos, 0, 0)
	if empty == 0 then 
		reaper.Main_OnCommandEx(40214, 0, Proj) -- insert MIDI item
	elseif empty == 1 then
		reaper.Main_OnCommandEx(40142, 0, Proj) -- insert empty item
	end
	item = reaper.GetSelectedMediaItem(Proj,0) -- get the selected item
	--reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", (0 + 256 * 0 + 65536 * 255)|16777216)
	if name then 
		if empty == 0 then
 			getSetItemName(item, name)
 		elseif empty ==1 then
 			getSetItemNotes(item, name)
 		end
 	end
	return item
end


function emptyTrack(track, keepWord)
	local item, items, name, s_pos
	local list = {}
	items = getTrackItems(track, keepWord)
	for k, v in ipairs(items) do
		item = v
		name,s_pos = getNamePos(item)
		reaper.DeleteTrackMediaItem(track,item)
		list[tonumber(s_pos)] = name
	end
	table.sort(list)
	return list
end

function getTrackItems(track, keepWord, dir)
	local itemCount,item, name
	local list = {}
	if not dir then dir = 1 end
	if not keepWord then keepWord = "nil" end
	itemCount =reaper.CountTrackMediaItems(track)
	if itemCount ~= 0 then
		if dir == 1 then
			for i=0, itemCount-1 do
				item = reaper.GetTrackMediaItem(track, i)
				name = getNamePos(item)
				if not string.find(name, keepWord) then
					list[#list +1] = item
				end
			end
		else
			for i=itemCount-1,0,-1 do
				item = reaper.GetTrackMediaItem(track, i)
				name = getNamePos(item)
				if not string.find(name, keepWord) then
					list[#list +1] = item
				end
			end
		end
	end
	return list
end

function getItemInfoList(itemlist, search)
	local name, s_pos, e_pos
	local list = {}
	for k, v in pairs(itemlist) do
		name,s_pos,e_pos = getNamePos(v)
		if not search or string.find(name, search)then
			list[#list+1] = {name, tonumber(s_pos), tonumber(e_pos)}
		end
	end
	return list
end