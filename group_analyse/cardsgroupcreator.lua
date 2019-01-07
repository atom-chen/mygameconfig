
local logic = {}


function logic.getCardLogicValue(card)
	-- assert(type(card) ~= 'table')
	return math.floor(card / 10)
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
	{tp = CT_THREE, percent = 20, subpercent = 25, increment = 10, max = 1},
	{tp = CT_SINGLE_LINE, percent = 25, subpercent = 25, increment = 5, max = 3},
	{tp = CT_DOUBLE_LINE, percent = 20, subpercent = 20, increment = 5, max = 2},
	{tp = CT_THREE_LINE, percent = 15, subpercent = 10, increment = 5, max = 1},
	{tp = CT_BOMB_CARD, percent = 20, subpercent = 15, increment = 5, max = 1},
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

local function create1group(cards, count)
	local result = {}
	local r-- = math.random(1, 100) --牌型概率
	local subr-- = math.random(1, 100) -- 牌型基础升级概率
	local exnum = 0 -- 升级次数
	local percent = 0 --累计概率
	local subpercent = 0 --累计升级概率

	local hasboom = false
	for c = 1, count do
		percent = 0
		exnum = 0
		subpercent = 0
		
		if hasboom then
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
				if _template[i].tp == CT_BOMB_CARD then
					hasboom = true
				end
				-- print('_template[i].tp: '..tostring(_template[i].tp)..'   exnum: '..tostring(exnum))
				-- logic.printCards(cards)
				--根据条件得到指定牌型
				local group = getSpecialGroup(_template[i].tp, cards, exnum)
				-- print('生成扑克 #group : '..tostring(#group))
				-- logic.printCards(group)
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

function logic.createCardsGroup(finish)
	local cards = {}
	for k, v in pairs(_cards) do
		table.insert(cards, v)
	end
	-- print('开始组牌')
	local cardsgroup = {}
	for i = 1, 3 do
		cardsgroup[i] = create1group(cards, 2)
		-- print('玩家 '..tostring(i))
		-- logic.printCards(cardsgroup[i])
		-- print('\n')
	end

	-- print('给剩余的扑克排序')
	local j
	for i = 1, #cards do
		j = math.random(1, #cards)
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

function logic.createCardsNormal(finish)
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

return logic