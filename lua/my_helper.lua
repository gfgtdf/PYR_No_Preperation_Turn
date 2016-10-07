--<<
local _ = _textdomain_pyr_npt
local myhelper = {}
function myhelper.tablegroupby(t, selector)
    local r1 = {}
	for key,value in pairs(t) do
		if(r1[selector(key, value)] == nil) then
			r1[selector(key, value)] = {}
		end
		table.insert(r1[selector(key, value)], {key = key, value = value})
	end
	return r1
end

function myhelper.tablemax(t, fn)
    local maxkey, maxvalue = nil, nil
	for key, value in pairs(t) do
		if(maxkey == nil or fn(maxvalue, value)) then
            maxkey, maxvalue = key, value
		end
	end
    return maxkey, maxvalue
end

function myhelper.arraytablefilter(t, fn)
    local r = {}
	for key, value in ipairs(t) do
		if fn(value) then
			table.insert(t, value)
		end
	end
	return r
end

function myhelper.tablecontains(t, elem)
	for key, value in pairs(t) do
		if(value == elem) then
            return true
		end
	end
	return false
end

function myhelper.tablemap(t, fm)
	local r = {}
	for key, value in pairs(t) do
		r[key] = fm(value)
	end
	return r
end

function myhelper.tableremovevalue(t, val)
	for index, value in ipairs(t) do
		if value == val then
			table.remove(t, index)
			return
		end
	end
end

function myhelper.tablereduce (list, fn, start) 
	local acc = start
	for k, v in pairs(list) do
		acc = fn(acc, v)
	end 
	return acc 
end
--I'd be happy to be able to always call this function without the helper. prefix.
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end
myhelper.Set = Set

myhelper.max = function(a,b ) return a > b and a or b end
myhelper.min = function(a,b ) return a < b and a or b end


-- TODO add support for userdata
-- for real serialasition i always use serialize. This is only used by cwo
myhelper.serialize_pretty = function(o, accept_nil, indention)
	-- getting nil here nomrlnomaly mens something got wrong so default = no
	accept_nil = accept_nil or false
	indention = indention or 0
	local r = ""
	if type(o) == "nil" and accept_nil then
		return "nil"
	elseif type(o) == "number" or type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "string" then
		return string.format("%q", o)
	elseif type(o) == "table" then
		r = "{\n" .. string.rep('\t',indention)
		for k,v in pairs(o) do
			r = r .. "\t[" .. myhelper.serialize_pretty(k,false) .. "] = " .. myhelper.serialize_pretty(v,false,indention + 1 ) .. ",\n" .. string.rep('\t',indention)
		end
		return r .. "}"
	elseif type(o) == "userdata" and getmetatable(o) == "translatable string" then
		-- maybe there is a better way?
		return myhelper.serialize_pretty(tostring(o))
	elseif type(o) == "function" then 
		return "loadstring(" .. string.format("%q", string.dump(o)) .. ")"
	else
		error("cannot serialize a " .. type(o))
	end
end

-- a function for debugging. cwo = Console Write Object
function myhelper.cwo(obj)
	local m = myhelper.serialize_pretty(obj, true)
	wesnoth.fire("message",{ speaker = "narrator", message = m })
	wesnoth.fire("wml_message", { logger = "err", message =  m })
end
-- to save keystrokes when using this  in the :lua commandline .
cwo = myhelper.cwo
-- a function for debugging. cwo = Console Write Object
function myhelper.log_object(obj, logger)
	logger = logger or "err"
	wesnoth.fire("wml_message",{ logger = logger, message =  myhelper.serialize_pretty(obj, true) .. "\n\n\n"})
end

-- this method searializes data to a string that can be pared with deseralize.
-- right now i dont use it for too big data but i want this method to be as fast as possible.
-- in my tests this was slightly faster than the previous version (i suppose that was just because f the localy stored functions)
-- 1.5 vs 1.4 sceonds to serialitze 1000 units.
-- the first verion took more than 1000 seconds for 1000 units.
-- note that these results are meaningless if we dont know the complexity of the test units
function myhelper.serialize(oo, accept_nil)
	accept_nil = accept_nil or false
	-- storing important functions as upvalues to to access it faster
	local tostring = tostring
	local type = type
	local pairs = pairs
	local insert = table.insert
	local format = string.format
	-- i need this, oterwise s_o_2 isnt saved as upvalue in itself
	local s_o_2 = nil
	s_o_2 = function(o, builder)
		local o_t = type(o)
		if o_t == "number" or o_t == "boolean" then
			insert(builder, tostring(o))
			return
		elseif o_t == "userdata" and getmetatable(o) == "translatable string" then
			s_o_2(tostring(o), builder)
			return
		elseif o_t == "string" then
			insert(builder, format("%q", o))
			return
		elseif o_t == "table" then
			insert(builder, "{ ")
			for k,v in pairs(o) do
				insert(builder, "[")
				s_o_2(k, builder)
				insert(builder, "] = ")
				s_o_2(v, builder)
				insert(builder, ", ")
			end
			insert(builder, "}")
			return 
		elseif o_t == "function" then
			-- i should remove this because the attpempt to store a function means normaly an error occured 
			-- and also because functions with upvalues arent serialized right anyway, but i dont want to.
			insert(builder, "loadstring(" .. format("%q", string.dump(o)) .. ")" )
			return
		elseif o_t == "nil" and accept_nil then
			insert(builder, "nil")
			return
		else
			error("cannot serialize a " .. o_t)
		end
	end
	-- finaly we call it.
	local build = {}
	s_o_2(oo, build)
	return table.concat(build)
end

-- obvious
function myhelper.deseralize(str)
	return loadstring("return " .. str)()
end

-- list globals, another debuggging function (to detect spamming in the gobal namespace).
function l_g(print_common)
	-- ignore some keys that are always present
	local known_engine_values = Set {"table", "next", "string", "xpcall", "tostring", "print", "os", 
		"unpack", "wesnoth", "pairs", "next", "assert", "rawlen", "ipairs", "rawequal", "collectgarbage", 
		"load", "tonumber", "getmetatable", "rawset", "_VERSION", "_G", "math", "pcall", "type", "debug", 
		"select", "rawget", "loadstring", "table", "setmetatable", "error", "", "", "", "", ""}
	local known_common_values = Set {
		"helper", --helper
		"H", --helper alias
		"T", --set_wml_tag_metatable 
		"V", --set_wml_var_metatable
		"W", --set_wml_action_metatable 
	}
	for k,v in pairs(_G) do
		if (print_common or ((not known_engine_values[k]) and (not known_common_values[k]))) then
			myhelper.cwo(k)
		end
	end
end

--not much to say
myhelper.deepcopy = function (orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[myhelper.deepcopy(orig_key)] = myhelper.deepcopy(orig_value)
		end
		setmetatable(copy, myhelper.deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--unlike get_child this creates a child if it cannot find it.
myhelper.get_or_create_child = function(cfg, name)
	local r = helper.get_child(cfg, name)
	if r ~= nil then
		return r
	else
		r = {}
		table.insert(cfg,{name,r})
		return r
	end
end
--unlike child_range this give also the index of the tag
myhelper.child_range_ex = function (cfg, tag)
	local function f(d, i)
		local c
		repeat
			i = i + 1
			c = cfg[i]
			if not c then return end
		until c[1] == tag
		return i, c[2]
	end
	return f, 0
end

function myhelper.child_range_multiple_tags(cfg, tag_set)
	local function f(s)
		local c
		repeat
			local i = s.i
			c = cfg[i]
			if not c then return end
			s.i = i + 1
		until tag_set[c[1]] ~= nil
		return c[2]
	end
	return f, { i = 1 }
end

myhelper.trim = function(s)
  return s:match'^%s*(.*%S)' or ''
end
-- this method is for iterating over 2 enumerations syncroinous, 
-- use it like "for k,v in  merge_iterators({pairs(..)},{pairs(..)}) do" then k,v are arrays of len 2 containing the original k v
myhelper.merge_iterators = function(it1, it2)
	local function f(d, i)
		i1 ,v1 = it1[1](d[1], i[1])
		i2 ,v2 = it2[1](d[2], i[2])
		if(i1 ~= nil or i2 ~= nil) then
			return {i1 ,i2}, {v1 ,v2}
		end
	end
	return f, {it1[2], it2[2]}, {it1[3], it2[3]}
end

--
myhelper.remove_from_array = function(arr, f_filter)
	local index = 1
	while index <= #arr do
		if(f_filter(arr[index])) then
			table.remove(arr, index)
		else
			index = index + 1
		end
	end
end
-- removes ONE subtag with the given tagname of the wml object returns weather somthing was removed,
myhelper.remove_subtag = function(cfg, name)
	for k,v in pairs(cfg) do
		if(type(k) == "number") and (v[1] == name) then
			table.remove(cfg, k)
			return true
		end
	end
	return false
end


myhelper.random_number = function(mi, ma)
	-- min, max are keyword according to notepad++s syntax highlighting
	if not ma then mi, ma = 1, mi end
	wesnoth.fire("set_variable", { name = "LUA_random", rand = string.format("%d..%d", mi, ma) })
	local res = wesnoth.get_variable "LUA_random"
	wesnoth.set_variable "LUA_random"
	return res
end

myhelper.string_starts = function(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

if wesnoth.have_file( "~add-ons/PYR_No_Preperation_Turn/images/tpixel.png") then
	myhelper.tpixel_png = "tpixel.png"
	myhelper.thex_png = "misc/blank-hex.png"
else
	myhelper.tpixel_png = "misc/blank-hex.png~SCALE(1,1)"
	myhelper.thex_png = "misc/blank-hex.png"
end
return myhelper




-->>




























