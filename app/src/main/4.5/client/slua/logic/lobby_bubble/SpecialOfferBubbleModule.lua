local SpecialOfferBubbleModule = {}
function SpecialOfferBubbleModule:DefineAndResetData()
  self.bActOpen = true
  self.act_info = nil
  self.bubble_data = nil
end
function SpecialOfferBubbleModule:OnInitialize()
end
function SpecialOfferBubbleModule:RegistEvents()
end
function SpecialOfferBubbleModule:OnLogin(bReLogin)
end
function SpecialOfferBubbleModule:OnLogOut()
end
function SpecialOfferBubbleModule:OnPreSwitchGameStatus(preState, nextState)
end
function SpecialOfferBubbleModule:OnPostSwitchGameStatus(preState, nextState)
end
function SpecialOfferBubbleModule:GetActData()
  if not self.act_info and self.bActOpen then
    log(bWriteLog and "[mxiliu]: SpecialOfferBubbleModule.GetActData act_info is nil")
    self:send_get_keep_stay_bubble_req()
  end
  return self.act_info
end
function SpecialOfferBubbleModule:SetActData(data)
  self.act_info = data
  EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_BUBBLE_UPDATE_ENTRANCE)
end
function SpecialOfferBubbleModule:CheckBubbleCanShow()
  if self.act_info then
    local TimeUtil = require("client.common.time_util")
    local nowtime = TimeUtil.GetServerTimeInSec()
    if nowtime >= self.act_info.act_start_time and nowtime < self.act_info.act_end_time then
      return true
    end
  end
  return false
end
function SpecialOfferBubbleModule:SetActOpen(bOpen)
  self.bActOpen = bOpen
end
function SpecialOfferBubbleModule:send_get_keep_stay_bubble_req()
  local LobbyBubbleHandler = require("client.network.Protocol.LobbyBubbleHandler")
  LobbyBubbleHandler.send_get_keep_stay_bubble_req()
end
function SpecialOfferBubbleModule:on_get_keep_stay_bubble_rsp(act_info)
  self:SetActData(act_info)
end
function SpecialOfferBubbleModule:HandleBubbleData(bubbleData)
  self.bubble_data = bubbleData
  if self.bubble_data.id then
    if self:HaveBubbleRecord(self.bubble_data.id) then
      return
    end
    local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
    if logic_return_activity_utils.IsActInProgress() then
      return
    end
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    if LogicNewbie.IsNewbie(true) then
      return
    end
    EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_SEPCIAL_OFFER_BUBBLE_UPDATE)
  end
end
function SpecialOfferBubbleModule:HaveBubbleRecord(id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBubble) or {}
  if not Data[id] then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local time = Data[id]
  return TimeUtil.IsSameDay(time, TimeUtil.GetServerTimeInSec())
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSpecialOfferBubbleModule = class(CModuleBase, nil, SpecialOfferBubbleModule)
return CSpecialOfferBubbleModule