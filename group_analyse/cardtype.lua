-- 炸弹7 葫芦6 顺子5 三张4 连对3 对子2 单牌1
logic.ct_quad = 7
logic.ct_fullhouse = 6
logic.ct_straight = 5
logic.ct_set = 4
logic.ct_twopair = 3
logic.ct_pair = 2
logic.ct_highcard = 1

local test = {
	{cards = {10, 21, 32, 41, 50}, ct = 5},
	{cards = {21, 32, 41, 50, 80}, ct = 1},
}