-- define new class Drum Hit
drumHit = {}
drumHit.__index = drumHit

setmetatable(drumHit, {
  __call = function (cls, ...)
      local self = setmetatable({}, drumHit)
      self:new(...)
    return self
  end,
})

function drumHit:new(pos, pitch, vel, pri, time, limb, tech)
	if not pos then return end
	if not pitch then return end
	if not vel then vel = I_velocity end
	if not pri then pri = 0 end
	if not time then time = 0 end
	self.pos = pos
	self.pitch = pitch
	self.vel = vel
	self.pri = pri
	self.time = time
	self.limb = limb
	self.tech = tech
	return self
	end

	-- the : syntax here causes a "self" arg to be implicitly added before any other args
	function drumHit:setPos(val)
		self.pos = val
	end

	function drumHit:getPos()
		return self.pos
	end

	function drumHit:setPitch(val)
		self.pitch = val
	end

	function drumHit:getPitch()
		return self.pitch
	end

	function drumHit:setVel(val)
		self.vel = val
	end

	function drumHit:getVel()
		return self.vel
	end

	function drumHit:setLimb(val)
		self.limb = val
	end

	function drumHit:getLimb()
		return self.limb
	end

	function drumHit:setPri(val)
		self.pri = val
	end

	function drumHit:getPri()
		return self.pri
	end

	function drumHit:setTime(val)
		self.time = val
	end

	function drumHit:getTime()
		return self.time
end


-- setup Drum Element class
drumEle = {}
drumEle.__index = drumEle
setmetatable(drumEle, {
  __call = function (cls, ...)
      local self = setmetatable({}, drumEle)
      self:new(...)
    return self
  end,
})

function drumEle:new()
	function drumEle:addHit(input, num)
		local f = {}
		if type(input) == 'table' then
			if not num then num = #self + 1 end
		-- our new class is a shallow copy of the input class!
			for i, v in pairs(input) do
				f[i] = v
			end
			-- self._input = input
			self[num] = f
		else
			return
		end
	end
	function drumEle:removeHit(num)
		if not num then return
		elseif type(num) == 'number' then
			self[num]=nil
		end
	end
	return self
end

--
drumSeq = {}
drumSeq.__index = drumSeq

setmetatable(drumSeq, {
  __call = function (cls, ...)
      local self = setmetatable({}, drumSeq)
      self:new(...)
    return self
  end,
})

function drumSeq:new()
	function drumSeq:addEle(input, addbeat)
		local f = {}
		if type(input) == 'table' then
		-- our new class is a shallow copy of the input class!
			for i, v in pairs(input) do
				if i == "pos" then
					beat = splitPos(v)
					if addbeat then beat = beat + addbeat end
					local v2 = splitPos(v, beat)
					f[i] = v2
				else
					f[i] = v
				end
			end
			self[#self+1] = f
		else
			return
		end
	end
	function drumSeq:addHit(input, num)
		local f = {}
		if type(input) == 'table' then
			if not num then num = #self + 1 end
		-- our new class is a shallow copy of the input class!
			for i, v in pairs(input) do
				f[i] = v
			end
			-- self._input = input
			self[num] = f
		else
			return
		end
	end
	function drumSeq:removeHit(ele, hit)
		if not ele then return
		elseif type(ele) == 'number' then
			if hit and hit ~= 0 then
				table.remove(self[ele], hit)
			else
				table.remove(self, ele)
			end
		end
	end
	function drumSeq:exist(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit] then return true else return false end
		else
			if self[ele] then return true else return false end
		end
	end
	function drumSeq:last(ele, hit)
		local div, count = ele, hit
		if self[ele][hit-1] then
			return div, count
		else
			if self[ele-1][#self[ele-1]] then
				div = ele-1 
				count = #self[ele-1] return div, count end
		end
	end
	function drumSeq:getPos(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit].pos then return self[ele][hit].pos end
		else
			if self[ele].pos then return self[ele].pos end
		end
	end
	function drumSeq:setPos(ele, hit, input)
		if hit and hit ~= 0 then
			self[ele][hit].pos = input
		else
			self[ele].pos = input
		end
	end
	function drumSeq:getVel(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit].vel then return self[ele][hit].vel end
		else
			if self[ele].vel then return self[ele].vel end
		end
	end
	function drumSeq:setVel(ele, hit, input)
		if hit and hit ~= 0 then
			self[ele][hit].vel = input
		else
			self[ele].vel = input
		end
	end
	function drumSeq:getPitch(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit].pitch then return self[ele][hit].pitch end
		else
			if self[ele].pitch then return self[ele].pitch end
		end
	end
	function drumSeq:setPitch(ele, hit, input)
		if hit and hit ~= 0 then
			self[ele][hit].pitch = input
		else
			self[ele].pitch = input
		end
	end
	function drumSeq:getTime(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit].time then return self[ele][hit].time end
		else
			if self[ele].time then return self[ele].time end
		end
	end
	function drumSeq:setTime(ele, hit, input)
		if hit and hit ~= 0 then
			self[ele][hit].time = input
		else
			self[ele].time = input
		end
	end
	function drumSeq:getLimb(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit].limb then return self[ele][hit].limb end
		else
			if self[ele].limb then return self[ele].limb end
		end
	end
	function drumSeq:setLimb(ele, hit, input)
		if hit and hit ~= 0 then
			self[ele][hit].limb = input
		else
			self[ele].limb = input
		end
	end
	function drumSeq:getTech(ele, hit)
		if hit and hit ~= 0 then
			if self[ele][hit].tech then return self[ele][hit].tech end
		else
			if self[ele].tech then return self[ele].tech end
		end
	end
	function drumSeq:setTech(ele, hit, input)
		if hit and hit ~= 0 then
			self[ele][hit].tech = input
		else
			self[ele].tech = input
		end
	end
end

