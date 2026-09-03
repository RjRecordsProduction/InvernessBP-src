local ModeEntrySystem = {
  lobbyEntryData = nil,
  lobbyEntryActor = nil,
  lobbyEntryTimer = nil,
  bIsFirstShowLobbyEntry = nil,
  lobbyEntryGuideActor = nil,
  selectMapEntryData = nil
}
function ModeEntrySystem.OnLogin()
  ModeEntrySystem.lobbyEntryData = nil
  ModeEntrySystem.selectMapEntryData = nil
end
function ModeEntrySystem.Init()
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, ModeEntrySystem.ShowEntry)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, ModeEntrySystem.DestroyEntry)
  EventSystem:registEvent(EVENTTYPE_LUCKAIR, EVENTID_SHOW_POPUP, ModeEntrySystem.DestroyEntry)
end
function ModeEntrySystem.OnModePostSwitch(preState, nextState)
  ModeEntrySystem.DestroyEntry()
  if nextState == GameStatus.Lobby then
    ModeEntrySystem.bIsFirstShowLobbyEntry = nil
    local time_ticker = require("common.time_ticker")
    if ModeEntrySystem.lobbyEntryTimer then
      time_ticker.RemoveTimer(ModeEntrySystem.lobbyEntryTimer)
      ModeEntrySystem.lobbyEntryTimer = nil
    end
    ModeEntrySystem.lobbyEntryTimer = time_ticker.AddTimerOnce(2, ModeEntrySystem.ShowEntry)
  end
end
function ModeEntrySystem.GetLobbyEntryData()
  if not ModeEntrySystem.lobbyEntryData then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local actList = ActivityNewSystem.GetActivityListByType(ActivityType.GAME_URI)
    for k, v in ipairs(actList) do
      if v.ShowSceneID == ActivitySceneID.ModeEntryInLobby then
        ModeEntrySystem.lobbyEntryData = v
        break
      end
    end
  end
  if not ModeEntrySystem.lobbyEntryData then
    ModeEntrySystem.lobbyEntryData = {ImgUrl = ""}
  end
  return ModeEntrySystem.lobbyEntryData
end
function ModeEntrySystem.ShowEntry()
  ModeEntrySystem.DestroyEntry()
  local entryData = ModeEntrySystem.GetLobbyEntryData()
  if not entryData then
    log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry, no lobby entry data")
    return
  end
  if DataMgr.anchor == 1 then
    log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry, ob user")
    return
  end
  if entryData.ImgUrl == "" or entryData.ExParam == "" then
    log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry, lobby entry data is error")
    return
  end
  local adaptLocationList = {}
  local StringUtil = require("common.string_util")
  local adaptLocationStrList = StringUtil.Split(entryData.ExParam, "|")
  for i, v in ipairs(adaptLocationStrList) do
    local posStr = StringUtil.Split(v, ",")
    for ii, vv in ipairs(posStr) do
      posStr[ii] = tonumber(vv)
    end
    table.insert(adaptLocationList, posStr)
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local adapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
  local location = adaptLocationList[1]
  if not location then
    log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry, lobby entry location data is error 1, adapt == " .. adapt)
    return
  end
  if not (location[1] and location[2]) or not location[3] then
    log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry, lobby entry location data is error 2, adapt == " .. adapt)
    return
  end
  local tClass = slua.loadClass(entryData.ImgUrl)
  if not tClass then
    log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry, lobby entry bp path is error")
    return
  end
  log(bWriteLog and "[edward] ModeEntrySystem.ShowEntry")
  local world = slua_GameFrontendHUD:GetWorld()
  ModeEntrySystem.lobbyEntryActor = world:SpawnActor(tClass, FVector(location[1], location[2], location[3]), nil, nil)
  ModeEntrySystem.Show3dUI(ModeEntrySystem.lobbyEntryActor, location)
end
function ModeEntrySystem.Show3dUI(actor, location)
  if not actor then
    return
  end
  log(bWriteLog and "[edward] ModeEntrySystem.Show3dUI")
  local userWidget = actor.Widget:GetUserWidgetObject()
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  local entry = UIComponentModule:InitWithoutParentComponent(UIComponentModule.Config.mode_lobby_entry, userWidget)
  entry:OnShow()
  if ModeEntrySystem.IsFirstShowLobbyEntry() then
    local tClass = import("/Game/UMG/UI_BP/ModLobbyEntry/ModLobbyEntry_3D_UIBP.ModLobbyEntry_3D_UIBP_C")
    if not tClass then
      return
    end
    log(bWriteLog and "[edward] ModeEntrySystem.Show3dUI, show first guide")
    local world = slua_GameFrontendHUD:GetWorld()
    ModeEntrySystem.lobbyEntryGuideActor = world:SpawnActor(tClass, FVector(location[1] + 25, location[2] + 10, location[3] - 80), nil, nil)
  end
end
function ModeEntrySystem.IsFirstShowLobbyEntry()
  local entryData = ModeEntrySystem.GetLobbyEntryData()
  if not entryData then
    return false
  end
  if ModeEntrySystem.bIsFirstShowLobbyEntry ~= nil then
    return ModeEntrySystem.bIsFirstShowLobbyEntry
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local json = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeLobbyEntry)
  if not json then
    ModeEntrySystem.bIsFirstShowLobbyEntry = true
    return true
  end
  local actID = entryData.ID
  if not json[tostring(actID)] then
    ModeEntrySystem.bIsFirstShowLobbyEntry = true
    return true
  end
  ModeEntrySystem.bIsFirstShowLobbyEntry = json[tostring(actID)] ~= 1
  return ModeEntrySystem.bIsFirstShowLobbyEntry
end
function ModeEntrySystem.DestroyEntry()
  if ModeEntrySystem.lobbyEntryActor and slua.isValid(ModeEntrySystem.lobbyEntryActor) then
    ModeEntrySystem.lobbyEntryActor:K2_DestroyActor()
  end
  ModeEntrySystem.lobbyEntryActor = nil
  if ModeEntrySystem.lobbyEntryGuideActor and slua.isValid(ModeEntrySystem.lobbyEntryGuideActor) then
    ModeEntrySystem.lobbyEntryGuideActor:K2_DestroyActor()
  end
  ModeEntrySystem.lobbyEntryGuideActor = nil
end
function ModeEntrySystem.CheckFirstClick()
  if ModeEntrySystem.lobbyEntryGuideActor and slua.isValid(ModeEntrySystem.lobbyEntryGuideActor) then
    ModeEntrySystem.lobbyEntryGuideActor:K2_DestroyActor()
    ModeEntrySystem.lobbyEntryGuideActor = nil
  end
  local entryData = ModeEntrySystem.GetLobbyEntryData()
  if not entryData then
    return
  end
  if ModeEntrySystem.bIsFirstShowLobbyEntry == nil then
    return
  end
  if ModeEntrySystem.bIsFirstShowLobbyEntry then
    ModeEntrySystem.bIsFirstShowLobbyEntry = false
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local json = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeLobbyEntry)
    json = json or {}
    json[tostring(entryData.ID)] = 1
    PlayerPrefsSystem.SaveTableToFile_N(json, PlayerPrefsSystem.ePlayerPrefsType.eModeLobbyEntry)
  end
end
function ModeEntrySystem.GetSelectMapEntryData()
  if not ModeEntrySystem.selectMapEntryData then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local actList = ActivityNewSystem.GetActivityListByType(ActivityType.GAME_URI)
    for k, v in ipairs(actList) do
      if v.ShowSceneID == ActivitySceneID.ModeEntryInSelectMap then
        ModeEntrySystem.selectMapEntryData = v
        break
      end
    end
  end
  return ModeEntrySystem.selectMapEntryData
end
return ModeEntrySystem