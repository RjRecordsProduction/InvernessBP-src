function _ENV:NEW()
  if self then
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
  end
  print(bWriteLog and "self is null!!!")
  return nil
end
function StringToTable(tableString)
  if not tableString then
    return nil
  end
  local stringToFunction = load("return " .. tableString)
  if stringToFunction == nil then
    print(bWriteLog and "Can not find this table:" .. tableString)
    return nil
  end
  local toTabel = stringToFunction()
  return toTabel
end
function TableLightCopy(targetTab)
  if type(targetTab) ~= "table" then
    return nil
  end
  local new_tab = {}
  for i, v in pairs(targetTab) do
    new_tab[i] = v
  end
  return new_tab
end
function ToInt(x)
  if x <= 0 then
    return math.ceil(x)
  end
  if math.ceil(x) == x then
    x = math.ceil(x)
  else
    x = math.ceil(x) - 1
  end
  return x
end
function SplitStr(str, sep, converter)
  local result = {}
  if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
    return result
  end
  if #sep == 0 then
    return result
  end
  local pattern = string.format("([^%s]*)", sep)
  string.gsub(str, pattern, function(element)
    if element ~= nil and element ~= "" then
      if converter ~= nil and type(converter) == "function" then
        result[#result + 1] = converter(element)
      else
        result[#result + 1] = element
      end
    end
  end)
  return result
end
function GlobalShowMsgBox(Style, Title, Msg)
  if Client then
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(Style, Title, Msg)
  else
    print(bWriteLog and "FuncUtil.ShowMsgBox", Title, Msg)
  end
end
function LuaTableToTArray(LuaTable, TArrayType)
  local TArrayRet = slua.Array(TArrayType)
  if next(LuaTable) then
    for Key, Value in pairs(LuaTable) do
      TArrayRet:Add(Value)
    end
  end
  return TArrayRet
end
function AddTableToTArray(LuaTable, TArray)
  if LuaTable and TArray then
    for Key, Value in pairs(LuaTable) do
      TArray:Add(Value)
    end
  end
  return TArray
end
function ReadTreeFromFile(FilePath)
  local AIMback = {}
  file = io.open(FilePath, "r")
  local UIUtil = require("client.common.ui_util")
  local bExist = UIUtil.IsFileExistsWithOutPakCheck(FilePath)
  print(bWriteLog and "ReadTreeFromFile bExist", FilePath, bExist)
  if file == nil then
    file = io.open("G:\\table.txt", "r")
    print(bWriteLog and "ReadTreeFromFile11", "G:\\table.txt", file)
  end
  io.input(file)
  local info = io.read()
  local tableLevel = {AIMback}
  local tableIndex = 1
  while info do
    local startIndex = string.find(info, "\226\148\156")
    startIndex = startIndex or string.find(info, "\226\148\148")
    local level = string.find(info, "\226\148\130")
    if startIndex then
      local belongtoLevel = 1
      local levelNum = 0
      local diffNum = 0
      if level then
        diffNum = startIndex - level
      end
      while level do
        levelNum = levelNum + 1
        level = string.find(info, "\226\148\130", level + 1)
      end
      if 0 < diffNum then
        belongtoLevel = (diffNum - levelNum * 2) / 3 + 1
      end
      tableIndex = belongtoLevel
      local aimstr = string.sub(info, startIndex + 3, string.len(info))
      aimstr = string.gsub(aimstr, "\226\148\128", "")
      aimstr = string.gsub(aimstr, " ", "")
      aimstr = string.gsub(aimstr, "\r\n", "")
      local equalindex = string.find(aimstr, ":")
      if aimstr == "weapons_exp" then
        print(bWriteLog and "find")
      end
      if equalindex then
        local key = string.sub(aimstr, 0, equalindex - 1)
        local numberKey = tonumber(key)
        local valueStr = string.sub(aimstr, equalindex + 1, string.len(aimstr))
        local value
        if string.sub(valueStr, 0, 1) == "\"" then
          value = string.sub(valueStr, 2, string.len(valueStr) - 1)
        elseif valueStr == "{}" then
          value = {}
        elseif valueStr == "true" then
          value = true
        elseif valueStr == "false" then
          value = false
        else
          value = tonumber(valueStr)
          value = value or valueStr
        end
        local aimTable = tableLevel[tableIndex]
        if numberKey then
          aimTable[numberKey] = value
        else
          aimTable[key] = value
        end
      else
        local aimTable = tableLevel[tableIndex]
        tableIndex = tableIndex + 1
        local numberKey = tonumber(aimstr)
        if numberKey then
          aimTable[numberKey] = {}
          tableLevel[tableIndex] = aimTable[numberKey]
        else
          aimTable[aimstr] = {}
          tableLevel[tableIndex] = aimTable[aimstr]
        end
      end
    end
    info = io.read()
  end
  io.close(file)
  return AIMback
end