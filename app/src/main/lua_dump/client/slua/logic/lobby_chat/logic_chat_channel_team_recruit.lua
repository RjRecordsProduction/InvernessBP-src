local macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local chatMessageList = super_list.Create()
local chatMessageListWOW = super_list.Create()
local chatMessageListPeak = super_list.Create()
local MAX_TEAM_RECRUIT_CACHE_NUM = 100
local C_WOWViewId = 20002
local Enum_ReasonFilterMsg = {
  LobbyType = 1,
  FirstMatchLang = 2,
  TWorth = 3,
  KD = 4,
  ViewNotOpen = 5,
  LevelLimit = 6,
  TabIDError = 7,
  PerspectiveError = 8,
  PlayerNum = 9,
  NoZoneID = 10,
  SegmentLevel = 11,
  SegmentLevelLimit = 12,
  ViewNotExist = 13
}
local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
local logic_chat_channel_team_recruit = {
  maxTeamRecruitDelayTime = 300,
  curRecruitZoneID = -1,
  taskFilterOpen = false,
  clientVersion = 0,
  serverVersion = 0
}
function logic_chat_channel_team_recruit.Init()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local setting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecruitFilter)
  if setting then
    if setting.taskFilterOpen ~= nil then
      logic_chat_channel_team_recruit.taskFilterOpen = setting.taskFilterOpen
    else
      logic_chat_channel_team_recruit.taskFilterOpen = false
    end
  else
    logic_chat_channel_team_recruit.taskFilterOpen = false
  end
end
function logic_chat_channel_team_recruit.AddNewChat(chatMsg)
  log(bWriteLog and "logic_chat_channel_team_recruit.AddNewChat")
  if not chatMsg.selfMsg then
    if chatMsg.msgType == macro.teamPlatFormRecruitMsgType then
      if not logic_chat_channel_team_recruit.TeamPlatFormRecruitMsgTypeFilter(chatMsg.content) then
        log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.AddNewChat teamPlatFormRecruitMsgType Be filtered ")
        return
      end
    elseif not logic_chat_channel_team_recruit.SetTeamRecruitNewChat(chatMsg, chatMsg.content) then
      log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.AddNewChat Be filtered ")
      return
    end
  end
  if chatMsg.msgType == macro.teamPlatFormRecruitMsgType and logic_chat_channel_team_recruit.CheckViewInfoExistModeId(chatMsg.content.mode) or chatMsg.msgType == macro.UGCPlayHallRecruit then
    if #chatMessageListWOW >= MAX_TEAM_RECRUIT_CACHE_NUM then
      logic_chat_table_pool.Recycle(chatMessageListWOW[1])
      chatMessageListWOW:RemoveItem(1)
    end
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    if logic_chat_main.currentChannel ~= macro.Channel.channelTeamRecruit then
      logic_chat_channel_team_recruit.UpdateRedpoint(1)
    end
    chatMessageListWOW:AppendItem(chatMsg)
    return
  end
  if chatMsg.msgType == macro.teamPlatFormRecruitMsgType and logic_chat_channel_team_recruit.CheckIsPeakViewId(chatMsg.content.view) then
    if #chatMessageListPeak >= MAX_TEAM_RECRUIT_CACHE_NUM then
      logic_chat_table_pool.Recycle(chatMessageListPeak[1])
      chatMessageListPeak:RemoveItem(1)
    end
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    if logic_chat_main.currentChannel ~= macro.Channel.channelTeamRecruit then
      logic_chat_channel_team_recruit.UpdateRedpoint(1)
    end
    chatMessageListPeak:AppendItem(chatMsg)
    return
  end
  if #chatMessageList >= MAX_TEAM_RECRUIT_CACHE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if logic_chat_main.currentChannel ~= macro.Channel.channelTeamRecruit then
    logic_chat_channel_team_recruit.UpdateRedpoint(1)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_chat_channel_team_recruit.SetTeamRecruitNewChat(chatMsg, chat_content)
  local logic_recruit_filter_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_filter_new)
  if chatMsg.msgType == macro.roomRecruitMsgType then
    if logic_recruit_filter_new:DoFilterRoomRecruit(chat_content.map_id, chat_content, chatMsg) == false then
      return false
    end
    local player_num = chat_content.player_num
    local max_player_num = chat_content.max_player_num
    chatMsg.game_model_type = chat_content.game_model_type
    local RoomUpSystem = require("client.logic.roomup.logic_roomup")
    local ugc_room_param = chat_content.ugc_room_param
    if ugc_room_param then
      chatMsg.msg = RoomUpSystem.CombineUGCRoomRecruitMsg(ugc_room_param.name, player_num, max_player_num)
    else
      local map_id = chat_content.map_id
      chatMsg.msg = RoomUpSystem.CombineRoomRecruitMsg(map_id, player_num, max_player_num)
    end
    chatMsg.roomId = chat_content.room_id
  else
    local map_data = chat_content.team_recuit_map_data
    local chat_ctt = chat_content.text
    if logic_recruit_filter_new:DoFilter(map_data, chat_content, chatMsg) == false then
      log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.SetTeamRecruitNewChat Be filtered ")
      return false
    end
    chatMsg.taskId = chat_content.taskId
    chatMsg.isRp = chat_content.isRp
    local TimeUtil = require("client.common.time_util")
    chatMsg.create_time = TimeUtil.GetServerTimeInSec()
    chatMsg.teamId = chat_content.team_id
    chatMsg.game_model_type = chat_content.game_model_type
    chatMsg.voiceType = chat_content.VoiceType
    local _msg, _mapdata = RecruitSystem.TeamRecruitMap(chat_ctt, map_data)
    chatMsg.msg = _msg
    chatMsg.mapData = _mapdata
  end
  return true
end
function logic_chat_channel_team_recruit.ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageList)
  chatMessageList:ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageListWOW)
  chatMessageListWOW:ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageListPeak)
  chatMessageListPeak:ClearData()
end
function logic_chat_channel_team_recruit.FilterMessageList(from)
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  for k = #chatMessageList, 1, -1 do
    local isShow, isRemove = logic_chat_entrance:CheckShowMsg(chatMessageList[k], from)
    if not isShow and isRemove then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_team_recruit.FilterMessageListWOW(from)
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  for k = #chatMessageListWOW, 1, -1 do
    local isShow, isRemove = logic_chat_entrance:CheckShowMsg(chatMessageListWOW[k], from)
    if not isShow and isRemove then
      logic_chat_table_pool.Recycle(chatMessageListWOW[k])
      chatMessageListWOW:RemoveItem(k)
    end
  end
end
function logic_chat_channel_team_recruit.FilterMessageListPeak(from)
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  for k = #chatMessageListPeak, 1, -1 do
    local isShow, isRemove = logic_chat_entrance:CheckShowMsg(chatMessageListPeak[k], from)
    if not isShow and isRemove then
      logic_chat_table_pool.Recycle(chatMessageListPeak[k])
      chatMessageListPeak:RemoveItem(k)
    end
  end
end
function logic_chat_channel_team_recruit.GetMessageList(from)
  logic_chat_channel_team_recruit.FilterMessageList(from)
  return chatMessageList
end
function logic_chat_channel_team_recruit.GetMessageListWOW(from)
  logic_chat_channel_team_recruit.FilterMessageListWOW(from)
  return chatMessageListWOW
end
function logic_chat_channel_team_recruit.GetMessageListPeak(from)
  logic_chat_channel_team_recruit.FilterMessageListPeak(from)
  return chatMessageListPeak
end
function logic_chat_channel_team_recruit.UpdateRedpoint(num)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(macro.Channel.channelTeamRecruit, 0 < num)
end
function logic_chat_channel_team_recruit.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
  for k = #chatMessageListWOW, 1, -1 do
    if chatMessageListWOW[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageListWOW[k])
      chatMessageListWOW:RemoveItem(k)
    end
  end
end
function logic_chat_channel_team_recruit.TeamRecruitMsgTypeFilter(chat_content, zone_id, selfMsg)
  local map_data = chat_content.team_recuit_map_data
  if map_data and chat_content.game_model_type ~= RecruitSystem.T_PLAN_TAB_ID then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    for index, id in pairs(map_data) do
      if id ~= 0 then
        local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(id)
        if not viewInfo then
          return false
        end
      end
    end
  end
  if logic_chat_channel_team_recruit.filterMsg(chat_content, zone_id, selfMsg) then
    return false
  end
  return true
end
function logic_chat_channel_team_recruit.TeamPlatFormRecruitMsgTypeFilter(chat_content)
  if not logic_chat_channel_team_recruit.filterRecruitMsgByTabID(chat_content) then
    log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 000, tab_id = " .. tostring(chat_content.tab_id))
    logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.LobbyType)
    return false
  end
  if chat_content.lang and chat_content.lang == ENUM_RECRUIT_OPENMIC.HAVETO then
    local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
    local selfLang = LanguageSelectSystem.GetFirstMatchLanguageName()
    if selfLang ~= "" and selfLang ~= chat_content.first_match_lang then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 111,selfLang =" .. tostring(selfLang) .. " otherLang =" .. tostring(chat_content.first_match_lang))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.FirstMatchLang, tostring(chat_content.first_match_lang))
      return false
    end
  end
  if RecruitSystem.IsTPlanRecruitMsg(chat_content) then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local selfWorth = LogicTxMissionMain.GetWorth()
    local chatWorth = chat_content.worth or 0
    if selfWorth < chatWorth then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 222,selfWorth =" .. tostring(selfWorth) .. " otherWorth =" .. tostring(chat_content.worth))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.TWorth, tostring(chat_content.worth))
      return false
    end
  else
    local kd = chat_content.kd or 0
    local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
    if TeamPlatformSystem.isKdValueUpdated and TeamPlatformSystem.self_kd < kd - 1 then
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.KD, tostring(chat_content.kd))
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 333,self_kd =" .. tostring(TeamPlatformSystem.self_kd) .. " otherKd =" .. tostring(kd))
      return false
    end
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(chat_content.view)
    if not viewInfo then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 444,view =" .. tostring(chat_content.view))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.ViewNotOpen, tostring(chat_content.view))
      return false
    end
    local pvpLevel = viewInfo.level_limit or 0
    local pveLevel = viewInfo.pve_level_limit or 0
    local selfLevel = DataMgr.roleData.level or 0
    local selfPreLevel = DataMgr.roleData.pve_level or 0
    if pveLevel > selfPreLevel or pvpLevel > selfLevel then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 888,view =" .. tostring(chat_content.view) .. "selfLevel = " .. tostring(selfLevel) .. "selfPvelLevel = " .. tostring(selfPreLevel))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.LevelLimit, tostring(chat_content.view))
      return false
    end
    local tabID = chat_content.tab_id
    if not tabID or type(tabID) ~= "number" then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 555,view =" .. tostring(chat_content.view))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.TabIDError, tostring(chat_content.tab_id))
      return false
    end
    local nPerspective = chat_content.perspective or 0
    if type(nPerspective) ~= "number" or nPerspective ~= ENUM_PerspectiveType.FPP and nPerspective ~= ENUM_PerspectiveType.TPP then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 777,view =" .. tostring(chat_content.view) .. "mode = " .. tostring(chat_content.mode) .. "nPerspective = " .. tostring(nPerspective))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.PerspectiveError, tostring(chat_content.perspective))
      return false
    end
    local nPlayerNum = chat_content.playerNum or 0
    if type(nPlayerNum) ~= "number" or nPlayerNum <= 1 then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 888, nPlayerNum =" .. tostring(nPlayerNum))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.PlayerNum, tostring(chat_content.playerNum))
      return false
    end
    local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
    if not logic_team_platform_new:IsClassicRank(tabID) then
      return true
    end
    local msgSegLevel = chat_content.segment_level or 0
    if not logic_chat_channel_team_recruit.IsSegmentMatch(tabID, msgSegLevel, nPerspective, nPlayerNum, chat_content.view) then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 100,msgSegLevel =" .. tostring(msgSegLevel) .. "tabID = " .. tostring(tabID) .. "view = " .. tostring(chat_content.view) .. "mode = " .. tostring(chat_content.mode))
      return false
    end
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(C_WOWViewId)
    if viewInfo and viewInfo.menu_id and tabID == viewInfo.menu_id then
      return true
    end
    local tabList = logic_mode_selection:GetViewTypeMenuList()
    local isTabExist = false
    if tabList then
      for _, v in ipairs(tabList) do
        if v.id == tabID then
          isTabExist = true
          break
        end
      end
    end
    if not isTabExist then
      log(bWriteLog and "[v_wllwu] TeamPlatFormRecruitMsgTypeFilter is Filter 666,tabID =" .. tostring(tabID) .. " view = " .. tostring(chat_content.view))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.TabIDError, tostring(chat_content.tab_id))
      return false
    end
  end
  return true
end
function logic_chat_channel_team_recruit.IsCanShowRecruitMsg(chat_content, isSelfMsg)
  if not chat_content.send_to_corps_channel and not chat_content.send_to_room_channel and not isSelfMsg then
    return logic_chat_channel_team_recruit.TeamPlatFormRecruitMsgTypeFilter(chat_content)
  end
  if not logic_chat_channel_team_recruit.filterRecruitMsgByTabID(chat_content) then
    log(bWriteLog and "[v_wllwu] IsCanShowRecruitMsg is Filter 000, tab_id = " .. tostring(chat_content.tab_id))
    logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.LobbyType)
    return false
  end
  if not RecruitSystem.IsTPlanRecruitMsg(chat_content) then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(chat_content.view)
    if not viewInfo then
      log(bWriteLog and "[v_wllwu] IsCanShowRecruitMsg is Filter 111,view =" .. tostring(chat_content.view))
      logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.ViewNotExist, tostring(chat_content.view))
      return false
    elseif viewInfo.id and viewInfo.id == 90069 then
      local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
      local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
      if PeakGameConfig.EnumPeakGameState.NotInPeakGameStartTime > LogicPeakGame:GetCurPeakGameState() then
        log(bWriteLog and string.format("[v_wllwu] IsCanShowRecruitMsg is Filter by Peak, state = %s", LogicPeakGame:GetCurPeakGameState()))
        logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.ViewNotExist, tostring(chat_content.view))
        return false
      end
    end
  end
  return true
end
function logic_chat_channel_team_recruit.SendFilterMsgTLog(reason, reasonStr)
  log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.SendFilterMsgTLog, reason = " .. tostring(reason) .. " reasonStr = " .. tostring(reasonStr))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.TeamPlatFormMsgFilterReason, reason, reasonStr)
end
function logic_chat_channel_team_recruit.IsSegmentMatch(tabID, segmentLevel, perspective, playerNum, viewId)
  log(bWriteLog and string.format("[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch(%s, %s, %s, %s)", tostring(tabID), tostring(segmentLevel), tostring(perspective), tostring(playerNum)))
  if not (tabID and segmentLevel and perspective) or not playerNum then
    return
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneId = ZoneSystem.nChooseZoneID
  log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch, zoneID = " .. tostring(zoneId))
  if not zoneId then
    logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.NoZoneID)
    log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch, return 1")
    return
  end
  local maxSelfSegment = 0
  local segmentInfo = DataMgr.GetSegmentByZoneId(zoneId)
  if segmentInfo then
    if perspective == ENUM_PerspectiveType.TPP then
      maxSelfSegment = playerNum == 2 and segmentInfo.double or segmentInfo.team
    else
      maxSelfSegment = playerNum == 2 and segmentInfo.fpp_double or segmentInfo.fpp_team
    end
  end
  log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch, maxSelfSegment = " .. tostring(maxSelfSegment))
  local selfSegConfig = FuncUtil.GetRankTableData(maxSelfSegment)
  if selfSegConfig and segmentLevel > selfSegConfig.IntegralTypeNew then
    log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch, return 2, IntegralTypeNew = " .. tostring(selfSegConfig.IntegralTypeNew))
    local reasonStr = string.format("%s;%s;%s;%s;%s", tostring(maxSelfSegment), tostring(segmentLevel), tostring(viewId), tostring(perspective), tostring(playerNum))
    logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.SegmentLevel, reasonStr)
    return false
  end
  if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
    local minLimitSeg, maxLimitSeg = LogicTeamUpLimit.GetSpecifiedModeSegmentLimit(perspective, playerNum)
    log(bWriteLog and string.format("[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch minLimitSeg(%s), maxLimitSeg(%s)", tostring(minLimitSeg), tostring(maxLimitSeg)))
    if 0 < minLimitSeg and 0 < maxLimitSeg then
      local minSegCfg = FuncUtil.GetRankTableData(minLimitSeg)
      local maxSegCfg = FuncUtil.GetRankTableData(maxLimitSeg)
      if minSegCfg and maxSegCfg then
        if segmentLevel < minSegCfg.IntegralTypeNew or segmentLevel > maxSegCfg.IntegralTypeNew then
          local reasonStr = string.format("%s;%s;%s;%s", tostring(segmentLevel), tostring(viewId), tostring(perspective), tostring(playerNum))
          logic_chat_channel_team_recruit.SendFilterMsgTLog(Enum_ReasonFilterMsg.SegmentLevelLimit, reasonStr)
          log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsSegmentMatch, return 3")
          return false
        end
        return minSegCfg.IntegralTypeNew, maxSegCfg.IntegralTypeNew
      end
    end
  end
  return true
end
function logic_chat_channel_team_recruit.filterRecruitMsgByTabID(chat_content)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXMission = LogicTxMissionMain.IsInXMission()
  if RecruitSystem.IsTPlanRecruitMsg(chat_content) then
    return isInXMission
  end
  return not isInXMission
end
function logic_chat_channel_team_recruit.filterMsg(chat_content, zone_id, selfMsg)
  if false == selfMsg then
    local zoneIp = ""
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local zoneList = ZoneSystem.chooseZoneList
    for i, v in pairs(zoneList) do
      if v.zone_id == zone_id then
        zoneIp = v.tpingsvr_ip
      end
    end
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    local fakeShowDelay = 10000
    local serveryDelay = logic_zone_delay.GetZoneDelay(zone_id, fakeShowDelay, 10000)
    log(bWriteLog and "god test serveryDelay " .. tostring(serveryDelay) .. " zoneIp " .. tostring(zoneIp))
    if serveryDelay > logic_chat_channel_team_recruit.maxTeamRecruitDelayTime then
      return true
    else
      log(bWriteLog and "god test ping too delay ")
    end
    return logic_chat_channel_team_recruit.SegmentLimitFilter(chat_content)
  end
  return false
end
function logic_chat_channel_team_recruit.SegmentLimitFilter(chat_content)
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return false
  end
  if not chat_content.text then
    return false
  end
  local StringUtil = require("common.string_util")
  local msgAtt = StringUtil.Split(chat_content.text, "-")
  local msgArr1 = int32ToBufStr(tonumber(msgAtt[1]) or 0)
  local tabID = msgArr1[1] or 0
  local perspectiveIndex = msgArr1[2] or 0
  local msgArr3 = int32ToBufStr(tonumber(msgAtt[3]) or 0)
  local msgSegment = msgArr3[2] or 0
  local tablepool = require("client.slua.logic.lobby_chat.logic_chat_recruit_bufstr_table_pool")
  tablepool.Recycle(msgArr1)
  tablepool.Recycle(msgArr3)
  local nPerspective = perspectiveIndex == 2 and ENUM_PerspectiveType.TPP or ENUM_PerspectiveType.FPP
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  if not logic_team_platform_new:IsClassicRank(tabID) then
    return false
  end
  local selfSegConfig = FuncUtil.GetRankTableData(msgSegment)
  if selfSegConfig and selfSegConfig.IntegralTypeNew then
    log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.SegmentLimitFilter, IntegralTypeNew = " .. tostring(selfSegConfig.IntegralTypeNew))
    msgSegment = selfSegConfig.IntegralTypeNew
  end
  return logic_chat_channel_team_recruit.IsSegmentMatch(tabID, msgSegment, nPerspective, 4)
end
function logic_chat_channel_team_recruit.IsShowSelfTeamRecruitMsg(chatData, is_history)
  if is_history then
    return true
  end
  local TableUtil = require("common.table_util")
  local msgType = TableUtil.GetTableValue(chatData, "chat_content", "msgType")
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local selfMsg = logic_chat_main.IsSelfMsg(chatData.send_uid)
  if not selfMsg then
    return true
  end
  log(bWriteLog and "[v_wllwu] IsShowSelfTeamRecruitMsg msgType is\239\188\154" .. tostring(msgType))
  log_tree(bWriteLog and "[v_wllwu] IsShowSelfTeamRecruitMsg, chatData is:", chatData)
  log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsShowSelfTeamRecruitMsg true, msgType is:" .. tostring(msgType))
  if msgType ~= macro.teamPlatFormRecruitMsgType then
    return true
  end
  local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
  local isOpen = logic_chat_recruit_msg:IsNewPlanOpen()
  if isOpen then
    log(bWriteLog and "[v_wllwu] logic_chat_channel_team_recruit.IsShowSelfTeamRecruitMsg, return false")
    return false
  end
  return true
end
function logic_chat_channel_team_recruit.CheckViewInfoExistModeId(mode_id)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(C_WOWViewId)
  if not viewInfo then
    return false
  end
  for id, _ in pairs(viewInfo.options.team_type_maps) do
    if mode_id == id then
      return true
    end
  end
  return false
end
function logic_chat_channel_team_recruit.CheckIsPeakViewId(viewID)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isPeak = logic_mode_selection:IsPeakGameViewID(viewID)
  return isPeak
end
return logic_chat_channel_team_recruit