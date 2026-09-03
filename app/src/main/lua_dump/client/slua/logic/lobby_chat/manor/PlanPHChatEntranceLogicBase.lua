local PlanPHChatEntranceLogicBase = {}
function PlanPHChatEntranceLogicBase:DefineAndResetData()
  self.hasNew = false
  self.maxMsg = 4
  self.chatInfoList = {}
end
function PlanPHChatEntranceLogicBase:GetMsgList()
  self.hasNew = false
  return self.chatInfoList
end
function PlanPHChatEntranceLogicBase:ReceiveNewMsg(chatMsg)
  printf("[PlanPHChatEntranceLogicBase] ReceiveNewMsg: %s", chatMsg.msg)
  if self:filterMsg(chatMsg) then
    return
  end
  self.hasNew = true
  if #self.chatInfoList >= self.maxMsg then
    table.remove(self.chatInfoList, 1)
  end
  table.insert(self.chatInfoList, chatMsg)
end
function PlanPHChatEntranceLogicBase:GetTeamRecruitMsgContent(chatMsg)
  return LocUtil.LocalizeResFormat(7791)
end
function PlanPHChatEntranceLogicBase:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "PlanPHChatEntranceLogicBase OnPreSwitchGameStatus")
  self:DefineAndResetData()
end
function PlanPHChatEntranceLogicBase:OnLogOut()
  log(bWriteLog and "PlanPHChatEntranceLogicBase OnLogOut")
  self:DefineAndResetData()
end
local class = require("class")
local CLogicChatEntranceBase = require("client.slua.logic.lobby_chat.logic_chat_entrance_base")
local CPlanPHChatEntranceLogicBase = class(CLogicChatEntranceBase, nil, PlanPHChatEntranceLogicBase)
return CPlanPHChatEntranceLogicBase