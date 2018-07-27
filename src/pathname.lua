-- Pathname
Pathname = {}
function Pathname:new(pathname)
	local self = {}
	self.pathname = pathname
	Pathname.__index = Pathname
	setmetatable(self, Pathname)
	return self;
end
function Pathname:__tostring()
	return self.pathname
end
function Pathname:to_s()
	return self:__tostring()
end
function Pathname:basename(extension)
	local base
	if self.pathname then
		base = self.pathname
	else
		base = self
	end
	if base ~= '' and base ~= '/' then
		base = base:match('([^/]+)/?$') or base
	end
	if extension then
		base = base:match('(.*)'..extension..'$')
	end
	return base
end
function Pathname:dirname()
	local dirname
	if self.pathname then
		dirname = self.pathname
	else
		dirname = self
	end
	if dirname == '' then
		return '.'
	end
	if dirname == '/' then
		return dirname
	end
	dirname, _ = Pathname.chop_basename(dirname)
	if dirname:match('/$') then
		dirname = dirname:sub(0, #dirname - 1)
	end
	return dirname
end
function Pathname.chop_basename(path)
	local base = Pathname.basename(path)
	if (base == '' or base == '/') then
		return nil
	end
	local index = path:find(base..'/?$')
	local prefix = ''
	if index > 1 then
		prefix = path:sub(1, index - 1)
	end
	return prefix, base
end
function Pathname.split_names(path)
	local names = {}
	local prefix
	local base
	prefix, base = Pathname.chop_basename(path)
	while prefix do
		table.insert(names, base)
		prefix, base = Pathname.chop_basename(prefix)
	end
	return names;
end
function Pathname.plus(path1, path2)
	local prefix2 = path2
	local last_prefix2
	local base2
	local index_list2 = {}
	local basename_list2 = {}
	prefix2, base2 = Pathname.chop_basename(prefix2)
	while prefix2 do
		last_prefix2 = prefix2
		table.insert(index_list2, 1, #prefix2)
		table.insert(basename_list2, 1, base2)
		prefix2, base2 = Pathname.chop_basename(prefix2)
	end
	if last_prefix2 ~= '' then
		return path2
	end

	local prefix1 = path1
	local last_prefix1
	local base1
	local result
	while true do
		last_prefix1 = prefix1
		while #basename_list2 ~= 0 and basename_list2[1] == '.' do
			table.remove(index_list2, 1)
			table.remove(basename_list2, 1)
		end
		prefix1, base1 = Pathname.chop_basename(prefix1)
		if not prefix1 then
			break
		end
		if base1 ~= '.' then
			if base1 == '..' or #basename_list2 == 0 or basename_list2[1] ~= '..' then
				prefix1 = prefix1 .. base1
				last_prefix1 = prefix1
				break
			end
			table.remove(index_list2, 1)
			table.remove(basename_list2, 1)
		end
	end
	result = prefix1
	if (not result) and Pathname.basename(last_prefix1):find('/') then
		while #basename_list2 > 0 and basename_list2[1] == '..' do
			table.remove(index_list2, 1)
			table.remove(basename_list2, 1)
		end
	end
	if #basename_list2 > 0 then
		local suffix2 = path2:sub(index_list2[1] + 1)
		if result then
			if last_prefix1:match('/$') then
				return last_prefix1 .. suffix2
			end
			return last_prefix1 .. '/' .. suffix2
		end
		return last_prefix1 .. suffix2
	else
		if result then
			return last_prefix1
		end
		return Pathname.dirname(last_prefix1)
	end
end
function Pathname:__add(other)
	if other.pathname then
		other = other.pathname
	end
	local new_path = Pathname.plus(self.pathname, other)
	return Pathname:new(new_path)
end
function Pathname:__div(other)
	return self:__add(other)
end
function Pathname:parent()
	return self:__add('..')
end
