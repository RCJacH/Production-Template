local a_fillElement = {"SD Hit", "FT 1", "Kick"}

function addFillCrash()
	if B_endCrash then
		local newHit
		local pos, pitch, vel, pri, time, limb, tech, randPitch, early
		if B_EarlyEnd then pos = "s"..I_seqLength..":"..3
		else pos = "s"..(I_seqLength + 1)..":"..1 end
		if B_RandomCrash then randPitch = math.random(0,4) else randPitch = 0 end
		pitch = getDrumMap(S_DrumLibrary, "Crash 1") + randPitch
		vel = I_velLimit+5
		pri = 10
		limb = "RH"
		time = I_groove
		newHit = drumHit(pos, pitch, vel, pri, time, limb, "")
		a_RH:addEle(newHit)
		B_lastEarly = true
	end
end

function setFills()
	local pos, pitch, vel, limb, pri, tech, ins
	local newHit
	if I_fillLength > 0 then
		local list = drumSeq()
		for i=0, I_fillLength-1 do
			local beat = I_seqLength - math.floor(i/timesiglower)
			local div = timesiglower - i % timesiglower
			pos = "s" .. beat..":"..div
			ins = a_fillElement[math.random(1, #a_fillElement)]
			pitch = getDrumMap(S_DrumLibrary, ins)
			vel = I_velFill - (i * I_velFD)
			pri = 8
			if ins == "Kick" then
				limb = "RF"
			else
				if i%2 == 0 then
					limb = "RH"
				else
					limb = "LH"
				end
			end
			time = 0
			newHit = drumHit(pos, pitch, vel, pri, time, limb, "")
			list:addHit(newHit)
		end
		if B_noGroove then
			local fbeat = I_seqLength - math.floor((I_fillLength-1)/timesiglower)
			local fdiv = (I_fillLength) % timesiglower
			local limblist = {a_LF,a_RF,a_LH,a_RH}
			for _, v in pairs(limblist) do -- for each limb
				local removelist = {}
				if v then
					for i, v2 in ipairs(v) do
						local pos, beat, pat
						pos = v:getPos(i)
						beat, pat = splitPos(pos)
						if beat >= fbeat then
							if pat > fdiv then
								removelist[#removelist +1] = i
							end
						end
					end
					for i, v2 in pairs(removelist) do
						v:removeHit(v2)
					end
				end
			end
		end
		fillSnareGhosts(I_fillLength, I_fillSnareGhosts)
		if B_inDrag then
			local beat = I_seqLength - math.floor((I_fillLength-1)/timesiglower)
			local div = I_fillLength % timesiglower
			if div == 0 then beat = beat-1 div = timesiglower end
			pos = "s" .. beat..":"..div
			pitch = getDrumMap(S_DrumLibrary, "SD Half Edge")
			vel = (I_velFill - I_fillLength * I_velFD) * 0.7
			pri = 1
			time = 0
			limb = "LH"
			newHit = drumHit(pos, pitch, vel, pri, time, limb, "Double")
			list:addHit(newHit)
		end
		for i, v in ipairs(list) do
			if list:getLimb(i) == "RH" then
				a_RH:addHit(v)
			elseif list:getLimb(i) == "LH" then
				a_LH:addHit(v)
			elseif list:getLimb(i) == "RF" then
				a_RF:addHit(v)
			end
		end
	end
end

function defineFillPitch()
	-- body
end

function fillSnareGhosts(length, random)
	if not random then random = 100 end
	local pos, pitch, vel, pri, time, limb, tech, rand, newHit
	list = drumSeq()
	for i = 2, math.floor(length/2) do
		rand = math.random(1, 100)
		if rand < random then
			local beat, div
			beat = I_seqLength - math.floor(i * 2 / timesiglower)
			div = timesiglower - (i * 2) % timesiglower
			pos = "s"..beat..":"..div
			pitch = getDrumMap(S_DrumLibrary, "SD Half Edge") -- "SD Half Edge"
			vel = 35 + math.random(-7, 7)
			pri = -1
			time = 0
			limb = "LH"
			if math.random()>=0.5 then tech = "Triple" else tech = "Drag" end
			newHit = drumHit(pos, pitch, vel, pri, time, limb, tech)
			list:addHit(newHit)
			a_LH:addHit(newHit)
		end
	end
end