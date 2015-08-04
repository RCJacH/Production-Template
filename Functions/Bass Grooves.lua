--[[
 * ReaScript Name: Bass　Grooves
 * Description: A script to generate bass grooves for each input
 * Instructions: This is an utility file for Set Bass Pattern track
 * Author: RCJacH
 * Author URl: http://RCJacH.github.io
 * Repository: 
 * Repository URl:
 * File URl: https:
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
require("Functions")

i_outputNoteCount=0
I_muteP = 86
I_lastPitch = 0
I_pocket = -2
I_separation = 20
I_kwIndent = 30
I_staccato = getLength{"32"}
I_velocity = 100
IndentBeat = 2
Indent = getLength{IndentBeat.."b"}
local a_preConPairs, a_techPairs, a_altPairs, a_patPairs, a_mute, a_alt, a_outPats, a_outMutes, a_tech = {},{},{},{},{},{},{},{},{}
local i_beats, i_length, i_beatsPPQ
local techName = {["mute"]=86, ["o"]=79, ["s"]=33,["l"]=34,["i"]=83,["h"]=81,["g"]=34, ["x"]=77}
local harmonics = {40, 45, 47, 50, 52, 55, 56, 57, 59, 61, 62, 64, 66, 67, 69, 71, 74}

function splitRhythm(input)
  local beats, PreCon, pat, mute, tech, alt = string.match(input, "(%d%l)_(.*)_(.*);(%w*);(.*)_(.*)$")
  i_beats, i_beatsPPQ = tonumber(string.match(beats, "%d"))
  i_length = splitBeats(beats)
  a_preConPairs = splitPreCon(Precon)
  a_patPairs = splitPat(pat)
  a_mute = splitPat(mute)
  a_mute = setMute(a_mute)
  a_tech = setTech(tech)
  a_altPairs = splitAlt(alt)
  a_alt = setAlt(a_altPairs)
  setPreCon()
  a_outPats, a_outMutes = setPat(a_patPairs, a_mute, a_tech, a_alt)
  return a_outPats, a_outMutes
end

function setPreCon()

end

function setPat(a_inPairs, a_inMute, a_inTech, a_inAlt)
	local i_nil,i_count
	if not a_inMute then a_inMute = {} end
	if not a_inTech then a_inTech = {} end
	if not a_inAlt  then a_inAlt  = {} end
	local a_outPats =  {}
	-- set nil counts
	for i=1, #a_inPairs do
		if a_inPairs[i][2] == "0" then i_nil = i_nil+1 end
	end
	local s_pos, len, e_pos, vel, div, i_div
	for i, v in ipairs(a_inPairs) do -- how many beat pairs
		s_pos, div, i_div = getPos(v) -- s_pos = pos of pattern + number of Pattern
		i_count= s_pos/i_div
		if (i_count<(i_beats-4/3) or i_count<(2*960/i_div)-1/3) then --pos of measure
			vel = I_velocity+3
		else
			vel = I_velocity-((s_pos-1)%2*5)
		end
		table.insert(a_outPats, {s_pos,e_pos,0, vel, tech}) -- s_pos, e_pos, pitch, vel
	end
	for i=1, #a_outPats do -- loop output
		-- set note e_pos
		s_pos = a_outPats[i][1]
		if i ~= #a_outPats then -- if not last note
			len = a_outPats[i+1][1]- s_pos
		else -- if last note of pattern
			len = i_length-s_pos
		end
		if s_pos+len >= i_length then e_pos = s_pos+len-20 else e_pos = s_pos + len end
		for i=1, #a_inMute do -- on technique
			if s_pos < a_inMute[i] and e_pos > a_inMute[i] then e_pos = a_inMute[i]+20 end
		end
		a_outPats[i][2]=e_pos
		--set technique
		if a_inTech ~= {} and a_inTech[i] then -- if not bypass
			if a_inTech[i] == "" then a_inTech[i] = "."
			elseif a_inTech[i] == "o" and a_outPats[i-1] then
				a_outPats[i][1] = a_outPats[i][1] -10
				a_outPats[i-1][2] = a_outPats[i][1] + getLength{"32"}/2 -- overlap HOPO
			end
			a_outPats[i][5]=a_inTech[i]
		end
		--set alt
		if a_inAlt ~= {} and a_inAlt[i] then
			a_outPats[i][3] = a_inAlt[i]
		end
	end
	for i=1, #a_inMute do -- set mute notes
		local b_noteExist= false
		for j=1, #a_outPats do
			if a_inMute[i]==a_outPats[j][1] then
				b_noteExist = true
				a_outPats[j][3] = "x"
			end
		end
		if not b_noteExist then
			table.insert(a_outMutes, {a_inMute[i],a_inMute[i]+getLength{"32"},"mute", 80})
		end
	end
	return a_outPats, a_outMutes
end

function setMute(input)
	local database, index={},0
	for i=1, #input do
		if i ~= "0" then
			local div, i_div = getDiv(input[i][1])
			local pat=input[i][2]
			if pat ~= "0" then
				for j=1, #A_Rhythms[div][pat]["notes"] do
					index=index+1
					database[index] = (A_Rhythms[div][input[i][2]]["notes"][j]-1)*i_div+(i-1)*getLength{'1b'}
				end
			end
		end
	end
	return database
end

function setTech(input, a_inPairs)
  local database = {} -- initiate database
  for div in string.gmatch(input, "[%l%.%d]") do

  	if type(tonumber(div, 16)) ~= "nil" then
  		for i=1, div do
  			database[#database+1] = "."
  		end
  	else
	    database[#database+1] = div
  	end
  end
  return database
end

function setAlt(input)
	local database = {}
	local i_preNote, i_nextNote, interval, i_dir, i_note, interval = 0, 0, "", 0, 0, 0
	if input and #input >= 1 then
		for i=1, #input do
			interval = input[i][1]
			i_note = input[i][2]
			if interval then
				if type(tonumber(interval, 16)) ~= "nil" then -- if numeral alt
					interval = getInterval(interval)
				else -- if ornamentation
					if input[i-1] and input[i-1][1] then i_preNote = tonumber(input[i-1][1], 16) end
					if input[i+1] and input[i+1][1] then i_nextNote = tonumber(input[i+1][1], 16) end
					if interval == "P" or interval == "p" then -- if passing note
						if i_preNote ~= 0 and i_nextNote ~= 0 then -- if alt note before and note after
							if i_preNote > i_nextNote then --if descending
								i_dir = -1
							elseif i_preNote < i_nextNote then --if ascending
								i_dir = 1
							end
							local steps = math.abs(i_preNote - i_nextNote)
							if steps == 2 then -- if scale step
								interval = getInterval(i_nextNote-i_dir)
							elseif steps == 1 then -- if chromatic
								if interval == "P" then
									interval = getInterval(i_preNote)+i_dir
								elseif interval =="p" then
									interval = getInterval(i_nextNote)-i_dir
								end
							elseif steps == 0 then
								if interval == "P" then
									interval = getInterval(i_preNote+1)
								elseif interval =="p" then
									interval = getInterval(i_preNote-1)
								end
							else --if no step
								if interval == "P" then
									interval = getInterval(i_nextNote-i_dir)
								elseif interval =="p" then
									interval = getInterval(i_nextNote+i_dir)
								end
							end
						else -- if partial note
							if i_preNote ~= 0 and i_nextNote == 0 then -- if only pre
								i_a = interval
								if interval == "P" then
									interval = getInterval(i_preNote+1)
								elseif interval =="p" then
									interval = getInterval(i_preNote-1)
								end
							elseif i_preNote == 0 and i_nextNote ~= 0 then -- if only post
								if interval == "P" then
									interval = getInterval(i_nextNote-1)
								elseif interval =="p" then
									interval = getInterval(i_nextNote+1)
								end
							else
								interval = 1
							end
						end
					end
					if interval == "N" or interval == "n" then -- if neighbour note
						if i_preNote ~= 0 then -- if as long as preNote exist
							if i_nextNote ~= 0 and math.abs(i_preNote - i_nextNote) ~= 0 then
								if interval == "N" then -- apply to all notes
									interval = getInterval(i_preNote+1)
								elseif interval =="n" then
									interval = getInterval(i_preNote-1)
								end
							else
								if interval == "N" then -- apply to all notes
									interval = getInterval(i_preNote)+1
								elseif interval =="n" then
									interval = getInterval(i_preNote)-1
								end
							end								
						elseif i_preNote ==0 and i_nextNote ~= 0 then -- if only post
							if interval == "N" then
								interval = getInterval(i_nextNote)-1
							elseif interval =="n" then
								interval = getInterval(i_nextNote)+1
							end
						else
							interval = 1
						end
					end
					if interval == "S" or interval == "s" then
						interval = "S"
					end
				end
				if i_note == -1 and interval ~= 0 then
					interval = (12 - interval)*i_note
				end
			else -- if interval == "."
				interval = 0
			end
			database[#database +1] = interval
		end
	end
	return database
end

function splitPreCon(input)
  if input ~= "xx" or input then

  else
    input = nil
  end
  return input
end


function splitAlt(input)
	local a_dataOri, a_dataPairs ={},{}
	local i_dir,interval = 0,""
	if input ~= "xx" or input ~= "x" then
		for d, interval in string.gmatch(input, "([ud]?)([%w%.UD])") do
			if stringComp(d, "u") then
				i_dir = 1
			elseif stringComp(d, "d") then
				i_dir = -1
			elseif i_dir==0 then
				i_dir =1
			else
				i_dir = i_dir
			end
			a_dataOri[#a_dataOri + 1] = {interval, i_dir}
		end
		for _, v in ipairs(a_dataOri) do
			for interval in string.gmatch(v[1],"([%x+pPnNsS%.])") do
				if interval == "." then interval = nil end -- . = no change
				a_dataPairs[#a_dataPairs+1]={interval, v[2]}
			end
		end
	else
		input = nil
	end
	return a_dataPairs
end

function getGroove(rhythm)
	A_Rhythms = build_patData(script_path:match("(.*"..S_slash..")").."Database"..S_slash.."Rhythm Patterns.ini")
	local a_Pats, a_Techs = splitRhythm(rhythm)
	A_Rhythms = nil
	return a_Pats, a_Techs
end

function getBassTech(name)
	for _,v in ipairs(name) do
		local s = type(techName[v]) == "function" and techName[v]() or techName[v]
		return tonumber(s)
	end
end

function pushMIDI(take, input)
	local s_pos, k_pos, e_pos, k_end, pitch, vel, tech
	local a_pats, a_mute = getGroove(input)
	for i = 1, #a_pats do -- for each note in pattern
		local b_noTech = false
		s_pos = a_pats[i][1]+math.random(-5,5)+I_pocket+Indent
		k_pos = s_pos - I_kwIndent
		e_pos = a_pats[i][2]-I_separation + math.random(-20,0)+Indent
		k_end = k_pos+getLength{"32"}
		pitch = a_pats[i][3]
		if type(tonumber(pitch)) == "nil" then
			if pitch == "S" then
				if I_lastPitch then
					pitch = I_lastPitch
				end
			elseif pitch == "x" then
				pitch = getBassTech{pitch}
			else pitch = 0
			end
		else
			pitch = pitch + i_outRoot		
		end
		vel = a_pats[i][4]+math.random(-5,5)
		tech = a_pats[i][5]
		if tech and tech ~= "." and tech ~= "" then
			local len = e_pos - s_pos
			if tech == "h" then
				if not harmonics[pitch] then
					b_noTech = true
					pitch = pitch +12
				end
			elseif tech == "s" then
				vel = vel+ 10
			elseif tech == "t" then
				b_noTech = true
				vel = vel - 10
				e_pos = s_pos+ I_staccato + math.random(-20,0)
			end
			if not b_noTech then reaper.MIDI_InsertNote(take, 0, 0, k_pos, k_end, 0, getBassTech{tech}, 127) end
		end
		if i == 1 then
			reaper.MIDI_InsertNote(take, 0, 0, k_pos, k_end, 0, getRoot{s_Root}+91, 127)
		end
		if vel > 127 then vel = 127 end
		reaper.MIDI_InsertNote(take, 0, 0, s_pos, e_pos, 0, pitch, vel)
		I_lastPitch = pitch
	end -- for a_pats
	for i = 1, #a_mute do
		s_pos = a_mute[i][1]+Indent
		e_pos = a_mute[i][2]+Indent
		pitch = getBassTech{a_mute[i][3]}
		vel = a_mute[i][4]
		reaper.MIDI_InsertNote(take, 0, 0, s_pos, e_pos, 0, pitch, vel)
	end
end -- function

function defineItemName(input)
	local s_newName = ""
	if not string.match(input, "%^") then
		getSetItemName(activeItem, input)
	end
end