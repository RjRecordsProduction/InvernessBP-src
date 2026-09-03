local logic_friend_list_ui = {}
function logic_friend_list_ui:DefineAndResetData()
  self.tabID = 1
  self.state = "Friends"
  self.from = 0
  self.batchDeleteMap = {}
  self.batchTopMap = {}
  self.ProfileRequestMap = {}
  self.friendListData = {}
  self.friendGuideItemIndex = nil
end
function logic_friend_list_ui:GetTabID()
  return self.tabID
end
function logic_friend_list_ui:SetTabID(tab)
  log(bWriteLog and "logic_friend_list_ui:SetTabID. tab = " .. tostring(tab))
  self.tabID = tab
end
function logic_friend_list_ui:GetShowReuseFall()
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  return self.tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG or self.tabID == FLMacros.ENUM_TAB.ENUM_RECENT_TAG
end
function logic_friend_list_ui:GetState()
  return self.state
end
function logic_friend_list_ui:SetState(state)
  self.  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  if state == FLMacros.ENUM_STATE.FRIENDS_TOP then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local Friends = LogicFriend.GetFriendList(false)
    self.batchTopMap = {}
    for k, v in pairs(Friends) do
      if v.isTop then
        self.batchTopMap[v.uid] = UEnums.ECheckBoxState.Checked
      end
    end
  end
end
function logic_friend_list_ui:SetFrom(from)
  self.end
function logic_friend_list_ui:GetFrom()
  return self.from
end
function logic_friend_list_ui:GetIsDelete(uid)
  return self.batchDeleteMap[uid]
end
function logic_friend_list_ui:GetCheckState(uid)
  return self.batchTopMap[uid]
end
function logic_friend_list_ui:HasReqProfile(uid)
  return self.ProfileRequestMap[uid]
end
function logic_friend_list_ui:SetReqProfile(uid)
  if not uid then
    return
  end
  self.ProfileRequestMap[uid] = true
end
function logic_friend_list_ui:ClearProfileReqMap()
  self.ProfileRequestMap = {}
end
function logic_friend_list_ui:GetFriendList()
  return self.friendListData
end
function logic_friend_list_ui:GetPlayerData(index)
  return self.friendListData[index]
end
function logic_friend_list_ui:SetFriendList(data)
  self.friendListData = data or {}
end
function logic_friend_list_ui:SetIsTop(uid, isTop)
  self.batchTopMap[uid] = isTop
end
function logic_friend_list_ui:GetTopCnt()
  local res = 0
  for k, v in pairs(self.batchTopMap) do
    if v == 1 then
      res = res + 1
    end
  end
  return res
end
function logic_friend_list_ui:GetTops()
  return self.batchTopMap
end
function logic_friend_list_ui:ClearTops()
  self.batchTopMap = {}
end
function logic_friend_list_ui:SetIsDelete(uid, isDel)
  self.batchDeleteMap[uid] = isDel
end
function logic_friend_list_ui:ClearDels()
  self.batchDeleteMap = {}
end
function logic_friend_list_ui:GetDelCnt()
  local res = 0
  for k, v in pairs(self.batchDeleteMap) do
    if v then
      res = res + 1
    end
  end
  return res
end
function logic_friend_list_ui:GetDels()
  return self.batchDeleteMap
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_friend_list_ui)