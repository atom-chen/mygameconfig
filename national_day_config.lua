	--
-- Author: cyj
-- Date: 2015-12-24 15:56:01
--

local t = {}

t.trigger_time = 1506787200 --触发时间
t.finish_time = 1507392000 --结束时间
-- t.last_day = 7 --持续时间
t.daysignin = {"2:1", "0:1000", "101:30", "0:3000", "2:12", "0:8888", "1:100"} --奖励

t.invite = {
	{s = 1, e = 10, reward = 30},
	{s = 11, e = 20, reward = 40},
	{s = 21, e = 40, reward = 50},
	{s = 41, e = 50, reward = 100},
}

return t