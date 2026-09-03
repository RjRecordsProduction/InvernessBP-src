local LobbyIdleUnlock = {
  E_CollectType = {E_Type_ChangeHead = 1, E_Type_SpecialIdle = 2},
  bSwitch = false,
  E_SearchItemType = {
    E_Type_Clothes = 1,
    E_Type_Weapon = 2,
    E_Type_Dependence = 3
  }
}
function LobbyIdleUnlock:OnInitialize()
  LobbyIdleUnlock.__super.OnInitialize(self)
end
function LobbyIdleUnlock:OnLogOut()
end
function LobbyIdleUnlock:SetUnlockSwitch(bSwitch, bPostEvent)
  self.bSwitch = bSwitch or false
  if bPostEvent then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_COLLECT_UNLOCK_STATE_REFRESH, self.E_CollectType.E_Type_SpecialIdle)
  end
end
function LobbyIdleUnlock:GetSpecialIdleSwitch()
  return self.bSwitch
end
function LobbyIdleUnlock:SelectFromMultiUnlockCfgByClothes(MultiClothesArray)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local gender = AvatarData.GetGameGender() - 1
  table.sort(MultiClothesArray, function(a, b)
    local ClothesA = a.ID
    local ClothesB = b.ID
    local CurAvatar = ModelDisplayer:GetShowingAvatar() or TeamAvatarManager:GetMainAvatar()
    if CurAvatar and slua.isValid(CurAvatar:GetModel()) then
      gender = CurAvatar:GetSex() - 1
      if self:IsAvatarWearingClothes(CurAvatar, ClothesA) then
        return true
      elseif self:IsAvatarWearingClothes(CurAvatar, ClothesB) then
        return false
      end
    end
    local bHasClothesA = self:IsDepotContainsClothes(ClothesA)
    local bHasClothesB = self:IsDepotContainsClothes(ClothesB)
    if bHasClothesA and not bHasClothesB then
      return true
    elseif not bHasClothesA and bHasClothesB then
      return false
    end
    local ClothesGenderA = CDataTable.GetTableData("FixGenderAvatarTable", ClothesA)
    local ClothesGenderB = CDataTable.GetTableData("FixGenderAvatarTable", ClothesB)
    local bGenderMatchA = ClothesGenderA and ClothesGenderA.Gender == gender
    local bGenderMatchB = ClothesGenderB and ClothesGenderB.Gender == gender
    if bGenderMatchA and not bGenderMatchB then
      return true
    end
    if not bGenderMatchA and bGenderMatchB then
      return false
    end
    return ClothesA < ClothesB
  end)
  return MultiClothesArray[1]
end
function LobbyIdleUnlock:IsAvatarWearingClothes(CurAvatar, ClothesID)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local EquipmentInfoList = CurAvatar:GetModel():GetCurAllEquipmentsInfo()
  local bIsXSuit = AvatarCommon.IsXSuit(ClothesID)
  local Period = XSuitUtil:GetPeriodByItemId(ClothesID)
  local branchId = XSuitUtil:GetBranchIdByItemId(ClothesID)
  local UpgradeInfo = XSuitUtil:GetUpgradeInfoByPeriodAndBranchId(Period, branchId)
  for _, EquipmentInfo in pairs(EquipmentInfoList) do
    if bIsXSuit and UpgradeInfo then
      for _, ItemInfo in pairs(UpgradeInfo) do
        if ItemInfo and ItemInfo.item_id == EquipmentInfo.ItemID then
          return true
        end
        if ItemInfo and ItemInfo.second_item_id == EquipmentInfo.ItemID then
          return true
        end
      end
    elseif EquipmentInfo.ItemID == ClothesID then
      return true
    end
  end
  return false
end
function LobbyIdleUnlock:HasEquippedWeapon(WeaponID)
  local CurrentWeaponId = DataMgr.GetCurrentWeaponID()
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local weaponCfg = ItemUpgradeMgr:GetUpgradeCfg(WeaponID)
  if weaponCfg then
    local baseWeaponID = weaponCfg.FavourateItemID
    local weaponCfgList = CDataTable.GetTableByFilter("ItemUpgradeConfig", "FavourateItemID", baseWeaponID)
    if weaponCfgList then
      for _, weaponCfg in pairs(weaponCfgList) do
        if weaponCfg and weaponCfg.ItemID == CurrentWeaponId then
          return true
        end
      end
    end
  end
  return false
end
function LobbyIdleUnlock:IsDepotContainsWeapon(WeaponID)
  return self:GetWeaponDepotData(WeaponID)
end
function LobbyIdleUnlock:GetWeaponDepotData(WeaponID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(WeaponID)
  if not DepotData then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local weaponCfg = ItemUpgradeMgr:GetUpgradeCfg(WeaponID)
    if weaponCfg then
      local baseWeaponID = weaponCfg.FavourateItemID
      local weaponCfgList = CDataTable.GetTableByFilter("ItemUpgradeConfig", "FavourateItemID", baseWeaponID)
      if weaponCfgList then
        for _, weaponCfg in pairs(weaponCfgList) do
          if weaponCfg and weaponCfg.ItemID then
            DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(weaponCfg.ItemID)
            if DepotData then
              return DepotData
            end
          end
        end
      end
    end
  end
  return DepotData
end
function LobbyIdleUnlock:IsDepotContainsClothes(ClothesID)
  return self:GetClothesDepotData(ClothesID)
end
function LobbyIdleUnlock:GetClothesDepotData(ClothesID)
  local DepotDataList = {}
  local bNeedSearch = true
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local MultiStateCfg = CDataTable.GetTableData("ClothingStateConfig", ClothesID)
  if MultiStateCfg and MultiStateCfg.OriginClothID then
    bNeedSearch = false
    local tAllShapeCfg = CDataTable.GetTableByFilter("ClothingStateConfig", "OriginClothID", MultiStateCfg.OriginClothID)
    if tAllShapeCfg then
      for _, v in pairs(tAllShapeCfg) do
        local DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.NewClothID)
        if DepotData then
          table.insert(DepotDataList, DepotData)
        end
      end
    end
    ClothesID = MultiStateCfg.OriginClothID
  end
  if #DepotDataList <= 0 then
    local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
    local bIsXSuit = AvatarCommon.IsXSuit(ClothesID)
    local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
    local Period = XSuitUtil:GetPeriodByItemId(ClothesID)
    local branchId = XSuitUtil:GetBranchIdByItemId(ClothesID)
    local UpgradeInfo = XSuitUtil:GetUpgradeInfoByPeriodAndBranchId(Period, branchId)
    if bIsXSuit and UpgradeInfo then
      bNeedSearch = false
      for _, ItemInfo in pairs(UpgradeInfo) do
        if ItemInfo and ItemInfo.item_id then
          local DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ItemInfo.item_id)
          if DepotData then
            table.insert(DepotDataList, DepotData)
          end
        end
        if ItemInfo and ItemInfo.second_item_id then
          local DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ItemInfo.second_item_id)
          if DepotData then
            table.insert(DepotDataList, DepotData)
          end
        end
      end
    end
  end
  if bNeedSearch then
    return wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ClothesID)
  end
  if 0 < #DepotDataList then
    local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
    table.sort(DepotDataList, function(a, b)
      return LogicMultiItemModule:IsLastSelectMultiLevel(a.resID)
    end)
    return DepotDataList[1]
  end
  return nil
end
function LobbyIdleUnlock:GetDependenceItemDepotData(ItemID)
  local DepotDataList = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local bIsMultiLevelItem = LogicMultiItemModule:IsMultiLevelItem(ItemID)
  local ItemCfgList = LogicMultiItemModule:GetMultiListByItemID(ItemID)
  if bIsMultiLevelItem and ItemCfgList then
    for _, v in pairs(ItemCfgList) do
      if v and v.ItemID then
        local DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.ItemID)
        if DepotData then
          table.insert(DepotDataList, DepotData)
        end
      end
    end
  else
    local DepotData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ItemID)
    if DepotData then
      return DepotData
    end
  end
  if 0 < #DepotDataList then
    table.sort(DepotDataList, function(a, b)
      return LogicMultiItemModule:IsLastSelectMultiLevel(a.resID)
    end)
    return DepotDataList[1]
  end
  return nil
end
function LobbyIdleUnlock:IsNeedShowSpecialIdleIcon(ItemID)
  local ESpecialIdleType = import("ESpecialIdleType")
  local cfg = LobbyIdleUnlock:GetCollectUnlockCfg(ItemID, ESpecialIdleType.EIdleType_ClothesWeapon)
  if cfg then
    return true
  end
  local cfg = LobbyIdleUnlock:GetCollectUnlockCfg(ItemID, ESpecialIdleType.EIdleType_Clothes)
  if cfg and cfg.bHideIconInWardrobe ~= 1 then
    return true
  end
  return false
end
function LobbyIdleUnlock:NeedShowUnlockPrompt()
  return not self:GetSpecialIdleSwitch()
end
function LobbyIdleUnlock:GetSpecialIdleDataList(ItemID)
  local DataList = {}
  if not ItemID or ItemID <= 0 then
    return DataList
  end
  local ESpecialIdleType = import("ESpecialIdleType")
  local cfg = self:GetCollectUnlockCfg(ItemID, ESpecialIdleType.EIdleType_ClothesWeapon)
  if cfg then
    local SearchItemType = self:GetSearchItemType(ItemID)
    if SearchItemType ~= LobbyIdleUnlock.E_SearchItemType.E_Type_Clothes and 0 < cfg.ID then
      local DepotMatchItemID = cfg.ID
      local DepotData = self:GetClothesDepotData(DepotMatchItemID)
      if DepotData and DepotData.resID then
        DepotMatchItemID = DepotData.resID
      end
      table.insert(DataList, {OriginSuitID = DepotMatchItemID, MatchItemID = DepotMatchItemID})
    end
    if SearchItemType ~= LobbyIdleUnlock.E_SearchItemType.E_Type_Weapon and 0 < cfg.WeaponID then
      local DepotMatchItemID = cfg.WeaponID
      local DepotData = self:GetWeaponDepotData(DepotMatchItemID)
      if DepotData and DepotData.resID then
        DepotMatchItemID = DepotData.resID
      end
      table.insert(DataList, {OriginSuitID = DepotMatchItemID, MatchItemID = DepotMatchItemID})
    end
    if SearchItemType ~= LobbyIdleUnlock.E_SearchItemType.E_Type_Dependence and 0 < cfg.DependenceID then
      local DepotMatchItemID = cfg.DependenceID
      local DepotData = self:GetDependenceItemDepotData(DepotMatchItemID)
      if DepotData and DepotData.resID then
        DepotMatchItemID = DepotData.resID
      end
      table.insert(DataList, {OriginSuitID = DepotMatchItemID, MatchItemID = DepotMatchItemID})
    end
  end
  return DataList
end
function LobbyIdleUnlock:GetSpecialIdleDescText(ItemID)
  if not ItemID or ItemID <= 0 then
    return ""
  end
  if self:GetSearchItemType(ItemID) ~= LobbyIdleUnlock.E_SearchItemType.E_Type_Clothes then
    local ESpecialIdleType = import("ESpecialIdleType")
    local cfg = LobbyIdleUnlock:GetCollectUnlockCfg(ItemID, ESpecialIdleType.EIdleType_ClothesWeapon)
    if cfg and cfg.ID then
      local DepotMatchItemID = cfg.ID
      local DepotData = self:GetClothesDepotData(DepotMatchItemID)
      if DepotData and DepotData.resID then
        DepotMatchItemID = DepotData.resID
      end
      ItemID = DepotMatchItemID
    end
  end
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return ""
  end
  return LocUtil.LocalizeResFormat(82116, itemCfg and itemCfg.ItemName or "")
end
function LobbyIdleUnlock:IsSpecialIdleUnlocked(MatchItemID)
  return self:GetSpecialIdleDepotData(MatchItemID)
end
function LobbyIdleUnlock:GetSpecialIdleDepotData(MatchItemID)
  local SearchItemType = self:GetSearchItemType(MatchItemID)
  if SearchItemType == LobbyIdleUnlock.E_SearchItemType.E_Type_Clothes then
    return self:GetClothesDepotData(MatchItemID)
  elseif SearchItemType == LobbyIdleUnlock.E_SearchItemType.E_Type_Weapon then
    return self:GetWeaponDepotData(MatchItemID)
  else
    return self:GetDependenceItemDepotData(MatchItemID)
  end
end
function LobbyIdleUnlock:GetSpecialIcon(MatchItemID)
  local itemCfg = CDataTable.GetTableData("Item", MatchItemID)
  if not itemCfg then
    return ""
  end
  return itemCfg and itemCfg.ItemSmallIcon or ""
end
function LobbyIdleUnlock:OpenUnlockConfirmPanel(ItemID)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local Title = LocUtil.GetLocalizeResStr(101001)
  local ItemCfg = CDataTable.GetTableData("JPCollectUnlock", StoreConst.label_price_type_chip)
  local itemCount = ItemCfg and ItemCfg.count or logic_suit_multi_shape.UNLOCK_COST
  local bMoneyEnough = DataMgr.IsMoneyEnough(StoreConst.label_price_type_chip, itemCount)
  local ContentLocID = bMoneyEnough and 69483 or 69482
  local Content = LocUtil.LocalizeResFormat(ContentLocID, itemCount)
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, Title, Content, function()
    if bMoneyEnough then
      local WardrobeInterActionHandler = require("client.network.Protocol.WardrobeInterActionHandler")
      WardrobeInterActionHandler.send_unlock_lobby_idle_req(ItemID)
    else
      ShowNotice(4457)
    end
  end)
end
function LobbyIdleUnlock:GetSearchItemType(ItemID)
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if ItemCfg then
    local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
    if ModelDisplayTypeHelper.IsClothingSet(ItemCfg.ItemType, ItemCfg.ItemSubType) then
      return LobbyIdleUnlock.E_SearchItemType.E_Type_Clothes
    elseif ModelDisplayTypeHelper.IsWeapon(ItemCfg.ItemType) then
      return LobbyIdleUnlock.E_SearchItemType.E_Type_Weapon
    else
      return LobbyIdleUnlock.E_SearchItemType.E_Type_Dependence
    end
  end
  return LobbyIdleUnlock.E_SearchItemType.E_Type_Clothes
end
function LobbyIdleUnlock:GetCollectUnlockCfg(ItemID, IdleType)
  if not ItemID or not IdleType then
    return nil
  end
  local SearchItemType = self:GetSearchItemType(ItemID)
  if SearchItemType == LobbyIdleUnlock.E_SearchItemType.E_Type_Clothes then
    return self:GetCollectUnlockCfgByClothesID(ItemID, IdleType)
  elseif SearchItemType == LobbyIdleUnlock.E_SearchItemType.E_Type_Weapon then
    return self:GetCollectUnlockCfgByWeaponID(ItemID, IdleType)
  else
    return self:GetCollectUnlockCfgByDependenceID(ItemID, IdleType)
  end
end
function LobbyIdleUnlock:GetClothesBaseID(ItemID)
  local baseClothesID = ItemID
  local MultiStateCfg = CDataTable.GetTableData("ClothingStateConfig", ItemID)
  if MultiStateCfg then
    baseClothesID = MultiStateCfg.OriginClothID
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Period = XSuitUtil:GetPeriodByItemId(ItemID)
  local branchId = XSuitUtil:GetBranchIdByItemId(ItemID)
  local UpgradeInfo = XSuitUtil:GetUpgradeInfoByPeriodAndBranchId(Period, branchId)
  if UpgradeInfo and UpgradeInfo[1] then
    baseClothesID = UpgradeInfo[1].item_id
  end
  return baseClothesID
end
function LobbyIdleUnlock:SelectFromMultiUnlockCfgByWeapon(MultiWeaponArray)
  table.sort(MultiWeaponArray, function(a, b)
    local WeaponA = a.WeaponID
    local WeaponB = b.WeaponID
    if self:HasEquippedWeapon(WeaponA) then
      return true
    elseif self:HasEquippedWeapon(WeaponB) then
      return false
    end
    local bHasClothesA = self:IsDepotContainsWeapon(WeaponA)
    local bHasClothesB = self:IsDepotContainsWeapon(WeaponB)
    if bHasClothesA and not bHasClothesB then
      return true
    elseif not bHasClothesA and bHasClothesB then
      return false
    end
    return WeaponA < WeaponB
  end)
  return MultiWeaponArray[1]
end
function LobbyIdleUnlock:GetCollectUnlockCfgByClothesID(ItemID, IdleType)
  local baseClothesID = self:GetClothesBaseID(ItemID)
  local CfgList = {}
  local CfgTable = CDataTable.GetTableByFilter("IdleCollectNew", "ID", baseClothesID, "IdleType", IdleType)
  for _, cfg in pairs(CfgTable) do
    table.insert(CfgList, cfg)
  end
  local CfgTableLen = #CfgList
  if 0 < CfgTableLen then
    if CfgTableLen == 1 then
      return CfgList[1]
    end
    local ESpecialIdleType = import("ESpecialIdleType")
    if IdleType ~= ESpecialIdleType.EIdleType_ClothesWeapon then
      return CfgList[1]
    end
    return self:SelectFromMultiUnlockCfgByWeapon(CfgList)
  end
  return nil
end
function LobbyIdleUnlock:GetCollectUnlockCfgByWeaponID(ItemID, IdleType)
  local baseWeaponID = ItemID
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local weaponCfg = ItemUpgradeMgr:GetUpgradeCfg(ItemID)
  if weaponCfg then
    baseWeaponID = weaponCfg.FavourateItemID
  end
  local CfgList = {}
  local CfgTable = CDataTable.GetTableByFilter("IdleCollectNew", "WeaponID", baseWeaponID, "IdleType", IdleType)
  for _, cfg in pairs(CfgTable) do
    table.insert(CfgList, cfg)
  end
  local CfgTableLen = #CfgList
  if 0 < CfgTableLen then
    if CfgTableLen == 1 then
      return CfgList[1]
    end
    return self:SelectFromMultiUnlockCfgByClothes(CfgList)
  end
  return nil
end
function LobbyIdleUnlock:GetCollectUnlockCfgByDependenceID(ItemID, IdleType)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local baseItemID = LogicMultiItemModule:GetMultiItemIDByGroupIDAndLevelID(ItemID, 1)
  local CfgList = {}
  local CfgTable = CDataTable.GetTableByFilter("IdleCollectNew", "DependenceID", baseItemID, "IdleType", IdleType)
  for _, cfg in pairs(CfgTable) do
    table.insert(CfgList, cfg)
  end
  local CfgTableLen = #CfgList
  if 0 < CfgTableLen then
    if CfgTableLen == 1 then
      return CfgList[1]
    end
    return self:SelectFromMultiUnlockCfgByClothes(CfgList)
  end
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyIdleUnlock = class(CModuleBase, nil, LobbyIdleUnlock)
return CLobbyIdleUnlock