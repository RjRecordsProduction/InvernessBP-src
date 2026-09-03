local LobbyLogicOB = {
  urlList = {},
  PlayFrom = -1,
  KillInfoRecordData = {}
}
local E_PlayerType = {
  None = -1,
  ReplayMode = 1,
  OnLive = 2
}
LobbyLogicOB.local luaCfg = {
  [E_PlayerType.ReplayMode] = UIManager.UI_Config.Lobby_OB_ReplayListMode_UIBP,
  [E_PlayerType.OnLive] = UIManager.UI_Config.Lobby_OB_ReplayList_UIBP
}
LobbyLogicOB.local lobbySpanPlayerData = {
  gid = "",
  sex = 1,
  headId = 401999,
  index = 0,
  avatarList = {
    resID = 401999,
    colorID = 0,
    patternID = 0
  },
  weaponId = 0,
  weaponSkinId = 0
}
function LobbyLogicOB.CreateMyself()
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:UpdateInvalidWearInfo(nil)
  local rolewear = AvatarData.GetWearInfo()
  local avatarSt = {
    gamegender = AvatarData.GetGameGender(),
    headid = AvatarData.GetHeadID(),
    hairid = AvatarData.GetHairID()
  }
  lobbySpanPlayerData = {
    gid = tostring(DataMgr.roleData.uid or 0),
    sex = avatarSt.gamegender or 1,
    headId = avatarSt.headid or 401999,
    index = 1,
    BP_ARRAY_AvatarList = rolewear or {},
    weaponId = DataMgr.GetCurrentWeaponID() or 0,
    weaponSkinId = 0
  }
  if not LobbySystem.CheckOpen(BP_ENUM_WARDROBE_UI_WEAPON) then
    lobbySpanPlayerData.weaponId = 0
  end
  lobbySpanPlayerData.sex = lobbySpanPlayerData.sex - 1
  table.insert(lobbySpanPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(avatarSt.hairid))
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.SpawnPlayer(lobbySpanPlayerData, false, true)
  LobbyAvatarManager.SpawnPlayer(lobbySpanPlayerData, true)
end
function LobbyLogicOB.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    if not GetWindowOBState() then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Lobby_OB_UIBP)
    if DataMgrInit then
      local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
      LobbyThemeManager:SwitchLobbySkin(LobbyThemeManager:GetDefaultLobbySkin())
    end
  end
  if (nextState == GameStatus.Fighting or nextState == GameStatus.Login) and UIManager.GetUI(UIManager.UI_Config.Lobby_OB_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Lobby_OB_UIBP)
  end
end
function LobbyLogicOB.GetPwdByRoomCarId(cardId)
  if not LobbyLogicOB.belong_warzone then
    return false
  end
  if LobbyLogicOB.belong_warzone[0] then
    return true
  end
  if LobbyLogicOB.belong_warzone[cardId] then
    return true
  end
  return false
end
function LobbyLogicOB.CheckReplayAuthority(id)
  return true
end
function LobbyLogicOB.CheckAllReplayAuthority()
  return true
end
function LobbyLogicOB.GetCurrentReplayTotalTimeInSeconds()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    local seconds = gameReplay:GetCurrentReplayTotalTimeInSeconds()
    return seconds
  end
  return 0
end
function LobbyLogicOB.SetCurrentReplayTimeToSeconds(seconds)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    gameReplay:SetCurrentReplayTimeToSeconds(seconds)
  end
end
function LobbyLogicOB.GetCurrentReplayCurTimeInSeconds()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    local seconds = gameReplay:GetCurrentReplayCurTimeInSeconds()
    return seconds
  end
  return 0
end
function LobbyLogicOB.PauseReplay(bPaused)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    gameReplay:PauseReplay(bPaused)
  end
end
function LobbyLogicOB.SetReplayTimeDilation(floatSpeed)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    gameReplay:SetReplayTimeDilation(floatSpeed)
  end
end
function LobbyLogicOB.GetSpectatorName()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  local playerName
  if slua.isValid(gameReplay) then
    playerName = gameReplay:GetSpectatorName()
  end
  return playerName
end
function LobbyLogicOB.GetKillInfoData()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    gameReplay:ClearStreams()
    LobbyLogicOB.ConstructKillInfoData(gameReplay.RecordKillInfoDataArray)
  else
    log(bWriteLog and "[YY]killinfo  is nil")
  end
  return LobbyLogicOB.KillInfoRecordData
end
function LobbyLogicOB.SetKillInfoData()
  LobbyLogicOB.KillInfoRecordData = {}
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  if slua.isValid(gameReplay) then
    gameReplay:ClearStreams()
    gameReplay.OnKillInfoDownloadComplete:Add(function(killinfo)
      LobbyLogicOB.ConstructKillInfoData(killinfo)
    end)
  else
    log(bWriteLog and "[YY]killinfo  is nil")
  end
end
function LobbyLogicOB.ConstructKillInfoData(killInfo)
  if not killInfo then
    return
  end
  local info = {}
  for k, v in pairs(killInfo) do
    if type(k) == "number" then
      info = {
        Killer = v.Killer or "None",
        Victim = v.Victim or "None",
        bKillDown = v.bKillDown,
        KillTimeStampDemoTime = v.KillTimeStampDemoTime or 0,
        KillTimeStampGameTime = v.KillTimeStampGameTime or 0
      }
      table.insert(LobbyLogicOB.KillInfoRecordData, info)
    end
  end
end
function LobbyLogicOB.FormatSize(InSize)
  if 1024 <= InSize then
    local KB = InSize / 1024
    if 1024 <= KB then
      local MB = KB / 1024
      if 1024 <= MB then
        return string.format("%.0f G", MB / 1024)
      else
        return string.format("%.0f M", MB)
      end
    else
      return string.format("%.0f K", KB)
    end
  else
    return string.format("%.0f B", InSize)
  end
end
function LobbyLogicOB.Format_MSToSecond(minute, seconds)
  local minuteTemp = tonumber(minute) or 0
  local secondsTemp = tonumber(seconds) or 0
  return minuteTemp * 60 + secondsTemp
end
function LobbyLogicOB.GetReplayURLs()
  log(bWriteLog and "LobbyLogicOB.GetReplayURLs")
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_get_replay_downstream_urls_req()
end
function LobbyLogicOB.get_replay_downstream_urls_rsp(list)
  LobbyLogicOB.urlList = list
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTTYPE_LOBBY_REPLAY_URL_RSP)
end
function LobbyLogicOB.GetAnchor_White_Cfg_Notify(belong_warzone, _)
  LobbyLogicOB.end
return LobbyLogicOB