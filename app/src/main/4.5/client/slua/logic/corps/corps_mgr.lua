local CorpsMgr = {
  saveManagerInfo = nil,
  saveIconID = 0,
  saveIconText = "",
  saveIconColourID = 0,
  onCorpsDataRsp = nil,
  onBatchGetCorpsSummary = nil,
  onGetCorpsSummary = nil,
  onGetCorpsSummaryList = {},
  remindInviteTimeStr = "CorpsRemindInviteTime",
  remindInviteTimeGapStr = "RemindInviteTimeGap",
  cmdrRemindNumLimitStr = "CmdrRemindNumLimit",
  remindNumLimitStr = "RemindNumLimit",
  memberInvitedMarkStr = "CorpsMemberInvitedMark",
  getSummaryReqMapCallBack = {},
  isJumpFromMall = false,
  corps_news_Interval = 60,
  corps_news_gift_id = 12,
  corps_news = {
    last_get_news_time = 0,
    corps_id = 0,
    news_list = {},
    gift_seq_ids = {}
  },
  corps_news_expires = 604800,
  new_corps_exchange = false,
  apply_red = false,
  MainUIIsShow = true,
  CanBeAgentLeader = false,
  corps_star = {},
  IsUseAvatar = false
}
NewsId = {
  player_win = 1,
  seglevel_up = 2,
  achvm_high_point = 3,
  alias_high_quality = 4,
  share_ticket = 5,
  buy_unknown_pass = 6,
  pass_level_up = 7,
  share_item_got = 8,
  activity = 9,
  corps_notice = 10,
  corps_star = 11,
  corps_top_msg = 12
}
local NewsId2MsgHandle = {
  [NewsId.player_win] = function(news, isShowName)
    local param_list = news.param_list
    return GlobalData.GetLocalizeStringWithNum(7822, 1, isShowName and param_list[1] or "", param_list[3])
  end,
  [NewsId.seglevel_up] = function(news, isShowName)
    local param_list = news.param_list
    local seglevel = param_list[2]
    local Segment = FuncUtil.GetRankTableData(seglevel)
    return LocUtil.LocalizeResFormat(7823, isShowName and param_list[1] or "", Segment.Name or "")
  end,
  [NewsId.achvm_high_point] = function(news, isShowName)
    local param_list = news.param_list
    local achieveId = param_list[2]
    local achieveCfg = CDataTable.GetTableData("AchievementCfg", achieveId)
    local achieveName = ""
    if achieveCfg and achieveCfg.Name then
      achieveName = achieveCfg.Name
    end
    return LocUtil.LocalizeResFormat(7824, isShowName and param_list[1] or "", achieveName)
  end,
  [NewsId.alias_high_quality] = function(news, isShowName)
    local param_list = news.param_list
    local aliasId = param_list[2]
    local achieveCfg = CDataTable.GetTableData("AliasCfg", aliasId)
    if not achieveCfg then
      return ""
    end
    local id
    if achieveCfg.AliasQuality == 3 then
      id = 7825
    elseif achieveCfg.AliasQuality == 4 then
      id = 7826
    elseif achieveCfg.AliasQuality == 5 then
      id = 7827
    elseif achieveCfg.AliasQuality == 6 then
      id = 7827
    end
    if not id then
      return ""
    end
    local title = FuncUtil.Gen_title(aliasId, param_list[3], {
      partner_name = param_list[4],
      partner_relation = param_list[5],
      weapon_power_zone_id = param_list[7],
      registertime = param_list[8]
    }, param_list[6])
    return LocUtil.LocalizeResFormat(id, isShowName and param_list[1] or "", title)
  end,
  [NewsId.share_ticket] = function(news, isShowName)
    local param_list = news.param_list
    if param_list[1] ~= "" then
      return GlobalData.GetLocalizeStringWithNum(7828, 1, isShowName and param_list[1] or "", param_list[2])
    else
      return GlobalData.GetLocalizeStringWithNum(7829, 1, isShowName and param_list[1] or "", param_list[2])
    end
  end,
  [NewsId.buy_unknown_pass] = function(news, isShowName)
    local param_list = news.param_list
    local buyCfg = CDataTable.GetTableData("UnknowPassBuyCfg", param_list[2])
    if not buyCfg then
      return ""
    end
    local id = buyCfg.PassType == 1 and 7831 or 7832
    return LocUtil.LocalizeResFormat(id, isShowName and param_list[1] or "")
  end,
  [NewsId.pass_level_up] = function(news, isShowName)
    local param_list = news.param_list
    return LocUtil.LocalizeResFormat(7836, isShowName and param_list[1] or "", param_list[2])
  end,
  [NewsId.share_item_got] = function(news, isShowName)
    local param_list = news.param_list
    local ItemData = CDataTable.GetTableData("Item", param_list[2])
    if not ItemData then
      return ""
    end
    local id
    if ItemData.ItemQuality == 5 then
      id = 7833
    elseif ItemData.ItemQuality == 6 then
      id = 7834
    elseif ItemData.ItemQuality == 7 then
      id = 7835
    end
    if not id then
      return ""
    end
    return LocUtil.LocalizeResFormat(id, isShowName and param_list[1] or "", ItemData.ItemName)
  end,
  [NewsId.activity] = function(news, isShowName, translate_news)
    local param_list = news.param_list
    return LocUtil.LocalizeResFormat(8032, isShowName and param_list[1] or "", translate_news or param_list[2])
  end,
  [NewsId.corps_notice] = function(news, isShowName)
    local param_list = news.param_list
    return LocUtil.LocalizeResFormat(421048, isShowName and param_list[2])
  end,
  [NewsId.corps_star] = function(news, isShowName)
    local param_list = news.param_list
    local uid = param_list[1]
    local corpsMemberList = DataMgr.corpsInfo.corpsMemberList
    local name
    for _, value in pairs(corpsMemberList) do
      if uid == value.id then
        name = value.name
        if name then
          local title = param_list[2]
          if title and type(title) == "number" then
            local msgConfig = CDataTable.GetTableData("CorpsStar", title)
            if msgConfig and msgConfig.StarName then
              title = msgConfig.StarName
            end
          end
          return LocUtil.LocalizeResFormat(46880084, isShowName and name, title)
        else
          return ""
        end
      end
    end
    return ""
  end,
  [NewsId.corps_top_msg] = function(news, isShowName)
    local param_list = news.param_list
    local uid = news.uid
    local corpsMemberList = DataMgr.corpsInfo.corpsMemberList
    local name
    for _, value in pairs(corpsMemberList) do
      if uid == value.id then
        name = value.name
        if name then
          local op = param_list[1]
          if op == 1 or op == 3 then
            local text = LocUtil.LocalizeResFormat(46880127, name)
            return text
          elseif op == 2 then
            local text = LocUtil.LocalizeResFormat(46880128, name)
            return text
          else
            return ""
          end
        else
          return ""
        end
      end
    end
    return ""
  end
}
function CorpsMgr.InitData(corps)
  log_tree("corps kkj", corps)
  if corps == nil then
    return
  end
  DataMgr.corpsInfo.isInit = true
  local CorpsInfoSystem = require("client.slua.logic.corps.logic_corps_info")
  CorpsInfoSystem.InitCorpsInfo(corps)
  CorpsInfoSystem.InitCorpsTaskInfo(corps)
  CorpsMgr.InitNews()
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.InitMembers(corps.members)
  CorpsMgr.SetCropsStarListFromMembers(corps.members)
  CorpsMgr.InitManagerInfo(corps)
  local CorpsApplyListUILogic = require("client.slua.logic.corps.logic_corps_apply_list")
  CorpsApplyListUILogic.InitApplyList(corps.apply_list)
  local CorpsWelfareSystem = require("client.slua.logic.corps.logic_corps_welfare")
  CorpsWelfareSystem.HaveCanReceiveShareTicketReq()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INFO, corps)
end
function CorpsMgr.InitID(corps_id)
  log(bWriteLog and "CorpsMgr.InitID corps_id " .. tostring(corps_id))
  DataMgr.corpsInfo.id = corps_id or 0
  if corps_id == 0 then
    local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
    CorpsMemberSystem.isInit = false
    CorpsMgr.ResetData()
  end
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateLobbyRedDot()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  LobbySocialSystem.get_corps_summary_req(DataMgr.roleData.uid)
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  logic_corps_fight.ReqNecessaryInfoForFight()
end
function CorpsMgr.InitNews()
  CorpsMgr.corps_news = {
    last_get_news_time = 0,
    corps_id = 0,
    news_list = {},
    gift_seq_ids = {}
  }
end
function CorpsMgr.InitManagerInfo(corps)
  DataMgr.corpsInfo.isAcceptApply = corps.accept_apply
  DataMgr.corpsInfo.isNeedApproval = corps.need_approval
  if corps.join_level then
    DataMgr.corpsInfo.joinLevel = math.max(1, corps.join_level)
  else
    DataMgr.corpsInfo.joinLevel = 0
  end
  if corps.join_segment then
    DataMgr.corpsInfo.joinSegment = math.max(1, corps.join_segment)
  else
    DataMgr.corpsInfo.joinSegment = 0
  end
  DataMgr.corpsInfo.commanderId = corps.leader
  if corps.change_name_time then
    DataMgr.corpsInfo.changeNameTime = corps.change_name_time
  end
end
function CorpsMgr.ShowCorpsLimitError()
  local level = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0
  local msg = LocUtil.LocalizeResFormat(411038, level, CorpsMgr.GetLevelName(level))
  ShowNotice(msg)
end
function CorpsMgr.ResetData()
  DataMgr.corpsInfo.isInit = false
  DataMgr.corpsInfo.id = 0
  DataMgr.corpsInfo.level = 0
  DataMgr.corpsInfo.memberNum = 0
  DataMgr.corpsInfo.agent_leader = {}
  local logic_corps_energy_mission = require("client.slua.logic.corps.logic_corps_energy_mission")
  logic_corps_energy_mission.energy_mission_reddot = false
  CorpsMgr.new_corps_exchange = false
  CorpsMgr.CanBeAgentLeader = false
  CorpsMgr.InitNews()
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.ResetData()
  local CorpsShopSystem = require("client.slua.logic.corps.logic_corps_shop")
  CorpsShopSystem.ClearData()
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  CorpsTrainingSystem.ResetData()
end
function CorpsMgr.IsInCorps()
  return DataMgr.corpsInfo.id and DataMgr.corpsInfo.id ~= 0
end
function CorpsMgr.on_sync_player_corps_id(corps_id, opentime, all_reddot, new_corps_exchange, exchange_red_info, corps_award_goal_ids, red_list, share_ticket_drop_id, corps_data, isSignPk)
  log(bWriteLog and "CorpsMgr.on_sync_player_corps_id corps_id " .. tostring(corps_id) .. ",opentime:" .. tostring(opentime) .. ",all_reddot:" .. tostring(all_reddot) .. ",new_corps_exchange:" .. tostring(new_corps_exchange) .. ",exchange_red_info:" .. tostring(exchange_red_info) .. ",corps_data:" .. tostring(corps_data) .. ",isSignPk:" .. tostring(isSignPk))
  if corps_id ~= 0 and corps_id == DataMgr.corpsInfo.id then
    return
  end
  local logic_corps = require("client.slua.logic.corps.logic_corps")
  logic_corps.opentime = opentime or 0
  local old_  CorpsMgr.InitID(corps_id)
  if corps_data ~= nil then
    local logic_corps_fight_new = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_fight_new)
    if logic_corps_fight_new ~= nil then
      logic_corps_fight_new:SetCropsId(corps_data)
      logic_corps_fight_new:SetSignPk(isSignPk)
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_SHOW_CORPS_FIGHT_POPUP_TIP)
    end
  end
  local CorpsSuggestionSystem = require("client.slua.logic.corps.logic_corps_suggestion")
  if corps_id ~= 0 then
    CorpsMgr.    local logic_corps_energy_mission = require("client.slua.logic.corps.logic_corps_energy_mission")
    logic_corps_energy_mission.    log_tree("on_sync_player_corps_id", {red_list = red_list, corps_award_goal_ids = corps_award_goal_ids})
    if red_list then
      local CorpsApplyListUILogic = require("client.slua.logic.corps.logic_corps_apply_list")
      CorpsApplyListUILogic.HasRedPoint = red_list[1]
      logic_corps_energy_mission.energy_mission_reddot = red_list[2]
      local CorpsWelfareSystem = require("client.slua.logic.corps.logic_corps_welfare")
      CorpsWelfareSystem.      CorpsWelfareSystem.SetWelfareReceiveFlag(red_list[3])
      local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
      CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.welfare)
    end
    local CorpGiftExchangeSystem = require("client.slua.logic.corps_gift_exchange.logic_corp_gift_exchange")
    CorpGiftExchangeSystem.is_show_redPoint = exchange_red_info or false
    if LobbySystem.roleData.is_low_corps then
      CorpsSuggestionSystem.get_corps_invitee_list_req()
    else
      CorpsSuggestionSystem.InitInvitedCorpsArray({})
    end
  else
    CorpsSuggestionSystem.get_corps_invitee_list_req()
  end
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateLobbyRedDot()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, old_corps_id)
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  logic_corps_fight.ReqNecessaryInfoForFight()
end
function CorpsMgr.SendCorpsDataReq(onCorpsDataRspCB)
  log(bWriteLog and "CorpsMgr.SendCorpsDataReq")
  CorpsMgr.onCorpsDataRsp = onCorpsDataRspCB
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_data_req()
end
function CorpsMgr.get_corps_data_rsp(msg, corps)
  log(bWriteLog and "CorpsMgr.get_corps_data_rsp msg " .. tostring(msg))
  if msg == NetErrorCode_NONE then
    CorpsMgr.InitData(corps)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_INFO, corps)
    CorpsMgr.CallGetCorpsDataCB()
    CorpsMgr.TaskGetDataReq()
  elseif msg ~= nil then
    CorpsMgr.InitID(0)
    if msg == 411008 then
      CorpsMgr.CallGetCorpsDataCB()
    else
      ShowNotice(msg)
    end
  end
end
function CorpsMgr.CallGetCorpsDataCB()
  log(bWriteLog and "CorpsMgr.CallGetCorpsDataCB")
  if CorpsMgr.onCorpsDataRsp ~= nil then
    local cb = CorpsMgr.onCorpsDataRsp
    CorpsMgr.onCorpsDataRsp = nil
    cb()
  end
end
function CorpsMgr.CreateCorpsReq(Create_Name, Announcement, City_ID, Icon_ID, Icon_Text, Icon_ColourID, EnergyType)
  log(bWriteLog and "CorpsMgr.CreateCorpsReq")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  if Icon_ID == 0 then
    Icon_ID = 2001001
  end
  log(bWriteLog and "Name:" .. Create_Name .. "|Icon ID:" .. Icon_ID .. "|Announcement: " .. Announcement .. "|CityID:" .. City_ID .. "|Icon_Text:" .. Icon_Text .. "|Icon_ColourID:" .. Icon_ColourID .. "|EnergyType:" .. tostring(EnergyType))
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_create_corps_req(Create_Name, Icon_ID, Announcement, City_ID, Icon_Text, Icon_ColourID, EnergyType)
end
function CorpsMgr.create_corps_rsp(msg, corps_id, corps)
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "CorpsMgr.create_corps_rsp msg " .. tostring(msg))
  if msg == "ban-create-corps" then
    local endtime = corps_id
    local reason = corps
    local title = LocUtil.GetLocalizeResStr(101001)
    local date = TimeUtil.FormatTime_YMDHMS(endtime, true)
    local textvalue = LocUtil.GetLocalizeResStr(115007)
    local text = string.format(textvalue, reason .. "\n", date)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text)
    return
  end
  if msg == NetErrorCode_NONE then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.Close()
    CorpsMgr.InitID(corps_id)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_INFO, corps)
    CorpsMgr.InitData(corps)
    CorpsMgr.TaskGetDataReq()
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.OpenCorpsUIWithForceReq()
    ShowNotice(410045)
  elseif msg == 411038 then
    CorpsMgr.ShowCorpsLimitError()
  elseif msg == 433003 or msg == 411011 or msg == 411019 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
  else
    ShowNotice(msg)
  end
end
function CorpsMgr.GetCorpsConfig(configName)
  local msgConfig = CDataTable.GetTableData("CorpsConfig", configName)
  if msgConfig then
    return msgConfig.ConfigValue
  end
  return nil
end
function CorpsMgr.GetConfigToNumber(cfgID)
  local cfg = CDataTable.GetTableData("CorpsConfig", cfgID)
  if cfg then
    return tonumber(cfg.ConfigValue)
  end
  return nil
end
function CorpsMgr.SendSetupApplyParamReq(accept_apply, need_approval, join_level, join_segment)
  log(bWriteLog and "CorpsMgr.SendSetupApplyParamReq")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  CorpsMgr.saveManagerInfo = {
    accept_apply = accept_apply,
    need_approval = need_approval,
    join_level = join_level,
      }
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_setup_apply_param_req(accept_apply, need_approval, join_level, join_segment)
end
function CorpsMgr.corps_setup_apply_param_rsp(msg)
  if msg == nil then
    return
  end
  log(bWriteLog and "CorpsMgr.corps_setup_apply_param_rsp msg " .. tostring(msg))
  if msg == NetErrorCode_NONE then
    ShowNotice(410004)
    if CorpsMgr.saveManagerInfo ~= nil then
      CorpsMgr.InitManagerInfo(CorpsMgr.saveManagerInfo)
      CorpsMgr.saveManagerInfo = nil
    end
  else
    ShowNotice(msg)
  end
end
function CorpsMgr.SendChangeIconReq(iconID, iconText, textCoulourId)
  log(bWriteLog and "CorpsMgr.SendChangeIconReq iconID " .. iconID .. " iconText:" .. iconText .. " textCoulourId:" .. textCoulourId)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  CorpsMgr.saveIconID = iconID
  CorpsMgr.saveIconText = iconText
  CorpsMgr.saveIconColourID = textCoulourId
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_change_icon_req(iconID, iconText, textCoulourId)
end
function CorpsMgr.corps_change_icon_rsp(res, timevalue)
  if res == nil then
    return
  end
  log(bWriteLog and "CorpsMgr.corps_change_icon_rsp res " .. tostring(res))
  if res == NetErrorCode_NONE then
    DataMgr.corpsInfo.icon = CorpsMgr.saveIconID
    DataMgr.corpsInfo.icon_text = CorpsMgr.saveIconText
    DataMgr.corpsInfo.icon_text_colour = CorpsMgr.saveIconColourID
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    local CorpsSummary = LobbySocialSystem.CacheCorpsSummary[DataMgr.corpsInfo.id]
    if CorpsSummary then
      CorpsSummary.icon = DataMgr.corpsInfo.icon
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_ICON)
    ShowNotice(301192)
  elseif res == 433005 then
    local TimeUtil = require("client.common.time_util")
    ShowNotice(LocUtil.LocalizeResFormat(tostring(res), TimeUtil.FormatCountDownTime_DH_or_HM(timevalue, true)))
  elseif res == 433003 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
  else
    ShowNotice(res)
  end
end
function CorpsMgr.GetMaxSegment(profileInfo)
  return profileInfo.cur_max_segment_level or 0
end
function CorpsMgr.TaskGetDataReq()
  log(bWriteLog and "$$CorpsMgr.TaskGetDataReq")
end
function CorpsMgr.get_corps_task_award_rsp(ret, taskid, itemlist)
  log(bWriteLog and "CorpsMgr.get_corps_task_award_rsp msg " .. tostring(ret))
  if ret == NetErrorCode_NONE then
    local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
    CorpsTrainingSystem.TeamTaskStatus = 2
    if 0 < #itemlist then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(itemlist)
    end
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.UpdateRedPoint()
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GOAL_TRAINING_UPDATE_INFO)
  else
    log(bWriteLog and "$$CorpsMgr.get_corps_task_award_rsp" .. ret)
    ShowNotice(tonumber(ret))
  end
end
function CorpsMgr.GetAvatarBaseInfo(idList, completeFunc, forceUpdate, selfFunc)
  log_tree("idList", idList)
  local callback = function(profileList)
    local infoList = {}
    for _, profileInfo in ipairs(profileList) do
      local info = CorpsMgr.ConvertProfileToBaseInfo(profileInfo)
      infoList[tonumber(profileInfo.uid)] = info
    end
    if completeFunc then
      if selfFunc then
        completeFunc(selfFunc, infoList)
      else
        completeFunc(infoList)
      end
    end
  end
  if forceUpdate == nil then
    forceUpdate = true
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(idList, callback, Enum_PROFILE_REPORT_CFG.CORPS_BASE)
end
function CorpsMgr.ConvertProfileToBaseInfo(profileInfo)
  local TimeUtil = require("client.common.time_util")
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local info = {}
  info.strUid = profileInfo.uid
  info.Name = profileInfo.nickName
  info.Level = profileInfo.level
  info.Sex = profileInfo.sex
  info.RankIntegralLevel = CorpsMgr.GetMaxSegment(profileInfo)
  info.IconUrl = profileInfo.picUrl
  info.IconFrameID = profileInfo.cur_avatar_box_id
  info.lastOnlineTime = profileInfo.lastOnlineTime
  info.lastOnlineTimeStr = TimeUtil.GetLastOnlineTimeStr(profileInfo.lastOnlineTime)
  info.nation = profileInfo.nation
  info.enableWatch = profileInfo.enableWatch
  info.aliasId = profileInfo.alias.id
  info.roleNation = profileInfo.nation
  info.aliasTitle = profileInfo.alias.title
  info.aliasNation = profileInfo.alias.nation
  info.segment_info_solo, info.segment_info_duo, info.segment_info_squad = FuncUtil.GetMaxSegement(profileInfo.segment_info)
  info.upass_is_buy, info.upass_is_show, info.upass_keep_buy, info.upass_cur_value, info.pass_type = UnknowPassUtil.ParseUpassInfo(profileInfo.upass)
  info.history_max_segment_level = profileInfo.history_max_segment_level
  info.history_max_segment_season_id = profileInfo.history_max_segment_season_id
  info.cur_max_segment_level = profileInfo.cur_max_segment_level
  info.vipLevel = profileInfo.vipLevel
  info.platName = profileInfo.platName
  return info
end
function CorpsMgr.get_corps_event_list()
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_get_corps_event_list()
end
function CorpsMgr.get_corps_event_list_rsp(ok, corps_id, event_list)
  log(bWriteLog and "===============get_corps_event_list_rsp")
  if ok == NetErrorCode_NONE then
    local CorpsInfoSystem = require("client.slua.logic.corps.logic_corps_info")
    CorpsInfoSystem.InitCorpsLog(event_list)
  end
end
local announcementCache = ""
function CorpsMgr.corps_change_announcement_req(announcement)
  announcementCache = announcement
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_change_announcement_req(announcement)
  log(bWriteLog and "================= " .. announcement)
end
function CorpsMgr.corps_change_announcement_rsp(msg)
  if msg == NetErrorCode_NONE then
    ShowNotice(410040)
    DataMgr.corpsInfo.announcement = announcementCache
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_ANNOUNCEMENT, announcementCache)
  elseif msg == 433028 then
    ShowNotice(421047)
  elseif msg == 411011 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
  else
    ShowNotice(tonumber(msg))
  end
end
local noticeCache = ""
function CorpsMgr.corps_change_notice_req(notice)
  noticeCache = notice
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_change_notice_req(notice)
  log(bWriteLog and "================= " .. notice)
end
function CorpsMgr.corps_change_notice_rsp(msg, unlock_time, uid, change_notice_time)
  local TimeUtil = require("client.common.time_util")
  if msg == NetErrorCode_NONE then
    ShowNotice(421041)
    DataMgr.corpsInfo.notice = noticeCache
    if uid then
      DataMgr.corpsInfo.change_notice_      DataMgr.corpsInfo.    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_NOTICE, noticeCache)
  elseif msg == 433028 then
    local startTimeStr = TimeUtil.FormatTime_YMD(unlock_time)
    ShowNotice(LocUtil.LocalizeResFormat(22203, startTimeStr))
  elseif msg == 433030 then
    ShowNotice(421046)
  elseif msg == 421039 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
  else
    ShowNotice(tonumber(msg))
  end
end
function CorpsMgr.on_notify_corps_notice_change(corps_id, op_uid, notice, change_notice_time)
  if corps_id ~= DataMgr.corpsInfo.id then
    log(bWriteLog and "CorpsMgr.on_notify_corps_notice_change is not self corpsid " .. tostring(corps_id) .. " selfid " .. tostring(DataMgr.corpsInfo.id))
    return
  end
  DataMgr.corpsInfo.  if op_uid then
    DataMgr.corpsInfo.change_notice_uid = op_uid
    DataMgr.corpsInfo.  end
  local canShowTip, canShowRed = CorpsMgr:CanShowNewNoticeTip()
  if canShowTip then
    local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
    logic_chat_entrance:SetCorpsChatTopMsgNotify(logic_chat_entrance.ENUM_CORP_MSG_TYPE.NEW_NOTICE_MSG)
  end
  if canShowRed then
    CorpsMgr.hasNewNotice = true
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_NOTICE, notice)
end
function CorpsMgr.get_auto_invite_list_req()
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_get_auto_invite_list_req()
end
function CorpsMgr.get_auto_invite_list_rsp(ret, idList)
  log_tree("get_auto_invite_list_req", {ret, idList})
  if ret == NetErrorCode_NONE and #idList ~= 0 then
    local TimeUtil = require("client.common.time_util")
    DataMgr.corpsInfo.lastAutoInviteTime = TimeUtil.GetServerTimeInSec()
    local common_config = require("client.slua.common.common_config")
    if not common_config:IsBlockingPopupTip() then
      UIManager.ShowUI(UIManager.UI_Config.Corps_AutoInvite_UIBP, idList)
    else
      log(bWriteLog and "Don't ShowUI Corps_AutoInvite_UIBP : UI responsiveness testing")
    end
  end
end
function CorpsMgr.corps_auto_invite_req(idList)
  if 0 < #idList then
    local CorpsHander = require("client.network.Protocol.CorpsHandler")
    CorpsHander.send_corps_auto_invite_req(idList)
  else
    UIManager.CloseUI(UIManager.UI_Config.Corps_AutoInvite_UIBP)
  end
end
function CorpsMgr.corps_auto_invite_rsp(ret)
  if ret == NetErrorCode_NONE then
    ShowNotice(422001)
    UIManager.CloseUI(UIManager.UI_Config.Corps_AutoInvite_UIBP)
  else
    ShowNotice(ret)
  end
end
function CorpsMgr.CreateGroupWXError(errorCode)
  if errorCode == -1 then
    ShowNotice(117016)
  elseif errorCode == 2009 or errorCode == -10001 then
    ShowNotice(117017)
  elseif errorCode == 2010 or errorCode == -10002 then
    ShowNotice(117018)
  elseif errorCode == 2011 or errorCode == -10005 then
    ShowNotice(117019)
  elseif errorCode == 2012 or errorCode == -10006 then
    ShowNotice(117020)
  elseif errorCode == 2013 or errorCode == -10007 then
    ShowNotice(117021)
  elseif errorCode == 2014 or errorCode == -10008 then
    ShowNotice(117022)
  else
    if errorCode == 2015 then
      ShowNotice(117023)
    else
    end
  end
end
function CorpsMgr.GetCorpsGroupId()
  local prefix = GroupTypePerfix.CORPS
  local serverId = DataMgr.roleData.sns_group_zone_id
  local id = ""
  if serverId ~= ServerZoneId.ONLINE then
    id = string.format("_%d_%s%d", serverId, prefix, DataMgr.corpsInfo.id)
  else
    id = string.format("%s%d", prefix, DataMgr.corpsInfo.id)
  end
  log(bWriteLog and "CorpsMgr.GetCorpsGroupId : " .. id)
  return id
end
function CorpsMgr.get_corps_group_relation_req()
  if BP_Platform == BP_ENUM_PLAYFORM_WX then
  end
end
function CorpsMgr.QueryCorpsGroupWX_rsp(hasGroup, selfInGroup)
  local groupInfo = {hasGroup = hasGroup, inGroup = selfInGroup}
  local roleId = tonumber(DataMgr.roleData.uid)
  local isCommand = roleId == DataMgr.corpsInfo.commanderId
  if isCommand and hasGroup and DataMgr.corpsInfo.group_id == 0 then
    CorpsMgr.BindCorpsGroupWXRsp()
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
end
function CorpsMgr.get_corps_group_relation_rsp(errorCode, relation)
  log(bWriteLog and "===========get_corps_group_relation_rsp===============" .. errorCode)
  local hasGroup = false
  local inGroup = false
  if errorCode == NetErrorCode_NONE then
    hasGroup = true
    inGroup = relation ~= 4
  else
  end
  local groupInfo = {hasGroup = hasGroup, inGroup = inGroup}
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
end
function CorpsMgr.bind_corps_group_req()
  if BP_Platform == BP_ENUM_PLAYFORM_WX then
  else
    local CorpsHander = require("client.network.Protocol.CorpsHandler")
    CorpsHander.send_bind_corps_group_req()
  end
end
function CorpsMgr.BindCorpsGroupWXRsp()
  local groupsId = CorpsMgr.GetCorpsGroupId()
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_bind_corps_group_req(groupsId)
end
function CorpsMgr.bind_corps_group_rsp(errorCode, groupId, groupName)
  log(bWriteLog and "===========bind_corps_group_rsp===============" .. errorCode)
  if errorCode == NetErrorCode_NONE then
    DataMgr.corpsInfo.group_id = groupId
    local groupInfo = {hasGroup = true, inGroup = true}
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
      ShowNotice(LocUtil.GetLocalizeResStr(301277))
    elseif BP_Platform == BP_ENUM_PLAYFORM_BGBG then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, "\230\143\144\231\164\186", LocUtil.GetLocalizeResStr(117050))
    end
  elseif errorCode == 421004 then
    if groupId ~= nil then
      DataMgr.corpsInfo.group_id = groupId
    end
  else
    ShowNotice(errorCode)
  end
end
function CorpsMgr.join_corps_group_req()
  if BP_Platform == BP_ENUM_PLAYFORM_WX then
  else
    local CorpsHander = require("client.network.Protocol.CorpsHandler")
    CorpsHander.send_join_corps_group_req()
  end
end
function CorpsMgr.join_corps_group_rsp(result)
  if result == NetErrorCode_NONE then
    local groupInfo = {hasGroup = true, inGroup = true}
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
    elseif BP_Platform == BP_ENUM_PLAYFORM_BGBG then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, "\230\143\144\231\164\186", LocUtil.GetLocalizeResStr(117049))
    end
  else
    ShowNotice(result)
  end
end
function CorpsMgr.unbind_corps_group_req()
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_unbind_corps_group_req()
end
function CorpsMgr.unbind_corps_group_rsp(result)
  log(bWriteLog and "...................unbind_corps_group_rsp " .. result)
  if result == NetErrorCode_NONE then
    local groupInfo = {hasGroup = false, inGroup = false}
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
    ShowNotice(LocUtil.GetLocalizeResStr(301276))
  else
    ShowNotice(result)
  end
end
function CorpsMgr.InitBySummary(summary)
  CorpsMgr.InitManagerInfo(summary)
  DataMgr.corpsInfo.icon = summary.icon
end
function CorpsMgr.get_corps_summary_req(corps_id, uid, cb, req_type)
  log(bWriteLog and "CorpsMgr.get_corps_summary_req corps_id:" .. tostring(corps_id) .. ",uid:" .. tostring(uid))
  if corps_id ~= nil then
    if req_type == nil then
      CorpsMgr.onGetCorpsSummary = cb
    else
      CorpsMgr.getSummaryReqMapCallBack[req_type] = cb
    end
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_summary_req(tonumber(corps_id), tonumber(uid), req_type)
  end
end
function CorpsMgr.get_corps_summary_req_cb_list(corps_id, uid, cb)
  log(bWriteLog and "CorpsMgr.get_corps_summary_req_cb_list corps_id:" .. tostring(corps_id) .. ",uid:" .. tostring(uid))
  corps_id = tonumber(corps_id)
  if corps_id ~= nil then
    CorpsMgr.onGetCorpsSummaryList[corps_id] = cb
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_summary_req(tonumber(corps_id), tonumber(uid), req_type)
  end
end
function CorpsMgr.get_corps_summary_rsp(res, corps_id, corps_summary, req_type, exchange_red_info)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and "CorpsMgr.get_corps_summary_rsp:" .. tostring(res) .. ",corps_id:" .. tostring(corps_id))
  local cb
  local cb_form_list = corps_id and CorpsMgr.onGetCorpsSummaryList and CorpsMgr.onGetCorpsSummaryList[corps_id]
  if req_type == nil then
    cb = CorpsMgr.onGetCorpsSummary
    CorpsMgr.onGetCorpsSummary = nil
  else
    cb = CorpsMgr.getSummaryReqMapCallBack[req_type]
    CorpsMgr.getSummaryReqMapCallBack[req_type] = nil
    if req_type == "plat_invite" then
      local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
      device_module:ClearExtendInfo()
    end
  end
  if res == NetErrorCode_NONE then
    if corps_summary ~= nil then
      corps_summary.      if corps_id == DataMgr.corpsInfo.id then
        CorpsMgr.InitBySummary(corps_summary)
        CorpsMgr.SetCropsStarList(corps_summary.star_members)
      end
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_SUMMARY, corps_summary)
      RoleInfoSystem.get_corps_summary_rsp(corps_id, corps_summary)
      local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
      ChatMenuSystem.get_corps_summary_rsp(res, corps_id, corps_summary, req_type)
      local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
      LobbySocialSystem.RefreshCorpsSummary(corps_id, corps_summary, req_type)
      if cb ~= nil then
        cb(corps_summary)
      end
      if cb_form_list ~= nil then
        cb_form_list(corps_summary)
        if CorpsMgr.onGetCorpsSummaryList and corps_id then
          CorpsMgr.onGetCorpsSummaryList[corps_id] = nil
        end
      end
      local CorpGiftExchangeSystem = require("client.slua.logic.corps_gift_exchange.logic_corp_gift_exchange")
      if exchange_red_info then
        CorpGiftExchangeSystem.is_show_redPoint = true
      else
        CorpGiftExchangeSystem.is_show_redPoint = false
      end
    else
      local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
      logic_corps_fight.GetDisBandRaceSummary(corps_id)
    end
  elseif res ~= nil then
    ShowNotice(res)
    if cb ~= nil then
      cb(nil)
    end
    if cb_form_list ~= nil then
      cb_form_list(nil)
      if CorpsMgr.onGetCorpsSummaryList and corps_id then
        CorpsMgr.onGetCorpsSummaryList[corps_id] = nil
      end
    end
  end
end
function CorpsMgr.SummaryToPanelData(summary, panelData)
  if summary == nil or panelData == nil then
    return
  end
  panelData.str_corps_id = tostring(summary.corps_id)
  panelData.level = summary.level
  panelData.name = summary.name
  panelData.activeness = summary.activeness
  panelData.city = summary.city
  panelData.icon = summary.icon
  panelData.join_level = summary.join_level
  panelData.join_segment = summary.join_segment
  panelData.member_num = summary.member_num
  panelData.icon_text = summary.icon_text
  panelData.icon_text_colour = summary.icon_text_colour
  local levelCfg = CDataTable.GetTableData("CorpsLevel", summary.level)
  if levelCfg ~= nil then
    panelData.member_max = levelCfg.MemberLimit
  else
    panelData.member_max = 0
  end
  panelData.announcement = summary.announcement
end
function CorpsMgr.batch_get_corps_summary_req(cb, corps_idlist)
  if not corps_idlist or #corps_idlist == 0 then
    log(bWriteLog and "CorpsMgr.batch_get_corps_summary_req is nil")
    if cb ~= nil then
      cb(nil)
    end
  else
    log(bWriteLog and "CorpsMgr.batch_get_corps_summary_req")
    CorpsMgr.onBatchGetCorpsSummary = cb
    local CorpsHander = require("client.network.Protocol.CorpsHandler")
    local CorpsMacro = require("client.slua.logic.corps.corps_macro")
    CorpsHander.send_batch_get_bin_corps_summary_req(CorpsMacro.SearchType.Normal, corps_idlist)
  end
end
function CorpsMgr.batch_get_corps_summary_rsp(res, opt_type, corps_info, client_data)
  log(bWriteLog and "CorpsMgr.batch_get_corps_summary_rsp")
  local cb = CorpsMgr.onBatchGetCorpsSummary
  CorpsMgr.onBatchGetCorpsSummary = nil
  if res == NetErrorCode_NONE then
    if cb ~= nil then
      cb(corps_info)
    end
  elseif res ~= nil then
    ShowNotice(res)
  end
end
function CorpsMgr.SendReportInfo(captainName, teamID, teamName, teamNotice)
  local ComplaintConfig = require("client.slua.umg.complaint.complaint_config")
  local reportInfo = {}
  reportInfo.UserName = captainName
  reportInfo.ReportRoleID = tonumber(DataMgr.roleData.uid)
  reportInfo.TeamID = tonumber(teamID)
  reportInfo.TeamName = teamName
  reportInfo.TeamNotice = teamNotice
  reportInfo.ComplaintType2 = ComplaintConfig.EComplaintSceneTLogType.Corpus
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_report_info(reportInfo)
end
function CorpsMgr.GetLevelName(level)
  if level == 1 then
    return LocUtil.GetLocalizeResStr("410002")
  end
  local lvlData = CDataTable.GetTableData("MilitaryRankLevel", level)
  return lvlData.MilitaryRankName
end
function CorpsMgr.GetLevelExp(level)
  local config = CDataTable.GetTableData("MilitaryRankLevel", level)
  if config then
    return config.NewExp
  else
    return 0
  end
end
function CorpsMgr.GetRankLevelName(levelID)
  if levelID == 101 then
    return LocUtil.GetLocalizeResStr("410003")
  end
  local lvlData = FuncUtil.GetRankTableData(levelID)
  return lvlData.Name
end
local changeCityReqID = 0
function CorpsMgr.corps_change_city_req(id)
  log(bWriteLog and "CorpsMgr.corps_change_city_req")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  changeCityReqID = id
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_change_city_req(id)
end
function CorpsMgr.corps_change_city_rsp(res, days)
  if res == NetErrorCode_NONE then
    DataMgr.corpsInfo.city = changeCityReqID
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CITY)
    ShowNotice(301192)
  elseif res == 433001 then
    ShowNotice(string.format(DataMgr.GetMsgByID(res), days))
  else
    ShowNotice(res)
  end
end
function CorpsMgr.corps_change_name_req(corpsName)
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_change_name_req(corpsName)
end
function CorpsMgr.corps_change_name_rsp(res, corpsName, unlock_time)
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "CorpsMgr.corps_change_name_rsp :" .. tostring(res))
  if res ~= 0 then
    if res == 433027 then
      local startTimeStr = TimeUtil.FormatTime_YMD(unlock_time)
      ShowNotice(LocUtil.LocalizeResFormat(22202, startTimeStr))
    elseif res == 411019 then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
    elseif res == 433022 then
      ShowNotice(46880157)
    else
      ShowNotice(res)
    end
  else
    DataMgr.corpsInfo.changeNameTime = TimeUtil.GetServerTimeInSec()
    ShowNotice(660022)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
    local reviseNameUI = UIManager.GetUI(UIManager.UI_Config.revise_name)
    if reviseNameUI then
      UIManager.CloseUI(UIManager.UI_Config.revise_name)
    end
  end
end
function CorpsMgr.get_corps_news_list_req()
  if DataMgr.corpsInfo.id == 0 then
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NEWS_LIST)
    return
  end
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "get_corps_news_list_req:" .. tostring(CorpsMgr.corps_news.last_get_news_time))
  if DataMgr.corpsInfo.id == CorpsMgr.corps_news.corps_id and TimeUtil.GetServerTimeInSec() - CorpsMgr.corps_news.last_get_news_time <= CorpsMgr.corps_news_Interval then
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NEWS_LIST)
    return
  end
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_news_list_req(CorpsMgr.corps_news.last_get_news_time)
end
function CorpsMgr.get_corps_news_list_rsp(ret, corps_id, news_list, last_get_news_time, gift_seq_ids, need_translate_news)
  if type(news_list) == "string" then
    news_list = slua.LuaArchiverDecode(LuaStateWrapper, news_list)
  end
  log_tree("get_corps_news_list_rsp", {
    ret = ret,
    last_get_news_time = last_get_news_time,
    corps_id = corps_id,
    news_list = news_list,
    gift_seq_ids = gift_seq_ids,
      })
  if ret ~= NetErrorCode_NONE then
    if ret == "no_change" then
      local TimeUtil = require("client.common.time_util")
      CorpsMgr.corps_news.last_get_news_time = last_get_news_time or TimeUtil.GetServerTimeInSec()
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NEWS_LIST)
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_NEWS_LIST)
    else
      ShowNotice(ret)
    end
    return
  end
  local news_list_temp = {}
  for i, news in pairs(news_list) do
    local handle = NewsId2MsgHandle[news.news_id]
    news.content = handle and handle(news, true, need_translate_news and need_translate_news[i]) or ""
    log(bWriteLog and "[v_ywuyuan] CorpsMgr.get_corps_news_list_rsp" .. ":" .. tostring(news.content))
    local StringUtil = require("common.string_util")
    local content2 = StringUtil.StrTrim(news.content)
    news.content_small = string.gsub(content2, "<(Corps%w*)>", "<%1_small>")
    log(bWriteLog and "[v_ywuyuan] CorpsMgr.get_corps_news_list_rsp" .. ":" .. tostring(news.content_small))
    news.content_small = news.content
    news.has_devote = gift_seq_ids[news.seq_id] ~= nil
    news.index = i
    if news.content ~= "" then
      table.insert(news_list_temp, news)
    end
  end
  table.sort(news_list_temp, function(new1, new2)
    return new1.time > new2.time
  end)
  CorpsMgr.corps_news = {
    last_get_news_time = last_get_news_time,
    corps_id = corps_id,
    news_list = news_list_temp,
      }
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NEWS_LIST)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_NEWS_LIST)
end
function CorpsMgr.corps_news_status_notify(corps_id, one_news, gift_seq_ids)
  log_tree("corps_news_status_notify", {
    corps_id,
    one_news,
    gift_seq_ids
  })
  if CorpsMgr.corps_news.corps_id == corps_id then
    for _, new in pairs(CorpsMgr.corps_news.news_list) do
      if new.seq_id == one_news.seq_id then
        for k, v in pairs(one_news) do
          new[k] = v
        end
        new.has_devote = gift_seq_ids[new.seq_id] ~= nil
      end
    end
    CorpsMgr.corps_news.    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NEWS_LIST)
  end
end
function CorpsMgr.recommend_corps_popup()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "CorpsMgr.recommend_corps_popup return of not IsInLobbyOrMainCity")
    return
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local jumpBtnInfo = {}
  function jumpBtnInfo.callback()
    local jump_utils = require("client.logic.store.jump_utils")
    jump_utils.OpenJumpModule(BP_ENUM_MODULE_CORPS, {module = "1003300"})
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.CorpsSuggestionConfirm)
  end
  local closeBtnInfo = {}
  function closeBtnInfo.callback()
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.CorpsSuggestionClose)
  end
  local timeOutCallBack = function()
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.CorpsSuggestionTimeOut)
  end
  local cfg = CDataTable.GetTableData("RecommendedConfig", 2)
  local countdown = 0
  if cfg then
    countdown = cfg.countdown
  end
  RightPopSystem.ShowNotifyInviteTip(LocUtil.LocalizeResFormat(39089), closeBtnInfo, nil, jumpBtnInfo, countdown, timeOutCallBack, true)
end
function CorpsMgr.SetCanBeAgentLeader(data)
  CorpsMgr.CanBeAgentLeader = data
  if not data then
    if not DataMgr.corpsInfo.agent_leader then
      DataMgr.corpsInfo.agent_leader = {}
    end
    DataMgr.corpsInfo.agent_leader.uid = tonumber(DataMgr.roleData.uid)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_AGENT_LEADER_CHANGE)
  end
end
function CorpsMgr.Handle_LogOut()
  log(bWriteLog and "CorpsMgr.Handle_LogOut")
  CorpsMgr.InitNews()
end
function CorpsMgr.BackToLobbyScene()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.Corps)
  CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.CorpsWithOutPet)
  CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.Corps2)
end
function CorpsMgr.ChangeScene()
  local UIUtil = require("client.common.ui_util")
  UIUtil.HideLobbyAndPersonSpaceUI()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(40035)
  LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR)
end
function CorpsMgr.SetCropsStarList(star_members)
  CorpsMgr.corps_star = {}
  if star_members and next(star_members) then
    for _, value in pairs(star_members) do
      local pos = value.star_pos or 9
      CorpsMgr.corps_star[pos] = value
    end
  else
    CorpsMgr.corps_star = star_members
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_STAR_RSP)
end
function CorpsMgr.SetCropsStarListFromMembers(members)
  CorpsMgr.corps_star = {}
  if members and next(members) then
    for _, value in pairs(members) do
      if value.star_name and value.star_pos then
        local starInfo = {
          uid = value.id,
          star_name = value.star_name,
          star_pos = value.star_pos
        }
        CorpsMgr.corps_star[value.star_pos] = starInfo
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_STAR_RSP)
end
function CorpsMgr.GetCropsStarInfo(member_uid)
  local uid = tonumber(member_uid)
  if not uid then
    return nil
  end
  local data = CorpsMgr.corps_star
  if not data or not next(data) then
    return nil
  end
  for _, value in pairs(data) do
    if uid == value.uid then
      return value
    end
  end
  return nil
end
function CorpsMgr.GetCropsStarInfoByPos(pos)
  local pos = tonumber(pos)
  if not pos then
    log(bWriteLog and "CorpsMgr.GetCropsStarInfoByPos no pos")
    return nil
  end
  local data = CorpsMgr.corps_star
  if not data or not next(data) then
    log(bWriteLog and "CorpsMgr.GetCropsStarInfoByPos no data")
    return nil
  end
  for _, value in pairs(data) do
    if pos == value.star_pos then
      return value
    end
  end
end
function CorpsMgr.GetCropsStarList()
  return CorpsMgr.corps_star
end
function CorpsMgr.CanShowNewNoticeTip()
  local canShowTip = false
  local canShowRed = false
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showCfg = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eCorpsNoticeShowTimes)
  log_tree("CorpsMgr.CanShowNewNoticeTip in", showCfg)
  if showCfg == nil then
    showCfg = {}
    showCfg.show_tip_times = 1
    showCfg.show_red_times = 1
    showCfg.time_Show = currentTime
    canShowTip = true
    canShowRed = true
    log(bWriteLog and "CorpsMgr.CanShowNewNoticeTip no data")
  elseif showCfg.time_Show and TimeUtil.IsSameDay(showCfg.time_Show, currentTime) then
    log(bWriteLog and "CorpsMgr.CanShowNewNoticeTip is same day")
    canShowTip = false
    if showCfg.show_red_times < 5 then
      log(bWriteLog and "CorpsMgr.CanShowNewNoticeTip canShowRed")
      showCfg.show_red_times = showCfg.show_red_times + 1
      canShowRed = true
    else
      canShowRed = false
    end
  else
    log(bWriteLog and "CorpsMgr.CanShowNewNoticeTip is new day")
    canShowTip = true
    canShowRed = true
    showCfg.show_tip_times = 1
    showCfg.show_red_times = 1
    showCfg.time_Show = currentTime
  end
  playerPrefsSystem.SaveTableToFile_N(showCfg, playerPrefsSystem.ePlayerPrefsType.eCorpsNoticeShowTimes)
  log_tree("CorpsMgr.CanShowNewNoticeTip out", showCfg)
  return canShowTip, canShowRed
end
return CorpsMgr