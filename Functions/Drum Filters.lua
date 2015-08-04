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
		local list = {A_RH,A_LH,A_LF,A_RF}
		for _, v in pairs(list) do -- for each limb
			if v then
				for i, v2 in ipairs(list) do
					pos = v2:getPos(i)
				end
			end
		end
	end
end