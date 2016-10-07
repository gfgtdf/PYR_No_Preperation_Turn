--<<
local sync_choice = {}

function sync_choice.get_global_variable(namespace, name, side)
	wesnoth.wml_actions.get_global_variable {
		namespace=namespace,
		from_global=name,
		to_local="pyr_npt_gobal_variable",
		side=side,
		immediate=true,
	}
	local r =  wesnoth.get_variable("pyr_npt_gobal_variable")
	wesnoth.set_variable("pyr_npt_gobal_variable", nil)
	return r
end

function sync_choice.set_global_variable(namespace, name, side, value)
	wesnoth.set_variable("pyr_npt_gobal_variable", value)
	wesnoth.wml_actions.set_global_variable {
		namespace=namespace,
		to_global=name,
		from_local="pyr_npt_gobal_variable",
		side=side,
		immediate=true,
	}
	wesnoth.set_variable("pyr_npt_gobal_variable", nil)
end

function sync_choice.clear_global_variable(namespace, name, side)
	wesnoth.wml_actions.set_global_variable {
		namespace=namespace,
		global=name,
		side=side,
		immediate=true,
	}
end

function sync_choice.version1_11_13(func_human, func_ai, sides)
	local r = {}
	local local_sides = {}
	for k,v in pairs(sides) do
		local ir = tostring(math.random(1000000000)) .. "_" .. tostring(os.time()) .. "_" .. tostring(os.clock()) .. "_" .. tostring(wesnoth.get_time_stamp())
		sync_choice.set_global_variable("pyr_npt_1_12", "side_local_test" .. tostring(v), v, ir)
		local ircheck = sync_choice.get_global_variable("pyr_npt_1_12", "side_local_test" .. tostring(v), v)
		if ir == tostring(ircheck) then
			table.insert(local_sides, v)
		end
	end
	for k, v in pairs(local_sides) do
		local sideobj = wesnoth.sides[v]
		local r_side
		if sideobj.controller == "human" or func_ai == nil then
			r_side = func_human(v)
		else
			r_side = func_ai(v)
		end
		sync_choice.set_global_variable("pyr_npt_1_12", "side_recruits" .. tostring(v), v, r_side)
	end
	for k,v in pairs(sides) do
		wesnoth.message("Pyr npt Mod", "Waiting for input from side " ..  tostring(v))
		r[v] = sync_choice.get_global_variable("pyr_npt_1_12", "side_recruits" .. tostring(v), v)
		wesnoth.message("Pyr npt Mod", "Received input from side " ..  tostring(v))
	end
	return r
end
function sync_choice.version1_13(func_human, func_ai, sides)
	return wesnoth.synchronize_choice(func_human, func_ai, sides)
end
return sync_choice
-->>