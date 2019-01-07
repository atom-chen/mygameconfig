-- local _cardres = {
-- 	10,11,12,13, -- 2
-- 	20,21,22,23, --3
-- 	30,31,32,33, --4
-- 	40,41,42,43, --5
-- 	50,51,52,53, --6
-- 	60,61,62,63, --7
-- 	70,71,72,73, --8
-- 	80,81,82,83, --9
-- 	90,91,92,93, --10
-- 	100,101,102,103, --J
-- 	110,111,112,113, --Q
-- 	120,121,122,123, --K
-- 	130,131,132,133, -- A
-- 	140,150} --小，大王

-- logic.ct_set = 6 三条
-- logic.ct_flushstraight = 5 同花顺
-- logic.ct_flush = 4 同花
-- logic.ct_straight = 3 顺子
-- logic.ct_pair = 2 对子
-- logic.ct_highcard = 1 单张

-- 150大王 = 红桃2 方块0
-- 140小王 = 黑桃3 梅花1

local test = {
{
  nodes = {
    {cards = {110, 23, 140}, ct = 2},
    {cards = {110, 23, 150}, ct = 2},
  },
  winner = 1
},
{
  nodes = {
    {cards = {131, 130, 140}, ct = 6},
    {cards = {132, 133, 150}, ct = 6},
  },
  winner = 2
},
{
  nodes = {
    {cards = {110, 112, 111}, ct = 6},
    {cards = {133, 123, 113}, ct = 5},
  },
  winner = 1
},
{
  nodes = {
    {cards = {21, 22, 23}, ct = 6},
    {cards = {150, 82, 112}, ct = 4},
  },
  winner = 1
},
{
  nodes = {
    {cards = {11, 12, 13}, ct = 6},
    {cards = {101, 112, 140}, ct = 3},
  },
  winner = 1
},
{
  nodes = {
    {cards = {51, 52, 53}, ct = 6},
    {cards = {50, 41, 140}, ct = 2},
  },
  winner = 1
},
{
  nodes = {
    {cards = {90, 91, 93}, ct = 6},
    {cards = {133, 123, 81}, ct = 1},
  },
  winner = 1
},
{
  nodes = {
    {cards = {101, 103, 102}, ct = 6},
    {cards = {91, 90, 93}, ct = 6},
  },
  winner = 1
},
{
  nodes = {
    {cards = {11, 21, 140}, ct = 5},
    {cards = {10, 20, 150}, ct = 5},
  },
  winner = 1
},
{
  nodes = {
    {cards = {130, 120, 10}, ct = 4},
    {cards = {133, 93, 140}, ct = 4},
  },
  winner = 2
},
{
  nodes = {
    {cards = {103, 113, 123}, ct = 5},
    {cards = {101, 112, 120}, ct = 3},
  },
  winner = 1
},
{
  nodes = {
    {cards = {62, 72, 82}, ct = 5},
    {cards = {133, 23, 140}, ct = 2},
  },
  winner = 1
},
{
  nodes = {
    {cards = {32, 42, 150}, ct = 5},
    {cards = {140, 112, 83}, ct = 1},
  },
  winner = 1
},
{
  nodes = {
    {cards = {140, 10, 150}, ct = 6},
    {cards = {60, 61, 62}, ct = 6},
  },
  winner = 2
},
{
  nodes = {
    {cards = {21, 61, 140}, ct = 4},
    {cards = {22, 150, 62}, ct = 4},
  },
  winner = 2
},
{
  nodes = {
    {cards = {132, 122, 102}, ct = 4},
    {cards = {131, 120, 150}, ct = 3},
  },
  winner = 1
},
{
  nodes = {
    {cards = {140, 91, 122}, ct = 2},
    {cards = {150, 102, 22}, ct = 4},
  },
  winner = 2
},
{
  nodes = {
    {cards = {51, 71, 101}, ct = 4},
    {cards = {52, 70, 103}, ct = 1},
  },
  winner = 1
},
{
  nodes = {
    {cards = {132, 122, 62}, ct = 4},
    {cards = {130, 150, 50}, ct = 4},
  },
  winner = 1
},
{
  nodes = {
    {cards = {133, 130, 150}, ct = 6},
    {cards = {132, 131, 140}, ct = 6},
  },
  winner = 2
},
{
  nodes = {
    {cards = {110, 123, 133}, ct = 3},
    {cards = {130, 80, 140}, ct = 2},
  },
  winner = 1
},
{
  nodes = {
    {cards = {63, 71, 83}, ct = 3},
    {cards = {62, 73, 82}, ct = 3},
  },
  winner = 1
},
{
  nodes = {
    {cards = {90, 81, 70}, ct = 3},
    {cards = {130, 101, 51}, ct = 1},
  },
  winner = 1
},
{
  nodes = {
    {cards = {132, 150, 93}, ct = 2},
    {cards = {131, 140, 83}, ct = 2},
  },
  winner = 2
},
{
  nodes = {
    {cards = {101, 73, 112}, ct = 1},
    {cards = {103, 72, 113}, ct = 1},
  },
  winner = 2
},
{
  nodes = {
    {cards = {101, 150, 72}, ct = 2},
    {cards = {131, 120, 93}, ct = 2},
  },
  winner = 1
},

{
  nodes = {
    {cards = {103, 102, 13}, ct = 2},
    {cards = {101, 10, 140}, ct = 2},
  },
  winner = 1
},
}

return test
