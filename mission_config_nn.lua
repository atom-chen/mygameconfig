local mission_conf_nn = {}
--missiontype = 1 参加房间游戏 num 比赛次数  reward 奖励 roomid 房间号  一个类型游戏为：0 dzniuniu 
--missiontype = 2 赢取比赛或者游戏 num 赢取次数  reward 奖励
--missiontype = 3 坐庄几次  y
--missiontype = 4 绑定微信  
--missiontype = 5 PC登录  
--missiontype = 6 网页登录  
--missiontype = 7 手机绑定
mission_conf_nn[1] = { missiontype = 1,
			id = 1,
			name = "参加对战牛牛新手房游戏10局",
			num = 10,
			reward = 500,
			roomid = 2001,
			gametype = "dzniuniu",
			navigation = "2"
			}

mission_conf_nn[2] = {missiontype = 1,
			id = 2,
			name = "参加对战牛牛初级房游戏5局",
			num = 5,
			reward = 1000,
			roomid = 2002,
			gametype = "dzniuniu",
			navigation = "2"
			}

mission_conf_nn[3] = { missiontype = 1,
			id = 3,
			name = "参加对战牛牛中级房游戏1局",
			num = 1,
			reward = 2000,
			roomid = 2003,
			gametype = "dzniuniu",
			navigation = "2"
			}

mission_conf_nn[4] = {missiontype = 2,
			id = 4,
			name = "赢取通比牛牛游戏5局",
			num = 5,
			reward = 500,
			roomid = 0,
			gametype = "4nn",
			navigation = "1"
			}

mission_conf_nn[5] = {missiontype = 2,
			id = 5,
			name = "赢取通比牛牛游戏10局",
			num = 10,
			reward = 1000,
			roomid = 0,
			gametype = "4nn",
			navigation = "1"
			}

mission_conf_nn[6] = {missiontype = 3,
			id = 6,
			name = "抢庄牛牛连续坐庄2次",
			num = 2,
			reward = 1000,
			roomid = 0,
			gametype = "combullfight",
			navigation = "3"
			}
mission_conf_nn[7] = {missiontype = 4,
			id = 7,
			name = "微信绑定",
			num = 1,
			reward = 1000,
			roomid = 0,
			gametype = "",
			navigation = "4"
			}
mission_conf_nn[8] = {missiontype = 5,
			id = 8,
			name = "PC登录",
			num = 1,
			reward = 1000,
			roomid = 0,
			gametype = "",
			navigation = "5"
			}
mission_conf_nn[9] = {missiontype = 6,
			id = 9,
			name = "网页登录",
			num = 1,
			reward = 1000,
			roomid = 0,
			gametype = "",
			navigation = "6"
			}	
mission_conf_nn[10] = {missiontype = 7,
			id = 10,
			name = "绑定手机",
			num = 1,
			reward = 1000,
			roomid = 0,
			gametype = "",
			navigation = "7"
			}		
return mission_conf_nn
