local FittingSlotItemUI = {bSelected = false}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local KismetTextLibrary = import("KismetTextLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local FBattleItemUseTarget = import("BattleItemUseTarget")
local EBattleItemDisuseReason = import("EBattleItemDisuseReason")
local EBattleItemUseReason = import("EBattleItemUseReason")
local ESlateVisibility = import("ESlateVisibility")
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
function FittingSlotItemUI:ctor()
  self.bEnableFitingSlot = true
  self.uMaskUIRef = nil
end
function FittingSlotItemUI:OnInitialize()
  FittingSlotItemUI.__super.OnInitialize(self)
  self.Image_FittingIcon = self.UIRoot.Image_FittingIcon
  self.Image_Lock = self.UIRoot.Image_Lock
  self.Image_Quality = self.UIRoot.Image_Quality
  self.Image_SlotHoverStatus = self.UIRoot.Image_SlotHoverStatus
  self.TextBlock_FittingName = self.UIRoot.TextBlock_FittingName
  self.DefineID = self.UIRoot.DefineID
  self.DragOrigin = self.UIRoot.DragOrigin
  self.highlightAttachID = slua.IndexReference(self.UIRoot, "highlightAttachID")
  self.ItemBeDragBegin = self.UIRoot.ItemBeDragBegin
  self.ItemBeDragCancel = self.UIRoot.ItemBeDragCancel
  self.FittingName = self.UIRoot.FittingName
  self.ChatText = 0
  self.Quality = self.UIRoot.Quality
  self.LastQuality = self.UIRoot.LastQuality
  self.additionalDataType = self.UIRoot.additionalDataType
  self.nSocketType = -1
  self.nItemID = 0
  self.BezelUI = nil
end
function FittingSlotItemUI:RegistEvents()
  FittingSlotItemUI.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchStartedImplementation", self.OnTouchStarted, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEndedImplementation", self.OnTouchEnded, self)
  self:AddControlEventByControl(self.UIRoot, "OnDragDetectedImplementation", self.OnDragDetected, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SHOW_BEZEL_ANIM, self.OnShowBezelAnim, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SHOW_GUNLOCK_ANIM, self.OnShowGunLockAnim, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SHOW_TACTICALATTACH_ANIM, self.OnShowTacticalAttachAnim, self)
end
function FittingSlotItemUI:OnClicked_Button_SlotClick()
  if not self.IsTouchStart then
    printf(bWriteLog and "FittingSlotItemUI:OnClicked_Button_SlotClick IsTouchStart false")
    return
  end
  self.IsTouchStart = false
  if self.nSocketType == -1 then
    if self.DefineID.TypeSpecificID ~= 0 then
      self:ShowACTips()
    end
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    printf(bWriteLog and "FittingSlotItemUI:OnClicked_Button_SlotClick uPlayerController invalid")
    return
  end
  printf(bWriteLog and "FittingSlotItemUI:OnClicked_Button_SlotClick")
  if self.highlightAttachID and self.highlightAttachID.TypeSpecificID == 0 then
    if self.Image_FittingIcon:GetVisibility() ~= ESlateVisibility.Collapsed then
      local ItemData = CDataTable.GetTableData("Item", self.DefineID.TypeSpecificID)
      if ItemData and ItemData.ItemType ~= 1 then
        uPlayerController:ServerDisuseItem(self.DefineID, EBattleItemDisuseReason.Manually)
      end
    else
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
      local ModType, _ = GameMainConfig.GetModType()
      if ModType ~= "SocialIsland" and not BackpackConfig.tTacticalAttachTipsInfo[self.nSocketType] then
        local uQuickSignComponent = uPlayerController:GetQuickSignComponent()
        if Game:IsValid(uQuickSignComponent) then
          uQuickSignComponent:MakeQuickNeed(self.ChatText)
          local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
          local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
          local uChatComponent = uPlayerController:GetChatComponent()
          if Game:IsValid(uChatComponent) and MainControlBaseUI then
            MainControlBaseUI:StartChatBarAnimation(uChatComponent.SendMsgCD)
          end
        end
      end
      if BackpackConfig.tTacticalAttachTipsInfo[self.nSocketType] and not StoreConfig.HideBezelMods[ModType] and not StoreConfig.HideNewAccessoriesInfoMods[ModType] then
        self.BezelUI = self.parentWeaponInfo:ShowBezelTips(self.nSocketType)
      end
    end
  else
    local BattleData = self:GetGunBattleData()
    local BattleItemUseTarget = FBattleItemUseTarget()
    BattleItemUseTarget.TargetDefineID = BattleData.DefineID
    BattleItemUseTarget.TargetAssociationType = 0
    BattleItemUseTarget.TargetActor = nil
    uPlayerController:ServerUseItem(self.highlightAttachID, BattleItemUseTarget, EBattleItemUseReason.Manually)
  end
end
function FittingSlotItemUI:OnTouchStarted(MyGeometry, InTouchEvent)
  printf(bWriteLog and "FittingSlotItemUI:OnTouchStarted")
  self.IsTouchStart = true
end
function FittingSlotItemUI:OnTouchEnded()
  printf(bWriteLog and "FittingSlotItemUI:OnTouchEnded")
  self:OnClicked_Button_SlotClick()
end
function FittingSlotItemUI:OnDragCancelled(PointerEvent, Operation)
  self.ItemBeDragCancel:BroadCast()
end
function FittingSlotItemUI:UpdateSlotItem(resID, defineID, dragOrigin, additionalDataType)
  local ItemID = 0
  local ItemQuality = 0
  local ItemSmallIcon = ""
  local BackpackSimple = ""
  self.DefineID = defineID
  self.DragOrigin = dragOrigin
  self.  print(bWriteLog and "FittingSlotItemUI:UpdateSlotItem resID:" .. resID)
  if resID == 0 then
    return
  end
  ItemQuality = CDataTable.GetTableData("Item", resID).ItemQuality
  ItemID = CDataTable.GetTableData("Item", resID).ItemID
  self.  ItemSmallIcon = CDataTable.GetTableData("Item", resID).ItemSmallIcon or ""
  BackpackSimple = CDataTable.GetTableData("Item", resID).BackpackSimple or ""
  local UIRoot = self.UIRoot
  UIRoot.Image_Quality:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if ItemID ~= 0 then
    UIRoot.TextBlock_FittingName:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    UIRoot.TextBlock_FittingName:SetText(KismetTextLibrary.Conv_StringToText(BackpackSimple))
    UIRoot.TextBlock_FittingName:SetColorAndOpacity(FSlateColor(FLinearColor(1.0, 1.0, 1.0, 1.0)))
    UIRoot.Image_FittingIcon:SetBrushFromPathAsync(ItemSmallIcon, false)
    UIRoot.Image_FittingIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Quality = ItemQuality
    self:UpdataQualityImage()
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
    if BackpackConfig.tTacticalAttachTipsInfo[self.nSocketType] then
      UIRoot.CanvasPanel_Labels:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
end
function FittingSlotItemUI:HighLightSocket(highLight, defineID)
  self.highlightAttachID = defineID
  if highLight then
    self.Image_SlotHoverStatus:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.Image_SlotHoverStatus:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function FittingSlotItemUI:OnDragDetected()
  local UIRoot = self.UIRoot
  if self.IsTouchStart and self.DefineID and self.DefineID.TypeSpecificID ~= 0 and UIRoot.Image_FittingIcon:GetVisibility() ~= ESlateVisibility.Collapsed then
    local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
    local BattleItemData = BackPackFunctionLibrary.GetBattleItemByDefineID(self.DefineID, UIRoot)
    if BattleItemData then
      UIRoot.ItemBeDragBegin:BroadCast(BattleItemData, self.DragOrigin)
      local BackPackDragWidget = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackDragWidget_BP.BackPackDragWidget_BP_C", self.UIRoot)
      BackPackDragWidget:SetPic(UIRoot.Image_FittingIcon.Brush)
      UIRoot.OnDragDetectedResult = UIRoot:CreateDragDropOpt(BackPackDragWidget, BattleItemData, self.DragOrigin, self.additionalDataType)
    end
  else
    UIRoot.OnDragDetectedResult = nil
  end
end
function FittingSlotItemUI:GetGunBattleData()
  if self.parentWeaponInfo then
    return self.parentWeaponInfo.BattleData
  elseif self.PistolInfo then
    return self.PistolInfo.BattleData
  end
end
function FittingSlotItemUI:ResetSlotIcon(bShowLock, nSlotType, nSlotNameID, nSlotChatID, tParentUI)
  print(bWriteLog and "FittingSlotItemUI:ResetSlotIcon nSlotType:" .. nSlotType .. " nSlotNameID:" .. nSlotNameID)
  local UIRoot = self.UIRoot
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if BackpackConfig.tTacticalAttachTipsInfo[nSlotType] then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType, _ = GameMainConfig.GetModType()
    local ModeID = GameMainConfig.GetModeID()
    if 1022 <= ModeID and ModeID <= 1063 then
      UIRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
      return
    end
  end
  self.ChatText = nSlotChatID
  self.nSocketType = nSlotType
  self:SetParentInfo(tParentUI)
  UIRoot:SetWidgetVisibility(ESlateVisibility.Visible)
  UIRoot.Image_FittingIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.Image_Equipment:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.Image_Quality:SetWidgetVisibility(ESlateVisibility.Collapsed)
  UIRoot.TextBlock_FittingName:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  UIRoot.TextBlock_FittingName:SetText(KismetTextLibrary.Conv_StringToText(LocUtil.LocalizeResFormat(nSlotNameID)))
  UIRoot.TextBlock_FittingName:SetColorAndOpacity(FSlateColor(FLinearColor(1.0, 1.0, 1.0, 0.47)))
  self:EnableSlotIcon()
  self.Quality = 0
  if bShowLock then
    UIRoot.Image_Lock:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    UIRoot.Image_Lock:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if BackpackConfig.tTacticalAttachTipsInfo[nSlotType] then
    UIRoot.CanvasPanel_Labels:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
  else
    UIRoot.CanvasPanel_Labels:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if self.BezelUI and self.BezelUI.bShow then
    self.BezelUI:ShowOrHide()
  end
end
function FittingSlotItemUI:UpdataQualityImage()
  local MergeExecutionPath0 = function()
    self.Image_Quality:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  local IsActiveItemQualityShow = STExtraModLogicSwitchLibrary.IsActiveItemQualityShow()
  if IsActiveItemQualityShow then
    if self.Quality > 0 then
      self.UIRoot.Image_Quality:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
      local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
      local Color = BackPackFunctionLibrary.GetAttachFitQualityBGImagePath(self.Quality)
      local kismet_string_library = require("common.kismet_string_library")
      if 0 < kismet_string_library.Len(Color) and self.Quality ~= self.LastQuality then
        self.UIRoot.Image_Quality:SetBrushFromPathAsync(Color, false)
      end
    else
      MergeExecutionPath0()
    end
  else
    MergeExecutionPath0()
  end
end
function FittingSlotItemUI:ShowACTips()
  print(bWriteLog and "FittingSlotItemUI:ShowACTips")
  if not self.DefineID then
    print(bWriteLog and "FittingSlotItemUI:ShowACTips DefineID nil")
    return
  end
  local ItemID = self.DefineID.TypeSpecificID
  if ItemID == 0 then
    self:HideSinkSlotTips()
    return
  end
  local WeaponConfig = CDataTable.GetTableData("WeaponConfig", ItemID)
  if WeaponConfig == nil then
    self:HideSinkSlotTips()
    return
  end
  if self.bSelected then
    self:HideSinkSlotTips()
    return
  end
  self.bSelected = true
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  local PickUpItemTips = BackpackUI.PickUpItemTips
  PickUpItemTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Image_SlotHoverStatus:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local WeaponACSlotTipsUI = UIManager.GetUI(UIManager.UI_Config_InGame.WeaponACTipsUI)
  if not WeaponACSlotTipsUI then
    WeaponACSlotTipsUI = UIManager.ShowUI(UIManager.UI_Config_InGame.WeaponACTipsUI)
  else
    WeaponACSlotTipsUI:ReleaseOldParent()
  end
  BackpackUI.UIRoot.GridPanel_0:AddChild(WeaponACSlotTipsUI.UIRoot)
  WeaponACSlotTipsUI.UIRoot.Slot:SetHorizontalAlignment(3)
  WeaponACSlotTipsUI.UIRoot.Slot:SetVerticalAlignment(3)
  local margin = FMargin(0, 0, PickUpItemTips.UIRoot.Slot.Padding.Right, 0)
  WeaponACSlotTipsUI.UIRoot.Slot:SetPadding(margin)
  WeaponACSlotTipsUI.UIRoot.Slot:SetLayer(2)
  WeaponACSlotTipsUI:SetWeaponInfo(WeaponConfig.TipsType)
  WeaponACSlotTipsUI:SetParent(self)
end
function FittingSlotItemUI:TryRefreshIcon()
  self.Image_FittingIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.Image_FittingIcon:SetBrushFromPathAsync("/Game/Arts/UI/NoAtlas/ZD_Icon_New.ZD_Icon_New", false)
end
function FittingSlotItemUI:HideSinkSlotTips()
  if not UIManager.UI_Config_InGame.WeaponACTipsUI then
    return
  end
  local ui = UIManager.GetUI(UIManager.UI_Config_InGame.WeaponACTipsUI)
  if ui then
    ui:CloseSelf()
  end
end
function FittingSlotItemUI:RefreshIcon(Icon)
  if not slua.isValid(Icon) then
    return
  end
  self.Image_FittingIcon:SetBrushFromTexture(Icon, false)
  self.Image_FittingIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function FittingSlotItemUI:IsWidgetShow(uWidget)
  local bIsShow = false
  if slua.isValid(uWidget) then
    local nState = uWidget:GetVisibility()
    bIsShow = nState ~= UEnums.ESlateVisibility.Collapsed and nState ~= UEnums.ESlateVisibility.Hidden
  end
  return bIsShow
end
function FittingSlotItemUI:SetEnableFitingSlot(bEnableFitingSlot)
  self.  self:EnableSlotIcon()
end
function FittingSlotItemUI:EnableSlotIcon()
  if self.bEnableFitingSlot then
    if self.uMaskUIRef then
      self.uMaskUIRef:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
  elseif self:IsWidgetShow(self.Object) then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if self.uMaskUIRef then
      self.uMaskUIRef:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  end
end
function FittingSlotItemUI:CreateMaskUI()
  local sUIPath = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BR_FitingSlotItem.BR_FitingSlotItem_C"
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  self.uMaskUIRef = USTExtraBlueprintFunctionLibrary.CreateWidgetByPathName(sUIPath, self.UIRoot)
  local CanvasPanel_Mask = self.UIRoot.CanvasPanel_Mask
  CanvasPanel_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  local CanvasPanelSlot = CanvasPanel_Mask:AddChildToCanvas(self.uMaskUIRef)
  if CanvasPanelSlot then
    CanvasPanelSlot:SetAnchors(FAnchors(0, 0, 1, 1))
    CanvasPanelSlot:SetOffsets(FMargin(0, 0, 0, 0))
    CanvasPanelSlot:SetAutoSize(true)
  end
end
function FittingSlotItemUI:SetParentInfo(ParentInfo)
  self.parentWeaponInfo = ParentInfo
end
function FittingSlotItemUI:OnClose()
  print(bWriteLog and "FittingSlotItemUI:OnClose")
  self.uMaskUIRef = nil
  self.BezelUI = nil
  self.parentWeaponInfo = nil
  FittingSlotItemUI.__super.OnClose(self)
end
function FittingSlotItemUI:OnShowBezelAnim()
  if self.nItemID == 0 and self.nSocketType == EWeaponAttachmentSocketType.Bezel then
    self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self:AddGameTimer(StoreConfig.BezelTipsAnimShowTime, false, function()
      self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end)
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_BEZEL_ANIM_COMPLETE)
  end
end
function FittingSlotItemUI:OnShowGunLockAnim()
  if self.nItemID == 0 and self.nSocketType == EWeaponAttachmentSocketType.GunLock then
    self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self:AddGameTimer(StoreConfig.BezelTipsAnimShowTime, false, function()
      self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end)
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_GUNLOCK_ANIM_COMPLETE)
  end
end
function FittingSlotItemUI:OnShowTacticalAttachAnim()
  if self.nItemID == 0 and self.nSocketType == EWeaponAttachmentSocketType.TacticalAttach then
    self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self:AddGameTimer(StoreConfig.BezelTipsAnimShowTime, false, function()
      self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end)
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_TACTICALATTACH_ANIM_COMPLETE)
  end
end
function FittingSlotItemUI:OnHideBezelAnim()
  self.UIRoot.Image_GuideLight:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, FittingSlotItemUI)