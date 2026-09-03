local CommonLocationScreenMarkUI = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local util = require("client.slua_ui_framework.util")
function CommonLocationScreenMarkUI:Initialize()
  print(bWriteLog and "CommonLocationScreenMarkUI:Initialize")
end
function CommonLocationScreenMarkUI:OnDestroy()
  print(bWriteLog and "CommonLocationScreenMarkUI:OnDestroy")
  self:Dispose()
end
function CommonLocationScreenMarkUI:OnLocationBindUI(Loc, ID)
  if Loc == nil or ID == nil then
    return
  end
  print(bWriteLog and "CommonLocationScreenMarkUI:OnLocationBindUI", Loc, ID)
  self.bCountDownTime = false
  self.  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig and ScreenMarkConfig[ID] and ScreenMarkConfig[ID].CommonMarkConfig then
    local CommonMarkConfig = ScreenMarkConfig[ID].CommonMarkConfig
    if CommonMarkConfig.Icon then
      util.SetTexture(self.Image_Icon, CommonMarkConfig.Icon)
    end
    if CommonMarkConfig.IconBG then
      util.SetTexture(self.Image_BG, CommonMarkConfig.IconBG)
    end
    if CommonMarkConfig.bDistance then
      self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.Text_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.TextBlock_Distance = self.Text_Distance
    else
      self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.Text_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if CommonMarkConfig.bCountDownTime then
      self.bCountDownTime = true
      local InstanceData = self:GetMarkInstanceData()
      local EndTime = InstanceData and InstanceData.CustomInt or nil
      self:UpdateCountDownTime(EndTime)
    else
      if self.ImageBG_Time then
        self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if self.TextBlock_Time then
        self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function CommonLocationScreenMarkUI:OnUpdateState(CustomInt, CustomFloat, CustomString)
  print(bWriteLog and "CommonLocationScreenMarkUI:OnUpdateState", CustomInt, CustomFloat, CustomString)
  self:UpdateCountDownTime(CustomInt)
end
function CommonLocationScreenMarkUI:UpdateCountDownTime(EndTime)
  local CurTime = CGameState and CGameState:GetServerWorldTimeSeconds() or -1
  print(bWriteLog and "CommonLocationScreenMarkUI:UpdateCountDownTime", EndTime, CurTime)
  if self.bCountDownTime and EndTime and 0 < CurTime and EndTime > CurTime then
    if self.ImageBG_Time then
      self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.TextBlock_Time then
      self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SetCountDownText(self.TextBlock_Time, EndTime - CurTime, true, "")
    end
  else
    if self.ImageBG_Time then
      self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.TextBlock_Time then
      self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function CommonLocationScreenMarkUI:OnCountDownOver()
  if self.ImageBG_Time then
    self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.TextBlock_Time then
    self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, CommonLocationScreenMarkUI)