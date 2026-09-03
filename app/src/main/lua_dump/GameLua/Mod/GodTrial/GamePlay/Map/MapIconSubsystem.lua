local MapIconSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local 
function MapIconSubsystem:OnInit()
  self.IslandTeammateMap = {}
  MapIconSubsystem.__super.OnInit(self)
  self.ArenaBossPos = nil
  self.ArenaFinalPos = nil
  self.GodTrialMapMarkInstancesMap = {}
  self.MapType = GameMainConfig.GetMapType()
  self:AddCommonEvent(EVENTTYPE_GODTRIAL_NORMAL, EVENTIT_TRIAL_STATE_CHANGE, self.OnTrialStateChange, self)
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
end
function MapIconSubsystem:OnGameDataReady()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or not GameState.GameStateTeamHonorFeature then
    if not slua.isValid(GameState) then
      print(bWriteLog and "MapIconSubsystem:OnGameDataReady - GameState is nil")
    elseif not GameState.GameStateTeamHonorFeature then
      print(bWriteLog and "MapIconSubsystem:OnGameDataReady - GameState.GameStateTeamHonorFeature is nil")
    end
    return
  end
  self:AddDataListener(GameState.GameStateTeamHonorFeature:GetSuperData(), "ArenaFinalPos", self.OnArenaFinalPosUpdated, self)
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_AREA_ID_CHANGED, self.HandlePlayerAreaChange, self)
    self:CheckPlayerIconValid()
  end
  if Client and GameState.GameStateFramePlatformFeature then
    local MapMarkInfo = GameState.GameStateFramePlatformFeature.MapMarkInfo
    if MapMarkInfo then
      for Instance, Location in pairs(MapMarkInfo) do
        self:OnTrialStateChange(nil, nil, Instance, Location, 440003)
      end
    end
  end
end
function MapIconSubsystem:OnArenaFinalPosUpdated(_, ArenaFinalPos)
  print(bWriteLog and string.format("MapIconSubsystem:OnArenaFinalPosUpdated - ArenaFinalPos(%s, %s, %s)", tostring(ArenaFinalPos.X), tostring(ArenaFinalPos.Y), tostring(ArenaFinalPos.Z)))
  self.ArenaBossPos = ArenaFinalPos + FVector(-1200, -14000, 0)
  self.ArenaFinalPos = ArenaFinalPos + FVector(-2650, 14300, 0)
  if self.AreaID and self.AreaID ~= "" then
    print(bWriteLog and "MapIconSubsystem:OnArenaFinalPosUpdated - ReCheckArea")
    self:ReCheckArea()
  end
end
function MapIconSubsystem:HandlePlayerAreaChange(_, __, PlayerKey, AreaID)
  print(bWriteLog and "MapIconSubsystem:HandlePlayerAreaChange: ", tostring(PlayerKey), tostring(AreaID))
  self:CheckPlayerIconValid()
end
function MapIconSubsystem:CheckPlayerIconValid()
  local uPlayerState = GameplayData.GetPlayerState()
  if not Game:IsValid(uPlayerState) then
    return
  end
  if not uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  local uTeammatePlayerStateArray = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if slua.isValid(uTeammatePlayerStateArray) and uTeammatePlayerStateArray:Num() > 0 then
    for nTeammateIndex = 0, uTeammatePlayerStateArray:Num() - 1 do
      local uTeammatePlayerState = uTeammatePlayerStateArray:Get(nTeammateIndex)
      if slua.isValid(uTeammatePlayerState) then
        local TeammateMapID = self:GetMapIDFromPlayerState(uTeammatePlayerState)
        self.IslandTeammateMap[nTeammateIndex] = TeammateMapID
      end
    end
  else
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) and PlayerState.GetMapID then
      local MapID = PlayerState:GetMapID()
      self.IslandTeammateMap[0] = MapID
    end
  end
  self:RefreshTeammateIcon()
end
function MapIconSubsystem:GetMapIDFromPlayerState(TeamMateState)
  if slua.isValid(TeamMateState) and TeamMateState.GetMapID then
    return TeamMateState:GetMapID()
  end
  return 0
end
function MapIconSubsystem:HandleMapChange(_, __, MapPath, Scale, ID)
  MapIconSubsystem.__super.HandleMapChange(self, _, __, MapPath, Scale, ID)
  self:CheckPlayerIconValid()
  if self.AreaID == "10001" and self.ArenaFinalPos then
    local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
    if not (MapManagerSubsystem and MapManagerSubsystem.StandaradPointParam and MapManagerSubsystem.StandaradPointParam[self.AreaID] and self.ArenaFinalPos and self.AreaID) or self.AreaID == "" then
      return
    end
    MapManagerSubsystem.StandaradPointParam[self.AreaID].Loc = self.ArenaFinalPos
    self.ArenaFinalPos = nil
    self:ReCheckArea()
  elseif self.AreaID == "10002" and self.ArenaBossPos then
    local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
    if not (MapManagerSubsystem and MapManagerSubsystem.StandaradPointParam and MapManagerSubsystem.StandaradPointParam[self.AreaID] and self.ArenaBossPos and self.AreaID) or self.AreaID == "" then
      return
    end
    MapManagerSubsystem.StandaradPointParam[self.AreaID].Loc = self.ArenaBossPos
    self.ArenaBossPos = nil
    self:ReCheckArea()
  end
end
function MapIconSubsystem:RefreshTeammateIcon()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local SelfAreaID = self:GetAreaID()
  local uTeammatePlayerStateArray = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if self.bBaltic then
    if slua.isValid(uTeammatePlayerStateArray) and uTeammatePlayerStateArray:Num() > 0 then
      for TeammateIndex = 0, uTeammatePlayerStateArray:Num() - 1 do
        if self.IslandTeammateMap[TeammateIndex] and 0 < self.IslandTeammateMap[TeammateIndex] then
          EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_PLAYERICON, TeammateIndex, "GodTrialPOI", false)
        else
          EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_PLAYERICON, TeammateIndex, "GodTrialPOI", true)
        end
      end
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_PLAYERICON, 0, "GodTrialPOI", true)
    end
  elseif slua.isValid(uTeammatePlayerStateArray) and uTeammatePlayerStateArray:Num() > 0 then
    for TeammateIndex = 0, uTeammatePlayerStateArray:Num() - 1 do
      if self.IslandTeammateMap[TeammateIndex] and self.IslandTeammateMap[TeammateIndex] == tonumber(SelfAreaID) then
        EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_PLAYERICON, TeammateIndex, "GodTrialPOI", true)
      else
        EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_PLAYERICON, TeammateIndex, "GodTrialPOI", false)
      end
    end
  end
end
local NewMapIconMap = {
  [440001] = 420017,
  [440002] = 420018,
  [440005] = 420019,
  [440003] = 420020,
  Baltic = {
    [420017] = {
      FVector2D(740107.625, 442026.28125),
      FVector2D(242781.40625, 384806.28125),
      FVector2D(428215.4375, 318638.6875)
    },
    [420018] = {
      FVector2D(434335.53125, 660024.25),
      FVector2D(369616.5625, 402177.03125),
      FVector2D(151478.90625, 220297.375)
    },
    [420019] = {
      FVector2D(120803.3125, 78675.335938),
      FVector2D(560327.375, 80401.132812),
      FVector2D(751205.25, 317774.1875),
      FVector2D(518618.875, 432330.09375),
      FVector2D(201159.1875, 585705.25)
    },
    [420020] = {
      FVector2D(256355.859375, 552400.75),
      FVector2D(294053.3125, 305510.5625),
      FVector2D(547621.125, 197831.4375),
      FVector2D(597117.75, 425120.3125)
    }
  },
  Livik = {
    [420017] = {
      FVector2D(146718.96875, 160330.078125)
    },
    [420018] = {
      FVector2D(237484.5625, 138314.4375)
    },
    [420019] = {
      FVector2D(241195.6875, 280363.625)
    },
    [420020] = {
      FVector2D(167161.25, 188192.046875),
      FVector2D(226283.203125, 202594.140625)
    }
  }
}
function MapIconSubsystem:OnTrialStateChange(_, __, InstanceID, State, TypeID)
  if type(State) == "number" and self.GodTrialMapMarkInstancesMap[InstanceID] then
    InGameMarkTools.UpdateMapMarkCustomState(self.GodTrialMapMarkInstancesMap[InstanceID], State)
  elseif type(State) == "userdata" then
    local MarkLocation = State
    local NewTypeID = NewMapIconMap[TypeID]
    if self.MapType == "Baltic" or self.MapType == "Livik" then
      local LocationList = NewMapIconMap[self.MapType] and NewMapIconMap[self.MapType][NewTypeID]
      if not LocationList then
        print(bWriteLog and "MapIconSubsystem:OnTrialStateChange - TypeID", tostring(TypeID))
        return
      end
      local Distance = math.maxinteger
      for _, Location in ipairs(LocationList) do
        local NewDistance = FVector2D.Distance(FVector2D(State.X, State.Y), Location)
        if Distance > NewDistance then
          Distance = NewDistance
          Mark        end
      end
    elseif self.MapType == "Livik" and TypeID == 440005 then
      MarkLocation.Y = MarkLocation.Y - 2000
    end
    local NewInstance
    if Client then
      NewInstance = InGameMarkTools.ClientAddMapMark(NewTypeID, FVector(MarkLocation.X, MarkLocation.Y, 0), 0, UEnums.EAddMarkFlag.Both)
    else
      NewInstance = InGameMarkTools.ServerAddMapMark(NewTypeID, FVector(MarkLocation.X, MarkLocation.Y, 0), 0, UEnums.EAddMarkFlag.Both)
    end
    self.GodTrialMapMarkInstancesMap[InstanceID] = NewInstance
  end
end
function MapIconSubsystem:AddGodTrialMapIcon()
  if Client then
    return
  end
  self:AddCommonEvent(EVENTTYPE_GODTRIAL_NORMAL, EVENTIT_SERVER_TRIAL_END_SUCCESS, self.OnTrialEndSuccess, self)
  print(bWriteLog and "MapIconSubsystem:AddMapIcon")
  self.GodTrialMapMarkInstances = {}
  for ConfigID, Locations in pairs(NewMapIconMap) do
    for _, Location in ipairs(Locations) do
      local Instance = InGameMarkTools.ServerAddMapMark(ConfigID, Location, 0, UEnums.EAddMarkFlag.Both)
      self.GodTrialMapMarkInstances[#self.GodTrialMapMarkInstances + 1] = Instance
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.Mod.Library.GamePlay.Map.MapIconSubsystem")
return class(SubsystemBase, nil, MapIconSubsystem)