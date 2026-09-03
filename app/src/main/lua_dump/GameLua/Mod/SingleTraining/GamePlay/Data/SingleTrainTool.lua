local ShootingTrainTool = {}
function ShootingTrainTool.GetTargetArrayByLocation(Location, ClassPath)
  local TargetArray = {}
  local uTargetClass
  if ClassPath then
    uTargetClass = import(ClassPath)
  else
    uTargetClass = import("/Game/Mod/SingleTraining/BluePrints/ShootingScoreTargetContainer.ShootingScoreTargetContainer_C")
  end
  local vLocation = Location or FVector(0, 0, 0)
  local uTargetArray
  if Client then
    local uActor = import("/Script/Engine.Actor")
    local UGameplayStatics = import("GameplayStatics")
    local UIUtil = require("client.common.ui_util")
    uTargetArray = UGameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), uTargetClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  else
    uTargetArray = CGame:GetActorsInSphere(vLocation, 100000, uTargetClass)
  end
  local MinDistance = 100000000
  local NearestContainer
  for _, uTarget in pairs(uTargetArray) do
    if uTarget and slua.isValid(uTarget) then
      local Distance = FVector.Distance(uTarget:K2_GetActorLocation(), vLocation)
      if MinDistance > Distance then
        Min        NearestContainer = uTarget
      end
    end
  end
  if NearestContainer then
    local Tmp = NearestContainer.TSpwanPostionArray
    for index = 0, Tmp:Num() - 1 do
      local ScoreTarget = Tmp:Get(index)
      TargetArray[index + 1] = ScoreTarget
    end
  end
  return TargetArray
end
function ShootingTrainTool.GetTargetArrayByContainer(Player, ClassPath)
  if not slua.isValid(Player) then
    return
  end
  return ShootingTrainTool.GetTargetArrayByLocation(Player:K2_GetActorLocation(), ClassPath)
end
function ShootingTrainTool.SetActorsStatByTag(Player, State, Tag)
  if not slua.isValid(Player) then
    print(bWriteLog and "SetActorsStatByTag player is nil")
    return
  end
  local vLocation = Player:K2_GetActorLocation()
  local World
  if Client then
    World = slua_GameFrontendHUD:GetWorld()
  else
    World = CGameWorld
  end
  local GameplayStatics = import("GameplayStatics")
  local ActorClass = import("/Script/Engine.Actor")
  local ActorArray = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
  ActorArray = GameplayStatics.GetAllActorsWithTag(World, Tag, ActorArray)
  print(bWriteLog and "SetActorsStatByTag:" .. tostring(ActorArray:Num()))
  local LegalDistance = 100000
  for _, uTarget in pairs(ActorArray) do
    if uTarget and slua.isValid(uTarget) then
      local Distance = FVector.Distance(uTarget:K2_GetActorLocation(), vLocation)
      if LegalDistance > Distance then
        uTarget:SetActorHiddenInGame(not State)
        uTarget:SetActorEnableCollision(State)
        uTarget:SetActorTickEnabled(State)
      end
    end
  end
end
function ShootingTrainTool.IsSelfInTraining()
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local game_sub_mode_str = logic_enter_game:GetSubModeId()
  local game_sub_mode = tonumber(game_sub_mode_str) or 0
  return game_sub_mode == 10080 and not GameStatus.IsInLobbyOrMainCity()
end
function ShootingTrainTool.IsOtherInTraining(status)
  if not status then
    return false
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local isInSingleTraining = PlayerStatusUtil.IsSingleTraining(status)
  return isInSingleTraining
end
function ShootingTrainTool.CanSelfEnterTraining(uid)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    log(bWriteLog and "ShootingTrainTool.CanSelfEnterTraining in social island mode")
    return false
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "ShootingTrainTool.CanSelfEnterTraining in home mode")
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
    local game_sub_mode_str = logic_enter_game:GetSubModeId()
    local game_sub_mode = tonumber(game_sub_mode_str) or 0
    if game_sub_mode ~= 10080 then
      log(bWriteLog and "ShootingTrainTool.CanSelfEnterTraining not in train battle mode " .. tostring(game_sub_mode))
      return false
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isTeam = TeamUpNewSystem.GetMemberInfo(uid) ~= nil
  if not isTeam then
    log(bWriteLog and "ShootingTrainTool.CanSelfEnterTraining not in team")
    return false
  end
  return true
end
function ShootingTrainTool.CanOtherEnterTraining(status)
  if not status then
    return false
  end
  if status.socialland_type == 1 then
    log(bWriteLog and "ShootingTrainTool.CanOtherEnterTraining in social island mode")
    return false
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  if status.game_sub_mode and status.game_sub_mode == home_macros.Home_SubMode.Visit then
    log(bWriteLog and "ShootingTrainTool.CanOtherEnterTraining in home mode")
    return false
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local isInMainCity = PlayerStatusUtil.IsMainCity(status)
  local isOtherInBattle = PlayerStatusUtil.IsBattle(status) and not isInMainCity
  if isOtherInBattle and not ShootingTrainTool.IsSelfInTraining() then
    log(bWriteLog and "ShootingTrainTool.CanOtherEnterTraining not in training battle mode")
    return false
  end
  return true
end
function ShootingTrainTool.IsButtonShow(uid, status)
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  local isOtherTraining = ShootingTrainTool.IsOtherInTraining(status)
  local IsSelfTraining = ShootingTrainTool.IsSelfInTraining()
  local result = false
  if IsSelfTraining and isOtherTraining then
    log(bWriteLog and "ShootingTrainTool.IsButtonShow both")
    result = false
  elseif IsSelfTraining and ShootingTrainTool.CanOtherEnterTraining(status) then
    log(bWriteLog and "ShootingTrainTool.IsButtonShow CenOtherEnter")
    result = true
  else
    if isOtherTraining and ShootingTrainTool.CanSelfEnterTraining(uid) then
      log(bWriteLog and "ShootingTrainTool.IsButtonShow CanSelfEnter")
      result = true
    else
    end
  end
  return result
end
function ShootingTrainTool.IsInSameTraining(status)
  if not status then
    return false
  end
  if status and status.game_id and status.game_id > 0 and status.game_id == g_game_id then
    ShowNotice(tostring(status.game_id))
    ShowNotice(tostring(g_game_id))
    return true
  end
  return false
end
function ShootingTrainTool.ClickButton_SingleTraining(uid)
  log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining uid = " .. tostring(uid))
  if not uid then
    log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining uid is nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local lastTime = ShootingTrainTool.lastInviteTime or 0
  if math.abs(curTime - lastTime) < 2 then
    log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining in cd")
    ShowNotice(76254)
    return
  else
    ShootingTrainTool.lastInviteTime = curTime
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if not status then
    log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining status is nil")
    return
  end
  local SingleTrainingHandler = require("client.network.Protocol.SingleTrainingHandler")
  if ShootingTrainTool.IsSelfInTraining() and ShootingTrainTool.IsOtherInTraining(status) then
    log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining Both")
    if not ShootingTrainTool.IsInSameTraining(status) then
      local trainingStr = LocUtil.GetLocalizeResStr(33069)
      local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
      local SingleTrainingHandler = require("client.network.Protocol.SingleTrainingHandler")
      IngameTipsTools.ShowMsgBox(4, "", LocUtil.LocalizeResFormat(9552, trainingStr, trainingStr), function()
        SingleTrainingHandler.send_single_training_invite_req(uid)
      end, function(_)
        SingleTrainingHandler.send_single_training_apply_req(uid)
      end, LocUtil.GetLocalizeResStr(9566), LocUtil.GetLocalizeResStr(9565))
    else
      ShowNotice(100210016)
    end
  elseif ShootingTrainTool.IsSelfInTraining() and ShootingTrainTool.CanOtherEnterTraining(status) then
    log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining Can Other Enter")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.CheckPlayerNumFull and uPlayerController:CheckPlayerNumFull() then
      log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining CanOtherEnter Room Is FUll")
      ShowNotice(100210026)
      return
    end
    SingleTrainingHandler.send_single_training_invite_req(uid)
  elseif ShootingTrainTool.IsOtherInTraining(status) and ShootingTrainTool.CanSelfEnterTraining(uid) then
    log(bWriteLog and "ShootingTrainTool.ClickButton_SingleTraining Can Self Enter")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      "map_singletraining"
    })
    if state ~= ENUM_DownloadState.Done then
      ShowNotice(31047)
      return
    end
    SingleTrainingHandler.send_single_training_apply_req(uid)
  end
end
return ShootingTrainTool