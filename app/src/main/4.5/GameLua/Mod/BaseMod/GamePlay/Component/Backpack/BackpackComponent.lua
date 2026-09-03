local BackpackComponent = {}
local slua_isValid = slua.isValid
local KismetSystemLibrary = import("KismetSystemLibrary")
local FBattleItemUseTarget = import("/Script/Basic.BattleItemUseTarget")
local SubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
local BackpackUtils = import("/Script/ShadowTrackerExtra.BackpackUtils")
local EBattleItemOperationFailedReason = import("EBattleItemOperationFailedReason")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local LuaBackpackUtils = require("GameLua.Mod.Library.GamePlay.Backpack.LuaBackpackUtils")
local STExtraModLogicSwitchLibrary = import("/Script/ShadowTrackerExtra.STExtraModLogicSwitchLibrary")
local STExtraVehicleUtils = import("/Script/ShadowTrackerExtra.STExtraVehicleUtils")
local BaseAIController = import("/Script/ShadowTrackerExtra.BaseAIController")
local AvatarUtils = import("/Script/ShadowTrackerExtra.AvatarUtils")
local BattleItemHandleBase = import("/Script/Basic.BattleItemHandleBase")
function BackpackComponent:ctor(selfType)
  self.tItemMapEvent = {
    [UEnums.EBackpackItemType.Weapon] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_WEAPON_1,
    [UEnums.EBackpackItemType.WeaponAttachment] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_WEAPONATTACHMENT_2,
    [UEnums.EBackpackItemType.Ammo] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_AMMO_3,
    [UEnums.EBackpackItemType.Clothing] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_CLOTHING_4,
    [UEnums.EBackpackItemType.Armor] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_ARMOR_5,
    [UEnums.EBackpackItemType.Consumable] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_CONSUMABLE_6,
    [UEnums.EBackpackItemType.Chip] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_CHIP_10,
    [UEnums.EBackpackItemType.Emote] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_EMOTE_22,
    [UEnums.EBackpackItemType.Decal] = EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_DECAL_23
  }
  self.CoinsID = 3000324
end
function BackpackComponent:_PostConstruct()
  BackpackComponent.__super._PostConstruct(self)
  print(bWriteLog and "BackpackComponent:_PostConstruct()", self)
  self:AddControlEvent(self.Object, "SingleItemUpdatedDelegate", self.OnSingleItemUpdatedDelegate, self)
  self:AddControlEvent(self.Object, "SingleItemDeleteDelegate", self.OnSingleItemDeleteDelegate, self)
  self:AddControlEvent(self.Object, "ItemListUpdatedDelegate", self.OnItemListUpdatedDelegate, self)
  self:AddControlEvent(self.Object, "CoinsChangedDelegate", self.OnCoinsChangedDelegate, self)
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CUSTOMVIRTUALITEM_DELETE, self.CacheBattleItemMapByItemID, self)
  else
    self:AddControlEvent(self.Object, "AvatarItemUpdatedDelegate", self.OnAvatarItemUpdatedDelegate, self)
  end
end
function BackpackComponent:ReceiveBeginPlay()
  BackpackComponent.__super.ReceiveBeginPlay(self)
  self:SelfBeginPlay()
  if Client then
    self:AddSettingOptionEvent("bDropUnusefulMelee", function(bDropUnusefulMelee)
      self:ServerSetDropMeelWeapon(bDropUnusefulMelee)
    end, true)
  end
  self.bEnableWeaponAttachmentBindToWeapon = STExtraModLogicSwitchLibrary.IsEnableWeaponAttachmentBindToWeapon()
  print(bWriteLog and "BackpackComponent:ReceiveBeginPlay()", self)
end
function BackpackComponent:OnGuideTlogValueChange(_, _, ClientGeneralCounterMap)
  if not Client then
    return
  end
  print(bWriteLog and "BackpackComponent:OnGuideTlogValueChange")
  self.end
function BackpackComponent:ReceiveEndPlay(nEndPlayReason)
  print(bWriteLog and "BackpackComponent:ReceiveEndPlay()", self)
  if Client then
    self.bDropUnusefulMeleeHandle = nil
  end
  BackpackComponent.__super.ReceiveEndPlay(self, nEndPlayReason)
  if self.Super and self.Super.ReceiveEndPlay then
    self.Super:ReceiveEndPlay()
  end
end
function BackpackComponent:OnSingleItemUpdatedDelegate(DefineID)
  print(bWriteLog and string.format("BackpackComponent:OnSingleItemUpdatedDelegate Item:%d-%d", DefineID.Type, DefineID.TypeSpecificID))
  local Event = self.tItemMapEvent[DefineID.Type]
  if Event ~= nil then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, Event, self.Object, DefineID, true)
  end
  if Client then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED, self.Object, DefineID, true)
  end
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if BackpackConfig and BackpackConfig.ItemNewbieGuideMap and BackpackConfig.ItemNewbieGuideMap[DefineID.TypeSpecificID] then
    print(bWriteLog and "BackpackComponent:OnSingleItemUpdatedDelegate EVENTID_BACKPACK_SINGLE_ITEM_ADD_NEWBIE_GUIDE", DefineID.TypeSpecificID, BackpackConfig.ItemNewbieGuideMap[DefineID.TypeSpecificID])
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_ADD_NEWBIE_GUIDE, BackpackConfig.ItemNewbieGuideMap[DefineID.TypeSpecificID])
  end
end
function BackpackComponent:OnSingleItemDeleteDelegate(DefineID)
  print(bWriteLog and string.format("BackpackComponent:OnSingleItemDeleteDelegate Item:%d-%d", DefineID.Type, DefineID.TypeSpecificID))
  local Event = self.tItemMapEvent[DefineID.Type]
  if Event ~= nil then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, Event, self.Object, DefineID, false)
  end
  if Client then
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED, self.Object, DefineID, false)
  end
end
function BackpackComponent:OnItemListUpdatedDelegate()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, self.Object)
  if not Client then
    self.CoinsNum = self:GetItemCountByItemSpecialID(self.CoinsID)
  end
end
function BackpackComponent:GetEmptyChipSlotIdx(ItemData, SupportChipNum)
  return LuaBackpackUtils.GetEmptyChipSlotIdx(ItemData, SupportChipNum)
end
function BackpackComponent:GetChipAssociationType(index)
  return LuaBackpackUtils.GetChipAssociationType(index)
end
function BackpackComponent:GetEquipChipNum(ItemData)
  return LuaBackpackUtils.GetEquipChipNum(ItemData)
end
function BackpackComponent:OnAvatarItemUpdatedDelegate(DefineID, Reason, bIsEquip)
  local uPlayerController = self:GetOwner()
  if not slua.isValid(uPlayerController) or not uPlayerController.AvatarBagFeature then
    return
  end
  uPlayerController.AvatarBagFeature:OnClothingItemUpdate(nil, nil, DefineID, Reason, bIsEquip)
end
function BackpackComponent:OnCoinsChangedDelegate(CoinsNum)
  print(bWriteLog and "BackpackComponent:OnCoinsChangedDelegate ", CoinsNum)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_REFRESH_COINS_NUM, CoinsNum)
end
function BackpackComponent:CacheBattleItemMapByItemID(_, __, ItemID)
  if ItemID and self.CacheBattleItemMap and self.CacheBattleItemMap:Get(ItemID) then
    self.CacheBattleItemMap:Remove(ItemID)
    print(bWriteLog and "BackpackComponent:CacheBattleItemMapByItemID Remove CacheBattleItemMap " .. tostring(ItemID))
  end
end
function BackpackComponent:CantDrop()
  if not Client and CGameState.bMainCityGameMode then
    log(bWriteLog and "BackpackComponent:CantDrop! IsInMainCity")
    return true
  end
  return false
end
function BackpackComponent:SelfBeginPlay()
  if Client or not Client and KismetSystemLibrary.IsStandalone(self) then
    BackpackUtils.InitialItemTable()
    self:AddControlEvent(self, "ItemOperationDelegate", self.ClientPlayerSound, self)
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    self:ModifyAimNotAutoUse(SettingModule:GetOptionValue("AutoEquipAim"))
    self:ModifyAutoPickClipType(SettingModule:GetOptionValue("AutoPickClipType"))
    self:AddSettingOptionEvent("AutoEquipAim", function(Value)
      self:EventAutoEquipAim(Value)
    end)
    self:AddSettingOptionEvent("AutoPickClipType", function(Value)
      self:EventPickClipType(Value)
    end)
  else
    self:AddControlEvent(self, "ItemOperationDelegate", self.ServerPlaySound, self)
  end
  self:AddControlEvent(self, "ItemOperationFailedDelegate", self.OperationFailed, self)
end
function BackpackComponent:EventAutoEquipAim(bAdd)
  self:ModifyAimNotAutoUse(bAdd)
end
function BackpackComponent:EventPickClipType(InAutoPickClipType)
  if self.ModifyAutoPickClipType then
    self:ModifyAutoPickClipType(InAutoPickClipType)
  else
    print(bWriteLog and "BackpackComponent:EventPickClipType - self.ModifyAutoPickClipType is nil")
  end
end
function BackpackComponent:ServerPlaySound(DefineID, OperationType, Reason)
  self:ServerPlaySoundByItemOperation(DefineID, OperationType, Reason)
end
function BackpackComponent:ClientPlayerSound(DefineID, OperationType, Reason)
  local DataInfo = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
  if DataInfo ~= nil and DataInfo.ItemSoundID ~= nil then
    local ItemSoundID = DataInfo.ItemSoundID
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    local PlayerController = GameplayData.GetPlayerController()
    if slua_isValid(PlayerCharacter) and slua_isValid(PlayerController) and not PlayerController:IsInPlane() then
      PlayerController:ClientPlayItemOperationSound(ItemSoundID, OperationType, PlayerCharacter)
    end
  end
end
function BackpackComponent:OperationFailed(DefineID, OperationType, OperationFailedReason)
  print(bWriteLog and string.format("BackpackComponent:OperationFailed DefineID.TypeSpecificID: %s, OperationFailedReason: %s", tostring(DefineID.TypeSpecificID), tostring(OperationFailedReason)))
  local PlayerController = self:GetOwner()
  if not slua_isValid(PlayerController) then
    return
  end
  if OperationFailedReason == EBattleItemOperationFailedReason.PickupFailed_CapacityExceeded then
    if not PlayerController:HasAuthority() and not PlayerController:IsSpectator() then
      PlayerController:DisplayGameTipWithMsgID(30005)
    end
  elseif OperationFailedReason == EBattleItemOperationFailedReason.PickupFailed_ItemCountExceeded then
    if not PlayerController:HasAuthority() then
      local ItemName
      local TypeSpecificID = DefineID.TypeSpecificID
      local DataInfo = CDataTable.GetTableData("Item", TypeSpecificID)
      if DataInfo == nil or DataInfo.ItemName == nil then
        return
      end
      PlayerController:DisplayGameTipWithMsgIDAndString(801086, DataInfo.ItemName, "")
    end
  elseif OperationFailedReason == EBattleItemOperationFailedReason.PickupFailed_PickupLimitExceeded then
    if not PlayerController:HasAuthority() then
      local ItemID, ItemName
      local TypeSpecificID = DefineID.TypeSpecificID
      local DataInfo = CDataTable.GetTableData("Item", TypeSpecificID)
      if DataInfo ~= nil and DataInfo.ItemName ~= nil and DataInfo.ItemID then
        ItemID = DataInfo.ItemID
        ItemName = DataInfo.ItemName
      else
        return
      end
      PlayerController:DisplayGameTipWithMsgIDAndString(27305, ItemName, tostring(BackpackUtils.GetItemPickupMaxLimitCount(self, ItemID)))
    end
  elseif OperationFailedReason == EBattleItemOperationFailedReason.UseFailed_CapacityExceeded then
    if not PlayerController:HasAuthority() then
      PlayerController:DisplayGameTipWithMsgID(30010)
    end
  elseif OperationFailedReason == EBattleItemOperationFailedReason.UseFailed_SafeBagCapacityExceeded then
    if not PlayerController:HasAuthority() then
      PlayerController:DisplayGameTipWithMsgID(48305)
    end
  elseif OperationFailedReason == EBattleItemOperationFailedReason.DisuseFailed_CapacityExceeded then
    if not PlayerController:HasAuthority() then
      PlayerController:DisplayGameTipWithMsgID(30010)
    end
  elseif OperationFailedReason == EBattleItemOperationFailedReason.DisuseFailed_SafeBagCapacityExceeded and not PlayerController:HasAuthority() then
    PlayerController:DisplayGameTipWithMsgID(48305)
  end
end
function BackpackComponent:NewItemHandle(DefineID)
  return BackpackUtils.CreateBattleItemHandleInBackpack(DefineID, self)
end
function BackpackComponent:GetBattleItemFeatureDataByDefineID(DefineID)
  local BattleItemFeatureDataByDefineID = BackpackUtils.GetBattleItemFeatureDataByDefineID(DefineID)
  return BattleItemFeatureDataByDefineID
end
function BackpackComponent:UpdateCapacity()
  print(bWriteLog and "BackpackComponent:UpdateCapacity")
  local PlayerController = self:GetOwner()
  local STExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if Game:IsClassOf(PlayerController, STExtraPlayerController) then
    local Character = STExtraVehicleUtils.GetCharacter(PlayerController)
    if slua_isValid(Character) then
      local AttributeValue = Character:GetAttributeValue("PawnBackpackCapacity")
      return AttributeValue
    end
  elseif Game:IsClassOf(PlayerController, BaseAIController) then
    local Character = PlayerController:K2_GetPawn()
    if slua_isValid(Character) and Character.GetAttributeValue then
      local AttributeValue = Character:GetAttributeValue("PawnBackpackCapacity")
      return AttributeValue
    end
  end
end
function BackpackComponent:CheckSkillPropItemCanBePickup(BackpackComp, DefineID)
  local Item = BackpackUtils.CanSkillPropsItemBePickedUp(BackpackComp, DefineID)
  return Item
end
function BackpackComponent:IsAutoUse(itemID)
  if self.AutoEquipAim or self.bForceAutoEquipAim then
    return true
  else
    local ProposeData = BackpackUtils.GetProposeData()
    local bContains = false
    for _, Item in pairs(ProposeData.MirrorList) do
      if Item == itemID then
        bContains = true
        break
      end
    end
    return not bContains
  end
end
function BackpackComponent:IsEnableWeaponAttachmentBindToWeapon()
  local IsEnableWeaponAttachmentBindToWeapon = STExtraModLogicSwitchLibrary.IsEnableWeaponAttachmentBindToWeapon()
  return IsEnableWeaponAttachmentBindToWeapon
end
function BackpackComponent:GetAvailableEquipChipSlot(ChipResID, bFindEmptySlot)
  print(bWriteLog and string.format("BackpackComponent:GetAvailableEquipChipSlot %s %s", tostring(ChipResID), tostring(bFindEmptySlot)))
  local DefineID
  local CanEquipItemMap = AvatarUtils.GetChipCanEquipItemList(CDataTable.GetTableData("Item", ChipResID).ItemSubType)
  local EuqippedArmorInBackpack = BackpackUtils.GetEuqippedArmorInBackpack(self)
  for _, Armor in pairs(EuqippedArmorInBackpack) do
    DefineID = Armor.DefineID
    local TypeSpecificID = DefineID.TypeSpecificID
    if CanEquipItemMap:Get(TypeSpecificID) then
      local CanEquipChipInfo = AvatarUtils.GetCanEquipChipInfo(TypeSpecificID)
      if bFindEmptySlot then
        local Index = self:GetEmptyChipSlotIdx(Armor, CanEquipChipInfo.SupportChipNum)
        if 0 < Index then
          local ChipAssociationType = self:GetChipAssociationType(Index)
          local BattleItemUseTarget = FBattleItemUseTarget()
          BattleItemUseTarget.Target          BattleItemUseTarget.TargetAssociationType = ChipAssociationType
          BattleItemUseTarget.TargetActor = nil
          return true, BattleItemUseTarget
        end
      else
        local BattleItemUseTarget = FBattleItemUseTarget()
        BattleItemUseTarget.Target        BattleItemUseTarget.TargetAssociationType = 2
        BattleItemUseTarget.TargetActor = nil
        return true, BattleItemUseTarget
      end
    end
  end
  local BattleItemUseTarget = FBattleItemUseTarget()
  if DefineID then
    BattleItemUseTarget.Target  end
  BattleItemUseTarget.TargetAssociationType = 0
  BattleItemUseTarget.TargetActor = nil
  return false, BattleItemUseTarget
end
function BackpackComponent:NewItemDefineID(DefineID)
  local ItemDefineID = BackpackUtils.GenerateItemDefineIDWithRandomInstanceID(DefineID.Type, DefineID.TypeSpecificID)
  return ItemDefineID
end
function BackpackComponent:HasTagSub(itemID, TagName)
  local bHasTagSub = BackpackUtils.HasTagSub(itemID, TagName)
  return bHasTagSub
end
function BackpackComponent:GetItemSubType(ItemID)
  local ItemSubType = BackpackUtils.GetItemSubType(ItemID)
  return ItemSubType
end
function BackpackComponent:IsItemExist(DefineID)
  local BattleItemHandleClass = BackpackUtils.GetBattleItemHandleClass(DefineID)
  if slua_isValid(BattleItemHandleClass) and Game:IsChildOf(BattleItemHandleClass, BattleItemHandleBase) then
    return true
  end
  return false
end
function BackpackComponent:GetItemAttrsFlag(ItemID)
  print(bWriteLog and "BackpackComponent:GetItemAttrsFlag" .. tostring(ItemID))
  return BackpackUtils.GetItemAttrsFlag(ItemID)
end
function BackpackComponent:CheckItemAttrsFlag(ItemID, ItemAttrEnum)
  return BackpackUtils.CheckItemAttrsFlag(ItemID, ItemAttrEnum)
end
function BackpackComponent:CheckLeftLimitCountForItem(ItemID, Count)
  local MaxLimitCount = 0
  MaxLimitCount = BackpackUtils.GetItemPickupMaxLimitCount(self, ItemID)
  if 0 < MaxLimitCount then
    local ItemCount = MaxLimitCount - self:GetItemCountByItemSpecialID(ItemID)
    if 0 <= ItemCount then
      return ItemCount
    end
  end
  return 99999
end
function BackpackComponent:ServerPlaySoundByItemOperation(DefineID, OperationType, Reason)
  local DataInfo = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
  if DataInfo ~= nil and DataInfo.ItemSoundID ~= nil then
    local ItemSoundID = DataInfo.ItemSoundID
    local PlayerController = self:GetOwner()
    if slua_isValid(PlayerController) and PlayerController.GetPlayerCharacterSafety then
      local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
      if slua_isValid(PlayerCharacter) then
        PlayerCharacter:HandlePlayOperateItemSoundOnServer(ItemSoundID, OperationType)
      end
    end
  end
end
function BackpackComponent:GetSafetyBoxCapacity()
  local Capacity = self.SafetyBoxCapacity
  local PlayerController = self:GetOwner()
  if slua_isValid(PlayerController) and PlayerController.GetPlayerCharacterSafety then
    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then
      return
    end
    local AttrModifyComp = PlayerCharacter.AttrModifyComp
    if slua_isValid(AttrModifyComp) then
      Capacity = Capacity + AttrModifyComp:GetAttributeValue("SafetyBoxCapacityAdd")
    end
  end
  return Capacity
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CBackpackComponent = class(CActorBase, nil, BackpackComponent)
return CBackpackComponent