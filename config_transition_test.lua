require 'group_analyse/functionsxx'  

local json = require('json4lua-master/json/json')

local function writeluajson(conf, filename, jsononly)
	if not jsononly then
		local tmp = util:serializeTable(conf)
		print('local conf = '..tmp..'\nreturn conf')

		local file1=io.output(filename..'.lua')
		io.write('local conf = '..tmp..'\nreturn conf')
		io.flush()
		io.close()
	end
	  
	-- Object to JSON encode
	local jsonText = json.encode(conf)
	print('\n\n--------------------------------------------------------------------------json--------------------------------------------------------------------------\n\n')
	print(jsonText)

	local file2=io.output(filename..'.json')
	io.write(jsonText)
	io.flush()
	io.close()
end

-- for k, v in pairs(group_rooms) do
-- 	writeluajson(v, k)
-- end


-- print('msg:----------------')
-- local tmp = util:serializeTable(match)
-- print('local conf = '..tmp..'\nreturn conf')

-- local file1=io.output("roomListConfig.lua")
-- io.write('local conf = '..tmp..'\nreturn conf')
-- io.flush()
-- io.close()
  
-- -- Object to JSON encode
-- local json = require('json4lua-master/json/json')

-- local jsonText = json.encode(clientConfig)

-- print('\n\n--------------------------------------------------------------------------json--------------------------------------------------------------------------\n\n')
-- print(jsonText)

-- local file2=io.output("roomListConfig.json")
-- io.write(jsonText)
-- io.flush()
-- io.close()


-- local jitem_config = json.encode(item_config)
-- print('\n\n--------------------------------------------------------------------jitem_config------------------------------------------------------------------------\n\n')
-- print(jitem_config)

-- local file3=io.output("item_conf.json")
-- io.write(jitem_config)
-- io.flush()
-- io.close()
----[[


local xxxx
xxxx = function (conf)
  for k, v in pairs(conf) do
    if type(k) ~= 'string' then
			conf[tostring(k)] = v
			conf[k] = nil
		end
    
    if type(v) == 'table' then
      --print(string.format('key: %s', tostring(k)))
      xxxx(v)
      --conf[tostring(k)] = xxxx(v)
			--conf[k] = nil
    end
	end
end

local function xxxconvert2json(conf, fname)
	--[[for k, v in pairs(conf) do
		if type(k) ~= 'string' then
			conf[tostring(k)] = v
			conf[k] = nil
		end
	end--]]
  xxxx(conf)
  luadump(conf)
	writeluajson(conf, fname, true)
end



local dbs_config = require 'dbs_config'
xxxconvert2json(dbs_config, 'dbs_config')

--]]