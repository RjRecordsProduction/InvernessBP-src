local CardCollectionPlayerDisplayModule = {}
function CardCollectionPlayerDisplayModule:DefineAndResetData()
  self.show_infoMap = {}
  self.all_cardface = nil
  self._GMTestCardList = nil
end
function CardCollectionPlayerDisplayModule:OnInitialize()
end
function CardCollectionPlayerDisplayModule:RegistEvents()
end
function CardCollectionPlayerDisplayModule:OnLogin(bReLogin)
end
function CardCollectionPlayerDisplayModule:OnLogOut()
end
function CardCollectionPlayerDisplayModule:OnPreSwitchGameStatus(preState, nextState)
  self:DefineAndResetData()
end
function CardCollectionPlayerDisplayModule:OnPostSwitchGameStatus(preState, nextState)
end
function CardCollectionPlayerDisplayModule:GetCardScoreLevelCfgByScore(score)
  log(bWriteLog and "CardCollectionPlayerDisplayModule:GetCardScoreLevelCfgByScore:" .. score)
  score = score or 0
  local cfg = CDataTable.GetTable("CardScoreLevelCfg")
  for i, data in ipairs(cfg or {}) do
    if not cfg[i + 1] or score <= data.MinScore and score < cfg[i + 1].MinScore then
      return data
    end
  end
end
function CardCollectionPlayerDisplayModule:GetCardCollectionLevelByScore(score)
  local levelConfig = CDataTable.GetTable("CardScoreLevelCfg")
  local level = 1
  for i, v in pairs(levelConfig) do
    if score < v.MinScore then
      return level
    end
    level = v.Level
  end
  return level
end
function CardCollectionPlayerDisplayModule:GetCardScroreByUid(uid)
  uid = tonumber(uid)
  if not self.show_infoMap then
    self.show_infoMap = {}
  end
  if self.show_infoMap[uid] then
    return self.show_infoMap[uid].career_score or 0
  end
  return nil
end
function CardCollectionPlayerDisplayModule:UpdateShowInfo(uid, show_info)
  if not self.show_infoMap then
    self.show_infoMap = {}
  end
  self.show_infoMap[uid] = show_info
end
function CardCollectionPlayerDisplayModule:GetSelectVersionCardList(uid)
  if self._GMTestCardList then
    return self._GMTestCardList
  end
  uid = tonumber(uid)
  if not uid then
    return nil
  end
  if uid == tonumber(DataMgr.roleData.uid) and self.show_series_id then
    local cardInfoModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardInfoModule)
    if cardInfoModule then
      return cardInfoModule:GetCardsByVersionList(self.show_series_id)
    end
  end
  if self.show_infoMap[uid] then
    log_tree("[CardCollection] CardCollectionPlayerDisplayModule:GetSelectVersionCardList show_infoMap", self.show_infoMap[uid])
    local series_id = self.show_infoMap[uid].show_series_id
    local cardInfoModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardInfoModule)
    if cardInfoModule then
      return cardInfoModule:GetCardsByVersionList(series_id)
    end
  end
  return nil
end
function CardCollectionPlayerDisplayModule:GetActionItemID()
  local card_list = self:GetSelectVersionCardList(DataMgr.roleData.uid)
  if card_list then
    local CardNum = 0
    for _ in pairs(card_list) do
      CardNum = CardNum + 1
    end
    local Config = CDataTable.GetTableData("CardCollectionEmoteConfig", CardNum)
    if Config then
      return Config.EmoteID
    end
  end
  return 12220500
end
function CardCollectionPlayerDisplayModule:HasUnlockAction()
  return true
end
function CardCollectionPlayerDisplayModule:GetCardActionDataList()
  local configList = CDataTable.GetSplitTable("Lobby", "CardCollection", "CardCollectionCardRandomActionConfig")
  if not configList then
    log(bWriteLog and "[CardCollection] CardCollectionPlayerDisplayModule:GetCardActionDataList configList is nil")
    return {}
  end
  local cardInfoModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardInfoModule)
  if not cardInfoModule then
    log(bWriteLog and "[CardCollection] CardCollectionPlayerDisplayModule:GetCardActionDataList cardInfoModule is nil")
    return {}
  end
  local result = {}
  for _, cfg in pairs(configList) do
    if cardInfoModule:HasCard(cfg.CardItemID) then
      table.insert(result, {
        CardItemID = cfg.CardItemID,
        IconPath = cfg.IconPath,
        RandomID = cfg.RandomID
      })
    end
  end
  return result
end
function CardCollectionPlayerDisplayModule:RequestCardActionDataIfNeeded(callback)
  local configList = CDataTable.GetSplitTable("Lobby", "CardCollection", "CardCollectionCardRandomActionConfig")
  if not configList then
    log(bWriteLog and "[CardCollection] CardCollectionPlayerDisplayModule:RequestCardActionDataIfNeeded configList is nil")
    return
  end
  local cardInfoModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardInfoModule)
  if not cardInfoModule then
    log(bWriteLog and "[CardCollection] CardCollectionPlayerDisplayModule:RequestCardActionDataIfNeeded cardInfoModule is nil")
    return
  end
  local resIdList = {}
  for _, cfg in pairs(configList) do
    if cardInfoModule:GetCardCount(cfg.CardItemID) == 0 then
      resIdList[#resIdList + 1] = cfg.CardItemID
    end
  end
  if #resIdList == 0 then
    if callback then
      callback()
    end
    return
  end
  local ModCardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
  ModCardCollectionSeasonHandler.send_card_collect_batch_query_card_req(resIdList):Then(function()
    if callback then
      callback()
    end
  end)
end
function CardCollectionPlayerDisplayModule:GetCardActionList(randomID)
  local poolCfg = CDataTable.GetSplitTableData("Lobby", "CardCollection", "CardCollectionActionPool", randomID)
  if not poolCfg or not poolCfg.ActionList then
    printf("[CardCollection] CardCollectionPlayerDisplayModule:GetCardActionList poolCfg not found, randomID=%s", randomID)
    return {}
  end
  local actionList = {}
  for id in string.gmatch(poolCfg.ActionList, "[^|]+") do
    local nID = tonumber(id)
    if nID and 0 < nID then
      table.insert(actionList, nID)
    end
  end
  return actionList
end
function CardCollectionPlayerDisplayModule:GetRandomCardAction(randomID)
  local actionList = self:GetCardActionList(randomID)
  if #actionList == 0 then
    printf("[CardCollection] CardCollectionPlayerDisplayModule:GetRandomCardAction actionList empty, randomID=%s", randomID)
    return 0
  end
  return actionList[math.random(1, #actionList)]
end
function CardCollectionPlayerDisplayModule:GetSelectCardActionVersion(uid)
  uid = tonumber(uid)
  if self.show_infoMap[uid] then
    return self.show_infoMap[uid].show_series_id
  end
  return nil
end
function CardCollectionPlayerDisplayModule:GetActionResourceDownloadList(series_id)
  local result = {}
  local card_list
  if series_id then
    local CardCollectionCardInfoModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardInfoModule)
    card_list = CardCollectionCardInfoModule:GetCardsByVersionList(series_id)
  end
  local getActionID = function(card_list)
    if card_list then
      local CardNum = 0
      for _ in pairs(card_list) do
        CardNum = CardNum + 1
      end
      local Config = CDataTable.GetTableData("CardCollectionEmoteConfig", CardNum)
      if Config then
        return Config.EmoteID
      end
    end
    return 12220500
  end
  table.insert(result, getActionID(card_list))
  for index, value in pairs(card_list or {}) do
    local cfg = CDataTable.GetTableData("CardShowConfig", value.CardID)
    if cfg then
      table.insert(result, cfg.MatPath)
      table.insert(result, cfg.MeshPath)
    end
  end
  log(bWriteLog and "[CardCollection] CardCollectionPlayerDisplayModule:GetActionResourceDownloadList series_id =" .. tostring(series_id))
  log_tree("[CardCollection] CardCollectionPlayerDisplayModule:GetActionResourceDownloadList result", result)
  return result
end
function CardCollectionPlayerDisplayModule:DownloadCardRes(list, autoDownload)
  local extraData = {bAutoDownload = autoDownload, bSkipPopUp = true}
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, list, nil, nil, extraData)
end
function CardCollectionPlayerDisplayModule:CreateActionDownloadUI(list, uiRoot, panelParent, extraData)
  if not Client.IsJaguar() then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local curSize, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, list)
  local size = (totalSize - curSize) / PufferConst.MB
  local tips = LocUtil.LocalizeResFormat(7921, string.format("%.2f MB", size))
  extraData = extraData or {}
  extraData.askTips = tips
  function extraData.callback()
    self:DownloadCardRes(list)
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, list, uiRoot, panelParent, extraData)
end
function CardCollectionPlayerDisplayModule:IsDownloadedAction()
  if not Client.IsJaguar() then
    return true
  end
  local series_id = self:GetSelectCardActionVersion(tonumber(DataMgr.roleData.uid))
  local list = self:GetActionResourceDownloadList(series_id)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local result = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, list) == PufferConst.ENUM_DownloadState.Done
  log(bWriteLog and "[CardCollection] CardCollectionPlayerDisplayModule:IsDownloadedAction result=" .. tostring(result))
  return result
end
function CardCollectionPlayerDisplayModule:GetAllCardFaceResList()
  if self.all_cardface then
    return self.all_cardface
  end
  local cardTable = CDataTable.GetTable("CardCollectionCardConfig")
  local list = {}
  for _, cfg in pairs(cardTable or {}) do
    table.insert(list, cfg.CardImagePath)
  end
  self.all_cardface = list
  return list
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CCardCollectionPlayerDisplayModule = class(CModuleBase, nil, CardCollectionPlayerDisplayModule)
return CCardCollectionPlayerDisplayModule