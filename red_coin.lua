--
-- Author: cyj
-- Date: 2017-03-07 15:56:01
--

local tbl = {}

--抽奖次数增加规则，房间号， 获胜次数， 获得抽奖机会
tbl.addrule = {
	[1001] = {wincnt = 5, chance = 1},
	[1002] = {wincnt = 3, chance = 1},
	[8001] = {wincnt = 1, chance = 1},
	[3002] = {wincnt = 1, chance = 1},
	[3003] = {wincnt = 1, chance = 1},
}

--可兑换商品列表
tbl.goods = {
	[0] = {id = 0,   name = "金豆",   describe = "金豆"},
	[1] = {id = 1,   name = "红包",   describe = "奖品"},
	[2] = {id = 2,   name = "记牌器",   describe = "记牌器"},
	[3] = {id = 3,   name = "钻石",   describe = "钻石"},
	[4] = {id = 4,   name = "话费",   describe = "话费"},
	[5] = {id = 5,   name = "京东券",   describe = "京东券"},
	[6] = {id = 6,   name = "话费卡",   describe = "话费卡"},
	[7] = {id = 7,   name = "支付宝零钱",   describe = "奖品"},
	[8] = {id = 8,   name = "支付宝红包",   describe = "奖品"},
}

tbl.diamondexchange = {
	[1] = {id = 1, diamond = 5, goodsid = 0, amount = 5000},
	[2] = {id = 2, diamond = 20, goodsid = 0, amount = 22000},
	[3] = {id = 3, diamond = 30, goodsid = 0, amount = 30000},
	[4] = {id = 4, diamond = 100, goodsid = 0, amount = 100000},
	[5] = {id = 5, diamond = 500, goodsid = 0, amount = 500000},
	[6] = {id = 6, diamond = 1000, goodsid = 0, amount = 1000000},
}

--兑换 “红包”数量， 商品id，商品数量
tbl.exchange = {
	[1] = {id = 1, coin = 50, goodsid = 0, amount = 5000},
	[2] = {id = 2, coin = 200, goodsid = 0, amount = 22000, addition = 10, hide = 1},
	[3] = {id = 3, coin = 500, goodsid = 0, amount = 60000, addition = 20},
	--[4] = {id = 4, first = 1, coin = 200, goodsid = 1, amount = 2, expiretime = 30, manual = 1},
	[4] = {id = 4, first = 1, coin = 500, goodsid = 7, amount = 5, expiretime = 30, manual = 1},
	[5] = {id = 5, after = 1, coin = 500, goodsid = 1, amount = 5, expiretime = 30, manual = 1},
	[6] = {id = 6, coin = 1000, goodsid = 4, amount = 10, expiretime = 30, manual = 1},
	[7] = {id = 7, coin = 2000, goodsid = 4, amount = 20, expiretime = 30, manual = 1},
	[8] = {id = 8, coin = 200, goodsid = 3, amount = 20},
	[9] = {id = 9, coin = 500, goodsid = 3, amount = 55},
	[10] = {id = 10, coin = 3000, goodsid = 4, amount = 30, expiretime = 30, manual = 1, hide = 1},
	[11] = {id = 11, coin = 5000, goodsid = 6, amount = 50, expiretime = 30, manual = 1},
	[12] = {id = 12, coin = 10000, goodsid = 6, amount = 100, expiretime = 30, manual = 1, hide = 1},
	[13] = {id = 13, coin = 5000, goodsid = 5, amount = 50, expiretime = 30, manual = 1},
	[14] = {id = 14, coin = 10000, goodsid = 5, amount = 100, expiretime = 30, manual = 1},
	[15] = {id = 15, coin = 500, goodsid = 5, amount = 5, expiretime = 30, manual = 1},
	[16] = {id = 16, coin = 1000, goodsid = 5, amount = 10, expiretime = 30, manual = 1},
	[17] = {id = 17, coin = 1000, goodsid = 6, amount = 10, expiretime = 30, manual = 1},
	[18] = {id = 18, coin = 3000, goodsid = 6, amount = 30, expiretime = 30, manual = 1},
	[19] = {id = 19, coin = 1000, goodsid = 1, amount = 10, expiretime = 30, manual = 1},
	[20] = {id = 20, coin = 2000, goodsid = 1, amount = 20, expiretime = 30, manual = 1},
	[21] = {id = 21, coin = 3000, goodsid = 1, amount = 30, expiretime = 30, manual = 1},
	[22] = {id = 22, coin = 5000, goodsid = 7, amount = 50, expiretime = 30, manual = 1},
	[23] = {id = 23, coin = 10000, goodsid = 7, amount = 100, expiretime = 30, manual = 1},
	[24] = {id = 24, coin = 500, goodsid = 0, amount = 50000},
	[25] = {id = 25, coin = 1000, goodsid = 0, amount = 120000},

	[26] = {id = 26, coin = 1000, goodsid = 7, amount = 10, expiretime = 30, manual = 1},
	[27] = {id = 27, coin = 2000, goodsid = 7, amount = 20, expiretime = 30, manual = 1},
	[28] = {id = 28, coin = 3000, goodsid = 7, amount = 30, expiretime = 30, manual = 1},
	-- [29] = {id = 29, coin = 500, goodsid = 7, amount = 5, expiretime = 30, manual = 1},

	-- [26] = {id = 26, coin = 2000, goodsid = 0, amount = 22000},
	-- [15] = {id = 15, after = 1, coin = 500, goodsid = 7, amount = 5, expiretime = 30, manual = 1},
	-- [16] = {id = 16, coin = 1000, goodsid = 7, amount = 10, expiretime = 30, manual = 1},
	-- [17] = {id = 17, first = 1, coin = 100, goodsid = 7, amount = 1, expiretime = 30, manual = 1},
}

return tbl