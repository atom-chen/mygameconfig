
--
-- Author: cyj
-- Date: 2015-10-20 17:35:26
--
local config = {}

config["match1"] = {
	{
		name = '冠军10奖杯',
		shortName  =  '8点到23点,每15分钟一场',
		sortid = 1,
		matchId = 109,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "ddz",									--游戏类型
		maxPlayer = 240,										--比赛最多人数
		minPlayer = 120,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		entryMoney = 2500,										--入场扣金币
		-- --entryDiamond = 5,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"08:00:00","08:15:00","08:30:00","08:45:00","09:00:00","09:15:00","09:30:00","09:45:00","10:00:00","10:15:00","10:30:00","10:45:00","11:00:00","11:15:00","11:30:00","11:45:00","12:00:00","12:15:00","12:30:00","12:45:00","13:00:00","13:15:00","13:30:00","13:45:00","14:00:00","14:15:00","14:30:00","14:45:00","15:00:00","15:15:00","15:30:00","15:45:00","16:00:00","16:15:00","16:30:00","16:45:00","17:00:00","17:15:00","17:30:00","17:45:00","18:00:00","18:15:00","18:30:00","18:45:00","19:00:00","19:15:00","19:30:00","19:45:00","20:00:00","20:15:00","20:30:00","20:45:00","21:00:00","21:15:00","21:30:00","21:45:00","22:00:00","22:15:00","22:30:00","22:45:00","23:00:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "ddz",						--游戏类型
				playerIn = 120,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 3,						--一局的最少人数
	 			maxPlayer   = 3,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {120, 48, 18, 0},				--每一阶段的人数	
				relivegold = {2500},
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:1000"},
			{rankstart = 2, rankend = 2, reward="1:400"},
			{rankstart = 3, rankend = 3, reward="1:200"},
			{rankstart = 4, rankend = 6, reward="1:100"},
			{rankstart = 7, rankend = 12, reward="1:50"},
			{rankstart = 13, rankend = 24, reward="1:20"},
			{rankstart = 25, rankend = 48, reward="1:10"},
		},
	},
}

config["match2"] = {
	{
		name = '冠军100奖杯',
		shortName  =  '每天20:30准点开赛',
		sortid = 6,
		matchId = 209,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "ddz",									--游戏类型
		maxPlayer = 1002,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		-- entryMoney = 5000,										--入场扣金币
		entryDiamond = 3,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2018-03-06T20:30:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"20:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "ddz",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 3,						--一局的最少人数
	 			maxPlayer   = 3,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 78, 36, 18, 9 , 0},				--每一阶段的人数	
				reliveDiamond = {3,5},
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:400"},
			{rankstart = 13, rankend = 24, reward="1:200"},
			{rankstart = 25, rankend = 36, reward="1:100"},
			{rankstart = 37, rankend = 72, reward="1:50"},
			{rankstart = 73, rankend = 120, reward="1:30"},
		},
	},
}

config["match3"] = {
	-- {
	-- 	name = '免费报名 冠军10奖杯',
	-- 	shortName  =  '8点到23点,每小时一场',
	-- 	sortid = 5,
	-- 	matchId = 303,										--比赛id[比赛服务id*100/+比赛子id] 
	-- 	matchType = 0,                                      --0是普通赛,1是金币赛
	-- 	--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
	-- 	-- forbidRobot = 1,									--禁用机器人		
	-- 	--showRealPlayers = 1,
	-- 	groupModel = 1,
	-- 	gameType = "ddz",									--游戏类型
	-- 	maxPlayer = 1002,										--比赛最多人数
	-- 	minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
	-- 	-- minPlayerIn = 3,                                   --
	-- 	startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
	-- 	maxDayPlayCnt = 99,									--每日最多次数
	-- 	enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
	-- 	entryMoney = 0,										--入场扣金币
	-- 	-- --entryDiamond = 5,
	-- 	extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
	-- 	showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
	-- 	hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
	-- 	startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
	-- 	cycleTime={"08:00:00","09:00:00","10:00:00","11:00:00","12:00:00","13:00:00","14:00:00","15:00:00","16:00:00","17:00:00","18:00:00","19:00:00","20:00:00","21:00:00","22:00:00","23:00:00"},					--一天中的循环时间
	-- 	cycleDay=1,               ---循环天数
	-- 	hotUpdate = 1, 										--支持热更新
	-- 	rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
	-- 	stage = {
	-- 		{
	-- 			type = "SWISSEX",					--打立出局+瑞士位移
	-- 			gameType = "ddz",						--游戏类型
	-- 			playerIn = 300,							--输入的玩家数量
	-- 			playerOut = 0,							--输出的玩家数量
	-- 			handCount = 6,							--一桌打几手牌
	-- 			baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
	-- 			maxOdds = 48,							--最大倍率
	-- 			defaultScore = 0,					--初始积分
	-- 			minPlayer	= 3,						--一局的最少人数
	--  			maxPlayer   = 3,						--一局最多
	-- 			adjustScore = 0,						--分差调整
	-- 			roundPlayer = {300, 0.5, 99, 45, 24, 12, 0},				--每一阶段的人数	
	-- 			relivegold = {2500,5000},
	-- 		},
	-- 	},

	-- 	reward = {
	-- 		{rankstart = 1, rankend = 1, reward="1:1000"},
	-- 		{rankstart = 2, rankend = 2, reward="1:400"},
	-- 		{rankstart = 3, rankend = 3, reward="1:200"},
	-- 		{rankstart = 4, rankend = 6, reward="1:100"},
	-- 		{rankstart = 7, rankend = 15, reward="1:50"},
	-- 		{rankstart = 16, rankend = 30, reward="1:20"},
	-- 		{rankstart = 31, rankend = 60, reward="1:10"},
	-- 	},
	-- },

	{
		name = '免费报名 冠军10奖杯',
		shortName  =  '8点到23点,每小时一场',
		sortid = 5,
		matchId = 304,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 1200,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		entryMoney = 0,										--入场扣金币
		-- --entryDiamond = 5,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"08:00:00","09:00:00","10:00:00","11:00:00","12:00:00","13:00:00","14:00:00","15:00:00","16:00:00","17:00:00","18:00:00","19:00:00","20:00:00","21:00:00","22:00:00","23:00:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 100, 48, 24, 12, 0},				--每一阶段的人数	
				relivegold = {2500,5000},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:1000"},
			{rankstart = 2, rankend = 2, reward="1:400"},
			{rankstart = 3, rankend = 3, reward="1:200"},
			{rankstart = 4, rankend = 6, reward="1:100"},
			{rankstart = 7, rankend = 15, reward="1:50"},
			{rankstart = 16, rankend = 30, reward="1:20"},
			{rankstart = 31, rankend = 60, reward="1:10"},
		},
	},
}

config["match4"] = {
	{
		name = '冠军10奖杯',
		shortName  =  '8点到23点,每15分钟一场',
		sortid = 2,
		matchId = 401,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 240,										--比赛最多人数
		minPlayer = 120,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		entryMoney = 2500,										--入场扣金币
		-- --entryDiamond = 5,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"08:05:00","08:20:00","08:35:00","08:50:00","09:05:00","09:20:00","09:35:00","09:50:00","10:05:00","10:20:00","10:35:00","10:50:00","11:05:00","11:20:00","11:35:00","11:50:00","12:05:00","12:20:00","12:35:00","12:50:00","13:05:00","13:20:00","13:35:00","13:50:00","14:05:00","14:20:00","14:35:00","14:50:00","15:05:00","15:20:00","15:35:00","15:50:00","16:05:00","16:20:00","16:35:00","16:50:00","17:05:00","17:20:00","17:35:00","17:50:00","18:05:00","18:20:00","18:35:00","18:50:00","19:05:00","19:20:00","19:35:00","19:50:00","20:05:00","20:20:00","20:35:00","20:50:00","21:05:00","21:20:00","21:35:00","21:50:00","22:05:00","22:20:00","22:35:00","22:50:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 120,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {120, 48, 18, 0},				--每一阶段的人数	
				relivegold = {2500},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:1000"},
			{rankstart = 2, rankend = 2, reward="1:400"},
			{rankstart = 3, rankend = 3, reward="1:200"},
			{rankstart = 4, rankend = 6, reward="1:100"},
			{rankstart = 7, rankend = 12, reward="1:50"},
			{rankstart = 13, rankend = 24, reward="1:20"},
			{rankstart = 25, rankend = 48, reward="1:10"},
		},
	},
}

config["match5"] = {
	{
		name = '冠军100奖杯',
		shortName  =  '每天9点30开赛',
		sortid = 4,
		matchId = 501,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 1002,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		-- entryMoney = 5000,										--入场扣金币
		entryDiamond = 3,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"09:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 78, 36, 18, 8 , 0},				--每一阶段的人数	
				-- relivegold = 5000,
				reliveDiamond = {3,5},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:400"},
			{rankstart = 13, rankend = 24, reward="1:200"},
			{rankstart = 25, rankend = 36, reward="1:100"},
			{rankstart = 37, rankend = 72, reward="1:50"},
			{rankstart = 73, rankend = 120, reward="1:30"},
		},
	},

	{
		name = '冠军100奖杯',
		shortName  =  '每天13点30开赛',
		sortid = 4,
		matchId = 502,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 1002,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		-- entryMoney = 5000,										--入场扣金币
		entryDiamond = 3,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"13:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 78, 36, 18, 8 , 0},				--每一阶段的人数	
				-- relivegold = 5000,
				reliveDiamond = {3,5},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:400"},
			{rankstart = 13, rankend = 24, reward="1:200"},
			{rankstart = 25, rankend = 36, reward="1:100"},
			{rankstart = 37, rankend = 72, reward="1:50"},
			{rankstart = 73, rankend = 120, reward="1:30"},
		},
	},

	{
		name = '冠军100奖杯',
		shortName  =  '每天17点30开赛',
		sortid = 4,
		matchId = 503,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 1002,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		-- entryMoney = 5000,										--入场扣金币
		entryDiamond = 3,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"17:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 78, 36, 18, 8 , 0},				--每一阶段的人数	
				-- relivegold = 5000,
				reliveDiamond = {3,5},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:400"},
			{rankstart = 13, rankend = 24, reward="1:200"},
			{rankstart = 25, rankend = 36, reward="1:100"},
			{rankstart = 37, rankend = 72, reward="1:50"},
			{rankstart = 73, rankend = 120, reward="1:30"},
		},
	},

	{
		name = '冠军100奖杯',
		shortName  =  '每天20点00开赛',
		sortid = 4,
		matchId = 504,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 1002,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		-- entryMoney = 5000,										--入场扣金币
		entryDiamond = 3,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"20:00:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 78, 36, 18, 8 , 0},				--每一阶段的人数	
				-- relivegold = 5000,
				reliveDiamond = {3,5},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:400"},
			{rankstart = 13, rankend = 24, reward="1:200"},
			{rankstart = 25, rankend = 36, reward="1:100"},
			{rankstart = 37, rankend = 72, reward="1:50"},
			{rankstart = 73, rankend = 120, reward="1:30"},
		},
	},

	{
		name = '冠军100奖杯',
		shortName  =  '每天21点30开赛',
		sortid = 4,
		matchId = 505,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "pdk",									--游戏类型
		maxPlayer = 1002,										--比赛最多人数
		minPlayer = 300,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		-- entryMoney = 5000,										--入场扣金币
		entryDiamond = 3,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2015-10-20T17:00:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"21:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "pdk",						--游戏类型
				playerIn = 300,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 2,						--一局的最少人数
	 			maxPlayer   = 2,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {300, 0.5, 78, 36, 18, 8 , 0},				--每一阶段的人数	
				-- relivegold = 5000,
				reliveDiamond = {3,5},
				bombScore = 10,
				roomSpeci = 0
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:400"},
			{rankstart = 13, rankend = 24, reward="1:200"},
			{rankstart = 25, rankend = 36, reward="1:100"},
			{rankstart = 37, rankend = 72, reward="1:50"},
			{rankstart = 73, rankend = 120, reward="1:30"},
		},
	},

}

config["match8"] = {
	{
		name = '免费报名 冠军100奖杯',
		shortName  =  '每天12:30准点开赛',
		sortid = 3,
		matchId = 801,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "ddz",									--游戏类型
		maxPlayer = 2100,										--比赛最多人数
		minPlayer = 900,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		entryMoney = 0,										--入场扣金币
		-- --entryDiamond = 5,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2018-03-06T20:30:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"12:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "ddz",						--游戏类型
				playerIn = 900,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 3,						--一局的最少人数
	 			maxPlayer   = 3,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {900, 0.5, 270, 132, 60, 30, 12, 0},				--每一阶段的人数	
				relivegold = {2500,5000},
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:600"},
			{rankstart = 13, rankend = 24, reward="1:300"},
			{rankstart = 25, rankend = 48, reward="1:200"},
			{rankstart = 49, rankend = 100, reward="1:100"},
			{rankstart = 101, rankend = 150, reward="1:50"},
			{rankstart = 151, rankend = 200, reward="1:20"},
			{rankstart = 201, rankend = 300, reward="1:10"},
		},
	},

	{
		name = '免费报名 冠军100奖杯',
		shortName  =  '每天19:30准点开赛',
		sortid = 3,
		matchId = 802,										--比赛id[比赛服务id*100/+比赛子id] 
		matchType = 0,                                      --0是普通赛,1是金币赛
		--maxOwnGoldLimit = 3000, 							--最大拥有金币数量(超过即无法报名)
		-- forbidRobot = 1,									--禁用机器人		
		--showRealPlayers = 1,
		groupModel = 1,
		gameType = "ddz",									--游戏类型
		maxPlayer = 2100,										--比赛最多人数
		minPlayer = 900,										--这个字段就填3(之前没用后来意义该了)
		-- minPlayerIn = 3,                                   --
		startTimeout = {15,20},								--多少秒之后满足最小人数就开始		
		maxDayPlayCnt = 99,									--每日最多次数
		enterTimeout = 15,									--参加比赛超时时间,超过这个时间算放弃
		entryMoney = 0,										--入场扣金币
		-- --entryDiamond = 5,
		extraMoney = 0,										--额外入场金币(出了入场券还需要扣的)
		showTime = "2018-03-06T20:30:00",					--比赛开始显示时间
		hideTime = "2099-10-29T18:00:00",					--比赛隐藏时间
		startDate= "2016-2-22T00:00:00",					--比赛第一天开始日期
		cycleTime={"19:30:00"},					--一天中的循环时间
		cycleDay=1,               ---循环天数
		hotUpdate = 1, 										--支持热更新
		rolltime = "", 								--滚服时间 当天该时间点提醒用户重新登录
		stage = {
			{
				type = "SWISSEX",					--打立出局+瑞士位移
				gameType = "ddz",						--游戏类型
				playerIn = 900,							--输入的玩家数量
				playerOut = 0,							--输出的玩家数量
				handCount = 6,							--一桌打几手牌
				baseScore = {[1]=1},					--游戏底分 [时间] = 倍率
				maxOdds = 48,							--最大倍率
				defaultScore = 0,					--初始积分
				minPlayer	= 3,						--一局的最少人数
	 			maxPlayer   = 3,						--一局最多
				adjustScore = 0,						--分差调整
				roundPlayer = {900, 0.5, 270, 132, 60, 30, 12, 0},				--每一阶段的人数	
				relivegold = {2500,5000},
			},
		},

		reward = {
			{rankstart = 1, rankend = 1, reward="1:10000"},
			{rankstart = 2, rankend = 2, reward="1:4000"},
			{rankstart = 3, rankend = 3, reward="1:2000"},
			{rankstart = 4, rankend = 6, reward="1:1000"},
			{rankstart = 7, rankend = 12, reward="1:600"},
			{rankstart = 13, rankend = 24, reward="1:300"},
			{rankstart = 25, rankend = 48, reward="1:200"},
			{rankstart = 49, rankend = 100, reward="1:100"},
			{rankstart = 101, rankend = 150, reward="1:50"},
			{rankstart = 151, rankend = 200, reward="1:20"},
			{rankstart = 201, rankend = 300, reward="1:10"},
		},
	},

}

return config