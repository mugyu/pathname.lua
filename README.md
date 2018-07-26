# Pathname

## usage

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
