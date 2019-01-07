local skynet = require "skynet"
require "functions"
local logic = require 'logic'
local combination = require 'combination'
local _game_prop = require 'game_prop'
local crypt = require "crypt"
local _base64decode = crypt.base64decode
local _room_cards_create = require 'room_cards_create'
local _gold_change_reason_enum = require "gold_change_reason"
local _cfg
local _dynamic_cfg

--比赛标记
local isMatch
local _maxplayer
local _minplayer
local CT_BOMB_CARD =			11 	--炸弹
local CT_MISSILE_CARD =			12	--王炸

local _loot_lord_time = 16 * 100
local _play_time = 16 * 100
local _call_double_time = 6 * 100
local DELAY = 100

local _cursid
local _starttime
local _delaytime 
local _gamestatus -- 100开始游戏 0 开始发牌 1叫庄 2 出牌 3 检查是否结束 4 加倍 255 空闲状态
local _concedecnt -- 让步次数
local odds
local _landlord
local lastcards
local _lastseatid
local winner
local _cardtable
local _players
-- local playtimeout
-- local lastmsg
local _basescore
-- local _last_seatid
-- local used_cards = {}
local played_seatids = {} --用来记录出过牌的玩家，用于计算春天反春天
local huojiancnt = 0 -- 用来记录火箭的个数
local zhadancnt = 0 -- 用来记录炸弹的个数
local _personalgame
local _re_shuffle_count
local _game_start_time --游戏开始时间
local _max_game_time = 100 * 60 * 15--15 * 60 * 100 -- 最大游戏时长~！
local _minscore
local _lootlordcnt
local _call_concede_times
local _end_game_time = 0
local _match_restart_time = 700
local game = {}
local _kickbacks
local _roomtype
local _remain_cards = {}
local _guesscards_mutiple = {
	[1] = 1.2,
	[2] = 3,
	[3] = 6,
	[4] = 15,
	[5] = 20,
	[6] = 100,
}

local _doubled = {}
local _double_price
local _double_limit

local _master_cards = {}
local _face_use = {item = 0, gold = 0, freeze = 0}
local _special_ct = {}
local _defaultOdds
local _round1lottery
local _redispool
local _robotcallbank

local function setTick(delay, from)
	_starttime = skynet.now()
	-- LOG_DEBUG('tableid:%d setTick  delay：%d   from: %s', skynet.self(), delay, from)
	if not delay or delay <= 0  then
		LOG_ERROR('tableid:%d !!!!!!!!!!!!!!!!!!!!!!setTick  delay：%d   from: %s', skynet.self(), delay, from)
		delay = 100
	end
	_delaytime = delay
end

local function cancelTick(from)
	-- if from then
	-- 	LOG_DEBUG('tableid:%d cancelTick from: %s', skynet.self(), from)
	-- end
	_delaytime = 0
end

local function sent_msg(seatid, msgname, msg, order)
	game.sent_msg2(seatid, msgname, msg, order)
end

local function gamelog(msg, cards)
	local str = ''
	if cards and type(cards) == 'table' and next(cards) then
		for i = 1, #cards do
			str = string.format('%s %d', str, cards[i])
		end
	end

	LOG_DEBUG('tableid:%d %s', skynet.self(), msg..str)
end

local function checkxplayer()
	local sidx
	for k, v in pairs(_players) do
		if v.sflag and v.sflag ~= 0 then
			if v.sflag > 0 then
				sidx = k
			else
				for k1, v1 in pairs(_players) do
					if k1 ~= k then
						sidx = k1
						if v1 and v1.isrobot then
							_robotcallbank = 1
						end
						break
					end
				end
			end
			_cardtable, _master_cards = logic.createCardsGroupXplayer(sidx)
			logic.printCards(_cardtable[sidx], true)
			return true
		end
	end
end

local function shuffle()
	if checkxplayer() then return end
	local shufflecnt = 0
	local cfg = _room_cards_create[_roomid] or {}
	local r = math.random(1, 100)
	local percent = 0
	for i = 1, #cfg do
		percent = percent + cfg[i][3]
		if r <= percent then
			shufflecnt = math.random(cfg[i][1], cfg[i][2])
			break
		end
	end

	if shufflecnt > 0 and not isMatch then
		_cardtable, _master_cards = logic.createCardsGroupHeap(shufflecnt)
	else
		_cardtable, _master_cards = logic.createCardsGroup(3, 2)
		-- _cardtable, _master_cards = logic.createCardsNormal()
		-- local percent = math.random(1000)
		-- if (_roomid == 1001 or isMatch) and percent < 300 then
		-- 	_cardtable, _master_cards = logic.createCardsNormal()
		-- else
		-- 	if _roomid == 1003 or _roomid == 1005 then
		-- 		_cardtable, _master_cards = logic.createCardsGroup(3, 2)
		-- 	elseif _roomid == 1000 or _roomid == 1004 then
		-- 		_cardtable, _master_cards = logic.createCardsGroup(3, 1)
		-- 	else
		-- 		_cardtable, _master_cards = logic.createCardsGroup()
		-- 	end
		-- end
	end
end

--检查cards1能否压住cards2
local function check(cards1,cards2)
	-- LOG_DEBUG('msg:--------------------检查cards1能否压住cards2')
	-- logic.printCards(cards1, true, 'cards1  ')
	-- logic.printCards(cards2, true, 'cards2  ')
	local ct1, keyValue1 =logic.getCardType(cards1)
	if ct1 == CT_MISSILE_CARD then
		return true, ct1
	end
	
	local ct2, keyValue2 =logic.getCardType(cards2)
	if ct2 == CT_MISSILE_CARD then
		return false, ct1
	end

	if ct2 ~= CT_BOMB_CARD and ct1 == CT_BOMB_CARD then
		-- if keyValue1 > keyValue2 then
			return true, ct1
		-- else
			-- return false,ct1
		-- end
	end

	if ct1 == ct2 and #cards1 == #cards2 then
		return keyValue1 > keyValue2, ct1
	end
	return false,ct1
end
--判断si号玩家有没有卡牌cards，如果有，则从该玩家手上删除这些卡牌并返回，如果没有，则返回nil
local function check_cards(si, cards)
	if si < 1 or si > 4 then return false end
	
	for i = 1, #cards do
		index = table.keyof(_cardtable[si], cards[i])
		if not index then
			return false
		else
			table.remove(_cardtable[si], index)
		end
	end
	return true
end

local function delCards(seatid, cards)
	local t
	for k, v in pairs(cards) do
		t = math.floor(v / 10)
		_remain_cards[seatid][t] = _remain_cards[seatid][t] - 1
	end
end

local function resetRemainCards()
	for j = 1, _maxplayer do
		_remain_cards[j] = {}
		
		for i = 1, 13 do
			_remain_cards[j][i] = 4
		end
		_remain_cards[j][14] = 1
		_remain_cards[j][15] = 1

		delCards(j, _cardtable[j])
	end
end

local function set_master(mid)
	_landlord = mid
	_lastseatid = mid
	sent_msg(0,"game.SetScore",{score = _concedecnt, seatid = _landlord, ismaster = true})
	table.mergeByAppend(_cardtable[_landlord], _master_cards)
	delCards(_landlord, _master_cards)
	if not _cardtable or not _cardtable[1] then
		if isMatch then
			game.end_game({0,0,0})
		else
			game.kick_out_all(0, _roomtype == 'diamond')
		end
		return
	end
	table.sort(_cardtable[1])
	table.sort(_cardtable[2])
	table.sort(_cardtable[3])
	gamelog(string.format('确定庄家uid:%s  底牌: ', _players[_landlord].uid), _master_cards)
	for i = 1, _maxplayer do
		if _cardtable[i][#_cardtable[i]] == 150 and _cardtable[i][#_cardtable[i] - 1] == 140 then
			if not _players[i] then
				LOG_DEBUG("set_master")
				luadump(_players)
				if isMatch then
					game.end_game({0,0,0})
				else
					game.kick_out_all(0, _roomtype == 'diamond')
				end
				return
			end
			_players[i].missile_sent = true
		end
		if _players[i] then
			if i == mid then
				_players[i].role = 2
			else
				_players[i].role = 1
			end
		end
	end

	sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
	sent_msg(0,"game.ShowCard",{seatid = _landlord, cardids = _master_cards})
	-- settle_guesscards_account(_master_cards)
end

local function next_player()
	_cursid = _cursid + 1
	if _cursid > _maxplayer then _cursid = 1 end
end

local function check_end()
	if _gamestatus ~= 2 then
		return false
	end
	_gamestatus = 3

	for i = 1, _maxplayer do
		if (i == _landlord and #(_cardtable[i]) < 1) or (i ~= _landlord and #(_cardtable[i]) <= _concedecnt) then
			gamelog(string.format('uid:%d 出完,获胜', _players[i].uid))
			winner = i
			return true
		end
	end
	return false
end

local function end_game_op(chge)
	for k, v in pairs(_players) do
		if v.subcontinuouswin then
			pcall(skynet.call, _redispool, "lua", "execute", "DECR", string.format("continuouswin%d", v.uid))
		end
	end
	_end_game_time = skynet.now()
	game.end_game(chge, nil, nil, _face_use, _special_ct)
	
	_game_start_time = nil
	if not isMatch and not _personalgame then
		game.kick_out_all()
	end
	_gamestatus = 255
end

local function diamond_end_game()
	sid = winner
	local chge = {}
	local flag = (winner == _landlord) and 1 or -1
	local spring = 0
	if flag == 1 then
		-- 春天,地主赢，并且出过牌的人只有一个
		local played_count = 0 -- 出过牌的人的个数
		for i = 1, _maxplayer do
			if played_seatids[i] and played_seatids[i] > 0 then
				played_count = played_count + 1
			end
		end
		
		if played_count == 1 then
			spring = 1
			odds = odds * 2
			if odds > _maxodds then odds = _maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	else
		-- 反春天，农民赢，并且地主只出过一手牌
		if played_seatids[_landlord] and played_seatids[_landlord] == 1 then
			spring = 1
			odds = odds * 2
			if odds > _maxodds then odds = _maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	end

	local s = _basescore * odds
	sent_msg(0,"game.UpdateGameInfo", {params2={spring, huojiancnt, zhadancnt}})
	for i = 1, _maxplayer do
		if i ~= _landlord then
			chge[i] = -s * flag
		else
			chge[i] = s * flag
		end
		if chge[i] > 0 then
			if odds >= 4 then
				chge[i] = chge[i] - 4
			elseif odds >= 2 then
				chge[i] = chge[i] - 2
			end
			if chge[i] < 0 then chge[i] = 0 end
		end
		sent_msg(0, "game.SetCards", {seatid = i, cardids = _cardtable[i]})
	end
	game.diamond_end_game(chge, _face_use, _special_ct)
	_game_start_time = nil
	game.kick_out_all()
	_gamestatus = 255
end

local function end_game()
	_cursid = winner
	local chge = {}
	local flag
	if winner == _landlord then
		--地主赢
		flag = 1
	else
		--农民赢
		flag = -1
	end

	local spring = 0
	if flag == 1 then
		-- 春天,地主赢，并且出过牌的人只有一个
		local played_count = 0 -- 出过牌的人的个数
		for i = 1, _maxplayer do
			if played_seatids[i] and played_seatids[i] > 0 then
				played_count = played_count + 1
			end
		end
		if played_count == 1 then
			spring = 1
			odds = odds * 2
			if odds > _maxodds then odds = _maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	else
		-- 反春天，农民赢，并且地主只出过一手牌
		if played_seatids[_landlord] and played_seatids[_landlord] == 1 then
			spring = 1
			odds = odds * 2
			if odds > _maxodds then odds = _maxodds end
			sent_msg(0,"game.UpdateGameInfo", {params1={odds}})
		end
	end

	local s = _basescore * odds
	for i = 1, _maxplayer do
		if i ~= _landlord then
			chge[i] = -s * flag
		else
			chge[i] = s * flag
		end
	end

	sent_msg(0,"game.UpdateGameInfo", {params2={spring, huojiancnt, zhadancnt}})
	for i = 1, _maxplayer do
		sent_msg(0, "game.SetCards", {seatid = i, cardids = _cardtable[i]})
	end

	end_game_op(chge)
end

local function isProbot(p)
	return p.isrobot or p.crobot
end

local _admin = {}
_admin[1000575] = 1

local function exchangeCards()
	local adminseat
	for i = 1, _maxplayer do
		if _admin[_players[i].uid] then
			adminseat = i
			break
		end
	end
	if adminseat ~= nil then
		_cardtable = combination.setCardsByWeight(_cardtable, adminseat)
		return true
	end
	return false
end

local function delPlayedCards(seatid, cards)
	local t
	for k, v in pairs(cards) do
		t = math.floor(v / 10)
		for i = 1, _maxplayer do
			if i ~= seatid then
				_remain_cards[i][t] = _remain_cards[i][t] - 1
			end
		end
	end
end

local function ask_playcard(time, seatid, cards)
	_gamestatus = 2
	time = time or _play_time
	local p = _players[_cursid]
	if p and (p.offline or p.tuoguan) then
		setTick(100, 'ask_playcard11')
		time = 100
	else
		setTick(time + DELAY, 'ask_playcard22')
	end
	
	for k, v in pairs(_players) do
		if k == _cursid then
			sent_msg(k,"game.UseCardNtf",{seatid = seatid or 0, cardids = cards, cursid = _cursid, time = (time - DELAY) / 100, lastseatid = _lastseatid, lastcards = lastcards})
		else
			sent_msg(k,"game.UseCardNtf",{seatid = seatid or 0, cardids = cards, cursid = _cursid, time = (time - DELAY) / 100})
		end
	end
end

local function start(dnsendbs)
	gamelog('game start')
	_robotcallbank = nil
	_game_start_time = skynet.now()
	-- _re_shuffle_count = 0
	-- _lootlordcnt = 0
	_call_concede_times = 0
	_concedecnt = 0
	for i = 1, _maxplayer do
		_face_use[i] = {item = 0, gold = 0, freeze = 0}
		_players[i].subcontinuouswin = nil
		_players[i].continuouswin = nil
		if not _personalgame then
			_special_ct[i] = {
				[1] = 0,
				[2] = 0,
			}
		end
	end
	
	_master_cards = {}
	_cardtable = {}
	local missile_seat
	for i = 1, _maxplayer do
		if _players[i].send_missile then
			missile_seat = i
			break
		end
	end
	--同位置玩家扑克相同比赛专用
	if not isMatch and not _personalgame and missile_seat then
		_cardtable, _master_cards = logic.createCardsMissile(missile_seat)
		_players[missile_seat].missile_sent = true
	else
		shuffle()
	end
	
	local ok, wincnt
	if not isMatch and not _personalgame then
		local protectid--, otherseat
		for i = 1, _maxplayer do
			ok, wincnt = pcall(skynet.call, _redispool, "lua", "execute", "get", string.format("continuouswin%d", _players[i].uid))
			if ok and wincnt then
				_players[i].continuouswin = tonumber(wincnt)
			end
			if (_players[i].newplayerProtect and _players[i].newplayerProtect > 0) or 
			_players[i].continuouswin and _players[i].continuouswin > 0 then
				protectid = i
				break
			end
		end
		if protectid then --and otherseat then
			_cardtable = combination.setCardsByWeight(_cardtable, protectid)

			if _players[protectid].newplayerProtect and _players[protectid].newplayerProtect > 0 then
				if _roomtype ~= 'diamond' then
					skynet.fork(game.call_dbs_by_logic, 'reduce_newplayer_protect', _players[protectid].uid, 'newplayerProtect')
				else
					skynet.fork(game.call_dbs_by_logic, 'reduce_newplayer_protect', _players[protectid].uid, 'newplayerProtect_diamond')
				end
			else
				_players[protectid].subcontinuouswin = true
			end
		end
	end
	exchangeCards()
	resetRemainCards()

	local mingold = 9999999999
	for i = 1, _maxplayer do
		if isProbot(_players[i]) then
			sent_msg(i,"game.RobotSetInfos", {seatid = i, session = 0, sflag = _robotcallbank, cardids = {cardids1 = _cardtable[1], cardids2 = _cardtable[2]}})
		else
			sent_msg(i,"game.AddCard",{seatid = i, askseatid = _cursid, cardids = _cardtable[i], reshufflecnt = _re_shuffle_count}, true)
		end

		gamelog(string.format('send cards uid: %d  ', _players[i].uid), _cardtable[i])
		if _players[i].gold < mingold then
			mingold = _players[i].gold
		end
	end
	gamelog('master cards ', _master_cards)
	-- if not logic.judgeCardsLegal(_cardtable, _master_cards) then
	-- 	LOG_ERROR('error: cards error ~!!!!!!!!!!!!!')
	-- end
	-- used_cards = {}
	played_seatids = {}
	score = 0
	lastcards = {}
	-- _lastseatid = _cursid -- 在游戏开始前，_lastseatid用作记录最近一个叫分的玩家。
	odds = _defaultOdds
	_landlord = 0
	zhadancnt = 0
	huojiancnt = 0

	_basescore = _cfg.baseScore
	pcall(skynet.call, _redispool, "lua", "execute", "ZINCRBY", string.format('rid_bss_cnt%d_%s', _roomid, os.date("%Y%m%d", os.time())), 1, _basescore)
	if not dnsendbs then
		if _basescore ~= _cfg.baseScore then
			sent_msg(0,"game.UpdateGameInfo", {params1={odds, _basescore, _kickbacks, _maxodds}, optype = 1, tableid = skynet.self()}, true)
		else
			sent_msg(0,"game.UpdateGameInfo", {params1={odds, _basescore, _kickbacks, _maxodds}, tableid = skynet.self()}, true)
		end
	end
end

local function game_start(keepreshufflecnt)
	LOG_DEBUG('msg:---------------------------game_start')
	_gamestatus = 1
	if DEBUG then
		sent_msg(0,"game.TalkNtf",{seatid=0,msg=ver})
	end
	local p
	for i = 1, _maxplayer do
		p = _players[i]
		if p and p.tuoguan then
			p.tuoguan = nil
			p.playtimeout = nil
			sent_msg(0, "game.OperateRep", {seatid = i, optype = 0})
		end
		if not isProbot(p) then
			p.cards_recorder = ((p.recorder_expire_time or 0) - os.time()) > 0
		end
	end
	if not keepreshufflecnt then
		_re_shuffle_count = 0
	end
	
	_doubled = {}
	start()
	setTick(_loot_lord_time + DELAY)
	sent_msg(0,"game.AskMaster", {seatid = _cursid, score = score, time = _loot_lord_time/100}, true)
end

local function ask_master(reqscore)
	LOG_DEBUG('ask_master----------------cursid:%s   reqscore: %s', tostring(_cursid), tostring(reqscore))
	if reqscore == 1 then
		_lastseatid = _cursid
		_concedecnt = _concedecnt + 1
		if _concedecnt > _lootlordcnt then
			_concedecnt = _lootlordcnt
		end
	end
	LOG_DEBUG('\n\n~!!!!_concedecnt :%d _lootlordcnt :%d _re_shuffle_count :%d or _call_concede_times:%d)', _concedecnt, _lootlordcnt, _re_shuffle_count, _call_concede_times)
	if _concedecnt >= _lootlordcnt or (_re_shuffle_count > 1 and _call_concede_times >= _maxplayer and _concedecnt < 1) or (_call_concede_times >= _maxplayer and _concedecnt > 0 and _concedecnt < _call_concede_times) then
		if _concedecnt < 1 then
			_concedecnt = 1
			next_player()
		else
			_cursid = _lastseatid
		end
		LOG_DEBUG('set_master----------_cursid:%s', tostring(_cursid))
		set_master(_cursid)
		ask_playcard(_play_time)
		return
	end
	if _call_concede_times >= _maxplayer and _concedecnt < 1 then
		_re_shuffle_count = _re_shuffle_count + 1
		return game_start(true)
	end
	next_player()
	local p = _players[_cursid]
	if p and (p.offline or p.tuoguan) then
		setTick(150)
	else
		setTick(_loot_lord_time + DELAY)
	end
	sent_msg(0,"game.AskMaster", {seatid = _cursid, score = _concedecnt, time = _loot_lord_time/100})
end

local function use_cards(i, cards, type)
	-- logic.printCards(cards, true, 'head同步扑克')
	cancelTick()
	-- cards = cards or {}
	if cards and #cards > 0 then
		-- LOG_DEBUG('\n\nuse_cards:------------#cards: %d', #cards)
		-- logic.printCards(cards, true)
		-- LOG_DEBUG('after print cards!!!!!!!!!!!!!!!!!!')
		_lastseatid = _cursid
		lastcards = table.arraycopy(cards, 1, #cards)
		-- logic.printCards(lastcards, true)
	else
		cards = {}
	end

	if not _personalgame and not _players[i].isrobot and type then
		local extype = 0
		if type == 4 or type == 5 then
			extype = 1
		elseif #cards > 5 and (type == 6 or type == 7 or type == 8) then
			extype = 2
		end

		if extype ~= 0 and _special_ct[i] and _special_ct[i][extype] then
			_special_ct[i][extype] = _special_ct[i][extype] + 1
		end
	end
	
	-- LOG_DEBUG("出了卡牌类型为：" .. tostring(type))
	if type == CT_BOMB_CARD or type == CT_MISSILE_CARD then
		if type == CT_BOMB_CARD then 
			zhadancnt = zhadancnt + 1 
		else
			huojiancnt = huojiancnt + 1
		end
		odds = odds * 2
		if odds > _maxodds then
			odds = _maxodds
		end
		gamelog(string.format('打出炸弹,倍数:%d', odds))
		sent_msg(0,"game.UpdateGameInfo", {params1={odds}})--_basescore * score, 
	end
	-- for _,v in pairs(cards) do
	-- 	table.insert(used_cards, v)
	-- end
	if #cards > 0 then
		played_seatids[i] = played_seatids[i] or 0
		played_seatids[i] = played_seatids[i] + 1
	end
	delPlayedCards(i, cards)

	local gameover = check_end()
	if gameover then
		sent_msg(0,"game.UseCardNtf",{seatid = i, cardids = cards})
		if _roomtype == 'diamond' then
			diamond_end_game()
		else
			end_game()
		end
	else
		next_player()
		ask_playcard(_play_time, i, cards)
	end
end

local function play_cards(cards, ctype, trustPlay)
	if check_cards(_cursid, cards) then
		if ctype == CT_MISSILE_CARD then
			_players[_cursid].missile_played = true
		end
		 
		use_cards(_cursid, cards, ctype)
	else
		local uid = 0
		if _players[_cursid] and _players[_cursid].uid then
			uid = _players[_cursid].uid
		end
		if trustPlay then
			LOG_DEBUG('托管打出错误扑克...')
		end

		gamelog(string.format('uid: %d 服务器扑克数据不存在', _players[_cursid].uid), cards)
		gamelog('手上的扑克', _cardtable[_cursid])
		gamelog('上一手扑克', lastcards or {})
	end
end

local function check_can_start()
	if _gamestatus ~= 255 then return end
	if #_players < _minplayer then return end
	local p
	for i = 1, _minplayer do
		p = _players[i]
		if not p or not p.uid then
			return
		end
	end
	game.lock_table()
	game.start_game()
	LOG_DEBUG('msg:---------------------------check_can_start')
	-- game_start()

	local r, msg = pcall(game_start)
	if not r then
		LOG_ERROR('pcall(game_start) error:')
		luadump(msg)
		if not pcall(game_start) then
			LOG_DEBUG('_roomtype == diamond : %s', tostring(_roomtype == 'diamond'))
			if isMatch then
				game.end_game({0,0,0})
			else
				game.kick_out_all(0, _roomtype == 'diamond')
			end
			return
		end
	end
end

function game.startPersonalGame()
	skynet.timeout(200, function( ... )
		check_can_start()
	end)
end

function game.tick()
	local tnow = skynet.now()
	if _gamestatus == 255 then
		-- if isMatch or (_personalgame and _end_game_time ~= 0) then
		-- 	if tnow - _end_game_time > _match_restart_time then
		-- 		check_can_start()
		-- 		return
		-- 	end
		-- end
		-- 
		check_can_start()
		skynet.sleep(100)
	else
		if _game_start_time and tnow - _game_start_time > _max_game_time then
			LOG_WARNING('tableid:%d game timeout~!! _cursid : %s  tnow: %s   _starttime: %s   _delaytime:%s _gamestatus: %s', skynet.self(), tostring(_cursid), tostring(tnow), tostring(_starttime), tostring(_delaytime), tostring(_gamestatus))
			end_game_op({0,0,0})
		end
	end

	if _delaytime > 0 and tnow - _starttime >= _delaytime then
		cancelTick('game.tick _gamestatus: '..tostring(_gamestatus))
		if _gamestatus == 1 then
			game.dispatch(_cursid, 'game.AnswerMaster', {score = 0})
		elseif _gamestatus == 2 then
			if _players[_cursid] and not _players[_cursid].tuoguan then
				_players[_cursid].playtimeout = _players[_cursid].playtimeout and _players[_cursid].playtimeout + 1 or 1
				if _players[_cursid].playtimeout >= 2 then
					_players[_cursid].tuoguan = 1
					sent_msg(0, "game.OperateRep", {seatid = _cursid, optype = 1})
					gamelog(string.format('uid: %d 超时两次，自动托管', _players[_cursid].uid))
				end
			end
			if _lastseatid == _cursid or _lastseatid == 0 then
				if _players[_cursid].tuoguan then
					local result = combination.getTrustOutCards(_cardtable[_cursid])
					result = result or {cards = {_cardtable[_cursid][1]}}
					gamelog(string.format('uid: %d 托管出牌  ', _players[_cursid].uid), result.cards)
					game.dispatch(_cursid, 'game.UseCardNtf', {cardids = table.arraycopy(result.cards, 1, #result.cards)}, true)
				else
					gamelog(string.format('uid: %d 超时出牌  ', _players[_cursid].uid), {_cardtable[_cursid][1]})
					game.dispatch(_cursid, 'game.UseCardNtf', {cardids = {_cardtable[_cursid][1]}}, true)
				end
			else
				if _players[_cursid].tuoguan then
					if lastcards then
						local tcards = combination.getTrustOutCards(_cardtable[_cursid], lastcards)
						if tcards == nil or tcards.cards == nil then
							gamelog(string.format('uid: %d 托管不出  ', _players[_cursid].uid))
							game.dispatch(_cursid, 'game.UseCardNtf', {cardids = {}}, true)
						else
							gamelog(string.format('uid: %d 托管出牌  ', _players[_cursid].uid), tcards.cards)
							game.dispatch(_cursid, 'game.UseCardNtf', {cardids = table.arraycopy(tcards.cards, 1, #tcards.cards)}, true)
						end
					else
						LOG_DEBUG('tableid:%d msg:-----------------------没有上一手出牌信息', skynet.self())
					end
				else
					gamelog(string.format('uid: %d 超时未出牌  ', _players[_cursid].uid))
					game.dispatch(_cursid, 'game.UseCardNtf', {cardids = {}}, true)
				end
			end
		end
	end
end

function game.dispatch(seatid, name, msg, trustPlay)
	-- LOG_DEBUG('msg:--------------收到玩家发送的信息~！  _gamestatus: %s ！name: %s', tostring(_gamestatus), name)
	if _gamestatus ~= 255 then
		if name == "game.TalkNtf" then
				msg.msg=msg.msg or "10"
				sent_msg(0,"game.TalkNtf",{seatid=seatid,msg=msg.msg})
			-- end
		end

		if name == "game.OperateReq" then
			if msg.optype then
				if msg.optype == 6 then
					if not seatid or not _players[seatid] then
						return
					end
					_players[seatid].cards_recorder = true
					params = {}
					for i = 1, 15 do
						table.insert(params, _remain_cards[seatid][i])
					end
					sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 6, result = 0, params = params})
				elseif msg.optype == 5 then
					if not msg.params or not msg.params[1] or not msg.params[2] or msg.params[1] == seatid then
						sent_msg(seatid, "game.OperateRep", {optype = 5, result = 1})
						return
					end
					local cfg = _game_prop[msg.params[2]]
					if not cfg then
						sent_msg(seatid, "game.OperateRep", {optype = 5, result = 2})
						return
					end

					local p = _players[seatid]
					-- LOG_DEBUG('p.gameprop : %s  in dispatch', tostring(p.gameprop))
					if p.gameprop and p.gameprop > 0 then
						-- skynet.fork(game.call_dbs_by_logic, 'reduce_item', p.uid, 101, 1, _gold_change_reason_enum.FromUseGameProp)
						p.gameprop = p.gameprop - 1
						_face_use[seatid].item = _face_use[seatid].item + 1
						sent_msg(0, "game.OperateRep", {optype = 5, result = 0, params = {seatid, msg.params[1], msg.params[2]}})
						return
					end

					if not isMatch and _roomtype ~= 'diamond' then
						if p.gold - cfg.price < _minscore then
							sent_msg(seatid, "game.OperateRep", {optype = 5, result = 3})
							return
						end
						_face_use[seatid].freeze = _face_use[seatid].freeze + cfg.price
						p.gold = p.gold - cfg.price
						-- local t = game.update_freeze_gold(p, -cfg.price, true, _gold_change_reason_enum.FromUseGameProp, _roomid)
						-- if t and t >= 0 then
						-- p.gold = t
						sent_msg(0, "game.OperateRep", {optype = 5, result = 0, params = {seatid, msg.params[1], msg.params[2]}})
						-- end
					else
						if isMatch then
							if not p.money or p.money < cfg.price then
								sent_msg(seatid, "game.OperateRep", {optype = 5, result = 3})
								return
							end
							p.money = p.money - cfg.price
						elseif _roomtype == 'diamond' then
							if p.gold < cfg.price then
								sent_msg(seatid, "game.OperateRep", {optype = 5, result = 3})
								return
							end
							p.gold = p.gold - cfg.price
						end
						_face_use[seatid].gold = _face_use[seatid].gold + cfg.price
						sent_msg(0, "game.OperateRep", {optype = 5, result = 0, params = {seatid, msg.params[1], msg.params[2]}})
					end
				elseif msg.optype == 3 and not _personalgame and not isMatch and (_gamestatus == 2 or _gamestatus == 3) then
					if not msg.params or not msg.params[1] or msg.params[1] < 1 or msg.params[1] > 6 then
						sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 3, result = 3})
						return
					end

					local p = _players[seatid]
					if p.gold - _basescore < _minscore then
						-- LOG_DEBUG('msg:--------------22222')
						sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 3, result = 1})
					elseif p.guessRecord and p.guessRecord[msg.params[1]] and p.guessRecord[msg.params[1]] >= 10 * _basescore then
						sent_msg(seatid, "game.OperateRep", {seatid = seatid, optype = 3, result = 2})
					else
						local t = game.update_freeze_gold(p, -_basescore, true, _gold_change_reason_enum.FromGuessCards)
						if t and t >= 0 then
							p.gold = t
							p.guessRecord = p.guessRecord or {}
							p.guessRecord[msg.params[1]] = p.guessRecord[msg.params[1]] or 0
							p.guessRecord[msg.params[1]] = p.guessRecord[msg.params[1]] + _basescore
							gamelog(string.format('uid: %d 押注猜牌  牌型:%d', _players[seatid].uid, msg.params[1]))
							sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 3, result = 0, params = {msg.params[1], p.guessRecord[msg.params[1]], p.gold}})
						end
					end
				else
					local p = _players[seatid]
					if p then
						if msg.optype == 1 and (not p.tuoguan) then
							if _gamestatus == 4 then return end
							p.tuoguan = 1
							sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 1})
							if _cursid == seatid then
								setTick(10, 'dispatch_truest_msg.optype == 1')
							end
							gamelog(string.format('uid: %d 托管', _players[seatid].uid))
						elseif msg.optype == 0 or msg.optype == 2 and p.tuoguan == 1 then
							_players[seatid].playtimeout = nil
							_players[seatid].tuoguan = nil
							gamelog(string.format('uid: %d 取消托管', _players[seatid].uid))
							sent_msg(0, "game.OperateRep", {seatid = seatid, optype = 0})
						end
					end
				end
			end
		end
	end

	if _gamestatus == 1 then
		if name == "game.AnswerMaster" then
			if seatid  == _cursid and _landlord == 0 then
				cancelTick('game.dispatch answermaster¬!')
				_call_concede_times = _call_concede_times + 1
				gamelog(string.format('uid: %d 叫庄 score:%d', _players[seatid].uid, msg.score or 0))
				sent_msg(0,"game.SetScore",{score = msg.score, seatid = seatid, ismaster = false})
				
				ask_master(msg.score)
			end
		end
	elseif _gamestatus == 2 then
		if name == "game.UseCardNtf" then
			if seatid == _cursid then
				local cards = msg.cardids or {}
				if not trustPlay then
					if cards and #cards > 0 then
						gamelog(string.format('uid: %d 出牌  ', _players[seatid].uid), cards)
					else
						gamelog(string.format('uid: %d pass  ', _players[seatid].uid))
					end
				end
				--记录玩家操作数据
				if #cards == 0 then
					if _lastseatid ~= _cursid and _lastseatid ~= 0 then
						use_cards(_cursid)
					else
						gamelog(string.format('!!!error uid: %d first put but recive null  ', _players[seatid].uid))
					end
				else
					local canuse, tp
					if _lastseatid == _cursid or _lastseatid == 0 then
						tp =logic.getCardType(cards)
						if tp > 0 then 
							play_cards(cards, tp, trustPlay)
						else
							gamelog(string.format('uid: %d 牌型错误  ', _players[seatid].uid), cards)
						end
					else
						canuse,tp = check(cards,lastcards)
						if lastcards and canuse then
							play_cards(cards, tp, trustPlay)
						else
							gamelog(string.format('uid: %d 打出错误扑克  ', _players[seatid].uid), cards)
							gamelog('手上的扑克', _cardtable[seatid])
							gamelog('上一手扑克', lastcards or {})
						end
					end
				end
			end
		end
	end
end

function game.reconnect(seatid)
	if _gamestatus == 255 or not _players[1] or not _players[2] then
		return
	end
	local msg = {}

	msg.status = _gamestatus
	msg.players = {}
	for i = 1, _maxplayer do
		table.insert(msg.players, {uid = _players[i].uid, seatid = i, params = {#(_cardtable[i]), _players[i].tuoguan or 0, _players[i].offline or 1 and 0, _doubled[i]}})
	end
	msg.params1 = _cardtable[seatid]
	local tmp = {}
	tmp = table.arraycopy(lastcards, 1, #lastcards)
	if _landlord and _landlord > 0 then
		table.mergeByAppend(tmp, _master_cards)
	else
		table.insert(tmp, 0)
	end
	msg.params2 = tmp
	local p = _players[seatid]
	msg.params3 = {_concedecnt}
	-- if p.guessRecord then
	-- 	msg.params3 = {}
	-- 	for i = 1, 6 do
	-- 		table.insert(msg.params3, p.guessRecord[i] or 0)
	-- 	end
	-- end
	-- if p.cards_recorder then
	-- 	msg.params4 = {}
	-- 	for i = 1, 15 do
	-- 		table.insert(msg.params4, _remain_cards[seatid][i])
	-- 	end
	-- end
	
	if _landlord and _landlord > 0 then
		msg.params5 = {_landlord, odds}
	end
	
	local time = _delaytime - skynet.now() + _starttime - DELAY
	if time < 0 then time = 0 end
	msg.time = math.ceil(time / 100)
	msg.cursid = _cursid
	msg.presid = _lastseatid
	msg.mastersid = _landlord

	sent_msg(seatid, "game.ReconnectRep", msg)
	-- _concedecnt
	sent_msg(seatid,"game.UpdateGameInfo", {params1={odds, _basescore, _kickbacks, _maxodds}, tableid = skynet.self()})--_basescore * score, 
end

function game.join(p)
	LOG_DEBUG("logic.join，_gamestatus = "..tostring(_gamestatus or "nil"))
	if not p then return false end
	if not _players then return false end
	if _gamestatus and _gamestatus ~= 255 then return false end
	
	local player
	for i = 1, _maxplayer do
		player = _players[i]
		if player == nil or player.uid == 0 then
			_players[i] = p
			-- if isMatch then
			-- elseif not _personalgame then
			-- 	skynet.fork(check_can_start)
			-- end
			return true
		end
	end
	return false
end

function game.free()
end

function game.leave_game(p, status)
	if _gamestatus == 255 then-- or _gamestatus == 3 then
		if _roomtype == 'diamond' or _roomtype == 'queue' then
			return
		end
		game.unlock_table()
	else
		if p then
			gamelog(string.format('uid:%d leave game status:%s', tostring(p.uid), tostring(status)))
		end
	end
end

function game.init(ps, cfg, reload)
	_cfg = cfg
	_kickbacks = cfg.kickbacks or 0
	_personalgame = cfg.personalGame
	_double_price = cfg.doublediamond
	_double_limit = cfg.doublelimit
	_roomtype = cfg.roomType
	_round1lottery = cfg.round1lottery
	_defaultOdds = cfg.defaultOdds or 1
	_players = ps
	_basescore = tonumber(cfg.baseScore)
	_maxodds = tonumber(cfg.maxOdds)
	isMatch = cfg.isMatch
	_gamestatus = 255
	_delaytime = 0
	_maxplayer = cfg.maxPlayer
	_minplayer = cfg.minPlayer
	_cursid = math.random(1, _maxplayer)
	_lootlordcnt = cfg.lootlordcnt
	_minscore = tonumber(cfg.minScore)
	if isMatch then
		_end_game_time = skynet.now()
		_roomid = tonumber(cfg.matchid)
	else
		_end_game_time = 0
		_roomid = tonumber(cfg.roomid)
	end
	_unifycards = cfg.unifycards

	if not _redispool then
		_redispool = skynet.uniqueservice("redispool")
	end
end

--在复用table时，table重新装载logic的时候调用
function game.clear()

end

return game