--<<
local T = helper.set_wml_tag_metatable {}
local _ = _textdomain_pyr_npt
local function GUI_FORCE_WIDGET_MINIMUM_SIZE(w,h, content)
	return T.stacked_widget {
		definition = "default",
			T.stack {
				T.layer {
				T.row {
					T.column {
						T.spacer {
							definition = "default",
							width = w,
							height = h
						}
					}
				} 
			},
			T.layer {
				T.row {
					grow_factor = 1,
					T.column {
						grow_factor = 1,
						horizontal_grow = "true",
						vertical_grow = "true",
						content
					}
				} 
			}
		}
	}
end
local unit_list = T.listbox {
	id = "unit_list",
	vertical_scrollbar_mode = "always",
	T.list_definition {
		T.row {
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.toggle_panel {
					T.grid {
						T.row {
							grow_factor = 1,
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								T.image {
									id = "list_image",
									linked_group = "pyr_image"
								}
							},
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								GUI_FORCE_WIDGET_MINIMUM_SIZE(150,5,
									T.label {
										id = "list_name",
										linked_group = "pyr_lg_name"
									}
								)
							}
						}
					}
				}
			}
		}
	}
}


local chosen_unit_list = T.listbox {
	id = "chosen_unit_list",
	vertical_scrollbar_mode = "always",
	T.list_definition {
		T.row {
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.toggle_panel {
					T.grid {
						T.row {
							grow_factor = 1,
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								T.image {
									id = "list_image2",
									linked_group = "pyr_image_chosen"
								}
							}
						}
					}
				}
			}
		}
	}
}


local chosen_unit_panel = T.grid{ 
	T.row { 
			grow_factor = 0,
		T.column {
			border = "all",
			border_size = 5,
			horizontal_grow = true,
			vertical_grow = true,
			grow_factor = 0,
			chosen_unit_list
		}
	},
	T.row {
			grow_factor = 1,
		T.column {
			horizontal_alignment = "left",
			border_size = 0,
			grow_factor = 1,
			T.spacer {
			}
		}
	},
	T.row {
			grow_factor = 0,
		T.column {
			horizontal_alignment = "left",
			border = "left, right",
			border_size = 5,
			grow_factor = 0,
			T.label {
				horizontal_alignment = "left",
				id = "pyr_total_count",
			}
		}
	},
	T.row {
			grow_factor = 0,
		T.column {
			horizontal_alignment = "left",
			border = "left, right, bottom",
			border_size = 5,
			grow_factor = 0,
			T.label {
				horizontal_alignment = "left",
				id = "pyr_total_cost",
			}
		}
	}
}

local race_list = T.listbox {
	id = "race_list",
	vertical_scrollbar_mode = "always",
	T.list_definition {
		T.row {
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.toggle_panel {
					T.grid {
						T.row {
							grow_factor = 1,
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								T.label {
									id = "race_name",
									linked_group = "pyr_lg_race_name"
								}
							}
						}
					}
				}
			}
		}
	}
}


local details_panel_pages =   T.grid {
				--horizontal_grow = true,
				--vertical_grow = true,
				--horizontal_alignment = "left",
				--vertical_alignment = "top",
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "top",
				T.image {	
					id = "unit_image"
				}
			}
		},
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				horizontal_grow = true,
				vertical_grow = true,
				GUI_FORCE_WIDGET_MINIMUM_SIZE(80,50,
					T.label {
						id = "unit_name",
						wrap= true
					}
				)
			}
		},
		T.row {
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "bottom",
				T.button {
					id = "show_help_button",
					label = _"show help"
				}
			}
		},
		T.row {
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "bottom",
				T.button {
					id = "add_button",
					label = _"Add"
				}
			}
		},
		T.row {
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "bottom",
				T.button {
					id = "remove_button",
					label = _"Remove"
				}
			}
		},
		T.row {
			grow_factor = 1,
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "bottom",
				T.spacer {
					id = "details_spacer",
				}
			}
		},
		T.row {
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "bottom",
				T.button {
					id = "remove_all_button",
					label = _"Remove All"
				}
			}
		},
		T.row {
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "bottom",
				T.button {
					id = "random_choice_button",
					label = _"Fill Random"
				}
			}
		},
		T.row {
			vertical_alignment = "bottom",
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "bottom",
				T.button {
					id = "ok",
					label = _"Ok"
				}
			}
		}
}


local main_window = {
	maximum_height = 700,
	maximum_width = 850,

	T.helptip { id = "tooltip_large" }, -- mandatory field
	T.tooltip { id = "tooltip_large" }, -- mandatory field

	T.linked_group { id = "pyr_image", fixed_width = true },
	T.linked_group { id = "pyr_image_chosen", fixed_width = true },
	T.linked_group { id = "pyr_lg_name", fixed_width = true },
	T.linked_group { id = "pyr_lg_race_name", fixed_width = true },

	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				T.label {
					definition = "title",
					label = _"Unit selction for side",
					id = "title"
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				horizontal_grow = true,
				vertical_grow = true,
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = true,
							vertical_grow = true,
							race_list
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = true,
							vertical_grow = true,
							unit_list
						},
						T.column {
							horizontal_grow = true,
							vertical_grow = true,
							details_panel_pages
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = true,
							vertical_grow = true,
							chosen_unit_panel
						}
					}
				}
			}
		}
	}
}

return {
	normal = main_window;
}
-->>
