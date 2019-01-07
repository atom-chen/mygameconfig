require 'group_analyse/functionsxx'  

local type2data = {}


type2data['match'] = {index = 1, match = 1, gameID = 'match', status = 0, text = '比赛', icon = 'res/.png'}
type2data['ddz'] = {index = 2, gameEngine = 'flash' ,startup = 'games/flash/doudizhu/ddz.swf', text = '斗地主', status = 0, icon = 'res/.png'}
type2data['zjh'] = {index = 3, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['showhand'] = {index = 4, gameEngine = 'cocos' ,startup = 'games/cocos/Gswz/', text = '港式五张', status = 1, icon = 'res/.png'}
type2data['dzniuniu'] = {index = 5, gameEngine = 'flash' ,startup = 'games/flash/bullfight/bullfight.swf', text = '对战牛牛', status = 2, icon = 'res/.png'}
type2data['4nn'] = {index = 6, gameEngine = 'flash' ,startup = 'games/flash/4nn/4nn.swf', text = '通比牛牛', status = 2, icon = 'res/.png'}
type2data['combullfight'] = {index = 7, gameEngine = 'flash' ,startup = 'games/flash/combullfight/combullfight.swf', text = '抢庄牛牛', status = 0, icon = 'res/.png'}
type2data['100nn'] = {index = 8, gameEngine = 'flash' ,startup = 'games/flash/100nn/100nn.swf', text = '百人牛牛', status = 0, icon = 'res/.png'}
type2data['doublebuckle'] = {index = 9, gameEngine = 'flash' ,startup = 'games/flash/doublebuckle/doublebuckle.swf', text = '双扣', status = 0, icon = 'res/.png'}
type2data['buyu'] = {index = 10, gameEngine = 'unity3d' ,startup = 'games/unity3d/fish/fish.exe', text = '捕鱼', status = 0, icon = 'res/.png', topTitle = {"捕鱼模式", "捕鱼人数", "炮台底分", "入场金币"}}
type2data['happylandlord'] = {index = 11, gameEngine = 'flash' ,startup = 'games/flash/hplandlord/hplandlord.swf', text = '欢乐斗地主', status = 0, icon = 'res/.png'}
type2data['dzpoker'] = {index = 12, gameEngine = 'cocos' ,startup = 'games/cocos/Dzpoker/', text = '德州扑克', status = 1, icon = 'res/.png'}
type2data['mahjong'] = {index = 13, gameEngine = 'flash' ,startup = 'games/flash/mj/MJ.swf', text = '麻将', status = 0, icon = 'res/.png'}
type2data['1000nn'] = {index = 14, gameEngine = 'flash' ,startup = 'games/flash/1000nn/1000nn.swf', text = '千人牛牛', status = 0, icon = 'res/.png'}
type2data['roundNN'] = {index = 15, gameEngine = 'flash' ,startup = 'games/flash/1000nn/1000nn.swf', text = '车轮牛牛', status = 0, icon = 'res/.png'}
type2data['ddz2'] = {index = 16, gameEngine = 'flash' ,startup = 'games/flash/1000nn/1000nn.swf', text = '残局挑战', status = 0, icon = 'res/.png'}
type2data['tommorow'] = {index = 7, gameEngine = 'flash' ,startup = 'games/flash/combullfight/combullfight.swf', text = '抢庄牛牛', status = 0, icon = 'res/.png'}
type2data['texasholdem'] = {index = 18, gameEngine = 'flash' ,startup = 'games/flash/combullfight/combullfight.swf', text = '德州扑克', status = 0, icon = 'res/.png'}
type2data['bankernn'] = {index = 19, gameEngine = 'flash' ,startup = 'games/flash/combullfight/combullfight.swf', text = '抢庄牛牛', status = 0, icon = 'res/.png'}
type2data['goldenflower'] = {index = 20, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['linkgame'] = {index = 21, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['2048'] = {index = 22, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['turnsamecards'] = {index = 23, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['pdk'] = {index = 24, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['ddz2'] = {index = 25, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}

type2data['knife'] = {index = 26, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}
type2data['chickencompare'] = {index = 27, gameEngine = 'cocos' ,startup = 'games/cocos/Zjh/', text = '诈金花', status = 2, icon = 'res/.png'}

local util = require 'ai_util'
local serverConfig = require 'room_conf'
local matchConfig = require 'match_config'

local group_conf = require 'group_conf'
local group_rooms = {}
--util.printTable(matchConfig)

local function insert_group(room)
	-- luadump(group_conf)
	util.printTable(group_conf)
	for k, v in pairs(group_conf) do
		if util.vInTbl(v.roomid, room.roomID) or util.vInTbl(v.roomid, room.matchId) then
			group_rooms[k] = group_rooms[k] or {}
			table.insert(group_rooms[k], room)
			return
		end
	end
end

local filter_match = {
	-- forbidRobot = 1,
	groupModel = 1,
	enterTimeout = 1,
	extraMoney = 1,
	hotUpdate = 1,
	rolltime = 1,
}

local function insertMatch(container, gtype, gindex)
	--print('msg:-------------------gtype: '..tostring(gtype))
	local ret = 0
	for k, v in pairs(matchConfig) do
		for k1, v1 in pairs(v) do
			--print('msg:---------k: '..tostring(k)..'----------v.gameType: '..tostring(v.gameType))
			--util.printTable(v)
			if v1.gameType == gtype then
				--print('msg:---------find match config')
				local item = {}
				item.gindex = gindex
				item.roomType = 2
				for k2, v2 in pairs(v1) do
					if k2 ~= 'stage' then
						if not filter_match[k2] then
							if type(v2) == 'table' then
								item[k2] = util.copyTab(v2)
							else
								item[k2] = v2
								if k2 == "entryMoney" then
									item[k2] = item[k2]
								end
							end
						end
					else
						item[k2] = {}
						-- util.printTable(v2)
						for i = 1, #v2 do
							item[k2][i] = {}
							for k3, v3 in pairs(v2[i]) do
								if k3 == 'kickOutOdds' or k3 == 'chip' 
									or k3 == 'option' or k3 == 'playerIn' 
                  or k3 == 'playerOut' or k3 == 'handCount' or k3 == 'startTimeout' or k3 == 'maxLastTime' or k3 =='kickScore' or k3 =='type' or k3 == 'roundPlayer' then
									if type(v3) == 'table' then
										item[k2][i][k3] = util.copyTab(v3)
									else
										item[k2][i][k3] = v3
									end
								elseif k3 == 'baseScore' then
									item[k2][i][k3] = {}
									for k4, v4 in pairs(v3) do
										local temp = {}
										temp[1] = k4
										temp[2] = v4
										table.insert(item[k2][i][k3], temp)
									end

									table.sort(item[k2][i][k3], function(t1, t2)
										return t1[1] < t2[1]
									end)
								end
							end
						end
					end
				end
				table.insert(container, item)
				ret = 1
				-- insert_group(item)
			end
		end
	end
	return ret
end

local match = {}
for k, v in pairs(type2data['match']) do
	match[k] = v
end

match.rooms = {}

local clientConfig = {}
local rjsConfig = {}

local hashTable = {}

local filter_room = {
	robot = 1,
	minrobot = 1,
	maxrobot = 1,
	changeTableThresholdDown = 1,
	changeTableThresholdUp = 3,
	leaveThresholdDown = 5,
	leaveThresholdUp = 1,
	record_playinfo = 1,
	maxCRobotCnt = 1,
	-- guessbet = 1,
	--poolsupport = 1,
	roomType = 1,
	--rewardround= 1,
	waitingsec = 1
}

local roomid2maxredcoin = {
  [1000] = '玩3局抽奖杯',
  [8003] = '玩1局抽奖杯',
  [8004] = '玩1局抽奖杯',
  
  [1001] = '赢5局抽奖杯',
  [1002] = '赢3局抽奖杯',
  [1006] = '赢1局抽奖杯',
  
  [8000] = '玩2局抽奖杯',
  [8001] = '赢1局抽奖杯',
  [8002] = '5分钟爆福袋',
  
  [9000] = '赢5局抽奖杯',
  [9001] = '赢3局抽奖杯',
  [9003] = '赢1局抽奖杯',
  
  [9002] = '玩3局抽奖杯',
  [9004] = '赢1局抽奖杯',
  [9005] = '赢1局抽奖杯',
  
  [10001] = '赢5局抽奖杯',
  [10002] = '赢3局抽奖杯',
  [10003] = '赢1局抽奖杯',
  
  [10004] = '玩3局抽奖杯',
  [10005] = '玩2局抽奖杯',
  [10006] = '玩1局抽奖杯',
}

local roomflagname = {
  [1000] = '最高5奖杯',
  [1006] = '最高100奖杯',
  [8003] = '最高100奖杯',
  [8004] = '最高100奖杯',
  [8000] = '最高50奖杯',
  
  [1001] = '欢乐三人场',
  [1002] = '欢乐三人场',
  [8001] = '刺激二人场',
  [8002] = '刺激二人场',
  

  [9002] = '最高5奖杯',
  [9004] = '最高50奖杯',
  [9005] = '最高100奖杯',
  
  [10004] = '最高5奖杯',
  [10005] = '最高50奖杯',
  [10006] = '最高100奖杯',
}

--luadump(serverConfig)
local findfish = true
local findlinkgame
while findfish or findlinkgame do -- filter fish
  findfish = false
  findlinkgame = false
  for k, v in pairs(serverConfig) do
    if v.gameType == 'fish' then-- or v.gameType == 'linkgame' then
      serverConfig[k] = nil
      --table.remove(serverConfig, k, 1)
      findfish = true
      break
    end
  end
  --print(string.format('-----findfish:%s', tostring(findfish)))
end

for k, v in pairs(serverConfig) do
  -- util.printTable(v)
	if hashTable[v.gameType] == nil then
		hashTable[v.gameType] = #clientConfig + 1
		 print('msg:----------------------hashTable[v.gameType]: '..tostring(hashTable[v.gameType])..'   v.gameType:  '..tostring(v.gameType))
		local t = {}
		for k1, v1 in pairs(type2data[v.gameType]) do
			t[k1] = v1
		end
		t.gameID = math.floor(k / 1000)
		t.rooms = {}
		table.insert(clientConfig, t)
		table.insert(rjsConfig, util.copyTab(t))
		insertMatch(rjsConfig[hashTable[v.gameType]].rooms, v.gameType)

		-- table.insert(match, util.copyTab(clientConfig[hashTable[v.gameType]]))
		-- match[#match].rooms = {}
		insertMatch(match.rooms, v.gameType, type2data[v.gameType].index)
		-- if  == 0 then
		-- 	table.remove(match, #match)
		-- end
	end

	local room = {roomType = 1, roomID = k, style = v.roomType}--, text = v.name, players_amount = 101, basic_score = v.baseScore, basic_gold = v.minScore}
  if roomid2maxredcoin[k] then
    room.roomid2maxredcoin = roomid2maxredcoin[k]
  end
  
  if roomflagname[k] then
    room.roomflagname = roomflagname[k]
  end
  --if v.roomType == 'diamond' then
  --  room.roomType = 10
  --end
  if v.roomType == 'diamond' then
      room['roomFlag'] = 2
    else
      room['roomFlag'] = 1
    end
	for k1, v1 in pairs(v) do
		-- if k1 ~= 'roomType' and k1 ~= 'robot' then
		if not filter_room[k1] then
			if type(v1) == 'table' then
				room[k1] = util.copyTab(v1)
			else
				room[k1] = v1
				--if k1 == "minScore" or k1 == "maxScore" or k1 == "baseScore" then
				--	room[k1] = room[k1] / 100
				--end
			end
		end
	end
	-- util.printTable(clientConfig)
	table.insert(clientConfig[hashTable[v.gameType]].rooms, room)

	table.insert(rjsConfig[hashTable[v.gameType]].rooms, util.copyTab(room))
	-- insert_group(room)
end

if match and next(match.rooms) then
	table.insert(clientConfig, 1, match)
end

local function sortRooms(rconfig)
	table.sort(rconfig, function(g1, g2)
		return g1.index < g2.index
	end)
	for k, v in pairs(rconfig) do
		-- print('\n\n\n\n')
		-- util.printTable(v.rooms)
		table.sort(v.rooms, function(r1, r2)
			if r1.gindex ~= r2.gindex then
				return r1.gindex < r2.gindex
			elseif r1.roomID ~= nil and r2.roomID ~= nil then
				return r1.roomID < r2.roomID
			elseif r1.matchId ~= nil and r2.matchId ~= nil then
				return r1.matchId < r2.matchId
			else
				return r1.roomID ~= nil
			end
		end)
	end
end

sortRooms(clientConfig)
sortRooms(rjsConfig)

for k, v in pairs(clientConfig) do
	if v.index ~= k then
		v.index = k
		-- util.printTable(clientConfig[1].rooms)
		for k1, v1 in pairs(clientConfig[1].rooms) do
			-- print('\n\n')
			-- util.printTable(v1)
			-- print('\n\n')
			-- assert(v1.matchId)
			if v1.matchId and v1.gameType == v.rooms[1].gameType then
				v1.gindex = v.index
			end
		end
	end
end

for k, v in pairs(rjsConfig) do
	v.index = k
end


local json = require('json4lua-master/json/json')

local function writeluajson(conf, filename, jsononly)
	if not jsononly then
		local tmp = util:serializeTable(conf)
		print('local conf = '..tmp..'\nreturn conf')

		local file1=io.output(filename..'.lua')
		io.write('local conf = '..tmp..'\nreturn conf')
		io.flush()
		io.close()
	end
	  
	-- Object to JSON encode
	local jsonText = json.encode(conf)
	print('\n\n--------------------------------------------------------------------------json--------------------------------------------------------------------------\n\n')
	print(jsonText)

	local file2=io.output(filename..'.json')
	io.write(jsonText)
	io.flush()
	io.close()
end

-- for k, v in pairs(group_rooms) do
-- 	writeluajson(v, k)
-- end

--writeluajson(clientConfig, 'roomListConfig')
writeluajson(rjsConfig, 'room', true)

local rid2gt = {}

for k, v in pairs(rjsConfig) do
	-- luadump(v.rooms)
	for k1, v1 in pairs(v.rooms) do
		--if v1.gameType == 'ddz' then
			if v1.roomID then
				rid2gt[tostring(v1.roomID)] = v1.gameType
			elseif v1.matchId then
				rid2gt[tostring(v1.matchId)] = v1.gameType
			end
		--end
	end
end

writeluajson(rid2gt, 'rid2gt', true)

for k, v in pairs(rjsConfig) do
  if v.gameID == 3 then
      writeluajson(v.rooms, 'challengerooms', true)
      break
  end
end

-- print('msg:----------------')
-- local tmp = util:serializeTable(match)
-- print('local conf = '..tmp..'\nreturn conf')

-- local file1=io.output("roomListConfig.lua")
-- io.write('local conf = '..tmp..'\nreturn conf')
-- io.flush()
-- io.close()
  
-- -- Object to JSON encode
-- local json = require('json4lua-master/json/json')

-- local jsonText = json.encode(clientConfig)

-- print('\n\n--------------------------------------------------------------------------json--------------------------------------------------------------------------\n\n')
-- print(jsonText)

-- local file2=io.output("roomListConfig.json")
-- io.write(jsonText)
-- io.flush()
-- io.close()

----[[
local temp = require 'item_conf'
local item_config = {}
for k, v in pairs(temp) do
  table.insert(item_config, v)
end

writeluajson(item_config, 'goods', true)
--]]
-- local jitem_config = json.encode(item_config)
-- print('\n\n--------------------------------------------------------------------jitem_config------------------------------------------------------------------------\n\n')
-- print(jitem_config)

-- local file3=io.output("item_conf.json")
-- io.write(jitem_config)
-- io.flush()
-- io.close()
----[[

local mission_config = require 'mission_config_nn'
writeluajson(mission_config, 'mission_config_nn', true)

local function convertRoomTask(conf)
  local rt = {}
  for k, v in pairs(conf.roomtask) do
    for k1, v1 in pairs(v) do
    	local t = util.copyTab(v1)
    	t.roomid = k
    	t.taskid = k1
    	table.insert(rt, t)
    end
  end
  writeluajson(rt, 'room_task', true)
end

local room_task = require 'room_task'
convertRoomTask(room_task)

local market_config = require 'market_config'
writeluajson(market_config, 'market_config', true)

local matchRule = require 'matchRule'
writeluajson(matchRule, 'match', true)

local red_coin = require 'red_coin'
local red_coin_exchange = {}
for k, v in pairs(red_coin.exchange) do
	table.insert(red_coin_exchange, v)
end
table.sort(red_coin_exchange, function(r1, r2)
	if r1.goodsid ~= r2.goodsid then
		return r1.goodsid < r2.goodsid
	else
		return r1.amount < r2.amount
	end
end)
--writeluajson(red_coin_exchange, 'red_coin_exchange', true)
writeluajson(red_coin.goods, 'red_coin_goods', true)
writeluajson(red_coin.diamondexchange, 'diamond_exchange', true)

local personalgame = require 'personalgame_config'
writeluajson(personalgame, 'personalgame', true)

local testers = require 'testers'
writeluajson(testers, 'testers', true)

--local recharge_optoins = require 'recharge_optoins'
--writeluajson(recharge_optoins, 'recharge', true)

local cards_recorder_buy_option = require 'cards_recorder_buy_option'
writeluajson(cards_recorder_buy_option, 'cards_recorder_buy_option', true)

local game_prop = require 'game_prop'
writeluajson(game_prop, 'game_prop', true)

--local national_day_config = require 'national_day_config'
--writeluajson(national_day_config, 'national_day_config', true)

--local badwords = require 'badwords'
--writeluajson(badwords, 'badwords', true)
local dbs_config = require 'dbs_config'
dbs_config.rewardcallback = nil
dbs_config.runquikc = nil
--xxxconvert2json(dbs_config, 'dbs_config')
writeluajson(dbs_config, 'dbs_config', true)

local xxxx
xxxx = function (conf)
  for k, v in pairs(conf) do
    if type(v) == 'table' then
      xxxx(v)
    elseif type(k) ~= 'string' then
			conf[tostring(k)] = v
			conf[k] = nil
		end
	end
end

local function xxxconvert2json(conf, fname)
	--[[for k, v in pairs(conf) do
		if type(k) ~= 'string' then
			conf[tostring(k)] = v
			conf[k] = nil
		end
	end--]]
  xxxx(conf)
	writeluajson(conf, fname, true)
end

local item_drop = require 'item_drop'
local cutcfg = item_drop[1000].cardtype
for k, v in pairs(cutcfg) do
	v.probability = nil
end
writeluajson(cutcfg, 'item_drop', true)


local day_task = require 'day_task'
xxxconvert2json(day_task, 'day_task')

--local fish_prop_conf = require 'fish_prop_conf'
--xxxconvert2json(fish_prop_conf, 'fish_prop_conf')

--local fish_conf = require 'fish_conf'
--xxxconvert2json(fish_conf, 'fish_conf')

--local fish_path_conf = require 'fish_path_conf'
--xxxconvert2json(fish_path_conf, 'fish_path_conf')

local server_group = require 'server_group'
xxxconvert2json(server_group, 'server_group')

local activity_config = require 'activity_config'
xxxconvert2json(activity_config, 'activity_config')

local drawcard_conf = require 'drawcard_conf'
xxxconvert2json(drawcard_conf, 'drawcard_conf')

local free_texasholdem_config = require 'free_texasholdem_config'
xxxconvert2json(free_texasholdem_config, 'free_texasholdem_config')

local vip_config = require 'vip_config'
xxxconvert2json(vip_config, 'vip_config')


local aaxxxx
aaxxxx = function (conf)
  for k, v in pairs(conf) do
    if type(k) ~= 'string' then
			conf[tostring(k)] = v
			conf[k] = nil
		end
    
    if type(v) == 'table' then
      aaxxxx(v)
    end
	end
  --luadump(conf)
end

local function aaaxxxconvert2json(conf, fname)
	--[[for k, v in pairs(conf) do
		if type(k) ~= 'string' then
			conf[tostring(k)] = v
			conf[k] = nil
		end
	end--]]
  
  aaxxxx(conf)
	writeluajson(conf, fname, true)
end

local friends_cfg = require 'friends_cfg'
aaaxxxconvert2json(friends_cfg, 'friends_cfg')


--]]