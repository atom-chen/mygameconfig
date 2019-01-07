-- local util = require 'ai_util'
local logic = require 'linkgame_lg'
require 'functionsxx'
--  'dispatch'
-- "<var>" = {
--     "optype"  = 1
--     "params" = {
--         1 = 9
--         2 = 3
--         3 = 10
--         4 = 3
--     }
--     "session" = 1073743496
-- }
local pos1 = {x = 6, y = 6, col = 8}
local pos2 = {x = 4, y = 7, col = 8}


-- e "skynetext"..."]:223] unmatch coordinate
-- p from: [string "local skynet = require "skynetext"..."]:224: in field 'dispatch'
-- <var>" = {
   -- "optype"  = 1
   -- "params" = {
       -- 1 = 6
       -- 2 = 6
       -- 3 = 4
       -- 4 = 7
   -- }
   -- "session" = 1073743496
-- 


local map = {
    {0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0},
		{0,0,0,0,0,8,8}
}

--local result = logic.findlinkpos(map)
local node1, node2 = logic.findlinkpos(map)
luadump(node1)
luadump(node2)