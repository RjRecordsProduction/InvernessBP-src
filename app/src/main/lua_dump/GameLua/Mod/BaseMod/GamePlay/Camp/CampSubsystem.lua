local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local CampSubsystem = {}
function CampSubsystem:ctor()
end
function CampSubsystem:OnInit()
  self.IsEnabled = false
  self.Team2Camp = {}
  self.CacheOriginCampId = {}
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_SET_PAWN_CAMP, self.OnPawnTrySetCamp, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_SET_TEAM_CAMP, self.OnTeamTrySetCamp, self)
end
function CampSubsystem:SetCampModeEnabled(IsEnabled)
  print(bWriteLog and string.format("CampSubsystem:SetCampModeEnabled %s", IsEnabled))
  if not Client then
    CGameMode.bConsiderCamp = IsEnabled
    local AllPlayerCharacters = GameplayData.GetAllPlayerCharacters()
    for _, PlayerCharacter in pairs(AllPlayerCharacters) do
      if slua.isValid(PlayerCharacter) then
        PlayerCharacter:EnsureDynamicFeature("CampFeature")
        if PlayerCharacter.CampFeature then
          PlayerCharacter.CampFeature:SetCampModeEnabled(IsEnabled)
          PlayerCharacter.CampFeature:ShowOrHideCampMark(IsEnabled, 10080000)
        end
        if not IsEnabled then
          local OriginCampId = self.CacheOriginCampId[PlayerCharacter.PlayerKey] or 0
          self:SetCampId(PlayerCharacter.PlayerKey, OriginCampId)
        end
      end
    end
    self.    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_CHANGE_TEAM, self.OnPlayerChangeTeam, self)
  end
end
function CampSubsystem:RegisterPlayerCharacter(PlayerCharacter)
  if not self.CacheOriginCampId then
    self.CacheOriginCampId = {}
  end
  self.CacheOriginCampId[PlayerCharacter.PlayerKey] = PlayerCharacter.CampID
  print(bWriteLog and string.format("PlayerCharacterCampFeature:RegisterPlayerCharacter %s OriginCampId = %s", PlayerCharacter.PlayerKey, PlayerCharacter.OriginCampId))
end
function CampSubsystem:SetCampId(PlayerKey, CampId)
  if Client or not self.IsEnabled then
    return
  end
  local PlayerState = GameplayData.GetPlayerState(PlayerKey)
  if slua.isValid(PlayerState) then
    PlayerState.CampID = CampId
    print(bWriteLog and string.format("CampSubsystem:SetCampId(PlayerState) %s CampId = %s", PlayerKey, CampId))
    local PlayerCharacter = PlayerState:GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      PlayerCharacter.CampID = CampId
      print(bWriteLog and string.format("CampSubsystem:SetCampId(PlayerCharacter) %s CampId = %s", PlayerKey, CampId))
      PlayerCharacter:LuaBroadcastCommonEventCpp("EVENTTYPE_INGAME_NORMAL", "EVENTID_INGAME_ON_PAWN_CAMP_CHANGED", PlayerCharacter, CampId)
    end
  end
  local PlayerController = GameplayData.GetPlayerController(PlayerKey)
  if slua.isValid(PlayerController) then
    PlayerController.CampID = CampId
    print(bWriteLog and string.format("CampSubsystem:SetCampId(PlayerController) %s CampId = %s", PlayerKey, CampId))
  end
end
function CampSubsystem:SetCampIdByTeam(TeamId, CampId)
  if Client or not self.IsEnabled then
    return
  end
  print(bWriteLog and string.format("CampSubsystem:SetCampIdByTeam TeamId = %s CampId = %s", TeamId, CampId))
  self.Team2Camp[TeamId] = CampId
  local AllPlayerStates = Game:GetAllPlayerStates()
  for _, PlayerState in pairs(AllPlayerStates) do
    if slua.isValid(PlayerState) and PlayerState:GetTeamId() == TeamId then
      self:SetCampId(PlayerState.PlayerKey, CampId)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_TEAM_CAMP_CHANGED, TeamId, CampId)
end
function CampSubsystem:GetTeamIdsByCamp(QueryCampId)
  local Result = {}
  for TeamId, CampId in pairs(self.Team2Camp) do
    if CampId == QueryCampId then
      table.insert(Result, TeamId)
    end
  end
  return Result
end
function CampSubsystem:GetCampIdByTeamId(TeamId)
  if self.Team2Camp[TeamId] ~= nil then
    return self.Team2Camp[TeamId]
  end
  return 0
end
function CampSubsystem:OnPlayerChangeTeam(_, __, PlayerKey, TeamId)
  if Client or not self.IsEnabled then
    return
  end
  local TargetCampId = self:GetCampIdByTeamId(TeamId)
  self:SetCampId(PlayerKey, TargetCampId)
end
function CampSubsystem:OnPawnTrySetCamp(_, __, Pawn, CampID)
  print(bWriteLog and string.format("CampSubsystem:OnPawnTrySetCamp %s %s", Pawn, CampID))
  if Game:IsBaseCharacter(Pawn) then
    self:SetCampId(Pawn.PlayerKey, CampID)
  end
end
function CampSubsystem:OnTeamTrySetCamp(_, __, TeamID, CampID)
  print(bWriteLog and string.format("CampSubsystem:OnPawnTrySetCamp %s %s", TeamID, CampID))
  self:SetCampIdByTeam(TeamID, CampID)
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, CampSubsystem)