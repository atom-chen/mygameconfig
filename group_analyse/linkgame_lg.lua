local logic = {}

logic.max_cards_amount = 28
local _row = 7
local _line = 10

function logic.printmap(map)
	local str
	for i = 1, _line do
		str = ''
		for j = 1, _row do
			str = string.format("%s %d", str, map[i][j])
			-- LOG_DEBUG('%d  ', map[i][j])
		end
		LOG_DEBUG('%s\n', str)
	end
	LOG_DEBUG('\n')
end

function logic.mapcleard(map)
	local img = 0
	for i = 1, _line do
		for j = 1, _row do
			if map[i][j] ~= 0 then
				img = img + 1
			end
		end
	end
	return img <= 0
end

function logic.disorganizemap(map)
	local img = {}
	for i = 1, _line do
		for j = 1, _row do
			table.insert(img, map[i][j])
		end
	end

	local idx
	local size = _row * _line
	for i = 1, size do
		if img[i] ~= 0 then
			idx = math.random(1, size)
			if i ~= idx then
				img[i] = img[i] + img[idx]
				img[idx] = img[i] - img[idx]
				img[i] = img[i] - img[idx]
			end
		end
	end

	for i = 1, _line do
		for j = 1, _row do
			map[i][j] = img[(i - 1) * _row + j]
		end
	end
	-- logic.printmap(map)
end

function logic.createmap(line, row, imgcnt)
	_row = row
	_line = line
	local pice
	local img = {}
	local size = _row * _line
	for i = 1, (size / 2) do
		pice = math.random(1, imgcnt)
		table.insert(img, pice)
		table.insert(img, pice)
	end

	local idx
	for i = 1, (_row * _line) / 2 do
		idx = math.random(1, size)
		if i ~= idx then
			img[i] = img[i] + img[idx]
			img[idx] = img[i] - img[idx]
			img[i] = img[i] - img[idx]
		end
	end

	local map = {}
	for i = 1, line do
		map[i] = {}
		for j = 1, row do
			map[i][j] = img[(i - 1) * _row + j]
		end
	end

	-- map = {
	-- 	{2,2,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0},
	-- 	{0,0,0,5,7,0,0},
	-- 	{0,0,0,7,5,0,0},
	-- 	{0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0}
	-- }

	return map
end

local _dir = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
local _allowturncnt = 2

function logic.judgelinked(map, pos1, pos2)
	-- logic.printmap(map)
	-- luadump(pos1)
	-- luadump(pos2)
	if map[pos1.x][pos1.y] ~= map[pos2.x][pos2.y] or (pos1.x == pos2.x and pos1.y == pos2.y) then
		return
	end
	pos1.turn = 0
	local queue = {}
	table.insert(queue, pos1)
	-- local findpos2
	local v
	local tx, ty
	while #queue > 0 do--and not findpos2 do
		-- print('-----------------------\n\n')
		v = table.remove(queue)
		-- luadump(v)
		for i = 1, #_dir do
			tx = v.x + _dir[i][1]
			ty = v.y + _dir[i][2]
			if (tx > 0 and tx <= _line and ty > 0 and ty <= _row) and
				(map[tx][ty] == 0 or ((pos2.x == tx) and (pos2.y == ty))) then
				-- print('in ???')
				local node = {}
				node.x = tx
				node.y = ty
				node.col = map[tx][ty]
				-- node.turn = v.turn
				node.dir = i
				if v.dir and v.dir ~= i then
					-- v.turn = v.turn or 0
					if v.turn + 1 < 3 then
						node.turn = v.turn + 1
						table.insert(queue, node)
					end
				else
					node.turn = v.turn
					table.insert(queue, node)
				end

				if node.x == pos2.x and node.y == pos2.y and node.turn and node.turn < 3 then
					return true
				end
			end
		end
		-- luadump(queue)
	end
end

function logic.getanylinkedpos(map, pos1)
	-- logic.printmap(map)
	-- luadump(pos1)
	if map[pos1.x][pos1.y] == 0 then
		return
	end

	local queue = {}
	pos1.turn = 0
	table.insert(queue, pos1)
	-- local findpos2
	local v
	local tx,ty
	while #queue > 0 do--and not findpos2 do
		v = table.remove(queue)
		-- luadump(v)
		for i = 1, #_dir do
			-- if not v.dir or v.dir ~= i then
			tx = v.x + _dir[i][1]
			ty = v.y + _dir[i][2]
			if tx > 0 and tx <= _line and ty > 0 and ty <= _row and not (tx == pos1.x and ty == pos1.y) and
				(map[tx][ty] == 0 or map[tx][ty] == map[pos1.x][pos1.y]) then
				local node = {}
				node.x = tx
				node.y = ty
				node.col = map[tx][ty]
				-- node.turn = v.turn
				node.dir = i
				if v.dir and v.dir ~= i then
					-- node.turn = node.turn or 0
					if v.turn + 1 < 3 then
						node.turn = v.turn + 1
						table.insert(queue, node)
					end
				else
					node.turn = v.turn or 0
					table.insert(queue, node)
				end

				if map[pos1.x][pos1.y] == map[node.x][node.y] and node.turn and node.turn < 3 then
					return node
				end
			end
		end
	end
end

function logic.findlinkpos(map)
	local node
	for i = 1, _line do
		for j = 1, _row do
			if map[i][j] ~= 0 then
				node = logic.getanylinkedpos(map, {x = i, y = j, col = map[i][j]})
				if node then
					return {x = i, y = j}, node
				end
			end
		end
	end
end

return logic