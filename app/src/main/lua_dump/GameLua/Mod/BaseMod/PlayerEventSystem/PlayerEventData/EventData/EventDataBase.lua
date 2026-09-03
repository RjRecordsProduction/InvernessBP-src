local EventDataBase = {
  EModDataType = {ETplan = 1, EBountyHunter = 2}
}
function EventDataBase:Init(bClient)
  self.IsClient = bClient
  self.ModData = {}
end
function EventDataBase:Clear()
  self.ModData = nil
end
function EventDataBase:GetTableData(tableName, id)
  return CDataTable.GetTableData(tableName, id)
end
function EventDataBase:GetTable(tableName)
  return CDataTable.GetTable(tableName)
end
function EventDataBase:GetParameterStrArray(ParameterStr)
  local ParaArray = {}
  local startIndex = 1
  if ParameterStr == nil or ParameterStr == "" then
    return ParaArray
  end
  local dotIndex = string.find(ParameterStr, ",", startIndex, true)
  local strLen = string.len(ParameterStr)
  while dotIndex ~= nil do
    local param = string.sub(ParameterStr, startIndex, dotIndex - 1)
    ParaArray[#ParaArray + 1] = param
    startIndex = dotIndex + 1
    dotIndex = string.find(ParameterStr, ",", startIndex, true)
  end
  if strLen >= startIndex then
    local param = string.sub(ParameterStr, startIndex, strLen)
    ParaArray[#ParaArray + 1] = param
  end
  return ParaArray
end
function EventDataBase:GetValueFromFunction(paramStr, FuncStr)
  local funcIndex = string.find(FuncStr, "f=", 1, true)
  local res = 0
  if funcIndex then
    local formatStr = string.sub(FuncStr, funcIndex + 2, string.len(FuncStr))
    local FuncArray = SplitStr(formatStr, "-")
    if 1 < #FuncArray then
      local FirstNum = tonumber(FuncArray[1])
      local XIndex = string.find(FuncArray[2], "x", 1, true)
      if XIndex and 1 <= XIndex then
        local SecondNum = tonumber(string.sub(FuncArray[2], 1, XIndex - 1))
        res = FirstNum - tonumber(paramStr) * SecondNum
        return res
      end
    end
  else
    res = tonumber(paramStr) * tonumber(FuncStr)
    return res
  end
  return res
end
local class = require("class")
local object = require("object")
local CEventDataBase = class(object, nil, EventDataBase)
return CEventDataBase