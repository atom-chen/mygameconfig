
pdk_select = {}

pdk_select.bombs = {}
pdk_select.single_joins = {}
pdk_select.three_join_twos = {}
pdk_select.three_joins = {}
pdk_select.double_joins = {}
pdk_select.doubles = {}
pdk_select.singles = {}


--选择出各种牌型
function pdk_select.get_all_card_type( cards )
	pdk_select.bombs = {}
	pdk_select.single_joins = {}
	pdk_select.three_join_twos = {}
	pdk_select.three_joins = {}
	pdk_select.double_joins = {}
	pdk_select.doubles = {}
	pdk_select.singles = {}

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end
	algorithm.sort(cs)
	local len = #cs

	local flag = 0
	for i =1,len,1 do
        local num = 1<<(i-1)
		flag = flag|num
    end

    local get_cards = {}
    local get_source = {} 
    for i = 1,#cards,1 do
    	table.insert(get_source,cards[i])
    end

    --print("flag1",flag)
    --挑出炸弹
    get_cards,flag = pdk_get_card.get_zhadan(cs,flag,0)
    while (#get_cards>0)
    do
    	get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	get_source = pdk_get_card.get_left_cards(cards,get_cards)
    	table.insert(pdk_select.bombs,get_cards)
    	get_cards,flag = pdk_get_card.get_zhadan(cs,flag,0)
   	end
   	--print("flag zhadan",flag)

   	--挑出顺子
   	local shunzi_len = 11
   	local b_find_shunzi = true
   	while(b_find_shunzi)
   	do
   		b_find_shunzi = false
   		shunzi_len = 11
	   	get_cards,flag = pdk_get_card.get_shunziV2(cs,shunzi_len,flag,2)
	   	if #get_cards>0 then
	   		b_find_shunzi = true
	   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
	   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
	    	table.insert(pdk_select.single_joins,get_cards)
	   	end
	   	while (#get_cards<=0)
	   	do
	   		shunzi_len = shunzi_len-1
	   		if shunzi_len<5 then
	   			break
	   		end
	   		get_cards,flag = pdk_get_card.get_shunziV2(cs,shunzi_len,flag,2)
	   		if #get_cards>0 then
		   		b_find_shunzi = true
		   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
		   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
		    	table.insert(pdk_select.single_joins,get_cards)
		   	end
	   	end
   end
   --print("flag shunzi",flag)

   --挑出飞机带翅膀
   local three_wings_len = 3
   local b_find_wings = true
   while(b_find_wings)
   do
   		b_find_wings = false
   		three_wings_len = 3
   		get_cards,flag = pdk_get_card.get_three_wings(cs,flag,three_wings_len,1)
   		if #get_cards>0 then
	   		b_find_wings = true
	   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
	   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
	    	table.insert(pdk_select.three_join_twos,get_cards)
	   	end 
	   	while (#get_cards<=0)
	   	do
	   		three_wings_len = three_wings_len-1
	   		if three_wings_len<2 then
	   			break
	   		end
	   		get_cards,flag = pdk_get_card.get_three_wings(cs,flag,three_wings_len,1)
	   		if #get_cards>0 then
		   		b_find_wings = true
		   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
		   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
		    	table.insert(pdk_select.three_join_twos,get_cards)
		   	end
	   	end
   end
   --print("flag wings",flag)

   --挑三带二
    get_cards,flag = pdk_get_card.get_three_two(cs,flag,2)
    while (#get_cards>0)
    do
    	get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
    	get_source = pdk_get_card.get_left_cards(get_source,get_cards)
    	table.insert(pdk_select.three_join_twos,get_cards)
    	get_cards,flag = pdk_get_card.get_three_two(cs,flag,2)
   	end

   	--挑出连三张
   local three_joins_len = 5
   local b_find_three_joins = true
   while(b_find_three_joins)
   do
   		b_find_three_joins = false
   		three_joins_len = 5
   		get_cards,flag = pdk_get_card.get_three_join(cs,flag,three_joins_len,1)
   		if #get_cards>0 then
	   		b_find_wings = true
	   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
	   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
	    	table.insert(pdk_select.three_joins,get_cards)
	   	end 
	   	while (#get_cards<=0)
	   	do
	   		three_joins_len = three_joins_len-1
	   		if three_joins_len<2 then
	   			break
	   		end
	   		get_cards,flag = pdk_get_card.get_three_join(cs,flag,three_joins_len,1)
	   		if #get_cards>0 then
		   		b_find_wings = true
		   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
		   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
		    	table.insert(pdk_select.three_joins,get_cards)
		   	end
	   	end
   end

    --挑三张
    get_cards,flag = pdk_get_card.get_three(cs,flag,2)
    while (#get_cards>0)
    do
    	get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
    	get_source = pdk_get_card.get_left_cards(get_source,get_cards)
    	table.insert(pdk_select.three_joins,get_cards)
    	get_cards,flag = pdk_get_card.get_three(cs,flag,2)
   	end

   --挑出连对
   local double_joins_len = 8
   local b_find_double_joins = true
   while(b_find_double_joins)
   do
   		b_find_double_joins = false
   		double_joins_len = 8
   		get_cards,flag = pdk_get_card.get_double_join(cs,flag,double_joins_len,1)
   		if #get_cards>0 then
	   		b_find_wings = true
	   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
	   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
	    	table.insert(pdk_select.double_joins,get_cards)
	   	end 
	   	while (#get_cards<=0)
	   	do
	   		double_joins_len = double_joins_len-1
	   		if double_joins_len<2 then
	   			break
	   		end
	   		get_cards,flag = pdk_get_card.get_double_join(cs,flag,double_joins_len,1)
	   		if #get_cards>0 then
		   		b_find_wings = true
		   		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
		   		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
		    	table.insert(pdk_select.double_joins,get_cards)
		   	end
	   	end
   end

   	--挑出对牌
   	get_cards,flag = pdk_get_card.get_double(cs,flag,2)
	while (#get_cards>0)
	do
		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
		table.insert(pdk_select.doubles,get_cards)
		get_cards,flag = pdk_get_card.get_double(cs,flag,2)
	end

	--挑出单牌
   	get_cards,flag = pdk_get_card.get_single(cs,flag,2)
	while (#get_cards>0)
	do
		get_cards = pdk_get_card.get_source_cards(get_cards,get_source)
		get_source = pdk_get_card.get_left_cards(get_source,get_cards)
		table.insert(pdk_select.singles,get_cards)
		get_cards,flag = pdk_get_card.get_single(cs,flag,2)
	end

end

function test_select(  )
	local cards = {11,12,110,111,112,100,101,91,80,60,61,62,50,51,52,32}
	pdk_select.get_all_card_type(cards)
	for i=1,#pdk_select.bombs,1 do
		print("zhadan",table.unpack(pdk_select.bombs[i]))
	end	
	for i=1,#pdk_select.single_joins,1 do
		print("shunzi",table.unpack(pdk_select.single_joins[i]))
	end	
	for i=1,#pdk_select.three_join_twos,1 do
		print("joins_two",table.unpack(pdk_select.three_join_twos[i]))
	end	
	for i=1,#pdk_select.three_joins,1 do
		print("three_joins",table.unpack(pdk_select.three_joins[i]))
	end	
	for i=1,#pdk_select.double_joins,1 do
		print("double_joins",table.unpack(pdk_select.double_joins[i]))
	end	
	for i=1,#pdk_select.doubles,1 do
		print("doubles",table.unpack(pdk_select.doubles[i]))
	end	
	for i=1,#pdk_select.singles,1 do
		print("singles",table.unpack(pdk_select.singles[i]))
	end	
end
--test_select(  )
--return pdk_select