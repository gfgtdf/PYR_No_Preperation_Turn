--<<
local _ = _textdomain_pyr_npt
local V = helper.set_wml_var_metatable {}

local unit_selection_wrapper = {}

function unit_selection_wrapper.ai_chose(side)

	if V.pyr_npt_no_ai then
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
	if V.pyr_npt_has_chosen_unit and V.pyr_npt_choose_units_once then
		return
	end

	local sided_numbers = {}
	-- NOTE: We do this even for ai sides, because there are known bugs where a side appeared as ai for one side but not for another.
	for i,v in ipairs(wesnoth.sides) do
		table.insert(sided_numbers, v.side)
	end	
	local result = wesnoth.synchronize_choices(
		_ "recruit selection",
		function(side)
			if wesnoth.sides[side].controller == "human" then
				while true do
					local retv = pyr_npt_unit_selection.do_selection(side)
					if pyr_npt_unit_confirmation.confirm_recruitlist(retv) then
						return {serialized_recruits = pyr_npt_helper.serialize(retv)}
					end
				end
			else
				local retv = unit_selection_wrapper.ai_chose(side)
				return {serialized_recruits = pyr_npt_helper.serialize(retv)}
			end
		end,
		sided_numbers
	)

	for k,v in pairs(result) do
		local side = wesnoth.sides[k]
		if v.serialized_recruits ~= nil then
			local recruitlist = pyr_npt_helper.deseralize(v.serialized_recruits)
			local should_ignore_invalid = (side.controller == "ai" or side.controller == "null") and V.pyr_npt_no_ai
			if not should_ignore_invalid then
				local is_valid, reason = pyr_npt_unit_selection.is_valid_recuitlist(recruitlist)
				if not is_valid then
					wesnoth.message("Pyr npt Mod", "player " .. tostring(k) .. " has an invalid recruitlist. Reason: " .. reason)
				end
			end
			side.recruit = recruitlist
		elseif side.controller ~= "null" then
			error("failed to get data from non-empty side")
		end
	end
	V.pyr_npt_has_chosen_unit = true
end

return unit_selection_wrapper

-->>
