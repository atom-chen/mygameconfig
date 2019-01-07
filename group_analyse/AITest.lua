local util = require 'ai_util'
local logic = require 'logic'
--local Hint = require 'Hint'
local combination = require 'combination'

--local mf = require "mail_format"



--bankerFirst

--local cards = {10,11,12,13}
--local cards = {{110, 111, 112, 120, 121, 122}, {10,11,20,22,60,12,100, 101, 102}, {12, 13, 31, 61, 71, 80, 90, 103, 130, 131, 132}}

--local cards = {{80, 90, 100, 110, 120, 20,21,22,30,32}, {10,11,100, 101, 102}, {12, 13, 31, 61, 71, 80, 90, 103, 130, 131, 132}}

local cards = {{110,111,112,113,120,121}, {90,101,110,121,131}, {40,60,70,71,72,73,90,91,100,110,111,120,130}}--140,150

--local cards = {{70,70,71,20,30, 120}, {130}, {10,11,100, 101, 102}}

--local cards = {{80,81,82,130,131}, {122,123}, {100,101,103}}

--local cards = {{80,81,82,130,131, 132,133}, {13,23,33,43,52,53,62,63,72,73,90,91,92,93,}, {100,101,103,110,111,113,120,121,122,123,131,132,133}}

--local cards = {{80, 81, 90, 91, 100, 101}, {10,11,100, 101, 102}, {12, 13, 31, 61, 71, 80, 90, 103, 130, 131, 132}}

--3♥ 3♣ 4♣ 6♥ 6♣ 7♥ 7♣ 7♦ J♦ Q♠ Q♥ Q♣ Q♦ A♠ A♣ 2♥ 2♣ 2♦ 

--combination.getTrustOutCards(cards[sid], {})

local preCards = {60,61,62,63}

local bestComb = combination.craeteBestComb(cards[1])

-- local resultCards = combination.bankerFirst(bestComb, cards[1], cards[2], cards[3])
--local resultCards = combination.bankerOutCard(bestComb, cards[1], preCards, true, cards[2], cards[3])
-- local resultCards = combination.upsideOfBankerOutCard(bestComb, cards[3], preCards, true, cards[1], cards[2])
--local resultCards = combination.undersideOfBankerOutCard(bestComb, cards[1], preCards, false, cards[2], cards[3])
-- local resultCards = combination.getTrustOutCards(cards[1], {12})
--local resultCards = combination.underBankerFirst(bestComb, cards[1], cards[2], cards[3])

--local resultCards = combination.upBankerFirst(bestComb, cards[1], cards[3], cards[2])
local resultCards = combination.getTrustOutCards(cards[1])
if resultCards and next(resultCards) then
	print('msg:--------------result')
  	logic.printCards(resultCards.cards)
end

print('1111\n\n')
-- [2016-01-06 23:57:47.819] [DEBUG] [robot1-26] [./server/robot/ddz/ai_ddz.lua:53] msg:----------------------underBanker : 1   upsideBanker:  2       mySeatID: 2    banker: 3
-- [2016-01-06 23:57:47.820] [DEBUG] [robot1-26] [./server/robot/ddz/logic.lua:172] 3♠ 3♦ 4♣ 5♠ 5♣ 5♦ 7♥ 7♦ 9♣ 10♦ J♦ Q♥ Q♣ K♠ 2♦ 
-- [2016-01-06 23:57:47.820] [DEBUG] [robot1-26] [./server/robot/ddz/logic.lua:157] 90,92,
-- [2016-01-06 23:57:47.820] [DEBUG] [robot1-26] [./server/robot/ddz/logic.lua:157] 11,13,22,31,32,33,50,53,72,83,93,100,102,111,133,
-- [2016-01-06 23:57:47.821] [DEBUG] [robot1-26] [./server/robot/ddz/logic.lua:157] 60,70,81,91,103,120,
-- [2016-01-06 23:57:47.821] [DEBUG] [robot1-26] [./server/robot/ddz/ai_ddz.lua:63] msg:-------------------第一个出牌
-- [2016-01-06 23:57:47.821] [DEBUG] [robot1-26] [./server/robot/ddz/ai_ddz.lua:94] getOutCards put cards
-- [2016-01-06 23:57:47.821] [DEBUG] [robot1-26] [./server/robot/ddz/logic.lua:172] 7♥ 7♦ 

--upbanker
--[[
--local cards = {{13,21,70,73,80,82,90,92,122,123,131}, {120}, {10,11,21,30,33,42,51,61,70,92,102,110,113,121,131}}
--local cards = {{11,13,22,31,32,33,50,72,83,93,100,102,111,133}, {60,70,81,91,103,120}, {90,92}}
--3♥ 3♣ 4♣ 6♥ 6♣ 7♥ 7♣ 7♦ J♦ Q♠ Q♥ Q♣ Q♦ A♠ A♣ 2♥ 2♣ 2♦ 
local preCards = {32}

table.sort(cards[1], function(card1, card2)
	return card1 < card2
end)

logic.printCards(cards[1])
local bestComb = combination.craeteBestComb(cards[1])

local resultCards = combination.upBankerFirst(bestComb, cards[1], cards[2], cards[3])
-- local resultCards = combination.upsideOfBankerOutCard(bestComb, cards[1], preCards, true, cards[2], cards[3])
--local resultCards = combination.getFlowOutCards(cards[1], preCards, true, 16)

--local resultCards = combination.upBankerFirst(cards[1], cards[2], cards[3])

if resultCards and next(resultCards) then
	print('msg:--------------result')
  	logic.printCards(resultCards.cards)

end
--]]

-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/ai_ddz.lua:53] msg:----------------------underBanker : 2   upsideBanker:  3       mySeatID: 2    banker: 1
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:172] K♥ K♦ A♠ A♣ 
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:157] 112,
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:157] 110,113,121,122,
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:157] 30,32,43,71,82,91,102,103,120,132,
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/ai_ddz.lua:74] msg:--------跟牌
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:157] 20,
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:172] 4♥ 
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/ai_ddz.lua:82] msg:----------------------------------------underBanker!!
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/ai_ddz.lua:94] getOutCards put cards
-- [2016-01-05 11:38:54.782] [DEBUG] [robot1-91] [./server/robot/ddz/logic.lua:172] A♠ A♣ 
--underbanker
--[[
local cards = {{110,113,121,122}, {122}, {30,32,43,71,82,91,102,103,120,132}}
-- 4♠ 5♥ 5♣ 5♦ 7♥ 7♦ 8♥ 8♦ 10♠ 10♣ J♠ J♥ Q♠ A♠ A♥ 2♣ 2♦ 

local preCards = {20}
-- 5♠ 6♠ 7♥ 8♦ 9♠ 10♠ J♠ Q♠ 

table.sort(cards[1], function(card1, card2)
	return card1 < card2
end)
local ss = combination.craeteBestComb(cards[1])

logic.printCards(cards[1])
--cards, preCards, enemy, enemyCards, friendCards
local resultCards = combination.undersideOfBankerOutCard(ss, cards[1], preCards, true, cards[2], cards[3])
--local resultCards = combination.underBankerFirst(ss, cards[1], cards[2], cards[3])

if resultCards and next(resultCards) then
	print('msg:--------------result')
  	logic.printCards(resultCards.cards)
end
--]]


--combination.printResultList(list)

-- --util.printTable(resultCards)
-- if resultCards and next(resultCards) then
-- 	print('msg:--------------result')
--   	logic.printCards(resultCards.cards)
-- end
--resultCards = combination.undersideOfBankerOutCard(cards, preCards, true)

--local resultCards = logic.getAllBomCard(cards, 0)--, false, true)--, false, true)--, false, true)
--local resultCards = logic.getAllFourTake(cards, true, false, 0)--, false, true)--, false, true)--, false, true)

-- combination
--[[
local cards = {10,11,13,21,23,32,41,50,61,81,82,83,92,100,102,111,113,121,122,130}

--local cards = {10, 30,31,32,40,50,60,70,80}

table.sort(cards, function(card1, card2)
	return card1 < card2
end)

logic.printCards(cards)
combination.initializeCombinations(cards, true)
combination.printCombination(combination.combinations)
--]]

--local resultCards = logic.getAllPlaneCard(cards)--, takeOne, takeTwo, preKeyValue, preAmount)

-- local resultCards = combination.getAllFirstCards(cards)
-- for k, v in pairs(resultCards) do
--   logic.printCards(v.cards)
-- end


-- local cards = {{20,32,43,50,52,70,81,90,101,110,111,112,120,123,130,132,133}, {112, 113}, {62}}
-- combination.initializeCombinations(cards[1], true)
-- assert(#combination.combinations > 0)
-- combination.printCombination(combination.combinations)

-- local cards = {10,30,31,40,42,43,50,51,52,61,80,81,90,111,113,131,133}
-- -- 3♠ 5♠ 5♥ 6♠ 6♣ 6♦ 7♠ 7♥ 7♣ 8♥ 10♠ 10♥ J♠ K♥ K♦ 2♥ 2♦ 
-- local container = {}
-- local amout = 2

-- container = logic.getMinDoubleEX(cards, amout, {40,42,43,50,51,52})
-- container = logic.getMinDoubleEX(cards, amout, {40,42,43,50,51,52})

-- print('msg:------------------------------amount: ', #container)
-- for k, v in pairs(container) do
-- 	logic.printCards(v)
-- end

--[[
math.randomseed(12534)
-- local sss = {{10, 30}}
-- local ress = {{10}}
-- if not logic.cardsInCards(container, result) then
function table.arraycopy(array, index, len)
    local newtable = {};
    len = len or 0
    if len == 0 then
        len = #array - index + 1
    end
    for i = index,index + len - 1 do
        newtable[i-index+1] = array[i];
    end
    return newtable;
end

combination.test()
--]]

-- msg:================托管中......
-- [2016-03-14 17:21:54.891] [DEBUG] [game1-14] [./server/robot/ddz/logic.lua:172] Q♠ Q♦ K♥ K♠ A♣ A♦ 上一个玩家的牌:
-- [2016-03-14 17:21:54.891] [DEBUG] [game1-14] [./server/robot/ddz/combination.lua:1459] msg:-------------------cards in hand
-- [2016-03-14 17:21:54.891] [DEBUG] [game1-14] [./server/robot/ddz/logic.lua:172] 4♥ 6♥ 6♠ 6♣ 6♦ 7♥ 8♥ 8♠ 8♦ 9♠ 10♣ 10♦ J♦ Q♣ K♣ K♦ A♠ JokerS 
-- [2016-03-14 17:21:54.891] [DEBUG] [game1-14] [./server/robot/ddz/logic.lua:157] 20,40,41,42,43,50,60,61,63,71,82,83,93,102,112,113,121,140,
-- [2016-03-14 17:21:54.891] [DEBUG] [game1-14] [./server/robot/ddz/combination.lua:1462] msg:-------------------pre cards
-- [2016-03-14 17:21:54.892] [DEBUG] [game1-14] [./server/robot/ddz/logic.lua:157] 101,103,110,111,122,123,
-- [2016-03-14 17:21:54.892] [DEBUG] [game1-14] [./server/robot/ddz/logic.lua:172] Q♠ Q♦ K♥ K♠ A♣ A♦ 
-- [2016-03-14 17:21:54.896] [DEBUG] [game1-14] [./server/game/logic/logic_ddz.lua:599] msg:---------------未找到答案。


  -- cardids = cardids or {
  --10,11,12,13,
  --        20,21,22,23,
  --        30,31,32,33,
  --        40,41,42,43,
  --        50,51,52,53, 7
  --        60,61,62,63,
  --        70,71,72,73,
  --        80,81,82,83,
  --        90,91,92,93,
  --        100,101,102,103,
  --        110,111,112,113,
  --        120,121,122,123,
  --        130,131,132,133,
  --        140,150}
  
--[[
local result = combination.getTrustOutCards({120,121,122, 123, 130}, {30,31,32, 41, 33, 50})
if result then
logic.printCards(result.cards)
else
print("msg:---!@@")
end

--]]



local cards = {10,11,20,21,22,30,31,32,33,40,41,42,50}

local ct = logic.getCardType(cards)
--local ct = logic.getGuessCardsType(cards)
print('\n\nct: '..ct)

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

local function get_type(cards, cards1, cards2, cards3, cards4)
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
			table.insert(ocards, #ocards+1, j)
			if cards1 then
				table.insert(cards1, #cards1+1, j)
			end
		elseif nums[j] == 2 then
			table.insert(tcards, #tcards+1, j)
			if cards2 then
				table.insert(cards2, #cards2+1, j)
			end
		elseif nums[j] == 3 then
			table.insert(scards, #scards+1, j)
			table.insert(sxcards, #sxcards+1, j)
			if cards3 then
				table.insert(cards3, #cards3+1, j)
			end
		elseif nums[j] == 4 then
			table.insert(fcards, #fcards+1, j)
			table.insert(sxcards, #sxcards+1, j)
			if cards4 then
				table.insert(cards4, #cards4+1, j)
			end
		end
	end
	if nums[14] == 1 and nums[15] == 1 and count == 2 then
		return SW
	end
	if count == 1 then
		return DZ
	end
	if count == 2 and #tcards == 1 then
		return EZ
	end
	if count == 3 and #scards == 1 then
		return SZ
	end
	if count == 4 and #fcards == 1 then
		return ZD
	end
	if #scards == 1 and count == 4 then
		return SDY
	end
	if #scards == 1 and count == 5 and #tcards == 1 then
		return SDD
	end
	if (#fcards == 1 and count == 6) then
		if #tcards == 1 or #ocards == 2 then
			return SDEY
		end
	end
	if count == 8 then
		if (#fcards == 1 and #tcards == 2) or #fcards == 2 then
			return SDED
		end
	end

	if #sxcards > 1 and is_shun(sxcards) then
		if count == 4 * #sxcards then
			return FJDY
		end
	end

	if #scards > 1 and is_shun(scards) then
		if count == 5 * #scards then
			if (#scards == #tcards) or (#scards == 2 * #fcards) then
				return FJDD
			end
		end
		if #scards * 3 == count then
			return SS
		end
	end
	if #ocards > 4 and #ocards == count and is_shun(ocards) then
		return DS
	end
	if #tcards > 2 and #tcards * 2 == count and is_shun(tcards) then
		return ES
	end
	return 0
end


local ct1 = logic.getCardType(cards)
--local ct = logic.getGuessCardsType(cards)
print('\n\nct1: '..ct1)

local str = "sdaf:00|sdf:22|"
for subv in str:gmatch("([^|]*)|") do
		local id, cnt = string.match(subv, "([^:]*):([^:]*)")
    print(tostring(id)..tostring(cnt))
end