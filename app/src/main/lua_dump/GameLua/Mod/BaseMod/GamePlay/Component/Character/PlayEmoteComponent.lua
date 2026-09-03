local PlayEmoteComponent = {}
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local IsTable = SecurityCommonUtils.IsTable
function PlayEmoteComponent:ctor()
  print(bWriteLog and "LuaPlayEmoteComponent:ctor")
  self.IsInDanceTogether = false
end
function PlayEmoteComponent:ReceiveBeginPlay()
  PlayEmoteComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "LuaPlayEmoteComponent:ReceiveBeginPlay()")
  if not slua.isValid(self.CharacterOwner) then
    self.CharacterOwner = self:GetOwner()
    if not slua.isValid(self.CharacterOwner) then
      return
    end
  end
  if Client and slua.isValid(self.CharacterOwner) and self.CharacterOwner:IsLocallyControlled() then
    print(bWriteLog and "LuaPlayEmoteComponent:ReceiveBeginPlay Client")
    self:AddGameTimer(3, true, function()
      if self.CurrentLoadedEmoteSequence ~= nil and not self:IsPlayingEmotes() and slua.isValid(self.CharacterOwner) and not self.CharacterOwner:HasState(EPawnState.PlayEmote) then
        print(bWriteLog and "LuaPlayEmoteComponent:ReceiveBeginPlay StopPlayEmoteAnim")
        self:StopPlayEmoteAnim(-1)
      end
      if self.CurrentLoadedEmoteSequence ~= nil and not self.CharacterOwner:HasState(EPawnState.PlayEmote) and slua.isValid(self.CharacterOwner) and self:IsPlayingEmotes() then
        print(bWriteLog and "LuaPlayEmoteComponent:ReceiveBeginPlay OnInterruptCurrentEmote")
        self:OnInterruptCurrentEmote()
      end
    end)
  end
end
function PlayEmoteComponent:ReceiveEndPlay(EndReason, bClearTable)
  self:StopPlayEmoteAnim(self.CurrentEmoteIndex)
  PlayEmoteComponent.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function PlayEmoteComponent:CheckCanShowFollowPlayEmote(EmotePlayer)
  local EmoteID = EmotePlayer.EmoteId
  if self.CharacterOwner == nil then
    return false
  end
  if self:IsCommonFollowTeam(EmotePlayer) then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote self:IsCommonFollowTeam")
    return false
  end
  if EmotePlayer.FollowPlayer == self.CharacterOwner.PlayerKey then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote EmotePlayer.FollowPlayer == self.PlayerKey " .. tostring(self.CharacterOwner.PlayerKey))
    return false
  end
  local EmoteHandlePath = self.CharacterOwner:GetEmoteHandlePath(EmoteID)
  local UEPathUtilityMethods = import("UEPathUtilityMethods")
  local ItemPathExist = UEPathUtilityMethods.IsAvatarResPathExist(EmoteHandlePath)
  if not ItemPathExist then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote not ItemPathExist")
    return false
  end
  local FollowEmoteCfg = CDataTable.GetTableData("FollowEmoteCfg", EmoteID)
  if FollowEmoteCfg and FollowEmoteCfg.CanShowButton == 0 then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote FollowEmoteCfg CanShowButton is false")
    return false
  end
  if self:IsPlayingEmotes() then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote is IsPlayingEmotes")
    return false
  end
  if not self:IsCanPlayEmote(EmoteID, false) then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote IsCanPlayEmote false1")
    return false
  end
  if self:IsInteractiveExpression(EmoteID) then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote IsInteractiveExpression")
    return false
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.CheckIsDanceTogetherEmote(EmoteID) then
    return false
  end
  if logic_emote.IsMileStoneEmote(EmoteID) then
    return false
  end
  if logic_emote.IsCustomWeaponShow(EmoteID) then
    return false
  end
  if logic_emote.IsAceImprintEmote(EmoteID) then
    return false
  end
  local HomePartyProxy = require("client.slua.logic.homeparty.HomePartyProxy")
  if HomePartyProxy:IsDanceLeadEmote(EmoteID) then
    printf("PlayEmoteComponent:CheckCanShowFollowPlayEmote HomePartyProxy:IsDanceLeadEmote")
    return false
  end
  local MCActionSubsystem = SubsystemMgr:Get("MCActionSubsystem")
  if MCActionSubsystem and MCActionSubsystem:IsForbidFollowEmote(EmoteID) then
    log(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote MCActionSubsystem:IsForbidFollowEmote emoteID=" .. tostring(EmoteID))
    return false
  end
  if self.CharacterOwner.PlayerState then
    local InteractivePlayerStateFeature = self.CharacterOwner.PlayerState.InteractivePlayerStateFeature
    local InteractiveState
    if InteractivePlayerStateFeature then
      InteractiveState = InteractivePlayerStateFeature.InteractiveState
    else
      InteractiveState = self.CharacterOwner.PlayerState.InteractiveState or 0
    end
    if 1 < InteractiveState then
      print(bWriteLog and "BP_PlayerPawn_SI CheckCanShowFollowPlayEmote Is InteractiveState " .. tostring(InteractiveState))
      return false
    end
  end
  if self:IsHighlightEmote(EmoteID) then
    print(bWriteLog and "PlayEmoteComponent:CheckCanShowFollowPlayEmote IsHighlightEmote" .. tostring(EmoteID))
    return false
  end
  return true
end
function PlayEmoteComponent:IsCanPlayEmoteLua(EmoteId, ShowTips)
  local EmoteCheckConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.EmoteCheckConfig")
  if EmoteCheckConfig and EmoteCheckConfig[EmoteId] and EmoteCheckConfig[EmoteId].FloatingCheck then
    local IgnoreActors = {}
    local ActorLoc = self:GetOwner():K2_GetActorLocation()
    local ActorRot = self:GetOwner():K2_GetActorRotation()
    for _, location in pairs(EmoteCheckConfig[EmoteId].FloatingCheck) do
      local WorldPos = ActorLoc + ActorRot:RotateVector(location)
      local HitResult
      local bIsHit, HitResult = self:FloatingCheckWhenPlay(HitResult, WorldPos, FVector(WorldPos.X, WorldPos.Y, WorldPos.Z - 100), IgnoreActors)
      if not bIsHit then
        if ShowTips then
          local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
          if slua.isValid(uPlayerController) then
            uPlayerController:DisplayGameTipWithMsgID(34434)
          end
        end
        return false
      end
    end
  end
  return true
end
function PlayEmoteComponent:CheckIsValidXSuitBornIslandAction(EmoteID)
  print(bWriteLog and "PlayEmoteComponent:CheckIsValidXSuitBornIslandAction EmoteID:" .. tostring(EmoteID))
  if self.CharacterOwner == nil then
    return false
  end
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) or not uPlayerController.CommerFeature then
    return false
  end
  local uAvatarComp2 = self.CharacterOwner:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if XSuitUtil:GetBornIslandActionByItemID(AvatarItem.TypeSpecificID, uAvatarComp2) ~= EmoteID then
    return false
  end
  local Period = XSuitUtil:GetPeriodByBattleActionID(EmoteID)
  if Period and 0 < Period then
    local UnLockLevel = XSuitUtil:GetUnLockLevelByFeature(AvatarItem.TypeSpecificID, Period, uPlayerController.CommerFeature.XSuitUnlockLevelList)
    local bValid = XSuitUtil:IsValidBornIslandAction(EmoteID, UnLockLevel)
    print(bWriteLog and "PlayEmoteComponent:CheckIsValidXSuitBornIslandAction bValid=" .. tostring(bValid) .. " EmoteID=" .. tostring(EmoteID) .. " Period=" .. tostring(Period) .. " UnLockLevel=" .. tostring(UnLockLevel))
    if not bValid then
      return false
    end
  end
  return true
end
function PlayEmoteComponent:CheckCanFollowPlayEmote(EmoteId)
  if not EmoteId or EmoteId == 0 then
    print(bWriteLog and "PlayEmoteComponent:CheckCanFollowPlayEmote Can`t Play EmoteId" .. tostring(EmoteId))
    return false
  end
  if self.CharacterOwner == nil then
    return false
  end
  local FollowEmoteCfg = CDataTable.GetTableData("FollowEmoteCfg", EmoteId)
  if FollowEmoteCfg and FollowEmoteCfg.CanPlay == 0 then
    print(bWriteLog and "PlayEmoteComponent:CheckCanFollowPlayEmote No CanPlay" .. tostring(EmoteId) .. "TipsID: " .. tostring(FollowEmoteCfg.TipsID))
    local TipsID = 44697
    if FollowEmoteCfg.TipsID and FollowEmoteCfg.TipsID ~= 0 then
      TipsID = FollowEmoteCfg.TipsID
    end
    local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(TipsID)
    end
    return false
  end
  if self:IsInteractiveExpression(EmoteId) then
    local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(44697)
    end
    print(bWriteLog and "PlayEmoteComponent:CheckCanFollowPlayEmote IsInteractiveExpression" .. tostring(EmoteId))
    return false
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.IsCustomWeaponShow(EmoteId) then
    return false
  end
  if self:IsHighlightEmote(EmoteId) then
    print(bWriteLog and "PlayEmoteComponent:CheckCanFollowPlayEmote IsHighlightEmote" .. tostring(EmoteId))
    return false
  end
  return true
end
function PlayEmoteComponent:IsInteractiveExpression(EmoteID)
  local ItemCfg = CDataTable.GetTableData("Item", EmoteID)
  if ItemCfg and ItemCfg.ItemSubType == 2205 then
    return true
  end
  return false
end
function PlayEmoteComponent:IsHighlightEmote(EmoteID)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local HighlightMomentConfig = GamePlayTools.GetCurrentConfig("HighlightMomentConfig")
  for Idx, Config in pairs(HighlightMomentConfig) do
    if Config and IsTable(Config) and Config.EmoteID == EmoteID then
      return true
    end
  end
  if HighlightMomentConfig and HighlightMomentConfig.CheckFreeEmoteID and HighlightMomentConfig.CheckFreeEmoteID[EmoteID] then
    return true
  end
  return false
end
function PlayEmoteComponent:IsInDanceStageList(EmoteID)
  local DanceConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.DanceConfig")
  return DanceConfig.EmoteListInDanceStage[EmoteID]
end
function PlayEmoteComponent:CheckEmoteSituation(EmoteID)
  if self.CharacterOwner then
    local DanceStageAreaState = self.CharacterOwner:GetAttrValue("DanceStageAreaState")
    if (DanceStageAreaState == UEnums.EDanceStageState.EState_OnlyInArea or DanceStageAreaState == UEnums.EDanceStageState.EState_InAreaAndDance) and not self:IsInDanceStageList(EmoteID) then
      print(bWriteLog and "PlayEmoteComponent:CheckEmoteSituation not in DanceStageList:", EmoteID)
      local uPlayerController = self.CharacterOwner:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) then
        uPlayerController:DisplayGameTipWithMsgID(73239)
      end
      return false
    end
  end
  return true
end
function PlayEmoteComponent:ServerCheckIsCanPlay(EmoteID, ExtraInfo)
  if self.CharacterOwner == nil then
    return false
  end
  if self:IsValidMileStoneEmote(EmoteID) then
    return true
  end
  if self:IsValidCustomWeaponShow(EmoteID) then
    return true
  end
  return false
end
function PlayEmoteComponent:IsValidMileStoneEmote(EmoteID)
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if not logic_emote.IsMileStoneEmote(EmoteID) then
    return false
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local MileStoneDatas = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(self.CharacterOwner.PlayerUID), ExtendAttribute.MileStoneDataNew)
  if not MileStoneDatas then
    print(bWriteLog and "[MileStone]PlayEmoteComponent:ServerCheckIsCanPlay not MileStoneData" .. tostring(self.CharacterOwner.PlayerUID))
    return false
  end
  for key, MileStoneData in pairs(MileStoneDatas) do
    local TableUtil = require("common.table_util")
    if TableUtil.Find(MileStoneData.expression_list, EmoteID) > 0 then
      local StringUtil = require("common.string_util")
      local Array = StringUtil.Split(ExtraInfo, "|")
      for key, ItemIDString in pairs(Array) do
        local ItemID = tonumber(ItemIDString)
        if ItemID and 0 < ItemID and 0 > TableUtil.Find(MileStoneData.stone_data, ItemID) then
          return false
        end
      end
      return true
    end
  end
  return false
end
function PlayEmoteComponent:IsValidCustomWeaponShow(EmoteID)
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local SkinID = logic_emote.GetCustomWeaponItemID(EmoteID)
  if not SkinID or SkinID <= 0 then
    return false
  end
  if self.CharacterOwner:CheckIsWearingThisCloth(SkinID) then
    return true
  end
  return false
end
function PlayEmoteComponent:CheckCanPlayDanceEmote(EmoteIndex)
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.CheckIsDanceTogetherEmote(EmoteIndex) then
    local EmoteSubSystem = SubsystemMgr:Get("EmoteSubSystem")
    if EmoteSubSystem:IsInPreListOrDanceList(self:GetOwner().Object) then
      return true
    end
  end
  return false
end
function PlayEmoteComponent:NeedEmoteTimeBuffer(EmoteID)
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.IsMileStoneEmote(EmoteID) then
    return false
  end
  return true
end
local Class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local PlayEmoteComponentClass = Class(CActorComponentBase, nil, PlayEmoteComponent)
return PlayEmoteComponentClass