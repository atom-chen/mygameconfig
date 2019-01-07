local group = {
	{
		id = 1,
		ip = "47.96.17.41",
		localip = "10.20.8.103",
		agent = {1, 3, 5},
		agent2url = {
			'wss://ddz-agent1.hztangyou.com/ws',
			'wss://ddz-agent3.hztangyou.com/ws',
			'wss://ddz-agent5.hztangyou.com/ws'
		}
	},
	{
		id = 2,
		ip = "118.31.36.246",
		localip = "10.20.8.101",
		agent = {2, 4, 6},
		agent2url = {
			'wss://ddz-agent2.hztangyou.com/ws',
			'wss://ddz-agent4.hztangyou.com/ws',
			'wss://ddz-agent6.hztangyou.com/ws'
		}
	}
}

return group