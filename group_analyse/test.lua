local revkey = require "uid_map_reverse_key"
local _uid_map_key = require 'uid_map_key'
local function revuidfake( fakeuid )
	--print(string.format('\n\nrevuidfake  fakeid = %d', fakeuid))
	local struid = tostring(fakeuid)
	local uid = ""
	local front, tail, part
	local len = string.len(struid)
	local tail = string.sub(struid, len, len)
	--print(string.format("struid:%s, len:%d, tail:%d", struid, len, tail))
	for i=1,len - 1 do
		local part = string.sub(struid, len - i, len - i)
		front = revkey[len - i].row[tonumber(part) + 1]
		tail = revkey[len - i].column[tonumber(tail) + 1]
		--LOG_DEBUG("part:%d, front:%d, tail:%d", part, front, tail)
		uid = tostring(front)..uid
	end
	--LOG_DEBUG('revuidfake  uid = %s', uid)
	return tonumber(uid)
end

local function uidfake(uid)
	local struid = tostring(uid)
	local rand = 0
	local fakeuid = ""
	local front, tail, part
	local tail = rand
	for i=1,string.len(struid) do
		part = string.sub(struid, i, i)
		front = _uid_map_key[i].row[tonumber(part) + 1]
		tail = _uid_map_key[i].column[tail + 1]
		fakeuid = fakeuid..front
	end
	fakeuid = fakeuid..tail
	return tonumber(fakeuid)
end

local uid = {
  1005025,
  1005026,
  1005027,
}

local fids = {
  77293546,
  77293545,
}

for k, v in pairs(uid) do
  local fid = uidfake(v)
  print(string.format('uid: %d   fid: %d   rev uid: %d', v, fid, revuidfake( fid )))
end

print('------------------------------')
for k, v in pairs(fids) do
  --local fid = uidfake(v)
  --print(string.format('uid: %d  ', revuidfake( v )))
end


local time = os.time() + 3600 * 24 * 365
print(time)
print(os.date("%Y年%m月%d日 %H:%M:%S", time))