local HitMarkUINew = {}
local ESightTypeDef = import("ESightType")
function HitMarkUINew:ctor()
  print(bWriteLog and "HitMarkUI:ctor", self)
  self.MaxCenterScale = 1.0
  self.MinCenterScale = 0.7
  self.ChangeScaleSpeed = 2
  self.HideDistanceRatio = 0.95
  self.FireSmall = false
  self.OldImageStylePath = {
    InScreenBG = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_dibiao_chengse_png.DJ_Icon_dibiao_chengse_png",
    OutScreenBG = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_kongdi_png.DJ_Icon_kongdi_png",
    ArrowIcon = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_duiyou_jiantou_png.ZD_icon_duiyou_jiantou_png"
  }
  self.NewImageStylePath = {
    InScreenBG = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_dibiao_new_Big_hongse_png.DJ_Icon_dibiao_new_Big_hongse_png",
    OutScreenBG = "/Game/Arts/UI/Atlas/BattleUI/Ingame_QuickSign/Frames/DJ_Icon_dibiao_new_Big_hongse_png.DJ_Icon_dibiao_new_Big_hongse_png",
    ArrowIcon = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/DJ_Icon_dibiao_new_jiantouhong_png.DJ_Icon_dibiao_new_jiantouhong_png"
  }
end
function HitMarkUINew:Initialize()
  print(bWriteLog and "HitMarkUINew:Initialize", self)
end
function HitMarkUINew:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SCOPECHANGE, self.OnScopeChange, self)
end
function HitMarkUINew:SwitchIfOutOfScreen(bIsCurrentOutOfScreen)
  print(bWriteLog and "HitMarkUINew:SwitchIfOutOfScreen", bIsCurrentOutOfScreen)
  if bIsCurrentOutOfScreen then
    self.CanvasPanel_Pointer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Effect:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.DotImg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.LineImg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self:OnSmallIconChange(false)
  else
    self.CanvasPanel_Pointer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Effect:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if not self.OldMarkStyle then
      self.LineImg:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
      self:OnSmallIconChange(self.IsCurSmall)
    end
  end
end
function HitMarkUINew:OnUpdateDistance(distance)
  local IsInSmallDistance = distance < self.SmallIconDistance and not self.bIsCurrentOutOfScreen
  if self.IsCurSmall == nil or self.IsCurSmall ~= IsInSmallDistance then
    self:OnSmallIconChange(IsInSmallDistance)
    self.IsCurSmall = IsInSmallDistance
  end
  local TimeUtil = require("client.common.time_util")
  local CurTime = TimeUtil.GetServerTimeInSec()
  if not self.BindTime then
    self.BindTime = CurTime
  end
  if CurTime - self.BindTime >= 6 then
    self.bShowWidget = false
  end
end
function HitMarkUINew:OnDistanceLineHeightChange(DistanceLineHeight)
  self:SetScopeCoefficient()
  local FinalHeight = DistanceLineHeight / self.ScopeCoefficient
  if FinalHeight < self.DistanceLineLimit.Z then
    FinalHeight = self.DistanceLineLimit.Z
  end
  self:ChangeDistanceLineHeight(FinalHeight)
end
function HitMarkUINew:OnScopeChange()
  self:SetScopeCoefficient()
  local FinalHeight = self.LastDistanceLineHeight / self.ScopeCoefficient
  if FinalHeight < self.DistanceLineLimit.Z then
    FinalHeight = self.DistanceLineLimit.Z
  end
  self:ChangeDistanceLineHeight(FinalHeight)
end
function HitMarkUINew:SetScopeCoefficient()
  self.ScopeCoefficient = 1
  if not slua.isValid(self.STExtraPlayerController) then
    self.STExtraPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(self.STExtraPlayerController) then
      return
    end
  end
  local uPlayerCharcter = self.STExtraPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerCharcter) then
    return
  end
  self.bIsGunADS = uPlayerCharcter.bIsGunADS
  if not self.bIsGunADS then
    self.IsInFire = false
    self:OnSmallIconChange(self.IsCurSmall)
    if not self.LastAlpha then
      self.LastAlpha = 1
    end
    self:SetSelfOpacity(self.LastAlpha)
    if self.DelayShowTimer then
      self:RemoveGameTimer(self.DelayShowTimer)
      self.DelayShowTimer = nil
    end
    return
  end
  local uCurWeapon = uPlayerCharcter:GetCurrentWeapon()
  if not slua.isValid(uCurWeapon) then
    return
  end
  local CurSightType = uCurWeapon:GetCurSightType()
  if CurSightType == ESightTypeDef.SightX2 then
    self.ScopeCoefficient = 2
  elseif CurSightType == ESightTypeDef.SightX3 then
    self.ScopeCoefficient = 3
  elseif CurSightType == ESightTypeDef.SightX4 then
    self.ScopeCoefficient = 4
  elseif CurSightType == ESightTypeDef.SightX6 then
    self.ScopeCoefficient = 6
  elseif CurSightType == ESightTypeDef.SightX8 then
    self.ScopeCoefficient = 8
  end
end
function HitMarkUINew:OnFireStateChanged(bIsInFire, bIsRelated)
  if self.UnFireDelayShowTime == nil then
    self.UnFireDelayShowTime = 4
  end
  if self.bIsGunADS == nil then
    self:SetScopeCoefficient()
  end
  if not self.LastAlpha then
    self.LastAlpha = 1
  end
  local bIsHide = bIsInFire and bIsRelated
  if bIsHide and self.bIsGunADS then
    self.IsInFire = true
    self:OnSmallIconChange(true)
    self:SetSelfOpacity(self.FireAlpha)
    if self.DelayShowTimer then
      self:RemoveGameTimer(self.DelayShowTimer)
      self.DelayShowTimer = nil
    end
  elseif self.bIsGunADS then
    if self.DelayShowTimer then
      return
    end
    self.DelayShowTimer = self:AddGameTimer(self.UnFireDelayShowTime, false, function()
      self.IsInFire = false
      self:OnSmallIconChange(self.IsCurSmall)
      self:SetSelfOpacity(self.LastAlpha)
    end)
  else
    self.IsInFire = false
    self:OnSmallIconChange(self.IsCurSmall)
    self:SetSelfOpacity(self.LastAlpha)
  end
end
function HitMarkUINew:SetSelfOpacity(Alpha)
  if slua.isValid(self.Object) then
    self:SetColorAndOpacity(FLinearColor(1, 1, 1, Alpha))
  end
end
function HitMarkUINew:HandleOnWidgetAlphaChange(Alpha)
  if not self.FireAlpha then
    self.FireAlpha = 0.2
  end
  if self.IsInFire then
    self:SetSelfOpacity(self.FireAlpha)
  else
    self:SetSelfOpacity(Alpha)
  end
  self.Lastend
function HitMarkUINew:OnReply()
  self.Image_Reply:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function HitMarkUINew:OnCenterAlphaChanged(Alpha, CenterOffsetRatio)
  self:HandleOnWidgetAlphaChange(Alpha)
  self:HandleOnCenterOffsetChange(CenterOffsetRatio)
end
function HitMarkUINew:HandleOnCenterOffsetChange(CenterOffsetRatio)
  print(bWriteLog and "HitMarkUINew:HandleOnCenterOffsetChange ", CenterOffsetRatio)
  if self.bIsGunADS == nil then
    self:SetScopeCoefficient()
  end
  if self.bIsGunADS == false then
    if self.LastScale ~= self.MaxCenterScale then
      self.CanvasPanel_Root:SetRenderScale(FVector2D(self.MaxCenterScale, self.MaxCenterScale))
      self.LastScale = self.MaxCenterScale
    end
    self.CanvasPanel_DistInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  if CenterOffsetRatio > self.HideDistanceRatio then
    self.CanvasPanel_DistInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_DistInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local finaleScale = self.ChangeScaleSpeed * (1 - CenterOffsetRatio) * (self.MaxCenterScale - self.MinCenterScale) + self.MinCenterScale
  if finaleScale > self.MaxCenterScale then
    finaleScale = self.MaxCenterScale
  elseif finaleScale < self.MinCenterScale then
    finaleScale = self.MinCenterScale
  end
  if self.LastScale == finaleScale then
    return
  end
  self.CanvasPanel_Root:SetRenderScale(FVector2D(finaleScale, finaleScale))
  self.LastScale = finaleScale
end
function HitMarkUINew:OnLocationBindUI(Loc)
  print(bWriteLog and "HitMarkUINew:OnLocationBindUI", self.Object)
  self.bShowWidget = true
  local TimeUtil = require("client.common.time_util")
  self.BindTime = TimeUtil.GetServerTimeInSec()
  self.bIsUpdateDistanceToLua = true
  self:AfterShow()
end
function HitMarkUINew:AfterShow()
  local OldMarkStyle = 1
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    OldMarkStyle = SettingSubsystem:GetUserSettings_Int("OldMarkStyle")
  end
  if OldMarkStyle == 1 then
    self:OnSmallIconChange(false)
    self.OldMarkStyle = true
    self.DistanceLine = nil
    self:ChangeOldMarkStyle(false)
    return
  end
  self.OldMarkStyle = false
  self:OnSmallIconChange(self.IsCurSmall)
  self:ChangeOldMarkStyle(true)
  self.DistanceLine = self.LineImg
  self:SwitchIfOutOfScreen(self.bIsCurrentOutOfScreen)
end
function HitMarkUINew:ChangeOldMarkStyle(bIsNew)
  if bIsNew then
    self.DotImg:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.LineImg:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.Image_Effect:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.Image_Icon.Slot:SetOffsets(FMargin(0, 0, 26, 26))
    self.Image_Icon.Slot:SetAlignment(FVector2D(0.5, 0.5))
    self.Image_BG:SetBrushfromPathAsync(self.NewImageStylePath.InScreenBG, false)
    self.Image_BG.Slot:SetOffsets(FMargin(0, 0, 36, 36))
    self.CenterImage:SetBrushfromPathAsync(self.NewImageStylePath.OutScreenBG, false)
    self.CenterImage.Slot:SetOffsets(FMargin(0, 0, 30, 30))
    self.CenterImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    local PointerBrush = slua.IndexReference(self.PointerWIdget, "Brush"):clone()
    PointerBrush.ImageSize = FVector2D(48.0, 49.0)
    self.PointerWIdget:SetBrush(PointerBrush)
    self.PointerWIdget.Slot:SetOffsets(FMargin(0, -5, 60, 60))
    self.PointerWIdget:SetRenderTransformPivot(FVector2D(0.5, 0.6))
    self.PointerWIdget:SetBrushfromPathAsync(self.NewImageStylePath.ArrowIcon, false)
    self.Image_2.Slot:SetSize(FVector2D(20, 20))
    self.AngleOffset = -90
    local Brush = slua.IndexReference(self.LineImg, "Brush"):clone()
    Brush.TintColor = FSlateColor(FLinearColor(1, 0.08022, 0.021219, 1.0))
    self.LineImg:SetBrush(Brush)
    local DotBrush = slua.IndexReference(self.DotImg, "Brush"):clone()
    DotBrush.TintColor = FSlateColor(FLinearColor(1, 0.08022, 0.021219, 0.7))
    self.DotImg:SetBrush(DotBrush)
  else
    self.DotImg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.LineImg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.Image_Effect:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.Image_Icon.Slot:SetOffsets(FMargin(0, -3.5, 22, 22))
    self.Image_BG:SetBrushfromPathAsync(self.OldImageStylePath.InScreenBG, false)
    self.Image_BG.Slot:SetOffsets(FMargin(0, 0, 32, 42))
    self.CenterImage:SetBrushfromPathAsync(self.OldImageStylePath.OutScreenBG, false)
    self.CenterImage.Slot:SetOffsets(FMargin(0, 0, 72, 72))
    self.CenterImage:SetColorAndOpacity(FLinearColor(0.187821, 0.038204, 0.012286, 1))
    local PointerBrush = slua.IndexReference(self.PointerWIdget, "Brush"):clone()
    PointerBrush.ImageSize = FVector2D(80.0, 80.0)
    self.PointerWIdget:SetBrush(PointerBrush)
    self.PointerWIdget.Slot:SetOffsets(FMargin(0, 0, 60, 60))
    self.PointerWIdget:SetRenderTransformPivot(FVector2D(0.5, 0.5))
    self.PointerWIdget:SetBrushfromPathAsync(self.OldImageStylePath.ArrowIcon, false)
    self.Image_2.Slot:SetSize(FVector2D(22, 22))
    self.AngleOffset = 0
  end
end
function HitMarkUINew:ChangeDistanceLineHeight(Height)
  if self.LastHeight ~= nil and self.LastHeight - Height < 0.1 then
    return
  end
  local Brush = slua.IndexReference(self.LineImg, "Brush"):clone()
  Brush.ImageSize = FVector2D(Brush.ImageSize.X, Height)
  self.LineImg:SetBrush(Brush)
end
function HitMarkUINew:OnSmallIconChange(bIsSmallIcon)
  if self.OldMarkStyle == true then
    return
  end
  if (bIsSmallIcon or self.IsInFire) and not self.bIsCurrentOutOfScreen then
    self.MainIconPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.DotImg:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  else
    self.MainIconPanel:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.DotImg:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.IsInFire = false
    if self.DelayShowTimer then
      self:RemoveGameTimer(self.DelayShowTimer)
      self.DelayShowTimer = nil
    end
  end
end
function HitMarkUINew:OnLocationUnbindUI(Loc)
  print(bWriteLog and "HitMarkUINew:OnLocationUnbindUI", self.Object)
  self.bIsUpdateDistanceToLua = false
end
function HitMarkUINew:Destruct()
  print(bWriteLog and "HitMarkUINew:Destruct", self)
  self.Super:Destruct()
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_UI_OPER_REPLY_MARK, self.SelfMark, self, false)
  if self.DelayShowTimer then
    self:RemoveGameTimer(self.DelayShowTimer)
    self.DelayShowTimer = nil
  end
  self.DistanceLine = nil
  self:UnRegistEvents()
end
function HitMarkUINew:OnDestroy()
  print(bWriteLog and "HitMarkUINew:OnDestroy", self)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_UI_OPER_REPLY_MARK, self.SelfMark, self, false)
  if self.DelayShowTimer then
    self:RemoveGameTimer(self.DelayShowTimer)
    self.DelayShowTimer = nil
  end
  self.DistanceLine = nil
  self:Dispose()
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, HitMarkUINew)