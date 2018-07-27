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
function Pathname:to_path()
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
function Pathname:is_relative()
	local path = self.pathname
	local _
	local result
	path, _ = self.chop_basename(path)
	while path do
		result = path
		path, _ = self.chop_basename(path)
	end
	return result == ''
end
function Pathname:is_absolute()
	return not self:is_relative()
end
function Pathname:each_filename(callback)
	local path = self.pathname
	local factory = function()
		local base
		path, base = Pathname.chop_basename(path)
		if not path then
			return nil
		end
		return base
	end
	if not callback then
		return factory
	end
	for name in factory do
		callback(name)
	end
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
function Pathname:ascend(callback)
	local path = self.pathname
	local _
	local result = {}
	local factory = function()
		if not path or path == '' then
			return nil
		end
		local new_path = self:new(self.del_trailing_separator(path))
		path, _ = self.chop_basename(path)
		return new_path
	end
	if not callback then
		return factory
	end
	for path in factory do
		callback(path)
	end
end
function Pathname:descend(callback)
	local tbl = {}
	self:ascend(function(path)
		table.insert(tbl, 1, path)
	end)
	local i = 0
	local factory = function()
		i = i + 1
		if i > #tbl then
			return nil
		end
		return tbl[i]
	end
	if not callback then
		return factory;
	end
	for path in factory do
		callback(path)
	end
end
function Pathname.del_trailing_separator(path)
	local prefix
	local base
	prefix, base = Pathname.chop_basename(path)
	if prefix then
		return prefix .. base
	end
	if path:match('/$') then
		return Pathname.dirname(path)
	end
	return path
end
function Pathname:is_root()
	if not Pathname.chop_basename(self.pathname) and self.pathname == '/' then
		return true
	end
	return false
end
function Pathname:gsub(pattern, replace, number)
	return Pathname:new(self.pathname:gsub(pattern, replace, number))
end
function Pathname:truncate(length)
	return Pathname:new(self.pathname:sub(1, length))
end
function Pathname:extname()
	local extname = self.pathname:match('(%.[^%.]+)%.*$')
	return extname or ''
end
function Pathname:cleanpath()
	return Pathname:new(Pathname.cleanpath_aggressive(self.pathname))
end
function Pathname.cleanpath_aggressive(path)
	local names = {}
	local prefix
	local base
	local pre = path
	prefix, base = Pathname.chop_basename(pre)
	while prefix do
		pre = prefix
		if base == '.' or base == '..' then
			table.insert(names, 1, base)
		else
			if names[1] == '..' then
				table.remove(names, 1)
			else
				table.insert(names, 1, base)
			end
		end
		prefix, base = Pathname.chop_basename(prefix)
	end
	if Pathname.basename(pre) == '/' then
		while names[1] == '..' do
			table.remove(names, 1)
		end
	end
	-- join
	local cleanpath = pre
	if #names > 0 then
		cleanpath = cleanpath .. names[1]
	end
	for i = 2, #names do
		cleanpath = cleanpath .. '/' .. names[i]
	end
	return cleanpath
end
