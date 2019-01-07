--
-- Author: cyj
-- Date: 2017-12-24 15:56:01
--

local activity = {
	-- { 	--感恩节
	-- 	id = 1,
	-- 	trigger_time = {11, 23}, --触发时间 月，日
	-- 	finish_time = {11, 26}, --结束时间
	-- 	-- last_day = 3, --持续时间
	-- 	daysignin = {"2:1|0:600", "2:6|0:1000", "2:12|0:1400"}, --奖励
	-- 	maxrechargecnt = 6, --最多参加充值活动的次数
	-- 	recharge_productid = {[10018] = 1, [10019] = 1, [10020] = 1} --活动的商品id
	-- }

	-- { 	--新年礼盒
	-- 	id = 2,
	-- 	trigger_time = {9, 29}, --触发时间 月，日
	-- 	finish_time = {10, 11}, --结束时间
	-- 	recharge_finish_time = {10, 5}, --充值结束时间
	-- 	rwd_aft_rec = {"0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:8888|2:24"},
	-- 	maxrechargecnt = 1, --最多参加充值活动的次数
	-- 	recharge_productid = {[10021] = 1} --活动的商品id
	-- },
	-- { 	--新年任务
	-- 	id = 3,
	-- 	trigger_time = {9, 29}, --触发时间 月，日
	-- 	finish_time = {10, 7}, --结束时间
	-- 	specialct = {
	-- 		[1] = {--sequence
	-- 			[1] = {progress = 2, rwd = "0:218"},
	-- 			[2] = {progress = 6, rwd = "0:618"},
	-- 			[3] = {progress = 10, rwd = "0:1018"},
	-- 		},
	-- 		[2] = {--plane
	-- 			[1] = {progress = 2, rwd = "0:218"},
	-- 			[2] = {progress = 6, rwd = "0:618"},
	-- 			[3] = {progress = 10, rwd = "0:1018"},
	-- 		}
	-- 	}
	-- },
	-- { 	--新年上班礼包
	-- 	id = 4,
	-- 	trigger_time = {2, 23}, --触发时间 月，日
	-- 	finish_time = {2, 24}, --结束时间
	-- 	play = {
	-- 		[1] = {progress = 5, rwd = "0:666|2:24"}
	-- 	} --完成除自由组局外的任意5局游戏
	-- }
	{ 	--新年礼盒
		id = 5,
		trigger_time = {9, 29}, --触发时间 月，日
		finish_time = {10, 12}, --结束时间
		recharge_finish_time = {10, 6}, --充值结束时间
		rwd_aft_rec = {"0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:2018|2:24", "0:8888|2:24"},
		maxrechargecnt = 1, --最多参加充值活动的次数
		recharge_productid = {[10021] = 1} --活动的商品id
	},
	{ 	--新年任务
		id = 6,
		trigger_time = {9, 29}, --触发时间 月，日
		finish_time = {10, 8}, --结束时间
		specialct = {
			[1] = {--sequence
				[1] = {progress = 2, rwd = "0:218"},
				[2] = {progress = 6, rwd = "0:618"},
				[3] = {progress = 10, rwd = "0:1018"},
			},
			[2] = {--plane
				[1] = {progress = 2, rwd = "0:218"},
				[2] = {progress = 6, rwd = "0:618"},
				[3] = {progress = 10, rwd = "0:1018"},
			}
		}
	},
}

return activity