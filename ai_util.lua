require "lfs"
local ai_util = {}
function ai_util.copyTab(st)  
    local tab = {}  
    for k, v in pairs(st or {}) do  
        if type(v) ~= "table" then  
            tab[k] = v  
        else  
            tab[k] = ai_util.copyTab(v)  
        end  
    end  
    return tab
end

function ai_util.vInTbl(t, val)
    if not val then return false end
    for k, v in pairs(t) do
        if v == val then 
            return true
        end
    end
    return false
end

function ai_util.merge(originTb, exTb)
	if not exTb or not next(exTb) then return originTb end
	
	for k, v in pairs(exTb) do
		table.insert(originTb, v)
	end

	return originTb
end

function ai_util.removeTable(originTb, exTb)
	for k, v in pairs(exTb) do
		for i = 1, #originTb do
			if originTb[i] == v then
				table.remove(originTb, i)
			end
		end
	end
	return originTb
end

function ai_util.getRandom(n, m)
	--math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	if not n and not m then
		return math.random()
	elseif n ~= nil and m == nil then
		return math.random(n)
	elseif n ~= nil and m ~= nil then
		return math.random(n, m)
	end
end

function ai_util.printTable(tb, headStr)
    if not headStr then headStr = '' end
    print(headStr..'{')
    for k, v in pairs(tb or {}) do
     --    print(k)
    	-- io.write(tostring(k))
        print(tostring(k))
        if type(v) ~= "table" then  
            print(headStr..'  '..tostring(v)) 
        else  
            ai_util.printTable(v, headStr..'  ')  
        end
    end
    print(headStr..'}')
end

function ai_util:serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then
        if type(name) == 'string' then
            tmp = tmp .. name .. " = " 
        -- end
        elseif type(name) == 'number' then
            tmp = tmp .. '['..name .. "] = " 
        end
    end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. self:serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
            --tmp =  tmp .. self:serializeTable(v, k, skipnewlines, depth + 1) .. "," .. ("")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

local getpathes
getpathes = function(rootpath, pathes)
    --pathes = pathes or {}

    local ret, files, iter = pcall(lfs.dir, rootpath)
    if ret == false then
        return pathes
    end
    for entry in files, iter do
        local next = false
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath .. '/' .. entry
            local attr = lfs.attributes(path)
            if attr == nil then
                next = true
            end

            if next == false then 
                if attr.mode == 'directory' then
                    getpathes(path, pathes)
                else
                    table.insert(pathes, path)
                end
            end
        end
        next = false
    end
    return pathes
end

function ai_util:getAllPath(root)
  local pathes = {}
  getpathes("D:\\soft\\zerobrane", pathes)
  --for key, path in pairs(pathes) do
  --  print(key .. " " .. path)
  --end
  return pathes
end

--math.ceil向上取整
--math.floor向下取整

return ai_util