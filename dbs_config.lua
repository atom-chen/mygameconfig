	--
-- Author: Dengbing
-- Date: 2015-12-24 15:56:01
--

local dbs_config = {}

--服务器金币比率
dbs_config.server_scale = 10000

--新手金币奖励
dbs_config.freshman_gold_reward = 20000
--首次钻石奖励
dbs_config.first_diamond_gift = '3:32'
--金币比例
dbs_config.scale = 1

dbs_config.wxshareBouns = 0.2 -- 人民币

--在登录过h5的前提下登录app奖励金币1w
dbs_config.login_app_reward = "0:20000|2:72"

--邮件有效天数
dbs_config.mail_expire_day = 7
dbs_config.mail_default_from = '管理员'
--聊天消耗金币
dbs_config.chat_consume = {
	[1] = '0:0',
	[2] = '3:10',
}
-- dbs_config.mail_expire_day = 7

--首充奖励
dbs_config.firstrechargereward = {
	RMB = 6,
	reward = {"2:168|0:10000|101:20", "0:10000|101:20", "0:10000|101:20", "0:10000|101:20", "0:10000|101:20", "0:10000|101:20", "0:10000|101:20"}
}
--每日签到
dbs_config.daysignin = {"0:1000", "0:1200", "0:1400", "0:1600|2:1", "0:1800", "0:2000", "0:2200|2:24"}

--救济金触发条件金额下限、每天领取次数、每次领取金额
dbs_config.alms = {condition = 1000, count = 2, gold = 1000}

--每日分享奖励
dbs_config.day_share_reward = "0:1000"

dbs_config.luck_packet_lottery_cnt = 3 --福袋抽奖次数

dbs_config.invite_active = {
	section = {1520179200, 1521388800},
	task = {
		{id = 1, reward = "1:200", progress = 10},
		{id = 2, reward = "1:400", progress = 20},
		{id = 3, reward = "1:600", progress = 30},
		{id = 4, reward = "1:800", progress = 40},
		{id = 5, reward = "1:1000", progress = 50},
	}
}

dbs_config.max_dayinvitereward_cnt = 5 --每日邀请奖励奖券次数上限

dbs_config.justlottery_day_limit = 20
dbs_config.justlottery_price = 5000
dbs_config.justlottery = {
	{120, "2:1"},
	{120, "2:6"},
	{100, "0:1888"},
	{48, "0:8888"},
	{26, "0:18888"},  
	{350, "3:5"},
	{10, "3:50"},
	{200, "1:10"},
	{25, "1:100"},
	{1, "1:5000"},
}

dbs_config.viplotterydura = {72000, 75600}
dbs_config.viplottery = {
	{130, "2:1"},
	{100, "2:6"},
	{200, "3:1"},
	{250, "3:2"},
	{210, "3:5"},  
	{48, "3:8"},
	{25, "3:10"},
	{26, "3:18"},
	{10, "3:50"},
	{1, "3:100"},
}

dbs_config.freediamondlottery = {
	{130, "2:1"},
	{100, "2:6"},
	{200, "3:1"},
	{250, "3:2"},
	{210, "3:5"},  
	{48, "3:8"},
	{25, "3:10"},
	{26, "3:18"},
	{10, "3:50"},
	{1, "3:100"},
}

dbs_config.rewardcallback = {
	[1002] = {
		percent = 0.5,
	},
	[8001] = {
		percent = 0.5,
	},
	[8002] = {
		percent = 0.5,
	}
}

dbs_config.goldroomid = {
	1001,
	1002,
	8001,
	8002,	
}

dbs_config.diamondroomid = {
	1000,
	8003,
	8004,
	1006,
}

-- local sortpercent = 70
-- if game_data.roomid == 9000 then
-- 	sortpercent = 70
-- elseif game_data.roomid == 9001 then
-- 	sortpercent = 60
-- elseif game_data.roomid == 9002 then
-- 	sortpercent = 70
-- end
dbs_config.runquikc = {
	[9000] = 70,
	[9001] = 80,
	[9003] = 80,

	[9002] = 70,
	[9004] = 70,
	[9005] = 75,
}
return dbs_config