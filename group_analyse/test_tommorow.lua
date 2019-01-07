local logic = require 'tommorow_lg'
local dropcardslg = require 'dropcardslg'

require 'functionsxx'


-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] - "<var>" = {
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "cards" = {
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         1 = 43
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         2 = 83
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         3 = 32
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         4 = 31
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         5 = 33
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         6 = 91
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         7 = 41
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     }
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "ct"    = 4
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "kv"    = 3
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "multi" = 1
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] - }
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:49] dump from: [string "local skynet = require "skynetext"..."]:351: in upvalue 'settle_account'
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] - "<var>" = {
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "cards" = {
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         1 = 92
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         2 = 72
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         3 = 40
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         4 = 113
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         5 = 61
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         6 = 10
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -         7 = 22
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     }
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "ct"     = 5
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "kv"     = 4
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "multi"  = 1
-- [2018-02-10 15:56:15.133] [DEBUG] [game4-56] [./common/functions.lua:95] -     "seatid" = 1
--[[
local cards = {
	{91, 90, 92, 63, 61}, 
	{112, 90, 73, 52, 32}
}


local node = {}
node.ct, node.kv =  logic.getCardType(cards[1])
--luadump(node)


local nodes = logic.gettotalcards(5)
	local v
	for k, v in pairs(nodes) do
    luadump(v)
    print(string.format('ct : %d      kv:%d  multi: %d', v.ct, v.kv, v.multi))
    logic.printCards(v.cards)
    logic.printCards(v.hidecards)
    print('\n')
	end
  

  print('--------------------------------')
  local prob = {
			[1] = {probability = 1000, reward = "0:500"},
			--[2] = {probability = 300, reward = "0:1000"},
			--[3] = {probability = 100, reward = "0:1500"},
			--[4] = {probability = 50, reward = "0:2500"},
			--[5] = {probability = 29, reward = "0:10000"},
			--[6] = {probability = 20, reward = "0:25000"},
			--[7] = {probability = 1, reward = "0:50000"},
		}
  for i = 1, 100 do
    local node = dropcardslg.getcardsnode(prob)
    logic.printCards(node.cards)
    print(string.format('  ct:%d\n', node.ct))
  end
  
  
  local testct = require 'tommorow_cardtype'
  
  for k, v in pairs(testct) do
    local ct, kv = logic.getCardType(v.cards)
    if ct ~= v.ct then
      logic.printMachineCards(v.cards)
      print(string.format('anser is not same!! key:%d   test:%d    calc:%d', k, v.ct, ct))
    end
  end
  --]]
  
  print('\n\n！！！！！！！！！！！！！！！！！！！！！！！！！！！')
  
  local texasholdem_lg = require 'texasholdem_lg'
  
  local nodes = texasholdem_lg.gettotalcards(9, 1)
	local v
	for k, v in pairs(nodes) do
    --luadump(v)
    --print(string.format('ct : %d      kv:%d  multi: %d', v.ct, v.kv, v.multi))
    logic.printCards(v.cards)
    logic.printCards(v.hidecards)
    print('\n')
	end
  --[[
  local testct = require 'texasholdem_cardtype'
  for k, v in pairs(testct) do
    local ct, kv = texasholdem_lg.getCardType(v.cards)
    if ct ~= v.ct then
      logic.printMachineCards(v.cards)
      print(string.format('anser is not same!! key:%d   test:%d    calc:%d', k, v.ct, ct))
    end
  end

  
  print('\n\n----------------------------------------------')
  
  local nodes, publiccards = texasholdem_lg.gettotalcards(6)
  texasholdem_lg.printCards(publiccards)
  
  for k, v in pairs(nodes) do
    texasholdem_lg.printCards({v.cards[1], v.cards[2]})
  end
    --]]
  print('\n\n========================================================')
  local ctc = require 'texasholdem_ctcompare'
  for k, v in pairs(ctc) do
    --if k == 48 then
      local win = 2
      local r = texasholdem_lg.cards1better(v.cards1, v.cards2)
      if r and r ~= -1 then
        win = 1
      end
      
      if r == -1 then win = -1 end
      
      if v. win ~= win then
        print(string.format('idx:%d  anser is not same!! test:%d    calc:%d', k, v.win, win))
      end
    --end
    --texasholdem_lg.printCards({v.cards[1], v.cards[2]})
  end
  
  