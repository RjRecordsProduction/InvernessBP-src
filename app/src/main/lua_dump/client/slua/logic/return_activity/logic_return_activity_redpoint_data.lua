local ReturnRedpointData = {}
local Status = {
  Init = 1,
  Temp = 2,
  Abandon = 3
}
local Enum_SubID = {
  dailySignInReward = 2,
  dailyTask = 3,
  battleReward = 4,
  rankReward = 5,
  teachReward = 6,
  newPostReward = 7,
  newPostFirstEnter = 8,
  interactReward = 9,
  discountReward = 10
}
local Enum_RedPointName = {
  dailySignInReward = "dailySignInReward",
  dailyTask = "dailyTask",
  privilege = "privilege",
  newPost = "newPost",
  interactReward = "interactReward",
  discountReward = "discountReward"
}
local isInitArr = {}
local countTbl = {}
local linkList, redpointData
local isInited = false
local C_DailyReward = 8
local isNeedFetchData = false
local _InitRedPointData = function()
  local RedDotMacro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    desc = RedDotMacro.SystemName.ReturnActivity,
    pages = {
      newCount = 0,
      discountReward = {
        newCount = 0,
        subID = Enum_SubID.discountReward,
        instanceId = {_isLeaf = true},
        category = RedDotMacro.Category.Receive
      },
      interactReward = {
        newCount = 0,
        subID = Enum_SubID.interactReward,
        instanceId = {_isLeaf = true},
        category = RedDotMacro.Category.Receive
      },
      dailySignInReward = {
        newCount = 0,
        subID = Enum_SubID.dailySignInReward,
        instanceId = {_isLeaf = true},
        category = RedDotMacro.Category.Receive
      },
      dailyTask = {
        newCount = 0,
        subID = Enum_SubID.dailyTask,
        instanceId = {_isLeaf = true},
        category = RedDotMacro.Category.Receive
      },
      privilege = {
        newCount = 0,
        battleReward = {
          newCount = 0,
          subID = Enum_SubID.battleReward,
          instanceId = {_isLeaf = true},
          category = RedDotMacro.Category.Receive
        },
        rankReward = {
          newCount = 0,
          subID = Enum_SubID.rankReward,
          instanceId = {_isLeaf = true},
          category = RedDotMacro.Category.Receive
        }
      },
      newPost = {
        newCount = 0,
        firstEnter = {
          newCount = 0,
          subID = Enum_SubID.newPostFirstEnter,
          instanceId = {_isLeaf = true},
          category = RedDotMacro.Category.Other
        },
        teachReward = {
          newCount = 0,
          subID = Enum_SubID.teachReward,
          instanceId = {_isLeaf = true},
          category = RedDotMacro.Category.Receive
        },
        newReward = {
          newCount = 0,
          subID = Enum_SubID.newPostReward,
          instanceId = {_isLeaf = true},
          category = RedDotMacro.Category.Receive
        }
      }
    }
  }
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  redpointData = super_data.CreateSuperData(data)
  reddot_manager:Regist(redpointData)
  linkList = {
    pages = {
      redpointData,
      redpointData.pages
    },
    dailySignInReward = {
      redpointData,
      redpointData.pages,
      redpointData.pages.dailySignInReward
    },
    dailyTask = {
      redpointData,
      redpointData.pages,
      redpointData.pages.dailyTask
    },
    privilege = {
      redpointData,
      redpointData.pages,
      redpointData.pages.privilege
    },
    newPost = {
      redpointData,
      redpointData.pages,
      redpointData.pages.newPost
    },
    interactReward = {
      redpointData,
      redpointData.pages,
      redpointData.pages.interactReward
    },
    discountReward = {
      redpointData,
      redpointData.pages,
      redpointData.pages.discountReward
    }
  }
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_BIND_REDPOINT)
  ReturnRedpointData.RefreshDailyTaskReward()
  ReturnRedpointData.RefreshNewArrivalsFirstEnterRed()
  ReturnRedpointData.RefreshInteractReward()
  ReturnRedpointData.RefreshPlayerReturnRed()
  ReturnRedpointData.RefreshDiscountReward()
end
function ReturnRedpointData.CheckModuleInit(nodeName)
  if isInitArr[nodeName] == nil or isInitArr[nodeName] == Status.Init then
    return true
  end
  return false
end
function ReturnRedpointData.CheckModuleTemp(nodeName)
  if isInitArr[nodeName] == Status.Temp then
    return true
  end
  return false
end
function ReturnRedpointData.CheckModuleAbandon(nodeName)
  if isInitArr[nodeName] == Status.Abandon then
    return true
  end
  return false
end
function ReturnRedpointData.SetModuleStatus(nodeName, redStatus)
  isInitArr[nodeName] = redStatus
end
function ReturnRedpointData.RevertTempModule(nodeName)
  if ReturnRedpointData.CheckModuleTemp(nodeName) then
    ReturnRedpointData.SetCount(nodeName, 0)
    ReturnRedpointData.SetModuleStatus(nodeName, Status.Abandon)
  end
end
function ReturnRedpointData.CheckRevertPages()
  if ReturnRedpointData.CheckModuleAbandon(Enum_RedPointName.dailySignInReward) and ReturnRedpointData.CheckModuleAbandon(Enum_RedPointName.privilege) and ReturnRedpointData.CheckModuleAbandon(Enum_RedPointName.newPost) then
    ReturnRedpointData.RevertTempModule("pages")
  end
end
function ReturnRedpointData.RefreshPlayerReturnRed()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local newCount = 0
  if logic_player_return.IsLobbyEntranceRed() then
    newCount = 1
    if isInited and redpointData then
      local RedDotMacro = require("client.slua.logic.reddot.reddot_macro")
      redpointData.pages.category = RedDotMacro.Category.Receive
    end
  end
  if ReturnRedpointData.CheckModuleInit("pages") == true or newCount == 0 and redpointData and 0 < redpointData.pages.newCount or 0 < newCount and redpointData and redpointData.pages.newCount == 0 then
    ReturnRedpointData.SetCount("pages", newCount)
    ReturnRedpointData.SetModuleStatus("pages", Status.Temp)
  end
end
function ReturnRedpointData.SetCount(key, value)
  local oldCount = countTbl[key] or 0
  local newCount = value
  for _, v in ipairs(linkList[key]) do
    v.newCount = v.newCount - oldCount
    v.newCount = v.newCount + newCount
  end
  countTbl[key] = newCount
end
function ReturnRedpointData.RefreshDiscountReward()
  if not DataMgr.roleData.back_user_data then
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if not logic_player_return.pay_back_info then
    return
  end
  local redData = ReturnRedpointData.GetDiscountRewardRedData()
  if not redData then
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.discountReward
  local bRedDot = false
  for _, data in pairs(logic_player_return.pay_back_info or {}) do
    if data.status == return_activity_macro.Enum_DiscountRewardStatus.Receive then
      bRedDot = true
      break
    end
  end
  if bRedDot then
    redData.instanceId[baseIndex + 1] = true
  else
    redData.instanceId[baseIndex + 1] = nil
  end
end
function ReturnRedpointData.RefreshInteractReward()
  if not DataMgr.roleData.back_user_data or not DataMgr.roleData.back_user_data.friend_record_data then
    return
  end
  local redData = ReturnRedpointData.GetInteractRewardRedData()
  if not redData then
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.interactReward
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local friendList = logic_return_activity:GetInteractFriendList() or {}
  local bRedDot = false
  local TableUtil = require("common.table_util")
  local rewardCount = TableUtil.CountTable(DataMgr.roleData.back_user_data.friend_record_data.got_indexs)
  if rewardCount < DataMgr.roleData.back_user_data.friend_record_cfg.reward_limit then
    for _, data in ipairs(friendList) do
      local interactData = data.interactData
      if interactData then
        local isCanGet = (interactData.recent_play_date or 0) > DataMgr.roleData.back_user_data.rejoin_start_time
        if isCanGet and not DataMgr.roleData.back_user_data.friend_record_data.got_indexs[data.uid] then
          bRedDot = true
          break
        end
      end
    end
  end
  if bRedDot then
    redData.instanceId[baseIndex + 1] = true
  else
    redData.instanceId[baseIndex + 1] = nil
  end
end
function ReturnRedpointData.RefreshDailyReward()
  local redData = ReturnRedpointData.GetDailyRewardRedData()
  if not redData then
    return
  end
  ReturnRedpointData.RevertTempModule(Enum_RedPointName.dailySignInReward)
  ReturnRedpointData.CheckRevertPages()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local TableUtil = require("common.table_util")
  local curDay = TableUtil.GetTableValue(logic_player_return.login_reward_info, "cur_day") or 0
  local gotIndexList = TableUtil.GetTableValue(logic_player_return.login_reward_info, "got_indexs") or {}
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.dailySignInReward
  for i = 1, C_DailyReward do
    if i <= curDay and not gotIndexList[i] then
      redData.instanceId[baseIndex + i] = true
    else
      redData.instanceId[baseIndex + i] = nil
    end
  end
end
function ReturnRedpointData.RefreshDailyTaskReward()
  local redData = ReturnRedpointData.GetDailyTaskRewardRedData()
  if not redData then
    return
  end
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local taskList = logic_longline_task.GetDayTaskListData()
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.dailyTask
  for taskIndex, v in pairs(taskList) do
    if v.status == logic_longline_task.E_Reward_State.CanGet then
      redData.instanceId[baseIndex + taskIndex] = true
    else
      redData.instanceId[baseIndex + taskIndex] = nil
    end
  end
  local bHasReward = logic_longline_task.isHaveLevelOrTaskReward()
  if bHasReward then
    log(bWriteLog and "ReturnRedpointData.RefreshDailyTaskReward bHasReward == true")
    redData.newCount = 1
  else
    log(bWriteLog and "ReturnRedpointData.RefreshDailyTaskReward bHasReward == false")
    redData.newCount = 0
  end
end
function ReturnRedpointData.RefreshPrivilegeReward()
  local redData = ReturnRedpointData.GetPrivilegeRedData()
  if not redData then
    return
  end
  ReturnRedpointData.RevertTempModule(Enum_RedPointName.privilege)
  ReturnRedpointData.CheckRevertPages()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.RankGoal) then
    ReturnRedpointData.RefreshRankReward()
    ReturnRedpointData.ClearBattleRedData()
  else
    ReturnRedpointData.ClearRankReward()
    if logic_return_activity_utils.IsGameRewardOpen() then
      ReturnRedpointData.RefreshBattleReward()
    else
      ReturnRedpointData.ClearBattleRedData()
    end
  end
end
function ReturnRedpointData.RefreshRankReward()
  local redData = ReturnRedpointData.GetRankRewardRedData()
  if not redData then
    return
  end
  local logic_player_return_rank = require("client.slua.logic.player_return.logic_player_return_rank")
  local awardInfo = logic_player_return_rank.PlayerInfo.AwardInfo
  if not awardInfo then
    ReturnRedpointData.ClearRankReward()
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local base = return_activity_macro.Enum_RedTypeDefaultIndex.rankReward
  for index, singleAwardInfo in ipairs(awardInfo) do
    if singleAwardInfo.AwardStatus == logic_player_return_rank.CONST.AWARD_STATUS_CAN_GET then
      redData.instanceId[index + base] = true
    else
      redData.instanceId[index + base] = nil
    end
  end
end
function ReturnRedpointData.ClearRankReward()
  local redData = ReturnRedpointData.GetRankRewardRedData()
  if not redData then
    return
  end
  for k, _ in pairs(redData.instanceId) do
    redData.instanceId[k] = false
  end
end
function ReturnRedpointData.RefreshBattleReward()
  local redData = ReturnRedpointData.GetBattleRewardRedData()
  if not redData then
    return
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local taskList = logic_return_activity_utils.GetPlayGameTaskList()
  if not taskList or #taskList <= 0 then
    ReturnRedpointData.ClearBattleRedData()
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local privilegeInfo = logic_player_return.privilege_info
  local TableUtil = require("common.table_util")
  local curProgress = TableUtil.GetTableValue(privilegeInfo, "progress", "progress") or 0
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local base = return_activity_macro.Enum_RedTypeDefaultIndex.battleReward
  for i = 1, #taskList do
    local taskInfo = taskList[i]
    local isGot = TableUtil.GetTableValue(privilegeInfo, "progress", "got_indexs", taskInfo.counts)
    local index = taskInfo.counts
    if curProgress >= taskInfo.counts and not isGot then
      redData.instanceId[base + index] = true
    else
      redData.instanceId[base + index] = nil
    end
  end
end
function ReturnRedpointData.ClearBattleRedData()
  local redData = ReturnRedpointData.GetBattleRewardRedData()
  if not redData then
    return
  end
  for k, _ in pairs(redData.instanceId) do
    redData.instanceId[k] = false
  end
end
function ReturnRedpointData.RefreshNewPostRed()
  local redData = ReturnRedpointData.GetNewPostRedData()
  if not redData then
    return
  end
  ReturnRedpointData.RevertTempModule(Enum_RedPointName.newPost)
  ReturnRedpointData.CheckRevertPages()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Teach) then
    ReturnRedpointData.RefreshTeachRewardRed()
  else
    ReturnRedpointData.ClearTeachRewardRedData()
  end
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Newpost) then
    ReturnRedpointData.RefreshNewArrivalsReward()
  else
    ReturnRedpointData.ClearNewArrivalsRewardRedData()
  end
end
function ReturnRedpointData.RefreshTeachRewardRed()
  local redData = ReturnRedpointData.GetTeachRewardRedData()
  if not redData then
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local teachInfo = logic_player_return.TeachInfo
  if not teachInfo or next(teachInfo) == nil then
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.teachReward
  if teachInfo.reward_status and teachInfo.reward_status == 1 then
    redData.instanceId[baseIndex + 1] = true
  else
    redData.instanceId[baseIndex + 1] = nil
  end
end
function ReturnRedpointData.ClearTeachRewardRedData()
  local redData = ReturnRedpointData.GetTeachRewardRedData()
  if not redData then
    return
  end
  for k, _ in pairs(redData.instanceId) do
    redData.instanceId[k] = false
  end
end
function ReturnRedpointData.RefreshNewArrivalsReward()
  local redData = ReturnRedpointData.GetNewArrivalsRewardRedData()
  if not redData then
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local newPostInfo = logic_player_return.new_post_info
  if not newPostInfo or next(newPostInfo) == nil then
    return
  end
  local hasReward = false
  for _, itemData in ipairs(newPostInfo) do
    if itemData.task_info and itemData.task_info.status and itemData.task_info.status == 1 then
      hasReward = true
      break
    end
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.newPostReward
  if hasReward then
    redData.instanceId[baseIndex + 1] = true
  else
    redData.instanceId[baseIndex + 1] = nil
  end
end
function ReturnRedpointData.ClearNewArrivalsRewardRedData()
  local redData = ReturnRedpointData.GetNewArrivalsRewardRedData()
  if not redData then
    return
  end
  for k, _ in pairs(redData.instanceId) do
    redData.instanceId[k] = false
  end
end
function ReturnRedpointData.RefreshNewArrivalsFirstEnterRed()
  local redData = ReturnRedpointData.GetNewArrivalsFirstEnterRedData()
  if not redData then
    return
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  if not logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Newpost) and not logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Teach) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityNewPostEnter)
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.newPostFirstEnter
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  if not (saveData and saveData.isEnter) or not logic_return_activity:IsReturnTimeOK(saveData) then
    redData.instanceId[baseIndex + 1] = true
  else
    redData.instanceId[baseIndex + 1] = nil
  end
end
function ReturnRedpointData.ClearNewArrivalsFirstEnterRedData()
  local redData = ReturnRedpointData.GetNewArrivalsFirstEnterRedData()
  if not redData then
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local baseIndex = return_activity_macro.Enum_RedTypeDefaultIndex.newPostFirstEnter
  redData.instanceId[baseIndex + 1] = nil
end
function ReturnRedpointData.Init()
  if isInited then
    return
  end
  isInited = true
  _InitRedPointData()
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_REDDOT, ReturnRedpointData.OnRefreshInteractReward, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_BUY_UC_CHANGE, ReturnRedpointData.OnRefreshDiscountReward, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_LOGIN_REWARD, ReturnRedpointData.OnRefreshLoginReward, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_REFRESH_REDDOT_INFO, ReturnRedpointData.OnLonglineRedChange, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_PRIVILEGE_CHANGE, ReturnRedpointData.OnPrivilegeChange, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_RANK_CHANGE, ReturnRedpointData.OnPrivilegeChange, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_NEW_POST, ReturnRedpointData.OnRefreshNewPost, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_TEACH_CHANGE, ReturnRedpointData.OnRefreshNewPost, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, ReturnRedpointData.OnNextDay, ReturnRedpointData)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, ReturnRedpointData.OnPostSwitchGameStatus)
  EventSystem:registEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_TASK_REDPOINT, ReturnRedpointData.RefreshPlayerReturnRed, ReturnRedpointData)
end
function ReturnRedpointData.DestroyData()
  isNeedFetchData = false
  redpointData = nil
  isInited = false
  isInitArr = {}
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_REDDOT, ReturnRedpointData.OnRefreshInteractReward)
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_LOGIN_REWARD, ReturnRedpointData.OnRefreshLoginReward)
  EventSystem:unregistEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_REFRESH_REDDOT_INFO, ReturnRedpointData.OnLonglineRedChange)
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_PRIVILEGE_CHANGE, ReturnRedpointData.OnPrivilegeChange)
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_RANK_CHANGE, ReturnRedpointData.OnPrivilegeChange)
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_NEW_POST, ReturnRedpointData.OnRefreshNewPost)
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_TEACH_CHANGE, ReturnRedpointData.OnRefreshNewPost)
  EventSystem:unregistEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, ReturnRedpointData.OnNextDay)
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, ReturnRedpointData.OnPostSwitchGameStatus)
  EventSystem:unregistEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_UPDATE_TASK_REDPOINT, ReturnRedpointData.RefreshPlayerReturnRed)
end
function ReturnRedpointData.OnRefreshDiscountReward()
  ReturnRedpointData.RefreshDiscountReward()
  ReturnRedpointData.RefreshPlayerReturnRed()
end
function ReturnRedpointData.OnRefreshInteractReward()
  ReturnRedpointData.RefreshInteractReward()
  ReturnRedpointData.RefreshPlayerReturnRed()
end
function ReturnRedpointData.OnPrivilegeChange()
  ReturnRedpointData.RefreshPrivilegeReward()
  ReturnRedpointData.RefreshPlayerReturnRed()
end
function ReturnRedpointData.OnRefreshLoginReward()
  ReturnRedpointData.RefreshDailyReward()
  ReturnRedpointData.RefreshPlayerReturnRed()
end
function ReturnRedpointData.OnRefreshNewPost()
  ReturnRedpointData.RefreshNewPostRed()
  ReturnRedpointData.RefreshPlayerReturnRed()
end
function ReturnRedpointData.OnNextDay()
  log(bWriteLog and "[v_wllwu] ReturnRedpointData.OnNextDay")
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "[v_wllwu] ReturnRedpointData.OnNextDay cache when in fight")
    isNeedFetchData = true
    return
  end
  ReturnRedpointData.FetchAllData()
end
function ReturnRedpointData.FetchAllData()
  log(bWriteLog and "[v_wllwu] ReturnRedpointData.FetchAllData")
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:FetchAllMessage()
end
function ReturnRedpointData.OnLonglineRedChange()
  ReturnRedpointData.RefreshDailyTaskReward()
  ReturnRedpointData.RefreshPlayerReturnRed()
end
function ReturnRedpointData.OnLogin()
  log(bWriteLog and "[v_wllwu] ReturnRedpointData OnLogin")
  ReturnRedpointData.Init()
end
function ReturnRedpointData.OnLogout()
  log(bWriteLog and "[v_wllwu] ReturnRedpointData OnLogout")
  ReturnRedpointData.DestroyData()
end
function ReturnRedpointData.OnPostSwitchGameStatus(_, __, curGameStatus)
  log(bWriteLog and "[v_wllwu] ReturnRedpointData OnPostSwitchGameStatus")
  if GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if not isNeedFetchData then
    return
  end
  isNeedFetchData = false
  ReturnRedpointData.FetchAllData()
end
function ReturnRedpointData.GetData()
  ReturnRedpointData.Init()
  return redpointData
end
function ReturnRedpointData.GetPagesRedData()
  ReturnRedpointData.Init()
  return redpointData.pages
end
function ReturnRedpointData.GetInteractRewardRedData()
  ReturnRedpointData.Init()
  return redpointData.pages.interactReward
end
function ReturnRedpointData.GetDiscountRewardRedData()
  ReturnRedpointData.Init()
  return redpointData.pages.discountReward
end
function ReturnRedpointData.GetDailyRewardRedData()
  ReturnRedpointData.Init()
  return redpointData.pages.dailySignInReward
end
function ReturnRedpointData.GetDailyTaskRewardRedData()
  ReturnRedpointData.Init()
  return redpointData.pages.dailyTask
end
function ReturnRedpointData.GetPrivilegeRedData()
  ReturnRedpointData.Init()
  return redpointData.pages.privilege
end
function ReturnRedpointData.GetRankRewardRedData()
  local redData = ReturnRedpointData.GetPrivilegeRedData()
  return redData and redData.rankReward
end
function ReturnRedpointData.GetBattleRewardRedData()
  local redData = ReturnRedpointData.GetPrivilegeRedData()
  return redData and redData.battleReward
end
function ReturnRedpointData.GetNewPostRedData()
  ReturnRedpointData.Init()
  return redpointData.pages.newPost
end
function ReturnRedpointData.GetTeachRewardRedData()
  local redData = ReturnRedpointData.GetNewPostRedData()
  return redData and redData.teachReward
end
function ReturnRedpointData.GetNewArrivalsRewardRedData()
  local redData = ReturnRedpointData.GetNewPostRedData()
  return redData and redData.newReward
end
function ReturnRedpointData.GetNewArrivalsFirstEnterRedData()
  local redData = ReturnRedpointData.GetNewPostRedData()
  return redData and redData.firstEnter
end
function ReturnRedpointData.GetRedDataByNodeName(nodeName)
  local redData = ReturnRedpointData.GetPagesRedData()
  return redData and redData[nodeName]
end
function ReturnRedpointData.OutputTestLog()
  if redpointData == nil then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] ReturnRedpointData.OutputTestLog redpointData ===== >>>>>>> ", redpointData)
  log_error(bWriteLog and "[v_wllwu] ReturnRedpointData.OutputTestLog redpoint count === >>>> " .. redpointData.newCount)
end
return ReturnRedpointData