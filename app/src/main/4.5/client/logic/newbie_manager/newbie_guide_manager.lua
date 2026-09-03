local NewbieGuideManager = {isFirstLogin = nil, disableInEditorSwitch = true}
NewbieGuideManager.NewbieRoleState = {
  Init = 1,
  UpdateRole = 2,
  NormalRole = 3
}
function NewbieGuideManager.Start(enterLobby)
  NewbieGuideManager.end
function NewbieGuideManager.CheckUseNewGuide()
  if NewbieGuideManager.CheckNewGuideSwitch() and NewbieGuideManager.is_first_login then
    return true
  end
  return false
end
function NewbieGuideManager.CheckNewGuideSwitch()
  return LobbySystem.CheckNewGuideSwitch()
end
function NewbieGuideManager.SetIsFirstLogin(isFirstLogin)
  NewbieGuideManager.end
function NewbieGuideManager.IsInit()
  return NewbieGuideManager.isFirstLogin == NewbieGuideManager.NewbieRoleState.Init
end
function NewbieGuideManager.IsUpdateRole()
  return NewbieGuideManager.isFirstLogin == NewbieGuideManager.NewbieRoleState.UpdateRole
end
function NewbieGuideManager.IsNormalRole()
  return NewbieGuideManager.isFirstLogin == NewbieGuideManager.NewbieRoleState.NormalRole
end
function NewbieGuideManager.DirectStartMatch()
  log(bWriteLog and "NewbieGuideManager.DirectStartMatch")
  local zoneSystem = require("client.slua.logic.teamup.logic_zone")
  if zoneSystem.autoChooseZoneFinished then
    NewbieGuideManager.DirectStartMatchImpl()
  else
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, 5, EVENTTYPE_TEAMUP, EVENTID_AUTO_CHOOSE_ZONE_END)
      NewbieGuideManager.DirectStartMatchImpl()
    end)
  end
end
function NewbieGuideManager.DirectStartMatchImpl()
  log(bWriteLog and "NewbieGuideManager.DirectStartMatchImpl")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.nSelectMatchID == 0 then
    MatchModeMgrSystem.nSelectMatchID = MatchModeMgrSystem.GetDefaultMatchID()
  end
  local autoFill = 0
  if Client.IsShipping() then
    autoFill = MatchModeMgrSystem.bAutoMatch and 1 or 0
  end
  log(bWriteLog and "NewbieGuideManager.DirectStartMatchImpl NewGuide start matching ...matching mode = " .. tostring(MatchModeMgrSystem.nSelectMatchID) .. " fill = " .. tostring(autoFill))
  local arrayMapId = MatchModeMgrSystem.CheckDataBeforeMatch(MatchModeMgrSystem.nSelectMatchID)
  log_tree("NewbieGuideManager.DirectStartMatchImpl arrayMapId =", arrayMapId)
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  log(bWriteLog and "NewbieGuideManager.DirectStartMatchImpl nSelectMatchID " .. tostring(MatchModeMgrSystem.nSelectMatchID))
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_on_match_req(MatchModeMgrSystem.nSelectMatchID, autoFill, arrayMapId, DeviceOSInfo.InfoList)
  NewbieGuideManager.WaitForMatchSuccess()
end
function NewbieGuideManager.WaitForMatchSuccess()
  local onMatchSuccess
  local time_ticker = require("common.time_ticker")
  local timer = time_ticker.AddTimerOnce(30, function()
    NewbieGuideManager.is_first_login = NewbieGuideManager.NewbieRoleState.UpdateRole
    NewbieGuideManager.EnterLobby()
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, onMatchSuccess)
    log(bWriteLog and "NewbieGuideManager.WaitForMatchSuccess NewGuide on_match_success timeout")
  end)
  function onMatchSuccess()
    log(bWriteLog and "NewbieGuideManager.WaitForMatchSuccess NewGuide on_match_success")
    time_ticker.RemoveTimer(timer)
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, onMatchSuccess)
  end
  EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, onMatchSuccess)
end
function NewbieGuideManager.WaitForMatchMod(roleData)
  local onGetMatchMod
  logic_connection_waiting:Show(1)
  local time_ticker = require("common.time_ticker")
  local timer = time_ticker.AddTimerOnce(5, function()
    logic_connection_waiting:Hide(1)
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, onGetMatchMod)
    NewbieGuideManager.is_first_login = NewbieGuideManager.NewbieRoleState.UpdateRole
    NewbieGuideManager.EnterLobby()
    log(bWriteLog and "============>NewGuide match timeout")
  end)
  function onGetMatchMod()
    log(bWriteLog and "============>NewGuide match mod")
    logic_connection_waiting:Hide(1)
    time_ticker.RemoveTimer(timer)
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, onGetMatchMod)
    if roleData.growup_novice_level then
      local zoneId = roleData.zone_id or 1
      UIManager.ShowUI(UIManager.UI_Config.Common_Welcome_UIBP, zoneId)
    else
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.SetInitPercent(0)
      LoadingSystem.ShowLoading(true)
      NewbieGuideManager.DirectStartMatch()
      NewbieGuideManager.is_first_login = NewbieGuideManager.NewbieRoleState.UpdateRole
    end
  end
  EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, onGetMatchMod)
end
function NewbieGuideManager.EnterLobby()
  if NewbieGuideManager.enterLobby then
    NewbieGuideManager.enterLobby()
  end
end
function NewbieGuideManager.NeedUpdateRole()
  if LobbySystem.CheckUseNewGuide() and LobbySystem.roleData then
    return LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole
  end
  return false
end
function NewbieGuideManager.ShowCreateRole()
  log_format("NewbieGuideManager.ShowCreateRole growup_novice_level = [%s]", LobbySystem.roleData.growup_novice_level)
  if LobbySystem.roleData.growup_novice_level then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local rolewear = {}
    local tRoleWear = AvatarData.GetRoleWear()
    for _, v in pairs(tRoleWear) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo and itemInfo.itemType == 4 then
        table.insert(rolewear, AvatarData.CreateAvatarCustom(itemInfo.resID, itemInfo.colorID, itemInfo.patternID))
      end
    end
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    logicCreateRole.NewbieUpdateAvatar(rolewear)
  else
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    local uiConfig = LogicNewbie.GetWelcomeUIConfig()
    UIManager.ShowUI(uiConfig, true)
  end
end
function NewbieGuideManager.GetDisableInEditor()
  return NewbieGuideManager.disableInEditorSwitch
end
function NewbieGuideManager.ChangeDebugSwitch()
  if Client.IsShipping() then
    log(bWriteLog and "============>NewbieGuideManager ChangeDebugSwitch shipping")
    return
  end
  local data = NewbieGuideManager.GetGlobalData()
  data.skipNewbieGuide = not data.skipNewbieGuide
  log(bWriteLog and "============>NewbieGuideManager ChangeDebugSwitch: " .. tostring(data.skipNewbieGuide))
  NewbieGuideManager.SaveGlobalData()
end
function NewbieGuideManager.GetNewbieDebugSwitch()
  if Client.IsShipping() then
    log(bWriteLog and "============>NewbieGuideManager GetNewbieDebugSwitch shipping")
    return false
  end
  local data = NewbieGuideManager.GetGlobalData()
  log(bWriteLog and "============>NewbieGuideManager GetNewbieDebugSwitch: " .. tostring(data.skipNewbieGuide))
  return data.skipNewbieGuide
end
function NewbieGuideManager.NeedPopModTip()
  if not NewbieGuideManager.NewbieFlagFor200() then
    log(bWriteLog and "============>NewbieGuideManager NeedPopModTip is_newbie_squad false")
    return false
  end
  if not LobbySystem.CheckUseNewGuide() then
    log(bWriteLog and "============>NewbieGuideManager NeedPopModTip isn't new guide")
    return false
  end
  local matchCount = NewbieGuideManager.GetMatchCount()
  if matchCount ~= 1 then
    log(bWriteLog and "============>NewbieGuideManager NeedPopModTip invalid match count: " .. tostring(matchCount))
    if matchCount < 1 then
      local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
      MatchModeMgrSystem.SetAutoFill(false)
      log(bWriteLog and "============>NewbieGuideManager NeedPopModTip set auto fill to false")
    end
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    if growthprojectMgrB.IsFinishAllNewGuide() then
      log(bWriteLog and "============>NewbieGuideManager NeedPopModTip guide finished")
      return false
    end
    return false
  end
  local data = NewbieGuideManager.GetUserData()
  local modTip = data.modTip
  if not modTip or not modTip[tonumber(DataMgr.roleData.uid)] then
    log(bWriteLog and "============>NewbieGuideManager NeedPopModTip true")
    return true
  end
  return false
end
function NewbieGuideManager.ShowModTip(callback)
  NewbieGuideManager.SetModTip()
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Newbie_Guidance_Group, callback)
end
function NewbieGuideManager.SetModTip()
  local data = NewbieGuideManager.GetUserData()
  if not data.modTip then
    data.modTip = {}
  end
  data.modTip[tonumber(DataMgr.roleData.uid)] = true
  NewbieGuideManager.SaveUserData()
end
function NewbieGuideManager.SaveUserData()
  log(bWriteLog and "============>NewbieGuideManager SaveUserData")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = NewbieGuideManager.userData
  if not data then
    log(bWriteLog and "============>NewbieGuideManager SaveUserData invalid data")
    return
  end
  log_tree("============>NewbieGuideManager SaveUserData", data)
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eUserNewbieGuideData)
end
function NewbieGuideManager.GetUserData()
  if not NewbieGuideManager.userData then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUserNewbieGuideData)
    data = data or {}
    NewbieGuideManager.userData = data
  end
  return NewbieGuideManager.userData
end
function NewbieGuideManager.GetGlobalData()
  if not NewbieGuideManager.globalData then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGlobalNewbieGuideManager)
    data = data or {}
    NewbieGuideManager.globalData = data
  end
  return NewbieGuideManager.globalData
end
function NewbieGuideManager.SaveGlobalData()
  log(bWriteLog and "============>NewbieGuideManager SaveGlobalData")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = NewbieGuideManager.globalData
  if not data then
    log(bWriteLog and "============>NewbieGuideManager SaveGlobalData invalid data")
    return
  end
  log_tree("============>NewbieGuideManager SaveGlobalData", data)
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eGlobalNewbieGuideManager)
end
function NewbieGuideManager.GetMatchCount()
  if not NewbieGuideManager.matchCount then
    local newbieAssistantHandler = require("client.network.Protocol.NewbieAssistantHandler")
    if newbieAssistantHandler then
      NewbieGuideManager.matchCount = newbieAssistantHandler.totalMatchCount
    end
  end
  if not NewbieGuideManager.matchCount then
    NewbieGuideManager.matchCount = 0
  end
  return NewbieGuideManager.matchCount
end
function NewbieGuideManager.AddMatchCount(subMode)
  if subMode ~= 24001 and subMode ~= 24002 and subMode ~= 24003 and subMode ~= 24004 then
    NewbieGuideManager.matchCount = NewbieGuideManager.GetMatchCount() + 1
  end
end
function NewbieGuideManager.OnLogout()
  log(bWriteLog and "============>NewbieGuideManager OnLogout")
  NewbieGuideManager.matchCount = nil
  NewbieGuideManager.userData = nil
  NewbieGuideManager.globalData = nil
end
function NewbieGuideManager.NewbieFlagFor200()
  log(bWriteLog and "============>NewbieGuideManager NewbieFlagFor200 is_newbie_squad: " .. tostring(LobbySystem.roleData.is_newbie_squad))
  return LobbySystem.roleData.is_newbie_squad == 1
end
function NewbieGuideManager.ChangeMatchCount(matchCount, afterChangeCB)
  if not NewbieGuideManager.NewbieFlagFor200() then
    log(bWriteLog and "============>ChangeDefaultView NewbieFlagFor200 is false")
    return false
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewDict = logic_mode_selection:GetViewDictionary()
  if not viewDict then
    log(bWriteLog and "============>ChangeDefaultView viewDict is invalid")
    return false
  end
  local defaultID = logic_mode_selection:GetDefaultViewID()
  local viewInfo = viewDict[defaultID]
  if not viewInfo then
    log(bWriteLog and "============>ChangeDefaultView viewInfo is invalid")
    return false
  end
  if not viewInfo.options then
    log(bWriteLog and "============>ChangeDefaultView viewInfo options is invalid")
    return false
  end
  local mods = viewInfo.options.team_type[100054]
  log(bWriteLog and "============>NewbieGuideManager.ChangeMatchCount send change team type: " .. tostring(mods[matchCount]) .. " defaultID: " .. tostring(defaultID))
  TeamupHandler.send_team_change_type_request(mods[matchCount], {
    [1] = defaultID
  })
  local async = require("client.common.async")
  async.Run(function(co)
    async.AwaitEvent(co, 5, EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE)
    log(bWriteLog and "============>NewbieGuideManager.ChangeMatchCount finished")
    if afterChangeCB then
      afterChangeCB()
    end
  end)
  return true
end
return NewbieGuideManager