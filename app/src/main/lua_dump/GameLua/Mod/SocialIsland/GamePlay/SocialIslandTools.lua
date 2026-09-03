local SocialIslandTools = {}
function SocialIslandTools.GetLandID(PlayerKey)
  local playerContol
  if Client then
    playerContol = slua_GameFrontendHUD:GetPlayerController()
  else
    playerContol = Game:GetPlayerControllerByPlayerKey(tonumber(PlayerKey))
  end
  if not slua.isValid(playerContol) then
    print(bWriteLog and "SocialIslandTools.GetLandID no playerContol PlayerKey = " .. PlayerKey)
    return
  end
  local PlayerState = playerContol.PlayerState
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "SocialIslandTools.GetLandID no PlayerState PlayerKey = " .. PlayerKey)
    return
  end
  return PlayerState.LandId
end
function SocialIslandTools.GetLandIDByLocation(position)
  print(bWriteLog and "SocialIslandTools.GetLandIDByLocation position = " .. position:ToString())
  return 1
end
function SocialIslandTools.GetGameState(context)
  local gameState
  if Client then
    gameState = slua_GameFrontendHUD:GetGameState()
  else
    local GameplayStatics = import("GameplayStatics")
    if context then
      gameState = GameplayStatics.GetGameState(context)
    end
  end
  return gameState
end
function SocialIslandTools.GetPlayerControl(uid)
  local playerControl
  if uid == nil then
    if Client then
      playerControl = slua_GameFrontendHUD:GetPlayerController()
    else
      local UGameplayStatics = import("GameplayStatics")
      playerControl = UGameplayStatics.GetPlayerController(CGameState, 0)
    end
  else
    playerControl = Game:GetPlayerControllerByUid(uid)
  end
  return playerControl
end
function SocialIslandTools.GetPlayerChar(uid)
  local playerControl
  if uid == nil then
    playerControl = slua_GameFrontendHUD:GetPlayerController()
  else
    playerControl = SocialIslandTools.GetPlayerControl(uid)
  end
  if not slua.isValid(playerControl) then
    return nil
  end
  if not playerControl.GetPlayerCharacterSafety then
    print(bWriteLog and "SocialIslandTools.GetPlayerChar no GetPlayerCharacterSafety")
    return nil
  end
  return playerControl:GetPlayerCharacterSafety()
end
function SocialIslandTools.GetPlayerState(uid)
  local playerState
  if Client then
    if uid == nil then
      local playerControl = slua_GameFrontendHUD:GetPlayerController()
      playerState = playerControl.PlayerState
    else
      local uGameState = slua_GameFrontendHUD:GetGameState()
      playerState = uGameState:GetPlayerStateByUID(uid)
    end
  else
    local playerControl = Game:GetPlayerControllerByUid(uid)
    if not slua.isValid(playerControl) then
      return nil
    end
    playerState = playerControl.PlayerState
  end
  return playerState
end
function SocialIslandTools.GetTimeSeconds()
  local tNow = 0
  if Client then
    local uGameState = slua_GameFrontendHUD:GetGameState()
    tNow = uGameState:GetServerWorldTimeSeconds()
  else
    tNow = CGameState:GetServerWorldTimeSeconds()
  end
  return tNow
end
function SocialIslandTools.GetTimeNow()
  if IsEditor and CGameMode.ServerStartTime == 0 then
    local now = os.time()
    printf("SocialIslandTools.GetTimeNow now = %s", now)
    return now
  end
  return CGameMode.ServerStartTime + CGameState:GetServerWorldTimeSeconds()
end
function SocialIslandTools.IsPlayerIdleClient()
  local playerState = SocialIslandTools.GetPlayerState()
  if not Game:IsValid(playerState) then
    log(bWriteLog and "[SocialIslandTools] playerState Is Not Available")
    return false
  end
  return playerState.IsPlayerIdle and playerState:IsPlayerIdle()
end
function SocialIslandTools.GetPlayerUIDByPlayerKey(nPlayerKey)
  nPlayerKey = tonumber(nPlayerKey)
  if not nPlayerKey then
    return -1
  end
  local uPlayerController = CGameMode:FindPlayerControllerWithPlayerKey(nPlayerKey, "Normal")
  if not slua.isValid(uPlayerController) then
    return -1
  end
  return uPlayerController.UID
end
function SocialIslandTools.GetMyName()
  local myName = ""
  if IsEditor then
    local uPC = SocialIslandTools.GetPlayerControl()
    myName = uPC.PlayerName
  else
    myName = DataMgr.roleData.nickName or ""
  end
  return myName
end
return SocialIslandTools