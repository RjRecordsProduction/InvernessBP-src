local logic_newbie_privileges = {LevelAmount = 20}
function logic_newbie_privileges.GetSegmentActivityShowData()
  local segmentProtectionConfig = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_daily_protect_times")
  local segmentAddScoreConfig = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_daily_team_adtnl_times")
  local segmentAddScoreNumConfig = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_daily_team_adtnl_num")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local segmentProtectionTimes, segmentAddScoreTimes = logic_newbie_new_abtest:GetNewbieNewDataPrivilegesData()
  local result = {
    pConfig = segmentProtectionConfig,
    pTimes = segmentProtectionTimes,
    asConfig = segmentAddScoreConfig,
    asTimes = segmentAddScoreTimes,
    asnConfig = segmentAddScoreNumConfig
  }
  return result
end
function logic_newbie_privileges.IsOpen()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    log(bWriteLog and "logic_newbie_privileges.IsOpen return not in ABTest new Group")
    return false
  end
  if DataMgr.roleData.level > logic_newbie_privileges.LevelAmount then
    log(bWriteLog and "logic_newbie_privileges.IsOpen return not in time end")
    return false
  end
  return true
end
function logic_newbie_privileges.UpdateRedDotCount(superData)
  if not superData then
    return
  end
  superData.newCount = 0
  log(bWriteLog and "==============> newbie activity logic_newbie_privileges UpdateRedDotCount: " .. tostring(superData.newCount))
end
function logic_newbie_privileges.HasRedDot()
  log(bWriteLog and "logic_newbie_privileges.HasRedDot")
  return false
end
function logic_newbie_privileges.GetActivitySubData()
  if not logic_newbie_privileges.IsOpen() then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Task,
    sName = LocUtil.GetLocalizeResStr(75498),
    bRedDot = logic_newbie_privileges.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
return logic_newbie_privileges