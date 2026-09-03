local logic_lobby_souvenirs = {}
local ShowOperationType = {Show = 1, CancelShow = 2}
local guideConfig = {
  [1] = {step = 1, text = 66875},
  [2] = {step = 2, text = 66875},
  [3] = {step = 3, text = 66875},
  [4] = {step = 4, text = 66874}
}
function logic_lobby_souvenirs:DefineAndResetData()
  log(bWriteLog and "logic_lobby_souvenirs:DefineAndResetData")
  self.curMySouvenirsData = {}
  self.lobbySouvenirsData = nil
  self.curFriendSouvenirsData = nil
  self.curFriendSouvenirsList = nil
  self.sortedSouvenirsData = {}
  self.myShowSouvenirsID = 0
  self.curShowSouvenirsId = 0
  self.temporaryDisplayId = 0
  self.curDetailIndex = 0
  self.currency = 0
  self.curPersonSocialUID = 0
  self.curVersionLoginCount = 0
  self.souvenirsGuideTip = nil
  self.canShowExpressionPop = false
  self.progressedCollections = {}
end
function logic_lobby_souvenirs:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_EXPRESSION_PLAY, self.OnSouvenirsExpressionPlay, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY_SOUVENIRS, self.OnSouvenirsJump, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY_SOUVENIRS_SLAP, self.OnSouvenirsSlap, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchPageEnd, self)
end
function logic_lobby_souvenirs:OnLogOut()
  self:DefineAndResetData()
end
function logic_lobby_souvenirs:OnSouvenirsExpressionPlay(_, _, actionID, delayTime, bGot)
  if not actionID then
    log(bWriteLog and "logic_lobby_souvenirs:OnSouvenirsExpressionPlay actionID : nil")
    return
  end
  log(bWriteLog and "logic_lobby_souvenirs:OnSouvenirsExpressionPlay actionID : " .. actionID)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
    expression_util.PlayReviewExpression(actionID, bGot)
    local topUIName = UIManager.GetTopUIName()
    if topUIName == UIManager.UI_Config.xmission_main.keyName then
      expression_util.OpenExpressionPopUI()
    end
  else
    local time = delayTime or 1.5
    local mainLobbyLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local curPage = mainLobbyLogic.curPage
    if curPage == ENUM_LobbyPageType.Mid then
      local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
      expression_util.PlayReviewExpression(actionID, bGot)
    else
      self:AddTimerOnce(time, function()
        local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
        expression_util.PlayReviewExpression(actionID, bGot)
        local isAndroidEmpty = UIManager.IsAndroidStackEmpty()
        if isAndroidEmpty and self.canShowExpressionPop then
          expression_util.OpenExpressionPopUI()
        end
      end)
    end
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SOUVENIRS_ACTION_DISPLAY, actionID)
end
function logic_lobby_souvenirs:OnSwitchPageStart(_, _, toPage)
  log(bWriteLog and "logic_lobby_souvenirs:OnSwitchPageStart toPage: " .. toPage)
  self.canShowExpressionPop = toPage == ENUM_LobbyPageType.Mid
end
function logic_lobby_souvenirs:OnSwitchPageEnd(_, _, _, toPage)
  log(bWriteLog and "logic_lobby_souvenirs:OnSwitchPageEnd toPage : " .. toPage)
  if toPage == ENUM_LobbyPageType.Left then
    local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
    local ExpressionPop_New_UIBP = Expression_Util.GetExpressionPopUI()
    if ExpressionPop_New_UIBP then
      Expression_Util.CloseExpressionPopUI()
    end
    if self.backToUICache then
      GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_LOBBY_SOUVENIRS .. "&id=" .. self.backToUICache.collection_id)
      self.backToUICache = nil
    end
  end
end
function logic_lobby_souvenirs:OnSouvenirsJump(_, _, vars)
  log(bWriteLog and "logic_lobby_souvenirs:OnSouvenirsJump")
  UIManager.ShowUI(UIManager.UI_Config.Souvenirs_Tab_UIBP, tonumber(DataMgr.roleData.uid), vars.id)
end
local isNeedSlap, slapSouvenirs
function logic_lobby_souvenirs:SetIsNeedSlap(new_collection_set)
  log_tree(bWriteLog and "logic_lobby_souvenirs:SetIsNeedSlap new_collection_set", new_collection_set)
  isNeedSlap = true
  slapSouvenirs = new_collection_set
end
function logic_lobby_souvenirs:IsCanShowSouvenirsSlap()
  return isNeedSlap
end
function logic_lobby_souvenirs:OnSouvenirsSlap()
  UIManager.ShowUI(UIManager.UI_Config.Souvenirs_Popup_Notes_UIBP, slapSouvenirs)
  isNeedSlap = nil
  slapSouvenirs = nil
  if self:CheckCanSetSouvenirsReddot() then
    self:SetExpressionReddot(true)
  end
end
function logic_lobby_souvenirs:ResetCache()
  log(bWriteLog and "logic_lobby_souvenirs:ResetCache")
  self.curMySouvenirsData = {}
  self.curFriendSouvenirsData = nil
  self.curFriendSouvenirsList = nil
  self.sortedSouvenirsData = {}
  self.curShowSouvenirsId = 0
  self.lobbySouvenirsData = nil
  self.curDetailIndex = 0
end
function logic_lobby_souvenirs:GetMySouvenirsData()
  return self.curMySouvenirsData
end
function logic_lobby_souvenirs:GetMySouvenirsListData()
  if self.curMySouvenirsData and self.curMySouvenirsData.collection_set then
    return self.curMySouvenirsData.collection_set
  end
  return nil
end
function logic_lobby_souvenirs:IsSouvenirsUnlock(SouvenirsID)
  if not SouvenirsID then
    log(bWriteLog and "logic_lobby_souvenirs:IsSouvenirsUnlock SouvenirsID : nil")
    return false
  end
  for k, v in pairs(self.sortedSouvenirsData) do
    if v.showExtraId == SouvenirsID then
      return v.status == 3
    end
  end
  return false
end
function logic_lobby_souvenirs:IsSouvenirsSpecial(SouvenirsID)
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  if self.sortedSouvenirsData then
    for id, config in pairs(self.sortedSouvenirsData) do
      if (config.souvenirsType == souvenirs_macro.ESouvenirsType.Special or config.souvenirsType == souvenirs_macro.ESouvenirsType.PMGC) and config.showExtraId == SouvenirsID then
        return true
      end
    end
  end
  return false
end
function logic_lobby_souvenirs:GetMySouvenirsListDataById(id)
  local data = self:GetMySouvenirsListData()
  if not data then
    log(bWriteLog and "logic_lobby_souvenirs:GetMySouvenirsListDataById id:" .. id)
    return nil
  end
  return data[id]
end
function logic_lobby_souvenirs:AddMyMotion(motionID)
  log(bWriteLog and "logic_lobby_souvenirs:AddMyMotion motionID: " .. motionID)
  if not self.curMySouvenirsData.motions then
    self.curMySouvenirsData.motions = {}
  end
  table.insert(self.curMySouvenirsData.motions, motionID)
end
function logic_lobby_souvenirs:SetMySouvenirsShareCount(collection_id, count)
  local data = self:GetMySouvenirsListDataById(collection_id)
  if not data then
    log(bWriteLog and "logic_lobby_souvenirs:SetMySouvenirsShareCount collect_id :" .. collection_id)
    return
  end
  if count <= count then
    data.share_    log(bWriteLog and "logic_lobby_souvenirs:SetMySouvenirsShareCount count: " .. tostring(count))
  end
end
function logic_lobby_souvenirs:SetMySouvenirsData(data)
  log_tree("logic_lobby_souvenirs:SetMySouvenirsData data : ", data or {})
  self.curMySouvenirsData = data
  if data and data.show_slot and data.show_slot[1] then
    self:SetMyShowSouvenirsId(self.curMySouvenirsData.show_slot[1])
  end
  if data then
    self.currency = data.currency
    self:SetCurVersionLoginCount(data.cur_version_login_count)
  end
end
function logic_lobby_souvenirs:UpdateMySouvenirsState(id, state)
  log(bWriteLog and "logic_lobby_souvenirs:UpdateMySouvenirsState 1 id = " .. tostring(id) .. " state = " .. tostring(state))
  if not (id and self.curMySouvenirsData) or not self.curMySouvenirsData.collection_set then
    log(bWriteLog and "logic_lobby_souvenirs:UpdateMySouvenirsState nil Data")
    return
  end
  for souvenirsID, data in pairs(self.curMySouvenirsData.collection_set) do
    if souvenirsID == id then
      log(bWriteLog and "logic_lobby_souvenirs:UpdateMySouvenirsState 2 id = " .. tostring(id) .. " state = " .. tostring(state))
      data.status = state
    end
  end
  if self.sortedSouvenirsData and next(self.sortedSouvenirsData) then
    for i = 1, #self.sortedSouvenirsData do
      if self.sortedSouvenirsData[i].collection_id == id then
        log(bWriteLog and "logic_lobby_souvenirs:UpdateMySouvenirsState sortedSouvenirsData id = " .. tostring(id) .. " state = " .. tostring(state))
        self.sortedSouvenirsData[i].status = state
      end
    end
  end
end
function logic_lobby_souvenirs:UpdateMySouvenirsAddtionUnlock(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:UpdateMySouvenirsAddtionUnlock " .. collection_id)
  local data = self:GetMySouvenirsListData()
  if not data then
    return
  end
  local extraId = self:GetExtraItemShowId(collection_id)
  data[collection_id].extra_item_id = extraId
end
function logic_lobby_souvenirs:SetCurFriendSouvenirsData(data)
  log_tree("logic_lobby_souvenirs:SetCurFriendSouvenirsData ", data)
  self.curFriendSouvenirsData = data
  if data and data.show_slot and data.show_slot[1] then
    self:SetCurShowSouvenirsId(data.show_slot[1])
  else
    self:SetCurShowSouvenirsId(0)
  end
end
function logic_lobby_souvenirs:AddNewCanReleaseData(collect_id)
  if not self.curMySouvenirsData or not self.curMySouvenirsData.collection_set then
    log(bWriteLog and "logic_lobby_souvenirs:AddNewCanReleaseData not my data")
    return
  end
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local _collector = tonumber(DataMgr.roleData.uid)
  local newData = {
    collection_id = collect_id,
    status = souvenirs_macro.LobbySouvenirsStatus.CanRelease,
    showExtraId = self:GetExtraItemShowId(collect_id),
    showEmotionId = self:GetEmotionID(collect_id),
    entryPath = self:GetEntryPath(collect_id),
    giftChance = self:GetGiftChance(collect_id),
    collector = _collector
  }
  self.curMySouvenirsData.collection_set[collect_id] = newData
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_CANRELEASE_REDDOT)
end
function logic_lobby_souvenirs:ReSetSouvenirsData(isOwner)
  log(bWriteLog and "logic_lobby_souvenirs:ReSetSouvenirsData")
  self.sortedSouvenirsData = {}
  local gameId = Client.GetITopGameId()
  if isOwner then
    if self.curMySouvenirsData and self.curMySouvenirsData.collection_set then
      self.lobbySouvenirsData = self.curMySouvenirsData.collection_set
    end
    if self.curMySouvenirsData and self.curMySouvenirsData.progressed_collections then
      self.progressedCollections = self.curMySouvenirsData.progressed_collections
    end
  else
    self.lobbySouvenirsData = self.curFriendSouvenirsList
  end
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  local souvenirsConfig = CDataTable.GetTableByFilter("SouvenirsTable", "type", souvenirs_macro.LobbySouvenirsType.lobby)
  for id, config in pairs(souvenirsConfig) do
    local souvenirsID = tonumber(id)
    local _status, _got_ts, _share_count, _extra_item_id, _emotion_id, _collector, _giftItemid
    if isOwner then
      if self.lobbySouvenirsData and self.lobbySouvenirsData[souvenirsID] then
        local curData = self.lobbySouvenirsData[souvenirsID]
        _status = curData.status
        _got_ts = curData.got_ts
        _share_count = curData.share_count
        _extra_item_id = curData.extra_item_id
        _emotion_id = curData.emotion_id
        _giftItemid = curData.giftItemid
      elseif config.souvenirsType == souvenirs_macro.ESouvenirsType.Special then
        _status = souvenirs_macro.LobbySouvenirsStatus.CanRelease
      else
        _status = souvenirs_macro.LobbySouvenirsStatus.UnRelease
      end
    elseif self.lobbySouvenirsData and self.lobbySouvenirsData[souvenirsID] then
      local status = self.lobbySouvenirsData[souvenirsID]
      _    else
      _status = souvenirs_macro.LobbySouvenirsStatus.UnRelease
    end
    if isOwner then
      _collector = tonumber(DataMgr.roleData.uid)
    else
      _collector = self.curPersonSocialUID
    end
    if not self:InAppidTest(gameId, config.shieldAppID) then
      local newData = {
        collection_id = souvenirsID,
        status = _status,
        got_ts = _got_ts,
        share_count = _share_count,
        extra_item_id = _extra_item_id,
        emtion_id = _emotion_id,
        showExtraId = self:GetExtraItemShowId(souvenirsID),
        showEmotionId = self:GetEmotionID(souvenirsID),
        entryPath = self:GetEntryPath(souvenirsID),
        giftChance = self:GetGiftChance(souvenirsID),
        collector = _collector,
        souvenirsType = config.souvenirsType,
        detailBPPath = config.detailBPPath,
        giftItemid = _giftItemid
      }
      table.insert(self.sortedSouvenirsData, newData)
    end
  end
  self:ReSortSouvenirsData()
  log_tree("sortedSouvenirsData:", self.sortedSouvenirsData)
  return self.sortedSouvenirsData
end
function logic_lobby_souvenirs:GetHomeDepotItemCount(itemId)
  local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
  return PHomeStoreProxy:GetDepotItemCount(itemId, true)
end
function logic_lobby_souvenirs:ReSetTSouvenirsData(isOwner)
  log(bWriteLog and "logic_lobby_souvenirs:ReSetTSouvenirsData")
  self.sortedSouvenirsData = {}
  local gameId = Client.GetITopGameId()
  if isOwner then
    if self.curMySouvenirsData and self.curMySouvenirsData.collection_set then
      self.lobbySouvenirsData = self.curMySouvenirsData.collection_set
    end
  else
    self.lobbySouvenirsData = self.curFriendSouvenirsList
  end
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  local tSouvenirs = logic_xmission_souvenirs:GetSouvenirs()
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  local souvenirsConfig = CDataTable.GetTableByFilter("SouvenirsTable", "type", souvenirs_macro.LobbySouvenirsType.xmission)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for id, config in pairs(souvenirsConfig) do
    local souvenirsID = tonumber(id)
    local _status, _got_ts, _share_count, _extra_item_id, _emotion_id, _collector, _ItemID
    if isOwner then
      if tSouvenirs and tSouvenirs[config.ItemID] then
        local curData = tSouvenirs[config.ItemID]
        _status = curData and souvenirs_macro.LobbySouvenirsStatus.Got or 0
        _emotion_id = config.expressionID
        _ItemID = config.ItemID
      else
        _status = souvenirs_macro.LobbySouvenirsStatus.UnRelease
      end
      local nCount = self:GetHomeDepotItemCount(config.addtionalItemID)
      if 0 < nCount then
        _extra_item_id = config.addtionalItemID
      end
    else
      local profile = logic_profile:GetLocalProfile(self.curPersonSocialUID)
      if profile then
        if profile.metro_souvenirs and profile.metro_souvenirs[config.ItemID] then
          _status = profile.metro_souvenirs[config.ItemID] and 3 or 0
          _ItemID = config.ItemID
        else
          _status = souvenirs_macro.LobbySouvenirsStatus.UnRelease
        end
      end
    end
    if _status == souvenirs_macro.LobbySouvenirsStatus.Got and not self:InAppidTest(gameId, config.shieldAppID) then
      if isOwner then
        _collector = tonumber(DataMgr.roleData.uid)
      else
        _collector = self.curPersonSocialUID
      end
      local newData = {
        collection_id = souvenirsID,
        status = _status,
        got_ts = _got_ts,
        share_count = _share_count,
        extra_item_id = _extra_item_id,
        emtion_id = _emotion_id,
        showExtraId = self:GetExtraItemShowId(souvenirsID),
        showEmotionId = self:GetEmotionID(souvenirsID),
        entryPath = self:GetEntryPath(souvenirsID),
        giftChance = self:GetGiftChance(souvenirsID),
        collector = _collector,
        itemID = _ItemID
      }
      table.insert(self.sortedSouvenirsData, newData)
    end
  end
  self:ReSortTSouvenirsData()
  log_tree("T sortedSouvenirsData:", self.sortedSouvenirsData)
  return self.sortedSouvenirsData
end
function logic_lobby_souvenirs:GetSortedSouvenirsData()
  return self.sortedSouvenirsData
end
function logic_lobby_souvenirs:GetProgressedSouvenirsData(souvenirsID)
  if self.progressedCollections and self.progressedCollections[souvenirsID] then
    return self.progressedCollections[souvenirsID]
  else
    return nil
  end
end
function logic_lobby_souvenirs:ReSortTSouvenirsData()
  if not next(self.sortedSouvenirsData) then
    return
  end
  table.sort(self.sortedSouvenirsData, function(a, b)
    return a.itemID > b.itemID
  end)
end
function logic_lobby_souvenirs:ReSortSouvenirsData()
  if not next(self.sortedSouvenirsData) then
    return
  end
  table.sort(self.sortedSouvenirsData, function(a, b)
    return a.collection_id > b.collection_id
  end)
end
function logic_lobby_souvenirs:GetSouvenirsData(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:GetSouvenirsData 1 collection_id = " .. tostring(collection_id))
  log_tree(bWriteLog and "logic_lobby_souvenirs:GetSouvenirsData self.sortedSouvenirsData = ", self.sortedSouvenirsData)
  if not next(self.sortedSouvenirsData) then
    return nil
  end
  for _, data in ipairs(self.sortedSouvenirsData) do
    if data.collection_id == collection_id then
      log(bWriteLog and "logic_lobby_souvenirs:GetSouvenirsData 2 collection_id = " .. tostring(collection_id))
      return data
    end
  end
  return nil
end
function logic_lobby_souvenirs:GetSouvenirsDataByItemID(itemID)
  if not next(self.sortedSouvenirsData) then
    return nil
  end
  for _, data in ipairs(self.sortedSouvenirsData) do
    if data.itemID == itemID then
      return data
    end
  end
  return nil
end
function logic_lobby_souvenirs:GetSouvenirsDataByIndex(index)
  if self.sortedSouvenirsData[index] then
    return self.sortedSouvenirsData[index]
  end
  return nil
end
function logic_lobby_souvenirs:UpdateSouvenirsData(collection_id, new_collection_info)
  if not new_collection_info or not collection_id then
    log(bWriteLog and "logic_lobby_souvenirs:UpdateSouvenirsData not new_collection_info")
    return
  end
  for i = 1, #self.sortedSouvenirsData do
    if self.sortedSouvenirsData[i].collection_id == collection_id then
      self.sortedSouvenirsData[i].status = new_collection_info.status
      self.sortedSouvenirsData[i].share_count = new_collection_info.share_count
    end
  end
  local selfData = self:GetMySouvenirsListData()
  if not selfData or not next(selfData) then
    log(bWriteLog and "logic_lobby_souvenirs:UpdateSouvenirsData UpdateMyData FirstTime")
    self.curMySouvenirsData.collection_set = {}
    self.curMySouvenirsData.collection_set[collection_id] = {}
    self.curMySouvenirsData.collection_set[collection_id].status = new_collection_info.status
    self.curMySouvenirsData.collection_set[collection_id].share_count = new_collection_info.share_count
  else
    log(bWriteLog and "logic_lobby_souvenirs:UpdateSouvenirsData UpdateMyData")
    if not selfData[collection_id] then
      selfData[collection_id] = {}
    end
    selfData[collection_id].status = new_collection_info.status
    selfData[collection_id].share_count = new_collection_info.share_count
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_CANRELEASE_REDDOT)
end
function logic_lobby_souvenirs:GetSouvenirsShareCount(collection_id)
  local data = self:GetSouvenirsData(collection_id)
  if data then
    return data.share_count
  end
  return 0
end
function logic_lobby_souvenirs:SetSouvenirsShareCount(collection_id, count)
  if not count then
    log(bWriteLog and "logic_lobby_souvenirs:SetSouvenirsShareCount not count")
    return
  end
  log(bWriteLog and "logic_lobby_souvenirs:SetSouvenirsShareCount id: " .. collection_id .. "count: " .. count)
  local data = self:GetSouvenirsData(collection_id)
  if data then
    data.share_  end
  self:SetMySouvenirsShareCount(collection_id, count)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_REFRESH_SEND_TIME)
end
function logic_lobby_souvenirs:GetSouvenirsFinalGetTime(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not (data and data.finalGetTime) or data.finalGetTime == "" then
    log(bWriteLog and "logic_lobby_souvenirs:GetSouvenirsFinalGetTime not data")
    return ""
  end
  local timeuitl = require("client.common.time_util")
  local finalGetTime = timeuitl.FormatTime_YMDHMS(timeuitl.TimeStringToUnixstamp(data.finalGetTime, false), false, true)
  return finalGetTime
end
function logic_lobby_souvenirs:GetSouvenirsShowState(collection_id)
  return self.myShowSouvenirsID == collection_id
end
function logic_lobby_souvenirs:GetCurShowSouvenirsId()
  log(bWriteLog and "logic_lobby_souvenirs:GetCurShowSouvenirsId :" .. tostring(self.curShowSouvenirsId))
  return self.curShowSouvenirsId or 0
end
function logic_lobby_souvenirs:GetMyShowSouvenirsId()
  log(bWriteLog and "logic_lobby_souvenirs:GetMyShowSouvenirsId :" .. tostring(self.myShowSouvenirsID))
  return self.myShowSouvenirsID or 0
end
function logic_lobby_souvenirs:SetCurShowSouvenirsId(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:SetCurShowSouvenirsId : " .. collection_id)
  self.curShowSouvenirsId = collection_id
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_ENTRY_ICON_CHANGE, collection_id)
end
function logic_lobby_souvenirs:SetMyShowSouvenirsId(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:SetMyShowSouvenirsId : " .. collection_id)
  self.myShowSouvenirsID = collection_id
end
function logic_lobby_souvenirs:IsUnlockExtraItem(collection_info)
  if collection_info.extra_item_id then
    return true
  end
  return false
end
function logic_lobby_souvenirs:GetExtraItemShowId(collect_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collect_id)
  if not data then
    return 0
  end
  return data.addtionalItemID
end
function logic_lobby_souvenirs:GetEmotionID(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    return nil
  end
  return data.expressionID
end
function logic_lobby_souvenirs:GetEntryPath(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    return nil
  end
  return data.entryPath
end
function logic_lobby_souvenirs:GetSouvenirsModelBPPath(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    return nil
  end
  return data.ModelBPPath
end
function logic_lobby_souvenirs:GetGiftChance(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    return nil
  end
  return data.giftChance
end
function logic_lobby_souvenirs:UpdateSouvenirsExtraItemDataId(collect_id)
  local data = self:GetSouvenirsData(collect_id)
  if not data then
    return
  end
  data.extra_item_id = data.showExtraId
end
function logic_lobby_souvenirs:GetTotalSouvenirsNum()
  return #self.sortedSouvenirsData
end
function logic_lobby_souvenirs:GetCurDetailIndex()
  log(bWriteLog and "logic_lobby_souvenirs:GetCurDetailIndex : " .. self.curDetailIndex)
  return self.curDetailIndex
end
function logic_lobby_souvenirs:SetCurDetailIndex(index)
  log(bWriteLog and "logic_lobby_souvenirs:SetCurDetailIndex : " .. self.curDetailIndex)
  self.curDetailIndex = index
end
function logic_lobby_souvenirs:AppendCurDetailIndex(changeNum)
  self.curDetailIndex = self.curDetailIndex + changeNum
  local total = #self.sortedSouvenirsData
  if total <= self.curDetailIndex then
    self.curDetailIndex = total
  elseif self.curDetailIndex < 1 then
    self.curDetailIndex = 1
  end
  log(bWriteLog and "logic_lobby_souvenirs:AppendCurDetailIndex : " .. self.curDetailIndex)
end
function logic_lobby_souvenirs:GetSouvenirsCurrency()
  log(bWriteLog and "logic_lobby_souvenirs:GetSouvenirsCurrency now :" .. tostring(self.currency))
  return self.currency
end
function logic_lobby_souvenirs:SetSouvenirsCurrency(isCover, changeNum)
  isCover = isCover or false
  if isCover and changeNum then
    self.currency = changeNum
  end
  if not isCover and changeNum then
    self.currency = self.currency + changeNum
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_ON_EXCHANGE_CURRENCY, self.currency)
end
function logic_lobby_souvenirs:GetCurVersionLoginCount()
  log(bWriteLog and "logic_lobby_souvenirs:GetCurVersionLoginCount : " .. self.curVersionLoginCount)
  return self.curVersionLoginCount
end
function logic_lobby_souvenirs:SetCurVersionLoginCount(count)
  log(bWriteLog and "logic_lobby_souvenirs:SetCurVersionLoginCount :" .. count)
  self.curVersionLoginCount = count
end
function logic_lobby_souvenirs:SetCurPersonSocialData(uid)
  self.curPersonSocialUID = uid
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
    if 0 < #list then
      local profile = list[1]
      if not profile then
        return
      end
      if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
        if profile.collection_summary then
          if profile.collection_summary.collection_status then
            self.curFriendSouvenirsList = profile.collection_summary.collection_status
          else
            self.curFriendSouvenirsList = nil
          end
          self:SetCurFriendSouvenirsData(profile.collection_summary)
        else
          self:ResetFriendData()
        end
      else
        self:ResetFriendData()
      end
    end
  end, Enum_PROFILE_REPORT_CFG.LOBBY_SOUVENIRS_FRIEND)
end
function logic_lobby_souvenirs:ResetFriendData()
  log(bWriteLog and "logic_lobby_souvenirs:ResetFriendData")
  self.curFriendSouvenirsList = nil
  self.curFriendSouvenirsData = nil
  self:SetCurShowSouvenirsId(0)
end
function logic_lobby_souvenirs:LobbySouvenirsGuideShow(bShow, locID)
  do return end
  log(bWriteLog and "logic_lobby_souvenirs:LobbySouvenirsGuideShow " .. tostring(bShow))
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local souvenirsGuideTip
  if lobbyMainUI then
    if self.souvenirsGuideTip then
      lobbyMainUI:CloseChildUI(UIManager.UI_Config.Souvenirs_NewGuide_Tips_UIBP)
      self.souvenirsGuideTip = nil
    end
    if bShow and not self.souvenirsGuideTip then
      self.souvenirsGuideTip = lobbyMainUI:AddChildUI("Border_Souvenirs", UIManager.UI_Config.Souvenirs_NewGuide_Tips_UIBP)
    end
    if not bShow and self.souvenirsGuideTip then
      lobbyMainUI:CloseChildUI(UIManager.UI_Config.Souvenirs_NewGuide_Tips_UIBP)
      self.souvenirsGuideTip = nil
      return
    end
  end
  if self.souvenirsGuideTip and self.souvenirsGuideTip.UIRoot then
    self.souvenirsGuideTip.UIRoot.TextBlock_12:SetText(LocUtil.GetLocalizeResStr(locID))
  end
end
function logic_lobby_souvenirs:CheckCanSetSouvenirsReddot()
  local canSet = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewExpressionMark)
  if data and next(data) and data.souvenirsRed == false then
    canSet = false
  end
  log(bWriteLog and "logic_lobby_souvenirs:CheckCanSetSouvenirsReddot : " .. tostring(canSet))
  return canSet
end
function logic_lobby_souvenirs:SetExpressionReddot(bShow)
  log(bWriteLog and "logic_lobby_souvenirs:SetExpressionReddot bShow : " .. tostring(bShow))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewExpressionMark)
  if not data or not next(data) then
    data = {souvenirsRed = true}
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eNewExpressionMark)
  else
    data = {souvenirsRed = bShow}
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eNewExpressionMark)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_EXPRESSION_REDDOT)
end
function logic_lobby_souvenirs:GetExpressionReddotShow()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewExpressionMark)
  log_tree(bWriteLog and "logic_lobby_souvenirs:GetExpressionReddotShow data", data)
  local bShow = false
  if data and next(data) then
    bShow = data.souvenirsRed or false
  else
    bShow = false
  end
  log(bWriteLog and "logic_lobby_souvenirs:GetExpressionReddotShow bShow : " .. tostring(bShow))
  return bShow
end
function logic_lobby_souvenirs:SetBackToMainUICache(backToUICache)
  self.end
function logic_lobby_souvenirs:IsHaveCanReleaseRed()
  log(bWriteLog and "logic_lobby_souvenirs:IsHaveCanReleaseRed")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSouvenirCanRelease) or {}
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local dataList = self:GetMySouvenirsListData()
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  for collection_id, v in pairs(dataList or {}) do
    local result = self:IsPMGCCollectReddotShow(collection_id, v.status)
    if result then
      return true
    elseif result == false then
    elseif result == nil and v.status == souvenirs_macro.LobbySouvenirsStatus.CanRelease and not saveData[collection_id] then
      return true
    end
  end
  local collection_ids = {}
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  local souvenirsConfig = CDataTable.GetTableByFilter("SouvenirsTable", "type", souvenirs_macro.LobbySouvenirsType.lobby, "souvenirsType", souvenirs_macro.ESouvenirsType.PMGC) or {}
  for id, cfg in pairs(souvenirsConfig) do
    local result = self:IsPMGCCollectReddotShow(id, 0)
    if result then
      return true
    end
  end
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  local tSouvenirs = logic_xmission_souvenirs:GetSouvenirs() or {}
  for itemID, _ in pairs(tSouvenirs) do
    local config = CDataTable.GetTableDataByFilter("SouvenirsTable", "ItemID", itemID)
    if config and not saveData[config.id] then
      return true
    end
  end
  return false
end
function logic_lobby_souvenirs:IsPMGCCollectReddotShow(collection_id, status)
  log(bWriteLog and "logic_lobby_souvenirs:IsPMGCCollectReddotShow collection_id = " .. tostring(collection_id) .. " status = " .. tostring(status))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSouvenirCanRelease) or {}
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local souvenirsConfig = CDataTable.GetTableDataByFilter("SouvenirsTable", "id", collection_id) or {}
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  if souvenirsConfig and souvenirsConfig.souvenirsType == souvenirs_macro.ESouvenirsType.PMGC then
    local endTimeDate = souvenirsConfig.endTimeDate
    local endTimestamp = TimeUtil.TimeStringToUnixstamp(endTimeDate, false)
    log(bWriteLog and "logic_lobby_souvenirs:IsPMGCCollectReddotShow saveData[collection_id] = " .. tostring(saveData[collection_id]) .. " nowTime = " .. tostring(nowTime) .. " endTimestamp = " .. tostring(endTimestamp))
    if status ~= souvenirs_macro.LobbySouvenirsStatus.CanGet and status ~= souvenirs_macro.LobbySouvenirsStatus.Got and not saveData[collection_id] and nowTime <= endTimestamp then
      return true
    end
    return false
  end
  return nil
end
function logic_lobby_souvenirs:SetCanReleaseRedDotShow(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:SetCanReleaseRedDotShow collection_id = " .. tostring(collection_id))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSouvenirCanRelease) or {}
  if saveData[collection_id] then
    return
  end
  saveData[collection_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eSouvenirCanRelease)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_CANRELEASE_REDDOT)
end
function logic_lobby_souvenirs:isNeedShowGuide()
  if not self:IsHaveTSouvenir() then
    return false
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local step = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_XMISSION_SOUVENIRS, 1)
  if step and step > #guideConfig then
    return false
  end
  return true
end
function logic_lobby_souvenirs:GetTSouvenirGuideStep()
  if not self:IsHaveTSouvenir() then
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local step = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_XMISSION_SOUVENIRS, 1) or 1
  return step
end
function logic_lobby_souvenirs:NextGuide()
  local tipsUI = UIManager.GetUI(UIManager.UI_Config.Souvenirs_NewGuide_Tips_UIBP)
  if tipsUI then
    tipsUI:CloseSelf()
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_XMISSION_SOUVENIRS, 1, self:GetTSouvenirGuideStep() + 1)
end
function logic_lobby_souvenirs:isCurStep(step)
  if not self:isNeedShowGuide() then
    return false
  end
  local curStep = logic_lobby_souvenirs:GetTSouvenirGuideStep()
  if step ~= curStep then
    return false
  end
  return true
end
function logic_lobby_souvenirs:CreateGuidetTips(parentUI, widget1Parent, widget2, offset)
  do return end
  local step = self:GetTSouvenirGuideStep()
  if step and parentUI then
    parentUI:AddTimerOnce(0.01, function()
      local ui = parentUI:CreateChildWindow(widget1Parent, UIManager.UI_Config.Souvenirs_NewGuide_Tips_UIBP)
      if ui then
        local tool_widget_align = require("client.common.tool_widget_align")
        tool_widget_align.AlignWidget(ui.UIRoot.CanvasPanel_Tips, widget1Parent, widget2, offset)
        ui.UIRoot.TextBlock_12:SetText(LocUtil.GetLocalizeResStr(guideConfig[step].text))
      end
    end)
  end
end
function logic_lobby_souvenirs:GetTLobbySouvenir(itemId)
  local souvenirsConfig = CDataTable.GetTableByFilter("SouvenirsTable", "ItemID", itemId)
  for k, v in pairs(souvenirsConfig) do
    return v
  end
  return nil
end
function logic_lobby_souvenirs:IsHaveTSouvenir(uid)
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  local tSouvenirs = logic_xmission_souvenirs:GetSouvenirs(uid)
  if not tSouvenirs then
    return false
  end
  if not next(tSouvenirs) then
    return false
  end
  for ItemId, _ in pairs(tSouvenirs) do
    local cfgs = CDataTable.GetTableByFilter("SouvenirsTable", "ItemId", ItemId)
    for _, data in pairs(cfgs) do
      local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
      if data and data.type == souvenirs_macro.LobbySouvenirsType.xmission then
        return true
      end
    end
  end
  return false
end
function logic_lobby_souvenirs:IsInReleaseTime(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    log(bWriteLog and "logic_lobby_souvenirs:IsInReleaseTime not config")
    return false
  end
  if data.discountStartTime and data.discountStartTime == "" then
    return true
  end
  if data.discountStartTime and data.discountStartTime ~= "" then
    local TimeUtil = require("client.common.time_util")
    local startTime = TimeUtil.TimeStringToUnixstamp(data.discountStartTime, false)
    local curTime = TimeUtil.GetServerTimeInSec()
    if startTime < curTime then
      log(bWriteLog and "logic_lobby_souvenirs:IsInReleaseTime true id = " .. collection_id)
      return true
    end
  end
  log(bWriteLog and "logic_lobby_souvenirs:IsInReleaseTime false id = " .. collection_id)
  return false
end
function logic_lobby_souvenirs:IsInDiscountTime(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    log(bWriteLog and "logic_lobby_souvenirs:IsInDiscountTime not config")
    return false
  end
  if data.discountStartTime and data.discountEndTime and data.discountStartTime ~= "" and data.discountEndTime ~= "" then
    local TimeUtil = require("client.common.time_util")
    local startTime = TimeUtil.TimeStringToUnixstamp(data.discountStartTime, false)
    local endTime = TimeUtil.TimeStringToUnixstamp(data.discountEndTime, false)
    local curTime = TimeUtil.GetServerTimeInSec()
    if startTime < curTime and endTime > curTime then
      log(bWriteLog and "logic_lobby_souvenirs:IsInDiscountTime true id = " .. collection_id)
      return true
    end
  end
  log(bWriteLog and "logic_lobby_souvenirs:IsInDiscountTime false id = " .. collection_id)
  return false
end
function logic_lobby_souvenirs:IsTSouvenirs(collection_id)
  local data = CDataTable.GetTableData("SouvenirsTable", collection_id)
  if not data then
    log(bWriteLog and "logic_lobby_souvenirs:IsTSouvenirs not config")
    return false
  end
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  return data.type == souvenirs_macro.LobbySouvenirsType.xmission
end
function logic_lobby_souvenirs:SetTemporaryId(id)
  log(bWriteLog and "logic_lobby_souvenirs:SetTemporaryId id = " .. tostring(id))
  self.temporaryDisplayId = id
end
function logic_lobby_souvenirs:ExchangeCollectionCurrency(exchange_number)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  LobbySouvenirsHandler.send_exchange_collection_currency_req(exchange_number)
end
function logic_lobby_souvenirs:OnExchangeCollectionCurrencyRsp(old_number, exchange_number, currency)
  log(bWriteLog and "logic_lobby_souvenirs:OnExchangeCollectionCurrencyRsp exchangeNumber:" .. exchange_number)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_UNRELEASE, old_number, exchange_number, currency)
end
function logic_lobby_souvenirs:SendUnReleaseReq(collection_id)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  local data = self:GetSouvenirsData(collection_id)
  if data then
    local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
    if data.souvenirsType == souvenirs_macro.ESouvenirsType.Special then
      log(bWriteLog and "logic_lobby_souvenirs:SendUnReleaseReq collcetion cant release")
    else
      LobbySouvenirsHandler.send_unfreeze_collection_req(collection_id)
    end
  else
    log(bWriteLog and "logic_lobby_souvenirs:SendUnReleaseReq data = nil")
  end
end
function logic_lobby_souvenirs:OnUnReleaseRsp(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:OnUnReleaseRsp collection_id=" .. collection_id)
  local data = self:GetSouvenirsData(collection_id)
  if data then
    local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
    data.status = souvenirs_macro.LobbySouvenirsStatus.CanGet
    self:UpdateMySouvenirsState(collection_id, souvenirs_macro.LobbySouvenirsStatus.CanGet)
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_UNRELEASE)
  end
end
function logic_lobby_souvenirs:SendGetSouvenirsReq(collection_id, cli_discounted_price)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  LobbySouvenirsHandler.send_buy_collection_req(collection_id, cli_discounted_price)
end
function logic_lobby_souvenirs:OnGetSouvenirsRsp(collection_id, currency)
  log(bWriteLog and "logic_lobby_souvenirs:OnGetSouvenirsRsp collection_id=" .. tostring(collection_id))
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  self:UpdateMySouvenirsState(collection_id, souvenirs_macro.LobbySouvenirsStatus.Got)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_GET_RSP, collection_id)
  if self:CheckCanSetSouvenirsReddot() then
    self:SetExpressionReddot(true)
  end
end
function logic_lobby_souvenirs:SendBuyAddtionalItemReq(collection_id)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  LobbySouvenirsHandler.send_unlock_collection_extra_item_req(collection_id)
end
function logic_lobby_souvenirs:OnBuyAddtionalItemRsp(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:OnBuyAddtionalItemRsp collection_id=" .. collection_id)
  self:UpdateSouvenirsExtraItemDataId(collection_id)
  self:UpdateMySouvenirsAddtionUnlock(collection_id)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_BUY_ADDTIONITEM, collection_id)
end
function logic_lobby_souvenirs:SendShowSouvenirsReq(collection_id)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  local op_type = ShowOperationType.Show
  LobbySouvenirsHandler.send_set_collection_in_show_req(op_type, collection_id)
end
function logic_lobby_souvenirs:OnShowSouvenirsRsp(show_slot)
  if show_slot and next(show_slot) then
    local id = show_slot[1]
    self:SetMyShowSouvenirsId(id)
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_SHOW)
    self:SetCurShowSouvenirsId(id)
    ShowNotice(77872)
    local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
    local nUId = tonumber(Logic_SocialLobbyModule:GetCurUId())
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogReasonStr = json.encode({
      uid = nUId or 0,
      slotType = "souvenirs",
      slotIndex = id or 0
    })
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.EditDisplayMonumentSlot, 0, TLogReasonStr)
  end
end
function logic_lobby_souvenirs:SendCancelShowSouvenirsReq(collection_id)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  local op_type = ShowOperationType.CancelShow
  LobbySouvenirsHandler.send_set_collection_in_show_req(op_type, collection_id)
end
function logic_lobby_souvenirs:OnCancelShowSouvenirsRsp()
  log(bWriteLog and "logic_lobby_souvenirs:OnCancelShowSouvenirsRsp")
  self:SetMyShowSouvenirsId(0)
  self:SetCurShowSouvenirsId(0)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOUVENIRS, EVENTID_LOBBY_SOUVENIRS_UNSHOW)
  ShowNotice(77873)
end
function logic_lobby_souvenirs:SendSouvenirsGiftReq(collection_id, shared_with_uid)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  LobbySouvenirsHandler.send_share_collection_req(collection_id, shared_with_uid)
end
function logic_lobby_souvenirs:OnSouvenirsGiftRsp(collection_id, gift_time)
  log(bWriteLog and "logic_lobby_souvenirs:OnSouvenirsGiftRsp collection_id = " .. collection_id .. " gift_time = " .. tostring(gift_time))
  self:SetSouvenirsShareCount(collection_id, gift_time)
end
function logic_lobby_souvenirs:set_progressed_collection_seen_req(collection_id)
  log(bWriteLog and "logic_lobby_souvenirs:OnSouvenirsGiftRsp collection_id = " .. collection_id)
  local LobbySouvenirsHandler = require("client.network.Protocol.LobbySouvenirsHandler")
  LobbySouvenirsHandler.send_set_progressed_collection_seen_req(collection_id)
end
function logic_lobby_souvenirs:proc_progressed_collection_seen_rsp(collection_id, statuslist)
  log(bWriteLog and "logic_lobby_souvenirs:proc_progressed_collection_seen_rsp collection_id =" .. tostring(collection_id))
  if statuslist and next(statuslist) then
    self.progressedCollections[collection_id] = statuslist
  end
end
function logic_lobby_souvenirs:proc_notify_pre_collection_status_rsp(pre_collection_update)
  log(bWriteLog and "logic_lobby_souvenirs:proc_notify_pre_collection_status_rsp")
  if self.progressedCollections and next(self.progressedCollections) then
    for collection_id, precollection_status in pairs(pre_collection_update) do
      if self.progressedCollections[collection_id] then
        local precollection_id, status = next(precollection_status)
        self.progressedCollections[collection_id][precollection_id] = status
      else
        log(bWriteLog and "logic_lobby_souvenirs:proc_notify_pre_collection_status_rsp  self.progressedCollections[" .. tostring(collection_id) .. "] = nil")
      end
    end
  end
end
function logic_lobby_souvenirs:InAppidTest(appid, appids)
  local id = tonumber(appid)
  if not id then
    return false
  end
  if not appids or appids == "" then
    return false
  end
  local StringUtil = require("common.string_util")
  local appIDList = StringUtil.Split(appids, "|")
  for _, appID in ipairs(appIDList) do
    if id == tonumber(appID) then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_souvenirs = class(CModuleBase, nil, logic_lobby_souvenirs)
return Clogic_lobby_souvenirs