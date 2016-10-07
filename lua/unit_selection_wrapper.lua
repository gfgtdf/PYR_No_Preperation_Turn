--<<
local _ = _textdomain_pyr_npt
local unit_selection_wrapper = {}
local V = helper.set_wml_var_metatable {}

local is_ai_side = function(side)
	-- TODO: maybe we should skip null-controlled sides?
	return wesnoth.sides[side].controller == "ai" or wesnoth.sides[side].controller == "network_ai" or wesnoth.sides[side].controller == "null"
end
unit_selection_wrapper.set_recruits = function(side, recruits)
	wesnoth.wml_actions.set_recruit( {side = side , recruit = table.concat(recruits, ",")} )
end

unit_selection_wrapper.ai_chose = function(side)

	if wesnoth.get_variable("pyr_npt_no_ai") then
		return wesnoth.sides[side].recruit
	end
	--choose random types.
	local unittypes = pyr_npt_unit_selection.get_unit_types(side)
	local r = {}
	local units_left = pyr_npt_unit_selection.max_selectalbe_units()
	local gold_left = pyr_npt_unit_selection.max_selectalbe_units_gold_limit()
	local unit_table = pyr_npt_unit_selection.random_choice(unittypes, gold_left, units_left)
	for k, v in pairs(unit_table) do
		table.insert(r, v.id)
	end
	return r
end


function unit_selection_wrapper.let_player_choose_sides()

	if V.pyr_npt_unit_limit == nil or V.pyr_npt_unit_pool_type == nil or V.pyr_npt_gold_limit == nil or V.pyr_npt_no_ai == nil then
		wesnoth.message("Pyr npt Mod", "Warning: PYR No Preperation Turn was not loaded correctly")
	end
	if V.pyr_npt_unit_pool_type == "all" then
		wesnoth.message("Pyr npt Mod", "Unit pool was set to 'all', this can cause OOS if you choose units that are not available to other players.")
	end
	if wesnoth.get_variable("pyr_npt_has_chosen_unit") and wesnoth.get_variable("pyr_npt_choose_units_once") then
		return
	end
		
	local sides = wesnoth.get_sides({})
	local sided_numbers = {}
	-- NOTE: We do this even for ai sides, because there are known bugs where a side appeared as ai for one side but not for another.
	for i,v in ipairs(sides) do
		table.insert(sided_numbers, v.side)
	end	
	
	local result = pyr_npt_synconize_choice(
		function(side)
			while true do
				local retv = pyr_npt_unit_selection.do_selection(side)
				if pyr_npt_unit_confirmation.confirm_recruitlist(retv) then
					return {serialized_recruits = pyr_npt_helper.serialize(retv)}
				end
			end
		end,
		function(side)
			local retv = unit_selection_wrapper.ai_chose(side)
			return {serialized_recruits = pyr_npt_helper.serialize(retv)}
		end,
		sided_numbers
	)


	for k,v in pairs(result) do
		if(v.serialized_recruits ~= nil) then
			local recruitlist = pyr_npt_helper.deseralize(v.serialized_recruits) 
			if (not (is_ai_side(k) and wesnoth.get_variable("pyr_npt_no_ai"))) and (pyr_npt_unit_selection.is_valid_recuitlist(recruitlist) ~= true) then
				wesnoth.message(pyr_npt_unit_selection.is_valid_recuitlist(recruitlist))
				error("player " .. tostring(k) .. " has an invalid recruitlist. Reason: " .. pyr_npt_unit_selection.is_valid_recuitlist(recruitlist))
			end
			unit_selection_wrapper.set_recruits(k,recruitlist)
		elseif wesnoth.sides[k].controller ~= "null" then
			error("failed to get data from non-empty side")
		end
	end
	wesnoth.set_variable("pyr_npt_has_chosen_unit", true)
end

return unit_selection_wrapper
-->>

