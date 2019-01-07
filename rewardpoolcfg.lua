local config = {}

config[4001] = {
	callback_pool_percent = 0.4,
	minexternalgold = 10000,
	reward_all = 1, --奖励全部玩家
	reward_percent = {win = {550, 650}, lose = {200, 350}},
	pool_section = {
		{
			s = 0,
			e = 10000,
		},
		{
			s = 10001,
			additional = {
			  {800, 100, 150},
			  {130, 150, 200},
			  {30, 200, 500},
			  {10, 500, 1000},
			  {10, 2000, 4000},
			  {10, 4000, 7000},
			  {10, 7000, 10000},
			}
		},
	},
	robot_gold_pool = {
		{
			s = -999999999,
			e = 500000,
			winprobability = 700
		},
		{
			s = 500001,
			e = 1000000,
			winprobability = 500--600
		},
		{
			s = 1000001,
			e = 5000000,
			winprobability = 100--500
		},
		{
			s = 5000001,
			e = 9999999999,
			winprobability = 20--400
		},
	}	
}

config[1004] = {
	callback_pool_percent = 0.6,
	reward_percent = {win = {600, 900}, lose = {0, 0}},
	minexternalgold = 1000,
	pool_section = {
		{
			s = 0,
			e = 5000,
		},
		{
			s = 5001,
			additional = {
			  {300, 5, 20},
			  {300, 21, 50},
			  {100, 50, 100},
			  {100, 100, 200},
			  {100, 200, 300},
			  {50, 300, 400},
			  {50, 400, 500},
			}
		},
	},
}

config[1001] = {
	callback_pool_percent = 0.6,
	reward_percent = {win = {600, 900}, lose = {0, 0}},
	minexternalgold = 1000,
	pool_section = {
		{
			s = 0,
			e = 3000,
		},
		{
			s = 3001,
			additional = {
			  {800, 30, 50},
			  {140, 50, 100},
			  {30, 100, 200},
			  {30, 200, 300},
			}
		},
	},
}

config[1005] = {
	callback_pool_percent = 0.7,
	reward_percent = {win = {600, 900}, lose = {0, 0}},
	minexternalgold = 1000,
	pool_section = {
		{
			s = 0,
			e = 5000,
		},
		{
			s = 5001,
			additional = {
			  {300, 50, 60},
			  {300, 100, 110},
			  {140, 150, 160},
			  {100, 200, 210},
			  {80, 300, 310},
			  {50, 400, 410},
			  {10, 500, 510},
			  {10, 1000, 1100},
			  {10, 2000, 2100},
			}
		},
	},
}

config[5001] = {
	callback_pool_percent = 0.4,
	minexternalgold = -99999999, --输赢达到10000才触发额外奖励
	reward_all = 1, --奖励全部玩家
	-- reward_percent = {win = {550, 650}, lose = {200, 350}},
	unstable = 1,
	maxrewardplayer = 2, --最大奖励人数
	coin2gold = {percent = 30, scale = 120}, -- 奖励变成金币的概率，奖券换算金币的比例
	pool_section = {
		{
			s = 0,
			e = 10000,
		},
		{
			s = 10001,
			additional = {
			  {550, 5, 10},
			  {350, 10, 50},
			  {60, 50, 100},
			  {30, 100, 200},
			  {10, 200, 500},
			}
		},
	},
}

return config