local C_GET_ALL_AWARD_INVOKE_TYPE_MINITV = _G.GET_ALL_AWARD_INVOKE_TYPE_MINITV or 1
local C_GET_ALL_AWARD_INVOKE_TYPE_SUB_MODULE = _G.GET_ALL_AWARD_INVOKE_TYPE_SUB_MODULE or 4
local AssemblyActivitySystem = {
  AssemblyRecallAward = {},
  AssemblyFriends = {},
  AssemblyStartTime = 0,
  AssemblyEndTime = 0,
  AssemblyTasks = {},
  AssemblyGoods = {},
  AssemblyData = nil,
  AssemblyBindInfo = nil,
  AssemblyCfg = nil,
  FaceBookFriends = {},
  HasGetFriendsProfile = false,
  AssemblyActivityType = 86,
  HasReqAssemblyInfo = false,
  HasReqAssemblyRedInfo = false,
  HasReqAssemblyFullInfo = false,
  AdjustURL = "",
  HasMallShowPanel = {},
  HasOpenAssemblyMall = false,
  LastReqFullAction = 0,
  ShareType = 0,
  ShareTitle = 8024,
  ShareDesc = 7194,
  success_list = nil,
  daily_battle_info = {},
  OtherInvite = {},
  taskInfo = {},
  rejoin_care_count = 0,
  battle_score_count = 0,
  weekly_score_count = 0,
  score_flow = {},
  getBackCornRankLimit = 5,
  backUserUidList = {},
  backUserInfoList = {},
  backUserListReqTime = 0,
  backUserListReqCD = 1,
  backUserLobbyTips = "",
  backUserBtnRefreshTime = 0,
  taskPlayerInfoList = {},
  GMSetFreindLable = false,
  HasOpenAssemblyTeamUpPopup = false,
  isCanReqGoldTips = true
}
local ENUM_RECALL_PLAYER_TYPE = {MyInvite = 1, OtherOldFriend = 2}
function AssemblyActivitySystem.Enter()
  AssemblyActivitySystem.ReqAssemblyInfo()
  AssemblyActivitySystem.ReqGrowthCfgData()
  AssemblyActivitySystem.ReadInfluenceScoreTable()
end
function AssemblyActivitySystem.GetCdnImgUrl()
  return FuncUtil.GetDomainByID(3366028) .. "/images%2F20191119%2Figshare677190177928081574183076.jpg"
end
function AssemblyActivitySystem.GetModuleParams()
  local acceptor = "module=" .. BP_ENUM_MODULE_ASSEMBLY .. "&uid=%s&invitecode=%s"
  local invitecode = AssemblyActivitySystem.GetAssemblyInviteCode()
  acceptor = string.format(acceptor, tostring(DataMgr.roleData.uid), tostring(invitecode))
  return acceptor
end
function AssemblyActivitySystem.GetAssemblyInviteCode()
  local StringUtil = require("common.string_util")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local code = StringUtil.uid_to_short_code(DataMgr.roleData.uid)
  if PublishRegionMacros.IsBLUEHOLE() then
    code = "B-" .. code
  end
  return code
end
function AssemblyActivitySystem.GetUidByInviteCode(inviteCode)
  if not inviteCode or inviteCode == "" then
    return nil
  end
  local code = inviteCode
  if string.sub(code, 1, 2) == "B-" then
    code = string.sub(code, 3)
  end
  local StringUtil = require("common.string_util")
  if not StringUtil.check_short_code(code) then
    printf("[WARN] AssemblyActivitySystem.GetUidByInviteCode invalid code = %s", inviteCode)
    return nil
  end
  return StringUtil.short_code_to_uid(code)
end
function AssemblyActivitySystem.GetShareUrl()
  local ShareMgr = require("client.logic.share.share_logic")
  local invitecode = AssemblyActivitySystem.GetAssemblyInviteCode()
  local acceptor = AssemblyActivitySystem.GetModuleParams()
  local shareTitle = LocUtil.LocalizeResFormat(AssemblyActivitySystem.ShareTitle, invitecode)
  local shareContent = LocUtil.LocalizeResFormat(AssemblyActivitySystem.ShareDesc, invitecode)
  local _imgUrl = AssemblyActivitySystem.GetCdnImgUrl()
  return ShareMgr.GetDefaultShareUrl(_imgUrl, shareTitle, shareContent, nil, acceptor, nil, ShareSource.System)
end
function AssemblyActivitySystem.GetAssemblyCoinCount()
  if AssemblyActivitySystem.AssemblyCfg == nil or AssemblyActivitySystem.AssemblyCfg.conf == nil then
    return 0
  end
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local itemId = logic_oldfriend_care.GetScoreID()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(itemId)
  if itemData ~= nil then
    log(bWriteLog and "AssemblyActivitySystem.GetAssemblyCoinCount" .. itemData.count)
    return itemData.count
  end
  return 0
end
function AssemblyActivitySystem.Handle_LogOut()
  log(bWriteLog and "AssemblyActivitySystem.Handle_LogOut")
  AssemblyActivitySystem.AssemblyData = nil
  AssemblyActivitySystem.AssemblyBindInfo = nil
  AssemblyActivitySystem.HasReqAssemblyInfo = false
  AssemblyActivitySystem.HasReqAssemblyRedInfo = false
  AssemblyActivitySystem.HasReqAssemblyFullInfo = false
  AssemblyActivitySystem.backUserUidList = {}
  AssemblyActivitySystem.backUserListReqTime = 0
end
function AssemblyActivitySystem.ExchangeData()
  if AssemblyActivitySystem.AssemblyData == nil or AssemblyActivitySystem.AssemblyCfg == nil then
    return
  end
  AssemblyActivitySystem.AssemblyRecallAward = {}
  local recall_award = AssemblyActivitySystem.AssemblyData.recall_award
  local recall_award_cfg = AssemblyActivitySystem.AssemblyCfg.recall_award_cfg
  if recall_award and recall_award_cfg then
    for id, status in pairs(recall_award) do
      local cfg = recall_award_cfg[id]
      local info = {
        status = status,
        id = id,
        condition = cfg.cond,
        itemId = cfg.item_id,
        itemCount = cfg.item_num,
        valid_hours = cfg.item_expire_hour
      }
      AssemblyActivitySystem.AssemblyRecallAward[#AssemblyActivitySystem.AssemblyRecallAward + 1] = info
    end
  end
  table.sort(AssemblyActivitySystem.AssemblyRecallAward, function(info1, info2)
    return info1.id < info2.id
  end)
  local friendlist = {}
  local my_invite = AssemblyActivitySystem.AssemblyData.my_invite
  if my_invite and my_invite.invite_list then
    local top5List = my_invite.inf_top5_list or {}
    local noToplist = {}
    local indexOfTable = function(value, tbl)
      for i, v in ipairs(tbl) do
        if v == value then
          return i
        end
      end
    end
    for _, data in ipairs(my_invite.invite_list) do
      local info = {
        status = data.status,
        uid = data.uid,
        platname = data.platname,
        topIndex = indexOfTable(data.uid, top5List) or 99
      }
      friendlist[#friendlist + 1] = info
    end
    table.sort(friendlist, function(a, b)
      return a.topIndex < b.topIndex
    end)
    for i, v in ipairs(noToplist) do
      friendlist[#friendlist + 1] = v
    end
  end
  AssemblyActivitySystem.AssemblyFriends = friendlist
  AssemblyActivitySystem.AssemblyTasks = {}
  local task_cfg = AssemblyActivitySystem.AssemblyCfg.task_cfg
  local task = AssemblyActivitySystem.AssemblyData.task
  if task and task_cfg then
    for id, data in pairs(task) do
      local cfg = task_cfg[id]
      if cfg then
        local info = {
          status = data.status,
          condition = cfg.task_cond_1,
          condition2 = cfg.task_cond_2,
          name = cfg.task_desc_id,
          item_id = cfg.item_id,
          item_num = cfg.item_num,
          valid_hours = cfg.item_expire_hour,
          use_num = data.use_num,
          progress = data.process,
          id = id,
          icon = cfg.task_icon,
          task_finished_max_num = cfg.task_finished_max_num,
          task_type = cfg.task_type,
          can_invite = cfg.can_invite
        }
        AssemblyActivitySystem.AssemblyTasks[#AssemblyActivitySystem.AssemblyTasks + 1] = info
      end
    end
  end
  local StatusInfo = {
    [0] = 2,
    [1] = 4,
    [2] = 3,
    [3] = 1
  }
  table.sort(AssemblyActivitySystem.AssemblyTasks, function(info1, info2)
    local aState, bState
    if info1.progress == info1.use_num and info1.progress == info1.task_finished_max_num then
      aState = 3
    else
      aState = info1.status
    end
    if info2.progress == info2.use_num and info2.progress == info2.task_finished_max_num then
      bState = 3
    else
      bState = info2.status
    end
    if info1.status == info2.status then
      return info1.id < info2.id
    else
      local Info1Status = StatusInfo[aState] or 0
      local Info2Status = StatusInfo[bState] or 0
      return Info1Status > Info2Status
    end
  end)
  AssemblyActivitySystem.AssemblyGoods = {}
  local exchange_list = AssemblyActivitySystem.AssemblyData.exchange_list or {}
  local exchange_cfg = AssemblyActivitySystem.AssemblyCfg.exchange_cfg
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if exchange_cfg then
    for id, cfg in pairs(exchange_cfg) do
      local data = exchange_list[id] or {}
      local info = {}
      info.      info.resID = cfg.item_id
      info.cost = cfg.consum_num
      if cfg.total_limit ~= 0 then
        info.count = data.total_count or 0
        info.maxCount = cfg.total_limit
      end
      info.item_expire_hour = cfg.item_expire_hour
      local Item = CDataTable.GetTableData("Item", cfg.item_id)
      info.icon = Item and Item.itemSmallIcon or ""
      AssemblyActivitySystem.AssemblyGoods[#AssemblyActivitySystem.AssemblyGoods + 1] = info
    end
  end
  table.sort(AssemblyActivitySystem.AssemblyGoods, function(info1, info2)
    return info1.id < info2.id
  end)
  local activityData = AssemblyActivitySystem.GetActivityData()
  if activityData then
    AssemblyActivitySystem.AssemblyStartTime = activityData.StartTime
    AssemblyActivitySystem.AssemblyEndTime = activityData.EndTime
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    AssemblyActivitySystem.ShareTitle = 8451
    AssemblyActivitySystem.ShareDesc = 8451
  else
    AssemblyActivitySystem.ShareTitle = 8024
    AssemblyActivitySystem.ShareDesc = 7194
  end
  log(bWriteLog and "AssemblyActivitySystem.ExchangeData")
  EventSystem:postEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVNETID_ACTIVITY_REDDOT)
  if AssemblyActivitySystem.isNeedShowTips and AssemblyActivitySystem.tipsTeamInfo then
    AssemblyActivitySystem.EnterTeamTips(AssemblyActivitySystem.tipsTeamInfo.oldCount, AssemblyActivitySystem.tipsTeamInfo.newCount)
    AssemblyActivitySystem.isNeedShowTips = nil
    AssemblyActivitySystem.tipsTeamInfo = nil
  end
end
function AssemblyActivitySystem.GetActivityData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local dataList = ActivityNewSystem.GetActivityListByType(AssemblyActivitySystem.AssemblyActivityType)
  local TimeUtil = require("client.common.time_util")
  local currTime = TimeUtil.GetServerTimeInSec()
  for _, data in ipairs(dataList or {}) do
    if currTime >= data.StartTime and currTime <= data.EndTime then
      return data
    end
  end
  return nil
end
function AssemblyActivitySystem.GetActivityStartTime()
  local data = AssemblyActivitySystem.GetActivityData()
  if data then
    return data.StartTime
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec()
end
function AssemblyActivitySystem.HasActivity()
  local data = AssemblyActivitySystem.GetActivityData()
  return data ~= nil
end
function AssemblyActivitySystem.ReqAssemblyRedInfo()
  if AssemblyActivitySystem.HasReqAssemblyRedInfo then
    return
  end
  if AssemblyActivitySystem.GetActivityData() then
    if not AssemblyActivitySystem.HasReqAssemblyFullInfo then
      AssemblyActivitySystem.ReqAssemblyInfo()
      return
    end
    local reqDataKeys = AssemblyActivitySystem.GetReqDataKeys()
    log_tree("Activity_Change_Event reqDataKeys", reqDataKeys)
    if next(reqDataKeys) ~= nil then
      AssemblyActivitySystem.HasReqAssemblyRedInfo = true
      AssemblyActivitySystem.assemb_task_query_req({
        "task",
        "recall_award",
        "ret_award"
      }, {
        "rejoiner_exchange_cfg",
        "score_config",
        "conf",
        "week_battle_reward_cfg"
      })
    end
  end
end
function AssemblyActivitySystem.ReqAssemblyInfo()
  if not AssemblyActivitySystem.GetActivityData() then
    return
  end
  local reqCfgKeys = AssemblyActivitySystem.GetReqCfgKeys()
  if not AssemblyActivitySystem.HasReqAssemblyFullInfo then
    AssemblyActivitySystem.HasReqAssemblyFullInfo = true
    AssemblyActivitySystem.HasReqAssemblyInfo = true
    AssemblyActivitySystem.HasReqAssemblyRedInfo = true
    AssemblyActivitySystem.assemb_task_query_req(nil, reqCfgKeys)
    return
  end
  if AssemblyActivitySystem.HasReqAssemblyInfo then
    return
  end
  local reqDataKeys = AssemblyActivitySystem.GetReqDataKeys()
  log_tree("Activity_Change_Event reqDataKeys", reqDataKeys)
  if next(reqDataKeys) ~= nil or next(reqCfgKeys) ~= nil then
    AssemblyActivitySystem.HasReqAssemblyInfo = true
    AssemblyActivitySystem.assemb_task_query_req(reqDataKeys, reqCfgKeys)
  end
end
function AssemblyActivitySystem.HasAssemblyAwardRedDot()
  return false
end
function AssemblyActivitySystem.GetFriendProfileList(callback)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  AssemblyActivitySystem.HasGetFriendsProfile = false
  if #AssemblyActivitySystem.AssemblyFriends > 0 then
    local gids = {}
    for i, v in ipairs(AssemblyActivitySystem.AssemblyFriends) do
      table.insert(gids, v.uid)
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.ASSEMBLY, gids, function(list)
      for j, currProfile in pairs(list) do
        for i, data in ipairs(AssemblyActivitySystem.AssemblyFriends) do
          if tonumber(data.uid) == tonumber(currProfile.uid) then
            PersonSpaceSystem.AddProfileData(data, currProfile)
          end
        end
      end
      AssemblyActivitySystem.HasGetFriendsProfile = true
      log_tree("AssemblyActivitySystem GetFriendProfileList", AssemblyActivitySystem.AssemblyFriends)
      if callback then
        callback()
      end
    end, false, false)
  else
    AssemblyActivitySystem.HasGetFriendsProfile = true
    if callback then
      callback()
    end
  end
end
function AssemblyActivitySystem.GetActivitySubData_AssemblySet()
  local logic_assembly_activity_utils = require("client.slua.logic.come_back.logic_assembly_activity_utils")
  if not logic_assembly_activity_utils.GetAssemblyBoxInfo() then
    log(bWriteLog and "AssemblyActivitySystem.GetActivitySubData_AssemblySet not assemblyBoxInfo")
    return
  end
  local actData = AssemblyActivitySystem.GetActivityData()
  if not actData then
    log(bWriteLog and "AssemblyActivitySystem.GetActivitySubData_AssemblySet not actData")
    return
  end
  return {
    nActID = ActivityFixedID.ASSEMBLY_SET,
    sName = LocUtil.GetLocalizeResStr(24742),
    bRedDot = false,
    sBgUrl = "",
    ImgUrl = actData.ImgUrl or "",
    ImgLink = "",
    nStartTime = AssemblyActivitySystem.GetActivityStartTime(),
    DisplayScene = actData.DisplayScene,
    sTabImageUrl = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/LOBBY_ComeBack_Banner02.LOBBY_ComeBack_Banner02"
  }
end
function AssemblyActivitySystem.GetActivitySubData_AssemblyAward()
  if not LobbySystem.CheckOpen(BP_ENUM_ASSEMBLY_SHARE) then
    return
  end
  local bOpen = false
  if DataMgr.RejoinTaskData == nil or not DataMgr.RejoinTaskData.is_open then
    bOpen = false
  else
    bOpen = true
  end
  if DataMgr.RejoinTaskData and DataMgr.RejoinTaskData.is_back_user then
    bOpen = true
  end
  if not bOpen then
    log(bWriteLog and string.format("AssemblyActivitySystem.GetActivitySubData_AssemblyAward, GetActivitySubData_AssemblyAward:%s", 1))
    return
  end
  if not AssemblyActivitySystem.HasActivity() then
    log(bWriteLog and string.format("AssemblyActivitySystem.GetActivitySubData_AssemblyAward, GetActivitySubData_AssemblyAward:%s", 2))
    return
  end
  if AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.ret_award == nil then
    log(bWriteLog and string.format("AssemblyActivitySystem.GetActivitySubData_AssemblyAward, GetActivitySubData_AssemblyAward:%s", 3))
    return
  end
  if AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.ret_award == true then
    log(bWriteLog and string.format("AssemblyActivitySystem.GetActivitySubData_AssemblyAward, GetActivitySubData_AssemblyAward:%s", 4))
    return
  end
  return {
    nActID = ActivityFixedID.ASSEMBLY_AWARD,
    sName = LocUtil.GetLocalizeResStr(7096),
    bRedDot = AssemblyActivitySystem.HasAssemblyAwardRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = AssemblyActivitySystem.GetActivityStartTime(),
    sTabImageUrl = "/Game/UMG/Texture/Lobby_NoAtlas/COMEBACK/LOBBY_ComeBack_Banner01.LOBBY_ComeBack_Banner01"
  }
end
function AssemblyActivitySystem.take_full_action_award(id)
  log(bWriteLog and "take_full_action_award:" .. tostring(id))
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_take_full_action_award(id)
end
function AssemblyActivitySystem.take_full_action_award_rsp(res, id, invoke_type)
  if res ~= NetErrorCode_NONE then
    return
  end
  if AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.recall_award_cfg then
    local cfg = AssemblyActivitySystem.AssemblyCfg.recall_award_cfg[id]
    if invoke_type == C_GET_ALL_AWARD_INVOKE_TYPE_MINITV then
      local logic_oneclick_reward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
      local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
      logic_oneclick_reward.AddListToAllRewardData({
        {
          res_id = cfg.item_id,
          count = cfg.item_num
        }
      }, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_RECALL_TASK)
    else
      local Result = {}
      table.insert(Result, {
        res_id = cfg.item_id,
        count = cfg.item_num,
        valid_hours = cfg.item_expire_hour
      })
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
    end
  end
  if AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.recall_award then
    AssemblyActivitySystem.AssemblyData.recall_award[id] = 2
  end
  AssemblyActivitySystem.ExchangeData()
end
function AssemblyActivitySystem.assemb_task_query_req(attr_name_list, cfg_name_list)
  log(bWriteLog and "assemb_task_query_req")
  log_tree("attr_name_list", attr_name_list)
  log_tree("cfg_name_list", cfg_name_list)
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_assemb_task_query_req(attr_name_list, cfg_name_list)
end
local SetData = function(key, value)
  if value == nil then
    return
  end
  if AssemblyActivitySystem.AssemblyData == nil then
    AssemblyActivitySystem.AssemblyData = {}
  end
  AssemblyActivitySystem.AssemblyData[key] = value
end
local SetCfg = function(key, value)
  if value == nil then
    return
  end
  if AssemblyActivitySystem.AssemblyCfg == nil then
    AssemblyActivitySystem.AssemblyCfg = {}
  end
  AssemblyActivitySystem.AssemblyCfg[key] = value
end
local SetBindInfo = function(bindInfo, isAll)
  if bindInfo == nil then
    if isAll then
      AssemblyActivitySystem.AssemblyBindInfo = nil
      if AssemblyActivitySystem.AssemblyData then
        AssemblyActivitySystem.AssemblyData.invite_request_uids = nil
        AssemblyActivitySystem.AssemblyData.invite_bound_flag = nil
        AssemblyActivitySystem.AssemblyData.confirmed_inviters = nil
      end
    end
    return
  end
  if AssemblyActivitySystem.AssemblyData == nil then
    AssemblyActivitySystem.AssemblyData = {}
  end
  AssemblyActivitySystem.AssemblyBindInfo = bindInfo
  AssemblyActivitySystem.AssemblyData.invite_request_uids = bindInfo.invite_request_uids or {}
  AssemblyActivitySystem.AssemblyData.invite_bound_flag = bindInfo.invite_bound_flag or false
  AssemblyActivitySystem.AssemblyData.confirmed_inviters = bindInfo.confirmed_inviters or {}
end
function AssemblyActivitySystem.GetDataKeys()
  return {
    "begin_time",
    "my_invite",
    "task",
    "recall_award",
    "exchange_list",
    "ret_award"
  }
end
function AssemblyActivitySystem.GetCfgKeys()
  return {
    "exchange_cfg",
    "conf",
    "task_cfg",
    "recall_award_cfg",
    "interval_time",
    "rejoin_award_cfg",
    "rejoiner_exchange_cfg",
    "score_config",
    "week_battle_reward_cfg",
    "team_score_plan_cfg"
  }
end
function AssemblyActivitySystem.GetGrowthKey()
  return {
    "rejoiner_exchange_cfg",
    "conf",
    "score_config"
  }
end
function AssemblyActivitySystem.ReqGrowthCfgData()
  local cfg = AssemblyActivitySystem.GetGrowthKey()
  AssemblyActivitySystem.assemb_task_query_req({}, cfg)
end
function AssemblyActivitySystem.GetGrowthCfgData()
  return AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.rejoiner_exchange_cfg or {}
end
function AssemblyActivitySystem.GetReqDataKeys()
  if AssemblyActivitySystem.AssemblyData == nil then
    return AssemblyActivitySystem.GetDataKeys()
  end
  local reqKeys = {}
  for i, key in ipairs(AssemblyActivitySystem.GetDataKeys()) do
    if AssemblyActivitySystem.AssemblyData[key] == nil then
      table.insert(reqKeys, key)
    end
  end
  table.insert(reqKeys, "my_invite")
  return reqKeys
end
function AssemblyActivitySystem.GetReqCfgKeys()
  if AssemblyActivitySystem.AssemblyCfg == nil then
    return AssemblyActivitySystem.GetCfgKeys()
  end
  local reqKeys = {}
  for i, key in ipairs(AssemblyActivitySystem.GetCfgKeys()) do
    if not AssemblyActivitySystem.AssemblyCfg[key] then
      table.insert(reqKeys, key)
    end
  end
  return reqKeys
end
function AssemblyActivitySystem.assemb_notify(is_all, assemb_data, cfg, is_back_user, assemb_bindinfo)
  log(bWriteLog and string.format("AssemblyActivitySystem.assemb_notify, is_all:%s", is_all))
  log_tree(bWriteLog and "AssemblyActivitySystem.assemb_notify assemb_data", assemb_data)
  log_tree(bWriteLog and "AssemblyActivitySystem.assemb_notify cfg", cfg)
  log_tree(bWriteLog and "AssemblyActivitySystem.assemb_notify assemb_bindinfo", assemb_bindinfo)
  log(bWriteLog and string.format("AssemblyActivitySystem.assemb_notify, is_back_user:%s", is_back_user))
  AssemblyActivitySystem.success_list = assemb_data and assemb_data.my_invite and assemb_data.my_invite.success_list or AssemblyActivitySystem.success_list
  if assemb_data ~= nil then
    for i, key in ipairs(AssemblyActivitySystem.GetDataKeys()) do
      SetData(key, assemb_data[key])
    end
    SetData("team_battle_progress", assemb_data.team_battle_progress)
    SetData("rejoiner_assemb_info", assemb_data.rejoiner_assemb_info)
  end
  SetBindInfo(assemb_bindinfo, is_all)
  local activityData = AssemblyActivitySystem.GetActivityData()
  if activityData then
    AssemblyActivitySystem.AssemblyStartTime = activityData.StartTime
    AssemblyActivitySystem.AssemblyEndTime = activityData.EndTime
  end
  if cfg ~= nil then
    for i, key in ipairs(AssemblyActivitySystem.GetCfgKeys()) do
      SetCfg(key, cfg[key])
    end
  end
  if assemb_data and assemb_data.task then
    for i, task_info in pairs(assemb_data.task) do
      if task_info.daily_battle_info then
        AssemblyActivitySystem.daily_battle_info = task_info.daily_battle_info
        break
      end
    end
    AssemblyActivitySystem.taskInfo = assemb_data.task
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ASSEMBLY_ACTIVITY_TASK_UPDATE)
  end
  if is_back_user ~= nil then
    DataMgr.RejoinTaskData.  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if AssemblyActivitySystem.success_list then
    local noInfoPlayerList = {}
    for _, PlayerId in pairs(AssemblyActivitySystem.success_list) do
      if not logic_profile:GetLocalProfile(PlayerId) then
        noInfoPlayerList[#noInfoPlayerList + 1] = PlayerId
      end
    end
    if next(noInfoPlayerList) then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(noInfoPlayerList, nil, Enum_PROFILE_REPORT_CFG.COMBACK)
    end
  end
  AssemblyActivitySystem.ExchangeData()
  if cfg and cfg.team_score_plan_cfg then
    SetCfg("team_score_plan_cfg", cfg.team_score_plan_cfg)
  end
end
function AssemblyActivitySystem.GetAssemblyBindInfo()
  return AssemblyActivitySystem.AssemblyBindInfo or {}
end
function AssemblyActivitySystem.GetInviteRequestUids()
  local bindInfo = AssemblyActivitySystem.GetAssemblyBindInfo()
  if bindInfo.invite_request_uids ~= nil then
    return bindInfo.invite_request_uids
  end
  return AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.invite_request_uids or {}
end
function AssemblyActivitySystem.HasPendingInviteBind()
  local bindInfo = AssemblyActivitySystem.GetAssemblyBindInfo()
  if bindInfo.invite_bound_flag then
    return false
  end
  return next(AssemblyActivitySystem.GetInviteRequestUids()) ~= nil
end
function AssemblyActivitySystem.GetTeamBattleProgress()
  return AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.team_battle_progress or {}
end
function AssemblyActivitySystem.GetWeeklyScoreLimit()
  local scoreCfg = AssemblyActivitySystem.GetScoreConfig()
  if scoreCfg and scoreCfg.rejoin_care_week_limit then
    return scoreCfg.rejoin_care_week_limit
  end
  return AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.conf and AssemblyActivitySystem.AssemblyCfg.conf.rejoin_care_week_limit or 0
end
function AssemblyActivitySystem.GetAssemblyBattleRewardList()
  local AddRewardItem = function(itemList, itemID, itemNum, validHours)
    itemID = tonumber(itemID) or 0
    itemNum = tonumber(itemNum) or 0
    if itemID <= 0 or itemNum <= 0 then
      return
    end
    itemList[#itemList + 1] = {
      item_id = itemID,
      item_num = itemNum,
      item_expire_hour = tonumber(validHours) or 0
    }
  end
  local BuildRewardItemList = function(cfg)
    local itemList = {}
    if not cfg then
      return itemList
    end
    if cfg.consume_item_id or cfg.consume_item_cnt then
      AddRewardItem(itemList, cfg.consume_item_id, cfg.consume_item_cnt, 0)
      return itemList
    end
    for _, item in pairs(cfg.item_list or {}) do
      AddRewardItem(itemList, item.res_id or item.item_id or item.ItemID or item[1], item.res_num or item.item_num or item.ItemNum or item.count or item[2], item.valid_hours or item.item_expire_hour or item[3])
    end
    if next(itemList) then
      return itemList
    end
    for index = 1, 3 do
      AddRewardItem(itemList, cfg["item_id" .. index], cfg["item_count" .. index], cfg["valid_hours" .. index])
    end
    return itemList
  end
  local scoreCfg = AssemblyActivitySystem.GetScoreConfig()
  local rewardTable = scoreCfg and AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.week_battle_reward_cfg and AssemblyActivitySystem.AssemblyCfg.week_battle_reward_cfg[scoreCfg.plan_id] or {}
  local progress = AssemblyActivitySystem.GetTeamBattleProgress()
  local awarded = progress.awarded or {}
  local count = progress.count or 0
  local list = {}
  for rewardId, cfg in pairs(rewardTable or {}) do
    local requiredCount = tonumber(rewardId) or 0
    local isClaimed = awarded[rewardId] or awarded[tostring(rewardId)] or false
    list[#list + 1] = {
      id = rewardId,
      required_count = requiredCount,
      item_list = BuildRewardItemList(cfg),
      is_claimed = isClaimed,
      progress = count,
      target = requiredCount,
      state = isClaimed and "collected" or count >= requiredCount and "collectable" or "undone"
    }
  end
  table.sort(list, function(a, b)
    return a.required_count < b.required_count
  end)
  return list
end
function AssemblyActivitySystem.GetAssemblyBattleRewardItemList(rewardId)
  for _, rewardData in ipairs(AssemblyActivitySystem.GetAssemblyBattleRewardList() or {}) do
    if tonumber(rewardData.id) == tonumber(rewardId) then
      local itemList = {}
      for _, item in ipairs(rewardData.item_list or {}) do
        itemList[#itemList + 1] = {
          res_id = item.item_id,
          count = item.item_num,
          valid_hours = item.item_expire_hour
        }
      end
      return itemList
    end
  end
  return {}
end
function AssemblyActivitySystem.bind_assemb_inviters_req(selectedUids)
  if not selectedUids or next(selectedUids) == nil then
    ShowNotice(720001)
    return false
  end
  local uidList = {}
  for i, uid in ipairs(selectedUids) do
    if 3 < i then
      break
    end
    uidList[#uidList + 1] = tonumber(uid) or uid
  end
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  return AssemblyHandler.send_bind_assemb_inviters_req(uidList)
end
function AssemblyActivitySystem.TestBindAssembInviters(selectedUids)
  local uidList = {}
  if selectedUids and next(selectedUids) ~= nil then
    for _, uid in ipairs(selectedUids) do
      if 3 <= #uidList then
        break
      end
      uidList[#uidList + 1] = tonumber(uid) or uid
    end
    if next(uidList) == nil then
      for uid in pairs(selectedUids) do
        if 3 <= #uidList then
          break
        end
        uidList[#uidList + 1] = tonumber(uid) or uid
      end
    end
  else
    local inviteRequestUids = AssemblyActivitySystem.GetInviteRequestUids()
    for uid in pairs(inviteRequestUids) do
      if 3 <= #uidList then
        break
      end
      uidList[#uidList + 1] = tonumber(uid) or uid
    end
  end
  if next(uidList) == nil then
    log(bWriteLog and "AssemblyActivitySystem.TestBindAssembInviters no pending uid")
    ShowNotice(720014)
    return false
  end
  log_tree(bWriteLog and "AssemblyActivitySystem.TestBindAssembInviters uidList", uidList)
  return AssemblyActivitySystem.bind_assemb_inviters_req(uidList)
end
function AssemblyActivitySystem.take_assemb_battle_reward_req(rewardId)
  if not rewardId then
    ShowNotice(720001)
    return false
  end
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  return AssemblyHandler.send_take_assemb_battle_reward_req(rewardId)
end
function AssemblyActivitySystem.take_task_award(task_id)
  log(bWriteLog and "take_task_award:" .. tostring(task_id))
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_take_task_award(task_id)
end
function AssemblyActivitySystem.get_all_assemb_task_reward_req()
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_get_all_assemb_task_reward_req()
end
function AssemblyActivitySystem.get_all_assemb_task_reward_rsp(err_code, item_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if item_list and next(item_list) then
    local Result = {}
    for itemID, count in pairs(item_list) do
      table.insert(Result, {
        res_id = tonumber(itemID),
              })
    end
    if next(Result) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  end
end
function AssemblyActivitySystem.take_task_award_rsp(res, id, num, invoke_type)
  if res ~= NetErrorCode_NONE then
    return
  end
  if AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.task_cfg then
    local cfg = AssemblyActivitySystem.AssemblyCfg.task_cfg[id]
    if invoke_type == C_GET_ALL_AWARD_INVOKE_TYPE_MINITV then
      local logic_oneclick_reward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
      local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
      logic_oneclick_reward.AddListToAllRewardData({
        {
          res_id = cfg.item_id,
          count = cfg.item_num
        }
      }, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_RECALL_TASK)
    elseif invoke_type == C_GET_ALL_AWARD_INVOKE_TYPE_SUB_MODULE then
      return
    else
      local Result = {}
      local valid_hours = cfg.item_expire_hour or 0
      table.insert(Result, {
        res_id = cfg.item_id,
        count = num
      })
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
    end
  end
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  end
end
function AssemblyActivitySystem.assemb_invite_friend(uid, fromID)
  log(bWriteLog and "assemb_invite_friend:" .. tostring(uid) .. " fromID:" .. tostring(fromID))
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_assemb_invite_friend(uid, fromID or 0)
end
function AssemblyActivitySystem.assemb_invite_friend_rsp(res, id)
end
function AssemblyActivitySystem.take_assemb_award(short_code)
  log(bWriteLog and "take_assemb_award:" .. tostring(short_code))
  if short_code and string.sub(short_code, 1, 2) == "B-" then
    short_code = string.sub(short_code, 3)
  end
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  return AssemblyHandler.send_take_assemb_award(short_code)
end
function AssemblyActivitySystem.take_assemb_award_rsp(res, awardList)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
  local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
  if res ~= NetErrorCode_NONE then
    if res == 100150011 or res == 100150012 then
      local NoticeMessage = LocUtil.LocalizeResFormat(14252, ChannelName)
      ShowNotice(NoticeMessage)
    elseif res == 100150013 then
      local NoticeMessage = LocUtil.LocalizeResFormat(14253, ChannelName, awardList)
      ShowNotice(NoticeMessage)
    else
      ShowNotice(res)
    end
    return
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(awardList)
  SetData("ret_award", true)
  AssemblyActivitySystem.assemb_task_query_req({}, {})
  EventSystem:postEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE)
  end
end
function AssemblyActivitySystem.ReadInfluenceScoreTable()
  local cfg = CDataTable.GetTable("InfluenceScoreTable")
  local keyTbl = {"Id", "Point"}
  local tbl = {}
  for _, v in pairs(cfg) do
    local tmp = {}
    for i, k in ipairs(keyTbl) do
      tmp[k] = v[k]
    end
    tbl[#tbl + 1] = tmp
  end
  AssemblyActivitySystem.InfluenceScoreTable = tbl
end
function AssemblyActivitySystem.ReceiveOne(id, instanceKey)
  if instanceKey and (instanceKey == ActivityFixedID.ASSEMBLY_FRIEND or instanceKey == ActivityFixedID.ASSEMBLY_TASK or instanceKey == ActivityFixedID.ASSEMBLY_MALL) then
    if instanceKey == ActivityFixedID.ASSEMBLY_FRIEND then
      AssemblyActivitySystem.take_full_action_award(id)
    elseif instanceKey == ActivityFixedID.ASSEMBLY_TASK then
      AssemblyActivitySystem.take_task_award(id)
    elseif instanceKey == ActivityFixedID.ASSEMBLY_MALL then
      AssemblyActivitySystem.exchange_item(id)
    end
  end
end
function AssemblyActivitySystem.ReceiveFromRedHot(instanceKey)
  if instanceKey and (instanceKey == ActivityFixedID.ASSEMBLY_FRIEND or instanceKey == ActivityFixedID.ASSEMBLY_TASK or instanceKey == ActivityFixedID.ASSEMBLY_MALL) then
    local time_ticker = require("common.time_ticker")
    local award_status = {}
    if instanceKey == ActivityFixedID.ASSEMBLY_FRIEND then
      award_status = AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.recall_award or {}
    elseif instanceKey == ActivityFixedID.ASSEMBLY_TASK then
      award_status = AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.task or {}
    elseif instanceKey == ActivityFixedID.ASSEMBLY_MALL then
      for i, v in ipairs(AssemblyActivitySystem.AssemblyGoods) do
        if v.count < v.maxCount and AssemblyActivitySystem.GetAssemblyCoinCount() >= v.cost and AssemblyActivitySystem.HasMallShowPanel[v.id] then
          time_ticker.AddTimerOnce(0.2, function()
            AssemblyActivitySystem.ReceiveOne(v.id, instanceKey)
          end)
        end
      end
      return
    end
    for id, status in pairs(award_status) do
      if status == 1 then
        time_ticker.AddTimerOnce(0.2, function()
          AssemblyActivitySystem.ReceiveOne(id, instanceKey)
        end)
      end
    end
  end
end
function AssemblyActivitySystem.GetCanReceiveAwards(instanceKey)
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  local awardList = {}
  if instanceKey and (instanceKey == ActivityFixedID.ASSEMBLY_FRIEND or instanceKey == ActivityFixedID.ASSEMBLY_TASK or instanceKey == ActivityFixedID.ASSEMBLY_MALL) then
    local award_cfg = {}
    local award_status = {}
    if instanceKey == ActivityFixedID.ASSEMBLY_FRIEND then
      award_cfg = AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.recall_award_cfg or {}
      award_status = AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.recall_award or {}
    elseif instanceKey == ActivityFixedID.ASSEMBLY_TASK then
      award_cfg = AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.task_cfg or {}
      award_status = AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.task or {}
      for id, item in pairs(award_status) do
        if type(item) == "table" and item.status == 1 then
          local cfg = award_cfg[id] or {}
          table.insert(awardList, reddotUtil.CreateItem(cfg.item_id, cfg.item_num, cfg.item_expire_hour))
        end
      end
      return awardList
    elseif instanceKey == ActivityFixedID.ASSEMBLY_MALL then
      local iCoinCount = AssemblyActivitySystem.GetAssemblyCoinCount()
      for i, v in ipairs(AssemblyActivitySystem.AssemblyGoods) do
        if iCoinCount >= v.cost then
          table.insert(awardList, reddotUtil.CreateItem(v.resID, v.count, v.item_expire_hour))
        end
      end
      return awardList
    end
    for id, status in pairs(award_status) do
      if status == 1 then
        local cfg = award_cfg[id] or {}
        table.insert(awardList, reddotUtil.CreateItem(cfg.item_id or cfg.id, cfg.item_num or cfg.num, cfg.item_expire_hour))
      end
    end
  end
  return awardList
end
function AssemblyActivitySystem.on_rejoiner_task_notify(rejoin_task_info)
  rejoin_task_info = rejoin_task_info or {}
  log_tree("[ZH] rejoin_task_info", rejoin_task_info)
  local isUpdateTodayLimit = false
  if rejoin_task_info.rejoin_care_count and rejoin_task_info.rejoin_care_count ~= AssemblyActivitySystem.rejoin_care_count then
    AssemblyActivitySystem.rejoin_care_count = rejoin_task_info.rejoin_care_count
    isUpdateTodayLimit = isUpdateTodayLimit or true
  end
  if rejoin_task_info.score_flow and rejoin_task_info.score_flow ~= AssemblyActivitySystem.score_flow then
    AssemblyActivitySystem.score_flow = rejoin_task_info.score_flow
    EventSystem:postEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_OLDFRIEND_ACTIVITY_SCORE_FLOW)
  end
  if isUpdateTodayLimit then
    EventSystem:postEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_OLDFRIEND_ACTIVITY_UPDATE_LIMIT)
  end
end
function AssemblyActivitySystem.GetScoreConfig()
  if not AssemblyActivitySystem.AssemblyCfg or not AssemblyActivitySystem.AssemblyCfg.score_config then
    return nil
  end
  local actData = AssemblyActivitySystem.GetActivityData()
  local actId = actData and actData.ID or 0
  if not AssemblyActivitySystem.AssemblyCfg.score_config[actId] then
    actId = 0
  end
  return AssemblyActivitySystem.AssemblyCfg.score_config[actId]
end
function AssemblyActivitySystem.GetScoreLimt()
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  if not scoreConfig then
    return
  end
  return AssemblyActivitySystem.rejoin_care_count, scoreConfig.rejoin_care_item_daily_limit, scoreConfig.rejoin_care_item_total_limit
end
function AssemblyActivitySystem.GetScoreList()
  return AssemblyActivitySystem.score_flow or {}
end
function AssemblyActivitySystem.GetMyInviteFriedList()
  AssemblyActivitySystem.AssemblyData = AssemblyActivitySystem.AssemblyData or {}
  AssemblyActivitySystem.AssemblyData.my_invite = AssemblyActivitySystem.AssemblyData.my_invite or {}
  local my_invite_success_list = AssemblyActivitySystem.AssemblyData.my_invite.current_success_list or {}
  log_tree("[ZH] my_invite_list", my_invite_success_list)
  return my_invite_success_list
end
function AssemblyActivitySystem.GetOtherInviteFriedList()
  AssemblyActivitySystem.AssemblyData = AssemblyActivitySystem.AssemblyData or {}
  AssemblyActivitySystem.AssemblyData.my_invite = AssemblyActivitySystem.AssemblyData.my_invite or {}
  local other_invite_list = {}
  AssemblyActivitySystem.OtherInvite = {}
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local friendList = logic_oldfriend_care.GetRejoinFriendList()
  local my_invite_list = AssemblyActivitySystem.AssemblyData.my_invite.success_list or {}
  local my_invite_success_list = AssemblyActivitySystem.AssemblyData.my_invite.current_success_list or {}
  for _, oldFriendId in ipairs(friendList) do
    local isMyinvite = false
    for i, myInviteId in ipairs(my_invite_list) do
      if oldFriendId == myInviteId then
        isMyinvite = true
      end
    end
    if not isMyinvite then
      table.insert(other_invite_list, oldFriendId)
      AssemblyActivitySystem.OtherInvite[oldFriendId] = true
    end
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  table.sort(other_invite_list, function(a, b)
    local statusA = PlayerStatusMgr:GetStatusData(tonumber(a))
    local statusB = PlayerStatusMgr:GetStatusData(tonumber(b))
    local onlineA = statusA and statusA.online or 0
    local onlineB = statusB and statusB.online or 0
    return onlineA > onlineB
  end)
  log_tree("[ZH] other_invite_list", other_invite_list)
  return other_invite_list
end
function AssemblyActivitySystem.IsBackCornReachLimit()
  local _, _, rejoin_care_item_total_limit = AssemblyActivitySystem.GetScoreLimt()
  if not rejoin_care_item_total_limit then
    return true
  end
  if rejoin_care_item_total_limit <= AssemblyActivitySystem.battle_score_count then
    log(bWriteLog and "AssemblyActivitySystem.IsBackCornReachLimit battle_score_count >= rejoin_care_item_total_limit")
    return true
  end
end
function AssemblyActivitySystem.IsBackCornReachTodayLimit()
  local rejoin_care_count, rejoin_care_item_daily_limit = AssemblyActivitySystem.GetScoreLimt()
  if not rejoin_care_count or not rejoin_care_item_daily_limit then
    return true
  end
  if rejoin_care_item_daily_limit <= rejoin_care_count then
    log(bWriteLog and "AssemblyActivitySystem.IsBackCornReachTodayLimit rejoin_care_count >= rejoin_care_item_daily_limit")
    return true
  end
  return false
end
function AssemblyActivitySystem.EnterTeamTips(oldTeamMembers, newTeamMembers)
  if not AssemblyActivitySystem.GetActivityData() then
    return
  end
  if AssemblyActivitySystem.IsBackCornReachTodayLimit() then
    return
  end
  if AssemblyActivitySystem.IsBackCornReachLimit() then
    return
  end
  local playerInfoList = {}
  for newUid, _ in pairs(newTeamMembers) do
    if not oldTeamMembers[newUid] then
      table.insert(playerInfoList, {uid = newUid})
    end
  end
  local myInviteUidList, otherOldFriendUidList, notFriendUidList = AssemblyActivitySystem.GetBackUserUidList(playerInfoList, false)
  if not next(myInviteUidList) and not next(otherOldFriendUidList) and not next(notFriendUidList) then
    return
  end
  local TableUtil = require("common.table_util")
  otherOldFriendUidList = TableUtil.Filter(otherOldFriendUidList, function(value)
    for _, v in ipairs(myInviteUidList) do
      if v == value then
        return false
      end
    end
    return true
  end)
  local tipsInfo
  if next(myInviteUidList) then
    tipsInfo = AssemblyActivitySystem.GetTipsInfo(myInviteUidList, ENUM_RECALL_PLAYER_TYPE.MyInvite)
    ShowNotice(LocUtil.LocalizeResFormat(43013, tipsInfo.allName, tipsInfo.allAwardNum))
  end
  if next(otherOldFriendUidList) then
    tipsInfo = AssemblyActivitySystem.GetTipsInfo(otherOldFriendUidList, ENUM_RECALL_PLAYER_TYPE.MyInvite)
    ShowNotice(LocUtil.LocalizeResFormat(43013, tipsInfo.allName, tipsInfo.allAwardNum))
  end
  if next(notFriendUidList) then
    tipsInfo = AssemblyActivitySystem.GetTipsInfo(notFriendUidList, ENUM_RECALL_PLAYER_TYPE.OtherOldFriend)
    ShowNotice(LocUtil.LocalizeResFormat(43012, tipsInfo.allName, tipsInfo.allAwardNum, tipsInfo.needRank))
  end
end
function AssemblyActivitySystem.GetTipsInfo(uidList, type)
  local rejoin_care_count, rejoin_care_item_daily_limit = AssemblyActivitySystem.GetScoreLimt()
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  if not (scoreConfig and rejoin_care_count) or not rejoin_care_item_daily_limit then
    log(bWriteLog and string.format("AssemblyActivitySystem.GetTipsInfo, not config"))
    return
  end
  local logic_assembly_activity_utils = require("client.slua.logic.come_back.logic_assembly_activity_utils")
  local allName = ""
  local allAwardNum = 0
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for index, uid in ipairs(uidList) do
    if rejoin_care_item_daily_limit <= rejoin_care_count + allAwardNum then
      allAwardNum = rejoin_care_item_daily_limit - rejoin_care_count
      break
    else
      local profile = logic_profile:GetLocalProfile(uid)
      local name = profile and profile.nickName or ""
      if index == 1 then
        allName = allName .. name
      else
        allName = allName .. "\227\128\129" .. name
      end
      local awardNum = logic_assembly_activity_utils.GetCoinNumByUID(uid, type)
      allAwardNum = allAwardNum + awardNum
    end
  end
  return {
    allName = allName,
    allAwardNum = allAwardNum,
    needRank = scoreConfig.battle_rank_cond
  }
end
function AssemblyActivitySystem.SetBackToLobbyTips(myInviteUidList, otherOldFriendUidList)
  local tipsInfo
  if next(myInviteUidList) then
    tipsInfo = AssemblyActivitySystem.GetTipsInfo(myInviteUidList, ENUM_RECALL_PLAYER_TYPE.MyInvite)
    if tipsInfo then
      AssemblyActivitySystem.backUserLobbyTips = LocUtil.LocalizeResFormat(43016, tipsInfo.allName, tipsInfo.allAwardNum)
    end
  end
  if next(otherOldFriendUidList) then
    tipsInfo = AssemblyActivitySystem.GetTipsInfo(otherOldFriendUidList, ENUM_RECALL_PLAYER_TYPE.OtherOldFriend)
    if tipsInfo then
      AssemblyActivitySystem.backUserLobbyTips = LocUtil.LocalizeResFormat(43015, tipsInfo.allName, tipsInfo.allAwardNum, tipsInfo.needRank)
    end
  end
end
function AssemblyActivitySystem.ShowBackToLobbyTips()
  if not AssemblyActivitySystem.backUserLobbyTips or AssemblyActivitySystem.backUserLobbyTips == "" then
    return
  end
  ShowNotice(AssemblyActivitySystem.backUserLobbyTips)
  AssemblyActivitySystem.backUserLobbyTips = ""
end
function AssemblyActivitySystem.GetBackUserUidList(playerInfoList, isCheckFriend)
  local GetEqualUidFromTwoList = function(t1, t2)
    local uidList = {}
    for k, v in pairs(t1) do
      for _, info in ipairs(t2) do
        if v == info.uid or isCheckFriend and not info.isMyFriend then
          table.insert(uidList, info.uid)
          break
        end
      end
    end
    return uidList
  end
  local myInviteUidList = {}
  local otherOldFriendUidList = {}
  local notFriendUidList = {}
  local MyInviteList = AssemblyActivitySystem.GetMyInviteFriedList() or {}
  myInviteUidList = GetEqualUidFromTwoList(MyInviteList, playerInfoList)
  local otherOldFriendList = AssemblyActivitySystem.GetOtherInviteFriedList() or {}
  otherOldFriendUidList = GetEqualUidFromTwoList(otherOldFriendList, playerInfoList)
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local TableUtil = require("common.table_util")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, info in ipairs(playerInfoList) do
    if info.isMyFriend == false or not LogicFriend.IsMyFriend(info.uid) then
      local profile = logic_profile:GetLocalProfile(info.uid)
      if profile and logic_oldfriend_care.IsRejoinPlayer(profile) and not TableUtil.IsInTable(otherOldFriendUidList, info.uid) then
        table.insert(notFriendUidList, info.uid)
      end
    end
  end
  return myInviteUidList, otherOldFriendUidList, notFriendUidList
end
function AssemblyActivitySystem.CheckBackUserAddFriend(resultData)
  if not AssemblyActivitySystem.GetActivityData() then
    log(bWriteLog and "AssemblyActivitySystem.CheckBackUserAddFriend Activity is not open")
    return
  end
  log_tree(bWriteLog and " AssemblyActivitySystem.CheckBackUserAddFriend resultData", resultData)
  local IsClassicMatchMode = function(battle_type)
    return battle_type == 111 or battle_type == 112 or battle_type == 113 or battle_type == 411 or battle_type == 412 or battle_type == 413
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, _ = logic_mode_selection:GetCurSelectInfo()
  if not IsClassicMatchMode(matchMode) then
    log(bWriteLog and "AssemblyActivitySystem.CheckBackUserAddFriend Match mode is not Classic Match Mode")
    return
  end
  local finalRank = resultData.person_rank or 0
  if resultData.is_team_result then
    finalRank = resultData.team_rank or 0
  end
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  if not scoreConfig then
    log(bWriteLog and "AssemblyActivitySystem.CheckBackUserAddFriend no scoreConfig")
    return
  end
  local needRank = scoreConfig.battle_rank_cond
  if finalRank == 0 or finalRank > needRank then
    log(bWriteLog and "AssemblyActivitySystem:CheckBackUserAddFriend finalRank == 0 or finalRank > AssemblyActivitySystem.getBackCornRankLimit")
    return
  end
  local teammateList = resultData.TeammateList or {}
  table.sort(teammateList, function(a, b)
    return a.FinalScore_f > b.FinalScore_f
  end)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local playerInfoList = {}
  local isAllFriend = true
  for k, v in ipairs(teammateList) do
    if tonumber(v.UID) ~= tonumber(DataMgr.roleData.uid) then
      local isMyFriend = LogicFriend.IsMyFriend(tonumber(v.UID))
      if not isMyFriend then
        isAllFriend = false
      end
      local info = {
        uid = tonumber(v.UID),
              }
      table.insert(playerInfoList, info)
    end
  end
  log_tree(bWriteLog and " AssemblyActivitySystem.CheckBackUserAddFriend playerInfoList", playerInfoList)
  local myInviteUidList, otherOldFriendUidList = AssemblyActivitySystem.GetBackUserUidList(playerInfoList, true)
  if not next(myInviteUidList) and not next(otherOldFriendUidList) then
    log(bWriteLog and "AssemblyActivitySystem.CheckBackUserAddFrien without return teammates")
    return
  end
  log_tree(bWriteLog and " AssemblyActivitySystem.CheckBackUserAddFriend myInviteUidList", myInviteUidList)
  log_tree(bWriteLog and " AssemblyActivitySystem.CheckBackUserAddFriend otherOldFriendUidList", otherOldFriendUidList)
  if isAllFriend then
    log(bWriteLog and "AssemblyActivitySystem.CheckBackUserAddFrien all teammates are friend")
    AssemblyActivitySystem.SetBackToLobbyTips(myInviteUidList, otherOldFriendUidList)
    return
  end
  local uid = AssemblyActivitySystem.GetPreTeammateUid(myInviteUidList)
  local awardNum = scoreConfig.battle_with_rejoiner_award
  local type = ENUM_RECALL_PLAYER_TYPE.MyInvite
  if not uid then
    uid = AssemblyActivitySystem.GetPreTeammateUid(otherOldFriendUidList)
    awardNum = scoreConfig.battle_with_non_rejoiner_award
    type = ENUM_RECALL_PLAYER_TYPE.OtherOldFriend
  end
  if not uid then
    log(bWriteLog and "AssemblyActivitySystem.CheckBackUserAddFrien without pre teamup teammates")
    return
  end
  local content = LocUtil.LocalizeResFormat(43994, AssemblyActivitySystem.getBackCornRankLimit, awardNum)
  AssemblyActivitySystem.ShowAddFriendUI(uid, content)
end
function AssemblyActivitySystem.GetPreTeammateUid(uidList)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  for _, uid in ipairs(uidList) do
    local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
    if memberInfo then
      return uid
    end
  end
  return nil
end
function AssemblyActivitySystem.ShowAddFriendUI(uid, content)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isShowCheckBox = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eFriendAddBackUserCheckTime, true)
  local checkBoxData
  if not isShowCheckBox then
    log(bWriteLog and "AssemblyActivitySystem.ShowAddFriendUI today not show again")
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  checkBoxData = {
    text = LocUtil.LocalizeResFormat(12096),
    callBack = function(isCheck)
      log(bWriteLog and "AssemblyActivitySystem:CheckBackUserAddFriend isCheck = " .. tostring(isCheck))
      local reason = isCheck and 1 or 2
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.Old_Friend_Care_AddFriend_UI_NotShow, reason)
      if not isCheck then
        return
      end
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eFriendAddBackUserCheckTime)
    end
  }
  local data = {
    uid = uid,
    msg = content,
    type = 3,
    recommend_type = BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT_RETURN_RECOMMENDED
  }
  UIManager.ShowUI(UIManager.UI_Config.Results_BackUser_Recommended_Friend_UIBP, data, checkBoxData)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Old_Friend_Care_AddFriend_UI_Show)
end
local oneClickCallTimes = 0
function AssemblyActivitySystem.GetAllReceiveAward(rewardDic, appendFunc, promise)
  local inner = function()
    local recall_award = AssemblyActivitySystem.AssemblyData.recall_award
    local recall_award_cfg = AssemblyActivitySystem.AssemblyCfg.recall_award_cfg
    for id, status in pairs(recall_award) do
      local cfg = recall_award_cfg[id]
      if cfg and status == 1 then
        appendFunc(rewardDic, cfg.item_id, cfg.item_num)
      end
    end
    local task_cfg = AssemblyActivitySystem.AssemblyCfg.task_cfg
    local task = AssemblyActivitySystem.AssemblyData.task
    for id, data in pairs(task) do
      local cfg = task_cfg[id]
      if cfg and data.status == 1 then
        appendFunc(rewardDic, cfg.item_id, cfg.item_num)
      end
    end
    promise:Resolve()
  end
  if not (AssemblyActivitySystem.AssemblyData and AssemblyActivitySystem.AssemblyData.recall_award and AssemblyActivitySystem.AssemblyData.task and AssemblyActivitySystem.AssemblyCfg and AssemblyActivitySystem.AssemblyCfg.recall_award_cfg) or not AssemblyActivitySystem.AssemblyCfg.task_cfg then
    if oneClickCallTimes == 0 then
      AssemblyActivitySystem.assemb_task_query_req({
        "task",
        "recall_award"
      }, {
        "task_cfg",
        "recall_award_cfg"
      })
    end
    oneClickCallTimes = oneClickCallTimes + 1
    printf("AssemblyActivitySystem.GetAllReceiveAward data not ready.do query req. oneClickCallTimes:%s", oneClickCallTimes)
    local time_ticker = require("common.time_ticker")
    if oneClickCallTimes < 4 then
      time_ticker.AddTimerOnce(0.5, function()
        AssemblyActivitySystem.GetAllReceiveAward(rewardDic, appendFunc, promise)
      end)
    else
      printf("AssemblyActivitySystem.GetAllReceiveAward data not ready finally resolve")
      promise:Resolve()
    end
  else
    printf("AssemblyActivitySystem.GetAllReceiveAward AssemblyData and AssemblyCfg is ready.do inner")
    inner()
  end
end
function AssemblyActivitySystem.on_batch_get_group_and_online_rsp_AssemblyActivitySystem(cacheData)
  for k, v in pairs(cacheData) do
    AssemblyActivitySystem.backUserInfoList[k] = {}
    AssemblyActivitySystem.backUserInfoList[k].teamState = v.teamStateNew or 0
    AssemblyActivitySystem.backUserInfoList[k].teamId = v.teamId
    AssemblyActivitySystem.backUserInfoList[k].currentTeamAmount = v.currentTeamAmount
    AssemblyActivitySystem.backUserInfoList[k].maxTeamAmount = v.maxTeamAmount
    AssemblyActivitySystem.backUserInfoList[k].timeSinceGameBegin = v.timeSinceGameBegin
    AssemblyActivitySystem.backUserInfoList[k].online = v.online
    AssemblyActivitySystem.backUserInfoList[k].socialland_type = v.socialland_type
    AssemblyActivitySystem.backUserInfoList[k].tplan_type = v.tplan_type
    AssemblyActivitySystem.backUserInfoList[k].cwow_type = v.cwow_type
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_OLD_FRIEND_CARE_TEAMUP_POOL_UPDATE)
end
function AssemblyActivitySystem.on_batch_get_group_and_online_rsp_CustomCareTeamUp(cacheData)
  for k, v in pairs(cacheData) do
    AssemblyActivitySystem.taskPlayerInfoList[k] = {}
    AssemblyActivitySystem.taskPlayerInfoList[k].teamState = v.teamStateNew or 0
    AssemblyActivitySystem.taskPlayerInfoList[k].teamId = v.teamId
    AssemblyActivitySystem.taskPlayerInfoList[k].currentTeamAmount = v.currentTeamAmount
    AssemblyActivitySystem.taskPlayerInfoList[k].maxTeamAmount = v.maxTeamAmount
    AssemblyActivitySystem.taskPlayerInfoList[k].timeSinceGameBegin = v.timeSinceGameBegin
    AssemblyActivitySystem.taskPlayerInfoList[k].online = v.online
    AssemblyActivitySystem.taskPlayerInfoList[k].socialland_type = v.socialland_type
    AssemblyActivitySystem.taskPlayerInfoList[k].tplan_type = v.tplan_type
    AssemblyActivitySystem.taskPlayerInfoList[k].cwow_type = v.cwow_type
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_OLD_FRIEND_CARE_TASK_PLAYER_UPDATE)
end
function AssemblyActivitySystem.send_assemb_get_back_user_list_req(count, invitee, isShowTips, isRefresh)
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() - AssemblyActivitySystem.backUserListReqTime <= AssemblyActivitySystem.backUserListReqCD then
    return
  end
  AssemblyActivitySystem.backUserListReqTime = TimeUtil.GetServerTimeInSec()
  for k, v in ipairs(AssemblyActivitySystem.backUserUidList or {}) do
    if v == invitee then
      table.remove(AssemblyActivitySystem.backUserUidList, k)
    end
  end
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local oldFriendUidList = logic_oldfriend_care.GetOldFriendUidList()
  local callback = {
    uidList = AssemblyActivitySystem.backUserUidList,
    isShowTips = isShowTips,
      }
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_assemb_get_back_user_list_req(count, callback, oldFriendUidList)
  log(bWriteLog and "AssemblyHandler.send_assemb_get_back_user_list_req count = " .. tostring(count))
  log_tree(bWriteLog and "AssemblyHandler.send_assemb_get_back_user_list_req AssemblyActivitySystem.backUserUidList", AssemblyActivitySystem.backUserUidList)
  log_tree(bWriteLog and "AssemblyHandler.send_assemb_get_back_user_list_req oldFriendUidList", oldFriendUidList)
  if isShowTips then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Old_Friend_Care_Invite_UI_BtnRefresh)
  end
end
function AssemblyActivitySystem.on_assemb_get_back_user_list_res(ret, uid_list, callback)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  if not callback then
    log(bWriteLog and "AssemblyHandler.on_assemb_get_back_user_list_res callback is nil")
    return
  end
  if not next(uid_list) then
    ShowDevNotice("[dev] no data")
  end
  AssemblyActivitySystem.backUserUidList = callback.isRefresh and next(uid_list) and uid_list or callback.uidList
  if not callback.isRefresh then
    for _, v in ipairs(uid_list) do
      local isEqual = false
      for _, uid in ipairs(callback.uidList) do
        if uid == v then
          isEqual = true
          break
        end
      end
      if not isEqual then
        table.insert(AssemblyActivitySystem.backUserUidList, v)
      end
    end
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if next(AssemblyActivitySystem.backUserUidList) then
    local noInfoPlayerList = {}
    for _, uid in pairs(uid_list) do
      if not logic_profile:GetLocalProfile(uid) then
        table.insert(noInfoPlayerList, uid)
      end
    end
    if next(noInfoPlayerList) then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(noInfoPlayerList, function()
        EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_OLD_FRIEND_CARE_TEAMUP_POOL_UPDATE)
      end, Enum_PROFILE_REPORT_CFG.COMBACK, 0, true)
    end
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.AssemblyActivitySystem, AssemblyActivitySystem.backUserUidList, AssemblyActivitySystem.on_batch_get_group_and_online_rsp_AssemblyActivitySystem)
  end
end
function AssemblyActivitySystem.SyncAssemblyFriendToServer(innerList, platformList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eAssemblyLastSycnFrdTime, true) then
    log(bWriteLog and "AssemblyActivitySystem.SyncAssemblyFriendToServer, is already sync")
    return
  end
  local count = 0
  local syncList = {}
  if not (LobbySystem.roleData.cfg_assemb_reg_days and LobbySystem.roleData.cfg_assemb_last_login_days) or not LobbySystem.roleData.cfg_assemb_role_level then
    return
  end
  local checkLimit = function(profile)
    if not profile then
      log(bWriteLog and "SyncAssemblyFriendToServer checkLimit, wrong profile")
      return false
    end
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - (profile.registertime or 0) < LobbySystem.roleData.cfg_assemb_reg_days * 86400 then
      log(bWriteLog and string.format("SyncAssemblyFriendToServer checkLimit, registertime < 60 uid:%s", profile.uid))
      return false
    end
    if TimeUtil.GetServerTimeInSec() - (profile.lastLoginTime or 0) < LobbySystem.roleData.cfg_assemb_last_login_days * 86400 then
      log(bWriteLog and string.format("SyncAssemblyFriendToServer checkLimit, lastLoginTime < 28 uid:%s", profile.uid))
      return false
    end
    if (profile.level or 1) < LobbySystem.roleData.cfg_assemb_role_level then
      log(bWriteLog and string.format("SyncAssemblyFriendToServer checkLimit, level < 15 uid:%s", profile.uid))
      return false
    end
    return true
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local len = 0
  for k, v in ipairs(platformList or {}) do
    if len < 100 then
      local profile = logic_profile:GetLocalProfile(v)
      if type(v) == "number" and checkLimit(profile) then
        syncList[v] = 1
        len = len + 1
      end
    else
      break
    end
  end
  for k, v in ipairs(innerList or {}) do
    if len < 100 then
      local profile = logic_profile:GetLocalProfile(v)
      if type(v) == "number" and checkLimit(profile) then
        syncList[v] = 1
        len = len + 1
      end
    else
      break
    end
  end
  if not next(syncList) then
    log_tree(bWriteLog and "AssemblyActivitySystem.SyncAssemblyFriendToServer syncList is empty", syncList)
    return
  end
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_assemb_update_invite_list(syncList)
end
function AssemblyActivitySystem.send_trigger_assemb_gold_tips_req()
  if not AssemblyActivitySystem.isCanReqGoldTips then
    log(bWriteLog and string.format("AssemblyActivitySystem.send_trigger_assemb_gold_tips_req, AssemblyActivitySystem.isCanReqGoldTips:%s", AssemblyActivitySystem.isCanReqGoldTips))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAssemblyGoldTips) or {}
  local actData = AssemblyActivitySystem.GetActivityData()
  if actData and saveData[actData.ID] then
    log(bWriteLog and string.format("AssemblyActivitySystem.send_trigger_assemb_gold_tips_req, is already req actData.ID:%s", actData.ID))
    return
  end
  local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
  AssemblyHandler.send_trigger_assemb_gold_tips_req()
end
function AssemblyActivitySystem.on_trigger_assemb_gold_tips_res(res, add_num)
  if res ~= 0 then
    local actData = AssemblyActivitySystem.GetActivityData()
    if not actData then
      AssemblyActivitySystem.isCanReqGoldTips = false
    else
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAssemblyGoldTips) or {}
      saveData[actData.ID] = true
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAssemblyGoldTips)
    end
    return
  end
  ShowNotice(665489)
end
return AssemblyActivitySystem