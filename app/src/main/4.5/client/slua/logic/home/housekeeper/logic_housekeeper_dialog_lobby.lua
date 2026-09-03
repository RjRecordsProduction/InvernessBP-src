local logic_housekeeper_dialog_lobby = {bIsTestInvalid = false}
function logic_housekeeper_dialog_lobby:DefineAndResetData()
  self.curHousekeeperId = 0
  self.curHouseKeeperInfo = nil
  self.maxHistoryNum = 30
  self.historyChatList = nil
  self.shouldReportHistory = false
  self.historyTimerHandle = nil
  self.serverInitNodeId = 0
  self.startNodeId = 0
  self.C_MAX_NODE_NUM = 3
  self.nextStepDelay = 2.5
  self.nextStepTimerHandle = nil
end
function logic_housekeeper_dialog_lobby:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_HKP_USE_ID_CHANGE, self.OnHouseKeeperIDChange, self)
end
function logic_housekeeper_dialog_lobby:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    self:send_manor_butler_history_dialogue_req(0, true)
  else
    log(bWriteLog and "logic_housekeeper_dialog_lobby:OnPostSwitchGameStatus not lobby")
    if not GameStatus.IsInMainCity() then
      self:StopHistoryTimer()
      self:StopNextStepTimer()
    end
  end
end
function logic_housekeeper_dialog_lobby:OnLogOut()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:OnLogOut")
  self:ClearData()
end
function logic_housekeeper_dialog_lobby:GetNodeSheetName(housekeeperId)
  local sheetId = CDataTable.GetTableData("Housekeeper_Tree_cfg", housekeeperId).TreeCfgID
  return string.format("Housekeeper_Dialog_Node_Lobby%s", sheetId)
end
function logic_housekeeper_dialog_lobby:GetConditionSheetName(housekeeperId)
  local sheetId = CDataTable.GetTableData("Housekeeper_Tree_cfg", housekeeperId).TreeCfgID
  return string.format("Housekeeper_Dialog_Condition_Lobby%s", sheetId)
end
function logic_housekeeper_dialog_lobby:GetHouseOwnerName()
  return DataMgr.roleData.nickName
end
function logic_housekeeper_dialog_lobby:GetHousekeeperName()
  local curHousekeeperId = self:GetCurHousekeeperId()
  local logic_home_housekeeper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_housekeeper)
  local hkName = logic_home_housekeeper:GetHouseKeeperName(curHousekeeperId)
  return hkName
end
function logic_housekeeper_dialog_lobby:OnHouseKeeperIDChange(_, _, id, belong_uid, detail)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:OnHouseKeeperIDChange id:" .. tostring(id))
  self:ClearData()
  local logic_home_housekeeper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_housekeeper)
  local info = logic_home_housekeeper:GetHousekeeperInfo(id)
  if info then
    if self.curHouseKeeperInfo == nil then
      self.curHouseKeeperInfo = {}
    end
    self.curHouseKeeperInfo.level = info.level or 0
    log(bWriteLog and "logic_housekeeper_dialog_lobby:OnHouseKeeperIDChange level:" .. tostring(self.curHouseKeeperInfo.level))
  else
    log(bWriteLog and "logic_housekeeper_dialog_lobby:OnHouseKeeperIDChange no info")
  end
  if self.curHouseKeeperInfo and belong_uid then
    self.curHouseKeeperInfo.  end
  self:SetCurHousekeeperId(id)
  if GameStatus.IsInLobbyOrMainCity() then
    self:send_manor_butler_history_dialogue_req(0, true)
  end
end
function logic_housekeeper_dialog_lobby:SetCurHousekeeperId(hkpId)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:SetCurHousekeeperId hkpId:" .. tostring(hkpId))
  if hkpId <= 0 then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:SetCurHousekeeperId invalid id")
    return
  end
  self.curHousekeeperId = hkpId
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.SetHouseKeeperToFriend(hkpId)
end
function logic_housekeeper_dialog_lobby:GetCurHousekeeperId()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:GetCurHousekeeperId curHousekeeperId:" .. tostring(self.curHousekeeperId))
  return self.curHousekeeperId
end
function logic_housekeeper_dialog_lobby:UpdateCurHousekeeperLv(hkpId, newLevel)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateCurHousekeeperLv hkpId:" .. tostring(hkpId) .. " ,newLevel:" .. tostring(newLevel))
  if not self.curHouseKeeperInfo then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateCurHousekeeperLv no curHouseKeeperInfo")
    return
  end
  if hkpId ~= self.curHousekeeperId then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateCurHousekeeperLv not curHousekeeper")
    return
  end
  if self.curHouseKeeperInfo.level == newLevel then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateCurHousekeeperLv no update")
    return
  end
  self.curHouseKeeperInfo.level = newLevel
end
function logic_housekeeper_dialog_lobby:GetCurHousekeeperLv()
  if not self.curHouseKeeperInfo then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:GetCurHousekeeperLv no curHouseKeeperInfo")
    return 0
  end
  return self.curHouseKeeperInfo.level
end
function logic_housekeeper_dialog_lobby:IsHouseKeeper(id)
  id = tonumber(id)
  if not id then
    return false
  end
  local logic_housekeeper_AI = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_AI)
  id = id % logic_housekeeper_AI.ORIGIN_DIGIT
  local hkpCfg = CDataTable.GetTableData("PlanPH_Housekeeper_cfg", id)
  return hkpCfg ~= nil
end
function logic_housekeeper_dialog_lobby:ResetChatState()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:ResetChatState")
  self:StopNextStepTimer()
  local curHousekeeperId = self:GetCurHousekeeperId()
  if curHousekeeperId <= 0 then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ResetChatState no id")
    return
  end
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local refMsg = logic_chat_channel_friend.GetFriendChatData(curHousekeeperId)
  if not refMsg then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ResetChatState no refMsg")
    return
  end
  for _, v in pairs(refMsg.messageList) do
    if v.content.newMsg then
      v.content.newMsg = false
    end
  end
end
function logic_housekeeper_dialog_lobby:StopHistoryTimer()
  if self.historyTimerHandle then
    self:RemoveTimer(self.historyTimerHandle)
    self.historyTimerHandle = nil
  end
end
function logic_housekeeper_dialog_lobby:StopNextStepTimer()
  if self.nextStepTimerHandle then
    self:RemoveTimer(self.nextStepTimerHandle)
    self.nextStepTimerHandle = nil
  end
end
function logic_housekeeper_dialog_lobby:UpdateOpenManorButler()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateOpenManorButler")
  if not LobbySystem.roleData.open_manor_butler then
    LobbySystem.roleData.open_manor_butler = true
  end
end
function logic_housekeeper_dialog_lobby:StartHouseKeeperChat()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:StartHouseKeeperChat")
  local curHousekeeperId = self:GetCurHousekeeperId()
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportDelay(TLogEventDefine.HouseKeeper_Chat_Lobby_Open_Chat, curHousekeeperId)
  if not self:CanStartHouseKeeperChat() then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:StartHouseKeeperChat cannot start")
    return
  end
  if self:CheckShowOptions() then
    local lastChat = self:GetLastChat()
    local options = self:GetOptionListByID(curHousekeeperId, lastChat.nodeId) or {}
    if next(options) then
      log(bWriteLog and "logic_housekeeper_dialog_lobby:StartHouseKeeperChat show options")
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_HKP_DIALOG_SHOW_OPTIONS, lastChat.nodeId, options)
    end
  else
    local startNodeId = self:GetStartNodeId()
    if 0 < curHousekeeperId and 0 < startNodeId then
      log(bWriteLog and "logic_housekeeper_dialog_lobby:StartHouseKeeperChat chat round")
      self:AddHouseKeeperRealTimeChat(curHousekeeperId, startNodeId)
      self:send_manor_butler_read_action_id_req(curHousekeeperId, startNodeId)
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.HouseKeeper_Chat_Lobby_Start, startNodeId)
    end
  end
end
function logic_housekeeper_dialog_lobby:AddHouseKeeperRealTimeChat(housekeeperId, nodeId)
  log(bWriteLog and string.format("logic_housekeeper_dialog_lobby:AddHouseKeeperRealTimeChat housekeeperId:%d, nodeId:%d", housekeeperId, nodeId))
  local msgText = self:GetNodeTextByID(housekeeperId, nodeId)
  self:AddHouseKeeperChat(housekeeperId, nodeId, msgText, true)
  self:SetHouseKeeperHistoryChat(nodeId, msgText)
  self:UpdateNextNodeId(housekeeperId, nodeId)
  self:StopNextStepTimer()
  self.nextStepTimerHandle = self:AddTimerOnce(self.nextStepDelay, function()
    self:ShowNextChat(housekeeperId, nodeId)
  end)
end
function logic_housekeeper_dialog_lobby:UpdateNextNodeId(housekeeperId, nodeId)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateNextNodeId cur nodeId:" .. tostring(nodeId))
  local nodeInfo = self:GetNodeInfoByID(housekeeperId, nodeId)
  if not nodeInfo then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateNextNodeId no nodeInfo")
    return
  end
  if nodeInfo.NextID > 0 then
    self:SetStartNodeId(nodeInfo.NextID)
  else
    local options = self:GetOptionListByID(housekeeperId, nodeId) or {}
    if not next(options) then
      self:SetStartNodeId(0)
    end
  end
end
function logic_housekeeper_dialog_lobby:FormatHousekeeperChat(housekeeperId, nodeId, msgText, newMsg, sort)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local chat_content = {
    msgType = chat_macro.HouseKeeperChatMsgType,
    text = msgText,
    housekeeperId = housekeeperId,
    nodeId = nodeId,
    newMsg = newMsg,
      }
  local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local send_uid = tonumber(housekeeperId)
  local uid = chat_main.GetIdStr(send_uid)
  return chat_main.SetNewChat(logic_chat_table_pool.Get(), "", chat_macro.Channel.channelPrivate, send_uid, uid, nil, nil, chat_content, send_uid == tonumber(DataMgr.roleData.uid))
end
function logic_housekeeper_dialog_lobby:AddHouseKeeperChat(housekeeperId, nodeId, msgText, newMsg)
  local chatMsg = self:FormatHousekeeperChat(housekeeperId, nodeId, msgText, newMsg)
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local refMsg = logic_chat_channel_friend.CheckAndCreateChatMsg(chatMsg.uid)
  chatMsg.content.sort = #refMsg.messageList + 1
  logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
  table.sort(refMsg.messageList, function(a, b)
    if not a.content.sort or not b.content.sort then
      return false
    else
      return a.content.sort < b.content.sort
    end
  end)
end
function logic_housekeeper_dialog_lobby:ShowNextChat(housekeeperId, nodeId)
  log(bWriteLog and string.format("logic_housekeeper_dialog_lobby:ShowNextChat housekeeperId:%d, nodeId:%d", housekeeperId, nodeId))
  local nodeInfo = self:GetNodeInfoByID(housekeeperId, nodeId)
  if not nodeInfo then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ShowNextChat no nodeInfo")
    return
  end
  if nodeInfo.NextID > 0 then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ShowNextChat next housekeeper chat")
    self:AddHouseKeeperRealTimeChat(housekeeperId, nodeInfo.NextID)
  else
    local options = self:GetOptionListByID(housekeeperId, nodeId) or {}
    if next(options) then
      log(bWriteLog and "logic_housekeeper_dialog_lobby:ShowNextChat player options")
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_HKP_DIALOG_SHOW_OPTIONS, nodeId, options)
    else
      log(bWriteLog and "logic_housekeeper_dialog_lobby:ShowNextChat chat over")
    end
  end
end
function logic_housekeeper_dialog_lobby:SetPlayerOption(nodeId, option)
  local tb = {nodeId = nodeId, option = option}
  log_tree(bWriteLog and "logic_housekeeper_dialog_lobby:SetPlayerOption tb:", tb)
  local curHousekeeperId = self:GetCurHousekeeperId()
  self:AddPlayerChat(curHousekeeperId, option.Text)
  self:SetPlayerHistoryChat(nodeId, option.SelectID, option.Text)
  self:ReportManorDialogue(option.SelectID)
  local jumpType, jumpParam = self:ParseJumpParam(option.Next)
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  if jumpType == PlanPH_Housekeeper_Config.JumpType.GameUrl then
    GlobalData.JumpUrl(jumpParam)
    self:SetStartNodeId(0)
  elseif 0 < jumpParam then
    self:SetStartNodeId(jumpParam)
    self:AddHouseKeeperRealTimeChat(curHousekeeperId, jumpParam)
  else
    self:SetStartNodeId(0)
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.HouseKeeper_Chat_Lobby_Option, nodeId, tostring(option.SelectID))
end
function logic_housekeeper_dialog_lobby:FormatPlayerChatMsg(housekeeperId, msgText, sort)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local chat_content = {
    msgType = chat_macro.HouseKeeperChatMsgType,
    text = msgText,
      }
  local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local send_uid = tonumber(DataMgr.roleData.uid)
  return chat_main.SetNewChat(logic_chat_table_pool.Get(), "", chat_macro.Channel.channelPrivate, send_uid, housekeeperId, nil, nil, chat_content, send_uid == tonumber(DataMgr.roleData.uid))
end
function logic_housekeeper_dialog_lobby:AddPlayerChat(housekeeperId, msgText)
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local chatMsg = self:FormatPlayerChatMsg(housekeeperId, msgText)
  local refMsg = logic_chat_channel_friend.CheckAndCreateChatMsg(chatMsg.uid)
  if not refMsg then
    return
  end
  chatMsg.content.sort = #refMsg.messageList + 1
  logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
  table.sort(refMsg.messageList, function(a, b)
    if not a.content.sort or not b.content.sort then
      return false
    else
      return a.content.sort < b.content.sort
    end
  end)
end
function logic_housekeeper_dialog_lobby:UpdateChatRedPoint(housekeeperId)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:UpdateChatRedPoint housekeeperId:" .. tostring(housekeeperId))
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local refMsg = logic_chat_channel_friend.CheckAndCreateChatMsg(housekeeperId)
  logic_chat_channel_friend.SetMsgNewMessageCount(refMsg)
  logic_chat_channel_friend.RefreshTotalUnread(housekeeperId)
  logic_chat_channel_friend.RefreshUnreadList(housekeeperId, refMsg.newMessageCount)
end
function logic_housekeeper_dialog_lobby:SetHouseKeeperHistoryChat(nodeId, hkpMsg)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:SetHouseKeeperHistoryChat")
  if self.historyChatList == nil then
    self.historyChatList = {}
  end
  if #self.historyChatList >= self.maxHistoryNum then
    table.remove(self.historyChatList, 1)
  end
  table.insert(self.historyChatList, {nodeId = nodeId, hkpMsg = hkpMsg})
  self.shouldReportHistory = true
end
function logic_housekeeper_dialog_lobby:SetPlayerHistoryChat(nodeId, optionId, optionText)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:SetPlayerHistoryChat")
  if self.historyChatList == nil then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:SetPlayerHistoryChat no history")
    return
  end
  local lastChat = self:GetLastChat()
  if lastChat.nodeId ~= nodeId then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:SetPlayerHistoryChat data error")
    return
  end
  lastChat.  lastChat.  self.shouldReportHistory = true
end
function logic_housekeeper_dialog_lobby:SaveDialogueToServer()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:SaveDialogueToServer")
  if self.historyChatList == nil then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:SaveDialogueToServer no history")
    return
  end
  if not self.shouldReportHistory then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:SaveDialogueToServer should not ReportHistory")
    return
  end
  log_tree("logic_housekeeper_dialog_lobby:SaveDialogueToServer", self.historyChatList)
  local curHousekeeperId = self:GetCurHousekeeperId()
  local bin_info = slua.LuaArchiverEncode(LuaStateWrapper, self.historyChatList)
  self:send_manor_butler_save_dialogue_req(curHousekeeperId, true, bin_info)
  self.shouldReportHistory = false
end
function logic_housekeeper_dialog_lobby:ProcessHistoryChat(curHousekeeperId, bin_info, butler_info)
  self.curHouseKeeperInfo = butler_info
  self:SetCurHousekeeperId(curHousekeeperId)
  if bin_info and bin_info ~= "" then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ProcessHistoryChat have history")
    self:GenerateHistoryChatList(bin_info)
    self:AddHistoryChat()
    self:ReqHouseKeeperChatData(true)
    local logic_AIChat_Adult = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_AIChat_Adult)
    logic_AIChat_Adult:CallAgegateSDK()
  else
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ProcessHistoryChat no history")
    self:send_manor_butler_init_action_id_req(true)
  end
end
function logic_housekeeper_dialog_lobby:GenerateHistoryChatList(bin_info)
  local info = slua.LuaArchiverDecode(LuaStateWrapper, bin_info) or {}
  local curHistoryNum = #info
  log_tree(bWriteLog and "logic_housekeeper_dialog_lobby:GenerateHistoryChatList info:", info)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:GenerateHistoryChatList curHistoryNum:" .. tostring(curHistoryNum))
  if curHistoryNum <= self.maxHistoryNum then
    self.historyChatList = info
  else
    self.historyChatList = {}
    for idx = curHistoryNum - self.maxHistoryNum + 1, curHistoryNum do
      table.insert(self.historyChatList, info[idx])
    end
  end
  log_tree(bWriteLog and "logic_housekeeper_dialog_lobby:GenerateHistoryChatList historyChatList:", self.historyChatList)
end
function logic_housekeeper_dialog_lobby:AddHistoryChat()
  local curHousekeeperId = self:GetCurHousekeeperId()
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local send_uid = tonumber(curHousekeeperId)
  local uid = chat_main.GetIdStr(send_uid)
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local refMsg = logic_chat_channel_friend.CheckAndCreateChatMsg(uid)
  if not refMsg then
    return
  end
  if refMsg.messageList then
    refMsg.messageList:ClearData()
  end
  local sort = 1
  for _, chatData in ipairs(self.historyChatList) do
    if chatData.hkpMsg then
      log(bWriteLog and string.format("logic_housekeeper_dialog_lobby:AddHistoryChat house: %s", chatData.hkpMsg))
      local chatMsg = self:FormatHousekeeperChat(curHousekeeperId, chatData.nodeId, chatData.hkpMsg, false, sort)
      logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
      sort = sort + 1
    end
    if chatData.optionId and chatData.optionText then
      log(bWriteLog and string.format("logic_housekeeper_dialog_lobby:AddHistoryChat player: %s", chatData.optionText))
      local chatMsg = self:FormatPlayerChatMsg(curHousekeeperId, chatData.optionText, sort)
      logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
      sort = sort + 1
    end
  end
end
function logic_housekeeper_dialog_lobby:AddHouseKeeperHistoryChat(chatData)
  if not (chatData and chatData.nodeId) or not chatData.hkpMsg then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:AddHouseKeeperHistoryChat invalid data")
    return
  end
  local curHousekeeperId = self:GetCurHousekeeperId()
  self:AddHouseKeeperChat(curHousekeeperId, chatData.nodeId, chatData.hkpMsg, false)
end
function logic_housekeeper_dialog_lobby:AddPlayerHistoryChat(chatData)
  if not (chatData and chatData.optionId) or not chatData.optionText then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:AddPlayerHistoryChat invalid data")
    return
  end
  local curHousekeeperId = self:GetCurHousekeeperId()
  self:AddPlayerChat(curHousekeeperId, chatData.optionText)
end
function logic_housekeeper_dialog_lobby:IsDialogOver()
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  return self:GetDialogStatus() == PlanPH_Housekeeper_Config.DialogStatus.Over
end
function logic_housekeeper_dialog_lobby:GetDialogStatus()
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  if self.historyChatList == nil or not next(self.historyChatList) then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:GetDialogStatus no history")
    return PlanPH_Housekeeper_Config.DialogStatus.Over
  end
  local lastChat = self:GetLastChat()
  log_tree(bWriteLog and "logic_housekeeper_dialog_lobby:GetDialogStatus lastChat:", lastChat)
  local curHousekeeperId = self:GetCurHousekeeperId()
  if not curHousekeeperId then
    return PlanPH_Housekeeper_Config.DialogStatus.Over
  end
  local nodeInfo = self:GetNodeInfoByID(curHousekeeperId, lastChat.nodeId)
  if not nodeInfo then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:GetDialogStatus no nodeInfo")
    return PlanPH_Housekeeper_Config.DialogStatus.Over
  end
  if nodeInfo.NextID > 0 then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:GetDialogStatus NextID > 0")
    return PlanPH_Housekeeper_Config.DialogStatus.NextID, nodeInfo.NextID
  else
    local options = self:GetOptionListByID(curHousekeeperId, lastChat.nodeId) or {}
    if next(options) and not lastChat.optionId then
      log(bWriteLog and "logic_housekeeper_dialog_lobby:GetDialogStatus not select option")
      return PlanPH_Housekeeper_Config.DialogStatus.NoSetOption
    end
  end
  log(bWriteLog and "logic_housekeeper_dialog_lobby:GetDialogStatus default")
  return PlanPH_Housekeeper_Config.DialogStatus.Over
end
function logic_housekeeper_dialog_lobby:CheckShowOptions()
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  return self:GetDialogStatus() == PlanPH_Housekeeper_Config.DialogStatus.NoSetOption
end
function logic_housekeeper_dialog_lobby:GetLastChat()
  return self.historyChatList[#self.historyChatList]
end
function logic_housekeeper_dialog_lobby:ReportManorDialogue(optionId)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:ReportManorDialogue optionId:" .. tostring(optionId))
  local nodeCfg = CDataTable.GetTableData("Housekeeper_Dialog_Intimacy_cfg", optionId)
  if not nodeCfg then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ReportManorDialogue no config")
    return
  end
  local curHousekeeperId = self:GetCurHousekeeperId()
  self:send_manor_butler_dialogue_report_req(curHousekeeperId, optionId, true)
end
function logic_housekeeper_dialog_lobby:send_manor_butler_history_dialogue_req(butler_id, in_lobby)
  if self.historyChatList then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_history_dialogue_req historyChatList")
    self:ReqHouseKeeperChatData(false)
  else
    if not LobbySystem.roleData.open_manor_butler then
      log(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_history_dialogue_req not open_manor_butler")
      return
    end
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    if QRcodeRestrictManager:IsRestrictChat() then
      log(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_history_dialogue_req RestrictChat")
      return
    end
    local delay = math.random(20, 30)
    log(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_history_dialogue_req delay:" .. tonumber(delay))
    self:StopHistoryTimer()
    self.historyTimerHandle = self:AddTimerOnce(delay, function()
      local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
      PHomeHousekeeperHandler.send_manor_butler_history_dialogue_req(butler_id, in_lobby)
    end)
  end
end
function logic_housekeeper_dialog_lobby:on_manor_butler_history_dialogue_rsp(curHousekeeperId, bin_info, butler_info)
  self:ProcessHistoryChat(curHousekeeperId, bin_info, butler_info)
end
function logic_housekeeper_dialog_lobby:send_manor_butler_init_action_id_req(in_lobby)
  local butler_dialogue_ts = LobbySystem.roleData.butler_dialogue_ts or 0
  log(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_init_action_id_req butler_dialogue_ts:" .. tostring(butler_dialogue_ts))
  local TimeUtil = require("client.common.time_util")
  if butler_dialogue_ts > TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_init_action_id_req CD")
    return
  end
  local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
  PHomeHousekeeperHandler.send_manor_butler_init_action_id_req(in_lobby)
end
function logic_housekeeper_dialog_lobby:on_manor_butler_init_action_id_rsp(housekeeperId, NodeId, act_type, context, butler_dialogue_ts)
  self:SetCurHousekeeperId(housekeeperId)
  LobbySystem.roleData.  if 0 < NodeId then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:on_manor_butler_init_action_id_rsp NodeId:" .. tostring(NodeId))
    self.serverInit    self:SetStartNodeId(NodeId)
    self:SetMemory(context)
    self:UpdateChatRedPoint(housekeeperId)
  end
end
function logic_housekeeper_dialog_lobby:send_manor_butler_read_action_id_req(housekeeperId, nodeId)
  local tb = {
    housekeeperId = housekeeperId,
    nodeId = nodeId,
    serverInitNodeId = self.serverInitNodeId
  }
  log_tree(bWriteLog and "logic_housekeeper_dialog_lobby:send_manor_butler_read_action_id_req tb:", tb)
  if self.serverInitNodeId ~= nodeId then
    return
  end
  local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
  PHomeHousekeeperHandler.send_manor_butler_read_action_id_req(true, housekeeperId, nodeId)
end
function logic_housekeeper_dialog_lobby:SetStartNodeId(nodeId)
  log(bWriteLog and "logic_housekeeper_dialog_lobby:SetStartNodeId nodeId:" .. tostring(nodeId))
  self.startNodeId = nodeId
end
function logic_housekeeper_dialog_lobby:GetStartNodeId()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:GetStartNodeId startNodeId:" .. tostring(self.startNodeId))
  local status, extra = self:GetDialogStatus()
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  if status == PlanPH_Housekeeper_Config.DialogStatus.NextID and extra and 0 < extra and self.startNodeId ~= extra then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:GetStartNodeId modify id:" .. tostring(extra))
    self.startNodeId = extra
  end
  return self.startNodeId
end
function logic_housekeeper_dialog_lobby:CanStartHouseKeeperChat()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:CanStartHouseKeeperChat")
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  if not self:HaveMemory() then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:CanStartHouseKeeperChat no memory")
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.HouseKeeper_Chat_Lobby_Start, PlanPH_Housekeeper_Config.CannotStartDialogReason.NoMemory)
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, uidKey in ipairs(PlanPH_Housekeeper_Config.MemoryParamUidKeys) do
    local uid = self.memory[uidKey]
    if uid and 0 < uid then
      local profile = logic_profile:GetLocalProfile(uid)
      if not profile then
        log(bWriteLog and "logic_housekeeper_dialog_lobby:CanStartHouseKeeperChat no profile:" .. tostring(uid))
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.HouseKeeper_Chat_Lobby_Start, PlanPH_Housekeeper_Config.CannotStartDialogReason.NoProfile)
        return false
      end
    end
  end
  log(bWriteLog and "logic_housekeeper_dialog_lobby:CanStartHouseKeeperChat can")
  return true
end
function logic_housekeeper_dialog_lobby:ReqHouseKeeperChatData(firstInLobby)
  if self:IsDialogOver() then
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ReqHouseKeeperChatData dialog over")
    self:send_manor_butler_init_action_id_req(true)
  else
    log(bWriteLog and "logic_housekeeper_dialog_lobby:ReqHouseKeeperChatData not over")
    if not self:HaveMemory() then
      self:send_manor_butler_memmory_req(true)
    end
    local curHousekeeperId = self:GetCurHousekeeperId()
    if 0 < curHousekeeperId then
      do
        local delay = firstInLobby and 0 or 1
        log(bWriteLog and "logic_housekeeper_dialog_lobby:ReqHouseKeeperChatData delay:" .. tostring(delay))
        self:AddTimerOnce(delay, function()
          self:UpdateChatRedPoint(curHousekeeperId)
        end)
      end
    end
  end
end
function logic_housekeeper_dialog_lobby:ClearData()
  log(bWriteLog and "logic_housekeeper_dialog_lobby:ClearData")
  local curHousekeeperId = self:GetCurHousekeeperId()
  if curHousekeeperId then
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    local refMsg = logic_chat_channel_friend.GetFriendChatData(curHousekeeperId)
    if refMsg then
      refMsg.messageList:ClearData()
      logic_chat_channel_friend.RemoveFriendChatData(curHousekeeperId)
    end
  end
  self:DefineAndResetData()
end
function logic_housekeeper_dialog_lobby:IsTestInvalid()
  return self.bIsTestInvalid
end
local class = require("class")
local Clogic_housekeeper_dialog_base = require("client.slua.logic.home.housekeeper.logic_housekeeper_dialog_base")
return class(Clogic_housekeeper_dialog_base, nil, logic_housekeeper_dialog_lobby)