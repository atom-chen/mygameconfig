local config = {}

config.enable = true

config.hash = {
	[0] = 4,
	[1] = 5,
	[2] = 5,
	[3] = 6,
	[4] = 6,
	[5] = 6,
	[6] = 6,
	[7] = 6,
	[8] = 1,
	[9] = 1,
	[10] = 1,
	[11] = 2,
	[12] = 2,
	[13] = 2,
	[14] = 3,
	[15] = 3,
	[16] = 3,
	[17] = 3,
	[18] = 4,
	[19] = 4,
	[20] = 4,
	[21] = 4,
	[22] = 4,
	[23] = 4,
	[24] = 4,
}

config.other = {
	updatedelay = 10,--s 人数变化间隔
	transition = 30, --m 过渡提前准备时间
	probtend = 60, --过渡期间偏向下一个阶段的概率
	exprobtend = 80, --偏离范围调整概率（超过过度时间，加强调整概率）
}

config.value = {
	[1] = {range = {600, 800}, fluctuate = {8, 15}}, --st = 8, et = 11, 
	[2] = {range = {800, 1200}, fluctuate = {12, 24}}, --st = 11, et = 14, 
	[3] = {range = {800, 1000}, fluctuate = {10, 20}}, --st = 14, et = 18, 
	[4] = {range = {1000, 1600}, fluctuate = {14, 28}}, --st = 18, et = 1, 
	[5] = {range = {800, 1000}, fluctuate = {10, 20}}, --st = 1, et = 3, 
	[6] = {range = {400, 600}, fluctuate = {6, 10}}, --st = 3, et = 8, 
}

return config