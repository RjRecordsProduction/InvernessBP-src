local logic_chat_entrance_base = {}
function logic_chat_entrance_base:GetNormalMsgContent(chatMsg)
  if chatMsg.voiceMsgId then
    return LocUtil.GetLocalizeResStr(106016)
  else
    return chatMsg.msg
  end
end
function logic_chat_entrance_base:GetTeamRecruitMsgContent(chatMsg)
  if chatMsg.content ~= nil then
    local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
    local mapData = chatMsg.mapData
    if mapData == nil and chatMsg.content and chatMsg.content.team_recuit_map_data then
      mapData = chatMsg.content.team_recuit_map_data
    end
    local msg = RecruitSystem.TeamRecruitMap(chatMsg.content.text, mapData)
    return LocUtil.GetLocalizeResStr(110027) .. " " .. (msg or "")
  end
end
function logic_chat_entrance_base:GetTeamPlatFormRecruitMsgContent(chatMsg)
  if not chatMsg.content then
    return ""
  end
  local content = chatMsg.content
  local str = ""
  local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
  if RecruitSystem.IsTPlanRecruitMsg(content) then
    local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
    local mapName, modeName = XMissionTeamUpSystem.GetModeShowInfo(content.sub_mode_group)
    str = LocUtil.LocalizeResFormat(7545, mapName, modeName)
  else
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    str = logic_mode_utils.GetMapNameByViewID(content.view)
  end
  return LocUtil.LocalizeResFormat(110027) .. (str or "")
end
function logic_chat_entrance_base:GetRoomRecruitMsgContent()
  return DataMgr.GetMsgByID(110027) .. DataMgr.GetMsgByID(117067)
end
function logic_chat_entrance_base:GetAchievementMsgContent(chatMsg)
  if chatMsg.content.other ~= nil then
    local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
    local achievement = logic_achievement.MakeSingleDetailData(chatMsg.content.other.achievementId)
    return string.format(LocUtil.GetLocalizeResStr("5082"), tostring(achievement.title))
  end
  return chatMsg.msg
end
function logic_chat_entrance_base:GetTargetShareMsgContent()
  return DataMgr.GetMsgByID(9921)
end
function logic_chat_entrance_base:GetWonderfulReplayMsgContent()
  return DataMgr.GetMsgByID(24668)
end
function logic_chat_entrance_base:GetisLandBattleShareMsgContent(oppoId)
  if oppoId and oppoId ~= 0 then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(oppoId)
    }, function(list)
      if 1 <= #list then
        return LocUtil.LocalizeResFormat(34730, list[1].nickName)
      end
    end, Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_BATTLE_SHARE)
    return DataMgr.GetMsgByID(34750)
  end
  return DataMgr.GetMsgByID(34750)
end
function logic_chat_entrance_base:GetComebackNotifyFriendMsg()
  return LocUtil.GetLocalizeResStr("12405")
end
function logic_chat_entrance_base:GetChatRoomInviteContent()
  return DataMgr.GetMsgByID(38769)
end
function logic_chat_entrance_base:GetProundHornMsgContent(chatMsg)
  if not chatMsg or not chatMsg.msg then
    return ""
  end
  local proundLevel = tonumber(chatMsg.msg)
  if not proundLevel then
    return ""
  end
  local levelStr = LocUtil.LocalizeResFormat(43196, proundLevel)
  return LocUtil.LocalizeResFormat(43192, levelStr)
end
function logic_chat_entrance_base:GetUGCShareMsgContent(chatMsg)
  return LocUtil.LocalizeResFormat(7545, LocUtil.GetLocalizeResStr(70063), chatMsg.content.other.mod_name)
end
function logic_chat_entrance_base:GetUGCShareCollectionListMsgContent(chatMsg)
  return LocUtil.LocalizeResFormat(7545, LocUtil.GetLocalizeResStr(70063), chatMsg.content.other.name)
end
function logic_chat_entrance_base:GetRedpacketMsgContent(chatMsg)
  local utils = require("client.slua.logic.crp.ChatRedpacketUtils")
  local basic_info = chatMsg.content.redpacket.basic_info
  local pickup_type = basic_info.pickup_type
  if pickup_type == utils.EPickupType.Pwd then
    return LocUtil.GetLocalizeResStr(48027)
  end
  local msg_type = basic_info.msg_type
  if msg_type == utils.EMsgType.Metro then
    local redpacket_item_id = basic_info.redpacket_item_id
    local ChatRedpacketUtils = require("client.slua.logic.crp.ChatRedpacketUtils")
    local itemId = ChatRedpacketUtils.MetroGetItemIDByRedpacketItemID(redpacket_item_id)
    local ItemName = ""
    if itemId then
      local itemCfg = CDataTable.GetTableData("Item", itemId)
      if itemCfg then
        ItemName = itemCfg.ItemName
      end
    end
    local text = LocUtil.LocalizeResFormat(88246, ItemName)
    return text
  end
  return chatMsg.msg
end
function logic_chat_entrance_base:GetPlayHallRoomRecruitMsgContent()
  return LocUtil.GetLocalizeResStr(110027)
end
function logic_chat_entrance_base:GetOpenBlackMsgContent(chatMsg)
  return LocUtil.LocalizeResFormat(chatMsg.content.chatMsg, chatMsg.content.last_week_count, chatMsg.content.intimacies)
end
function logic_chat_entrance_base:GetMilestoneMsgContent(chatMsg)
  if not chatMsg or not chatMsg.content then
    return ""
  end
  local text = ""
  local other = chatMsg.content.other
  if other and other.itemID then
    local tItemCfg = CDataTable.GetTableData("Item", other.itemID)
    if tItemCfg then
      text = LocUtil.LocalizeResFormat(82021, tItemCfg.ItemName)
    else
      log(bWriteLog and string.format("reuse_list_chat_item:GetMilestoneMsgContent tItemCfg is nil itemID=%d", other.itemID))
    end
  else
    log(bWriteLog and string.format("reuse_list_chat_item:GetMilestoneMsgContent other is nil"))
  end
  log(bWriteLog and string.format("logic_chat_entrance_base:GetMilestoneMsgContent text = %s", text))
  return text
end
function logic_chat_entrance_base:GetMsgContent(chatMsg)
  if not chatMsg then
    return nil
  end
  local content = ""
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msgHandlers = {
    [chat_macro.chatNormalMsgType] = function()
      if chatMsg.Poke then
        return LocUtil.GetLocalizeResStr(73566)
      elseif chatMsg.Interactive then
        return chatMsg.msgInteractive
      else
        return self:GetNormalMsgContent(chatMsg)
      end
    end,
    [chat_macro.teamRecruitMsgType] = function()
      return self:GetTeamRecruitMsgContent(chatMsg)
    end,
    [chat_macro.roomRecruitMsgType] = function()
      return self:GetRoomRecruitMsgContent()
    end,
    [chat_macro.achivementMsgType] = function()
      return self:GetAchievementMsgContent(chatMsg)
    end,
    [chat_macro.targetShareMsgType] = function()
      return self:GetTargetShareMsgContent()
    end,
    [chat_macro.islandBattleShareMsgType] = function()
      return self:GetisLandBattleShareMsgContent(chatMsg.oppoId or 0)
    end,
    [chat_macro.friendComebackMsgType] = function()
      return self:GetComebackNotifyFriendMsg()
    end,
    [chat_macro.replayShareMsgType] = function()
      return self:GetWonderfulReplayMsgContent()
    end,
    [chat_macro.ChatRoomInviteMsgType] = function()
      return self:GetChatRoomInviteContent()
    end,
    [chat_macro.teamPlatFormRecruitMsgType] = function()
      return self:GetTeamPlatFormRecruitMsgContent(chatMsg)
    end,
    [chat_macro.proundHornMsgType] = function()
      return self:GetProundHornMsgContent(chatMsg)
    end,
    [chat_macro.UGCShareMsgType] = function()
      return self:GetUGCShareMsgContent(chatMsg)
    end,
    [chat_macro.UGCShareChallengeMsgType] = function()
      return self:GetUGCShareMsgContent(chatMsg)
    end,
    [chat_macro.UGCShareChallengeResultMsgType] = function()
      return self:GetUGCShareMsgContent(chatMsg)
    end,
    [chat_macro.UGCShareCollectionMsgType] = function()
      return self:GetUGCShareCollectionListMsgContent(chatMsg)
    end,
    [chat_macro.redpacket] = function()
      return self:GetRedpacketMsgContent(chatMsg)
    end,
    [chat_macro.OpenBlackMsgType] = function()
      return self:GetOpenBlackMsgContent(chatMsg)
    end,
    [chat_macro.ManorGiftMsgType] = function()
      local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
      return logic_chat_manor_topic:GetManorGiftMsgContent(chatMsg)
    end,
    [chat_macro.MilestoneShare] = function()
      return self:GetMilestoneMsgContent(chatMsg)
    end,
    [chat_macro.corpsNewsMsgType] = function()
      return self:GetCorpsNewsContent(chatMsg)
    end,
    [chat_macro.NationalEsportsInviteMsgType] = function()
      return self:GetNationalEsportsInviteMsgContent(chatMsg)
    end,
    [chat_macro.UGCPlayHallRecruit] = function()
      return self:GetPlayHallRoomRecruitMsgContent()
    end
  }
  if msgHandlers[chatMsg.msgType] then
    content = msgHandlers[chatMsg.msgType]()
  elseif chat_macro.ChatMsgContentTextConfig[chatMsg.msgType] then
    content = LocUtil.GetLocalizeResStr(chat_macro.ChatMsgContentTextConfig[chatMsg.msgType])
  else
    content = self:GetNormalMsgContent(chatMsg)
  end
  local name = chatMsg.name
  if chatMsg.msgType == chat_macro.FriendRecruitType and chatMsg.sender_uid == DataMgr.roleData.uid then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(chatMsg.uid)
    name = profile.nickName
  end
  if content == nil or name == nil then
    log_error(bWriteLog and "logic_chat_entrance_base:GetMsgContent - content or name is nil! msgType = " .. tostring(chatMsg.msgType))
    return LocUtil.LocalizeResFormat(1210, 1)
  end
  content = string.format("[%s]: %s", name, content)
  return content
end
function logic_chat_entrance_base:GetCorpsNewsContent(chatMsg)
  local content = ""
  if chatMsg.content and chatMsg.content.extra and chatMsg.content.extra.source == "returning_auto_speak" then
    local text = LocUtil.LocalizeResFormat(chatMsg.content.extra.loc_id, chatMsg.content.extra.nick_name)
    if text and text ~= "" then
      content = text
    end
  else
    content = chatMsg.text
  end
  return content
end
function logic_chat_entrance_base:GetNationalEsportsInviteMsgContent(chatMsg)
  return LocUtil.LocalizeResFormat(78385)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicChatEntranceBase = class(CModuleBase, nil, logic_chat_entrance_base)
return CLogicChatEntranceBase