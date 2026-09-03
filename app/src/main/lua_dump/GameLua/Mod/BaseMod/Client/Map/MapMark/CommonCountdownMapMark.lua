local CommonCountdownMapMark = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function CommonCountdownMapMark:Initialize()
  print(bWriteLog and "CommonCountdownMapMark:Initialize")
end
function CommonCountdownMapMark:LuaOnUIBPCreate(CustomState, CustomString, CreateTime, InWhichMap, ParentState, TypeID)
  print(bWriteLog and "CommonCountdownMapMark:LuaOnUIBPCreate init PropertyArray CustomState:", CustomState)
  self.PropertyArray = self:ConvertConfig(TypeID)
  self:SetUpdatePropertyArray(self.PropertyArray, -1)
  self:UpdateMarkState(CustomState)
end
function CommonCountdownMapMark:ConvertConfig(TypeID)
  self.  local TableUtil = require("common.table_util")
  local Result = {}
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
  if NewMapMarkConfig and NewMapMarkConfig[TypeID] then
    self.MapMarkConfig = NewMapMarkConfig[TypeID]
  end
  if NewMapMarkConfig and NewMapMarkConfig[TypeID] and NewMapMarkConfig[TypeID].CommonMarkConfig then
    local CommonMarkConfig = NewMapMarkConfig[TypeID].CommonMarkConfig
    for index, value in pairs(CommonMarkConfig) do
      if value.UpdateWidget then
        local widget = self[value.UpdateWidget]
        if widget then
          local Res = TableUtil.FastCopyTable(value)
          Res.UpdateWidget = widget
          table.insert(Result, Res)
        else
          print(bWriteLog and "CommonCountdownMapMark:ConvertConfig widget not found:", value.UpdateWidget)
        end
      end
    end
  end
  return Result
end
function CommonCountdownMapMark:LuaUpdateUIBPState(CustomState, CustomString, CreateTime, InWhichMap)
  print(bWriteLog and "CommonCountdownMapMark:LuaUpdateUIBPState CustomState:", CustomState)
  self:UpdateMarkState(CustomState)
end
function CommonCountdownMapMark:UpdateMarkState(CustomState)
  print(bWriteLog and "CommonCountdownMapMark:UpdateMarkState CustomState:", CustomState)
  if 1 < CustomState then
    local uGameState = GameplayData.GetGameState()
    if not Game:IsValid(uGameState) then
      return
    end
    local InCountdown = CustomState
    local In    if 10000 < CustomState then
      InCountdown = CustomState // 10000
      InCustomState = CustomState % 10000
    end
    self.TotalCountTime = InCountdown - uGameState:GetServerWorldTimeSeconds()
    print(bWriteLog and "CommonCountdownMapMark:UpdateMarkState InCustomState:", InCustomState, "CountTime:", self.TotalCountTime, "InCountdown:", InCountdown)
    if self.TotalCountTime > 0 then
      self:SetCountDownText(self.TextBlock_Time, self.TotalCountTime, true, "")
      if CustomState <= 10000 then
        self:OnUpdateIconMap(0)
      else
        self:OnUpdateIconMap(InCustomState)
      end
    else
      self:OnUpdateIconMap(InCustomState)
    end
  else
    self:SetUpdatePropertyArray(self.PropertyArray, math.abs(CustomState))
  end
end
function CommonCountdownMapMark:OnDestroy()
  print(bWriteLog and "CommonCountdownMapMark:OnDestroy")
  self:Dispose()
end
function CommonCountdownMapMark:ReceivedInitWidget()
  print(bWriteLog and "CommonCountdownMapMark:ReceivedInitWidget")
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, CommonCountdownMapMark)