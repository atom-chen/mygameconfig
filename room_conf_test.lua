local conf = {}
--斗地主ID段是1000~1999
--牛牛ID段2000~2999

--gameType 游戏类型，ddz表示斗地主，告知服务器加载logic_ddz.lua的逻辑
--robot 1表示可以加入机器人，其他数值表示不加入机器人
--minScore 准入最低分数
--maxScore 准入最高根数
--baseScore底分
--maxOdds最大倍数
--maxPlayer 每个桌子的最多人数
--minPlayer 每个桌子的最少人数
--rankScore 玩一局游戏排行榜分数增加

--斗地主房间配置
conf[1001] = {name = "斗地主体验房", 
			 gameType = "ddz", 
			 roomType = "common",
			 robot = 1,
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 100,
			 maxScore = 5000,
			 baseScore = 1,
			 maxOdds = 99999,
			 minPlayer = 3,
			 maxPlayer = 3,
			 rankScore = 5
			}

conf[1002] = {name = "斗地主0.1元房", 
			 gameType = "ddz", 
			 roomType = "common",
			 robot = 1,
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 1000,
			 maxScore = 10000,
			 baseScore = 10,
			 maxOdds = 99999,
			 minPlayer=3,
			 maxPlayer=3,
			 rankScore = 25
			}

conf[1003] = {name = "斗地主0.5元房", 
			 gameType = "ddz", 
			 roomType = "common",
			 robot = 1,
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 5000,
			 maxScore = 50000,
			 baseScore = 50,
			 maxOdds = 99999,
			 minPlayer=3,
			 maxPlayer=3,
			 rankScore = 25
			}

conf[1004] = {name = "斗地主1元房", 
			 gameType = "ddz", 
			 roomType = "common",
			 robot = 1,
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 10000,
			 maxScore = 50000,
			 baseScore = 100,
			 maxOdds = 99999,
			 minPlayer=3,
			 maxPlayer=3,
			 rankScore = 50
			 }

conf[2001] = {name = "对战牛牛体验房", 
			 gameType = "dzniuniu", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 400,
			 maxScore = 50000,
			 baseScore = 0,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=2,
			 rankScore = 5
			 }

conf[2002] = {name = "对战牛牛1元房", 
			 gameType = "dzniuniu", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 10000,
			 maxScore = 100000,
			 baseScore = 0,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=2,
			 rankScore = 15
			 }

conf[2003] = {name = "对战牛牛3元房", 
			 gameType = "dzniuniu", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 30000,
			 maxScore = 300000,
			 baseScore = 0,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=2,
			 rankScore = 50
			 }
			 
conf[3001] = {name = "抢庄牛牛体验房", 
			 gameType = "combullfight", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 750,
			 maxScore = 7500,
			 baseScore = 10,
			 maxOdds = 99999,
			 minPlayer=3,
			 maxPlayer=5,
			 rankScore = 5
			 }

			 
conf[3002] = {name = "抢庄牛牛1元房", 
			 gameType = "combullfight", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 7500,
			 maxScore = 75000,
			 baseScore = 100,
			 maxOdds = 99999,
			 minPlayer=3,
			 maxPlayer=5,
			 rankScore = 20
			 }

			 
conf[3003] = {name = "抢庄牛牛3元房", 
			 gameType = "combullfight", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 30000,
			 maxScore = 750000,
			 baseScore = 300,
			 maxOdds = 99999,
			 minPlayer=3,
			 maxPlayer=5,
			 rankScore = 50
			 }

conf[4001] = {name = "诈金花体验房", 
			 gameType = "zjh", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 1,
			 maxrobot = 10,
			 minScore = 1000,
			 maxScore = 10000,
			 baseScore = 10,
			 escapeScore = 0, -- 逃跑额外惩罚
			 maxOdds = 99999,
			 maxHand = 10, --最大手数
			 compareHand = 2, --可比手数
			 minPlayer=2,
			 maxPlayer=6,
			 rankScore = 10
			 }


conf[4002] = {name = "诈金花1元房", 
			 gameType = "zjh", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 50,
			 maxScore = 100000,
			 baseScore = 100,
			 escapeScore = 0, -- 逃跑额外惩罚
			 maxOdds = 99999,
			 maxHand = 10, --最大手数
			 compareHand = 2, --可比手数
			 minPlayer=2,
			 maxPlayer=6,
			 rankScore = 20
			 }

conf[4003] = {name = "诈金花5元房", 
			 gameType = "zjh", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 50000,
			 maxScore = 1000000,
			 baseScore = 500,
			 escapeScore = 0, -- 逃跑额外惩罚
			 maxOdds = 99999,
			 maxHand = 10, --最大手数
			 compareHand = 2, --可比手数
			 minPlayer=2,
			 maxPlayer=6,
			 rankScore = 50
			 }

conf[5001] = {name = "百人牛牛体验房", 
			 gameType = "100nn", 
			 roomType = "common",
			 baseScore = 0,
			 maxOdds = 0,
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 1000,
			 maxScore = 0,
			 maxBankerRound = 3,	--上庄最多玩几局
			 minBankerScore = 50000, --上庄最少钱数
			 maxBetScore = 10000, 	--押注封顶
			 minPlayer=2,
			 maxPlayer=100,
			 --betList = {100, 1000, 10000, 50000, 100000, 500000, 100000}, --客户端押注金额
			 betList = {5, 10, 20, 50, 100, 200, 500}, --客户端押注金额
			 rankScore = 0
			}

conf[5002] = {name = "百人牛牛中级房", 
			 gameType = "100nn", 
			 roomType = "common",
			 baseScore = 0,
			 maxOdds = 0,
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 5000,
			 maxScore = 0,
			 maxBankerRound = 3,	--上庄最多玩几局
			 minBankerScore = 500000, --上庄最少钱数
			 maxBetScore = 100000, 	--押注封顶
			 minPlayer=2,
			 maxPlayer=100,
			 --betList = {100, 1000, 10000, 50000, 100000, 500000, 100000}, --客户端押注金额
			 betList = {50, 100, 200, 500, 1000, 2000, 5000}, --客户端押注金额
			 rankScore = 0
			}

conf[5003] = {name = "百人牛牛高级房", 
			 gameType = "100nn", 
			 roomType = "common",
			 baseScore = 0,
			 maxOdds = 0,
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 10000,
			 maxScore = 0,
			 maxBankerRound = 3,	--上庄最多玩几局
			 minBankerScore = 2000000, --上庄最少钱数
			 maxBetScore = 400000, 	--押注封顶
			 minPlayer=2,
			 maxPlayer=100,
			 --betList = {100, 1000, 10000, 50000, 100000, 500000, 100000}, --客户端押注金额
			 betList = {200, 500, 1000, 2000, 5000, 10000, 20000}, --客户端押注金额
			 rankScore = 0
			}

conf[6001] = {name = "双扣体验房", 
			 gameType = "doublebuckle", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 400,
			 maxScore = 2000,
			 baseScore = 10,
			 maxOdds = 99999,
			 minPlayer=4,
			 maxPlayer=4,
			 rankScore = 10
			 }


conf[6002] = {name = "双扣0.5元房", 
			 gameType = "doublebuckle", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 1000,
			 maxScore = 5000,
			 baseScore = 50,
			 maxOdds = 99999,
			 minPlayer=4,
			 maxPlayer=4,
			 rankScore = 35
			 }


conf[6003] = {name = "双扣2元房", 
			 gameType = "doublebuckle", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 0,
			 minScore = 4000,
			 maxScore = 40000,
			 baseScore = 200,
			 maxOdds = 99999,
			 minPlayer=4,
			 maxPlayer=4,
			 rankScore = 70
			 }

conf[7001] = {name = "港五0.5元房",
			 gameType = "showhand",
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 2000,
			 maxScore = 10000,
			 baseScore = 50, --底注
			 maxOdds = 99999,
			 chip = 40, --每局可以下的最大值相对于底注的倍数		 
			 option = {1, 5, 10},--快捷加注相对于底注的倍数
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 5
			 }

conf[7002] = {name = "港五2元房", 
			 gameType = "showhand",
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 8000,
			 maxScore = 50000,
			 baseScore = 200, --底注
			 maxOdds = 99999,
			 chip = 40, --每局可以下的最大值相对于底注的倍数
			 option = {1, 5, 10},--快捷加注相对于底注的倍数
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 25
			 }

conf[7003] = {name = "港五5元房",
			 gameType = "showhand",
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 20000,
			 maxScore = 250000,
			 baseScore = 500, --底注
			 maxOdds = 99999,
			 chip = 40, --每局可以下的最大值相对于底注的倍数		 
			 option = {1, 5, 10},
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 50
			 }
			 
conf[8001] = {name = "通比6元房", 
			 gameType = "4nn", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 3000,
			 maxScore = 10000,
			 baseScore = 600,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 5
			 }

conf[8002] = {name = "通比10元房", 
			 gameType = "4nn", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 5000,
			 maxScore = 30000,
			 baseScore = 1000,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 15
			 }

conf[8003] = {name = "通比20元房", 
			 gameType = "4nn", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 10000,
			 maxScore = 100000,
			 baseScore = 2000,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 50
			 }
conf[10001] = {name = "捕鱼练习场",
			 gameType = "buyu", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 1,
			 maxScore = 100000,
			 baseScore = 6000,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 50,
			 fishingGrounds = "fishingGrounds01",
			 fishType = 1, --捕鱼的游戏类型
			 paoTaiList = {1,2,3,4,5}, --允许的炮台模式
			 }
conf[10002] = {name = "捕鱼新手场",
			 gameType = "buyu", 
			 roomType = "common",
			 robot = 1, 
			 minrobot = 0,
			 maxrobot = 10,
			 minScore = 1,
			 maxScore = 100000,
			 baseScore = 6000,
			 maxOdds = 99999,
			 minPlayer=2,
			 maxPlayer=4,
			 rankScore = 50,
			 fishingGrounds = "fishingGrounds01",
			 fishType = 1, --捕鱼的游戏类型
			 paoTaiList = {1,2,3,4,5}, --允许的炮台模式
			 }


return conf
