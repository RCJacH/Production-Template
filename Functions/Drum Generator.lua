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


function getElement(instrument, style, seq)
	local pat, beat, a_inPairs
	local a_outSeq = drumSeq()
	local beats = 0
	local l=1
	while beats < seq do
		for i, v in ipairs(style) do
			pat, beat, tech = getStyle(instrument, v)
			a_inPairs =splitPat(pat)
			local ele = setStyle(a_inPairs, instrument, beat, tech, beats)
			a_outSeq:addEle(ele, (i-1)*beat)
			beats = beats + beat
		end
		l=l+1
	end
	return a_outSeq
end

function setGroove(instrument, list)
	-- apply filter
	-- apply limitation
end

function pushMIDI(list)
	local s_pos, k_pos, e_pos, k_end, pitch, vel, tech
	for i, v in pairs(list) do -- for each pattern
		local beat, pat = splitPos(v.pos)
		s_pos = getPos(v.pos)+math.random(-2,2)+I_pocket+Indent
		e_pos = s_pos+getLength{"32"}
		pitch = v.pitch
		if v.vel > 0 then
			vel = v.vel + math.random(-5 , 5)
			if vel > 127 then vel = 127 end
			reaper.MIDI_InsertNote(activeTake, 0, 0, s_pos, e_pos, 0, pitch, vel)
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

function addFillCrash()
	if B_EndCrash then
		local newHit
		local pos, pitch, vel, pri, limb, tech, randPitch, early
		if B_EarlyEnd then pos = "s"..seqLength..":"..3
		else pos = "s"..(seqLength + 1)..":"..1 end
		if B_RandomCrash then randPitch = math.random(0,4) else randPitch = 0 end
		pitch = getDrumMap(S_DrumLibrary, "Crash 1") + randPitch
		vel = I_velocity+5
		pri = 10
		limb = "RH"
		newHit = drumHit(pos, pitch, vel, pri, limb, "")
		a_RH:addEle(newHit)
	end
end
