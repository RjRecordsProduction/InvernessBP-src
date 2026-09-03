local table_pool = {}
local table_remove = table.remove
local local local local local local local local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local SuperList = require("common.super_list")
function table_pool.__index(_, k)
  if IsDevelopment then
    assert(k ~= "Create", "table_pool.__index k should not Create ")
  end
  if table_pool[k] then
    return table_pool[k]
  end
end
function table_pool:Get()
  local key, element = next(self._tables)
  if element then
    self._tables[key] = nil
    return element
  end
  return {}
end
function table_pool:Recycle(element)
  if IsDevelopment then
    assert(type(element) == "table", "Recycle element should be table type")
  end
  for k, _ in pairs(element) do
    element[k] = nil
  end
  if IsDevelopment then
    for _, v in pairs(self._tables) do
      assert(v ~= element, "Recycle v should not be element")
    end
  end
  self._tables[#self._tables + 1] = element
end
function table_pool:RecycleRecursive(element)
  for _, v in pairs(element) do
    if type(v) == "table" then
      self:RecycleRecursive(v)
    end
  end
  self:Recycle(element)
end
function table_pool:RecycleAll(elements)
  if IsDevelopment then
    assert(type(elements) == "table", "RecycleAll elements should be table type")
  end
  if getmetatable(elements) == SuperList then
    for i = #elements, 1, -1 do
      self:Recycle(elements[i])
    end
    elements:ClearData()
  else
    for i = #elements, 1, -1 do
      self:Recycle(elements[i])
      table_remove(elements)
    end
    for k, v in pairs(elements) do
      self:Recycle(v)
      elements[k] = nil
    end
  end
end
function table_pool.Create()
  local pool = setmetatable({
    _tables = setmetatable({}, {__mode = "v"})
  }, table_pool)
  return pool
end
return table_pool