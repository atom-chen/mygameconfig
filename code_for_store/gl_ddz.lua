local util = {}

function util.copyTab(st)  
    local tab = {}  
    for k, v in pairs(st or {}) do  
        if type(v) ~= "table" then  
            tab[k] = v  
        else  
            tab[k] = util.copyTab(v)  
        end  
    end  
    return tab
end

function util.merge(originTb, exTb)
	if not exTb or not next(exTb) then return originTb end
	
	for k, v in pairs(exTb) do
		table.insert(originTb, v)
	end

	return originTb
end

function util.removeTable(originTb, exTb)
	for k, v in pairs(exTb) do
		for i = 1, #originTb do
			if originTb[i] == v then
				table.remove(originTb, i)
			end
		end
	end
	return originTb
end

-- 1.无参调用，产生[0, 1)之间的浮点随机数。
-- 2.一个参数n，产生[1, n]之间的整数。
-- 3.两个参数，产生[n, m]之间的整数。
function util.getRandom(n, m)
	--math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	if not n and not m then
		return math.random()
	elseif n ~= nil and m == nil then
		return math.random(n)
	elseif n ~= nil and m ~= nil then
		return math.random(n, m)
	end
end

function util.printTable(tb, headStr)
    if not headStr then headStr = '' end
    print(headStr..'{')
    for k, v in pairs(tb or {}) do  
    	io.write(tostring(k))
        if type(v) ~= "table" then  
            print(headStr..'  '..v) 
        else  
            util.printTable(v, headStr..'  ')  
        end
    end
    print(headStr..'}')
end

function util:serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then
    	if type(name) == 'string' then
    		tmp = tmp .. name .. " = " 
        end
    	-- elseif type(name) == 'number' then
    	-- 	tmp = tmp .. '['..name .. "] = " 
    	-- end
 	end
    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. self:serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
            --tmp =  tmp .. self:serializeTable(v, k, skipnewlines, depth + 1) .. "," .. ("")
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end
    return tmp
end

local logic = {}
logic.cardHashTab = {}
--logic.hashCardAmount = 0
--logic.preHashCardData = {}
local CT_ERROR =				0	--错误
local CT_SINGLE	=				1 	--单牌
local CT_DOUBLE	=				2 	--对子
local CT_THREE =				3 	--三张
local CT_SINGLE_LINE =			4 	--顺子
local CT_DOUBLE_LINE =			5 	--连对
local CT_THREE_LINE	=			6 	--飞机
local CT_THREE_LINE_TAKE_ONE =	7 	--飞机带单(包括三张带单牌)
local CT_THREE_LINE_TAKE_TWO =	8 	--飞机带对
local CT_FOUR_LINE_TAKE_ONE	=	9	--炸弹带单牌
local CT_FOUR_LINE_TAKE_TWO	=	10	--炸弹带对子
local CT_BOMB_CARD =			11 	--炸弹
local CT_MISSILE_CARD =			12	--王炸

function logic.getCardLogicValue(card)
	assert(type(card) ~= 'table')
	return math.floor(card / 10)
end

function logic.maxInCards(kv, cards)
	for k, v in pairs(cards) do
		if kv < logic.getCardLogicValue(v) then
			return false
		end
	end
	return true
end

function logic.getHumanVisible(card)
	local v = logic.getCardLogicValue(card)

	v = v + 2

	local color
	if card % 10 == 0 then
		color = '♥'
	elseif card % 10 == 1 then
		color = '♠'
	elseif card % 10 == 2 then
		color = '♣'
	elseif card % 10 == 3 then
		color = '♦'
	end
   
	local str = ''
	if v < 11 then
		str = string.format('%s%s', tostring(v), color)
	elseif v == 11 then
		str = 'J'..color
	elseif v == 12 then
		str = 'Q'..color
	elseif v == 13 then
		str = 'K'..color
	elseif v == 14 then
		str = 'A'..color
	elseif v == 15 then
		str = '2'..color
	elseif v == 16 then
		str = 'JokerS'
	elseif v == 17 then
		str = 'JokerB'
	end

	return str
end

function logic.getCardsWeightSum(cards)
	local weight = 0
	for k, v in pairs(cards) do
		weight = weight + logic.getCardLogicValue(v)
	end

	return weight
end

function logic.getCardsWeightSpecial(cards, amount)
	local weight = 0

	local hashTab = logic.getCardsHashTab(cards)

	for k, v in pairs(hashTab) do
		if #v == amount then
			weight = weight + logic.getCardLogicValue(v[1]) * amount
		end
	end

	return weight
end

function logic.getCardsWeight(cards, cardType)
	--logic.printCards(cards)
	local cardType = cardType or logic.getCardType(cards)

	if cardType == CT_SINGLE then
		return 1 * logic.getCardLogicValue(cards[1])
	elseif cardType == CT_DOUBLE then
		return 2 * logic.getCardLogicValue(cards[1])
	elseif cardType == CT_THREE then
		return 3 * logic.getCardLogicValue(cards[1])
	elseif cardType == CT_SINGLE_LINE then
		return logic.getCardsWeightSum(cards) * 2
	elseif cardType == CT_DOUBLE_LINE then
		return logic.getCardsWeightSum(cards) * 4
	elseif cardType == CT_THREE_LINE then
		return logic.getCardsWeightSpecial(cards, 3) * 6
	elseif cardType == CT_THREE_LINE_TAKE_ONE then
		local baseWeight = logic.getCardsWeightSpecial(cards, 3)
		return baseWeight * 7
	elseif cardType == CT_THREE_LINE_TAKE_TWO then
		local baseWeight = logic.getCardsWeightSpecial(cards, 3)
		return baseWeight * 7

	elseif cardType == CT_FOUR_LINE_TAKE_ONE then
		local baseWeight = logic.getCardsWeightSpecial(cards, 4)
		return baseWeight * 8
	elseif cardType == CT_FOUR_LINE_TAKE_TWO then
		local baseWeight = logic.getCardsWeightSpecial(cards, 4)
		return baseWeight * 8
	elseif cardType == CT_BOMB_CARD or cardType == CT_MISSILE_CARD then
		return 4 * logic.getCardLogicValue(cards[1]) * 10
	end
end

function logic.getCardsNode(cards, cardType, keyValue)
	-- if cards ~= nil and #cards > 1 then
		
	-- end
	table.sort(cards, function(card1, card2)
		return card1 < card2
	end)

	local ct, kv = logic.getCardType(cards)
	return {keyValue = kv, amount = #cards, cardType = ct, weight = logic.getCardsWeight(cards, ct), cards = cards}
end

function logic.printMachineCards(cards, log, tailStr)
	if not cards then return end
	local buff = ''
	for i = 1, #cards do
		buff = string.format("%s%s,", buff, tostring(cards[i]))
	end

	if not log then
		print(buff)
	else

		LOG_DEBUG(buff..(tailStr or ""))
	end
end

function logic.printCards(cards, log, tailStr)
	if not cards then return end
	local buff = ''
	for i = 1, #cards do
		buff = buff..logic.getHumanVisible(cards[i])..' '
	end

	if not log then
		print(buff)
	else

		LOG_DEBUG(buff..(tailStr or ""))
	end
end

function logic.printCardsList(list)
	for k, v in pairs(list) do
		logic.printCards(v)
	end
end

function logic.printNodes(list, headStr)
	local headStr = headStr or ''
	print('start-----'..headStr)
	for k, v in pairs(list) do
		logic.printCards(v.cards)
	end
	print('end-----'..headStr)
end

function logic.analyseCards(cards)
	--print('msg:----------------------------------logic.analyseCards')
	--luadump(cards)
	local temp = {}
	for k, v in pairs(cards) do
		local v_key = logic.getCardLogicValue(v)
		if temp[v_key] == nil then
			temp[v_key] = {keyValue = v_key, amount = 1, cards = {v}}
		else
			temp[v_key].amount = temp[v_key].amount + 1
			table.insert(temp[v_key].cards, v)
		end
	end

	local result = {single = {}, double = {}, three = {}, four = {}}
	for i = 1, 15 do
		local v = temp[i]
		if v then
			if v.amount == 1 then
				--if not result.single then result.single = {} end
				result.single.cardType = CT_SINGLE
				table.insert(result.single, v)
			elseif v.amount == 2 then
				--if not result.double then result.double = {} end
				result.double.cardType = CT_DOUBLE
				table.insert(result.double, v)
			elseif v.amount == 3 then
				--if not result.three then result.three = {} end
				result.three.cardType = CT_THREE
				table.insert(result.three, v)
			elseif v.amount == 4 then
				--if not result.four then result.four = {} end
				result.four.cardType = CT_BOMB_CARD
				table.insert(result.four, v)
			end
		end
	end

	return result
end

local function is_sequence(cards, keeptailhead)
	if not cards or not next(cards) then return false end
	local tailwrong = false
	local headwrong = false
	for i = 1, #cards - 1 do
		if cards[i] + 1 ~= cards[i+1] or cards[i+1] == 13 or cards[i+1] == 14 or cards[i+1] == 15 then
			if keeptailhead then
				return false
			end

			if #cards > 2 then
				if i == 1 then
					headwrong = true
				elseif i == #cards - 1 then
					if headwrong then
						return false
					end
					tailwrong = true
				else
					return false
				end
			else
				return false
			end
		end
	end
	if not keeptailhead and tailwrong then
		return true, cards[1]
	else
		return true, cards[1]
	end
end

function logic.getCardType(cards)
	local count = #cards
	local nums = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local ocards = {}
	local tcards = {}
	local scards = {}
	local sxcards = {}
	local fcards = {}
	local j = 1
	for i=1,count do
		j = math.floor(cards[i]/10)
		nums[j] = nums[j] + 1
	end
	for j=1,15 do
		if nums[j] == 1 then
			table.insert(ocards, j)
		elseif nums[j] == 2 then
			table.insert(tcards, j)
		elseif nums[j] == 3 then
			table.insert(scards, j)
        	table.insert(sxcards, j)
		elseif nums[j] == 4 then
			table.insert(fcards, j)
          	table.insert(sxcards, j)
		end
	end
	if nums[14] == 1 and nums[15] == 1 and count == 2 then
		return CT_MISSILE_CARD, 15
	end
	if count == 1 then
		return CT_SINGLE, ocards[1]
	end
	if count == 2 and #tcards == 1 then
		return CT_DOUBLE, tcards[1]
	end
	if count == 3 and #scards == 1 then
		return CT_THREE, scards[1]
	end
	if count == 4 and #fcards == 1 then
		return CT_BOMB_CARD, fcards[1]
	end
	if #scards == 1 and count == 4 then
		return CT_THREE_LINE_TAKE_ONE, scards[1]
	end
	if #scards == 1 and count == 5 and #tcards == 1 then
		return CT_THREE_LINE_TAKE_TWO, scards[1]
	end
	if (#fcards == 1 and count == 6) then
		if #tcards == 1 or #ocards == 2 then
			return CT_FOUR_LINE_TAKE_ONE, fcards[1]
		end
	end
	if count == 8 then
		if (#fcards == 1 and #tcards == 2) then
			return CT_FOUR_LINE_TAKE_TWO, fcards[1]
		elseif #fcards == 2 then
			return CT_FOUR_LINE_TAKE_TWO, fcards[2]
		end
	end

	if #sxcards > 1 then
		local temp, kv = is_sequence(sxcards)
		if temp then
			if (#sxcards - 1) * 4 == count then

				return CT_THREE_LINE_TAKE_ONE, kv
			end
		end
		temp, kv = is_sequence(sxcards, true)
		-- if  then
		if temp and count == 4 * #sxcards then
			-- print(111111111111111)
			return CT_THREE_LINE_TAKE_ONE, kv
		end
	end

	if #scards > 1 then
		local temp, kv = is_sequence(scards, true)
		-- and is_sequence(scards) then
		if temp then
			if count == 5 * #scards then
				if #scards == (2 * #fcards + #tcards) then--(#scards == #tcards) or (#scards == 2 * #fcards) or (#scards == (2 * #fcards + #tcards)) then
					return CT_THREE_LINE_TAKE_TWO, kv
				end
			end
			if #scards * 3 == count then
				return CT_THREE_LINE, kv
			end
		end
	end
	if #ocards > 4 and #ocards == count then
		local temp, kv = is_sequence(ocards, true)
		if temp then
			return CT_SINGLE_LINE, kv
		end
	end

	if #tcards > 2 and #tcards * 2 == count then
		local temp, kv = is_sequence(tcards, true)
		if temp then
			return CT_DOUBLE_LINE, kv
		end
	end
	return CT_ERROR, 0
end

function logic.getCardsHashTab(cards)
	-- if #logic.preHashCardData == #cards then
	-- 	for 
	-- 	return logic.cardHashTab
	-- end

	local cardHashTab = {}
	--local tempTb = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		if not cardHashTab[key] then
			cardHashTab[key] = {v}
		else
			table.insert(cardHashTab[key], v)
		end
	end
	--logic.hashCardAmount = #cards

	return cardHashTab
end

function logic.getAllSingleStrictly(cards, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)
	
	for k, v in pairs(hashTab) do
		if k > preKeyValue then
			table.insert(result, logic.getCardsNode({v[1]}, CT_SINGLE, k))
		end
	end

	return result
end

function logic.getAllSingle(cards, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)
	
	for k, v in pairs(hashTab) do
		if k > preKeyValue and #v <= 3 then
			if k == 14 or k == 15 then
				if not (hashTab[14] and hashTab[15]) then
					table.insert(result, logic.getCardsNode({v[1]}, CT_SINGLE, k))
				end
			else
				table.insert(result, logic.getCardsNode({v[1]}, CT_SINGLE, k))
			end
		end
	end

	return result
end

function logic.getAllSingleEX(cards, preKeyValue, CPAmount)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)

	for k = 1, 15 do
		if hashTab[k] and k > preKeyValue and #hashTab[k] <= CPAmount then
			if not ((k == 14 or k ==15) and hashTab[15] and hashTab[14]) then
				table.insert(result, logic.getCardsNode({hashTab[k][1]}, CT_SINGLE, k))
			end
		end
	end
	return result
end

function logic.getAllDoubleCardEX(cards, preKeyValue, CPAmount)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)

	for k = 1, 13 do
		if hashTab[k] and k > preKeyValue and #hashTab[k] == CPAmount then
			table.insert(result, logic.getCardsNode({hashTab[k][1], hashTab[k][2]}, CT_DOUBLE, k))
		end
	end
	return result
end


function logic.getAllLineCard(cards, preKeyValue, preAmount)
	local cardCount = #cards
	if cardCount < 5 then return nil end
	local lines = {}
	local line = {}
	--local analyseData = logic.analyseCards(cards)
	local tempTb = logic.getCardsHashTab(cards)
	--util.printTable(tempTb)
	if not preKeyValue and not preAmount then
		for k, v in pairs(tempTb) do
			line = {v[1]}
			for j = k + 1, 12 do
				if tempTb[j] ~= nil then
					table.insert(line, tempTb[j][1])
					if #line >= 5 then
						--logic.printCards(line)
						table.insert(lines, logic.getCardsNode(util.copyTab(line), CT_SINGLE_LINE, logic.getCardLogicValue(line[1])))--{amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_SINGLE_LINE, weight = logic.getCardsWeight(line, CT_SINGLE_LINE), cards = util.copyTab(line)})
					end
				else
					break
				end
			end
		end
	else
		for k, v in pairs(tempTb) do
			if k > preKeyValue then
				line = {v[1]}
				for j = k + 1, 12 do
					if tempTb[j] ~= nil then
						table.insert(line, tempTb[j][1])
						if #line == preAmount then
							--logic.printCards(line)
							table.insert(lines, logic.getCardsNode(util.copyTab(line), CT_SINGLE_LINE, logic.getCardLogicValue(line[1])))
							--table.insert(lines, {amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_SINGLE_LINE, weight = logic.getCardsWeight(line, CT_SINGLE_LINE), cards = util.copyTab(line)})
						end
					else
						break
					end
				end
			end
		end
	end

	return lines
end

function logic.getAllDoubleLineCard(cards, preKeyValue, preAmount)
	local cardCount = #cards
	if cardCount < 6 then return nil end
	local doubleLines = {}
	local line = {}
	--local analyseData = logic.analyseCards(cards)
	local tempTb = logic.getCardsHashTab(cards)
	--util.printTable(tempTb)

	if not preKeyValue and not preAmount then
		for k, v in pairs(tempTb) do
			if #v >= 2 then
				line = {v[1], v[2]}
				for j = k + 1, 12 do
					if tempTb[j] ~= nil and #tempTb[j] >= 2 then
						table.insert(line, tempTb[j][1])
						table.insert(line, tempTb[j][2])
						if #line >= 6 then
							table.insert(doubleLines, logic.getCardsNode(util.copyTab(line), CT_DOUBLE_LINE, logic.getCardLogicValue(line[1])))--{amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_DOUBLE_LINE, weight = logic.getCardsWeight(line, CT_DOUBLE_LINE), cards = util.copyTab(line)})
						end
					else
						break
					end
				end
			end
		end
	else
		for k, v in pairs(tempTb) do
			if k > preKeyValue and #v >= 2 then
				line = {v[1], v[2]}
				for j = k + 1, 12 do
					if tempTb[j] ~= nil and #tempTb[j] >= 2 then
						table.insert(line, tempTb[j][1])
						table.insert(line, tempTb[j][2])
						if #line == preAmount then
							table.insert(doubleLines, logic.getCardsNode(util.copyTab(line), CT_DOUBLE_LINE, logic.getCardLogicValue(line[1])))
							--table.insert(doubleLines, {amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_DOUBLE_LINE, weight = logic.getCardsWeight(line, CT_DOUBLE_LINE), cards = util.copyTab(line)})
						end
					else
						break
					end
				end
			end
		end
	end

	return doubleLines
end

function logic.getAllPlaneCard(cards, takeOne, takeTwo, preKeyValue, preAmount)
	local cardCount = #cards
	if cardCount < 6 then return nil end
	local plane = {}
	local line = {}
	
	local tempTb = logic.getCardsHashTab(cards)

	if not preKeyValue and not preAmount then
		for k, v in pairs(tempTb) do
			if #v == 3 then
				line = {v[1], v[2], v[3]}
				for j = k + 1, 12 do
					if tempTb[j] ~= nil and #tempTb[j] == 3 then
						table.insert(line, tempTb[j][1])
						table.insert(line, tempTb[j][2])
						table.insert(line, tempTb[j][3])
						if #line >= 6 then
							if not takeOne and not takeTwo then
								table.insert(plane, logic.getCardsNode(util.copyTab(line), CT_THREE_LINE, logic.getCardLogicValue(line[1])))
							elseif takeOne then
								local combs = logic.getMinSingleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_LINE_TAKE_ONE, logic.getCardLogicValue(line[1])))
								end
							elseif takeTwo then
								local combs = logic.getMinDoubleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_LINE_TAKE_TWO, logic.getCardLogicValue(line[1])))
								end
							end
						end
					else
						break
					end
				end
			end
		end
	else
		for k, v in pairs(tempTb) do
			if k > preKeyValue and #v == 3 then
				line = {v[1], v[2], v[3]}
				for j = k + 1, 12 do
					if tempTb[j] ~= nil and #tempTb[j] == 3 then
						table.insert(line, tempTb[j][1])
						table.insert(line, tempTb[j][2])
						table.insert(line, tempTb[j][3])
						if #line == preAmount then
							if not takeOne and not takeTwo then
								table.insert(plane, logic.getCardsNode(util.copyTab(line), CT_THREE_LINE, logic.getCardLogicValue(line[1])))
							elseif takeOne then
								local combs = logic.getMinSingleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_LINE_TAKE_ONE, logic.getCardLogicValue(line[1])))
								end
							elseif takeTwo then
								local combs = logic.getMinDoubleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_LINE_TAKE_TWO, logic.getCardLogicValue(line[1])))
								end
							end
						end
					else
						break
					end
				end
			end
		end
	end

	return plane
end

function logic.getAllThreeLineCard(cards, preKeyValue, preAmount)
	local cardCount = #cards
	if cardCount < 6 then return nil end
	local plane = {}
	local line = {}
	
	local tempTb = logic.getCardsHashTab(cards)
	-- util.printTable(tempTb)
	for k, v in pairs(tempTb) do
		if k > preKeyValue and #v >= 3 then
			line = {v[1], v[2], v[3]}
			for j = k + 1, 12 do
				if tempTb[j] ~= nil and #tempTb[j] >= 3 then
					table.insert(line, tempTb[j][1])
					table.insert(line, tempTb[j][2])
					table.insert(line, tempTb[j][3])
					if #line == preAmount * 3 then
						table.insert(plane, logic.getCardsNode(util.copyTab(line), CT_THREE_LINE, logic.getCardLogicValue(line[1])))
					end
				else
					break
				end
			end
		end
	end

	return plane
end

function logic.getAllThreeCardLow(cards, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)
	
	-- for k, v in pairs(hashTab) do
	for k = 1, 13 do
		if hashTab[k] and #hashTab[k] >= 3 then
			local cds = {}
			for i = 1, 3 do
				table.insert(cds, hashTab[k][i])
			end
			table.insert(result, logic.getCardsNode(cds, CT_THREE, k))
		end
	end

	return result
end

function logic.getAllThreeCard(cards, takeOne, takeTwo, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)
	
	-- for k, v in pairs(hashTab) do
	for k = 1, 13 do
		if hashTab[k] and k > preKeyValue and #hashTab[k] == 3 then
			if not takeOne and not takeTwo then
				table.insert(result, logic.getCardsNode(util.copyTab(hashTab[k]), CT_THREE, k))
			elseif takeOne then
				local combs = logic.getMinSingleEX(cards, 1, hashTab[k])
				for k1, v1 in pairs(combs) do
					table.insert(result, logic.getCardsNode(util.merge(util.copyTab(hashTab[k]), v1), CT_THREE_LINE_TAKE_ONE, k))
				end
			elseif takeTwo then
				local combs = logic.getMinDoubleEX(cards, 1, hashTab[k])
				for k1, v1 in pairs(combs) do
					table.insert(result, logic.getCardsNode(util.merge(util.copyTab(hashTab[k]), v1), CT_THREE_LINE_TAKE_TWO, k))
				end
			end
		end
	end

	return result
end

function logic.getAllDoubleCardStrictly(cards, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)

	for k, v in pairs(hashTab) do
		if k > preKeyValue and #v > 1 then
			table.insert(result, logic.getCardsNode({v[1], v[2]}, CT_DOUBLE, k))
		end
	end
	return result
end

--{keyValue, amount, cards}
function logic.getAllDoubleCard(cards, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)

	for k, v in pairs(hashTab) do
		if k > preKeyValue and (#v == 2 or #v == 3) then
			table.insert(result, logic.getCardsNode({v[1], v[2]}, CT_DOUBLE, k))
		end
	end
	return result
end

function logic.getAllBomCard(cards, preKeyValue)
	local preKeyValue = preKeyValue or 0
	local boomList = {}
	local hasTab = logic.getCardsHashTab(cards)

	for k, v in pairs(hasTab) do
		if k > preKeyValue and #v == 4 then
			table.insert(boomList, logic.getCardsNode(util.copyTab(v), CT_BOMB_CARD, k))
		end
	end

	if hasTab[14] ~= nil and #hasTab[14] == 1 and hasTab[15] ~= nil and #hasTab[15] == 1 then
		table.insert(boomList, logic.getCardsNode({140, 150}, CT_MISSILE_CARD, 14))
	end

	return boomList
end

function logic.getAllFourTake(cards, takeOne, takeTwo, preKeyValue)
	local optionsCards = logic.getAllBomCard(cards, preKeyValue)
	if not optionsCards or not next(optionsCards) then return nil end
	for i = 1, #optionsCards do
		if optionsCards[i].cardType == CT_MISSILE_CARD then
			table.remove(optionsCards, i, 1)
			break
		end
	end

	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end

	local result = {}
	for i = 1, #optionsCards do
		if takeOne then
			local combs = logic.getMinSingleEX(cards, 2, optionsCards[i].cards)
			for k, v in pairs(combs) do
				-- local temp = util.copyTab(optionsCards[i])
				-- temp.amount = temp.amount + 2
				-- temp.cardType = CT_FOUR_LINE_TAKE_ONE
				-- temp.cards = util.merge(temp.cards, v)
				-- temp.weight = logic.getCardsWeight(temp.cards, CT_FOUR_LINE_TAKE_ONE)
				--return optionsCards[i]
				
				table.insert(result, logic.getCardsNode(util.merge(util.copyTab(optionsCards[i].cards), v), CT_FOUR_LINE_TAKE_ONE, optionsCards[i].keyValue))
			end
		elseif takeTwo then
			local combs = logic.getMinDoubleEX(cards, 2, optionsCards[i].cards)
			for k, v in pairs(combs) do
				-- optionsCards[i].amount = optionsCards[i].amount + 4
				-- optionsCards[i].cardType = CT_FOUR_LINE_TAKE_TWO
				-- optionsCards[i].cards = util.merge(optionsCards[i].cards, v)
				-- optionsCards[i].weight = logic.getCardsWeight(optionsCards[i].cards, CT_FOUR_LINE_TAKE_TWO)
				-- --return optionsCards[i]
				-- table.insert(result, optionsCards[i])
				table.insert(result, logic.getCardsNode(util.merge(util.copyTab(optionsCards[i].cards), v), CT_FOUR_LINE_TAKE_TWO, optionsCards[i].keyValue))
			end
		end
	end
	return result
end

function logic.getSingleBigger(preKeyValue, cards)
	local result = logic.getAllSingle(cards, preKeyValue)
	if result and next(result) then
		return result[1]
	end

	for i = 1, #cards do
		if logic.getCardLogicValue(cards[i]) > preKeyValue then
			return logic.getCardsNode({cards[i]}, CT_SINGLE, logic.getCardLogicValue(cards[i]))
		end
	end
end

function logic.getDoubleBigger(preKeyValue, cards)
	local optionsCards = logic.getAllDoubleCard(cards, preKeyValue)

	if optionsCards and next(optionsCards) then
		return optionsCards[1]
	end
end

function logic.getThreeBigger(preKeyValue, cards, takeOne, takeTwo)
	local optionsCards = logic.getAllThreeCard(cards, takeOne, takeTwo, preKeyValue)
	if not optionsCards or not next(optionsCards) then return nil end
	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end
	return optionsCards[1]
end

function logic.getLineBigger(preKeyValue, amount, cards)
	local optionsCards = logic.getAllLineCard(cards, preKeyValue, amount)
	if not optionsCards or not next(optionsCards) then return nil end
	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end

	return optionsCards[1]
end

function logic.getDoubleLineBigger(preKeyValue, amount, cards)
	local optionsCards = logic.getAllDoubleLineCard(cards, preKeyValue, amount)
	if not optionsCards or not next(optionsCards) then return nil end
	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end

	return optionsCards[1]
end

function logic.getPlaneBigger(preKeyValue, amount, cards, takeOne, takeTwo)
	--三张
	if amount == 3 then
		return logic.getThreeBigger(preKeyValue, cards, takeOne, takeTwo)
	end
	local result = {}
	--飞机
	local optionsCards = logic.getAllPlaneCard(cards, takeOne, takeTwo, preKeyValue, amount)
	if not optionsCards or not next(optionsCards) then return nil end
	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end

	return optionsCards[1]
end


function logic.getBoomBigger(preKeyValue, cards)
	local optionsCards = logic.getAllBomCard(cards, preKeyValue)
	if not optionsCards or not next(optionsCards) then return nil end

	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end

	return optionsCards[1]
end

function logic.getFourTakeBigger(preKeyValue, cards, takeOne, takeTwo)
	--炸弹
	local optionsCards = logic.getAllFourTake(cards, takeOne, takeTwo, preKeyValue)
	if not optionsCards or not next(optionsCards) then return nil end
	if #optionsCards > 1 then
		table.sort(optionsCards, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	end
	return optionsCards[1]
end

function logic.getSingleCombDfs(pos, cards, result, amount, container)
	--if #result == amount then
	for i = pos, #cards do
		if next(result) == nil and i > #cards - amount + 1 then
			return
		end
		table.insert(result, cards[i])
		if #result == amount then
			table.insert(container, util.copyTab(result))
		else
			logic.getSingleCombDfs(i + 1, cards, result, amount, container)
		end
		table.remove(result, #result)
	end
end

function logic.getDoubleCombDfs(pos, cards, result, amount, container)
	for i = pos, #cards do
		if next(result) == nil and i > #cards - amount + 1 then
			return
		end
		util.merge(result, cards[i])
		if #result / 2 == amount then
			table.insert(container, util.copyTab(result))
		else
			logic.getDoubleCombDfs(i + 1, cards, result, amount, container)
		end
		util.removeTable(result, cards[i])
	end
end

local function getExtraCards(mincnt, hashTab)
	local result = {}
	local len = 15
	if hashTab[14] and hashTab[15] then
		len = 13
	end
	for i = mincnt, 3 do
		for k = 1, len do
			if hashTab[k] and #hashTab[k] == i then
				if mincnt == 1 then
					table.insert(result, hashTab[k][#hashTab[k]])
				else
					local t = {}
					for j = 1, mincnt do
						table.insert(t, hashTab[k][#hashTab[k] - j + 1])
					end
					table.insert(result, t)
				end
			end
		end
	end
	return result
end

function logic.getMinSingleEX(cards, amount, exCards)
	local container = {}
	-- 删除不能组合的扑克
	local tempCards = util.copyTab(cards)
	util.removeTable(tempCards, exCards)
	-- 排除大于amount个数的牌
	-- local origin = {}
	local hashTab = logic.getCardsHashTab(tempCards)
	local origin = getExtraCards(1, hashTab)
	-- for k = 1, 13 do
	-- 	if hashTab[k] and #hashTab[k] == 1 then	
	-- 		table.insert(origin, hashTab[k][1])
	-- 	end
	-- end

	-- for k, v in pairs(hashTab) do
	-- 	if #v ~= 1 and #v ~= 4 then
	-- 		table.insert(origin, v[#v])
	-- 	end
	-- end

	--local len = #origin - amount + 1
	logic.getSingleCombDfs(1, origin, {}, amount, container)
	--带单牌不需要带 对子及以上类型
	-- if amount > 1 then
	-- 	for k, v in pairs(hashTab) do
	-- 		if #v >= amount then
	-- 			local t = {}
	-- 			for i = 1, amount do
	-- 				table.insert(t, v[i])
	-- 			end
	-- 			table.insert(container, t)
	-- 		end
	-- 	end
	-- end

	return container
end

function logic.getMinDoubleEX(cards, amount, exCards)
	local container = {}
	-- 删除不能组合的扑克
	local tempCards = util.copyTab(cards)
	util.removeTable(tempCards, exCards)

	-- local origin = {}
	local hashTab = logic.getCardsHashTab(tempCards)
	local origin = getExtraCards(2, hashTab)
	-- for k = 1, 13 do
	-- 	if hashTab[k] and #hashTab[k] == 2 then	
	-- 		table.insert(origin, {hashTab[k][1], hashTab[k][2]})
	-- 	end
	-- end

	-- for k, v in pairs(hashTab) do
	-- 	if #v >= 2 and #v <= 3 then
	-- 		table.insert(origin, {v[#v], v[#v - 1]})
	-- 	end
	-- end

	--local len = #origin - amount + 1
	logic.getDoubleCombDfs(1, origin, {}, amount, container)

	return container
end

function logic.getMinSingle(cards, amount, exCards)
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)
	for i = 1, 11 do
		if hashTab[i] ~= nil and #hashTab[i] == 1 then
			table.insert(result, hashTab[i][1])
			if #result >= amount then
				return result
			end
		end
	end

	local find = false
	for i = 1, 11 do
		if hashTab[i] ~= nil and #hashTab[i] ~= 1 and #hashTab[i] < 4 then
			for j = 1, #hashTab[i] do
				find = false
				for k = 1, #exCards do
					if exCards[k] == hashTab[i][j] then
						find = true
					end
				end
				if not find then
					table.insert(result, hashTab[i][j])
					if #result >= amount then
						return result
					end
				end
			end
		end
	end
	
	return nil
end

function logic.sparateFromTakes(node, amount, result, compareKey)
	if node.cardType == CT_THREE_LINE_TAKE_ONE or node.cardType == CT_THREE_LINE_TAKE_TWO or
		node.cardType == CT_FOUR_LINE_TAKE_ONE or node.cardType == CT_FOUR_LINE_TAKE_TWO then
		local hashTab = logic.getCardsHashTab(node.cards)
		-- local result = {}
		for k, v in pairs(hashTab) do
			if #v == amount and k > compareKey then
				if amount == 1 then
					table.insert(result, logic.getCardsNode({v[1]}, CT_SINGLE, k))
				elseif amount == 2 then
					table.insert(result, logic.getCardsNode({v[1], v[2]}, CT_DOUBLE, k))
				end
			end
		end
	end
end

function logic.sparateMasterFromTakes(node, compareAmout, cutAmount)
	if node.cardType == CT_THREE_LINE_TAKE_ONE or node.cardType == CT_THREE_LINE_TAKE_TWO or
		node.cardType == CT_FOUR_LINE_TAKE_ONE or node.cardType == CT_FOUR_LINE_TAKE_TWO or
		node.cardType == CT_THREE or node.cardType == CT_THREE_LINE then
		assert(compareAmout >= cutAmount)
		local hashTab = logic.getCardsHashTab(node.cards)
		local result = {}
		for k, v in pairs(hashTab) do
			if #v == compareAmout then
				for i = 1, cutAmount do
					table.insert(result, v[i])
				end
				return result
			end
		end
	end
end

function logic.getMinDouble(cards, amount, exCards)
	local result = {}
	local hashTab = logic.getCardsHashTab(cards)
	for i = 1, 11 do
		if hashTab[i] ~= nil and #hashTab[i] == 2 then
			table.insert(result, hashTab[i][1])
			table.insert(result, hashTab[i][2])
			if #result >= amount * 2 then
				return result
			end
		end
	end

	local find = false
	for i = 1, 11 do
		if hashTab[i] ~= nil and #hashTab[i] == 3 then
			find = false
			for j = 1, 2 do
				for k = 1, #exCards do
					if exCards[k] == hashTab[i][j] then
						find = true
						break
					end
				end
				if find then break end
			end
			if not find then
				table.insert(result, hashTab[i][1])
				table.insert(result, hashTab[i][2])
			end

			if #result >= amount * 2 then
				return result
			end
		end
	end
end

function logic.getBomBigger(preKeyValue, cards)
	if preKeyValue >= 140 then return nil end
	local optionsCards = logic.getAllBomCard(cards)
	if nil == optionsCards then return nil end
	for i = 1, #optionsCards do
		if optionsCards[i].keyValue > preKeyValue then
			return optionsCards[i]
		end
	end
end

-- function logic.getKeyValueInCards(cards, cardType)
-- 	local cardType = cardType or logic.getCardType(cards)
-- 	if cardType == CT_ERROR then
-- 		return 0
-- 	end
-- 	if cardType == CT_SINGLE or cardType == CT_DOUBLE or cardType == CT_THREE or 
-- 		cardType == CT_SINGLE_LINE or cardType == CT_DOUBLE_LINE or cardType == CT_THREE_LINE or
-- 		 cardType == CT_BOMB_CARD or cardType == CT_MISSILE_CARD then
-- 		return logic.getCardLogicValue(cards[1])
-- 	end

-- 	local hashTab = logic.getCardsHashTab(cards)

-- 	if cardType == CT_THREE_LINE_TAKE_ONE or cardType == CT_THREE_LINE_TAKE_TWO then
-- 		local _, kv = logic.getCardType(cards)
-- 		return kv
-- 		-- for i = 1, 13 do
-- 		-- 	if hashTab[i] and #hashTab[i] == 3 then
-- 		-- 		return i
-- 		-- 	end
-- 		-- end
-- 	end

-- 	if cardType == CT_FOUR_LINE_TAKE_ONE or cardType == CT_FOUR_LINE_TAKE_TWO then
-- 		for i = 1, 13 do
-- 			if hashTab[i] and #hashTab[i] == 4 then
-- 				return i
-- 			end
-- 		end
-- 	end
-- end

function logic.cardsTableEqual(cards1, cards2)
	if cards2 == nil or cards1 == nil then return false end
	if #cards2 ~= #cards1 then return false end

	local find = false
	for k, v in pairs(cards1) do
		find = false
		for k1, v1 in pairs(cards2) do
			if v1 == v then
				find = true
				break
			end
		end
		if not find then 
			return false
		end
	end
	return true
end

function logic.getGuessCardsType(cards)
	if not cards or #cards ~= 3 then return 0 end
	table.sort(cards, function(card1, card2)
		return card1 < card2
	end)

	local sequence = true
	local samecolor = true
	local haspair = false
	local hasJQK = false
	local hasJork = false
	local has2 = false
	for k, v in pairs(cards) do
		if v == 140 or v == 150 then
			hasJork  = true
			sequence = false
			samecolor = false
		end

		if not hasJQK and (math.floor(v / 10) == 9 or math.floor(v / 10) == 10 or math.floor(v / 10) == 11) then
			hasJQK = true
		end

		if not has2 and math.floor(v / 10) == 13 then
			has2 = true
		end
	end

	for i = 2, 3 do
		if math.floor(cards[i] / 10) == math.floor(cards[i - 1] / 10) then
			haspair = true
		end
		if not hasJork then
			if math.floor(cards[i] / 10) - math.floor(cards[i - 1] / 10) ~= 1 then
				sequence = false
			end

			if (cards[i] % 10) ~= (cards[i - 1] % 10) then
				samecolor = false
			end
		end
	end

	if has2 and sequence then
		sequence = false
	end

	if not sequence then
		if (math.floor(cards[1] / 10) == 1 and math.floor(cards[2] / 10) == 12 and math.floor(cards[3] / 10) == 13) or
			(math.floor(cards[1] / 10) == 1 and math.floor(cards[2] / 10) == 2 and math.floor(cards[3] / 10) == 13) then
			sequence = true
		end
	end

	if sequence and samecolor then
		return 6, hasJQK
	elseif sequence then
		return 5, hasJQK
	elseif samecolor then
		return 4, hasJQK
	else
		if hasJork then return 3, hasJQK, nil, haspair end
		if haspair then return 2, hasJQK, hasJork end
		if hasJQK then return 1, hasJQK, hasJork end

		return 0
	end
end
--------------------------------------------------------------------------------------------
local _cards =  {
	10,11,12,13,
	20,21,22,23,
	30,31,32,33,
	40,41,42,43,
	50,51,52,53,
	60,61,62,63,
	70,71,72,73,
	80,81,82,83,
	90,91,92,93,
	100,101,102,103,
	110,111,112,113,
	120,121,122,123,
	130,131,132,133,
	140,150}

--飞机(2~3)、炸弹(1~2)、连对(3~5)、连牌(5~8)、三张
local _template = {
    --牌型          --百分比      --附加百分比     --附加百分比递增 --最多附加次数
	{tp = CT_THREE, percent = 25, subpercent = 25, increment = 10, max = 1},
	{tp = CT_SINGLE_LINE, percent = 20, subpercent = 25, increment = 5, max = 3},
	{tp = CT_DOUBLE_LINE, percent = 25, subpercent = 20, increment = 5, max = 2},
	{tp = CT_THREE_LINE, percent = 15, subpercent = 10, increment = 5, max = 1},
	{tp = CT_BOMB_CARD, percent = 15, subpercent = 15, increment = 5, max = 1},
}

local function getSpecialGroup(tp, cards, exnum)
	local options = {}
	if tp == CT_THREE then
		-- print('三张')
		options = logic.getAllThreeCardLow(cards, false, false, 1)
	elseif tp == CT_SINGLE_LINE then
		-- print('顺子')
		options = logic.getAllLineCard(cards, 1, exnum + 5)
	elseif tp == CT_DOUBLE_LINE then
		-- print('连对')
		options = logic.getAllDoubleLineCard(cards, 1, exnum + 3)
	elseif tp == CT_THREE_LINE then
		-- print('飞机')
		options = logic.getAllThreeLineCard(cards, 1, exnum + 2)
	elseif tp == CT_BOMB_CARD then
		-- print('炸弹')
		options = logic.getAllBomCard(cards)
	end
	-- print('getSpecialGroup  #options: '..tostring(#options))

	if not next(options) then
		return options
	else
		return options[math.random(1, #options)].cards
	end
end

local function create1group(cards, count, boomcnt)
	local result = {}
	local r-- = math.random(1, 100) --牌型概率
	local subr-- = math.random(1, 100) -- 牌型基础升级概率
	local exnum = 0 -- 升级次数
	local percent = 0 --累计概率
	local subpercent = 0 --累计升级概率
	local boomcnt = boomcnt or 1
	local hasboom = 0
	for c = 1, count do
		percent = 0
		exnum = 0
		subpercent = 0
		
		if hasboom >= boomcnt then
			r = math.random(1, 85) --牌型概率
		else
			r = math.random(1, 100) --牌型概率
		end
		subr = math.random(1, 100) -- 牌型基础升级概率
		for i = 1, #_template do
			percent = percent + _template[i].percent
			if percent >= r then --随机选中该牌型
				if _template[i].max > 1 then
					local maxpercent = _template[i].increment * _template[i].max + _template[i].subpercent
					-- print('maxpercent : '..tostring(maxpercent))
					for p = _template[i].subpercent, maxpercent, -_template[i].increment do
						-- print('p : '..tostring(p))
						if p >= subr then --确定牌型附加次数
							break
						end
						exnum = exnum + 1
					end
				end
				if _template[i].tp == CT_BOMB_CARD then
					hasboom = hasboom + 1
				end
				-- print('_template[i].tp: '..tostring(_template[i].tp)..'   exnum: '..tostring(exnum))
				-- logic.printCards(cards)
				--根据条件得到指定牌型
				local group = getSpecialGroup(_template[i].tp, cards, exnum)
				-- print('生成扑克 #group : '..tostring(#group))
				-- logic.printCards(group)
				if #group + #result > 17 then return result end
				if group and next(group) then -- 保存数据，更新牌堆
					for k, v in pairs(group) do
						table.insert(result, v)
						for k1, v1 in pairs(cards) do
							if v1 == v then
								table.remove(cards, k1)
								break
							end
						end
					end
				end
				break
			end
		end
	end
	return result
end

function logic.createCardsGroupXplayer(sidx, bottom, top)
	local cards = {}
	for k, v in pairs(_cards) do
		table.insert(cards, v)
	end
	-- print('开始组牌')
	local cardsgroup = {}
	local bottom = top or 2
	local top = top or 3
	local boomcnt = math.random(bottom, top)
	
	cardsgroup[sidx] = create1group(cards, 2)
	for i = 1, boomcnt do
		local group = getSpecialGroup(CT_BOMB_CARD, cards)
		if #cardsgroup[sidx] + #group > 17 then break end
		if group and next(group) then -- 保存数据，更新牌堆
			for k, v in pairs(group) do
				table.insert(cardsgroup[sidx], v)
				for k1, v1 in pairs(cards) do
					if v1 == v then
						table.remove(cards, k1)
						break
					end
				end
			end
		end
	end

	local j
	for i = 1, #cards do
		j = math.random(1, #cards)
		if i ~= j then
			cards[i] = cards[i] + cards[j]
			cards[j] = cards[i] - cards[j]
			cards[i] = cards[i] - cards[j]
		end
	end

	local idx = 1
	for i = 1, 3 do
		if not cardsgroup[i] then cardsgroup[i] = {} end
		for j = #cardsgroup[i] + 1, 17 do
			table.insert(cardsgroup[i], cards[idx])
			idx = idx + 1
		end
	end

	local mastercards = {cards[#cards], cards[#cards - 1], cards[#cards - 2]}
	return cardsgroup, mastercards
end


function logic.createCardsGroup(level, boomcnt)
	local cards = {}
	for k, v in pairs(_cards) do
		table.insert(cards, v)
	end
	-- print('开始组牌')
	local level = level or 2
	local cardsgroup = {}
	for i = 1, 3 do
		cardsgroup[i] = create1group(cards, level, boomcnt)
		-- print('玩家 '..tostring(i))
		-- logic.printCards(cardsgroup[i])
		-- print('\n')
	end

	-- print('给剩余的扑克排序')
	local j
	local len = math.floor(#cards / 2)
	for i = 1, len do
		j = math.random(1, #cards)
		if i ~= j then
			cards[i] = cards[i] + cards[j]
			cards[j] = cards[i] - cards[j]
			cards[i] = cards[i] - cards[j]
		end
	end
	len = #cards
	for i = len - 2, len do --防止底牌过于集中
        j = math.random(1, len - 2)
        if i ~= j then
            cards[i] = cards[i] + cards[j]
            cards[j] = cards[i] - cards[j]
            cards[i] = cards[i] - cards[j]
        end
    end
	-- print('剩余的扑克')
	-- logic.printCards(cards)
	local idx = 1
	for i = 1, 3 do
		for j = #cardsgroup[i] + 1, 17 do
			table.insert(cardsgroup[i], cards[idx])
			idx = idx + 1
		end
		-- table.sort(cardsgroup[i])
	end

	local mastercards = {cards[#cards], cards[#cards - 1], cards[#cards - 2]}
	return logic.killBadCards(cardsgroup, mastercards)
end

function logic.judgeCardsLegal(cardsgroup, mastercards)
	local total = {}
	util.merge(total, mastercards)
	for k, v in pairs(cardsgroup) do
		util.merge(total, v)
	end

	table.sort(total, function(c1, c2)
		return c1 < c2
	end)

	for i = 1, #_cards do
		if _cards[i] ~= total[i] then
			return false
		end
	end
	return true
end

function logic.createCardsNormal()
	local cards = {}
	for k, v in pairs(_cards) do
		table.insert(cards, v)
	end
	-- 大切
	local idx
	idx = math.random(10, 40)
	for i = idx, 54 do
	  table.insert(cards, 1, table.remove(cards, #cards))
	end
	-- 抽35次
	local j
	for i = 1, 35 do
		j = math.random(1, #cards)
		if i ~= j then
			cards[i] = cards[i] + cards[j]
			cards[j] = cards[i] - cards[j]
			cards[i] = cards[i] - cards[j]
		end
	end

	for i = 50, 52 do --防止底牌过于集中
        j = math.random(1, 49)
        if i ~= j then
            cards[i] = cards[i] + cards[j]
            cards[j] = cards[i] - cards[j]
            cards[i] = cards[i] - cards[j]
        end
    end

	local cardsgroup = {}
	for i = 1, 3 do
    	cardsgroup[i] = {}
		idx = (i - 1) * 17
		for j = idx + 1, idx + 17 do
			table.insert(cardsgroup[i], cards[j])
		end
	end
	local mastercards = {cards[#cards], cards[#cards - 1], cards[#cards - 2]}
	return logic.killBadCards(cardsgroup, mastercards)
end

function logic.createCardsMissile(missile_seat)
	if missile_seat < 1 or missile_seat > 3 then return end
	local cards = {}
	for k, v in pairs(_cards) do
		if v ~= 140 and v ~= 150 then
			table.insert(cards, v)
		end
	end
	-- 大切
	local idx
	idx = math.random(10, 40)
	for i = idx, #cards do
	  	table.insert(cards, 1, table.remove(cards, #cards))
	end
	-- 抽35次
	local j
	for i = 1, 35 do
		j = math.random(1, #cards)
		if i ~= j then
			cards[i] = cards[i] + cards[j]
			cards[j] = cards[i] - cards[j]
			cards[i] = cards[i] - cards[j]
		end
	end

	for i = 50, 52 do --防止底牌过于集中
        j = math.random(1, 49)
        if i ~= j then
            cards[i] = cards[i] + cards[j]
            cards[j] = cards[i] - cards[j]
            cards[i] = cards[i] - cards[j]
        end
    end

	local cardsgroup = {}
	cardsgroup[missile_seat] = {140, 150}
	idx = 1
	for i = 1, 3 do
		cardsgroup[i] = cardsgroup[i] or {}
		while #cardsgroup[i] < 17 do			
			table.insert(cardsgroup[i], cards[idx])
			idx = idx + 1
		end
	end

	return logic.killBadCards(cardsgroup, {cards[#cards], cards[#cards - 1], cards[#cards - 2]}, true)
	-- return cardsgroup, {cards[#cards], cards[#cards - 1], cards[#cards - 2]}
end


function logic.createCardsGroupHeap(shufflecnt)
	local cards = {}
	for k, v in pairs(_cards) do
		table.insert(cards, v)
	end

	local n, m
	n = math.random(10, 40)
	for i = n, 54 do
	  table.insert(cards, 1, table.remove(cards, #cards))
	end
	for i = 1, shufflecnt do
		n = math.random(1, 54)
		m = math.random(2, 5)

		if (n + m) > 54 then
			m = 54 - n
		end
		n = n + m
		for j = 1, m do
			table.insert(cards, 1, table.remove(cards, n))
		end
	end
	local j
	for i = 52, 54 do --防止底牌过于集中
        j = math.random(1, 51)
        if i ~= j then
            cards[i] = cards[i] + cards[j]
            cards[j] = cards[i] - cards[j]
            cards[i] = cards[i] - cards[j]
        end
    end
	local cardsgroup = {}
	local x = {6, 6, 5}
	for j = 1, 3 do
		for i = 1, 3 do
			if not cardsgroup[i] then cardsgroup[i] = {} end
			table.mergeByAppend(cardsgroup[i], table.arraycopy(cards, 3 * (j - 1) * (x[j - 1] or 0) + (i - 1) * x[j] + 1, x[j]))
		end
	end

	local mastercards = {cards[#cards], cards[#cards - 1], cards[#cards - 2]}
	return logic.killBadCards(cardsgroup, mastercards)
end

function logic.judgeBadCards(cards, jorkexcept)
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or 0
		hash[key] = hash[key] + 1
	end

	local notsingle
	local cutAmount

	local threecnt = 0
	local boomcnt = 0
	for i = 1, 12 do
		if hash[i] == 3 then
			threecnt = threecnt + 1
		elseif hash[i] == 4 then
			boomcnt = boomcnt + 1
		end
	end
	
	if hash[14] and hash[15] then
		boomcnt = boomcnt + 1
	end

	if boomcnt + threecnt >= 4 then
		return false
	end
	
	local badcards = false
	local badkey, tempbk, excidx
	for i = 1, 8 do
	    if hash[i] == 1 then
			notsingle = 0
			cutAmount = 0
			for j = i, i + 4 do
				if not hash[j] then
					tempbk = j
					cutAmount = cutAmount + 1
				elseif hash[j] > 1 then
					notsingle = notsingle + 1
				end
			end
		    if cutAmount == 0 and notsingle <= 1 then
		      return false
		    end

			if cutAmount == 1 and notsingle <= 1 then
				badkey = tempbk
				for k, v in pairs(cards) do
					key = logic.getCardLogicValue(v)
					if key < i or key > (i + 4) then
						if not jorkexcept or (key ~= 140 and key ~= 150) then
							excidx = k
							break
						end
					end
				end
				badcards = true
			end
		end
	end
	return badcards, badkey, excidx
end

function logic.killBadCards(cardsgroup, mastercards, jorkexcept)
	local bad, key, idx
	local success
	for i = 1, 3 do
		bad, key, idx = logic.judgeBadCards(cardsgroup[i], jorkexcept)
		if bad then
			-- print('\nneed exchange before index: %d key:%d ', i, key)
			-- for ix = 1, 3 do
			-- 	logic.printCards(cardsgroup[ix])
			-- end
			if key and idx then
				for j = 1, 3 do
					if i ~= j then
						for k, v in pairs(cardsgroup[j]) do
							if logic.getCardLogicValue(v) == key then
								cardsgroup[i][idx] = cardsgroup[i][idx] + v
								cardsgroup[j][k] = cardsgroup[i][idx] - cardsgroup[j][k]
								cardsgroup[i][idx] = cardsgroup[i][idx] - cardsgroup[j][k]
								success = true
								-- print('need exchange after: ')
								-- for ix = 1, 3 do
								-- 	logic.printCards(cardsgroup[ix])
								-- end
								-- print('\n')
								break
							end
						end
						if success then break end
					end
				end
			end
		end
	end
	
	return cardsgroup, mastercards
end

-- local CT_ERROR =				0	--错误
-- local CT_SINGLE	=				1 	--单牌
-- local CT_DOUBLE	=				2 	--对子
-- local CT_THREE =				3 	--三张
-- local CT_SINGLE_LINE =			4 	--顺子
-- local CT_DOUBLE_LINE =			5 	--连对
-- local CT_THREE_LINE	=			6 	--飞机
-- local CT_THREE_LINE_TAKE_ONE =	7 	--飞机带单(包括三张带单牌)
-- local CT_THREE_LINE_TAKE_TWO =	8 	--飞机带对
-- local CT_FOUR_LINE_TAKE_ONE	=	9	--炸弹带单牌
-- local CT_FOUR_LINE_TAKE_TWO	=	10	--炸弹带对子
-- local CT_BOMB_CARD =			11 	--炸弹
-- local CT_MISSILE_CARD =			12	--王炸

local combination = {}

combination.combinations = {}
combination.recordOriginCards = {}
combination.stepWeight = {}

combination.minStep = 999
function combination.resetConfigData()
	combination.minStep = 999
	combination.stepWeight = {}
	combination.combinations = {}
	combination.recordOriginCards = {}
end

function combination.printCombination(combs)
	for i = 1, #combs do
		-- LOG_DEBUG(string.format('combination: %d           step:%d           weight:%d', i, combs[i].step, combs[i].weight))

		for k, v in pairs(combs[i].resultArr) do
			-- LOG_DEBUG('msg:---------------card '..k)
			logic.printCards(v.cards)
		end
	end
end

function combination.initializeCombinations(cards, NeedSort)
	table.sort(cards, function(card1, card2)
		return card1 < card2
	end)

	--if not logic.cardsTableEqual(cards) then
	if not logic.cardsTableEqual(combination.recordOriginCards, cards) then
	--if not combination.cardsEqualHashTable(cards) then
	-- 	return combination.combinations
	-- else
		--重置临时数据
		combination.resetConfigData()
		--记录表格
        combination.recordOriginCards = util.copyTab(cards)
		-- dfs get combs
		-- print('msg:-----------------------------before--fist(cards, true)')
		-- logic.printCards(cards)
		combination.getBestCombination(1, util.copyTab(cards), {resultArr = {}, step = 0, weight = 0})
		-- print('msg:-----------------------------before--end(cards, true)')
		-- logic.printCards(cards)
		if NeedSort then
			combination.sortCombinations()
		end
	end
end

function combination.getBestCardsIndex(cardsArr)
	local nodes = {}
	for i = 1, 3 do
		combination.initializeCombinations(cardsArr[i], true)
		--总手数小于6
		nodes[i] = combination.combinations[1]
		nodes[i].index = i
	end
	table.sort(nodes, function(node1, node2)
		return node1.weight > node2.weight
	end)
	return nodes[1].index
end

function combination.setCardsByWeight(cardsArr, better_seat, bad_seat)
	local nodes = {}
	for i = 1, 3 do
		combination.initializeCombinations(cardsArr[i], true)
		--总手数小于6
		nodes[i] = combination.combinations[1]
		nodes[i].index = i
	end

	table.sort(nodes, function(node1, node2)
		return node1.weight > node2.weight
	end)

	local newCards = {}
	newCards[better_seat] = cardsArr[nodes[1].index]

	if bad_seat then
		newCards[bad_seat] = cardsArr[nodes[3].index]
		for i = 1, 3 do
			if i ~= better_seat and i ~= bad_seat then
				newCards[i] = cardsArr[nodes[2].index]
			end
		end
	else
		local idx = 2
		for i = 1, 3 do
			if i ~= better_seat then
				newCards[i] = cardsArr[nodes[idx].index]
				idx = idx + 1
			end
		end
	end

	return newCards
end

function combination.getCardsVaule(cards)
	if not cards or #cards < 1 then return 9999999999 end
	combination.initializeCombinations(cards, true)
	-- print('----------------------------------------------------------')
	-- luadump(combination.combinations[1])
	local baseval = 0
	for k, v in pairs(combination.combinations[1].resultArr) do
		baseval = baseval + v.weight
	end

	local remain = #combination.combinations[1].resultArr
	local remian_value = 100 - remain

	return remian_value * baseval
end

function combination.callBankerPercent(cards)
	combination.initializeCombinations(cards, true)
	--总手数小于6
	-- if combination.combinations[1].step <= 4 then
	-- 	return 50
	-- end

	local boomsAmout = 0
	local threeAmount = 0
	local bigAmount = 0

	local hashTab = logic.getCardsHashTab(cards)
	for k, v in pairs(hashTab) do
		if #v == 3 then
			threeAmount = threeAmount + 1
		elseif #v == 4 then
			boomsAmout = boomsAmout + 1
		end

		if k == 14 or k == 15 or k == 13 then
			bigAmount = bigAmount + 1
		end
	end

	if hashTab[14] ~=nil and hashTab[15] ~=nil then
		boomsAmout = boomsAmout + 1
	end

	if boomsAmout > 3 then
		return 100
	elseif boomsAmout >= 2 and combination and 
		combination.combinations[1] and
		combination.combinations[1].step and combination.combinations[1].step <= 5 then
		return 60
	elseif boomsAmout == 3 then
		return 50
	--三条大于2 并且2 和王的个数大于3
	elseif threeAmount >= 3 and bigAmount >= 4 then
		return 50
	elseif boomsAmout == 2 then
		return 10
	--王炸在手 还有一对2
	-- elseif hashTab[14] ~=nil and hashTab[15] ~=nil then-- and bigAmount >= 4 then
	-- 	return 100
	--权值大于2400
	-- elseif combination.combinations[1].weight >= 2400 then
	-- 	return 60
	-- elseif combination.combinations[1].weight >= 1800 then
	-- 	return 20
	end

	return 0
end

function combination.chooseOne(resultArr, enemyCards1, enemyCards2)
	-- print('msg:-------------------#result: ', tostring(#resultArr))
	if nil == resultArr or #resultArr ~= 2 then
		assert(false)
		return 
	end

	table.sort(resultArr, function(node1, node2)
		-- local temp1 = node1.amount > 2
		-- local temp2 = node2.amount > 2
		-- --先出数量大于敌人的牌
		-- if temp1 == temp2 then
		-- 	return node1.keyValue < node2.keyValue
		-- else
			return node1.amount > node2.amount
		--end
	end)

	local singleEnemyAmount = #enemyCards1
	local ecards = util.copyTab(enemyCards1)
	if enemyCards2 ~= nil then
		if singleEnemyAmount < #enemyCards2 then
			singleEnemyAmount = #enemyCards2
		end
		util.merge(ecards, enemyCards2)
	end

	for k, v in pairs(resultArr) do
		--出数量大于敌人的牌
		if v.amount > singleEnemyAmount then
			return v
		end

		--出大于任何人手中牌的牌
		if logic.maxInCards(v.keyValue, ecards) then
			return v
		end
	end

	if resultArr[1].cardType == CT_SINGLE_LINE and resultArr[2].cardType ~= CT_SINGLE_LINE then
		return resultArr[1]
	elseif resultArr[1].cardType ~= CT_SINGLE_LINE and resultArr[2].cardType == CT_SINGLE_LINE then
		return resultArr[2]
	end
	--大于对子的牌 先出
	if resultArr[1].amount > 5 or (resultArr[1].cardType > CT_DOUBLE and resultArr[1].cardType < CT_BOMB_CARD) then--(resultArr[1].cardType > CT_DOUBLE and resultArr[2].keyValue < 8)  then
		return resultArr[1]
	end

	--出大的
	if resultArr[1].cardType < CT_BOMB_CARD and resultArr[1].keyValue < resultArr[2].keyValue then
		return resultArr[1]
	else
		return resultArr[2]
	end
end

function combination.getFirstOutCards(cards, enemysCards1, enemysCards2, friendCards)
	
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end
	if #comb.resultArr > 1 then
		combination.sortOutCardsList(comb.resultArr)
	end

	if #comb.resultArr == 2 then
		return combination.chooseOne(comb.resultArr, enemysCards1, enemysCards2)
	elseif #comb.resultArr > 1 then
		local takeamount = 0
		local vct = 0
		
		for i = 1, #comb.resultArr do
			vct = comb.resultArr[i].cardType
			if vct < CT_BOMB_CARD then
				if #comb.resultArr > 1 then
					takeamount = 0
					if vct == CT_THREE_LINE_TAKE_ONE or vct == CT_FOUR_LINE_TAKE_ONE then
						takeamount = 1
					elseif vct == CT_THREE_LINE_TAKE_TWO or vct == CT_FOUR_LINE_TAKE_TWO then
						takeamount = 2
					end
					--三带X牌型， 带出大于K或者和敌人手中最大牌一样的大牌，并且自己手中还有两手以上牌型 则不带~！
					if vct == CT_THREE_LINE_TAKE_ONE or vct == CT_THREE_LINE_TAKE_TWO then
						if takeamount ~= 0 then
							local ecards = util.copyTab(enemysCards1)
							if enemysCards2 ~= nil then
								util.merge(ecards, enemysCards2)
							end
							table.sort(ecards, function(card1, card2)
								return card1 > card2
							end)

							local maxcardkv = logic.getCardLogicValue(ecards[1])
							if maxcardkv > 11 then
								maxcardkv = 11
							end
							local takecards = {}
							logic.sparateFromTakes(comb.resultArr[i], takeamount, takecards, 0)
							if takecards and next(takecards) and takecards[1].keyValue > maxcardkv then
								-- return op[1]
								local result = logic.getCardsNode(logic.sparateMasterFromTakes(comb.resultArr[i], 3, 3), CT_THREE, comb.resultArr[i].keyValue)
								if result then
									return result
								end
							end
						end
					end
				end
				-- result = logic.getCardsNode(logic.sparateMasterFromTakes(v, 3, 2), CT_DOUBLE, k)
				return comb.resultArr[i]
			end
		end
	end

	for k, v in pairs(comb.resultArr) do
		if not v.ct then
			logic.printMachineCards(cards, true, '我的')
			logic.printMachineCards(enemysCards1, true, '敌人1')
			logic.printMachineCards(enemysCards2, true, '敌人1')
			logic.printMachineCards(friendCards, true, '队友的')
			break
		end
		if v.ct >= CT_THREE_LINE and v.ct <= CT_THREE_LINE_TAKE_TWO then
			return v
		end
	end

	return comb.resultArr[1]
end

function combination.chooseOption(options, bestComb, cards)
	if not options or not next(options) then
		return nil
	end

	local index = nil
	local minStep = 999
	local maxWeight = -1

	--local tempNode
	for i = 1, #options do
		--local tempCards = util.copyTab(cards)
		-- remove the flow cards
		util.removeTable(cards, options[i].cards)
		-- get combs in remaining cards
		combination.initializeCombinations(cards, true)
		-- print('msg:----------------options: ', i)
		-- logic.printCards(options[i].cards)
		-- combination.printCombination(combination.combinations)
		if combination.combinations[1].step < minStep or 
			(combination.combinations[1].step == minStep and combination.combinations[1].weight > maxWeight) or
			(combination.combinations[1].step == minStep and options[i].keyValue < options[index].keyValue) then
			-- print('msg:----------------options: ', i)
			-- logic.printCards(options[i].cards)
			-- combination.printCombination(combination.combinations)

			-- tempNode = util.copyTab(combination.combinations[1])
			minStep = combination.combinations[1].step
			maxWeight = combination.combinations[1].weight
			index = i
		end
		-- reset cards
		util.merge(cards, options[i].cards)			
	end
	--print('msg:-------------------minStep: ',minStep, '    weight: ', maxWeight)
	--util.printTable(bestComb)
	
	-- print('\n\nmsg:--------------------------chosed option, ', options[index].weight)
	-- combination.printCombination({tempNode, bestComb})
	--步数多出2步，价值减少100左右可以接受- -
	if minStep < bestComb.step or (minStep <= bestComb.step + 1 and maxWeight + options[index].weight >= bestComb.weight - 100) then
		-- print('msg:----get answer')
		-- util.printTable(options[index])
		return options[index]
	end
end

function combination.printResultList(list)
	for k, v in pairs(list) do
		logic.printCards(v.cards)
	end
end

function combination.getOutCardsOptions(cards, preCards)
	local options = {}
	if not preCards or not next(preCards) then
		local bestComb = combination.craeteBestComb(cards)
		return bestComb.resultArr
	else
	  	local preNode = logic.getCardsNode(preCards)
		
		if preNode.cardType == CT_SINGLE then
			options = logic.getAllSingleStrictly(cards, preNode.keyValue)
		elseif preNode.cardType == CT_DOUBLE then
			options = logic.getAllDoubleCardStrictly(cards, preNode.keyValue)
		elseif preNode.cardType == CT_THREE then
			options = logic.getAllThreeCardLow(cards, preNode.keyValue)
		elseif preNode.cardType == CT_SINGLE_LINE then
			options = logic.getAllLineCard(cards, preNode.keyValue, preNode.amount)
		elseif preNode.cardType == CT_DOUBLE_LINE then
			options = logic.getAllDoubleLineCard(cards, preNode.keyValue, preNode.amount)
		elseif preNode.cardType == CT_THREE_LINE then
			options = logic.getAllPlaneCard(cards, false, false, preNode.keyValue, preNode.amount)
		elseif preNode.cardType == CT_THREE_LINE_TAKE_ONE then
			if preNode.amount == 4 then
				options = logic.getAllThreeCard(cards, true, false, preNode.keyValue)
			else
				options = logic.getAllPlaneCard(cards, true, false, preNode.keyValue, preNode.amount - preNode.amount / 4)
			end
		elseif preNode.cardType == CT_THREE_LINE_TAKE_TWO then
			if preNode.amount == 5 then
				options = logic.getAllThreeCard(cards, false, true, preNode.keyValue)
			else
				options = logic.getAllPlaneCard(cards, false, true, preNode.keyValue, preNode.amount - preNode.amount / 5)
			end
		elseif preNode.cardType == CT_FOUR_LINE_TAKE_ONE then
			options = logic.getAllFourTake(cards, true, false, preNode.keyValue)
		elseif preNode.cardType == CT_FOUR_LINE_TAKE_TWO then
			options = logic.getAllFourTake(cards, false, true, preNode.keyValue)
		elseif preNode.cardType == CT_BOMB_CARD then
			options = logic.getAllBomCard(cards, preNode.keyValue)
		end

		if preNode.cardType < CT_BOMB_CARD then
			local booms = logic.getAllBomCard(cards)
			table.mergeByAppend(options, booms)
		end
	end
	
	return options
end

function combination.getFlowOutCards(cards, preCards, enemy, enemyCards)
	-- record my best combinations
	--combination.initializeCombinations(cards, true)
	--assert(#combination.combinations > 0)
	local enemyCardsAmount = #enemyCards
	local bestComb = util.copyTab(combination.bestComb)
	-- if not combination.judge(bestComb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({bestComb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end
  ----------------to get the beset combs after put cards-----------------------
  	local preNode = logic.getCardsNode(preCards)
	--util.printTable(preNode)
	local options = {}
	local result = nil
	--优先从最佳组合中找
	if preNode.cardType == CT_SINGLE or preNode.cardType == CT_DOUBLE then
		local hashTab = logic.getCardsHashTab(cards)
		local op = {}
		--拆分三带，4带牌型中的“带牌”
		for k, v in pairs(bestComb.resultArr) do
			logic.sparateFromTakes(v, preNode.amount, op, preNode.keyValue)
			if v.cardType == preNode.cardType and v.keyValue > preNode.keyValue then
				table.insert(op, v)
			end
		end
		if preNode.cardType == CT_SINGLE and preNode.keyValue < 13 and hashTab[13] and #hashTab[13] > 1 then
			table.insert(op, logic.getCardsNode({hashTab[13][1]}, CT_SINGLE, 13))
		end
		--升序牌型
		if #op > 1 then
			table.sort(op, function(node1, node2)
				return node1.keyValue < node2.keyValue
			end)
		end
		--有解
		if next(op) then
			result = op[1]
		elseif enemy then
			--自己3手以内出完，或者敌方牌数小于8
			if bestComb.step <= 3 or enemyCardsAmount < 8 then
				-- print('msg:-----coming??')
				-- combination.printCombination({bestComb})
				-- util.printTable(bestComb)
				local tarNode = {}
				for k, v in pairs(bestComb.resultArr) do
					--大于k，并且大于上一家出牌的三带
					if v.cardType == CT_THREE_LINE_TAKE_ONE or v.cardType == CT_THREE_LINE_TAKE_TWO or v.cardType == CT_THREE_LINE or v.cardType == CT_THREE then
						if v.keyValue > preNode.keyValue then--v.keyValue >= 11 and
							if not tarNode.keyValue or tarNode.keyValue < v.keyValue then
								tarNode = util.copyTab(v)
								if tarNode.keyValue == 13 then
									break
								end
							end
						end
					end
				end
				-- 如果有三带XX
				if next(tarNode) then
					--自己一手出完 或者 3手之内出完 或者 敌人只剩6张
					local percent = 0
					--只剩一手并且是2
					if bestComb.step == 1 and tarNode.keyValue >= 11 then
						percent = 100
					--剩下小于三手 则
					-- elseif (bestComb.step <= 1) then
					-- 	percent = 80 + (3 - bestComb.step) * 10
					-- elseif (bestComb.step <= 2) then
					-- 	percent = 60 + (3 - bestComb.step) * 10
					elseif (bestComb.step <= 3) then
						percent = 50 + (4 - bestComb.step) * 10
					elseif (enemyCardsAmount < 8) or logic.getCardType(enemyCards) ~= CT_ERROR then
						percent = 100
					end

					local randPercent = math.random(100)
					if randPercent <= percent then
						if preNode.cardType == CT_SINGLE then
						 	result = logic.getCardsNode(logic.sparateMasterFromTakes(tarNode, 3, 1), CT_SINGLE, k)
						elseif preNode.cardType == CT_DOUBLE then
							result = logic.getCardsNode(logic.sparateMasterFromTakes(tarNode, 3, 2), CT_DOUBLE, k)
						end
					end
				end
			end

			if not result and preNode.cardType == CT_SINGLE then
				if hashTab[14] and hashTab[15] and bestComb.step > 2 then
					if bestComb.step == 3 then
						local mymax
						for i = 13, 1, -1 do
							if hashTab[i] then
								mymax = i
								break
							end
						end
						assert(mymax ~= nil)
						
						local enemyhash = logic.getCardsHashTab(enemyCards)
						
						local hasbigger
						for i = mymax + 1, 13 do
							if enemyhash[i] then
								hasbigger = true
								break
							end
						end
						if hasbigger then
							if enemyCardsAmount < 8 or math.random(1, 100) < 40 then
								result = logic.getCardsNode({140}, CT_SINGLE, 14)
							end
						end
					elseif enemyCardsAmount < 8 or math.random(1, 100) < 40 then
						result = logic.getCardsNode({140}, CT_SINGLE, 14)
					end
				end
			end
		end
	else
		for k, v in pairs(bestComb.resultArr) do
			--三带的先不出(避免有两副或者更多的时候会优先带出大牌)
			if v.cardType < CT_BOMB_CARD and v.cardType ~= CT_THREE_LINE_TAKE_ONE and v.cardType ~= CT_THREE_LINE_TAKE_TWO and 
				v.cardType == preNode.cardType and v.amount == preNode.amount and
			 v.keyValue > preNode.keyValue then-- and v.keyValue - 5 <= preNode.keyValue then
				-- print('msg---------------------------coming??')
				-- util.printTable(v)
				result = v
				break
			end
		end
	end

	if not result then
		if preNode.cardType == CT_SINGLE then
			
			-- --找不到则拆分对二
			-- if result == nil and preNode.keyValue < 13 then
			-- 	local hashTab = logic.getCardsHashTab(cards)
			-- 	--options = logic.getAllSingle(cards, preNode.keyValue)
			-- 	if hashTab[13] ~= nil then
			-- 		result = {keyValue = 13, amount = 1, cardType = CT_SINGLE, cards = {hashTab[13][1]}}
			-- 	end
			-- end

			--还是找不到则拆对子和三条
			if result == nil and preNode.keyValue < 13 then
				options = logic.getAllSingle(cards, preNode.keyValue)
			end

			-- print('msg---------------------------CT_SINGLE')
			-- combination.printResultList(options)
			-- logic.printCards(cards)
			-- 是否要压=- =
		elseif preNode.cardType == CT_DOUBLE then
			--print('msg-------------------------------get options double')
			options = logic.getAllDoubleCard(cards, preNode.keyValue)
			-- print('msg---------------------------CT_DOUBLE')
			-- combination.printResultList(options)
			-- if options and next(options) then
			-- 	resultCards = options[1]
			-- end
		elseif preNode.cardType == CT_THREE then
			options = logic.getAllThreeCard(cards, false, false, preNode.keyValue)
			-- if options and next(options) then
			-- 	combination.printResultList(options)
			-- end
		elseif preNode.cardType == CT_SINGLE_LINE then
			--print('msg-------------------------------get options CT_SINGLE_LINE')
			options = logic.getAllLineCard(cards, preNode.keyValue, preNode.amount)
			--combination.printResultList(options)
			--resultCards = logic.getLineBigger(logic.getCardLogicValue(preCards[1]), #preCards, playersCards[mySeatID])
		elseif preNode.cardType == CT_DOUBLE_LINE then
			options = logic.getAllDoubleLineCard(cards, preNode.keyValue, preNode.amount)
		elseif preNode.cardType == CT_THREE_LINE then
			options = logic.getAllPlaneCard(cards, false, false, preNode.keyValue, preNode.amount)
		elseif preNode.cardType == CT_THREE_LINE_TAKE_ONE then
			
			if preNode.amount == 4 then
				options = logic.getAllThreeCard(cards, true, false, preNode.keyValue)
			else
				options = logic.getAllPlaneCard(cards, true, false, preNode.keyValue, preNode.amount - preNode.amount / 4)
			end
			-- print('msg-------------------------------get options CT_THREE_LINE_TAKE_ONE')
			-- combination.printResultList(options)
			-- logic.printCards(cards)
		elseif preNode.cardType == CT_THREE_LINE_TAKE_TWO then
			if preNode.amount == 5 then
				options = logic.getAllThreeCard(cards, false, true, preNode.keyValue)
			else
				options = logic.getAllPlaneCard(cards, false, true, preNode.keyValue, preNode.amount - preNode.amount / 5)
			end

		elseif preNode.cardType == CT_FOUR_LINE_TAKE_ONE then
			options = logic.getAllFourTake(cards, true, false, preNode.keyValue)
		elseif preNode.cardType == CT_FOUR_LINE_TAKE_TWO then
			options = logic.getAllFourTake(cards, false, true, preNode.keyValue)
		-- elseif preNode.cardType == CT_BOMB_CARD and enemy then
		-- 	options = logic.getAllBomCard(cards, preNode.keyValue)
		end

		local find = false
		local hashTable = logic.getCardsHashTab(cards)
		if enemy and options ~= nil and next(options) ~= nil then
			if preNode.cardType == CT_DOUBLE then
				--如果不是拆的三张则压- -
				for k, v in pairs(options) do
					if #hashTable[v.keyValue] == 2 then
						result = v
						find = true
						break
					end
				end
			elseif preNode.cardType == CT_THREE or preNode.cardType == CT_THREE_LINE_TAKE_ONE or 
				preNode.cardType == CT_THREE_LINE_TAKE_TWO then
				result = options[1]
				find = true
			end
		end

		if not find then
			result = combination.chooseOption(options, bestComb, cards)
		end
	end

	-- if preNode.cardType ~= CT_SINGLE or next(options) ~= nil then
	-- 	result = combination.chooseOption(options, bestComb, cards)
	-- end
	
	if result then
		local temp = util.copyTab(cards)
		util.removeTable(temp, result.cards)
		local nextCT = logic.getCardType(temp)
		-- 如果马上能出完 或者 下一手能出完,直接出
		if #result.cards == #cards or nextCT ~= CT_ERROR then
			return result
		-- 出不完
		else
			--if preNode.cardType == CT_SINGLE or preNode.cardType == CT_DOUBLE or preNode.cardType == CT_THREE or
			--	preNode.cardType == CT_THREE_LINE_TAKE_ONE or preNode.cardType == CT_THREE_LINE_TAKE_TWO or 
			--	preNode.cardType == CT_SINGLE_LINE or preNode.cardType == CT_THREE_LINE_TAKE_TWO then
			
		 	if result and #result.cards < #cards then
				--是队友
				if not enemy then
					--单牌，其他大于Q的不压队友
					--三带带了2之类的牌
					for k, v in pairs(result.cards) do
						if logic.getCardLogicValue(v) > 12 then
							return nil
						end
					end
					-- if preNode.cardType == CT_SINGLE then
					-- 	--大于A的不压队友
					-- 	if result.keyValue > 12 then
					-- 		return nil
					-- 	end
					-- -- 连牌，单 双 三
					-- else
					if preNode.cardType == CT_SINGLE_LINE or preNode.cardType == CT_DOUBLE_LINE or preNode.cardType == CT_THREE_LINE then
						--30%概率压队友
						if math.random(100) < 31 then
							return nil
						end
					--其他牌型
					else--if preNode.cardType == CT_SINGLE then
						--大于Q的牌 98%的概率不压队友
						if result.keyValue > 9 and math.random(100) < 98 then
							return nil
						end
					end	
				else
					-- 对手打出大于A的牌，还有大于等于16张扑克，我打出的大于A的牌
					--单牌
					if preNode.cardType == CT_SINGLE then
						--敌方扑克大于15，且敌人出的牌小于2， 且我方出joker的情况
					 	if enemyCardsAmount > 16 and result.keyValue > 13 and preNode.keyValue < 13 then
					 		if math.random(100) < 81 then
								return nil
							end
					 	end
					elseif preNode.cardType == CT_DOUBLE then
						--敌方扑克大于14，且敌人出的牌大于J， 且我方出大于K的情况
					 	if enemyCardsAmount > 14 and result.keyValue >= 12 and preNode.keyValue > 9 then
					 		if math.random(100) < 71 then
								return nil
							end
					 	end
					elseif preNode.cardType == CT_THREE or	preNode.cardType == CT_THREE_LINE_TAKE_ONE or preNode.cardType == CT_THREE_LINE_TAKE_TWO or
						preNode.cardType == CT_FOUR_LINE_TAKE_ONE or preNode.cardType == CT_FOUR_LINE_TAKE_TWO then
						local takesbig = false
						if preNode.cardType == CT_THREE_LINE_TAKE_ONE then
				            local takes = {}
				            logic.sparateFromTakes(result, 1, takes, 12)
				            if next(takes) then
				            	takesbig = true
				            end
				        elseif preNode.cardType == CT_THREE_LINE_TAKE_TWO then
				            local takes = {}
				            logic.sparateFromTakes(result, 2, takes, 11)
				            if next(takes) then
				            	takesbig = true
				            end
				        end
						--如果我方出的三个2 or 四个2 并且地方出不完的情况 直接不出- -
						if logic.getCardType(enemyCards) == CT_ERROR then
							if result.keyValue == 13 or takesbig then
						 		return nil
						 	end
					 	end
				 	end
				end
			end
		end
	end

	return result
end

function combination.bankerFirst(myComb, cards, enemy1Cards, enemy2Cards)
	combination.recordBestComb(myComb)
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end
	if #comb.resultArr == 1 then
		return comb.resultArr[1]
	elseif #enemy1Cards < 3 or #enemy2Cards < 3 then
		combination.initializeCombinations(cards, true)
		-- get the best comb and put the best cards
		if combination.combinations and next(combination.combinations) then

			for k, v in pairs(combination.combinations) do
				if #v.resultArr > 1 then
					combination.sortOutCardsList(v.resultArr)
				end
				for i = 1, #v.resultArr do
					if (v.resultArr[i].amount ~= #enemy1Cards and v.resultArr[i].amount ~= #enemy2Cards) or (v.resultArr[i].amount >= 3) then
						return v.resultArr[i]
					end
				end
			end
		end

		-- 如果没有找到要出的牌 则出keyValue最大的- -
		assert(combination.combinations and next(combination.combinations))
		local cmb = combination.combinations[1]
		combination.sortOutCardsListByKeyValue(cmb.resultArr, false)

		return cmb.resultArr[1]
	else
		return combination.getFirstOutCards(cards, enemy1Cards, enemy2Cards)
	end
end

function combination.recordBestComb(comb)
	assert(comb ~= nil)
	combination.bestComb = {}
	combination.bestComb = util.copyTab(comb)
end

function combination.craeteBestComb(cards)
	combination.initializeCombinations(cards, true)
	
	return combination.combinations[1]
	--combination.bestComb = util.copyTab(combination.combinations[1])
	-- print('msg:-----coming??')
	-- combination.printCombination({combination.bestComb})
end

function combination.judge(comb, cards)
	local tc = {}
	for k, v in pairs(comb.resultArr) do
		util.merge(tc, v.cards)
	end

	if #tc ~= #cards then return false end
	table.sort(tc, function(card1, card2)
		return card1 < card2
	end)
	for k, v in pairs(cards) do
		if tc[k] ~= v then
			LOG_DEBUG('最佳组合')
			combination.printCombination({comb})

			logic.printCards(tc)
			LOG_DEBUG('card in hand')
			logic.printCards(cards)
			return false
		end
	end
	return true
end

function combination.bankerRemainLess3(cards, bankerCards, couldPass)
	local bankerCardsAmount = #bankerCards
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end
	if #comb.resultArr > 1 then
		combination.sortOutCardsList(comb.resultArr)
	end

	if #bankerCards == 1 then
		local allsingle = true
		for k, v in pairs(comb.resultArr) do
			if v.cardType ~= CT_SINGLE then
				allsingle = false
				break
			end
		end

		if allsingle then
			return comb.resultArr[#comb.resultArr]
		end
	end

	if #comb.resultArr == 2 then
		return combination.chooseOne(comb.resultArr, bankerCards)
	end

	for i = 1, #comb.resultArr do
		if comb.resultArr[i].cardType < CT_BOMB_CARD and comb.resultArr[i].amount ~= bankerCardsAmount then
			return comb.resultArr[i]
		end
	end

	if not couldPass then
		--print('-- 庄家剩余扑克不是1张则出一张')
		-- 庄家剩余扑克不是1张则出一张
		if bankerCardsAmount ~= 1 then
			return {keyValue = logic.getCardLogicValue(cards[1]), amount = 1, cardType = CT_SINGLE, cards = {cards[1]}}
		else
			--print('msg:---------------------bankerCardsAmount == 1')
			-- 如果没有找到要出的牌 则出keyValue最大的- -
			assert(combination.combinations and next(combination.combinations))
			--local cmb = combination.combinations[1]
			combination.sortOutCardsListByKeyValue(comb.resultArr, false)
			return comb.resultArr[1]
		end
	end
end

function combination.friendRemainLess3(cards, friendCards)
	local friendNode = logic.getCardsNode(friendCards)
	if friendNode.cardType ~= CT_ERROR then
		combination.initializeCombinations(cards, true)
		-- get the best comb and put the best cards
		if combination.combinations and next(combination.combinations) then
			for k, v in pairs(combination.combinations) do
				if #v.resultArr > 1 then
					combination.sortOutCardsListByKeyValue(v.resultArr, true)
				end
				for i = 1, #v.resultArr do
					if v.resultArr[i].cardType == friendNode.cardType and v.resultArr[i].keyValue < friendNode.keyValue then
						return v.resultArr[i]
					end
				end
			end
		end
	end
end

function combination.underBankerFirst(myComb, cards, bankerCards, friendCards)
	combination.recordBestComb(myComb)
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end
	local fNode = logic.getCardsNode(friendCards)

	local booms = logic.getAllBomCard(cards)
	local step = combination.boomAndAnyother(booms, cards)

	--如果对家能出完 送对家
	if #comb.resultArr == 1 then
		return comb.resultArr[1]
	elseif fNode.cardType ~= CT_ERROR and fNode.keyValue > 1 and not (next(booms) and step < 2) then
		for k, v in pairs(comb.resultArr) do
			if v.cardType == fNode.cardType and v.keyValue < fNode.keyValue then
				return v
			end
		end
		if fNode.cardType == CT_SINGLE then
			--还是找不到则拆对子和三条
			options = logic.getAllSingleStrictly(cards, 0)
			if options and next(options) and options[1].keyValue < fNode.keyValue then return options[1] end
		elseif fNode.cardType == CT_DOUBLE then
			options = logic.getAllDoubleCardStrictly(cards, 0)
			if options and next(options) and options[1].keyValue < fNode.keyValue then return options[1] end
		end
	elseif #bankerCards < 3 and #friendCards < 3 and #bankerCards ~= #friendCards then
		--先看能否送队友
		local result = combination.friendRemainLess3(cards, friendCards)
		if result then return result end
		--庄家小于3的出牌方式
		result = combination.bankerRemainLess3(cards, bankerCards, true)
		if result then return result end
		--找不到则正常出牌
		return combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
	elseif #friendCards < 3 then
		local result = combination.friendRemainLess3(cards, friendCards)
		if result ~= nil then return result end
		--如果找不到
		if #bankerCards < 3 then
			return combination.bankerRemainLess3(cards, bankerCards, true)
		else
			return combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
		end
	elseif #bankerCards < 3 then
		--不出庄家的牌
		local result = combination.bankerRemainLess3(cards, bankerCards, false)
		if result then return result end
	else
		return combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
	end
end

function combination.upBankerFirst(myComb, cards, bankerCards, friendCards)
	combination.recordBestComb(myComb)
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end

	-- local fNode = logic.getCardsNode(friendCards)

	if #comb.resultArr == 1 then
		return comb.resultArr[1]
	elseif #bankerCards < 3 and #friendCards < 3 and #bankerCards ~= #friendCards then
		--先看能否送队友
		local result = combination.friendRemainLess3(cards, friendCards)
		if result then return result end
		
		--正常出牌
		result = combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
		--如果正常出牌会送走庄家
		local bankNode = logic.getCardsNode(bankerCards)
		if result.cardType == bankNode.cardType and result.keyValue < bankNode.keyValue then
			--庄家小于3的出牌方式
			return combination.bankerRemainLess3(cards, bankerCards, false)
		-- 不会送走则直接出
		else
			return result
		end
	elseif #bankerCards < 3 then
		--print('msg:------------------elseif #bankerCards < 3 then')
		--不出庄家的牌
		local result = combination.bankerRemainLess3(cards, bankerCards, false)
		if result then return result end

		--print('msg:----------------can not find answer')
		--送队友
		-- if #friendCards < 3 then 
		-- 	local result = combination.friendRemainLess3(cards, friendCards)
		-- 	if result then return result end
		-- end
		-- 如果对手剩一张
		--找不到则正常出牌
		return combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
	-- elseif fNode.cardType ~= CT_ERROR and fNode.keyValue > 1 then
	-- 	for k, v in pairs(comb.resultArr) do
	-- 		if v.cardType == fNode.cardType and v.keyValue < fNode.keyValue then
	-- 			return v
	-- 		end
	-- 	end
	-- 	if fNode.cardType == CT_SINGLE then
	-- 		--还是找不到则拆对子和三条
	-- 		options = logic.getAllSingleStrictly(cards, 0)
	-- 		if options and next(options) and options[1].keyValue < fNode.keyValue then return options[1] end
	-- 	elseif fNode.cardType == CT_DOUBLE then
	-- 		options = logic.getAllDoubleCardStrictly(cards, 0)
	-- 		if options and next(options) and options[1].keyValue < fNode.keyValue then return options[1] end
	-- 	end
	elseif #friendCards < 3 then 
		local result = combination.friendRemainLess3(cards, friendCards)
		if result then return result end
		--找不到则正常出牌
		return combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
	else
		return combination.getFirstOutCards(cards, bankerCards, nil, friendCards)
	end
end

function combination.boomAndAnyother(booms, cards)
	local tempCards = util.copyTab(cards)
	for k, v in pairs(booms) do
		util.removeTable(tempCards, v.cards)
	end

	if next(tempCards) ~= nil then-- and logic.getCardType(tempCards) ~= CT_ERROR) or next(tempCards) == nil then
		combination.initializeCombinations(tempCards, true)
		assert(#combination.combinations > 0)
		return combination.combinations[1].step, combination.combinations[1].weight
	else
		return 0,0
	end
end

function combination.PutBoom(banker, cards, preCards, enemy, enemyCards1, enemyCards2, friendCards, couldPass)
	--上一手是火箭直接返回
	local preNode = logic.getCardsNode(preCards)
	if preNode.cardType == CT_MISSILE_CARD then return nil end

	local booms = logic.getAllBomCard(cards)
	if not booms or not next(booms) then
		return nil
	elseif #booms > 1 then
		combination.sortOutCardsListByKeyValue(booms, true)
	end

	--选择比上一手大的炸弹
	local getBoomBigger = function()
		if preNode.cardType == CT_BOMB_CARD then
			for i = 1, #booms do
				if booms[i].keyValue > preNode.keyValue then
					return booms[i]
				end
			end
		else
			return booms[1]
		end
	end
	
	--剩下炸弹带一手或者只剩炸弹
	local step, weight = combination.boomAndAnyother(booms, cards)
	--剩下的牌小于三手，权值大于100 并且是敌人
	if step < 3 and weight > 200 and enemy then
		return getBoomBigger()
	--只剩一手
	elseif step == 1 then
		--是敌人出牌直接出炸弹
        if enemy then
            return getBoomBigger()
            --否则50%概率出炸弹
        else
            if math.random(100) > 50 then
                return getBoomBigger()
            end
        end
    elseif step == 0 then
    	return getBoomBigger()
	end

	--地主出牌
	if banker then
		local enemy1RemainNode = logic.getCardsNode(enemyCards1)
		local enemy2RemainNode = logic.getCardsNode(enemyCards2)
		--庄家出牌 且 庄家剩余扑克小于5张 且不是炸弹
		if (#enemyCards1 <= 4 and enemy1RemainNode.cardType ~= CT_BOMB_CARD and enemy1RemainNode.cardType ~= CT_MISSILE_CARD) then
			if enemy1RemainNode.cardType ~= CT_ERROR then
				return getBoomBigger()
			end
		elseif (#enemyCards2 <= 4 and enemy2RemainNode.cardType ~= CT_BOMB_CARD and enemy2RemainNode.cardType ~= CT_MISSILE_CARD) then
			--如果剩下的能一手出完 并且一定要我压的情况
			if enemy2RemainNode.cardType ~= CT_ERROR then
				return getBoomBigger()
			end
		end
	--农民出牌
	else
		local bankerRemainNode = logic.getCardsNode(enemyCards1)
		--庄家出牌 且 庄家剩余扑克小于5张 且不是炸弹
		if enemy and #enemyCards1 <= 4 and bankerRemainNode.cardType ~= CT_BOMB_CARD then
			--如果剩下的能一手出完 并且一定要我压的情况
			if bankerRemainNode ~= CT_ERROR then
				return getBoomBigger()
			--庄家不能一手出完，并且我是庄家上家则30%概率出炸
			else
				if not couldPass and math.random(100) > 70 then
					return getBoomBigger()
				end
			end
		--else
		end
	end

	--如果能在3手之内出完则炸
	if enemy then
		local percent = 6
		if #combination.bestComb.resultArr <= 3 or combination.bestComb.weight > 1200 then
			percent = 101
		end
		if math.random(100) < percent then
			return getBoomBigger()
		end
	end
end

function combination.enemyRemain1or2(cards, preNode, enemy, enemyNode, result)
	--assert(enemyNode.cardType ~= CT_ERROR)
	if (preNode.cardType <= CT_DOUBLE and preNode.cardType == enemyNode.cardType
	 and preNode.keyValue < enemyNode.keyValue) or (enemy and enemyNode.cardType ~= CT_ERROR) then
		--我没有出牌或者出的牌大不过敌人
		if not result or (result.cardType == preNode.cardType and result.keyValue < enemyNode.keyValue) then
			--combination.initializeCombinations(cards, true)
			--assert(#combination.combinations > 0)
			local bestComb = util.copyTab(combination.bestComb)
			-- if not combination.judge(bestComb, cards) then
			-- 	assert(false)
			-- end
			local options = {}
			if preNode.cardType == CT_SINGLE then
				--优先从最佳组合中找				
				local biggerKey = preNode.keyValue > (enemyNode.keyValue - 1) and preNode.keyValue or (enemyNode.keyValue - 1)
				for k, v in pairs(bestComb.resultArr) do
					if v.cardType == preNode.cardType and v.keyValue > biggerKey then
						return v
					end
				end
				--还是找不到则拆对子和三条
				options = logic.getAllSingleStrictly(cards, biggerKey)
				if not next(options) then
					options = logic.getAllSingleStrictly(cards, preNode.keyValue)
				end
			elseif preNode.cardType == CT_DOUBLE then
				--优先从最佳组合中找
				local biggerKey = preNode.keyValue > (enemyNode.keyValue - 1) and preNode.keyValue or (enemyNode.keyValue - 1)
				for k, v in pairs(bestComb.resultArr) do
					if v.cardType == preNode.cardType  and v.keyValue > biggerKey then
						return v
					end
				end

				options = logic.getAllDoubleCardStrictly(cards, biggerKey)

				if not next(options) then
					options = logic.getAllDoubleCardStrictly(cards, preNode.keyValue)
				end
			end
			if next(options) ~= nil then
				local answer = combination.chooseOption(options, bestComb, cards)
				--找不到答案出最大的
				if not answer then
					for i = #options, 1, -1 do
						if options[i].keyValue > preNode.keyValue then
							return options[i]
						end
					end
				else
					return answer
				end
			end
		end
	end
end

function combination.bankerOutCard(myComb, cards, preCards, enemy, enemyCards1, enemyCards2)
	combination.recordBestComb(myComb)

	local enemyCards = enemyCards1
	if #enemyCards1 > #enemyCards2 then
		enemyCards = enemyCards2
	end
	local result = combination.getFlowOutCards(cards, preCards, enemy, enemyCards)
	if not result then
		result = combination.PutBoom(true, cards, preCards, enemy, enemyCards1, enemyCards2)
	end

	--如果敌人只有一张或者一对,并且我出的牌会放过敌人的情况下
	local enemyNode1 = logic.getCardsNode(enemyCards1)
	local enemyNode2 = logic.getCardsNode(enemyCards2)
	local preNode = logic.getCardsNode(preCards)

	if enemyNode1.amount <= 2 then
		local specialResult1 = combination.enemyRemain1or2(cards, preNode, enemy, enemyNode1, result)
		if specialResult1 then
			return specialResult1
		end
	end

	if enemyNode2.amount <= 2 then
		local specialResult2 = combination.enemyRemain1or2(cards, preNode, enemy, enemyNode2, result)
		if specialResult2 then
			return specialResult2
		end
	end

	--如果只剩两手并且两手都能压上，如果大牌是最大的则压大牌
	local preNode = logic.getCardsNode(preCards)
	local comb = util.copyTab(combination.bestComb)
	if result and #comb.resultArr == 2 then
		local ecards1 = util.copyTab(enemyCards1)
		local ecards2 = util.copyTab(enemyCards2)
		local tempResult = combination.followLessTwo(comb, preNode, util.merge(ecards1, ecards2))
		if tempResult ~= nil then
			return tempResult
		end
	end

	return result
end

function combination.followLessTwo(comb, preNode, enemyCards)
	if comb.resultArr[1].cardType == preNode.cardType and comb.resultArr[1].cardType == comb.resultArr[2].cardType and
		comb.resultArr[1].keyValue > preNode.keyValue and comb.resultArr[2].keyValue > preNode.keyValue then
		for k, v in pairs(comb.resultArr) do
			if logic.maxInCards(v.keyValue, enemyCards) then
				return v
			end
		end

	end
end

function combination.undersideOfBankerOutCard(myComb, cards, preCards, enemy, enemyCards, friendCards)
	combination.recordBestComb(myComb)
	local preNode = logic.getCardsNode(preCards)
	local enemyNode = logic.getCardsNode(enemyCards)
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end

	if #comb.resultArr == 1 and comb.resultArr[1].cardType >= CT_BOMB_CARD and 
		preNode.cardType < CT_BOMB_CARD then
		return comb.resultArr[1]
	elseif not enemy and logic.getCardType(friendCards) ~= CT_ERROR then
		if enemyNode.amount ~= preNode.amount or
		 (preNode.cardType == enemyNode.cardType and preNode.keyValue >= enemyNode.keyValue) then
			return nil
		end
	end
	
	-- if friendCards then
	-- 	local friendNode = logic.getCardsNode(friendCards)
	-- 	--如果上一手牌正好送走下一家则不要
	-- 	if friendNode.cardType == preNode.cardType and preNode.keyValue < friendNode.keyValue then
	-- 		return nil
	-- 	end
	-- end
	local result = combination.getFlowOutCards(cards, preCards, enemy, enemyCards)
	if result then
		-- 是队友并且不能一手出完则不压大于Q的牌
		if not enemy and result.cardType > CT_SINGLE and result.amount ~= #cards and result.keyValue > 10 then
			return nil
		end
	else
		if (preNode.cardType == enemyNode.cardType and preNode.keyValue < enemyNode.keyValue) then
			result = combination.PutBoom(false, cards, preCards, true, enemyCards, nil, friendCards, false)
			if result and not enemy and enemyNode.cardType == CT_SINGLE and 
				combination.getSingleLessAmount(comb, enemyNode.keyValue) > 1 then
				result = nil
			end
		else
			result = combination.PutBoom(false, cards, preCards, enemy, enemyCards, nil, friendCards, true)
		end
	end

	--如果敌人只有一张或者一对,并且我出的牌会放过敌人的情况下
	if enemyNode.amount <= 2 then
		local specialResult = combination.enemyRemain1or2(cards, preNode, enemy, enemyNode, result)
		if specialResult then
			return specialResult
		end
	end

	--队友出的牌，庄家只剩1张
	if not result and not enemy and enemyNode.cardType == CT_SINGLE then
		--我手中只有一张小于庄家的牌，寻找能接过来的牌
		if combination.getSingleLessAmount(comb, enemyNode.keyValue) < 2 then
			return combination.getBiggerWontGenerateSingle(preNode, cards, enemyNode.keyValue)
		end
	end

	--自己出不完永远不压
	if result and not enemy and enemyNode.cardType == CT_SINGLE and 
		combination.getSingleLessAmount(comb, enemyNode.keyValue) > 1 then
		return nil
	end

	--如果只剩两手并且两手都能压上，如果大牌是最大的则压大牌
	if result and #comb.resultArr == 2 then
		local ecards = util.copyTab(enemyCards)
		local tempResult = combination.followLessTwo(comb, preNode, ecards)
		if tempResult ~= nil then
			return tempResult
		end
	end
	
	return result
end

function combination.getSingleLessAmount(comb, kv)
	local lessSingle = 0
	for k, v in pairs(comb.resultArr) do
		if v.cardType == CT_SINGLE and v.keyValue < kv then
			lessSingle = lessSingle + 1
		end
	end

	return lessSingle
end

function combination.getBiggerWontGenerateSingle(preNode, cards, kv)
	local options = {}
	if preNode.cardType == CT_SINGLE then
		if result == nil and preNode.keyValue < 13 then
			options = logic.getAllSingle(cards, preNode.keyValue)
		end
	elseif preNode.cardType == CT_DOUBLE then
		--print('msg-------------------------------get options double')
		options = logic.getAllDoubleCard(cards, preNode.keyValue)
	elseif preNode.cardType == CT_THREE then
		options = logic.getAllThreeCard(cards, false, false, preNode.keyValue)
	elseif preNode.cardType == CT_SINGLE_LINE then
		--print('msg-------------------------------get options CT_SINGLE_LINE')
		options = logic.getAllLineCard(cards, preNode.keyValue, preNode.amount)
	elseif preNode.cardType == CT_DOUBLE_LINE then
		options = logic.getAllDoubleLineCard(cards, preNode.keyValue, preNode.amount)
	elseif preNode.cardType == CT_THREE_LINE then
		options = logic.getAllPlaneCard(cards, false, false, preNode.keyValue, preNode.amount)
	elseif preNode.cardType == CT_THREE_LINE_TAKE_ONE then
		if preNode.amount == 4 then
			options = logic.getAllThreeCard(cards, true, false, preNode.keyValue)
		else
			options = logic.getAllPlaneCard(cards, true, false, preNode.keyValue, preNode.amount - preNode.amount / 4)
		end
	elseif preNode.cardType == CT_THREE_LINE_TAKE_TWO then
		if preNode.amount == 5 then
			options = logic.getAllThreeCard(cards, false, true, preNode.keyValue)
		else
			options = logic.getAllPlaneCard(cards, false, true, preNode.keyValue, preNode.amount - preNode.amount / 5)
		end
	elseif preNode.cardType == CT_FOUR_LINE_TAKE_ONE then
		options = logic.getAllFourTake(cards, true, false, preNode.keyValue)
	elseif preNode.cardType == CT_FOUR_LINE_TAKE_TWO then
		options = logic.getAllFourTake(cards, false, true, preNode.keyValue)
	-- elseif preNode.cardType == CT_BOMB_CARD and enemy then
	-- 	options = logic.getAllBomCard(cards, preNode.keyValue)
	end

	if not options or not next(options) then
		return nil
	end

	for i = 1, #options do
		-- remove the flow cards
		util.removeTable(cards, options[i].cards)
		-- get combs in remaining cards
		combination.initializeCombinations(cards, true)
		-- print('msg:----------------options: ', i)
		-- logic.printCards(options[i].cards)
		-- combination.printCombination(combination.combinations)
		if combination.getSingleLessAmount(combination.combinations[1], kv) < 2 then
			util.merge(cards, options[i].cards)
			return options[i]
		end
		-- reset cards
		util.merge(cards, options[i].cards)
	end
end

function combination.upsideOfBankerOutCard(myComb, cards, preCards, enemy, enemyCards, friendCards)
	combination.recordBestComb(myComb)
	local enemyNode = logic.getCardsNode(enemyCards)
	local preNode = logic.getCardsNode(preCards)
	local comb = util.copyTab(combination.bestComb)
	-- if not combination.judge(comb, cards) then
	-- 	print('最佳组合')
	-- 	combination.printCombination({comb})
	-- 	print('card in hand')
	-- 	logic.printCards(cards)
	-- 	assert(false)
	-- end
	
	if #comb.resultArr == 1 and comb.resultArr[1].cardType >= CT_BOMB_CARD and 
		preNode.cardType < CT_BOMB_CARD then
		return comb.resultArr[1]
	elseif not enemy and logic.getCardType(friendCards) ~= CT_ERROR then
		--如果这张牌不会送走庄家的情况下才不压
		if enemyNode.amount ~= preNode.amount or
		 (preNode.cardType == enemyNode.cardType and preNode.keyValue >= enemyNode.keyValue) then
			return nil
		end
	end

	local result = combination.getFlowOutCards(cards, preCards, enemy, enemyCards)
	-- print('msg:--------------------------------upsideOfBankerOutCard')
	if not result then
		if preNode.cardType == enemyNode.cardType and preNode.keyValue < enemyNode.keyValue then
			result = combination.PutBoom(false, cards, preCards, true, enemyCards, nil, friendCards, false)
			if result and not enemy and enemyNode.cardType == CT_SINGLE and 
				combination.getSingleLessAmount(comb, enemyNode.keyValue) > 1 then
				result = nil
			end
		else
			result = combination.PutBoom(false, cards, preCards, enemy, enemyCards, nil, friendCards, false)
		end
	end
	--如果敌人只有一张或者一对,并且我出的牌会放过敌人的情况下
	if enemyNode.amount <= 2 then
		local specialResult = combination.enemyRemain1or2(cards, preNode, enemy, enemyNode, result)
		if specialResult then
			return specialResult
		end
	end

	--队友出的牌，庄家只剩1张
	if not result and not enemy and enemyNode.cardType == CT_SINGLE then
		--我手中只有一张小于庄家的牌，寻找能接过来的牌
		if combination.getSingleLessAmount(comb, enemyNode.keyValue) < 2 then
			return combination.getBiggerWontGenerateSingle(preNode, cards, enemyNode.keyValue)
		end
	end

	--自己出不完永远不压
	if result and not enemy and enemyNode.cardType == CT_SINGLE and 
		combination.getSingleLessAmount(comb, enemyNode.keyValue) > 1 then
		return nil
	end

	--如果只剩两手并且两手都能压上，如果大牌是最大的则压大牌
	if result and #comb.resultArr == 2 then
		local ecards = util.copyTab(enemyCards)
		local tempResult = combination.followLessTwo(comb, preNode, ecards)
		if tempResult ~= nil then
			return tempResult
		end
	end

	return result
end

function combination.sortOutCardsList(list)
	if list and #list > 1 then
		table.sort(list, function(node1, node2)

			if node1.keyValue == node2.keyValue then
				return node1.amount > node2.amount
			else
				return node1.keyValue < node2.keyValue
			end
			-- if node1.cardType == node2.cardType then
			-- 	-- 先出起始值小的
			-- 	return node1.keyValue < node2.keyValue					
			-- end
			-- --均不是四带牌型
			-- if node1.cardType ~= CT_FOUR_LINE_TAKE_ONE and node1.cardType ~= CT_FOUR_LINE_TAKE_TWO and 
			-- 	node2.cardType ~= CT_FOUR_LINE_TAKE_ONE and node2.cardType ~= CT_FOUR_LINE_TAKE_TWO then
			-- 	-- 起始扑克均小于10
			-- 	if node1.keyValue < 8 and node2.keyValue < 8 then
			-- 		-- 先出扑克多的
			-- 		if node1.amount == node2.amount then
			-- 			-- 先出起始值小的
			-- 			return node1.keyValue < node2.keyValue
			-- 		else
			-- 			return node1.amount > node2.amount
			-- 		end
			-- 	else
			-- 		--先出小的
			-- 		return node1.keyValue < node2.keyValue
			-- 	end
			-- else
			-- 	--至少有一副是4带牌型
			-- 	--另一幅牌大于3张则出
			-- 	--if node1
			-- 	if node1.cardType ~= CT_FOUR_LINE_TAKE_ONE and node1.cardType ~= CT_FOUR_LINE_TAKE_TWO then
			-- 		return node1.amount > 3
			-- 	elseif node2.cardType ~= CT_FOUR_LINE_TAKE_ONE and node2.cardType ~= CT_FOUR_LINE_TAKE_TWO then
			-- 		return node1.amount <= 3
			-- 	end
			-- end
		end)
	end
end

function combination.sortOutCardsListByKeyValue(list, ascent)
	if ascent then
		table.sort(list, function(node1, node2)
			return node1.keyValue < node2.keyValue
		end)
	else
		table.sort(list, function(node1, node2)
			return node1.keyValue > node2.keyValue
		end)
	end
end

--combination={resultArr = {{keyValue, amount, cards}}, step, weight}
function combination.doOrResetDfs(cards, resultCards, comb, reset)
	if not reset then
		cards = util.removeTable(cards, resultCards.cards)
		-- table.insert(comb.resultArr, resultCards)
		-- comb.step = comb.step + 1
		-- comb.weight = comb.weight + logic.getCardsWeight(resultCards.cards, resultCards.cardType)
		combination.addNode2Comb(comb, resultCards)
	else
		--cards = util.removeTable(cards, resultCards.cards)
		--table.insert(comb.resultArr, resultCards)
		cards = util.merge(cards, resultCards.cards)
		table.remove(comb.resultArr, #comb.resultArr)
		comb.step = comb.step - 1
		comb.weight = comb.weight - resultCards.weight
	end
end

function combination.addNode2Comb(comb, node)
	table.insert(comb.resultArr, node)
	comb.step = comb.step + 1
	--util.printTable(node)
	comb.weight = comb.weight + node.weight --logic.getCardsWeight(node.cards, node.cardType)
end

function combination.sortCombinations()
	if combination.combinations ~= nil and next(combination.combinations) ~= nil then
		table.sort(combination.combinations, function(node1, node2)
			if node1.step == node2.step then
				return node1.weight > node2.weight
			else
				--if math.abs(node1.weight - node2.weight) < 5
				return node1.step < node2.step
			end
		end)
	end
end

function combination.cardInCards(originCards, compareCard)
    for k, v in pairs(originCards) do
        if v == compareCard then
            return true
        end
    end
    return false
end

function combination.cardsInCards(originList, compareCards)
    for k, v in pairs(compareCards) do
        for k1, v1 in pairs(originList) do
            if combination.cardInCards(v1.cards, v) then
                return true
            end
        end
    end

    return false
end

function combination.getAllFirstCards(cards)
	local cmbs = {}
	local allSingleLine = logic.getAllLineCard(cards)
	if allSingleLine then
		cmbs = util.merge(cmbs, allSingleLine)
	end

	local allDoubleLine = logic.getAllDoubleLineCard(cards)
	if allDoubleLine then
		cmbs = util.merge(cmbs, allDoubleLine)
	end

	local allPlane = logic.getAllPlaneCard(cards)
	if allPlane then
		cmbs = util.merge(cmbs, allPlane)
	end

	local allPlaneTakeOne = logic.getAllPlaneCard(cards, true)
	if allPlaneTakeOne then
		cmbs = util.merge(cmbs, allPlaneTakeOne)
	end

	local allPlaneTakeTwo = logic.getAllPlaneCard(cards, false, true)
	if allPlaneTakeTwo then
		cmbs = util.merge(cmbs, allPlaneTakeTwo)
	end
	
	local allBoom = logic.getAllBomCard(cards)
	if allBoom then
		cmbs = util.merge(cmbs, allBoom)
	end

	-- local allFourTakeOne = logic.getAllFourTake(cards, true, false, 0)
	-- if allFourTakeOne then
	-- 	cmbs = util.merge(cmbs, allFourTakeOne)
	-- end

	-- local allFourTakeTwo = logic.getAllFourTake(cards, false, true, 0)
	-- if allFourTakeTwo then
	-- 	cmbs = util.merge(cmbs, allFourTakeTwo)
	-- end

	local allThreeTakeOne = logic.getAllThreeCard(cards, true)
	if allThreeTakeOne then
		cmbs = util.merge(cmbs, allThreeTakeOne)
	end

	local allThreeTakeTwo = logic.getAllThreeCard(cards, false, true)
	if allThreeTakeTwo then
		cmbs = util.merge(cmbs, allThreeTakeTwo)
	end

	return cmbs
end

function combination.makeComb(resultList, container)
	if not resultList or not next(resultList) then return end
	local container = container or {}
	for k, v in pairs(resultList) do
		table.insert(container, {resultArr = {v}, step = 1, weight = logic.getCardsWeight(v.cards, v.cardType)})
	end
end

function combination.reslutInResults(list, node)
	for k, v in pairs(list) do
		if v.cardType == node.cardType and v.keyValue == node.keyValue and #v.cards == #node.cards then
			return true
		end
	end
	return false
end

function combination.compareForDebug(combs)
	if combs and #combs.resultArr == 2 then
		-- Q K A
		if combs.resultArr[1].amount == 6 and combs.resultArr[1].cardType == CT_DOUBLE_LINE and
			-- 4/5/6/7/8
			combs.resultArr[2].amount == 5 and combs.resultArr[2].cardType == CT_SINGLE_LINE and combs.resultArr[2].keyValue == 2 then
			--combs.resultArr[3].cardType == CT_THREE_LINE_TAKE_ONE and combs.resultArr[3].keyValue == 1 and logic.getCardLogicValue(combs.resultArr[3].cards[4]) == 2 then
			return true
		end
	end
end

-- 得到最佳组合(需要出的次数最少的组合)
function combination.getBestCombination(pos, cards, comb, firstPutCards)
	if combination.minStep < comb.step then return end

	if not firstPutCards or not next(firstPutCards) then
		firstPutCards = combination.getAllFirstCards(cards)
		table.sort(firstPutCards, function(node1, node2)
			return node1.amount > node2.amount
		end)
	end

	if firstPutCards and next(firstPutCards) and pos <= #firstPutCards then
		for i = pos, #firstPutCards do
			--没有用到相同的卡牌则继续
			if not combination.cardsInCards(comb.resultArr, firstPutCards[i].cards) then
				-- modify
				table.insert(comb.resultArr, firstPutCards[i])
				comb.step = comb.step + 1
				comb.weight = comb.weight + firstPutCards[i].weight
				-- copy cards
				local tempCards = util.copyTab(cards)
				util.removeTable(tempCards, firstPutCards[i].cards)
				combination.getBestCombination(i + 1, tempCards, comb, firstPutCards)
				-- reset
				table.remove(comb.resultArr, #comb.resultArr)
				comb.step = comb.step - 1
				comb.weight = comb.weight - firstPutCards[i].weight
			end
		end
	end

	local tempComb = util.copyTab(comb)
	-- delete used cards
	for k, v in pairs(comb.resultArr) do
		--logic.printCards(v.cards)
		util.removeTable(cards, v.cards)
	end
	if #cards > 0 then
		local hashTab = logic.getCardsHashTab(cards)
		for k, v in pairs(hashTab) do
			if #v == 4 then
				--CT_BOMB_CARD
				combination.addNode2Comb(tempComb, logic.getCardsNode(util.copyTab(v), CT_BOMB_CARD, k))
			elseif #v == 3 then
				--CT_THREE
				combination.addNode2Comb(tempComb, logic.getCardsNode(util.copyTab(v), CT_THREE, k))
			elseif  #v == 2 then
				--
				combination.addNode2Comb(tempComb, logic.getCardsNode(util.copyTab(v), CT_DOUBLE, k))
			elseif  #v == 1 then
				combination.addNode2Comb(tempComb, logic.getCardsNode(util.copyTab(v), CT_SINGLE, k))
			else
				logic.printCards(cards, true)
				LOG_DEBUG('msg:---------------key:%s   vlen:%s ', tostring(k), tostring(#v))
				assert(false)
			end

			if tempComb.step > combination.minStep then
				return
			end
		end
	end
	--combination.stepWeight[tempComb.step] = tempComb.weight
	if combination.minStep > tempComb.step then
		combination.minStep = tempComb.step
	end

	table.insert(combination.combinations, tempComb)
end

function combination.getTrustOutCards(cards, preCards)
	-- LOG_DEBUG('msg:-------------------cards in hand')
	-- logic.printCards(cards, true)
	-- logic.printMachineCards(cards, true)

  	local preNode = nil
  	if preCards then
  -- 		LOG_DEBUG('msg:-------------------pre cards')
		-- logic.printMachineCards(preCards, true)
		-- logic.printCards(preCards, true)

  		preNode = logic.getCardsNode(preCards)
  	else
  		local temp = logic.getCardsNode(cards)
  		if temp.cardType ~= CT_ERROR then
  			return temp
  		end

		local hashTab = logic.getCardsHashTab(cards)

		for k = 1, 15 do
			if hashTab[k] then
				return logic.getCardsNode(util.copyTab(hashTab[k]), nil, k)
			end
		end
		return nil
  	end
	--util.printTable(preNode)
	local options = {}
	local result = nil
	-- local hashTab = logic.getCardsHashTab(cards)

-- 	getAllSingleEX
-- 
	if preNode.cardType == CT_SINGLE then
		options = logic.getAllSingleEX(cards, preNode.keyValue, 1)
		if #options < 1 then
			util.merge(options, logic.getAllSingleEX(cards, preNode.keyValue, 2))
			if #options < 1 then
				util.merge(options, logic.getAllSingleEX(cards, preNode.keyValue, 3))
			end
		end
	elseif preNode.cardType == CT_DOUBLE then
		options = logic.getAllDoubleCardEX(cards, preNode.keyValue, 2)
		if #options < 1 then
			util.merge(options, logic.getAllDoubleCardEX(cards, preNode.keyValue, 3))
		end
		-- options = logic.getAllDoubleCard(cards, preNode.keyValue)
	elseif preNode.cardType == CT_THREE then
		options = logic.getAllThreeCard(cards, false, false, preNode.keyValue)
	elseif preNode.cardType == CT_SINGLE_LINE then
		options = logic.getAllLineCard(cards, preNode.keyValue, preNode.amount)
	elseif preNode.cardType == CT_DOUBLE_LINE then
		options = logic.getAllDoubleLineCard(cards, preNode.keyValue, preNode.amount)
	elseif preNode.cardType == CT_THREE_LINE then
		options = logic.getAllPlaneCard(cards, false, false, preNode.keyValue, preNode.amount)
	elseif preNode.cardType == CT_THREE_LINE_TAKE_ONE then
		if preNode.amount == 4 then
			options = logic.getAllThreeCard(cards, true, false, preNode.keyValue)
		else
			options = logic.getAllPlaneCard(cards, true, false, preNode.keyValue, preNode.amount - preNode.amount / 4)
		end
	elseif preNode.cardType == CT_THREE_LINE_TAKE_TWO then
		if preNode.amount == 5 then
			options = logic.getAllThreeCard(cards, false, true, preNode.keyValue)
		else
			options = logic.getAllPlaneCard(cards, false, true, preNode.keyValue, preNode.amount - preNode.amount / 5)
		end
	elseif preNode.cardType == CT_FOUR_LINE_TAKE_ONE then
		options = logic.getAllFourTake(cards, true, false, preNode.keyValue)
	elseif preNode.cardType == CT_FOUR_LINE_TAKE_TWO then
		options = logic.getAllFourTake(cards, false, true, preNode.keyValue)
	end

	if options ~= nil and next(options) ~= nil then
        return options[1]
    end

	-- local hashTable = logic.getCardsHashTab(cards)
	-- local preNode = logic.getCardsNode(preCards)
	if preNode.cardType == CT_MISSILE_CARD then return nil end
	local booms
	if preNode.cardType ~= CT_BOMB_CARD then
		booms = logic.getAllBomCard(cards)
	else
		booms = logic.getAllBomCard(cards, preNode.keyValue)
	end

	if not booms or not next(booms) then
		return nil
	elseif #booms >= 1 then
		return booms[1]
	end

	return result
end

local skynet = require "skynet"
require "functions"
-- local logic = require 'logic'
-- local combination = require 'combination'
local _game_prop = require 'game_prop'
local crypt = require "crypt"
local _base64decode = crypt.base64decode
local _room_cards_create = require 'room_cards_create'
local _gold_change_reason_enum = require "gold_change_reason"
local _cfg
local _dynamic_cfg

local isMatch
local CT_BOMB_CARD =			11 	--炸弹
local CT_MISSILE_CARD =			12	--王炸

local TIME = 16 * 100
local _play_time = 16 * 100
local _call_double_time = 6 * 100
local DELAY = 100

local sid
local starttime
local delaytime 
local gamestatus -- 100开始游戏 0 开始发牌 1叫庄 2 出牌 3 检查是否结束 4 加倍 255 空闲状态
local asktimes
local score
local odds
local master
local lastcards
local lastseatid
local winner
local cardtable
local players
local basegold
local played_seatids = {} --用来记录出过牌的玩家，用于计算春天反春天
local huojiancnt = 0 -- 用来记录火箭的个数
local zhadancnt = 0 -- 用来记录炸弹的个数
local _personalgame
local _re_shuffle_count = 0
local _game_start_time --游戏开始时间
local _max_game_time = 100 * 60 * 15--15 * 60 * 100 -- 最大游戏时长~！
local _minscore

local _end_game_time = 0
local _match_restart_time = 100
local _personal_restart_time = 700
local game = {}
local _kickbacks
local _roomtype
local _remain_cards = {}
local _guesscards_mutiple = {
	[1] = 1.2,
	[2] = 3,
	[3] = 6,
	[4] = 15,
	[5] = 20,
	[6] = 100,
}

local _doubled = {}
local _double_price
local _double_limit

local _play_op_cnt = {}
local _master_cards = {}

local _face_use = {item = 0, gold = 0, freeze = 0}

local _special_ct = {}
local _defaultOdds
local _round1lottery
local _redispool
local _callbanker2

local function setTick(delay, from)
	starttime = skynet.now()
	-- LOG_DEBUG('tableid:%d setTick  delay：%d   from: %s', skynet.self(), delay, from)
	if not delay or delay <= 0  then
		LOG_ERROR('tableid:%d !!!!!!!!!!!!!!!!!!!!!!setTick  delay：%d   from: %s', skynet.self(), delay, from)
		delay = 100
	end
	delaytime = delay
end

local function cancelTick(from)
	-- if from then
	-- 	LOG_DEBUG('tableid:%d cancelTick from: %s', skynet.self(), from)
	-- end
	delaytime = 0
end

local function sent_msg(seatid, msgname, msg, order)
	game.sent_msg2(seatid, msgname, msg, order)
end

local function gamelog(msg, cards)
	-- local str = ''
	-- if cards and type(cards) == 'table' and next(cards) then
	-- 	for i = 1, #cards do
	-- 		str = string.format('%s %d', str, cards[i])
	-- 	end
	-- end

	-- LOG_DEBUG('tableid:%d %s', skynet.self(), msg..str)
end

local function checkxplayer()
	local sidx
	for k, v in pairs(players) do
		if v.sflag and v.sflag ~= 0 then
			if v.sflag > 0 then
				sidx = k
			else
				for k1, v1 in pairs(players) do
					if k1 ~= k then
						sidx = k1
						break
					end
				end
			end
			cardtable, _master_cards = logic.createCardsGroupXplayer(sidx)
			logic.printCards(cardtable[sidx], true)
			return true
		end
	end
end

local function allrobot()
	local isallrobot = true
	for k, v in pairs(players) do
		if not v.isrobot then
			isallrobot = false
			break
		end
	end
	return isallrobot
end

local function shuffle()
	if checkxplayer() then return end
	local shufflecnt = 0
	local cfg = _room_cards_create[_roomid] or {}
	local r = math.random(1, 100)
	local percent = 0
	for i = 1, #cfg do
		percent = percent + cfg[i][3]
		if r <= percent then
			shufflecnt = math.random(cfg[i][1], cfg[i][2])
			break
		end
	end
	if shufflecnt > 0 and not isMatch then
		cardtable, _master_cards = logic.createCardsGroupHeap(shufflecnt)
	else
		if isMatch then
			if allrobot() then
				cardtable, _master_cards = logic.createCardsGroupHeap(4)
			else
				cardtable, _master_cards = logic.createCardsGroup(4, 0)
			end
			return
		end

		local percent = math.random(1000)
		if (_roomid == 1001 or isMatch) and percent < 300 then
			cardtable, _master_cards = logic.createCardsNormal()
		else
			if _roomid == 1003 or _roomid == 1005 then
				cardtable, _master_cards = logic.createCardsGroup(3, 2)
			elseif _roomid == 1000 or _roomid == 1004 then
				cardtable, _master_cards = logic.createCardsGroup(3, 1)
			else
				cardtable, _master_cards = logic.createCardsGroup()
			end
		end
	end
end

--检查cards1能否压住cards2
local function check(cards1,cards2)
	-- LOG_DEBUG('msg:--------------------检查cards1能否压住cards2')
	-- logic.printCards(cards1, true, 'cards1  ')
	-- logic.printCards(cards2, true, 'cards2  ')
	local ct1, keyValue1 =logic.getCardType(cards1)
	if ct1 == CT_MISSILE_CARD then
		return true, ct1
	end
	
	local ct2, keyValue2 =logic.getCardType(cards2)
	if ct2 == CT_MISSILE_CARD then
		return false, ct1
	end

	if ct2 ~= CT_BOMB_CARD and ct1 == CT_BOMB_CARD then
		-- if keyValue1 > keyValue2 then
			return true, ct1
		-- else
			-- return false,ct1
		-- end
	end

	if ct1 == ct2 and #cards1 == #cards2 then
		return keyValue1 > keyValue2, ct1
	end
	return false,ct1
end
--判断si号玩家有没有卡牌cards，如果有，则从该玩家手上删除这些卡牌并返回，如果没有，则返回nil
local function check_cards(si, cards)
	if si < 1 or si > 4 then return false end
	
	for i = 1, #cards do
		index = table.keyof(cardtable[si], cards[i])
		if not index then
			return false
		else
			table.remove(cardtable[si], index)
		end
	end
	return true
end

local function settle_guesscards_account(cards)
	local ct, hasJQK, hasJork, haspair = logic.getGuessCardsType(cards)
	local wingold = 0
	gamelog(string.format('猜牌结算，牌型:%d ', ct), cards)
	local pguess = {}
	for k, v in pairs(players) do
		wingold = 0
		if v.guessRecord then
			pguess[k] = v.uid
			--买中
			if v.guessRecord[ct] then
				gamelog(string.format('uid:%d  猜中牌型: %d', v.uid, ct))
				wingold = wingold + _guesscards_mutiple[ct] * v.guessRecord[ct]
			end

			--同花顺，买了顺子或者同花
			if ct == 6 then
				if v.guessRecord[5] then
					gamelog(string.format('uid:%d  猜中牌型: 5', v.uid))
					wingold = wingold + _guesscards_mutiple[5] * v.guessRecord[5]
				end

				if v.guessRecord[4] then
					gamelog(string.format('uid:%d  猜中牌型: 4', v.uid))
					wingold = wingold + _guesscards_mutiple[4] * v.guessRecord[4]
				end
			end

			--牌型不是hasJQK ，买了有JQK
			if ct ~= 1 and v.guessRecord[1] and hasJQK then
				gamelog(string.format('uid:%d  猜中牌型: 1', v.uid))
				wingold = wingold + _guesscards_mutiple[1] * v.guessRecord[1]
			end

			-- 牌型不是hasjork，买了hasjork
			if ct ~= 3 and v.guessRecord[3] and hasJork then
				gamelog(string.format('uid:%d  猜中牌型: 3', v.uid))
				wingold = wingold + _guesscards_mutiple[3] * v.guessRecord[3]
			end

			-- 牌型不是haspair，买了haspair
			if ct ~= 2 and v.guessRecord[2] and haspair then
				gamelog(string.format('uid:%d  猜中牌型: 2', v.uid))
				wingold = wingold + _guesscards_mutiple[2] * v.guessRecord[2]
			end

			if wingold > 0 then
				-- wingold = v.guessRecord[ct] * _guesscards_mutiple[ct]
				wingold = math.ceil(wingold * 0.95)
				if isMatch or _roomtype == 'diamond' then
					skynet.fork(game.call_dbs_by_logic, 'add_gold', v.uid, wingold, _gold_change_reason_enum.FromGuessCards, _roomid)

					if _roomtype == 'diamond' then
						v.gold = v.gold or 0
						v.gold = v.gold + wingold
					elseif isMatch then
						v.money = v.money or 0
						v.money = v.money + wingold
					end
				else
					if not game.update_freeze_gold(v, wingold) then
						LOG_ERROR('msg:--uid:%d--game.update_freeze_gold(v, wingold:%d) failed!', v.uid or 0, wingold or 0)
					end
					v.gold = v.gold or 0
					v.gold = v.gold + wingold
				end
				
				sent_msg(0, "game.OperateRep", {seatid = k, optype = 4, params = {wingold}})
				-- if wingold > 1000000 and v.nickname then
				-- 	local msg = string.format('0:恭喜 %s 在猜底牌小游戏中赢得%d万金币', _base64decode(v.nickname), math.ceil(wingold / 10000))
				-- 	skynet.fork(pcall, skynet.call, _redispool, "lua", "execute", "zadd", "MatchChampionMsgPool", os.time(), msg)
				-- end
			else
				sent_msg(k, "game.OperateRep", {seatid = k, optype = 4})
			end
			v.guessRecord = nil
		end
	end

	game.clearGuessCards(pguess)
end

local function delCards(seatid, cards)
	local t
	for k, v in pairs(cards) do
		t = math.floor(v / 10)
		_remain_cards[seatid][t] = _remain_cards[seatid][t] - 1
	end
end

local function resetRemainCards()
	for j = 1, 3 do
		_remain_cards[j] = {}
		
		for i = 1, 13 do
			_remain_cards[j][i] = 4
		end
		_remain_cards[j][14] = 1
		_remain_cards[j][15] = 1

		delCards(j, cardtable[j])
	end
end

local function set_master(mid)
	master = mid
	sent_msg(0,"game.SetScore",{score = score, seatid = master, ismaster = true})
	table.mergeByAppend(cardtable[master], _master_cards)
	delCards(master, _master_cards)
	if not cardtable or not cardtable[1] then
		if isMatch then
			game.end_game({0,0,0})
		else
			game.kick_out_all(0, _roomtype == 'diamond')
		end
		return
	end
	table.sort(cardtable[1])
	table.sort(cardtable[2])
	table.sort(cardtable[3])
	gamelog(string.format('确定庄家uid:%s  底牌: ', players[master].uid), _master_cards)
	for i = 1, 3 do
		if cardtable[i][#cardtable[i]] == 150 and cardtable[i][#cardtable[i] - 1] == 140 then
			if not players[i] then
				LOG_DEBUG("set_master")
				luadump(players)
				if isMatch then
					game.end_game({0,0,0})
				else
					game.kick_out_all(0, _roomtype == 'diamond')
				end
				return
			end
			players[i].missile_sent = true
			-- break
		end
		if players[i] then
			if i == mid then
				players[i].role = 2
			else
				players[i].role = 1
			end
		end
	end

	sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
	sent_msg(0,"game.ShowCard",{seatid = master, cardids = _master_cards})
	settle_guesscards_account(_master_cards)
end

local function next_player()
	-- _last_seatid = sid
	sid = sid + 1
	if sid > 3 then sid = 1 end
end

local function check_end()
	if gamestatus ~= 2 then
		return false
	end
	gamestatus = 3
	for i=1,3 do
		if #(cardtable[i]) < 1 then
			gamelog(string.format('uid:%d 出完,获胜', players[i].uid))
			winner = i;
			return true;
		end
	end
	return false
end

local function end_game_op(chge)
	_end_game_time = skynet.now()
	-- if isMatch then
	game.end_game(chge, nil, nil, _face_use, _special_ct)
	-- else
		-- game.end_game(chge, _face_use_item)
	-- end
	-- LOG_DEBUG('\n\nend_game_op?? coming???')
	_game_start_time = nil
	if not isMatch and not _personalgame then
		game.kick_out_all()
		-- game.free_table()
	end
	gamestatus = 255
end

local function diamond_end_game()
	sid = winner
	local chge = {}
	local flag = (winner == master) and 1 or -1
	local spring = 0
	if flag == 1 then
		-- 春天,地主赢，并且出过牌的人只有一个
		local played_count = 0 -- 出过牌的人的个数
		if played_seatids[1] and played_seatids[1] > 0 then
			played_count = played_count + 1
		end
		if played_seatids[2] and played_seatids[2] > 0 then
			played_count = played_count + 1
		end
		if played_seatids[3] and played_seatids[3] > 0 then
			played_count = played_count + 1
		end
		if played_count == 1 then
			spring = 1
			odds = odds * 2
			if odds > maxodds then odds = maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	else
		-- 反春天，农民赢，并且地主只出过一手牌
		if played_seatids[master] and played_seatids[master] == 1 then
			spring = 1
			odds = odds * 2
			if odds > maxodds then odds = maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	end

	local s = basegold * odds
	if s * 2 > players[master].diamond then
		s = math.ceil(players[master].diamond / 2)
	end
	-- local role = {}
	local fsid = {}
    for i = 1, 3 do
      if i ~= master then
      	-- role[i] = 1
        chge[i] = -s * flag
        if chge[i] + players[i].diamond < 0 then
        	chge[i] = -players[i].diamond
        end
        table.insert(fsid, i)
      -- else
      	-- role[i] = 2
      end
    end

    chge[master] = -(chge[fsid[1]] + chge[fsid[2]])

	for k, v in pairs(_play_op_cnt) do
		if v.offline >= 5 then
			v.punish = true
		end
	end
	
	if chge[master] > 0 then
		if _play_op_cnt[fsid[1]].punish and not _play_op_cnt[fsid[2]].punish then
			chge[fsid[1]] = chge[fsid[1]] + chge[fsid[2]]
			chge[fsid[2]] = 0
			if chge[fsid[1]] + players[fsid[1]].diamond < 0 then --惩罚的玩家不够扣
				chge[fsid[2]] = chge[fsid[1]] + players[fsid[1]].diamond -- 剩余部分由另一个玩家承担
				chge[fsid[1]] = -players[fsid[1]].diamond -- 惩罚玩家扣完
			end
		elseif _play_op_cnt[fsid[2]].punish and not _play_op_cnt[fsid[1]].punish then
			chge[fsid[2]] = chge[fsid[2]] + chge[fsid[1]]
			chge[fsid[1]] = 0
			if chge[fsid[2]] + players[fsid[2]].diamond < 0 then
				chge[fsid[1]] = chge[fsid[2]] + players[fsid[2]].diamond
				chge[fsid[2]] = -players[fsid[2]].diamond
			end
		end
	end

	for k, v in pairs(players) do
		if _play_op_cnt[k].punish and chge[k] > 0 then
			chge[k] = 0
		end

		if v.subcontinuouswin then
			pcall(skynet.call, _redispool, "lua", "execute", "DECR", string.format("continuouswin%d", v.uid))
		end
	end

	sent_msg(0,"game.UpdateGameInfo", {params2={spring, huojiancnt, zhadancnt}})
	local exkickback = {}
	for i = 1, 3 do
		exkickback[i] = 0
		if chge[i] > 0 then
			if odds >= 4 then
				chge[i] = chge[i] - 4
				exkickback[i] = 4
			elseif odds >= 2 then
				chge[i] = chge[i] - 2
				exkickback[i] = 2
			end
			if chge[i] < 0 then chge[i] = 0 end
		end

		sent_msg(0, "game.SetCards", {seatid = i, cardids = cardtable[i]})
	end

	-- _end_game_time = skynet.now()
	game.diamond_end_game(chge, _face_use, _special_ct, {}, exkickback)
	gamestatus = 255
	_game_start_time = nil
	game.kick_out_all()
end

local _max_normal_play_sec = 600 --正常出牌的最大时间
-- local _punish_shorten = {[20] = 12, [45] = 8, [90] = 5}
-- local _delay_play = {}
local function record_delay_play_in_match(seatid)
	if not isMatch then return end
	local delay = skynet.now() - starttime
	if delay <= _max_normal_play_sec then return end
	players[seatid].delay_play_sec = players[seatid].delay_play_sec or 0
	players[seatid].delay_play_sec = players[seatid].delay_play_sec + delay
end

local function get_delay_play_time(seatid)
	if not isMatch or not seatid or not players[seatid] then return end
	local ds = players[seatid].delay_play_sec
	if not isMatch or not ds or ds < 2500 then return end
	if ds >= 3000 and ds < 4500 then
		return 1300
	elseif ds >= 4500 and ds < 12000 then
		return 900
	elseif ds >= 12000 then
		return 600
	end
end

local function clear_good_delay_play_time()
	if not isMatch then return end
	for k, v in pairs(players) do
		if v.delay_play_sec and v.delay_play_sec < 2000 then
			v.delay_play_sec = 0
		end
	end
end

local function end_game()
	-- if not isMatch and not _personalgame then
	-- 	for k, v in pairs(players) do
	-- 		v.gold = v.gold - _kickbacks
	-- 	end
	-- end

	sid = winner
	local chge = {}
	
	local flag;
	if winner == master then
		--地主赢
		flag = 1
	else
		--农民赢
		flag = -1
	end

	local chuntian = 0
	if flag == 1 then
		-- 春天,地主赢，并且出过牌的人只有一个
		local played_count = 0 -- 出过牌的人的个数
		if played_seatids[1] and played_seatids[1] > 0 then
			played_count = played_count + 1
		end
		if played_seatids[2] and played_seatids[2] > 0 then
			played_count = played_count + 1
		end
		if played_seatids[3] and played_seatids[3] > 0 then
			played_count = played_count + 1
		end
		if played_count == 1 then
			chuntian = 1
			odds = odds * 2
			if odds > maxodds then odds = maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	else
		-- 反春天，农民赢，并且地主只出过一手牌
		if played_seatids[master] and played_seatids[master] == 1 then
			chuntian = 1
			odds = odds * 2
			if odds > maxodds then odds = maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	end

	  local s = {}  
  local fsid = {}
  for i = 1, 3 do
    _doubled[i] = _doubled[i] or 1
    if i ~= master then
      table.insert(fsid, i)
    end
    s[i] = basegold * odds 
  end
    local maxlimit
    if not _cfg.allownegtive then
      for i = 1, 3 do
        if i ~= master then
          s[i] = s[i] * _doubled[master] * _doubled[i]
        end
      end
      
      local maxlimit = players[master].gold
      if flag == 1 then
        --庄家 加倍之后最多可以赢身上金币的两倍
        if _doubled[master] == 2 then
          maxlimit = players[master].gold * 4
        end

        for i = 1, 3 do
          if i ~= master then
            if s[i] > players[i].gold then
              s[i] = players[i].gold
            end
          end
        end

        local totalwin = s[fsid[1]] + s[fsid[2]]
        if totalwin > maxlimit then
          totalwin = maxlimit
          for i = 1, 2 do
            s[fsid[i]] = math.ceil(totalwin / (_doubled[fsid[1]] + _doubled[fsid[2]])) * (_doubled[fsid[i]])
          end
        end
      else
      end
    end

    for i = 1, 3 do
      if i ~= master then
        chge[i] = -s[i] * flag
      end
    end
    if not _cfg.allownegtive then
      for i = 1, 3 do
        if i ~= master then
          --农民胜
          if flag == -1 then
            --加倍过可以赢身上两倍的金币
            if _doubled[i] == 2 then
              maxlimit = players[i].gold * 2
            else
              maxlimit = players[i].gold
            end
            if chge[i] > maxlimit then
              chge[i] = maxlimit
            end
          end

          if chge[i] + players[i].gold < 0 then
            chge[i] = -players[i].gold
          end
        end
      end
      --庄家金币不够赔 则按倍数分给农民
      if (chge[fsid[1]] + chge[fsid[2]]) > players[master].gold then
        if _doubled[fsid[1]] == _doubled[fsid[2]] then
          local olcg = {}
          local half = math.floor(players[master].gold / 2)
          local tl = {}
          for i = 1, 2 do
            olcg[fsid[i]] = chge[fsid[i]]
            tl[fsid[i]] = players[fsid[i]].gold
            if _doubled[fsid[i]] == 2 then tl[fsid[i]] = tl[fsid[i]] * 2 end
            if tl[fsid[i]] >= half then
              chge[fsid[i]] = half
            else
              chge[fsid[i]] = tl[fsid[i]]
            end
          end
          local remain = players[master].gold - chge[fsid[1]] - chge[fsid[2]]
          if remain > 0 then
            local excouldwin = 0
            for i = 1, 2 do
              if olcg[fsid[i]] > chge[fsid[i]] then
                excouldwin = tl[fsid[i]] - chge[fsid[i]]
                if excouldwin > remain then excouldwin = remain end
                if excouldwin and excouldwin > 0 then
                  chge[fsid[i]] = chge[fsid[i]] + excouldwin
                end
              end
            end
          end
        else
          local percent = chge[fsid[1]] /  (chge[fsid[1]] + chge[fsid[2]])
          chge[fsid[1]] = math.floor(percent * players[master].gold)
          chge[fsid[2]] = players[master].gold - chge[fsid[1]]
        end
      end
    end

    chge[master] = -(chge[fsid[1]] + chge[fsid[2]])

	for k, v in pairs(_play_op_cnt) do
		if players[k].offline and (v.offline >= 5 or (v.offline / v.total) >= 0.3) then
			v.punish = true
		end
	end
	
	if chge[master] > 0 then
		if _play_op_cnt[fsid[1]].punish and not _play_op_cnt[fsid[2]].punish then
			chge[fsid[1]] = chge[fsid[1]] + chge[fsid[2]]
			chge[fsid[2]] = 0
			if not _cfg.allownegtive and chge[fsid[1]] + players[fsid[1]].gold < 0 then
				chge[fsid[2]] = chge[fsid[1]] + players[fsid[1]].gold
				chge[fsid[1]] = -players[fsid[1]].gold
			end
		elseif _play_op_cnt[fsid[2]].punish and not _play_op_cnt[fsid[1]].punish then
			chge[fsid[2]] = chge[fsid[2]] + chge[fsid[1]]
			chge[fsid[1]] = 0
			if not _cfg.allownegtive and chge[fsid[2]] + players[fsid[2]].gold < 0 then
				chge[fsid[1]] = chge[fsid[2]] + players[fsid[2]].gold
				chge[fsid[2]] = -players[fsid[2]].gold
			end
		end
	end

	for k, v in pairs(players) do
		if _play_op_cnt[k].punish and chge[k] > 0 then
			chge[k] = 0 -- -2 * basegold
		end
		if v.subcontinuouswin then
			pcall(skynet.call, _redispool, "lua", "execute", "DECR", string.format("continuouswin%d", v.uid))
		end
	end

	sent_msg(0,"game.UpdateGameInfo", {params2={chuntian, huojiancnt, zhadancnt}})

	for i=1,3 do
		sent_msg(0, "game.SetCards", {seatid = i, cardids = cardtable[i]})
	end

	-- if not isMatch and not _personalgame then
	-- 	for k, v in pairs(players) do
	-- 		v.gold = v.gold + _kickbacks
	-- 	end
	-- end

	clear_good_delay_play_time()
	end_game_op(chge)
end

local function isProbot(p)
	return p.isrobot or p.crobot
end

local function setBestCards2SO()
	local robot_seat = nil
	local player_seat = nil
	for i = 1,3 do
		if isProbot(players[i]) then
			robot_seat = i
		else
			player_seat = i
		end
	end
	if robot_seat ~= nil and player_seat ~= nil and game.robot_need_cheat() then
		cardtable = combination.setCardsByWeight(cardtable, robot_seat, player_seat)
		return true
	end
	return false
end

local _admin = {}
-- _admin[1000015] = 1
-- _admin[1098586] = 1
-- _admin[1129939] = 1

local function exchangeCards()
	local adminseat
	for i = 1, 3 do
		if _admin[players[i].uid] then
			adminseat = i
			break
		end
	end
	if adminseat ~= nil then
		cardtable = combination.setCardsByWeight(cardtable, adminseat)
		return true
	end
	return false
end

local function LuckyControl(lucky_seatid, lucky_uid, unlucky_uid, lucky_val, unluck_val, luckytb )
	local head
	local float 
	head, float = math.modf(math.random(300, 350)/1000)
	local lucky = math.ceil(float * (lucky_val - 100))
	local addlucky = math.ceil(float * (100 - unluck_val))

	local node = nil
	local temp_ct
	local unluck_seatid = 0
	for k, v in pairs(players) do
		if v.uid == unlucky_uid then
			unluck_seatid = k
		end
	end
	-- LOG_DEBUG("lucky_seatid:%d, unluck_seatid:%d", lucky_seatid, unluck_seatid)
	cardtable = combination.setCardsByWeight(cardtable, lucky_seatid, unluck_seatid)

	for i,v in ipairs(players) do
		if v.uid == lucky_uid and lucky_val > 100 then
			game.reduce_lucky_value(lucky_uid, lucky)
		end
		if v.uid == unlucky_uid and unluck_val < 100 then
			game.add_lucky_value(unlucky_uid, addlucky)
		end
	end
end

local function NeedLuckyControl()
	local max = 0xfffffff * -1
	local min = 0xfffffff
	local lucky_uid = 0
	local lucky_seatid = 0
	_lucky_tb = {}
	
	for i = 1,3 do
		table.insert(_lucky_tb, {uid = players[i].uid, lucky = players[i].lucky})
		if max < players[i].lucky then
			max = players[i].lucky
			lucky_uid = players[i].uid
			lucky_seatid = i
		end
		if min > players[i].lucky then
			min = players[i].lucky
		end
	end

	table.sort(_lucky_tb, function(tb1, tb2)
		return tb1.lucky < tb2.lucky
	end)

	for k,v in pairs(_lucky_tb) do
		if lucky_uid ~= v.uid then
			local interval = max - v.lucky
			local control = math.random(1,100) 
			-- LOG_DEBUG("control interval:%d, v:%d, max:%d, v.lucky:%d control:%d, lucky_uid:%d", interval, v.uid, max, v.lucky, control, lucky_uid)
			if control < interval then
			--if true then
				-- LOG_DEBUG("control start")
				LuckyControl(lucky_seatid, lucky_uid, v.uid, max, v.lucky ,_lucky_tb)
				return true
			end
		end
	end
	return false
end

local function delPlayedCards(seatid, cards)
	local t
	for k, v in pairs(cards) do
		t = math.floor(v / 10)
		for i = 1, 3 do
			if i ~= seatid then
				_remain_cards[i][t] = _remain_cards[i][t] - 1
			end
		end
	end
end

local function init_dynamic_cfg(mingold)
	-- LOG_DEBUG('\n\ninit_dynamic_cfg       mingold:%d', mingold)
	if not _dynamic_cfg then return end
	for i = 1, #_dynamic_cfg do
		if _dynamic_cfg[i].min <= mingold and (not _dynamic_cfg[i].max or mingold <= _dynamic_cfg[i].max) then
			basegold = _dynamic_cfg[i].bs or basegold
			maxodds = _dynamic_cfg[i].modx or maxodds
			if not _round1lottery then
				_kickbacks = math.ceil(basegold / 2)
			end
			local tcfg = {basescore = basegold}
			if not _cfg.constkb then
				tcfg.kickbacks = _kickbacks
			end
			game.update_dynamic_cfg(tcfg)
			-- LOG_DEBUG('find ....kickbacks = %d, basescore = %d', _kickbacks, basegold)
			break
		end
	end
end

local function start(dnsendbs)
	gamelog('game start')
	_game_start_time = skynet.now()
	gamestatus = 0
	for i = 1, 3 do
		_face_use[i] = {item = 0, gold = 0, freeze = 0}
		players[i].subcontinuouswin = nil
		players[i].continuouswin = nil
		if not _personalgame then
			_special_ct[i] = {
				[1] = 0,
				[2] = 0,
			}
		end
	end
	
	_master_cards = {}
	cardtable = {}
	local missile_seat
	for i = 1, 3 do
		-- if not players[i] then
		-- 	game.kick_out_all(_roomtype == 'diamond')
		-- 	return
		-- end
		if players[i].send_missile then
		-- if not players[i].isrobot then
			missile_seat = i
			break
		end
	end
	--同位置玩家扑克相同比赛专用
	if _unifycards then
		local cardids = game.get_unifycards()
		for i = 1, 3 do
			cardtable[i] = table.arraycopy(cardids, (i - 1) * 17 + 1, 17)
		end
		_master_cards = {cardids[#cardids], cardids[#cardids - 1], cardids[#cardids - 2]}
	--需要发送double jork给指定玩家
	elseif not isMatch and not _personalgame and missile_seat then
		cardtable, _master_cards = logic.createCardsMissile(missile_seat)
		players[missile_seat].missile_sent = true
	else
		shuffle()
	end
	
	-- local ret --comment luck
	-- if not missile_seat then --
	-- 	ret = setBestCards2SO()

	-- 	if not isMatch and not _personalgame and not ret and _roomtype ~= 'diamond' then
	-- 		NeedLuckyControl()
	-- 	end
	-- end
	
	
	local ok, wincnt
	if not isMatch and not _personalgame then
		local protectid--, otherseat
		for i = 1, 3 do
			ok, wincnt = pcall(skynet.call, _redispool, "lua", "execute", "get", string.format("continuouswin%d", players[i].uid))
			if ok and wincnt then
				players[i].continuouswin = tonumber(wincnt)
			end
			if (players[i].newplayerProtect and players[i].newplayerProtect > 0) or 
			players[i].continuouswin and players[i].continuouswin > 0 then
				protectid = i
				break
			end
		end
		if protectid then --and otherseat then
			cardtable = combination.setCardsByWeight(cardtable, protectid)

			if players[protectid].newplayerProtect and players[protectid].newplayerProtect > 0 then
				if _roomtype ~= 'diamond' then
					skynet.fork(game.call_dbs_by_logic, 'reduce_newplayer_protect', players[protectid].uid, 'newplayerProtect')
				else
					skynet.fork(game.call_dbs_by_logic, 'reduce_newplayer_protect', players[protectid].uid, 'newplayerProtect_diamond')
				end
			else
				players[protectid].subcontinuouswin = true
			end
		end
	end
	exchangeCards()
	resetRemainCards()

	local mingold = 9999999999
	for i=1,3 do
		if isProbot(players[i]) then
			sent_msg(i,"game.RobotSetInfos", {seatid = i, session = 0, cardids = {cardids1 = cardtable[1], cardids2 = cardtable[2], cardids3 = cardtable[3]}})
		else
			sent_msg(i,"game.AddCard",{seatid = i, askseatid = sid, cardids = cardtable[i], reshufflecnt = _re_shuffle_count}, true)
		end

		gamelog(string.format('send cards uid: %d  ', players[i].uid), cardtable[i])
		if players[i].gold < mingold then
			mingold = players[i].gold
		end
	end
	gamelog('master cards ', _master_cards)
	-- if not logic.judgeCardsLegal(cardtable, _master_cards) then
	-- 	LOG_ERROR('error: cards error ~!!!!!!!!!!!!!')
	-- end
	-- used_cards = {}
	played_seatids = {}
	asktimes = 0
	score = 0
	lastcards = {}
	lastseatid = sid -- 在游戏开始前，lastseatid用作记录最近一个叫分的玩家。
	odds = _defaultOdds
	master = 0
	zhadancnt = 0
	huojiancnt = 0

	basegold = _cfg.baseScore
	if _dynamic_cfg then
		init_dynamic_cfg(mingold)
	end
	pcall(skynet.call, _redispool, "lua", "execute", "ZINCRBY", string.format('rid_bss_cnt%d_%s', _roomid, os.date("%Y%m%d", os.time())), 1, basegold)
	if not dnsendbs then
		if basegold ~= _cfg.baseScore then
			sent_msg(0,"game.UpdateGameInfo", {params1={odds, basegold, _kickbacks, maxodds}, optype = 1, tableid = skynet.self()}, true)
		else
			sent_msg(0,"game.UpdateGameInfo", {params1={odds, basegold, _kickbacks, maxodds}, tableid = skynet.self()}, true)
		end
	end
end

local function ask_playcard(time, seatid, cards)
	gamestatus = 2
	time = time or _play_time
	local p = players[sid]
	if p and (p.offline or p.tuoguan) then
		setTick(100, 'ask_playcard11')
		time = 100
	else
		time = get_delay_play_time(sid) or time
		setTick(time + DELAY, 'ask_playcard22')
	end
	
	for k, v in pairs(players) do
		if k == sid then
			-- logic.printCards(lastcards, true)
			sent_msg(k,"game.UseCardNtf",{seatid = seatid or 0, cardids = cards, cursid = sid, time = (time - DELAY) / 100, lastseatid = lastseatid, lastcards = lastcards})
		else
			sent_msg(k,"game.UseCardNtf",{seatid = seatid or 0, cardids = cards, cursid = sid, time = (time - DELAY) / 100})
		end
	end
end

local ask_master
ask_master = function(inorder)
	if ((not _callbanker2 or isMatch or _personalgame) and score >= 3) or 
		(not isMatch and not _personalgame and _callbanker2 and score >= 1) or
		 _re_shuffle_count > 2 or (score > 0 and asktimes > 2)  then
		if _callbanker2 then
			score = 1
		end
		
		if score < 1 then score = 1 end
		sid = lastseatid
		set_master(lastseatid)
		if not isMatch and not _personalgame and _roomtype ~= 'diamond' and _double_price and _double_price > 0 then
			gamestatus = 4
			setTick(_call_double_time)
		else
			ask_playcard(TIME + 300)
		end
		return
	elseif asktimes > 2 then
		_re_shuffle_count = _re_shuffle_count + 1
		if _re_shuffle_count >= 3 then
			ask_master()
			return
		end

		-- if isMatch and _roomid ~= 303 then
		-- 	for k, v in pairs(players) do
		-- 		v.gold = v.gold - 100
		-- 	end
		-- end
		-- shuffle()
		local r, msg = pcall(start, true)
		if not r then
			luadump(msg)
			if isMatch then
				game.end_game({0,0,0})
			else
				game.kick_out_all(0, _roomtype == 'diamond')
			end
			return
		end
		ask_master()
		return
	end
	asktimes = 1 + asktimes
	gamestatus = 1
	-- starttime = skynet.now()
	local p = players[sid]
	local time = TIME
	if p and (p.offline or p.tuoguan) then
		setTick(150, 'ask_master11')
		time = 100
	else
		time = get_delay_play_time(sid) or time
		setTick(time + DELAY, 'ask_master22')
	end
	sent_msg(0,"game.AskMaster", {seatid = sid, score = score, time = time/100}, inorder)
end

local function use_cards(i, cards, type)
	-- logic.printCards(cards, true, 'head同步扑克')
	record_delay_play_in_match(sid)
	cancelTick()
	-- cards = cards or {}
	if cards and #cards > 0 then
		-- LOG_DEBUG('\n\nuse_cards:------------#cards: %d', #cards)
		-- logic.printCards(cards, true)
		-- LOG_DEBUG('after print cards!!!!!!!!!!!!!!!!!!')
		lastseatid = sid
		lastcards = table.arraycopy(cards, 1, #cards)
		-- logic.printCards(lastcards, true)
	else
		cards = {}
	end

	if not _personalgame and not players[i].isrobot and type then
		local extype = 0
		if type == 4 or type == 5 then
			extype = 1
		elseif #cards > 5 and (type == 6 or type == 7 or type == 8) then
			extype = 2
		end

		if extype ~= 0 and _special_ct[i] and _special_ct[i][extype] then
			_special_ct[i][extype] = _special_ct[i][extype] + 1
		end
	end
	
	-- LOG_DEBUG("出了卡牌类型为：" .. tostring(type))
	if type == CT_BOMB_CARD or type == CT_MISSILE_CARD then
		if type == CT_BOMB_CARD then 
			zhadancnt = zhadancnt + 1 
		else
			huojiancnt = huojiancnt + 1
		end
		odds = odds * 2
		if odds > maxodds then
			odds = maxodds
		end
		gamelog(string.format('打出炸弹,倍数:%d', odds))
		sent_msg(0,"game.UpdateGameInfo", {params1={odds}})--basegold * score, 
	end
	-- for _,v in pairs(cards) do
	-- 	table.insert(used_cards, v)
	-- end
	if #cards > 0 then
		played_seatids[i] = played_seatids[i] or 0
		played_seatids[i] = played_seatids[i] + 1
	end
	delPlayedCards(i, cards)

	local gameover = check_end()
	if gameover then
		sent_msg(0,"game.UseCardNtf",{seatid = i, cardids = cards})
		if _roomtype == 'diamond' then
			diamond_end_game()
		else
			end_game()
		end
	else
		next_player()
		ask_playcard(_play_time, i, cards)
	end
end

local function play_cards(cards, ctype, trustPlay)
	if check_cards(sid, cards) then
		if ctype == CT_MISSILE_CARD then
			players[sid].missile_played = true
		end
		 
		use_cards(sid, cards, ctype)
	else
		local uid = 0
		if players[sid] and players[sid].uid then
			uid = players[sid].uid
		end
		if trustPlay then
			LOG_DEBUG('托管打出错误扑克...')
		end

		gamelog(string.format('uid: %d 服务器扑克数据不存在', players[sid].uid), cards)
		gamelog('手上的扑克', cardtable[sid])
		gamelog('上一手扑克', lastcards or {})
	end
end

local function game_start()
	gamestatus = 100
	if DEBUG then
		sent_msg(0,"game.TalkNtf",{seatid=0,msg=ver})
	end
	local p
	for i=1,3 do
		p = players[i]
		if p and p.tuoguan then
			p.tuoguan = nil
			p.playtimeout = nil
			sent_msg(0, "game.OperateRep", {seatid = i, optype = 0})
		end
		if not isProbot(p) then
			p.cards_recorder = ((p.recorder_expire_time or 0) - os.time()) > 0
		end

		_play_op_cnt[i] = {total = 0, offline = 0} --重置玩家操作数据
	end
	
	_re_shuffle_count = 0
	_doubled = {}
	start()
	ask_master(true)
end

local function check_can_start()
	if #players ~= 3 then return end
	local p
	for i=1,3 do
		p = players[i]
		if not p or not p.uid then
			return
		end
	end
	game.lock_table()
	game.start_game()
	local r, msg = pcall(game_start)
	if not r then
		LOG_ERROR('pcall(game_start) error:')
		luadump(msg)
		if not pcall(game_start) then
			LOG_DEBUG('_roomtype == diamond : %s', tostring(_roomtype == 'diamond'))
			if isMatch then
				game.end_game({0,0,0})
			else
				game.kick_out_all(0, _roomtype == 'diamond')
			end
			return
		end
	end
end

local function countdown_2_start()
	if #players ~= 3 then return end
	local p
	for i=1,3 do
		p = players[i]
		if not p or not p.uid then
			return
		end
	end
	
	-- _end_game_time = skynet.now()
end

function game.startPersonalGame()
	skynet.timeout(200, function( ... )
		check_can_start()
	end)
end

function game.tick()
	local tnow = skynet.now()
	if gamestatus == 255 then
		if isMatch or (_personalgame and _end_game_time ~= 0) then
			if (isMatch and tnow - _end_game_time > _match_restart_time) or 
			(_personalgame and tnow - _end_game_time > _personal_restart_time) then
				check_can_start()
				return
			end
		end
	else
		if _game_start_time and tnow - _game_start_time > _max_game_time then
			LOG_WARNING('tableid:%d game timeout~!! sid : %s  tnow: %s   starttime: %s   delaytime:%s gamestatus: %s', skynet.self(), tostring(sid), tostring(tnow), tostring(starttime), tostring(delaytime), tostring(gamestatus))
			end_game_op({0,0,0})
		end
	end

	if delaytime > 0 and tnow - starttime >= delaytime then
		cancelTick('game.tick gamestatus: '..tostring(gamestatus))
		if gamestatus == 1 then
			sent_msg(0,"game.SetScore",{score = 0, seatid = sid, ismaster = false})
			next_player()
			ask_master()
		elseif gamestatus == 2 then
			if players[sid] and not players[sid].tuoguan then
				players[sid].playtimeout = players[sid].playtimeout and players[sid].playtimeout + 1 or 1
				if players[sid].playtimeout >= 2 then
					players[sid].tuoguan = 1
					sent_msg(0, "game.OperateRep", {seatid = sid, optype = 1})
					gamelog(string.format('uid: %d 超时两次，自动托管', players[sid].uid))
				end
			end
			if lastseatid == sid or lastseatid == 0 then
				if players[sid].tuoguan then
					local result = combination.getTrustOutCards(cardtable[sid])
					result = result or {cards = {cardtable[sid][1]}}
					gamelog(string.format('uid: %d 托管出牌  ', players[sid].uid), result.cards)
					game.dispatch(sid, 'game.UseCardNtf', {cardids = table.arraycopy(result.cards, 1, #result.cards)}, true)
				else
					gamelog(string.format('uid: %d 超时出牌  ', players[sid].uid), {cardtable[sid][1]})
					game.dispatch(sid, 'game.UseCardNtf', {cardids = {cardtable[sid][1]}}, true)
				end
			else
				if players[sid].tuoguan then
					if lastcards then
						local tcards = combination.getTrustOutCards(cardtable[sid], lastcards)
						if tcards == nil or tcards.cards == nil then
							gamelog(string.format('uid: %d 托管不出  ', players[sid].uid))
							game.dispatch(sid, 'game.UseCardNtf', {cardids = {}}, true)
						else
							gamelog(string.format('uid: %d 托管出牌  ', players[sid].uid), tcards.cards)
							game.dispatch(sid, 'game.UseCardNtf', {cardids = table.arraycopy(tcards.cards, 1, #tcards.cards)}, true)
						end
					else
						LOG_DEBUG('tableid:%d msg:-----------------------没有上一手出牌信息', skynet.self())
					end
				else
					gamelog(string.format('uid: %d 超时未出牌  ', players[sid].uid))
					game.dispatch(sid, 'game.UseCardNtf', {cardids = {}}, true)
				end
			end
		elseif gamestatus == 4 then
			for i = 1, 3 do
				if not _doubled[i] then
					game.dispatch(i, 'game.OperateReq', {optype = 7, params = {1}})
				end
			end
		end
	end
end

function game.dispatch(seatid, name, msg, trustPlay)
	-- LOG_DEBUG('msg:--------------收到玩家发送的信息~！！name: %s', name)
	if gamestatus ~= 255 then
		if name == "game.TalkNtf" then
				msg.msg=msg.msg or "10"
				sent_msg(0,"game.TalkNtf",{seatid=seatid,msg=msg.msg})
			-- end
		end

		if name == "game.OperateReq" then
			if msg.optype then
				if msg.optype == 7 then
					if _personalgame or isMatch or _roomtype == 'diamond' or gamestatus ~= 4 or not seatid or 
						not players[seatid] or not msg.params or not msg.params[1] or (msg.params[1] ~= 1 and msg.params[1] ~= 2) then return end
					if _doubled[seatid] then return end
					local p = players[seatid]

					_doubled[seatid] = msg.params[1]
					if msg.params[1] == 2 then
						if not p.diamond or p.diamond < _double_price then
							return sent_msg(seatid, "game.OperateRep", {optype = 7, result = 1})
						end

						if master == seatid then
							local no_one_enough = true
							for k, v in pairs(players) do
								if k ~= master and _double_limit <= v.gold then
									no_one_enough = false
									break
								end
							end
							if no_one_enough then
								return sent_msg(seatid, "game.OperateRep", {optype = 7, result = 2})
							end
						else
							if _double_limit > players[master].gold then
								return sent_msg(seatid, "game.OperateRep", {optype = 7, result = 2})
							end
						end
						skynet.fork(game.call_dbs_by_logic, 'reduce_item', p.uid, 3, _double_price, _gold_change_reason_enum.DoubleByDiamond)
						p.diamond = p.diamond - _double_price
						gamelog(string.format('uid:%d double ', p.uid or 0))
					end
					
					sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 7, params = msg.params})

					for i = 1, 3 do
						if not _doubled[i] then
							return
						end
					end
					ask_playcard(TIME)
				elseif msg.optype == 6 then
					-- local userdata = game.call_dbs(uid, "get_userdata", uid, {"recorder_expire_time"})
					-- if userdata and userdata.recorder_expire_time and userdata.recorder_expire_time > os.time() then
					if not seatid or not players[seatid] then
						return
					end
					
					players[seatid].cards_recorder = true
					params = {}
					for i = 1, 15 do
						table.insert(params, _remain_cards[seatid][i])
					end
					sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 6, result = 0, params = params})
				elseif msg.optype == 5 then
					if not msg.params or not msg.params[1] or not msg.params[2] or msg.params[1] == seatid then
						sent_msg(seatid, "game.OperateRep", {optype = 5, result = 1})
						return
					end
					local cfg = _game_prop[msg.params[2]]
					if not cfg then
						sent_msg(seatid, "game.OperateRep", {optype = 5, result = 2})
						return
					end

					local p = players[seatid]
					-- LOG_DEBUG('p.gameprop : %s  in dispatch', tostring(p.gameprop))
					if p.gameprop and p.gameprop > 0 then
						-- skynet.fork(game.call_dbs_by_logic, 'reduce_item', p.uid, 101, 1, _gold_change_reason_enum.FromUseGameProp)
						p.gameprop = p.gameprop - 1
						_face_use[seatid].item = _face_use[seatid].item + 1
						sent_msg(0, "game.OperateRep", {optype = 5, result = 0, params = {seatid, msg.params[1], msg.params[2]}})
						return
					end

					if not isMatch and _roomtype ~= 'diamond' then
						if p.gold - cfg.price < _minscore then
							sent_msg(seatid, "game.OperateRep", {optype = 5, result = 3})
							return
						end
						_face_use[seatid].freeze = _face_use[seatid].freeze + cfg.price
						p.gold = p.gold - cfg.price
						-- local t = game.update_freeze_gold(p, -cfg.price, true, _gold_change_reason_enum.FromUseGameProp, _roomid)
						-- if t and t >= 0 then
						-- p.gold = t
						sent_msg(0, "game.OperateRep", {optype = 5, result = 0, params = {seatid, msg.params[1], msg.params[2]}})
						-- end
					else
						if isMatch then
							if not p.money or p.money < cfg.price then
								sent_msg(seatid, "game.OperateRep", {optype = 5, result = 3})
								return
							end
							p.money = p.money - cfg.price
						elseif _roomtype == 'diamond' then
							if p.gold < cfg.price then
								sent_msg(seatid, "game.OperateRep", {optype = 5, result = 3})
								return
							end
							p.gold = p.gold - cfg.price
						end
						_face_use[seatid].gold = _face_use[seatid].gold + cfg.price
						sent_msg(0, "game.OperateRep", {optype = 5, result = 0, params = {seatid, msg.params[1], msg.params[2]}})
					end
				elseif msg.optype == 3 and not _personalgame and not isMatch and (gamestatus == 2 or gamestatus == 3) then
					if not msg.params or not msg.params[1] or msg.params[1] < 1 or msg.params[1] > 6 then
						sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 3, result = 3})
						return
					end

					local p = players[seatid]
					if p.gold - basegold < _minscore then
						-- LOG_DEBUG('msg:--------------22222')
						sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 3, result = 1})
					elseif p.guessRecord and p.guessRecord[msg.params[1]] and p.guessRecord[msg.params[1]] >= 10 * basegold then
						sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 3, result = 2})
					else
						local t = game.update_freeze_gold(p, -basegold, true, _gold_change_reason_enum.FromGuessCards)
						if t and t >= 0 then
							p.gold = t
							p.guessRecord = p.guessRecord or {}
							p.guessRecord[msg.params[1]] = p.guessRecord[msg.params[1]] or 0
							p.guessRecord[msg.params[1]] = p.guessRecord[msg.params[1]] + basegold
							gamelog(string.format('uid: %d 押注猜牌  牌型:%d', players[seatid].uid, msg.params[1]))
							sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 3, result = 0, params = {msg.params[1], p.guessRecord[msg.params[1]], p.gold}})
						end
					end
				else
					local p = players[seatid]
					if p then
						if msg.optype == 1 and (not p.tuoguan) then
							if gamestatus == 4 then return end
							p.tuoguan = 1
							sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 1})
							if sid == seatid then
								setTick(10, 'dispatch_truest_msg.optype == 1')
							end
							gamelog(string.format('uid: %d 托管', players[seatid].uid))
						elseif msg.optype == 0 or msg.optype == 2 and p.tuoguan == 1 then
							players[seatid].playtimeout = nil
							players[seatid].tuoguan = nil
							gamelog(string.format('uid: %d 取消托管', players[seatid].uid))
							sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 0})
						end
					end
				end
			end
		end
	end

	--test client modify cards
	-- if name == "game.SetCards" then
	-- 	if msg and msg.cardids and #msg.cardids == 54 then
	-- 		print("收到卡牌:" .. table.concat(msg.cardids,","))
	-- 		cardids = msg.cardids
	-- 		start()
	-- 		ask_master()
	-- 		return
	-- 	end
	-- end

	if gamestatus == 1 then
		if name == "game.AnswerMaster" then
			if seatid  == sid and master == 0 then
				record_delay_play_in_match(sid)
				cancelTick('game.dispatch answermaster¬!')
				if score < msg.score then
					score = msg.score
					lastseatid = seatid
					odds = _defaultOdds * score
				end
				if score > 3 then
					score = 3 
					odds = _defaultOdds * score
				end
				gamelog(string.format('uid: %d 叫庄 score:%d', players[seatid].uid, msg.score or 0))
				sent_msg(0,"game.SetScore",{score = msg.score, seatid = seatid, ismaster = false})
				next_player()
				ask_master()
			end
		end
	elseif gamestatus == 2 then
		if name == "game.UseCardNtf" then
			if seatid == sid then
				local cards = msg.cardids or {}
				if not trustPlay then
					if cards and #cards > 0 then
						gamelog(string.format('uid: %d 出牌  ', players[seatid].uid), cards)
					else
						gamelog(string.format('uid: %d pass  ', players[seatid].uid))
					end
				end
				--记录玩家操作数据
				_play_op_cnt[sid].total = _play_op_cnt[sid].total + 1
				if players[sid].offline and next(cards) then
					_play_op_cnt[sid].offline = _play_op_cnt[sid].offline + 1
				end
				if #cards == 0 then
					if lastseatid ~= sid and lastseatid ~= 0 then
						use_cards(sid)
					else
						gamelog(string.format('!!!error uid: %d first put but recive null  ', players[seatid].uid))
					end
				else
					local canuse, tp
					if lastseatid == sid or lastseatid == 0 then
						tp =logic.getCardType(cards)
						if tp > 0 then 
							play_cards(cards, tp, trustPlay)
						else
							gamelog(string.format('uid: %d 牌型错误  ', players[seatid].uid), cards)
						end
					else
						canuse,tp = check(cards,lastcards)
						if lastcards and canuse then
							play_cards(cards, tp, trustPlay)
						else
							gamelog(string.format('uid: %d 打出错误扑克  ', players[seatid].uid), cards)
							gamelog('手上的扑克', cardtable[seatid])
							gamelog('上一手扑克', lastcards or {})
						end
					end
				end
			end
		end
	end
end

function game.reconnect(seatid)
	if gamestatus == 255 or not players[1] or not players[2] or not players[3] then 
		return
	end
	local msg = {}

	msg.status = gamestatus
	msg.players = {}
	for i = 1, 3 do
		table.insert(msg.players, {uid = players[i].uid, seatid = i, params = {#(cardtable[i]), players[i].tuoguan or 0, players[i].offline or 1 and 0, _doubled[i]}})
	end
	msg.params1 = cardtable[seatid]
	local tmp = {}
	tmp = table.arraycopy(lastcards, 1, #lastcards)
	if master and master > 0 then
		table.mergeByAppend(tmp, _master_cards)
	else
		table.insert(tmp, 0)
	end
	msg.params2 = tmp
	local p = players[seatid]
	if p.guessRecord then
		msg.params3 = {}
		for i = 1, 6 do
			table.insert(msg.params3, p.guessRecord[i] or 0)
		end
	end
	if p.cards_recorder then
		msg.params4 = {}
		for i = 1, 15 do
			table.insert(msg.params4, _remain_cards[seatid][i])
		end
	end

	if master and master > 0 then
		msg.params5 = {master, odds}
	end
	
	local time = delaytime - skynet.now() + starttime - DELAY
	if time < 0 then time = 0 end
	msg.time = math.ceil(time / 100)
	msg.cursid = sid
	msg.presid = lastseatid
	msg.mastersid = master
	sent_msg(seatid, "game.ReconnectRep", msg)
	sent_msg(seatid,"game.UpdateGameInfo", {params1={odds, basegold, _kickbacks, maxodds}, tableid = skynet.self()})--basegold * score, 
end

function game.join(p)
	-- LOG_DEBUG("logic.join，gamestatus = "..tostring(gamestatus or "nil"))
	if not p then return false end
	if not players then return false end
	if gamestatus and gamestatus ~= 255 then return false end
	
	local player
	for i=1,3 do
		player = players[i]
		if player == nil or player.uid == 0 then
			players[i] = p
			if isMatch then
				-- skynet.fork(countdown_2_start)
			elseif not _personalgame then
				skynet.fork(check_can_start)
			end
			return true
		end
	end
	return false
end

function game.free()
end

function game.leave_game(p, status)
	if gamestatus == 255 then-- or gamestatus == 3 then
		if _roomtype == 'diamond' or _roomtype == 'queue' then
			return
		end
		game.unlock_table()
	else
		if p then
			gamelog(string.format('uid:%d leave game status:%s', tostring(p.uid), tostring(status)))
		end
	end
end

function game.init(ps, cfg, reload)
	_cfg = cfg
	_callbanker2 = cfg.callbanker2
	_kickbacks = cfg.kickbacks or 0
	_personalgame = cfg.personalGame
	_double_price = cfg.doublediamond
	_double_limit = cfg.doublelimit
	_roomtype = cfg.roomType
	_round1lottery = cfg.round1lottery
	_defaultOdds = cfg.defaultOdds or 1
	players = ps
	basegold = tonumber(cfg.baseScore)
	maxodds = tonumber(cfg.maxOdds)
	isMatch = cfg.isMatch
	gamestatus = 255
	delaytime = 0
	sid = lrandom(1, cfg.maxPlayer)
	_minscore = tonumber(cfg.minScore)
	_dynamic_cfg = cfg.dynamicbs
	if isMatch then
		_end_game_time = skynet.now()
		_roomid = tonumber(cfg.matchid)
	else
		_end_game_time = 0
		_roomid = tonumber(cfg.roomid)
	end
	_unifycards = cfg.unifycards

	if not _redispool then
		_redispool = skynet.uniqueservice("redispool")
	end
end

--在复用table时，table重新装载logic的时候调用
function game.clear()

end

return game