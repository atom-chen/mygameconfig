--
-- Author: cyj
-- Date: 2017-03-07 15:56:01
--

local lottery = {
	[1] = {
		id = 1,
		interval = 1440, --min
		minpoll = 600,
		price = "1:2",
		reward = "3:100",
		rewarddes = '100钻石'
	},
	[2] = {
		id = 2,
		interval = 1440, --min
		minpoll = 600,
		price = "1:1",
		reward = "0:50000",
		rewarddes = '5万金豆'
	},
	[3] = {
		id = 3,
		interval = 1440, --min
		minpoll = 600,
		price = "1:2",
		reward = "0:100000",
		rewarddes = '10万金豆'
	},
	[4] = {
		id = 4,
		interval = 1440, --min
		minpoll = 600,
		price = "1:1",
		reward =  "3:50",
		-- redreward = "3:50", --话费卡50
		rewarddes = '50钻石'
	},
	-- 50钻石，0.01券，600次（火爆）
}

return lottery