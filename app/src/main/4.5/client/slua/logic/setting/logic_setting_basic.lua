local logic_setting_basic = {
  nShowRoleInSending = 0,
  bCanShowHistory = true,
  bCanShowRole = true,
  bCanShowUnknownPass = true,
  bUnknownPassBattleShow = true,
  bUnknownPassRecordShow = true,
  bAllowFriendIsland = false,
  bAllowStrangerIsland = false,
  bSeasonFriendDataPrivacy = true,
  bShowWatching = 1,
  bIsClickPushButton = false,
  bShowSubscribeBadge = true,
  bShowChatRoom = true,
  bWoWShow = true,
  bWoWPlayShow = true,
  bWoWCollectModShow = true,
  bWoWLikeAuthorShow = true,
  bWoWHeadShwoShow = true,
  bWoWModCollectionShow = true,
  bWoWPassDisplay = true,
  bWoWTotalCollectCnt = true,
  bWoWTotalPlayCnt = true,
  bWoWTotalFollowerCnt = true,
  bWoWTotalPubCnt = true,
  bWoWTotalPlayTotalTime = true,
  bWoWSeasonCreativeLevel = true,
  bWoWCreatorRank = true,
  bWoWSupportCount = true,
  bWoWHonors = true,
  bWoWCopilotDisplay = true,
  nGromeLinkOpenValue = 0,
  nGromeLinkFECSwitcher = 0
}
function logic_setting_basic.SendCanShowRole()
  logic_setting_basic.nShowRoleInSending = 1
end
function logic_setting_basic.OnChangeAvatarShowSwitchRoleInfoRsp()
  if logic_setting_basic.nShowRoleInSending == 1 then
    logic_setting_basic.nShowRoleInSending = logic_setting_basic.nShowRoleInSending + 1
  end
end
function logic_setting_basic.get_role_privacy_rsp(canShow)
  local privacy = true
  if canShow ~= nil then
    privacy = canShow
  else
    privacy = true
  end
  logic_setting_basic.bCanShowHistory = privacy
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_CAN_SHOW_HISTORY)
end
function logic_setting_basic.ShowThrowTips(nType)
  UIManager.ShowUI(UIManager.UI_Config.Throw_Tips_UIBP, nType)
end
function logic_setting_basic.SendUnknownPassSwitch()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_change_switch_req(logic_setting_basic.bCanShowUnknownPass, logic_setting_basic.bCanShowUnknownPass, logic_setting_basic.bUnknownPassBattleShow, logic_setting_basic.bUnknownPassRecordShow)
end
function logic_setting_basic.SendSubscribeSwich()
  local SubscribeHandler = require("client.network.Protocol.SubscribeHandler")
  local flag = 0
  if not logic_setting_basic.bShowSubscribeBadge then
    flag = 1
  end
  SubscribeHandler.send_set_prime_badge_no_show_flag(flag)
end
function logic_setting_basic.SetShowChatRoom(bShow)
  log(bWriteLog and "logic_setting_basic.SetShowChatRoom bShow:" .. tostring(bShow))
  if bShow == nil then
    bShow = true
  end
  logic_setting_basic.bShowChatRoom = bShow
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_SET_SHOW_CHAT_ROOM)
end
function logic_setting_basic.GetPrivacyWoWShow(Key)
  if not Key then
    return false
  end
  if Key == "WoWShow" then
    return logic_setting_basic.bWoWShow
  elseif Key == "WoWPlay" then
    return logic_setting_basic.bWoWPlayShow
  elseif Key == "WoWCollectMod" then
    return logic_setting_basic.bWoWCollectModShow
  elseif Key == "WoWLikeAuthor" then
    return logic_setting_basic.bWoWLikeAuthorShow
  elseif Key == "WoWHeadShwo" then
    return logic_setting_basic.bWoWHeadShwoShow
  elseif Key == "WoWModCollectionShow" then
    return logic_setting_basic.bWoWModCollectionShow
  elseif Key == "WoWPassDisplay" then
    return logic_setting_basic.bWoWPassDisplay
  elseif Key == "WoWCopilotDisplay" then
    return logic_setting_basic.bWoWCopilotDisplay
  elseif Key == "WoWTotalCollectCnt" then
    return logic_setting_basic.bWoWTotalCollectCnt
  elseif Key == "WoWTotalPlayCnt" then
    return logic_setting_basic.bWoWTotalPlayCnt
  elseif Key == "WoWTotalFollowerCnt" then
    return logic_setting_basic.bWoWTotalFollowerCnt
  elseif Key == "WoWTotalPubCnt" then
    return logic_setting_basic.bWoWTotalPubCnt
  elseif Key == "WoWTotalPlayTotalTime" then
    return logic_setting_basic.bWoWTotalPlayTotalTime
  elseif Key == "WoWSeasonCreativeLevel" then
    return logic_setting_basic.bWoWSeasonCreativeLevel
  elseif Key == "WoWCreatorRank" then
    return logic_setting_basic.bWoWCreatorRank
  elseif Key == "WoWSupportCount" then
    return logic_setting_basic.bWoWSupportCount
  elseif Key == "WoWHonors" then
    return logic_setting_basic.bWoWHonors
  else
    return false
  end
end
function logic_setting_basic.SetPrivacyWoWShow(Key, bShow)
  if not Key then
    return
  end
  if Key == "WoWShow" then
    if logic_setting_basic.bWoWShow ~= bShow then
      logic_setting_basic.bWoWShow = bShow
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_FATHER_PRIVACY_SETTING_STATUS_NOTIFY)
    else
      logic_setting_basic.bWoWShow = bShow
    end
  elseif Key == "WoWPlay" then
    logic_setting_basic.bWoWPlayShow = bShow
  elseif Key == "WoWCollectMod" then
    logic_setting_basic.bWoWCollectModShow = bShow
  elseif Key == "WoWLikeAuthor" then
    logic_setting_basic.bWoWLikeAuthorShow = bShow
  elseif Key == "WoWHeadShwo" then
    logic_setting_basic.bWoWHeadShwoShow = bShow
  elseif Key == "WoWModCollectionShow" then
    logic_setting_basic.bWoWModCollectionShow = bShow
  elseif Key == "WoWPassDisplay" then
    logic_setting_basic.bWoWPassDisplay = bShow
  elseif Key == "WoWCopilotDisplay" then
    if logic_setting_basic.bWoWCopilotDisplay ~= bShow then
      logic_setting_basic.bWoWCopilotDisplay = bShow
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_SETTING_STATUS_NOTIFY, bShow)
    else
      logic_setting_basic.bWoWCopilotDisplay = bShow
    end
  elseif Key == "WoWTotalCollectCnt" then
    logic_setting_basic.bWoWTotalCollectCnt = bShow
  elseif Key == "WoWTotalPlayCnt" then
    logic_setting_basic.bWoWTotalPlayCnt = bShow
  elseif Key == "WoWTotalFollowerCnt" then
    logic_setting_basic.bWoWTotalFollowerCnt = bShow
  elseif Key == "WoWTotalPubCnt" then
    logic_setting_basic.bWoWTotalPubCnt = bShow
  elseif Key == "WoWTotalPlayTotalTime" then
    logic_setting_basic.bWoWTotalPlayTotalTime = bShow
  elseif Key == "WoWSeasonCreativeLevel" then
    logic_setting_basic.bWoWSeasonCreativeLevel = bShow
  elseif Key == "WoWCreatorRank" then
    logic_setting_basic.bWoWCreatorRank = bShow
  elseif Key == "WoWSupportCount" then
    logic_setting_basic.bWoWSupportCount = bShow
  elseif Key == "WoWHonors" then
    logic_setting_basic.bWoWHonors = bShow
  end
end
function logic_setting_basic.ReqUGCSetPrivacy()
  local Privacy = {
    main = not logic_setting_basic.bWoWShow,
    play = not logic_setting_basic.bWoWPlayShow,
    collect = not logic_setting_basic.bWoWCollectModShow,
    follow = not logic_setting_basic.bWoWLikeAuthorShow,
    rec_display = not logic_setting_basic.bWoWHeadShwoShow,
    mod_collection = not logic_setting_basic.bWoWModCollectionShow,
    wow_pass_display = not logic_setting_basic.bWoWPassDisplay,
    wow_copilot_display = not logic_setting_basic.bWoWCopilotDisplay,
    total_collect_cnt = not logic_setting_basic.bWoWTotalCollectCnt,
    total_play_cnt = not logic_setting_basic.bWoWTotalPlayCnt,
    total_follower_cnt = not logic_setting_basic.bWoWTotalFollowerCnt,
    total_pub_cnt = not logic_setting_basic.bWoWTotalPubCnt,
    total_play_total_time = not logic_setting_basic.bWoWTotalPlayTotalTime,
    season_creative_level = not logic_setting_basic.bWoWSeasonCreativeLevel,
    creator_rank = not logic_setting_basic.bWoWCreatorRank,
    support_count = not logic_setting_basic.bWoWSupportCount,
    honors = not logic_setting_basic.bWoWHonors
  }
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_set_privacy_req(Privacy)
end
function logic_setting_basic.RspUGCSetPrivacy(Privacy)
  if not Privacy then
    return
  end
  logic_setting_basic.bWoWShow = not Privacy.main
  logic_setting_basic.bWoWPlayShow = not Privacy.play
  logic_setting_basic.bWoWCollectModShow = not Privacy.collect
  logic_setting_basic.bWoWLikeAuthorShow = not Privacy.follow
  logic_setting_basic.bWoWHeadShwoShow = not Privacy.rec_display
  logic_setting_basic.bWoWModCollectionShow = not Privacy.mod_collection
  logic_setting_basic.bWoWPassDisplay = not Privacy.wow_pass_display
  if logic_setting_basic.bWoWCopilotDisplay ~= not Privacy.wow_copilot_display then
    logic_setting_basic.bWoWCopilotDisplay = not Privacy.wow_copilot_display
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_SETTING_STATUS_NOTIFY, logic_setting_basic.bWoWCopilotDisplay)
  end
  if Privacy.total_collect_cnt ~= nil then
    logic_setting_basic.bWoWTotalCollectCnt = not Privacy.total_collect_cnt
  end
  if Privacy.total_play_cnt ~= nil then
    logic_setting_basic.bWoWTotalPlayCnt = not Privacy.total_play_cnt
  end
  if Privacy.total_follower_cnt ~= nil then
    logic_setting_basic.bWoWTotalFollowerCnt = not Privacy.total_follower_cnt
  end
  if Privacy.total_pub_cnt ~= nil then
    logic_setting_basic.bWoWTotalPubCnt = not Privacy.total_pub_cnt
  end
  if Privacy.total_play_total_time ~= nil then
    logic_setting_basic.bWoWTotalPlayTotalTime = not Privacy.total_play_total_time
  end
  if Privacy.season_creative_level ~= nil then
    logic_setting_basic.bWoWSeasonCreativeLevel = not Privacy.season_creative_level
  end
  if Privacy.creator_rank ~= nil then
    logic_setting_basic.bWoWCreatorRank = not Privacy.creator_rank
  end
  if Privacy.support_count ~= nil then
    logic_setting_basic.bWoWSupportCount = not Privacy.support_count
  end
  if Privacy.honors ~= nil then
    logic_setting_basic.bWoWHonors = not Privacy.honors
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY)
end
return logic_setting_basic