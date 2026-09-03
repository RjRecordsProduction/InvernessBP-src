local TableUtil = {}
local table_move = table.move
local table_remove = table.remove
local local local local local local local local local 
function TableUtil.slice(tbl, first, last, step)
  local sliced = {}
  _for_step_ = step or 1
  for i = first or 1, last or #tbl do
    sliced[#sliced + 1] = tbl[i]
  end
  return sliced
end
function TableUtil.TableSlice(values, i1, i2)
  local res = {}
  local n = #values
  i1 = i1 or 1
  i2 = i2 or n
  if i2 < 0 then
    i2 = n + i2 + 1
  elseif n < i2 then
    i2 = n
  end
  if i1 < 1 or n < i1 then
    return {}
  end
  local k = 1
  for i = i1, i2 do
    res[k] = values[i]
    k = k + 1
  end
  return res
end
function TableUtil.Intersection(t1, t2)
  local ret = {}
  local t1H = {}
  for i, v in pairs(t1) do
    t1H[v] = i
  end
  for _, v in pairs(t2) do
    if t1H[v] then
      ret[#ret + 1] = v
    end
  end
  return ret
end
function TableUtil.Diff(lhs, rhs)
  local diff = {}
  for i, v in pairs(lhs) do
    if rhs then
      if type(v) == "table" then
        local inner = TableUtil.Diff(v, rhs[i])
        if inner then
          diff[i] = inner
        end
      elseif v ~= rhs[i] then
        diff[i] = v
      end
    else
      diff[i] = v
    end
  end
  if next(diff) then
    return diff
  end
end
function TableUtil.CollectValues(tb, vs)
  vs = vs or {}
  for i, v in pairs(tb) do
    if type(v) == "table" then
      TableUtil.CollectValues(v, vs)
    else
      vs[#vs + 1] = v
    end
  end
  return vs
end
function TableUtil.ArrayUnique(arrayTable)
  local check = {}
  local n = {}
  for key, value in pairs(arrayTable) do
    if not check[value] then
      n[key] = value
      check[value] = value
    end
  end
  return n
end
function TableUtil.Merge(...)
  local arrays = {
    ...
  }
  local result = {}
  for _, array in ipairs(arrays) do
    for _, v in ipairs(array) do
      result[#result + 1] = v
    end
  end
  return result
end
function TableUtil.ReverseArray(t)
  if type(t) ~= "table" then
    return
  end
  local itemCount = #t
  for i = 1, math.floor(itemCount / 2) do
    t[i], t[itemCount - i + 1] = t[itemCount - i + 1], t[i]
  end
end
function TableUtil.ReverseMap(t)
  if type(t) ~= "table" then
    return
  end
  local Result = {}
  for key, value in pairs(t) do
    if type(value) == "table" then
      for k, v in pairs(value) do
        Result[v] = key
      end
    else
      Result[value] = key
    end
  end
  return Result
end
function TableUtil.ExpandMap(t)
  if type(t) ~= "table" then
    return
  end
  local Result = {}
  for key, value in pairs(t) do
    if type(value) == "table" then
      for k, v in pairs(value) do
        Result[k] = v
      end
    else
      Result[key] = value
    end
  end
  return Result
end
function TableUtil.CopyTable(st)
  local tab = {}
  for k, v in pairs(st or {}) do
    local typeVale = type(v)
    if typeVale ~= "table" and typeVale ~= "userdata" then
      tab[k] = v
    else
      tab[k] = TableUtil.CopyTable(v)
    end
  end
  return tab
end
function TableUtil.FastCopyTable(st)
  local tab = {}
  for k, v in pairs(st or {}) do
    local typeVale = type(v)
    if typeVale ~= "table" and typeVale ~= "userdata" then
      tab[k] = v
    else
      tab[k] = TableUtil.CopyTable(v)
    end
  end
  return tab
end
function TableUtil.LiteCopy(st, bIgnore)
  local tab = {}
  for k, v in pairs(st or {}) do
    local typeVale = type(v)
    if bIgnore or typeVale ~= "table" and typeVale ~= "userdata" and typeVale ~= "function" then
      tab[k] = v
    end
  end
  return tab
end
function TableUtil.DeepCloneTable(_object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for key, value in pairs(object) do
      new_table[_copy(key)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(_object)
end
function TableUtil.IsInTable(list, data)
  if list == nil or data == nil then
    return false
  end
  for _, v in pairs(list) do
    if v == data then
      return true
    end
  end
  return false
end
function TableUtil.IsInTable2(list, data)
  if list == nil or data == nil then
    return false
  end
  for _, v in pairs(list) do
    if TableUtil.IsSameTable(v, data) then
      return true
    end
  end
  return false
end
function TableUtil.CountTable(st)
  if type(st) ~= "table" then
    return 0
  else
    local count = 0
    for _, _ in pairs(st) do
      count = count + 1
    end
    return count
  end
end
function TableUtil.IsDataEqual(a, b)
  if a == b then
    return true
  end
  if a == nil or b == nil then
    return false
  end
  if type(a) ~= "table" or type(b) ~= "table" then
    return a == b
  end
  for k1, v1 in pairs(a) do
    local v2 = b[k1]
    if v2 == nil then
      return false
    end
    local bEqual = TableUtil.IsDataEqual(v1, v2)
    if not bEqual then
      return false
    end
  end
  for k1, v1 in pairs(b) do
    local v2 = a[k1]
    if v2 == nil then
      return false
    end
    local bEqual = TableUtil.IsDataEqual(v1, v2)
    if not bEqual then
      return false
    end
  end
  return true
end
function TableUtil.IsSameTable(tb1, tb2)
  if tb1 == tb2 then
    return true
  end
  local tb1TypeVale = type(tb1)
  local tb2TypeVale = type(tb2)
  if tb1TypeVale == "table" and tb2TypeVale == "table" or tb1TypeVale == "userdata" and tb2TypeVale == "userdata" then
    if TableUtil.CountTable(tb1) ~= TableUtil.CountTable(tb2) then
      return false
    end
    for key, v in pairs(tb1) do
      if not TableUtil.IsSameTable(v, tb2[key]) then
        return false
      end
    end
  else
    return tb1 == tb2
  end
  return true
end
function TableUtil.GetKeys(tb)
  local keys = {}
  for k, _ in pairs(tb) do
    keys[#keys + 1] = k
  end
  return keys
end
function TableUtil.UniqueInsert(tb, value)
  local index = TableUtil.Find(tb, value)
  if index == -1 then
    tb[#tb + 1] = value
  end
end
function TableUtil.Find(array, element)
  for i, v in pairs(array) do
    if v == element then
      return i
    end
  end
  return -1
end
function TableUtil.FindTable(tb, func)
  for i, v in pairs(tb) do
    if func(i, v) then
      return i, v
    end
  end
  return
end
function TableUtil.GetTableValue(tb, ...)
  for index = 1, select("#", ...) do
    local typeVale = type(tb)
    if typeVale ~= "table" and typeVale ~= "userdata" then
      return nil
    else
      tb = tb[select(index, ...)]
    end
  end
  return tb
end
function TableUtil.TableConcat(t1, t2)
  local len1 = #t1
  local len2 = #t2
  table_move(t2, 1, len2, len1 + 1, t1)
  return t1
end
function TableUtil.MergeTable(t1, t2)
  local visited = {}
  local function _merge(t1, t2)
    if visited[t2] then
      return
    end
    visited[t2] = true
    for k, v in pairs(t2) do
      if type(v) == "table" then
        if type(t1[k]) == "table" then
          _merge(t1[k], t2[k])
        else
          t1[k] = v
        end
      else
        t1[k] = v
      end
    end
  end
  _merge(t1, t2)
  return t1
end
function TableUtil.OverwriteTable(t1, t2)
  local visited = {}
  local function _merge(t1, t2)
    if visited[t2] then
      return
    end
    visited[t2] = true
    for k, v in pairs(t2) do
      if type(v) == "table" then
        if type(t1[k]) == "table" then
          _merge(t1[k], t2[k])
        elseif t1[k] == nil then
          t1[k] = v
        end
      elseif t1[k] == nil then
        t1[k] = v
      end
    end
  end
  _merge(t1, t2)
  return t1
end
function TableUtil.InsertTable(target, source)
  if not source or not target then
    return
  end
  for i, v in pairs(source) do
    if type(v) == "table" then
      if nil == target[i] then
        target[i] = {}
      end
      for _, vInMap in pairs(v) do
        table.insert(target[i], vInMap)
      end
    else
      table.insert(target, v)
    end
  end
end
function TableUtil.ModifyMap(target, source)
  if not source or not target then
    return
  end
  for i, v in pairs(source) do
    if type(v) == "table" then
      if nil == target[i] then
        target[i] = {}
      end
      for key, vInMap in pairs(v) do
        target[i][key] = target[i][key] and target[i][key] + vInMap or 1
      end
    else
      target[i] = target[i] and target[i] + v or 1
    end
  end
end
function TableUtil.OverrideTable(target, source)
  if not source then
    return
  end
  for i, v in pairs(source) do
    target[i] = v
  end
end
function TableUtil.Clear(tb)
  for k, _ in pairs(tb) do
    tb[k] = nil
  end
end
function TableUtil.ClearArray(Array)
  if Array then
    while 0 < #Array do
      table_remove(Array)
    end
  end
end
function TableUtil.Remove(tb, value)
  local index = TableUtil.Find(tb, value)
  if index ~= -1 then
    table_remove(tb, index)
  end
end
function TableUtil.RemoveTableCorret(tb, first, count)
  if not tb or #tb <= 0 then
    return tb
  end
  first = first or 1
  count = count or #tb - first + 1
  if first < 1 or first > #tb then
    return tb
  end
  count = math.min(count, #tb - first + 1)
  local curCount = 0
  while count > curCount do
    table_remove(tb, first)
    curCount = curCount + 1
  end
  return tb
end
function TableUtil.RemoveTable(tb, first, count)
  if not tb or #tb <= 0 then
    return tb
  end
  first = first or 1
  count = count or #tb
  if first > count then
    return tb
  end
  local curCount = 0
  while count > curCount do
    table_remove(tb, first)
    curCount = curCount + 1
  end
  return tb
end
function TableUtil.PopValue(tb)
  for key, value in pairs(tb) do
    table_remove(tb, key)
    return value
  end
end
function TableUtil.Map(tb, func)
  local result = {}
  for key, value in pairs(tb) do
    result[key] = func(value)
  end
  return result
end
function TableUtil.Filter(tb, predicate)
  local result = {}
  for key, value in pairs(tb) do
    if predicate(value) then
      result[key] = value
    end
  end
  return result
end
function TableUtil.SortedPairs(tb)
  local keys = TableUtil.GetKeys(tb)
  table.sort(keys)
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], tb[keys[i]]
    end
  end
end
function TableUtil.Sum(tb)
  local sum = 0
  for i, v in pairs(tb) do
    sum = sum + v
  end
  return sum
end
function TableUtil.RandomIndexWeight(weightTb, TotalWeightCache)
  local TotalWeight = TotalWeightCache or 0
  if TotalWeight == 0 then
    for index, weight in pairs(weightTb) do
      if type(weight) == "number" and 0 < weight then
        TotalWeight = TotalWeight + weight
      end
    end
  end
  if TotalWeight <= 0 then
    local Count = TableUtil.CountTable(weightTb)
    local Index = math.random(1, Count)
    return Index, TotalWeight
  end
  local RandomWeight = math.floor(math.random() * TotalWeight)
  local CurWeight = 0
  for index, WeightInfo in pairs(weightTb) do
    if (type(WeightInfo) == "userdata" or type(WeightInfo) == "table") and type(WeightInfo.Weight) == "number" and 0 < WeightInfo.Weight then
      CurWeight = CurWeight + WeightInfo.Weight
    elseif type(WeightInfo) == "number" and 0 < WeightInfo then
      CurWeight = CurWeight + WeightInfo
    end
    if RandomWeight <= CurWeight then
      return index, TotalWeight
    end
  end
  return -1, TotalWeight
end
function TableUtil.RandomValue(tb)
  local count = #tb
  if count == 0 then
    return nil
  end
  local index = math.random(1, count)
  return tb[index]
end
function TableUtil.Contains(tb, val, equal)
  if not tb then
    return false
  end
  if equal then
    for _, v in pairs(tb) do
      if equal(val, v) then
        return true
      end
    end
  else
    for _, v in pairs(tb) do
      if v == val then
        return true
      end
    end
  end
  return false
end
function TableUtil.EuqalValue(va, vb)
  return va == vb
end
function TableUtil.ArrayDifference(arrayA, arrayB)
  if not arrayB then
    return arrayA
  end
  local setB = {}
  for _, v in ipairs(arrayB) do
    setB[v] = true
  end
  local result = {}
  for _, value in ipairs(arrayA) do
    if not setB[value] then
      result[#result + 1] = value
    end
  end
  return result
end
function TableUtil.FillDefaults(tb, defaultsTb)
  for k, v in pairs(defaultsTb) do
    if type(v) == "table" then
      if not tb[k] then
        tb[k] = {}
      end
      TableUtil.FillDefaults(tb[k], v)
    elseif not tb[k] then
      tb[k] = v
    end
  end
end
function TableUtil.MapToTable(Map)
  if Map == nil then
    return {}
  end
  local Table = {}
  for k, v in pairs(Map) do
    Table[k] = v
  end
  return Table
end
function TableUtil.LuaMap2Table(container)
  if container.__name == "LuaMap" then
    local TableResult = {}
    for k, v in pairs(container) do
      TableResult[k] = v
    end
    return TableResult
  end
end
function TableUtil.LuaArray2Table(container)
  if container.__name == "LuaArray" then
    local TableResult = {}
    local Count = container:Num()
    for i = 1, Count do
      TableResult[i] = container:Get(i - 1)
    end
    return TableResult
  end
end
function TableUtil.Table2LuaMap(table, container)
  if container.__name == "LuaMap" then
    container:Clear()
    for k, v in pairs(table) do
      container:Add(k, v)
    end
  end
end
function TableUtil.Table2LuaMap(table, container)
  if container.__name == "LuaArray" then
    container:Clear()
    for _, v in ipairs(table) do
      container:Add(v)
    end
  end
end
function TableUtil.hash2List(t)
  local list = {}
  for k, v in pairs(t) do
    table.insert(list, v)
  end
  return list
end
function TableUtil.TableToString(tbl, indent)
  indent = indent or ""
  local result = {}
  local nextIndent = indent .. "  "
  local formatKey = function(key)
    if type(key) == "string" then
      return string.format("%q", key)
    else
      return tostring(key)
    end
  end
  local formatValue = function(value, indent)
    local typeVale = type(value)
    if typeVale == "table" then
      return TableUtil.TableToString(value, indent)
    elseif typeVale == "string" then
      return string.format("%q", value)
    else
      return tostring(value)
    end
  end
  table.insert(result, "{\n")
  for k, v in pairs(tbl) do
    table.insert(result, nextIndent .. "[" .. formatKey(k) .. "] = " .. formatValue(v, nextIndent) .. ",\n")
  end
  table.insert(result, indent .. "}")
  return table.concat(result)
end
if bInUGCLuaTool then
  print(bWriteLog and "  bInUGCLuaTool.  TableUtil can't replace function ")
  return TableUtil
end
local cpp_table_util
pcall(function()
  cpp_table_util = require("cpp_table_util")
end)
if not cpp_table_util then
  return TableUtil
end
local SafeCppFunctionNames = {
  "CountTable",
  "IsSameTable"
}
local loadSafeCppFunc = function()
  for _, name in ipairs(SafeCppFunctionNames) do
    local func = cpp_table_util[name]
    if func then
      TableUtil[name] = func
      print(bWriteLog and "  loadSafeCppFunc. replace for TableUtil  name: " .. tostring(name))
    end
  end
end
loadSafeCppFunc()
local cppFunctionNames = {
  GetTableValue = 1,
  IsInTable = 1,
  IsDataEqual = 1
}
local switches = {
  "CPP_TableUtil_Safe",
  "CPP_TableUtil_UnSafe"
}
for name, _ in pairs(cppFunctionNames) do
  local func = cpp_table_util[name]
  if func then
    TableUtil[name] = func
    print(bWriteLog and "  loadCppFunc client. replace for TableUtil  name: " .. tostring(name))
  end
end
local replaceNewFunctions = function()
  print(bWriteLog and "  loadCppFunc client. replace for TableUtil  name:DeepCopyTable ")
  TableUtil.FastCopyTable = cpp_table_util.CopyTable
  TableUtil.CopyTable1 = cpp_table_util.CopyTable1
end
if Client then
  if _G.IsEditor then
    print(bWriteLog and "  : LuaTableUtil is open on Editor.")
    replaceNewFunctions()
  elseif HDmpveRemote.HDmpveRemoteConfigGetBool("CPP_TableUtil_UnSafe", false) then
    replaceNewFunctions()
  end
end
return TableUtil