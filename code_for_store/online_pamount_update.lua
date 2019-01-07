local skynet = require "skynet"
local _redispool
local xx = {}

function xx.init()
	_redispool = skynet.uniqueservice("redispool")
	local ok, time = pcall(skynet.call, _redispool, "lua", "execute", "get", 'outbitch')
	if tonumber(time) < os.time() then
		pcall(skynet.call, _redispool, "lua", "execute", "del", 'outbitch')
		pcall(skynet.call, _redispool, "lua", "execute", "del", 'online_pamount_update')
		pcall(skynet.call, _redispool, "lua", "execute", "del", 'gl')
		pcall(skynet.call, _redispool, "lua", "execute", "del", 'xxxlg')
	end
end

return xx