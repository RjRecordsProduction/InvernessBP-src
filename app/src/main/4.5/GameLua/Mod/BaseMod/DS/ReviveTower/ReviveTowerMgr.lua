local ReviveTowerMgr = {}
function ReviveTowerMgr:OnInit()
  self.bCreated = false
  self.bEnabled = true
  self.bTicking = true
  self.TowerCurrentNum = 0
  self.TowerArray = {}
  self.MapToMaterialPath = {
    UnknownMap = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_01.MI_Baltic_BirthLsland_ResurrectionTower_01",
    Baltic = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_Baltic.MI_Baltic_BirthLsland_ResurrectionTower_Baltic",
    Desert = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_Desert.MI_Baltic_BirthLsland_ResurrectionTower_Desert",
    DihorOtok = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_DihorOtok.MI_Baltic_BirthLsland_ResurrectionTower_DihorOtok",
    Neon = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_Neon.MI_Baltic_BirthLsland_ResurrectionTower_Neon",
    Livik = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_Livik.MI_Baltic_BirthLsland_ResurrectionTower_Livik",
    Savage = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_Savage.MI_Baltic_BirthLsland_ResurrectionTower_Savage",
    Karakin = "/Game/Arts_Scenes/_Baltic/Baltic_Objects/V430/Materials/MI_Baltic_BirthLsland_ResurrectionTower_Karakin.MI_Baltic_BirthLsland_ResurrectionTower_Karakin"
  }
  self.MaterialPath = nil
  if CGameMode and CGameMode.PlayerNumPerTeam > 1 then
    local RevivalCount = 0
    local ReviveTowerConfig
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    if DSReviveSubsystem then
      RevivalCount = DSReviveSubsystem:GetInitRevivalCount(UEnums.RevivalWay.General)
      ReviveTowerConfig = DSReviveSubsystem:GetReviveTowerConfig()
    else
      print(bWriteLog and "ReviveTowerMgr:OnInit, DSReviveSubsystem = nil")
    end
    if 0 < RevivalCount and ReviveTowerConfig then
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChangedInLua, self)
    end
  end
  self.CharacterVoiceByID = {
    [29994] = {
      Region = "BLUEHOLE",
      MsgID = 45001,
      VoiceID = 32
    }
  }
end
function ReviveTowerMgr:GetCurrentMapMaterial()
  if self.MaterialPath then
    return self.MaterialPath
  end
  if self.MapToMaterialPath == nil then
    print(bWriteLog and "ReviveTowerMgr:GetCurrentMapMaterial, return nil because MapToMaterialPath = nil")
    return nil
  end
  local Path
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType2 = GameMainConfig.GetMapType()
  if ModType2 ~= nil then
    Path = self.MapToMaterialPath[ModType2]
    if Path == nil then
      Path = self.MapToMaterialPath.UnknownMap
    end
  end
  if Path ~= nil then
    self.Material  end
  print(bWriteLog and "ReviveTowerMgr:GetCurrentMapMaterial, ModType2 = " .. tostring(ModType2) .. ", Path = " .. tostring(Path))
  return Path
end
function ReviveTowerMgr:GetCharacterVoiceByID(MsgID, VoiceID)
  local UGameplayStatics = import("GameplayStatics")
  local uGameInstance = UGameplayStatics.GetGameInstance(CGameState)
  if uGameInstance == nil then
    print(bWriteLog and "ReviveTowerMgr:GetCharacterVoiceByID, uGameInstance = nil")
    return MsgID, VoiceID
  end
  local SubModeID = uGameInstance:GetModeID()
  local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
  if SubModeID == 0 or MatchModeIds == nil or MatchModeIds[SubModeID] ~= nil then
    print(bWriteLog and "ReviveTowerMgr:GetCharacterVoiceByID, SubModeID = " .. tostring(SubModeID) .. " is one of MatchModeIds")
    return MsgID, VoiceID
  end
  if self.CharacterVoiceByID[MsgID] then
    local Config = self.CharacterVoiceByID[MsgID]
    if Config.Region then
      local strRegion = Client.GetPublishRegion()
      if strRegion == Config.Region then
        print(bWriteLog and "ReviveTowerMgr:GetCharacterVoiceByID, MsgID = " .. tostring(Config.MsgID) .. ", VoiceID = " .. tostring(Config.VoiceID))
        return Config.MsgID, Config.VoiceID
      end
    end
  end
  return MsgID, VoiceID
end
function ReviveTowerMgr:GetDisableTimeConfigByModeType()
  if self.DisableTimeConfig then
    return self.DisableTimeConfig
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local _, ModType2 = GameMainConfig.GetModType()
  if ModType2 == nil or ModType2 == "" then
    ModType2 = GameMainConfig.GetMapType()
    if ModType2 == nil or ModType2 == "" or ModType2 == "UnknownMap" then
      print(bWriteLog and "ReviveTowerMgr:GetDisableTimeConfigByModeType, ModType2 = " .. tostring(ModType2) .. ", and set to Default.")
      ModType2 = "Default"
    else
      print(bWriteLog and "ReviveTowerMgr:GetDisableTimeConfigByModeType, GetMapType ModType2 = " .. tostring(ModType2))
    end
  else
    print(bWriteLog and "ReviveTowerMgr:GetDisableTimeConfigByModeType, ModType2 = " .. tostring(ModType2))
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ReviveTowerConfig = GamePlayTools.GetCurrentConfig("ReviveTowerConfig")
  if ReviveTowerConfig and ReviveTowerConfig.DisableTimeConfig then
    local SubModDisableTimeConfig = ReviveTowerConfig.DisableTimeConfig[ModType2]
    SubModDisableTimeConfig = SubModDisableTimeConfig or ReviveTowerConfig.DisableTimeConfig.Default
    if SubModDisableTimeConfig == nil then
      print(bWriteLog and "ReviveTowerMgr:GetDisableTimeConfigByModeType, Load from BaseMod directly")
      local BaseReviveConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ReviveTowerConfig")
      SubModDisableTimeConfig = BaseReviveConfig.DisableTimeConfig[ModType2]
      SubModDisableTimeConfig = SubModDisableTimeConfig or BaseReviveConfig.DisableTimeConfig.Default
    end
    log_tree("ReviveTowerMgr:GetDisableTimeConfigByModeType, SubModDisableTimeConfig = ", SubModDisableTimeConfig)
    self.DisableTimeConfig = SubModDisableTimeConfig
    return self.DisableTimeConfig
  else
    print(bWriteLog and "ReviveTowerMgr:GetDisableTimeConfigByModeType, ReviveTowerConfig = " .. tostring(ReviveTowerConfig))
    return nil
  end
end
function ReviveTowerMgr:AddTower(TowerActor)
  if TowerActor and slua.isValid(TowerActor.Object) then
    local Temp = {
      Index = TowerActor.TowerIndex,
      Position = TowerActor:K2_GetActorLocation(),
      Object = TowerActor.Object
    }
    table.insert(self.TowerArray, Temp)
    self.TowerCurrentNum = self.TowerCurrentNum + 1
    print(bWriteLog and "ReviveTowerMgr:AddTower, After add num = " .. tostring(self.TowerCurrentNum) .. ", index = " .. tostring(Temp.Index) .. ", position = " .. tostring(Temp.Position:ToString()))
  else
    print(bWriteLog and "ReviveTowerMgr:AddTower, TowerActor = " .. tostring(TowerActor))
  end
end
function ReviveTowerMgr:IsReviveTowerEnabled()
  return self.bEnabled
end
function ReviveTowerMgr:IsReviveTowerTicking()
  return self.bTicking
end
function ReviveTowerMgr:SetAllReviveTowerEnabled(bEnabled, bTicking)
  if bEnabled == self.bEnabled and bTicking == nil then
    print(bWriteLog and "ReviveTowerMgr:SetAllReviveTowerEnabled, self.bEnabled = " .. tostring(bEnabled) .. " = bEnabled")
    return
  end
  self.  if bTicking ~= nil then
    self.  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ReviveTowerConfig = GamePlayTools.GetCurrentConfig("ReviveTowerConfig")
  local ResultArray = self:GetAllReviveTowerActor()
  if ResultArray then
    for i = 0, ResultArray:Num() - 1 do
      local uActor = ResultArray:Get(i)
      if uActor and slua.isValid(uActor) then
        if bEnabled then
          uActor.TowerState = ReviveTowerConfig.TowerState.Enabled
        else
          uActor.TowerState = ReviveTowerConfig.TowerState.Disabled
        end
        if bTicking ~= nil then
          local Component = uActor:GetInteractiveComponent()
          if Component then
            if bTicking then
              Component:SetEnable(true)
            else
              Component:SetEnable(false)
            end
          end
        end
      end
    end
    print(bWriteLog and "ReviveTowerMgr:SetAllReviveTowerEnabled, bEnabled = " .. tostring(bEnabled) .. ", bTicking = " .. tostring(bTicking) .. ", ReviveTowerNum = " .. tostring(ResultArray:Num()))
  end
  for k, v in pairs(self.TowerArray) do
    local Location = v.Position
    if bEnabled then
      EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_CHANGE_REVIVETOWER_STATE, Location, 1)
    else
      EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_CHANGE_REVIVETOWER_STATE, Location, 0)
    end
  end
  if bEnabled then
    EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_GLOBAL_CHANGE_REVIVETOWER_STATE, 1)
  else
    EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_GLOBAL_CHANGE_REVIVETOWER_STATE, 0)
  end
  print(bWriteLog and "ReviveTowerMgr:SetAllReviveTowerEnabled, bEnabled = " .. tostring(bEnabled) .. ", bTicking = " .. tostring(bTicking) .. ", #self.TowerArray = " .. tostring(#self.TowerArray))
end
function ReviveTowerMgr:OnGameModeStateChangedInLua(_, _, State)
  print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, State = " .. tostring(State))
  if State == "ReadyState" or State == "ActiveState" then
    self:CreateReviveTowerByConfig()
  elseif State == "FightingState" then
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    local ClearRevivalCountTime = DSReviveSubsystem:GetClearRevivalCountTime()
    if ClearRevivalCountTime and 0 < ClearRevivalCountTime then
      print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, ClearRevivalCountTime = " .. tostring(ClearRevivalCountTime))
      self:AddGameTimer(ClearRevivalCountTime, false, function()
        self:SetAllReviveTowerEnabled(false, false)
        self:DespatchMsgToAllPlayer(10245)
      end)
      local DisableTimeConfig = self:GetDisableTimeConfigByModeType()
      if not DisableTimeConfig then
        print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, DisableTimeConfig = nil")
        return
      end
      local MsgTimeArray = {
        {
          Time = DisableTimeConfig.ReviveTowerDisableTimeTips1,
          MsgId = 10243
        },
        {
          Time = DisableTimeConfig.ReviveTowerDisableTimeTips2,
          MsgId = 10244
        }
      }
      for k, v in ipairs(MsgTimeArray) do
        if v.Time then
          local MsgTime = ClearRevivalCountTime - v.Time
          if 0 < MsgTime then
            self:AddGameTimer(MsgTime, false, function()
              self:DespatchMsgToAllPlayer(v.MsgId, v.Time)
              local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
              local CurrentTime = GamePlayTools.GetServerWorldTimeSeconds()
              print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, CurrentTime" .. tostring(k) .. " = " .. tostring(CurrentTime) .. ", ConfigTime = " .. tostring(v.Time))
            end)
          else
            print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, MsgTime = " .. tostring(MsgTime))
          end
        else
          print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, v.Time = nil")
        end
      end
    else
      print(bWriteLog and "ReviveTowerMgr:OnGameModeStateChangedInLua, ClearRevivalCountTime = " .. tostring(ClearRevivalCountTime))
    end
  end
end
function ReviveTowerMgr:CreateReviveTowerByConfig()
  if self.bCreated == false then
    self.bCreated = true
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    local ReviveTowerConfig = DSReviveSubsystem:GetReviveTowerConfig()
    local Path = ReviveTowerConfig.Path
    local Position = ReviveTowerConfig.Position
    if Path and Position then
      local uWorld = CGameMode:GetWorld()
      local TowerClass = slua.loadClass(Path)
      if uWorld and TowerClass then
        for k, v in pairs(Position) do
          if type(v) == "table" and v[1] and v[2] and v[3] then
            local Location = FVector(v[1], v[2], v[3])
            local TowerActor = uWorld:SpawnActor(TowerClass, Location, FRotator(0, 0, 0), nil)
            if TowerActor then
              TowerActor.TowerIndex = k
              self:AddTower(TowerActor)
            end
          else
            print(bWriteLog and "ReviveTowerMgr:CreateReviveTowerByConfig, invalid position when index = " .. tostring(k))
          end
        end
      else
        print(bWriteLog and "ReviveTowerMgr:CreateReviveTowerByConfig, uWorld = " .. tostring(uWorld) .. ", TowerClass = " .. tostring(TowerClass))
      end
    else
      print(bWriteLog and "ReviveTowerMgr:CreateReviveTowerByConfig, Path = " .. tostring(Path) .. ", Position = " .. tostring(Position))
    end
  end
end
function ReviveTowerMgr:DespatchMsgToAllPlayer(TipsId, Param)
  local AllControllers = Game:GetAllPlayerControllers()
  if AllControllers then
    for k, PC in pairs(AllControllers) do
      if slua.isValid(PC) and not PC:IsSpectator() and not PC:IsInPetSpectator() then
        Game:UIShowImageTips(PC.PlayerKey, TipsId, Param)
      else
        print(bWriteLog and "ReviveTowerMgr:DespatchMsgToAllPlayer, PC:IsSpectator()")
      end
    end
  else
    print(bWriteLog and "ReviveTowerMgr:DespatchMsgToAllPlayer, AllControllers = nil")
  end
end
function ReviveTowerMgr:GetAllReviveTowerActor()
  local GameplayStatics = import("GameplayStatics")
  local GameInstance = GameplayStatics.GetGameInstance(CGameMode)
  local ActorClass = slua.loadClass("/Game/Mod/EvoBase/BluePrints/Actor/ReviveTower.ReviveTower")
  local uActor = import("/Script/Engine.Actor")
  local ResultArray = GameplayStatics.GetAllActorsOfClass(GameInstance, ActorClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  if ResultArray ~= nil then
    return ResultArray
  else
    print(bWriteLog and "ReviveTowerMgr:GetAllReviveTowerActor, ResultArray = nil")
    return nil
  end
end
function ReviveTowerMgr:OnRelease()
  print(bWriteLog and "ReviveTowerMgr:OnRelease")
  self.MaterialPath = nil
  ReviveTowerMgr.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ReviveTowerMgr)