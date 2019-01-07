--
-- Author: cyj
-- Date: 2017-03-07 15:56:01
--

local tbl  = {}
tbl.friendslimt = 50
tbl.item = {
	[201] = {gold = 1000,   charm = 10},
	[202] = {gold = 2000,   charm = 20},
	[203] = {gold = 5000,   charm = 50},
	[204] = {gold = 10000,  charm = 100},
	[205] = {gold = 20000,  charm = 200},
}
tbl.limit ={
	[1] = {giftcnt = 1},
	[2] = {giftcnt = 2},
	[3] = {giftcnt = 4},
	[4] = {giftcnt = 6},
	[5] = {giftcnt = 10},
	[6] = {giftcnt = 20},
	[7] = {giftcnt = 40},
}
return tbl