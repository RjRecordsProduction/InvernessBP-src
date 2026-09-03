local ShareSuit = {}
function ShareSuit:DefineAndResetData()
  self.CanShareList = {}
  self.HasShareList = {}
  self.SharePostureList = {}
  self.bRefreshing = false
end
function ShareSuit:GetHasShareList()
  return self.HasShareList
end
function ShareSuit:OnExitMember(_, _, UID)
  if not UID then
    return
  end
  UID = tonumber(UID)
  self.CanShareList[UID] = nil
  local selfUID = tonumber(DataMgr.roleData.uid)
  if tostring(UID) == DataMgr.roleData.uid then
    for _, data in pairs(self.HasShareList) do
      if data and data.invitee == selfUID then
        local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
        if data.cloth then
          if data.cloth.clothes_id then
            TeamAvatarManager.PutoffEquipment(data.invitee, data.cloth.clothes_id)
          end
          if data.cloth.head_id then
            TeamAvatarManager.PutoffEquipment(data.invitee, data.cloth.head_id)
          end
        end
        break
      end
    end
    self.HasShareList = {}
    self.CanShareList = {}
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(UID)
    logic_share_bag_team_util:UpdateTeamAvatar(UID, selectSharedItems, false)
    return
  end
  if self.HasShareList[UID] then
    local data = self.HasShareList[UID]
    log(bWriteLog and "ShareSuit:OnExitMember " .. tostring(UID))
    local invitee = data.invitee
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    if data.cloth then
      if data.cloth.clothes_id then
        TeamAvatarManager.PutoffEquipment(invitee, data.cloth.clothes_id)
      end
      if data.cloth.head_id then
        TeamAvatarManager.PutoffEquipment(invitee, data.cloth.head_id)
      end
    end
    self.HasShareList[UID] = nil
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(invitee)
    logic_share_bag_team_util:UpdateTeamAvatar(invitee, selectSharedItems, false)
    return
  end
  local inviterUID
  for inviter, data in pairs(self.HasShareList) do
    if data.invitee == UID then
      inviterUID = inviter
      break
    end
  end
  if inviterUID then
    log(bWriteLog and "ShareSuit:OnExitMember " .. tostring(UID))
    self.HasShareList[inviterUID] = nil
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(UID)
    logic_share_bag_team_util:UpdateTeamAvatar(UID, selectSharedItems, true)
  end
end
function ShareSuit:BatchUpdateHasShareList(share_list)
  local oldShareList = self.HasShareList
  local newInviteeMap = {}
  self.HasShareList = {}
  if share_list then
    for inviter, data in pairs(share_list) do
      if data then
        for invitee, cloth in pairs(data) do
          self.HasShareList[inviter] = {invitee = invitee, cloth = cloth}
          newInviteeMap[invitee] = self.HasShareList[inviter]
        end
      end
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  for _, data in pairs(oldShareList) do
    if data.cloth then
      if data.cloth.clothes_id and (not (newInviteeMap[data.invitee] and newInviteeMap[data.invitee].cloth) or newInviteeMap[data.invitee].cloth.clothes_id ~= data.cloth.clothes_id) then
        log(bWriteLog and "ShareSuit:BatchUpdateHasShareList putoff diff " .. tostring(data.cloth.clothes_id))
        TeamAvatarManager.PutoffEquipment(data.invitee, data.cloth.clothes_id)
      end
      if data.cloth.head_id and (not (newInviteeMap[data.invitee] and newInviteeMap[data.invitee].cloth) or newInviteeMap[data.invitee].cloth.head_id ~= data.cloth.head_id) then
        log(bWriteLog and "ShareSuit:BatchUpdateHasShareList putoff diff " .. tostring(data.cloth.head_id))
        TeamAvatarManager.PutoffEquipment(data.invitee, data.cloth.head_id)
      end
    end
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(data.invitee)
    logic_share_bag_team_util:UpdateTeamAvatar(data.invitee, selectSharedItems, true)
  end
  for _, v in pairs(self.HasShareList) do
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(v.invitee)
    logic_share_bag_team_util:UpdateTeamAvatar(v.invitee, selectSharedItems, true)
  end
end
function ShareSuit:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, self.OnExitMember, self)
end
function ShareSuit:CheckLoverCollect(ItemID)
  local ShareSuitCfg = CDataTable.GetTableData("ShareSuitCfg", ItemID)
  if ShareSuitCfg and ShareSuitCfg.CollectList_a then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    for _, v in pairs(ShareSuitCfg.CollectList_a) do
      if not wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v) then
        return false
      end
    end
  end
  return true
end
function ShareSuit:CheckSharePostureItem(ItemID)
  if not ItemID then
    return false
  end
  return self.SharePostureList[ItemID] or false
end
function ShareSuit:GetShareWingType(UID)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() <= 1 then
    return nil
  end
  if not UID or not self.CanShareList[UID] then
    log(bWriteLog and "ShareSuit:GetShareWingType can not share UID = " .. tostring(UID))
    return nil
  end
  if self.HasShareList[UID] then
    log(bWriteLog and "ShareSuit:GetShareWingType already share UID = " .. tostring(UID))
    return nil
  end
  if tostring(UID) == DataMgr.roleData.uid then
    if not next(self.CanShareList[UID]) then
      log(bWriteLog and "ShareSuit:GetShareWingType no one can share ")
      return nil
    end
  else
    local find = false
    for k, _ in pairs(self.CanShareList[UID]) do
      if tostring(k) == DataMgr.roleData.uid then
        find = true
        break
      end
    end
    if not find then
      log(bWriteLog and "ShareSuit:GetShareWingType can not share to me")
      return nil
    end
  end
  local SuitID = self:GetTeammateSuit(UID)
  log(bWriteLog and "ShareSuit:GetShareWingType SuitID not match, SuitID = " .. tostring(SuitID))
  return SuitID
end
function ShareSuit:CheckCanShare(fromUID, toUID)
  if not (fromUID and toUID) or fromUID == toUID or not self.CanShareList[fromUID] then
    return false
  end
  if tostring(fromUID) ~= DataMgr.roleData.uid and tostring(toUID) ~= DataMgr.roleData.uid then
    return false
  end
  for k, _ in pairs(self.CanShareList[fromUID]) do
    if k == toUID then
      return true
    end
  end
  return false
end
function ShareSuit:HandleDrag(fromUID, toUID)
  log(bWriteLog and string.format("ShareSuit:HandleDrag fromUID = %s, toUID = %s", tostring(fromUID), tostring(toUID)))
  if not (fromUID and toUID) or fromUID == toUID then
    return
  end
  if not self:CheckCanShare(fromUID, toUID) then
    ShowNotice(7474)
    EventSystem:postEvent(EVENTTYPE_SHARESUIT, EVENTID_SHARESUIT_REJECT_SHARE)
    return
  end
  local ShareSuitHandler = require("client.network.Protocol.ShareSuitHandler")
  if tostring(fromUID) == DataMgr.roleData.uid then
    ShareSuitHandler.send_invite_share_taluo_dress_req(toUID)
    local TarotCardDrawCardSystem = require("client.slua.logic.tarot_card.logic_tarotcard_drawcard")
    TarotCardDrawCardSystem.SendTLog(TLogEventDefine.TarotCard_Share_By_Inviter)
  end
  if tostring(toUID) == DataMgr.roleData.uid then
    ShareSuitHandler.send_invitee_response_share_req(fromUID, ShareSuitHandler.RES_TYPE.ACCEPT)
    local TarotCardDrawCardSystem = require("client.slua.logic.tarot_card.logic_tarotcard_drawcard")
    TarotCardDrawCardSystem.SendTLog(TLogEventDefine.TarotCard_Share_By_Invitee)
  end
end
function ShareSuit:GetTeammateSuit(UID)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local MemberInfo = TeamUpNewSystem.GetMemberInfo(UID)
  if not MemberInfo then
    log(bWriteLog and "ShareSuit:GetTeammateSuit not MemberInfo UID = " .. tostring(UID))
    return nil
  end
  local SuitID
  if tostring(UID) == DataMgr.roleData.uid then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tRoleWear = AvatarData.GetRoleWear()
    for _, v in pairs(tRoleWear) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo and CDataTable.GetTableData("ShareSuitCfg", itemInfo.resID) then
        return itemInfo.resID
      end
    end
  elseif MemberInfo.wear_ext and MemberInfo.wear_ext[3] and MemberInfo.wear_ext[3][1] then
    SuitID = MemberInfo.wear_ext[3][1]
    if CDataTable.GetTableData("ShareSuitCfg", SuitID) then
      return SuitID
    end
  end
  return nil
end
function ShareSuit:RefreshAllTeammateShareSuit()
  for inviter, data in pairs(self.HasShareList) do
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local MemberInfo = TeamUpNewSystem.GetMemberInfo(inviter)
    if not MemberInfo then
      log(bWriteLog and "ShareSuit:RefreshAllTeammateShareSuit not inviter in team, inviter = " .. tostring(inviter))
    else
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      if data and data.invitee and data.cloth then
        if data.cloth.clothes_id then
          TeamAvatarManager.PutonEquipment(data.invitee, data.cloth.clothes_id)
        end
        if data.cloth.head_id then
          TeamAvatarManager.PutonEquipment(data.invitee, data.cloth.head_id)
        end
      end
    end
  end
end
function ShareSuit:RefreshAvatarShareSuit(uid)
  if self.bRefreshing then
    return
  end
  self.bRefreshing = true
  for inviter, data in pairs(self.HasShareList) do
    if data and data.invitee == uid then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local MemberInfo = TeamUpNewSystem.GetMemberInfo(inviter)
      if MemberInfo then
        log(bWriteLog and "ShareSuit:RefreshAvatarShareSuit")
        if data.cloth then
          local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
          if data.cloth.clothes_id then
            TeamAvatarManager.PutonEquipment(data.invitee, data.cloth.clothes_id)
          end
          if data.cloth.head_id then
            TeamAvatarManager.PutonEquipment(data.invitee, data.cloth.head_id)
          end
        end
        break
      end
    end
  end
  self.bRefreshing = false
end
function ShareSuit:UpdateCanShareList(user_list)
  if user_list then
    self.CanShareList = user_list
  else
    self.CanShareList = {}
  end
  EventSystem:postEvent(EVENTTYPE_SHARESUIT, EVENTID_SHARESUIT_UPDATE_WING)
end
function ShareSuit:on_taluo_dress_share_qualification_notify(user_list, share_list)
  if not Client.IsShipping() then
    log_tree("ShareSuit:on_taluo_dress_share_qualification_notify, user_list", user_list)
    log_tree("ShareSuit:on_taluo_dress_share_qualification_notify, share_list", share_list)
  end
  self:BatchUpdateHasShareList(share_list)
  self:UpdateCanShareList(user_list)
end
function ShareSuit:on_receive_share_taluo_dress_notify(inviter_uid, inviter_nick_name)
  if IsWoWEditor then
    return
  end
  if not inviter_uid or not inviter_nick_name then
    log(bWriteLog and "ShareSuit:on_receive_share_taluo_dress_notify not data " .. tostring(inviter_uid) .. " " .. tostring(inviter_nick_name))
    return
  end
  local TeammateSuit = self:GetTeammateSuit(inviter_uid)
  if not TeammateSuit then
    log(bWriteLog and "share_suit_invite_tip not TeammateSuit Find!")
    return
  end
  local ShareSuitCfg = CDataTable.GetTableData("ShareSuitCfg", TeammateSuit)
  if not ShareSuitCfg then
    log(bWriteLog and "share_suit_invite_tip not ShareSuitCfg Find!")
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.share_suit_invite_tip)
  UIManager.ShowUI(UIManager.UI_Config.share_suit_invite_tip, inviter_uid, inviter_nick_name, ShareSuitCfg.ShareTipsItem)
end
function ShareSuit:on_share_taluo_dress_broadcast_notify(inviter_uid, invitee_uid, invitee_wear_itemid, invitee_head_id)
  log(bWriteLog and string.format("ShareSuit:on_share_taluo_dress_broadcast_notify %s %s %s %s", tostring(inviter_uid), tostring(invitee_uid), tostring(invitee_wear_itemid), tostring(invitee_head_id)))
  self.HasShareList[inviter_uid] = {
    invitee = invitee_uid,
    cloth = {clothes_id = invitee_wear_itemid, head_id = invitee_head_id}
  }
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  if invitee_uid and invitee_uid ~= 0 then
    local selectSharedItems = logic_share_bag_team_util:GetLastSelectSharedItemsByUID(invitee_uid)
    logic_share_bag_team_util:UpdateTeamAvatar(invitee_uid, selectSharedItems, true)
  end
  local ShareSuitCfg = CDataTable.GetTableData("ShareSuitCfg", invitee_wear_itemid)
  if ShareSuitCfg and ShareSuitCfg.TipsPath then
    UIManager.ShowUIWithBpPath(UIManager.UI_Config.Lobby_GoldSpin_Tips_UIBP, ShareSuitCfg.TipsPath, TeamUpNewSystem.GetMemberName(inviter_uid), TeamUpNewSystem.GetMemberName(invitee_uid), ShareSuitCfg.TipsKey)
  end
  EventSystem:postEvent(EVENTTYPE_SHARESUIT, EVENTID_SHARESUIT_UPDATE_WING)
end
function ShareSuit:on_change_taluo_share_dress_notify(inviter_uid, invitee_uid, user_list, share_list)
  self:BatchUpdateHasShareList(share_list)
  self:UpdateCanShareList(user_list)
end
function ShareSuit:on_tenquiry_posture_qualification_rsp(flag, event_card_posture_share)
  log_tree("ShareSuit:on_tenquiry_posture_qualification_rsp", event_card_posture_share)
  log_tree("event_card_posture_share", event_card_posture_share or {})
  self.SharePostureList = event_card_posture_share or {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CShareSuit = class(CModuleBase, nil, ShareSuit)
return CShareSuit