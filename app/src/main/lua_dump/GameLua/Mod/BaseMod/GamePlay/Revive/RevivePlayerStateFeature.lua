local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UGameplayStatics = import("GameplayStatics")
local ENetRole = import("ENetRole")
local EBattleItemOperationType = import("EBattleItemOperationType")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local RevivePlayerStateFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function RevivePlayerStateFeature:ctor()
  self.bIsInRevivePlane = false
  self.fRevivalCardEndTime = -1.0
  self.TextId = 0
  self.bHaveSinglePlayerReviveItem = false
  self.bUseSinglePlayerReviveItem = false
  self.nReviveTime = 0
end
function RevivePlayerStateFeature:ReceiveBeginPlay()
  RevivePlayerStateFeature.__super.ReceiveBeginPlay(self)
  if not Client then
    self:AddGameTimer(3, false, function()
      self:ReviveItemsTipsInit()
    end)
  end
end
function RevivePlayerStateFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bHaveSinglePlayerReviveItem",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bUseSinglePlayerReviveItem",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "nReviveTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "fRevivalCardEndTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "TextId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function RevivePlayerStateFeature:OnRep_bHaveSinglePlayerReviveItem(oldValue)
  if self.Owner then
    EventSystem:postEvent(EVENTTYPE_HALLOWEEN2_NORMAL, EVENTID_HALLOWEEN2_REP_REVIVE_ITEM, self.Owner.Playerkey)
  end
end
function RevivePlayerStateFeature:GetHaveSinglePlayerReviveItem()
  return self.bHaveSinglePlayerReviveItem
end
function RevivePlayerStateFeature:SetHaveSinglePlayerReviveItem(bHave)
  if not Client then
    self.bHaveSinglePlayerReviveItem = bHave
    if bHave == false then
      if self.ReviveItemTips1 then
        self:RemoveGameTimer(self.ReviveItemTips1)
        self.ReviveItemTips1 = nil
      end
      if self.ReviveItemTips2 then
        self:RemoveGameTimer(self.ReviveItemTips2)
        self.ReviveItemTips2 = nil
      end
    end
  end
end
function RevivePlayerStateFeature:SetUseSinglePlayerReviveItem(bSendTlog)
  if not Client then
    self.bUseSinglePlayerReviveItem = true
    print(bWriteLog and "Set bUseSinglePlayerReviveItem:" .. tostring(self.bUseSinglePlayerReviveItem))
    if bSendTlog and self.Owner then
      self.Owner:AddGeneralCount(426, 1, false)
    end
  end
end
function RevivePlayerStateFeature:GetUseSinglePlayerReviveItem()
  return self.bUseSinglePlayerReviveItem
end
function RevivePlayerStateFeature:SetReviveTime(nTime, TextId)
  print(bWriteLog and "SetReviveTime SetReviveTime:" .. tostring(nTime) .. ", TextId = " .. tostring(TextId))
  self.nReviveTime = nTime
  if TextId then
    self.  end
end
function RevivePlayerStateFeature:OnRep_bUseSinglePlayerReviveItem(oldValue)
  print(bWriteLog and "OnRep_bUseSinglePlayerReviveItem:" .. tostring(self.bUseSinglePlayerReviveItem))
  if self.bUseSinglePlayerReviveItem then
    local ENetRole = import("ENetRole")
    local uCharacter
    if self.Owner then
      uCharacter = self.Owner:GetPlayerCharacter()
    end
    if uCharacter and slua.isValid(uCharacter) then
      print(bWriteLog and ":uCharacter.Role" .. tostring(uCharacter.Role))
      if uCharacter.Role == ENetRole.ROLE_AutonomousProxy then
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_REVIVE_SINGLE_PLAYER_ONPLAN)
      end
    end
  end
end
function RevivePlayerStateFeature:OnRep_nReviveTime()
  print(bWriteLog and "OnRep_nReviveTime--------:" .. tostring(self.nReviveTime))
  if not CGameState then
    return
  end
  if not self.Owner then
    return
  end
  local uCharacter = self.Owner:GetPlayerCharacter()
  if not uCharacter or not slua.isValid(uCharacter) then
    return
  end
  if uCharacter.Role == ENetRole.ROLE_AutonomousProxy then
    local WaitingTime = self.nReviveTime - CGameState:GetServerWorldTimeSeconds()
    if WaitingTime <= 0 then
      if UIManager.GetUI(UIManager.UI_Config_InGame.ReviveCountDownUI) ~= nil then
        UIManager.CloseUI(UIManager.UI_Config_InGame.ReviveCountDownUI)
      end
      return
    end
    local CountDownCfg = {
      CountDownTime = WaitingTime,
      CountDownTextId = 30508,
      CountDownRealTime = self.nReviveTime
    }
    if self.TextId ~= 0 then
      CountDownCfg.CountDownTextId = self.TextId
      self.TextId = 0
    end
    if UIManager.GetUI(UIManager.UI_Config_InGame.ReviveCountDownUI) == nil then
      UIManager.ShowUI(UIManager.UI_Config_InGame.ReviveCountDownUI, CountDownCfg)
      print(bWriteLog and "RevivePlayerStateFeature:ShowUI ReviveCountDownUI")
    else
      print(bWriteLog and "RevivePlayerStateFeature:ShowUI ReviveCountDownUI error")
    end
  end
end
function RevivePlayerStateFeature:CheckRepLiveState(nLiveState)
  if not Client or not SubsystemMgr then
    return
  end
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem and BattleResultSubSystem:InResultProcess() then
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState InResultProcess return")
    return
  end
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if nLiveState > ExtraPlayerLiveState.InPlane then
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState nLiveState return")
    return
  end
  local uPlayerController = UGameplayStatics.GetPlayerController(self.Owner, 0)
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState uPlayerController nil, return")
    return
  end
  log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState test1")
  if uPlayerController.bWaitRetryGotoSpectating and uPlayerController.bIsSpectating == false and uPlayerController.IsPureSpectator and not uPlayerController:IsPureSpectator() and not uPlayerController.bIsForReplay then
    local uPlayerState = uPlayerController.PlayerState
    if not slua.isValid(uPlayerState) then
      log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState uPlayerState nil, return")
      return
    end
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState test2")
    if uPlayerState.bHaveSinglePlayerReviveItem == true then
      log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState bHaveSinglePlayerReviveItem, return")
      return
    end
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState test3")
    local uBackpackComponent = uPlayerController.BackpackComponent
    if slua.isValid(uBackpackComponent) then
      local SelfReviveItemId = 0
      if CGameState then
        local ReviveState = CGameState.ReviveState
        if ReviveState and ReviveState.GetConfigSelfReviveItemId then
          SelfReviveItemId = ReviveState:GetConfigSelfReviveItemId()
        end
      end
      local nCount = uBackpackComponent:GetItemCountByItemSpecialID(SelfReviveItemId)
      if 0 < nCount then
        log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState have reival item, return")
        return
      end
    end
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState test4")
    if not self.Owner then
      return
    end
    if uPlayerState ~= self.Owner.Object and uPlayerState.LiveState == ExtraPlayerLiveState.InDied then
      local uCharacter = self.Owner:GetPlayerCharacter()
      if slua.isValid(uCharacter) and uPlayerController:IsTeamMate(uCharacter) then
        printf("RevivePlayerStateFeature:OnRep_PlayerLiveState GotoSpectating PlayerName[%s] LiveState[%d]", uCharacter:GetPlayerNameSafety(), nLiveState)
        uPlayerController:GotoSpectating(0)
      end
    end
    log(bWriteLog and "RevivePlayerStateFeature:OnRep_PlayerLiveState test5")
  end
end
function RevivePlayerStateFeature:ReviveItemsTipsInit()
  if not self.Owner or not self.Owner.GetOwner then
    return
  end
  local uPC = self.Owner:GetOwner()
  if not uPC then
    return
  end
  local uCharacter = uPC:GetPlayerCharacterSafety()
  if not Game:IsValid(uPC) or not Game:IsValid(uCharacter) then
    return
  end
  local uBackpackComponent = uPC.BackpackComponent
  if not uPC.BackpackComponent then
    return
  end
  local ItemOperCountDelegate = uBackpackComponent.ItemOperCountDelegate
  if not ItemOperCountDelegate then
    return
  end
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if not DSReviveSubsystem or not DSReviveSubsystem:GetItemReviveConfig() then
    return
  end
  if self.bHasReviveItemsTipsInit then
    return
  end
  self.bHasReviveItemsTipsInit = true
  ItemOperCountDelegate:Add(function(uDItemDefineID, nOperationType, nReason)
    if not slua.isValid(uCharacter) then
      return
    end
    local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
    local ItemReviveConfig = DSReviveSubsystem:GetItemReviveConfig()
    local SelfReviveItemId = ItemReviveConfig.ItemId
    local ItemLimitedTime = DSReviveSubsystem:GetClearRevivalCountTime(true)
    if uDItemDefineID and uDItemDefineID.TypeSpecificID == SelfReviveItemId and nOperationType == EBattleItemOperationType.Pickup and self.fRevivalCardEndTime <= 0 then
      self.bHaveSinglePlayerReviveItem = true
      if self.Owner and Game:IsAIController(self.Owner:GetOwner()) then
        local HaveTime = ItemLimitedTime - CGameState:GetServerWorldTimeSeconds()
        if HaveTime <= 0 then
          self.bHaveSinglePlayerReviveItem = false
        end
        return
      end
      if self.Owner and self.Owner:HasAuthority() then
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVE_PICK_UP_ITEM, self.Owner)
        local GameState = UGameplayStatics.GetGameState(self.Owner)
        if not slua.isValid(GameState) and GameState.ReviveState then
          return
        end
        self.Owner:AddGeneralCount(428, 1, false)
        local TempAreaID = math.floor(uCharacter:GetAttrValue("AreaID") + 0.5)
        self.fRevivalCardEndTime = ItemLimitedTime
        self:DSSetRevivalCardCountdown(TempAreaID <= 0)
      end
    end
  end)
end
function RevivePlayerStateFeature:ShowReviveAirLine(bReconnecting)
  if bReconnecting then
    local ds_net = require("ds_net")
    if self.bIsInRevivePlane and self.Owner and self.Owner.Plane and slua.isValid(self.Owner.Plane) then
      local param = {
        plane = self.Owner.Plane,
        start_x = self.Owner.Plane.MyFlyingData.PlaneStartLoc.X,
        start_y = self.Owner.Plane.MyFlyingData.PlaneStartLoc.Y,
        end_x = self.Owner.Plane.MyFlyingData.PlaneEndLoc.X,
        end_y = self.Owner.Plane.MyFlyingData.PlaneEndLoc.Y
      }
      local PlayerUID = tonumber(self.Owner.PlayerUID)
      ds_net.SendMessage("enter_plane", param, PlayerUID)
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_REVIVE_AIRLINE_INFO, self.Owner.PlayerUID, self.Owner.Plane, param.start_x, param.start_y, param.end_x, param.end_y)
    end
  end
end
function RevivePlayerStateFeature:SetIsInRevivePlane(bNewState)
  self.bIsInRevivePlane = bNewState
end
function RevivePlayerStateFeature:OnRep_fRevivalCardEndTime()
  print(bWriteLog and "RevivePlayerStateFeature:OnRep_fRevivalCardEndTime", self.fRevivalCardEndTime)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_PLAYER_REVIVE_TIME_CHANGE, self.fRevivalCardEndTime, self.Owner)
end
function RevivePlayerStateFeature:GetRevivalCardEndTime()
  return self.fRevivalCardEndTime
end
function RevivePlayerStateFeature:ShowTipsBeforeRevivalCardExpired()
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  local ItemReviveConfig = DSReviveSubsystem:GetItemReviveConfig()
  if ItemReviveConfig.TipsIDBeforeExpired and ItemReviveConfig.TipsIDWhenDestroy then
    self.fRevivalCardEndTime = DSReviveSubsystem:GetClearRevivalCountTime(true)
    local CurrentTime = CGameState:GetServerWorldTimeSeconds()
    local LeftTime = self.fRevivalCardEndTime - CurrentTime
    print(bWriteLog and "RevivePlayerStateFeature:ShowTipsBeforeRevivalCardExpired, LeftTime = " .. tostring(LeftTime))
    self:RefreshItemTimer(LeftTime, ItemReviveConfig.TipsIDWhenDestroy, ItemReviveConfig.TipsIDBeforeExpired)
  end
end
function RevivePlayerStateFeature:DSSetRevivalCardCountdown(bStart)
  if Client or not slua.isValid(CGameState) then
    return
  end
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  local ClearRevivalCountTime = DSReviveSubsystem:GetClearRevivalCountTime(true)
  local ItemReviveConfig = DSReviveSubsystem:GetItemReviveConfig()
  local CurrentTime = CGameState:GetServerWorldTimeSeconds()
  if self.fRevivalCardEndTime > 0 and CurrentTime > self.fRevivalCardEndTime then
    return
  end
  if not ItemReviveConfig or ItemReviveConfig.LeavePOIRemoveRevivalCardTime == nil then
    self:ShowTipsBeforeRevivalCardExpired()
    return
  end
  if bStart == true then
    if not ItemReviveConfig then
      return
    end
    local LeftTime = ItemReviveConfig.LeavePOIRemoveRevivalCardTime or 270
    if LeftTime > ClearRevivalCountTime - CurrentTime then
      LeftTime = ClearRevivalCountTime - CurrentTime
    end
    self.fRevivalCardEndTime = CurrentTime + LeftTime
  else
    self.fRevivalCardEndTime = ClearRevivalCountTime
  end
  local LeftTime = self.fRevivalCardEndTime - CurrentTime
  print(bWriteLog and "RevivePlayerStateFeature:DSSetRevivalCardCountdown LeftTime:", LeftTime)
  self:RefreshItemTimer(LeftTime, 11348, 11346)
end
function RevivePlayerStateFeature:RefreshItemTimer(ItemLeftTime, TipsID1, TipsID2)
  if self.ReviveItemTips1 then
    self:RemoveGameTimer(self.ReviveItemTips1)
    self.ReviveItemTips1 = nil
  end
  if self.ReviveItemTips2 then
    self:RemoveGameTimer(self.ReviveItemTips2)
    self.ReviveItemTips2 = nil
  end
  if 0 < ItemLeftTime then
    self.ReviveItemTips1 = self:AddGameTimer(ItemLeftTime, false, function()
      if self.bHaveSinglePlayerReviveItem and self.Owner and slua.isValid(CGameState) and CGameState.ReviveState then
        local uPlayer = self.Owner:GetPlayerCharacter()
        local SelfReviveItemId = CGameState.ReviveState:GetConfigSelfReviveItemId()
        Game:ConsumeItem(uPlayer, SelfReviveItemId, 1)
        Game:UIShowImageSAPTips(self.Owner.PlayerKey, TipsID1)
      end
      self.ReviveItemTips1 = nil
      self.bHaveSinglePlayerReviveItem = false
    end)
  else
    self.bHaveSinglePlayerReviveItem = false
  end
  local OneMinuteTipsTime = ItemLeftTime - 60
  if 0 < OneMinuteTipsTime then
    self.ReviveItemTips2 = self:AddGameTimer(OneMinuteTipsTime, false, function()
      if self.bHaveSinglePlayerReviveItem then
        self.ReviveItemTips2 = nil
        if self.Owner then
          Game:UIShowImageSAPTips(self.Owner.PlayerKey, TipsID2)
        end
      end
    end)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CRevivePlayerStateFeature = class(CFeatureBase, nil, RevivePlayerStateFeature)
return CRevivePlayerStateFeature