local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EWeaponChangeInvenroryDataType = import("EWeaponChangeInvenroryDataType")
local FBattleItemData = import("/Script/Basic.BattleItemData")
local FItemRecordData = import("ItemRecordData")
function BackPackPanelUI:ShowBindWeaponMsg()
  if self.isBindWeaponMsg then
  elseif slua.isValid(self.UIRoot) then
    local uPawn = self.UIRoot:GetOwningPlayerPawn()
    if slua.isValid(uPawn) then
      self:BindWeaponMsgEvent()
      self:RemoveGameTimer(self.BindDelHandle)
    end
  end
end
function BackPackPanelUI:BindWeaponMsgEvent()
  self.isBindWeaponMsg = true
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      self:AddControlEventByControl(WeaponManager, "ChangeInventoryDataDelegate", self.UpdateWeaponBySlot1, self)
      self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.UpdateWeaponBySlot2, self)
      self:AddControlEventByControl(WeaponManager, "SwapWeaponByPropSlotFinishedDelegate", self.SwapWeapon, self)
      self:AddControlEventByControl(self.WeaponInfoItem_Weapon1.UIRoot, "ItemBeDragBegin", self.OnItemDragBegin, self)
      self:AddControlEventByControl(self.WeaponInfoItem_Weapon2.UIRoot, "ItemBeDragBegin", self.OnItemDragBegin, self)
      self:AddControlEventByControl(self.WeaponInfoItem_Weapon1.UIRoot, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
      self:AddControlEventByControl(self.WeaponInfoItem_Weapon2.UIRoot, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
      self:AddControlEventByControl(self.PistolInfoItem_BP.UIRoot, "ItemBeDragBegin", self.OnItemDragBegin, self)
      self:AddControlEventByControl(self.PistolInfoItem_BP.UIRoot, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
      self:AddControlEventByControl(self.MeleeInfoItem_BP.UIRoot, "ItemBeDragBegin", self.OnItemDragBegin, self)
      self:AddControlEventByControl(self.MeleeInfoItem_BP.UIRoot, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
      if self.DragDropWidgetWeaponDetail then
        self:AddControlEventByControl(self.DragDropWidgetWeaponDetail, "ItemBeDragBegin", self.OnItemDragBegin, self)
        self:AddControlEventByControl(self.DragDropWidgetWeaponDetail, "ItemBeDragCancelled", self.OnItemDragCancelled, self)
      end
    end
  end
end
function BackPackPanelUI:UpdateWeaponBySlot1(TargetChangeSlot, ChangeType)
  self:UpdateWeaponBySlot(TargetChangeSlot, EWeaponChangeInvenroryDataType.EWCIDT_Init)
end
function BackPackPanelUI:UpdateWeaponBySlot2(TargetChangeSlot, ChangeType)
  self:UpdateWeaponBySlot(TargetChangeSlot, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleWeaponChange(TargetChangeSlot)
end
function BackPackPanelUI:UpdateWeaponItems(WeaponItemDataArray)
  local EBackPackDragOrigin = UEnums.EBackPackDragOrigin
  for _, value in pairs(ESurviveWeaponPropSlot) do
    local LoopWeaponSlotEnum = value
    if LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
      local battledata_1, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, WeaponItemDataArray)
      log_tree("Debug_EBackPackDragOrigin", EBackPackDragOrigin)
      self.WeaponInfoItem_Weapon1:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_1, EBackPackDragOrigin.FromWeapon1 or 1)
    elseif LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
      local battledata_2, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, WeaponItemDataArray)
      self.WeaponInfoItem_Weapon2:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_2, EBackPackDragOrigin.FromWeapon2 or 2)
    elseif LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
      local battledata_3, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, WeaponItemDataArray)
      self.PistolInfoItem_BP:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_3, EBackPackDragOrigin.FromPistol or 6)
    elseif LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_MeleeWeapon then
      local battledata_4, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, WeaponItemDataArray)
      self.MeleeInfoItem_BP:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_4)
    end
  end
end
function BackPackPanelUI:HightLightAttachSlots(ItemData)
  local DefineId = ItemData.DefineID
  local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
  local IsAttach = BackPackFunctionLibrary.IsAttach(DefineId)
  if IsAttach then
    for _, Item in pairs(self.WeaponInfoItemArray) do
      Item:HighLightAttachSlot(DefineId)
    end
    self.PistolInfoItem_BP:HighLightAttachSlot(DefineId)
    if slua.isValid(self.DragDropWidgetWeaponDetail) then
      self.DragDropWidgetWeaponDetail:HighLightAttachSlot(DefineId)
    end
  end
end
function BackPackPanelUI:HighLightUpgradeWeapon(ItemData)
  local DefineID = ItemData.DefineID
  self.WeaponInfoItem_Weapon1:HighLightUpgradeWeapon(DefineID)
  self.WeaponInfoItem_Weapon2:HighLightUpgradeWeapon(DefineID)
end
function BackPackPanelUI:GetWeaponSlotEnumByName(Name)
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPawn = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    local WeaponManager = uPawn:GetWeaponManager()
    local SlotMap = WeaponManager.LogicSocketToPropSlotMap
    local value_3, returnvalue_3 = SlotMap:Get(Name), SlotMap:Get(Name) ~= nil
    return value_3, returnvalue_3
  end
end
function BackPackPanelUI:GetWeaponAttach()
  local TableUtil = require("common.table_util")
  TableUtil.Clear(self.WeaponList)
  local STExtraUIUtils = import("STExtraUIUtils")
  local uPawn = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(uPawn) then
    local WeaponManager = uPawn:GetWeaponManager()
    local returnvalue_2 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
    if slua.isValid(returnvalue_2) then
      TableUtil.UniqueInsert(self.WeaponList, returnvalue_2)
    end
    local returnvalue_4 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
    if slua.isValid(returnvalue_4) then
      TableUtil.UniqueInsert(self.WeaponList, returnvalue_4)
    end
    local returnvalue_9 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
    if slua.isValid(returnvalue_9) then
      TableUtil.UniqueInsert(self.WeaponList, returnvalue_9)
    end
  end
end
function BackPackPanelUI:GetWeaponDataBySlot(slotIndex, weaponList)
  local LoopBattleData, weaponMgr
  local CurWeaponList = weaponList
  local STExtraUIUtils = import("STExtraUIUtils")
  local returnvalue_19 = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not slua.isValid(returnvalue_19) then
    return FBattleItemData(), 0
  end
  local returnvalue_9 = returnvalue_19:GetWeaponManager()
  weaponMgr = returnvalue_9
  local output_get_21 = weaponMgr
  local returnvalue_10 = output_get_21:GetInventoryWeaponByPropSlot(slotIndex)
  if slua.isValid(returnvalue_10) then
    local returnvalue_4 = returnvalue_10:GetItemDefineID()
    local SlotWeaponDefineID = returnvalue_4
    local curweaponlist_13 = CurWeaponList
    for i_2, arrayelement_2 in pairs(curweaponlist_13) do
      LoopBattleData = arrayelement_2
      local DefineID = slua.IndexReference(LoopBattleData, "DefineID")
      local BackpackUtils = import("BackpackUtils")
      local returnvalue_7 = BackpackUtils.IsSameInstance(SlotWeaponDefineID, DefineID) and SlotWeaponDefineID.TypeSpecificID == DefineID.TypeSpecificID
      if returnvalue_7 then
        return LoopBattleData, DefineID.TypeSpecificID
      end
    end
    local tempexecute_1 = false
    local weaponmgr_22 = weaponMgr
    local returnvalue_23 = weaponmgr_22:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
    if slua.isValid(returnvalue_23) then
      local weaponmgr_24 = weaponMgr
      local returnvalue_25 = weaponmgr_24:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
      if slua.isValid(returnvalue_25) then
        local returnvalue_28 = returnvalue_23:GetItemDefineID()
        local returnvalue_29 = returnvalue_25:GetItemDefineID()
        local returnvalue_32 = returnvalue_28.TypeSpecificID ~= returnvalue_29.TypeSpecificID
        if returnvalue_32 then
          tempexecute_1 = true
        else
          local returnvalue_34 = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
          if slua.isValid(returnvalue_34) then
            returnvalue_34:LogWeaponsDataInWeaponManagerAndBackpack()
          end
        end
      else
        tempexecute_1 = true
      end
    else
      tempexecute_1 = true
    end
    if tempexecute_1 then
      local returnvalue_52 = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
      if slua.isValid(returnvalue_52) then
        returnvalue_52:LogWeaponsDataInWeaponManagerAndBackpack()
      end
      local curweaponlist_37 = CurWeaponList
      for i_38, arrayelement_38 in pairs(curweaponlist_37) do
        LoopBattleData = arrayelement_38
        local output_get_41 = LoopBattleData
        local typespecificid_47 = output_get_41.DefineID.TypeSpecificID
        local returnvalue_46 = SlotWeaponDefineID.TypeSpecificID == typespecificid_47
        if returnvalue_46 then
          return LoopBattleData, typespecificid_47
        end
      end
    end
  end
  return FBattleItemData(), 0
end
function BackPackPanelUI:UpdateWeaponBySlot(slot_, ChangeType)
  if not self.WeaponInfoItem_Weapon1 or not self.WeaponInfoItem_Weapon2 then
    return
  end
  if self.UIRoot:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed then
    local GameplayStatics = import("GameplayStatics")
    local ExecuteTime = GameplayStatics.GetTimeSeconds(self.UIRoot)
    local LoopWeaponSlotEnum = slot_
    local returnvalue_15 = self.UIRoot:GetOwningPlayer()
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local returnvalue_14 = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(returnvalue_15)
    if slua.isValid(returnvalue_14) then
      local BackpackUtils = import("BackpackUtils")
      local returnvalue_16 = BackpackUtils.GetWeaponsInBackpack(returnvalue_14)
      local CurWeaponList = returnvalue_16
      self.WeaponInfoItem_Weapon1:UpdateUsingSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
      self.WeaponInfoItem_Weapon2:UpdateUsingSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
      self.PistolInfoItem_BP:UpdateUsingSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
      local EBackPackDragOrigin = UEnums.EBackPackDragOrigin
      if LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
        local battledata_1, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, CurWeaponList)
        self.WeaponInfoItem_Weapon1:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_1, EBackPackDragOrigin.FromWeapon1)
      elseif LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
        local battledata_2, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, CurWeaponList)
        self.WeaponInfoItem_Weapon2:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_2, EBackPackDragOrigin.FromWeapon2)
      elseif LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
        local battledata_3, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, CurWeaponList)
        self.PistolInfoItem_BP:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_3, EBackPackDragOrigin.FromList)
      elseif LoopWeaponSlotEnum == ESurviveWeaponPropSlot.SWPS_MeleeWeapon then
        local battledata_4, TypeSpecificID = self:GetWeaponDataBySlot(LoopWeaponSlotEnum, CurWeaponList)
        self.MeleeInfoItem_BP:UpdateWeaponAppearanceInfo(TypeSpecificID, battledata_4)
      end
    end
    local returnvalue_41 = tostring(GameplayStatics.GetTimeSeconds(self.UIRoot) - ExecuteTime)
    print(bWriteLog and "BackPack Update Weapon Info Time in Seconds: " .. returnvalue_41)
  end
end
function BackPackPanelUI:ResetAttachSlots()
  for i_2, arrayelement_2 in pairs(self.WeaponInfoItemArray) do
    arrayelement_2:ResetHighLightAttachSlot()
  end
  self.PistolInfoItem_BP:ResetHighLightAttachSlot()
  if slua.isValid(self.DragDropWidgetWeaponDetail) then
    local return_8 = self.DragDropWidgetWeaponDetail:ResertHighLightAttachSlot()
  end
  for i_10, arrayelement_10 in pairs(self.ArmorEquipInfoItemArray) do
    local breturn_11 = slua.isValid(arrayelement_10) and arrayelement_10:ResertHighLightAttachSlot()
  end
end
function BackPackPanelUI:ResetUpgradeWeapon()
  self.WeaponInfoItem_Weapon1:ResetUpgradeWeapon()
  self.WeaponInfoItem_Weapon2:ResetUpgradeWeapon()
end
function BackPackPanelUI:SwapWeapon(slot1, slot2)
  local STExtraUIUtils = import("STExtraUIUtils")
  local returnvalue_2 = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(returnvalue_2) then
    local AkGameplayStatics = import("AkGameplayStatics")
    local BusinessHelper = import("BusinessHelper")
    local returnvalue_1 = AkGameplayStatics.PostEvent(BusinessHelper.LoadAssetFromPath("/Game/WwiseEvent/WeaponPublic/Play_Weapon_Equip_Rifle.Play_Weapon_Equip_Rifle"), returnvalue_2, false, "")
  end
end
function BackPackPanelUI:HandleWeaponChange(Slot)
  local STExtraUIUtils = import("STExtraUIUtils")
  local returnvalue_1 = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if slua.isValid(returnvalue_1) then
    local returnvalue_4 = returnvalue_1:GetWeaponManager()
    if slua.isValid(returnvalue_4) then
      local WeaponManager = returnvalue_4
      local STExtraShootWeapon = import("STExtraShootWeapon")
      if Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
        local returnvalue_9 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
        if Game:IsClassOf(returnvalue_9, STExtraShootWeapon) then
          self.CurUsingShootWeapon = returnvalue_9
          self:AddControlEventByControl(self.CurUsingShootWeapon, "OnWeaponReloadStartDelegate", self.StartReloadAnim, self)
          self:AddControlEventByControl(self.CurUsingShootWeapon, "OnWeaponReloadEndDelegage", self.HandleReloadFinish, self)
        end
      elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
        local returnvalue_9 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
        if Game:IsClassOf(returnvalue_9, STExtraShootWeapon) then
          self.CurUsingShootWeapon = returnvalue_9
          self:AddControlEventByControl(self.CurUsingShootWeapon, "OnWeaponReloadStartDelegate", self.StartReloadAnim, self)
          self:AddControlEventByControl(self.CurUsingShootWeapon, "OnWeaponReloadEndDelegage", self.HandleReloadFinish, self)
        end
      elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
        local returnvalue_9 = WeaponManager:GetInventoryWeaponByPropSlot(ESurviveWeaponPropSlot.SWPS_SubShootWeapon)
        if Game:IsClassOf(returnvalue_9, STExtraShootWeapon) then
          self.CurUsingShootWeapon = returnvalue_9
          self:AddControlEventByControl(self.CurUsingShootWeapon, "OnWeaponReloadStartDelegate", self.StartReloadAnim, self)
          self:AddControlEventByControl(self.CurUsingShootWeapon, "OnWeaponReloadEndDelegage", self.HandleReloadFinish, self)
        end
      end
    end
  end
end
function BackPackPanelUI:StartReloadAnim()
  if not slua.isValid(self.CurUsingShootWeapon) then
    return
  end
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  if not STExtraModLogicSwitchLibrary.IsActiveBulletDegreeSwitch(self.CurUsingShootWeapon:GetWeaponID()) then
    return
  end
  self.CurUsingShootWeapon:GetCurReloadMethod()
  local Time = self.CurUsingShootWeapon:GetCurReloadTime()
  if 0.0 < Time then
    self.WeaponInfoItem_Weapon1:StartReloadBullet(Time)
    self.WeaponInfoItem_Weapon2:StartReloadBullet(Time)
    self.PistolInfoItem_BP:StartReloadBullet(Time)
  end
end
function BackPackPanelUI:HandleReloadFinish()
  self.WeaponInfoItem_Weapon1:HandleReloadFinish()
  self.WeaponInfoItem_Weapon2:HandleReloadFinish()
  self.PistolInfoItem_BP:HandleReloadFinish()
end