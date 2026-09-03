local BRPlayerStateBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function BRPlayerStateBase:ctor()
  self.LastDeadType = 0
  self.LastDeadLoc = nil
  self.InviteValidTime = -1.0
end
function BRPlayerStateBase:_PostConstruct()
  BRPlayerStateBase.__super._PostConstruct(self)
  if self:HasAuthority() then
    self.CanUseFlaregun = true
    self.DungeonId = 0
  end
end
function BRPlayerStateBase:ReceiveBeginPlay()
  BRPlayerStateBase.__super.ReceiveBeginPlay(self)
  if self:HasAuthority() then
    self:AddControlEvent(self.Object, "OnCharacterOwnerUpdate", self.HandleOnCharacterOwnerUpdate, self)
  end
end
function BRPlayerStateBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerStateBase.__super.ReceiveEndPlay(self, EndPlayReason)
end
function BRPlayerStateBase:GetLifetimeReplicatedProps()
  local BaseRepTable = BRPlayerStateBase.__super.GetLifetimeReplicatedProps(self) or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "CanUseFlaregun",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "DungeonId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "InviteValidTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    },
    {
      "LuaRepCharacterMainType",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function BRPlayerStateBase:HandleOnCharacterOwnerUpdate()
  if not Client and slua.isValid(self.CharacterOwner) then
    self.LuaRepCharacterMainType = self.CharacterOwner:GetCharacterMainType()
    print(bWriteLog and "BRPlayerStateBase:HandleOnCharacterOwnerUpdate", self.PlayerKey, self.PlayerName, self.LuaRepCharacterMainType)
  end
end
function BRPlayerStateBase:GetHaveSinglePlayerReviveItem()
  return self.ReviveStateFeature:GetHaveSinglePlayerReviveItem()
end
function BRPlayerStateBase:SetHaveSinglePlayerReviveItem(bHave)
  self.ReviveStateFeature:SetHaveSinglePlayerReviveItem(bHave)
end
function BRPlayerStateBase:SetUseSinglePlayerReviveItem(bSendTlog)
  self.ReviveStateFeature:SetUseSinglePlayerReviveItem(bSendTlog)
end
function BRPlayerStateBase:GetUseSinglePlayerReviveItem()
  return self.ReviveStateFeature:GetUseSinglePlayerReviveItem()
end
function BRPlayerStateBase:SetReviveTime(nTime, TextId)
  self.ReviveStateFeature:SetReviveTime(nTime, TextId)
end
function BRPlayerStateBase:ShowReviveAirLine(bReconnecting)
  self.ReviveStateFeature:ShowReviveAirLine(bReconnecting)
end
function BRPlayerStateBase:SetIsInRevivePlane(bNewState)
  self.ReviveStateFeature:SetIsInRevivePlane(bNewState)
end
function BRPlayerStateBase:OnRep_PlayerLiveState()
  BRPlayerStateBase.__super.OnRep_PlayerLiveState(self)
  log(bWriteLog and "BRPlayerStateBase:OnRep_PlayerLiveState LiveState " .. self.LiveState)
  if self.ReviveStateFeature and self.ReviveStateFeature.CheckRepLiveState then
    self.ReviveStateFeature:CheckRepLiveState(self.LiveState)
  end
end
function BRPlayerStateBase:SetDungeonId(DungeonId)
  self.  print(bWriteLog and string.format("BRPlayerStateBase:SetDungeonId %s", DungeonId))
  self:ForceNetUpdate()
end
function BRPlayerStateBase:IsInDungeon()
  return self.DungeonId > 0
end
function BRPlayerStateBase:OnRep_DungeonId()
  print(bWriteLog and string.format("BRPlayerStateBase:OnRep_DungeonId %s", self.DungeonId))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_DUNGEON_ID_CHANGED, self.PlayerKey, self.DungeonId)
  local uPlayerCharacter = self:GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and (uPlayerCharacter:IsLocallyControlled() or uPlayerCharacter:IsLocalViewed()) then
    self:CheckDungeon(uPlayerCharacter)
  end
end
function BRPlayerStateBase:CheckDungeon(uPlayerCharacter)
  local Controller = uPlayerCharacter:GetControllerSafety()
  if slua.isValid(Controller) and slua.isValid(Controller.BP_FourInOneSoftBoundCheckComponent) then
    local IsEnter = self:IsInDungeon()
    print(bWriteLog and string.format("BRPlayerStateBase:CheckDungeon BP_FourInOneSoftBoundCheckComponent.bSetPawnNotInBounds = %s", IsEnter))
    Controller.BP_FourInOneSoftBoundCheckComponent.bSetPawnNotInBounds = IsEnter
    if not IsEnter then
      Controller.bForceShowBlueCircleEffect = false
    else
      local ScreenAppearanceStatics = import("ScreenAppearanceStatics")
      if ScreenAppearanceStatics.IsScreenAppearancePlaying(Controller, Controller, "CirclePain") then
        ScreenAppearanceStatics.StopScreenAppearanceByName(Controller, Controller, "CirclePain")
        Controller.BP_FourInOneSoftBoundCheckComponent:OnInsideSoftBoundStatusChanged(true)
      end
    end
  end
end
function BRPlayerStateBase:OnRep_InviteValidTime()
  print(bWriteLog and string.format("BRPlayerStateBase:OnRep_InviteValidTime %s", tostring(self.InviteValidTime)))
end
function BRPlayerStateBase:OnRep_LuaRepCharacterMainType()
  print(bWriteLog and string.format("BRPlayerStateBase:OnRep_LuaRepCharacterMainType %s", tostring(self.LuaRepCharacterMainType)))
end
function BRPlayerStateBase:SetLastDeadInfo(Pawn, Killer, TypeID)
  if not Client then
    if slua.isValid(Killer) then
      if Game:IsPlayer(Killer) then
        self.LastDeadType = 2
      else
        self.LastDeadType = 3
      end
    else
      self.LastDeadType = 1
    end
    print(bWriteLog and "BRPlayerStateBase:SetLastDeadInfo LastDeadType = " .. tostring(self.LastDeadType))
    if slua.isValid(Pawn) then
      self.LastDeadLoc = Pawn:K2_GetActorLocation()
    end
  end
end
BRPlayerStateBase.ClientRPC.RPC_Client_PromptCharacterTeleport = {
  Reliable = true,
  Params = {}
}
function BRPlayerStateBase:RPC_Client_PromptCharacterTeleport()
  local CommonConfirm = require("GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local DungeonConfig = GamePlayTools.GetCurrentConfig("DungeonConfig")
  local Config = DungeonConfig.Default.Character.TeamInvite
  local PromptTextIds = Config.PromptTextIds
  local CountdownTime = Config.CountdownTime
  local ConfirmInfo = {
    Style = "Simple",
    Content = LocUtil.GetLocalizeResStr(PromptTextIds.Content),
    LeftLable = LocUtil.GetLocalizeResStr(PromptTextIds.Reject),
    RightLable = LocUtil.GetLocalizeResStr(PromptTextIds.Accept),
    LeftCountDownTime = CountdownTime.Left,
    RightCountDownTime = CountdownTime.Right,
    CountDownEndTime = CountdownTime.Right + CGameState:GetServerWorldTimeSeconds(),
    RightLableColorAndOpacity = FSlateColor(FLinearColor(1, 0.723055, 0.015209, 1))
  }
  function ConfirmInfo.RightCB()
    print(bWriteLog and "BRPlayerStateBase:RPC_Client_PromptCharacterTeleport - Confirm Teleport")
    self:RPC_Server_CharacterComfirmTeleport()
  end
  function ConfirmInfo.CloseCB()
    print(bWriteLog and "BRPlayerStateBase:RPC_Client_PromptCharacterTeleport - Close")
  end
  CommonConfirm.ShowConfirm(ConfirmInfo)
end
BRPlayerStateBase.ServerRPC.RPC_Server_CharacterComfirmTeleport = {
  Reliable = true,
  Params = {}
}
function BRPlayerStateBase:RPC_Server_CharacterComfirmTeleport()
  if self.InviteValidTime < 0 then
    print(bWriteLog and "BRPlayerStateBase:RPC_Server_CharacterComfirmTeleport - InviteValidTime invalid")
    return
  end
  local nCurTime = CGameState:GetServerWorldTimeSeconds()
  if nCurTime > self.InviteValidTime then
    print(bWriteLog and string.format("BRPlayerStateBase:RPC_Server_CharacterComfirmTeleport - Invite expired nCurTime[%s] > InviteValidTime[%s]", tostring(nCurTime), tostring(self.InviteValidTime)))
    self.InviteValidTime = -1.0
    return
  end
  print(bWriteLog and "BRPlayerStateBase:RPC_Server_CharacterComfirmTeleport - Confirm Teleport")
  local PlayerCharacter = self:GetPlayerCharacter()
  if not (slua.isValid(PlayerCharacter) and slua.isValid(CGameMode)) or not CGameMode.DungeonFeature then
    print(bWriteLog and "BRPlayerStateBase:RPC_Server_CharacterComfirmTeleport - Invalid PlayerCharacter")
    return
  end
  local DungeonFeature = CGameMode.DungeonFeature
  if DungeonFeature and DungeonFeature.HandleTeamMateConfirmTeleport then
    DungeonFeature:HandleTeamMateConfirmTeleport(PlayerCharacter)
  else
    print(bWriteLog and "BRPlayerStateBase:RPC_Server_CharacterComfirmTeleport - GameModeBaseDungeonFeature not found")
  end
end
function BRPlayerStateBase:GetLastDeadType()
  return self.LastDeadType
end
function BRPlayerStateBase:GetLastDiedPosition()
  return self.LastDeadLoc
end
local class = require("class")
local CPlayerStateBase = require("GameLua.GameCore.Framework.PlayerStateBase")
local CBRPlayerStateBase = class(CPlayerStateBase, nil, BRPlayerStateBase)
return require("combine_class").DeclareFeature(CBRPlayerStateBase, {
  {
    ReviveStateFeature = "GameLua.Mod.BaseMod.GamePlay.Revive.RevivePlayerStateFeature"
  },
  {
    ItemPickUpGuideFeature = "GameLua.Mod.BaseMod.GamePlay.Store.ItemPickUpGuideFeature"
  },
  {
    BlazingFeature = "GameLua.Mod.BRMod.Gameplay.Feature.Blazing.PlayerStateBlazingFeature"
  },
  {
    PromotionFeature = "GameLua.Mod.BRMod.Gameplay.Feature.Promotion.PlayerStatePromotionFeature"
  }
}, "BRPlayerStateBase")