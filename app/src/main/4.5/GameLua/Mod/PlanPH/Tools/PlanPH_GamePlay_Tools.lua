local PlanPH_GamePlay_Tools = {
  putSendTime = 0,
  putRspTime = 0,
  editorTestLevel = 50
}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local Actor = import("/Script/Engine.Actor")
local PlanPH_Mode_Config = require("GameLua.Mod.PlanPH.Gameplay.Config.PlanPH_Mode_Config")
local EmoteConfig = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.EmoteConfig")
function PlanPH_GamePlay_Tools.ReInitPutSendAndRspTime()
  PlanPH_GamePlay_Tools.putSendTime = 0
  PlanPH_GamePlay_Tools.putRspTime = 0
  PlanPH_GamePlay_Tools.bCanPut = true
end
function PlanPH_GamePlay_Tools.RecordPutSendTime()
  local TimeUtil = require("client.common.time_util")
  PlanPH_GamePlay_Tools.putSendTime = TimeUtil.GetServerTimeInSecWithFraction()
  PlanPH_GamePlay_Tools.bCanPut = false
end
function PlanPH_GamePlay_Tools.RecordPutRspTime()
  local TimeUtil = require("client.common.time_util")
  PlanPH_GamePlay_Tools.putRspTime = TimeUtil.GetServerTimeInSecWithFraction()
  PlanPH_GamePlay_Tools.bCanPut = true
end
function PlanPH_GamePlay_Tools.CheckPutSendAndRspTimeValid()
  return PlanPH_GamePlay_Tools.bCanPut
end
function PlanPH_GamePlay_Tools.IsStandalone()
  local bStandalone = UKismetSystemLibrary.IsStandalone(slua.getGameInstance())
  return bStandalone
end
function PlanPH_GamePlay_Tools.IsLocalBoot()
  if Client then
    if not Client.IsDevelopment() then
      return false
    end
    local uid = DataMgr.roleData.uid
    if uid == "" and IsEditor then
      return true
    end
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if uPlayerCharacter and Game:IsValid(uPlayerCharacter) then
      local ret = uPlayerCharacter.PlayerUID ~= uid
      return ret
    end
    return uid == ""
  else
    return _G.IsEditor
  end
end
function PlanPH_GamePlay_Tools.IsNoneMode()
  if Client then
    local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
    return logic_home_entry.mode == PlanPH_Mode_Config.EModeType.None
  end
  return false
end
function PlanPH_GamePlay_Tools.IsVisitMode(playerUid)
  if Client then
    local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
    return logic_home_entry.mode == PlanPH_Mode_Config.EModeType.Visit
  else
    if playerUid == nil then
      return true
    end
    local PlanPH_ManorData_DS = require("GameLua.Mod.PlanPH.DS.ManorData.PlanPH_ManorData_DS")
    if PlanPH_ManorData_DS.manorDataList then
      local homeIndex = PlanPH_ManorData_DS.FindHomeIndex(playerUid)
      if homeIndex == nil then
        return true
      end
      return homeIndex <= 4
    else
      return false
    end
  end
end
function PlanPH_GamePlay_Tools.IsEditHomeMode(homeIndex)
  if Client then
    local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
    return logic_home_entry.mode == PlanPH_Mode_Config.EModeType.EditHome
  elseif PlanPH_GamePlay_Tools.IsEditHomeIndex(homeIndex) then
    local PlanPH_ManorData_DS = require("GameLua.Mod.PlanPH.DS.ManorData.PlanPH_ManorData_DS")
    if PlanPH_ManorData_DS.manorDataList then
      local manorData = PlanPH_ManorData_DS.manorDataList[homeIndex - 4]
      if manorData then
        return manorData.editMode == PlanPH_Mode_Config.EModeType.EditHome
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end
function PlanPH_GamePlay_Tools.IsEditPlanMode()
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  return logic_home_entry.mode == PlanPH_Mode_Config.EModeType.EditPlan
end
function PlanPH_GamePlay_Tools.IsManorOwner()
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  return logic_home_entry:IsSelfOwner()
end
function PlanPH_GamePlay_Tools.IsEditPlanMode_Owner()
  if PlanPH_GamePlay_Tools.IsEditPlanMode() then
    if Client then
      return PlanPH_GamePlay_Tools.IsManorOwner()
    else
      return false
    end
  else
    return false
  end
end
function PlanPH_GamePlay_Tools.IsEditPlanMode_OwnerExclusiveJoint()
  local bIsPlanOwner = PlanPH_GamePlay_Tools.IsEditPlanMode_Owner()
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if bIsPlanOwner and logic_home_joint:HasJointHome() then
    log(bWriteLog and "PlanPH_GamePlay_Tools.IsEditPlanMode_OwnerSelf")
    local logic_home_edit_plan = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_edit_plan)
    local editPlanInfo = logic_home_edit_plan:GetEditPlanInfo()
    if editPlanInfo then
      if editPlanInfo.firstEditPlayerUid ~= tonumber(DataMgr.roleData.uid) then
        log(bWriteLog and "PlanPH_GamePlay_Tools.IsEditPlanMode_OwnerSelf plan owner is not me, plan owner uid = " .. tostring(editPlanInfo.firstEditPlayerUid))
        bIsPlanOwner = false
      end
    else
      log(bWriteLog and "PlanPH_GamePlay_Tools.IsEditPlanMode_OwnerSelf editPlanInfo missing")
      bIsPlanOwner = false
    end
  end
  return bIsPlanOwner
end
function PlanPH_GamePlay_Tools.IsEditPlanMode_Guest()
  if PlanPH_GamePlay_Tools.IsEditPlanMode() then
    if Client then
      return not PlanPH_GamePlay_Tools.IsManorOwner()
    else
      return false
    end
  else
    return false
  end
end
function PlanPH_GamePlay_Tools.GetMyUid()
  if DataMgr.roleData.uid ~= "" then
    return tonumber(DataMgr.roleData.uid)
  end
  local playerControl = slua_GameFrontendHUD:GetPlayerController()
  local playerChar = playerControl:GetPlayerCharacterSafety()
  return Game:GetPlayerUID(playerChar) or 0
end
function PlanPH_GamePlay_Tools.IsEditHomeIndex(homeIndex)
  return 4 < homeIndex
end
function PlanPH_GamePlay_Tools.GetEditHomeIndex(homeIndex)
  return homeIndex + 4
end
function PlanPH_GamePlay_Tools.GetVisitHomeIndex(homeIndex)
  return homeIndex - 4
end
function PlanPH_GamePlay_Tools.GetSlotIndex(playerUid)
  print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex")
  if Client then
    if PlanPH_GamePlay_Tools.IsVisitMode() then
      print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex 1")
      return 1
    elseif PlanPH_GamePlay_Tools.IsEditHomeMode() then
      print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex 2")
      return 1
    elseif PlanPH_GamePlay_Tools.IsEditPlanMode() then
      print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex 3")
      local logic_home_edit_plan = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_edit_plan)
      return logic_home_edit_plan.editSlotIndex
    else
      print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex 4")
      return 1
    end
  else
    local PlanPH_ManorData_DS = require("GameLua.Mod.PlanPH.DS.ManorData.PlanPH_ManorData_DS")
    local manorData = PlanPH_ManorData_DS.FindManorData(playerUid)
    if manorData then
      print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex 6")
      return manorData.editSlotIndex
    else
      print(bWriteLog and "PlanPH_GamePlay_Tools.GetSlotIndex 7")
      return 1
    end
  end
end
function PlanPH_GamePlay_Tools.IsSocialIslandMode()
  if Client then
    if IsEditor and slua.isValid(CGameState) and CGameState.bSocialIslandGameMode == true then
      return true
    end
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    return MatchModeMgrSystem.IsSocialIslandMode()
  else
    return CGameMode and CGameMode.bSocialIslandGameMode == true
  end
end
function PlanPH_GamePlay_Tools.IsPHomeMode(bIsGameStatusInFighting)
  if type(bIsGameStatusInFighting) == "nil" then
    if not GameStatus.IsInFightingNotMainCity() then
      return false
    end
  elseif not bIsGameStatusInFighting then
    return false
  end
  if IsEditor and slua.isValid(CGameState) and CGameState.bPlanPHGameMode == true then
    return true
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local home_macros = require("client.slua.logic.home.home_macros")
  local sub_mode = logic_enter_game.sub_mode
  if sub_mode == home_macros.Home_SubMode.Visit then
    return true
  end
  return false
end
function PlanPH_GamePlay_Tools.IsSupportInteractive()
  return PlanPH_GamePlay_Tools.IsSocialIslandMode() or PlanPH_GamePlay_Tools.IsVisitMode()
end
function PlanPH_GamePlay_Tools.GetLandIDByLocation(position)
  print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandIDByLocation position = " .. position:ToString())
  local uLevelGenerator = PlanPH_GamePlay_Tools.GetLevelGenerator()
  if not slua.isValid(uLevelGenerator) then
    print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandIDByLocation no uLevelGenerator")
    return 1
  end
  local levelInfo = uLevelGenerator:GetLevelStreamInfoByLocation(position)
  if not levelInfo then
    print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandIDByLocation no levelInfo")
    return 1
  end
  print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandIDByLocation position = " .. position:ToString() .. ", landId = " .. levelInfo.Index + 1)
  return levelInfo.Index + 1
end
function PlanPH_GamePlay_Tools.GetLandOffset()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return FVector(0, 0, 0)
  end
  return PlanPH_GamePlay_Tools.GetLandOffsetByLocation(uPlayerCharacter:K2_GetActorLocation())
end
function PlanPH_GamePlay_Tools.GetLandOffsetByLocation(position)
  print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandOffsetByLocation position = " .. position:ToString())
  local uLevelGenerator = PlanPH_GamePlay_Tools.GetLevelGenerator()
  if not slua.isValid(uLevelGenerator) then
    print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandOffsetByLocation no uLevelGenerator")
    return FVector(0, 0, 0)
  end
  local OffsetLocation = uLevelGenerator:GetLandscapeOffset(position)
  print(bWriteLog and "PlanPH_GamePlay_Tools.GetLandOffsetByLocation OffsetLocation = " .. OffsetLocation:ToString())
  return OffsetLocation
end
function PlanPH_GamePlay_Tools.GetLevelGenerator()
  if slua.isValid(PlanPH_GamePlay_Tools.uLevelGenerator) then
    return PlanPH_GamePlay_Tools.uLevelGenerator
  end
  local BpPath = "/Game/Mod/PlanPH/BluePrints/Core/BP_SubLevelGen.BP_SubLevelGen_C"
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  if Client then
    PlanPH_GamePlay_Tools.uLevelGenerator = ActorTools.GetOneActor(slua_GameFrontendHUD, BpPath)
  else
    PlanPH_GamePlay_Tools.uLevelGenerator = ActorTools.GetOneActor(CGameMode, BpPath)
  end
  return PlanPH_GamePlay_Tools.uLevelGenerator
end
function PlanPH_GamePlay_Tools.GetGameInstance()
  local gameInst
  if Client then
    gameInst = slua_GameFrontendHUD:GetGameInstance()
  else
    local STExtraGameInstance = import("STExtraGameInstance")
    gameInst = STExtraGameInstance.GetInstance()
  end
  return gameInst
end
function PlanPH_GamePlay_Tools.GetDecorationInstByID(homeIndex, instId)
  if not homeIndex or not instId then
    return nil
  end
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local curHome = PlanPH_HomeArea_Manager.FindHomeArea(homeIndex)
  if curHome then
    local sceneObjectSystem = curHome.sceneObjectSystem
    if sceneObjectSystem then
      local objectInstList = sceneObjectSystem.objectInstList
      if objectInstList then
        local decorationInstInfo = objectInstList:GetDecorationInstByID(instId)
        if decorationInstInfo and decorationInstInfo.objectInst then
          return decorationInstInfo.objectInst
        end
      end
    end
  end
  if Client then
    local PlanPH_SceneObject_RepActorList_Client = require("GameLua.Mod.PlanPH.Client.HomeArea.SceneObject.PlanPH_SceneObject_RepActorList_Client")
    local RepActor = PlanPH_SceneObject_RepActorList_Client.GetRepActor(homeIndex, instId)
    return RepActor
  end
  log(bWriteLog and "PlanPH_Halloween_Utils.GetDecorationInstByID Failed to find DecorationInstByID: " .. tostring(instId))
  return nil
end
function PlanPH_GamePlay_Tools.GetCharacterOverlappingActor(character, ignoreActors)
  if not slua.isValid(character) then
    return false
  end
  local capsuleComponent = character:K2_GetRootComponent()
  if not slua.isValid(capsuleComponent) then
    return false
  end
  ignoreActors = ignoreActors or slua.Array(UEnums.EPropertyClass.Object, Actor)
  ignoreActors:Add(character)
  local radius = capsuleComponent:GetScaledCapsuleRadius()
  local halfHeight = capsuleComponent:GetScaledCapsuleHalfHeight()
  local startLocation = character:K2_GetActorLocation()
  local endLocation = FVector(startLocation.X + 1, startLocation.Y + 1, startLocation.Z + 1)
  local bBlocking, hitResult = UKismetSystemLibrary.CapsuleTraceSingleByProfile(character, startLocation, endLocation, radius, halfHeight, "Pawn", true, ignoreActors, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 5)
  if not bBlocking then
    return nil
  end
  return hitResult.Actor
end
function PlanPH_GamePlay_Tools.LocationValidCheck(character, location, ignoreActors)
  if not slua.isValid(character) then
    return false
  end
  local capsuleComponent = character:K2_GetRootComponent()
  if not slua.isValid(capsuleComponent) then
    return false
  end
  ignoreActors = ignoreActors or slua.Array(UEnums.EPropertyClass.Object, Actor)
  ignoreActors:Add(character)
  local radius = capsuleComponent:GetScaledCapsuleRadius()
  local halfHeight = capsuleComponent:GetScaledCapsuleHalfHeight()
  local startLocation = location
  local bBlocking, hitResult = UKismetSystemLibrary.CapsuleTraceSingleByProfile(character, startLocation, startLocation, radius, halfHeight, "Pawn", true, ignoreActors, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 5)
  return not bBlocking, hitResult
end
function PlanPH_GamePlay_Tools.StopPlayEmote(uid)
  if Client and uid == nil then
    uid = PlanPH_GamePlay_Tools.GetMyUid()
  end
  log(bWriteLog and "PlanPH_GamePlay_Tools.StopPlayEmote uid = " .. tostring(uid))
  local PlanPH_PlayerCharacter_Manager = require("GameLua.Mod.PlanPH.Gameplay.Core.PlanPH_PlayerCharacter_Manager")
  local character = PlanPH_PlayerCharacter_Manager.GetCharacter(tonumber(uid))
  if not character then
    log(bWriteLog and "PlanPH_GamePlay_Tools.StopPlayEmote character not found")
    return
  end
  local skillManager = character:GetSkillManager()
  if not Game:IsValid(skillManager) then
    log(bWriteLog and "PlanPH_GamePlay_Tools.StopPlayEmote skillManager not valid")
    return
  end
  local skillId = skillManager:GetCurSkillID()
  if skillId == EmoteConfig.ForwardEmoteConfig.LeaderSkillID or skillId == EmoteConfig.ForwardEmoteConfig.FollowerSkillID then
    log(bWriteLog and "PlanPH_GamePlay_Tools.StopPlayEmote interrupt forward dance, skillId = " .. tostring(skillId))
    skillManager:TriggerStringEvent(skillId, "LeaveForwardEmote")
    return
  end
  local playEmoteComponent = character:GetPlayEmoteComponent()
  if not Game:IsValid(playEmoteComponent) then
    log(bWriteLog and "PlanPH_GamePlay_Tools.StopPlayEmote playEmoteComponent not valid")
    return
  end
  local emoteIndex = playEmoteComponent:GetCurrentEmoteID()
  log(bWriteLog and "PlanPH_GamePlay_Tools.StopPlayEmote emoteIndex = " .. tostring(emoteIndex))
  if 0 < emoteIndex then
    character:LocalInteruptPlayEmote(emoteIndex)
  end
end
function PlanPH_GamePlay_Tools.DisplayGameTipWithMsgID(character, tips)
  log(bWriteLog and "PlanPH_GamePlay_Tools.DisplayGameTipWithMsgID character=" .. tostring(Game:GetPlayerUID(character)) .. " tips=" .. tostring(tips))
  if not tips or tips == 0 then
    return
  end
  if character and character.GetPlayerControllerSafety then
    local playerController = character:GetPlayerControllerSafety()
    if playerController and playerController.DisplayGameTipWithMsgID then
      playerController:DisplayGameTipWithMsgID(tips)
    end
  end
end
return PlanPH_GamePlay_Tools