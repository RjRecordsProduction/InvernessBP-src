local ReviveGameStateFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function ReviveGameStateFeature:ctor()
  self.ReviveTimer = nil
  self.nDefaultRevivalCount = 0
  self.nSelfReviveItemId = 0
  self.nItemWaitingTime = 0
  self.nItemLimitedTime = 0
  self.nHelicopterWaitingTime = 0
  self.nHelicopterLimitedTime = 0
end
function ReviveGameStateFeature:ReceiveBeginPlay()
  ReviveGameStateFeature.__super.ReceiveBeginPlay(self)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  print(bWriteLog and " ReviveGameStateFeature:AddReconnected Event")
  if GameplayData.AddGameStateEvent then
    GameplayData.AddGameStateEvent(self, "OnServerGameRecovered", self.HandleReviveReconnect, self)
  end
  print(bWriteLog and " ReviveGameStateFeature:ReceiveBeginPlay")
  self:SetDefaultRevivalConfig()
end
function ReviveGameStateFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "nReviveEndTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "nDefaultRevivalCount",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nSelfReviveItemId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nItemWaitingTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nItemLimitedTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nHelicopterWaitingTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nHelicopterLimitedTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function ReviveGameStateFeature:SetDefaultRevivalConfig()
  if Client then
    return
  end
  local RevivalCount = 0
  local SelfReviveItemId = 0
  local ItemWaitingTime = 0
  local ItemLimitedTime = 0
  local HelicopterWaitingTime = 0
  local HelicopterLimitedTime = 0
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if DSReviveSubsystem then
    RevivalCount = DSReviveSubsystem:GetInitRevivalCount()
    local ItemReviveConfig = DSReviveSubsystem:GetItemReviveConfig()
    if ItemReviveConfig then
      SelfReviveItemId = ItemReviveConfig.ItemId
      ItemWaitingTime = ItemReviveConfig.WaitingTime
      ItemLimitedTime = DSReviveSubsystem:GetClearRevivalCountTime(true)
    end
    local HelicopterConfig = DSReviveSubsystem:GetHelicopterReviveConfig()
    if HelicopterConfig then
      HelicopterWaitingTime = HelicopterConfig.WaitingTime
      HelicopterLimitedTime = DSReviveSubsystem:GetClearRevivalCountTime()
    end
  else
    print(bWriteLog and "ReviveGameStateFeature:SetDefaultRevivalConfig, DSReviveSubsystem = nil")
  end
  self.nDefault  self.n  self.n  self.n  self.n  self.n  print(bWriteLog and "ReviveGameStateFeature:SetDefaultRevivalConfig, RevivalCount = " .. tostring(RevivalCount) .. ", SelfReviveItemId = " .. tostring(SelfReviveItemId) .. ", ItemWaitingTime = " .. tostring(ItemWaitingTime) .. ", ItemLimitedTime = " .. tostring(ItemLimitedTime) .. ", HelicopterWaitingTime = " .. tostring(HelicopterWaitingTime) .. ", HelicopterLimitedTime = " .. tostring(HelicopterLimitedTime))
end
function ReviveGameStateFeature:OnRep_nDefaultRevivalCount()
  print(bWriteLog and "ReviveGameStateFeature:OnRep_nDefaultRevivalCount, self.nDefaultRevivalCount = " .. tostring(self.nDefaultRevivalCount))
end
function ReviveGameStateFeature:GetDefaultRevivalCount()
  return self.nDefaultRevivalCount
end
function ReviveGameStateFeature:OnRep_nSelfReviveItemId()
  print(bWriteLog and "ReviveGameStateFeature:OnRep_nSelfReviveItemId, self.nSelfReviveItemId = " .. tostring(self.nSelfReviveItemId))
end
function ReviveGameStateFeature:GetConfigSelfReviveItemId()
  return self.nSelfReviveItemId
end
function ReviveGameStateFeature:OnRep_nItemWaitingTime()
  print(bWriteLog and "ReviveGameStateFeature:OnRep_nItemWaitingTime, self.nItemWaitingTime = " .. tostring(self.nItemWaitingTime))
end
function ReviveGameStateFeature:GetConfigItemWaitingTime()
  return self.nItemWaitingTime
end
function ReviveGameStateFeature:OnRep_nItemLimitedTime()
  print(bWriteLog and "ReviveGameStateFeature:OnRep_nItemLimitedTime, self.nItemLimitedTime = " .. tostring(self.nItemLimitedTime))
end
function ReviveGameStateFeature:GetConfigItemLimitedTime()
  return self.nItemLimitedTime
end
function ReviveGameStateFeature:OnRep_nHelicopterWaitingTime()
  print(bWriteLog and "ReviveGameStateFeature:OnRep_nHelicopterWaitingTime, self.nHelicopterWaitingTime = " .. tostring(self.nHelicopterWaitingTime))
end
function ReviveGameStateFeature:GetConfigHelicopterWaitingTime()
  return self.nHelicopterWaitingTime
end
function ReviveGameStateFeature:OnRep_nHelicopterLimitedTime()
  print(bWriteLog and "ReviveGameStateFeature:OnRep_nHelicopterLimitedTime, self.nHelicopterLimitedTime = " .. tostring(self.nHelicopterLimitedTime))
end
function ReviveGameStateFeature:GetConfigHelicopterLimitedTime()
  return self.nHelicopterLimitedTime
end
function ReviveGameStateFeature:SetReviveEndTime(nTime)
  print(bWriteLog and "ReviveGameStateFeature SetReviveEndTime SetReviveTime:" .. tostring(nTime))
  self.nReviveEndTime = nTime
  if not Client and self.nReviveEndTime > 0 then
    if self.ReviveTimer then
      self:RemoveGameTimer(self.ReviveTimer)
      self.ReviveTimer = nil
    end
    if CGameState then
      local CurTime = CGameState:GetServerWorldTimeSeconds()
      if CurTime < self.nReviveEndTime then
        local nReviveRestTime = self.nReviveEndTime - CurTime
        print(bWriteLog and "ReviveGameStateFeature nReviveRestTime:" .. tostring(nReviveRestTime))
        self.ReviveTimer = self:AddGameTimer(nReviveRestTime, false, function()
          print(bWriteLog and "ReviveGameStateFeature MulticastRPC.MulticastPlayClickSound")
          self:MulticastRevivalTimeEnd()
        end)
      end
    end
  end
end
function ReviveGameStateFeature:GetReviveEndTime()
  return self.nReviveEndTime
end
function ReviveGameStateFeature:OnRep_nReviveEndTime()
  print(bWriteLog and "ReviveGameStateFeature OnRep_nReviveEndTime nReviveEndTime:" .. tostring(self.nReviveEndTime))
  if self.nReviveEndTime > 0 then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVAL_TIME_END_UPDATE)
  end
end
function ReviveGameStateFeature:CheckReviveTimeEnd()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return 0
  end
  local ReviveEndTime = 0
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.ReviveState then
    print(bWriteLog and "ReviveGameStateFeature:CheckReviveTimeEnd GameState = nil")
    return
  end
  if GameState.GetReviveEndTime then
    ReviveEndTime = GameState:GetReviveEndTime() or 0
  end
  local CurServerTime = GamePlayTools.GetServerWorldTimeSeconds() or 0
  if ReviveEndTime <= 0 then
    print(bWriteLog and "ReviveGameStateFeature: !!!!!!!!!!Ops ReviveEndTime = ", ReviveEndTime)
  end
  return ReviveEndTime - CurServerTime < 0 and true or false
end
ReviveGameStateFeature.MulticastRPC.MulticastRevivalTimeEnd = {
  Reliable = true,
  Params = {}
}
function ReviveGameStateFeature:MulticastRevivalTimeEnd()
  print(bWriteLog and "ReviveGameStateFeature MulticastRevivalTimeEnd")
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVAL_TIME_END)
end
function ReviveGameStateFeature:HandleReviveReconnect(uPlayerController)
  if not slua.isValid(uPlayerController) then
    return
  end
  print(bWriteLog and "ReviveGameStateFeature:HandleReviveReconnect Reconnected is", uPlayerController.bReconnected)
  local uPlayerState = uPlayerController.PlayerState
  if uPlayerController.bReconnected then
    if slua.isValid(uPlayerState) and uPlayerState.ReviveStateFeature then
      uPlayerState.ReviveStateFeature:ShowReviveAirLine(true)
      print(bWriteLog and "ReviveGameStateFeature:HandleReviveReconnect ShowReviveAirLine when Reconnected")
    else
      print(bWriteLog and "ReviveGameStateFeature:HandleReviveReconnect PlayerState or ReviveStateFeature is nil")
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CReviveGameStateFeature = class(CFeatureBase, nil, ReviveGameStateFeature)
return CReviveGameStateFeature