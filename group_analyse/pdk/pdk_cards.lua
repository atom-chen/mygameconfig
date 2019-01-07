local skynet = require "skynet"

pdk_cards = {}

--枚举变量
pdk_cards.const_vars=
{
	["out_card"] = 1
}

--一共48张牌
pdk_cards.cardids = {
		11,12,13,
	20,--黑桃2
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
	--140,150
}

--花色
pdk_cards.colours = {
    0,1,2,3 -- 黑桃，红桃，草花，方块
}

--得到牌的真实大小值
function pdk_cards.get_card_real_value(card)
	if math.floor(card / 10) == 1 or math.floor(card / 10) == 2 then
		return math.floor(card / 10)+13
	end

	return math.floor(card / 10)
end

--得到牌的牌面大小
function pdk_cards.get_card_vale( card )
	return math.floor(card / 10)
end

--得到牌的花色
function pdk_cards.get_card_colour( card )
	return math.floor(card % 10)
end

pdk_cards.shuffle_conf = {}
pdk_cards.shuffle_conf[3006] = {
	 			{5, 7, 100},
			}
pdk_cards.shuffle_conf[9000] = {
	 			{6, 8, 100},
			}
pdk_cards.shuffle_conf[9001] = {
	 			{5, 7, 100},
			}
pdk_cards.shuffle_conf[9002] = {
	 			{5, 6, 100},
			}

--洗牌
function pdk_cards.shuffle(cards,roomid,ishave_new)
	if not roomid then
		roomid = 3006
	end
	local shufflecnt = 0
	local cfg = pdk_cards.shuffle_conf[roomid]
	if not cfg then
		cfg = pdk_cards.shuffle_conf[3006]
	end
	local r = math.random(1, 100)
	local percent = 0
	-- local model = 1
	for i = 1, #cfg do
		if r<=cfg[i][3] then
			shufflecnt = math.random(cfg[i][1], cfg[i][2])
			-- model = 1
			break
		end

		-- if r<=80 then
		-- 	shufflecnt = math.random(cfg[i][1], cfg[i][2])
		-- 	shufflecnt = shufflecnt
		-- 	model = 2
		-- 	break
		-- end
	end

	if ishave_new then
		return pdk_cards.createCardsGroupHeapV5(shufflecnt,cards,0)
	end

	local robot_num = 0
	--判断有几个机器人
	for m,n in pairs(game_data.players) do
		if n.isrobot then
			robot_num = robot_num + 1
		end
	end

	--shufflecnt = 0
	if shufflecnt>0 then
		-- if model == 1 then
			return  pdk_cards.createCardsGroupHeapV2(shufflecnt,cards)
		-- else
		-- 	return  pdk_cards.createCardsGroupHeapV2(shufflecnt,cards)
		-- end
	else
		algorithm.shuffle(cards,#cards)
		return {}
	end

	algorithm.shuffle(cards,#cards)
	return {}
end

function pdk_cards.createCardsGroupHeap(shufflecnt,cards)
	local n, m
	n = math.random(10, 40)
	for i = n, 48 do
	  table.insert(cards, 1, table.remove(cards, #cards))
	end
	for i = 1, shufflecnt do
		n = math.random(1, 48)
		m = math.random(1, 3)

		if (n + m) > 48 then
			m = 48 - n
		end
		n = n + m
		for j = 1, m do
			table.insert(cards, 1, table.remove(cards, n))
		end
	end

	--for i = 1,1 do
		--print(cards[1],cards[2],cards[3],cards[4],cards[5],cards[6],cards[7],cards[8],cards[9],cards[10],cards[11],cards[12],cards[13],cards[14],cards[15],cards[16])
		--print(cards[17],cards[18],cards[19],cards[20],cards[21],cards[22],cards[23],cards[24],cards[25],cards[26],cards[27],cards[28],cards[29],cards[30],cards[31],cards[32])
		--print(cards[33],cards[34],cards[35],cards[36],cards[37],cards[38],cards[39],cards[40],cards[41],cards[42],cards[43],cards[44],cards[45],cards[46],cards[47],cards[48])
	--end
	--print("aaaaaaaaaa")

	local cardsgroup = {}
	local x = {5, 5, 6}
	for j = 1, 3 do
		for i = 1, 3 do
			if not cardsgroup[i] then cardsgroup[i] = {} end
			table.mergeByAppend(cardsgroup[i], table.arraycopy(cards, 3 * (j - 1) * (x[j - 1] or 0) + (i - 1) * x[j] + 1, x[j]))
		end
	end

	--for i = 1,3 do
		--print(cardsgroup[i][1],cardsgroup[i][2],cardsgroup[i][3],cardsgroup[i][4],cardsgroup[i][5],cardsgroup[i][6]
			--,cardsgroup[i][7],cardsgroup[i][8],cardsgroup[i][9],cardsgroup[i][10],cardsgroup[i][11],cardsgroup[i][12],cardsgroup[i][13],cardsgroup[i][14],cardsgroup[i][15],cardsgroup[i][16])
	--end
	--return cardsgroup
	return pdk_cards.killBadCards(cardsgroup)
end

local function get_card_num( card,cards )
	local num = 0
	 for m,n in pairs(cards) do
	 	if pdk_cards.get_card_vale(card) == pdk_cards.get_card_vale(n) then
	 		num = num + 1
	 	end
    end
    return num
end

function pdk_cards.createCardsGroupHeapV5( shufflecnt,cards,robot_num )
	--print("createCardsGroupHeapV5",robot_num)
	local cardsgroup = {}
	cardsgroup[1] = {}
	--再给炸弹
	local zha = math.random(3, 11)
	if robot_num == 0 then
		table.insert(cardsgroup[1],11)
		table.insert(cardsgroup[1],12)
		table.insert(cardsgroup[1],13)
		table.insert(cardsgroup[1],20)
		table.insert(cardsgroup[1],131)
		table.insert(cardsgroup[1],132)
	else
		for i = 1,#cards,1 do
			if pdk_cards.get_card_vale(cards[i]) == zha then
				table.insert(cardsgroup[1],cards[i])
			end
		end
	end
	local three = 0
	--再给飞机带翅膀
	if zha > 6 then
		three = math.random(3, 5)
		if three == zha then
			three = three+2
		end
	else
		three = math.random(7, 11)
		if three == zha then
			three = three-2
		end
	end

	local get_num = 0
	for i = 1,#cards,1 do
		if pdk_cards.get_card_vale(cards[i]) == three then
			table.insert(cardsgroup[1],cards[i])
			get_num = get_num+1
			if get_num == 3 then
				break
			end
		end
	end
	get_num = 0
	for i = 1,#cards,1 do
		if pdk_cards.get_card_vale(cards[i]) == three+1 then
			table.insert(cardsgroup[1],cards[i])
			get_num = get_num+1
			if get_num == 3 then
				break
			end
		end
	end
	if robot_num ~= 0 then
		--先给两张
		for i = 3,13,1 do 
			if i ~= zha and i~= three and i~=three+1 then
				table.insert(cardsgroup[1],i*10+1)
				table.insert(cardsgroup[1],i*10+2)
				break
			end
		end
	end
	--得到剩下的牌
	for i = 1,#cardsgroup[1],1 do
		local len = #cards
		for j = 1,len,1 do
			if cardsgroup[1][i] == cards[j] then
				table.remove(cards,j)
				break
			end
		end
	end
	algorithm.shuffle(cards,#cards)
	--得到4张牌
	for i=1,4,1 do
		table.insert(cardsgroup[1],table.remove(cards,1))
	end

	local index = 1
	--机器人挑16张牌
	for i = 2,3,1 do
		cardsgroup[i] = cardsgroup[i] or {}
		for j = 1,16,1 do
			table.insert(cardsgroup[i],cards[index])
			index = index+1
		end
	end

	local get_change_cards = {}
	--挑选炸弹
	for i = 1,#cardsgroup[2],1 do
		if get_card_num(cardsgroup[2][i],cardsgroup[2]) == 4 then
			local bfind = false
			if #get_change_cards > 0 then
				for j = 1,#get_change_cards,1 do
					if pdk_cards.get_card_vale(get_change_cards[j]) == pdk_cards.get_card_vale(cardsgroup[2][i]) then
						bfind = true
						break
					end
				end
			end

			if bfind == false then
				table.insert(get_change_cards,cardsgroup[2][i])
			end
		end
	end
	--获取三连张
	local get_three_cards = pdk_get_card.get_card(algorithm.card_type.three_join,1,cardsgroup[2],2)
	if #get_three_cards >0 then
		for i = 1,#get_three_cards,1 do
			local bfind = false
			if #get_change_cards > 0 then
				for j = 1,#get_change_cards,1 do
					if pdk_cards.get_card_vale(get_change_cards[j]) == pdk_cards.get_card_vale(get_three_cards[i]) then
						bfind = true
						break
					end
				end
			end
			if bfind == false then
				table.insert(get_change_cards,get_three_cards[i])
			end
		end
	end
	--获取三个A
	local a_num = get_card_num(11,cardsgroup[2])
	if a_num == 3 then
		local bfind = false
		if #get_change_cards > 0 then
			for j = 1,#get_change_cards,1 do
				if pdk_cards.get_card_vale(get_change_cards[j]) == pdk_cards.get_card_vale(11) then
					bfind = true
					break
				end
			end
		end
		if bfind == false then
			table.insert(get_change_cards,11)
		end
	end
	--交换
	pdk_cards.changecards(cardsgroup,2,3,get_change_cards)

	get_change_cards = {}
	--挑选炸弹
	for i = 1,#cardsgroup[3],1 do
		if get_card_num(cardsgroup[3][i],cardsgroup[3]) == 4 then
			local bfind = false
			if #get_change_cards > 0 then
				for j = 1,#get_change_cards,1 do
					if pdk_cards.get_card_vale(get_change_cards[j]) == pdk_cards.get_card_vale(cardsgroup[3][i]) then
						bfind = true
						break
					end
				end
			end

			if bfind == false then
				table.insert(get_change_cards,cardsgroup[3][i])
			end
		end
	end
	--获取三连张
	local get_three_cards = pdk_get_card.get_card(algorithm.card_type.three_join,1,cardsgroup[3],2)
	if #get_three_cards >0 then
		for i = 1,#get_three_cards,1 do
			local bfind = false
			if #get_change_cards > 0 then
				for j = 1,#get_change_cards,1 do
					if pdk_cards.get_card_vale(get_change_cards[j]) == pdk_cards.get_card_vale(get_three_cards[i]) then
						bfind = true
						break
					end
				end
			end
			if bfind == false then
				table.insert(get_change_cards,get_three_cards[i])
			end
		end
	end
	a_num = get_card_num(11,cardsgroup[3])
	if a_num == 3 then
		local bfind = false
		if #get_change_cards > 0 then
			for j = 1,#get_change_cards,1 do
				if pdk_cards.get_card_vale(get_change_cards[j]) == pdk_cards.get_card_vale(11) then
					bfind = true
					break
				end
			end
		end
		if bfind == false then
			table.insert(get_change_cards,11)
		end
	end
	--交换
	pdk_cards.changecards(cardsgroup,3,2,get_change_cards)
	return cardsgroup
end

function pdk_cards.createCardsGroupHeapV3(shufflecnt,cards,robot_num)
	local get_cards = {}
	for i = 1,#cards,1 do 
		local value = pdk_cards.get_card_real_value(cards[i])
		if value >=10 and value<=15 then
			table.insert(get_cards,cards[i])
		end
	end

	local left_cards = {}
	for i = 1,#cards,1 do 
		local value = pdk_cards.get_card_real_value(cards[i])
		if value <10 then
			table.insert(left_cards,cards[i])
		end
	end

	algorithm.shuffle(get_cards,#get_cards)
	algorithm.shuffle(left_cards,#left_cards)

	local cardsgroup = {}
	local index = 1
	--机器人一人挑10张
	for i = 1,1 ,1 do
		cardsgroup[i] = {}
		for j = 1,10,1 do
			table.insert(cardsgroup[i],get_cards[index])
			index = index+1
		end
	end

	--合并牌
	for i = index,#get_cards,1 do
		table.insert(left_cards,get_cards[i])
	end
	algorithm.shuffle(left_cards,#left_cards)

	index = 1
	--机器人挑剩下的6张
	for i = 1,1 ,1 do
		for j = 1,6,1 do
			table.insert(cardsgroup[i],left_cards[index])
			index = index+1
		end
	end

	--机器人挑16张牌
	for i = 2,3,1 do
		cardsgroup[i] = cardsgroup[i] or {}
		for j = 1,16,1 do
			table.insert(cardsgroup[i],left_cards[index])
			index = index+1
		end
	end

	return cardsgroup
end

function pdk_cards.createCardsGroupHeapV2( shufflecnt, cards)
	local get_cards = {}
	for i = 3,13,1 do
		local clen = #cards
		local get_num = 0
		local value = 3
		local j = 1
		while (get_num<3)
		do
			--print("clen",j,clen)
			clen = #cards
			if j>clen then
				LOG_DEBUG("system error clen",j,clen)
				break
			end
			if pdk_cards.get_card_vale(cards[j]) == i then
				table.insert(get_cards,cards[j])
				table.remove(cards,j)
				j = 1
				clen = #cards
				get_num = get_num+1
				if get_num ==3 then
					break
				end
			else
				j = j+1
			end
		end
	end

	local total_len = #get_cards
	for i = 1, shufflecnt do
		n = math.random(1, total_len)
		m = 2

		if (n + m) > total_len then
			m = total_len - n
		end
		n = n + m
		for j = 1, m do
			table.insert(get_cards, 1, table.remove(get_cards, n))
		end
	end

	algorithm.shuffle(cards,#cards)

	for i = 1,#cards,1 do
		table.insert(get_cards,cards[i])
	end
	local cardsgroup = {}
	--每人先给11张
	local offset = 1
	for i = 1,3,1 do
		if not cardsgroup[i] then cardsgroup[i] = {} end
		table.mergeByAppend(cardsgroup[i], table.arraycopy(get_cards,offset,11))
		offset = offset + 11
	end


	for i=1,5,1 do
		for j=1,3,1 do
			table.insert(cardsgroup[j],get_cards[offset])
			offset = offset+1
		end
	end
	--return cardsgroup
	return pdk_cards.killBadCards(cardsgroup)
end

function pdk_cards.judgeBadCards( cards )
	local hash = {}
	local key
	for k, v in pairs(cards) do
		key = pdk_cards.get_card_vale(v)
		hash[key] = hash[key] or 0
		hash[key] = hash[key] + 1
	end
	local notsingle
	local cutAmount

	local badcards = false
	local badkey, tempbk, excidx
	for i = 3, 8 do
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
					key = pdk_cards.get_card_vale(v)
					if key < i or key > (i + 4) then
						if key~=1 and key ~=2 then
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

--交换牌
function pdk_cards.changecards( cardsgroup,m,n,cards )
	local get_cards = {}
	local get_num = 0
	for i = 1,#cardsgroup[n],1 do
		local bfind =false
		for j = 1,#cards,1 do
			if pdk_cards.get_card_vale(cardsgroup[n][i]) == pdk_cards.get_card_vale(cards[j]) then
				bfind = true
				break
			end
		end
		if bfind == false and get_num<#cards then
			table.insert(get_cards,cardsgroup[n][i])
			get_num = get_num+1
			if get_num>=#cards then
				break
			end
		end
	end

	if get_num~= #cards then
		return
	end

	for i = 1,#cards,1 do
		local len = #cardsgroup[m]
		for j = 1,len,1 do
			if cardsgroup[m][j] == cards[i] then
				table.remove(cardsgroup[m],j)
				break
			end
		end
	end

	for i = 1,#get_cards,1 do
		local len = #cardsgroup[n]
		for j = 1,len,1 do
			if cardsgroup[n][j] == get_cards[i] then
				table.remove(cardsgroup[n],j)
				break
			end
		end
	end

	for i = 1,#cards,1 do
		table.insert(cardsgroup[n],cards[i])
	end
	for i = 1,#get_cards,1 do
		table.insert(cardsgroup[m],get_cards[i])
	end
end

function pdk_cards.killBadCards(cardsgroup)
	local bad, key, idx
	local success
	for i = 1, 3 do
		bad, key, idx = pdk_cards.judgeBadCards(cardsgroup[i])
		if bad then
			-- print('\nneed exchange before index: %d key:%d ', i, key)
			-- for ix = 1, 3 do
			-- 	logic.printCards(cardsgroup[ix])
			-- end
			if key and idx then
				for j = 1, 3 do
					if i ~= j then
						for k, v in pairs(cardsgroup[j]) do
							if pdk_cards.get_card_vale(v) == key then
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

local function test_func()
	local cards = {}
	for m,n in pairs(pdk_cards.cardids) do
		table.insert(cards,n)
	end
	pdk_cards.shuffle(cards)

end

--test_func()

return pdk_cards