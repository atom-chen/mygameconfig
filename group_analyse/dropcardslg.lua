local logic = {}

local _cardres = {
	10,11,12,13, -- 3
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
	130,131,132,133} -- 2
-- 炸弹7 葫芦6 顺子5 三张4 连对3 对子2 单牌1
logic.ct_quad = 7
logic.ct_fullhouse = 6
logic.ct_straight = 5
logic.ct_set = 4
logic.ct_twopair = 3
logic.ct_pair = 2
logic.ct_highcard = 1

-- local ct_multip = {1, 1, 2, 3, 4, 5, 6}

-- local ct_probability = {300, 260, 100, 100, 100, 80, 60}

local _card_amount = 5

local function getCardsHash(cards)
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or {}
		table.insert(hash[key], v)
	end
	return hash
end

local function get_all_pairs(cards, hash)
	if #cards < 5 then return end
	local options = {}
	local hash = hash or getCardsHash(cards)

	local kused = {}
	for k, v in pairs(hash) do
		if #v >= 2 then
			kused[k] = true
			table.insert(options, {v[1], v[2]})
		end
	end
	return options
end

local function get_all_set(cards, hash)
	if #cards < 5 then return end
	local options = {}
	local hash = hash or getCardsHash(cards)
	for k, v in pairs(hash) do
		if #v >= 3 then
			table.insert(options, {v[1], v[2], v[3]})
		end
	end
	return options
end

local function get_all_quad(cards, hash)
	if #cards < 5 then return end
	local options = {}
	local hash = getCardsHash(cards)
	for k, v in pairs(hash) do
		if #v >= 4 then
			table.insert(options, {v[1], v[2], v[3], v[4]})
		end
	end
	return options
end

local function get_all_sequece(cards, hash)
	if #cards < 5 then return end
	local lines = {}
	local line = {}
	local hash = getCardsHash(cards)
	for k, v in pairs(hash) do
		line = {v[1]}
		for j = k + 1, 12 do
			if hash[j] ~= nil then
				table.insert(line, hash[j][math.random(1, #hash[j])])
				if #line >= 5 then
					table.insert(lines, line)
					break
				end
			else
				break
			end
		end
	end

	return lines
end

local function fill_less_cards(cards, result)
	result = result or {}
	if #result < _card_amount then
		local find
		for k, v in pairs(cards) do
			find = false
			for k1, v1 in pairs(result) do
				if v1 == v then
					find = true
					break
				end
			end
			if not find then
				table.insert(result, v)
				if #result >= _card_amount then
					break
				end
			end
		end
	end

	local ri
	for i = 1, 5 do
		ri = math.random(1, 5)
		if i ~= ri then
			result[i] = result[i] + result[ri]
			result[ri] = result[i] - result[ri]
			result[i] = result[i] - result[ri]
		end
	end

	return result
end

local function createspecifiedct(ct)
	if not ct or ct < logic.ct_highcard or ct > logic.ct_quad then return end
	local hash = {}
	local key
	local cards = _cardres
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or {}
		table.insert(hash[key], v)
	end
	local result = {}
	if ct == logic.ct_highcard then
		local ocard = {}
		for i = 1, 13 do
			table.insert(ocard, i)
		end
		local idx
		for i = 1, _card_amount do
			idx = math.random(1, #ocard)
			table.insert(result, table.remove(ocard, idx) * 10 + math.random(1, 4) - 1)
		end
		-- result = fill_less_cards(cards)
	elseif ct == logic.ct_pair then
		local options = get_all_pairs(cards, hash)
		result = fill_less_cards(cards, options[math.random(1, #options)])
	elseif ct == logic.ct_twopair then
		local options = get_all_pairs(cards, hash)
		local op
		for i = 1, 2 do
			if options and next(options) then
				op = table.remove(options, math.random(1, #options))
				if op and next(op) then
					table.insert(result, op[1])
					table.insert(result, op[2])
				end
			end
		end

		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_set then
		local options = get_all_set(cards, hash)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end
		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_straight then
		local options = get_all_sequece(cards, hash)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end
		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_fullhouse then
		local opsets = get_all_set(cards, hash)
		local oppairs = get_all_pairs(cards, hash)
		if opsets and next(opsets) then
			result = opsets[math.random(1, #opsets)]
		end
		for k, v in pairs(oppairs) do
			if logic.getCardLogicValue(result[1]) == logic.getCardLogicValue(v[1]) then
				table.remove(oppairs, k)
				break
			end
		end
		if oppairs and next(oppairs) then
			local option = oppairs[math.random(1, #oppairs)]
			table.insert(result, option[1])
			table.insert(result, option[2])
		end

		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_quad then
		local options = get_all_quad(cards, hash)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end
		result = fill_less_cards(cards, result)
	end
	return result
end

function logic.shuffle(sindex)
	--洗牌
	local randomIndex
	local sindex = sindex or 1
	for i = sindex, 52 do
		randomIndex = math.random(i, 52)
		--luadump(_cardres)
		if randomIndex ~= i then
			_cardres[i] = _cardres[i] + _cardres[randomIndex]
			_cardres[randomIndex] = _cardres[i] - _cardres[randomIndex]
			_cardres[i] = _cardres[i] - _cardres[randomIndex]
		end
	end
end

function logic.getcardsnode(prob)
	local r = math.random(1, 1000)
	local pc = 0
	local ct
	for k, v in pairs(prob) do
		pc = pc + v.probability
		if r <= pc then
			ct = k
			break
		end
	end
	logic.shuffle()
	if not ct then return end
	-- print(string.format('getcardsnode  ct:%d', ct))
	local rcards = createspecifiedct(ct)
	ct = logic.getCardType(rcards)
	return {cards = rcards, ct = ct}
end

function logic.getCardLogicValue(card)
	assert(type(card) ~= 'table')
	return math.floor(card / 10)
end

function logic.getKeyValueInCards(cards, ct)
	local cardType = ct or logic.getCardType(cards)
	if cardType == logic.CT_HIGH_CARD then
		return 0
	end
	if cardType == CT_SINGLE or cardType == CT_DOUBLE or cardType == CT_THREE or 
		cardType == CT_SINGLE_LINE or cardType == CT_DOUBLE_LINE or cardType == CT_THREE_LINE or
		 cardType == CT_BOMB_CARD or cardType == CT_MISSILE_CARD then
		return logic.getCardLogicValue(cards[1])
	end

	local hashTab = logic.getCardsHashTab(cards)

	if cardType == CT_THREE_LINE_TAKE_ONE or cardType == CT_THREE_LINE_TAKE_TWO then
		for i = 1, 13 do
			if hashTab[i] and #hashTab[i] == 3 then
				return i
			end
		end
	end

	if cardType == CT_FOUR_LINE_TAKE_ONE or cardType == CT_FOUR_LINE_TAKE_TWO then
		for i = 1, 13 do
			if hashTab[i] and #hashTab[i] == 4 then
				return i
			end
		end
	end
end

function logic.getCardType(cards)
	if not cards or not next(cards) or #cards < 5 then return end
	local hash = {}
	for i = 1, 5 do
		key = logic.getCardLogicValue(cards[i])
		hash[key] = hash[key] or 0
		hash[key] = hash[key] + 1
	end
	local tsets = {}
	local tpairs = {}
	for k, v in pairs(hash) do
		if v == 4 then
			return logic.ct_quad--, k, ct_multip[logic.ct_quad]
		elseif v == 2 then
			table.insert(tpairs, k)
		elseif v == 3 then
			table.insert(tsets, k)
		end
	end
	if next(tsets) and next(tpairs) then
		return logic.ct_fullhouse--, tsets[1]--, ct_multip[logic.ct_fullhouse]
	elseif next(tsets) then
		return logic.ct_set--, tsets[1]--, ct_multip[logic.ct_set]
	elseif #tpairs == 2 then
		table.sort(tpairs, function(p1, p2)
			return p1 > p2
		end)
		return logic.ct_twopair--, tpairs[1], ct_multip[logic.ct_twopair]
	elseif #tpairs == 1 then
		return logic.ct_pair--, tpairs[1], ct_multip[logic.ct_pair]
	end

	local straightkv
	for i = 1, 12 do
		if hash[i] then
			for j = i + 1, i + 4 do
				if not hash[j] then
					for i1 = 13, 1, -1 do
						if hash[i1] then
							return logic.ct_highcard--, i1, ct_multip[logic.ct_highcard]
						end
					end
				end
			end
			straightkv = i
			break
		end
	end

	return logic.ct_straight--, straightkv, ct_multip[logic.ct_straight]
end

return logic