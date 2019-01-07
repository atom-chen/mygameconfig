--
-- Author: cyj
-- Date: 2017-03-07 15:56:01
--
--tp 1针对自己的任务 2针对上线的任务  3 游戏局数 4 胜利局数
--condition 1自己赢几局 2下线赢5局

-- logic.ct_quad = 7
-- logic.ct_fullhouse = 6
-- logic.ct_straight = 5
-- logic.ct_set = 4
-- logic.ct_twopair = 3
-- logic.ct_pair = 2
-- logic.ct_highcard = 1

local itemdropcfg = {}

itemdropcfg = {
	[1000] = {
		drop = 30,
		cardtype = {
			[1] = {probability = 500, reward = "0:500"},
			[2] = {probability = 300, reward = "0:1000"},
			[3] = {probability = 100, reward = "0:1500"},
			[4] = {probability = 50, reward = "0:2500"},
			[5] = {probability = 29, reward = "0:10000"},
			[6] = {probability = 20, reward = "0:25000"},
			[7] = {probability = 1, reward = "0:50000"},
		}
	}
}
itemdropcfg[1001] = itemdropcfg[1000]
itemdropcfg[1005] = itemdropcfg[1000]

itemdropcfg.roomid2idx = {
	[1000] = 1,
	[1001] = 2,
	[1005] = 2,
}
-- itemdropcfg.idx2roomid = {
-- 	[1] = 1000,
-- 	[1001] = 2,
-- 	[1005] = 2,
-- }
return itemdropcfg