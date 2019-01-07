local util = require 'ai_util'
require 'group_analyse/functionsxx'
local test_data = require 'settle_account_test_data'
local _cfg = {allownegtive = nil}

local function test(data)
  local basegold = data.basegold --低分

  local odds = data.odds  --倍数
  local flag = data.flag --1庄家胜-1农民胜
  local isMatch = false -- 是否是比赛
  local master = data.master -- 地主
  local s = {}
  
  local fsid = {}
  for i = 1, 3 do
    if i ~= master then
      table.insert(fsid, i)
    end
    s[i] = basegold * odds 
  end

  local chge = {}
  local _doubled = data._doubled -- 加倍
  

  local players = {}
  players[1] = {gold = data.gold[1]}
  players[2] = {gold = data.gold[2]}
  players[3] = {gold = data.gold[3]}


  local s = {}  
  local fsid = {}
  for i = 1, 3 do
    _doubled[i] = _doubled[i] or 1
    if i ~= master then
      table.insert(fsid, i)
    end
    s[i] = basegold * odds 
  end
    local maxlimit
    if not _cfg.allownegtive then
      for i = 1, 3 do
        if i ~= master then
          s[i] = s[i] * _doubled[master] * _doubled[i]
        end
      end
      
      local maxlimit = players[master].gold
      if flag == 1 then
        --庄家 加倍之后最多可以赢身上金币的两倍
        if _doubled[master] == 2 then
          maxlimit = players[master].gold * 4
        end

        for i = 1, 3 do
          if i ~= master then
            if s[i] > players[i].gold then
              s[i] = players[i].gold
            end
          end
        end

        local totalwin = s[fsid[1]] + s[fsid[2]]
        if totalwin > maxlimit then
          totalwin = maxlimit
          for i = 1, 2 do
            s[fsid[i]] = math.ceil(totalwin / (_doubled[fsid[1]] + _doubled[fsid[2]])) * (_doubled[fsid[i]])
          end
        end
      else
      end
    end

    for i = 1, 3 do
      if i ~= master then
        chge[i] = -s[i] * flag
      end
    end
    if not _cfg.allownegtive then
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
        print('11111111111111111111111')
        if _doubled[fsid[1]] == _doubled[fsid[2]] then
          local olcg = {}
          local half = math.floor(players[master].gold / 2)
          local tl = {}
          for i = 1, 2 do
            olcg[fsid[i]] = chge[fsid[i]]
            tl[fsid[i]] = players[fsid[i]].gold
            if _doubled[fsid[i]] == 2 then tl[fsid[i]] = tl[fsid[i]] * 2 end
            if tl[fsid[i]] >= half then
              chge[fsid[i]] = half
            else
              chge[fsid[i]] = tl[fsid[i]]
            end
          end
          local remain = players[master].gold - chge[fsid[1]] - chge[fsid[2]]
          if remain > 0 then
            local excouldwin = 0
            for i = 1, 2 do
              if olcg[fsid[i]] > chge[fsid[i]] then
                excouldwin = tl[fsid[i]] - chge[fsid[i]]
                if excouldwin > remain then excouldwin = remain end
                if excouldwin and excouldwin > 0 then
                  chge[fsid[i]] = chge[fsid[i]] + excouldwin
                end
              end
            end
          end
        else
          local percent = chge[fsid[1]] /  (chge[fsid[1]] + chge[fsid[2]])
          chge[fsid[1]] = math.floor(percent * players[master].gold)
          chge[fsid[2]] = players[master].gold - chge[fsid[1]]
        end
      end
    end

    chge[master] = -(chge[fsid[1]] + chge[fsid[2]])
    
    local same = true
    for k, v in pairs(data.result) do
      --if v ~= chge[k] then
      if math.abs(v - chge[k]) > 1 then
        same = false
        break
      end
    end
    if not same then
      print('origin:\n')
      -- util.printTable(data)
      luadump(data)
      print('answer:\n')
      -- util.printTable(chge)
      luadump(chge)
    end
    
  end
  
  
for i = 1, #test_data do
  print('msg:--------------index: '..i)
  test(test_data[i])
end