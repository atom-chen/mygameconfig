local mission_conf = {}
--missiontype = 1 参加比赛 num 比赛次数  reward 奖励
--missiontype = 2 赢取比赛或者游戏 num 赢取次数  reward 奖励
--missiontype = 3 参加游戏 num 比赛次数  reward 奖励
--missiontype = 4 参加比赛赢取24倍获胜 num 赢取倍率  reward 奖励
--missiontype = 5 分享到微信朋友圈 num 赢取倍率  reward 奖励
--missiontype = 6 分享到微信群或好友 num 赢取倍率  reward 奖励
--navigation = "room.match" 导向比赛房，navigation = "room.normal"导向普通房
mission_conf[1] = { missiontype = 5,
			id = 1,
			name = "微信分享朋友圈",
			num = 1,
			reward = 500,
			navigation = "share.wx_timeline"
			}

mission_conf[2] = {missiontype = 6,
			id = 2,
			name = "微信邀请好友",
			num = 1,
			reward = 500,
			navigation = "share.wx_session"
			}

mission_conf[3] = { missiontype = 1,
			id = 3,
			name = "参加比赛1次",
			num = 1,
			reward = 100,
			navigation = "room.match"
			}

mission_conf[4] = {missiontype = 2,
			id = 4,
			name = "赢取游戏1次",
			num = 1,
			reward = 100,
			navigation = "room.normal"
			}

mission_conf[5] = {missiontype = 3,
			id = 5,
			name = "参加游戏10局",
			num = 10,
			reward = 500,
			navigation = "room.normal"
			}
			
mission_conf[6] = {missiontype = 4,
			id = 6,
			name = "高于24倍获胜",
			num = 24,
			reward = 1000,
			navigation = "room.normal"
			}

mission_conf[7] = { missiontype = 1,
			id = 7,
			name = "参加比赛5次",
			num = 5,
			reward = 600,
			navigation = "room.match"
			}

mission_conf[8] = {missiontype = 2,
			id = 8,
			name = "赢取游戏10次",
			num = 10,
			reward = 1000,
			navigation = "room.normal"
			}

mission_conf[9] = {missiontype = 3,
			id = 9,
			name = "参加游戏30局",
			num = 30,
			reward = 1000,
			navigation = "room.normal"
			}

mission_conf[10] = { missiontype = 1,
			id = 10,
			name = "参加比赛10次",
			num = 10,
			reward = 1000,
			navigation = "room.match"
			}

mission_conf[11] = {missiontype = 2,
			id = 11,
			name = "赢取游戏30次",
			num = 30,
			reward = 2000,
			navigation = "room.normal"
			}
			
mission_conf[12] = {missiontype = 3,
			id = 12,
			name = "参加游戏50局",
			num = 50,
			reward = 2000,
			navigation = "room.normal"
			}
			
return mission_conf
