local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
	S_slash = "\\"
else
	S_slash = "/"
end
package.path = package.path .. ";" .. script_path:match("(.*"..S_slash..")") .. "?.lua"
require("Functions")
require("Drum Variables")

function setStyle(input, instrument, length, tech, seq)
	if not input then return end
	local a_outEle =  drumEle(length)
	for i,v in ipairs(input) do
		local s_pos, pitch, time, beat, pat, pri, limb, vel, hit
		beat, pat = splitPos(v)
		s_pos = splitPos(v, beat+seq)
		if stringComp(instrument, "kick") then --if kick
			pri = 3
			pitch = getDrumMap(S_DrumLibrary, instrument)
			vel = I_velLimit
			limb = "RF"
		elseif stringComp(instrument, "snare") then --if snare
			pitch = getDrumMap(S_DrumLibrary, "SD Hit")
			pri = 1
			vel = I_velLimit
			limb = dualHHSnare(s_pos)
		elseif stringComp(instrument, "hh") then -- if hh
			-- set open HH
			if tech and tech ~= "" then
				if tech:find 'Open' and not tech:find 'Open3' then
					I_hhOpen = math.floor(127*I_hhOpenReduc/100)
					I_hhShank = 1
				elseif tech:find 'Fhalf' then
					if pat<3 then
						I_hhOpen = math.floor(127*I_hhOpenReduc/100)
					else
						I_hhOpen = math.floor(0*I_hhOpenReduc/100)
					end
					I_hhShank = 0
				elseif tech:find 'Shalf' then
					if pat>=3 then
						I_hhOpen = math.floor(127*I_hhOpenReduc/100)
					else
						I_hhOpen = math.floor(0*I_hhOpenReduc/100)
					end
					I_hhShank = 0
				elseif tech:find 'Open3' then
					if pat==3 then
						I_hhOpen = math.floor(127*I_hhOpenReduc/100)
					elseif pat == 4 then
						I_hhOpen = math.floor(40*I_hhOpenReduc/100)
					else
						I_hhOpen = math.floor(0*I_hhOpenReduc/100)
					end
					I_hhShank = 0
				else
					I_hhOpen = math.floor(0*I_hhOpenReduc/100)
					I_hhShank = 0
				end
			else
				I_hhOpen = math.floor(0*I_hhOpenReduc/100)
				I_hhShank = 0
			end
			if not I_hhredirect or I_hhredirect == 0 then
				pitch = getDrumMap(S_DrumLibrary, "HH Cl. Tip")+math.ceil(I_hhOpen*4/127)+(I_hhShank*5)
				if pitch >23 then pitch =23 end
			else
				pitch = getDrumMap(S_DrumLibrary, I_hhredirect)
			end
			-- set Limb
			if tech:find 'Alternate' or b_lasthhalt then
				if pat%2 == 0 then limb = "LH" else limb = "RH" end
				if tech:find 'Alternate' then B_lasthhalt = true else B_lasthhalt = false end
			else
				limb = "RH"
				B_lasthhalt = false
			end
			-- set velocity
			if tech:find 'Full' then
				vel = I_velLimit - (beat + seq - 1 + I_hhHeavyBeat) % 2 * I_hhHeavyAccent
			else
				vel = I_velLimit - (pat+1)%2*math.ceil(I_velLimit*0.17) - pat*math.ceil(I_velLimit*0.09) + math.ceil(I_hhOpen/127) * 10 - (beat * seq + I_hhHeavyBeat) % 2 * I_hhHeavyAccent
			end
			-- set Priority
			pri = 0
		else
			pitch = getDrumMap(S_DrumLibrary, instrument)
		end

		hit = drumHit(s_pos, pitch, vel, pri, time, limb, tech)
		a_outEle:addHit(hit)
	end
	return a_outEle
end

function getDrumMap(filename, techname)
	for a in io.lines(script_path:match("(.*"..S_slash..")").."Database"..S_slash..filename.." DrumMap.ini") do
		local note, name = a:match '(%d+)%s+(.*)'
		if name == techname then return tonumber(note) end
	end
end

function getStyle(instrument, style)
	if not instrument then error("getStyle: Invalid Instrument") end
	if not style then error("getStyle: Invalid style") end
	if stringComp(instrument, "kick") then instrument = "k"
		elseif stringComp(instrument, "snare") then instrument = "s"
		elseif stringComp(instrument, "hh") or stringComp(instrument, "hihat") then instrument = "hh"
		elseif stringComp(instrument, "ride") then instrument = "r"
	end
	local ins, name, content, p2, b2, t2, stylesub, pattern, beats, tech, ins2, rIndex, i, s
	for a in io.lines(script_path:match("(.*"..S_slash..")").."Database"..S_slash.."DrumGrooveType.ini") do
		ins, name, content = a:match '(%l+)(%L.+):%s*(.*)'
		if stringComp(ins, instrument) and stringComp(name, style) then
			if content:find '%d+b' then
				beats, pattern, tech = content:match '(%d+)b_(.*);(%w*)'
			else
				if content:find '%%' then --if random
					local random = {}
					for v in content:gmatch '[%w%+%s]+' do
						random[#random + 1] = v
					end
					rIndex = random[math.random(1, #random)]
					ins2, stylesub = rIndex:match '(%l+)(%L.+)'
					pattern, beats, tech = getStyle(ins2, stylesub)
				elseif content:find '%+' and not content:find '%%' then -- if comb
					for stylesub in content:gmatch '([%w%s]+)' do -- for every style between +
						i, s = string.match(stylesub, "(%l+)(%L.+)") -- match each substyle
						p2, b2, t2 = getStyle(i, s) -- get substyle
						if not pattern then pattern = p2 else pattern = pattern..p2 end
						if not beats then beats = b2 else beats = beats + b2 end
					end
				elseif content:find '%;' then
					stylesub, tech = content:match '([%w%s]+);(%w*)' -- get style;tech
					i, s = string.match(stylesub, "(%l+)(%L.+)") -- match style
					pattern, beats, t2 = getStyle(i, s)
					if not tech then
						if t2 then tech = t2 end
					else
						if t2 then tech = tech..t2 end
					end
				end
			end
			return pattern, tonumber(beats), tech
		end
	end
end

function dualHHSnare(pos)
	local altLimb
	if A_hhElement then
		for k, con in ipairs(A_hhElement) do
			for k2, _ in ipairs(con) do
				if A_hhElement:getPos(k, k2) == pos then
					local kl, k2l = A_hhElement:last(k, k2) -- get pos of last hit
					local tech1, tech = A_hhElement:getTech(k, k2), A_hhElement:getTech(kl, k2l)
					if tech1:find 'Alternate' or tech:find 'Alternate' then
						altLimb = true
					end
				end
			end
		end
	else return
	end
	if altLimb then return "RH" else return "LH" end
end