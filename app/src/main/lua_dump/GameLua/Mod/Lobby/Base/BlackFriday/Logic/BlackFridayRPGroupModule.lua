local BlackFridayRPGroupModule = {}
local BlackFridayMacros = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMacros")
local ENum_LinkageSubscribeType = BlackFridayMacros.ENum_LinkageSubscribeType
local Enum_LinkageReceiveStatus = BlackFridayMacros.Enum_LinkageReceiveStatus
function BlackFridayRPGroupModule:DefineAndResetData()
  self.nGroupMemberList = nil
  self.nMyGroupID = nil
  self.nCurrentGroupNum = nil
  self.nGroupLeaderID = nil
  self.tRPGroupRewardCfg = nil
  self.tLinkedRewarData = nil
  self.tLinkagePersonalRewardInfo = nil
  self.tLinkageGroupRewardInfo = nil
  self.tRPGroupShopItemData = nil
  self.nQuickTeamListIndex = 1
  self.tRPGroupInviteRecord = nil
  self.tInvitableFriendList = nil
  self.tInvitedFriendList = nil
  self.bIsBlackFridayJumpRPBuy = false
  self.bIsPopUpRewardUpgradePopup = false
  self.bIsUpgradeRPPlus = false
  self.bIsNeedCheckProductDataDuplicate = false
  self.bIsHadReceiveReward = false
  self.nRPGroupBuyType = nil
  self.bIsNeedShowDelTips = false
  self.bIsOneKeyInvite = true
  self.nLatestByFriendInviteTime = nil
  self.bIsHaveNewInvite = false
  self.bIsNeedUpdateInvitationTimeRecord = true
  self.bIsShowJapanLinkageRewardIcon = false
  self.bIsPrimeBan = false
  self.bIsShowShopTab = false
  self.nHadReceiveLinkageRewardType = nil
end
function BlackFridayRPGroupModule:OnInitialize()
end
function BlackFridayRPGroupModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnDataChangeList, self)
end
function BlackFridayRPGroupModule:OnPostSwitchGameStatus(preState, nextState)
  self:AddTimerOnce(1, function()
    if self:GetRPGroupActId() then
      local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
      local BlackFridaySubHandler = require("client.network.Protocol.BlackFridaySubHandler")
      BlackFridayHandler.send_black_friday_get_rp_group_received_invitation_req()
      if not self:IsJapanOrKoreaThreeStarPackage() then
        BlackFridaySubHandler.send_black_friday_prime_get_relate_reward_req()
      end
    end
  end)
end
function BlackFridayRPGroupModule:_ProcessTeamMemberList(memberList)
  if not memberList then
    return {}
  end
  local tResult = {}
  for uid, v in pairs(memberList) do
    v.    table.insert(tResult, v)
  end
  table.sort(tResult, function(a, b)
    return a.join_time < b.join_time
  end)
  return tResult
end
function BlackFridayRPGroupModule:GetRPGroupQuickTeamList()
  local tRecommendList = self:GetRPGroupInviteRecordList()
  local nPageSize = 6
  local nMaxDataCount = 18
  local tResult = {}
  local nAvailableCount = math.min(#tRecommendList, nMaxDataCount)
  if nAvailableCount == 0 then
    return tResult
  end
  local nStartIndex = self.nQuickTeamListIndex
  local nEndIndex = math.min(nStartIndex + nPageSize - 1, nAvailableCount)
  for i = nStartIndex, nEndIndex do
    table.insert(tResult, tRecommendList[i])
  end
  self.nQuickTeamListIndex = nEndIndex + 1
  if nAvailableCount < self.nQuickTeamListIndex then
    self.nQuickTeamListIndex = 1
  end
  return tResult
end
function BlackFridayRPGroupModule:ResetQuickTeamListIndex()
  self.nQuickTeamListIndex = 1
end
function BlackFridayRPGroupModule:ResetDelTipsStatus()
  self.bIsNeedShowDelTips = false
end
function BlackFridayRPGroupModule:GetRPGroupTeamMemberList()
  if self.nGroupMemberList then
    table.sort(self.nGroupMemberList, function(a, b)
      return a.join_time < b.join_time
    end)
    return self.nGroupMemberList
  end
  return {}
end
function BlackFridayRPGroupModule:GetMyTeamMemberCount()
  log(bWriteLog and "BlackFridayRPGroupModule:GetMyTeamMemberCount " .. tostring(self.nCurrentGroupNum))
  if self.nCurrentGroupNum then
    return self.nCurrentGroupNum
  end
  return 0
end
function BlackFridayRPGroupModule:GetInvitableFriendList()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  self.tInvitableFriendList = {}
  local tFriendList = LogicFriend.GetFriendList(true)
  for _, v in pairs(tFriendList) do
    if LogicFriend.IsInnerFriend(v.uid) and not self:GetIsPlayerHaveGroup(v.uid) then
      table.insert(self.tInvitableFriendList, v)
    end
  end
  return self.tInvitableFriendList
end
function BlackFridayRPGroupModule:GetRPGroupInviteRecordList(bIsGetRecommendGroup)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if bIsGetRecommendGroup then
    local tRecommendList = {}
    if self.tRPGroupInviteRecord then
      for _, v in pairs(self.tRPGroupInviteRecord) do
        local bIsMyFriend = LogicFriend.IsMyFriend(v.send_uid)
        if bIsMyFriend then
          if self.nLatestByFriendInviteTime and v.invite_time > self.nLatestByFriendInviteTime then
            v.is_new_invite = true
          elseif not self.nLatestByFriendInviteTime then
            v.is_new_invite = true
          end
          table.insert(tRecommendList, v)
        end
      end
      table.sort(tRecommendList, function(a, b)
        return a.invite_time > b.invite_time
      end)
      return tRecommendList
    end
  end
  local tResultData = {}
  local nMaxDataCount = 18
  if self.tRPGroupInviteRecord then
    for _, v in pairs(self.tRPGroupInviteRecord) do
      local bIsMyFriend = LogicFriend.IsMyFriend(v.send_uid)
      if bIsMyFriend then
        table.insert(tResultData, v)
      end
    end
    if 1 < #tResultData then
      table.sort(tResultData, function(a, b)
        return a.invite_time > b.invite_time
      end)
    end
    if nMaxDataCount > #tResultData then
      for _, v in pairs(self.tRPGroupInviteRecord) do
        if nMaxDataCount <= #tResultData then
          break
        end
        local bIsMyFriend = LogicFriend.IsMyFriend(v.send_uid)
        if not bIsMyFriend then
          table.insert(tResultData, v)
        end
      end
    end
  end
  return tResultData
end
function BlackFridayRPGroupModule:GetBlackFridayRPGroupShopItemData()
  if self.tRPGroupShopItemData then
    table.sort(self.tRPGroupShopItemData, function(a, b)
      return a.id < b.id
    end)
  end
  return self.tRPGroupShopItemData or {}
end
function BlackFridayRPGroupModule:GetMyGroupID()
  return self.nMyGroupID
end
function BlackFridayRPGroupModule:GetGroupLeaderUID()
  return self.nGroupLeaderID
end
function BlackFridayRPGroupModule:GetLinkageRewardInfo()
  return self.tLinkedRewarData
end
function BlackFridayRPGroupModule:GetRPGroupBuyType()
  return self.nRPGroupBuyType
end
function BlackFridayRPGroupModule:GetIsHadReceiveReward()
  return self.bIsHadReceiveReward
end
function BlackFridayRPGroupModule:GetIsNeedShowDelTips()
  return self.bIsNeedShowDelTips
end
function BlackFridayRPGroupModule:GetIsOneKeyInvite()
  return self.bIsOneKeyInvite
end
function BlackFridayRPGroupModule:GetIsShowJapanLinkageRewardIcon()
  return self.bIsShowJapanLinkageRewardIcon
end
function BlackFridayRPGroupModule:GetRPGroupRewardConfig()
  if not self.tRPGroupRewardCfg or next(self.tRPGroupRewardCfg) then
  end
  self.tRPGroupRewardCfg = {}
  local tRPRewardCfg = CDataTable.GetTable("GroupRewardCfg")
  for i, v in pairs(tRPRewardCfg) do
    local nIndex = #self.tRPGroupRewardCfg + 1
    self.tRPGroupRewardCfg[nIndex] = {}
    for j = 1, 4 do
      self.tRPGroupRewardCfg[nIndex][j] = {
        resid = v["RewardItemID" .. j],
        count = v["RewardItemNum" .. j],
        valid_hours = v["RewardItemVaildTime" .. j],
        buyType = i
      }
    end
  end
  table.sort(self.tRPGroupRewardCfg, function(a, b)
    return a[1].buyType > b[1].buyType
  end)
  return self.tRPGroupRewardCfg
end
function BlackFridayRPGroupModule:_GetLinkageSubscribeType(rewardData)
  local nSubscribeType = ENum_LinkageSubscribeType.RPAndPrime
  if rewardData.prime_plus_buy and rewardData.prime_buy then
    nSubscribeType = ENum_LinkageSubscribeType.RPAndPrimeAndPrimePlus
  elseif rewardData.prime_plus_buy then
    nSubscribeType = ENum_LinkageSubscribeType.RPAandPrimePlus
  end
  return nSubscribeType
end
function BlackFridayRPGroupModule:_BuildRewardInfo(itemList, status)
  local tRewardInfo = {}
  if itemList.item_list and itemList.item_list[1] then
    tRewardInfo[1] = {
      resid = itemList.item_list[1].resid,
      count = itemList.item_list[1].count,
          }
  end
  if itemList.prime_list and itemList.prime_list[1] then
    tRewardInfo[2] = {
      resid = itemList.prime_list[1].resid,
      count = itemList.prime_list[1].count,
          }
  elseif itemList.item_list and itemList.item_list[2] then
    tRewardInfo[2] = {
      resid = itemList.item_list[2].resid,
      count = itemList.item_list[2].count,
          }
    self.bIsShowJapanLinkageRewardIcon = true
  end
  return tRewardInfo
end
function BlackFridayRPGroupModule:GetLinkageRewardCfgInfo()
  self.tLinkagePersonalRewardInfo = {}
  self.tLinkageGroupRewardInfo = {}
  if not self.tLinkedRewarData then
    return self.tLinkagePersonalRewardInfo, self.tLinkageGroupRewardInfo
  end
  local tLinkedData = self.tLinkedRewarData
  local tPersonalReward = tLinkedData.personal_reward
  local tGroupReward = tLinkedData.group_reward
  local nPersonalSubscribeType = self:_GetLinkageSubscribeType(tPersonalReward)
  local nGroupSubscribeType = self:_GetLinkageSubscribeType(tGroupReward)
  if self.nHadReceiveLinkageRewardType then
    nPersonalSubscribeType = self.nHadReceiveLinkageRewardType
    nGroupSubscribeType = self.nHadReceiveLinkageRewardType
  end
  local tPersonalItemList = tPersonalReward.item_info[nPersonalSubscribeType]
  local tGroupItemList = tGroupReward.item_info[nGroupSubscribeType]
  if tPersonalItemList and tPersonalReward.status ~= Enum_LinkageReceiveStatus.Expired then
    self.tLinkagePersonalRewardInfo = self:_BuildRewardInfo(tPersonalItemList, tPersonalReward.status)
  end
  if tGroupItemList and tGroupReward.status ~= Enum_LinkageReceiveStatus.Expired then
    self.tLinkageGroupRewardInfo = self:_BuildRewardInfo(tGroupItemList, tGroupReward.status)
  end
  return self.tLinkagePersonalRewardInfo, self.tLinkageGroupRewardInfo
end
function BlackFridayRPGroupModule:_ExtractFirstAvailableItem(index, itemInfo)
  if not itemInfo or not itemInfo.item_list then
    return nil
  end
  if index == 1 and itemInfo.item_list[1] then
    return itemInfo.item_list[1]
  end
  if itemInfo.item_list[2] then
    return itemInfo.item_list[2]
  end
  if itemInfo.prime_list[1] then
    return itemInfo.prime_list[1]
  end
  return nil
end
function BlackFridayRPGroupModule:_CollectItemsFromRewardInfo(rewardInfo, bIsPersonal)
  if not rewardInfo or not rewardInfo.item_info then
    return {}
  end
  local tItemList = {}
  local tLinkedData = self.tLinkedRewarData
  local tPersonalReward = tLinkedData.personal_reward
  local tGroupReward = tLinkedData.group_reward
  local tSubscribeConfig = {
    {
      type = ENum_LinkageSubscribeType.RPAndPrime,
      personalLocalKey = 18140133,
      groupLocalKey = 18140136,
      unlockField = "rp_buy",
      specialLocalKey = 18140139,
      bIsShowSpecialTips = not bIsPersonal and tPersonalReward.rp_buy and not tGroupReward.rp_buy
    },
    {
      type = ENum_LinkageSubscribeType.RPAndPrime,
      personalLocalKey = 18140134,
      groupLocalKey = 18140137,
      unlockField = "prime_buy",
      specialLocalKey = 18140140,
      bIsShowSpecialTips = not bIsPersonal and tPersonalReward.prime_buy and not tGroupReward.prime_buy
    },
    {
      type = ENum_LinkageSubscribeType.RPAandPrimePlus,
      personalLocalKey = 18140135,
      groupLocalKey = 18140138,
      unlockField = "prime_plus_buy",
      specialLocalKey = 18140141,
      bIsShowSpecialTips = not bIsPersonal and tPersonalReward.prime_plus_buy and not tGroupReward.prime_plus_buy
    }
  }
  for index, config in ipairs(tSubscribeConfig) do
    local itemInfo = rewardInfo.item_info[config.type]
    local item = self:_ExtractFirstAvailableItem(index, itemInfo)
    if item then
      item.LocalKey = bIsPersonal and config.personalLocalKey or config.groupLocalKey
      item.isUnlocked = rewardInfo[config.unlockField] or false
      item.specialLocalKey = config.specialLocalKey
      item.bIsShowSpecialTips = config.bIsShowSpecialTips
      table.insert(tItemList, item)
    end
  end
  local bIsUpdateUnlockedByType = false
  if self.nHadReceiveLinkageRewardType then
    if bIsPersonal and tPersonalReward.status == Enum_LinkageReceiveStatus.Received or not bIsPersonal and tGroupReward.status == Enum_LinkageReceiveStatus.Received then
      bIsUpdateUnlockedByType = true
    end
    for _, v in pairs(tItemList) do
      v.isUnlocked = false
      v.bIsShowSpecialTips = false
    end
    if bIsUpdateUnlockedByType then
      local tUnlockConfig = {
        [ENum_LinkageSubscribeType.RPAndPrime] = {1, 2},
        [ENum_LinkageSubscribeType.RPAandPrimePlus] = {1, 3},
        [ENum_LinkageSubscribeType.RPAndPrimeAndPrimePlus] = "all"
      }
      local unlockIndexes = tUnlockConfig[self.nHadReceiveLinkageRewardType]
      if unlockIndexes then
        if unlockIndexes == "all" then
          for _, v in pairs(tItemList) do
            v.isUnlocked = true
          end
        else
          for _, index in ipairs(unlockIndexes) do
            if tItemList[index] then
              tItemList[index].isUnlocked = true
            end
          end
        end
      end
    end
  end
  return tItemList
end
function BlackFridayRPGroupModule:GetCompleteLinkageRewardData()
  if not self.tLinkedRewarData then
    return {}, {}
  end
  local tLinkedData = self.tLinkedRewarData
  local tPersonalReward = tLinkedData.personal_reward
  local tGroupReward = tLinkedData.group_reward
  local tPersonalItemList = self:_CollectItemsFromRewardInfo(tPersonalReward, true)
  local tGroupItemList = self:_CollectItemsFromRewardInfo(tGroupReward)
  return tPersonalItemList, tGroupItemList
end
function BlackFridayRPGroupModule:IsNeedShowKickedOutTips()
  return false
end
function BlackFridayRPGroupModule:GetRPGroupActId()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tBlackFridayRPGroup = ActivityNewSystem.GetActivityListByType(ActivityType.BlackFriday_RPGroup)
  if tBlackFridayRPGroup then
    local TableUtil = require("common.table_util")
    local nActId = TableUtil.GetTableValue(tBlackFridayRPGroup, 1, "ID")
    return nActId
  end
  return nil
end
function BlackFridayRPGroupModule:OnDataChangeList(_, _, changeList)
  local actId = self:GetRPGroupActId()
  if changeList and changeList.idList and changeList.idList[actId] then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local tActData = ActivityNewSystem.GetActivityByID(actId)
    log_tree("BlackFridayRPGroupModule:OnDataChangeList ", tActData)
    self.nMyGroupID = tActData.other.group_id
    self.nGroupLeaderID = tActData.other.leader_uid
    self.nCurrentGroupNum = tActData.other.current_num
    self.bIsHadReceiveReward = tActData.other.is_rewarded
    self.nRPGroupBuyType = tActData.other.rp_buy_type
    self.nHadReceiveLinkageRewardType = tActData.other.prime_type_when_reward
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_REDDOT)
  end
end
function BlackFridayRPGroupModule:on_black_friday_get_rp_promotion_info_rsp(info)
  self.bIsHadReceiveReward = info and info.is_rewarded or false
  self.nRPGroupBuyType = info and info.rp_buy_type
  log_tree("on_black_friday_get_rp_promotion_info_rsp\227\128\138\227\128\138\227\128\138\227\128\138\227\128\138\227\128\138\227\128\138", info)
  self.bIsNeedShowDelTips = info.need_show_del_tips
  if info.my_group_info then
    self.nGroupMemberList = info.my_group_info.member
    self.nMyGroupID = info.my_group_info.group_id
    self.nCurrentGroupNum = info.my_group_info.current_num
    self.nGroupLeaderID = info.my_group_info.leader_uid
    self.nGroupMemberList = self:_ProcessTeamMemberList(self.nGroupMemberList)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_INFO_UPDATE)
  end
end
function BlackFridayRPGroupModule:on_black_friday_prime_get_relate_reward_rsp(info)
  self.tLinkedRewarData = info
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_LINKAGE_REWARD)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_REDDOT)
end
function BlackFridayRPGroupModule:on_black_friday_prime_take_relate_reward_rsp(info)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(info.item_list)
  local BlackFridaySubHandler = require("client.network.Protocol.BlackFridaySubHandler")
  BlackFridaySubHandler.send_black_friday_prime_get_relate_reward_req()
end
function BlackFridayRPGroupModule:on_black_friday_create_rp_group_rsp(info)
  log(bWriteLog and "BlackFridayRPGroupModule:on_black_friday_create_rp_group_rsp  " .. tostring(info.current_num))
  self.nGroupMemberList = info.member
  self.nMyGroupID = info.group_id
  self.nCurrentGroupNum = info.current_num
  self.nGroupLeaderID = info.leader_uid
  self.nGroupMemberList = self:_ProcessTeamMemberList(self.nGroupMemberList)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_INFO_UPDATE)
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_black_friday_get_rp_group_received_invitation_req()
end
function BlackFridayRPGroupModule:on_black_friday_invite_rp_group_rsp(info)
  self.tInvitableFriendList = info
end
function BlackFridayRPGroupModule:on_black_friday_join_rp_group_rsp(group_id, robot_group_flag, info)
  log(bWriteLog and "BlackFridayRPGroupModule:on_black_friday_join_rp_group_rsp " .. tostring(info.current_num))
  ShowNotice(18140047)
  self.nGroupMemberList = info.member
  self.nMyGroupID = info.group_id
  self.nCurrentGroupNum = info.current_num
  self.nGroupLeaderID = info.leader_uid
  self.nGroupMemberList = self:_ProcessTeamMemberList(self.nGroupMemberList)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_INFO_UPDATE)
end
function BlackFridayRPGroupModule:on_black_friday_onekey_send_rp_group_invitation_rsp(uid_list, chat_content)
  self.bIsOneKeyInvite = true
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_black_friday_get_rp_group_send_invitation_req()
end
function BlackFridayRPGroupModule:on_black_friday_rp_group_delete_member_rsp(member_uid, info)
  log(bWriteLog and "BlackFridayRPGroupModule:on_black_friday_rp_group_delete_member_rsp  " .. tostring(info.current_num))
  ShowNotice(18140049)
  self.nGroupMemberList = info.member
  self.nMyGroupID = info.group_id
  self.nCurrentGroupNum = info.current_num
  self.nGroupLeaderID = info.leader_uid
  self.nGroupMemberList = self:_ProcessTeamMemberList(self.nGroupMemberList)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_INFO_UPDATE)
end
function BlackFridayRPGroupModule:on_black_friday_rp_group_notify(info)
  log(bWriteLog and "BlackFridayRPGroupModule:on_black_friday_rp_group_notify  " .. tostring(info.current_num))
  self.nGroupMemberList = info.member
  self.nMyGroupID = info.group_id
  self.nCurrentGroupNum = info.current_num
  self.nGroupLeaderID = info.leader_uid
  self.nGroupMemberList = self:_ProcessTeamMemberList(self.nGroupMemberList)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_INFO_UPDATE)
end
function BlackFridayRPGroupModule:on_black_friday_get_rp_group_send_invitation_rsp(record_list)
  self.tInvitedFriendList = record_list
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_BLACK_FRIDAY_RPGROUP_INVITED_FRIEND)
end
function BlackFridayRPGroupModule:on_black_friday_get_rp_group_reward_rsp(item_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_black_friday_get_rp_promotion_info_req()
end
function BlackFridayRPGroupModule:on_black_friday_get_rp_discount_buy_info_rsp(info)
  local TableUtil = require("common.table_util")
  if self.bIsNeedCheckProductDataDuplicate and TableUtil.IsDataEqual(self.tRPGroupShopItemData, info) then
    self.bIsNeedCheckProductDataDuplicate = false
    self:AddTimerOnce(2, function()
      local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
      BlackFridayHandler.send_black_friday_get_rp_discount_buy_info_req()
    end)
    return
  end
  self.bIsNeedCheckProductDataDuplicate = false
  self.tRPGroupShopItemData = info
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_DISCOUNT_INFO_UPDATE)
end
function BlackFridayRPGroupModule:on_black_friday_buy_rp_discount_item_rsp(uniq_id, item_info)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(item_info)
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_black_friday_get_rp_discount_buy_info_req()
end
function BlackFridayRPGroupModule:on_black_friday_get_rp_group_received_invitation_rsp(info)
  self.tRPGroupInviteRecord = info
  if self.bIsNeedUpdateInvitationTimeRecord then
    local tInvitedRecordList = self:GetRPGroupInviteRecordList(true)
    self:UpdateInvitationTimeRecord(tInvitedRecordList)
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_BLACK_FRIDAY_RPGROUP_INVITED_RECORD)
end
function BlackFridayRPGroupModule:on_black_friday_send_rp_group_invitation_rsp(receive_uid)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ActType = BlackFridayMacros.ActivityType
  local nActivityID, nGroupID, nGroupMemberNum
  nActivityID = self:GetRPGroupActId()
  nGroupID = self:GetMyGroupID()
  nGroupMemberNum = self:GetMyTeamMemberCount()
  log(bWriteLog and "BlackFridayRPGroupModule:on_black_friday_send_rp_group_invitation_rsp " .. tostring(nGroupMemberNum))
  self.bIsOneKeyInvite = false
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_black_friday_get_rp_group_send_invitation_req()
  local other = {}
  local msgType = chat_macro.BF_RP_InviteGroupMsgType
  local tabContent = {}
  other.activityId = nActivityID
  other.group_count = nGroupMemberNum
  other.group_id = nGroupID
  other.actType = ActType.RPGroup
  tabContent.  tabContent.toUid = receive_uid
  tabContent.  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.SendBFRPGroupInvite(chat_macro.Channel.channelPrivate, tabContent)
end
function BlackFridayRPGroupModule:IsJoinedRPGroup()
  local tMemberLisst = self:GetRPGroupTeamMemberList()
  if tMemberLisst and 0 < #tMemberLisst then
    return true
  end
  return false
end
function BlackFridayRPGroupModule:HandleChatMessageJoinRPGroup(nGroupID, bIsChannelWorld)
  local nGroupMemberNum = self:GetMyTeamMemberCount()
  if 1 < nGroupMemberNum then
    ShowNotice(18140046)
  elseif nGroupID == self.nMyGroupID then
    ShowNotice(18140046)
  else
    local nCurJoinGroupSource
    if bIsChannelWorld then
      nCurJoinGroupSource = 1
    end
    local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
    BlackFridayHandler.send_black_friday_join_rp_group_req(nGroupID, 0, nCurJoinGroupSource)
  end
end
function BlackFridayRPGroupModule:GetIsPlayerHaveGroup(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile and profile.bf_rp_group_current_num and profile.bf_rp_group_current_num > 1 then
    return true
  end
  return false
end
function BlackFridayRPGroupModule:IsPlayerInvited(uid)
  local inviteList = self.tInvitedFriendList
  if inviteList and inviteList[uid] then
    return true
  end
  return false
end
function BlackFridayRPGroupModule:IsAllFriendInvited()
  for _, v in pairs(self.tInvitableFriendList) do
    if not self:IsPlayerInvited(v.uid) then
      return false
    end
  end
  return true
end
function BlackFridayRPGroupModule:IsGroupFullAndAllBuyedRP()
  local nGroupMemberNum = self:GetMyTeamMemberCount()
  if nGroupMemberNum < 3 then
    return false
  end
  if not self.nGroupMemberList then
    return false
  end
  for i, v in pairs(self.nGroupMemberList) do
    if not v.is_buy_rp then
      return false
    end
  end
  return true
end
function BlackFridayRPGroupModule:SetIsBlackFridayJumpToRPBuy(bIsJumpToRPBuy)
  self.bIsBlackFridayJumpRPBuy = bIsJumpToRPBuy
end
function BlackFridayRPGroupModule:GetIsBlackFridayJumpToRPBuy()
  return self.bIsBlackFridayJumpRPBuy
end
function BlackFridayRPGroupModule:SetIsNeedPopUpRewardUpgradePopup(bIsPopUpRewardUpgradePopup)
  self.end
function BlackFridayRPGroupModule:GetIsNeedPopUpRewardUpgradePopup()
  return self.bIsPopUpRewardUpgradePopup
end
function BlackFridayRPGroupModule:SetIsUpgradeRPPlus(bIsUpgradeRPPlus)
  self.end
function BlackFridayRPGroupModule:GetIsUpgradeRPPlus()
  return self.bIsUpgradeRPPlus
end
function BlackFridayRPGroupModule:UpdateInvitationTimeRecord(tInvitedRecordList, bIsUpdateBestNewInviteTime)
  if not tInvitedRecordList or #tInvitedRecordList == 0 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if bIsUpdateBestNewInviteTime then
    self.nLatestByFriendInviteTime = tInvitedRecordList[1].invite_time
    self.bIsHaveNewInvite = false
    PlayerPrefsSystem.SaveTableToFile_N({
      nInviteTime = self.nLatestByFriendInviteTime
    }, PlayerPrefsSystem.ePlayerPrefsType.eBlackFridayRPGroupInviteTimeRecord)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_INVITED_REDDOT)
    return
  end
  local tTimeRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBlackFridayRPGroupInviteTimeRecord) or {}
  if tTimeRecord.nInviteTime and tTimeRecord.nInviteTime ~= 0 then
    self.nLatestByFriendInviteTime = tTimeRecord.nInviteTime
  end
  self.bIsHaveNewInvite = false
  if not self.nLatestByFriendInviteTime then
    self.bIsHaveNewInvite = true
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_INVITED_REDDOT)
    return
  end
  if tInvitedRecordList[1].invite_time > self.nLatestByFriendInviteTime then
    self.bIsHaveNewInvite = true
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_INVITED_REDDOT)
end
function BlackFridayRPGroupModule:SetIsNeedUpdateInvitationTimeRecord(bIsNeedUpdateInvitationTimeRecord)
  self.end
function BlackFridayRPGroupModule:IsHasNewInvite()
  return self.bIsHaveNewInvite
end
function BlackFridayRPGroupModule:HasAnyAward()
  local bIsCanReceiveGroupReward = self:IsGroupFullAndAllBuyedRP()
  if bIsCanReceiveGroupReward and not self.bIsHadReceiveReward then
    return true
  end
  return self:IsCanReceiveLinkageReward()
end
function BlackFridayRPGroupModule:IsCanReceiveLinkageReward()
  if not self.tLinkedRewarData then
    return false
  end
  if self.tLinkedRewarData.is_prime_ban then
    return false
  end
  if self.tLinkedRewarData.personal_reward.status == Enum_LinkageReceiveStatus.CanReceive then
    return true
  end
  if self.tLinkedRewarData.group_reward.status == Enum_LinkageReceiveStatus.CanReceive then
    return true
  end
  return false
end
function BlackFridayRPGroupModule:IsJapanOrKoreaThreeStarPackage()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local nAOSSHOP = Client.GetAOSSHOP()
  if nAOSSHOP == AOSSHOPMacros.Samsung and PublishRegionMacros.IsJapanOrKorea() then
    return true
  end
  return false
end
function BlackFridayRPGroupModule:IsSubscriptionBunishment()
  if self.tLinkedRewarData then
    return self.tLinkedRewarData.is_prime_ban
  end
  return false
end
function BlackFridayRPGroupModule:IsGroupRewardAndLinkageRewardReceived()
  if not self.tLinkedRewarData then
    return false
  end
  local tPersonalReward = self.tLinkedRewarData.personal_reward
  local nPersonalRewardStatus = tPersonalReward.status
  local tGroupReward = self.tLinkedRewarData.group_reward
  local nGroupRewardStatus = tGroupReward.status
  if self.bIsHadReceiveReward and (nPersonalRewardStatus == Enum_LinkageReceiveStatus.Received or nGroupRewardStatus == Enum_LinkageReceiveStatus.Received) then
    return true
  end
  return false
end
function BlackFridayRPGroupModule:SetIsNeedCheckProductDataDuplicate(bIsNeedCheckProductDataDuplicate)
  self.end
function BlackFridayRPGroupModule:SetIsShowShopTab(bIsShowShopTab)
  self.end
function BlackFridayRPGroupModule:GetIsShowShopTab()
  return self.bIsShowShopTab
end
function BlackFridayRPGroupModule:IsShowLinkageRewardOr()
  if self.nHadReceiveLinkageRewardType then
    return false
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlackFridayRPGroupModule = class(CModuleBase, nil, BlackFridayRPGroupModule)
return CBlackFridayRPGroupModule