local root = {
	C       = "0",
	["C#"]  = "1",
	C3      = "1",
	Db      = "1",
	D       = "2",
	["D#"]  = "3",
	D3      = "3",
	Eb      = "3",
	E       = "4",
	F       = "5",
	["F#"]  = "6",
	F3      = "6",
	Gb      = "6",
	G       = "7",
	["G#"]  = "8",
	G3      = "8",
	Ab      = "8",
	A       = "9",
	["A#"]  = "-2",
	A3      = "-2",
	Bb      = "-2",
	B       = "-1",
}
local length = {
	["1b"] = 960,
	["h"]  = 1920,
	["q"]  = 960,
	["e"]  = 480,
	["s"]  = 240,
	["r"]  = 120,
	["k"]  = 60
}

local a_chordStruc = {1,3,5,7,9,11,13}
local scalePreset = {0, 2, 4, 5, 7, 9, 11}
scaleStruc = scalePreset

function getRoot(name)
  for _,v in ipairs(name) do
    local s = type(root[v]) == "function" and root[v]() or root[v]
    return tonumber(s)
  end
end

function getLength(name)
	for _,v in ipairs(name) do
		if string.find(v, "b") and v ~= "1b" then
			local b = string.match(v, "(%d+)b")
			return getLength{"1b"} * tonumber(b)
	    elseif type(tonumber(v))=="number" then
	    	return math.floor(getLength{"4b"}/v)
	    elseif string.find(v,"t") then
	    	if v == "t" then
	    		return math.floor(getLength{"1b"} / 3)
	    	else
	    		local d = string.match(v, "(%l)t")
	    		return math.floor(getLength{d} * 2 / 3)
	    	end
	    elseif string.find(v,"*") then
	    	local d = string.match(v, "*(%d)")
	    	return math.floor(getLength{"1b"}/d)
	    else
	    	local s = type(length[v]) == "function" and length[v]() or length[v]
			return tonumber(s)
		end
	end
end

function getScale(name)
  for _,v in ipairs(name) do
    local s = type(scaleStruc[v]) == "function" and scaleStruc[v]() or scaleStruc[v]
    return tonumber(s)
  end
end

function getDiv(input)
  local ev, i_div
  if string.match(input, "t") then
    ev = "t"
  elseif string.match(input, "*") then
  	ev = "*"
  else
    ev = "n"
  end
  i_div = getLength{input}
  return ev, i_div
end

function setScale(input)
	local output, index
	for i, v in pairs(input) do
		if v then
			index = (i*2-1)%7
			if index == 0 then index=7 end
			if v >=12 then output = v - 12 else output = v end
			scaleStruc[index]=output
		end
	end
end

function getInterval(input)
	local index, oct, output = 0,0,0
	if type(input)=="string" then input = tonumber(input, 16) end
	oct = math.floor(input/8)
	if input%7 == 0 then index=7 else index = input%7 end
		output = getScale{(index)}+oct*12
	return output
end


function getPos(pattern, timesigupper)
    if not pattern then return end
    if not timesigupper then timesigupper = 4 end
    local beat, pat, div, i_div = splitPos(pattern)
    local s_pos = ((pat - 1) + (beat -1) * timesigupper) * i_div
    return math.modf(s_pos), div, i_div
end

function splitPos(pattern, seq)
    if not pattern then return end
    local div, i_div, pat, beat, ev
    div, pat = pattern:match '(%l)(.*)'
    ev, i_div = getDiv(div)
    beat, pat = pat:match '(%d+):([%-%d]+)'
    if seq then
    	return div..seq..":"..pat
    else
    	return tonumber(beat), tonumber(pat), ev, tonumber(i_div), div
    end
end

function splitBeats(input)
  return getLength{input}
end


function calcBeat(input1, input2, op)
    local n1, n2
    n1 = string.gsub(input1, "b","")
    n1 = tonumber(n1)
    n2 = string.gsub(input2, "b","")
    n2 = tonumber(n2)
    if op == "+" then
        return n1 + n2.."b"
    elseif op == "-" then
        return n1 - n2.."b"
    elseif op == "*" then
        return n1 * n2 .."b"
    elseif op == "/" then
        return n1/n2 .. "b"
    elseif op == "%" then
        return n1%n2 .. "b"
    elseif op == "^" then
        return n1^n2 .. "b"
    end
end