local CardCollectionDriftModule = {}
local CardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
local CardCollectionUtil = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionUtil")
local CardCollectionUIConfig = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionSeasonUIConfig")
local logic_card_collection_cache = require("GameLua.Mod.Lobby.Split.CardCollection.logic.logic_card_collection_cache")
local popupType = CardCollectionUIConfig.ECardCollectionPopupType
local QUERY_DRIFT_BOTTLE_INTERVAL = 7200
function CardCollectionDriftModule:DefineAndResetData()
  self.GM_DirectShowGetDriftBottle = nil
end
function CardCollectionDriftModule:_GetDataModule()
  return ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionDataModule)
end
function CardCollectionDriftModule:OnInitialize()
end
function CardCollectionDriftModule:RegistEvents()
end
function CardCollectionDriftModule:OnLogin(bReLogin)
end
function CardCollectionDriftModule:OnLogOut()
end
function CardCollectionDriftModule:OnPreSwitchGameStatus(preState, nextState)
end
function CardCollectionDriftModule:OnPostSwitchGameStatus(preState, nextState)
end
function CardCollectionDriftModule:IsTodayCanDrift()
  local dataModule = self:_GetDataModule()
  if dataModule:IsOldVersion() then
    log(bWriteLog and "[CardCollection] CardCollectionDriftModule:IsTodayCanDrift is old version")
    return
  end
  return dataModule:GetIsTodayCanDrift()
end
function CardCollectionDriftModule:IsTodayCanGetDrift()
  if self:_GetDataModule():IsOldVersion() then
    log(bWriteLog and "[CardCollection] CardCollectionDriftModule:IsTodayCanGetDrift is old version")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastReqTime = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionDriftBottleReqTime) or 0
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and string.format("[CardCollection] CardCollectionDriftModule:IsTodayCanGetDrift lastReqTime: %d, currentTime: %d", lastReqTime, currentTime))
  return currentTime - lastReqTime >= QUERY_DRIFT_BOTTLE_INTERVAL
end
function CardCollectionDriftModule:QueryGetDriftBottle()
  if self:_GetDataModule():IsOldVersion() then
    log(bWriteLog and "[CardCollection] CardCollectionDriftModule:QueryGetDriftBottle is old version")
    return
  end
  if self:IsTodayCanGetDrift() then
    CardCollectionSeasonHandler.send_card_collect_get_bottle_req()
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local TimeUtil = require("client.common.time_util")
    PlayerPrefsSystem.SaveTableToFile_N(TimeUtil.GetServerTimeInSec(), PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionDriftBottleReqTime)
  end
end
function CardCollectionDriftModule:ShowGetDriftBottle()
  log(bWriteLog and "[CardCollection] CardCollectionDriftModule:ShowGetDriftBottle")
  local driftData = logic_card_collection_cache.LoadDriftBottleData()
  if not driftData or not next(driftData) then
    log(bWriteLog and "[CardCollection] CardCollectionDriftModule:ShowGetDriftBottle not data")
    return
  end
  log_tree(bWriteLog and "[CardCollection] CardCollectionDriftModule:ShowGetDriftBottle driftData", driftData)
  for _, v in ipairs(driftData) do
    CardCollectionUtil.OpenPopup(popupType.GetDrift, {
      awardList = v.awardList,
      senderUid = v.senderUid
    })
  end
  logic_card_collection_cache.ClearDriftBottleData()
end
function CardCollectionDriftModule:on_card_collect_get_bottle_rsp(award_list, send_uid)
  log(bWriteLog and string.format("[CardCollection] CardCollectionDriftModule:on_card_collect_get_bottle_rsp res_id=%s, send_uid=%s", tostring(award_list.res_id), tostring(send_uid)))
  logic_card_collection_cache.SaveDriftBottleData(award_list, send_uid)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_GET_DRIFT_BOTTLE, award_list, send_uid)
  if self.GM_DirectShowGetDriftBottle then
    self:ShowGetDriftBottle()
  end
end
function CardCollectionDriftModule:on_card_collect_send_bottle_rsp(bottle_card_id, send_type, award_list)
  log_tree(bWriteLog and string.format("[CardCollection] CardCollectionDriftModule:on_card_collect_send_bottle_rsp bottle_card_id=%s, send_type=%s, award_list", tostring(bottle_card_id), tostring(send_type)), award_list)
  self:_GetDataModule():SetIsTodayCanDrift(false)
  local cardData = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", bottle_card_id)
  if cardData then
    self:_GetDataModule():DecrementCardCount(cardData.SetID, cardData.CardID)
  end
  local data = {
    card_pack_id = bottle_card_id,
    card_list = award_list,
    card_pack_count = 1,
    extendData = {nickName = ""}
  }
  CardCollectionUtil.OpenPopup(popupType.Removal, data)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEND_BOTTLE_RESULT, bottle_card_id)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CCardCollectionDriftModule = class(CModuleBase, nil, CardCollectionDriftModule)
return CCardCollectionDriftModule