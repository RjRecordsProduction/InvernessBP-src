local MainCity_GamePlay_Tools = {}
local EmoteConfig = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.EmoteConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MainCityCoreConst = require("GameLua.Mod.MainCity.Gameplay.Core.MainCityCoreConst")
local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
local _cacheCurrState
function MainCity_GamePlay_Tools.InvalidateCurrStateCache()
  _cacheCurrState = nil
end
function MainCity_GamePlay_Tools.GetCurrState()
  if _cacheCurrState ~= nil then
    return _cacheCurrState
  end
  local result
  if GameStatus.IsInMainCity() then
    result = main_city_config.ESceneType.MainCity
  else
    local status = GameStatus.GetGameStatus()
    if status == GameStatus.Lobby then
      result = main_city_config.ESceneType.Lobby
    elseif status == GameStatus.Fighting then
      if Client then
        local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
        if Lobby_Main_UIBP then
          result = main_city_config.ESceneType.Lobby
        else
          result = main_city_config.ESceneType.Fighting
        end
      else
        result = main_city_config.ESceneType.Fighting
      end
    else
      result = main_city_config.ESceneType.Others
    end
  end
  _cacheCurrState = result
  return result
end
function MainCity_GamePlay_Tools.IsInMainCity()
  if Client then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    if Lobby_Main_City_Enter.bInMainCity then
      return true
    else
      return false
    end
  elseif CGameState and CGameState.bMainCityGameMode then
    return true
  else
    return false
  end
end
function MainCity_GamePlay_Tools.SetInGameUIVisible_OnInteractiveStateChange(bShowJoystick, bShowPhotoEntrance, bShowMainUI)
  printf("MainCity_GamePlay_Tools.SetInGameUIVisible_OnInteractiveStateChange bShowJoystick:%s, bShowPhotoEntrance:%s, bShowMainUI:%s", bShowJoystick, bShowPhotoEntrance, bShowMainUI)
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if not Lobby_Main_City_Enter.bShowMainCityUI then
    log(bWriteLog and "MainCity_GamePlay_Tools.SetInGameUIVisible_OnInteractiveStateChange not show maincity ui, skip")
    return
  end
  if bShowJoystick ~= nil then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:ShowTouchInterface(bShowJoystick)
    end
    if bShowJoystick then
      local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
      if IngameSelfieSubsystem then
        IngameSelfieSubsystem:ExitSelfie()
      end
    end
  end
  local MainCity_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.MainCity_Main_UIBP)
  if MainCity_Main_UIBP and MainCity_Main_UIBP.UIRoot then
    if bShowMainUI then
      MainCity_Main_UIBP:SelfHitTestInvisible()
    else
      MainCity_Main_UIBP:Collapsed()
    end
  end
end
function MainCity_GamePlay_Tools.GetMyUid()
  if DataMgr.roleData.uid ~= "" then
    return tonumber(DataMgr.roleData.uid)
  end
  local playerControl = slua_GameFrontendHUD:GetPlayerController()
  local playerChar = playerControl:GetPlayerCharacterSafety()
  return Game:IsValid(playerChar) and playerChar.PlayerKey or 0
end
function MainCity_GamePlay_Tools.LocationValidCheck(character, location, ignoreActors)
  if not slua.isValid(character) then
    return false
  end
  local capsuleComponent = character:K2_GetRootComponent()
  if not slua.isValid(capsuleComponent) then
    return false
  end
  if not ignoreActors then
    local Actor = import("/Script/Engine.Actor")
    ignoreActors = slua.Array(UEnums.EPropertyClass.Object, Actor)
  end
  ignoreActors:Add(character)
  local radius = capsuleComponent:GetScaledCapsuleRadius()
  local halfHeight = capsuleComponent:GetScaledCapsuleHalfHeight()
  local startLocation = location
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local bBlocking, hitResult = KismetSystemLibrary.CapsuleTraceSingleByProfile(character, startLocation, startLocation, radius, halfHeight, "Pawn", true, ignoreActors, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 5)
  return not bBlocking
end
function MainCity_GamePlay_Tools.SetDanceMusicState(bState)
  EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAIN_CITY_DANCE_MUSIC_STATE_CHANGE, bState)
end
function MainCity_GamePlay_Tools.IsInInteractiveState()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local playerState = GameplayData.GetPlayerState()
  if Game:IsValid(playerState) and Game:IsValid(playerState.InteractivePlayerStateFeature) then
    local EMainCityInteractiveStateTypeFlag = MainCityCoreConst.EMainCityInteractiveStateTypeFlag
    return not playerState.InteractivePlayerStateFeature:IsInteractiveStateIdle(EMainCityInteractiveStateTypeFlag.ISTF_Soccer)
  end
  return false
end
function MainCity_GamePlay_Tools.ResetMyCameraState(Reason)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    printf("MainCity_GamePlay_Tools.ResetMyCameraState Character is nil")
    return
  end
  local PlayerController = Character:GetPlayerControllerSafety()
  if not PlayerController then
    printf("MainCity_GamePlay_Tools.ResetMyCameraState PlayerController is nil")
    return
  end
  local Rot = Character:K2_GetActorRotation()
  PlayerController:SetControlRotation(Rot, Reason or "MainCity_GamePlay_Tools")
  Character.bUseControllerRotationYaw = true
  local SpringArmComp = Character.SpringArmComp
  if slua.isValid(SpringArmComp) then
    SpringArmComp.bUsePawnControlRotation = true
    SpringArmComp.bForceUseTargetArmLength = false
    SpringArmComp.TargetArmLength = Character.TPPSpringArmParam.TargetArmALength
  end
end
function MainCity_GamePlay_Tools.GetServerWorldTimeSeconds()
  if not CGameState then
    return os.time()
  end
  if Client then
    local ClientWorldTime = CGameState:GetServerWorldTimeSeconds()
    local logic_main_city_heart = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_heart)
    local offset = logic_main_city_heart.ClientWorldTimeOffset
    local result = ClientWorldTime - offset
    printf("MainCity_GamePlay_Tools.GetServerWorldTimeSeconds ClientWorldTime = %s, ClientWorldTimeOffset = %s, return %s", ClientWorldTime, offset, result)
    return result
  else
    return CGameState:GetServerWorldTimeSeconds()
  end
end
function MainCity_GamePlay_Tools.IsCanTeleport(showNotice)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    log(bWriteLog and "MainCity_GamePlay_Tools.IsInInteractiveAction Character is nil")
    return false
  end
  if MainCity_GamePlay_Tools.IsInInteractiveState() then
    log(bWriteLog and "MainCity_GamePlay_Tools.IsInInteractiveAction Character is in InteractiveState")
    if showNotice then
      ShowNotice(73347)
    end
    return false
  end
  local EPawnState = import("EPawnState")
  if PlayerCharacter:HasState(EPawnState.CarryBack) or PlayerCharacter:HasState(EPawnState.BeCarriedBack) or PlayerCharacter:HasState(EPawnState.FollowWalk) then
    log(bWriteLog and "MainCity_GamePlay_Tools.IsInInteractiveAction Character is in CarryBack or BeCarriedBack or FollowWalk")
    if showNotice then
      ShowNotice(73347)
    end
    return false
  end
  return true
end
function MainCity_GamePlay_Tools.StopPlayEmote()
  local playerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(playerCharacter) then
    return
  end
  local skillManager = playerCharacter:GetSkillManager()
  if slua.isValid(skillManager) then
    local skillId = skillManager:GetCurSkillID()
    if skillId == EmoteConfig.ForwardEmoteConfig.LeaderSkillID or skillId == EmoteConfig.ForwardEmoteConfig.FollowerSkillID then
      skillManager:TriggerStringEvent(skillId, "LeaveForwardEmote")
      return
    end
  end
  local playEmoteComponent = playerCharacter:GetPlayEmoteComponent()
  if Game:IsValid(playEmoteComponent) then
    local emoteIndex = playEmoteComponent:GetCurrentEmoteID()
    if 0 < emoteIndex then
      playerCharacter:LocalInteruptPlayEmote(emoteIndex)
    end
  end
end
local _CheckAndAddClothEmote = function(tShowEmoteList)
  local nClothEmoteID = 0
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    log(bWriteLog and "MainCity_GamePlay_Tools._CheckAndAddClothEmote OwningActor invalid")
    return tShowEmoteList, nClothEmoteID
  end
  if not OwningActor.getAvatarComponent2 then
    log(bWriteLog and "MainCity_GamePlay_Tools._CheckAndAddClothEmote getAvatarComponent2 not exist")
    return tShowEmoteList, nClothEmoteID
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    log(bWriteLog and "MainCity_GamePlay_Tools._CheckAndAddClothEmote AvatarComp2 invalid")
    return tShowEmoteList, nClothEmoteID
  end
  local targetExpressionID = 0
  local AvatarItemIDListTable
  AvatarItemIDListTable = uAvatarComp2:GetAllEquipItems(AvatarItemIDListTable)
  if AvatarItemIDListTable then
    local StringUtil = require("common.string_util")
    for _, itemID in pairs(AvatarItemIDListTable) do
      local featuresItems = CDataTable.GetTableData("FeaturesItems", itemID)
      if featuresItems and featuresItems.Features ~= "" then
        local features = StringUtil.Split(featuresItems.Features, ";")
        for _, featureIDStr in ipairs(features) do
          local featureID = tonumber(featureIDStr)
          if featureID then
            local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
            if featureCfg and featureCfg.FeatureType == ENUM_FeatureType.ClickEmotion and featureCfg.FightExpressionID and 0 < featureCfg.FightExpressionID then
              targetExpressionID = featureCfg.FightExpressionID
              break
            end
          end
        end
      end
      if 0 < targetExpressionID then
        break
      end
    end
  end
  if 0 < targetExpressionID then
    local uItemCfg = CDataTable.GetTableData("Item", targetExpressionID)
    local sName = uItemCfg and uItemCfg.ItemName or ""
    log(bWriteLog and "MainCity_GamePlay_Tools._CheckAndAddClothEmote hasClothEmote ID:" .. tostring(targetExpressionID))
    local ClothEmoteItem = {
      DefineID = {Type = 22, TypeSpecificID = targetExpressionID},
      Name = sName,
      bClothEmote = true
    }
    nClothEmoteID = targetExpressionID
    table.insert(tShowEmoteList, 1, ClothEmoteItem)
  end
  return tShowEmoteList, nClothEmoteID
end
local IsEmoteValidInMainCity = function(emoteID)
  if not GameStatus.IsInMainCity() then
    log(bWriteLog and "MainCity_GamePlay_Tools.IsEmoteValidInMainCity not in main city")
    return true
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsInviteAction(emoteID) then
    log(bWriteLog and "MainCity_GamePlay_Tools.IsEmoteValidInMainCity is xsuit invite action: " .. tostring(emoteID))
    return false
  end
  return true
end
function MainCity_GamePlay_Tools.GetExpressionItems()
  log(bWriteLog and "MainCity_GamePlay_Tools.GetExpressionItems")
  if not GameStatus.IsInMainCity() then
    log(bWriteLog and "MainCity_GamePlay_Tools.GetExpressionItems not in main city")
    return {}
  end
  local EmoteSubSystem = SubsystemMgr:Get("EmoteSubSystem")
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local result = {}
  local expressionItems = DataMgr.GetMotionItemDatas()
  for _, itemData in pairs(expressionItems) do
    local emoteID = itemData and itemData.resID
    if emoteID then
      if IsEmoteValidInMainCity(emoteID) then
        table.insert(result, {
          DefineID = {Type = 22, TypeSpecificID = emoteID}
        })
      else
        log(bWriteLog and "MainCity_GamePlay_Tools.GetExpressionItems emoteID is not valid in main city: " .. tostring(emoteID))
      end
    end
  end
  local nClothEmoteID = 0
  result, nClothEmoteID = _CheckAndAddClothEmote(result)
  log_tree("MainCity_GamePlay_Tools.GetExpressionItems result=", result)
  return result
end
return MainCity_GamePlay_Tools