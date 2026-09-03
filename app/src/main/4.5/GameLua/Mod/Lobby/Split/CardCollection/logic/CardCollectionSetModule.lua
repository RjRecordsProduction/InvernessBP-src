local CardCollectionSetModule = {}
local CardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
function CardCollectionSetModule:DefineAndResetData()
end
function CardCollectionSetModule:_GetDataModule()
  return ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionDataModule)
end
function CardCollectionSetModule:OnInitialize()
end
function CardCollectionSetModule:RegistEvents()
end
function CardCollectionSetModule:OnLogin(bReLogin)
end
function CardCollectionSetModule:OnLogOut()
end
function CardCollectionSetModule:OnPreSwitchGameStatus(preState, nextState)
end
function CardCollectionSetModule:OnPostSwitchGameStatus(preState, nextState)
end
function CardCollectionSetModule:GetSetListByVersion(version)
  local dataModule = self:_GetDataModule()
  local regionConfig = dataModule:GetRegionConfig()
  local version_util = require("client.common.version_util")
  local targetVersion = version or version_util.GetClientFormat(Client.GetAppVersion())
  local setConfigTable = CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", regionConfig.Set, "Version", targetVersion)
  local setList = {}
  if setConfigTable then
    for _, setCfg in pairs(setConfigTable) do
      table.insert(setList, setCfg)
    end
  end
  table.sort(setList, function(a, b)
    return a.SetID < b.SetID
  end)
  log(bWriteLog and string.format("[CardCollection] GetSetListByVersion version=%s, count=%d", tostring(targetVersion), #setList))
  return setList
end
function CardCollectionSetModule:GetSetTabDataByVersion(version)
  local dataModule = self:_GetDataModule()
  if not dataModule:_EnsureSeasonData() then
    return
  end
  local seasonData = dataModule:GetSeasonData()
  log_tree("[CardCollection] CardCollectionSetModule:GetSetTabDataByVersion season data", seasonData)
  local setList = self:GetSetListByVersion(version)
  local tabData = {}
  local setIDToIndex = {}
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  for _, setCfg in pairs(setList) do
    local startTime = setCfg.StartTime
    local isOnline = startTime == "" or currentTime >= TimeUtil.TimeStringToUnixstamp(startTime)
    if isOnline then
      local setID = setCfg.SetID
      local setData = seasonData[setID] or {}
      table.insert(tabData, {
        text = setCfg.Name,
        setID = setID,
        ownNum = setData.count or 0,
        totalNum = self:GetTotalCardNumBySetID(setID)
      })
      setIDToIndex[setID] = #tabData
    end
  end
  return tabData, setIDToIndex
end
function CardCollectionSetModule:GetHistorySetDataBySetId(setID)
  local dataModule = self:_GetDataModule()
  local setData = dataModule:GetSetData(setID)
  if not setData then
    CardCollectionSeasonHandler.send_card_collect_query_series_data_req(setID)
    return nil
  end
  local cardModule = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionCardModule)
  local result = cardModule:GetCardDataBySetID(setID, setData)
  if not result then
    return nil
  end
  return {
    CardData = result.CardData,
    OwnedNum = result.OwnedNum,
    TotalNum = result.TotalNum,
    collect_award = result.collect_award
  }
end
function CardCollectionSetModule:GetAllHistorySetData()
  local dataModule = self:_GetDataModule()
  local version_util = require("client.common.version_util")
  local historyData = self:GetHistoryCardTable()
  local ClientVersion = Client.GetAppVersion()
  for k, v in pairs(historyData) do
    if v then
      if version_util.CompareVersionFull(ClientVersion, v.Version) >= 0 then
        if not dataModule:GetSetData(v.SetId) then
          CardCollectionSeasonHandler.send_card_collect_query_series_data_req(v.SetId)
        end
      else
        log(bWriteLog and "CardCollectionSetModule:Cur setPage version > ClientVersion" .. "  setId = " .. tostring(v.SetId))
      end
    end
  end
end
function CardCollectionSetModule:GetHistoryCardTable()
  local dataModule = self:_GetDataModule()
  local regionConfig = dataModule:GetRegionConfig()
  local version_util = require("client.common.version_util")
  local ClientVersion = Client.GetAppVersion()
  local setConfigTable = CDataTable.GetSplitTable("Lobby", "CardCollection", regionConfig.Set)
  local history_setTable = {}
  for k, v in pairs(setConfigTable) do
    if version_util.CompareVersionMain(ClientVersion, v.Version) > 0 then
      table.insert(history_setTable, v)
    else
      log(bWriteLog and "CardCollectionSetModule:Cur setPage version > ClientVersion" .. "  setId = " .. tostring(v.SetId))
    end
  end
  return history_setTable
end
function CardCollectionSetModule:HasCanReceiveCollectAward(setID)
  local dataModule = self:_GetDataModule()
  local seasonData = dataModule:GetSeasonData()
  if not seasonData then
    return false
  end
  local setData = seasonData[setID]
  if not setData then
    return false
  end
  if setData.collect_award == 1 then
    return false
  end
  return 0 < (setData.finish_ts or 0)
end
function CardCollectionSetModule:RefreshAllCollectAwardRedDot(reddotData)
  local dataModule = self:_GetDataModule()
  local seasonData = dataModule:GetSeasonData()
  if not seasonData then
    return
  end
  for setID, setData in pairs(seasonData) do
    if type(setID) == "number" and type(setData) == "table" then
      if self:HasCanReceiveCollectAward(setID) then
        reddotData:SetCollectAwardRedDot(setID)
      else
        reddotData:CloseCollectAwardRedDot(setID)
      end
    end
  end
end
function CardCollectionSetModule:GetSetProgress(setID)
  local dataModule = self:_GetDataModule()
  local seasonData = dataModule:GetSeasonData()
  local setData = seasonData and seasonData[setID] or {}
  local own = setData.count or 0
  local total = self:GetTotalCardNumBySetID(setID)
  return own, total
end
function CardCollectionSetModule:GetSeasonSetData()
  local dataModule = self:_GetDataModule()
  if not dataModule:_EnsureSeasonData() then
    return
  end
  local seasonData = dataModule:GetSeasonData()
  local regionConfig = dataModule:GetRegionConfig()
  log_tree("[CardCollection] CardCollectionSetModule:GetSeasonSetData season data", seasonData)
  local seasonID = dataModule:GetSeasonIDByClientVersion()
  local setConfigTable = CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", regionConfig.Set, "SeasonID", seasonID)
  local res = {}
  local setIDToIndex = {}
  local setData
  if setConfigTable then
    for setID, v in pairs(setConfigTable) do
      setData = seasonData[setID] or {}
      table.insert(res, {
        count = setData.count or 0,
        show_data = v
      })
      setIDToIndex[setID] = #res
    end
  end
  return res, setIDToIndex
end
function CardCollectionSetModule:GetTotalCardNumBySetID(setID)
  local setCfg = self:GetCardCollectionSetConfigBySetID(setID)
  return setCfg and setCfg.TotalCardCount or 0
end
function CardCollectionSetModule:GetCardCollectionSetConfigBySetID(setId)
  local dataModule = self:_GetDataModule()
  local regionConfig = dataModule:GetRegionConfig()
  local cfg = CDataTable.GetSplitTableData("Lobby", "CardCollection", regionConfig.Set, setId)
  return cfg
end
function CardCollectionSetModule:GetCardCollectionSetConfigBySeasonID(seasonID)
  local dataModule = self:_GetDataModule()
  local regionConfig = dataModule:GetRegionConfig()
  seasonID = seasonID or dataModule:GetSeasonIDByClientVersion()
  local cfg = CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", regionConfig.Set, "SeasonID", seasonID)
  return cfg
end
function CardCollectionSetModule:GetSetTaskConfig(setID)
  if not setID then
    return {}
  end
  local dataModule = self:_GetDataModule()
  local configTable = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", setID)
  if not configTable then
    return {}
  end
  local result = {}
  for _, config in pairs(configTable) do
    if config.TaskDesc and config.TaskDesc ~= "" and dataModule:IsCardOnline(config) then
      table.insert(result, {show_data = config})
    end
  end
  return result
end
function CardCollectionSetModule:GetAdditionalAwardBySetID(setID)
  if not setID then
    return nil
  end
  local additionalAward = CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", "CardCollectionSetSpecialAward", "SetID", setID)
  if not additionalAward then
    return nil
  end
  local res = {}
  for _, v in pairs(additionalAward) do
    table.insert(res, v)
  end
  return res
end
function CardCollectionSetModule:IsNewSet(setID)
  if not setID then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local readSetMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionNewSetRead) or {}
  return not readSetMap[tostring(setID)]
end
function CardCollectionSetModule:MarkNewSetRead(setID)
  if not setID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local readSetMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionNewSetRead) or {}
  if readSetMap[tostring(setID)] then
    return
  end
  readSetMap[tostring(setID)] = true
  PlayerPrefsSystem.SaveTableToFile_N(readSetMap, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionNewSetRead)
end
function CardCollectionSetModule:on_card_collect_query_series_data_rsp(series_id, series_data)
  log_tree(bWriteLog and string.format("[CardCollection] CardCollectionSetModule:on_card_collect_query_series_data_rsp series_id=%s, series_data", tostring(series_id)), series_data)
  self:_GetDataModule():SetSetData(series_id, series_data)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SERIES_DATA_UPDATE, series_id, series_data)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CCardCollectionSetModule = class(CModuleBase, nil, CardCollectionSetModule)
return CCardCollectionSetModule