local util = require 'ai_util'
require 'group_analyse/functionsxx'

local basegold = 1

local odds = 48
local flag = 1 --1庄家胜-1农民胜
local isMatch = false
local s = basegold * odds

local chge = {}
local _doubled = {1,1,1}
local master = 1

local players = {}
players[1] = {gold = 100}
players[2] = {gold = 100}
players[3] = {gold = 100}


	local maxlimit
	if not isMatch then
		--
		-- if flag == -1 and s * 2 > players[master].gold then
		-- 	s = math.ceil(players[master].gold / 2)
		-- end
		s = s * _doubled[master]
		local maxlimit = players[master].gold
		if flag then
			--庄家 加倍之后最多可以赢身上金币的两倍
			if _doubled[master] == 2 then
				maxlimit = players[master].gold * 4
			end
		end
		if s * 2 > maxlimit then
    		s = math.ceil(maxlimit / 2)
    	end
	end

	local fsid = {}
	for i = 1, 3 do
		if i ~= master then
			table.insert(fsid, i)
			chge[i] = -s * flag

			if not isMatch and _doubled[i] == 2 then
				chge[i] = chge[i] * 2
			end
		end
	end

	if not isMatch then
		for i = 1, 3 do
			if i ~= master then
				--农民胜
				if flag == -1 then
					--加倍过可以赢身上两倍的金币
					if _doubled[i] == 2 then
						maxlimit = players[i].gold * 2
					else
						maxlimit = players[i].gold
					end

					if chge[i] > maxlimit then
						chge[i] = maxlimit
					end
				end

				if chge[i] + players[i].gold < 0 then
					chge[i] = -players[i].gold
				end
			end
		end
		--庄家金币不够赔 则按倍数分给农民
		if (chge[fsid[1]] + chge[fsid[2]]) > players[master].gold then
			local percent = chge[fsid[1]] /  (chge[fsid[1]] + chge[fsid[2]])
			chge[fsid[1]] = math.floor(percent * players[master].gold)
			chge[fsid[2]] = players[master].gold - chge[fsid[1]]
		end
	end

	chge[master] = -(chge[fsid[1]] + chge[fsid[2]])
  
  util.printTable(chge)
  
  
  
  local str = "132465|425"
  print(string.find(str, "|"))
  
  print(string.sub(str, 1, string.find(str, "|") - 1))
  
  local test = "sdaf"
  print(tonumber(test))
  
  print(os.time({year=2017, month=11, day=12, hour=0, min=0, sec=0}))
  print(os.date("%Y年%m月%d日 %H:%M:%S", 1510416000))
  
  local xx = {11,21,31,31,42}
  local removed = true
  while removed do
    removed = false
    for k, v in pairs(xx) do
      if v % 10 == 1 then
        table.remove(xx, k)
        removed = true
      end
    end
  end
  
  util.printTable(xx)
  
  
  local time = os.time() - 24 * 3600
	local date = os.date("*t", time)
	print(time - (date.hour*3600 + date.min*60 + date.sec))
  print(os.date("%Y年%m月%d日 %H:%M:%S", time - (date.hour*3600 + date.min*60 + date.sec)))
  
  
  
  local players = {}
  for i = 1, 10 do
    table.insert(players, i)
  end
  
    util.printTable(players)
    
    for i = 1, 3 do
      table.remove(players, 1)
    end
     util.printTable(players)
     
    local ok,xx = pcall(require, 'room_conf')
     local ok,tt = pcall(require, '33')
     if ok then xx = tt end
    util.printTable(xx)
    
    
    local __FILE__ = debug.getinfo(1,'S').source:sub(2)--debug.getinfo(1,'S').source:sub(2)
    print(__FILE__)
    
    
local socket = require("socket")
--print(os.time())
function GetAdd(hostname)
    local ip, resolved = socket.dns.toip(hostname)
    local ListTab = {}
    for k, v in ipairs(resolved.ip) do
        table.insert(ListTab, v)
    end
    return ListTab
end

--print(socket.dns.gethostname())
--print(unpack(GetAdd('localhost')))
print(unpack(GetAdd(socket.dns.gethostname())))
 print(os.date("%Y年%m月%d日 %H:%M:%S", 1503817033))


--util.printTable(os.date("*t", os.time()))
local util = require 'ai_util'
local t = {1, 2, 3, 4}
table.remove(t, 2)
util.printTable(t)


local function get_monday(t)
	local tdate = os.date("*t", t)
	local twday = tdate.wday
	if twday == 1 then twday = 8 end
	local subday = twday - 2
	local tempyear = t - subday * 24 * 3600

	local year = os.date("%Y", tempyear)
	local month = os.date("%m", tempyear)
	local day = os.date("%d", tempyear)

	return string.format("%d_%d_%d", year, month, day)
end

local t = os.time()
print(get_monday(t))
print(get_monday(t) == "2018_1_1")


local nstr = "https://pl-ddz.hztangyou.com/uploads/avatar/txa"
local old = "http://pl.ddz.htgames.cn:18998/uploads/avatar/txa1613.jpg"

local str = string.gsub(old, 'http://pl.ddz.htgames.cn:18998/uploads/avatar/txa', nstr)
print(str)


print(os.date("%Y年%m月%d日 %H:%M:%S", 1518537600))


print(os.time({year=2018, month=3, day=5, hour=0, min=0, sec=0}))




local _diamond_rc_normal = {
  {
    {850, 40, 90},
    {50, 100, 150},
    {50, 200, 250},
    {25, 300, 400},
    {23, 500, 900},
    {1, 1000, 3000},
    {1, 3000, 5000},
  },
  {
    {600, 40, 90},
    {200, 100, 150},
    {100, 200, 250},
    {50, 300, 400},
    {48, 500, 900},
    {1, 1000, 3000},
    {1, 3000, 5000},
  },
}

local answer
for i = 1, #_diamond_rc_normal do
  answer = 0
  for k, v in pairs(_diamond_rc_normal[i]) do
    local av = (v[2] + v[3]) / 2 * v[1] / 1000
    answer = answer + av
  end
  print(answer)
end
    

local rnickname = 'k.?_1956'
local nickname = string.gsub(rnickname, "_%d%d%d%d", "")
print(nickname)

local xxx = {1,2,3,4,4,87}
for k, v in pairs(xxx) do
  if v == 4 then
    xxx[k] = nil
  end
end

luadump(xxx)



local curdate = os.date("*t", os.time())
local todayzero = os.time({year=curdate.year, month=curdate.month, day=curdate.day + 1, hour=0, min=0, sec=0})
print(todayzero)


local xx = -1

if xx then
  print('-1 is true')
else
  print('-1 is false')
end

print(os.date("%Y年%m月%d日 %H:%M:%S", 1522512000))


local function getcards(id)
	if not id or id < 0 or id > 3 then return end
	local cards = {}
	if id == 0 then -- 生成2 2 1 的组合
		local temp = {1, 2, 3}

		local tidx = math.random(1, #temp)
		cards[1] = temp[tidx]
		cards[2] = temp[tidx]
		table.remove(temp, tidx)

		tidx = math.random(1, #temp)
		cards[3] = temp[tidx]
		cards[4] = temp[tidx]
		table.remove(temp, tidx)
		cards[5] = temp[1]
	else -- 生成确保有三张一样的组合
		for i = 1, 3 do
			cards[i] = id
		end
		cards[4] = math.random(1, 3)
		cards[5] = math.random(1, 3)
	end

	return cards
end

luadump(getcards(0))




local sum = 0
local function getcardsdfs(arr, sp)
  if table.len(arr) >= 5 then
    local ss = 0
    for k, v in pairs(arr) do
      ss = ss + v
    end
    if ss < 10 then
      for k, v in pairs(arr) do
        print('%d, ', v)
      end
      print('\n')
      sum = sum + 1
    end
    return
  end
  for i = sp, 5 do
    table.insert(arr, i)
    getcardsdfs(arr, i)
    table.remove(arr, #arr, 1)
  end
end

local xx = {}
getcardsdfs(xx, 1)

print(string.format('-----------------------sum:%d', sum))

for i = 1, 100 do
  --print(string.format("https://pl-ddz.hhh100.com/uploads/avatar/head%d.png", math.random(1,8)))
  
  print("https://pl-ddz.hhh100.com/uploads/avatar/head"..(math.random(1,8))..".png")
    --          _userdata.imageid = "https://pl-ddz.hhh100.com/uploads/avatar/head"..(math.random(1,8))..".png"

end


local diamond_rc_percent = {
  {560, 30, 60},
        {308, 60, 150},
        {80, 150, 200},
        {30, 500, 800},
        {10, 1000, 2500},
        {8, 3000, 5000},        
        {3, 5000, 7000},
        {1, 7000, 10000},
  }
local percent = 1000--math.random(1000)
	local percent_t = 0
	local rc = 0
	for i = 1, #diamond_rc_percent do
		percent_t = percent_t + diamond_rc_percent[i][1]
		print(' percent:%d    percent_t : %d', percent, percent_t)
    luadump(diamond_rc_percent[i])
		if percent <= percent_t then
      print(string.format('!!!!!!i = %d   diamond_rc_percent[i][2]: %d diamond_rc_percent[i][3]: %d', i, diamond_rc_percent[i][2], diamond_rc_percent[i][3]))
			rc = math.random(diamond_rc_percent[i][2], diamond_rc_percent[i][3])
      print(string.format('!!!!!!!!!!!!!!!!!!!!!rc = %d', rc))
			--CMD.add_red_coin(roomid, rc, 1, {'wincnt'})
			break
		end
	end
  
  print(os.time())
  
  print(os.date("%Y年%m月%d日 %H:%M:%S", 1541606400))
  
  print('============================')
  print(os.date("%x %X", os.time()))