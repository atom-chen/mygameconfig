local logic = require 'chickencompare_lg'
local dropcardslg = require 'dropcardslg'

require 'functionsxx'

local cards = {

-- sJork 4♦ 10♥ 5♥ 5♠ A♣ K♣ 2♣ 5♣ J♠ 

-- 5♠ K♠ 7♦ 5♥ 4♣ sJork♦ bJork♦ 6♦ Q♦ 10♦ 
	-- {11,30,41,42,43,92,103,121,131,140}, 

	-- A♠ A♣ 9♥ K♥ K♣ 6♥ 8♠ 4♣ 4♦ bJork 
	-- {30,31,52,73,82,121,122,131,133,150}

	-- 6♦ bJork K♠ 7♣ 5♦ 10♥ 6♣ A♥ A♣ 9♥ 
	-- {40,50,51,61,82,92,123,132,131,150}

	-- 6♣ 2♥ K♥ sJork 5♦ 8♣ 10♥ 10♠ 5♣ K♣ 
	{72,83,122,51,113,101,22,11,12,150},
	-- {150,133,130,112,93,90,81,62,23,10}
	-- {43,42,31,50,60,90,123,110,140,150}, 
	-- {91,90,83,82,81,80,73,72,71,70}, 
  --{133,93,83,131,81,21,112,52,150}，
}

-- local excards = {30,10,140,113,63,33,81,71,51}
-- logic.getCardType({30,10,140})

-- logic.printCards(excards)
-- print(logic.judgeleague(excards))

-- local cpcards = {
-- 	{91,21,140,112,92,22,150,72,60},
-- 	{91,92,140,21,22,23,150,72,60},
-- }

-- print(logic.pieceGroup1better(cpcards[1], cpcards[2]))

local testdata = require 'text_chikencompaire_cardtype'

local testdatax = require 'test_chikencompaire_xcardtype'

for k, v in pairs(cards) do
	print('\n\n')
	logic.printCards(v)
	local result = logic.getorgnizegroup(v)
	-- luadump(result)
	logic.printCards(result)

end



--logic.printCards(result, false, 'final answer!')
-- local final = {}
-- for k, v in pairs(result) do
	-- local tmp = {}
	-- for k, v in pairs(v) do
	-- 	table.mergeByAppend(tmp, v.cards)
	-- end
	-- table.insert(final, tmp)
	-- logic.printCards(tmp, false, 'final answer!')
	-- logic.printCards(v)
-- end

-- logic.test(cards[1])

-- for i = 1, 10000 do
-- 	local cards = logic.gettotalcardsnormal(2)
-- 	for k, v in pairs(cards) do
--     print('group: '..tostring(i))
-- 		logic.printCards(v.cards, false)
	  
-- 		local result = logic.getorgnizegroup(v.cards)
-- 	    if not result or not next(result) then
-- 	    	logic.printMachineCards(v.cards)
-- 	    end
-- 		assert(result ~= nil and next(result))
-- 		logic.printCards(result, false, 'final answer!')
-- 	  	print('\n\n')
-- 	end
-- end

--local result = logic.getMaxCombination(cards[1])

--luadump(logic.gettotalcardsnormal(3))


--luadump(result)

--local cards1 = {133,93,83,131,81,21,112,52,150}
--logic.judgeleague(cards1)


-- print('\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')

-- for k, v in pairs(testdata) do
--   luadump(v)
--   local ct, kv = logic.getCardType(v.cards)
--   print(string.format('\n\nct: %d  kv : %s', ct, tostring(kv)))
--   if ct ~= v.ct then
--     luadump(v)
--     break
--   end
-- end

-- print('\n\n')

-- logic.getCardTypeEX({130, 10})
--[[
local ct , kv, xx = logic.getCardType({150, 93, 83})
print(string.format('ct : %s, kv : %s, xx: %s', tostring(ct), tostring(kv), tostring(xx)))
--luadump(xx)

local tmpcards
local ct,kv
--testdatax = {}
--]]
for k, v in pairs(testdatax) do
	local xnode = {}
	xnode.ct = {}
	xnode.finalcards = v.cards
	-- xnode.excards = table.arraycopy(xnode.finalcards, 1, #xnode.finalcards)
	xnode.excards = {}
	for i = 1, 3 do
		tmpcards = table.arraycopy(v.cards, (i - 1) * 3 + 1, 3)
		table.sort(tmpcards, function(c1, c2)
			return c1 > c2
		end)
		ct, kv, changec = logic.getCardType(tmpcards)
		xnode.ct[i] = {cards = tmpcards, ct = ct, kv = kv}
		for k1, v1 in pairs(tmpcards) do
			if v1 >= 140 then
				table.insert(xnode.excards, table.remove(changec))
			else
				table.insert(xnode.excards, v1)
			end
		end
	end
	local exct = logic.getEXCardType(xnode)
  
  	for i = 1, 11 do
  		if (exct[i] and exct[i] ~= 0 and not v.ct[i]) or (not exct[i] and v.ct[i]) or (exct[i] ~= 0 and exct[i] ~= v.ct[i]) then
  			luadump(xnode)
			luadump(exct)
			luadump(v)
			print('\n\n')
			break
  		end
  	end
end

print('done!!!')

--[[
local testdatacompare = require 'test_chikencompaire_compare'
for k, v in pairs(testdatacompare) do

	local winner = 2

	if logic.node1better({v.nodes[1].cards, v.nodes[2].cards}) then
		winner = 1
	end
	if winner ~= v.winner then
    print('calc winner = '..tostring(winner))
		luadump(v)
		break
	end
end
--local ct, kv, cc = logic.getCardType({140, 123, 113})
--print(ct)
--luadump(cc)

--]]