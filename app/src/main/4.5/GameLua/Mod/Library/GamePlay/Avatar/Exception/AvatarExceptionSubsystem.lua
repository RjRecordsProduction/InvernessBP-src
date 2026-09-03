local AvatarExceptionSubsystem = {}
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
local AvatarExceptionConfig = require("GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionConfig")
function AvatarExceptionSubsystem:ctor(selfType)
  self.tPlayerInstMap = {}
  self.tTickPlayerMap = {}
  self.TickCheckTimer = nil
  self.bInFightingState = false
end
function AvatarExceptionSubsystem:OnInit()
  AvatarExceptionSubsystem.__super.OnInit(self)
  print(bWriteLog and string.format("[DebugLLP]AvatarExceptionSubsystem:OnInit()"))
  self.bInFightingState = false
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.ClearAllCheckCharacterTimer, self)
  self:AddCommonEvent(EVENTTYPE_REPORT_BUG, EVENTID_SUBMIT_BATTLE_REPORT_BUG, self.OnClickReportCheckAvatar, self)
  local AvatarCheckExceptionName = "AvatarExceptionReport_AllSlotCheck"
  if not GameReportUtils.CheckCanBugglyPostException(AvatarCheckExceptionName) then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController.bIsForReplay then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_ALL_MESH_LOADED, self.OnAvatarAllMeshLoaded, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChange, self)
  end
end
function AvatarExceptionSubsystem:OnRelease()
  print(bWriteLog and "AvatarExceptionSubsystem:OnRelease()")
  self:ClearAllCheckCharacterTimer()
  AvatarExceptionSubsystem.__super.OnRelease(self)
end
function AvatarExceptionSubsystem:BindPlayerCharacter(uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.PlayerKey and not uPlayerCharacter:GetEnsure() then
    local AvatarExceptionPlayerInst = self:GetPlayerInstData(uPlayerCharacter)
    if AvatarExceptionPlayerInst then
      AvatarExceptionPlayerInst.bActive = true
    end
  end
end
function AvatarExceptionSubsystem:UnbindPlayerCharacter(uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.PlayerKey and not uPlayerCharacter:GetEnsure() then
    local AvatarExceptionPlayerInst = self:GetPlayerInstData(uPlayerCharacter)
    if AvatarExceptionPlayerInst then
      AvatarExceptionPlayerInst.bActive = false
    end
  end
end
function AvatarExceptionSubsystem:ResetAvatarExceptionCheckCount()
  for PlayerKey, AvatarExceptionPlayerInst in pairs(self.tPlayerInstMap) do
    if AvatarExceptionPlayerInst then
      AvatarExceptionPlayerInst.tCheckCountTable = {}
    end
  end
end
function AvatarExceptionSubsystem:TickCheckCharacterAvatar()
  for PlayerKey, _ in pairs(self.tTickPlayerMap) do
    local AvatarExceptionPlayerInst = self.tPlayerInstMap[PlayerKey]
    if AvatarExceptionPlayerInst and AvatarExceptionPlayerInst:IsActive() then
      AvatarExceptionPlayerInst:CheckAvatarException(UEnums.EAvatarExceptionTriggerType.Tick)
    end
  end
end
function AvatarExceptionSubsystem:ClearAllCheckCharacterTimer()
  if self.TickCheckTimer then
    self:RemoveGameTimer(self.TickCheckTimer)
    self.TickCheckTimer = nil
  end
  if self.tPlayerInstMap then
    for PlayerKey, AvatarExceptionPlayerInst in pairs(self.tPlayerInstMap) do
      if AvatarExceptionPlayerInst then
        AvatarExceptionPlayerInst:ClearAllTimer()
      end
    end
  end
  self:RemoveCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_ALL_MESH_LOADED)
end
function AvatarExceptionSubsystem:RegisterTickCheckCharacterAvatar()
  if not self.TickCheckTimer then
    self.TickCheckTimer = self:AddGameTimer(AvatarExceptionConfig.TickCheckInterval, true, function()
      self:TickCheckCharacterAvatar()
    end)
  end
end
function AvatarExceptionSubsystem:OnGameModeStateChange(_, _, sState)
  print(bWriteLog and "AvatarExceptionSubsystem:OnGameModeStateChange", sState)
  if sState == "ReadyState" then
    if Client and Client.IsDevelopment() then
      self:RegisterTickCheckCharacterAvatar()
    end
    self.bInFightingState = false
  elseif sState == "FightingState" then
    self:RegisterTickCheckCharacterAvatar()
    self.bInFightingState = true
    for PlayerKey, AvatarExceptionPlayerInst in pairs(self.tPlayerInstMap) do
      if AvatarExceptionPlayerInst then
        AvatarExceptionPlayerInst.bInFightingState = true
      end
    end
  elseif sState == "FinishedState" then
    self:ClearAllCheckCharacterTimer()
  end
end
function AvatarExceptionSubsystem:OnAvatarAllMeshLoaded(_, _, PlayerKey)
  print(bWriteLog and "AvatarExceptionSubsystem:OnAvatarAllMeshLoaded", PlayerKey)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter(PlayerKey)
  if slua.isValid(uPlayerCharacter) then
    local AvatarExceptionPlayerInst = self:GetPlayerInstData(uPlayerCharacter)
    if AvatarExceptionPlayerInst and AvatarExceptionPlayerInst:IsActive() then
      AvatarExceptionPlayerInst:CheckAvatarException(UEnums.EAvatarExceptionTriggerType.AllMeshLoadedEvent)
    end
  end
end
function AvatarExceptionSubsystem:OnClickReportCheckAvatar(_, _, sErrorReason)
  if sErrorReason == "REPROTBUG-REASON-CHARACTER-DISAPPEAR" then
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local AvatarExceptionPlayerInst = self:GetPlayerInstData(uPlayerCharacter)
      if AvatarExceptionPlayerInst and AvatarExceptionPlayerInst:IsActive() then
        AvatarExceptionPlayerInst:CheckAvatarException(UEnums.EAvatarExceptionTriggerType.ClickReportEvent)
      end
    end
  elseif sErrorReason == "REPROTBUG-REASON-OTHER-CHARACTER-DISAPPEAR" then
    for PlayerKey, AvatarExceptionPlayerInst in pairs(self.tPlayerInstMap) do
      if AvatarExceptionPlayerInst and AvatarExceptionPlayerInst:IsActive() then
        AvatarExceptionPlayerInst:CheckAvatarException(UEnums.EAvatarExceptionTriggerType.ClickReportEvent)
      end
    end
  end
end
local AvatarExceptionPlayerInstClass = require("GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst")
function AvatarExceptionSubsystem:GetPlayerInstData(uPlayerPawn)
  if self.tPlayerInstMap == nil then
    self.tPlayerInstMap = {}
  end
  local PlayerKey = uPlayerPawn.PlayerKey
  if not self.tPlayerInstMap[PlayerKey] then
    local ExceptionName, tConfig = self:GetPlayerInstConfig(uPlayerPawn)
    if tConfig then
      local AvatarExceptionPlayerInst = AvatarExceptionPlayerInstClass(PlayerKey, uPlayerPawn, ExceptionName, tConfig, self.bInFightingState)
      self.tPlayerInstMap[PlayerKey] = AvatarExceptionPlayerInst
      if tConfig.Trigger[UEnums.EAvatarExceptionTriggerType.Tick] then
        if self.tTickPlayerMap == nil then
          self.tTickPlayerMap = {}
        end
        self.tTickPlayerMap[PlayerKey] = true
      end
    end
  end
  return self.tPlayerInstMap[PlayerKey]
end
function AvatarExceptionSubsystem:GetPlayerInstConfig(uPlayerPawn)
  local uSelfPlayerPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uSelfPlayerPawn) and slua.isValid(uPlayerPawn) then
    if uSelfPlayerPawn == uPlayerPawn then
      return "SelfPawnAvatarMiss", AvatarExceptionConfig.SelfPawnAvatarMiss
    elseif uSelfPlayerPawn:IsSameTeam(uPlayerPawn) then
      return "TeamPawnAvatarMiss", AvatarExceptionConfig.TeamPawnAvatarMiss
    end
  end
  return "OtherPawnAvatarMiss", AvatarExceptionConfig.OtherPawnAvatarMiss
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
local CAvatarExceptionSubsystem = class(SubsystemBase, nil, AvatarExceptionSubsystem)
return CAvatarExceptionSubsystem