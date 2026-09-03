local LogicParticleEmote = {}
local _Enum_EmoteCfgLevel = {
  RPExchange = 1,
  AG_FP_Exchange = 2,
  UCExchange = 3
}
function LogicParticleEmote:DefineAndResetData()
  self._nCheckItemId = nil
  self._nEmoteID = nil
  self.EmoteIDLevel2Map = {}
  local ParticleEmoteCfg = CDataTable.GetTable("ParticleEmoteCfg")
  for k, v in pairs(ParticleEmoteCfg) do
    self.EmoteIDLevel2Map[v.EmoteIDLevel2] = v
  end
end
function LogicParticleEmote:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.CheckBuyItemToShop, self)
end
function LogicParticleEmote:IsParticleEmote(EmoteID)
  local ParticleEmoteCfg = CDataTable.GetTableData("ParticleEmoteCfg", EmoteID)
  if ParticleEmoteCfg then
    return true
  end
  return false
end
function LogicParticleEmote:Is2LevelParticleEmote(EmoteID)
  return self.EmoteIDLevel2Map[EmoteID] ~= nil
end
function LogicParticleEmote:GetParticleEmoteCfgBy2LevelItem(EmoteID)
  return self.EmoteIDLevel2Map[EmoteID]
end
function LogicParticleEmote:IsUnLockProp(ItemID)
  local ParticleEmoteCfg = CDataTable.GetTable("ParticleEmoteCfg")
  for _, v in pairs(ParticleEmoteCfg) do
    if v.UpgradeItemID == ItemID then
      return true
    end
  end
end
function LogicParticleEmote:GetEmoteListByUnLockProp(ItemID)
  local EmoteList = {}
  local ParticleEmoteCfg = CDataTable.GetTable("ParticleEmoteCfg")
  for _, v in pairs(ParticleEmoteCfg) do
    if v.UpgradeItemID == ItemID then
      table.insert(EmoteList, v.EmoteID)
    end
  end
  return EmoteList
end
function LogicParticleEmote:GetUserCanUpgradeEmote(ItemID)
  local EmoteList = {}
  local ParticleEmoteCfg = CDataTable.GetTable("ParticleEmoteCfg")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(ParticleEmoteCfg) do
    if v.UpgradeItemID == ItemID then
      local HasUnLock = self:HasUnlockParticle(v.EmoteID)
      local WardrobeEmoteNum = wardrobe_data:GetHallDepotItemCountByResID(v.EmoteID, true)
      if not HasUnLock and 0 < WardrobeEmoteNum then
        table.insert(EmoteList, v.EmoteID)
      end
    end
  end
  return EmoteList
end
function LogicParticleEmote:GetBaseID(ParticleEmoteID)
  local cfg = self.EmoteIDLevel2Map[ParticleEmoteID]
  if cfg then
    return cfg.EmoteID
  end
  return ParticleEmoteID
end
function LogicParticleEmote:GetParticleEmoteID(BaseEmoteID)
  local ParticleEmoteCfg = CDataTable.GetTableData("ParticleEmoteCfg", BaseEmoteID)
  if not ParticleEmoteCfg then
    print(bWriteLog and "[ParticleEmote] LogicParticleEmote ParticleEmoteID Can`t find ParticleEmoteCfg ItemID" .. tostring(BaseEmoteID))
    return BaseEmoteID
  end
  return ParticleEmoteCfg.EmoteIDLevel2
end
function LogicParticleEmote:GetNeedPlayEmoteID(BaseEmoteID)
  local EmoteID = BaseEmoteID
  local CanPlay = true
  if self:IsParticleEmote(BaseEmoteID) and LogicParticleEmote:HasUnlockParticle(BaseEmoteID) and DataMgr.show_effect then
    EmoteID = self:GetParticleEmoteID(BaseEmoteID)
  end
  local CoopEmoteUtil = require("GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteUtil")
  if not CoopEmoteUtil.CanShowInLobby(EmoteID) then
    CanPlay = false
  end
  log(bWriteLog and "[ParticleEmote] GetNeedPlayEmoteID BaseEmoteID:" .. tostring(BaseEmoteID) .. " NeedPlayEmoteID:" .. tostring(EmoteID) .. " CanPlay:" .. tostring(CanPlay))
  return EmoteID, CanPlay
end
function LogicParticleEmote:HasUnlockParticle(BaseEmoteID)
  if DataMgr.motion_effect_level and DataMgr.motion_effect_level[BaseEmoteID] and DataMgr.motion_effect_level[BaseEmoteID] > 0 then
    return true
  end
  return false
end
function LogicParticleEmote:HaveUnLockProp(EmoteID)
  local ParticleEmoteCfg = CDataTable.GetTableData("ParticleEmoteCfg", EmoteID)
  if not ParticleEmoteCfg then
    log(bWriteLog and "bWriteLog and [ParticleEmote] LogicParticleEmote HaveUnLockProp Can`t Find Emote In Table EmoteID:" .. tostring(EmoteID))
    return
  end
  local ItemID = ParticleEmoteCfg.UpgradeItemID
  local NeedNum = ParticleEmoteCfg.UpgradeItemNum
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardrobeNum = wardrobe_data:GetHallDepotItemCountByResID(ItemID, true)
  if NeedNum > WardrobeNum then
    return false
  end
  return true
end
function LogicParticleEmote:GetUnLockPropItemID(EmoteID)
  local ParticleEmoteCfg = CDataTable.GetTableData("ParticleEmoteCfg", EmoteID)
  if not ParticleEmoteCfg then
    log_error("[ParticleEmote] LogicParticleEmote GetUnLockPropItemID Can`t Find Emote In Table EmoteID:" .. tostring(EmoteID))
    return 0
  end
  return ParticleEmoteCfg.UpgradeItemID
end
function LogicParticleEmote:GetUnLockPropItemJumpUrl(nEmoteID, nJumpUrlLevel)
  local nSeasonId = UnknowPassSystem.Season
  if nJumpUrlLevel == _Enum_EmoteCfgLevel.RPExchange and (not nSeasonId or nSeasonId == 0) then
    log_error("[ParticleEmote] Season Id Error >>>> type = " .. type(nSeasonId) .. " >>> data = " .. tostring(nSeasonId))
    return
  end
  local tParticleEmoteCfg = CDataTable.GetTableData("ParticleEmoteCfg", nEmoteID)
  if not tParticleEmoteCfg then
    log_error(bWriteLog and "[ParticleEmote] Configuration table ParticleEmail has no configuration with EmoteID = " .. nEmoteID)
    return
  end
  local sCfgName = "ParticleEmoteJumpCfg"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJK = PublishRegionMacros.IsJapanOrKorea()
  if bIsJK then
    sCfgName = "JKParticleEmoteJumpCfg"
  end
  local nResItemId = tParticleEmoteCfg.UpgradeItemID
  local tJumpCfg = CDataTable.GetTableDataByFilter(sCfgName, "SeasonID", nSeasonId, "ItemId", nResItemId)
  if not tJumpCfg then
    log_error("[ParticleEmote] LogicParticleEmote GetUnLockPropItemID Can`t Find Emote In Table EmoteID: " .. tostring(nEmoteID))
    return
  end
  local sJumpUrl = tJumpCfg.JumpUrl1
  if nJumpUrlLevel == _Enum_EmoteCfgLevel.AG_FP_Exchange then
    sJumpUrl = tJumpCfg.JumpUrl2
  elseif nJumpUrlLevel == _Enum_EmoteCfgLevel.UCExchange then
    sJumpUrl = tJumpCfg.JumpUrl3
  end
  return sJumpUrl
end
function LogicParticleEmote:UsePropItem(ItemID)
  log(bWriteLog and "[ParticleEmote] UsePropItem ItemID:" .. tostring(ItemID))
  local EmoteList = self:GetUserCanUpgradeEmote(ItemID)
  if #EmoteList == 0 then
    ShowNotice(49487)
  elseif #EmoteList == 1 then
    self:send_effect_motion_levelup_req(EmoteList[1])
  else
    for _, v in pairs(EmoteList) do
      if self:HaveUnLockProp(v) then
        UIManager.ShowUI(UIManager.UI_Config.Wardrobe_Expression_Popup_UIBP, EmoteList)
        return
      end
    end
    ShowNotice(49487)
  end
end
function LogicParticleEmote:ShowUnlockPropPanel(EmoteID)
  log(bWriteLog and "[ParticleEmote] ShowUnlockPropPanel:" .. tostring(EmoteID))
  local ParticleEmoteCfg = CDataTable.GetTableData("ParticleEmoteCfg", EmoteID)
  if not ParticleEmoteCfg then
    return
  end
  self.PreUnlockEmote = EmoteID
  UIManager.ShowUI(UIManager.UI_Config.EmoteUpgrade_Popup_UIBP, EmoteID)
end
function LogicParticleEmote:GetPreUnlockEmote()
  return self.PreUnlockEmote
end
function LogicParticleEmote:send_effect_motion_levelup_req(EmoteID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local Data = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(EmoteID)
  log(bWriteLog and "[ParticleEmote] send_effect_motion_levelup_req EmoteID:" .. tostring(EmoteID) .. " Data.insID:" .. tostring(Data.insID))
  if not self:HaveUnLockProp(EmoteID) then
    ShowNotice(13061003)
    return
  end
  if not Data then
    log(bWriteLog and "[ParticleEmote] send_effect_motion_levelup_req Data is nil")
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_effect_motion_levelup_req(EmoteID, Data.insID)
end
function LogicParticleEmote:on_effect_motion_levelup_rsp(EmoteID, Level)
  log(bWriteLog and "[ParticleEmote] on_effect_motion_levelup_rsp EmoteID:" .. tostring(EmoteID) .. " Level:" .. tostring(Level))
  DataMgr.motion_effect_level[EmoteID] = Level
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.UpdateEmoteLevel(tonumber(DataMgr.roleData.uid), EmoteID, Level)
  UIManager.ShowUI(UIManager.UI_Config.ParticleEmoteUpgradePopup, EmoteID)
  EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPGRADE, EmoteID)
end
function LogicParticleEmote:send_effect_motion_setting_req(show_effect)
  log(bWriteLog and "[ParticleEmote] send_effect_motion_setting_req " .. tostring(show_effect))
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_effect_motion_setting_req(show_effect)
end
function LogicParticleEmote:on_effect_motion_setting_rsp(show_effect)
  log(bWriteLog and "[ParticleEmote] on_effect_motion_setting_rsp " .. tostring(show_effect))
  DataMgr.  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.UpdateEmoteShowEffect(tonumber(DataMgr.roleData.uid), show_effect)
  EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_ON_SHOWEFFECT_UPDATE)
end
function LogicParticleEmote:SendCheckBuyItemJumpType(nItemId, nEmoteID)
  self._nCheckItemId = nItemId
  self._  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_check_buy_item_type_req(nItemId)
end
function LogicParticleEmote:CheckBuyItemTypeRsp(bIsRPBuy)
  if bIsRPBuy then
    local sJumpUrl = LogicParticleEmote:GetUnLockPropItemJumpUrl(self._nEmoteID)
    GlobalData.JumpUrl(sJumpUrl)
    self._nCheckItemId = nil
    self._nEmoteID = nil
  else
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      store_supply_manager:GetTabData(StoreConst.store_tab, StoreConst.Page_ID_Item)
    else
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      store_supply_manager:GetTabData(StoreConst.store_tab, StoreConst.Page_New_ID_Treasure)
    end
  end
end
function LogicParticleEmote:CheckBuyItemToShop(_, _, tShopData)
  if not self._nEmoteID then
    return
  end
  local nEmoteId = self._nEmoteID
  self._nEmoteID = nil
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJK = PublishRegionMacros.IsJapanOrKorea()
  local bIsJump = false
  local nFPType = StoreConst.label_price_type_fp
  local nAGType = StoreConst.label_price_type_diamond
  local nCheckCoinType = bIsJK and nFPType or nAGType
  local bIsJumpSpecial = true
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  for nShopId, tTempData in pairs(tShopData.data[StoreConst.label_market_index_market_list]) do
    local nItemId = tTempData[StoreConst.label_item_index_id] or 0
    if nItemId == self._nCheckItemId then
      log_tree("LogicParticleEmote:CheckBuyItemToShop ", tTempData)
      local _, tPriceData = next(tTempData[StoreConst.label_item_index_price_list])
      local bIsAGOrFP = false
      if tPriceData then
        local nPriceType = tPriceData[StoreConst.label_price_index_price_type]
        bIsAGOrFP = nPriceType == nCheckCoinType
      end
      local tLimitRawData = tTempData[StoreConst.label_item_index_buy_limit] or {}
      local tLimitData = StoreUtils.GetBuyLimitData(tLimitRawData, nShopId)
      if tLimitData.isSoldOut then
        if not bIsAGOrFP then
          goto lbl_83
        end
        bIsJumpSpecial = false
        if bIsJump then
          break
        end
      else
        bIsJump = true
        if bIsAGOrFP then
          break
        end
      end
    end
    ::lbl_83::
  end
  if bIsJump then
    local nLevel = _Enum_EmoteCfgLevel.UCExchange
    if bIsJumpSpecial then
      nLevel = _Enum_EmoteCfgLevel.AG_FP_Exchange
    end
    local sJumpUrl = LogicParticleEmote:GetUnLockPropItemJumpUrl(nEmoteId, nLevel)
    self:AddTimerOnce(0, function()
      GlobalData.JumpUrl(sJumpUrl)
    end)
  else
    ShowNotice(64139)
  end
  self._nCheckItemId = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicParticleEmote)
return CModuleTemplate