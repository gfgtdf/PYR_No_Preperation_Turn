--<<
local _ = _textdomain_pyr_npt
local confirm_recruitlist = function (recruitlist)
	local recruit_number = #recruitlist
	local images = pyr_npt_helper.tablemap(recruitlist, function(uid) return wesnoth.unit_types[uid].__cfg.image or pyr_npt_helper.thex_png end)
	local image_per_row = 5
	local rows = math.ceil(recruit_number/image_per_row)
	local gridcontent = {}
	for row = 1, rows do
		local rowcontent = { grow_factor = 1, horizontal_grow = true, vertical_grow = true,}
		for col = 1, image_per_row do
			local cellcontent =  { grow_factor = 1, horizontal_grow = true, vertical_grow = true,}
			local image = pyr_npt_helper.thex_png
			local index = (row - 1)*image_per_row + col 
			if index <= #images then
				image = images[index] .. "~SCALE(72,72)"
			end
			table.insert(cellcontent, T.image {
				--name = image,
				id = "unitimage" .. tostring(index)
			})
			
			table.insert(rowcontent, T.column(cellcontent))
		end
		table.insert(gridcontent, T.row(rowcontent))
	end
	if rows == 0 then
		table.insert(gridcontent, T.row {
			T.column {
				T.label {
					label = _"No recruits selected"
				}
			}
		})
	end
	local preshow = function()
		for row = 1, rows do
			for col = 1, image_per_row do
				local image = pyr_npt_helper.thex_png
				local index = (row - 1)*image_per_row + col 
				if index <= #images then
					image = images[index] .. "~SCALE(72,72)"
				end
				wesnoth.set_dialog_value(image, "unitimage" .. tostring(index))
			end
		end
	end
	
	local dialog = {
		maximum_height = 700,
		maximum_width = 850,
		T.helptip { id = "tooltip_large" }, -- mandatory field
		T.tooltip { id = "tooltip_large" }, -- mandatory field
		T.grid {
			T.row {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.column {
					border = "all",
					border_size = 5,
					horizontal_alignment = "left",
					T.label {
						definition = "title",
						label = _"Confirm Selected Units",
						id = "title"
					}
				}
			},
			T.row {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.column {
					grow_factor = 1,
					horizontal_grow = true,
					vertical_grow = true,
					T.grid (-- roudn bracets intended
						gridcontent
						--[[
						T.row {
							T.column {
								T.button {
									label = "OOK",
									id = "ook"
								}
							}
						}
						--]]
					)
				}
			},
			T.row {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.column {
					grow_factor = 1,
					horizontal_grow = true,
					vertical_grow = true,
					T.grid {
						horizontal_grow = true,
						vertical_grow = true,
						grow_factor = 1,
						T.row {
							horizontal_grow = true,
							vertical_grow = true,
							grow_factor = 1,
							T.column {
								border = "all",
								border_size = 5,
								T.button {
									label = _"OK",
									id = "ok",
									return_value = 1
								}
							},
							T.column {
								border = "all",
								border_size = 5,
								T.button {
									label = _"Abort",
									id = "abort",
									return_value = -2
								}
							},
						}
					}
				}
			},
		}
	}
	return wesnoth.show_dialog(dialog, preshow) == 1
end

return { confirm_recruitlist = confirm_recruitlist}
-->>