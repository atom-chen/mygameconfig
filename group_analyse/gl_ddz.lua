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
  print('getSpecialGroup tp = '..tostring(tp))
	if tp == CT_THREE then
  print('三张')
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
    
    print(' r == '..tostring(r))
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
				 --print('_template[i].tp: '..tostring(_template[i].tp)..'   exnum: '..tostring(exnum))
				 --logic.printCards(cards)
				--根据条件得到指定牌型
				local group = getSpecialGroup(_template[i].tp, cards, exnum)
				 print('生成扑克 #group : '..tostring(#group))
				 logic.printCards(group)
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

	local allFourTakeOne = logic.getAllFourTake(cards, true, false, 0)
	if allFourTakeOne then
		cmbs = util.merge(cmbs, allFourTakeOne)
	end

	local allFourTakeTwo = logic.getAllFourTake(cards, false, true, 0)
	if allFourTakeTwo then
		cmbs = util.merge(cmbs, allFourTakeTwo)
	end

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

for i = 1, 10 do
  local cardtable, _master_cards = logic.createCardsGroup(4, 0)
  for j = 1, #cardtable do
    table.sort(cardtable[j], function(c1, c2)
        return c1 < c2
        end)
    logic.printCards(cardtable[j])
    
  end
  print('\n\n')
end