local MapMarkLightCrossMgr = {}
local LightCrossClass = "/Game/Mod/EvoBase/BluePrints/Actor/LightCross.LightCross_C"
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local ECollisionChannel = import("ECollisionChannel")
local EStateType = import("EStateType")
local MapMarkConfig = require("GameLua.Mod.BaseMod.Gameplay.Config.MapMarkConfig")
function MapMarkLightCrossMgr:OnInit()
  print(bWriteLog and "MapMarkLightCrossMgr:OnInit")
  self:ResetData()
  self:BindEvents()
  self:EnableLightCrossBecauseInTheSky(true)
end
function MapMarkLightCrossMgr:ReviveInit()
  self.bIsOnThePlane = true
  print(bWriteLog and "MapMarkLightCrossMgr:ReviveInit, self.bIsOnThePlane = " .. tostring(self.bIsOnThePlane))
  self:BindEvents()
  self:ShowLightCrossByMapMark()
  self:EnableLightCrossBecauseInTheSky(true)
end
function MapMarkLightCrossMgr:ShowLightCrossByMapMark()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    if uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() then
      return
    end
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if uPlayerState and slua.isValid(uPlayerState) then
      local TeammatesState = uPlayerState.TeamMatePlayerStateList
      if TeammatesState == nil or TeammatesState:Num() <= 0 then
        print(bWriteLog and "MapMarkLightCrossMgr:ShowLightCrossByMapMark, TeammatesState = nil")
        return
      end
      local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
      for nIndex = 0, TeammatesState:Num() - 1 do
        local uTeammatePlayerState = TeammatesState:Get(nIndex)
        if uTeammatePlayerState and slua.isValid(uTeammatePlayerState) then
          local nTeammateIndex = uTeammatePlayerState.PlayerInTeamIndex
          if self.TeammateColor and self.TeammateColor[nTeammateIndex] then
            local MatePlayerState = uTeammatePlayerState.TeamMatePlayerState
            if slua.isValid(MatePlayerState) and (MatePlayerState == uPlayerState or MatePlayerState.LiveState ~= ExtraPlayerLiveState.InDied) then
              local MapMarkSize = FVector2D(MatePlayerState.MapMark.X, MatePlayerState.MapMark.Y):Size()
              if 0 < MapMarkSize then
                local LightCrossPos = MatePlayerState:GetMapMark3DLocation()
                if not slua.isValid(self.LightCrossActors[nTeammateIndex]) then
                  ActorTools.SpawnActorAsync(uPlayerController, LightCrossClass, LightCrossPos, FRotator(0, 0, 0), FVector(1, 1, 1), function(uActor)
                    if uActor and slua.isValid(uActor) then
                      uActor:SetLightCrossColor(self.TeammateColor[nTeammateIndex])
                      self:DestroyLightCrossActor(nTeammateIndex)
                      self.LightCrossActors[nTeammateIndex] = uActor
                      print(bWriteLog and "MapMarkLightCrossMgr:ShowLightCrossByMapMark, Spawn, nTeammateIndex = " .. tostring(nTeammateIndex))
                    end
                  end)
                else
                  local uLightCross = self.LightCrossActors[nTeammateIndex]
                  if uLightCross and slua.isValid(uLightCross) then
                    self.LightCrossActors[nTeammateIndex]:K2_SetActorLocation(LightCrossPos, false, nil, false)
                    print(bWriteLog and "MapMarkLightCrossMgr:ShowLightCrossByMapMark, Update, nTeammateIndex = " .. tostring(nTeammateIndex))
                  end
                end
              else
                print(bWriteLog and "MapMarkLightCrossMgr:ShowLightCrossByMapMark, MapMarkSize = 0 when nTeammateIndex = " .. tostring(nTeammateIndex))
              end
            end
          else
            print(bWriteLog and "MapMarkLightCrossMgr:ShowLightCrossByMapMark, TeammateColor = nil when nTeammateIndex = " .. tostring(nTeammateIndex))
          end
        end
      end
    end
  end
end
function MapMarkLightCrossMgr:OnRelease()
  self:EnableLightCrossBecauseInTheSky(false)
  self:UnBindEvents()
  MapMarkLightCrossMgr.__super.OnRelease(self)
end
function MapMarkLightCrossMgr:ResetData()
  self.TeammateColor = {}
  self.TeammateColor[0] = {
    R = 1.0,
    G = 1.0,
    B = 0.0,
    A = 1
  }
  self.TeammateColor[1] = {
    R = 1.0,
    G = 0.1,
    B = 0.0,
    A = 1
  }
  self.TeammateColor[2] = {
    R = 0.0,
    G = 0.4,
    B = 1.0,
    A = 1
  }
  self.TeammateColor[3] = {
    R = 0.0,
    G = 1.0,
    B = 0.0,
    A = 1
  }
  self.LightCrossActors = {}
  self.TouchStartTime = 0
  self.TouchBeginPos = FVector(0, 0, 0)
  self.TouchDown = false
  self.LightCrossZ = 1
  self.RemoveTeammateLightAfterExitTime = 5
end
function MapMarkLightCrossMgr:BindEvents()
  if self.HaveBinded == true then
    print(bWriteLog and "MapMarkLightCrossMgr:BindEvents, return because HaveBinded = " .. tostring(self.HaveBinded))
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController == nil or slua.isValid(uPlayerController) == false then
    print(bWriteLog and "MapMarkLightCrossMgr:BindEvents, return because uPlayerController = " .. tostring(uPlayerController))
    return
  end
  if uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() then
    print(bWriteLog and "MapMarkLightCrossMgr:BindEvents, return because IsSpectator")
    return
  end
  print(bWriteLog and "MapMarkLightCrossMgr:BindEvents")
  self.HaveBinded = true
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_REAL_EXIT_GAME, self.OnTeammateRealExitGame, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_DELETE_SELF_MAP_MAKER, self.RemoveSelfLightCross, self)
  self.OldTraceDistance = uPlayerController.HitResultTraceDistance
  self.MapMarkChanageDelegate = uPlayerController.OnMapMarkChangeDelegate:Add(function(nTeammateIndex)
    self:OnMapMarkChange(nTeammateIndex)
  end)
  self.TouchBeginDelegate = uPlayerController.OnPlayerContollerTouchBegin:Add(function(TouchPos)
    print(bWriteLog and "MapMarkLightCrossMgr OnPlayerContollerTouchBegin")
    self:OnTouchBegin(TouchPos)
    self.TouchDown = true
  end)
  self.TouchEndDelegate = uPlayerController.OnPlayerControllerTouchEnd:Add(function(TouchPos)
    if not TouchPos then
      return
    end
    print(bWriteLog and "MapMarkLightCrossMgr OnPlayerControllerTouchEnd", tostring(TouchPos.X), tostring(TouchPos.Y))
    self:OnTouchEnd(TouchPos)
    self.TouchDown = false
  end)
  self.PlayerControllerStateChangedDelegate = uPlayerController.OnPlayerControllerStateChangedDelegate:Add(function(CurStateType)
    print(bWriteLog and "MapMarkLightCrossMgr OnPlayerControllerStateChangedDelegate CurStateType", CurStateType, self)
    if self.bEnableLightCross ~= true then
      print(bWriteLog and "MapMarkLightCrossMgr:OnPlayerControllerStateChangedDelegate, return because self.bEnableLightCross = " .. tostring(self.bEnableLightCross))
      return
    end
    if CurStateType == EStateType.State_ParachuteJump then
      uPlayerController:BindVirtualJoystickInputDelegates(true)
      self.InParachute = true
    elseif CurStateType == EStateType.State_ParachuteOpen then
      self.InParachute = true
      self.LandscapeDetectTimer = self:AddGameTimer(1.5, true, function()
        if slua.isValid(uPlayerController) then
          local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
          if slua.isValid(uPlayerCharacter) then
            local Position = uPlayerCharacter:K2_GetActorLocation()
            local LandscapeHasLoad = CGame:HasLandscapeLevelLoad(Position)
            if LandscapeHasLoad then
              local bUpdateSucceed = self:UpdateAllTeammateLightCrossPosition()
              if bUpdateSucceed and self.LandscapeDetectTimer then
                self:RemoveGameTimer(self.LandscapeDetectTimer)
                self.LandscapeDetectTimer = nil
              end
            end
          end
        end
      end)
    elseif CurStateType == EStateType.State_Fight then
      local uCharacter = uPlayerController:GetPlayerCharacterSafety()
      local EPawnState = import("EPawnState")
      local InEmergencyCall = slua.isValid(uCharacter) and uCharacter:HasState(EPawnState.InActivityActor)
      local InReadyState = false
      if uCharacter and slua.isValid(uCharacter) then
        local UGameplayStatics = import("GameplayStatics")
        local GameState = UGameplayStatics.GetGameState(uCharacter)
        if GameState and slua.isValid(GameState) then
          local GameModeState = GameState:GetGameModeState()
          if GameModeState == "ReadyState" then
            InReadyState = true
          else
            print(bWriteLog and "MapMarkLightCrossMgr:OnPlayerControllerStateChangedDelegate, GameModeState = " .. tostring(GameModeState))
          end
        end
      end
      if not InEmergencyCall and not InReadyState then
        print(bWriteLog and "MapMarkLightCrossMgr EStateType.State_Fight")
        self:EnableLightCrossBecauseInTheSky(false)
      else
        print(bWriteLog and "MapMarkLightCrossMgr:OnPlayerControllerStateChangedDelegate, InEmergencyCall = " .. tostring(InEmergencyCall) .. ", InReadyState = " .. tostring(InReadyState))
      end
    end
  end)
  self:AddControlEvent(uPlayerController, "OnPlayerExitParachute", self.OnPlayerExitParachuteCallback, self)
  if slua.isValid(CGameState) then
    local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
    local DelegateMgrInstance = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
    self.BindCharacterStateChangedDelegate = self:AddControlEvent(DelegateMgrInstance, "OnCharacterStateChangeDelegate", self.OnCharacterStateChange, self)
  end
end
function MapMarkLightCrossMgr:OnTeammateRealExitGame(EventType, EventID, TeammateIndex, LiveState)
  print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, TeammateIndex = " .. tostring(TeammateIndex))
  self:AddGameTimer(self.RemoveTeammateLightAfterExitTime, false, function()
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, In Timer")
    self:DestroyLightCrossActor(TeammateIndex)
  end)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, uPlayerController = " .. tostring(uPlayerController))
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not Game:IsValid(uPlayerState) then
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, uPlayerState = " .. tostring(uPlayerState))
    return
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if not TeammatePlayerStateList then
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, TeammatePlayerStateList = " .. tostring(TeammatePlayerStateList))
    return
  end
  if TeammateIndex >= TeammatePlayerStateList:Num() then
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, TeammateIndex >= TeammatePlayerStateList:Num")
    self:DestroyLightCrossActor(TeammateIndex)
  end
  local TeammateNum = TeammatePlayerStateList:Num()
  for i = 0, TeammateNum - 1 do
    self:DestroyLightCrossActor(i)
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, DestroyLightCrossActor i = " .. i)
  end
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, uGameState = " .. tostring(uGameState))
    return
  end
  local PlayerNumPerTeam = uGameState.PlayerNumPerTeam
  for j = TeammateNum, PlayerNumPerTeam - 1 do
    self:DestroyLightCrossActor(j)
    print(bWriteLog and "MapMarkLightCrossMgr:OnTeammateRealExitGame, DestroyLightCrossActor j = " .. j)
  end
end
function MapMarkLightCrossMgr:OnPlayerExitParachuteCallback()
  print(bWriteLog and "MapMarkLightCrossMgr:OnPlayerExitParachuteCallback")
  self:EnableLightCrossBecauseInTheSky(false)
end
function MapMarkLightCrossMgr:EnableLightCrossBecauseInTheSky(bEnable)
  if bEnable then
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if uGameState == nil or slua.isValid(uGameState) == false then
      print(bWriteLog and "MapMarkLightCrossMgr:EnableLightCrossBecauseInTheSky, return because uGameState = " .. tostring(uGameState))
      return
    end
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if uPlayerController == nil or slua.isValid(uPlayerController) == false then
      print(bWriteLog and "MapMarkLightCrossMgr:EnableLightCrossBecauseInTheSky, return because uPlayerController = " .. tostring(uPlayerController))
      return
    end
    if uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() then
      print(bWriteLog and "MapMarkLightCrossMgr:EnableLightCrossBecauseInTheSky, return because IsSpectator")
      return
    end
    local EStateType = import("EStateType")
    local ControllerState = uPlayerController:GetCurrentStateType()
    local CurrentState = uGameState:GetGameModeState()
    if CurrentState == "ReadyState" or CurrentState == "ActiveState" or CurrentState == "FightingState" and self.bIsOnThePlane == true then
    else
      print(bWriteLog and "MapMarkLightCrossMgr:EnableLightCrossBecauseInTheSky, return because CurrentState = " .. tostring(CurrentState) .. ", bIsOnThePlane = " .. tostring(self.bIsOnThePlane) .. ", ControllerState = " .. tostring(ControllerState))
      return
    end
  end
  self.bEnableLightCross = bEnable
  print(bWriteLog and "MapMarkLightCrossMgr:EnableLightCrossBecauseInTheSky, bEnable = " .. tostring(self.bEnableLightCross))
  if self.bEnableLightCross == false then
    self:RemoveAllLightCross()
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if uPlayerController and slua.isValid(uPlayerController) and uPlayerController.BindVirtualJoystickInputDelegates then
      uPlayerController:BindVirtualJoystickInputDelegates(false)
    end
    if self.InParachute then
      self.InParachute = false
      if self.LandscapeDetectTimer then
        self:RemoveGameTimer(self.LandscapeDetectTimer)
        self.LandscapeDetectTimer = nil
      end
    end
    self:ResetData()
    self.bIsOnThePlane = false
  end
end
function MapMarkLightCrossMgr:OnCharacterStateChange(LiveState, uTargetCharacter)
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if LiveState ~= ExtraPlayerLiveState.InDied or uTargetCharacter == nil or slua.isValid(uTargetCharacter) == false then
    return
  end
  print(bWriteLog and "MapMarkLightCrossMgr:OnCharacterStateChange, PlayerKey = " .. tostring(uTargetCharacter.PlayerKey) .. " died")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:K2_GetPawn()
    if uPlayerCharacter == uTargetCharacter then
      print(bWriteLog and "MapMarkLightCrossMgr self Die")
      self:EnableLightCrossBecauseInTheSky(false)
      return
    end
    if uPlayerController.GetCurPlayerState then
      local uPlayerState = uPlayerController:GetCurPlayerState()
      if uPlayerState and slua.isValid(uPlayerState) then
        local TeammatesState = uPlayerState.TeamMatePlayerStateList
        if TeammatesState == nil or TeammatesState:Num() <= 0 then
          print(bWriteLog and "MapMarkLightCrossMgr:OnCharacterStateChange, TeammatesState = nil")
          return
        end
        for nIndex = 0, TeammatesState:Num() - 1 do
          local uTeammatePlayerState = TeammatesState:Get(nIndex)
          if uTeammatePlayerState and slua.isValid(uTeammatePlayerState) and slua.isValid(uTeammatePlayerState.TeamMatePlayerState) and uTargetCharacter.PlayerKey == uTeammatePlayerState.TeamMatePlayerState.PlayerKey then
            self:DestroyLightCrossActor(uTeammatePlayerState.PlayerInTeamIndex)
            break
          end
        end
      end
    end
  end
end
function MapMarkLightCrossMgr:UpdateAllTeammateLightCrossPosition()
  print(bWriteLog and "MapMarkLightCrossMgr:UpdateAllTeammateLightCrossPosition")
  local bUpdateSucceed = false
  if not self.LightCrossActors then
    return bUpdateSucceed
  end
  for _, LightCross in pairs(self.LightCrossActors) do
    if slua.isValid(LightCross) then
      local Location = LightCross:K2_GetActorLocation()
      Location.Z = Location.Z + 9999
      local GroundPosition = Game:GetGroundLocation(Location, -15000)
      if GroundPosition == Location then
        print(bWriteLog and "MapMarkLightCrossMgr:UpdateAllTeammateLightCrossPosition hit nothing!!!")
      else
        LightCross:K2_SetActorLocation(GroundPosition, false, nil, false)
        bUpdateSucceed = true
      end
      print(bWriteLog and "MapMarkLightCrossMgr:UpdateAllTeammateLightCrossPosition", GroundPosition.X, GroundPosition.Y, GroundPosition.Z)
    end
  end
  return bUpdateSucceed
end
function MapMarkLightCrossMgr:OnTouchBegin(TouchPos)
  if self:CanProcessMapMark() then
    self.TouchBeginPos = TouchPos
    self.TouchStartTime = Game:GetCurTimeMilliseconds()
  else
    print(bWriteLog and "MapMarkLightCrossMgr:OnTouchBegin cant CanProcessMapMark")
  end
end
function MapMarkLightCrossMgr:OnTouchEnd(TouchPos)
  print(bWriteLog and "MapMarkLightCrossMgr:OnTouchEnd")
  if not self:CanProcessMapMark() then
    print(bWriteLog and "MapMarkLightCrossMgr:OnTouchEnd cant CanProcessMapMark")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local XDist = math.abs(TouchPos.X - self.TouchBeginPos.X)
    local YDist = math.abs(TouchPos.Y - self.TouchBeginPos.Y)
    if XDist > MapMarkConfig.MapMarkTouchMaxDistance or YDist > MapMarkConfig.MapMarkTouchMaxDistance then
      return
    end
    local Now = Game:GetCurTimeMilliseconds()
    local ElapsedTime = Now - self.TouchStartTime
    print(bWriteLog and "MapMarkLightCrossMgr:OnTouchEnd elapsed time = ", ElapsedTime)
    if ElapsedTime <= MapMarkConfig.MapMarkTouchElapsedTime then
      self.TouchStartTime = 0
      print(bWriteLog and " MapMarkLightCrossMgr:OnTouchEnd", TouchPos.X, TouchPos.Y)
      uPlayerController.HitResultTraceDistance = 99999999
      uPlayerController:SetMouseLocation(math.ceil(TouchPos.X), math.ceil(TouchPos.Y))
      local uHitResult = import("/Script/Engine.HitResult")()
      local bHit, HitResult = uPlayerController:GetHitResultUnderCursor(ECollisionChannel.ECC_GameTraceChannel9, true, uHitResult)
      if bHit then
        print(bWriteLog and "MapMarkLightCrossMgr hit!!!")
        local nCurPlayerTeamIndex = self:GetCurPlayerTeamIndex()
        local LightCrossPos = FVector(HitResult.Location.X, HitResult.Location.Y, self.LightCrossZ)
        self:UpdateMiniMapMapMarkPos(uPlayerController, LightCrossPos)
        EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "UseMapMark", 1)
      else
        print(bWriteLog and "MapMarkLightCrossMgr not hit!!!", ECollisionChannel.ECC_GameTraceChannel9)
      end
      uPlayerController.HitResultTraceDistance = self.OldTraceDistance
    else
      print(bWriteLog and "error!!!!")
    end
  end
end
function MapMarkLightCrossMgr:UpdateMiniMapMapMarkPos(uPlayerController, Pos)
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) then
      local MapMark2DMiniMap = uPlayerState:ConverMapMarkTo2D(Pos)
      local MarkIconLocation = FVector(MapMark2DMiniMap.X, MapMark2DMiniMap.Y, 0)
      local EntireMapWidget = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
      if EntireMapWidget ~= nil then
        local MapUI = EntireMapWidget:GetEntireMapUIBP()
        if slua.isValid(MapUI) then
          MapUI:MakeMarker(FVector2D(MarkIconLocation.X + 0.5, MarkIconLocation.Y + 0.5))
        end
      end
    end
  end
end
function MapMarkLightCrossMgr:OnMapMarkChange(nTeammateIndex)
  print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange TeammateIndex = ", nTeammateIndex, self)
  self:SetAutoParachuteLocationWhenMapMarkChanged(nTeammateIndex)
  if self.bEnableLightCross ~= true then
    print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange, return because self.bEnableLightCross = " .. tostring(self.bEnableLightCross))
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    if uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() then
      return
    end
    local uPlayerState = uPlayerController:GetCurPlayerState()
    local LightCrossPos = FVector(0, 0, 0)
    if slua.isValid(uPlayerState) then
      local uTeammatePlayerState
      if uPlayerState:IsSinglePlayer() or uPlayerController:IsDemoPlaySpectator() then
        uTeammatePlayerState = uPlayerState
        if nTeammateIndex < 0 then
          nTeammateIndex = 0
        end
      else
        uTeammatePlayerState = uPlayerState:GetTeammatePlayerState(nTeammateIndex)
      end
      local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
      if slua.isValid(uTeammatePlayerState) and (uTeammatePlayerState == uPlayerState or uTeammatePlayerState.LiveState ~= ExtraPlayerLiveState.InDied) then
        local MapMarkSize = FVector2D(uTeammatePlayerState.MapMark.X, uTeammatePlayerState.MapMark.Y):Size()
        if 0 < MapMarkSize then
          LightCrossPos = uTeammatePlayerState:GetMapMark3DLocation()
          if not self.LightCrossActors then
            self.LightCrossActors = {}
          end
          if not slua.isValid(self.LightCrossActors[nTeammateIndex]) then
            ActorTools.SpawnActorAsync(uPlayerController, LightCrossClass, LightCrossPos, FRotator(0, 0, 0), FVector(1, 1, 1), function(uActor)
              if slua.isValid(uActor) then
                print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange spawn actor teammateindex ", nTeammateIndex)
                if self.TeammateColor then
                  uActor:SetLightCrossColor(self.TeammateColor[nTeammateIndex])
                  self:DestroyLightCrossActor(nTeammateIndex)
                  self.LightCrossActors[nTeammateIndex] = uActor
                end
              end
            end)
          else
            local uLightCross = self.LightCrossActors[nTeammateIndex]
            if slua.isValid(uLightCross) then
              print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange K2_SetActorLocation teammateindex ", nTeammateIndex, self)
              self.LightCrossActors[nTeammateIndex]:K2_SetActorLocation(LightCrossPos, false, nil, false)
            end
          end
        else
          print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange DestroyLightCrossActor", nTeammateIndex, self)
          self:DestroyLightCrossActor(nTeammateIndex)
        end
      else
        print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange uTeammatePlayerState is invalid")
      end
    else
      print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange uPlayerState is invalid")
    end
  else
    print(bWriteLog and "MapMarkLightCrossMgr:OnMapMarkChange uPlayerController is invalid")
  end
end
function MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged(nTeammateIndex)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    if uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() then
      print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, return because IsObserver")
      return
    end
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if uPlayerState and slua.isValid(uPlayerState) then
      local uTeammatePlayerState
      if uPlayerState:IsSinglePlayer() or uPlayerController:IsDemoPlaySpectator() then
        uTeammatePlayerState = uPlayerState
        if nTeammateIndex < 0 then
          nTeammateIndex = 0
        end
      else
        uTeammatePlayerState = uPlayerState:GetTeammatePlayerState(nTeammateIndex)
      end
      local nCurPlayerTeamIndex = self:GetCurPlayerTeamIndex()
      if nCurPlayerTeamIndex and nCurPlayerTeamIndex == nTeammateIndex then
        if uTeammatePlayerState == uPlayerState and slua.isValid(uTeammatePlayerState) then
          local MapMarkSize = FVector2D(uTeammatePlayerState.MapMark.X, uTeammatePlayerState.MapMark.Y):Size()
          if 0 < MapMarkSize then
            local LightCrossPos = FVector(0, 0, 0)
            LightCrossPos = uTeammatePlayerState:GetMapMark3DLocation()
            local uParachuteComp = uPlayerController:GetParachuteComponent()
            if uParachuteComp and slua.isValid(uParachuteComp) then
              local TargetLocation = FVector(LightCrossPos.X, LightCrossPos.Y, LightCrossPos.Z + MapMarkConfig.AutoParachuteLocationZOffset)
              uParachuteComp:SetAutoParachuteLocation(TargetLocation)
              EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MARK_PARACHUTE_REFRESH)
              print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, nTeammateIndex = " .. tostring(nTeammateIndex) .. ", TargetLocation = " .. tostring(TargetLocation:ToString()))
            else
              print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, uParachuteComp = " .. tostring(uParachuteComp))
            end
          else
            print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, MapMarkSize = " .. tostring(MapMarkSize))
          end
        else
          print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, uTeammatePlayerState = " .. tostring(uTeammatePlayerState))
        end
      else
        print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, nCurPlayerTeamIndex = " .. tostring(nCurPlayerTeamIndex) .. ", nTeammateIndex = " .. tostring(nTeammateIndex))
      end
    else
      print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, uPlayerState = " .. tostring(uPlayerState))
    end
  else
    print(bWriteLog and "MapMarkLightCrossMgr:SetAutoParachuteLocationWhenMapMarkChanged, uPlayerController = " .. tostring(uPlayerController))
  end
end
function MapMarkLightCrossMgr:CanProcessMapMark()
  if self.bEnableLightCross ~= true then
    print(bWriteLog and "MapMarkLightCrossMgr:CanProcessMapMark, return false because self.bEnableLightCross = " .. tostring(self.bEnableLightCross))
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local EPawnState = import("EPawnState")
    local uCharacter = uPlayerController:GetPlayerCharacterSafety()
    local InEmergencyCall = slua.isValid(uCharacter) and uCharacter:HasState(EPawnState.InActivityActor)
    if uPlayerController:IsInPlane() or uPlayerController:IsInParachute() or InEmergencyCall then
      if uPlayerController:IsObserver() or uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() then
        print(bWriteLog and "MapMarkLightCrossMgr:CanProcessMapMark is ob or spectator")
        return false
      else
        local AutoParachuteSubsystem = SubsystemMgr:Get("AutoParachuteSubsystem")
        if AutoParachuteSubsystem then
          return AutoParachuteSubsystem:IsMapMarkEnable()
        end
      end
    else
      print(bWriteLog and "MapMarkLightCrossMgr:CanProcessMapMark not in plane or not in parachute", uPlayerController:IsObserver())
    end
  else
    print(bWriteLog and "MapMarkLightCrossMgr:CanProcessMapMark uPlayerController is invalid")
  end
  return false
end
function MapMarkLightCrossMgr:GetCurPlayerTeamIndex()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) then
      local TeamIndex = uPlayerState:GetPlayerTeamIndex()
      if 255 <= TeamIndex then
        TeamIndex = 0
        print(bWriteLog and "MapMarkLightCrossMgr:GetCurPlayerTeamIndex error , get 255")
      end
      return TeamIndex
    end
  end
  return 0
end
function MapMarkLightCrossMgr:UnBindEvents()
  print(bWriteLog and "MapMarkLightCrossMgr:UnBindEvents")
  self:RemoveCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_DELETE_SELF_MAP_MAKER)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    if self.MapMarkChanageDelegate then
      if uPlayerController.OnMapMarkChangeDelegate then
        uPlayerController.OnMapMarkChangeDelegate:Remove(self.MapMarkChanageDelegate)
      end
      self.MapMarkChanageDelegate = nil
    end
    if self.TouchBeginDelegate then
      if uPlayerController.OnPlayerContollerTouchBegin then
        uPlayerController.OnPlayerContollerTouchBegin:Remove(self.TouchBeginDelegate)
      end
      self.TouchBeginDelegate = nil
    end
    if self.TouchEndDelegate then
      if uPlayerController.OnPlayerControllerTouchEnd then
        uPlayerController.OnPlayerControllerTouchEnd:Remove(self.TouchEndDelegate)
      end
      self.TouchEndDelegate = nil
    end
    if self.PlayerControllerStateChangedDelegate then
      if uPlayerController.OnPlayerControllerStateChangedDelegate then
        uPlayerController.OnPlayerControllerStateChangedDelegate:Remove(self.PlayerControllerStateChangedDelegate)
      end
      self.PlayerControllerStateChangedDelegate = nil
    end
    self:RemoveControlEvent(uPlayerController, "OnPlayerExitParachute")
  end
  if self.BindCharacterStateChangedDelegate and slua.isValid(CGameState) then
    local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
    local DelegateMgrInstance = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
    self:RemoveControlEvent(DelegateMgrInstance, "OnCharacterStateChangeDelegate")
    self.BindCharacterStateChangedDelegate = nil
  end
  self.HaveBinded = false
end
function MapMarkLightCrossMgr:RemoveAllLightCross()
  print(bWriteLog and "MapMarkLightCrossMgr:RemoveAllLightCross", self)
  if self.LightCrossActors == nil then
    return
  end
  for _, LightCrossActor in pairs(self.LightCrossActors) do
    if slua.isValid(LightCrossActor) then
      LightCrossActor:K2_DestroyActor()
    end
  end
  self.LightCrossActors = {}
end
function MapMarkLightCrossMgr:RemoveSelfLightCross()
  print(bWriteLog and "MapMarkLightCrossMgr:RemoveSelfLightCross", self)
  local nCurPlayerTeamIndex = self:GetCurPlayerTeamIndex()
  self:DestroyLightCrossActor(nCurPlayerTeamIndex)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_CANCEL_AUTOPARACHUTE)
end
function MapMarkLightCrossMgr:DestroyLightCrossActor(nTeammateIndex)
  if self.LightCrossActors and self.LightCrossActors[nTeammateIndex] and slua.isValid(self.LightCrossActors[nTeammateIndex]) then
    print(bWriteLog and "MapMarkLightCrossMgr:DestroyLightCrossActor, nTeammateIndex = " .. tostring(nTeammateIndex))
    self.LightCrossActors[nTeammateIndex]:K2_DestroyActor()
    self.LightCrossActors[nTeammateIndex] = nil
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, MapMarkLightCrossMgr)