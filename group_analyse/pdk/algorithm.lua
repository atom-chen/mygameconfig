local skynet = require "skynet"

algorithm = {}

--牌型
algorithm.card_type = {
}
algorithm.card_type.zhadan = 1
algorithm.card_type.single = 2
algorithm.card_type.double = 3
algorithm.card_type.three = 4
algorithm.card_type.three_one = 5
algorithm.card_type.three_two = 6
algorithm.card_type.single_join = 7
algorithm.card_type.double_join = 8
algorithm.card_type.three_join = 9
algorithm.card_type.three_wings = 10
algorithm.card_type.four_two = 11
algorithm.card_type.three_wings_1 = 12
algorithm.card_type.four_three = 13

--洗牌
function algorithm.shuffle(cards,len)
    for i = 1,len,1 do
		local rand = math.random(1,len)
		if rand ~= i then
			local value = cards[i]
			cards[i] = cards[rand]
			cards[rand] = value
		end
	end
end

--计算某张牌的个数
local function get_real_card_num( card,cards )
	local num = 0
	 for m,n in pairs(cards) do
	 	if pdk_cards.get_card_vale(card) == pdk_cards.get_card_vale(n) then
	 		num = num + 1
	 	end
    end
    return num
end

local function get_card_num( card,cards )
	local num = 0
	 for m,n in pairs(cards) do
	 	if card == n then
	 		num = num + 1
	 	end
    end
    return num
end

--排序

function algorithm.sort(cards)
    table.sort(cards, function(card1, card2)
		return card1 < card2
	end)
end

function algorithm.sort_value(cards)
    table.sort(cards, function(card1, card2)
		return pdk_cards.get_card_vale(card1) < pdk_cards.get_card_vale(card2)
	end)
end

--优先按照数量排序，从大到小
function algorithm.sort_by_num( cards )
	table.sort(cards, function(card1, card2)
			local num1 = get_card_num(card1,cards)
			local num2 = get_card_num(card2,cards)
			if num1>num2 then
				return true
			elseif num1<num2 then
				return false
			end
			if num1 == num2 then
				return card1<card2
			end
	end)
end

--判断是否是炸弹
function algorithm.isZhaDan( cards )
	local num = 0
	local card = 0
	if #cards<3 or #cards >4 then
		return false
	end
	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	--algorithm.sort_by_num(cs)
	for i=1,4,1 do
		if card == 0 then
			num = num+1
			card = cs[i]
		else
			if card == cs[i] then
				num = num+1
			end
		end
	end
	if num == 3 and #cards == 3 and (card == 1 or card == 14) then
		return true,14
	end

	if num == 4 and #cards == 4 then
		return true,cs[1]
	end

	return false
end

--判断是否是顺子
local function isShunzi( cards )
	algorithm.sort(cards)
	local card = 0
	if #cards < 5 or cards[1]==2 then
		return false
	end

	local len = #cards
	for i=1,len,1 do
		if card == 0 then
			card = cards[i]
		else
			if cards[i] - card ~= 1 or cards[i] == 15  then
				return false
			end
			card = cards[i]
		end
	end

	return true
end

--判断是否是顺子
function algorithm.isShunzi( cards )
	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end
	if isShunzi(cs) then
		return true,cs[1]
	end

	cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_vale(cards[i]))
	end
	if isShunzi(cs) then
		return true,cs[1]
	end

end

--判断是否是一对
function algorithm.isDuiZi(cards)
	if #cards ~=2 then
		return false
	end

	if  pdk_cards.get_card_real_value(cards[1])~= pdk_cards.get_card_real_value(cards[2]) then
		return false
	end

	return true, pdk_cards.get_card_real_value(cards[1])
end

--判断是否是连对
function algorithm.isLianDui( cards )
	if #cards <4 then
		return false
	end
	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort(cs)
	local len = #cs
	for i=1,len-3,2 do
		if cs[i+1] == cs[i] and cs[i+2] == cs[i+3] and cs[i+2]-cs[i+1] == 1 then

		else
			return false
		end
	end

	return true, cs[1]
end

--判断是否是三张
function algorithm.isThree(cards )
	if #cards ~=3 then
		return false
	end

	local len = #cards
	for i=1,len-1,1 do
		if pdk_cards.get_card_vale(cards[i])~=pdk_cards.get_card_vale(cards[i+1]) then
			return false
		end
	end
	return true, pdk_cards.get_card_real_value(cards[1])
end

--判断是否是三带一
function algorithm.isSanDaiYi( cards )
	if #cards ~= 4  then
		return false
	end
	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end
	algorithm.sort_by_num(cs)
	for i=1,#cs,1 do
		if get_card_num(cs[i],cs) == 3  then
			return true, cs[i]
		end
	end
	return false
end

--判断是否是三带二
function algorithm.isSanDaiEr(cards)
	if #cards ~= 5  then
		return false
	end
	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end
	algorithm.sort_by_num(cs)
	for i=1,#cs,1 do
		if get_card_num(cs[i],cs) == 3 then
			if get_card_num(cs[i],cs) == 4 then
				return false
			end
			return true, cs[i]
		end
	end
	return false
end

--判断是否是连三张
function algorithm.isLianThreeValue(cards)
	if #cards%3 ~= 0 or #cards < 6 then
		return false
	end

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, cards[i])
	end

	algorithm.sort_by_num(cs)
	local isThree = true
	--先判断是否是三张组合
	for i=1,#cs-2,3 do
		if cs[i] ~= cs[i+1] or cs[i] ~= cs[i+2] then
			isThree = false
			break
		end
	end	
	if isThree == false then
		return false
	end

	--判断是否是连续的
	for i=1,#cs-3,3 do
		if cs[i+3] - cs[i] ~=1  then
			return false
		end
	end	

	return true, cs[1]
end

--判断是否是连三张
function algorithm.isLianThree(cards)
	if #cards%3 ~= 0 or #cards < 6 then
		return false
	end

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort_by_num(cs)
	local isThree = true
	--先判断是否是三张组合
	for i=1,#cs-2,3 do
		if cs[i] ~= cs[i+1] or cs[i] ~= cs[i+2] then
			isThree = false
			break
		end
	end	
	if isThree == false then
		return false
	end

	--判断是否是连续的
	for i=1,#cs-3,3 do
		if cs[i+3] - cs[i] ~=1  then
			return false
		end
	end	

	return true, cs[1]
end

--判断是否是飞机带翅膀
function algorithm.isThreeWings(cards)
	if #cards%5 ~= 0 or #cards < 10 then
		return false
	end
	local lian_count = 0
	
	lian_count = #cards/5

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort_by_num(cs)

	--将炸弹多余的一张放到后面
	--处理过的牌
	local deal_card = {}
	for i=1,#cs,1 do
		local c_num = get_card_num(cs[i],cs)
		if c_num == 4 then
			local bfind = false
			for m,n in pairs(deal_card) do
				if n == cs[i] then
					bfind = true
				end
			end
			if bfind == false then
				table.insert(deal_card, cs[i])
				table.insert(cs,table.remove(cs,i))
			end
		end
	end

	--判断是否是连三张的个数
	local isThreeNum = 0
	--先判断是否是三张组合
	for i=1,#cs,3 do
		if i+2 >#cs then
			break
		end
		if cs[i] == cs[i+1] and cs[i] == cs[i+2] then
			isThreeNum = isThreeNum+1
		end
	end	

	if isThreeNum < lian_count then
		return false
	end

	local three_tb = {}
	for i=1,isThreeNum,1 do
		table.insert(three_tb,cs[(i-1)*3+1])
		table.insert(three_tb,cs[(i-1)*3+1])
		table.insert(three_tb,cs[(i-1)*3+1])
	end

	algorithm.sort_by_num(three_tb)

	--判断是否是连续的
	for i=1,isThreeNum,1 do
		if isThreeNum*3-(i-1)*3<lian_count*3 then
			return false
		end
		local cacl_cards = {}
		for j = 1,lian_count,1 do
			table.insert(cacl_cards,three_tb[(i-1)*3+(j-1)*3+1])
			table.insert(cacl_cards,three_tb[(i-1)*3+(j-1)*3+1])
			table.insert(cacl_cards,three_tb[(i-1)*3+(j-1)*3+1])
		end
		--判断是否是连续的
		local ok = algorithm.isLianThreeValue(cacl_cards)
		if ok then
			return true,cacl_cards[1]
		end
	end	

	return false
end

--判断是否是飞机带翅膀
function algorithm.isThreeWings_1(cards)
	if #cards%4 ~= 0 or #cards < 8 then
		return false
	end
	local lian_count = 0
	
	lian_count = #cards/4

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort_by_num(cs)

	--将炸弹多余的一张放到后面
	--处理过的牌
	local deal_card = {}
	for i=1,#cs,1 do
		local c_num = get_card_num(cs[i],cs)
		if c_num == 4 then
			local bfind = false
			for m,n in pairs(deal_card) do
				if n == cs[i] then
					bfind = true
				end
			end
			if bfind == false then
				table.insert(deal_card, cs[i])
				table.insert(cs,table.remove(cs,i))
			end
		end
	end

	--判断是否是连三张的个数
	local isThreeNum = 0
	--先判断是否是三张组合
	for i=1,#cs,3 do
		if i+2 >#cs then
			break
		end
		if cs[i] == cs[i+1] and cs[i] == cs[i+2] then
			isThreeNum = isThreeNum+1
		end
	end	

	if isThreeNum < lian_count then
		return false
	end

	local three_tb = {}
	for i=1,isThreeNum,1 do
		table.insert(three_tb,cs[(i-1)*3+1])
		table.insert(three_tb,cs[(i-1)*3+1])
		table.insert(three_tb,cs[(i-1)*3+1])
	end

	algorithm.sort_by_num(three_tb)

	--判断是否是连续的
	for i=1,isThreeNum,1 do
		if isThreeNum*3-(i-1)*3<lian_count*3 then
			return false
		end
		local cacl_cards = {}
		for j = 1,lian_count,1 do
			table.insert(cacl_cards,three_tb[(i-1)*3+(j-1)*3+1])
			table.insert(cacl_cards,three_tb[(i-1)*3+(j-1)*3+1])
			table.insert(cacl_cards,three_tb[(i-1)*3+(j-1)*3+1])
		end
		--判断是否是连续的
		local ok = algorithm.isLianThreeValue(cacl_cards)
		if ok then
			return true,cacl_cards[1]
		end
	end	

	return false
end

--判断是否是四带二
function algorithm.isFourWithTwo(cards)
	if #cards ~= 6 then
		return false
	end

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort_by_num(cs)

	for i=1,#cs,1 do
		local c_num = get_card_num(cs[i],cs)
		if c_num == 4 then
			return true,cs[i]
		end
	end

	return false,0
end

--判断是否是四带三
function algorithm.isFourWithThree(cards)
	if #cards ~= 7 then
		return false
	end

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort_by_num(cs)

	for i=1,#cs,1 do
		local c_num = get_card_num(cs[i],cs)
		if c_num == 4 then
			return true,cs[i]
		end
	end

	return false,0
end
--判断是什么牌型
function algorithm.get_card_type( cards )
	local len = #cards
	local ok = false
	local value = 0
	if len == 1 then
		return algorithm.card_type.single,pdk_cards.get_card_real_value(cards[1])
	end
	ok,value = algorithm.isDuiZi(cards)
	if ok then
		return algorithm.card_type.double,value
	end
	ok,value = algorithm.isZhaDan(cards)
	if ok then
		return algorithm.card_type.zhadan,value
	end
	ok,value = algorithm.isThree(cards)
	if ok then
		return algorithm.card_type.three,value
	end
	ok,value = algorithm.isSanDaiYi(cards)
	if ok then
		return algorithm.card_type.three_one,value
	end
	ok,value = algorithm.isSanDaiEr(cards)
	if ok then
		return algorithm.card_type.three_two,value
	end
	ok,value = algorithm.isShunzi(cards)
	if ok then
		return algorithm.card_type.single_join,value
	end
	ok,value = algorithm.isLianDui(cards)
	if ok then
		return algorithm.card_type.double_join,value
	end
	ok,value = algorithm.isLianThree(cards)
	if ok then
		return algorithm.card_type.three_join,value
	end
	ok,value = algorithm.isThreeWings(cards)
	if ok then
		return algorithm.card_type.three_wings,value
	end

	ok,value = algorithm.isThreeWings_1(cards)
	if ok then
		return algorithm.card_type.three_wings_1,value
	end

	ok,value = algorithm.isFourWithTwo(cards)
	if ok then
		return algorithm.card_type.four_two,value
	end

	ok,value = algorithm.isFourWithThree(cards)
	if ok then
		return algorithm.card_type.four_three,value
	end

	return 0,0
end

--local test_cards = {101,102,103,111,112,113,30,31,32,110}
--local ret = algorithm.get_card_type(test_cards)
--print("type",ret)

return algorithm

