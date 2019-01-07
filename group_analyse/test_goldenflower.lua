local logic = require 'goldenflower_lg'
local dropcardslg = require 'dropcardslg'

require 'functionsxx'

local cards = {
	{33, 43, 53}, 
	{42, 62, 102}
}

local ct1, kv1 = logic.getCardType(cards[1])
luadump(ct1)
local testct = require 'goldenflower_cardtypetest1'
for k, v in pairs(testct) do
  print('group: '..tostring(k))
	local ct1, kv1 = logic.getCardType(v.cards1)
	if ct1 ~= v.ct1 then
		print(string.format('group:%d program ct1:%d  manual ct1 : %d', k, ct1, v.ct1))
	end
	local ct2, kv2 = logic.getCardType(v.cards2)
	if ct2 ~= v.ct2 then
		print(string.format('group:%d program ct2:%s  manual ct2: %d', k, tostring(ct2), v.ct2))
	end
	local node1 = {cards = v.cards1, ct = ct1, kv = kv1}
	local node2 = {cards = v.cards2, ct = ct2, kv = kv2}
	local xx = logic.node1better(node1, node2)
	if xx == true then
		xx = 1
	elseif xx == false then
		xx = 2
	end

	if xx ~= v.win then
		print(string.format('anser is not same!! program  win:%s   manually win:%d', tostring(xx), v.win))
	end
end


local ct1, kv1 = logic.getCardType(testct[41].cards1)
luadump(ct1)
print(kv1)

local ct2, kv2 = logic.getCardType(testct[41].cards2)
luadump(ct2)
print(kv2)
-- local node = {}
-- node.ct, node.kv =  logic.getCardType(cards[1])
-- --luadump(node)


-- local nodes = logic.gettotalcards(5)
-- luadump(nodes)
  
  
  local logic1 = require 'GFguess_lg'
  
  local nodes = {
  		{cards = {43, 120, 50}},
  		{cards = {20, 121, 52}},
	}

	for k, v in pairs(nodes) do
		v.ct, v.kv = logic.getCardType(v.cards)
	end
	luadump(logic.node1better(nodes[1], nodes[2]))

-- "params1":[102,120,40,1],"winsid":2,"params2":[31,131,73,1]} isCache:false
local cards = {
	{11,53},
	{122,130},
  {122,130,10},
}

print('\n\n---------------------!!!!!!!!!!!!!!!!')
--local xnode = logic1.getCardType(cards[2])


--luadump(cards[2])
--luadump(xnode)


luadump(logic1.getsidepercent(cards[3], cards[2]))