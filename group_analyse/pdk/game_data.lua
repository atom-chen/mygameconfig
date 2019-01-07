local skynet = require "skynet"

game_data = {}

game_data.user_cards = {}
game_data.last_out_cards = {}
game_data.cards = {}
game_data.curr_seatid = 0--当前玩家
game_data.user_out_bomb = {}
game_data.last_out_seatid = 0--上次打牌的玩家
game_data.last_out_type = 0--上次打出牌的牌型
game_data.last_out_value = 0
game_data.game_start = false
game_data.is_outcard = {}--三个玩家是否出过牌，首次出牌不算
game_data.is_first_out = true;
game_data.is_deposit = {}--玩家是否已经托管
game_data.first_out_seatid = 0
game_data.roomid = 0
game_data.curr_new_user = 0--本局新手
game_data.is_out_a_zha = 0--是否打过A炸弹
game_data.max_player = 0
game_data.allownegtive = false
game_data.isMatch = false

function game_data.set_info(players,sent_msg,game,roomid,max_player, cfg)
	game_data.players = players
	game_data.sent_msg = sent_msg
	game_data.game = game
	game_data.roomid = roomid
	game_data.max_player = max_player

	game_data.allownegtive = cfg.allownegtive
	game_data.isMatch = cfg.isMatch
	--local total = {}
	--game_data.game.end_game(total)
	--print("game_data.game",game_data.game)
end

function game_data.reset_value()
	game_data.user_cards = {}
	game_data.last_out_cards = {}
	game_data.cards = {}
	game_data.curr_seatid = 0
	game_data.user_out_bomb = {}
	game_data.last_out_seatid = 0
	game_data.last_out_type = 0
	game_data.last_out_value = 0
	game_data.game_start = false
	game_data.is_outcard = {}
	game_data.is_first_out = true;
	game_data.is_deposit = {}
	game_data.first_out_seatid = 0
	game_data.curr_new_user = 0
	game_data.is_out_a_zha = 0
end

function game_data.clear_user_data( seatid )
	if game_data.is_deposit[seatid] then
		game_data.is_deposit[seatid] = nil
	end
end

--得到用户牌值的数量
local function get_value_num( seatid,value)
	if game_data.user_cards[seatid] == nil then
		return 0
	end
	local num = 0
	for i=1,#game_data.user_cards[seatid],1 do
		if value == pdk_cards.get_card_vale(game_data.user_cards[seatid][i]) then
			num = num + 1
		end
	end

	return num
end

--计算剩余的牌值数
local function get_left_value_num( seatid )
	if game_data.user_cards[seatid] == nil then
		return
	end
	local card_infos = {}
	for i = 1,13,1 do
		local info = {}
		info.card_value = i
		info.card_num = 0
		for j = 1,game_data.max_player,1 do
			if j ~= seatid then
				info.card_num = info.card_num + get_value_num(j,i)
			end
		end
		--print("记牌器",info.card_value,info.card_num)
		table.insert(card_infos,info)
	end
	return card_infos
end

--请求记牌器数据
function game_data.req_card_holder( seatid,msg )
	local p
	if game_data.players then
		p = game_data.players[seatid]
	end
	if not p then
		return
	end

	if p.cardholder == 1 then
		p.cardholder = nil
		return
	end
	p.cardholder = 1

	game_data.give_card_holder()
end

--游戏开始检查记牌器
function game_data.check_card_holder()
	if game_data.max_player == 2 then
		return
	end
	for i = 1,game_data.max_player,1 do
		if game_data.players then
			local p = game_data.players[i]
			--判断记牌器是否过期
			if p and p.recorder_expire_time then
				local curr_time = skynet.time()
				if p.recorder_expire_time > curr_time then
					p.cardholder = 1
				end
			end
		end
	end
end

--发送记牌器数据
function game_data.give_card_holder( )
	if game_data.game_start ==false or game_data.max_player == 2 then
		return
	end

	for i = 1,game_data.max_player,1 do
		if game_data.players then
			local p = game_data.players[i]
			--判断记牌器是否过期
			if p and p.recorder_expire_time and  p.cardholder == 1 then
				local curr_time = skynet.time()
				if p.recorder_expire_time < curr_time then
					p.cardholder = 0
				end
			end

			if p and p.cardholder == 1 then
				local response = {}
				response.session = 1
				response.card_infos = get_left_value_num(i)
				game_data.sent_msg(i,"game.STCPdkCardHolder",response)
			end

		end
	end
end

--请求
function game_data.OperateReq( seatid,msg )
	if msg.optype == 1 then--托管
		if game_data.game_start ==false then
			return
		end
		game_data.is_deposit[seatid] = 1

		if game_data.players[seatid].isrobot then
			return
		end
		local response = {}
		response.session = 1
		response.optype = 1
		response.seatid = seatid
		response.params = {}
		game_data.sent_msg(0,"game.OperateRep",response)
	end

	if msg.optype == 0 then--取消托管
		if game_data.is_deposit[seatid] then
			game_data.is_deposit[seatid] = nil
		end
		local response = {}
		response.session = 1
		response.optype = 0
		response.seatid = seatid
		response.params = {}
		game_data.sent_msg(0,"game.OperateRep",response)
	end
end

--判断是否是从没赢过的新手
function game_data.check_isnot_win( seatid )
	local redis_name = 'pdk'..3006
	local value = game_data.game.query_hash_redis_data(seatid,redis_name,'has_win')
	if value then
		return false
	end
	redis_name = 'pdk'
	value = game_data.game.query_hash_redis_data(seatid,redis_name,'has_win')
	if value then
		return false
	end

	return true
end

function game_data.set_isnot_win( seatid )
	local redis_name = 'pdk'
	game_data.game.record_hash_redis_data(seatid,redis_name,'has_win',"1")
end

return game_data