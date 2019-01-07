local logic = {}

local _cardres = {
	10,11,12,13, -- 2
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
	130,131,132,133} -- A

logic.ct_set = 6
logic.ct_flushstraight = 5
logic.ct_flush = 4
logic.ct_straight = 3
logic.ct_pair = 2
logic.ct_highcard = 1

local _ct_probability = {710, 200, 45, 20, 15, 10}

local _card_amount = 3
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
				table.insert(flushstraight, line)
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

	local ridx 
	for i = 1, #result do
		ridx = math.random(1, #result)
		if ridx ~= i then
			result[ridx] = result[ridx] + result[i]
			result[i] = result[ridx] - result[i]
			result[ridx] = result[ridx] - result[i]
		end
	end

	return result
end

-- function logic.getcardsnode(prob)
-- 	local r = math.random(1, 1000)
-- 	local pc = 0
-- 	local ct
-- 	for k, v in pairs(prob) do
-- 		pc = pc + v.probability
-- 		if r <= pc then
-- 			ct = k
-- 			break
-- 		end
-- 	end
-- 	if not ct then return end

-- 	local rcards = createspecifiedct(ct)
-- 	-- local ct = logic.getCardType(rcards)
-- 	return {cards = rcards, ct = ct}
-- end

local function createspecialcards(cards)
	local r = math.random(1, 1000)
	local pc = 0
	local ct
	for k, v in pairs(_ct_probability) do
		pc = pc + v
		if r <= pc then
			ct = k
			break
		end
	end
	if not ct then return end
	return createspecifiedct(cards, ct)
end

local function set_235(node1, node2)
	local hash = {}
	-- if node1.ct == logic.ct_set and node2.ct == logic.ct_highcard then
	-- 	for k, v in pairs(node2.cards) do
	-- 		hash[logic.getCardLogicValue(v)] = 1
	-- 	end
	-- 	if hash[1] and hash[2] and hash[4] then
	-- 		return true
	-- 	end
	-- end

	if node1.ct == logic.ct_highcard and node2.ct == logic.ct_set then
		for k, v in pairs(node1.cards) do
			hash[logic.getCardLogicValue(v)] = 1
		end
		if hash[1] and hash[2] and hash[4] then
			return true
		end
	end
end

function logic.node1better(node1, node2)
	if node1.ct == node2.ct then
		if node1.kv ~= node2.kv then
			return node1.kv > node2.kv
		else
			local c1, c2
			if node1.ct == logic.ct_pair then
				-- for k, v in pairs(node1.cards) do
				for i = 1, 3 do
					if not c1 then
						c1 = logic.getCardLogicValue(node1.cards[i])
					end
					if not c2 then
						c2 = logic.getCardLogicValue(node2.cards[i])
					end
					if c1 == node1.kv then
						c1 = nil
					end

					if c2 == node2.kv then
						c2 = nil
					end
				end

				if c1 == c2 then
					--return -1
				else
					return c1 > c2
				end
			end

			table.sort(node1.cards, function(c1, c2)
				return c1 > c2
			end)

			table.sort(node2.cards, function(c1, c2)
				return c1 > c2
			end)

			for i = 1, 3 do
				c1 = logic.getCardLogicValue(node1.cards[i])
				c2 = logic.getCardLogicValue(node2.cards[i])
				if c1 ~= c2 then
					return c1 > c2
				end
			end

			return node1.cards[1] > node2.cards[1]
		end
	else
		if set_235(node1, node2) then
			return true
		end
		return node1.ct > node2.ct
	end
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

function logic.gettotalcards(amount)
	if not amount or amount > 5 then return end
	
	local cards = {}
	for k, v in pairs(_cardres) do
		table.insert(cards, v)
	end

	local nodes = {}
	for i = 1, amount do
		local node = {cards = {}}
		node.cards = createspecialcards(cards)
		node.ct, node.kv = logic.getCardType(node.cards)
		table.insert(nodes, node)
	end
	return nodes
end

-- function logic.getcards(seatid, donottryagain)
-- 	if not seatid or seatid < 1 or seatid > 5 then return end
-- 	local s = (seatid - 1) * 7 + 1

-- 	if donottryagain then
-- 		logic.shuffle(s)
-- 	end

-- 	local node = {cards = {}}
-- 	for i = s, s + 6 do
-- 		table.insert(node.cards, _cardres[i])
-- 	end
-- 	node.ct, node.kv, node.multi = logic.getCardType(node.cards)
-- 	-- node.multi = 1
-- 	if not donottryagain then
-- 		if node.ct == 1 then
-- 			return logic.getcards(seatid, true)
-- 		end
-- 	end
-- 	return node
-- end

function logic.getCardLogicValue(card)
	-- assert(type(card) ~= 'table')
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
	print('-----------------getCardType')
	luadump(cards)
	if not cards or not next(cards) then return end--or #cards < _card_amount 
	local cardamount = #cards
	local hash = {}
	for i = 1, cardamount do
		key = logic.getCardLogicValue(cards[i])
		hash[key] = hash[key] or 0
		hash[key] = hash[key] + 1
	end
	
	for k, v in pairs(hash) do
		if v == 3 then
			return logic.ct_set, k
		elseif v == 2 then
			return logic.ct_pair, k
		end
	end

	local flush = true
	local flower = cards[1] % 10
	for i = 2, cardamount do
		if cards[i] % 10 ~= flower then
			flush = false
			break
		end
	end

	local straightkv
	for i = 1, 12 do
		if hash[i] then
			straightkv = i
			print('----------------straightkv: '..tostring(straightkv))
			for j = i, i + cardamount - 1 do
				if not hash[j] then
					print('----------------not hash[j]')
					if (cardamount == 3 and hash[1] and hash[2] and hash[13]) or (cardamount == 2 and hash[1] and hash[13]) then --A2345
						straightkv = 0
						break
					end
					for i1 = 13, 1, -1 do
						if hash[i1] then
							if flush then
								return logic.ct_flush, i1
							else
								return logic.ct_highcard, i1
							end
						end
					end
				end
			end
			break
		end
	end
print('----------------straightkv: '..tostring(straightkv))
	if flush then
		return logic.ct_flushstraight, straightkv
	end

	return logic.ct_straight, straightkv
end

function logic.getsidepercent(cards1, cards2)
	if not cards1 or not cards2 or not next(cards1) or #cards1 < 2 or not next(cards2) or #cards2 < 2 then return end
	local node1 = {}
	node1.ct, node1.kv = logic.getCardType(cards1)
	local node2 = {}
	node2.ct, node2.kv = logic.getCardType(cards2)
	logic.printCards(cards1)
	logic.printCards(cards2)
	local node1percent
	luadump(node1)
	luadump(node2)
	if node1.ct == node2.ct then
		if node1.kv ~= node2.kv then
			if node1.kv > node2.kv then
				if node1.ct == logic.ct_pair or node1.ct == logic.ct_highcard then
					node1percent = 100
				else
					node1percent = 90
				end
			else
				if node2.ct == logic.ct_pair or node2.ct == logic.ct_highcard then
					node1percent = 0
				else
					node1percent = 10
				end
			end
		else
			node1percent = 50
		end
	else
		if node1.ct > node2.ct then
			if node1.ct == logic.ct_pair or (node2.kv < node1.kv) then
				node1percent = 100
			else
				if node2.kv < node1.kv then
					node1percent = 90
				else
					node1percent = 65
				end
			end
		else
			if node1.ct == logic.ct_pair then
				node1percent = 70
			elseif node2.ct == logic.ct_pair or (node1.kv < node2.kv) then
				node1percent = 0
			else
				if node2.kv < node1.kv then
					node1percent = 40
				else
					node1percent = 10
				end
			end
		end
	end
	return node1percent
end

return logic