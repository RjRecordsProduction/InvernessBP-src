local CircleChooseItemBaseUI = {}
local USTExtraUIUtils = import("STExtraUIUtils")
local ETouchIndex = import("ETouchIndex")
local STExtraUIUtils = import("STExtraUIUtils")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function CircleChooseItemBaseUI:ctor()
  print(bWriteLog and "CircleChooseItemBaseUI:ctor", self)
  self.WidgetMap = {}
  self.Colors = {
    Grey = FLinearColor(1, 1, 1, 0.3),
    White = FLinearColor(1, 1, 1, 1),
    Black = FLinearColor(0, 0, 0, 1)
  }
  self.RingList = {}
  self.IDSlotMap = {}
  self.ItemWidgetList = {}
  self.VisibilityCtrls = {}
  self.MySubsystem = nil
  self.GrenadesListPanel = nil
  self.IsListExpand = false
  self.CanMoveandEnd = false
  self.CurFingerIndex = ETouchIndex.Touch10
  self.VMShow = true
end
function CircleChooseItemBaseUI:OnInitialize()
  CircleChooseItemBaseUI.__super.OnInitialize(self)
  print(bWriteLog and "CircleChooseItemBaseUI:Initialize", self, self.UIRoot)
  self:InitAngleAndSlot(5)
  self.UIRoot.Radius = 30
  self.UIRoot.BeginDragThreshold = 5
  print(bWriteLog and "CircleChooseItemBaseUI CircleChooseGrenadeUITEST:Initialize")
  self.RingSlotMap = {
    [4] = {
      Image = self.UIRoot.ThrowItem_04,
      ItemNumText = self.UIRoot.ThrowText_04_num,
      HighlightWidget = self.UIRoot.ThrowItem_04_Select,
      SpecialWidget = self.UIRoot.Image_BanThrow,
      BGImage = self.UIRoot.ThrowItem_04_BG,
      OwningImage = self.UIRoot.Image_Owning4
    },
    [3] = {
      Image = self.UIRoot.ThrowItem_02,
      ItemNumText = self.UIRoot.ThrowText_02_num,
      HighlightWidget = self.UIRoot.ThrowItem_02_Select,
      OwningImage = self.UIRoot.Image_Owning3
    },
    [2] = {
      Image = self.UIRoot.ThrowItem_03,
      ItemNumText = self.UIRoot.ThrowText_03_num,
      HighlightWidget = self.UIRoot.ThrowItem_03_Select,
      OwningImage = self.UIRoot.Image_Owning1
    },
    [1] = {
      Image = self.UIRoot.ThrowItem_05,
      ItemNumText = self.UIRoot.ThrowText_05_num,
      HighlightWidget = self.UIRoot.ThrowItem_05_Select,
      OwningImage = self.UIRoot.Image_Owning2
    },
    [0] = {
      Image = self.UIRoot.ThrowItem_06,
      ItemNumText = self.UIRoot.ThrowText_06_num,
      HighlightWidget = self.UIRoot.ThrowItem_06_Select,
      OwningImage = self.UIRoot.Image_Owning5
    }
  }
  self.MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  local util = require("client.slua_ui_framework.util")
  local sGrenadeListItemClassPath = "/Game/BluePrints/ControlInput/CircleChooseWidget/GrenadeListItem_UIBP.GrenadeListItem_UIBP_C"
  util.GetAssetAsync(sGrenadeListItemClassPath, function(_LoadObject)
    self.GrenadeListItemClass = _LoadObject
  end)
end
function CircleChooseItemBaseUI:InitAngleAndSlot(ValidSlotNum)
  local tAngles = {
    [1] = -180,
    [2] = -157.5,
    [3] = -22.5
  }
  local ValidDegree = 225
  if not ValidSlotNum or ValidSlotNum == 0 then
    print(bWriteLog and "CircleChooseItemBaseUI:InitAngleAndSlot, InvalidSlotNum", ValidSlotNum)
    return
  end
  local DegreeOffset = ValidDegree / ValidSlotNum
  for i = 4, ValidSlotNum + 1 + 2 do
    tAngles[i] = tAngles[i - 1] + DegreeOffset
  end
  tAngles[#tAngles] = 180
  local tSlots = {
    [1] = ValidSlotNum - 1,
    [2] = -2,
    [3] = 0
  }
  for i = 4, ValidSlotNum + 2 do
    tSlots[i] = tSlots[i - 1] + 1
  end
  for index, value in ipairs(tAngles) do
    self.UIRoot.Angles:Add(value)
  end
  for index, value in ipairs(tSlots) do
    self.UIRoot.Slots:Add(value)
  end
end
function CircleChooseItemBaseUI:OnPostInitialize()
  CircleChooseItemBaseUI.__super.OnPostInitialize(self)
  local ModType = GameMainConfig.GetModType()
  local ModPath = string.format("GameLua.Mod.%s.Client.InGameUI.NewCircleChooseUI.CircleGrenadeItem", ModType)
  local DefaultPath = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleGrenadeItem"
  local FinalPath = GamePlayTools.LuaFileExits(ModPath) and ModPath or DefaultPath
  local SlotItem = require(FinalPath)
  for SlotID, tData in pairs(self.RingSlotMap) do
    self.RingList[SlotID] = SlotItem(tData, self.IDSlotMap[SlotID])
  end
  for key, value in pairs(self.RingList) do
    value:OnInit()
  end
  self:Update(true)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_MainIcon)
end
function CircleChooseItemBaseUI:Close()
  print(bWriteLog and "CircleChooseItemBaseUI:Close", self)
  if self.GrenadesListPanel then
    self.GrenadesListPanel:Close()
    self.GrenadesListPanel = nil
  end
  self.GrenadeListItemClass = nil
  for key, value in pairs(self.RingList) do
    if value then
      value:Close()
    end
  end
  self.RingSlotMap = nil
  self.RingList = {}
  CircleChooseItemBaseUI.__super.Close(self)
end
function CircleChooseItemBaseUI:OnClose()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_MainIcon)
  CircleChooseItemBaseUI.__super.OnClose(self)
end
function CircleChooseItemBaseUI:RegistEvents()
  CircleChooseItemBaseUI.__super.RegistEvents(self)
  print(bWriteLog and "CircleChooseItemBaseUI:RegistEvent", self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchStartedDel", self.TouchStartLua, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEndedDel", self.TouchEndLua, self)
  self:AddControlEventByControl(self.UIRoot, "OnDragBeginDel", self.OnDragBeginLua, self)
  self:AddControlEventByControl(self.UIRoot, "OnEnterSlotDel", self.OnEnterSlotLua, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, self.OnBackpackChanged, self)
end
function CircleChooseItemBaseUI:Update(bShow)
  self.VisibilityCtrls.DataShow = bShow
  local FinalShow = self:GetFinalVisibilityFlag()
  if FinalShow then
    self:UpdateCenterSlot()
    for key, value in pairs(self.RingList) do
      value:UpdateOwningImage()
    end
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CircleChooseItemBaseUI:HandleSwitchVehicleWeapon()
  local bShow = true
  local uPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPawn) then
    local uWeapon = uPawn:GetTemporaryWeapon()
    if slua.isValid(uWeapon) and uWeapon.CanSwitchToGrenade then
      bShow = uWeapon:CanSwitchToGrenade()
    end
  end
  self.VisibilityCtrls.VehicleWeapon = bShow
  self:RefreshFinalVisibility()
  return bShow
end
function CircleChooseItemBaseUI:SetVisibilityFlag(InFlag, InVisible)
  print(bWriteLog and "CircleChooseItemBaseUI:SetVisibilityFlag", InFlag, InVisible)
  self.VisibilityCtrls[InFlag] = InVisible
  self:RefreshFinalVisibility()
end
function CircleChooseItemBaseUI:GetFinalVisibilityFlag()
  for key, value in pairs(self.VisibilityCtrls) do
    if not value then
      return false
    end
  end
  return true
end
function CircleChooseItemBaseUI:RefreshFinalVisibility()
  local FinalShow = self:GetFinalVisibilityFlag()
  if FinalShow then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CircleChooseItemBaseUI:HideRingSelected()
  self.UIRoot.CanvasPanel_RingList:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.GrenadeListBox:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_Changan:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function CircleChooseItemBaseUI:UpdateRingUI()
  for key, value in pairs(self.RingList) do
    value:UpdateImage()
  end
end
function CircleChooseItemBaseUI:UpdateListBox(bShow, tData, bGrenades)
  if bShow then
    if self.GrenadesListPanel then
      EventSystem:postEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_UPDATE_LIST_PANEL, tData, bGrenades)
    else
      local GrenadesListPanelConfig = UIManager.UI_Config_InGame.GrenadeListBox
      if GrenadesListPanelConfig then
        self.GrenadesListPanel = UIManager.ShowUI(GrenadesListPanelConfig, tData, bGrenades)
        self:AttachChildWindow("GrenadeListBox", self.GrenadesListPanel)
      end
    end
  elseif self.GrenadesListPanel then
    self.GrenadesListPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CircleChooseItemBaseUI:SetCustomLayout(InCustomType, Position)
  local CustomContainer = self.UIRoot.CustomizeContainer
  CustomContainer.Slot:SetPosition(Position)
  CustomContainer.Default  CustomContainer:SetCustomType(InCustomType)
end
function CircleChooseItemBaseUI:OnEnterSlotLua(SlotNum)
  print(bWriteLog and "CircleChooseItemBaseUI:OnEnterSlotLua", SlotNum)
  for index, value in pairs(self.RingList) do
    if SlotNum == index then
      value.HighlightWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:PlayAudio(sound_config.CircleChoose_EnterSLot)
    else
      value.HighlightWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local vis = self.UIRoot.CanvasPanel_RingList:GetVisibility()
  if SlotNum == -1 and self.UIRoot.CanvasPanel_RingList:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    self.UIRoot.Image_Close:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAudio(sound_config.CircleChoose_EnterSLot)
  else
    self.UIRoot.Image_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CircleChooseItemBaseUI:OnReleaseScreen(FingerIndex)
  if FingerIndex == self.CurFingerIndex then
    self:TouchUpImpl()
    local EWidgetTouchState = import("EWidgetTouchState")
    self.UIRoot.TouchState = EWidgetTouchState.Up
    self.CanMoveandEnd = false
    print(bWriteLog and "CircleChooseItemBaseUI:OnReleaseScreen", self.UIRoot.TouchState, FingerIndex, self.CurFingerIndex)
    self.CurFingerIndex = ETouchIndex.Touch10
    self:HideRingSelected()
  end
end
function CircleChooseItemBaseUI:TouchStartLua(PointerIndex)
  print(bWriteLog and "CircleChooseItemBaseUI:TouchStartLua PointerIndex", PointerIndex)
  local playerController = GameplayData.GetPlayerController()
  if slua.isValid(playerController) then
    print(bWriteLog and "CircleChooseItemBaseUI:OnReleaseScreen Add")
    self:AddControlEventByControl(playerController, "OnReleaseScreen", self.OnReleaseScreen, self)
  end
  self.UIRoot.CurrentSlot = -1
  self.CanMoveandEnd = true
  self.CurFingerIndex = PointerIndex
  self.UIRoot.Image_Changan:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if slua.isValid(playerController) then
    if slua.isValid(playerController.IgnoreCameraMovingIndexArray) then
      playerController.IgnoreCameraMovingIndexArray:Add(self.CurFingerIndex)
    end
    if slua.isValid(playerController.AddTouchMoveFingerArray) then
      playerController.AddTouchMoveFingerArray:Add(self.CurFingerIndex)
    end
  end
  self.UIRoot.Image_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function CircleChooseItemBaseUI:TouchEndLua(PointerIndex)
  print(bWriteLog and "CircleChooseItemBaseUI:TouchEndLua")
  self.CanMoveandEnd = false
  if self.UIRoot.GrenadeListBox then
    self.UIRoot.GrenadeListBox:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self.UIRoot.CanvasPanel_RingList:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_Changan:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.CurFingerIndex = ETouchIndex.Touch10
  local playerController = GameplayData.GetPlayerController()
  if slua.isValid(playerController) then
    print(bWriteLog and "CircleChooseItemBaseUI:OnReleaseScreen Remove")
    self:RemoveControlEventByControl(playerController, "OnReleaseScreen")
  end
end
function CircleChooseItemBaseUI:OnDragBeginLua()
  for index, value in pairs(self.RingList) do
    if value.HighlightWidget then
      value.HighlightWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  print(bWriteLog and "CircleChooseItemBaseUI:OnDragBeginLua", self.IsPrepareToThrow)
  if not self.IsPrepareToThrow then
    self:UpdateRingUI()
    self.UIRoot.CanvasPanel_RingList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self.UIRoot.GrenadeListBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function CircleChooseItemBaseUI:OnBackpackChanged()
  self:UpdateRingUI()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, CircleChooseItemBaseUI)