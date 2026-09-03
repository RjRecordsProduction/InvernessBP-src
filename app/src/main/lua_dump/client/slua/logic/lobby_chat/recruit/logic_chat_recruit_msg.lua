local logic_chat_recruit_msg = {}
local Enum_SearchReason = {Chat = 0, Lobby = 1}
local Enum_ErrorCode = {err_team_conscribe_not_enough_credit = 100220021}
local ErrorCodeTipsConfig = {
  [Enum_ErrorCode.err_team_conscribe_not_enough_credit] = 47363
}
local CONST_REQUEST_CREDIT_INTERVAL = 60
local isSwitchOpen, recruitTeamList, isInitCfgData
local reqInterValTime = 5
local reqFastInterValTime = 3
local reqSlowInterValTime = 5
local lastReqGetRecruitTeamTime = 0
local addMsgToLobbyEntranceInterval = 20
local addMsgToLobbyEntranceTime = 0
local saveDataSendTime
local showMsgSeveralTime = 3
local minShowMsgCount = 3
local showMsgSpeed = 3
local showMsgIntervalTime = 2
local showErrorCodeList
local lastRequestUpdateCreditTime = 0
local SelectTeamRecruitTabId = 0
local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
local _InitCfgData = function()
  if isInitCfgData then
    return
  end
  local cfg = CDataTable.GetTableData("TeamPlatformParamConfig", "ReqRecruitTeamInterval")
  if cfg then
    reqSlowInterValTime = cfg.ParamValue
    reqInterValTime = cfg.ParamValue
  end
  local fastTimeCfg = CDataTable.GetTableData("TeamPlatformParamConfig", "FastReqRecruitTeamInterval")
  if fastTimeCfg then
    reqFastInterValTime = fastTimeCfg.ParamValue
  end
  local addLobbyMsgTimeCfg = CDataTable.GetTableData("TeamPlatformParamConfig", "ShowMsgInChatEntranceInterval")
  if addLobbyMsgTimeCfg then
    addMsgToLobbyEntranceInterval = addLobbyMsgTimeCfg.ParamValue
  end
  local batchNumCfg = CDataTable.GetTableData("TeamPlatformParamConfig", "BatchDisplayMsgNum")
  if batchNumCfg then
    showMsgSeveralTime = batchNumCfg.ParamValue
  end
  local minSpeedCfg = CDataTable.GetTableData("TeamPlatformParamConfig", "MinNumShowMsgOnce")
  if minSpeedCfg then
    minShowMsgCount = minSpeedCfg.ParamValue
  end
  isInitCfgData = true
end
local _InitData = function()
  _InitCfgData()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  addMsgToLobbyEntranceTime = curTime
  log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg.InitData, curTime is:" .. tostring(curTime))
end
local _UpdateShowMsgSpeed = function()
  local currentMsgTotalCount = recruitTeamList and #recruitTeamList or 0
  if currentMsgTotalCount <= 0 then
    return
  end
  local speed = #recruitTeamList / showMsgSeveralTime
  showMsgSpeed = math.floor(speed + FLOAT_NUMBER_TRAIL)
  log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg.UpdateShowMsgSpeed, showMsgSpeed is\239\188\154" .. tostring(showMsgSpeed))
  if showMsgSpeed < minShowMsgCount then
    showMsgSpeed = minShowMsgCount
  end
end
function logic_chat_recruit_msg:OnInitialize()
  logic_chat_recruit_msg.__super.OnInitialize(self)
  _InitData()
end
function logic_chat_recruit_msg:OnLogin(bReLogin)
end
function logic_chat_recruit_msg:OnLogOut()
  isSwitchOpen = nil
  recruitTeamList = nil
  isInitCfgData = nil
  self:ClearDelayShowTimer()
  showErrorCodeList = nil
  lastRequestUpdateCreditTime = 0
end
function logic_chat_recruit_msg:OnPostSwitchGameStatus(preState, nextState)
  if nextState ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    self:ClearDelayShowTimer()
  end
end
function logic_chat_recruit_msg:IsNewPlanOpen()
  return isSwitchOpen
end
function logic_chat_recruit_msg:UpdateNewPlanSwitch(isOpen)
  log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg:UpdateNewPlanSwitch, isOpen is:" .. tostring(isOpen))
  isSwitchOpen = isOpen
end
function logic_chat_recruit_msg:ClearRecruitTeamListData()
  recruitTeamList = nil
end
function logic_chat_recruit_msg:GetLastReqRecruitDataTime()
  return lastReqGetRecruitTeamTime or 0
end
function logic_chat_recruit_msg:GetReqMsgIntervalTime()
  return reqInterValTime
end
function logic_chat_recruit_msg:ClearDelayShowTimer()
  if self.delayShowMsgTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.delayShowMsgTimer)
    self.delayShowMsgTimer = nil
  end
end
function logic_chat_recruit_msg:ShowRecruitMsgInChatEntrance()
  if not TeamPlatformSystem.IsCanEnter() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) then
    self:RequestMsgInChatUI(nowTime)
    return
  end
  local logic_chat_filter_language = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_filter_language)
  if logic_chat_filter_language:IsContainEnglish() then
    return
  end
  if not self:IsCanAddToChat(nowTime) then
    return
  end
  if recruitTeamList and 0 < #recruitTeamList then
    local chatMsg = recruitTeamList[1]
    local logicMain = require("client.slua.logic.lobby_chat.logic_chat_main")
    logicMain.AddOneChatMsg(chatMsg)
    local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
    logic_chat_table_pool.Recycle(recruitTeamList[1])
    table.remove(recruitTeamList, 1)
  else
    local lasReqTime = self:GetLastReqRecruitDataTime()
    if nowTime - lasReqTime > addMsgToLobbyEntranceInterval then
      self:ReqSearchRecruitTeamData(Enum_SearchReason.Lobby)
    end
  end
end
function logic_chat_recruit_msg:OnReceiveSelfPublishTeamRecruitMsg(msg)
  if not self:IsNewPlanOpen() then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] params, logic_chat_recruit_msg:OnReceiveSelfPublishTeamRecruitMsg  msg is:", msg)
  local logicMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  logicMain.AddOneChatMsg(msg)
end
function logic_chat_recruit_msg:IsCanShowMsgInLobbyEntrance()
  if not self:IsNewPlanOpen() then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if self:IsCanAddToChat(nowTime) then
    self:UpdateRecruitMsgInLobbyTime(nowTime)
    return true
  end
  return false
end
function logic_chat_recruit_msg:UpdateRecruitMsgInLobbyTime(time)
  log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg:UpdateRecruitMsgInLobbyTime, time is:" .. tostring(time))
  addMsgToLobbyEntranceTime = time
end
function logic_chat_recruit_msg:ClearDataWhenOpenChat()
  if not self:IsNewPlanOpen() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self:IsCanRequestMsgInChat(nowTime, reqFastInterValTime) then
    return
  end
  self:ClearMsgList()
end
function logic_chat_recruit_msg:CheckShowErrorMsg()
  if not self:IsNewPlanOpen() then
    return
  end
  showErrorCodeList = nil
  if TeamPlatformSystem.IsCanEnter() then
    return
  end
  local errorCode = TeamPlatformSystem.GetErrorCode()
  log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg:CheckShowErrorMsg, errorCode is:" .. tostring(errorCode))
  if errorCode == 0 then
    return
  end
  self:ShowErrorCodeTips(errorCode)
end
function logic_chat_recruit_msg:ClearMsgList()
  if not recruitTeamList then
    return
  end
  local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
  logic_chat_table_pool.RecycleAll(recruitTeamList)
end
function logic_chat_recruit_msg:ShowRecruitMsg()
  if not recruitTeamList or #recruitTeamList <= 0 then
    return
  end
  if self.delayShowMsgTimer then
    return
  end
  local time_ticker = require("common.time_ticker")
  local logicMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
  self.delayShowMsgTimer = time_ticker.AddTimer(0, function()
    while 0 < #recruitTeamList do
      local totalNum = #recruitTeamList
      if totalNum < showMsgSpeed then
        showMsgSpeed = totalNum
      end
      for i = 1, showMsgSpeed do
        if 0 < #recruitTeamList then
          local chatMsg = recruitTeamList[1]
          logicMain.AddOneChatMsg(chatMsg)
          logic_chat_table_pool.Recycle(recruitTeamList[1])
          table.remove(recruitTeamList, 1)
        end
      end
      coroutine.yield(showMsgIntervalTime)
    end
    self:ClearDelayShowTimer()
  end)
end
function logic_chat_recruit_msg:AddMsgToChatEntrance(time, msg)
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.SetChatEntranceMsg(msg)
  addMsgToLobbyEntranceTime = time
end
function logic_chat_recruit_msg:IsCanAddToChat(nowTime)
  if nowTime - addMsgToLobbyEntranceTime < addMsgToLobbyEntranceInterval then
    return false
  end
  return true
end
function logic_chat_recruit_msg:UpdateReqSendTime(time)
  saveDataSendTime = time
end
function logic_chat_recruit_msg:UpdateNextRequestIntervalTime(bHaveData)
  if bHaveData then
    reqInterValTime = reqSlowInterValTime
  else
    reqInterValTime = reqFastInterValTime
  end
  showMsgIntervalTime = reqInterValTime / showMsgSeveralTime
  if showMsgIntervalTime <= 0 then
    showMsgIntervalTime = 1
  end
end
function logic_chat_recruit_msg:RequestMsgInChatUI(nowTime)
  if not self:IsCanRequestMsgInChat(nowTime) then
    return
  end
  self:ReqSearchRecruitTeamData(Enum_SearchReason.Chat)
end
function logic_chat_recruit_msg:IsCanRequestMsgInChat(nowTime, intervalTime)
  local lasReqTime = self:GetLastReqRecruitDataTime()
  intervalTime = intervalTime or self:GetReqMsgIntervalTime()
  if intervalTime > nowTime - lasReqTime then
    return false
  end
  return true
end
function logic_chat_recruit_msg:ShowErrorCodeTips(err_code)
  if showErrorCodeList and showErrorCodeList[err_code] then
    return
  end
  if not showErrorCodeList then
    showErrorCodeList = {}
  end
  showErrorCodeList[err_code] = true
  ShowNotice(ErrorCodeTipsConfig[err_code] or err_code)
end
function logic_chat_recruit_msg:ReqSearchRecruitTeamData(search_reason)
  local worthValue = -1
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    worthValue = 0
  end
  local logic_chat_filter_language = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_filter_language)
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.GetChooseZone() or 0
  if zoneID <= 0 then
    zoneID = 1
  end
  local condition = {
    filter_langs = logic_chat_filter_language:GetCurSelectLanguageData(),
    worth = worthValue,
    chat_time = saveDataSendTime,
    zone = zoneID,
    zone_list = logic_team_platform_utils.GetZoneList()
  }
  local TimeUtil = require("client.common.time_util")
  lastReqGetRecruitTeamTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg:ReqSearchTeamRecruitData, time is:" .. tostring(lastReqGetRecruitTeamTime) .. " search_reason is:" .. tostring(search_reason))
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_search_team_recruit_req(condition, search_reason)
end
function logic_chat_recruit_msg:OnSearchTeamRecruitDataRsp(err_code, msg_list)
  if err_code ~= 0 then
    log(bWriteLog and "[v_wllwu] ChatHandler.OnSearchTeamRecruitDataRsp, err_code is:" .. tostring(err_code))
    self:HandleErrorCode(err_code)
    return
  end
  print(bWriteLog and "[v_wllwu] logic_chat_recruit_msg.on_search_team_recruit_rsp, msg_list count:", msg_list and #msg_list)
  if not msg_list or #msg_list <= 0 then
    self:UpdateNextRequestIntervalTime(false)
    return
  end
  table.sort(msg_list, function(a, b)
    local aSendTime = a.chat_time or 0
    local bSendTime = b.chat_time or 0
    return aSendTime < bSendTime
  end)
  if not recruitTeamList then
    recruitTeamList = {}
  end
  local count = 0
  local StringUtil = require("common.string_util")
  local logic_chat_channel_team_recruit = require("client.slua.logic.lobby_chat.logic_chat_channel_team_recruit")
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  for _, v in ipairs(msg_list) do
    local msg = base64.DecodeBase64(v.base64bin)
    if msg then
      msg = slua.LuaArchiverDecode(LuaStateWrapper, msg)
      if msg then
        if logic_chat_channel_team_recruit.TeamPlatFormRecruitMsgTypeFilter(msg.chat_content) then
          msg.chat_content.team_id = v.team_id
          msg.chat_content.player_count = v.player_count
          msg.chat_content.team_size = v.team_size
          table.insert(recruitTeamList, msg)
          count = count + 1
        else
          log(bWriteLog and "[v_wllwu] logic_chat_recruit_msg:OnSearchTeamRecruitDataRsp, fiter msg >>> v.chat_content is:" .. tostring(msg.chat_content.team_id))
        end
      end
    end
  end
  self:UpdateReqSendTime(msg_list[#msg_list].chat_time)
  self:UpdateNextRequestIntervalTime(0 < count)
  if #recruitTeamList <= 0 then
    return
  end
  _UpdateShowMsgSpeed()
  if UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) then
    self:ShowRecruitMsg()
  end
end
function logic_chat_recruit_msg:HandleErrorCode(err_code)
  if not err_code then
    return
  end
  if err_code == Enum_ErrorCode.err_team_conscribe_not_enough_credit then
    local TimeUtil = require("client.common.time_util")
    local severTime = TimeUtil.GetServerTimeInSec()
    if severTime - lastRequestUpdateCreditTime > CONST_REQUEST_CREDIT_INTERVAL then
      TeamPlatformSystem.ReqGetEntryStatus(true)
      lastRequestUpdateCreditTime = severTime
    end
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) then
    return
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.channelTeamRecruit then
    return
  end
  self:ShowErrorCodeTips(err_code)
end
function logic_chat_recruit_msg:SetSelectTeamRecruitTabId(tabId)
  SelectTeamRecruitTabId = tabId
end
function logic_chat_recruit_msg:GetSelectTeamRecruitTabId()
  return SelectTeamRecruitTabId
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_chat_recruit_msg = class(CModuleBase, nil, logic_chat_recruit_msg)
return Clogic_chat_recruit_msg