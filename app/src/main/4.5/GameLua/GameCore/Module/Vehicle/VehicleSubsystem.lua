local VehicleSubsystem = {}
local UScriptGameplayStatics = import("ScriptGameplayStatics")
function VehicleSubsystem:ctor()
  self.FindHorseMaxDistance = 500.0
  self.FindHorseMinDistance = 150.0
  self.RecallDistMax = 5000.0
  self.nRecallItemID = 604123
  self.nAppleItemID = 604127
  self.bIsInSpectatorOrReplay = false
end
function VehicleSubsystem:OnInit()
  self:GetVehicleHPModifyCfg()
  print(bWriteLog and "VehicleSubsystem:OnInit")
end
function VehicleSubsystem:OnRegister()
  print(bWriteLog and "VehicleSubsystem:OnRegister")
  self:RegistEvents()
end
function VehicleSubsystem:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_PLAYER_CHANGED, self.DetachFromVehicle, self)
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  if Client and slua.isValid(Bridge) then
    self:AddControlEvent(Bridge, "OnPlayReplayBegin", self.OnSpectatorReplayChanged, self)
    self:AddControlEvent(Bridge, "OnPlayReplayEnd", self.OnSpectatorReplayChanged, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnSpectatorReplayChanged, self)
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorReplayChanged, self)
    self:OnSpectatorReplayChanged()
  end
end
function VehicleSubsystem:OnSpectatorReplayChanged()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(CGameWorld, 0)
  if not slua.isValid(PlayerController) or not PlayerController.HasAnySpectatorReplayFlag then
    return
  end
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  self.bIsInSpectatorOrReplay = PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay)
  print(bWriteLog and "VehicleSubsystem:OnSpectatorReplayChanged bIsInSpectatorOrReplay: ", self.bIsInSpectatorOrReplay)
end
function VehicleSubsystem:GetVehicleHPModifyCfg()
  if ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.room_vehicular_blood then
    self.VehicleHPModifyCfg = ServerDataMgr.SyncGameParams.room_vehicular_blood
    print(bWriteLog and "VehicleSubsystem:GetVehicleHPModifyCfg finished")
  end
end
function VehicleSubsystem:BeginPlay(uVehicle)
  if not self.VehicleHPModifyCfg or not slua.isValid(uVehicle) then
    return
  end
  local VehicleType = uVehicle.VehicleShapeType
  local VehicleModifiedHP = self.VehicleHPModifyCfg[tonumber(VehicleType)]
  if not VehicleModifiedHP then
    print(bWriteLog and "VehicleSubsystem:BeginPlay, no need modify this VehicleType", VehicleType)
    return
  end
  local uCommonComp = uVehicle:GetCommonComponent()
  if not slua.isValid(uCommonComp) then
    return
  end
  uCommonComp:SetHPMax(VehicleModifiedHP, true)
  print(bWriteLog and "VehicleSubsystem:BeginPlay, ChangeVehicleHP", VehicleType, VehicleModifiedHP)
end
function VehicleSubsystem:AddHorse(uHorse, nHorseID)
  if not slua.isValid(uHorse) or not Client then
    print(bWriteLog and "uHorse is InValid")
    return
  end
  if nHorseID == nil then
    print(bWriteLog and "nHorseID is Nill")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if uHorse.VehicleType ~= ESTExtraVehicleType.VT_Horse and uHorse.VehicleType ~= ESTExtraVehicleType.VT_WarHorse then
    return
  end
  if self.CacheMap == nil then
    self.CacheMap = {}
  end
  self.CacheMap[nHorseID] = uHorse
  if self.CanFeedTimer == nil then
    self.CanFeedTimer = self:AddGameTimer(0.5, true, function()
      self:CheckCanShowFeedButton()
    end)
  end
end
function VehicleSubsystem:DeleteHorse(uHorse, nHorseID)
  if not slua.isValid(uHorse) or not Client then
    print(bWriteLog and "uHorse is InValid")
    return
  end
  if nHorseID == nil then
    print(bWriteLog and "nHorseID is Nill")
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if uHorse.VehicleType ~= ESTExtraVehicleType.VT_Horse and uHorse.VehicleType ~= ESTExtraVehicleType.VT_WarHorse then
    return
  end
  if self.CacheMap == nil then
    self.CacheMap = {}
  end
  self.CacheMap[nHorseID] = nil
end
function VehicleSubsystem:CheckCanShowFeedButton()
  if self.bIsInSpectatorOrReplay then
    if self.CacheMap == nil and self.CanFeedTimer then
      self:RemoveGameTimer(self.CanFeedTimer)
      self.CanFeedTimer = nil
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_FeedHorse")
    return
  end
  if self.CacheMap == nil or not next(self.CacheMap) then
    if self.CanFeedTimer then
      self:RemoveGameTimer(self.CanFeedTimer)
      self.CanFeedTimer = nil
    end
  else
    local bShow = false
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerController) then
      local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
      local nNeedItemID = self.nAppleItemID or 0
      if 0 < Game:GetItemNumByResID(uPlayerCharacter, self.nAppleItemID) and slua.isValid(uPlayerController.VehicleUserComp) and uPlayerController.VehicleUserComp.VehicleUserState == ESTExtraVehicleUserState.EVUS_OutOfVehicle then
        local CharacterLoc = uPlayerCharacter:K2_GetActorLocation()
        local bEmpty = true
        for _, uHorse in pairs(self.CacheMap) do
          if slua.isValid(uHorse) then
            bEmpty = false
            local HorseLoc = uHorse:K2_GetActorLocation()
            local Dist = FVector.Distance(CharacterLoc, HorseLoc)
            if Dist <= self.FindHorseMaxDistance and Dist >= self.FindHorseMinDistance and not uHorse:IsTransforming() then
              local VehicleSeats = uHorse.VehicleSeats
              if slua.isValid(VehicleSeats) and VehicleSeats:GetInUseSeatNum() == 0 then
                bShow = true
              end
            end
          end
        end
        if bEmpty and self.CanFeedTimer then
          self:RemoveGameTimer(self.CanFeedTimer)
          self.CanFeedTimer = nil
        end
      end
    end
    if bShow then
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_FeedHorse")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_FeedHorse")
    end
  end
end
function VehicleSubsystem:DetachFromVehicle(_, __, uVehicle, uPlayerCharacter, bAttach)
  if bAttach and slua.isValid(uPlayerCharacter) then
    local PlayerKey = uPlayerCharacter.PlayerKey
    if PlayerKey and self.RecallItemMap ~= nil and self.RecallItemMap[PlayerKey] ~= nil then
      local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
      if slua.isValid(uVehicle) and uVehicle.VehicleShapeType ~= ESTExtraVehicleShapeType.VST_Horse and uVehicle.VehicleShapeType ~= ESTExtraVehicleShapeType.VST_WarHorse and uVehicle.VehicleShapeType ~= ESTExtraVehicleShapeType.VST_HorseLiquid then
        self:RemoveHorseRecallItem(uPlayerCharacter, nil, true)
      end
    end
  end
end
function VehicleSubsystem:AddHorseRecallItem(uPlayerCharacter, uVehicle)
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uVehicle) then
    return
  end
  if CGameState and CGameState:IsCreativeMode() then
    return
  end
  local ESTExtraVehicleType = import("ESTExtraVehicleType")
  if uVehicle.VehicleType ~= ESTExtraVehicleType.VT_Horse and uVehicle.VehicleType ~= ESTExtraVehicleType.VT_WarHorse then
    return
  end
  if self.RecallItemMap == nil then
    self.RecallItemMap = {}
  end
  local PlayerKey = uPlayerCharacter.PlayerKey
  if PlayerKey ~= nil then
    if self.RecallItemMap[PlayerKey] ~= nil then
      Game:DropItem(PlayerKey, self.nRecallItemID, 1)
    end
    self.RecallItemMap[PlayerKey] = nil
    if Game:AddItemByResID(uPlayerCharacter, self.nRecallItemID, 1, true, 0, -1, 0, false) then
      self.RecallItemMap[PlayerKey] = uVehicle
      self:AddRecallTimer()
    end
  end
end
function VehicleSubsystem:RemoveHorseRecallItem(uPlayerCharacter, uVehicle, bForse)
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  if CGameState and CGameState:IsCreativeMode() then
    return
  end
  if self.RecallItemMap == nil then
    self.RecallItemMap = {}
  end
  local PlayerKey = uPlayerCharacter.PlayerKey
  if PlayerKey ~= nil and self.RecallItemMap[PlayerKey] ~= nil then
    if bForse then
      if Game:DropItem(PlayerKey, self.nRecallItemID, 1) then
        self.RecallItemMap[PlayerKey] = nil
        Game:UIShowTips(PlayerKey, 71137)
      end
    elseif slua.isValid(uVehicle) and self.RecallItemMap[PlayerKey] == uVehicle and Game:DropItem(PlayerKey, self.nRecallItemID, 1) then
      self.RecallItemMap[PlayerKey] = nil
      Game:UIShowTips(PlayerKey, 71137)
    end
  end
end
function VehicleSubsystem:AddRecallTimer()
  if self.RecallTimer ~= nil then
    return
  end
  self.RecallTimer = self:AddGameTimer(10, true, function()
    if self.RecallItemMap == nil then
      self:RemoveRecallTimer()
      return
    end
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local tRemovePlayerKey = {}
    local bFlag = true
    for PlayerKey, uVehicle in pairs(self.RecallItemMap) do
      bFlag = false
      local uPlayerCharacter = GameplayData.GetPlayerCharacter(PlayerKey)
      if slua.isValid(uVehicle) and slua.isValid(uPlayerCharacter) then
        local VehLoc = uVehicle:K2_GetActorLocation()
        local PlayerLoc = uPlayerCharacter:K2_GetActorLocation()
        local Dist = FVector.Distance(VehLoc, PlayerLoc)
        if Dist > self.RecallDistMax then
          table.insert(tRemovePlayerKey, PlayerKey)
        end
      end
    end
    if 0 < #tRemovePlayerKey then
      for Index, PlayerKey in pairs(tRemovePlayerKey) do
        local uPlayerCharacter = GameplayData.GetPlayerCharacter(PlayerKey)
        self:RemoveHorseRecallItem(uPlayerCharacter, nil, true)
      end
      tRemovePlayerKey = nil
    end
    if bFlag then
      self:RemoveRecallTimer()
    end
  end)
end
function VehicleSubsystem:RemoveRecallTimer()
  if self.RecallTimer ~= nil then
    self:RemoveGameTimer(self.RecallTimer)
  end
  self.RecallTimer = nil
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VehicleSubsystem)