--
-- Author: cyj
-- Date: 2017-03-07 15:56:01
--
--tp 1针对自己的任务 2针对上线的任务  3 游戏局数 4 胜利局数 5捕鱼游戏抓到鱼 6比赛局数 7付费赛局数 99 其他
--condition 1自己赢几局 2下线赢5局
local task = {
	[1] = {id = 1, tp = 1, day = 1, reward = "0:1000|2:3", progress = 10, condition = 1, win = 1},--赢20
	[2] = {id = 2, tp = 2, day = 1, reward = "0:2000|2:12", progress = 1, condition = 2},--一个下线赢5局
	[3] = {id = 3, tp = 2, week = 1, reward = "1:200", progress = 10, condition = 2},
	[4] = {id = 4, tp = 2, week = 1, reward = "1:400", progress = 20, condition = 2},
	[5] = {id = 5, tp = 2, week = 1, reward = "1:600", progress = 30, condition = 2},
	[6] = {id = 6, tp = 2, week = 1, reward = "1:800", progress = 40, condition = 2},
	[7] = {id = 7, tp = 2, week = 1, reward = "1:1000", progress = 50, condition = 2},
	[8] = {id = 8, tp = 3, day = 1, roomid = {[4001] = 1}, reward = "0:1000", progress = 1},
	[9] = {id = 9, tp = 3, day = 1, roomid = {[1000] = 1, [8000] = 1, [8003] = 1, [8004] = 1, [1006] = 1}, reward = "3:8", progress = 10},
	-- [10] = {id = 10, tp = 4, day = 1, roomid = {[1001] = 1, [1002] = 1, [8001] = 1, [8002] = 1}, reward = "3:2", progress = 5, win = 1},
	--[11] = {id = 11, tp = 4, day = 1, roomid = {[1001] = 1, [1002] = 1, [8001] = 1, [8002] = 1}, reward = "3:3", progress = 20, win = 1},
	[10] = {id = 10, tp = 4, day = 1, roomid = {[9000] = 1, [9001] = 1, [9003] = 1}, reward = "3:2", progress = 5, win = 1},
	[11] = {id = 11, tp = 3, day = 1, roomid = {[9000] = 1, [9001] = 1, [9002] = 1, [9003] = 1, [9004] = 1, [9005] = 1}, reward = "0:1000", progress = 1},
	[12] = {id = 12, tp = 3, day = 1, roomid = {[9002] = 1, [9004] = 1, [9005] = 1}, reward = "3:8", progress = 10},
	[13] = {id = 13, tp = 5, day = 1, roomid = {[3002] = 1, [3003] = 1, [3004] = 1}, reward = "0:1500", progress = 1},
	[14] = {id = 14, tp = 99, day = 1, reward = "3:5", flag = 3, progress = 1},--在小游戏连连翻中翻到777
	[15] = {id = 15, tp = 99, day = 1, reward = "3:5", progress = 5},--在小游戏连连探中一次挖到4个以上宝藏

	[16] = {id = 16, tp = 6, day = 1, reward = "0:600", progress = 1},
	[17] = {id = 17, tp = 6, day = 1, reward = "0:1000", progress = 5},
	[18] = {id = 18, tp = 7, day = 1, reward = "3:3", progress = 1},
}

return task