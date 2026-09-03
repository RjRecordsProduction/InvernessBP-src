local UDeathPlaybackUtils = import("DeathPlaybackUtils")
local UIInterface = require("client.ingame.death_replay.death_replay_ui_interface")
function _ENV:death_replay_lua_interface_RegisterUI()
  InGameUIManager.SubUIWidgetList(self, {
    {
      Path = "/Game/BluePrints/ControlInput/ResultsshareUI/DeathPlaybackNew_UIBP.DeathPlaybackNew_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
  log(bWriteLog and "death_replay_lua_interface_RegisterUI")
end
DeathReplayLuaInterface = DeathReplayLuaInterface or {
  CameraInst = nil,
  DelayPlayTimer = nil,
  CameraShotTimer = nil,
  FastForwardFinished = false,
  CacheReceivedBattleResult = false,
  CacheKillOrPutDownMessage = nil,
  LockCameraMode = false,
  RestoreCameraMode = nil,
  SettingMark = true,
  SettingOBBullet = true
}
local GetDeathPlayBackUIRoot = function()
  local UIUtil = require("client.common.ui_util")
  local UIRoot = UIUtil.GetWidgetByName("death_replay_lua_interface", "DeathPlaybackNew_UIBP")
  return UIRoot
end
local HasReceivedBattleResult = function()
  if NetUtil.BBattleResultRecieved then
    if BP_STRUCT_BattleResultData.IsSolo then
      return true
    end
    return BP_STRUCT_BattleResultData.is_team_result
  end
  return false
end
function DeathReplayLuaInterface:GetDeathReplayInstance()
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) and GameInstance.GetDeathPlayback ~= nil then
    return GameInstance:GetDeathPlayback()
  end
  return nil
end
function DeathReplayLuaInterface:ClearTimer()
  print(bWriteLog and "----DeathReplayLuaInterface:ClearTimer----")
  if DeathReplayLuaInterface.DelayPlayTimer ~= nil then
    Game:ClearTimer(DeathReplayLuaInterface.DelayPlayTimer)
    DeathReplayLuaInterface.DelayPlayTimer = nil
  end
  if DeathReplayLuaInterface.CameraShotTimer ~= nil then
    Game:ClearTimer(DeathReplayLuaInterface.CameraShotTimer)
    DeathReplayLuaInterface.CameraShotTimer = nil
  end
end
function DeathReplayLuaInterface:BeginCameraShow(IsBegin)
  log(bWriteLog and "----DeathReplayLuaInterface:BeginCameraShow:" .. tostring(IsBegin))
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(uPlayerController) and slua.isValid(DeathReplayInstance) then
    local EPlayerCameraMode = import("EPlayerCameraMode")
    DeathReplayLuaInterface:PausePlay(IsBegin)
    DeathReplayInstance:SetCanChangeViewTarget(not IsBegin)
    local ViewCharacter = DeathReplayInstance:GetViewCharacter()
    if IsBegin then
      DeathReplayLuaInterface.LockCameraMode = false
      log(bWriteLog and "----DeathReplayLuaInterface:BeginCameraShow SwitchCameraMode PCM_Normal")
      uPlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_Normal, ViewCharacter, false, true)
      DeathReplayLuaInterface.LockCameraMode = true
    else
      DeathReplayLuaInterface.LockCameraMode = false
      log(bWriteLog and "----DeathReplayLuaInterface:SwitchCameraMode RestoreMode:" .. tostring(DeathReplayLuaInterface.RestoreCameraMode))
      if DeathReplayLuaInterface.RestoreCameraMode ~= nil and DeathReplayLuaInterface.RestoreCameraMode ~= EPlayerCameraMode.PCM_Normal then
        uPlayerController:SwitchCameraMode(DeathReplayLuaInterface.RestoreCameraMode, ViewCharacter, false, true)
      end
    end
    if uPlayerController.GetTargetedSpringArm then
      local uSpringArm = uPlayerController:GetTargetedSpringArm()
      if slua.isValid(uSpringArm) and uPlayerController.CurCameraMode ~= EPlayerCameraMode.PCM_FPP then
        log(bWriteLog and "----DeathReplayLuaInterface:UsePawnControlRotation:" .. tostring(IsBegin))
        uSpringArm.bUsePawnControlRotation = not IsBegin
      end
    end
  end
end
function DeathReplayLuaInterface:Init()
  log(bWriteLog and "----DeathReplayLuaInterface:Init")
  if death_replay_lua_interface ~= nil then
    InGameUIManager.HandleDynamicCreation(death_replay_lua_interface)
    DeathReplayLuaInterface:Show()
    local EGameReplayType = import("EGameReplayType")
    EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_REPLAYUI, EGameReplayType.EGameReplayType_DeathPlayback)
  end
end
function DeathReplayLuaInterface:Show()
  log(bWriteLog and "----DeathReplayLuaInterface:Show----")
  if death_replay_lua_interface ~= nil then
    InGameUIManager.HandleUIMessage(death_replay_lua_interface, "Deathplayback_ShowUI")
  end
  UIInterface.OnShow(GetDeathPlayBackUIRoot())
end
function DeathReplayLuaInterface:Hide()
  log(bWriteLog and "----DeathReplayLuaInterface:Hide----")
  if death_replay_lua_interface ~= nil then
    InGameUIManager.HandleUIMessage(death_replay_lua_interface, "Deathplayback_HideUI")
  end
  UIInterface.OnHide()
end
function DeathReplayLuaInterface:UISetting_Weapon()
  if death_replay_lua_interface ~= nil then
    InGameUIManager.HandleUIMessage(death_replay_lua_interface, "UISetting_Weapon")
  end
end
function DeathReplayLuaInterface:UISetting_Bullet()
  if death_replay_lua_interface ~= nil then
    InGameUIManager.HandleUIMessage(death_replay_lua_interface, "UISetting_Bullet")
  end
end
function DeathReplayLuaInterface:PausePlay(Pause)
  printf("----DeathReplayLuaInterface:PausePlay----[%s]", tostring(Pause))
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) and DeathReplayInstance:HaveRecordingData_New() then
    DeathReplayInstance:PauseReplay(Pause)
    UIInterface.OnPausePlay(Pause)
  end
end
function DeathReplayLuaInterface:PlayReplayInTeam()
  log(bWriteLog and "----DeathReplayLuaInterface:PlayReplayInTeam----")
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) and DeathReplayInstance:HaveRecordingData_New() then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      DeathReplayInstance:PlayReplayMemory()
    end
  end
end
function DeathReplayLuaInterface:OnClientObserveCharacterNotify()
  log(bWriteLog and "----DeathReplayLuaInterface:OnClientObserveCharacterNotify----")
  Game:SetTimer(0.5, false, function()
    local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
    if slua.isValid(DeathReplayInstance) and DeathReplayInstance:HaveRecordingData_New() then
      DeathReplayInstance:PlayReplayMemory()
    end
  end)
end
function DeathReplayLuaInterface:OnDeathEvent()
  log(bWriteLog and "----DeathReplayLuaInterface:OnDeathEvent----")
  UIInterface.HideTargetMark()
end
function DeathReplayLuaInterface:OnKillOrPutDownMessageEvent()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.KillOrPutDownMessageData ~= nil then
    local uPawn = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPawn) then
      local PlayerName = uPawn:GetPlayerNameSafety()
      local KillOrPutDownMessage = uPlayerController.KillOrPutDownMessageData
      if PlayerName == KillOrPutDownMessage.VictimPlayerName then
        log(bWriteLog and string.format("----DeathReplayLuaInterface:OnKillOrPutDownMessageEvent, PlayerName:[%s]", PlayerName))
        DeathReplayLuaInterface.Cache      end
    end
  end
end
function DeathReplayLuaInterface:PlayReplay()
  log(bWriteLog and "----DeathReplayLuaInterface:PlayReplay----")
  DeathReplayLuaInterface.FastForwardFinished = false
  DeathReplayLuaInterface.CacheReceivedBattleResult = HasReceivedBattleResult()
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) then
    WatchGameUI:HideSpectatingUI()
  end
end
function DeathReplayLuaInterface:StopPlay()
  log(bWriteLog and "----DeathReplayLuaInterface:StopPlay----")
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) then
  end
end
function DeathReplayLuaInterface:StartRecordingReplay()
  log(bWriteLog and "----DeathReplayLuaInterface:StartRecordingReplay----")
end
function DeathReplayLuaInterface:StopRecordingReplay()
  log(bWriteLog and "----DeathReplayLuaInterface:StopRecordingReplay----")
end
function DeathReplayLuaInterface:OnPreLoadMap()
  log(bWriteLog and "----DeathReplayLuaInterface:OnPreLoadMap----")
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) and DeathReplayInstance.LevelPrefixOverride == 0 then
    log(bWriteLog and "----DeathReplayLuaInterface:ResetPlaybackData----")
    DeathReplayInstance:ResetPlaybackData()
    DeathReplayInstance.IsNewDeathReplay = false
    DeathReplayLuaInterface:ClearTimer()
    DeathReplayLuaInterface.CacheReceivedBattleResult = false
    DeathReplayLuaInterface.FastForwardFinished = false
    DeathReplayLuaInterface.CacheKillOrPutDownMessage = nil
    DeathReplayLuaInterface.LockCameraMode = false
    DeathReplayLuaInterface.RestoreCameraMode = nil
  end
end
function DeathReplayLuaInterface:OnPostLoadMap()
  log(bWriteLog and "----DeathReplayLuaInterface:OnPostLoadMap----")
end
function DeathReplayLuaInterface:OnFastForwardFinished()
  log(bWriteLog and "----DeathReplayLuaInterface:OnFastForwardFinished----")
end
function DeathReplayLuaInterface:PlayCameraAnim()
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if not (slua.isValid(DeathReplayInstance) and DeathReplayInstance:HaveRecordingData_New()) or not DeathReplayInstance:IsInPlayState() then
    log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim return----")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim uPlayerController is not valid ")
    return
  end
  local bViewVehicle = false
  local ViewCharacter = DeathReplayInstance:GetViewCharacter()
  if not slua.isValid(ViewCharacter) then
    log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim ViewCharacter is not valid ")
    return
  end
  local uViewTarget = ViewCharacter:GetCurrentVehicle() or ViewCharacter
  if not slua.isValid(uViewTarget) then
    log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim uViewTarget is not valid ")
    return
  end
  if uViewTarget == ViewCharacter:GetCurrentVehicle() then
    bViewVehicle = true
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim uWorld is not valid ")
    return
  end
  if not slua.isValid(DeathReplayInstance.DeathPlayCameraShot) then
    local uDeathPlayCameraShot = slua.loadClass("/Game/BluePrints/Core/DeathReplay/BP_DeathPlayCameraShot.BP_DeathPlayCameraShot")
    if uDeathPlayCameraShot == nil then
      log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim loadClass DeathPlayCameraShot is not valid ")
      return
    end
    DeathReplayInstance.DeathPlayCameraShot = uWorld:SpawnActor(uDeathPlayCameraShot, nil, nil, nil)
    if not slua.isValid(DeathReplayInstance.DeathPlayCameraShot) then
      log(bWriteLog and "----DeathReplayLuaInterface:PlayCameraAnim spawn actor failed")
      return
    end
  end
  uPlayerController.bPauseUpdateStreamingState = true
  DeathReplayInstance.DeathPlayCameraShot:StartCameraShot(uPlayerController)
  DeathReplayInstance.DeathPlayCameraShot:K2_SetActorLocationAndRotation(uViewTarget:K2_GetActorLocation(), uViewTarget:K2_GetActorRotation(), false, nil, true)
  if bViewVehicle then
    local EAttachmentRule = import("EAttachmentRule")
    if uViewTarget.GetMesh and slua.isValid(uViewTarget:GetMesh()) and uViewTarget:GetMesh().GetAllSocketNames then
      local VehicleSockName = "EnterDriverSocket"
      local Names = uViewTarget:GetMesh():GetAllSocketNames()
      for _, Name in pairs(Names) do
        if Name == "EnterDriverSocketForReplay" then
          VehicleSock          break
        end
      end
      DeathReplayInstance.DeathPlayCameraShot:K2_AttachToComponent(uViewTarget:GetMesh(), VehicleSockName, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.KeepWorld, false)
      DeathReplayInstance.DeathPlayCameraShot:K2_AddActorLocalOffset(FVector(100, 0, 50), false, nil, true)
      uViewTarget:SetSimulatePhysics(false)
    else
      DeathReplayInstance.DeathPlayCameraShot:K2_SetActorLocationAndRotation(ViewCharacter:K2_GetActorLocation(), ViewCharacter:K2_GetActorRotation(), false, nil, true)
      DeathReplayInstance.DeathPlayCameraShot:K2_AddActorLocalOffset(FVector(100, 50, -50), false, nil, true)
    end
  end
  local CameraShotDuration = 6.0
  local UDeathPlaybackUtilsInst = UDeathPlaybackUtils:GetInstance()
  if slua.isValid(UDeathPlaybackUtilsInst) then
    CameraShotDuration = UDeathPlaybackUtilsInst.CameraShotDuration
  end
  CameraShotDuration = CameraShotDuration - 0.25
  log(bWriteLog and string.format("----DeathReplayLuaInterface:PlayCameraAnim Wait Seconds:[%.1f]", CameraShotDuration))
  DeathReplayLuaInterface.CameraShotTimer = Game:SetTimer(CameraShotDuration, false, function()
    local uController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uController) then
      uController.bPauseUpdateStreamingState = false
      DeathReplayLuaInterface.CameraShotTimer = nil
      DeathReplayLuaInterface:OnCameraShotFinished()
      if bViewVehicle and uViewTarget then
        uViewTarget:SetSimulatePhysics(true)
      end
    end
  end)
end
function DeathReplayLuaInterface:StopCameraAnim()
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if not slua.isValid(DeathReplayInstance) then
    log(bWriteLog and "----DeathReplayLuaInterface:StopCameraAnim return----")
    return
  end
  if not slua.isValid(DeathReplayInstance.DeathPlayCameraShot) then
    log(bWriteLog and "----DeathReplayLuaInterface:StopCameraAnim DeathPlayCameraShot is not valid")
    return
  end
  DeathReplayInstance.DeathPlayCameraShot:StopCameraShot()
end
function DeathReplayLuaInterface:AfterAllLevelLoaded()
  print(bWriteLog and "----DeathReplayLuaInterface:AfterAllLevelLoaded----")
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if not (slua.isValid(DeathReplayInstance) and DeathReplayInstance:HaveRecordingData_New()) or not DeathReplayInstance:IsInPlayState() then
    print(bWriteLog and "----DeathReplayLuaInterface:AfterAllLevelLoaded return----")
    return
  end
  DeathReplayLuaInterface:Init()
  DeathReplayInstance:SetMurderInfo()
  local ViewCharacter = DeathReplayInstance:GetViewCharacter()
  if not slua.isValid(ViewCharacter) then
    print(bWriteLog and "----DeathReplayLuaInterface:AfterAllLevelLoaded no ViewCharacter return----")
    return
  end
  local CameraManager = DeathReplayInstance:GetPlayerCameraManager()
  print(bWriteLog and "----DeathReplayLuaInterface:AfterAllLevelLoaded", ViewCharacter, CameraManager)
  if slua.isValid(CameraManager) then
    DeathReplayLuaInterface:ClearTimer()
    ViewCharacter.bIsHideCrossHairType = true
    UIInterface.MaskEnable(true)
    UIInterface.ShowLeft(DeathReplayInstance)
    DeathReplayLuaInterface.LockCameraMode = true
    DeathReplayLuaInterface.RestoreCameraMode = nil
    local EPlayerCameraMode = import("EPlayerCameraMode")
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController.OnSwitchCameraModeStart:Add(function(CameraMode)
        printf("----DeathReplayLuaInterface:AfterAllLevelLoaded OnSwitchCameraModeStart LockCameraMode[%s]", tostring(DeathReplayLuaInterface.LockCameraMode))
        if DeathReplayLuaInterface.LockCameraMode then
          DeathReplayLuaInterface.Restore          printf("----DeathReplayLuaInterface:AfterAllLevelLoaded RestoreCameraMode[%d]", CameraMode)
          if CameraMode ~= EPlayerCameraMode.PCM_Normal and slua.isValid(ViewCharacter) then
            DeathReplayLuaInterface.LockCameraMode = false
            uPlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_Normal, ViewCharacter, false, true)
            DeathReplayLuaInterface.LockCameraMode = true
          end
        end
      end)
    end
    print(bWriteLog and "----DeathReplayLuaInterface.DelayPlayTimer----")
    DeathReplayLuaInterface.DelayPlayTimer = Game:SetTimer(0.1, false, function()
      print(bWriteLog and "----DeathReplayLuaInterface.DelayPlayTimer Begin----")
      DeathReplayLuaInterface.DelayPlayTimer = nil
      DeathReplayLuaInterface:BeginCameraShow(true)
      UIInterface.MaskFade(true)
      DeathReplayLuaInterface:PlayCameraAnim()
      log(bWriteLog and "----DeathReplayLuaInterface.DelayPlayTimer End----")
    end)
    print(bWriteLog and "----DeathReplayLuaInterface:AfterAllLevelLoaded Finished----")
  end
end
function DeathReplayLuaInterface:OnPlaybackEnded()
  log(bWriteLog and "----DeathReplayLuaInterface:OnPlaybackEnded----")
  DeathReplayLuaInterface:ClearTimer()
  EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_DEATH_REPLAY_PLAYBACK_ENDED)
end
function DeathReplayLuaInterface:RestoreSettings()
  log(bWriteLog and "----DeathReplayLuaInterface:RestoreSettings----")
  UIInterface.RestoreSettings()
end
function DeathReplayLuaInterface:OnCameraShotFinished()
  log(bWriteLog and "----DeathReplayLuaInterface:OnCameraShotFinished----")
  local DeathReplayInstance = DeathReplayLuaInterface:GetDeathReplayInstance()
  if slua.isValid(DeathReplayInstance) and DeathReplayInstance:HaveRecordingData_New() and DeathReplayInstance:IsInPlayState() then
    DeathReplayLuaInterface:PausePlay(false)
    DeathReplayLuaInterface:StopCameraAnim()
    DeathReplayLuaInterface:BeginCameraShow(false)
    local ViewCharacter = DeathReplayInstance:GetViewCharacter()
    if slua.isValid(ViewCharacter) then
      ViewCharacter.bIsHideCrossHairType = false
    end
    UIInterface.MaskFade(true, 0.5)
    UIInterface.ShowRight(DeathReplayInstance, DeathReplayLuaInterface.SettingMark, DeathReplayLuaInterface.SettingOBBullet)
    DeathReplayLuaInterface:PausePlay(false)
  end
end
function DeathReplayLuaInterface:IsFatalDamageDetailPanelVisible()
  return UIInterface.IsFatalDamageDetailPanelVisible()
end
function DeathReplayLuaInterface:ToggleFatalDamageDetailPanel(bIsShow)
  UIInterface.ToggleFatalDamageDetailPanel(bIsShow)
end
function DeathReplayLuaInterface:ForceHideFatalDamageDetailPanel(bIsForceHide)
  UIInterface.ForceHideFatalDamageDetailPanel(bIsForceHide)
end
function DeathReplayLuaInterface:ReturnToLobby()
  log(bWriteLog and "----DeathReplayLuaInterface:ReturnToLobby----")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true)
  Client.ReturnToLobby(GameFrontendHUD)
end
function DeathReplayLuaInterface:OnReEnterGame(ip, port, key, packet_key, sub_mode, game_id, ad_conf, waterType, waterUserID)
end
function DeathReplayLuaInterface:OnReceiveGameResult()
end
function DeathReplayLuaInterface:OnEventResultToSpectateEnterSpectating()
  return false
end