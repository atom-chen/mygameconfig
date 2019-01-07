--[[print(tonumber(false))

local t = {}
t[1] = 3
t[3] = 2

print(table.getn(t))

print(#t)
--]]


-- if not isMatch then
-- 		if chge[master] + players[master].gold < 0 then
-- 			chge[master] = -players[master].gold
-- 		elseif chge[master] > players[master].gold then
-- 			chge[master] = players[master].gold
-- 		end
-- 		local t = -math.floor(chge[master] / 2)
-- 		for i = 1, 3 do
-- 			if i ~= master then
-- 				if t > players[i].gold then
-- 					chge[i] = players[i].gold
-- 				else
-- 					chge[i] = t
-- 				end
-- 			end
-- 		end
-- 		chge[master] = -(chge[fsid[1]] + chge[fsid[2]])
-- 	end
  
--   util.printTable(chge)

-- 特殊牌型
-- 飞机带翅膀中含有炸弹
-- 60,61,62,63,70,71,72,73,80,81,82,90
-- 90,91,92,100,101,102,110,111,112,120,121,122,123,130,131
-- 两个以上连号炸弹，当飞机出
-- 70,71,72,73,80,81,82,83,90,91,92,93,
-- KA2当顺子或连对或飞机或炸弹
-- 91,101,110,120,130
-- 90,91,110,111,120,121,130,131
-- 101,102,103,110,111,112,120,121,122,130,131,132
-- 飞机带王炸
-- 101,102,103,110,111,112,120,121,122,130,140,150
-- 四个3张带2个炸弹的飞机
local logic = require 'logic'
local cardsx = {
	{60,61,62,63,70,71,72,73,80,81,82,90},
	{90,91,92,100,101,102,110,111,112,120,121,122,123,130,131},
	{70,71,72,73,80,81,82,83,90,91,92,93},
	{91,101,110,120,130},
	{90,91,110,111,120,121,130,131},
	{101,102,103,110,111,112,120,121,122,130,131,132},
	{90,91,92,101,102,103,110,111,112,30,31,32},
	{20,21,22,30,31,32,33,40,41,42,50,51},
	{92,91, 90, 82, 81, 80, 72, 70, 43, 33, 32, 30}
}


local SW = 1--双王
local ZD = 2--炸弹
local DZ = 3--单张
local EZ = 4--对子
local SZ = 5--三张
local SDY = 6;--三带一
local SDD = 7;--三带对
local SDEY = 8;--四带二单
local SDED = 9;--四带二对
local FJDY = 10;--飞机带单
local FJDD = 11;--飞机带队
local DS = 12;--单顺
local ES = 13;--双顺
local SS = 14;--三顺



--local cards = {100,101,102,103,110,111,112,113,120,122,121,123,130,131,132,133}
--local cards = {40,41,42,50, 51, 52, 53,60,61,62}
--local cards = {90,91,92,100,101,102,111,112,113,122,121,123,120,130,131}

local cards = {100,101,102,111,112,113,122,121,123,130,140,150}


table.sort(cards, function(card1, card2)
		return card1 < card2
	end)

local function is_shun(cards, keeptailhead)
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
				end
			else
				return false
			end
		end
	end
	if not keeptailhead and tailwrong then
		return true, cards[#cards - 1]
	else
		return true, cards[#cards]
	end
end


local function get_type(cards)
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
		return SW, 15
	end
	if count == 1 then
		return DZ, ocards[1]
	end
	if count == 2 and #tcards == 1 then
		return EZ, tcards[1]
	end
	if count == 3 and #scards == 1 then
		return SZ, scards[1]
	end
	if count == 4 and #fcards == 1 then
		return ZD, fcards[1]
	end
	if #scards == 1 and count == 4 then
		return SDY, scards[1]
	end
	if #scards == 1 and count == 5 and #tcards == 1 then
		return SDD, scards[1]
	end
	if (#fcards == 1 and count == 6) then
		if #tcards == 1 or #ocards == 2 then
			return SDEY, fcards[1]
		end
	end
	if count == 8 then
		if (#fcards == 1 and #tcards == 2) then
			return SDED, fcards[1]
		elseif #fcards == 2 then
			return SDED, fcards[2]
		end
	end


	if #sxcards > 1 then
		local temp, kv = is_shun(sxcards)
		if temp then
			if (#sxcards - 1) * 4 == count then

				return FJDY, kv
			end
		end
		temp, kv = is_shun(sxcards, true)
		-- if  then
		if temp and count == 4 * #sxcards then
			-- print(111111111111111)
			return FJDY, kv
		end
	end

	if #scards > 1 then
		local temp, kv = is_shun(scards, true)
		-- and is_shun(scards) then
		if temp then
			if count == 5 * #scards then
				if #scards == (2 * #fcards + #tcards) then--(#scards == #tcards) or (#scards == 2 * #fcards) or (#scards == (2 * #fcards + #tcards)) then
					return FJDD, kv
				end
			end
			if #scards * 3 == count then
				return SS, kv
			end
		end
	end
	if #ocards > 4 and #ocards == count then
		local temp, kv = is_shun(ocards, true)
		if temp then
			return DS, kv
		end
	end

	if #tcards > 2 and #tcards * 2 == count then
		local temp, kv = is_shun(tcards, true)
		if temp then
			return ES, kv
		end
	end
	return 0, 0
end

--检查cards1能否压住cards2
local function check(cards1,cards2)
	-- LOG_DEBUG('msg:--------------------检查cards1能否压住cards2')
	-- logic.printCards(cards1, true, 'cards1  ')
	-- logic.printCards(cards2, true, 'cards2  ')
	local ct1, keyValue1 = get_type(cards1)
	if ct1 == SW then
		return true,ct1
	end
	
	local ct2, keyValue2 = get_type(cards2)
	if ct2 == SW then
		return false,ct1
	end

	if ct2 ~= ZD and ct1 == ZD then
		-- if keyValue1 > keyValue2 then
			return true,ct1
		-- else
			-- return false,ct1
		-- end
	end

	if ct1 == ct2 and #cards1 == #cards2 then
		return keyValue1 > keyValue2, ct1
	end
	return false,ct1
end

for i = 1, #cardsx do
  logic.printCards(cardsx[i])
	local xxx, kv = logic.getCardType(cardsx[i])
	print('牌型'..tostring(i)..': '..tostring(xxx)..' keyvalue: '..tostring(kv)..'\n')
end


--local xxx, kv = get_type(cardsx[7])
--print('牌型'..tostring(i)..': '..tostring(xxx)..' keyvalue: '..tostring(kv)..'\n')


local cards1 = {50, 51, 52, 53}
local lastcards = {133}
local x1,x2 = check(cards1,lastcards)
print('canuse: %s       ct:%s', tostring(x1), tostring(x2))


print(os.date("%Y年%m月%d日 %H:%M:%S", 1503714332))

--[[
[2017-11-03 23:40:23.846] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 send cards uid: 1694095   50 51 52 60 61 72 73 82 83 92 93 100 101 102 103 130 132
[2017-11-03 23:40:23.846] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 send cards uid: 111301   21 30 33 40 53 63 70 71 80 81 90 91 121 122 123 131 150
[2017-11-03 23:40:23.846] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 send cards uid: 111292   10 12 22 23 31 32 41 42 43 62 110 111 112 113 120 133 140
[2017-11-03 23:40:23.846] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 master cards  13 20 11
[2017-11-03 23:40:26.654] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 111301 叫庄 score:0
[2017-11-03 23:40:28.114] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 111292 叫庄 score:0
[2017-11-03 23:40:29.724] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 1694095 叫庄 score:3
[2017-11-03 23:40:29.724] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 确定庄家uid:1694095  底牌:  13 20 11
[2017-11-03 23:40:29.724] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 猜牌结算，牌型:2  11 13 20
[2017-11-03 23:40:34.299] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 1694095 出牌   11
[2017-11-03 23:40:36.800] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 111301 出牌   33
[2017-11-03 23:40:38.299] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 111292 出牌   62
[2017-11-03 23:40:55.439] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 1694095 超时未出牌
[2017-11-03 23:40:57.950] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 111301 出牌
[2017-11-03 23:41:00.469] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 111292 出牌   10 12 22 23 31 32
[2017-11-03 23:41:17.641] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 1694095 超时两次，自动托管
[2017-11-03 23:41:17.641] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 1694095 托管出牌   50 51 60 61 72 73 82 83 92 93 100 101
[2017-11-03 23:41:17.641] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 uid: 1694095 打出错误扑克   50 51 60 61 72 73 82 83 92 93 100 101
[2017-11-03 23:41:17.641] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 手上的扑克 13 20 50 51 52 60 61 72 73 82 83 92 93 100 101 102 103 130 132
[2017-11-03 23:41:17.641] [DEBUG] [game1-95] [./server/game/logic/logic_ddz.lua:150] tableid:95 上一手扑克 10 12 22 23 31 32
--]]

require 'functionsxx'

local combination = require 'combination'
local hc = {11, 12, 13, 20, 21, 22, 60, 92,90, 93, 100, 101, 102, 113, 110, 112, 120,121,122,150}
local lastcards = {10, 12,13,11, 31, 32}
print('----------------------------------')
local tcards = combination.getTrustOutCards(hc)
logic.printCards(tcards.cards)
luadump(tcards)

local logic = require 'logic'
local result = logic.getCardType(hc)
luadump(result)


print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
local function is_sequence(cards, keeptailhead)
	if not cards or not next(cards) then return false end
	local tailwrong = false
	local headwrong = false
	for i = 1, #cards - 1 do
    print(string.format('cards[i]:%d         cards[i+1]:%d', cards[i], cards[i + 1]))
		if cards[i] + 1 ~= cards[i+1] or cards[i+1] == 13 or cards[i+1] == 14 or cards[i+1] == 15 then
      print('coming????')
			if keeptailhead then
				return false
			end

			if #cards > 2 then
				if i == 1 then
					print(1111111)
					headwrong = true
				elseif i == #cards - 1 then
					if headwrong then
						print(2222222222)
						return false
					end
					print(3333333333)
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


local sxcards = {1,2,9,10,11,12}


print(is_sequence(sxcards))


print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')

local logic4 = require 'landlord4_lg'

local cards = {10, 11, 22, 21, 120, 121, 131, 130}
--local cards = {10, 11, 22, 21, 131, 130}
luadump(logic4.getCardType(cards))


local texasholdem = require 'texasholdem_lg'
print('--------------------------------------------------------------\n\n')
texasholdem.gettotalcards(6)
 