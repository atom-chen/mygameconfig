
--
-- Author: cyj
-- Date: 2015-10-20 17:35:26
--


local config = {}

--最大创建房间数量
config.max_own_amount = 1
--创建房间需要的金币
-- config.create_game_cost = 0

--自动解散超时未开始时间
config.auto_release_timeout = 10

--报名费用选项
-- config.signupCost = {0}

-- config.enterCondition = {1000, 10000, 100000}

config.gameHash = {
	[1] = {gameType = 'ddz'},
	[2] = {gameType = 'dzniuniu'},
	[8] = {gameType = '4nn'},
	[3] = {gameType = 'combullfight'}
}

config["ddz"] = {
	name = '斗地主',
	stageid = 10000,
	gameType = "ddz", 
	maxPlayer = 3,
	minPlayer = 3,
	-- duration = {1, 15, 30, 60},
	basescore = {10, 2000, 4000, 10000},
	-- createcost = {0, 1000, 2000, 5000},
	createcost = {0, 10, 20, 30},
	kickbacks = {150, 1000, 2000, 5000},
	maxodd = {12, 48, 192},
	scorelimit = {1000, 10000, 100000},
	-- initscore = {20, 100, 200, 500},
	roundcnt = {3, 6, 9, 15},
}

return config