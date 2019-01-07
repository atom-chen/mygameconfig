local util = require 'ai_util'
local logic = require 'logic'
--local Hint = require 'Hint'
local combination = require 'combination'
require 'functionsxx'
local cardids =  {
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
local cardids1 =  {
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
local isMatch = false
local function shuffle(special)
	table.sort(cardids, function(c1, c2)
		return c1 < c2
	end)

	local r = math.random(1, 100)
	local shufflecnt = 0
	if r < 11 then
		shufflecnt = 5
	elseif r < 21 then
		shufflecnt = 10
	elseif r < 31 then
		shufflecnt = 15
	else
		
	end

	if special then
		shufflecnt = special
	end
	-- shufflecnt = 5
	if shufflecnt > 0 and not isMatch then
		local n,m
		n = math.random(10, 40)
		for i = n, 54 do
		  table.insert(cardids, 1, table.remove(cardids, #cardids))
		end
		for i = 1, shufflecnt do
			n = math.random(1, 54)
			m = math.random(2, 5)

			if (n + m) > 54 then
				m = 54 - n
			end
			n = n + m
			for j = 1, m do
				table.insert(cardids, 1, table.remove(cardids, n))
			end
		end
		local j
		-- luadump(cardids)
		for i=52,54 do
			j = math.random(1, 51)
			if i ~= j then
				-- LOG_DEBUG('1msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
				cardids[i] = cardids[i] + cardids[j]
				-- LOG_DEBUG('2msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
				cardids[j] = cardids[i] - cardids[j]
				-- LOG_DEBUG('3msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
				cardids[i] = cardids[i] - cardids[j]
				-- LOG_DEBUG('4msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
			end
		end
		-- LOG_DEBUG('\n\nmsg:-------------------after exchange')
		-- luadump(cardids)
	else
		-- luadump(cardids)
		local j
		for i=1,54 do
			j = math.random(i,54)
			if i ~= j then
				-- LOG_DEBUG('1msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
				cardids[i] = cardids[i] + cardids[j]
				-- LOG_DEBUG('2msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
				cardids[j] = cardids[i] - cardids[j]
				-- LOG_DEBUG('3msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
				cardids[i] = cardids[i] - cardids[j]
				-- LOG_DEBUG('4msg:------------cardids[i] :%d  cardids[j]: %d', cardids[i], cardids[j])
			end
		end
		-- LOG_DEBUG('\n\nmsg:-------------------after exchange')
		-- luadump(cardids)
	end
end

local function shuffle1(special)
	table.sort(cardids1, function(c1, c2)
		return c1 < c2
	end)
	local r = math.random(1, 100)
	local shufflecnt = 0
	if r < 11 then
		shufflecnt = 5
	elseif r < 21 then
		shufflecnt = 10
	elseif r < 31 then
		shufflecnt = 15
	else
		
	end

	if special then
		shufflecnt = 0
	end
	shufflecnt = 6
	if shufflecnt > 0 and not isMatch then
		local n,m
		n = math.random(10, 40)
		for i = n, 54 do
		  table.insert(cardids1, 1, table.remove(cardids1, #cardids1))
		end
		for i = 1, shufflecnt do
			n = math.random(1, 54)
			m = math.random(2, 5)

			if (n + m) > 54 then
				m = 54 - n
			end
			n = n + m
			for j = 1, m do
				table.insert(cardids1, 1, table.remove(cardids1, n))
			end
		end
		local j
		-- luadump(cardids1)
		for i=52,54 do
			j = math.random(1, 51)
			if i ~= j then
				-- LOG_DEBUG('1msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
				cardids1[i] = cardids1[i] + cardids1[j]
				-- LOG_DEBUG('2msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
				cardids1[j] = cardids1[i] - cardids1[j]
				-- LOG_DEBUG('3msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
				cardids1[i] = cardids1[i] - cardids1[j]
				-- LOG_DEBUG('4msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
			end
		end
		-- LOG_DEBUG('\n\nmsg:-------------------after exchange')
		-- luadump(cardids1)
	else
		-- luadump(cardids1)
		local j
		for i=1,54 do
			j = math.random(i,54)
			if i ~= j then
				-- LOG_DEBUG('1msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
				cardids1[i] = cardids1[i] + cardids1[j]
				-- LOG_DEBUG('2msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
				cardids1[j] = cardids1[i] - cardids1[j]
				-- LOG_DEBUG('3msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
				cardids1[i] = cardids1[i] - cardids1[j]
				-- LOG_DEBUG('4msg:------------cardids1[i] :%d  cardids1[j]: %d', cardids1[i], cardids1[j])
			end
		end
		-- LOG_DEBUG('\n\nmsg:-------------------after exchange')
		-- luadump(cardids1)
	end
end

local x = {6, 6, 5}



local ran
local result = {}
local _max_shuffle_cnt = 10
local _max_group_cnt = 100
for ix = 5, _max_shuffle_cnt do
	result[ix] = {}
	for k = 1, _max_group_cnt do
		shuffle(ix)
		-- shuffle1()

		local cardtable = {}
		-- local cardtable1 = {}
		for j = 1, 3 do
			for i = 1, 3 do
				if not cardtable[i] then cardtable[i] = {} end
				table.mergeByAppend(cardtable[i], table.arraycopy(cardids, 3 * (j - 1) * (x[j - 1] or 0) + (i - 1) * x[j] + 1, x[j]))
			end

			-- for i = 1, 3 do
			-- 	if not cardtable1[i] then cardtable1[i] = {} end
			-- 	table.mergeByAppend(cardtable1[i], table.arraycopy(cardids1, 3 * (j - 1) * (x[j - 1] or 0) + (i - 1) * x[j] + 1, x[j]))
			-- end	
		end
		ran = math.random(1, 3)
		table.mergeByAppend(cardtable[ran], {cardids[#cardids], cardids[#cardids - 1], cardids[#cardids - 2]})
		-- table.mergeByAppend(cardtable1[ran], {cardids1[#cardids1], cardids1[#cardids1 - 1], cardids1[#cardids1 - 2]})

		table.insert(result[ix], cardtable)
		-- table.insert(result[2], cardtable1)
	end
end


local function get_boomamount(cards)
	local count = #cards
	local nums = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local ocards = {}
	local tcards = {}
	local scards = {}
	local sxcards = {}
	local fcards = {}
	-- local boomamount = {}
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
			-- boomamount
			table.insert(fcards, j * 10)
          	table.insert(sxcards, j)
		end
	end

	
	if nums[14] == 1 and nums[15] == 1 then
		-- boomamount = boomamount + 1
		table.insert(fcards, 150)
	end
	return fcards
end


local function analysCardsGroup(cardgroup, filename)
	local resultex = {}
	local boommorethan = {}
	local ba
	local totalstr = ''
	local cardstr = ''
	for i = 1, #cardgroup do
		resultex[i] = {}
		ba = 0
		for j = 1, 3 do
			cardstr = ''
			resultex[i][j] = {}
			table.sort(cardgroup[i][j])
			cardstr = string.format('%s%s', cardstr, logic.getCardsStr(cardgroup[i][j]))
			while string.len(cardstr) < 108 do
				cardstr = cardstr..' '
			end
			-- logic.printCards(cardgroup[i][j])
			resultex[i][j].boom = get_boomamount(cardgroup[i][j])
			local bstr = ''
			if resultex[i][j].boom and #resultex[i][j].boom > 0  then
				ba = ba + #resultex[i][j].boom
				bstr = '炸弹: '
				for k = 1, #resultex[i][j].boom do
					bstr = string.format('%s %s', bstr, logic.getHumanVisible(resultex[i][j].boom[k]))
				end

				cardstr = cardstr..bstr
			end
			
			totalstr = string.format('%s%s\n', totalstr, cardstr)
		end
		for i = 1, 10 do
			if ba > i then
				boommorethan[i] = boommorethan[i] or 0
				boommorethan[i] = boommorethan[i] + 1
			end
		end
		
		if ba > 0 then
			totalstr = string.format('%s 炸弹数量: %d\n\n', totalstr, ba)
		end
		local bestCardsIndex = combination.getBestCardsIndex(cardgroup[i])
		totalstr = string.format('%s besetindex: %d\n\n', totalstr, bestCardsIndex)
		-- print('\n\n')
	end
	local morethanstr = ''
	for i = 1, 10 do
		boommorethan[i] = boommorethan[i] or 0
		morethanstr = string.format('%s炸弹总数大于 %d 副的牌组有 %d 组\n', morethanstr, i, boommorethan[i])
	end
	totalstr = string.format('%s %s', morethanstr, totalstr)
	local file2=io.output(filename..'.lua')
	io.write(totalstr)
	io.flush()
	io.close()
end

for ix = 5, _max_shuffle_cnt do
	analysCardsGroup(result[ix], string.format('group_%danalyse', ix))
end

-- analysCardsGroup(result[2], 'group_analyse_new')

