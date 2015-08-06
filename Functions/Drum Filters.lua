function filters()
	delEarlyEnd()
	if A_kickElement then kickFilter() end
end

function kickFilter()
	k_skip3()
	k_skipKickonSnare()
end

function k_skip3()
	if B_kickskip3 and A_kickElement then
		for i,v in ipairs(A_kickElement) do
			for j, v2 in ipairs(v) do 
				local pos = A_kickElement:getPos(i, j)
				local beat = splitPos(pos)
				if beat%4 == 3 then
					A_kickElement:setVel(i, j, 0)
				end
			end
		end
	end
end

function k_skipKickonSnare()
	if B_skipKickonSnare and A_snareElement then
		for i,v in ipairs(A_kickElement) do
			for j, v2 in ipairs(v) do 
				for k, con in ipairs(A_snareElement) do
					for k2=1, #con do
						if A_snareElement:getPos(k, k2) == A_kickElement:getPos(i, j) then
							A_kickElement:setVel(i, j, 0)
						end
					end
				end
			end
		end
	end
end


function delEarlyEnd()
	if B_EarlyEnd then
		local limblist = {a_LF,a_RF,a_LH,a_RH}
		for _, v in pairs(limblist) do -- for each limb
			if v then
				for i, v2 in ipairs(v) do
					local pos, beat, pat
					pos = v:getPos(i)
					beat, pat = splitPos(pos)
					if beat == I_seqLength and pat > 3 then
						v:setVel(i, 0, 0)
					end
				end
			end
		end
	end
end

function limitSnare()
	local removelist = {}
	for i, v in ipairs(a_RH) do --for each hit
		for j, v2 in ipairs(a_LH) do
			if v:getPos(i) == v2:getPos(j) and v:getPitch(i) == v2:getPitch(i) then
				if v:getPri(i) > v2:getPri(j) then
					removelist[#removelist+1] = j
				else
					removelist[#removelist+1] = i
				end
			end
		end
	end
	for i, v in ipairs(removelist) do
		w:removeHit(v)
	end
end