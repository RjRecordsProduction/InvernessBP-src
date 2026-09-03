local FramePlatformMapMark = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UIUtil = require("client.common.ui_util")
function FramePlatformMapMark:Initialize()
  print(bWriteLog and "FramePlatformMapMark:Initialize")
  self.AnimState = 0
end
function FramePlatformMapMark:LuaOnUIBPCreate(CustomState, CustomString, CreateTime, InWhichMap, ParentState, TypeID)
  print(bWriteLog and "FramePlatformMapMark:LuaOnUIBPCreate init PropertyArray CustomState:", CustomState)
  self.PropertyArray = self:ConvertConfig(TypeID)
  self:SetUpdatePropertyArray(self.PropertyArray, -1)
  self:UpdateMarkState(CustomState)
end
function FramePlatformMapMark:ConvertConfig(TypeID)
  self.  local TableUtil = require("common.table_util")
  local Result = {}
  local NewMapMarkConfig = GamePlayTools.GetCurrentConfig("NewMapMarkConfig")
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
          print(bWriteLog and "FramePlatformMapMark:ConvertConfig widget not found:", value.UpdateWidget)
        end
      end
    end
  end
  return Result
end
function FramePlatformMapMark:LuaUpdateUIBPState(CustomState, CustomString, CreateTime, InWhichMap)
  self:UpdateMarkState(CustomState)
end
function FramePlatformMapMark:UpdateMarkState(CustomState)
  if 1 < CustomState then
    local uGameState = GameplayData.GetGameState()
    if not Game:IsValid(uGameState) then
      return
    end
    local InCountdown = 0
    local In    if 10000 <= CustomState then
      InCountdown = CustomState // 10000
      InCustomState = CustomState % 10000
    end
    local TotalCountTime = InCountdown
    if 0 < TotalCountTime and InCustomState ~= 1 then
      self.CanvasPanel_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local TimeString = string.format("%02d:%02d", math.floor(TotalCountTime / 60), TotalCountTime % 60)
      self.TextBlock_Time:SetText(TimeString)
    else
      self.CanvasPanel_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if 0 < TotalCountTime then
      if CustomState <= 10000 then
        self:OnUpdateIconMap(0)
      else
        self:OnUpdateIconMap(InCustomState)
      end
    else
      self:OnUpdateIconMap(InCustomState)
    end
    if InCustomState == 0 then
      self.TextBlock_Time:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
      self:CheckUpdateAnim(3)
    elseif InCustomState == 1 then
      self.CanvasPanel_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:CheckUpdateAnim(3)
    elseif InCustomState == 2 then
      self.TextBlock_Time:SetColorAndOpacity(FSlateColor(FLinearColor(0.09, 0.65, 0.93, 1.0)))
      self:CheckUpdateAnim(1)
    elseif InCustomState == 3 then
      self.TextBlock_Time:SetColorAndOpacity(FSlateColor(FLinearColor(0.83, 0.03, 0.09, 1.0)))
      self:CheckUpdateAnim(2)
    elseif InCustomState == 4 or InCustomState == 5 then
      self.TextBlock_Finished:SetText(LocUtil.LocalizeResFormat(4404016))
      self:CheckUpdateAnim(3)
    end
  else
    self:SetUpdatePropertyArray(self.PropertyArray, math.abs(CustomState))
    if CustomState == 0 or CustomState == 1 then
      self.CanvasPanel_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.CanvasPanel_Finished:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:CheckUpdateAnim(3)
    end
  end
end
function FramePlatformMapMark:CheckUpdateAnim(AnimState)
  if self.AnimState == AnimState then
    return
  end
  self.  if self.AnimState == 1 then
    self.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIUtil.PlayWidgetAnimation(self.Object, "Anim_Glow_1", 0, 0, 0, 1)
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_2")
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_3")
  elseif self.AnimState == 2 then
    self.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_1")
    UIUtil.PlayWidgetAnimation(self.Object, "Anim_Glow_2", 0, 0, 0, 1)
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_3")
  else
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_1")
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_2")
    UIUtil.StopWidgetAnimation(self.Object, "Anim_Glow_3")
    self.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function FramePlatformMapMark:OnDestroy()
  print(bWriteLog and "FramePlatformMapMark:OnDestroy")
  self:Dispose()
end
function FramePlatformMapMark:ReceivedInitWidget()
  print(bWriteLog and "FramePlatformMapMark:ReceivedInitWidget")
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, FramePlatformMapMark)