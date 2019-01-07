local skynet = require "skynet"
local datacenter = require "datacenter"
local _gc_reason = require "gold_change_reason"

-- local _dbs_config = require 'dbs_config'

game_start = {}
local players
local _redispool

local function gamelog(msg, cards)
	local str = ''
	if cards and type(cards) == 'table' and next(cards) then
		for i = 1, #cards do
			str = string.format('%s %d', str, cards[i])
		end
	end

	LOG_DEBUG('tableid:%d %s', skynet.self(), msg..str)
end

local function checkxplayer(pls)
	-- LOG_DEBUG('-----------------checkxplayer')
	-- luadump(pls)
	if not _redispool then
		_redispool = skynet.uniqueservice("redispool")
	end
	if not _redispool then
		LOG_DEBUG('_redispool init failed!')
		return
	end
	for k, v in pairs(pls) do
		local ok, val = pcall(skynet.call, _redispool, "lua", "execute", "hget", 'rqxplayer', v.uid)
		-- LOG_DEBUG('ok: %s val:%s', tostring(ok), tostring(val))
		if ok and val then
			val = tonumber(val)
			if val and val ~= 0 then
				-- LOG_DEBUG('rkxplayer: %d           val: %d     seatid : %d', v.uid, val, k)
				if val > 0 then
					pcall(skynet.call, _redispool, "lua", "execute", "hset", 'rqxplayer', v.uid, val - 1)
				else
					pcall(skynet.call, _redispool, "lua", "execute", "hset", 'rqxplayer', v.uid, val + 1)
				end
				return k, val
			end
		end
	end
end

--设置桌子用户
function game_start.set_players(p)
	players = p
end

function game_start.set_send_msg( func )
	game_start.send_msg = func
end

local function is_bomb( card,cards )
	local num = 0
	for m,n in pairs(cards) do
	 	if pdk_cards.get_card_real_value(card) == pdk_cards.get_card_real_value(n) then
	 		num = num + 1
	 	end
    end
    if num == 4 then
    	return true
    end
    if num == 3 and pdk_cards.get_card_real_value(card) == 14 then
    	return true
    end
    return false
end

local is_system_out_error = false
--自动打牌
function game_start.auto_out_card( )
	if game_data.game_start ==false then
		return
	end

	if game_data.curr_seatid == 0 then
		LOG_DEBUG("game_data.curr_seatid is %d",game_data.curr_seatid)
		return 
	end

	--计算数量
	local last_num = #game_data.last_out_cards
	last_num = pdk_get_card.get_num_by_type(game_data.last_out_type,last_num)
	local get_cards = {}
	if game_data.curr_seatid ~= game_data.last_out_seatid and #game_data.last_out_cards > 0 then
		if #get_cards==0 then
			get_cards = pdk_get_card.get_card(game_data.last_out_type,game_data.last_out_value,game_data.user_cards[ game_data.curr_seatid],last_num)
			--判断是否拆了炸弹
			if #get_cards > 0 and game_data.last_out_type ~= algorithm.card_type.zhadan then
				for k = 1,#get_cards,1 do
					if is_bomb(get_cards[k],game_data.user_cards[ game_data.curr_seatid]) then
						get_cards = {}
						break
					end
				end
			end
		end
		if #get_cards==0 and game_data.last_out_type ~= algorithm.card_type.zhadan then
			get_cards = pdk_get_card.get_card(algorithm.card_type.zhadan,1,game_data.user_cards[game_data.curr_seatid],last_num)
		end

		-- if #get_cards == 0 then
		-- 	--判断上次打的是否是三带二并且自己是最后一手牌，能否打出三带一
		-- 	if game_data.last_out_type == algorithm.card_type.three_two and #game_data.user_cards[game_data.curr_seatid] == 4 then
		-- 		get_cards = pdk_get_card.get_card(algorithm.card_type.three_one,game_data.last_out_value,game_data.user_cards[game_data.curr_seatid],1)
		-- 	end
		-- end
	else
		get_cards = pdk_get_card.get_first_out_cards( )--pdk_get_card.get_card(algorithm.card_type.single,1,game_data.user_cards[ game_data.curr_seatid],1)

	end
	local seatid = game_data.curr_seatid
	local msg = {}
	msg.card = get_cards
	if is_system_out_error then
 		msg.card = {}
 		LOG_DEBUG("system_out_error")
 		game_start.pass_out_card(  )
 		return
 	end
 	game_start.out_card(seatid,msg,true)

end

local function get_next_seat( seatid )
	local next_user = seatid+1
	if next_user>#players then
		next_user = 1
	end
	return next_user
end

local function update_boom_score(cursid)
	if not cursid then return end
	local p = players[cursid]
	if not p then return end
	local bc = {}
	if game_data.max_player == 2 then
		local p2 = players[2 - cursid + 1]
		if not p2 then return end
		if game_data.game.get_room_type() == 'diamond' then
			local subdiamond = pdk_define.bomb_score / 2
			if subdiamond > p2.diamond then
				subdiamond = p2.diamond
			end
			bc[cursid] = subdiamond
			bc[2 - cursid + 1] = -subdiamond
			p.diamond = game_data.game.update_freeze_diamond(p, subdiamond, _gc_reason.RunquickBoom)
			p2.diamond = game_data.game.update_freeze_diamond(p2, -subdiamond, _gc_reason.RunquickBoom)
		else
			local subgold = pdk_define.bomb_score / 2
			if not game_data.allownegtive and subgold > p2.gold then
				subgold = p2.gold
			end

			bc[cursid] = subgold
			bc[2 - cursid + 1] = -subgold

			if game_data.isMatch then
				p.gold = p.gold + subgold
				p2.gold = p2.gold - subgold
			else
				p.gold = game_data.game.update_freeze_gold(p, subgold, nil, _gc_reason.RunquickBoom)
				p2.gold = game_data.game.update_freeze_gold(p2, -subgold, nil, _gc_reason.RunquickBoom) or 0
			end
		end
	elseif game_data.max_player == 3 then
		if game_data.game.get_room_type() == 'diamond' then
			local getscore = 0
			local tmp
			for i = 1, game_data.max_player do
				if i ~= cursid then
					tmp = pdk_define.bomb_score / 2
					if players[i].diamond < tmp then
						tmp = players[i].diamond
					end
					players[i].diamond = game_data.game.update_freeze_diamond(players[i], -tmp, _gc_reason.RunquickBoom)
					getscore = getscore + tmp
					bc[i] = -tmp
				end
			end
			bc[cursid] = getscore
			p.diamond = game_data.game.update_freeze_diamond(p, getscore, pdk_define.bomb_score)
		else
			local getscore = 0
			local tmp
			for i = 1, game_data.max_player do
				if i ~= cursid then
					tmp = pdk_define.bomb_score / 2
					if players[i].gold < tmp then
						tmp = players[i].gold
					end
					players[i].gold = game_data.game.update_freeze_gold(players[i], -tmp, nil, _gc_reason.RunquickBoom)
					getscore = getscore + tmp
					bc[i] = -tmp
				end
			end
			p.gold = game_data.game.update_freeze_gold(p, getscore, nil, pdk_define.bomb_score)
		end
	end

	return bc
end

--pass
function game_start.pass_out_card(  )
	game_data.curr_seatid = get_next_seat(game_data.curr_seatid)
	local respone = {}
	respone.session = 1
	respone.seatid = seatid
	respone.curr_seatid = game_data.curr_seatid
	respone.card = {}
	respone.code = 0
	respone.left_card = #game_data.user_cards[seatid]
	respone.last_out_seatid = game_data.last_out_seatid
	respone.last_out_cards = {}
	respone.bomb_get_gold = 0
	for i=1,#game_data.last_out_cards,1 do
		table.insert(respone.last_out_cards,game_data.last_out_cards[i])
	end
	
	--判断是否炸弹大
	if game_data.last_out_seatid == game_data.curr_seatid and game_data.last_out_type == algorithm.card_type.zhadan then
		game_data.user_out_bomb[game_data.curr_seatid] = game_data.user_out_bomb[game_data.curr_seatid] or 0
		game_data.user_out_bomb[game_data.curr_seatid] = game_data.user_out_bomb[game_data.curr_seatid] + 1
		respone.bomb_get_gold = pdk_define.bomb_score
		respone.bomb_change_gold = update_boom_score(game_data.curr_seatid)
		respone.bomb_get_gold = pdk_define.bomb_score
	end
	game_start.send_msg(0,"game.STCGPdkOutCard",respone)

	if not is_system and game_data.is_deposit[game_data.seatid] then
		game_data.is_deposit[game_data.seatid] = nil
	end
	if game_data.is_deposit[game_data.curr_seatid] == 1 then
		--skynet.fork(game_start.auto_out_card( ))
	end
	--设置打牌超时回调
	Events:DelEventById(pdk_cards.const_vars.out_card)
	Events:AddEvent(pdk_cards.const_vars.out_card,15,out_card_time_out,1)
end

--打牌超时
function out_card_time_out( id,data )
	if game_data.game_start ==false then
		return
	end
	-- body
	LOG_DEBUG("out_card_time_out:%d",id)

	game_data.is_deposit[game_data.curr_seatid] = 1

	local response = {}
	response.session = 1
	response.optype = 1
	response.seatid = game_data.curr_seatid
	response.params = {}
	game_data.sent_msg(0,"game.OperateRep",response)
	game_start.auto_out_card( )
end

function game_start.usertrust(seatid)
	local p = players[seatid]
	if p and not p.isrobot and game_data.is_deposit[game_data.curr_seatid] == 1 and game_data.curr_seatid == seatid then
		Events:DelEventById(pdk_cards.const_vars.out_card)
		out_card_time_out(0)
	end	
end

--准备
function game_start.ready(seatid)
	local p = players[seatid]
	--判断用户是否存在
	if p == nil then
		LOG_DEBUG("ready player is not exsit:%d",seatid)
		return
	end

	p.ready = true

	if p.isrobot then
		local msg = {}
		msg.session = 1
		msg.seat_id = seatid
		game_start.send_msg(seatid,"game.STCGPdkReady",msg)
	end

	--判断是否都准备了
	for m,n in pairs(players) do
		if n.ready ~= true then
			return
		end
	end

	--判断是否三个人都准备了
	if #players <game_data.max_player then
		return
	end

	--游戏开始
	if not pcall(game_start.start_game) then
		game_data.game.kick_out_all()
	end
end

function game_start.is_can_greater_card(  )
	local is_must_out = true
	
	--计算数量
	local last_num = #game_data.last_out_cards
	if #game_data.last_out_cards == 0 or game_data.last_out_seatid == game_data.curr_seatid then
		return true
	end
	last_num = pdk_get_card.get_num_by_type(game_data.last_out_type,last_num)
	--判断是否能压，能压不能过
	local get_cards = pdk_get_card.get_card(game_data.last_out_type,game_data.last_out_value,game_data.user_cards[game_data.curr_seatid],last_num)
	if #get_cards>0 and is_must_out then
		return true
	end

	if game_data.last_out_type ~= algorithm.card_type.zhadan then
		get_cards = pdk_get_card.get_card(algorithm.card_type.zhadan,1,game_data.user_cards[game_data.curr_seatid],last_num)
		if #get_cards>0 and is_must_out then
			return true
		end

		--判断上次打的是否是三带二并且自己是最后一手牌，能否打出三带一
		-- if game_data.last_out_type == algorithm.card_type.three_two and #game_data.user_cards[game_data.curr_seatid] == 4 then
		-- 	get_cards = pdk_get_card.get_card(algorithm.card_type.three_one,game_data.last_out_value,game_data.user_cards[game_data.curr_seatid],1)
		-- 	if #get_cards>0 and is_must_out then
		-- 		return true
		-- 	end
		-- end
	end

	return false
end

function game_start.start_game( )
	LOG_DEBUG("game_start.start_game")
	game_start.reset_value(  )
	game_data.game_start = true
	game_data.game.gameStart()
	game_data.check_card_holder()
	local cards = {}
	for m,n in pairs(pdk_cards.cardids) do
		table.insert(cards,n)
	end

	local is_new_user = false
	if game_data.game.get_room_type() ~= 'diamond' and game_data.game.get_room_speci() == 0 then
		for i=1,#players,1 do
			if not players[i].isrobot and game_data.check_isnot_win(i)  then
				is_new_user = true
				game_data.curr_new_user = i
				local game_num_str = string.format("game_num_%d",players[i].uid)
				local game_num = datacenter.get(game_num_str)
				if game_num then
					if game_num>=10 then
						is_new_user = false
						game_data.curr_new_user = 0
					end
				end
				break
			end
		end
	end

	local after_cards = pdk_cards.shuffle(cards,game_data.roomid,is_new_user)

	game_data.user_cards = {}
	if #after_cards == 0 and game_data.game.get_room_type( ) == 'diamond' then
		for i=1,#players,1 do
			after_cards[i] = {}
			for k=1,16,1 do
				local card = table.remove(cards,1)
				table.insert(after_cards[i],card)
			end
		end
	end
	if #after_cards == 0 then
		for i=1,#players,1 do
			game_data.user_cards[i] = {}
			for k=1,16,1 do
				local card = table.remove(cards,1)
				table.insert(game_data.user_cards[i],card)
			end
		end
	else
		local hasrobot
		for i=1,#players,1 do
			if players[i] and players[i].isrobot then
				hasrobot = true
				break
			end
		end

		local xseatid, xval = checkxplayer(players)
		-- runquikc = _dbs_config.runquikc
		local sortpercent = 0
		if xseatid and xval then
			sortpercent = 100
		elseif hasrobot then
			local ok, val = pcall(skynet.call, _redispool, "lua", "execute", "hget", 'roombetterpercent', game_data.roomid)
			if not ok or not val then
				sortpercent = 70
			else
				sortpercent = tonumber(val)
			end
			-- sortpercent = runquikc[game_data.roomid] or 70
		end
		if game_data.isMatch then
			sortpercent = 50
		end
		-- LOG_DEBUG('------------------------sortpercent: %d', sortpercent)
		local rand_give = math.random(1, 100)
		if rand_give<=sortpercent then
			pdk_get_card.sort_card_array(after_cards)
		end
		-- luadump(after_cards)
		local give_index = 1
		if is_new_user then
			--先给新手牌
			for i=1,#players,1 do
				if i == game_data.curr_new_user then
					game_data.user_cards[i] = {}
					table.mergeByAppend(game_data.user_cards[i],after_cards[give_index])
					give_index = give_index + 1
					break
				end
			end
		else
			if xseatid then
				if xval and xval > 0 then
					game_data.user_cards[xseatid] = {}
					table.mergeByAppend(game_data.user_cards[xseatid],after_cards[give_index])
					give_index = give_index + 1
				elseif xval and xval < 0 then
					game_data.user_cards[xseatid] = {}
					table.mergeByAppend(game_data.user_cards[xseatid],after_cards[game_data.max_player])
					-- give_index = give_index + 1
				end
			end
			--先给机器人牌
			for i=1,#players,1 do
				if game_data.players[i] and game_data.players[i].isrobot then
					game_data.user_cards[i] = {}
					table.mergeByAppend(game_data.user_cards[i],after_cards[give_index])
					give_index = give_index + 1
					break
				end
			end
		end

		for i=1,#players,1 do
			if not game_data.user_cards[i] then
				game_data.user_cards[i] = {}
				table.mergeByAppend(game_data.user_cards[i],after_cards[give_index])
				give_index = give_index + 1
			end

			if players[i] and players[i].uid then
				pcall(gamelog, string.format('uid: %d send cards: ', players[i].uid), game_data.user_cards[i])
			end
		end
	end
	-- luadump(game_data.user_cards)
	game_data.curr_seatid = 0
	for i=1,#players do
		for k = 1,#game_data.user_cards[i] do
			if game_data.user_cards[i][k] == 33 then
				game_data.curr_seatid = i
				game_data.first_out_seatid = i
				--print(game_data.user_cards[i][k])
				break
			end
		end
		if game_data.curr_seatid ~= 0 then
			break
		end
	end

	if game_data.curr_seatid == 0 then
		--LOG_DEBUG("system error 222222222222222")
		if xseatid then
			if xval and xval > 0 then
				game_data.curr_seatid = xseatid
			else
				for i = 1, i < game_data.max_player do
					if i ~= xseatid then
						game_data.curr_seatid = i
						break
					end
				end
			end
		else
			game_data.curr_seatid = math.random(1,100000)%2+1
		end
		game_data.first_out_seatid = game_data.curr_seatid
		--return
	end

	--[[game_data.user_cards[1] = {11,12,93,133,123,113,103,83,
	40,41,42,73,
	50,51,52,33}
	game_data.user_cards[2] = {60,61,62,63,
	70,71,72,43,
	80,81,82,53,
	90,91,92,13}
	game_data.user_cards[3] = {100,101,102,32,
	110,111,112,31,
	120,121,122,30,
	130,131,132,20}]]--
	game_data.game.start_game()--nil,table_fee
	--发牌
	for i=1,#players,1 do
		game_data.players[i].ingame = true
		local msg = {}
		msg.session = 1
		msg.curr_seatid = game_data.curr_seatid
		msg.gold = tostring(players[i].gold)
		msg.time = 20
		msg.cards = {}
		for k=1,16,1 do
			--print(game_data.user_cards[i][k])
			table.insert(msg.cards,game_data.user_cards[i][k])
		end
		--print("game.STCGPdkGiveCards",game_data.curr_seatid,msg.time,msg.gold)
		game_start.send_msg(i,"game.STCGPdkGiveCards",msg)
		game_data.give_card_holder()
	end
	local table_fee = 4
	if #players == 2 then
		table_fee = 6
	end
	
	--设置打牌超时回调
	Events:DelEventById(pdk_cards.const_vars.out_card)
	Events:AddEvent(pdk_cards.const_vars.out_card,21,out_card_time_out,1)
end

--出牌出错
local function out_card_error( seatid,reasion )
	print("out_card_error",seatid,game_data.curr_seatid,reasion)
	local respone = {}
	respone.session = 1
	respone.left_card = #game_data.user_cards[seatid]
	respone.last_out_seatid = game_data.last_out_seatid
	respone.seatid = seatid
	respone.curr_seatid = game_data.curr_seatid
	respone.card = {}
	respone.code = reasion
	respone.last_out_cards = {}
	for i=1,#game_data.last_out_cards,1 do
		table.insert(respone.last_out_cards,game_data.last_out_cards[i])
	end
	game_start.send_msg(seatid,"game.STCGPdkOutCard",respone)
end

local function outcardsdebuglog(is_system, seatid, cards)
	gamelog(string.format('is_system : %s uid:%d send error cards:  ', tostring(is_system), players[seatid].uid), cards)
	gamelog('left cards:  ', game_data.user_cards[seatid])
	gamelog('last cards:  ', game_data.last_out_cards)
end

local last_auto_time = 0
--出牌
function game_start.out_card(seatid,msg,is_system)
	if game_data.game_start ==false then
		return
	end
	local p = players[seatid]
	--判断用户是否存在
	if p == nil then
		LOG_DEBUG("ready player is not exsit:%d",seatid)
		return
	end

	--判断是否是该玩家出牌
	if seatid~=game_data.curr_seatid then
		LOG_DEBUG("out_card is not curr_user:%d,%d",seatid,game_data.curr_seatid)
		return
	end

	if (not msg.card or  #msg.card == 0) and seatid == game_data.last_out_seatid then
		LOG_DEBUG("out_card msg.card is nil")
		return
	end

	--判断是否过,轮到自己是最后一次打牌的不能过
	if (msg.card == nil or #msg.card == 0) and seatid ~= game_data.last_out_seatid and  #game_data.last_out_cards ~= 0 then

		local is_must_out = true
		-- if #players == 2 then
		-- 	is_must_out = false
		-- end
		--计算数量
		local last_num = #game_data.last_out_cards
		last_num = pdk_get_card.get_num_by_type(game_data.last_out_type,last_num)
		--判断是否能压，能压不能过
		local get_cards = pdk_get_card.get_card(game_data.last_out_type,game_data.last_out_value,game_data.user_cards[game_data.curr_seatid],last_num)
		if #get_cards>0 and is_must_out then
			out_card_error(seatid,1)
			LOG_DEBUG("out_card can out is not allow pass :%d,%d",game_data.last_out_type,#get_cards)
			return
		end

		if game_data.last_out_type ~= algorithm.card_type.zhadan then
			get_cards = pdk_get_card.get_card(algorithm.card_type.zhadan,1,game_data.user_cards[game_data.curr_seatid],last_num)
			if #get_cards>0 and is_must_out then
				out_card_error(seatid,1)
				LOG_DEBUG("out_card can out zhadan is not allow pass :%d,%d",game_data.last_out_type,#get_cards)
				return
			end

			--判断上次打的是否是三带二并且自己是最后一手牌，能否打出三带一
			-- if game_data.last_out_type == algorithm.card_type.three_two and #game_data.user_cards[game_data.curr_seatid] == 4 then
			-- 	get_cards = pdk_get_card.get_card(algorithm.card_type.three_one,game_data.last_out_value,game_data.user_cards[game_data.curr_seatid],1)
			-- 	if #get_cards>0 and is_must_out then
			-- 		out_card_error(seatid,1)
			-- 		LOG_DEBUG("out_card can out three_one is not allow pass :%d,%d",game_data.last_out_type,#get_cards)
			-- 		return
			-- 	end
			-- end
		end

		game_data.curr_seatid = get_next_seat(game_data.curr_seatid)
		local respone = {}
		respone.session = 1
		respone.seatid = seatid
		respone.curr_seatid = game_data.curr_seatid
		respone.card = {}
		respone.code = 0
		respone.left_card = #game_data.user_cards[seatid]
		respone.last_out_seatid = game_data.last_out_seatid
		respone.last_out_cards = {}
		respone.bomb_get_gold = 0
		for i=1,#game_data.last_out_cards,1 do
			table.insert(respone.last_out_cards,game_data.last_out_cards[i])
		end
		
		last_auto_time = 0
		--判断是否炸弹大
		if game_data.last_out_seatid == game_data.curr_seatid and game_data.last_out_type == algorithm.card_type.zhadan then
			game_data.user_out_bomb[game_data.curr_seatid] = game_data.user_out_bomb[game_data.curr_seatid] or 0
			game_data.user_out_bomb[game_data.curr_seatid] = game_data.user_out_bomb[game_data.curr_seatid] +1
			respone.bomb_change_gold = update_boom_score(game_data.curr_seatid)
			respone.bomb_get_gold = pdk_define.bomb_score
		end
		game_start.send_msg(0,"game.STCGPdkOutCard",respone)

		if not is_system and game_data.is_deposit[game_data.seatid] then
			game_data.is_deposit[game_data.seatid] = nil
		end
		if game_data.is_deposit[game_data.curr_seatid] == 1 then
			--skynet.fork(game_start.auto_out_card( ))
		end
		--设置打牌超时回调
		Events:DelEventById(pdk_cards.const_vars.out_card)
		Events:AddEvent(pdk_cards.const_vars.out_card,15,out_card_time_out,1)
		return
	end
	if not msg.card then return end
	--判断玩家手上是否有出的牌
	if msg.card and next(msg.card) then
		for m,n in pairs(msg.card) do
			local bfind =false
			for a,b in pairs(game_data.user_cards[seatid]) do
				if n == b then
					bfind = true
					break
				end
			end --
			if bfind == false then
				LOG_DEBUG("out_card is not card:%d,%d",seatid,n)
				for h=1,#game_data.user_cards[seatid],1 do
					LOG_DEBUG("out_card is not card cards:%d,%d",seatid,game_data.user_cards[seatid][h])
				end
				return
			end
		end
	end

	-- local is_last_out  = false
	-- --判断是否是最后一手牌
	-- if msg.card and #msg.card == #game_data.user_cards[seatid] then
	-- 	is_last_out = true
	-- end

	-- --不是最后一手牌不能出三带一
	-- if is_last_out == false and algorithm.get_card_type(msg.card) == algorithm.card_type.three_one then
	-- 	LOG_DEBUG("out_card is not last out three_one :%d",seatid)
	-- 	out_card_error(seatid,1)
	-- 	return
	-- end

	--判断是否是第一次出牌
	if #game_data.last_out_cards == 0 or game_data.last_out_seatid == game_data.curr_seatid then
		
		local type_curr,type_value = algorithm.get_card_type(msg.card)
		if type_curr == 0 then
			LOG_DEBUG("out_card is error type :%d",seatid)
			pcall(outcardsdebuglog, is_system, seatid, msg.card)
			-- pcall(gamelog, string.format('is_system : %s uid:%d send error type cards:  ', tostring(is_system), players[seatid].uid), msg.card)
			-- pcall(gamelog, 'left cards:  ', game_data.user_cards[seatid])
			-- pcall(gamelog, 'last cards:  ', game_data.last_out_cards)
			out_card_error(seatid,1)
			return
		end
		game_data.last_out_type = type_curr
		game_data.last_out_value =type_value

	else
		--计算牌型
		local type_last,last_value = algorithm.get_card_type(game_data.last_out_cards)
		local type_curr,type_value = algorithm.get_card_type(msg.card)
		if type_curr == algorithm.card_type.zhadan then
			if type_last == algorithm.card_type.zhadan then
				if last_value>=type_value then
					LOG_DEBUG("out_card zhadan is letter last:%d,%d_%d",seatid,last_value,type_value)
					
					if is_system then
						is_system_out_error = true
					end
					pcall(outcardsdebuglog, is_system, seatid, msg.card)
					-- pcall(gamelog, string.format('is_system: %s  uid:%d put letter boom cards:  ', tostring(is_system), players[seatid].uid), msg.card)
					-- pcall(gamelog, 'left cards:  ', game_data.user_cards[seatid])
					-- pcall(gamelog, 'last cards:  ', game_data.last_out_cards)
					out_card_error(seatid,1,msg.card)
					return
				end
			end
		else
			if msg.card and #game_data.last_out_cards~=#msg.card then-- and type_curr ~=algorithm.card_type.three_one then
				LOG_DEBUG("out_card num not same:%d",seatid)
				for k = 1,#msg.card,1 do
					LOG_DEBUG("out_card num not same card :%d,%d",msg.card[k],#msg.card)
				end
				if is_system then
					is_system_out_error = true
				end
				pcall(outcardsdebuglog, is_system, seatid, msg.card)
				-- pcall(gamelog, string.format('is_system: %s uid:%d put not same count cards:  ', tostring(is_system), players[seatid].uid), msg.card)
				-- pcall(gamelog, 'left cards:  ', game_data.user_cards[seatid])
				-- pcall(gamelog, 'last cards:  ', game_data.last_out_cards)
				out_card_error(seatid,1,msg.card)
				return
			end

			if type_last~=type_curr then--and type_curr ~=algorithm.card_type.three_one then
				LOG_DEBUG("out_card type not same:%d,%d",type_last,type_curr)

				out_card_error(seatid,1)
				if is_system then
					is_system_out_error = true
				end
				pcall(outcardsdebuglog, is_system, seatid, msg.card)
				-- pcall(gamelog, string.format('is_system: %s uid:%d put not same type cards:  ', tostring(is_system), players[seatid].uid), msg.card)
				-- pcall(gamelog, 'left cards:  ', game_data.user_cards[seatid])
				-- pcall(gamelog, 'last cards:  ', game_data.last_out_cards)

				return
			end

			--三带一可以压三带二
			-- if type_curr == algorithm.card_type.three_one then
			-- 	if type_last ~= algorithm.card_type.three_one and type_last ~= algorithm.card_type.three_two then
			-- 		LOG_DEBUG("out_three one card type not same:%d",type_last)
			-- 		out_card_error(seatid,1)
			-- 		if is_system then
			-- 			is_system_out_error = true
			-- 		end
			-- 		return
			-- 	end
			-- end

			if type_last == algorithm.card_type.single_join then -- 顺子比较最后一张
				--print("out card",last_value,type_value)
				if last_value>=type_value then
					LOG_DEBUG("out_card type is letter last:%d,%d_%d",seatid,last_value,type_value)
					out_card_error(seatid,1)
					if is_system then
						is_system_out_error = true
					end
					pcall(outcardsdebuglog, is_system, seatid, msg.card)
					-- pcall(gamelog, string.format('is_system: %s uid:%d put same type equal last. cards:  ', tostring(is_system), players[seatid].uid), msg.card)
					-- pcall(gamelog, 'left cards:  ', game_data.user_cards[seatid])
					-- pcall(gamelog, 'last cards:  ', game_data.last_out_cards)
					return
				end
			else
				--print("out card",last_value,type_value)
				if last_value>=type_value then
					LOG_DEBUG("out_card type1 is letter last:%d,%d_%d",seatid,last_value,type_value)
					out_card_error(seatid,1)
					if is_system then
						is_system_out_error = true
					end
					pcall(outcardsdebuglog, is_system, seatid, msg.card)
					-- pcall(gamelog, string.format('is_system: %s uid:%d put same type letter last. cards:  ', tostring(is_system), players[seatid].uid), msg.card)
					-- pcall(gamelog, 'left cards:  ', game_data.user_cards[seatid])
					-- pcall(gamelog, 'last cards:  ', game_data.last_out_cards)
					return
				end
			end

			-- if type_curr == algorithm.card_type.three_one then
			-- 	if type_last ~= algorithm.card_type.three_one and type_last~=algorithm.card_type.three_two then
			-- 		LOG_DEBUG("out_card three_one not same:%d",seatid)
			-- 		out_card_error(seatid,1)
			-- 		if is_system then
			-- 			is_system_out_error = true
			-- 		end
			-- 		return
			-- 	end
			-- end
		end

		game_data.last_out_type = type_curr
		game_data.last_out_value =type_value
	end


	is_system_out_error = false
	--去掉打出的牌
	for m,n in pairs(msg.card) do
		for i=1,#game_data.user_cards[seatid],1 do
			if n == game_data.user_cards[seatid][i] then
				table.remove(game_data.user_cards[seatid],i)
				break
			end
		end
	end

	local last_p = players[game_data.last_out_seatid]
	if last_p and last_p.isrobot then
		local a = game_data.last_out_seatid
		local b = game_data.curr_seatid
		local rand_t = math.random(1,3)
		
		skynet.timeout(100*rand_t, function ( ... )
			game_start.send_face(a,b)
		end)--game_start.send_face(game_data.last_out_seatid,game_data.curr_seatid)
	end

	pcall(gamelog, string.format('uid:%d out cards:  ', players[seatid].uid), msg.card)
	game_data.last_out_seatid = game_data.curr_seatid

	game_data.curr_seatid = get_next_seat(game_data.curr_seatid)
	local respone = {}
	respone.session = 1
	respone.seatid = seatid
	respone.curr_seatid = game_data.curr_seatid
	respone.card = {}
	for m,n in ipairs(msg.card) do
		table.insert(respone.card,n)
	end
	respone.code = 0
	respone.left_card = #game_data.user_cards[seatid]
	respone.last_out_seatid = game_data.last_out_seatid
	respone.last_out_cards = {}
	respone.bomb_get_gold = 0
	for i=1,#game_data.last_out_cards,1 do
		table.insert(respone.last_out_cards,game_data.last_out_cards[i])
	end

	last_auto_time = 0

	game_data.last_out_cards = {}
	--保存上一次打的牌
	for m,n in pairs(msg.card) do
		table.insert(game_data.last_out_cards,n)
	end

	if game_data.is_first_out then
		game_data.is_first_out = false
	else
		game_data.is_outcard[seatid] = 1
	end

	--发送记牌器数据
	game_data.give_card_holder(seatid)
	if game_data.last_out_type == algorithm.card_type.zhadan then
		--判断是否是a
		if #game_data.last_out_cards>0 and pdk_cards.get_card_vale(game_data.last_out_cards[1]) == 1 then
			game_data.is_out_a_zha = seatid
		end
	end

	if #game_data.user_cards[seatid] == 0 then --游戏结束
		--判断是否炸弹大
		if game_data.last_out_type == algorithm.card_type.zhadan then
			game_data.user_out_bomb[seatid] = game_data.user_out_bomb[seatid] or 0
			game_data.user_out_bomb[seatid] = game_data.user_out_bomb[seatid] + 1
			respone.bomb_change_gold = update_boom_score(seatid)
			respone.bomb_get_gold = pdk_define.bomb_score
		end
		game_start.send_msg(0,"game.STCGPdkOutCard",respone)
		game_end.end_game(seatid)
	else
		game_start.send_msg(0,"game.STCGPdkOutCard",respone)
		if game_data.is_deposit[game_data.curr_seatid] == 1 then
			--skynet.fork(game_start.auto_out_card( ))
		else
			if not is_system and game_data.is_deposit[game_data.curr_seatid] then
				game_data.is_deposit[game_data.curr_seatid] = nil
			end
		end
		--设置打牌超时回调
		Events:DelEventById(pdk_cards.const_vars.out_card)
		Events:AddEvent(pdk_cards.const_vars.out_card,15,out_card_time_out,1)
	end
end

local auto_jiege_time = 0
function game_start.check_auto_out( )
	if game_data.game_start and game_data.is_deposit[game_data.curr_seatid] == 1 then
		local curr_time = skynet.time()
		if last_auto_time == 0 then
			local p = players[game_data.curr_seatid]
			last_auto_time = curr_time
			if p and not p.isrobot then
				auto_jiege_time = 1
			else
				if game_start.is_can_greater_card(  ) then
					auto_jiege_time = math.random(1,3)
				else
					auto_jiege_time = 2
				end
			end
		end
		if curr_time - last_auto_time >auto_jiege_time then
			local p = players[game_data.curr_seatid]
			if p and p.isrobot then
				game_start.auto_out_card()
			else
				game_start.auto_out_card()
			end
			local p = players[game_data.curr_seatid]
			if p and not p.isrobot then
				auto_jiege_time = 1
			else
				if game_start.is_can_greater_card(  ) then
					auto_jiege_time = math.random(2,5)
				else
					auto_jiege_time = 2
				end
			end
		end
	end
end

function game_start.send_face( seatid,toid )
	local value = math.random(1,100)
	if value>=10 then
		return
	end
	local msg = {}
	msg.optype = 5
	msg.params = {}
	msg.params[1] = toid
	local face = math.random(1,5)
	msg.params[2] = face
	game_data.game.dispatch(seatid, 'game.OperateReq', msg)
end

function game_start.reset_value(  )
	game_data.reset_value()
end

--短线重连
function game_start.reconect( seatid )
	--发牌
	if game_data.players[seatid] and game_data.game_start then
		game_data.players[seatid].ingame = true
		local msg = {}
		msg.session = 1
		msg.curr_seatid = game_data.curr_seatid
		msg.cards = {}
		if game_data.user_cards and game_data.user_cards[seatid] then
			for k=1,#game_data.user_cards[seatid],1 do
				--print(game_data.user_cards[i][k])
				table.insert(msg.cards,game_data.user_cards[seatid][k])
			end
		end
		msg.players = {}
		for i=1,#players,1 do
			msg.players[i] = msg.players[i] or {}
			msg.players[i].left_card = 0
			if game_data.user_cards and game_data.user_cards[i] then
				msg.players[i].left_card = #game_data.user_cards[i]
			end
			msg.players[i].uid = game_data.players[i].uid
			msg.players[i].seatid = i
			if game_data.players[i].isrobot then
				msg.players[i].is_deposit = 0
			else
				msg.players[i].is_deposit = game_data.is_deposit[i] or 0
			end
			if game_data.players[i].offline then
				msg.players[i].is_offline = 1
			else
				msg.players[i].is_offline = 0
			end
			msg.players[i].params = {}
		end
		msg.last_out_seatid = game_data.last_out_seatid
		msg.last_out_cards = {}
		for i = 1,#game_data.last_out_cards,1 do
			table.insert(msg.last_out_cards,game_data.last_out_cards[i])
		end
		--print("game.STCGPdkGiveCards",game_data.curr_seatid,msg.time,msg.gold)
		game_start.send_msg(seatid,"game.STCPdkReconnect",msg)

		--发送记牌器数据
		game_data.give_card_holder()
	end

end

return game_start