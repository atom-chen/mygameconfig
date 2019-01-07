
local skynet = require "skynet"
Events = {};

Events.events = {}

Events.em_msg_type = {
	fish_check = 1,
	fish_trace = 2,
	fish_update_gold = 3,--定期更新分数
	fish_check_user = 4--检查用户是否卡在房间不动
}

--id为某一类的消息，belongto为归属于哪个用户的消息，为nil,表示不归属谁
function Events:AddEvent(id,delaytime,funccallback,carrdata,belongto)
	for i=#self.events,1,-1 do
		if self.events[i].id == id and carrdata == self.events[i].carrdata then
			--self[i].delaytime = delaytime
			print("AddEvent",carrdata)
			return
		end
	end

	table.insert(self.events,{id = id,delaytime = delaytime,funccallback = funccallback,carrdata = carrdata,addtime = skynet.time()});
end

function Events:DelEvent( belongto )
	while(#self.events>0)
	do
		bFind = false
		for i=#self.events,1,-1 do
			if self.events[i].belongto ~=nil and self.events[i].belongto == belongto then
				table.remove(self.events,i);
				bFind = true
				break;
			end
		end
		if bFind == false then
			return
		end
	end
end

function Events:DelEventById( id )
	bFind = true
	while(bFind)
	do
		bFind = false
		for i=#self.events,1,-1 do
			if self.events[i].id ~=nil and self.events[i].id == id then
				table.remove(self.events,i);
				bFind = true
				break;
			end
		end
		if bFind == false then
			return
		end
	end
end

function Events:CheckEvent(  )
	local currTime = skynet.time()
	for i=#self.events,1,-1 do
		--print("CheckEvent num",#self.events)
		if currTime>self.events[i].addtime and currTime-self.events[i].addtime>self.events[i].delaytime then
			local tid = self.events[i].id
			local tcarrdata = self.events[i].carrdata
			local func = self.events[i].funccallback
			table.remove(self.events,i);
			func(tid,tcarrdata)
			break;
		end
	end
end

function Events.Clear( )
	-- body
	Events.events = {}
end

return Events