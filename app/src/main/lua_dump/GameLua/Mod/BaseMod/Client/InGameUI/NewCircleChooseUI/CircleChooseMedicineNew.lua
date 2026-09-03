local CircleChooseMedicineNew = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local UI_Util = require("client.slua_ui_framework.util")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local ETouchIndex = import("ETouchIndex")
function CircleChooseMedicineNew:ctor()
  self.bHasEnterCenter = false
end
function CircleChooseMedicineNew:OnInitialize()
  CircleChooseMedicineNew.__super.OnInitialize(self)
  local CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  self.IDSlotMap = CircleChooseCfg.RingListCfg.Medicines
  self.ValidSlotNum = CircleChooseCfg.MedValidSlotNum or 5
  self.MaterialInstPath = "/Game/Arts/UI/UI_Mat/RingThrowUI/MI_RingThrowUI_Med.MI_RingThrowUI_Med"
  local CustomType = require("client.logic.setting.CustomType")
  self:SetCustomLayout(CustomType._3_FirstAid, FVector2D(-247.6, -91.0))
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
end
function CircleChooseMedicineNew:RegistEvents()
  CircleChooseMedicineNew.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_GRENADE_RING_OPEN_OR_CLOSE, self.OnGrenadeRingOpenOrClose, self)
end
function CircleChooseMedicineNew:OnPostInitialize()
  CircleChooseMedicineNew.__super.OnPostInitialize(self)
  local GrenadesMedsSubsytem = SubsystemMgr:Get("GrenadesMedsSubsytem")
  if GrenadesMedsSubsytem then
    self:AddDataListener(GrenadesMedsSubsytem:GetSuperData(), "bMedicineItemChange", self.OnMedicItemChange, self)
  end
  self:AddGameTimer(0, false, function()
    self:OnMedicItemChange()
  end)
end
function CircleChooseMedicineNew:OnMedicItemChange()
  local bShow = false
  local bListShow = false
  local FinalConsumablesList = {}
  local GrenadesMedsSubsytem = SubsystemMgr:Get("GrenadesMedsSubsytem")
  if GrenadesMedsSubsytem then
    FinalConsumablesList = GrenadesMedsSubsytem:GetFinalConsumables()
    if FinalConsumablesList then
      if 0 < #FinalConsumablesList then
        bShow = true
      end
      if 1 < #FinalConsumablesList then
        bListShow = true
      end
    end
  end
  self:Update(bShow)
  self:UpdateListBox(bListShow, FinalConsumablesList, false)
end
function CircleChooseMedicineNew:UpdateCenterSlot()
  local CurBattleItem = self.MySubsystem.CurrentSelectedConsumableBattleItem
  if CurBattleItem then
    local ItemID = CurBattleItem.DefineID.TypeSpecificID
    local Num = CurBattleItem.Count
    local BrushPath = self.MySubsystem:GetPathFromCachedMap(ItemID, false)
    if BrushPath then
      self.UIRoot.ThrowItem_01:SetBrushFromPathAsync(BrushPath, false)
    end
    self.UIRoot.ThrowText_01_num:SetText(tostring(Num))
  end
end
function CircleChooseMedicineNew:OnBackpackChanged()
  CircleChooseMedicineNew.__super.OnBackpackChanged(self)
  self:UpdateCenterSlot()
end
function CircleChooseMedicineNew:OnGrenadeRingOpenOrClose(_, _, IsOpen)
  print(bWriteLog and "CircleChooseMedicineNew:OnGrenadeRingOpenOrClose", IsOpen)
  if IsOpen then
    self.UIRoot.Border_Throw:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_Throw:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function CircleChooseMedicineNew:TouchStartLua(PointerIndex)
  CircleChooseMedicineNew.__super.TouchStartLua(self, PointerIndex)
  EventSystem:postEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_MEDICINE_RING_OPEN_OR_CLOSE, true)
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if ShootingUIPanel and ShootingUIPanel.ConsumeListPanel then
    ShootingUIPanel.ConsumeListPanel.Slot:SetZOrder(1)
  end
end
function CircleChooseMedicineNew:OnEnterSlotLua(SlotNum)
  CircleChooseMedicineNew.__super.OnEnterSlotLua(self, SlotNum)
  if SlotNum < 0 then
    self.bHasEnterCenter = true
  end
end
function CircleChooseMedicineNew:TouchEndLua(PointerIndex)
  self:TouchUpImpl(PointerIndex)
  CircleChooseMedicineNew.__super.TouchEndLua(self, PointerIndex)
end
function CircleChooseMedicineNew:TouchUpImpl(PointerIndex)
  if self.UIRoot.CurrentSlot >= 0 and self.UIRoot.CurrentSlot <= 4 then
    self.RingList[self.UIRoot.CurrentSlot]:HandleSlotChosen()
  elseif self.UIRoot.CurrentSlot < 0 and not self.bHasEnterCenter then
    local CurMed = self.MySubsystem.CurrentSelectedConsumableBattleItem
    CircleChooseUtil.UseConsumableItem(CurMed)
  end
  self.bHasEnterCenter = false
  self.CurFingerIndex = ETouchIndex.Touch10
  EventSystem:postEvent(EVENTTYPE_INGAME_CIRCLECHOOSEWIDGET, EVENTID_MEDICINE_RING_OPEN_OR_CLOSE, false)
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseItemBaseUI")
function CircleChooseMedicineNew:OnClose()
  print(bWriteLog and "CircleChooseMedicineNew:OnClose")
  CircleChooseMedicineNew.__super.OnClose(self)
end
return class(object, nil, CircleChooseMedicineNew)