local golden_suit_module = {}
local NHorseSubtype = 987
function golden_suit_module:DefineAndResetData()
  self.exclusiveTb = nil
end
function golden_suit_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, self.OnPutOnSuc, self)
  self:AddCommonEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, self.UpdateWearingGun, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, self.UpdateWearingGunSkin, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_3206_TIME_LIMIT_GOLD_SUIT, self.OnDeleteGoldSuit3206, self)
end
function golden_suit_module:GetSkillID()
  return 1014420
end
local TableUtil = require("common.table_util")
local clothes2Hat2Hat = {
  [1407726] = {
    [1410923] = 1410945
  }
}
function golden_suit_module:GetSpecialHatId(clothesId, hatId)
  return TableUtil.GetTableValue(clothes2Hat2Hat, clothesId, hatId)
end
function golden_suit_module:GetSpecialClothesAndHat()
  local clothesId
  local WearInfo = AvatarData.GetWearInfo()
  for i, v in pairs(WearInfo) do
    local itemCfg = CDataTable.GetTableData("Item", v.ItemID)
    if itemCfg and itemCfg.ItemSubType == 403 then
      clothesId = v.ItemID
      break
    end
  end
  if not clothesId then
    return
  end
  local hatTb = clothes2Hat2Hat[clothesId]
  if not hatTb then
    return
  end
  local hatId
  for i, v in pairs(hatTb) do
    hatId = i
    break
  end
  if not hatId then
    return
  end
  local useHat
  for i, v in pairs(WearInfo) do
    if v.ItemID == hatId then
      useHat = hatTb[hatId]
    end
  end
  return clothesId, hatId, useHat
end
function golden_suit_module:IsGoldenSuit(itemID)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  if AvatarCommon.IsXSuit(itemID) then
    return nil
  end
  local ItemConfig = CDataTable.GetTableData("Item", itemID)
  if ItemConfig and ItemConfig.ItemQuality == 8 and ItemConfig.ItemSubType == 403 then
    return true
  end
end
function golden_suit_module:GetAnotherItemId(itemID)
  if not self:IsGoldenSuit(itemID) then
    return 0
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local level = LogicMultiItemModule:GetMultiItemLevel(itemID)
  if level < 0 then
    return 0
  end
  return LogicMultiItemModule:GetItemID(itemID, 2)
end
function golden_suit_module:VehicleNeedClothes(vehicleId)
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local exclusiveTb = self.exclusiveTb
  if not exclusiveTb then
    self:LoadExclusiveTb()
    exclusiveTb = self.exclusiveTb
  end
  local itemTb = exclusiveTb[vehicleId]
  if not itemTb then
    return 0
  end
  local item1 = next(itemTb)
  local ItemConfig = CDataTable.GetTableData("Item", item1)
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(ItemConfig.itemSubType)
  log_tree("  golden_suit_module:VehicleNeedClothes. wearInfo ", wearInfo)
  log_tree("  golden_suit_module:VehicleNeedClothes. itemTb ", itemTb)
  if wearInfo and itemTb[wearInfo.resID] then
    return 0
  end
  return item1
end
function golden_suit_module:EmoteNeedClothesWithWord(emoteId)
  local cfg = CDataTable.GetTableData("Clothes2EmoteCfg", emoteId)
  if not cfg then
    return
  end
  local ItemID_a = cfg.ItemID_a
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetMainAvatar()
  for _, id in pairs(ItemID_a) do
    if avatar:HasEquiped(id) then
      return
    end
  end
  log_warning(bWriteLog and "  golden_suit_module:EmoteNeedClothesWithWord. cfg.tipsId: " .. tostring(cfg.tipsId))
  return cfg.tipsId
end
function golden_suit_module:EmoteNeedClothesAllWithWord(emoteId)
  local cfg = CDataTable.GetTableData("EmotionLimitCfg", emoteId)
  if not cfg then
    return
  end
  local ItemID_a = cfg.ItemID_a
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetMainAvatar()
  for _, id in pairs(ItemID_a) do
    if not avatar:HasEquiped(id) then
      return cfg.tipsId
    end
  end
  return
end
function golden_suit_module:LoadExclusiveTb()
  local exclusiveTb = {}
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local item2Vehicle = CommerAvatarDataUtil:GetClothes2VehicleCfg()
  for item, Vehicle in pairs(item2Vehicle) do
    local tb = exclusiveTb[Vehicle.VehicleId]
    if not tb then
      tb = {
        [item] = 1
      }
      exclusiveTb[Vehicle.VehicleId] = tb
    else
      tb[item] = 1
    end
  end
  self.end
function golden_suit_module:IsExclusiveVehicle(resId)
  local exclusiveTb = self.exclusiveTb
  if exclusiveTb then
    return exclusiveTb[resId]
  end
  self:LoadExclusiveTb()
  return self.exclusiveTb[resId]
end
function golden_suit_module:ModifyVehicleWhenPutOn(resId, hasVehicle)
  local cfg = CDataTable.GetTableData("Clothes2VehicleCfg", resId)
  if not cfg then
    local itemCfg = CDataTable.GetTableData("Item", resId)
    if itemCfg and itemCfg.ItemSubType == BP_ENUM_AVATAR_CLOTH then
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      local me = TeamAvatarManager.GetMainAvatar()
      if me then
        local LobbyAvatar = me:GetModel()
        if LobbyAvatar then
          local CharacterAvatarComp2_BP = LobbyAvatar.CharacterAvatarComp2_BP
          local EAvatarSlotType = import("EAvatarSlotType")
          local clothes = CharacterAvatarComp2_BP:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
          local clothesId = clothes and clothes.ItemID
          cfg = CDataTable.GetTableData("Clothes2VehicleCfg", clothesId)
          if cfg then
            self:ModifyVehicleWhenPutOff({resID = clothesId})
          end
        end
      end
    end
    return
  end
  local VehicleId = cfg.VehicleId
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = WardrobeData:GetHallDepotItemDataByResID(VehicleId)
  if not itemData then
    return
  end
  local insID = itemData.insID
  log_warning(bWriteLog and "  golden_suit_module:ModifyVehicleWhenPutOn. VehicleId: " .. tostring(VehicleId))
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local changeHorse
  if not hasVehicle and HallThemeUtils.GetThemeVehicleItemId() ~= 0 then
    local itemCfg = CDataTable.GetTableData("Item", HallThemeUtils.GetThemeVehicleItemId())
    if itemCfg.itemSubType == NHorseSubtype then
      local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      logic_wardrobe_new:wardrobe_puton_req(insID)
      changeHorse = true
    end
  end
  if not changeHorse then
    local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
    WardrobeNewHandler.send_depot_modify_combat_vehicle_req(tonumber(insID), 1, true)
  end
end
function golden_suit_module:ModifyVehicleWhenPutOff(itemData)
  local resId = itemData.resID or itemData.res_id
  log_warning(bWriteLog and "  golden_suit_module:ModifyVehicleWhenPutOff. resId: " .. tostring(resId))
  local cfg = CDataTable.GetTableData("Clothes2VehicleCfg", resId)
  if not cfg then
    log_warning(bWriteLog and "  golden_suit_module:ModifyVehicleWhenPutOff. : not cfg")
    return
  end
  local VehicleId = cfg.VehicleId
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  itemData = WardrobeData:GetHallDepotItemDataByResID(VehicleId)
  if not itemData then
    log_warning(bWriteLog and "  golden_suit_module:ModifyVehicleWhenPutOff.  no itemData")
    return
  end
  local insID = tonumber(itemData.insID)
  local itemCfg = CDataTable.GetTableData("Item", VehicleId)
  local curTypeList = DataMgr.VehicleSlotList[itemCfg.itemSubType]
  log_warning(bWriteLog and "  golden_suit_module:ModifyVehicleWhenPutOff. insID: " .. tostring(insID))
  log_tree("  golden_suit_module:ModifyVehicleWhenPutOff. curTypeList", curTypeList)
  local index
  if curTypeList then
    for i, v in ipairs(curTypeList) do
      if v == insID then
        index = i
      end
    end
  end
  if index then
    local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
    WardrobeNewHandler.send_depot_modify_combat_vehicle_req(tonumber(insID), index, false)
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local defaultClothID = multi_state_manager:GetDefaultClothID(VehicleId)
    log_warning(bWriteLog and "  golden_suit_module:ModifyVehicleWhenPutOff. toId: " .. tostring(defaultClothID))
    if defaultClothID and HallThemeUtils.GetThemeVehicleItemId() == VehicleId then
      itemData = WardrobeData:GetHallDepotItemDataByResID(defaultClothID)
      if itemData then
        log_tree("  golden_suit_module:ModifyVehicleWhenPutOff. itemData ", itemData)
        local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        logic_wardrobe_new:wardrobe_puton_req(itemData.insID)
      end
    end
  end
end
function golden_suit_module:ChangeGoldenWhenPlay(animBP)
  local lobbyPawn = animBP:GetOwningActor()
  if not slua.isValid(lobbyPawn) then
    log(bWriteLog and "golden_suit_module:ChangeForm animBP is invalid")
    return
  end
  local uAvatarComp2 = lobbyPawn.CharacterAvatarComp2_BP
  if not slua.isValid(uAvatarComp2) then
    log(bWriteLog and "golden_suit_module:ChangeGoldenWhenPlay uAvatarComp2 is invalid")
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local oldItemId = AvatarItem.TypeSpecificID
  log(bWriteLog and "golden_suit_module.ChangeGoldenWhenPlay oldItemId = " .. tostring(oldItemId))
  local afterItemId
  local tAllActionCfg = CDataTable.GetTableByFilter("StateChangeActionConfig", "BeforeClothID", oldItemId)
  if tAllActionCfg then
    for _, tCurActionCfg in pairs(tAllActionCfg) do
      afterItemId = tCurActionCfg.AfterClothID
      break
    end
  end
  log(bWriteLog and "  golden_suit_module:ChangeGoldenWhenPlay. afterItemId: " .. tostring(afterItemId))
  if afterItemId and afterItemId ~= 0 then
    lobbyPawn:PutOnEquipmentByResID(afterItemId)
  end
end
function golden_suit_module:OnPutOnSuc(_, _, item)
  log_tree("  golden_suit_module:OnPutOnSuc. item ", item)
  if item then
    self:SendTLogSpecialIdleIfNeed(item.res_id)
  end
end
local NeedTLog = function(id)
  local featureItem = CDataTable.GetTableData("FeaturesItems", id)
  if featureItem and featureItem.NeedTlog == 1 then
    return true
  end
end
function golden_suit_module:UpdateWearingGun(_, _, id)
  if not id then
    return
  end
  log(bWriteLog and "  golden_suit_module:UpdateWearingGun. id: " .. tostring(id))
  self:SendTLogSpecialIdleIfNeed(id)
end
local gun2GunSkin = {
  [101102] = 1101102034
}
function golden_suit_module:UpdateWearingGunSkin(_, _, _, id)
  log(bWriteLog and "  golden_suit_module:UpdateWearingGunSkin. id: " .. tostring(id))
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local weaponSkinIns = HallThemeUtils.GetCurWeaponInstId()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(weaponSkinIns)
  log(bWriteLog and "  golden_suit_module:UpdateWearingGunSkin. weaponSkinIns: " .. tostring(weaponSkinIns))
  local res = weaponSkinData and weaponSkinData.resID
  local skin = id and gun2GunSkin[id]
  if skin then
    local ItemCfg = CDataTable.GetTableByFilter("ItemUpgradeConfig", "FavourateItemID", skin)
    if ItemCfg then
      for i, v in pairs(ItemCfg) do
        if res == v.ItemID then
          log(bWriteLog and "  golden_suit_module:UpdateWearingGunSkin. v: " .. tostring(v.ItemID))
          self:SendTLogSpecialIdleIfNeed(skin)
          break
        end
      end
    end
  elseif id == 0 then
    self:SendTLogSpecialIdleIfNeed(1101102034)
  end
end
function golden_suit_module:SendTLogWhenEnterGame()
  local WearInfo = AvatarData.GetWearInfo()
  for _, v in pairs(WearInfo) do
    local itemID = v.ItemID
    local featureItem = CDataTable.GetTableData("FeaturesItems", itemID)
    if featureItem and featureItem.NeedTlog == 1 then
      log(bWriteLog and "  golden_suit_module:SendTLogWhenEnterGame. itemID: " .. tostring(itemID))
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.TarotCard_Suit2_Game, itemID)
      break
    end
  end
end
function golden_suit_module:SendTLogSpecialIdleIfNeed(resID)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local list = LobbyIdleUnlock:GetSpecialIdleDataList(resID)
  local WearInfo = AvatarData.GetWearInfo()
  local FindOneId = function(id)
    for _, v in pairs(WearInfo) do
      local oneId = v.ItemID
      if oneId == id then
        return true
      end
    end
    return false
  end
  local itemsTemp = {}
  for i, v in pairs(list) do
    itemsTemp[#itemsTemp + 1] = v.MatchItemID
  end
  itemsTemp[#itemsTemp + 1] = resID
  log_tree("  golden_suit_module:SendTLogSpecialIdleIfNeed. HeaderList ", itemsTemp)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local items = {}
  for _, _resId in pairs(itemsTemp) do
    local list = LogicMultiItemModule:GetMultiListByItemID(_resId)
    for _, v in pairs(list) do
      items[v.ItemID] = 1
    end
  end
  local hasNum = 0
  local nTLog
  for id, _ in pairs(items) do
    if FindOneId(id) then
      hasNum = hasNum + 1
      if not nTLog and NeedTLog(id) then
        nTLog = true
      end
    end
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local weaponSkinIns = HallThemeUtils.GetCurWeaponInstId()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(weaponSkinIns)
  log(bWriteLog and "  golden_suit_module:SendTLogSpecialIdleIfNeed. weaponSkinIns: " .. tostring(weaponSkinIns))
  local res = weaponSkinData and weaponSkinData.resID
  local WardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local GunID = WardrobeGunLogic:GetGunID()
  local skin = gun2GunSkin[GunID]
  if skin then
    local ItemCfg = CDataTable.GetTableByFilter("ItemUpgradeConfig", "FavourateItemID", skin)
    if ItemCfg then
      for i, v in pairs(ItemCfg) do
        if res == v.ItemID then
          log(bWriteLog and "  golden_suit_module:SendTLogSpecialIdleIfNeed.  has gun skin")
          hasNum = hasNum + 1
          break
        end
      end
    end
  end
  log(bWriteLog and "  golden_suit_module:SendTLogSpecialIdleIfNeed. GunID: " .. tostring(GunID))
  log(bWriteLog and "  golden_suit_module:SendTLogSpecialIdleIfNeed. hasNum: " .. tostring(hasNum))
  local SpecialPoseType
  if 3 <= hasNum then
    SpecialPoseType = 5
  elseif 2 <= hasNum and GunID == 0 then
    SpecialPoseType = 4
  end
  log(bWriteLog and "  golden_suit_module:SendTLogSpecialIdleIfNeed. SpecialPoseType: " .. tostring(SpecialPoseType))
  local UIUtil = require("client.common.ui_util")
  if SpecialPoseType then
    if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.golden_suit_upgrade, false) then
      return
    end
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.TarotCard_Suit2_SpecialIdle, resID, SpecialPoseType, true)
    return true
  end
end
function golden_suit_module:OnDeleteGoldSuit3206(_, __, changeList)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  for i, v in ipairs(changeList) do
    local itemCfg = CDataTable.GetTableData("Item", v.res_id)
    local content = LocUtil.LocalizeResFormat(20051045, itemCfg.ItemName)
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(5077), content)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cgolden_suit_module = class(CModuleBase, nil, golden_suit_module)
return Cgolden_suit_module