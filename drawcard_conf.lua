--
-- Author: cyj
-- Date: 2017-03-07 15:56:01
--

local drawcard_conf = {}

drawcard_conf.turn = {
	multip = {
		[1] = 1.4,
		[2] = 3,
		[3] = 8,
	},
	price = 1000,
	topmultip = 10,
	prob = {
		{580, 0},
		{290, 1},
		{100, 2},
		{30, 3},
	}
}

drawcard_conf.checkout = {
	price = 1000,
	topmultip = 10,
	multip = {
		[1] = 0.2,
		[2] = 1,
		[3] = 2,
		[4] = 6,
		[5] = 10,
		[6] = 30,
	},
	prob = {
		{335, 0},
		{400, 1},
		{120, 2},
		{80, 3},
		{50, 4},
		{10, 5},
		{5, 6},
	}
}

return drawcard_conf