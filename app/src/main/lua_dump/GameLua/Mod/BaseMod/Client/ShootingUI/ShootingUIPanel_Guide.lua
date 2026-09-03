local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local ShootingUIPanelIMP = require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelIMP")
function ShootingUIPanelIMP:RegistEvents_Guide()
  GameplayData.AddSelfPlayerControllerEvent(self, "NewbieShowCurGuide", self.ShowOrHideNewbieGuide, self)
end
function ShootingUIPanelIMP:ShowOrHideNewbieGuide(TipsID, bShow)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController:IsSpectator() then
    return
  end
  local GuideTextStruct = CDataTable.GetTableData("GuideText", TipsID)
  if not GuideTextStruct then
    return
  end
  if TipsID == 1006 then
    self:ShowOrHideGlideTips(bShow, GuideTextStruct)
  end
  if TipsID == 1018 then
    self:ShowOrHideRightFireTips(bShow, GuideTextStruct)
  end
  if TipsID == 1019 then
    self:ShowOrHideLeftFireTips(bShow, GuideTextStruct)
  end
  if TipsID == 1020 then
    self:ShowOrHideReloadTips(bShow, GuideTextStruct)
  end
  if TipsID == 1015 then
    self:ShowOrHideSearchingHouseTips(bShow, GuideTextStruct)
  end
  if TipsID == 1007 then
    self:ShowOrHideSearchingHouseTips(bShow, GuideTextStruct)
  end
  if TipsID == 1038 then
    self:ShowOrHideGrenadeTips(bShow, GuideTextStruct)
  end
  if TipsID == 1049 then
    self:ShowOrHideGrenadeTips(bShow, GuideTextStruct)
  end
  if TipsID == 1025 then
    self:ShowOrHideConsumeTips(bShow, GuideTextStruct)
  end
  if TipsID == 1005 then
    self:ShowOrHideJumpingMoveCamTips(bShow, GuideTextStruct)
  end
  if TipsID == 1042 then
    self:ShowOrHideQuickThrowBtnTips(bShow, GuideTextStruct)
  end
end
function ShootingUIPanelIMP:ShowOrHideGlideTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideGlideTips")
  if not bShow and self.NewbieTips_Joystick then
    self.NewbieTips_Joystick:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.NewbieGuideCanvas:RemoveChild(self.NewbieTips_Joystick)
    return
  end
  self.NewbieTips_Joystick = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_Joystick.NewbieTips_Joystick", self.UIRoot)
  if not self.NewbieTips_Joystick then
    return
  end
  self.UIRoot.NewbieGuideCanvas:AddChild(self.NewbieTips_Joystick)
  self.NewbieTips_Joystick.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
  self.NewbieTips_Joystick:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local JoyStickCenter = PlayerController:GetJoyStickCenter()
    local ViewportSize = WidgetLayoutLibrary.GetViewportSize(self.UIRoot)
    local ViewportScale = WidgetLayoutLibrary.GetViewportScale(self.UIRoot)
    local X = JoyStickCenter.X * (ViewportSize.X / ViewportScale) - PlayerController.CurDeviceAdaptationOffset.LeftOffset
    local Y = JoyStickCenter.Y * (ViewportSize.Y / ViewportScale) - PlayerController.CurDeviceAdaptationOffset.TopOffset
    local Translation = FVector2D(X, Y)
    self.NewbieTips_Joystick.Image_LeftBtn:SetRenderTranslation(Translation)
    self.NewbieTips_Joystick.CanvasPanel_LeftBtn:SetRenderTranslation(Translation)
    self.NewbieTips_Joystick.Image_Arrow:SetRenderTranslation(Translation)
    self.NewbieTips_Joystick.Image_FX:SetRenderTranslation(Translation)
  end
  self.NewbieTips_Joystick.UTRichTextBlock_Tips1_Text1:SetText(GuideTextStruct.text1)
  self:PlayUserWidgetAnimation(self.NewbieTips_Joystick.Tips1_anima, 0, 0, 0, 1)
end
function ShootingUIPanelIMP:ShowOrHideRightFireTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideRightFireTips")
  if not bShow and self.NewbieTips_RightFire then
    self.NewbieTips_RightFire:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TipsRightFire_BareHandControl:RemoveChild(self.NewbieTips_RightFire)
    return
  end
  self.NewbieTips_RightFire = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_RightFire.NewbieTips_RightFire", self.UIRoot)
  if not self.NewbieTips_RightFire then
    return
  end
  self.UIRoot.TipsRightFire_BareHandControl:AddChild(self.NewbieTips_RightFire)
  local Slot = self.NewbieTips_RightFire.Slot
  Slot:SetAnchors(FAnchors(0, 0, 0, 0))
  Slot:SetPosition(FVector2D(0, 0))
  self.NewbieTips_RightFire:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.NewbieTips_RightFire.UTRichTextBlock_Tips4_Text1:SetText(GuideTextStruct.text1)
end
function ShootingUIPanelIMP:ShowOrHideLeftFireTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideLeftFireTips")
  if not bShow and self.NewbieTips_LeftFire then
    self.NewbieTips_LeftFire:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TipsLeftFire_BareHandControl:RemoveChild(self.NewbieTips_LeftFire)
    return
  end
  self.NewbieTips_LeftFire = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_LeftFire.NewbieTips_LeftFire", self.UIRoot)
  if not self.NewbieTips_LeftFire then
    return
  end
  self.UIRoot.TipsLeftFire_BareHandControl:AddChild(self.NewbieTips_LeftFire)
  local Slot = self.NewbieTips_LeftFire.Slot
  Slot:SetAnchors(FAnchors(0, 0.5, 0, 0.5))
  Slot:SetPosition(FVector2D(0.285736, -114.666664))
  self.NewbieTips_LeftFire:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.NewbieTips_LeftFire.UTRichTextBlock_Tips5_Text1:SetText(GuideTextStruct.text1)
end
function ShootingUIPanelIMP:ShowOrHideReloadTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideReloadTips")
  if not bShow and self.NewbieTips_Reload then
    self.NewbieTips_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TipsReload_BareHandControl:RemoveChild(self.NewbieTips_Reload)
    return
  end
  self.NewbieTips_Reload = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_Reload.NewbieTips_Reload", self.UIRoot)
  if not self.NewbieTips_Reload then
    return
  end
  self.UIRoot.TipsReload_BareHandControl:AddChild(self.NewbieTips_Reload)
  local Slot = self.UIRoot.TipsReload_BareHandControl.Slot
  Slot:SetAnchors(FAnchors(1, 1, 1, 1))
  Slot:SetPosition(FVector2D(-551.495972, -354.861176))
  self.NewbieTips_Reload:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.NewbieTips_Reload.UTRichTextBlock_Tips6:SetText(GuideTextStruct.text1)
end
function ShootingUIPanelIMP:ShowOrHideSearchingHouseTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideSearchingHouseTips")
  if not bShow and self.NewbieTips_SearchBuild then
    self.NewbieTips_SearchBuild:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.NewbieGuideCanvas:RemoveChild(self.UIRoot.NewbieTips_SearchBuild)
    return
  end
  self.NewbieTips_SearchBuild = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_SearchBuilding.NewbieTips_SearchBuilding", self.UIRoot)
  if not self.NewbieTips_SearchBuild then
    return
  end
  if self.NewbieTips_SearchBuild then
    self.UIRoot.NewbieGuideCanvas:AddChild(self.NewbieTips_SearchBuild)
    local Slot = self.NewbieTips_SearchBuild.Slot
    Slot:SetPosition(FVector2D(-507, -170))
    Slot:SetSize(FVector2D(200, 66))
    Slot:SetAnchors(FAnchors(1, 1, 1, 1))
    self.NewbieTips_SearchBuild:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.NewbieTips_SearchBuild.UTRichTextBlock_Tips2_Text1:SetText(GuideTextStruct.text1)
  end
end
function ShootingUIPanelIMP:ShowOrHideGrenadeTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideGrenadeTips")
  if not bShow then
    if self.NewbieTips_GrenadeList then
      self.NewbieTips_GrenadeList:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.NewbieGuideCanvas:RemoveChild(self.NewbieTips_GrenadeList)
    end
    return
  end
  self.NewbieTips_GrenadeList = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_GrenadeTips.NewbieTips_GrenadeTips", self.UIRoot)
  if self.NewbieTips_GrenadeList then
    self.UIRoot.NewbieGuideCanvas:AddChild(self.NewbieTips_GrenadeList)
    local Slot = self.NewbieTips_GrenadeList.Slot
    Slot:SetSize(FVector2D(429.333344, 390.0))
    Slot:SetPosition(FVector2D(0.0, -390.0))
    Slot:SetAnchors(FAnchors(0.5, 1, 0.5, 1))
    self.NewbieTips_GrenadeList:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.NewbieTips_GrenadeList.UTRichTextBlock_Tips10_Text1:SetText(GuideTextStruct.text1)
  end
end
function ShootingUIPanelIMP:ShowOrHideConsumeTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideConsumeTips")
  if not bShow and self.NewbieTips_ConsumeTips then
    self.NewbieTips_ConsumeTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.NewbieGuideCanvas:RemoveChild(self.UIRoot.NewbieTips_ConsumeTips)
    return
  end
  self.NewbieTips_ConsumeTips = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_ConsumeTips.NewbieTips_ConsumeTips", self.UIRoot)
  if not self.NewbieTips_ConsumeTips then
    return
  end
  self.UIRoot.NewbieGuideCanvas:AddChild(self.NewbieTips_ConsumeTips)
  local Slot = self.NewbieTips_ConsumeTips.Slot
  Slot:SetSize(FVector2D(429.333344, 390.0))
  Slot:SetPosition(FVector2D(-454.399994, -388.0))
  Slot:SetAnchors(FAnchors(0.5, 1, 0.5, 1))
  self.NewbieTips_ConsumeTips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.NewbieTips_ConsumeTips.UTRichTextBlock_Tips22_Text1:SetText(GuideTextStruct.text1)
end
function ShootingUIPanelIMP:ShowOrHideJumpingMoveCamTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideJumpingMoveCamTips")
  if not bShow and self.NewbieTips_JumpingMoveCam then
    self.NewbieTips_JumpingMoveCam:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.NewbieGuideCanvas:RemoveChild(self.UIRoot.NewbieTips_JumpingMoveCam)
    return
  end
  self.NewbieTips_JumpingMoveCam = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_JumpingMoveCam.NewbieTips_JumpingMoveCam", self.UIRoot)
  if not self.NewbieTips_JumpingMoveCam then
    return
  end
  self.UIRoot.NewbieGuideCanvas:AddChild(self.NewbieTips_JumpingMoveCam)
  local Slot = self.NewbieTips_JumpingMoveCam.Slot
  Slot:SetAnchors(FAnchors(0, 0, 1, 1))
  self.NewbieTips_JumpingMoveCam:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.NewbieTips_JumpingMoveCam.UTRichTextBlock_Tip1_Text2:SetText(GuideTextStruct.text1)
  self:PlayUserWidgetAnimation(self.NewbieTips_JumpingMoveCam.Tips2_anima, 0, 0, 0, 1)
end
function ShootingUIPanelIMP:ShowOrHideAllNewbieGuide(bShow)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideAllNewbieGuide")
  if bShow then
    self.UIRoot.NewbieGuideCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.NewbieGuideCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ShootingUIPanelIMP:ShowOrHideBareHandUI(bShow)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideBareHandUI " .. tostring(bShow))
  for _, Widget in pairs(self.BareHandHideTipsArray) do
    if slua.isValid(Widget) then
      if bShow then
        Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function ShootingUIPanelIMP:ShowOrHideQuickThrowBtnTips(bShow, GuideTextStruct)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowOrHideQuickThrowBtnTips")
  if not bShow then
    self.UIRoot.QuickThrowTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.QuickThrowTips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.QuickThrowTipsText:SetText(GuideTextStruct.text1)
end