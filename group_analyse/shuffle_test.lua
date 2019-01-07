local util = require 'ai_util'
local logic = require 'logic'
--local logic = require 'cardsgroupcreator'
--local Hint = require 'Hint'
local combination = require 'combination'
require 'functionsxx'

local badcnt = 0
for i = 1, 100 do
  local total = {}
  local cg, mc = logic.createCardsGroup(3, 1)
  -- local cg, mc = logic.createCardsNormal()
  -- local cg, mc = logic.createCardsGroupHeap(math.random(5, 10))
  -- local cg, mc = logic.createCardsMissile(1)
  -- logic.killBadCards(cardsgroup, mc, 'createCardsGroup')

  if not logic.judgeCardsLegal(cg, mc) then
    print("!!\n\ncards not legal")
  end
  for k, v in pairs(cg) do
    table.sort(v, function(c1, c2)
        return c1 < c2
        end)
  	logic.printCards(v)
    if logic.judgeBadCards(v) then
      badcnt = badcnt + 1
      print('bad cards~!!!')
    end
  end
  logic.printCards(mc)
  print('\n')
--table.mergeByAppend(total, mc)
end

print('bad cards count: '..tostring(badcnt))
-- local cards =  {
-- 	10,11,12,13,
-- 	20,21,22,23,
-- 	30,31,32,33,
-- 	40,41,42,43,
-- 	50,51,52,53,
-- 	60,61,62,63,
-- 	70,71,72,73,
-- 	80,81,82,83,
-- 	90,91,92,93,
-- 	100,101,102,103,
-- 	110,111,112,113,
-- 	120,121,122,123,
-- 	130,131,132,133,
-- 	140,150}
-- local optoins = logic.getAllDoubleLineCard(cards, 1, 3)
-- util.printTable(optoins)
-- analysCardsGroup(result[2], 'group_analyse_new')

