local friend_interact_tool = {}
function friend_interact_tool.GetStatisLog()
  log(bWriteLog and "friend_interact_tool.statisLog")
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local resInteractData = logic_friend_interact_record.resInteractData
  if not resInteractData then
    return ""
  end
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  local statisLogList = {}
  local maxVal_1 = 0
  local maxUid_1 = 0
  local totalNum_1 = 0
  local maxVal_2 = 0
  local maxUid_2 = 0
  local log_ChiJi_num = 0
  local log_JieYuan_num = 0
  local log_RiseInitmacy_num = 0
  local log_TeamupNum_num = 0
  local log_MaxTime_num = 0
  for uid, v in pairs(resInteractData) do
    local val_1 = v.last_week_inc_teamup_wins
    if val_1 and maxVal_1 < val_1 then
      maxVal_1 = val_1
      maxUid_1 = uid
    end
    local val_2 = v.last_week_inc_teamup_num
    if val_2 and 0 < val_2 then
      totalNum_1 = totalNum_1 + 1
    end
    local val_3 = v.last_week_inc_rescued_me_num or 0
    local val_4 = v.last_week_inc_rescued_other_num or 0
    if (0 < val_3 or 0 < val_4) and log_JieYuan_num < 3 then
      friend_interact_tool.Log_JieYuan(statisLogList, uid, val_3, val_4)
      log_JieYuan_num = log_JieYuan_num + 1
    end
    local val_5 = v.last_week_inc_teamup_game_time
    if val_5 and maxVal_2 < val_5 then
      maxVal_2 = val_5
      maxUid_2 = uid
    end
    local riseInitmacy = logic_friend_list:GetLastWeekRiseIntimacy(uid)
    if 0 < riseInitmacy and log_RiseInitmacy_num < 3 then
      friend_interact_tool.Log_RiseInitmacy(statisLogList, uid, riseInitmacy)
      log_RiseInitmacy_num = log_RiseInitmacy_num + 1
    end
  end
  if maxUid_1 ~= 0 and log_ChiJi_num < 3 then
    friend_interact_tool.Log_ChiJi(statisLogList, maxUid_1, maxVal_1)
    log_ChiJi_num = log_ChiJi_num + 1
  end
  if 0 < totalNum_1 and log_TeamupNum_num < 3 then
    friend_interact_tool.Log_TeamupNum(statisLogList, totalNum_1)
    log_TeamupNum_num = log_TeamupNum_num + 1
  end
  if maxUid_2 ~= 0 and log_MaxTime_num < 3 then
    friend_interact_tool.Log_MaxTime(statisLogList, maxUid_2, maxVal_2)
    log_MaxTime_num = log_MaxTime_num + 1
  end
  local statisLog = ""
  if 0 < #statisLogList then
    statisLog = statisLogList[1]
  end
  for i = 2, #statisLogList do
    statisLog = statisLog .. "\n" .. statisLogList[i]
  end
  return statisLog
end
function friend_interact_tool.Log_ChiJi(logList, maxUid, maxVal)
  log(bWriteLog and "friend_interact_tool.Log_ChiJi maxUid = " .. maxUid .. ", maxVal = " .. maxVal)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(maxUid)
  if not profile then
    return
  end
  local logStr = LocUtil.LocalizeResFormat(84361, maxUid, profile.nickName, maxVal)
  logStr = string.StrReplace(logStr, "$$", "\"")
  logList[#logList + 1] = logStr
end
function friend_interact_tool.Log_TeamupNum(logList, totalNum)
  log(bWriteLog and "friend_interact_tool.Log_TeamupNum totalNum = " .. totalNum)
  logList[#logList + 1] = LocUtil.LocalizeResFormat(84363, totalNum)
end
function friend_interact_tool.Log_JieYuan(logList, uid, rescued_me_num, rescued_other_num)
  log(bWriteLog and "friend_interact_tool.Log_JieYuan uid = " .. uid .. ", rescued_me_num = " .. rescued_me_num .. ", rescued_other_num = " .. rescued_other_num)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    return
  end
  local logStr = LocUtil.LocalizeResFormat(84364, uid, profile.nickName, rescued_me_num, uid, profile.nickName, rescued_other_num)
  logStr = string.StrReplace(logStr, "$$", "\"")
  logList[#logList + 1] = logStr
end
function friend_interact_tool.Log_MaxTime(logList, maxUid, maxVal)
  log(bWriteLog and "friend_interact_tool.Log_MaxTime maxUid = " .. maxUid .. ", maxVal = " .. maxVal)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(maxUid)
  if not profile then
    return
  end
  local logStr = LocUtil.LocalizeResFormat(84365, maxUid, profile.nickName, math.ceil(maxVal / 60))
  logStr = string.StrReplace(logStr, "$$", "\"")
  logList[#logList + 1] = logStr
end
function friend_interact_tool.Log_RiseInitmacy(logList, uid, riseInitmacy)
  log(bWriteLog and "friend_interact_tool.Log_RiseInitmacy uid = " .. uid .. ", riseInitmacy = " .. riseInitmacy)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    return
  end
  local logStr = LocUtil.LocalizeResFormat(84362, uid, profile.nickName, riseInitmacy)
  logStr = string.StrReplace(logStr, "$$", "\"")
  logList[#logList + 1] = logStr
end
function friend_interact_tool.LoadFile()
  log(bWriteLog and "friend_interact_tool.LoadFile")
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileTb = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.InitmateRelationWeeklySummeryRedDot)
  friend_interact_tool.  log_tree("fileTb 2 = ", fileTb)
  return fileTb
end
function friend_interact_tool.SaveFile(fileTb)
  log(bWriteLog and "friend_interact_tool.SaveFile")
  if fileTb == nil then
    log(bWriteLog and "friend_interact_tool.SaveFile 1")
    return
  end
  friend_interact_tool.  log_tree("fileTb = ", fileTb)
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerprefs.SaveTableToFile_N(friend_interact_tool.fileTb, playerprefs.ePlayerPrefsType.InitmateRelationWeeklySummeryRedDot)
end
return friend_interact_tool