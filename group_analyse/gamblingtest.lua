local util = require 'ai_util'
local logic = require 'logic'
--local logic = require 'cardsgroupcreator'
--local Hint = require 'Hint'
local combination = require 'combination'
local gamblingtree = require 'gamblingtree'
require 'functionsxx'

local cards = {
		{83,92,93,103,122,123},--第1关
		{13,32,33,62,63,112,113},
	}



gamblingtree.max_depth = 5
  local xx = gamblingtree.getoutcards(1, 2, {}, cards)
  luadump(xx)



-- [2018-01-25 19:39:01.178] [DEBUG] [robot1-14] [./server/robot/ddz/logic.lua:170] 10♦ J♣ J♦ Q♦ A♣ A♦
-- [2018-01-25 19:39:01.178] [DEBUG] [robot1-14] [./server/robot/ddz/logic.lua:155] 83,92,93,103,122,123,
-- [2018-01-25 19:39:01.178] [DEBUG] [robot1-14] [./server/robot/ddz/logic.lua:170] 3♦ 5♣ 5♦ 8♣ 8♦ K♣ K♦
-- [2018-01-25 19:39:01.178] [DEBUG] [robot1-14] [./server/robot/ddz/logic.lua:155] 13,32,33,62,63,112,113,
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:49] dump from: ./server/robot/ddz/gamblingtree.lua:17: in function 'gamblingtree.getoutcards'
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] - "<var>" = {
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -     "cards" = {
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -         1 = 112
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -         2 = 113
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -     }
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -     "maxlayer" = true
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -     "value"    = -3625
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] - }
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./server/robot/ddz/ai_ddz2.lua:122] getOutCardsEx--------------------result
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:49] dump from: ./server/robot/ddz/ai_ddz2.lua:123: in function 'ai_ddz2.getOutCardsEx'
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] - "<var>" = {
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -     1 = 112
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] -     2 = 113
-- [2018-01-25 19:39:01.183] [DEBUG] [robot1-14] [./common/functions.lua:95] - }
-- [2018-01-25 19:39:18.295] [DEBUG] [robot1-14] [./server/robot/ddz/ai_ddz2.lua:105]


-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./server/robot/ddz/logic.lua:170] Q♦ A♣ A♦
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./server/robot/ddz/logic.lua:155] 103,122,123,
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./server/robot/ddz/logic.lua:170] 3♦ 8♣ 8♦ 2♦
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./server/robot/ddz/logic.lua:155] 13,62,63,133,
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:49] dump from: ./server/robot/ddz/gamblingtree.lua:17: in function 'gamblingtree.getoutcards'
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] - "<var>" = {
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -     "cards" = {
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -         1 = 62
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -         2 = 63
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -     }
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -     "maxlayer" = true
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -     "value"    = 382
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] - }
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./server/robot/ddz/ai_ddz2.lua:122] getOutCardsEx--------------------result
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:49] dump from: ./server/robot/ddz/ai_ddz2.lua:123: in function 'ai_ddz2.getOutCardsEx'
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] - "<var>" = {
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -     1 = 62
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] -     2 = 63
-- [2018-02-24 00:59:27.644] [DEBUG] [robot1-13] [./common/functions.lua:95] - }
-- [2018-02-24 00:59:44.656] [DEBUG] [robot1-13] [./server/robot/ddz/ai_ddz2.lua:105]


