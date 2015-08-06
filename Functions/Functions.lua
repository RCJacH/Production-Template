local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
    S_slash = "\\"
else
    S_slash = "/"
end
package.path = package.path .. ";" .. script_path:match("(.*"..S_slash..")") .. "?.lua"

sortListPos = function(a, b) return a[2]>b[2] end
sortPos = function(a,b)
local beat1, pat1 = splitPos(a.pos)
local beat2, pat2 = splitPos(b.pos)
    if beat1 ~= beat2 then
        return beat1<beat2
    else
        return pat1<pat2
    end
end
math.randomseed(tostring(os.time()):reverse():sub(1, 6))

function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

function convertTimeBeats(input, pos)
	if not pos then
		local retval, measures, cml, beats = reaper.TimeMap2_timeToBeats(Proj, input)
		return beats, measures, cml
	else
		if type(pos) == "number" then
			return reaper.TimeMap2_beatsToTime(Proj, input, pos - 1) -- return time of beat input of bar pos
		else -- if pos = ""
			return reaper.TimeMap2_beatsToTime(Proj, input)
		end
	end
end

function tableMerge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == "table" then
    		if type(t1[k] or false) == "table" then
    			tableMerge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[tonumber(k)] = v
    	end
    end
    return t1
end

function splitPat(input, timesigupper)
    if not timesigupper then timesigupper = 4 end
    local a_listIn, a_listOut, a_listOut2 = {},{},{}
    for div, pat in string.gmatch(input, "([%l%*]*)([%x%d]+)") do
        a_listIn[#a_listIn + 1] = {div, pat}
    end
    for _, v in ipairs(a_listIn) do
        for pair in string.gmatch(v[2],"[%x%d]") do 
            a_listOut[#a_listOut + 1] = {v[1], pair}
        end
    end
    local div, pat, string
    for i, v in ipairs(a_listOut) do
        div = getDiv(v[1])
        pat = v[2]
        if pat == "0" then pat = nil end
        if pat then -- if number > 0
            for _, v2 in pairs(A_Rhythms[div][pat]["notes"]) do -- match rhythm sequence
                string = tostring(i)..":"..math.modf(v2)
                a_listOut2[#a_listOut2 + 1] = v[1]..string
            end
        end
    end
    return a_listOut2
end

function build_patData(filename)
    local database = {}
    for a in io.lines(filename) do
        local content = {}
        local d, i, con = a:match '(.+)(%x):(.*)'
        if not database[d] then database[d] = {} end
        if not database[d][i] then database[d][i] = {} end
        for s in string.gmatch(con, "(%d+);-")do
            content[#content+1] = s
        end
        database[d][i] = {notes = content}
    end
    return database
end

function build_bassData(filename)
    local database = {}
    for a in io.lines(filename) do
        local content = {}
        local d, i, con = a:match '(.+)(%x):(.*)'
        if not database[d] then database[d] = {} end
        if not database[d][i] then database[d][i] = {} end
        for s, l, p, v in string.gmatch(con, "(%d+)%|(%w-)%|(%W-%d*)%|(%d*);-") do
            if p == "" then p = 0 end
            if v == "" then v = 100 end
            if l == "" then l = nil end
            content[#content+1] = {s_pos = s, len = l, pitch = p, vel=v}
        end
        database[d][i] = {notes = content}
    end
    return database
end

function stringComp(input, comp)
    if not input or not comp then return end
    if input == comp or string.lower(input) == comp then return true else return false end
end


function getbinhandler (op1, op2, event)
    return metatable(op1)[event] or metatable(op2)[event]
end

function add_event (op1, op2)
    local o1, o2 = tonumber(op1), tonumber(op2)
    if o1 and o2 then  -- both operands are numeric?
        return o1 + o2   -- '+' here is the primitive 'add'
    else  -- at least one of the operands is not numeric
        local h = getbinhandler(op1, op2, "__add")
        if h then
            -- call the handler with both operands
            return (h(op1, op2))
        else  -- no handler available: default behavior
            --error(···)
        end
    end
end