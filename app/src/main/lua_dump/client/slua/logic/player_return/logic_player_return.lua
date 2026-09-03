local logic_player_return = {
  login_reward_list = {},
  login_reward_info = {},
  notifyFriendList = nil,
  pay_back_info = {},
  privilege_info = {},
  new_post_info = {},
  warm_statistic = {},
  blockTip = false,
  blackListUI = {
    SecurityStation = true,
    esport_center_tip = true,
    Notify_Invite_UIBP = true,
    allstar_begin_popup = true,
    Common_Receive_UIBP = true,
    ui_season_switch_mgr = true,
    Achievement_Tip_UIBP = true,
    corps_fight_right_tip = true,
    Championship_Begin_Popup = true,
    ReputationSystem_Popup_UIBP = true
  }
}
local Report_Event_Config = {
  [1] = 83,
  [2] = 84,
  [3] = 85,
  [4] = 86,
  [5] = 87,
  [6] = 88,
  [7] = 89,
  [8] = 90
}
function logic_player_return.on_backuser_get_login_reward_info_notify(info, reward_list, path)
  logic_player_return.login_  logic_player_return.login_reward_  logic_player_return.login_reward_info.back_image_url = path
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_LOGIN_REWARD)
end
function logic_player_return.on_backuser_get_login_reward_res(index)
  if logic_player_return.login_reward_info and logic_player_return.login_reward_info.got_indexs then
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_LOGIN_REWARD)
  end
end
function logic_player_return.on_back_user_report_event(dayIndex)
  local logic_user_ctrl = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_user_ctrl)
  if not logic_user_ctrl:IsReturnUser() then
    log(bWriteLog and "logic_player_return.on_back_user_report_event return of not IsReturnUser")
    return
  end
  if Report_Event_Config[dayIndex] then
    local StatManager = import("StatManager")
    local BusinessHelper = import("BusinessHelper")
    StatManager.GetInstance():ReportEventWithParam(Report_Event_Config[dayIndex], {
      openId = BusinessHelper.GetOpenId(),
      nation = DataMgr.roleData.nation
    }, true)
  end
end
function logic_player_return.send_backuser_get_user_gift_req()
  local playreturn = require("client.network.Protocol.PlayerReturnHandler")
  playreturn.send_backuser_get_user_gift_req()
end
local _CheckHaveShareItem = function(arrayItemList)
  if not arrayItemList or #arrayItemList <= 0 then
    log(bWriteLog and "_CheckHaveShareItem return of arrayItemList error")
    return
  end
  local rare_item_get_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.rare_item_get_module)
  for _, itemData in ipairs(arrayItemList) do
    if rare_item_get_module:NeedShare(itemData) then
      return true
    end
  end
  return false
end
function logic_player_return.on_backuser_get_user_gift_res(reward_list)
  if DataMgr and DataMgr.roleData and DataMgr.roleData.back_user_data then
    DataMgr.roleData.back_user_data.user_gift_dropid = 0
  end
  local arrayItemList = {}
  if reward_list then
    for _, v in pairs(reward_list) do
      local arrayItem = {
        res_id = v.res_id,
        count = v.count,
        expire_ts = v.expire_ts,
        valid_hours = v.valid_hours
      }
      table.insert(arrayItemList, arrayItem)
    end
  end
  local fCloseFunc
  if not _CheckHaveShareItem(arrayItemList) then
    log(bWriteLog and "logic_player_return.on_backuser_get_user_gift_res not _CheckHaveShareItem")
    fCloseFunc = logic_player_return.AfterPackageUIFunc
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, true, {fCloseCallback = fCloseFunc})
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_GET_GIFT_RSP)
  local StatManager = import("StatManager")
  local BusinessHelper = import("BusinessHelper")
  local roleData_Nation = DataMgr and DataMgr.roleData and DataMgr.roleData.nation or ""
  StatManager.GetInstance():ReportEventWithParam(78, {
    openId = BusinessHelper.GetOpenId(),
    nation = roleData_Nation
  }, true)
end
function logic_player_return.AfterPackageUIFunc(arrayItemList)
  local packageUI = UIManager.GetUI(UIManager.UI_Config.ReturnActivity_WelcomeBack_UIBP)
  if packageUI then
    packageUI:CloseSelf()
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  if logic_return_activity_guide:IsHitNewGuide() then
    return
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  if logic_return_activity:CheckShowReturnGiftUI() then
  else
    local cfg = logic_return_activity:GetAbtestConfig()
    if not cfg then
      return
    end
    log_tree(bWriteLog and "logic_player_return.AfterPackageUIFunc cfg", cfg)
    local common_config = require("client.slua.common.common_config")
    if common_config:IsBlockingPopupTip() then
      log(bWriteLog and "logic_player_return.AfterPackageUIFunc UI responsiveness testing")
      return
    end
    if tonumber(cfg.guide_type) == 1 then
      UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Task_Popup_UIBP)
    elseif tonumber(cfg.guide_type) == 2 then
      logic_return_activity_guide:ShowFBGuideUI()
    end
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityABTestGuide, cfg.guide_type)
    local isItemCanShare = _CheckHaveShareItem(arrayItemList)
    if not isItemCanShare then
      local StatManager = import("StatManager")
      local BusinessHelper = import("BusinessHelper")
      local roleData_Nation = DataMgr and DataMgr.roleData and DataMgr.roleData.nation or ""
      StatManager.GetInstance():ReportEventWithParam(79, {
        openId = BusinessHelper.GetOpenId(),
        nation = roleData_Nation
      }, true)
    end
  end
end
function logic_player_return.GetNotifyFriendList()
  if not (DataMgr and DataMgr.roleData) or not DataMgr.roleData.back_user_data then
    log(bWriteLog and "logic_player_return.GetNotifyFriendList no back_user_data")
    return
  end
  local logicNewFriend = require("client.slua.logic.friend.logic_new_friend")
  log(bWriteLog and string.format("logic_player_return.GetNotifyFriendList, DataMgr.roleData.back_user_data.frd_notify_num_limit:%s", DataMgr.roleData.back_user_data.frd_notify_num_limit))
  local limitNum = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.frd_notify_num_limit or 3
  local friendList = logicNewFriend.GetInnerList(true, function(a, b)
    if a.intimacy == nil or b.intimacy == nil then
      return false
    else
      return a.intimacy > b.intimacy
    end
  end)
  local realFriendList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, uid in ipairs(friendList) do
    local proflie = logic_profile:GetLocalProfile(uid)
    if logicNewFriend.IsMyFriend(uid) and not logic_profile:IsPlayerDelete(proflie) then
      table.insert(realFriendList, logicNewFriend.GetFriendData(uid))
    end
  end
  logic_player_return.notifyFriendList = {}
  local insertList = {}
  for _, data in ipairs(realFriendList) do
    if limitNum <= #logic_player_return.notifyFriendList then
      break
    end
    if data.intimacy and data.intimacy >= 10 and data.online == 1 and not insertList[data.uid] then
      table.insert(logic_player_return.notifyFriendList, {
        uid = data.uid,
        selected = true
      })
      insertList[data.uid] = true
    end
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local interval = 604800
  if limitNum > #logic_player_return.notifyFriendList then
    for _, data in ipairs(realFriendList) do
      if limitNum <= #logic_player_return.notifyFriendList then
        break
      end
      if data.online == 0 and data.intimacy and data.intimacy >= 10 and not insertList[data.uid] then
        local proflie = logic_profile:GetLocalProfile(data.uid)
        if proflie and proflie.lastLoginTime and (serverTime - proflie.lastLoginTime or 0 < interval) then
          table.insert(logic_player_return.notifyFriendList, {
            uid = data.uid,
            selected = true
          })
          insertList[data.uid] = true
        end
      end
    end
  end
  if limitNum > #logic_player_return.notifyFriendList then
    for _, data in ipairs(realFriendList) do
      if limitNum <= #logic_player_return.notifyFriendList then
        break
      end
      local proflie = logic_profile:GetLocalProfile(data.uid)
      if proflie and proflie.lastLoginTime and not insertList[data.uid] and (data.online == 1 or serverTime - proflie.lastLoginTime or 0 < interval) then
        table.insert(logic_player_return.notifyFriendList, {
          uid = data.uid,
          selected = true
        })
        insertList[data.uid] = true
      end
    end
  end
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  table.sort(logic_player_return.notifyFriendList, function(a, b)
    local interactDataA = logic_friend_interact_record:GetCumulativeInteractRecordData(a.uid) or {}
    local interactDataB = logic_friend_interact_record:GetCumulativeInteractRecordData(b.uid) or {}
    local teamupCountA = interactDataA.teamup_num or 0
    local teamupCountB = interactDataB.teamup_num or 0
    return teamupCountA > teamupCountB
  end)
  log_tree(bWriteLog and "logic_player_return.GetNotifyFriendList logic_player_return.notifyFriendList", logic_player_return.notifyFriendList)
  return logic_player_return.notifyFriendList
end
function logic_player_return.on_backuser_get_topup_rebate_info_res(info)
  if not LobbySystem.CheckOpen(32013) then
    return
  end
  logic_player_return.pay_back_info = info or {}
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_BUY_UC_CHANGE)
end
function logic_player_return.on_backuser_get_privilege_data_res(data, battle_task_cfg, privi_cfg, day_win_cnt)
  logic_player_return.privilege_info = {}
  logic_player_return.privilege_info.progress = data
  logic_player_return.privilege_info.task_cfg = battle_task_cfg
  logic_player_return.privilege_info.base_cfg = privi_cfg
  log_tree(bWriteLog and "logic_player_return.on_backuser_get_privilege_data_res privi_cfg", privi_cfg)
  log(bWriteLog and "[v_wllwu] logic_player_return.on_backuser_get_privilege_data_res,  day_win_cnt = " .. tostring(day_win_cnt))
  if day_win_cnt ~= nil and DataMgr and DataMgr.roleData and DataMgr.roleData.back_user_data then
    DataMgr.roleData.back_user_data.back_user_day_win_score_cnt = day_win_cnt
  end
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_PRIVILEGE_CHANGE)
end
function logic_player_return.on_backuser_battle_task_reward_res(got_indexs)
  logic_player_return.privilege_info.progress.got_indexs[got_indexs] = true
  local itemdata = logic_player_return.privilege_info.task_cfg[got_indexs]
  local arrayItemList = {}
  for i = 1, 3 do
    local suffix = string.format("%d", i)
    local arrayItem = {}
    local resid = itemdata["res_id" .. suffix]
    if resid ~= 0 then
      arrayItem.res_id = resid
      arrayItem.expire_ts = 0
      arrayItem.valid_hours = itemdata["expire_time" .. suffix]
      arrayItem.count = itemdata["res_num" .. suffix]
      table.insert(arrayItemList, arrayItem)
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_PRIVILEGE_CHANGE)
end
function logic_player_return.on_backuser_privilege_change_notify(progress, data2)
  if logic_player_return.privilege_info.progress then
    logic_player_return.privilege_info.progress.  else
    local userData = DataMgr.roleData.back_user_data
    if userData then
      local battleNum = userData.battle_task_progress
      if battleNum and battleNum <= 0 then
        local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
        PlayerReturnHandler.send_backuser_get_privilege_data_req()
      end
    end
  end
  if DataMgr.roleData.back_user_data then
    DataMgr.roleData.back_user_data.red_point = data2
  end
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_PRIVILEGE_CHANGE)
end
function logic_player_return.OpenMainUI(_, _, params)
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:EnterMainUI(params and params.menuId and tonumber(params.menuId), true)
end
function logic_player_return.SetIsSendMsg(result)
  if result and result.backuser_reward then
    logic_player_return.isSendPrivilegeMsg = true
  end
end
function logic_player_return.OnModePostSwitch(preState, nextState)
  local logic_player_return_slap = require("client.slua.logic.player_return.logic_player_return_slap")
  if GameStatus.IsInLobbyOrMainCity() then
    logic_player_return.isFight = false
    if DataMgr.roleData.back_user_data and next(DataMgr.roleData.back_user_data) and logic_player_return.isSendPrivilegeMsg then
      local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
      PlayerReturnHandler.send_backuser_get_privilege_data_req()
      logic_player_return.isSendPrivilegeMsg = false
    end
  else
    local logic_replay = require("client.slua.logic.replay.logic_replay")
    if logic_replay.IsPlayingReplay() then
      return
    end
    if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
      logic_player_return.isFight = true
      logic_player_return_slap.UpdateCurrentBattleNum()
    end
  end
  if nextState == GameStatus.Login then
    logic_player_return.warm_Data_Game = nil
    logic_player_return_slap.ClearData()
    logic_player_return.pay_back_info = {}
  end
end
function logic_player_return.IsPrivilegeOpen()
  if DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.rejoin_start_time and DataMgr.roleData.back_user_data.privilege_expire_day then
    local TimeUtil = require("client.common.time_util")
    return DataMgr.roleData.back_user_data.rejoin_start_time + DataMgr.roleData.back_user_data.privilege_expire_day * 86400 - TimeUtil.GetServerTimeInSec() > 0
  else
    return false
  end
end
function logic_player_return.GetPrivilegeEndTime()
  local time = 0
  if DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.rejoin_start_time and DataMgr.roleData.back_user_data.privilege_expire_day then
    time = DataMgr.roleData.back_user_data.rejoin_start_time + DataMgr.roleData.back_user_data.privilege_expire_day * 86400
  end
  return time
end
function logic_player_return.isPlayerReturnOpenNew()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsNewActOpen() then
    log(bWriteLog and "logic_player_return.isPlayerReturnOpenNew return of not open")
    return false
  end
  return logic_return_activity_utils.IsActInProgress()
end
function logic_player_return.HandleHideUIWhenPlayerReturn()
  log(bWriteLog and "[chub]logic_player_return.HandleHideUIWhenPlayerReturn()")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not logic_player_return.isPlayerReturnOpenNew() then
    log(bWriteLog and "[chub]logic_player_return.isPlayerReturnOpenNew() is false")
    logic_player_return.blockTip = false
    PlayerPrefsSystem.SaveTableToFile_N({loginTimes = 0}, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLoginTimes)
    return
  end
  local TimeUtil = require("client.common.time_util")
  local dayCfg = CDataTable.GetTableData("ReturnParamsConfig", "BlockTipDay")
  local timesCfg = CDataTable.GetTableData("ReturnParamsConfig", "BlockTipTimes")
  local day = tonumber(dayCfg.ParamValue) or 1
  local times = tonumber(timesCfg.ParamValue) or 5
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLoginTimes) or {}
  log(bWriteLog and "[chub]dayCfg.ParamValue = " .. tostring(dayCfg.ParamValue))
  log(bWriteLog and "[chub]timesCfg.ParamValue = " .. tostring(timesCfg.ParamValue))
  log(bWriteLog and "[chub]DataMgr.roleData.back_user_data.rejoin_start_time = " .. tostring(DataMgr.roleData.back_user_data.rejoin_start_time))
  log(bWriteLog and "[chub]TimeUtil.GetServerTimeInSec() - DataMgr.roleData.back_user_data.rejoin_start_time = " .. tostring(TimeUtil.GetServerTimeInSec() - DataMgr.roleData.back_user_data.rejoin_start_time))
  log(bWriteLog and "[chub]savedData.loginTimes = " .. tostring(savedData.loginTimes))
  local bDayLimit = TimeUtil.GetServerTimeInSec() - DataMgr.roleData.back_user_data.rejoin_start_time < day * 86400
  local bTimesLimit = not savedData.loginTimes or times > savedData.loginTimes
  if bDayLimit or bTimesLimit then
    log(bWriteLog and "[chub]logic_player_return.blockTip = true")
    logic_player_return.blockTip = true
  else
    log(bWriteLog and "[chub]logic_player_return.blockTip = false")
    logic_player_return.blockTip = false
  end
  local loginTimes = tonumber(savedData.loginTimes or 0) + 1
  PlayerPrefsSystem.SaveTableToFile_N({loginTimes = loginTimes}, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLoginTimes)
end
function logic_player_return.on_back_user_notify_friends_gifts_res()
  local userdata = DataMgr.roleData.back_user_data
  if userdata then
    userdata.friend_notify_flag = true
  end
end
function logic_player_return.JudgeDailyRewardRedDot()
  if logic_player_return.login_reward_info.cur_day and logic_player_return.login_reward_info.got_indexs and logic_player_return.login_reward_list and next(logic_player_return.login_reward_list) then
    local cur_day = logic_player_return.login_reward_info.cur_day
    for k, _ in pairs(logic_player_return.login_reward_list) do
      if k <= cur_day and not logic_player_return.login_reward_info.got_indexs[k] then
        return true
      end
    end
  else
    return false
  end
  return false
end
function logic_player_return.JudgePrivilegeRedDot(battleNum)
  if not DataMgr.roleData.back_user_data then
    return
  end
  local page_info = DataMgr.roleData.back_user_data.page_info
  local macro = require("client.slua.logic.player_return.player_return_macro")
  local menuID = macro.Enum_Tab_MenuID.tabPrivilege
  if not page_info[menuID] or not LobbySystem.CheckOpen(menuID) then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local endTime = logic_player_return.GetPrivilegeEndTime()
  if nowTime >= endTime then
    return
  end
  if logic_player_return.privilege_info and logic_player_return.privilege_info.progress and next(logic_player_return.privilege_info.progress) then
    local progress = logic_player_return.privilege_info.progress.progress
    local gotInfo = logic_player_return.privilege_info.progress.got_indexs
    for k, _ in pairs(logic_player_return.privilege_info.task_cfg) do
      if battleNum ~= nil then
        if battleNum == k then
          return k <= progress and not gotInfo[k]
        end
      elseif k <= progress and not gotInfo[k] then
        return true
      end
    end
  end
  return false
end
function logic_player_return.JudgeTeachRedDot()
  if logic_player_return.TeachInfo and logic_player_return.TeachInfo.reward_status and logic_player_return.TeachInfo.reward_status == 1 then
    return true
  else
    return false
  end
end
function logic_player_return.JudgeNewPost()
  if logic_player_return.new_post_info and next(logic_player_return.new_post_info) then
    for _, itemdata in ipairs(logic_player_return.new_post_info) do
      if itemdata.task_info and itemdata.task_info.status and itemdata.task_info.status == 1 then
        return true
      end
    end
  end
  return false
end
function logic_player_return.IsLobbyEntranceRed()
  local logic_come_back_task = require("client.slua.logic.player_return.logic_come_back_task")
  local logic_player_return_rank = require("client.slua.logic.player_return.logic_player_return_rank")
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if logic_player_return.login_reward_info.cur_day then
    return logic_come_back_task.GetRedPoint() or logic_player_return.JudgeDailyRewardRedDot() or logic_player_return.JudgePrivilegeRedDot() or logic_player_return.JudgeTeachRedDot() or logic_player_return_rank.CheckRedDot() or logic_player_return.JudgeNewPost() or logic_longline_task.isHaveLevelOrTaskReward()
  end
  if DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.red_point then
    return true
  end
  return false
end
function logic_player_return.on_backuser_get_user_guide_res(guide_cfg, status)
  logic_player_return.TeachInfo = guide_cfg or {}
  logic_player_return.TeachInfo.reward_  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_TEACH_CHANGE)
end
function logic_player_return.on_backuser_set_guide_finished_res(status)
  if logic_player_return.TeachInfo then
    logic_player_return.TeachInfo.reward_  end
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_TEACH_CHANGE)
end
function logic_player_return.on_backuser_get_guide_reward_res()
  if logic_player_return.TeachInfo then
    logic_player_return.TeachInfo.reward_status = 2
    if logic_player_return.TeachInfo.res_id1 then
      local arrayItemList = {}
      local arrayItem = {}
      arrayItem.res_id = logic_player_return.TeachInfo.res_id1
      arrayItem.expire_ts = 0
      local itemcfg = CDataTable.GetTableData("Item", arrayItem.res_id)
      arrayItem.valid_hours = itemcfg.ValidTimes or 0
      arrayItem.count = logic_player_return.TeachInfo.res_num1
      table.insert(arrayItemList, arrayItem)
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
    end
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_TEACH_CHANGE)
  end
end
function logic_player_return.on_backuser_get_new_content_res(content_list)
  logic_player_return.new_post_info = content_list
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_NEW_POST_CHANGE)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_NEW_POST)
end
function logic_player_return.send_backuser_get_new_content_task_award_req(pageIndex, taxk_index)
  logic_player_return.  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_get_new_content_task_award_req(taxk_index)
end
function logic_player_return.on_backuser_get_new_content_task_award_rsp()
  log(bWriteLog and "[ZH] logic_player_return.pageIndex: " .. tostring(logic_player_return.pageIndex))
  local new_post_info = logic_player_return.new_post_info
  if new_post_info and next(new_post_info) then
    log_tree("[ZH]  logic_player_return.new_post_info", new_post_info)
    local pageInfo = logic_player_return.new_post_info[logic_player_return.pageIndex]
    if pageInfo and pageInfo.task_info then
      pageInfo.task_info.status = 2
      local rewardList = {}
      for _, v in pairs(pageInfo.task_info.reward_list) do
        table.insert(rewardList, {
          res_id = v.res_id,
          count = v.res_num,
          valid_hours = v.valid_hours or 0
        })
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(rewardList)
    end
  end
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_NEW_POST_CHANGE)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_NEW_POST)
end
function logic_player_return.send_backuser_get_daily_reward_req()
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_get_daily_reward_req()
end
function logic_player_return.on_backuser_get_daily_reward_res(status)
  if status == 2 then
    DataMgr.roleData.back_user_data.daily_battle_data.  end
  local rewardCfg = DataMgr.roleData.back_user_data.daily_battle_data.reward_cfg
  local rewardItems = {}
  for i, _ in ipairs(rewardCfg) do
    if rewardCfg[i].res_id and rewardCfg[i].res_id > 0 then
      table.insert(rewardItems, {
        res_id = rewardCfg[i].res_id,
        count = rewardCfg[i].res_num,
        valid_hours = rewardCfg[i].valid_hours
      })
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewardItems)
end
function logic_player_return.on_back_user_daily_battle_award_notify(status)
  if DataMgr and DataMgr.roleData and DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.daily_battle_data then
    DataMgr.roleData.back_user_data.daily_battle_data.  end
end
function logic_player_return.on_warm_statistic_info_notify(warm_statistic_info)
  logic_player_return.warm_statistic = warm_statistic_info
end
function logic_player_return.checkFavorTeammateNotComplete()
  local data = logic_player_return.getDataFromTaskType(114)
  if data and data.status == 0 then
    return true
  end
  return false
end
function logic_player_return.getFavorTeammateData()
  return logic_player_return.getDataFromTaskType(114)
end
function logic_player_return.getFavorTeammateText()
  local comebackTaskList = CDataTable.GetTable("ComeBackTask")
  local showTaskCData = comebackTaskList[114]
  if showTaskCData then
    local showTaskSData = logic_player_return.getDataFromTaskType(showTaskCData.ID)
    local showText = LocUtil.LocalizeResFormat(showTaskCData.showText, showTaskSData.para1)
    return showText
  end
  return ""
end
function logic_player_return.getDataFromTaskType(tasktype)
  local logic_come_back_task = require("client.slua.logic.player_return.logic_come_back_task")
  if logic_come_back_task.ext_info == nil then
    return
  end
  tasktype = tonumber(tasktype)
  local curDay = logic_come_back_task.ext_info.cur_day
  if 5 < curDay then
    curDay = 5
  end
  local tasklist = logic_come_back_task.get_task_list
  for i = 1, curDay do
    local task = tasklist[i]
    for _, taskItem in ipairs(task) do
      if taskItem.task_type == tasktype then
        return taskItem
      end
    end
  end
end
function logic_player_return.CheckTaskTipGray()
  local back_user_data = DataMgr.roleData.back_user_data
  if back_user_data and back_user_data.task_tips_gray_switch == true then
    return false
  end
  return true
end
function logic_player_return.UpdateWarmData(kill_num, survive_time)
  if 101 == BATTLETYPE_MODE or 102 == BATTLETYPE_MODE or 103 == BATTLETYPE_MODE or 401 == BATTLETYPE_MODE or 402 == BATTLETYPE_MODE or 403 == BATTLETYPE_MODE then
  else
    return
  end
  logic_player_return.warm_Data_Games = logic_player_return.warm_Data_Games or {}
  local tab = {}
  tab.sub_mode = BP_STRUCT_BattleResultData.sub_mode or 0
  tab.kill_num = kill_num or 0
  tab.survive_time = survive_time or 0
  local TimeUtil = require("client.common.time_util")
  tab.start_time = TimeUtil.GetServerTimeInSec()
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  local bIsNewRecord = true
  for _, gameRecord in ipairs(logic_player_return.warm_Data_Games) do
    if gameRecord.survive_time == tab.survive_time and gameRecord.kill_num == tab.kill_num then
      bIsNewRecord = false
      break
    end
  end
  if bIsNewRecord then
    table.insert(logic_player_return.warm_Data_Games, tab)
  end
  if not BP_STRUCT_BattleResultData.sub_mode then
    GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] BP_STRUCT_BattleResultData.sub_mode is nil ")
  end
  log_tree("[ZH] logic_player_return.warm_Data_Games", logic_player_return.warm_Data_Games)
end
function logic_player_return.SetWarmData(warm_Data_Games)
  logic_player_return.warm_Data_Games = warm_Data_Games or {}
  log_tree("[ZH] logic_player_return.warm_Data_Games", logic_player_return.warm_Data_Games)
end
function logic_player_return.GetGameNumsByNearDays(days)
  local time = days * 86400
  local TimeUtil = require("client.common.time_util")
  local nowTime = tonumber(TimeUtil.GetServerTimeInSec())
  local gameNums = 0
  local dayGameList = logic_player_return.warm_Data_Games or {}
  for _, v in ipairs(dayGameList) do
    if tonumber(v.start_time) >= nowTime - time then
      gameNums = gameNums + 1
    end
  end
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] gameNums: " .. tostring(gameNums))
  return gameNums
end
function logic_player_return.GetLiveTimeByGameNums(min, max)
  local survive_time = 0
  local gameNum = 0
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  local cfg
  if GuideFlowHandler.GuideFlowModeAliveTb then
    cfg = GuideFlowHandler.GuideFlowModeAliveTb
  else
    GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] GuideFlowModeAliveTb is nil ")
    cfg = CDataTable.GetTable("GuideFlowModeAliveTb") or {}
  end
  local gameList = logic_player_return.warm_Data_Games or {}
  table.sort(gameList, function(a, b)
    return a.start_time > b.start_time
  end)
  local DefaultGuideFlowMode = require("client.slua.logic.GuideFlow.DefaultGuideFlowMode")
  local surviveTimeCoef = 1
  local sub_mode = 0
  local info = {}
  for i, v in ipairs(gameList) do
    if i <= max and min <= i then
      sub_mode = v.sub_mode or 0
      info = DefaultGuideFlowMode.GetFromTable(cfg, sub_mode) or {}
      surviveTimeCoef = info.surviveTimeCoef or 1
      if surviveTimeCoef <= 0 then
        log_tree("[ZH] game info of falult sub_mode", v)
        GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] surviveTimeCoef: " .. tostring(surviveTimeCoef))
        surviveTimeCoef = 1
      end
      survive_time = survive_time + tonumber(v.survive_time) * surviveTimeCoef
      gameNum = gameNum + 1
    end
  end
  if gameNum == 0 then
    log_tree("[ZH] gameList", gameList)
    GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] GetLiveTimeByGameNums = 0 ")
    return 0
  end
  survive_time = survive_time / gameNum
  GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] survive_time: " .. tostring(survive_time))
  return survive_time
end
function logic_player_return.GetKillNumsByGameNums(min, max)
  local kill_num = 0
  local gameNum = 0
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  local cfg
  if GuideFlowHandler.GuideFlowModeAliveTb then
    cfg = GuideFlowHandler.GuideFlowModeAliveTb
  else
    GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] GuideFlowModeAliveTb is nil ")
    cfg = CDataTable.GetTable("GuideFlowModeAliveTb") or {}
  end
  local gameList = logic_player_return.warm_Data_Games or {}
  table.sort(gameList, function(a, b)
    return a.start_time > b.start_time
  end)
  local DefaultGuideFlowMode = require("client.slua.logic.GuideFlow.DefaultGuideFlowMode")
  local killNumCoef = 1
  local sub_mode = 0
  local info = {}
  for i, v in ipairs(gameList) do
    if i <= max and min <= i then
      sub_mode = v.sub_mode or 0
      info = DefaultGuideFlowMode.GetFromTable(cfg, sub_mode) or {}
      killNumCoef = info.killNumCoef or 1
      if killNumCoef <= 0 then
        log_tree("[ZH] game of fault sub_mode ", v)
        GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] killNumCoef: " .. tostring(killNumCoef))
        killNumCoef = 1
      end
      kill_num = kill_num + tonumber(v.kill_num) * killNumCoef
      gameNum = gameNum + 1
    end
  end
  if gameNum == 0 then
    log_tree("[ZH] gameList", gameList)
    GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] GetKillNumsByGameNums = 0 ")
    return 0
  end
  kill_num = kill_num / gameNum
  GuideFlowLog.log(GuideFlowLog.bLog and "[ZH] kill_num: " .. tostring(kill_num))
  return kill_num
end
function logic_player_return.GetCurrentBattleNum()
  if logic_player_return.privilege_info and logic_player_return.privilege_info.progress then
    return logic_player_return.privilege_info.progress.progress
  end
  return nil
end
function logic_player_return.GetPrivilegeDataByIndex(index)
  if not logic_player_return.privilege_info.base_cfg then
    return
  end
  return logic_player_return.privilege_info.base_cfg[index]
end
function logic_player_return.GetPrivilegeIsExpire()
  local firstWin = logic_player_return.GetPrivilegeDataByIndex(3)
  local exp = logic_player_return.GetPrivilegeDataByIndex(1)
  local rankProtect = logic_player_return.GetPrivilegeDataByIndex(2)
  if not firstWin and not exp and not rankProtect then
    return true
  end
  return false
end
function logic_player_return.Get400HasReturnChannel()
  local is_return = logic_player_return.isPlayerReturnOpenNew()
  local is_a = LobbySystem.roleData.back_user_chat_abtest_info and LobbySystem.roleData.back_user_chat_abtest_info[1]
  local is_newbie = DataMgr.IsRecruit()
  log(bWriteLog and string.format("logic_player_return.Get400HasReturnChannel is_return = %s, is_a = %s, is_newbie = %s", tostring(is_return), tostring(is_a), tostring(is_newbie)))
  if is_newbie then
    return false
  elseif is_return and is_a then
    return true
  elseif not is_return then
    return true
  end
  return false
end
function logic_player_return.Get400CanFreeTalkInReturnChannel()
  local is_return = logic_player_return.isPlayerReturnOpenNew()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local TimeUtil = require("client.common.time_util")
  local leftTime = logic_return_activity_utils.GetTime(7) - TimeUtil.GetServerTimeInSec()
  local is_a = LobbySystem.roleData.back_user_chat_abtest_info and LobbySystem.roleData.back_user_chat_abtest_info[1]
  local hasPermission = LobbySystem.roleData.back_user_chat_abtest_info and LobbySystem.roleData.back_user_chat_abtest_info[2]
  log(bWriteLog and string.format("logic_player_return.Get400CanFreeTalkInReturnChannel is_return = %s, leftTime = %s, is_a = %s, hasPermission = %s", tostring(is_return), tostring(leftTime), tostring(is_a), tostring(hasPermission)))
  if is_return and is_a and hasPermission and 0 < leftTime then
    return true
  end
  return false
end
return logic_player_return