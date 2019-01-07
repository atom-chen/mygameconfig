	--
-- Author: cyj
-- Date: 2016-12-24 15:56:01
--

local config = {}

config.tasktype = {
	[1] = 'playcnt',-- 游戏局数
	[2] = 'wincnt',-- 获胜局数
}

config.roomtask = {
	[2001] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
			
		}
	},
	[2002] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
		}
	},
	[2003] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
		}
	},
	[3001] = {
		[1] = {
			tasktype = 1,
			condition = 5
		},
		[2] = {
			tasktype = 2,
			condition = 3
		},
		[3] = {
			tasktype = 1,
			condition = 10
		},
		[4] = {
			tasktype = 2,
			condition = 5
		},
		[5] = {
			tasktype = 1,
			condition = 20
		},
		[6] = {
			tasktype = 2,
			condition = 10	
		}
	},
	[3002] = {
		[1] = {
			tasktype = 1,
			condition = 2
		},
		[2] = {
			tasktype = 2,
			condition = 2
		},
		[3] = {
			tasktype = 2,
			condition = 2
		}
	},
	[3003] = {
		[1] = {
			tasktype = 1,
			condition = 2
		},
		[2] = {
			tasktype = 2,
			condition = 2
		},
		[3] = {
			tasktype = 2,
			condition = 2
		}
	},
	[8001] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
		}
	},
	[8002] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
		}
	},
	[8003] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
		}
	},
	[14001] = {
		[1] = {
			tasktype = 1,
			condition = 10
		},
		[2] = {
			tasktype = 2,
			condition = 10
		},
		[3] = {
			tasktype = 1,
			condition = 20
		},
		[4] = {
			tasktype = 2,
			condition = 20
		},
		[5] = {
			tasktype = 1,
			condition = 40
		},
		[6] = {
			tasktype = 2,
			condition = 40	
		}
	},
}


return config