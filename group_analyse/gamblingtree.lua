local util = require 'ai_util'
local logic = require 'logic'

local combination = require 'combination'
local gamblingtree = {}
gamblingtree.max_depth = 3

local _cut_branch = -1
local _not_define = -2

function gamblingtree.getoutcards(depth, sid, precards, cards)
	local grandFather = {}
	local father = {maxlayer = true, value = _not_define}
	-- gamblingtree.search(grandFather, father, depth, sid, precards, cards, true)
	gamblingtree.search(nil, father, depth, sid, precards, cards, false)
	print('answer is .....')
	luadump(father)
	return father.cards or {}
end

local function printStatus(cards, sid)
	logic.printCards(cards[sid])
	logic.printCards(cards[1 - (sid - 1) + 1])
end

function gamblingtree.search(grandFather, father, depth, sid, precards, cards, maxlayer)
	if depth > gamblingtree.max_depth then return end 
	if not next(cards[1]) or not next(cards[2]) then return end
	print(string.format('\n\n-------------depth:%d     sid = %d', depth, sid))
	-- logic.printMachineCards(cards[sid])
	-- logic.printMachineCards(precards)
	local options = combination.getOutCardsOptions(cards[sid], precards) or {}
	
	-- table.insert(options, {cards = {}})
	-- luadump(options)
	if not options or not next(options) then
		options = {{cards = {}}}
	end
	
	-- local tempcards = table.deepcopy(cards)
	local t = {}
	for i = 1, 2 do
		logic.printCards(cards[i])
	end
	for k, v in pairs(options) do
		util.removeTable(cards[sid], v.cards)
		t.maxlayer = maxlayer
		t.value = _not_define--combination.getCardsVaule(cards[sid])
		t.cards = v.cards
		-- printStatus(cards, sid)

		print(string.format('\n\n玩家 sid : %d 打出扑克', sid))
		logic.printCards(v.cards)
		gamblingtree.search(father, t, depth + 1, 1 - (sid - 1) + 1, v.cards, cards, not maxlayer)

		if (depth == gamblingtree.max_depth and t.value == _not_define) or (#cards[sid] < 1) then
			-- print('start calc')
			logic.printCards(cards[sid])
			logic.printCards(cards[1 - (sid - 1) + 1])
			if t.maxlayer then
				t.value = -combination.getCardsVaule(cards[sid]) - combination.getCardsVaule(cards[1 - (sid - 1) + 1])
			else
				t.value = combination.getCardsVaule(cards[sid]) - combination.getCardsVaule(cards[1 - (sid - 1) + 1])
			end
			print(string.format('depth:%d :-----sid:%d-------value:%d', depth, sid, t.value))
		end
		
		table.mergeByAppend(cards[sid], v.cards)
		-- logic.printCards(cards[sid])

		if t.value ~= _cut_branch then
			if maxlayer then
				if grandFather and grandFather.value ~= _not_define then
					if grandFather.maxlayer then
						if not father.maxlayer then
							if grandFather.value >= t.value then
								father.value = _cut_branch
								return
							end
						end
					else
						if father.maxlayer then
							if grandFather.value <= t.value then
								father.value = _cut_branch
								return
							end
						end
					end
				end

				-- print('depth   =  :%d', depth)
				if t.value ~= _not_define then
					if father.value == _not_define or (not father.maxlayer and t.value < father.value) or (father.maxlayer and t.value > father.value) then
						father.value = t.value
					end
				end
			else
				if grandFather and grandFather.value ~= _not_define then
					if not grandFather.maxlayer then
						if father.maxlayer then
							if grandFather.value <= t.value then
								father.value = _cut_branch
								return
							end
						end
					else
						if not father.maxlayer then
							if grandFather.value >= t.value then
								father.value = _cut_branch
								return
							end
						end
					end
				end
			end

			if t.value ~= _not_define then
				if father.value == _not_define or (father.maxlayer and t.value > father.value) or (father.maxlayer and t.value < father.value) then
					father.value = t.value
				end
			end

			if depth == 1 then
				if father.value ~= _not_define and t.value == father.value then
					father.cards = t.cards
				end
			end
		end
	end

	if depth > 2 and father.value ~= _not_define and father.value ~= _cut_branch then
		if grandFather.value == _not_define then
			grandFather.value = father.value
		elseif maxlayer then
			if grandFather.maxlayer then
				if not father.maxlayer then
					if grandFather.value < father.value then
						grandFather.value = father.value
					else
						father.value = _cut_branch
						return
					end
				else
					if grandFather.value < father.value then
						grandFather.value = father.value
					end
				end
			else
				if not father.maxlayer then
					if grandFather.value > father.value then
						grandFather.value = father.value
					end
				else
					if grandFather.value > father.value then
						grandFather.value = father.value
					else
						father.value = _cut_branch
						return
					end
				end
			end
		else
			if not father.maxlayer then
				if father.maxlayer then
					if grandFather.value > father.value then
						grandFather.value = father.value
					else
						father.value = _cut_branch
						return
					end

				else
					if grandFather.value > father.value then
						grandFather.value = father.value
					end
				end
			else
				if father.maxlayer then
					if grandFather.value < father.value then
						grandFather.value = father.value
					end
				else
					if grandFather.value < father.value then
						grandFather.value = father.value
					else
						father.value = _cut_branch
						return
					end
				end
			end
		end
	end
end

return gamblingtree