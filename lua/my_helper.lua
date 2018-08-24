--<<

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

function myhelper.tablecontains(t, elem)
	for key, value in pairs(t) do
		if(value == elem) then
            return true
		end
	end
	return false
end

function myhelper.tablecontainsp(t, p)
	for key, value in pairs(t) do
		if p(value) then
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

function myhelper.arrayfilter(t, f)
	local r = {}
	for key, value in ipairs(t) do
		if f(value) then
			r[#r + 1] = value
		end
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

function myhelper.max(a, b)
	return a > b and a or b
end

function myhelper.min(a, b)
	return a < b and a or b
end

function myhelper.deepcopy(orig)
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

function myhelper.trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function myhelper.split(s)
	return tostring(s or ""):gmatch("[^%s,][^,]*")
end

function myhelper.comma_to_list(str)
	local res = {}
	for elem in myhelper.split(str) do
		table.insert(res, myhelper.trim(elem))
	end
	return res
end

myhelper.thex_png = "misc/blank-hex.png"

return myhelper
-->>
