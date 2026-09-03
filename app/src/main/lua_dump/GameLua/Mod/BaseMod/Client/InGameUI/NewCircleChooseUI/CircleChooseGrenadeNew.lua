local CircleChooseGrenadeNew = {}
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local UI_Util = require("client.slua_ui_framework.util")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UAESkillManagerUtils = import("UAESkillManagerUtils")
local ETouchIndex = import("ETouchIndex")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local uBackpackUtils = import("BackpackUtils")
local EHoldThrowType = {CenterQuickThrow = 1, CircleQuickThrow = 2}
function CircleChooseGrenadeNew:ctor()
  self.RingThrowSwitch = false
  self.RingThrowPressSetting = false
  self.b3DTouchSwitcher = false
  self.StartTouchPickDelay = 0.4
  self.FinishPickOneGrenadeTime = 0.4
  self.StayOnSlotHandler = nil
  self.StartTouchPickOneTimer = nil
  self.TouchToThrowTimer = nil
  self.StopFireToSwitchTimer = nil
  self.SpecialWidgetID = {}
  self.SpecialWidget = nil
  self.HoldThrowType = 0
  self.changeWeaponDelegate = nil
end
function CircleChooseGrenadeNew:OnInitialize()
  CircleChooseGrenadeNew.__super.OnInitialize(self)
  local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  self.IDSlotMap = CircleChooseCfg.RingListCfg.Grenades
  self.ValidSlotNum = CircleChooseCfg.GrenadeValidSlotNum or 5
  self.MaterialInstPath = "/Game/Arts/UI/UI_Mat/RingThrowUI/MI_RingThrowUI.MI_RingThrowUI"
  self.SpecialWidgetID = CircleChooseCfg.SpecialAnnexID or {}
  local CustomType = require("client.logic.setting.CustomType")
  self:SetCustomLayout(CustomType._9_Projectile, FVector2D(186.0, -89.0))
  self:RefreshSetting()
end
function CircleChooseGrenadeNew:RegistEvents()
  CircleChooseGrenadeNew.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_MEDICINE_RING_OPEN_OR_CLOSE, self.OnMedicineRingOpenOrClose, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_THROW_BUTTON_CLICK, self.OnThrowButClick, self)
end
function CircleChooseGrenadeNew:OnClose()
  self:ClearTimers()
  if self.SpecialWidget then
    self.SpecialWidget:Close()
  end
  CircleChooseGrenadeNew.__super.OnClose(self)
end
function CircleChooseGrenadeNew:UpdateCenterSlot()
  local CurBattleItem = self.MySubsystem.FinalGrenadesList[1]
  if CurBattleItem then
    local ItemID = CurBattleItem.DefineID.TypeSpecificID
    local bMed = CircleChooseUtil.IsAMedicine(ItemID)
    local bMelee = CircleChooseUtil.SimMelee(ItemID)
    local Num = CurBattleItem.Count
    local sPath = self.MySubsystem:GetPathFromCachedMap(ItemID, bMed)
    self.UIRoot.ThrowItem_01:SetBrushFromPathAsync(sPath, false)
    if bMed or bMelee then
      self.UIRoot.ThrowText_01_num:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.ThrowText_01_num:SetText(tostring(Num))
      self.UIRoot.ThrowText_01_num:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    self:UpdateSpecialWidget(CurBattleItem)
  end
end
function CircleChooseGrenadeNew:UpdateSpecialWidget(BattleItemData)
  local ItemID = BattleItemData.DefineID.TypeSpecificID
  if self.SpecialWidgetID[ItemID] then
    local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
    local AddiData = uBackpackUtils.GetAddtionalData(EBattleItemAdditionalDataType.RemainingDuability, BattleItemData.AdditionalData)
    local VehicleHealth = AddiData.FloatData
    if VehicleHealth <= 0 then
      VehicleHealth = 1
    end
    if not self.SpecialWidget then
      if UIManager.UI_Config_InGame.CircleChooseAnnex then
        self.SpecialWidget = UIManager.ShowUI(UIManager.UI_Config_InGame.CircleChooseAnnex)
        self:AttachChildWindow("CanvasPanel_Main", self.SpecialWidget)
        self.SpecialWidget:SetAnchors(0.5, 0.5, 0.5, 0.5)
        self.SpecialWidget:SetOffsets(-31, -31, 60, 60)
      end
    elseif not self.SpecialWidget:IsShow() then
      self.SpecialWidget:SelfHitTestInvisible()
    end
    self.SpecialWidget:UpdateData(true, VehicleHealth)
  elseif self.SpecialWidget and self.SpecialWidget:IsShow() then
    self.SpecialWidget:Collapsed()
  end
end
function CircleChooseGrenadeNew:MarkDownStatus(bShow)
  if bShow then
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CircleChooseGrenadeNew:HideCenterWidget(bHide)
  if bHide then
    self.UIRoot.CanvasPanel_Center:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_Center:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function CircleChooseGrenadeNew:UpdateMedSlot(ItemID)
  local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  if MySubsystem.bEnableThrowMeds then
    self.RingList[4].  else
    self.RingList[4].ItemID = -1
  end
  self.RingList[4]:UpdateOwningImage()
end
function CircleChooseGrenadeNew:OnBackpackChanged()
  CircleChooseGrenadeNew.__super.OnBackpackChanged(self)
  self:UpdateCenterSlot()
end
function CircleChooseGrenadeNew:TouchStartLua(PointerIndex)
  print(bWriteLog and "CircleChooseGrenadeNew:TouchStart")
  CircleChooseGrenadeNew.__super.TouchStartLua(self, PointerIndex)
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if ShootingUIPanel and ShootingUIPanel.GrenadeListPanel then
    ShootingUIPanel.GrenadeListPanel.Slot:SetZOrder(1)
  end
  self.LastMedicineThrown = false
  self:ClearTimers()
  EventSystem:postEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_GRENADE_RING_OPEN_OR_CLOSE, true)
  self:RefreshSetting()
  local CurBattleItem = self.MySubsystem.FinalGrenadesList[1]
  if not CurBattleItem then
    return
  end
  local CurItemID = slua.IndexReference(CurBattleItem, "DefineID").TypeSpecificID
  if self.RingThrowSwitch and not self.b3DTouchSwitcher and not CircleChooseUtil.SimMelee(CurItemID) then
    self.StartTouchPickOneTimer = self:AddGameTimer(self.StartTouchPickDelay, false, function()
      self:HandleCenterChosen(false)
      self:SwitchToGrenadeAndPrepareToThrow(false)
    end)
    self.HoldThrowType = EHoldThrowType.CenterQuickThrow
  elseif not self.RingThrowSwitch and not self.b3DTouchSwitcher then
    self.StartTouchPickOneTimer = self:AddGameTimer(self.StartTouchPickDelay, false, function()
      local EWidgetTouchState = import("EWidgetTouchState")
      self.TouchState = EWidgetTouchState.Dragging
      self:OnDragBeginLua()
    end)
  end
end
function CircleChooseGrenadeNew:OnDragBeginLua()
  print(bWriteLog and "CircleChooseGrenadeNew:DragBegin")
  CircleChooseGrenadeNew.__super.OnDragBeginLua(self)
  self:ClearTimers()
end
function CircleChooseGrenadeNew:OnEnterSlotLua(SlotNum)
  print(bWriteLog and "CircleChooseGrenadeNew:OnEnterSlot")
  if self.UIRoot.CanvasPanel_RingList:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    return
  end
  CircleChooseGrenadeNew.__super.OnEnterSlotLua(self, SlotNum)
  self:ClearTimers()
  if self.RingThrowPressSetting and not self.b3DTouchSwitcher then
    self.StayOnSlotHandler = self:AddGameTimer(self.FinishPickOneGrenadeTime, false, function()
      self:SwitchToGrenadeAndPrepareToThrow(true)
    end)
    self.HoldThrowType = EHoldThrowType.CircleQuickThrow
  end
end
function CircleChooseGrenadeNew:TouchEndLua(PointerIndex)
  print(bWriteLog and "CircleChooseGrenadeNew:TouchEndLua", self.CurrentSlot, self.TouchState, PointerIndex)
  self:TouchUpImpl(PointerIndex)
end
function CircleChooseGrenadeNew:OnMedicineRingOpenOrClose(_, _, IsOpen)
  print(bWriteLog and "CircleChooseGrenadeNew:OnMedicineRingOpenOrClose", IsOpen)
  if IsOpen then
    self.UIRoot.Border_Throw:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_Throw:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function CircleChooseGrenadeNew:OnThrowButClick()
  print(bWriteLog and "CircleChooseGrenadeNew:OnThrowButClick")
  self:ClearTimers()
  self.CurFingerIndex = ETouchIndex.Touch10
  EventSystem:postEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_GRENADE_RING_OPEN_OR_CLOSE, false)
  self.IsPrepareToThrow = false
  if self.CanMoveandEnd then
    CircleChooseGrenadeNew.__super.TouchEndLua(self, self.CurFingerIndex)
  end
end
function CircleChooseGrenadeNew:TouchUpImpl(PointerIndex)
  print(bWriteLog and "CircleChooseGrenadeNew:TouchUpImpl", PointerIndex, self.UIRoot.CurrentSlot, self.CanMoveandEnd)
  if not self.CanMoveandEnd then
    return
  end
  self:ClearTimers()
  self.CurFingerIndex = ETouchIndex.Touch10
  EventSystem:postEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_GRENADE_RING_OPEN_OR_CLOSE, false)
  local ParentWidget = InGameUITools.GetShootingUIPanelLuaClass()
  if self.IsPrepareToThrow then
    ParentWidget:GrenadeThrow()
    self.IsPrepareToThrow = false
    self:SendThrowTLog()
  elseif self.CanMoveandEnd then
    if self.UIRoot.CurrentSlot >= 0 and self.UIRoot.CurrentSlot <= 4 then
      self.RingList[self.UIRoot.CurrentSlot]:HandleSlotChosen()
      self:PlayAudio(sound_config.CircleChoose_EnterSLot)
    elseif self.UIRoot.CurrentSlot == -1 and self.UIRoot.Image_Close:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
      print(bWriteLog and "CircleChooseGrenadeNew:TouchUpImpl touch center IsChoosingMedicine", self.IsChoosingMedicine)
      self:HandleCenterChosen(true)
    end
  end
  CircleChooseGrenadeNew.__super.TouchEndLua(self, PointerIndex)
end
function CircleChooseGrenadeNew:HandleCenterChosen(bNeedFist)
  local CurItem = self.MySubsystem.FinalGrenadesList[1]
  if CurItem and self.MySubsystem.PreUsingGrenadeID ~= CurItem.DefineID.TypeSpecificID then
    CircleChooseUtil.HandleItemChosen(CurItem)
  elseif bNeedFist then
    CircleChooseUtil.HandleItemChosen()
  end
end
function CircleChooseGrenadeNew:SwitchToGrenadeAndPrepareToThrow(InSlot)
  local bNeedStopFire = self:StopFire()
  self:RemoveIgnoreFinger()
  local SwitchAndThrowFunc = function()
    local ParentWidget = InGameUITools.GetShootingUIPanelLuaClass()
    self.UIRoot.CanvasPanel_RingList:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.GrenadeListBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.UIRoot.CurrentSlot >= 0 and self.UIRoot.CurrentSlot <= 4 then
      self.RingList[self.UIRoot.CurrentSlot]:HandleSlotChosen()
    elseif self.UIRoot.CurrentSlot == -1 then
      self:HandleCenterChosen(false)
    end
    if self.changeWeaponDelegate ~= nil then
      return
    end
    local WeaponMgr = self.MySubsystem:GetWeaponMgr()
    if WeaponMgr ~= nil then
      if not InSlot then
        local curWeaponSlot = WeaponMgr:GetCurrentUsingPropSlot()
        local uWeapon = WeaponMgr:GetCurrentUsingWeapon()
        if not slua.isValid(uWeapon) then
          return
        end
        if ESurviveWeaponPropSlot.SWPS_HandProp == curWeaponSlot then
          local SkillID = uWeapon.GetGrenadeSkillID and uWeapon:GetGrenadeSkillID() or 0
          self:ClearTimers()
          self.TouchToThrowTimer = self:AddGameTimer(0.1, false, function()
            if self.CurFingerIndex == ETouchIndex.Touch10 or not self.CanMoveandEnd then
              print(bWriteLog and "CircleChooseGrenadeNew:SwitchToGrenadeAndPrepareToThrow up")
              return
            end
            if 0 < SkillID then
              print(bWriteLog and "CircleChooseGrenadeNew:SwitchToGrenadeAndPrepareToThrow SkillID", SkillID)
              if ParentWidget:ShouldThrowGrenadeWithID(ParentWidget.CurGrenadeID, SkillID) then
                ParentWidget:GrenadePrepareToThrow(self.CurFingerIndex)
                self.IsPrepareToThrow = true
              end
            end
          end)
          return
        end
      end
      self.changeWeaponDelegate = WeaponMgr.ChangeCurrentUsingWeaponDelegate:Add(function(WeaponPropSlot)
        print(bWriteLog and "CircleChooseGrenadeNew:SwitchToGrenadeAndPrepareToThrow onChangeWeapon", WeaponPropSlot, ESurviveWeaponPropSlot.SWPS_HandProp)
        if WeaponPropSlot ~= ESurviveWeaponPropSlot.SWPS_HandProp then
          return
        end
        self:ClearTimers()
        local character = GameplayData.GetPlayerCharacter()
        if not slua.isValid(character) then
          return
        end
        local DelayTime = character.ClientCallSwitchWeaponDur
        if 0 < DelayTime then
          DelayTime = 0.2 + DelayTime
        else
          DelayTime = 0.2
        end
        self.TouchToThrowTimer = self:AddGameTimer(DelayTime, false, function()
          if self.CurFingerIndex == ETouchIndex.Touch10 or not self.CanMoveandEnd then
            return
          end
          local success = ParentWidget:GrenadePrepareToThrow(self.CurFingerIndex)
          print(bWriteLog and "CircleChooseGrenadeNew:SwitchToGrenadeAndPrepareToThrow DelayTime", DelayTime, success, ParentWidget.CurGrenadeID)
          if self.changeWeaponDelegate ~= nil then
            WeaponMgr.ChangeCurrentUsingWeaponDelegate:Remove(self.changeWeaponDelegate)
            self.changeWeaponDelegate = nil
          end
          if success then
            self.IsPrepareToThrow = true
            return
          end
        end)
      end)
    else
      print(bWriteLog and "CircleChooseGrenadeNew:SwitchToGrenadeAndPrepareToThrow weaponManager is nil!")
    end
  end
  if bNeedStopFire then
    self:ClearTimers()
    self.StopFireToSwitchTimer = self:AddGameTimer(0.1, false, SwitchAndThrowFunc)
  else
    SwitchAndThrowFunc()
  end
end
function CircleChooseGrenadeNew:StopFire()
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass then
    ShootingUIPanelLuaClass:OnReleasedFire(true)
    ShootingUIPanelLuaClass:OnReleasedFire(false)
    return true
  end
  return false
end
function CircleChooseGrenadeNew:RefreshSetting()
  local bRingThrowSwitch = CircleChooseUtil.GetSettingByStrKey("RingThrowSwitch")
  if bRingThrowSwitch ~= self.RingThrowSwitch then
    self.RingThrowSwitch = bRingThrowSwitch
    if bRingThrowSwitch then
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_SET_VALUE_TLOG, "CenterQuickThrow", 1)
    else
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_SET_VALUE_TLOG, "CenterQuickThrow", 0)
    end
  end
  local bRingThrowPressSetting = CircleChooseUtil.GetSettingByStrKey("RingThrowPressSwitch")
  if bRingThrowPressSetting ~= self.RingThrowPressSetting then
    self.RingThrowPressSetting = bRingThrowPressSetting
    if bRingThrowPressSetting then
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_SET_VALUE_TLOG, "CircleQuickThrow", 1)
    else
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_SET_VALUE_TLOG, "CircleQuickThrow", 0)
    end
  end
  self.b3DTouchSwitcher = CircleChooseUtil.GetSettingByStrKey("3DTouchSwitcher")
end
function CircleChooseGrenadeNew:SendThrowTLog()
  if self.HoldThrowType == EHoldThrowType.CenterQuickThrow then
    EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "CenterQuickThrowCnt", 1)
  elseif self.HoldThrowType == EHoldThrowType.CircleQuickThrow then
    EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "CircleQuickThrowCnt", 1)
  end
  self.HoldThrowType = 0
end
function CircleChooseGrenadeNew:ClearTimers()
  if self.StartTouchPickOneTimer then
    self:RemoveGameTimer(self.StartTouchPickOneTimer)
    self.StartTouchPickOneTimer = nil
  end
  if self.StayOnSlotHandler then
    self:RemoveGameTimer(self.StayOnSlotHandler)
    self.StayOnSlotHandler = nil
  end
  if self.StartTouchTimer then
    self:RemoveGameTimer(self.StartTouchTimer)
    self.StartTouchTimer = nil
  end
  if self.TouchToThrowTimer then
    self:RemoveGameTimer(self.TouchToThrowTimer)
    self.TouchToThrowTimer = nil
  end
  if self.StopFireToSwitchTimer then
    self:RemoveGameTimer(self.StopFireToSwitchTimer)
    self.StopFireToSwitchTimer = nil
  end
  local MySubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  if MySubsystem then
    local WeaponMgr = MySubsystem:GetWeaponMgr()
    if self.changeWeaponDelegate ~= nil and WeaponMgr then
      WeaponMgr.ChangeCurrentUsingWeaponDelegate:Remove(self.changeWeaponDelegate)
      self.changeWeaponDelegate = nil
    end
  end
end
function CircleChooseGrenadeNew:RemoveIgnoreFinger()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and self.CurFingerIndex < uPlayerController.IgnoreCameraMovingIndexArray:Num() then
    uPlayerController.IgnoreCameraMovingIndexArray:Remove(self.CurFingerIndex)
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseItemBaseUI")
return class(object, nil, CircleChooseGrenadeNew)