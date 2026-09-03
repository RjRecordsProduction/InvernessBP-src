local logic_legend_weapon = {}
local LegendWeaponHandler = require("client.network.Protocol.LegendWeaponHandler")
local LEGEND_WEAPON_ENABLED = false
local E_LGD_WPN_ERROR = {
  SUCCESS = 0,
  PARAM_ERR = 19270001,
  NO_PERMISSION = 19270002,
  TRIAL_EXPIRED = 19270003,
  TRIAL_NOT_ACTIVATED = 19270004
}
local E_LGD_WPN_PERM = {
  NONE = 0,
  TRIAL_EXPIRED = 1,
  TRIAL_ACTIVATED = 2,
  TRIAL_PENDING = 3,
  PERMANENT = 4
}
function logic_legend_weapon:DefineAndResetData()
  self._nSelectedResId = 0
  self._nSceneLobby = 0
  self._nSceneBattle = 0
  self._tItems = {}
end
function logic_legend_weapon:_UpdateFromServerData(tLgdWpnInfo)
  if not LEGEND_WEAPON_ENABLED then
    log(bWriteLog and "logic_legend_weapon:_UpdateFromServerData disabled by master switch")
    return
  end
  if not tLgdWpnInfo then
    log(bWriteLog and "logic_legend_weapon:_UpdateFromServerData lgd_wpn_info is nil")
    return
  end
  self._nSelectedResId = tonumber(tLgdWpnInfo.selected) or 0
  self._nSceneLobby = tonumber(tLgdWpnInfo.scene_lobby) or 0
  self._nSceneBattle = tonumber(tLgdWpnInfo.scene_battle) or 0
  self._tItems = {}
  if tLgdWpnInfo.items then
    for resid, itemData in pairs(tLgdWpnInfo.items) do
      local nResId = tonumber(resid) or 0
      if 0 < nResId then
        self._tItems[nResId] = {
          expire_ts = tonumber(itemData.expire_ts) or 0
        }
      end
    end
  end
  log(bWriteLog and string.format("logic_legend_weapon:_UpdateFromServerData selected=%s, lobby=%s, battle=%s, itemCount=%d", tostring(self._nSelectedResId), tostring(self._nSceneLobby), tostring(self._nSceneBattle), self:GetItemCount()))
end
function logic_legend_weapon:_GetCfg(nResId)
  if not nResId or nResId == 0 then
    return nil
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local config = BasicDataServerTable:GetCacheData("card_collect_lgb_wpn_cfg")
  return config and config[nResId]
end
function logic_legend_weapon:GetAllCfg()
  if not LEGEND_WEAPON_ENABLED then
    return nil
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  return BasicDataServerTable and BasicDataServerTable:GetCacheData("card_collect_lgb_wpn_cfg")
end
function logic_legend_weapon:_HasPermanentCard(nResId)
  local tCfg = self:_GetCfg(nResId)
  if not tCfg then
    return false
  end
  local nPermanentCardResId = tCfg.permanent_card_resid
  if not nPermanentCardResId or nPermanentCardResId == 0 then
    return false
  end
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  return logic_card_collection_season and logic_card_collection_season:HasCard(nPermanentCardResId) or false
end
function logic_legend_weapon:_HasTrialCard(nResId)
  local tCfg = self:_GetCfg(nResId)
  if not tCfg then
    return false
  end
  local nTrialCardResId = tCfg.trial_card_resid
  if not nTrialCardResId or nTrialCardResId == 0 then
    return false
  end
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  return logic_card_collection_season and logic_card_collection_season:HasCard(nTrialCardResId) or false
end
function logic_legend_weapon:ReqCardStatus()
  if not LEGEND_WEAPON_ENABLED then
    log(bWriteLog and "logic_legend_weapon:ReqCardStatus disabled by master switch")
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.collectCard) then
    log(bWriteLog and "logic_legend_weapon:ReqCardStatus card collection not unlocked, skip")
    return
  end
  local CardCollectionSeasonHandler = require("client.network.Protocol.CardCollectionSeasonHandler")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local config = BasicDataServerTable:GetCacheData("card_collect_lgb_wpn_cfg")
  if not config then
    log(bWriteLog and "logic_legend_weapon:ReqCardStatus config not ready, skip")
    return
  end
  local tResIdList = {}
  local tResIdSet = {}
  for _, cfgItem in pairs(config) do
    local nPerm = cfgItem.permanent_card_resid
    local nTrial = cfgItem.trial_card_resid
    if nPerm and 0 < nPerm and not tResIdSet[nPerm] then
      tResIdSet[nPerm] = true
      tResIdList[#tResIdList + 1] = nPerm
    end
    if nTrial and 0 < nTrial and not tResIdSet[nTrial] then
      tResIdSet[nTrial] = true
      tResIdList[#tResIdList + 1] = nTrial
    end
  end
  if #tResIdList == 0 then
    log(bWriteLog and "logic_legend_weapon:ReqCardStatus no card resids to query")
    return
  end
  log(bWriteLog and string.format("[logic_legend_weapon] ReqCardStatus: querying %d card resids", #tResIdList))
  CardCollectionSeasonHandler.send_card_collect_batch_query_card_req(tResIdList)
end
function logic_legend_weapon:OnCardQueryRsp(nErrCode, tResIdCountMap)
  log(bWriteLog and string.format("[logic_legend_weapon] OnCardQueryRsp: errCode=%s", tostring(nErrCode)))
  if nErrCode ~= 0 then
    return
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_LEGEND_WEAPON_UPDATE)
end
function logic_legend_weapon:GetUsageRight(nResId)
  local bHasPermanentCard = self:_HasPermanentCard(nResId)
  local bHasTrialCard = self:_HasTrialCard(nResId)
  local nPermType = self:GetPermissionType(nResId)
  log(bWriteLog and string.format("logic_legend_weapon:GetUsageRight resid=%s, perm=%s, permanentCard=%s, trialCard=%s", tostring(nResId), tostring(nPermType), tostring(bHasPermanentCard), tostring(bHasTrialCard)))
  return nPermType, bHasPermanentCard, bHasTrialCard
end
function logic_legend_weapon:OnInitialize()
  log(bWriteLog and "logic_legend_weapon:OnInitialize")
end
function logic_legend_weapon:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_CHANGE, self._OnDepotChange, self)
end
function logic_legend_weapon:_ReqLgdWpnCfg()
  if not LEGEND_WEAPON_ENABLED then
    log(bWriteLog and "logic_legend_weapon:_ReqLgdWpnCfg disabled by master switch")
    return
  end
  log(bWriteLog and "logic_legend_weapon:_ReqLgdWpnCfg")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local cache = BasicDataServerTable:GetCacheData("card_collect_lgb_wpn_cfg")
  if not cache then
    BasicDataServerTable:GetOrReqData("card_collect_lgb_wpn_cfg", function(key, info)
      log_tree(bWriteLog and "logic_legend_weapon:_ReqLgdWpnCfg info", info)
    end)
  end
  log_tree(bWriteLog and "logic_legend_weapon:_ReqLgdWpnCfg cache", cache)
end
function logic_legend_weapon:OnLogOut()
  log(bWriteLog and "logic_legend_weapon:OnLogOut")
end
function logic_legend_weapon:OnPreSwitchGameStatus(preState, nextState)
end
function logic_legend_weapon:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
    queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, {
      module = self,
      funcName = "_ReqLgdWpnCfg",
      debugInfo = "logic_legend_weapon:_ReqLgdWpnCfg",
      protect = true
    })
    local tLgdWpnInfo = LobbySystem.roleData and LobbySystem.roleData.lgd_wpn_info
    if tLgdWpnInfo then
      self:_UpdateFromServerData(tLgdWpnInfo)
    else
      log(bWriteLog and "logic_legend_weapon:OnPostSwitchGameStatus lgd_wpn_info not found")
    end
  end
end
function logic_legend_weapon:GetSelectedResId()
  return self._nSelectedResId or 0
end
function logic_legend_weapon:IsSceneLobbyOn()
  return self._nSceneLobby == 1
end
function logic_legend_weapon:SetSceneLobbyOff()
  if self._nSceneLobby ~= 1 then
    return
  end
  self._nSceneLobby = 0
  self:SendSetLgdWpn(nil, 0, self._nSceneBattle or 0)
end
function logic_legend_weapon:IsSceneBattleOn()
  return self._nSceneBattle == 1
end
function logic_legend_weapon:GetItemCount()
  local nCount = 0
  for _ in pairs(self._tItems) do
    nCount = nCount + 1
  end
  return nCount
end
function logic_legend_weapon:GetAllItems()
  return self._tItems
end
function logic_legend_weapon:GetItemData(nResId)
  return self._tItems[nResId]
end
function logic_legend_weapon:GetPermissionType(nResId)
  if not nResId or nResId == 0 then
    return E_LGD_WPN_PERM.NONE
  end
  if self:_HasPermanentCard(nResId) then
    return E_LGD_WPN_PERM.PERMANENT
  end
  local tItemData = self._tItems[nResId]
  if not tItemData then
    if self:_HasTrialCard(nResId) then
      return E_LGD_WPN_PERM.TRIAL_PENDING
    end
    return E_LGD_WPN_PERM.NONE
  end
  local nExpireTs = tItemData.expire_ts or 0
  if nExpireTs == 0 then
    return E_LGD_WPN_PERM.TRIAL_PENDING
  end
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  if nExpireTs > nNow then
    return E_LGD_WPN_PERM.TRIAL_ACTIVATED
  else
    return E_LGD_WPN_PERM.TRIAL_EXPIRED
  end
end
function logic_legend_weapon:IsLgdWpnValid(nResId)
  if not LEGEND_WEAPON_ENABLED then
    return false
  end
  local nPerm = self:GetPermissionType(nResId)
  return nPerm == E_LGD_WPN_PERM.PERMANENT or nPerm == E_LGD_WPN_PERM.TRIAL_ACTIVATED or nPerm == E_LGD_WPN_PERM.TRIAL_PENDING
end
function logic_legend_weapon:IsPermanent(nResId)
  if not LEGEND_WEAPON_ENABLED then
    return false
  end
  return self:GetPermissionType(nResId) == E_LGD_WPN_PERM.PERMANENT
end
function logic_legend_weapon:GetTrialRemainTime(nResId)
  local nPerm = self:GetPermissionType(nResId)
  if nPerm ~= E_LGD_WPN_PERM.TRIAL_ACTIVATED then
    return 0
  end
  local tItemData = self._tItems[nResId]
  if not tItemData then
    return 0
  end
  local TimeUtil = require("client.common.time_util")
  local nRemain = (tItemData.expire_ts or 0) - TimeUtil.GetServerTimeInSec()
  return 0 < nRemain and nRemain or 0
end
function logic_legend_weapon:GetTrialDuration(nResId)
  local tCfg = self:_GetCfg(nResId)
  if not tCfg then
    return 0
  end
  return tonumber(tCfg.trial_duration_sec) or 0
end
function logic_legend_weapon:IsInitialized()
  return self._nSelectedResId ~= nil
end
function logic_legend_weapon:GetWeaponIdByCardId(nCardId)
  if not LEGEND_WEAPON_ENABLED then
    return 0
  end
  if not nCardId or nCardId == 0 then
    return 0
  end
  local tAllCfg = self:GetAllCfg()
  if not tAllCfg then
    return 0
  end
  for nResId, tCfg in pairs(tAllCfg) do
    if tCfg.permanent_card_resid == nCardId or tCfg.trial_card_resid == nCardId then
      return nResId
    end
  end
  return 0
end
function logic_legend_weapon:IsLegendWeaponItem(nItemId)
  if not LEGEND_WEAPON_ENABLED then
    return false
  end
  if not nItemId or nItemId == 0 then
    return false
  end
  return nItemId == 1081205
end
function logic_legend_weapon:_OnDepotChange()
  if self._nSelectedResId > 0 then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_LEGEND_WEAPON_UPDATE)
  end
end
function logic_legend_weapon:SendSetLgdWpn(nLgdWpnResId, nSceneLobby, nSceneBattle)
  if not LEGEND_WEAPON_ENABLED then
    log(bWriteLog and "logic_legend_weapon:SendSetLgdWpn disabled by master switch")
    return
  end
  log(bWriteLog and string.format("logic_legend_weapon:SendSetLgdWpn resid=%s, lobby=%s, battle=%s", tostring(nLgdWpnResId), tostring(nSceneLobby), tostring(nSceneBattle)))
  LegendWeaponHandler.send_set_lgd_wpn(nLgdWpnResId, nSceneLobby, nSceneBattle)
end
function logic_legend_weapon:on_set_lgd_wpn_rsp(tLgdWpnInfo)
  self:_UpdateFromServerData(tLgdWpnInfo)
  if LobbySystem.roleData then
    LobbySystem.roleData.lgd_wpn_info = tLgdWpnInfo
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_LEGEND_WEAPON_UPDATE)
  local nResId = self._nSelectedResId or 0
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  if 0 < nResId and self:IsSceneLobbyOn() then
    local nPerm = self:GetPermissionType(nResId)
    if nPerm == E_LGD_WPN_PERM.TRIAL_ACTIVATED or nPerm == E_LGD_WPN_PERM.PERMANENT then
      logic_wardrobe_gun:SetKeepGunID(nResId)
      logic_wardrobe_gun:SetGunID(nResId)
      logic_wardrobe_gun:PutOnGunAvatar(nResId, nResId)
    end
  elseif 0 < nResId and self:IsLegendWeaponItem(logic_wardrobe_gun:GetPreviewGunResID()) then
    logic_wardrobe_gun:SetGunID(0)
    logic_wardrobe_gun:PutOffGunAvatar()
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, true, nResId)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_legend_weapon = class(CModuleBase, nil, logic_legend_weapon)
return Clogic_legend_weapon