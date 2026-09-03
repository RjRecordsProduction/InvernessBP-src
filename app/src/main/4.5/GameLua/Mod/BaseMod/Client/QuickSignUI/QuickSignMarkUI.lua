local ESightTypeDef = import("ESightType")
local QuickSignMarkUI = {}
local OldArrowPivot = FVector2D(0.5, 2.7)
local OldInnerBGSize = FVector2D(32, 40)
local OldOuterBGSize = FVector2D(32, 40)
local OldInnerIconSlotSize = FVector2D(32.0, 32.0)
local NewArrowPivot = FVector2D(0.5, 0.6)
local NewInnerBGSize = FVector2D(36, 36)
local NewOuterBGSize = FVector2D(30, 30)
local NewInnerIconSlotSize = FVector2D(26.0, 26.0)
local _SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local _Collapsed = UEnums.ESlateVisibility.Collapsed
function QuickSignMarkUI:ctor()
  self.MaxCenterScale = 1.0
  self.MinCenterScale = 0.8
  self.ChangeScaleSpeed = 2
  self.HideDistanceRatio = 1
  self.BGSmallIcon = {
    DJ_Icon_dibiao_new_Big_hongse_png = FLinearColor(1, 0.08022, 0.021219, 1.0),
    DJ_Icon_dibiao_new_Big_huangse_png = FLinearColor(1.0, 0.693872, 0.021219, 1.0),
    DJ_Icon_dibiao_new_Big_Baidi_png = FLinearColor(1.0, 0.693872, 0.021219, 1.0),
    DJ_Icon_dibiao_new_Big_huangsedi_png = FLinearColor(1.0, 0.693872, 0.021219, 1.0)
  }
  self.IconInScreenSize = FVector2D(26, 26)
  self.IconOutScreenSize = FVector2D(20, 20)
  self.FireSmall = false
  self.MarkUIType = 0
  self.bOldStyle = false
end
function QuickSignMarkUI:Initialize()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SCOPECHANGE, self.OnScopeChange, self)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self.bOldStyle = SettingModule:GetOptionValue("OldMarkStyle") == 1
  self:SetStyle(self.bOldStyle)
end
function QuickSignMarkUI:LuaOnDistanceLineHeightChange(DistanceLineHeight)
  self:SetScopeCoefficient()
  local FinalHeight = DistanceLineHeight / self.ScopeCoefficient
  if FinalHeight < self.DistanceLineLimit.Z then
    FinalHeight = self.DistanceLineLimit.Z
  end
  self:ChangeDistanceLineHeight(FinalHeight)
end
function QuickSignMarkUI:LuaOnReply()
  self.Image_Reply:SetWidgetVisibility(_SelfHitTestInvisible)
end
function QuickSignMarkUI:OnScopeChange()
  self:SetScopeCoefficient()
  local FinalHeight = self.LastDistanceLineHeight / self.ScopeCoefficient
  if FinalHeight < self.DistanceLineLimit.Z then
    FinalHeight = self.DistanceLineLimit.Z
  end
  self:ChangeDistanceLineHeight(FinalHeight)
end
function QuickSignMarkUI:SetScopeCoefficient()
  self.ScopeCoefficient = 1
  if not slua.isValid(self.STExtraPlayerController) then
    return
  end
  local uPlayerCharcter = self.STExtraPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerCharcter) then
    return
  end
  self.bIsGunADS = uPlayerCharcter.bIsGunADS
  if not self.bIsGunADS then
    self.IsInFire = false
    self:LuaOnSmallIconChange(self.bIsLastSmallIcon)
    if not self.LastAlpha then
      self.LastAlpha = 1
    end
    self:SetColorAndOpacity(FLinearColor(1, 1, 1, self.LastAlpha))
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
function QuickSignMarkUI:LuaOnFireStateChange(bIsInFire, bIsRelated)
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
    self:LuaOnSmallIconChange(true)
    self:SetColorAndOpacity(FLinearColor(1, 1, 1, self.FireAlpha))
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
      self:LuaOnSmallIconChange(self.bIsLastSmallIcon)
      if slua.isValid(self.Object) then
        self:SetColorAndOpacity(FLinearColor(1, 1, 1, self.LastAlpha))
      end
    end)
  else
    self.IsInFire = false
    self:LuaOnSmallIconChange(self.bIsLastSmallIcon)
    self:SetColorAndOpacity(FLinearColor(1, 1, 1, self.LastAlpha))
  end
end
function QuickSignMarkUI:AfterShow()
  print(bWriteLog and "QuickSignMarkUI:AfterShow", self)
  if self.bOldStyle then
    self:HandleSmallIconChange(false)
    self.DistanceLine = nil
  else
    Client.RequireSlateTickEveryFrame(SlateUI_ID.QUICK_SIGN_MARK)
    self:HandleSmallIconChange(self.bIsLastSmallIcon)
    self.DistanceLine = self.LineImg
    self:PlayUserWidgetAnimation(self.Auto_Fadein, 0, 1, 0, 1.5)
    self:OnChangeOutScreenState(self.bIsOutScreen)
    for Path, Color in pairs(self.BGSmallIcon) do
      local pos = string.find(self.BgPath, Path, 0)
      if pos then
        local Brush = slua.IndexReference(self.LineImg, "Brush"):clone()
        Brush.TintColor = FSlateColor(Color)
        self.LineImg:SetBrush(Brush)
        local DotBrush = slua.IndexReference(self.DotImg, "Brush"):clone()
        Color.A = 0.7
        DotBrush.TintColor = FSlateColor(Color)
        self.DotImg:SetBrush(DotBrush)
        break
      end
    end
  end
end
function QuickSignMarkUI:ChangeDistanceLineHeight(Height)
  if self.LastHeight ~= nil and self.LastHeight - Height < 0.1 then
    return
  end
  local Brush = slua.IndexReference(self.LineImg, "Brush"):clone()
  Brush.ImageSize = FVector2D(Brush.ImageSize.X, Height)
  self.LineImg:SetBrush(Brush)
end
function QuickSignMarkUI:OnChangeOutScreenState(bIsOutScreen)
  if bIsOutScreen then
    self.DotImg:SetWidgetVisibility(_Collapsed)
    self.LineImg:SetWidgetVisibility(_Collapsed)
    if self.Image_Icon then
      self.Image_Icon.Slot:SetSize(self.IconOutScreenSize)
    end
    self:LuaOnSmallIconChange(false)
  elseif not self.bOldStyle then
    self.LineImg:SetWidgetVisibility(_SelfHitTestInvisible)
    self:LuaOnSmallIconChange(self.bIsLastSmallIcon)
    if self.Image_Icon then
      self.Image_Icon.Slot:SetSize(self.IconInScreenSize)
    end
  end
end
function QuickSignMarkUI:LuaOnSmallIconChange(bIsSmallIcon)
  if self.bOldStyle == true then
    return
  end
  self:HandleSmallIconChange(bIsSmallIcon)
end
function QuickSignMarkUI:HandleSmallIconChange(bIsSmallIcon)
  if (bIsSmallIcon or self.IsInFire) and not self.bIsOutScreen then
    self.CanvasPanel_Content:SetWidgetVisibility(_Collapsed)
    self.TextBlock_Distance:SetWidgetVisibility(_Collapsed)
    self.DistanceBG:SetWidgetVisibility(_Collapsed)
    self.DotImg:SetWidgetVisibility(_SelfHitTestInvisible)
  else
    self.CanvasPanel_Content:SetWidgetVisibility(_SelfHitTestInvisible)
    self.TextBlock_Distance:SetWidgetVisibility(_SelfHitTestInvisible)
    self.DistanceBG:SetWidgetVisibility(_SelfHitTestInvisible)
    self.DotImg:SetWidgetVisibility(_Collapsed)
    self.IsInFire = false
    if self.DelayShowTimer then
      self:RemoveGameTimer(self.DelayShowTimer)
      self.DelayShowTimer = nil
    end
  end
end
function QuickSignMarkUI:LuaOnWidgetAlphaChange(Alpha)
  if not self.FireAlpha then
    self.FireAlpha = 0.2
  end
  if self.IsInFire then
    self:SetColorAndOpacity(FLinearColor(1, 1, 1, self.FireAlpha))
  else
    self:SetColorAndOpacity(FLinearColor(1, 1, 1, Alpha))
  end
  self.Lastend
function QuickSignMarkUI:LuaOnCenterRatioChange(CenterOffsetRatio)
  if self.bIsGunADS == nil then
    self:SetScopeCoefficient()
  end
  if self.bIsGunADS == false then
    if self.LastScale ~= self.MaxCenterScale then
      self.CanvasPanel_Root:SetRenderScale(FVector2D(self.MaxCenterScale, self.MaxCenterScale))
      self.LastScale = self.MaxCenterScale
    end
    if self.CanvasPanel_DistInfo then
      self.CanvasPanel_DistInfo:SetWidgetVisibility(_SelfHitTestInvisible)
    end
    return
  end
  if CenterOffsetRatio > self.HideDistanceRatio then
    if self.CanvasPanel_DistInfo then
      self.CanvasPanel_DistInfo:SetWidgetVisibility(_Collapsed)
    end
  elseif self.CanvasPanel_DistInfo then
    self.CanvasPanel_DistInfo:SetWidgetVisibility(_SelfHitTestInvisible)
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
function QuickSignMarkUI:SetStyle(bIsOld)
  if bIsOld then
    self.bOldStyle = true
    self.Image_arrow.Slot:SetOffsets(FMargin(0, -20, 17, 12))
    self.Image_arrow:SetRenderTransformPivot(OldArrowPivot)
    if self.Image_BG then
      self.Image_BG.Slot:SetOffsets(FMargin(0, 10, 32, 40))
      self.OutScreenBGSize = OldOuterBGSize
      self.InScreenBGSize = OldInnerBGSize
    end
    if self.Image_Icon_Inner then
      self.Image_Icon_Inner.Slot:SetSize(OldInnerIconSlotSize)
    end
    if self.Image_Icon_Outer then
      self.Image_Icon_Outer.Slot:SetOffsets(FMargin(0, 0, 38.0, 49.0))
    end
    self.IconInScreenSize = FVector2D(25, 25)
    self.IconOutScreenSize = FVector2D(25, 25)
    self.DotImg:SetWidgetVisibility(_Collapsed)
    self.LineImg:SetWidgetVisibility(_Collapsed)
    self.Image_Effect:SetWidgetVisibility(_Collapsed)
  else
    self.bOldStyle = false
    self.Image_arrow.Slot:SetOffsets(FMargin(0, 0, 45, 45))
    self.Image_arrow:SetRenderTransformPivot(NewArrowPivot)
    if self.Image_BG then
      self.Image_BG.Slot:SetOffsets(FMargin(0, 5, 36, 36))
      self.OutScreenBGSize = NewOuterBGSize
      self.InScreenBGSize = NewInnerBGSize
    end
    if self.Image_Icon_Inner then
      self.Image_Icon_Inner.Slot:SetSize(NewInnerIconSlotSize)
    end
    if self.Image_Icon_Outer then
      self.Image_Icon_Outer.Slot:SetOffsets(FMargin(0, 2, 22.0, 22.0))
    end
    self.IconInScreenSize = FVector2D(26, 26)
    self.IconOutScreenSize = FVector2D(20, 20)
    self.DotImg:SetWidgetVisibility(_SelfHitTestInvisible)
    self.LineImg:SetWidgetVisibility(_SelfHitTestInvisible)
    self.Image_Effect:SetWidgetVisibility(_SelfHitTestInvisible)
  end
end
function QuickSignMarkUI:Destruct()
  Client.ReleaseSlateTickEveryFrame(SlateUI_ID.QUICK_SIGN_MARK)
  print(bWriteLog and "QuickSignMarkUI:Destruct", self)
  self.Super:Destruct()
  if self.DelayShowTimer then
    self:RemoveGameTimer(self.DelayShowTimer)
    self.DelayShowTimer = nil
  end
  self.DistanceLine = nil
  self:UnRegistEvents()
end
function QuickSignMarkUI:OnDestroy()
  print(bWriteLog and "QuickSignMarkUI:OnDestroy")
  if self.DelayShowTimer then
    self:RemoveGameTimer(self.DelayShowTimer)
    self.DelayShowTimer = nil
  end
  self.DistanceLine = nil
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CQuickSignMarkUI = class(CDelegateContainer, nil, QuickSignMarkUI)
return CQuickSignMarkUI