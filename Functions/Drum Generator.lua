local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
	S_slash = "\\"
else
	S_slash = "/"
end
package.path = package.path .. ";" .. script_path:match("(.*"..S_slash..")") .. "?.lua"
require("Note Functions")
require("Drum Grooves")
require("Drum Filters")
require("Drum Fills")

function getElement(instrument, style, seq)
	local pat, beat, a_inPairs
	local a_outSeq = drumSeq()
	local beats = 0
	while beats < seq do
		for i, v in ipairs(style) do
			pat, beat, tech = getStyle(instrument, v)
			a_inPairs =splitPat(pat)
			local ele = setStyle(a_inPairs, instrument, beat, tech, beats)
			a_outSeq:addEle(ele, (i-1)*beat)
			beats = beats + beat
		end
	end
	return a_outSeq
end

function setGroove()
	filters()
end

function getAccents()
	setAccents()
end
function getFills()
	setFills()
	addFillCrash()
end

function pushMIDI(list)
	local s_pos, k_pos, e_pos, k_end, pitch, vel, tech, early, s_pos2, vel2
	for i, v in pairs(list) do -- for each pattern
		local beat, pat = splitPos(v.pos)
		if beat==1 and pat ==1 then
			if B_lastEarly then
				early = getLength{"8"}
			else
				early = 0
			end
		else
			early = 0
			B_lastEarly = false
		end
		s_pos = getPos(v.pos)+math.random(0-I_timeRandom,I_timeRandom)+I_pocket+Indent-early+v.time
		e_pos = s_pos+getLength{"32"}
		pitch = v.pitch
		if not v.tech then v.tech = "" end
		if v.vel > 0 then
			if v.tech:find 'Drag' then
				pitch = getDrumMap(S_DrumLibrary, "SD Drag")
			end
			vel = math.ceil(v.vel + math.random(0-I_velRandom , I_velRandom))
			if vel > 127 then vel = 127 end
			reaper.MIDI_InsertNote(activeTake, 0, 0, s_pos, e_pos, 0, pitch, vel) -- output original note
			if v.tech:find 'Flam' then
				s_pos2 = s_pos + I_flamIndent
				vel2 = vel - 5
				vel = vel + 5
				reaper.MIDI_InsertNote(activeTake, 0, 0, s_pos2, s_pos2+getLength{"32"}, 0, pitch, vel2+math.random(0-I_velRandom, I_velRandom))
			elseif v.tech:find 'Triple' then
				s_pos2 = s_pos + getLength{"48"}
				vel2 = math.ceil(vel * I_velDep)
				reaper.MIDI_InsertNote(activeTake, 0, 0, s_pos2, s_pos2+getLength{"48"}, 0, pitch, vel2+math.random(0-I_velRandom, I_velRandom))
				s_pos2 = s_pos2 + getLength{"48"}
				vel2 = math.ceil(vel2 * I_velDep)
				reaper.MIDI_InsertNote(activeTake, 0, 0, s_pos2, s_pos2+getLength{"48"}, 0, pitch, vel2+math.random(0-I_velRandom, I_velRandom))
			elseif v.tech:find 'Double' then
				s_pos2 = s_pos + getLength{"32"}
				vel2 = math.ceil(vel * I_velDep)
				reaper.MIDI_InsertNote(activeTake, 0, 0, s_pos2, s_pos2+getLength{"32"}, 0, pitch, vel2+math.random(0-I_velRandom, I_velRandom))
			end
		end
	end
end

function applyLimit(input)
	for i, v in ipairs(input) do
		for j, v2 in ipairs(input) do
			if v.pos == v2.pos and i ~= j then
				if v.pri > v2.pri then
					v2.vel=0
				else
					v.vel=0
				end
			end
		end
	end
end

function buildLimbList(input, limb)
	local length
	if not length then length = #input end
	local list = drumSeq()
	for _, v in ipairs(input) do -- for each Seq
		for j,v2 in ipairs(v) do -- for each element
			for k, v3 in pairs(v2) do -- for each hit
				if v3.limb == limb then
					list:addEle(v3)
				end
			end
		end
	end
	return list
end

