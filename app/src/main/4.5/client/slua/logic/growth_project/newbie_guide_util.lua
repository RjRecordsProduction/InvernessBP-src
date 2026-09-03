local newbie_guide_util = {mcNewbieActivityTip = nil}
function newbie_guide_util.GetNewbieGuideABTestType()
  log(bWriteLog and "newbie_guide_util.GetNewbieGuideABTestType")
  local newbie_abtest_group = LobbySystem.roleData.newbie_abtest_group
  log(bWriteLog and "newbie_guide_util.GetNewbieGuideABTestType newbie_abtest_group = " .. tostring(newbie_abtest_group))
  return newbie_abtest_group
end
function newbie_guide_util.IsInNewbieABTest()
  local newbie_abtest_group = LobbySystem.roleData.newbie_abtest_group
  local ENewbieABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ENewbieABTestType
  return newbie_abtest_group == ENewbieABTestType.Type_B or newbie_abtest_group == ENewbieABTestType.Type_C
end
function newbie_guide_util.IsInNewbieABTest_TypeC()
  local newbie_abtest_group = LobbySystem.roleData.newbie_abtest_group
  local ENewbieABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ENewbieABTestType
  return newbie_abtest_group == ENewbieABTestType.Type_C
end
function newbie_guide_util.IsNewbieAndIsInNewbieABTest()
  local NewbieTaskSystem = require("client.slua.logic.activity.newbie.logic_newbie_task")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_new_abtest:CheckUseNewNewbieLogic() and not NewbieTaskSystem.IsNewbie() then
    log(bWriteLog and "newbie_guide_util.IsNewbieAndIsInNewbieABTest NewbieTaskSystem.IsNewbie return false")
    return false
  end
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  if not logic_newbie_assist.CheckIsNewBie() then
    log(bWriteLog and "newbie_guide_util.IsNewbieAndIsInNewbieABTest logic_newbie_assist.CheckIsNewBie return false")
    return false
  end
  return newbie_guide_util.IsInNewbieABTest()
end
function newbie_guide_util.IsNewbieChatChannelABTest()
  local bIsNew = DataMgr.IsRecruit()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  local bIsMentor = MentorSystem.IsMentor()
  local newbie_abtest_group = LobbySystem.roleData.newbie_abtest_group
  local ENewbieABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ENewbieABTestType
  local isA = newbie_abtest_group == ENewbieABTestType.Type_B or newbie_abtest_group == ENewbieABTestType.Type_C
  local version_util = require("client.common.version_util")
  local bClientVersion = version_util.GetCurVersionNumber() >= 4200
  log_format(bWriteLog and "newbie_guide_util.IsNewbieChatChannelABTest bIsNew = %s, bIsMentor = %s, isA = %s, bClientVersion = %s", bIsNew, bIsMentor, isA, bClientVersion)
  if bClientVersion == false then
    return false
  end
  return bIsNew and isA or bIsMentor
end
function newbie_guide_util.CanFreeTalkInNewbieChatChannelABTest()
  local bIsNew = DataMgr.IsRecruit()
  log_format(bWriteLog and "newbie_guide_util.CanFreeTalkInNewbieChatChannelABTest bIsNew = %s", bIsNew)
  return bIsNew
end
function newbie_guide_util.ForceSetNewbieABTestGroup(group)
  if not Client.IsDevelopment() then
    return
  end
  LobbySystem.roleData.newbie_abtest_  local MailHandler = require("client.network.Protocol.MailHandler")
  local cmd = string.format("gm_newbie_abt_stat(%d)", group)
  MailHandler.send_exec(cmd)
end
function newbie_guide_util.UpdateMCNewbieActivityTip()
  local isABTestTypeC = newbie_guide_util.IsInNewbieABTest_TypeC()
  local useNewGuide = LobbySystem.CheckUseNewGuide()
  local version_util = require("client.common.version_util")
  local version = version_util.GetClientFormat(Client.GetAppVersion())
  local isOver410Version = version_util.CompareVersionStandard(version, "4.1.0") >= 0
  local entryParam = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_abtest_entry_core")
  local isEntryOpen = entryParam and tonumber(entryParam.Value) == 1
  newbie_guide_util.mcNewbieActivityTip = isABTestTypeC and useNewGuide and isOver410Version and isEntryOpen
  log(bWriteLog and "newbie_guide_util.UpdateMCNewbieActivityTip mcNewbieActivityTip = " .. tostring(newbie_guide_util.mcNewbieActivityTip))
end
function newbie_guide_util.GetMCNewbieActivityTip()
  return newbie_guide_util.mcNewbieActivityTip
end
function newbie_guide_util.CloseMCNewbieActivityTip()
  newbie_guide_util.mcNewbieActivityTip = false
end
function newbie_guide_util.EnterSceneByABTestGroup()
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local UIUtil = require("client.common.ui_util")
  local isEnterToLobby = false
  if newbieGuideManager.GetDisableInEditor() and _G.isEditor then
    log(bWriteLog and "newbie_guide_util.EnterSceneByABTestGroup isEditor")
    isEnterToLobby = true
  end
  newbie_guide_util.UpdateMCNewbieActivityTip()
  local mcNewbieActivityTip = newbie_guide_util.GetMCNewbieActivityTip()
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  local isDownLoadMainCity = Main_City_Download_Tool.IsMainCityMapDownloaded()
  if not mcNewbieActivityTip or not isDownLoadMainCity then
    log_format("newbie_guide_util.EnterSceneByABTestGroup not ABTest, mcNewbieActivityTip = %s, isDownLoadMainCity = %s", mcNewbieActivityTip, isDownLoadMainCity)
    isEnterToLobby = true
  end
  local hasCreateRole = true
  if LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.Init or LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole then
    log(bWriteLog and "newbie_guide_util.EnterSceneByABTestGroup is_first_login is Init or UpdateRole")
    isEnterToLobby = true
    hasCreateRole = false
  end
  if isEnterToLobby then
    UIUtil.ShowLobbyUI(true)
  end
  if hasCreateRole and mcNewbieActivityTip then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    Lobby_Main_City_Enter.EnterMainCity()
  end
end
function newbie_guide_util.GetJapanKoreaNewbieABTestGroup()
  local groupID = LobbySystem.roleData.newbie_guide_gamestart_abtest_id
  log(bWriteLog and "newbie_guide_util.GetJapanKoreaNewbieABTestGroup newbie_guide_gamestart_abtest_id = " .. tostring(groupID))
  return groupID
end
function newbie_guide_util.IsInJapanKoreaNewbieABTest()
  local newbie_japan_abtest_group = newbie_guide_util.GetJapanKoreaNewbieABTestGroup()
  local EJKNewbieABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").EJKNewbieABTestType
  return newbie_japan_abtest_group and newbie_japan_abtest_group == EJKNewbieABTestType.Type_B
end
function newbie_guide_util.GetNewbieRemainingTime()
  local nRegisterTime = DataMgr.registertime or 0
  if nRegisterTime == 0 then
    return 0
  end
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  log_format(bWriteLog and "newbie_guide_util.GetNewbieRemainingTime nRegisterTime = %s, nCurTime = %s", nRegisterTime, nCurTime)
  local totalTime = 1209599
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  return totalTime - (nCurTime - nRegisterTime)
end
function newbie_guide_util.CheckCanUseCreateRoleClothes()
  if not LobbySystem.CheckUseNewGuide() then
    log_warning(bWriteLog and "newbie_guide_util:CheckCanUseCreateRoleClothes not use new guide")
    return false
  end
  if not LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole then
    log_warning(bWriteLog and "newbie_guide_util:CheckCanUseCreateRoleClothes not UpdateRole")
    return false
  end
  local currentGroup = newbie_guide_util.GetNewbieGuideABTestType()
  local config = CDataTable.GetTableData("NewbieTaskOtherConfig", "newbie_abtest_create_role_groups")
  local value = config and config.Value or ""
  local StringUtil = require("common.string_util")
  value = StringUtil.StrReplace(value, "\"", "")
  local groups = StringUtil.SplitToNum(value, "|")
  local isIn = false
  for i, v in ipairs(groups) do
    if v == currentGroup then
      isIn = true
      break
    end
  end
  if not isIn then
    log_warning(bWriteLog and "newbie_guide_util:CheckCanUseCreateRoleClothes not target group. currentGroup = " .. tostring(currentGroup))
    return false
  end
  return true
end
function newbie_guide_util.IsNewbie(nUID)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(nUID)
  if profile == nil then
    log(bWriteLog and "newbie_guide_util.IsNewbie profile is nil")
    return false
  end
  return newbie_guide_util.IsNewbieByRegisterTime(profile.registertime)
end
function newbie_guide_util.IsNewbieByRegisterTime(registerTime)
  local nRegisterTime = registerTime or 0
  local TimeUtil = require("client.common.time_util")
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if 1209599 < nCurTime - nRegisterTime then
    return false
  end
  return true
end
function newbie_guide_util.GetNewbieForceRankABTestGroup()
  local groupID = DataMgr.roleData.newbie_match_guide_flag
  log(bWriteLog and "newbie_guide_util.GetNewbieForceRankABTestGroup newbie_match_guide_flag = " .. tostring(groupID))
  return groupID
end
function newbie_guide_util.IsInNewbieForceRankABTest()
  local abtest_group = newbie_guide_util.GetNewbieForceRankABTestGroup()
  local ENewbieForceRankABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ENewbieForceRankABTestType
  return abtest_group and abtest_group == ENewbieForceRankABTestType.Type_B
end
return newbie_guide_util