local CommonActorScreenMarkUI = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local util = require("client.slua_ui_framework.util")
function CommonActorScreenMarkUI:Initialize()
  print(bWriteLog and "CommonActorScreenMarkUI:Initialize")
end
function CommonActorScreenMarkUI:OnDestroy()
  print(bWriteLog and "CommonActorScreenMarkUI:OnDestroy")
  self:Dispose()
end
function CommonActorScreenMarkUI:OnActorBindUI(BindActor, ID, InInstanceID)
  print(bWriteLog and "CommonActorScreenMarkUI:OnActorBindUI", BindActor, ID, InInstanceID)
  if not slua.isValid(BindActor) or ID == nil then
    return
  end
  self:SetUpInfoInternal(ID)
end
function CommonActorScreenMarkUI:OnActorUnbindUI(BindActor)
  print(bWriteLog and "CommonActorScreenMarkUI:OnActorUnbindUI", BindActor)
end
function CommonActorScreenMarkUI:OnLocationBindUI(Loc, ID, InInstanceID)
  print(bWriteLog and "CommonActorScreenMarkUI:OnLocationBindUI", Loc, ID, InInstanceID)
  if not Loc or ID == nil then
    return
  end
  self:SetUpInfoInternal(ID)
end
function CommonActorScreenMarkUI:SetUpInfoInternal(ID)
  print(bWriteLog and "CommonActorScreenMarkUI:SetUpInfoInternal", ID)
  self.  self.bCountDownTime = false
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig and ScreenMarkConfig[ID] then
    self.SCMarkConfig = ScreenMarkConfig[ID]
    if self.SCMarkConfig.MaxShowDistance and self.SCMarkConfig.MaxShowDistance > 0 then
      self.bEnableMaxShowDistance = true
      self.MaxShowDistance = self.SCMarkConfig.MaxShowDistance
    end
  end
  if ScreenMarkConfig and ScreenMarkConfig[ID] and ScreenMarkConfig[ID].CommonMarkConfig then
    local CommonMarkConfig = ScreenMarkConfig[ID].CommonMarkConfig
    if CommonMarkConfig.Icon and self.Image_Icon then
      util.SetTexture(self.Image_Icon, CommonMarkConfig.Icon)
    end
    if CommonMarkConfig.IconBG and self.Image_BG then
      util.SetTexture(self.Image_BG, CommonMarkConfig.IconBG)
    end
    if CommonMarkConfig.bDistance then
      if self.ImageBG_Distance then
        self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.Text_Distance then
        self.Text_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.TextBlock_Distance = self.Text_Distance
      end
    else
      if self.ImageBG_Distance then
        self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if self.Text_Distance then
        self.Text_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
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
function CommonActorScreenMarkUI:OnUpdateState(CustomInt, CustomFloat, CustomString)
  print(bWriteLog and "CommonActorScreenMarkUI:OnUpdateState", CustomInt, CustomFloat, CustomString)
  self:UpdateCountDownTime(CustomInt)
end
function CommonActorScreenMarkUI:UpdateCountDownTime(EndTime)
  local CurTime = CGameState and CGameState:GetServerWorldTimeSeconds() or -1
  print(bWriteLog and "CommonActorScreenMarkUI:UpdateCountDownTime", EndTime, CurTime)
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
function CommonActorScreenMarkUI:OnCountDownOver()
  if self.ImageBG_Time then
    self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.TextBlock_Time then
    self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, CommonActorScreenMarkUI)