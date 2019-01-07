
pdk_get_card = {}

--取反
local function get_fan(index)
	local value = 0
	for i = 0,31,1 do
		if index ~= i then
			value = value|(1<<(i))
			--print("value",value)
		end
	end
	return value
end

--去除标志
local function remove_flag( flag,index )
	flag = flag & get_fan(index)
	if flag == 0 then
		flag = flag|(1<<32)
	end
	return flag
end

--去除多个相同牌的标志
local function remove_same_card_flag( flag,cards,card,num )
	local r_num = 0
	 for m,n in pairs(cards) do
	 	if card == n and  flag & 1<<(m-1) >0 then
	 		flag = remove_flag(flag,m-1)
	 		r_num = r_num+1
		 	if r_num >= num then
		 		if flag == 0 then
					flag = flag|(1<<32)
				end
		 		return flag
		 	end
		 end
	 end
	 if flag == 0 then
		flag = flag|(1<<32)
	end
	 return flag
end

local function get_card_num( card,cards,flag )
	local num = 0
	if flag ~= nil then
		for i=1,#cards,1 do
			if flag & 1<<(i-1) >0 and card == cards[i] then
				num = num + 1
			end
		end
	else
		for m,n in pairs(cards) do
		 	if card == n then
		 		num = num + 1
		 	end
	    end
	end
    return num
end

--炸弹
function pdk_get_card.get_zhadan(cards,flag,value)
	local tb_zhadan = {}
	algorithm.sort(cards)
	if not flag then
		return {}
	end
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
    
   for m,n in pairs(cards) do
   		if flag & 1<<(m-1) >0 then
	   		local c_num = get_card_num(n,cards)
	   		if c_num == 4 then
	   			if value ~= nil then
	   				if n>value then
	   					table.insert(tb_zhadan,n)
			   			table.insert(tb_zhadan,n)
			   			table.insert(tb_zhadan,n)
			   			table.insert(tb_zhadan,n)
			   			flag = remove_same_card_flag(flag,cards,n,4)
			   			return tb_zhadan,flag 
	   				end
	   			else
		   			table.insert(tb_zhadan,n)
		   			table.insert(tb_zhadan,n)
		   			table.insert(tb_zhadan,n)
		   			table.insert(tb_zhadan,n)
		   			flag = remove_same_card_flag(flag,cards,n,4)
		   			return tb_zhadan,flag
		   		end
	   		end

	   		if c_num == 3 and (n == 1 or n == 14) then
	   			table.insert(tb_zhadan,n)
	   			table.insert(tb_zhadan,n)
	   			table.insert(tb_zhadan,n)
	   			flag = remove_same_card_flag(flag,cards,n,3)
	   			return tb_zhadan,flag
	   		end
	   	end
    end
    return tb_zhadan,flag
end

--顺子
function pdk_get_card.get_shunzi( cards,glen ,flag,value)
	if not flag then
		return {}
	end
	algorithm.sort(cards)
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end

	local get_cards = {}
	local get_cards_index = {}
	local last_card = 0
	for i = 1,len,1 do
		get_cards = {}
		get_cards_index = {}
		if flag & 1<<(i-1) >0 and cards[i]>value and cards[i]~= 15 then
			last_card = cards[i]
			table.insert(get_cards,cards[i])
			table.insert(get_cards_index,i)
			for j = i,len,1 do
				if flag & 1<<(j-1) >0 then
					if cards[j]-last_card == 1 and cards[j]~= 15 then
						--print("shunzi",cards[j],last_card)
						last_card = cards[j]
						table.insert(get_cards,cards[j])
						table.insert(get_cards_index,j)
						if #get_cards >= glen then
							break
						end
					end
				end--
			end

		end

		if #get_cards >= glen then
			break
		end
	end

	if #get_cards >= glen then
		for i = 1,#get_cards_index,1 do
			flag = remove_flag(flag,get_cards_index[i]-1)
		end
	else
		get_cards = {}
	end

	return get_cards,flag
end

--顺子,不拆三张
function pdk_get_card.get_shunziV2( cards,glen ,flag,value)
	if not flag then
		return {}
	end
	algorithm.sort(cards)
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end

	local get_cards = {}
	local get_cards_index = {}
	local last_card = 0
	for i = 1,len,1 do
		get_cards = {}
		get_cards_index = {}
		if flag & 1<<(i-1) >0 and cards[i]>value and cards[i]~= 15 and  get_card_num(cards[i],cards,flag)<3 then
			last_card = cards[i]
			table.insert(get_cards,cards[i])
			table.insert(get_cards_index,i)
			for j = i,len,1 do
				if flag & 1<<(j-1) >0 then
					if cards[j]-last_card == 1 and cards[j]~= 15 and  get_card_num(cards[j],cards,flag)<3 then
						--print("shunzi",cards[j],last_card)
						last_card = cards[j]
						table.insert(get_cards,cards[j])
						table.insert(get_cards_index,j)
						if #get_cards >= glen then
							break
						end
					end
				end--
			end

		end

		if #get_cards >= glen then
			break
		end
	end

	if #get_cards >= glen then
		for i = 1,#get_cards_index,1 do
			flag = remove_flag(flag,get_cards_index[i]-1)
		end
	else
		get_cards = {}
	end

	return get_cards,flag
end

--対子
function pdk_get_card.get_double(cards,flag,value)
	if not flag then
		return {}
	end
	algorithm.sort(cards)
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end

	local get_cards = {}
	for i = 1,len,1 do
		if flag & 1<<(i-1) > 0 then
			local c_num = get_card_num(cards[i],cards,flag)
	   		if c_num >= 2 then
	   			if value ~= nil then
	   				if cards[i]>value then
	   					table.insert(get_cards,cards[i])
			   			table.insert(get_cards,cards[i])
			   			flag = remove_same_card_flag(flag,cards,cards[i],2)
			   			return get_cards,flag
	   				end
	   			else
		   			table.insert(get_cards,cards[i])
		   			table.insert(get_cards,cards[i])
		   			flag = remove_same_card_flag(flag,cards,cards[i],2)
		   			return get_cards,flag
	   			end
	   		end
		end
	end
	return get_cards,flag
end

--单牌
function pdk_get_card.get_single(cards,flag,value)
	if not flag then
		return {}
	end
	algorithm.sort(cards)
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end

	local get_cards = {}
	for i = 1,len,1 do
		if flag & 1<<(i-1) > 0 then
			local c_num = get_card_num(cards[i],cards,flag)
	   		if c_num == 1 then
	   			if value ~= nil then
	   				if cards[i]>value then
	   					table.insert(get_cards,cards[i])
			   			flag = remove_same_card_flag(flag,cards,cards[i],1)
			   			return get_cards,flag
	   				end
	   			else
		   			table.insert(get_cards,cards[i])
		   			flag = remove_same_card_flag(flag,cards,cards[i],1)
		   			return get_cards,flag
	   			end
	   		end
		end
	end
	return get_cards,flag
end

--三张
function pdk_get_card.get_three( cards,flag,value )
	if not flag then
		return {}
	end
	algorithm.sort(cards)
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
	local src_flag = flag

	local get_cards = {}
	for i = 1,len,1 do
		if flag & 1<<(i-1) >0 then
			local c_num = get_card_num(cards[i],cards,flag)
	   		if c_num >= 3 then
	   			if value~=nil then
	   				if cards[i]>value then
	   					table.insert(get_cards,cards[i])
			   			table.insert(get_cards,cards[i])
			   			table.insert(get_cards,cards[i])
			   			flag = remove_same_card_flag(flag,cards,cards[i],3)
			   			return get_cards,flag
	   				end
	   			else
		   			table.insert(get_cards,cards[i])
		   			table.insert(get_cards,cards[i])
		   			table.insert(get_cards,cards[i])
		   			flag = remove_same_card_flag(flag,cards,cards[i],3)
		   			return get_cards,flag
		   		end
	   		end
		end
	end
	if #get_cards ~= 3 then
		return {},src_flag
	end
	return get_cards,flag
end

--得到三带一
function pdk_get_card.get_three_one( cards,flag,value )
	if not flag then
		return {}
	end
	local len = #cards
	
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
	local src_flag = flag
	local get_cards,flag = pdk_get_card.get_three( cards,flag,value )
	if #get_cards>0 then
		for i = 1,len,1 do
			if flag & 1<<(i-1) >0 then
				table.insert(get_cards,cards[i])
				flag = remove_flag(flag,i-1)
				return get_cards,flag 
			end
		end
	end
	if #get_cards~=4 then
		return {},src_flag
	end
	return get_cards,flag 
end

--得到三带二
function pdk_get_card.get_three_two( cards,flag,value )
	if not flag then
		return {}
	end
	local len = #cards
	
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
	local src_flag = flag
	local get_cards,flag = pdk_get_card.get_three( cards,flag,value )
	local getc = 0
	if #get_cards>0 then
		getc = get_cards[1]
	end
	local get_num = 0
	--先获取独立的单张
	if #get_cards >0 then
		for i = 1,len,1 do
			if flag & 1<<(i-1) >0 and getc~=cards[i] and   get_card_num(cards[i],cards,flag)==1 and  cards[i]<13 then
				table.insert(get_cards,cards[i])
				flag = remove_flag(flag,i-1)
				get_num = get_num+1
				if get_num >=2 then
					return get_cards,flag 
				end
			end
		end
	end
	if #get_cards >0 then
		for i = 1,len,1 do
			if flag & 1<<(i-1) >0 and getc~=cards[i] and get_num<2 then
				table.insert(get_cards,cards[i])
				flag = remove_flag(flag,i-1)
				get_num = get_num+1
				if get_num >=2 then
					return get_cards,flag 
				end
			end
		end
	end
	if #get_cards ~= 5 then
		return {},src_flag
	end
	return get_cards,flag 
end

--判断是否是连对
function pdk_get_card.isLianDui( cards )
	if #cards <4 then
		return false
	end
	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, cards[i])
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

--判断是否是连三张
function pdk_get_card.isLianThree(cards)
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

--得到连对
function pdk_get_card.get_double_join( cards,flag,join_num,value )
	if not flag then
		return {}
	end
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
	local src_flag = flag
	local get_doubles,flag = pdk_get_card.get_double(cards,flag,value)
	--print("get_doubles",get_doubles[1],get_doubles[2],value)
	local get_cards = {}
	local whilenum = 0
	while (#get_doubles == 2)
	do
		table.insert(get_cards, get_doubles[1])
		table.insert(get_cards, get_doubles[2])
		get_doubles,flag = pdk_get_card.get_double(cards,flag,value)
		--print("get_doubles",get_doubles[1],get_doubles[2],flag)
		whilenum = whilenum+1
		if whilenum > 500 then
			LOG_DEBUG("pdk_get_card.get_double_join ,whilenum:%d",whilenum)
			break
		end
	end
	--print("whilenum",whilenum)
	if #get_cards<join_num*2 then
		return {},src_flag
	end
	algorithm.sort(get_cards)
	for i=1,#get_cards/2,1 do
		if #get_cards-(i-1)*2<join_num*2 then
			return {},src_flag
		end
		local cacl_cards = {}
		for j = 1,join_num,1 do
			--print("get_doble_index",(i-1)*2+(j-1)*2+1,get_cards[(i-1)*2+(j-1)*2+1])
			table.insert(cacl_cards,get_cards[(i-1)*2+(j-1)*2+1])
			table.insert(cacl_cards,get_cards[(i-1)*2+(j-1)*2+1])
		end
		--判断是否是连续的
		local ok = pdk_get_card.isLianDui(cacl_cards)
		if ok and #cacl_cards==join_num*2 then
			flag = pdk_get_card.get_new_flag(cards,cacl_cards,src_flag)
			return cacl_cards,flag
		end
	end

	return {},src_flag
end

--得到连三张
function pdk_get_card.get_three_join( cards,flag,join_num,value )
	if not flag then
		return {}
	end
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
	local src_flag = flag
	local get_threes,flag = pdk_get_card.get_three(cards,flag,value)
	local get_cards = {}
	local whilenum = 0
	while (#get_threes == 3)
	do
		table.insert(get_cards, get_threes[1])
		table.insert(get_cards, get_threes[2])
		table.insert(get_cards, get_threes[3])
		get_threes,flag = pdk_get_card.get_three(cards,flag,value)

		whilenum = whilenum+1
		if whilenum > 500 then
			LOG_DEBUG("pdk_get_card.get_three_join ,whilenum:%d",whilenum)
			break
		end
	end
	if #get_cards<join_num*3 then
		return {},src_flag
	end
	algorithm.sort(get_cards)
	for i=1,#get_cards/3,1 do
		if #get_cards-(i-1)*3<join_num*3 then
			return {},src_flag
		end
		local cacl_cards = {}
		for j = 1,join_num,1 do
			table.insert(cacl_cards,get_cards[(i-1)*3+(j-1)*3+1])
			table.insert(cacl_cards,get_cards[(i-1)*3+(j-1)*3+1])
			table.insert(cacl_cards,get_cards[(i-1)*3+(j-1)*3+1])
		end
		--判断是否是连续的
		local ok = pdk_get_card.isLianThree(cacl_cards)
		if ok then
			flag = pdk_get_card.get_new_flag(cards,cacl_cards,src_flag)
			return cacl_cards,flag
		end
	end

	return {},src_flag
end

--得到飞机带翅膀
function pdk_get_card.get_three_wings( cards,flag,join_num,value )
	if not flag then
		return {},flag
	end
	local src_flag = flag
	local len = #cards
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end
	
	local get_cards,flag = pdk_get_card.get_three_join( cards,flag,join_num,value )
	--for i = 1,#get_cards ,1 do
		--print("get_three_wings get_cards",get_cards[i],flag)
	--end

	--取独立的单张优先

	local get_num = 0

	if #get_cards >0 then
		--挑选单牌
		for i = 1,#cards,1 do
			if flag & 1<<(i-1) >0 and get_card_num(cards[i],cards,flag)==1  then
				table.insert(get_cards,cards[i])
				flag = remove_flag(flag,i-1)
				get_num = get_num+1
				--print("get_three_wings",get_num,cards[i])
				if get_num >=join_num*2 then
					return get_cards,flag
				end
			end
		end--

	end

	if #get_cards >0 then
		--挑选单牌
		for i = 1,#cards,1 do
			if flag & 1<<(i-1) >0 and get_num<join_num*2 and get_card_num(cards[i],cards,flag)~=4  then
				table.insert(get_cards,cards[i])
				flag = remove_flag(flag,i-1)
				get_num = get_num+1
				--print("get_three_wings",get_num,cards[i])
				if get_num >=join_num*2 then
					return get_cards,flag
				end
			end
		end--

		for i = 1,#cards,1 do
			if flag & 1<<(i-1) >0 and get_num<join_num*2  then
				table.insert(get_cards,cards[i])
				flag = remove_flag(flag,i-1)
				get_num = get_num+1
				--print("get_three_wings",get_num,cards[i])
				if get_num >=join_num*2 then
					return get_cards,flag
				end
			end
		end--

	end

	return {},src_flag
end

--得到修正后的flag
function pdk_get_card.get_new_flag(cards,select_cards,flag )
	 if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
	    end
	end

	for i = 1,#select_cards,1 do
		for j=1,#cards,1 do
			if flag & 1<<(j-1) > 0 and cards[j] == select_cards[i] then
				flag = remove_flag(flag,j-1)
				break
			end
		end
	end
	return flag
end

--将点数转换成实际的牌
function pdk_get_card.get_source_cards( cs,cards )
	local ccards = {}
	for i=1,#cards,1 do
		ccards[i] = cards[i]
	end
	local get_cards = {}
	for i=1,#cs,1 do
		for j=1,#ccards,1 do
			if ccards[j]>0 and (cs[i] == pdk_cards.get_card_vale(ccards[j]) or cs[i] == pdk_cards.get_card_real_value(ccards[j])) then
				table.insert(get_cards,ccards[j])
				ccards[j] = 0
				break
			end
		end
	end
	return get_cards
end

--获取剩余的牌
function pdk_get_card.get_left_cards( cards,get_cards )
	local left_cards = {}
	for m,n in pairs(cards) do
		local b_find = false
		for i=1,#get_cards,1 do
			if n == get_cards[i] then
				b_find = true
				break
			end
		end
		if not b_find then
			table.insert(left_cards,n)
		end
	end
	return left_cards
end

--真实玩家托管
function pdk_get_card.get_first_out_cards_player(  )
	-- LOG_DEBUG('-----------------------pdk_get_card.get_first_out_cards_player--------------------')
	local cards = game_data.user_cards[game_data.curr_seatid]
	-- luadump(cards)
	local tc = {}
	for k, v in pairs(cards) do
		table.insert(tc, v)
	end
	-- luadump(tc)
	local tp, val = algorithm.get_card_type( tc )
	if tp > 0 then
		return tc
	end

	local cs = {}
	for i = 1,#cards,1 do
		table.insert(cs, pdk_cards.get_card_real_value(cards[i]))
	end

	algorithm.sort(cs)

	local get_cards = {}
    get_cards[1] = cs[1]
	get_cards = pdk_get_card.get_source_cards(get_cards,cards)
	-- luadump(get_cards)
	return get_cards
end

--排序
function pdk_get_card.sort_card_array( arrays )
	local other_card_type = {}
	for i = 1,game_data.max_player,1 do
		other_card_type[i] = {}
		pdk_select.get_all_card_type(arrays[i])
		other_card_type[i].bombs = table.deepcopy(pdk_select.bombs)
		other_card_type[i].single_joins = table.deepcopy(pdk_select.single_joins)
		other_card_type[i].three_join_twos = table.deepcopy(pdk_select.three_join_twos)
		other_card_type[i].three_joins = table.deepcopy(pdk_select.three_joins)
		other_card_type[i].double_joins = table.deepcopy(pdk_select.double_joins)
		other_card_type[i].doubles = table.deepcopy(pdk_select.doubles)
		other_card_type[i].singles = table.deepcopy(pdk_select.singles)
	end

	--炸弹多的放在前面
	local bombs_num = #other_card_type[1].bombs
	local b_change = false
	--print("1bomb num",bombs_num)
	for m = 1,game_data.max_player - 1,1 do
		for i = m+1,game_data.max_player,1 do
			if #other_card_type[i].bombs>bombs_num then
				local tb = arrays[m]
				arrays[m] = arrays[i]
				arrays[i] = tb
				bombs_num = #other_card_type[i].bombs
				b_change = true
				--print("bomb change")
			end
		end
	end
	if b_change then
		return
	end
	if bombs_num>0 then
		--单张少的放在前面
		local single_num = #other_card_type[1].singles
		for m = 1,game_data.max_player - 1,1 do
			for i = m+1,game_data.max_player,1 do
				if #other_card_type[i].singles<single_num and bombs_num == #other_card_type[i].bombs then
					local tb = arrays[m]
					arrays[m] = arrays[i]
					arrays[i] = tb
					single_num = #other_card_type[i].singles
				end
			end
		end
	end
	if bombs_num>0 then
		return
	end

	--单张少的放在前面
	local single_num = #other_card_type[1].singles
	for m = 1,game_data.max_player - 1,1 do
		for i = m+1,game_data.max_player,1 do
			if #other_card_type[i].singles<single_num then
				local tb = arrays[m]
				arrays[m] = arrays[i]
				arrays[i] = tb
				single_num = #other_card_type[i].singles
			end
		end
	end
end

local function getminknode(list)
	-- LOG_DEBUG('\n\ngetminknode--------------')
	-- luadump(list)
	local mink = 99999
	local minidx = 1
	local t
	for k, v in pairs(list) do
		t = pdk_cards.get_card_real_value(v[1])
		if (#v ~= 4 or algorithm.get_card_type(v) ~= 1) and t < mink then
			mink = t
			minidx = k
		end
	end
	return list[minidx]
end

local function enemynoboomchoose(cards, other_card_type)
	local top = {}
	
	local tnode

	local keys = {
		"single_joins",
		"doubles",
		"double_joins",
		"three_join_twos",
		"three_joins",
		"singles",
		"bombs",
	}
	
	local unmaxcnt = 0
	pdk_select.get_all_card_type(cards)
	local b_max = true
	for k, v in pairs(keys) do
		if #pdk_select[v] > 0 then
			b_max = true
			tnode = pdk_select[v][#pdk_select[v]]
			local max_value = tnode[1]
			for i = 1,game_data.max_player,1 do
				if other_card_type[i] and #other_card_type[i][v]>0 then
					local curr_value = other_card_type[i][v][#other_card_type[i][v]][1]
					if pdk_cards.get_card_real_value(curr_value)>pdk_cards.get_card_real_value(max_value) then
						unmaxcnt = unmaxcnt + 1
						b_max = false
						break
					end
				end
			end
			if b_max then
				table.insert(top, table.arraycopy(tnode, 1, #tnode))
				for k1, v1 in pairs(tnode) do
					for k2, v2 in pairs(cards) do
						if v1 == v2 then
							table.remove(cards, k2)
							break
						end
					end
				end
			end
		end
	end
	-- luadump(pdk_select)
	-- luadump(other_card_type)
	-- LOG_DEBUG('\n\n-------------enemynoboomchoose  unmaxcnt: %d', unmaxcnt)
	if unmaxcnt > 1 then
		local tp, val = algorithm.get_card_type(cards)
		if tp > 0 and #top > 0 then
			return getminknode(top)
		else
			return #top
		end
	end
	return getminknode(top)
end

function pdk_get_card.get_robot_first_out( )
	local get_cards = {}

	local other_card_type = {}
	local enemynoboom = true
	for i = 1,game_data.max_player,1 do
		if i~=game_data.curr_seatid then
			other_card_type[i] = {}
			pdk_select.get_all_card_type(game_data.user_cards[i])
			other_card_type[i].bombs = table.deepcopy(pdk_select.bombs)
			if other_card_type[i].bombs and next(other_card_type[i].bombs) then
				enemynoboom = false
			end
			other_card_type[i].single_joins = table.deepcopy(pdk_select.single_joins)
			other_card_type[i].three_join_twos = table.deepcopy(pdk_select.three_join_twos)
			other_card_type[i].three_joins = table.deepcopy(pdk_select.three_joins)
			other_card_type[i].double_joins = table.deepcopy(pdk_select.double_joins)
			other_card_type[i].doubles = table.deepcopy(pdk_select.doubles)
			other_card_type[i].singles = table.deepcopy(pdk_select.singles)
		end
	end
	local mycards = game_data.user_cards[game_data.curr_seatid]

	local result
	if enemynoboom and #mycards > 1 then --enemy no boom,
		result = enemynoboomchoose(table.arraycopy(mycards, 1, #mycards), other_card_type)
		if result and type(result) == 'table' and next(result) then
			return result
		end
	end
	if not result or result <= 0 then --一手打完
		local tcards = table.arraycopy(mycards, 1, #mycards)
		local tp, val = algorithm.get_card_type(tcards)
		if tp > 0 then
			return tcards
		end
	end 
	
	pdk_select.get_all_card_type(mycards)

	if #pdk_select.doubles>1 then
		local len = #pdk_select.doubles
		local max_value = pdk_select.doubles[len][1]
		local b_max = true
		for i = 1,game_data.max_player,1 do
			if other_card_type[i] and #other_card_type[i].doubles>0 then
				len = #other_card_type[i].doubles
				local curr_value = other_card_type[i].doubles[len][1]
				if pdk_cards.get_card_real_value(curr_value)>pdk_cards.get_card_real_value(max_value) then
					b_max = false
					break
				end
			end
		end
		if b_max then
			get_cards = table.arraycopy(pdk_select.doubles[1],1,#pdk_select.doubles[1])
			return get_cards
		end
	end

	--挑出最小的牌型
	local value = 255


	if #pdk_select.double_joins>0 then
		for i = 1,#pdk_select.double_joins,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.double_joins[i][1])
			if value > card_value then
				get_cards = table.arraycopy(pdk_select.double_joins[i],1,#pdk_select.double_joins[i])
				value = card_value
			end
		end
	end

	if #pdk_select.three_joins>0 then
		for i = 1,#pdk_select.three_joins,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.three_joins[i][1])
			if value > card_value then
				get_cards = table.arraycopy(pdk_select.three_joins[i],1,#pdk_select.three_joins[i])
				value = card_value
			end
		end
	end

	if #pdk_select.three_join_twos>0 then
		for i = 1,#pdk_select.three_join_twos,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.three_join_twos[i][1])
			if value > card_value then
				get_cards = table.arraycopy(pdk_select.three_join_twos[i],1,#pdk_select.three_join_twos[i])
				value = card_value
			end
		end
	end

	if #pdk_select.single_joins>0 then
		for i = 1,#pdk_select.single_joins,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.single_joins[i][1])
			get_cards = table.arraycopy(pdk_select.single_joins[i],1,#pdk_select.single_joins[i])
			--if value > card_value then
				--get_cards = table.arraycopy(pdk_select.single_joins[i],1,#pdk_select.single_joins[i])
				--value = card_value 
			--end
		end
		if #get_cards >0 then
			return get_cards
		end
	end

	if #pdk_select.doubles > 0 and #get_cards==0 then
		for i = 1,#pdk_select.doubles,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.doubles[i][1])
			if value > card_value then
				get_cards = table.arraycopy(pdk_select.doubles[i],1,#pdk_select.doubles[i])
				value = card_value
			end
		end
	end

	-- if enemynoboom then
	-- 	luadump(pdk_select.singles)
	-- 	if #pdk_select.singles>1 and #get_cards==0 then
	-- 		local len = #pdk_select.singles
	-- 		local max_value = pdk_select.singles[len][1]
	-- 		local b_max = true
	-- 		for i = 1,game_data.max_player,1 do
	-- 			if other_card_type[i] and #other_card_type[i].singles>0 then
	-- 				len = #other_card_type[i].singles
	-- 				--print('single',table.unpack(other_card_type[i].singles))
	-- 				local curr_value = other_card_type[i].singles[len][1]
	-- 				if pdk_cards.get_card_real_value(curr_value)>pdk_cards.get_card_real_value(max_value) then
	-- 					b_max = false
	-- 					break
	-- 				end
	-- 			end
	-- 		end
	-- 		if b_max then
	-- 			local to = table.arraycopy(pdk_select.singles[len],1,#pdk_select.singles[len])
	-- 			local tc = {}
	-- 			for k, v in pairs(mycards) do
	-- 				if v ~= to[1] then
	-- 					table.insert(tc, v)
	-- 				end
	-- 			end
	-- 			local tp, val = algorithm.get_card_type( tc )
	-- 			if tp > 0 then
	-- 				get_cards = to
	-- 			end
	-- 		end
	-- 	end
	-- end

	if #pdk_select.singles>0 and #get_cards==0 then
		for i = 1,#pdk_select.singles,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.singles[i][1])
			if value > card_value then
				get_cards = table.arraycopy(pdk_select.singles[i],1,#pdk_select.singles[i])
				value = card_value
			end
		end
	end

	if #pdk_select.bombs>0 and #get_cards==0 then
		for i = 1,#pdk_select.bombs,1 do
			local card_value = pdk_cards.get_card_real_value(pdk_select.bombs[i][1])
			if value > card_value then
				get_cards = table.arraycopy(pdk_select.bombs[i],1,#pdk_select.bombs[i])
				value = card_value
			end
		end
	end

	if #pdk_select.singles>1 and #get_cards==0 then
		local len = #pdk_select.singles
		local max_value = pdk_select.singles[len][1]
		local b_max = true
		for i = 1,game_data.max_player,1 do
			if other_card_type[i] and #other_card_type[i].singles>0 then
				len = #other_card_type[i].singles
				--print('single',table.unpack(other_card_type[i].singles))
				local curr_value = other_card_type[i].singles[len][1]
				if pdk_cards.get_card_real_value(curr_value)>pdk_cards.get_card_real_value(max_value) then
					b_max = false
					break
				end
			end
		end
		if b_max then
			get_cards = table.arraycopy(pdk_select.singles[1],1,#pdk_select.singles[1])
		end
	end

	--对方有单张
	local b_other_have_single = false
	for i = 1,#game_data.user_cards,1 do
		if #game_data.user_cards[i] == 1 and i~=game_data.curr_seatid then
			b_other_have_single = true
			break
		end
	end
	if b_other_have_single and #get_cards==1 then
		local single_num = #pdk_select.singles
		get_cards = pdk_select.singles[single_num]
	end


	if #get_cards == 0 then
		LOG_DEBUG("system error get_robot_first_out")
		return pdk_get_card.get_first_out_cards_player(  )
	end

	return get_cards
end

--得到首次打的牌型
function pdk_get_card.get_first_out_cards( )
	--当家玩家是否是机器人
	local isrobot = false
	if game_data.players[game_data.curr_seatid] then
		isrobot = game_data.players[game_data.curr_seatid].isrobot
	end
	if not isrobot then
		return pdk_get_card.get_first_out_cards_player(  )
	else return pdk_get_card.get_robot_first_out( )
	end
	
	--打飞机带翅膀
	local get_cards = pdk_get_card.get_card(algorithm.card_type.three_wings,1,game_data.user_cards[game_data.curr_seatid],2)

	if #get_cards>0 then
		return get_cards
	end

	--打炸弹
	get_cards = pdk_get_card.get_card(algorithm.card_type.zhadan,1,game_data.user_cards[game_data.curr_seatid],4)

	if #get_cards>0 then
		return get_cards
	end

	--三带二
	get_cards = pdk_get_card.get_card(algorithm.card_type.three_two,1,game_data.user_cards[game_data.curr_seatid],1)

	if #get_cards>0 then
		return get_cards
	end

	--顺子
	get_cards = pdk_get_card.get_card(algorithm.card_type.single_join,1,game_data.user_cards[game_data.curr_seatid],5)

	if #get_cards>0 then
		return get_cards
	end

	--连对
	get_cards = pdk_get_card.get_card(algorithm.card_type.double_join,1,game_data.user_cards[game_data.curr_seatid],2)

	if #get_cards>0 then
		return get_cards
	end

	--三带一
	if #game_data.user_cards[game_data.curr_seatid] == 4 then
		get_cards = pdk_get_card.get_card(algorithm.card_type.three_one,1,game_data.user_cards[game_data.curr_seatid],1)

		if #get_cards>0 then
			return get_cards
		end
	end

	--对子
	get_cards = pdk_get_card.get_card(algorithm.card_type.double,1,game_data.user_cards[game_data.curr_seatid],1)

	if #get_cards>0 then
		return get_cards
	end

	--单张
	get_cards = pdk_get_card.get_card(algorithm.card_type.single,1,game_data.user_cards[game_data.curr_seatid],1)

	if #get_cards>0 then
		return get_cards
	end

	return get_cards
end

function pdk_get_card.get_card( ctype,value,cards,last_len )
	if not cards then
		LOG_DEBUG("system error get_card")
		game_data.reset_value()
		game_data.game.kick_out_all()
		return
	end
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

    if ctype == algorithm.card_type.single then
    	for i =len,1,-1 do
    		if cs[i]> value then
    			local get_cards = {}
    			get_cards[1] = cs[i]
    			get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    			return get_cards
	    	end
    	end
    end

    if ctype == algorithm.card_type.double then
    	local get_cards = pdk_get_card.get_double(cs,flag,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype == algorithm.card_type.three then
    	local get_cards = pdk_get_card.get_three(cs,flag,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype == algorithm.card_type.zhadan then
    	local get_cards = pdk_get_card.get_zhadan(cs,flag,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype == algorithm.card_type.three_one then
    	local get_cards = pdk_get_card.get_three_one(cs,flag,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype == algorithm.card_type.three_two then
    	local get_cards = pdk_get_card.get_three_two(cs,flag,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype ==  algorithm.card_type.single_join then
    	local get_cards = pdk_get_card.get_shunzi(cs,last_len,flag,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype == algorithm.card_type.double_join then
    	local get_cards = pdk_get_card.get_double_join(cs,flag,last_len,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype ==  algorithm.card_type.three_join then
    	local get_cards = pdk_get_card.get_three_join(cs,flag,last_len,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    if ctype ==  algorithm.card_type.three_wings then
    	local get_cards = pdk_get_card.get_three_wings(cs,flag,last_len,value)
    	if #get_cards >0 then
    		get_cards = pdk_get_card.get_source_cards(get_cards,cards)
    	end
    	return get_cards
    end

    return {}
end

--根据牌型得到张数
function pdk_get_card.get_num_by_type( ctype,len )
	local get_num = len
	if ctype ==  algorithm.card_type.double_join then 
		get_num = len/2
	end

	if ctype ==  algorithm.card_type.three_join then
		get_num = len/3
	end

	if ctype ==  algorithm.card_type.three_wings then
		get_num = len/5
	end

	return get_num
end

function test_get(  )
	local get_cards = pdk_get_card.get_card(algorithm.card_type.single,5,{60,61},1)
	print("single",get_cards[1])

	get_cards = pdk_get_card.get_card(algorithm.card_type.double,5,{60,61,70,32},2)
	print("double",get_cards[1])

	get_cards = pdk_get_card.get_card(algorithm.card_type.three,5,{60,61,62,70,32},3)
	print("three",get_cards[1])

	get_cards = pdk_get_card.get_card(algorithm.card_type.zhadan,1,{60,61,62,70,11,12,13,33},3)
	print("zhadan",get_cards[1])

	get_cards = pdk_get_card.get_card(algorithm.card_type.three_one,5,{60,61,62,70,32,30,31,33},4)
	print("three_one",get_cards[1],get_cards[4])

	get_cards = pdk_get_card.get_card(algorithm.card_type.three_two,5,{60,61,62,63,75,30,31,81},5)
	print("three_two",get_cards[1],get_cards[5],get_cards[4])

	get_cards = pdk_get_card.get_card(algorithm.card_type.single_join,1,{11,20,130,121,111},5)
	print("single_join",get_cards[1],get_cards[5])

	get_cards = pdk_get_card.get_card(algorithm.card_type.double_join,1,{60,61,70,71},2)
	print("double_join",get_cards[1],get_cards[4])

	get_cards = pdk_get_card.get_card(algorithm.card_type.three_join,1,{60,61,62,70,32,30,31,33,41,52,71,72},2)
	print("three_join",get_cards[1],get_cards[6])

	get_cards = pdk_get_card.get_card(algorithm.card_type.three_wings,5,{90,91,92,93,100,101,102,103,41,52,71,72},2)
	print("three_wings",get_cards[1],get_cards[10],#get_cards)
end
--test_get(  )

function test_falg( ... )
	local cards = {}
	for i=1,10,1 do
		cards[i]=1
	end
	local len = #cards
	local flag = 0
    if flag == 0 then
	    for i =1,len,1 do
	        local num = 1<<(i-1)
			flag = flag|num
			print(flag)
	    end
	end

	for i = 10,1,-1 do
		flag = remove_flag(flag,i-1)
		print(flag)
	end
end

return pdk_get_card