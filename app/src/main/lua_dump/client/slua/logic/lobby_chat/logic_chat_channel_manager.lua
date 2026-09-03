local logic_chat_channel_manager = {}
local _MakeInfoByChannel = function(channelId)
  return {channelId = channelId, isShowRedPoint = false}
end
function logic_chat_channel_manager:UpdateChannelList()
  if self.chatChannelList == nil then
    local super_list = require("common.super_list")
    self.chatChannelList = super_list.Create()
  else
    self.chatChannelList:ClearData()
  end
  local chatConfig = require("client.slua.umg.lobby_chat.chat_ui_config")
  for channelId, v in pairs(chatConfig.channel) do
    if self:IsCanShowChannel(v) then
      local channelInfo = _MakeInfoByChannel(channelId)
      if self.redPointInfoList and self.redPointInfoList[channelId] then
        channelInfo.isShowRedPoint = true
      end
      self.chatChannelList:AppendItem(channelInfo)
    end
  end
  self.redPointInfoList = nil
  if #self.chatChannelList <= 1 then
    return
  end
  table.sort(self.chatChannelList, function(a, b)
    local aTabId = chatConfig.channel[a.channelId].tabId or 0
    local bTabId = chatConfig.channel[b.channelId].tabId or 0
    return aTabId < bTabId
  end)
  self.CurGameStatus = GameStatus.GetGameStatus()
  log(bWriteLog and "logic_chat_channel_manager:UpdateChannelList GameStatus " .. tostring(GameStatus.GetGameStatus()))
  log_tree(bWriteLog and "[v_wllwu] logic_chat_channel_manager:UpdateChannelList, self.chatChannelList is:", self.chatChannelList)
end
function logic_chat_channel_manager:CheckUpdateChannelList()
  log(bWriteLog and "logic_chat_channel_manager:CheckUpdateChannelList()")
  if self.CurGameStatus ~= GameStatus.GetGameStatus() then
    self:UpdateChannelList()
    self.CurGameStatus = GameStatus.GetGameStatus()
  end
end
function logic_chat_channel_manager:UpdateOneChannelData(channelId)
  local chatConfig = require("client.slua.umg.lobby_chat.chat_ui_config")
  local channelConfig = chatConfig.channel[channelId]
  if channelConfig == nil then
    log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:UpdateOneChannelData error, channelId is:" .. tostring(channelId))
    return
  end
  if not self.chatChannelList then
    log_error(bWriteLog and "logic_chat_channel_manager:UpdateOneChannelData return of not self.chatChannelList")
    return
  end
  if self:IsCanShowChannel(channelConfig) then
    local isExist = self:IsChannelExist(channelId)
    if not isExist then
      local channelInfo = _MakeInfoByChannel(channelId)
      self.chatChannelList:AppendItem(channelInfo)
    end
    return
  end
  local index = self:GetChannelIndex(channelId)
  if index < 0 then
    return
  end
  self.chatChannelList:RemoveItem(index)
end
function logic_chat_channel_manager:OnInitialize()
  logic_chat_channel_manager.__super.OnInitialize(self)
  self.chatChannelList = nil
  self.redPointInfoList = nil
end
function logic_chat_channel_manager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_OPEN_LOBBY, self.OnTxmissionStateChange, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_LOBBY, self.OnTxmissionStateChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, self.OnUpdateSwitch, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_WAITING_OPEN, self.OnWaitingRoomStateChange, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_WAITING_CLOSE, self.OnWaitingRoomStateChange, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_MANOR_INFO_GET, self.OnGetManorInfo, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_HOME_ENTER_EDIT_HOME_SUCCESS, self.OnEnterEditHomeSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_HOME_EXIT_EDIT_HOME_SUCCESS, self.OnExitEditHomeSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_HOME_ENTER_EDIT_PLAN_SUCCESS, self.OnEnterEditPlanSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_HOME_EXIT_EDIT_PLAN_SUCCESS, self.OnExitEditPlanSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CLEAR_MODE, self.OnPlanPHClearMode, self)
end
function logic_chat_channel_manager:OnTxmissionStateChange()
  log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnTxmissionStateChange")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if self.redPointInfoList then
    self.redPointInfoList[chat_macro.Channel.channelTeamRecruit] = false
  end
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnTeamChange()
  log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnTeamChange")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local channel = chat_macro.Channel.channelTeam
  if self.redPointInfoList then
    self.redPointInfoList[channel] = false
  end
  self:UpdateOneChannelData(channel)
end
function logic_chat_channel_manager:OnUpdateSwitch()
  log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnUpdateSwitch")
  self:AddTimerOnce(1, function()
    self:UpdateChannelList()
  end)
end
function logic_chat_channel_manager:OnWaitingRoomStateChange()
  log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnWaitingRoomStateChange")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnGetManorInfo()
  log(bWriteLog and "logic_chat_channel_manager:OnGetManorInfo")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnEnterEditHomeSuccess()
  log(bWriteLog and "logic_chat_channel_manager:OnEnterEditHomeSuccess")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnExitEditHomeSuccess()
  log(bWriteLog and "logic_chat_channel_manager:OnExitEditHomeSuccess")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnEnterEditPlanSuccess()
  log(bWriteLog and "logic_chat_channel_manager:OnEnterEditPlanSuccess")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnExitEditPlanSuccess()
  log(bWriteLog and "logic_chat_channel_manager:OnExitEditPlanSuccess")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnPlanPHClearMode()
  log(bWriteLog and "logic_chat_channel_manager:OnPlanPHClearMode")
  self:UpdateChannelList()
end
function logic_chat_channel_manager:OnLogOut()
  self.redPointInfoList = nil
  if self.chatChannelList ~= nil then
    self.chatChannelList:ClearData()
  end
end
function logic_chat_channel_manager:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnPostSwitchGameStatus, preState is:" .. tostring(preState) .. ";  next is:" .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnPostSwitchGameStatus, back to lobby")
    self:UpdateChannelList()
  elseif nextState == GameStatus.Fighting then
    local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
    if modeSystem.IsSocialIslandMode() then
      log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:OnPostSwitchGameStatus, enter socialLand")
      self:UpdateChannelList()
    end
    if GameStatus.IsInMainCity() then
      log(bWriteLog and "[dongkaizha] logic_chat_channel_manager:OnPostSwitchGameStatus, enter maincity")
      self:UpdateChannelList()
    end
  end
end
function logic_chat_channel_manager:IsCanShowChannel(channelConfig)
  local ChatUtils = require("client.slua.logic.lobby_chat.ChatUtils")
  if not ChatUtils.IsChatOpen() then
    if channelConfig.ignoreChatMasterSwitchId ~= nil then
      return LobbySystem.CheckOpen(channelConfig.ignoreChatMasterSwitchId)
    end
    return false
  end
  if channelConfig.checkShowFunc ~= nil and not channelConfig.checkShowFunc() then
    return false
  end
  return true
end
function logic_chat_channel_manager:GetChannelList()
  return self.chatChannelList
end
function logic_chat_channel_manager:GetChannelIndex(channelId)
  if self.chatChannelList then
    for index, channelInfo in ipairs(self.chatChannelList) do
      if channelInfo.channelId == channelId then
        return index
      end
    end
  end
  return -1
end
function logic_chat_channel_manager:IsChannelExist(channelId)
  local channelIndex = self:GetChannelIndex(channelId)
  return 0 < channelIndex
end
function logic_chat_channel_manager:UpdateChannelRedPoint(channelId, isShow)
  log(bWriteLog and "[v_wllwu] logic_chat_channel_manager:UpdateChannelRedPoint, channelId is:" .. tostring(channelId) .. "; isShow:" .. tostring(isShow))
  if not self.redPointInfoList then
    self.redPointInfoList = {}
  end
  self.redPointInfoList[channelId] = isShow
  local index = self:GetChannelIndex(channelId)
  if index < 0 then
    return
  end
  if self.chatChannelList[index].isShowRedPoint == isShow then
    return
  end
  self.chatChannelList[index].isShowRedPoint = isShow
  self.chatChannelList[index] = self.chatChannelList[index]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_chat_channel_manager = class(CModuleBase, nil, logic_chat_channel_manager)
return Clogic_chat_channel_manager