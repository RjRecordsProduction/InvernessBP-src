local local local local EnableLuaClassIndexCache = not Client or Client.CanEnableLuaClassIndexCache()
local Class = function(base, static, classImplement)
  if type(base) ~= "table" then
    error(string.format("class: base parameter must be a table, got %s", type(base)))
  end
  classImplement = classImplement or {}
  classImplement.__super_impl = base.__inner_impl
  classImplement.__super = base
  local base_mt = getmetatable(base)
  local class = static or {}
  class.__inner_impl = classImplement
  local class_index = function(t, k, cache)
    local impl = classImplement
    local ret
    while impl do
      ret = impl[k]
      if ret ~= nil then
        if EnableLuaClassIndexCache and rawset and cache ~= false then
          rawset(t, k, ret)
        end
        return ret
      end
      impl = impl.__super_impl
    end
    return nil
  end
  local instance_metatable = {__index = class_index}
  setmetatable(class, {
    __index = class_index,
    __newindex = function()
      error("Prevent __newindex with class!")
    end,
    __call = function(...)
      local r = base_mt.__call(...)
      setmetatable(r, instance_metatable)
      if classImplement.ctor then
        classImplement.ctor(r, ...)
      end
      r.__      return r
    end
  })
  return class
end
return Class