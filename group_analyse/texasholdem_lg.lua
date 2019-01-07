local logic = {}

local _cardres = {
	10,11,12,13, -- 2
	20,21,22,23,
	30,31,32,33,
	40,41,42,43,
	50,51,52,53,--6
	60,61,62,63,
	70,71,72,73,
	80,81,82,83,
	90,91,92,93,
	100,101,102,103,
	110,111,112,113,
	120,121,122,123,
	130,131,132,133} -- A

logic.ct_flushstraight = 9	--同花顺
logic.ct_quad = 8 		   	--4张
logic.ct_fullhouse = 7 		--葫芦
logic.ct_flush = 6			--同花
logic.ct_straight = 5		--顺子
logic.ct_set = 4			--三张
logic.ct_twopair = 3		--两队
logic.ct_pair = 2			--对子
logic.ct_highcard = 1		--高牌

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
	if #cards < _card_amount then return end
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

local function get_all_flush(cards)
	if #cards < _card_amount then return end

	local hash = {}
	local flower
	for k, v in pairs(cards) do
		flower = v % 10
		hash[flower] = hash[flower] or {}
		table.insert(hash[flower], v)
	end

	local options = {}

	for k, v in pairs(hash) do
		if #v >= 3 then
			table.insert(options, {v[1], v[2], v[3]})
		end
	end
	return options
end

local function get_all_flushstraight(cards)
	if #cards < _card_amount then return end
	local hash = {}
	local flower
	local val
	for k, v in pairs(cards) do
		flower = v % 10
		val = math.floor(v / 10)
		hash[flower] = hash[flower] or {}
		hash[flower][val] = 1
	end

	local flushstraight = {}
	local line = {}
	for k, v in pairs(hash) do
		for j = 1, 10 do
			line = {}
			for i = j, j + _card_amount - 1 do
				if not v[i] then
					break
				end
				table.insert(line, i * 10 + k)
			end
			if #line == _card_amount then
				table.insert(flushstraight, {line})
			end
		end
	end

	return flushstraight
end

local function get_all_set(cards, hash)
	if #cards < _card_amount then return end
	local options = {}
	local hash = hash or getCardsHash(cards)
	for k, v in pairs(hash) do
		if #v >= 3 then
			table.insert(options, {v[1], v[2], v[3]})
		end
	end
	return options
end

local function get_all_straight(cards, hash)
	if #cards < _card_amount then return end
	local lines = {}
	local line = {}
	local hash = hash or getCardsHash(cards)
	for k, v in pairs(hash) do
		line = {v[1]}
		for j = k + 1, 12 do
			if hash[j] ~= nil then
				table.insert(line, hash[j][math.random(1, #hash[j])])
				if #line >= _card_amount then
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
	for k, v in pairs(result) do
		for k1, v1 in pairs(cards) do
			if v == v1 then
				table.remove(cards, k1)
			end
		end
	end

	while #result < _card_amount do
		table.insert(result, table.remove(cards, math.random(1, #cards)))
	end

	-- local ri
	-- for i = 1, _card_amount do
	-- 	ri = math.random(1, _card_amount)
	-- 	if i ~= ri then
	-- 		result[i] = result[i] + result[ri]
	-- 		result[ri] = result[i] - result[ri]
	-- 		result[i] = result[i] - result[ri]
	-- 	end
	-- end

	return result
end

local function createspecifiedct(cards, ct)
	if not ct or ct < logic.ct_highcard or ct > logic.ct_set then return end
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or {}
		table.insert(hash[key], v)
	end

	local result = {}
	if ct == logic.ct_highcard then
		result = fill_less_cards(cards)
	elseif ct == logic.ct_pair then
		local options = get_all_pairs(cards, hash)
		result = fill_less_cards(cards, options[math.random(1, #options)])
	elseif ct == logic.ct_straight then
		local options = get_all_straight(cards, hash)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end
		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_flush then-------------------------------------
		local options = get_all_flush(cards)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end

		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_flushstraight then--------------------------  ,lbh
		-- get_all_flushstraight
		local options = get_all_flushstraight(cards)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end
		result = fill_less_cards(cards, result)
	elseif ct == logic.ct_set then
		local options = get_all_set(cards, hash)
		if options and next(options) then
			result = options[math.random(1, #options)]
		end
		result = fill_less_cards(cards, result)
	end
	return result
end

local function createspecialcards(cards)
	local r = math.random(1, 1000)
	local pc = 0
	local ct
	for k, v in pairs(ct_probability) do
		pc = pc + v
		if r <= pc then
			ct = k
			break
		end
	end
	if not ct then return end
	return createspecifiedct(cards, ct)
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

-- logic.ct_flushstraight = 9	--同花顺
-- logic.ct_quad = 8 		   	--4张
-- logic.ct_fullhouse = 7 		--葫芦
-- logic.ct_flush = 6			--同花
-- logic.ct_straight = 5		--顺子
-- logic.ct_set = 4			--三张
-- logic.ct_twopair = 3		--两队
-- logic.ct_pair = 2			--对子
-- logic.ct_highcard = 1		--高牌

local _hidecardspercent = {}--[2] = 15, [5] = 20, [6] = 15, [9] = 10}
-- local _hidecardspercent = {[5] = 100}
local function getbetterhidecards(cards)
	local percent = math.random(1, 100)
	local sump = 0
	local ct = 0
	for k, v in pairs(_hidecardspercent) do
		sump = sump + v
		if percent <= sump then
			ct = k
			break
		end
	end
	local result = {}
	local hash = getCardsHash(cards)
	local options = {}
	if ct == logic.ct_pair then
		for k, v in pairs(hash) do
			if #v >= 2 then
				table.insert(options, {v[1], v[2]})
			end
		end
		result = options[math.random(1, #options)]
	elseif ct == logic.ct_straight then
		local spos = math.random(4, 12)
		for i = spos, 12 do
			if hash[i] and hash[i + 1] then
				table.insert(result, hash[i][1])
				table.insert(result, hash[i + 1][1])
				luadump(result)

				break
			end
		end
	elseif ct == logic.ct_flush then
		for k, v in pairs(hash) do
			if k >= 8 and #v > 0 then
				table.insert(options, v[1])
			end
		end
		table.insert(result, options[math.random(1, #options)])
		for k, v in pairs(cards) do
			if v ~= result[1] and (v % 10 == result[1] % 10) then
				table.insert(result, v)
				break
			end
		end
	elseif ct == logic.ct_flushstraight then
		for k, v in pairs(hash) do
			if k >= 6 and #v > 0 and hash[k + 1] then
				table.insert(options, {v[1], hash[k + 1][1]})
			end
		end
		result = options[math.random(1, #options)]
	end


	if not result or #result < 2 then
		options = {}
		result = {}
		for k, v in pairs(cards) do
			if v / 10 > 10 then
				table.insert(options, v)
			end
		end
    luadump(options)
		if #options < 2 then
      print('1111111111111111111111111111111111111111111111')
			options = {}
			for k, v in pairs(cards) do
				table.insert(options, v)
			end
		end

		table.insert(result, table.remove(options, math.random(1, #options)))
		table.insert(result, table.remove(options, math.random(1, #options)))
	end

	for k, v in pairs(result) do
		for k1, v1 in pairs(cards) do
			if v == v1 then
				table.remove(cards, k1)
				break
			end
		end
	end
	return result
end

function logic.gettotalcards(amount, xmodel)
	if not amount or amount > 10 then return end
	
	local cards = {}
	for k, v in pairs(_cardres) do
		table.insert(cards, v)
	end

	local nodes = {}

	local publiccards = {}
	for j = 1, 5 do
		table.insert(publiccards, table.remove(cards, math.random(1, #cards)))
	end

	if not xmodel then
		for i = 1, amount do
			local handcards = {}
			for j = 1, 2 do
				table.insert(handcards, table.remove(cards, math.random(1, #cards)))
			end
			local node = logic.getMaxCombination(handcards, publiccards)
			node.hidecards = handcards
			table.insert(nodes, node)
		end
	else
		for i = 1, amount do
			local handcards = getbetterhidecards(cards)
			local node = logic.getMaxCombination(handcards, publiccards)
			node.hidecards = handcards
			table.insert(nodes, node)
		end
	end
	return nodes, publiccards
end

function logic.node1better(node1, node2)
	if node1.ct == node2.ct then
		if node1.kv1 == node2.kv1 then
			if node1.kv2 == node2.kv2 then
				table.sort(node1.cards, function(c1, c2)
					return c1 > c2
				end)

				table.sort(node2.cards, function(c1, c2)
					return c1 > c2
				end)

				local k1, k2
				for i = 1, _card_amount do
					k1 = logic.getCardLogicValue(node1.cards[i])
					k2 = logic.getCardLogicValue(node2.cards[i])
					if k1 ~= k2 then
						return k1 > k2
					end
				end
				return -1
			else
				return node1.kv2 > node2.kv2
			end
		else
			return node1.kv1 > node2.kv1
		end
	else
		return node1.ct > node2.ct
	end
end

function logic.cards1better(cards1, cards2)
	local node1 = {cards = cards1}
	node1.ct, node1.kv1, node1.kv2 = logic.getCardType(cards1)
	local node2 = {cards = cards2}
	node2.ct, node2.kv1, node2.kv2 = logic.getCardType(cards2)
	
	return logic.node1better(node1, node2)
end

function logic.getMaxCombination(cards, publiccards)
	if not cards or #cards ~= 2 or not publiccards or #publiccards ~= 5 then assert(false) end
	local maxnode

	local function choosebetter(tcards)
		local tnode = {cards = tcards}
		tnode.ct, tnode.kv1, tnode.kv2 = logic.getCardType(tnode.cards)
		if not maxnode then
			maxnode = tnode
		else--if maxnode then
			local r = logic.node1better(tnode, maxnode)
			if r and r ~= -1 then
				maxnode = tnode
			end
		end
	end

	for i = 1, 3 do
		for j = i + 1, 4 do
			for k = j + 1, 5 do
				choosebetter({cards[1], cards[2], publiccards[i], publiccards[j], publiccards[k]})
				for i1 = k + 1, 5 do
					choosebetter({cards[1], publiccards[i], publiccards[j], publiccards[k], publiccards[i1]})
					choosebetter({cards[2], publiccards[i], publiccards[j], publiccards[k], publiccards[i1]})
				end
			end
		end
	end
	choosebetter({publiccards[1], publiccards[2], publiccards[3], publiccards[4], publiccards[5]})

	return maxnode
end

function logic.getcards(seatid, donottryagain)
	if not seatid or seatid < 1 or seatid > 5 then return end
	local s = (seatid - 1) * 7 + 1

	if donottryagain then
		logic.shuffle(s)
	end

	local node = {cards = {}}
	for i = s, s + 6 do
		table.insert(node.cards, _cardres[i])
	end
	node.ct, node.kv, node.multi = logic.getCardType(node.cards)
	-- node.multi = 1
	if not donottryagain then
		if node.ct == 1 then
			return logic.getcards(seatid, true)
		end
	end
	return node
end

function logic.getCardLogicValue(card)
	assert(type(card) ~= 'table')
	return math.floor(card / 10)
end

function logic.getHumanVisible(card)
	local v = logic.getCardLogicValue(card)
	local color
	if card % 10 == 0 then
		color = '♦'
	elseif card % 10 == 1 then
		color = '♣'
	elseif card % 10 == 2 then
		color = '♥'
	elseif card % 10 == 3 then
		color = '♠'
	end
   
	local str = ''
	if v < 10 then
		str = string.format('%s%s', tostring(v + 1), color)
	elseif v == 10 then
		str = 'J'..color
	elseif v == 11 then
		str = 'Q'..color
	elseif v == 12 then
		str = 'K'..color
	elseif v == 13 then
		str = 'A'..color
	end

	return str
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

function logic.getCardType(cards)
	if not cards or not next(cards) or #cards < _card_amount then return end
	local hash = {}

	local maxk = 0
	local flush = true
	local cmpfollow = cards[1] % 10
	for i = 1, _card_amount do
		key = logic.getCardLogicValue(cards[i])
		hash[key] = hash[key] or 0
		hash[key] = hash[key] + 1
		if key > maxk then
			maxk = key
		end

		if flush and cmpfollow ~= cards[i] % 10 then
			flush = false
		end
	end
	
	local tsets = {}
	local tpairs = {}

	local v
	for k = 1, 13 do
		v = hash[k]
		if v then
			if v == 4 then
				return logic.ct_quad, k
			elseif v == 2 then
				table.insert(tpairs, k)
			elseif v == 3 then
				table.insert(tsets, k)
			end
		end
	end

	if next(tsets) and next(tpairs) then
		return logic.ct_fullhouse, tsets[1]--, ct_multip[logic.ct_fullhouse]
	elseif next(tsets) then
		return logic.ct_set, tsets[1]--, ct_multip[logic.ct_set]
	elseif #tpairs == 2 then
		return logic.ct_twopair, tpairs[2], tpairs[1]
	elseif #tpairs == 1 then
		return logic.ct_pair, tpairs[1]
	end

	local straightkv
	for i = 1, 9 do
		if hash[i] then
			straightkv = i
			for j = i, i + _card_amount - 1 do
				if not hash[j] then
					if i == 1 and j == (i + _card_amount - 1) and hash[13] then --A2345
						straightkv = 0
						break
					end
					if flush then
						return logic.ct_flush, maxk
					else
						return logic.ct_highcard, maxk
					end
				end
			end
			break
		end
	end
	if straightkv then
		if flush then
			return logic.ct_flushstraight, straightkv
		end
		return logic.ct_straight, straightkv
	else
		return logic.ct_highcard, maxk
	end
end

return logic