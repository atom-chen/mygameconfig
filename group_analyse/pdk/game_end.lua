
local datacenter = require "datacenter"
game_end = {}

function game_end.end_game(win_seatid)
	if game_data.game.get_room_type( ) == 'diamond' then
		game_end.end_game_diamond(win_seatid)
		return
	end
	if game_data.game.get_room_speci() == 1 then
		game_end.end_game_speci(win_seatid)
		return
	end
	LOG_DEBUG("game_end.end_game")
	game_data.game_start = false
	--计算输的玩家剩余的牌数
	local fail_seats = {};
	--玩家总输赢
	local total = {}

	local total_left_card = 0
	--计算剩余张数的分数
	for i=1,game_data.max_player,1 do
		if win_seatid ~= i then
			local left_len = #game_data.user_cards[i]
			fail_seats[i] = left_len
			total_left_card = total_left_card + left_len

			local rate = 2
			--判断是否被关

			if game_data.is_outcard[i] == 1 then
				rate = 1
			end
			local value = math.floor(left_len*pdk_define.base_score*rate)
			total[i] = 0-value
			total[win_seatid] = total[win_seatid] or 0
			total[win_seatid] = total[win_seatid] + value
		end
	end

	--总流水
	local total_gold = 0
	for i=1,game_data.max_player,1 do
		local value = total[i]
		if value < 0 then
			value = 0-value
		end
		total_gold = total_gold+value
	end

	-- LOG_DEBUG("seatid,%d,%f",1,total[1])
	-- LOG_DEBUG("seatid,%d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid,%d,%f",3,total[3])
	-- end

	--计算炸弹的分数
	-- for i=1,game_data.max_player,1 do
	-- 	if game_data.user_out_bomb[i] and game_data.user_out_bomb[i]>0 then
	-- 		for j = 1,game_data.max_player,1 do
	-- 			if j~=i then
	-- 				total[j] = total[j] - game_data.user_out_bomb[i]*pdk_define.bomb_score/2
	-- 				total[i] = total[i]+game_data.user_out_bomb[i]*pdk_define.bomb_score/2
	-- 			end
	-- 		end
	-- 	end -- end if
	-- end

	-- LOG_DEBUG("seatid zhadan,%d,%f",1,total[1])
	-- LOG_DEBUG("seatid zhadan,%d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid zhadan,%d,%f",3,total[3])
	-- end

	--total[1]= -11600
	--total[2]= 9600
	--total[3]= 2000

	--统计赢得个数
	local win_num = 0
	for i=1,game_data.max_player,1 do
		if total[i]>0 then
			win_num = win_num+1
		end
	end


	--一输两赢的情况
	if not game_data.allownegtive then
		local little_gold = 0
		if win_num >1 then
			for i=1,game_data.max_player,1 do
				--判断金币是否够扣
				if total[i] < 0 and 0-total[i]>game_data.players[i].gold then
					little_gold = 0-total[i] - game_data.players[i].gold
					total[i] = 0-game_data.players[i].gold
					break
				end
			end

			if little_gold>0 then
				little_gold = math.floor(little_gold/2)
				local other_value = 0

				for i=1,game_data.max_player,1 do
					if total[i]>0 then
						if total[i] < little_gold then
							other_value = little_gold - total[i]
							total[i] = 0
							break
						end
					end
				end

				little_gold = little_gold+other_value


				for i=1,game_data.max_player,1 do
					if total[i]>0 then
						if total[i] > little_gold then
							total[i] = total[i] - little_gold
						end
					end
				end

			end
		end

		--print("seatid 1",1,total[1])
		--print("seatid 1",2,total[2])
		--print("seatid 1",3,total[3])

		--一赢得情况
		little_gold = 0
		if win_num == 1 then
			for i=1,game_data.max_player,1 do
				if total[i] < 0 and 0-total[i]>game_data.players[i].gold then
					local value = 0-total[i]
					total[i] = 0-game_data.players[i].gold
					little_gold = little_gold+(value - game_data.players[i].gold)
					--print("little_gold",little_gold)
				end
			end

			for i=1,game_data.max_player,1 do
				if total[i]>0 then
					total[i] = total[i] - little_gold
				end
			end
		end
	end

	local respone = {}
	respone.session = 1
	respone.users = {}
	respone.first_out = game_data.first_out_seatid
	local table_fee = 0--100--10
	-- if game_data.max_player == 2 then
	-- 	table_fee = 6.6
	-- end
	for i=1,game_data.max_player,1 do
		local UserScore = {}
		UserScore.seatid = i
		UserScore.score = total[i]
		UserScore.table_fee = 0--math.floor(total_gold/table_fee)
		game_data.is_outcard[i] = game_data.is_outcard[i] or 0
		UserScore.is_outcard = game_data.is_outcard[i]
		UserScore.left_card = #game_data.user_cards[i]
		UserScore.ncards = {}
		for j=1,#game_data.user_cards[i],1 do
			table.insert(UserScore.ncards,game_data.user_cards[i][j])
		end

		table.insert(respone.users,UserScore)
	end

	--print("seatid 2",1,total[1])
	--print("seatid 2",2,total[2])
	--print("seatid 2",3,total[3])

	if game_data.curr_new_user>0 and game_data.curr_new_user == win_seatid and game_data.is_out_a_zha == win_seatid then
		game_data.set_isnot_win(game_data.curr_new_user)
		-- game_data.players[win_seatid].missile_played = true
	else
		if game_data.curr_new_user>0 and game_data.players[game_data.curr_new_user] then
			local game_num_str = string.format("game_num_%d",game_data.players[game_data.curr_new_user].uid)
			local game_num = datacenter.get(game_num_str)
			if game_num then
				game_num = game_num+1
				datacenter.set(game_num_str,game_num)
				if game_num >=20 then
					game_data.set_isnot_win(game_data.curr_new_user)
					--datacenter.del(game_num_str)
				end
			else
				game_num = 1
				datacenter.set(game_num_str,game_num)
			end
		end
	end

	--计算台费
	for i=1,game_data.max_player,1 do
		--print("free",math.floor(total_gold/30),total_gold)
		-- total[i] = total[i]-math.floor(total_gold/table_fee)
		if not game_data.allownegtive then
			if total[i] < 0 and 0-total[i]>game_data.players[i].gold then
				total[i] = 0-game_data.players[i].gold
			end
		end
		respone.users[i].gold = tostring(game_data.players[i].gold+total[i])
	end

	-- LOG_DEBUG("seatid %d,%f",1,total[1])
	-- LOG_DEBUG("seatid %d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid %d,%f",3,total[3])
	-- end

	--if true then
		--return
	--end

	game_data.sent_msg(0,"game.STCGPdkEnd",respone)

	--更新用户金币
	for i=1,game_data.max_player,1 do
		--game_data.players[i].gold = game_data.players[i].gold+total[i]

		if game_data.game then
			if not game_data.isMatch and game_data.players[i].isrobot and total[i] < 0 and tonumber(respone.users[i].gold)<15000 then
				total[i] = 0
			end
			--print("game_data.players[i].isrobot",game_data.players[i].isrobot)
		else
			LOG_DEBUG("game_data.game is nil")
		end
		if game_data.players[i] then
			game_data.players[i].ingame = false
		end
	end

	local redis_name = 'pdk'..game_data.roomid
	--统计机器人赢得局数
	if game_data.players[win_seatid] and game_data.players[win_seatid].isrobot then
		local robot_win = game_data.game.query_hash_redis_data(0,redis_name,'robot_win')
		if not robot_win then
			robot_win = 0
		else 
			robot_win = tonumber(robot_win)
		end
		robot_win = robot_win + 1
		robot_win = tostring(robot_win)
		game_data.game.record_hash_redis_data(0,redis_name,'robot_win',robot_win)
	end

	if game_data.game then
		
		game_data.game.gameEnd(total,win_seatid)
	end
	if not game_data.isMatch then
		game_data.game.kick_out_all()
	end

	--统计台费
	local redis_fee = game_data.game.query_hash_redis_data(0,redis_name,'table_fee')
	if not redis_fee then
		redis_fee = 0
	else
		redis_fee = tonumber(redis_fee) or 0
	end

	redis_fee = redis_fee + game_data.max_player*math.floor(total_gold/table_fee)
	redis_fee = tostring(redis_fee)
	game_data.game.record_hash_redis_data(0,redis_name,'table_fee',redis_fee)

	local redis_game_num = game_data.game.query_hash_redis_data(0,redis_name,'game_num')
	if not redis_game_num then
		redis_game_num = 0
	else
		redis_game_num = tonumber(redis_game_num)
	end
	redis_game_num = redis_game_num + 1
	redis_game_num = tostring(redis_game_num)
	game_data.game.record_hash_redis_data(0,redis_name,'game_num',redis_game_num)
end

function game_end.end_game_diamond(win_seatid)
	LOG_DEBUG("game_end.end_game_diamond,%d",game_data.max_player)
	game_data.game_start = false
	--计算输的玩家剩余的牌数
	local fail_seats = {};
	--玩家总输赢
	local total = {}

	local total_left_card = 0
	--计算剩余张数的分数
	for i=1,game_data.max_player,1 do
		if win_seatid ~= i then
			local left_len = #game_data.user_cards[i]
			fail_seats[i] = left_len
			total_left_card = total_left_card + left_len

			local rate = 2
			--判断是否被关

			if game_data.is_outcard[i] == 1 then
				rate = 1
			end
			local value = math.floor(left_len*pdk_define.base_score*rate)
			total[i] = 0-value
			total[win_seatid] = total[win_seatid] or 0
			total[win_seatid] = total[win_seatid] + value
		end
	end

	-- luadump(total[i])
	-- for i=1,game_data.max_player,1 do
	-- 	if total[i] and total[i] > 0  and game_data.max_player == 2 then
	-- 		total[i] = 0
	-- 	end
	-- end

	local no_zhadan_score = {}
	for i=1,game_data.max_player,1 do
		no_zhadan_score[i] = total[i]
	end

	--总流水
	local total_gold = 0
	for i=1,game_data.max_player,1 do
		local value = total[i]
		if value < 0 then
			value = 0-value
		end
		total_gold = total_gold+value
	end

	-- LOG_DEBUG("seatid,%d,%f",1,total[1])
	-- LOG_DEBUG("seatid,%d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid,%d,%f",3,total[3])
	-- end

	--计算炸弹的分数
	-- for i=1,game_data.max_player,1 do
	-- 	if game_data.user_out_bomb[i] and game_data.user_out_bomb[i]>0 then
	-- 		for j = 1,game_data.max_player,1 do
	-- 			if j~=i then
	-- 				total[j] = total[j] - game_data.user_out_bomb[i]*pdk_define.bomb_score/2
	-- 				total[i] = total[i]+game_data.user_out_bomb[i]*pdk_define.bomb_score/2
	-- 			end
	-- 		end
	-- 	end -- end if
	-- end

	-- LOG_DEBUG("seatid zhadan,%d,%f",1,total[1])
	-- LOG_DEBUG("seatid zhadan,%d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid zhadan,%d,%f",3,total[3])
	-- end

	--total[1]= -11600
	--total[2]= 9600
	--total[3]= 2000

	--统计赢得个数
	local win_num = 0
	for i=1,game_data.max_player,1 do
		if total[i]>0 then
			win_num = win_num+1
		end
	end


	--一输两赢的情况
	local little_gold = 0
	if win_num >1 then
		for i=1,game_data.max_player,1 do
			--判断金币是否够扣
			if total[i] < 0 and 0-total[i]>game_data.players[i].diamond then
				little_gold = 0-total[i] - game_data.players[i].diamond
				total[i] = 0-game_data.players[i].diamond
				break
			end
		end

		if little_gold>0 then
			little_gold = math.floor(little_gold/2)
			local other_value = 0

			for i=1,game_data.max_player,1 do
				if total[i]>0 then
					if total[i] < little_gold then
						other_value = little_gold - total[i]
						total[i] = 0
						break
					end
				end
			end

			little_gold = little_gold+other_value


			for i=1,game_data.max_player,1 do
				if total[i]>0 then
					if total[i] > little_gold then
						total[i] = total[i] - little_gold
					else
						total[i] = 0
					end
				end
			end

		end
	end

	--print("seatid 1",1,total[1])
	--print("seatid 1",2,total[2])
	--print("seatid 1",3,total[3])

	--一赢得情况
	little_gold = 0
	if win_num == 1 then
		for i=1,game_data.max_player,1 do
			if total[i] < 0 and 0-total[i]>game_data.players[i].diamond then
				local value = 0-total[i]
				total[i] = 0-game_data.players[i].diamond
				little_gold = little_gold+(value - game_data.players[i].diamond)
				--print("little_gold",little_gold)
			end
		end

		for i=1,game_data.max_player,1 do
			if total[i]>0 then
				total[i] = total[i] - little_gold
				if total[i] < 0  then
					total[i] = 0
				end
			end
		end
	end


	local respone = {}
	respone.session = 1
	respone.users = {}
	respone.first_out = game_data.first_out_seatid

	local table_fee = 4
	if game_data.max_player == 2 then
		table_fee = 6
	end
	for i=1,game_data.max_player,1 do
		local UserScore = {}
		UserScore.seatid = i
		-- if game_data.max_player == 2 and game_data.game.get_room_type( ) == 'diamond' then
		-- 	UserScore.score = no_zhadan_score[i]
		-- else
			UserScore.score = total[i]
		-- end
		UserScore.table_fee = table_fee--math.floor(total_gold/20)
		game_data.is_outcard[i] = game_data.is_outcard[i] or 0
		UserScore.is_outcard = game_data.is_outcard[i]
		UserScore.left_card = #game_data.user_cards[i]
		UserScore.ncards = {}
		for j=1,#game_data.user_cards[i],1 do
			table.insert(UserScore.ncards,game_data.user_cards[i][j])
		end

		table.insert(respone.users,UserScore)
	end

	--print("seatid 2",1,total[1])
	--print("seatid 2",2,total[2])
	--print("seatid 2",3,total[3])

	--计算台费
	for i=1,game_data.max_player,1 do
		--print("free",math.floor(total_gold/30),total_gold)
		--total[i] = total[i]-4--math.floor(total_gold/20)
		--if total[i] < 0 and 0-total[i]>game_data.players[i].diamond then
			--total[i] = 0-game_data.players[i].diamond
		--end 

		--if total[i] > 0 then
			--total[i] = 0
		--end
		respone.users[i].gold = tostring(game_data.players[i].diamond+total[i])
	end

	-- LOG_DEBUG("seatid %d,%f",1,total[1])
	-- LOG_DEBUG("seatid %d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid %d,%f",3,total[3])
	-- end

	--if true then
		--return
	--end

	game_data.sent_msg(0,"game.STCGPdkEnd",respone)

	--更新用户金币
	for i=1,game_data.max_player,1 do
		--game_data.players[i].gold = game_data.players[i].gold+total[i]

		if game_data.game then
			if game_data.players[i].isrobot and total[i] < 0 and tonumber(respone.users[i].gold)<300 then
				total[i] = 0
			end
			--print("game_data.players[i].isrobot",game_data.players[i].isrobot)
		else
			LOG_DEBUG("game_data.game is nil")
		end
		if game_data.players[i] then
			game_data.players[i].ingame = false
		end
	end

	local redis_name = 'pdk'..game_data.roomid
	--统计机器人赢得局数
	if game_data.players[win_seatid] and game_data.players[win_seatid].isrobot then
		local robot_win = game_data.game.query_hash_redis_data(0,redis_name,'robot_win')
		if not robot_win then
			robot_win = 0
		else 
			robot_win = tonumber(robot_win)
		end
		robot_win = robot_win + 1
		robot_win = tostring(robot_win)
		game_data.game.record_hash_redis_data(0,redis_name,'robot_win',robot_win)
	end

	if game_data.game then
		game_data.game.gameEnd(total,win_seatid,total_left_card)
	end
	game_data.game.kick_out_all()

	--统计台费
	local redis_fee = game_data.game.query_hash_redis_data(0,redis_name,'table_fee')
	if not redis_fee then
		redis_fee = 0
	else
		redis_fee = tonumber(redis_fee)
	end

	redis_fee = redis_fee + game_data.max_player*table_fee
	redis_fee = tostring(redis_fee)
	game_data.game.record_hash_redis_data(0,redis_name,'table_fee',redis_fee)

	local redis_game_num = game_data.game.query_hash_redis_data(0,redis_name,'game_num')
	if not redis_game_num then
		redis_game_num = 0
	else
		redis_game_num = tonumber(redis_game_num)
	end
	redis_game_num = redis_game_num + 1
	redis_game_num = tostring(redis_game_num)
	game_data.game.record_hash_redis_data(0,redis_name,'game_num',redis_game_num)
end

function game_end.end_game_speci(win_seatid)
	LOG_DEBUG("game_end.end_game_speci,%d",game_data.max_player)
	game_data.game_start = false
	--计算输的玩家剩余的牌数
	local fail_seats = {};
	--玩家总输赢
	local total = {}

	local total_left_card = 0
	--计算剩余张数的分数
	for i=1,game_data.max_player,1 do
		if win_seatid ~= i then
			local left_len = #game_data.user_cards[i]
			fail_seats[i] = left_len
			total_left_card = total_left_card + left_len

			local rate = 2
			--判断是否被关

			if game_data.is_outcard[i] == 1 then
				rate = 1
			end
			local value = math.floor(left_len*pdk_define.base_score*rate)
			total[i] = 0-value
			total[win_seatid] = total[win_seatid] or 0
			total[win_seatid] = total[win_seatid] + value
		end
	end


	for i=1,game_data.max_player,1 do
		if total[i] and total[i] > 0  and game_data.max_player == 2 then
			total[i] = 0
		end
	end

	local no_zhadan_score = {}
	for i=1,game_data.max_player,1 do
		no_zhadan_score[i] = total[i]
	end

	--总流水
	local total_gold = 0
	for i=1,game_data.max_player,1 do
		local value = total[i]
		if value < 0 then
			value = 0-value
		end
		total_gold = total_gold+value
	end

	-- LOG_DEBUG("seatid,%d,%f",1,total[1])
	-- LOG_DEBUG("seatid,%d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid,%d,%f",3,total[3])
	-- end

	--计算炸弹的分数
	-- for i=1,game_data.max_player,1 do
	-- 	if game_data.user_out_bomb[i] and game_data.user_out_bomb[i]>0 then
	-- 		for j = 1,game_data.max_player,1 do
	-- 			if j~=i then
	-- 				total[j] = total[j] - game_data.user_out_bomb[i]*pdk_define.bomb_score/2
	-- 				total[i] = total[i]+game_data.user_out_bomb[i]*pdk_define.bomb_score/2
	-- 			end
	-- 		end
	-- 	end -- end if
	-- end

	-- LOG_DEBUG("seatid zhadan,%d,%f",1,total[1])
	-- LOG_DEBUG("seatid zhadan,%d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid zhadan,%d,%f",3,total[3])
	-- end

	--total[1]= -11600
	--total[2]= 9600
	--total[3]= 2000

	--统计赢得个数
	local win_num = 0
	for i=1,game_data.max_player,1 do
		if total[i]>0 then
			win_num = win_num+1
		end
	end


	--一输两赢的情况
	local little_gold = 0
	if win_num >1 then
		for i=1,game_data.max_player,1 do
			--判断金币是否够扣
			if total[i] < 0 and 0-total[i]>game_data.players[i].gold then
				little_gold = 0-total[i] - game_data.players[i].gold
				total[i] = 0-game_data.players[i].gold
				break
			end
		end

		if little_gold>0 then
			little_gold = math.floor(little_gold/2)
			local other_value = 0

			for i=1,game_data.max_player,1 do
				if total[i]>0 then
					if total[i] < little_gold then
						other_value = little_gold - total[i]
						total[i] = 0
						break
					end
				end
			end

			little_gold = little_gold+other_value


			for i=1,game_data.max_player,1 do
				if total[i]>0 then
					if total[i] > little_gold then
						total[i] = total[i] - little_gold
					else
						total[i] = 0
					end
				end
			end

		end
	end

	--print("seatid 1",1,total[1])
	--print("seatid 1",2,total[2])
	--print("seatid 1",3,total[3])

	--一赢得情况
	little_gold = 0
	if win_num == 1 then
		for i=1,game_data.max_player,1 do
			if total[i] < 0 and 0-total[i]>game_data.players[i].gold then
				local value = 0-total[i]
				total[i] = 0-game_data.players[i].gold
				little_gold = little_gold+(value - game_data.players[i].gold)
				--print("little_gold",little_gold)
			end
		end

		for i=1,game_data.max_player,1 do
			if total[i]>0 then
				total[i] = total[i] - little_gold
				if total[i] < 0  then
					total[i] = 0
				end
			end
		end
	end


	local respone = {}
	respone.session = 1
	respone.users = {}
	respone.first_out = game_data.first_out_seatid

	local table_fee = 5000
	if game_data.max_player == 2 then
		table_fee = 5000
	end
	for i=1,game_data.max_player,1 do
		local UserScore = {}
		UserScore.seatid = i
		if game_data.max_player == 2  then
			UserScore.score = no_zhadan_score[i]
		else
			UserScore.score = total[i]
		end
		UserScore.table_fee = table_fee--math.floor(total_gold/20)
		game_data.is_outcard[i] = game_data.is_outcard[i] or 0
		UserScore.is_outcard = game_data.is_outcard[i]
		UserScore.left_card = #game_data.user_cards[i]
		UserScore.ncards = {}
		for j=1,#game_data.user_cards[i],1 do
			table.insert(UserScore.ncards,game_data.user_cards[i][j])
		end

		table.insert(respone.users,UserScore)
	end

	--print("seatid 2",1,total[1])
	--print("seatid 2",2,total[2])
	--print("seatid 2",3,total[3])

	--计算台费
	for i=1,game_data.max_player,1 do
		--print("free",math.floor(total_gold/30),total_gold)
		total[i] = total[i]-table_fee
		if total[i] < 0 and 0-total[i]>game_data.players[i].gold then
			total[i] = 0-game_data.players[i].gold
		end 
		respone.users[i].gold = tostring(game_data.players[i].gold+total[i])
	end

	-- LOG_DEBUG("seatid %d,%f",1,total[1])
	-- LOG_DEBUG("seatid %d,%f",2,total[2])
	-- if game_data.max_player == 3 then
	-- 	LOG_DEBUG("seatid %d,%f",3,total[3])
	-- end

	--if true then
		--return
	--end

	game_data.sent_msg(0,"game.STCGPdkEnd",respone)

	--更新用户金币
	for i=1,game_data.max_player,1 do
		--game_data.players[i].gold = game_data.players[i].gold+total[i]

		if game_data.game then
			if game_data.players[i].isrobot and total[i] < 0 and tonumber(respone.users[i].gold)<300 then
				total[i] = 0
			end
			--print("game_data.players[i].isrobot",game_data.players[i].isrobot)
		else
			LOG_DEBUG("game_data.game is nil")
		end
		if game_data.players[i] then
			game_data.players[i].ingame = false
		end
	end

	local redis_name = 'pdk'..game_data.roomid
	--统计机器人赢得局数
	if game_data.players[win_seatid] and game_data.players[win_seatid].isrobot then
		local robot_win = game_data.game.query_hash_redis_data(0,redis_name,'robot_win')
		if not robot_win then
			robot_win = 0
		else 
			robot_win = tonumber(robot_win)
		end
		robot_win = robot_win + 1
		robot_win = tostring(robot_win)
		game_data.game.record_hash_redis_data(0,redis_name,'robot_win',robot_win)
	end

	if game_data.game then
		game_data.game.gameEnd(total,win_seatid,total_left_card)
	end
	game_data.game.kick_out_all()

	--统计台费
	local redis_fee = game_data.game.query_hash_redis_data(0,redis_name,'table_fee')
	if not redis_fee then
		redis_fee = 0
	else
		redis_fee = tonumber(redis_fee)
	end

	redis_fee = redis_fee + game_data.max_player*table_fee
	redis_fee = tostring(redis_fee)
	game_data.game.record_hash_redis_data(0,redis_name,'table_fee',redis_fee)

	local redis_game_num = game_data.game.query_hash_redis_data(0,redis_name,'game_num')
	if not redis_game_num then
		redis_game_num = 0
	else
		redis_game_num = tonumber(redis_game_num)
	end
	redis_game_num = redis_game_num + 1
	redis_game_num = tostring(redis_game_num)
	game_data.game.record_hash_redis_data(0,redis_name,'game_num',redis_game_num)
end

game_data.players = {}
game_data.players[1] = {}
game_data.players[1].gold = 10000
game_data.players[2] = {}
game_data.players[2].gold = 10000
game_data.players[3] = {}
game_data.players[3].gold = 10000
game_data.user_cards[1] = {}
game_data.user_cards[2] = {1,2,3,4,5,6,7,8,1,2,3,4,5,6,7} 
game_data.user_cards[3] = {1,2,3,4,5,6,7,8,1,2,3,4,5,6,7} 

--game_end.end_game(2)

return game_end