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
function logic_setting_basic.SetSwitcherAnim(widget, status)
  local bEnable = false
  if type(status) ~= "boolean" then
    if status == 1 then
      bEnable = true
    else
      bEnable = false
    end
  else
    bEnable = status
  end
  if widget then
    widget:SetSwitcherEnable2(bEnable)
  end
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
function logic_setting_basic.GetOneSettingValue(cfgKey)
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) and uSettingConfig[cfgKey] ~= nil then
      log(bWriteLog and "  logic_setting_basic.GetOneSettingValue: get cfgKey" .. tostring(cfgKey) .. "     " .. tostring(uSettingConfig[cfgKey]))
      return uSettingConfig[cfgKey]
    end
  end
  if logic_setting_basic[cfgKey] ~= nil then
    return logic_setting_basic[cfgKey]
  end
  return nil
end
function logic_setting_basic.SetOneSettingValue(cfgKey, value)
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) and uSettingConfig[cfgKey] ~= nil then
      log(bWriteLog and "  : set cfgKey LogicSetting_SetOneSettingValue: " .. tostring(cfgKey) .. " " .. tostring(value))
      uSettingConfig[cfgKey] = value
    end
  end
  if logic_setting_basic[cfgKey] ~= nil then
    logic_setting_basic[cfgKey] = value
  end
end
function logic_setting_basic.CfgConvertNot(key)
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) and uSettingConfig[key] ~= nil then
      log(bWriteLog and "  : CfgConvertNot " .. tostring(key))
      local open = uSettingConfig[key]
      uSettingConfig[key] = not open
      return uSettingConfig[key]
    end
  end
  if logic_setting_basic[key] ~= nil then
    logic_setting_basic[key] = not logic_setting_basic[key]
    return logic_setting_basic[key]
  end
  return nil
end
function logic_setting_basic.CfgConvert1And2(key)
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) and uSettingConfig[key] ~= nil then
      local openPet = uSettingConfig[key]
      local value = 1
      if openPet == 1 then
        value = 2
      end
      uSettingConfig[key] = value
      log(bWriteLog and "  : CfgConvert1And2 " .. tostring(key))
    end
  end
  if logic_setting_basic[key] ~= nil then
    local openPet = logic_setting_basic[key]
    local tvalue = 1
    if openPet == 1 then
      tvalue = 2
    end
    logic_setting_basic[key] = tvalue
    logic_setting_basic[key] = not logic_setting_basic[key]
    return logic_setting_basic[key]
  end
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
    wow_copilot_display = not logic_setting_basic.bWoWCopilotDisplay
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
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PRIVACY_SETTING_STATUS_NOTIFY)
  local Refresh = require("client.logic.setting.refresh.setting_refresh")
  Refresh.RefreshWoWShow("WoWShow")
end
return logic_setting_basic