
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
config.auto_release_timeout = 30

--报名费用选项
-- config.signupCost = {0}

-- config.enterCondition = {1000, 10000, 100000}

config.gameHash = {
	-- [1] = {gameType = 'ddz'},
	[5] = {gameType = 'texasholdem'},
	-- [2] = {gameType = 'dzniuniu'},
	-- [8] = {gameType = '4nn'},
	-- [3] = {gameType = 'combullfight'}
}

config["texasholdem"] = {
	name = 'texasholdem',
	stageid = 50000,
	gameType = "texasholdem", 
	maxPlayer = 100,
	minPlayer = 2,
	duration = {30, 60, 120, 180, 240},
	blind = {{5, 10}, {10, 20}, {25, 50}, {50, 100}, {100, 200}, {200, 400}, {500, 1000}, {1000, 2000}},
	mintakein = {1000, 2000, 5000, 10000, 20000, 40000, 100000, 200000},
	maxtakein = {
		{2000, 3000, 4000, 6000, 99999999},
		{4000, 6000, 8000, 12000, 99999999},
		{10000, 15000, 20000, 30000, 99999999},
		{20000, 30000, 40000, 60000, 99999999},
		{40000, 60000, 80000, 120000, 99999999},
		{80000, 120000, 160000, 240000, 99999999},
		-- {160000, 240000, 320000, 480000, 99999999},
		{200000, 300000, 400000, 600000, 99999999},
		{400000, 600000, 800000, 1200000, 99999999},
	},

	-- basescore = {0, 1, 2},
	createcost = {0, 0, 0, 0},
	kickbacks = {0, 0, 0, 0},
	-- maxodd = {12, 48, 192},
	-- scorelimit = {1000, 10000, 100000},
	-- roundcnt = {3, 6, 9, 15},
}

return config