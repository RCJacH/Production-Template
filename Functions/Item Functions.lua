local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "Functions/?.lua"
end
require("Functions")

function getSetItemName(item, name, add_or_remove)
	if reaper.GetMediaItemNumTakes(item) < 1 then return end
	local take = reaper.GetActiveTake(item)
	if take then
		local current_name = reaper.GetTakeName(take) -- get item name
		if name then -- if any input in name field
			if add_or_remove == 1 then -- add item
				name = current_name.." "..name
			elseif add_or_remove == -1 then -- remove item
				name = string.gsub(current_name, name, "")
			end
			reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", name, true) -- set new name
			return name, take
		else
			return current_name, take -- return old name
		end
	end
end

function getSetItemNotes(item,newnote)
	local retval, str = reaper.GetSetItemState(item, "")
	local chunk, chunk2, newchunk, afternote, b_hasNotes, note
	b_hasNotes = string.find(str, "<NOTES*") 
	if b_hasNotes then -- there are notes already
		chunk, note, chunk2 = string.match(str, "(.*<NOTES\n|)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
		if newnote then
			newchunk = chunk .. newnote .. chunk2
			reaper.GetSetItemState(item, newchunk)
		else
			return note
		end
	else --there are still no notes
		chunk,chunk2 = string.match(str,"(.*IID%s%d+)(.*)")
		if newnote then 
			newchunk = chunk .. "\n<NOTES\n|" .. newnote .. "\n>\nIMGRESOURCEFLAGS 2" .. chunk2
			reaper.GetSetItemState(item, newchunk)
		end
	end
end

function deselect()
	local num = reaper.CountSelectedMediaItems(Proj)
	if not num or num < 1 then return end
	local i = 0
	while i < num do
		reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(Proj, i), false)
		i = i + 1
	end
	num = reaper.CountSelectedMediaItems(Proj)
end

function reselect( items )
	local i, item
	for i,item in pairs(items) do
		reaper.SetMediaItemSelected(item, true)
	end
end


function get_set_envelope(take, envelope_name)
	local env = ""--new_chunk = ""
  	--if "take envelope" doesn't exist -> create envelope
	if reaper.GetTakeEnvelopeByName(take, envelope_name) == 0 then
		env = reaper.GetTakeEnvelopeByName(take, envelope_name)
		if envelope_name == "Volume" then Main_OnCommand(NamedCommandLookup("_S&M_TAKEENV1"), 0) end -- show take volume envelope
		if envelope_name == "Pan" then Main_OnCommand(NamedCommandLookup("_S&M_TAKEENV2"), 0) end -- show take pan envelope
		if envelope_name == "Mute" then Main_OnCommand(NamedCommandLookup("_S&M_TAKEENV3"), 0) end -- show take mute envelope
		if envelope_name == "Pitch" then Main_OnCommand(NamedCommandLookup("_S&M_TAKEENV10"), 0) end -- show take pitch envelope
	end
	-- now it should exist -> get source take's "take envelope pointer"
	if env == reaper.GetTakeEnvelopeByName(take, envelope_name) then
		local retval, str=reaper.GetSetEnvelopeState(env, "")
	end
	return str
end

function getActiveTake()
	activeItem =		reaper.GetSelectedMediaItem(Proj, 0)
    activeTake =        reaper.GetActiveTake(activeItem)
    takeVol =           reaper.GetMediaItemTakeInfo_Value(activeTake, "D_VOL")
    takePan =           reaper.GetMediaItemTakeInfo_Value(activeTake, "D_PAN")
    takePlayrate =      reaper.GetMediaItemTakeInfo_Value(activeTake, "D_PLAYRATE")
    takePitch =         reaper.GetMediaItemTakeInfo_Value(activeTake, "D_PITCH")
    takeChannelmode =   reaper.GetMediaItemTakeInfo_Value(activeTake, "I_CHANMODE")
    takeVolEnv =		get_set_envelope(activeTake, "Volume")
    takePanEnv =		get_set_envelope(activeTake, "Pan")
    takeMuteEnv =       get_set_envelope(activeTake, "Mute")
    takePitchEnv =      get_set_envelope(activeTake, "Pitch")
    takeName = 			getSetItemName(activeItem)
    itemVol =           reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_VOL")
    itemMute =          reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "B_MUTE")
    itemLock =          reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "C_LOCK")
    itemLoopsrc =       reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "B_LOOPSRC")
    itemFadeinshape =   reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "C_FADEINSHAPE")
    itemFadeoutshape =  reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "C_FADEOUTSHAPE")
end



function getNamePos(item)
	if not place then place = 1 end
	if not item then return end
	local name, s_pos, e_pos
	name = getSetItemName(item)
	if not name then name = getSetItemNotes(item) end
	s_pos = convertTimeBeats(reaper.GetMediaItemInfo_Value(item, "D_POSITION"))
	e_pos = s_pos + convertTimeBeats(reaper.GetMediaItemInfo_Value(item, "D_LENGTH"))
	return name, s_pos, e_pos
end

function getGroupID(list)
	local IDlist = {}
	for _, v in pairs(list) do
		IDlist[#IDlist +1] = reaper.GetMediaItemInfo_Value(v, "I_GROUPID")
	end
	return IDlist
end