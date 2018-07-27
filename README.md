# Pathname

## Usage

```lua
path1 = Pathname:new("/usr/bin")
print(path1)        --> /usr/bin
print(path1:to_s()) --> /usr/bin
path2 = Pathname:new("luajit")
path3 = path1 + path2
print(path3)        --> /usr/bin/luajit
path4 = path1 / "lua"
print(path4)        --> /usr/bin/lua
path5 = path4:parent()
print(path5)        --> /usr/bin
```

## Methods

- Pathname:__add(other)
- Pathname:__div(other)
- Pathname:__tostring()
- Pathname:ascend(callback)
- Pathname:basename(extension)
- Pathname:cleanpath()
- Pathname:descend(callback)
- Pathname:dirname()
- Pathname:each_filename(callback)
- Pathname:extname()
- Pathname:gsub(pattern, replace, number)
- Pathname:is_absolute()
- Pathname:is_relative()
- Pathname:is_root()
- Pathname:new(pathname)
- Pathname:parent()
- Pathname:to_path()
- Pathname:to_s()
- Pathname:truncate(length)
