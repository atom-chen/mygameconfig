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
	130,131,132,133, -- A
	140,150}

logic.ct_set = 6
logic.ct_flushstraight = 5
logic.ct_flush = 4
logic.ct_straight = 3
logic.ct_pair = 2
logic.ct_highcard = 1

local _ct_probability = {600, 200, 70, 60, 50, 20}

local _card_amount = 3

local getcardsbydfs
getcardsbydfs = function(pos, cards, container, options, count)
	-- logic.printCards(container)
	if #container >= count then
		table.insert(options, table.arraycopy(container, 1, count))
		return
	end
	for i = pos, #cards do
		table.insert(container, cards[i])
		-- if i + 1 <= #cards then
		-- 	print(i + 1)
		getcardsbydfs(i + 1, cards, container, options, count)
		-- end
		table.remove(container, #container)
	end
end

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

local function get_pairs(cards, hash)
	local options = {}
	if hash[14] or hash[15] then
		for i = 13, 0, -1 do
			if hash[i] and #hash[i] == 1 then
				if hash[14] then
					table.insert(options, {140, hash[i][1]})
				elseif hash[15] then
					table.insert(options, {150, hash[i][1]})
				end
			end
		end
	else
		for i = 13, 0, -1 do
			if hash[i] and #hash[i] >= 2 then
				getcardsbydfs(1, hash[i], {}, options, 2)
				-- table.insert(options, {hash[i][1], hash[i][2]})
			end
		end
	end
	return options
end

function logic.test(cards)
	if #cards < _card_amount then return end
	local options = {}
	local fhash = {}
	local flower
	for k, v in pairs(cards) do
		flower = v % 10
		fhash[flower] = fhash[flower] or {}
		table.insert(fhash[flower], v)
	end

	-- for i = 0, 3 do
	-- 	if fhash[i] then
	-- 		table.sort(fhash[i], function(a, b)
	-- 			return a > b
	-- 		end)
	-- 	end
	-- end
	-- luadump(fhash[1])
	-- getcardsbydfs(1, fhash[1], {}, options, 3)
	-- luadump(options)
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or {}
		table.insert(hash[key], v)
	end

	local pair = get_pairs(cards, hash)
	if pair then
		table.mergeByAppend(options, pair)
	end

	luadump(options)
	-- for i = 0, 3 do
	-- 	if fhash[i] and #fhash[i] >= 3 then
	-- 		getcardsbydfs(1, fhash[i], {}, options, 3)
	-- 	end
	-- end
end

local function get_flush(cards, hash)
	if #cards < _card_amount then return end
	local options = {}
	local fhash = {}
	local flower
	for k, v in pairs(cards) do
		if v ~= 140 and v ~= 150 then
			flower = v % 10
			fhash[flower] = fhash[flower] or {}
			table.insert(fhash[flower], v)
		end
	end

	for i = 0, 3 do
		if fhash[i] then
			table.sort(fhash[i], function(a, b)
				return a > b
			end)
		end
	end
	for i = 0, 3 do
		if fhash[i] and #fhash[i] >= 3 then
			getcardsbydfs(1, fhash[i], {}, options, 3)
		end
	end

	if hash[14] or hash[15] then
		for i = 0, 3 do
			if fhash[i] and #fhash[i] >= 2 then
				if (i == 1 or i == 3) and hash[14] then
					table.insert(fhash[i], 140)
					getcardsbydfs(1, fhash[i], {}, options, 3)
				elseif (i == 0 or i == 2) and hash[15] then
					table.insert(fhash[i], 150)
					getcardsbydfs(1, fhash[i], {}, options, 3)
				end
			end
		end
	end
	return options
end

local function get_set(cards, hash)
	local options = {}
	if hash[14] and hash[15] then
		for i = 13, 0, -1 do
			if hash[i] and #hash[i] == 2 then
				table.insert(options, {140, hash[i][1], hash[i][2]})
				table.insert(options, {150, hash[i][1], hash[i][2]})
			end
		end
		
		for i = 13, 0, -1 do
			if hash[i] and #hash[i] < 3 then
				table.insert(options, {140, 150, hash[i][1]})
			end
		end
	elseif hash[14] or hash[15] then
		for i = 13, 0, -1 do
			if hash[i] and #hash[i] == 2 then
				if hash[14] then
					table.insert(options, {140, hash[i][1], hash[i][2]})
				elseif hash[15] then
					table.insert(options, {150, hash[i][1], hash[i][2]})
				end
			end
		end
	end
	for i = 13, 0, -1 do
		if hash[i] and #hash[i] >= 3 then
			getcardsbydfs(1, hash[i], {}, options, 3)
			-- table.insert(options, {hash[i][1], hash[i][2], hash[i][3]})
			-- return {hash[i][1], hash[i][2], hash[i][3]}
		end
	end
	
	return options
end

local function get_flushstraight(cards, chash)
	if #cards < _card_amount then return end
	local options = {}
	local hash = {}
	local flower
	local val
	for k, v in pairs(cards) do
		flower = v % 10
		val = math.floor(v / 10)
		hash[flower] = hash[flower] or {}
		hash[flower][val] = 1
	end

	local line = {}
	for k, v in pairs(hash) do
		local function accept()
			if #line == _card_amount - 1 then
				if (k == 1 or k == 3) and hash[14] then
					table.insert(line, 140)
				elseif (k == 0 or k == 2) and hash[15] then
					table.insert(line, 150)
				end
			end

			if #line == _card_amount then
				table.insert(options, line)
			end
		end
		for j = 1, 11 do
			line = {}
			for i = j, j + _card_amount - 1 do
				if v[i] then
					table.insert(line, k + i * 10)
				end
			end
			accept()
		end
		line = {}
		if v[1] then
			table.insert(line, 10 + k)
		end
		if v[2] then
			table.insert(line, 20 + k)
		end

		if v[13] then
			table.insert(line, 130 + k)
		end
		accept()
	end
	return options
end

local function get_straight(cards, hash)
	if #cards < _card_amount then return end
	local options = {}
	local line = {}
	local hash = hash or getCardsHash(cards)

	local function accept()
		if #line == _card_amount - 1 then
			if hash[14] then
				table.insert(line, 140)
			elseif hash[15] then
				table.insert(line, 150)
			end
		end

		if #line == _card_amount then
			table.insert(options, line)
		end
	end

	for i = 13, 3, -1 do
		line = {}
		for j = i, i - _card_amount + 1, -1 do
			if hash[j] then
				table.insert(line, hash[j][math.random(1, #hash[j])])
			end
		end
		
		accept()
	end
	line = {}
	if hash[1] then
		table.insert(line, hash[1][math.random(1, #hash[1])])
	end
	if hash[2] then
		table.insert(line, hash[2][math.random(1, #hash[2])])
	end

	if hash[13] then
		table.insert(line, hash[13][math.random(1, #hash[13])])
	end
	accept()
	return options
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

function logic.gettotalcardsnormal(amount)
	if not amount or amount > 5 then return end
	
	logic.shuffle()
	local cards = {}
	for k, v in pairs(_cardres) do
		table.insert(cards, v)
	end

	local nodes = {}
	for i = 1, amount do
		local node = {cards = {}}
		for j = 1, 10 do
			table.insert(node.cards, table.remove(cards, math.random(1, #cards)))
			-- node.cards = createspecialcards(cards)
		end
		-- node.ct, node.kv = logic.getCardType(node.cards)
		table.insert(nodes, node)
	end
	return nodes
end

local getcombinationdfs
getcombinationdfs = function(pos, options, tmp, result, maxlen, nodecnt)
	if #tmp >= nodecnt then
		table.insert(result, table.deepcopy(tmp))
		return
	end
	local decline
	local n1, n2
	for i = pos, #options do
		decline = false
		if #tmp > 0 then
			for k, v in pairs(options[i].cards) do
				for k1, v1 in pairs(tmp) do
					for k2, v2 in pairs(v1.cards) do
						if v == v2 then
							decline = true
							break
						end
					end
					if decline then
						break
					end
				end
				if decline then
					break
				end
			end

			if not decline then-- and #tmp > 0 
				n1 = options[i]
				n2 = tmp[#tmp]
				if n1.ct > n2.ct or (n1.ct == n2.ct and n1.kv > n2.kv) then
					decline = true
				end
			end
		end
		
		if not decline then
			table.insert(tmp, options[i])
			getcombinationdfs(i + 1, options, tmp, result, maxlen, nodecnt)
			if #result >= maxlen then
				return
			end
			table.remove(tmp, #tmp)
		end
	end
end

function logic.pieceGroup1better(group1, group2)
	local bettercnt = 0
	for i = 1, 3 do
		if logic.node1better({table.arraycopy(group1, (i - 1) * 3 + 1, 3), table.arraycopy(group2, (i - 1) * 3 + 1, 3)}) then
			bettercnt = bettercnt + 1
		end
	end
	return bettercnt > 1
end

function logic.group1better(group1, group2)
	local bettercnt = 0
	for i = 1, 3 do
		if logic.node1better({group1[i].cards, group2[i].cards}) then
			bettercnt = bettercnt + 1
		end
	end
	return bettercnt > 1
end

function logic.getorgnizegroup(cards)
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or {}
		table.insert(hash[key], v)
	end
	local result = {}
	local options = {}
	local set = get_set(cards, hash)
	if set then
		table.mergeByAppend(options, set)
	end
	-- print('\n\n')
	-- logic.printCards(cards)
	-- print('sets')
	-- for i = 1, #options do
	-- 	logic.printCards(options[i])
	-- end
	local flushstraight = get_flushstraight(cards, hash)
	if flushstraight then
		table.mergeByAppend(options, flushstraight)
	end
	-- print('\nflushstraight')
	-- for i = 1, #flushstraight do
	-- 	logic.printCards(flushstraight[i])
	-- end
	
	local flush = get_flush(cards, hash)
	if flush then
		table.mergeByAppend(options, flush)
	end
	-- print('\nflush')
	-- for i = 1, #flush do
	-- 	logic.printCards(flush[i])
	-- end

	local straight = get_straight(cards, hash)
	if straight then
		table.mergeByAppend(options, straight)
	end
	-- print('\nstraight')
	-- for i = 1, #straight do
	-- 	logic.printCards(straight[i])
	-- end

	local cpair = get_pairs(cards, hash)
	if cpair then
		table.mergeByAppend(options, cpair)
	end
	-- print('\npair')
	-- for i = 1, #cpair do
	-- 	logic.printCards(cpair[i])
	-- end

	-- for i = 1, #options do
	-- 	logic.printCards(options[i])
	-- end
	-- print('\n\nget options over!!!!')
	local nopions = {}
	local ct, kv
	for k, v in pairs(options) do
		ct, kv = logic.getCardType(v)
		if not ct or not kv then
			luadump(v)
			break
		end
		table.insert(nopions, {cards = v, ct = ct, kv = kv})
	end
	-- luadump(nopions)
	table.sort(nopions, function(node1, node2)
		if node1.ct == node2.ct then
			return node1.kv > node2.kv
		else
			return node1.ct > node2.ct
		end
	end)

	-- luadump(nopions)
	local two
	getcombinationdfs(1, nopions, {}, result, 100, 3)
	if not next(result) or (#result < 10) then
		getcombinationdfs(1, nopions, {}, result, 100, 2)
	end

	if not next(result) then
		-- result = nopions
		getcombinationdfs(1, nopions, {}, result, 100, 1)
	end

	table.sort(cards, function(c1, c2)
		return c1 > c2
	end)
	-- luadump(result)
	local tmphash
	for k, v in pairs(result) do
		if #v < 3 then
			tmphash = {}
			for k2, v2 in pairs(v) do
				for k3, v3 in pairs(v2.cards) do
					tmphash[v3] = 1
				end
			end

			for j = #v + 1, 3 do
				local attach = {}
				for i = 1, #cards do
					if not tmphash[cards[i]] then
						table.insert(attach, cards[i])
						tmphash[cards[i]] = 1
						if #attach >= 3 then
							break
						end
					end
				end
				
				ct, kv = logic.getCardType(attach)
				table.insert(v, {cards = attach, ct = ct, kv = kv})
			end
		end

		for k1, v1 in pairs(v) do
			if #v1.cards < _card_amount then
				tmphash = {}
				for k2, v2 in pairs(v) do
					for k3, v3 in pairs(v2.cards) do
						tmphash[v3] = 1
					end
				end
				for k2, v2 in pairs(cards) do
					if not tmphash[v2] then
						table.insert(result[k][k1].cards, v2)
						tmphash[v2] = 1
						break
					end
				end
			end
		end
	end

	local finalresult-- = {}
	local maxnode
	-- luadump(result)
	-- local findsame
	for k, v in pairs(result) do
		local tmp = {}
		for k1, v1 in pairs(v) do
			table.mergeByAppend(tmp, v1.cards)
		end
		if logic.judgeleague(tmp) then
			if not maxnode or logic.group1better(v, maxnode) then
				maxnode = v
				finalresult = tmp
			end
			-- table.insert(finalresult, tmp)
		end
	end

	return finalresult
end

local function getsinglecombination(cards)
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = logic.getCardLogicValue(v)
		hash[key] = hash[key] or {}
		table.insert(hash[key], v)
	end
	local result = {}

	local set = get_set(cards, hash)
	if set then return set end

	local flushstraight = get_flushstraight(cards, hash)
	if flushstraight then return flushstraight end

	local flush = get_flush(cards, hash)
	if flush then return flush end

	local straight = get_straight(cards, hash)
	if straight then return straight end

	local pair = get_pairs(cards, hash)
	if pair then return pair end
end

function logic.getMaxCombination(ocards)
	local cards = {}
	for k, v in pairs(ocards) do
		table.insert(cards, v)
	end

	return logic.getorgnizegroup(cards)
	
	-- local result = {}
	-- local nodes = {}
	-- -- luadump(ocards)
	-- for i = 1, 3 do
	-- 	local tmp = getsinglecombination(cards) or {}
	-- 	-- luadump(tmp)
	-- 	-- luadump()
	-- 	tmp = fill_less_cards(cards, tmp)
	-- 	-- luadump(tmp)
	-- 	assert(#tmp == _card_amount)
	-- 	if #tmp == _card_amount then
	-- 		table.insert(nodes, tmp)
	-- 		-- for k, v in pairs(tmp) do
	-- 		-- 	table.insert(result, v)
	-- 		-- end
	-- 	end
	-- end
	-- table.sort(nodes, function(node1, node2)
	-- 	return logic.node1better({node1, node2})
	-- end)
	-- for i = 1, #nodes do
	-- 	table.mergeByAppend(result, nodes[i])
	-- 	-- table.insert(result, v)
	-- end
	-- -- for k, v in pairs(tmp) do
	-- -- 	table.insert(result, v)
	-- -- end
	-- return result
end

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
	elseif v == 14 then
		str = 'sJork'
	elseif v == 15 then
		str = 'bJork'
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

logic.ct_all_flush = 11
logic.ct_all_black = 10
logic.ct_all_red = 9
logic.ct_all_flushstraight = 8
logic.ct_two_flushstraight = 7
logic.ct_two_set = 6
logic.ct_all_set = 5
logic.ct_four_same = 4
logic.ct_9_straight = 3
logic.ct_9_flushstraight = 2
logic.ct_all_win = 1

function logic.getEXCardType(node)
	local cthash = {}
	for i = 1, 11 do
		cthash[i] = 0
	end
	-- cthash[logic.ct_all_flush] = true
	local flushcnt = 0
	local flushstraightcnt = 0
	local setcnt = 0

	for k, v in pairs(node.ct) do
		if v.ct == logic.ct_flush then
			flushcnt = flushcnt + 1
		elseif v.ct == logic.ct_flushstraight then
			flushstraightcnt = flushstraightcnt + 1
			flushcnt = flushcnt + 1
		elseif v.ct == logic.ct_set then
			setcnt = setcnt + 1
		end
	end

	if flushcnt == 3 then
		cthash[logic.ct_all_flush] = 1
	end
	-- print(string.format('flushstraightcnt: %s', tostring(flushstraightcnt)))
	if flushstraightcnt >= 3 then
		cthash[logic.ct_all_flushstraight] = 1
	end
	if flushstraightcnt >= 2 then
		cthash[logic.ct_two_flushstraight] = 1
	end

	if setcnt == 3 then
		cthash[logic.ct_all_set] = 1
	elseif setcnt == 2 then
		cthash[logic.ct_two_set] = 1
	end

	local flowcnt = {0, 0, 0, 0}
	-- local blackcnt = {0, 0}
	local flower
	for k, v in pairs(node.excards) do
		flower = v % 10 + 1
		-- if flower == 3 or flower == 1 then
		flowcnt[flower] = flowcnt[flower] + 1
		-- else
			-- redcnt = redcnt + 1
		-- end

		-- if redcnt ~= 0 and blackcnt ~= 0 then
			-- break
		-- end
	end

	local allsameflower
	-- if not cthash[logic.ct_all_flush] then
	for k, v in pairs(flowcnt) do
		if v >= 9 then
			cthash[logic.ct_all_flush] = 1
			allsameflower = true
			break
		end
	end
	-- end

	if flowcnt[1] + flowcnt[3] == 9 then
	-- if redcnt == 9 then
		cthash[logic.ct_all_red] = 1
	elseif flowcnt[2] + flowcnt[4] == 9 then--if blackcnt == 9 then
		cthash[logic.ct_all_black] = 1
	end

-- 	logic.ct_four_same = 4
-- logic.ct_9_straight = 3
-- logic.ct_9_flushstraight = 2

	local hash = {}
	for i = 1, 9 do
		key = logic.getCardLogicValue(node.excards[i])
		hash[key] = hash[key] or 0
		hash[key] = hash[key] + 1
	end


	local exhash = {}
	for i = 1, 9 do
		key = logic.getCardLogicValue(node.finalcards[i])
		exhash[key] = exhash[key] or 0
		exhash[key] = exhash[key] + 1
	end

	for k, v in pairs(exhash) do
		if v >= 4 then
			cthash[logic.ct_four_same] = cthash[logic.ct_four_same] or 0
			cthash[logic.ct_four_same] = cthash[logic.ct_four_same] + 1
		end
	end

	local cnt = 0
	local straight9 = true
	-- luadump(hash)
	for i = 1, 12 do
		if hash[i] then
			if hash[i] > 1 then
				straight9 = false
				break
			end
			cnt = cnt + 1
		end
		if hash[i] and not hash[i + 1] and cnt < 9 then
			if (hash[13]) and i == 8 and cnt == 8 then
				break
			end
			straight9 = false
			break
		end
	end
	-- print(string.format('straight9: %s', tostring(straight9)))

	if straight9 then
		cthash[logic.ct_9_straight] = 1
		if allsameflower then
			cthash[logic.ct_9_flushstraight] = 1
		end
	end

	return cthash
end

local function getjorkflower(jk, f)
	if jk == 140 then
		if f == 1 or f == 3 then
			return f
		else
			return 3
		end
	elseif jk == 150 then
		if f == 0 or f == 2 then
			return f
		else
			return 2
		end
	end
end

local function brokenstraight(purecards, jork)
	table.sort(purecards, function(c1, c2)
		return c1 < c2
	end)
	local cv1 = math.floor(purecards[1] / 10)
	local cv2 = math.floor(purecards[2] / 10)
	local f = cv1 % 10
	local val
	local mv
	if cv2 - cv1 == 2 then
		val = cv1 + 1
		mv = cv2
	end
	if (cv1 == 2 and cv2 == 13) then
		val = 2
		mv = 2
	end
	if val then
		return val * 10 + getjorkflower(jork, f), mv
	end
end

function logic.getCardType(cards)
	local purecards = {}
	local jork = {}
	for k, v in pairs(cards) do
		if logic.getCardLogicValue(v) < 14 then
			table.insert(purecards, v)
		else
			table.insert(jork, v)
		end
	end

	if #purecards == #cards then
		return logic.getCardTypeEX(cards)
	elseif #purecards == 1 then
		if #jork == 1 then
			local val = math.floor(purecards[1] / 10)
			return logic.ct_pair, logic.getCardLogicValue(purecards[1]), {val * 10 + getjorkflower(jork[1], purecards[1] % 10)}
		else
			local val = math.floor(purecards[1] / 10)
			return logic.ct_set, logic.getCardLogicValue(purecards[1]), {val * 10 + 3, val * 10 + 2}
		end
	end

	local ct, val = logic.getCardTypeEX(purecards)
	-- print(string.format('!!ct: %d  kv : %s', ct, tostring(val)))
	if ct == logic.ct_pair then
		local f = purecards[1] % 10
		if ((f == 0 or f == 2) and jork[1] == 140) then
			f = 3
		elseif ((f == 1 or f == 3) and jork[1] == 150) then
			f = 2
		end
		return logic.ct_set, val, {val * 10 + f}
	elseif ct == logic.ct_straight or ct == logic.ct_flushstraight then
		-- print('!!!!'..val)
		if val ~= 13 then
			val = val + 1
		end
		local f = purecards[1] % 10

		local jf = getjorkflower(jork[1], f)
		if jf ~= f then
			ct = logic.ct_straight
		end
		return ct, val, {val * 10 + jf}
	elseif ct == logic.ct_flush then
		local cv, kv = brokenstraight(purecards, jork[1])
		local f = purecards[1] % 10
		if cv then
			if getjorkflower(jork[1], f) == f then
				return logic.ct_flushstraight, kv, {cv}
			else
				return logic.ct_straight, kv, {cv}
			end
		end
		-- if ((f == 1 or f == 3) and jork[1] == 140) or ((f == 0 or f == 2) and jork[1] == 150) then
		if getjorkflower(jork[1], f) == f then
			return logic.ct_flush, 13, {13 * 10 + f}
		end
		-- end
		ct = logic.ct_highcard
	end
	if ct == logic.ct_highcard then
		local cv, kv = brokenstraight(purecards, jork[1])
		if cv then
			return logic.ct_straight, kv, {cv}
		end

		local f
		-- for k, v in pairs(purecards) do
		-- 	if math.floor(v / 10) == val then
		-- 		f = v % 10
		-- 		print('f = '..tostring(f))
		-- 		luadump(jork)
				if (jork[1] == 140) then
					-- print('jork == 3')
					f = 3
				elseif (jork[1] == 150) then
					-- print('jork == 2')
					f = 2
				end
		-- 		break
		-- 	end
		-- end
		return logic.ct_pair, val, {val * 10 + f}
	end
end

function logic.judgeleague(cards)
	local ok, result
	for i = 1, 2 do
    --logic.node1better({table.arraycopy(cards, (i - 1) * 3 + 1, 3), table.arraycopy(cards, (i) * 3 + 1, 3)})
		ok, result = pcall(logic.node1better, {table.arraycopy(cards, (i - 1) * 3 + 1, 3), table.arraycopy(cards, (i) * 3 + 1, 3)})
		--print(string.format('ok: %s   result:%s', tostring(ok), tostring(result)))
		if not ok or not result then
			-- luadump(cards)
			return false
		end
	end
	return true
end

function logic.node1better(cards)
	local nodes = {}
	for i = 1, #cards do
		local ct1 , kv1, xx1 = logic.getCardType(cards[i])
		
		-- if xx1 then
		-- 	for i = 1, #xx1 do
		-- 		xx1[i] = xx1[i] - 0.5
		-- 	end
		-- end
		xx1 = xx1 or {}
		for k1, v1 in pairs(cards[i]) do
			if v1 < 140 then
				table.insert(xx1, v1)
			end
		end

		table.sort(xx1, function(c1, c2)
			return c1 > c2
		end)

		nodes[i] = {
			ct = ct1,
			kv = kv1,
			cards = xx1--cards[i][1] > xx1 and cards[i][1] or xx1
		}
	end
	-- luadump(nodes)

	if nodes[1].ct == nodes[2].ct then
		if nodes[1].kv == nodes[2].kv then
			for i = 1, #nodes[1].cards do
				if nodes[1].cards[i] ~= nodes[2].cards[i] then
					return nodes[1].cards[i] > nodes[2].cards[i]
				end
			end
			return false
			-- return nodes[1].card > nodes[2].card
		else
			return nodes[1].kv > nodes[2].kv
		end
	else
		return nodes[1].ct > nodes[2].ct
	end
end

function logic.getCardTypeEX(cards)
	if not cards or not next(cards) or #cards < 2 then return end
	local hash = {}
	local clen = #cards
	for i = 1, clen do
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
	for i = 2, clen do
		if cards[i] % 10 ~= flower then
			flush = false
			break
		end
	end

	-- luadump(hash)
	local straightkv
	for i = 1, 14 - clen do
		line = {}
		if hash[i] then
			straightkv = i + (clen - 1)
			for j = i, i + clen - 1 do
				if not hash[j] then
					-- print('j = %d', j)
					if clen == 3 and hash[1] and hash[2] and hash[13] then --A2345
						straightkv = 2
						break
					elseif clen == 2 and hash[1] and hash[13] then --A2345
						straightkv = 1
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
	if flush then
		return logic.ct_flushstraight, straightkv
	end
	return logic.ct_straight, straightkv
end

return logic