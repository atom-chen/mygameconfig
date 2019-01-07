--
-- Author: cyj
-- Date: 2018-06-19 15:56:01
--

local config = {}
config.decline = 10
config.upgrade = {
	[1] = {
		exp = 1,
		reward = "0:500|3:2",
	},
	[2] = {
		exp = 66,
		reward = "0:1000|3:10",
	},
	[3] = {
		exp = 188,
		reward = "0:1500|3:10",
	},
	[4] = {
		exp = 388,
		reward = "0:2000|3:10",
	},
	[5] = {
		exp = 688,
		reward = "0:2500|3:20",
	},
	[6] = {
		exp = 1288,
		reward = "0:3000|3:20",
	},
	[7] = {
		exp = 2288,
		reward = "0:3500|3:20",
	},
}

return config