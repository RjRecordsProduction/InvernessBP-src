local logic_friend_apply_battle = {}
function logic_friend_apply_battle:DefineAndResetData()
  self.ResultAddFriendBtnState = {}
  self.ResultAddFriendBp = {}
end
function logic_friend_apply_battle:will_add_you_as_friend_req(uid, gameid)
  local friend_const = require("client.slua.logic.friend.friend_const")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local innerList = LogicFriend.GetInnerList()
  if #innerList >= friend_const.Friend_Max_Num then
    ShowNotice(689308)
    return
  end
  local FriendApplyBattleHandler = require("client.network.Protocol.FriendApplyBattleHandler")
  FriendApplyBattleHandler.send_will_add_you_as_friend_req(uid, gameid)
end
function logic_friend_apply_battle:please_add_me_as_friend_req(uid)
  if not uid then
    return
  end
  log(bWriteLog and "logic_friend_apply_battle:please_add_me_as_friend_req uid = " .. uid)
  if not self.ResultAddFriendBtnState then
    return
  end
  if not self.ResultAddFriendBtnState.Teammate or not self.ResultAddFriendBtnState.Teammate[uid] then
    return
  end
  local item = self.ResultAddFriendBtnState.Teammate[uid]
  if not item.isSelf or item.State ~= 3 then
    return
  end
  item.State = 4
  local friendList = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for _, value in pairs(self.ResultAddFriendBtnState.Teammate) do
    if value.isSelf == false and LogicFriend.IsMyFriend(value.UID) == false then
      table.insert(friendList, value.UID)
    end
  end
  if 0 < #friendList then
    local friend_const = require("client.slua.logic.friend.friend_const")
    local innerList = LogicFriend.GetInnerList()
    if #innerList >= friend_const.Friend_Max_Num then
      ShowNotice(689308)
      return
    end
    local FriendApplyBattleHandler = require("client.network.Protocol.FriendApplyBattleHandler")
    FriendApplyBattleHandler.send_please_add_me_as_friend_req(friendList)
  end
end
function logic_friend_apply_battle:proc_please_add_me_as_friend_resp(uid)
  if not uid then
    return
  end
  local UID = tostring(uid)
  if UID and self.ResultAddFriendBtnState and self.ResultAddFriendBtnState.Teammate and self.ResultAddFriendBtnState.Teammate[UID] then
    local item = self.ResultAddFriendBtnState.Teammate[UID]
    item.IsInvite = true
    if item.State == 2 then
      self:will_add_you_as_friend_req(UID, self.ResultAddFriendBtnState.GameID)
    end
    if self.ResultAddFriendBp then
      for _, value in pairs(self.ResultAddFriendBp) do
        if tostring(value.UID) == tostring(UID) and value.ParentWidget then
          value.ParentWidget:ShowInviteAddFriendTip(0)
        end
      end
    end
  end
  if self.ResultAddFriendBtnState then
    self.ResultAddFriendBtnState.ReciveInviteAddFriend  end
end
function logic_friend_apply_battle:AddFriendInBattle(uid)
  if not uid then
    return
  end
  log(bWriteLog and "logic_friend_apply_battle:AddFriendInBattle uid = " .. uid)
  if not self.ResultAddFriendBtnState then
    return
  end
  if not self.ResultAddFriendBtnState.Teammate or not self.ResultAddFriendBtnState.Teammate[uid] then
    return
  end
  local item = self.ResultAddFriendBtnState.Teammate[uid]
  local tipsContent
  if item.State == 0 then
    tipsContent = DataMgr.GetFormatMsgByIDForBattleText(20098)
  elseif item.State == 1 then
    if item.IsInvite then
      self:will_add_you_as_friend_req(uid, self.ResultAddFriendBtnState.GameID)
    else
      local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
      if item.Sex == 1 then
        logic_friend_apply:add_inner_friend_req(uid, "", BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT, 7)
      else
        logic_friend_apply:add_inner_friend_req(uid, "", BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT, 8)
      end
    end
    item.State = 2
  elseif item.State == 2 then
    tipsContent = DataMgr.GetFormatMsgByIDForBattleText(20100)
  end
  if tipsContent then
    if not GameStatus.IsInLobbyOrMainCity() then
      BattleNormalTips(tipsContent)
    else
      ShowNotice(tipsContent)
    end
  end
end
function logic_friend_apply_battle:HandleReciveInviteAddFriendCache()
  if not self.ResultAddFriendBtnState or not self.ResultAddFriendBtnState.ReciveInviteAddFriendUID then
    return
  end
  self:proc_please_add_me_as_friend_resp(self.ResultAddFriendBtnState.ReciveInviteAddFriendUID)
end
function logic_friend_apply_battle:ResetResultAddFriendReq(gameid, teammateList)
  self.ResultAddFriendBtnState = {}
  self.ResultAddFriendBtnState.GameID = gameid
  self.ResultAddFriendBtnState.Teammate = {}
  self.ResultAddFriendBp = {}
  self:ResultAddFriendReq(teammateList)
end
function logic_friend_apply_battle:ResultAddFriendReq(teammateList)
  if teammateList == nil then
    return
  end
  local bAllFriend = true
  for _, v in pairs(teammateList) do
    local item = {}
    item.UID = tostring(v.UID)
    item.Sex = v.rela_sex
    if v.Name then
      item.Name = v.Name
    elseif v.PlayerName then
      item.Name = v.PlayerName
    end
    if tonumber(DataMgr.roleData.uid) == tonumber(item.UID) then
      item.isSelf = true
    else
      item.isSelf = false
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if LogicFriend.IsInnerFriend(tonumber(item.UID)) then
        item.State = 0
      else
        bAllFriend = false
        item.State = 1
        item.IsInvite = false
      end
    end
    log(bWriteLog and "logic_friend_apply_battle:ResultAddFriendReq uid = " .. tostring(item.UID) .. " State = " .. tostring(item.State))
    self.ResultAddFriendBtnState.Teammate[item.UID] = item
  end
  for _, value in pairs(self.ResultAddFriendBtnState.Teammate) do
    if value.isSelf then
      if bAllFriend then
        value.State = 0
      else
        value.State = 3
      end
    end
  end
end
function logic_friend_apply_battle:GetResultAddFriendState(UID)
  log(bWriteLog and "logic_friend_apply_battle:GetResultAddFriendState UID = " .. tostring(UID))
  if not (UID and self.ResultAddFriendBtnState and self.ResultAddFriendBtnState.Teammate) or not self.ResultAddFriendBtnState.Teammate[UID] then
    return 0
  end
  local item = self.ResultAddFriendBtnState.Teammate[UID]
  return item.State
end
function logic_friend_apply_battle:AddAddFriendBP(bp)
  if not self.ResultAddFriendBp then
    log(bWriteLog and "logic_friend_apply_battle:AddAddFriendBP ResultAddFriendBp nil")
    return
  end
  for index = 1, #self.ResultAddFriendBp do
    if self.ResultAddFriendBp[index] == bp then
      log(bWriteLog and "logic_friend_apply_battle:AddAddFriendBP Repeat Add")
      return
    end
  end
  table.insert(self.ResultAddFriendBp, #self.ResultAddFriendBp + 1, bp)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_friend_apply = class(CModuleBase, nil, logic_friend_apply_battle)
return Clogic_friend_apply