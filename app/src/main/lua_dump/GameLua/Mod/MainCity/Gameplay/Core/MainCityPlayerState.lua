local MainCityPlayerState = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local EMask = require("GameLua.Mod.MainCity.Gameplay.Core.MainCityCoreConst").EMainCityInteractiveStateTypeFlag
function MainCityPlayerState:ctor()
end
function MainCityPlayerState:_PostConstruct()
  MainCityPlayerState.__super._PostConstruct(self)
  self.Charm = 0
  self.CharmLevel_Client = -1
end
function MainCityPlayerState:ReceiveBeginPlay()
  MainCityPlayerState.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "MainCityPlayerState:ReceiveBeginPlay")
  local character = self:GetPlayerCharacter()
  if slua.isValid(character) and character.RefreshInteractState then
    character:RefreshInteractState()
  end
end
function MainCityPlayerState:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "MainCityPlayerState:ReceiveEndPlay")
  MainCityPlayerState.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MainCityPlayerState:GetLifetimeReplicatedProps()
  local BaseRepTable = MainCityPlayerState.__super:GetLifetimeReplicatedProps() or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "Charm",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function MainCityPlayerState:WaitForValidCharacter(callback)
  local timer
  timer = self:AddGameTimer(0.1, true, function()
    if not slua.isValid(self.Object) then
      if timer then
        self:RemoveGameTimer(timer)
        timer = nil
      end
      return
    end
    if self.GetPlayerCharacter then
      local character = self:GetPlayerCharacter()
      if Game:IsValid(character) then
        callback(character)
        self:RemoveGameTimer(timer)
        timer = nil
      end
    end
  end)
end
function MainCityPlayerState:HandlerOnCharmChanged_Client()
  local CharmValue = self.Charm
  local CharmUtils = require("GameLua.Mod.MainCity.Client.logic.Charm.CharmUtils")
  local CharmLevel = CharmUtils.CalculateCharmLevel(CharmValue)
  self.CharmLevel_Client = CharmLevel
  printf("MainCityPlayerState:HandlerOnCharmChanged_Client Charm: %s, CharmLevel: %s", CharmValue, CharmLevel)
  self:WaitForValidCharacter(function(uMainCityCharacter)
    local sPlayerUID = self:GetUIDString()
    local nPlayerUID = tonumber(sPlayerUID)
    local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
    local isFriend = logic_new_friend.IsMyFriend(nPlayerUID)
    local SubStatusType = self.SubStatusType
    local bShowCharm = true
    if isFriend then
      if SubStatusType == 6 then
        printf("MainCityPlayerState:HandlerOnCharmChanged_Client: isFriend false by SubStatusType = 6")
        bShowCharm = false
      end
    elseif SubStatusType == 6 or SubStatusType == 8 then
      printf("MainCityPlayerState:HandlerOnCharmChanged_Client: stranger false by SubStatusType = %s", SubStatusType)
      bShowCharm = false
    end
    uMainCityCharacter.CharmCharacterFeature:OnCharmChanged_Client(CharmValue, CharmLevel, bShowCharm)
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_CHARM_LEVEL_CHANGED, nPlayerUID, CharmLevel, bShowCharm)
  end)
end
function MainCityPlayerState:OnRep_Charm()
  if not Client then
    return
  end
  printf("MainCityPlayerState:OnRep_Charm Charm: %s", self.Charm)
  self:HandlerOnCharmChanged_Client()
end
function MainCityPlayerState:OnRep_InteractiveState()
  if not Client then
    return
  end
  log(bWriteLog and string.format("MainCityPlayerState:OnRep_InteractiveState [%s] %d", self.PlayerUID, self.InteractivePlayerStateFeature.InteractiveState))
  self:WaitForValidCharacter(function(uMainCityCharacter)
    if not slua.isValid(uMainCityCharacter) then
      return
    end
    local TempState = self.InteractivePlayerStateFeature.InteractiveState
    TempState = TempState & ~EMask.ISTF_Soccer
    TempState = TempState & ~EMask.ISTF_DanceLead
    TempState = TempState & ~EMask.ISTF_DanceFollow
    TempState = TempState & ~EMask.ISTF_MagicWand
    TempState = TempState & ~EMask.ISTF_PartyPopper
    local character = self:GetPlayerCharacter()
    if TempState ~= 0 then
      local attachedActors = uMainCityCharacter:GetAttachedActors(nil)
      local xSuitCompanionActorClass = slua.loadClass("/Game/Arts_PlayerBluePrints/Character_Show/AvatarShow/BP_XSuitCompanionActor_Base.BP_XSuitCompanionActor_Base")
      for _, actor in pairs(attachedActors) do
        if Game:IsClassOf(actor, xSuitCompanionActorClass) then
          actor:SetActorHiddenInGame(true)
          break
        end
      end
      if slua.isValid(character) then
        character:SetOnlyTickWhenRenderFlag(false)
      end
    else
      local attachedActors = uMainCityCharacter:GetAttachedActors(nil)
      local xSuitCompanionActorClass = slua.loadClass("/Game/Arts_PlayerBluePrints/Character_Show/AvatarShow/BP_XSuitCompanionActor_Base.BP_XSuitCompanionActor_Base")
      for _, actor in pairs(attachedActors) do
        if Game:IsClassOf(actor, xSuitCompanionActorClass) then
          actor:SetActorHiddenInGame(false)
          break
        end
      end
      if slua.isValid(character) then
        character:SetOnlyTickWhenRenderFlag(true)
      end
    end
  end)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uMyPS = GameplayData.GetPlayerState()
  if uMyPS == self.Object then
    log(bWriteLog and "MainCityPlayerState:OnRep_InteractiveState Update states")
    local bShowPhotoEntrance = true
    local bShowMainUI = true
    if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_DanceLead | EMask.ISTF_DanceFollow) then
      bShowPhotoEntrance = false
      bShowMainUI = false
    end
    local bShowJoystick = true
    if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_Seesaw | EMask.ISTF_MultiPhotoCaster | EMask.ISTF_MultiPhotoJoiner | EMask.ISTF_DanceLead | EMask.ISTF_DanceFollow) then
      bShowJoystick = false
    end
    local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
    if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_DualSkill) then
      self.lastIsDualSkill = true
      if IngameSelfieSubsystem and IngameSelfieSubsystem:GetIsInSelfieMode() then
        bShowJoystick = nil
        bShowMainUI = false
        bShowPhotoEntrance = false
      end
    elseif self.lastIsDualSkill and IngameSelfieSubsystem and IngameSelfieSubsystem:GetIsInSelfieMode() then
      self.lastIsDualSkill = false
      local uPlayerController = GameplayData.GetPlayerController()
      if slua.isValid(uPlayerController) then
        uPlayerController:ShowTouchInterface(true)
      end
      bShowJoystick = nil
      bShowMainUI = false
      bShowPhotoEntrance = false
    end
    local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
    MainCity_GamePlay_Tools.SetInGameUIVisible_OnInteractiveStateChange(bShowJoystick, bShowPhotoEntrance, bShowMainUI)
    if not self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_DanceLead | EMask.ISTF_DanceFollow) and UIManager.GetUI(UIManager.UI_Config.MainCity_Dance_Status_UIBP) then
      printf("MainCityPlayerState:OnRep_InteractiveState Close dance status ui")
      UIManager.CloseUI(UIManager.UI_Config.MainCity_Dance_Status_UIBP)
    end
    local MCCharmSubsystem = SubsystemMgr:Get("MCCharmSubsystem")
    if MCCharmSubsystem then
      local CharmConst = require("GameLua.Mod.MainCity.Client.logic.Charm.CharmConst")
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_Soccer) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.PlayFootball, true)
      end
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_Seesaw) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.PlaySeesaw, true)
      end
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_DanceLead | EMask.ISTF_DanceFollow) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.Dance, true)
      end
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_MagicWand) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.HoldMagicWand, true)
      end
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_Swing) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.Swing, true)
      end
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_Carrousel) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.Carrousel, true)
      end
      if self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_PartyPopper) then
        MCCharmSubsystem:ReportCharmAction(CharmConst.ECharmActionType.PartyPopper, true)
      end
    end
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_LOCAL_PLAYER_INTERACTIVE_STATE_CHANGED, self)
  end
  local character = self:GetPlayerCharacter()
  if slua.isValid(character) and character.RefreshInteractState then
    character:RefreshInteractState()
  end
  local sPlayerUID = self:GetUIDString()
  local bIsJoiner = self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_MultiPhotoJoiner)
  local bIsCaster = self.InteractivePlayerStateFeature:HasInteractiveStateMask(EMask.ISTF_MultiPhotoCaster)
  printf("MainCityPlayerState:OnRep_InteractiveState multipose HUD event: UID=%s, bIsJoiner=%s, bIsCaster=%s, InteractiveState=%s", sPlayerUID, bIsJoiner, bIsCaster, self.InteractivePlayerStateFeature.InteractiveState)
  EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MULTIPOSE_POSITION_HUD_CHANGED, sPlayerUID, bIsJoiner, bIsCaster)
end
function MainCityPlayerState:GetCharm()
  return self.Charm
end
function MainCityPlayerState:SetCharm(charmValue)
  printf("MainCityPlayerState:SetCharm uid: %s, charmValue: %s", self.PlayerUID, charmValue)
  self.Charm = charmValue
end
function MainCityPlayerState:ParseInteractiveStateMask()
  local interactiveState = self.InteractivePlayerStateFeature.InteractiveState
  if not interactiveState or interactiveState == 0 then
    return "None"
  end
  local stateNames = {}
  local stateMap = {
    [EMask.ISTF_Seat] = "Seat",
    [EMask.ISTF_Seesaw] = "Seesaw",
    [EMask.ISTF_MultiPhotoCaster] = "MultiPhotoCaster",
    [EMask.ISTF_MultiPhotoJoiner] = "MultiPhotoJoiner",
    [EMask.ISTF_DanceLead] = "DanceLead",
    [EMask.ISTF_DanceFollow] = "DanceFollow",
    [EMask.ISTF_MagicWand] = "MagicWand",
    [EMask.ISTF_Soccer] = "Soccer",
    [EMask.ISTF_Swing] = "Swing",
    [EMask.ISTF_Carrousel] = "Carrousel",
    [EMask.ISTF_PartyPopper] = "PartyPopper"
  }
  for mask, name in pairs(stateMap) do
    if interactiveState & mask ~= 0 then
      table.insert(stateNames, name)
    end
  end
  if #stateNames == 0 then
    return string.format("Unknown(%d)", interactiveState)
  end
  return table.concat(stateNames, "|") .. string.format("(%d)", interactiveState)
end
local class = require("class")
local CPlayerStateBase = require("GameLua.GameCore.Framework.PlayerStateBase")
local MergePatialTool = require("GameLua.Mod.SocialIsland.GamePlay.MergePatialTool")
MergePatialTool.Mixin(CPlayerStateBase, MainCityPlayerState, require("GameLua.Mod.MainCity.Gameplay.Action.MainCityPlayerState_DNDAction"))
local CMainCityPlayerState = class(CPlayerStateBase, nil, MainCityPlayerState)
return require("combine_class").DeclareFeature(CMainCityPlayerState, {
  {
    InteractivePlayerStateFeature = "GameLua.Mod.Library.GamePlay.Feature.InteractivePlayerStateFeature"
  }
}, "MainCityPlayerState")