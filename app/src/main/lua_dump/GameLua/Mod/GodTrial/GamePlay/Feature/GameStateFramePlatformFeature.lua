local FPTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.FPTrialConfig")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameStateFramePlatformFeature = {}
function GameStateFramePlatformFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "MarkLocationList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      import("/Script/CoreUObject.Vector")
    },
    {
      "IgniteInfoList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      import("Vector2D")
    }
  }
  return RepTable
end
function GameStateFramePlatformFeature:ctor()
  self.MarkLocationList = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.Vector"))
  self.IgniteInfoList = slua.Array(UEnums.EPropertyClass.Struct, import("Vector2D"))
  self.LastIgniteTeamIDList = slua.Array(UEnums.EPropertyClass.Int)
  self.TrialActorList = {}
  self.MapMarkList = {}
  self.ScreenMarkList = {}
  self.InTrialAreaList = {}
  self.TimerHandler = nil
  self.MapMarkInfo = {}
  self.bIsLog0Printed = false
  self.bIsLog1Printed = false
  self.TrialOpenCount = 0
  self.PlayerDeathCount = 0
  self.FightCount = 0
  self.ResetCount = 0
end
function GameStateFramePlatformFeature:_PostConstruct()
  GameStateFramePlatformFeature.__super._PostConstruct(self)
end
function GameStateFramePlatformFeature:ReceiveBeginPlay()
  GameStateFramePlatformFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "GameStateFramePlatformFeature:ReceiveBeginPlay")
  if not self:HasAuthority() then
    self.TimerHandler = self:AddGameTimer(0.33, true, function()
      self:OnUpdateMarks()
    end)
  end
end
function GameStateFramePlatformFeature:ReceiveEndPlay(EndPlayReason)
  if self.TimerHandler then
    self:RemoveGameTimer(self.TimerHandler)
    self.TimerHandler = nil
  end
  for _, MarkID in ipairs(self.MapMarkList) do
    print(bWriteLog and string.format("GameStateFramePlatformFeature:ReceiveEndPlay, HideMapMark, MarkID:%s", tostring(MarkID)))
    InGameMarkTools.HideMapMark(MarkID)
  end
  self.MapMarkList = {}
  for _, MarkID in ipairs(self.ScreenMarkList) do
    print(bWriteLog and string.format("GameStateFramePlatformFeature:ReceiveEndPlay, HideMapMark, MarkID:%s", tostring(MarkID)))
    InGameMarkTools.HideMapMark(MarkID)
  end
  self.ScreenMarkList = {}
  GameStateFramePlatformFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GameStateFramePlatformFeature:AddDSTrialActor(TrialActor)
  if not TrialActor then
    print(bWriteLog and "GameStateFramePlatformFeature:AddDSTrialActor, invalid TrialActor")
    return 0
  end
  self.TrialActorList[#self.TrialActorList + 1] = TrialActor
  self.MarkLocationList:Add(TrialActor:K2_GetActorLocation())
  self.IgniteInfoList:Add(FVector2D(-1, FPTrialConfig.StartTime))
  self:ForceNetUpdate()
  return #self.TrialActorList
end
function GameStateFramePlatformFeature:AddClientTrialActor(TrialActor, Index)
  if not TrialActor then
    print(bWriteLog and string.format("GameStateFramePlatformFeature:AddClientTrialActor, invalid TrialActor, Index:%s", tostring(Index)))
    return
  end
  print(bWriteLog and string.format("GameStateFramePlatformFeature:AddClientTrialActor, Index:%s", tostring(Index)))
  self.TrialActorList[Index] = TrialActor
  self:OnIgniteTeamIDChanged(Index - 1)
end
function GameStateFramePlatformFeature:RemoveClientTrialActor(Index)
  self.TrialActorList[Index] = nil
end
function GameStateFramePlatformFeature:OnRep_MarkLocationList()
  local CurrentCount = #self.MapMarkList
  if CurrentCount < self.MarkLocationList:Num() then
    print(bWriteLog and "GameStateFramePlatformFeature:OnRep_MarkLocationList")
    for Index = CurrentCount, self.MarkLocationList:Num() - 1 do
      self:InitMapMark(Index)
      self:InitScreenMark(Index)
    end
  else
    print(bWriteLog and "Error, GameStateFramePlatformFeature:OnRep_MarkLocationList")
  end
end
function GameStateFramePlatformFeature:UpdateIgniteTeamID(Index, TeamID)
  if Index >= self.IgniteInfoList:Num() then
    print(bWriteLog and string.format("GameStateFramePlatformFeature:UpdateIgniteTeamID, invalid Index:%s", tostring(Index)))
    return
  end
  if TeamID < 0 then
    self.IgniteInfoList:Set(Index, FVector2D(TeamID, math.floor(FPTrialConfig.StartTime)))
  elseif TeamID == 0 then
    self.IgniteInfoList:Set(Index, FVector2D(TeamID, 36000))
  elseif 0 < TeamID then
    if TeamID >= FPTrialConfig.DefaultFinishedMark then
      self.IgniteInfoList:Set(Index, FVector2D(TeamID, 0))
    else
      local CurrentTime = CGameState:GetServerWorldTimeSeconds()
      self.IgniteInfoList:Set(Index, FVector2D(TeamID, math.floor(CurrentTime + FPTrialConfig.OccupyDuration)))
    end
  end
  self:ForceNetUpdate()
end
function GameStateFramePlatformFeature:ReplaceIgniteTeamID(Index, TeamID)
  if Index >= self.IgniteInfoList:Num() then
    print(bWriteLog and string.format("GameStateFramePlatformFeature:ReplaceIgniteTeamID, invalid Index:%s", tostring(Index)))
    return
  end
  if TeamID <= 0 or TeamID >= FPTrialConfig.DefaultFinishedMark then
    return
  end
  local EndTime = self:GetIgniteEndTime(Index)
  self.IgniteInfoList:Set(Index, FVector2D(TeamID, math.floor(EndTime)))
  self:ForceNetUpdate()
end
function GameStateFramePlatformFeature:GetIgniteTeamID(Index)
  if 0 <= Index and Index < self.IgniteInfoList:Num() then
    local IgniteInfoList = self.IgniteInfoList:Get(Index)
    if IgniteInfoList then
      return math.floor(IgniteInfoList.X)
    end
  end
  return -1
end
function GameStateFramePlatformFeature:GetIgniteEndTime(Index)
  if 0 <= Index and Index < self.IgniteInfoList:Num() then
    local IgniteInfoList = self.IgniteInfoList:Get(Index)
    if IgniteInfoList then
      return IgniteInfoList.Y
    end
  end
  return -1
end
function GameStateFramePlatformFeature:OnRep_IgniteInfoList(OldValue)
  print(bWriteLog and "GameStateFramePlatformFeature:OnRep_IgniteTeamIDList")
  local IgniteTeamIDList = slua.Array(UEnums.EPropertyClass.Int)
  for Index = 0, self.IgniteInfoList:Num() - 1 do
    local IgniteInfo = self.IgniteInfoList:Get(Index)
    IgniteTeamIDList:Add(IgniteInfo.X)
  end
  if IgniteTeamIDList:Num() == self.LastIgniteTeamIDList:Num() then
    for Index = 0, IgniteTeamIDList:Num() - 1 do
      local NewTeamID = IgniteTeamIDList:Get(Index)
      local OldTeamID = self.LastIgniteTeamIDList:Get(Index)
      if NewTeamID ~= OldTeamID then
        self:OnIgniteTeamIDChanged(Index)
      end
    end
  elseif IgniteTeamIDList:Num() > self.LastIgniteTeamIDList:Num() then
    for Index = 0, self.LastIgniteTeamIDList:Num() - 1 do
      local NewTeamID = IgniteTeamIDList:Get(Index)
      local OldTeamID = self.LastIgniteTeamIDList:Get(Index)
      if NewTeamID ~= OldTeamID then
        self:OnIgniteTeamIDChanged(Index)
      end
    end
    for Index = self.LastIgniteTeamIDList:Num(), IgniteTeamIDList:Num() - 1 do
      self:OnIgniteTeamIDChanged(Index)
    end
  end
  self.LastIgniteTeamIDList:Clear()
  for Index = 0, IgniteTeamIDList:Num() - 1 do
    self.LastIgniteTeamIDList:Add(IgniteTeamIDList:Get(Index))
  end
end
function GameStateFramePlatformFeature:OnIgniteTeamIDChanged(Index)
  self:UpdateMapMark(Index)
  self:UpdateScreenMark(Index)
  self:UpdateIgniteStateUI(Index)
  if self.TrialActorList[Index + 1] and 0 <= Index and Index < self.IgniteInfoList:Num() then
    local TeamID = self:GetIgniteTeamID(Index)
    self.TrialActorList[Index + 1]:UpdateAreaParticle(TeamID)
    self.TrialActorList[Index + 1]:UpdateIgniteParticle(TeamID)
    self.TrialActorList[Index + 1]:UpdateAudio(TeamID)
  end
end
function GameStateFramePlatformFeature:OnUpdateMarks()
  if not self.MarkLocationList then
    if not self.bIsLog0Printed then
      self.bIsLog0Printed = true
      print(bWriteLog and string.format("GameStateFramePlatformFeature:OnUpdateMarks, Invalid MarkLocationList"))
    end
    return
  end
  local Count = self.MarkLocationList:Num()
  if Count < 1 or 10 < Count then
    if not self.bIsLog1Printed then
      self.bIsLog1Printed = true
      print(bWriteLog and string.format("GameStateFramePlatformFeature:OnUpdateMarks, Invalid Count:%d", Count))
    end
    return
  end
  for Index = 0, Count - 1 do
    self:UpdateMapMark(Index)
    self:UpdateScreenMark(Index)
    self:UpdateIgniteStateUI(Index)
  end
end
function GameStateFramePlatformFeature:InitMapMark(Index)
  print(bWriteLog and string.format("GameStateFramePlatformFeature:InitMapMark, Index:%d", Index))
  if not self.MapMarkList[Index + 1] then
    local TargetLocation = self.MarkLocationList:Get(Index)
    self.MapMarkList[Index + 1] = InGameMarkTools.ClientAddMapMark(440003, TargetLocation, 0, nil, 3)
    local NewInstance = self.MapMarkList[Index + 1]
    print(bWriteLog and string.format("GameStateFramePlatformFeature:InitMapMark, Success. Index:%d, MarkID:%s", Index, tostring(NewInstance)))
    self.MapMarkInfo[NewInstance] = TargetLocation
  end
end
function GameStateFramePlatformFeature:UpdateMapMark(Index)
  if not self.MapMarkList[Index + 1] then
    print(bWriteLog and string.format("Error: GameStateFramePlatformFeature:UpdateMapMark, MapMark not Existed!!! Index:%d", Index))
  end
  if Index >= self.IgniteInfoList:Num() then
    return
  end
  local IgniteInfo = self.IgniteInfoList:Get(Index)
  if not IgniteInfo then
    return
  end
  local TeamID, EndTime = IgniteInfo.X, math.floor(IgniteInfo.Y - CGameState:GetServerWorldTimeSeconds())
  if EndTime < 0 then
    EndTime = 0
  end
  if TeamID == -1 then
    InGameMarkTools.UpdateMapMarkCustomState(self.MapMarkList[Index + 1], 0, EndTime)
  elseif TeamID == 0 then
    InGameMarkTools.UpdateMapMarkCustomState(self.MapMarkList[Index + 1], 1)
  elseif 0 < TeamID and TeamID < FPTrialConfig.DefaultFinishedMark then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      local uPlayerCharacter = uPlayerController:GetCurPawn()
      if slua.isValid(uPlayerCharacter) then
        local MyTeamID = Game:GetTeamID(uPlayerCharacter)
        if TeamID == MyTeamID then
          InGameMarkTools.UpdateMapMarkCustomState(self.MapMarkList[Index + 1], 2, EndTime)
        else
          InGameMarkTools.UpdateMapMarkCustomState(self.MapMarkList[Index + 1], 3, EndTime)
        end
      end
    end
  elseif TeamID >= FPTrialConfig.DefaultFinishedMark then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      local uPlayerCharacter = uPlayerController:GetCurPawn()
      if slua.isValid(uPlayerCharacter) then
        local MyTeamID = Game:GetTeamID(uPlayerCharacter)
        if TeamID == MyTeamID + FPTrialConfig.DefaultFinishedMark then
          InGameMarkTools.UpdateMapMarkCustomState(self.MapMarkList[Index + 1], 4)
        else
          InGameMarkTools.UpdateMapMarkCustomState(self.MapMarkList[Index + 1], 5)
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_GODTRIAL_NORMAL, EVENTIT_TRIAL_STATE_CHANGE, self.MapMarkList[Index + 1], 1)
  end
end
function GameStateFramePlatformFeature:InitScreenMark(Index)
  print(bWriteLog and string.format("GameStateFramePlatformFeature:InitScreenMark, Index:%d", Index))
  if not self.ScreenMarkList[Index + 1] then
    self.InTrialAreaList[Index + 1] = false
    local TargetLocation = self.MarkLocationList:Get(Index)
    TargetLocation = TargetLocation + FPTrialConfig.ScreenMarkOffset
    self.ScreenMarkList[Index + 1] = InGameMarkTools.ClientAddMapMark(440003, TargetLocation, 0, nil, 4)
    print(bWriteLog and string.format("GameStateFramePlatformFeature:InitScreenMark, Success. Index:%d, MarkID:%s", Index, tostring(self.ScreenMarkList[Index + 1])))
  end
end
function GameStateFramePlatformFeature:UpdateScreenMark(Index)
  if not self.ScreenMarkList[Index + 1] then
    print(bWriteLog and string.format("Error: GameStateFramePlatformFeature:UpdateScreenMark, ScreenMark not Existed!!! Index:%d", Index))
  end
  if not self.InTrialAreaList[Index + 1] then
    return
  end
  if Index >= self.IgniteInfoList:Num() then
    return
  end
  local IgniteInfo = self.IgniteInfoList:Get(Index)
  if not IgniteInfo then
    return
  end
  local TeamID, EndTime = IgniteInfo.X, math.floor(IgniteInfo.Y - CGameState:GetServerWorldTimeSeconds())
  if EndTime < 0 then
    EndTime = 0
  end
  if TeamID == -1 then
    InGameMarkTools.UpdateMapMarkCustomState(self.ScreenMarkList[Index + 1], 1, EndTime)
  elseif TeamID == 0 then
    InGameMarkTools.UpdateMapMarkCustomState(self.ScreenMarkList[Index + 1], 2, EndTime)
  elseif 0 < TeamID and TeamID < FPTrialConfig.DefaultFinishedMark then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      local uPlayerCharacter = uPlayerController:GetCurPawn()
      if slua.isValid(uPlayerCharacter) then
        local MyTeamID = Game:GetTeamID(uPlayerCharacter)
        if TeamID == MyTeamID then
          InGameMarkTools.UpdateMapMarkCustomState(self.ScreenMarkList[Index + 1], 3, EndTime)
        else
          InGameMarkTools.UpdateMapMarkCustomState(self.ScreenMarkList[Index + 1], 4, EndTime)
        end
      end
    end
  elseif TeamID >= FPTrialConfig.DefaultFinishedMark then
    InGameMarkTools.UpdateMapMarkCustomState(self.ScreenMarkList[Index + 1], 0)
  end
end
function GameStateFramePlatformFeature:UpdateIgniteStateUI(Index)
  if not self.InTrialAreaList[Index + 1] then
    return
  end
  if Index >= self.IgniteInfoList:Num() then
    return
  end
  local IgniteInfo = self.IgniteInfoList:Get(Index)
  if not IgniteInfo then
    return
  end
  local TeamID, EndTime = IgniteInfo.X, math.floor(IgniteInfo.Y - CGameState:GetServerWorldTimeSeconds())
  if TeamID <= 0 or TeamID >= FPTrialConfig.DefaultFinishedMark or EndTime < 1 then
    UIManager.CloseUI(UIManager.UI_Config_InGame.FPIgnitingUI)
  else
    local IgniteStateUI = UIManager.GetUI(UIManager.UI_Config_InGame.FPIgnitingUI)
    IgniteStateUI = IgniteStateUI or UIManager.ShowUI(UIManager.UI_Config_InGame.FPIgnitingUI)
    if not IgniteStateUI then
      print(bWriteLog and string.format("Error: GameStateFramePlatformFeature:UpdateIgniteStateUI, IgniteStateUI not Existed!!! Index:%d", Index))
      return
    end
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
      return
    end
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    if not slua.isValid(uPlayerCharacter) then
      return
    end
    if TeamID == Game:GetTeamID(uPlayerCharacter) then
      IgniteStateUI:UpdateState(true, EndTime)
    else
      IgniteStateUI:UpdateState(false, EndTime)
    end
  end
end
function GameStateFramePlatformFeature:LeaveFPTrialArea(Index)
  print(bWriteLog and string.format("GameStateFramePlatformFeature:LeaveFPTrialArea, Index:%d", Index))
  if self.ScreenMarkList[Index + 1] then
    InGameMarkTools.UpdateMapMarkCustomState(self.ScreenMarkList[Index + 1], 0)
  end
  UIManager.CloseUI(UIManager.UI_Config_InGame.FPIgnitingUI)
  self.InTrialAreaList[Index + 1] = false
end
function GameStateFramePlatformFeature:EnterFPTrialArea(Index)
  print(bWriteLog and string.format("GameStateFramePlatformFeature:EnterFPTrialArea, Index:%d", Index))
  self.InTrialAreaList[Index + 1] = true
  self:UpdateScreenMark(Index)
  self:UpdateIgniteStateUI(Index)
end
function GameStateFramePlatformFeature:AddTrialOpenCount()
  self.TrialOpenCount = self.TrialOpenCount + 1
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddCommonTLog(699, self.TrialOpenCount, false)
  end
end
function GameStateFramePlatformFeature:AddPlayerDeathCount()
  self.PlayerDeathCount = self.PlayerDeathCount + 1
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddCommonTLog(700, self.PlayerDeathCount, false)
  end
end
function GameStateFramePlatformFeature:AddFightCount()
  self.FightCount = self.FightCount + 1
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddCommonTLog(701, self.FightCount, false)
  end
end
function GameStateFramePlatformFeature:AddResetCount()
  self.ResetCount = self.ResetCount + 1
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddCommonTLog(702, self.ResetCount, false)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateFramePlatformFeature)