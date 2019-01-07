local util = require 'ai_util'
--require 'functions'
local logic = {}

logic.cardHashTab = {}
--logic.hashCardAmount = 0
--logic.preHashCardData = {}

local CT_ERROR =				0	--错误
local CT_SINGLE	=				1 	--单牌
local CT_PAIRS	=				2 	--对子
local CT_SET =					3 	--三张
local CT_SEQUENCE =				4 	--顺子
local CT_PAIRS_SEQUENCE =		5 	--连对
local CT_THREE_SEQUENCE	=		6 	--飞机
local CT_THREE_TAKE_ONE =		7 	--飞机带单(包括三张带单牌)
local CT_THREE_TAKE_PAIRS =		8 	--飞机带对
local CT_FOUR_LINE_TAKE_ONE	=	9	--炸弹带单牌
local CT_FOUR_LINE_TAKE_TWO	=	10	--炸弹带对子
local CT_BOMB4 =				11 	--炸弹
local CT_BOMB5 =				12 	--炸弹
local CT_BOMB6 =				13 	--炸弹
local CT_BOMB7 =				14 	--炸弹
local CT_BOMB8 =				15 	--炸弹
local CT_MISSILE_CARD =			16	--王炸

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
	else
		color = tostring(card % 10)
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
	elseif cardType == CT_PAIRS then
		return 2 * logic.getCardLogicValue(cards[1])
	elseif cardType == CT_SET then
		return 3 * logic.getCardLogicValue(cards[1])
	elseif cardType == CT_SEQUENCE then
		return logic.getCardsWeightSum(cards) * 2
	elseif cardType == CT_PAIRS_SEQUENCE then
		return logic.getCardsWeightSum(cards) * 4
	elseif cardType == CT_THREE_SEQUENCE then
		return logic.getCardsWeightSpecial(cards, 3) * 6
	elseif cardType == CT_THREE_TAKE_ONE then
		local baseWeight = logic.getCardsWeightSpecial(cards, 3)
		return baseWeight * 7
	elseif cardType == CT_THREE_TAKE_PAIRS then
		local baseWeight = logic.getCardsWeightSpecial(cards, 3)
		return baseWeight * 7
	-- elseif cardType == CT_FOUR_LINE_TAKE_ONE then
	-- 	local baseWeight = logic.getCardsWeightSpecial(cards, 4)
	-- 	return baseWeight * 8
	-- elseif cardType == CT_FOUR_LINE_TAKE_TWO then
	-- 	local baseWeight = logic.getCardsWeightSpecial(cards, 4)
	-- 	return baseWeight * 8
	elseif cardType == CT_MISSILE_CARD then
		return 80 * logic.getCardLogicValue(cards[1]) * 10
	elseif cardType >= CT_BOMB4 then
		return #cards * logic.getCardLogicValue(cards[1]) * 10
	end
end

function logic.getCardsNode(cards, cardType, keyValue)
	-- if cards ~= nil and #cards > 1 then
		
	-- end
	table.sort(cards, function(card1, card2)
		return card1 < card2
	end)

	local ct, kv, change = logic.getCardType(cards)
	if change and next(change) then
		for k, v in pairs(change) do
			table.insert(cards, v)
		end

		local val
		for i = 1, #change do
			var = 0
			if change[i] % 10 == 5 then
				val = 140
			elseif change[i] % 10 == 6 then
				val = 150
			end
			for k, v in pairs(cards) do
				if v == val then
					table.remove(cards, k)
					break
				end
			end
		end
	end
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

-- function logic.compareCard(cards1, cards2)
-- 	local type1 = logic.getCardType(cards1)
-- 	local type2 = logic.getCardType(cards2)
-- 	local amounts1 = #cards1
-- 	local amounts2 = #cards2
-- 	-- error detect
-- 	if type2 == CT_ERROR then return false end
-- 	if cards1 == CT_MISSILE_CARD then return false end
-- 	if type2 == CT_MISSILE_CARD then return true end

-- 	if type1 == CT_BOMB4 and type2 ~= CT_BOMB4 then return false end
-- 	if type1 ~= CT_BOMB4 and type2 == CT_BOMB4 then return true end

-- 	if type1 ~= type2 or amounts1 ~= amounts2 then return false end

-- 	if type1 == CT_SINGLE or type1 == CT_PAIRS or type1 == CT_SET or type1 == CT_SEQUENCE or type1 == CT_PAIRS_SEQUENCE or type1 == CT_THREE_SEQUENCE or type1 == CT_BOMB4 then
-- 		return logic.getCardLogicValue(cards2[1]) > logic.getCardLogicValue(cards2[2])
-- 	elseif type1 == CT_THREE_TAKE_ONE or type1 == CT_THREE_TAKE_PAIRS then
-- 		local analyseData1 = logic.analyseCards(cards1)
-- 		local analyseData2 = logic.analyseCards(cards2)

-- 		return analyseData2.three[1].keyValue > analyseData1.three[1].keyValue
-- 	elseif type1 == CT_FOUR_LINE_TAKE_ONE or type1 == CT_FOUR_LINE_TAKE_TWO then
-- 		local analyseData1 = logic.analyseCards(cards1)
-- 		local analyseData2 = logic.analyseCards(cards2)

-- 		return analyseData2.four[1].keyValue > analyseData1.four[1].keyValue
-- 	end
-- end

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
				result.double.cardType = CT_PAIRS
				table.insert(result.double, v)
			elseif v.amount == 3 then
				--if not result.three then result.three = {} end
				result.three.cardType = CT_SET
				table.insert(result.three, v)
			elseif v.amount == 4 then
				--if not result.four then result.four = {} end
				result.four.cardType = CT_BOMB4
				table.insert(result.four, v)
			end
		end
	end

	return result
end

local function is_sequence(cards)
	if not cards or not next(cards) then return false end
	for i = 1, #cards - 1 do
		if cards[i] + 1 ~= cards[i+1] or cards[i + 1] == 13 or 
			cards[i+1] == 14 or cards[i+1] == 15 then
			if cards[i + 1] == 13 and (i + 1 == #cards) and cards[1] == 1 then
				return true, 0
			elseif cards[i + 1] == 12 and cards[i + 2] == 13 and (i + 2 == #cards) and cards[1] == 1 then
				return true, -1
			end
			return false
		end
	end
	
	return true, cards[1]
end

local function getnormalcardtype(cards)
	if not cards or not next(cards) then return CT_ERROR end
	local count = #cards
	local hash = {}
	local c_single = {}
	local c_pairs = {}
	local c_set = {}
	-- local c_xset = {}
	--local c_four = {}
	local c_multi = {}
	local kv
	for k, v in pairs(cards) do
		kv = math.floor(v / 10)
		hash[kv] = hash[kv] or 0
		hash[kv] = hash[kv] + 1
	end

	local v
	for k = 1, 15 do
	-- for k, v in pairs(hash) do
		v = hash[k]
		if v == 1 then
			table.insert(c_single, k)
		elseif v == 2 then
			table.insert(c_pairs, k)
		elseif v == 3 then
			table.insert(c_set, k)
        	-- table.insert(c_xset, k)
		elseif v ~= nil then
        	c_multi[v] = c_multi[v] or {}
          	table.insert(c_multi[v], k)
		end
	end
	if hash[14] == 2 and hash[15] == 2 and count == 4 then
		return CT_MISSILE_CARD, 15
	elseif count == 1 then
		return CT_SINGLE, c_single[1]
	elseif count == 2 and #c_pairs == 1 then
		return CT_PAIRS, c_pairs[1]
	elseif count == 3 and #c_set == 1 then
		return CT_SET, c_set[1]
	elseif count >= 4 and next(c_multi) then
		for i = 4, 8 do
			if c_multi[i] and count == i then
				return (CT_BOMB4 + i - 4), c_multi[i][1]
			end
		end
	-- elseif #c_set == 1 and count == 4 then
		-- return CT_THREE_TAKE_ONE, c_set[1]
	elseif #c_set == 1 and count == 5 and #c_pairs == 1 then
		return CT_THREE_TAKE_PAIRS, c_set[1]
	elseif #c_set > 1 then
		local temp, kv = is_sequence(c_set)
		if temp then
			-- if count == 4 * #c_set then
				-- return CT_THREE_TAKE_ONE, kv
			-- else
			if count == 5 * #c_set and #c_pairs == #c_set and is_sequence(c_pairs) then
				return CT_THREE_TAKE_PAIRS, kv
			elseif #c_set * 3 == count then
				return CT_THREE_SEQUENCE, kv
			end
		end
	-- elseif #c_single > 4 and #c_single == count then
	-- 	local temp, kv = is_sequence(c_single, true)
	-- 	if temp then
	-- 		return CT_SEQUENCE, kv
	-- 	end
	elseif #c_pairs > 2 and #c_pairs * 2 == count then
		local temp, kv = is_sequence(c_pairs)
		if temp then
			return CT_PAIRS_SEQUENCE, kv
		end
	end
	return CT_ERROR, 0
end

function logic.getCardType(cards, prenode)
	local ct, kv = getnormalcardtype(cards)
	if ct ~= CT_ERROR then
		return ct, kv
	else
		local jork = {}
		local tcards = {}
		for k, v in pairs(cards) do
			if v == 140 then
				table.insert(jork, 5)
			elseif v == 150 then
				table.insert(jork, 6)
			else
				table.insert(tcards, v)
			end
		end

		-- local hash = {}
		-- local kv
		-- for k, v in pairs(cards) do
		-- 	kv = math.floor(v / 10)
		-- 	hash[kv] = hash[kv] or 0
		-- 	hash[kv] = hash[kv] + 1
		-- end
		
		if #jork > 0 then
			-- logic.printCards(cards)
			-- logic.printMachineCards(cards)
			local answer
			local function getjorkchangedfs(result)
				result = result or {}
				if answer then return end
				if #result >= #jork then
					logic.printMachineCards(result)
					
					table.mergeByAppend(tcards, result)

					logic.printMachineCards(tcards)
					ct, kv = getnormalcardtype(tcards)
					print(string.format('ct: %d   kv:%d', ct, kv))
					if ct ~= CT_ERROR then--and (not prect or (ct == prenode.ct and kv > prenode.kv)) then
						answer = {ct = ct, kv = kv, change = result}
					end
					for k, v in pairs(result) do
						for k1, v1 in pairs(tcards) do
							if v == v1 then
								table.remove(tcards, k1)
								break
							end
						end
					end
					return 
				end
				for i = 13, 1, -1 do
					table.insert(result, i * 10 + jork[#result + 1])
					getjorkchangedfs(result)
					if answer then return end
					table.remove(result, #result)
				end
			end

			getjorkchangedfs()
			if answer then
				return answer.ct, answer.kv, answer.change
			end
		end
	end

	return CT_ERROR
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
			table.insert(result, logic.getCardsNode({hashTab[k][1], hashTab[k][2]}, CT_PAIRS, k))
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
						table.insert(lines, logic.getCardsNode(util.copyTab(line), CT_SEQUENCE, logic.getCardLogicValue(line[1])))--{amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_SEQUENCE, weight = logic.getCardsWeight(line, CT_SEQUENCE), cards = util.copyTab(line)})
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
							table.insert(lines, logic.getCardsNode(util.copyTab(line), CT_SEQUENCE, logic.getCardLogicValue(line[1])))
							--table.insert(lines, {amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_SEQUENCE, weight = logic.getCardsWeight(line, CT_SEQUENCE), cards = util.copyTab(line)})
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
							table.insert(doubleLines, logic.getCardsNode(util.copyTab(line), CT_PAIRS_SEQUENCE, logic.getCardLogicValue(line[1])))--{amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_PAIRS_SEQUENCE, weight = logic.getCardsWeight(line, CT_PAIRS_SEQUENCE), cards = util.copyTab(line)})
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
							table.insert(doubleLines, logic.getCardsNode(util.copyTab(line), CT_PAIRS_SEQUENCE, logic.getCardLogicValue(line[1])))
							--table.insert(doubleLines, {amount = #line, keyValue = logic.getCardLogicValue(line[1]), cardType = CT_PAIRS_SEQUENCE, weight = logic.getCardsWeight(line, CT_PAIRS_SEQUENCE), cards = util.copyTab(line)})
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
								table.insert(plane, logic.getCardsNode(util.copyTab(line), CT_THREE_SEQUENCE, logic.getCardLogicValue(line[1])))
							elseif takeOne then
								local combs = logic.getMinSingleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_TAKE_ONE, logic.getCardLogicValue(line[1])))
								end
							elseif takeTwo then
								local combs = logic.getMinDoubleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_TAKE_PAIRS, logic.getCardLogicValue(line[1])))
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
								table.insert(plane, logic.getCardsNode(util.copyTab(line), CT_THREE_SEQUENCE, logic.getCardLogicValue(line[1])))
							elseif takeOne then
								local combs = logic.getMinSingleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_TAKE_ONE, logic.getCardLogicValue(line[1])))
								end
							elseif takeTwo then
								local combs = logic.getMinDoubleEX(cards, #line / 3, line)
								for k1, v1 in pairs(combs) do
									table.insert(plane, logic.getCardsNode(util.merge(util.copyTab(line), v1), CT_THREE_TAKE_PAIRS, logic.getCardLogicValue(line[1])))
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
						table.insert(plane, logic.getCardsNode(util.copyTab(line), CT_THREE_SEQUENCE, logic.getCardLogicValue(line[1])))
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
			table.insert(result, logic.getCardsNode(util.copyTab(hashTab[k]), CT_SET, k))
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
				table.insert(result, logic.getCardsNode(util.copyTab(hashTab[k]), CT_SET, k))
			elseif takeOne then
				local combs = logic.getMinSingleEX(cards, 1, hashTab[k])
				for k1, v1 in pairs(combs) do
					table.insert(result, logic.getCardsNode(util.merge(util.copyTab(hashTab[k]), v1), CT_THREE_TAKE_ONE, k))
				end
			elseif takeTwo then
				local combs = logic.getMinDoubleEX(cards, 1, hashTab[k])
				for k1, v1 in pairs(combs) do
					table.insert(result, logic.getCardsNode(util.merge(util.copyTab(hashTab[k]), v1), CT_THREE_TAKE_PAIRS, k))
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
			table.insert(result, logic.getCardsNode({v[1], v[2]}, CT_PAIRS, k))
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
			table.insert(result, logic.getCardsNode({v[1], v[2]}, CT_PAIRS, k))
		end
	end
	return result
end

function logic.getAllBomCard(cards, preKeyValue, amount)
	local amount = amount or 4
	local preKeyValue = preKeyValue or 0
	local boomList = {}
	local hasTab = logic.getCardsHashTab(cards)

	for k, v in pairs(hasTab) do
		if k > preKeyValue and #v >= amount then
			table.insert(boomList, logic.getCardsNode(util.copyTab(v), CT_BOMB4, k))
		end
	end

	if hasTab[14] ~= nil and #hasTab[14] == 2 and hasTab[15] ~= nil and #hasTab[15] == 2 then
		table.insert(boomList, logic.getCardsNode({140, 140, 150, 150}, CT_MISSILE_CARD, 14))
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
	local temp
	for i = pos, #cards do
		if next(result) == nil and i > #cards - amount + 1 then
			return
		end

		temp = logic.getCardLogicValue(cards[i][1])
		if next(result) and temp < 13 and logic.getCardLogicValue(result[#result]) + 1 == temp then
			util.merge(result, cards[i])
		end
		
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
	if node.cardType == CT_THREE_TAKE_ONE or node.cardType == CT_THREE_TAKE_PAIRS or
		node.cardType == CT_FOUR_LINE_TAKE_ONE or node.cardType == CT_FOUR_LINE_TAKE_TWO then
		local hashTab = logic.getCardsHashTab(node.cards)
		-- local result = {}
		for k, v in pairs(hashTab) do
			if #v == amount and k > compareKey then
				if amount == 1 then
					table.insert(result, logic.getCardsNode({v[1]}, CT_SINGLE, k))
				elseif amount == 2 then
					table.insert(result, logic.getCardsNode({v[1], v[2]}, CT_PAIRS, k))
				end
			end
		end
	end
end

function logic.sparateMasterFromTakes(node, compareAmout, cutAmount)
	if node.cardType == CT_THREE_TAKE_ONE or node.cardType == CT_THREE_TAKE_PAIRS or
		node.cardType == CT_FOUR_LINE_TAKE_ONE or node.cardType == CT_FOUR_LINE_TAKE_TWO or
		node.cardType == CT_SET or node.cardType == CT_THREE_SEQUENCE then
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
-- 	if cardType == CT_SINGLE or cardType == CT_PAIRS or cardType == CT_SET or 
-- 		cardType == CT_SEQUENCE or cardType == CT_PAIRS_SEQUENCE or cardType == CT_THREE_SEQUENCE or
-- 		 cardType == CT_BOMB4 or cardType == CT_MISSILE_CARD then
-- 		return logic.getCardLogicValue(cards[1])
-- 	end

-- 	local hashTab = logic.getCardsHashTab(cards)

-- 	if cardType == CT_THREE_TAKE_ONE or cardType == CT_THREE_TAKE_PAIRS then
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
	140,150,
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
	{tp = CT_SET, percent = 20, subpercent = 25, increment = 10, max = 1},
	{tp = CT_SEQUENCE, percent = 25, subpercent = 25, increment = 5, max = 3},
	{tp = CT_PAIRS_SEQUENCE, percent = 20, subpercent = 20, increment = 5, max = 2},
	{tp = CT_THREE_SEQUENCE, percent = 15, subpercent = 10, increment = 5, max = 1},
	{tp = CT_BOMB4, percent = 20, subpercent = 15, increment = 5, max = 1},
}

local function getSpecialGroup(tp, cards, exnum)
	local options = {}
	if tp == CT_SET then
		-- print('三张')
		options = logic.getAllThreeCardLow(cards, false, false, 1)
	elseif tp == CT_SEQUENCE then
		-- print('顺子')
		options = logic.getAllLineCard(cards, 1, exnum + 5)
	elseif tp == CT_PAIRS_SEQUENCE then
		-- print('连对')
		options = logic.getAllDoubleLineCard(cards, 1, exnum + 3)
	elseif tp == CT_THREE_SEQUENCE then
		-- print('飞机')
		options = logic.getAllThreeLineCard(cards, 1, exnum + 2)
	elseif tp == CT_BOMB4 then
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
			r = math.random(1, 80) --牌型概率
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
				if _template[i].tp == CT_BOMB4 then
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

function logic.createCardsGroupXplayer(sidx)
	local cards = {}
	for k, v in pairs(_cards) do
		table.insert(cards, v)
	end
	-- print('开始组牌')
	local cardsgroup = {}
	local boomcnt = math.random(2, 3)
	
	cardsgroup[sidx] = create1group(cards, 2)
	for i = 1, boomcnt do
		local group = getSpecialGroup(CT_BOMB4, cards)
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
	idx = math.random(10, 80)
	for i = idx, #_cards do
	  table.insert(cards, 1, table.remove(cards, #cards))
	end
	-- 抽70次
	local j
	for i = 1, 70 do
		j = math.random(1, #cards)
		if i ~= j then
			cards[i] = cards[i] + cards[j]
			cards[j] = cards[i] - cards[j]
			cards[i] = cards[i] - cards[j]
		end
	end

	for i = 101, #_cards do --防止底牌过于集中
        j = math.random(1, 100)
        if i ~= j then
            cards[i] = cards[i] + cards[j]
            cards[j] = cards[i] - cards[j]
            cards[i] = cards[i] - cards[j]
        end
    end

	local cardsgroup = {}
	for i = 1, 4 do
    	cardsgroup[i] = {}
		idx = (i - 1) * 25
		for j = idx + 1, idx + 25 do
			table.insert(cardsgroup[i], cards[j])
		end
	end
	local mastercards = table.arraycopy(cards, 101, 8)
	return cardsgroup, mastercards
	-- return logic.killBadCards(cardsgroup, mastercards)
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

return logic