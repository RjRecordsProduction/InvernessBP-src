local logic_newbie_assist = {
  switchLobby = false,
  switchBattle = false,
  tipQueue = {},
  tipCondition = {},
  ENUM_TIP_ACTION_TYPE = {SCREEN_MARK_BY_LOC = 1, SCREEN_MARK_BY_ACTOR = 2}
}
logic_newbie_assist.tipCondition = {
  [1] = "CheckWeapon",
  [2] = "CheckSubItem",
  [3] = "CheckWeaponBullet",
  [4] = "CheckHp",
  [5] = "CheckInBlueCircle",
  [6] = "CheckInWhiteCircle",
  [7] = "CheckHelmet",
  [8] = "CheckCloth",
  [9] = "CheckSpecificItem",
  [10] = "CheckLevel",
  [11] = "CheckDyingTeammateDistance",
  [12] = "CheckHaveRevivableTeamate",
  [13] = "CheckHaveActorInDistance"
}
function logic_newbie_assist.GetNewbieGuideTipUI()
  local ui = UIManager.GetUI(UIManager.UI_Config_InGame.NewbieGuideTip)
  return ui
end
local Inited = false
function logic_newbie_assist.GetLobbySwitchState()
  logic_newbie_assist.InitSwitch()
  return logic_newbie_assist.switchLobby
end
function logic_newbie_assist.GetBattleSwitchState()
  logic_newbie_assist.InitSwitch()
  return logic_newbie_assist.switchBattle
end
function logic_newbie_assist.InitSwitch()
  if Inited then
    return
  end
  Inited = true
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  logic_newbie_assist.switchLobby = SettingConfig.bOpenLobbyNewBieAssist or false
  logic_newbie_assist.switchBattle = SettingConfig.bOpenBattleNewBieAssist or false
end
function logic_newbie_assist.SetLobbySwitch(bOn)
  logic_newbie_assist.switchLobby = bOn
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.bOpenLobbyNewBieAssist = bOn
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function logic_newbie_assist.SetBattleSwitch(bOn)
  logic_newbie_assist.switchBattle = bOn
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.bOpenBattleNewBieAssist = bOn
  slua_GameFrontendHUD:FinishModifyUserSettings()
  EventSystem:postEvent(EVENTTYPE_NEWBIE, EVENTID_NEWBIE_ASSIST_CHANGE_SWITCH, bOn)
end
function logic_newbie_assist.IsLobbySwtichMenuOpen()
  return LobbySystem.CheckOpen(BP_ENUM_SWITCH_LOBBY_NEWBIE_ASSIST)
end
function logic_newbie_assist.IsBattleSwtichMenuOpen()
  return LobbySystem.CheckOpen(BP_ENUM_SWITCH_BATTLE_NEWBIE_ASSIST)
end
function logic_newbie_assist.CheckIsNewBie()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    log(bWriteLog and "[v_wllwu]logic_newbie_assist NewbieActivitySystem is end")
    return false
  end
  return true
end
function logic_newbie_assist.CheckIsNewbieBanner()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieBanner() then
    log(bWriteLog and "logic_newbie_assist newbie banner is end")
    return false
  end
  return true
end
function logic_newbie_assist.IsShowLobbyEntrance()
  if not logic_newbie_assist.IsLobbySwtichMenuOpen() then
    log(bWriteLog and "[v_wllwu] logic_newbie_assist switch is closed")
    return false
  end
  if not logic_newbie_assist.CheckIsNewBie() then
    return false
  end
  return true
end
function logic_newbie_assist.UpdateNewbieTipState(tiped)
  local tipData = logic_newbie_assist.GetNewbieTipData()
  if tipData then
    tipData.    logic_newbie_assist.SaveNewbieTipData()
  end
end
function logic_newbie_assist.SetNewbieTipedItem(tipInfoID)
  local tipData = logic_newbie_assist.GetNewbieTipData()
  if tipData then
    if not tipData.tipedID then
      tipData.tipedID = {}
    end
    tipData.tipedID[tipInfoID] = true
    logic_newbie_assist.SaveNewbieTipData()
  end
end
function logic_newbie_assist.GetNewbieTiped(tipInfoID)
  local tipData = logic_newbie_assist.GetNewbieTipData()
  if tipData then
    local tipedID = tipData.tipedID
    if tipedID then
      return tipedID[tipInfoID]
    end
  end
  return false
end
function logic_newbie_assist.GetNewbieTipData()
  if not logic_newbie_assist.tipData then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    logic_newbie_assist.tipData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.newbieTipData)
    if not logic_newbie_assist.tipData then
      logic_newbie_assist.tipData = {}
    end
  end
  return logic_newbie_assist.tipData
end
function logic_newbie_assist.SaveNewbieTipData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if logic_newbie_assist.tipData then
    PlayerPrefsSystem.SaveTableToFile_N(logic_newbie_assist.tipData, PlayerPrefsSystem.ePlayerPrefsType.newbieTipData)
  end
end
function logic_newbie_assist.PushTipInfo(tipInfo)
  if not (tipInfo and tipInfo.Priority) or not tonumber(tipInfo.Priority) then
    return
  end
  if not logic_newbie_assist.tipQueue then
    logic_newbie_assist.tipQueue = {}
  end
  local priority = tonumber(tipInfo.Priority)
  if not logic_newbie_assist.tipQueue[priority] then
    logic_newbie_assist.tipQueue[priority] = {}
  end
  table.insert(logic_newbie_assist.tipQueue[priority], tipInfo)
  log(bWriteLog and "logic_newbie_assist.PushTipInfo " .. tostring(tipInfo.ID))
  log_tree("logic_newbie_assist.PushTipInfo", logic_newbie_assist.tipQueue)
end
function logic_newbie_assist.PopTipInfo()
  if not logic_newbie_assist.tipQueue then
    return nil
  end
  local tip
  for priority, tipInfos in pairsByKeys(logic_newbie_assist.tipQueue) do
    if next(tipInfos) then
      tip = table.remove(tipInfos, 1)
      break
    end
  end
  if tip then
    log(bWriteLog and "logic_newbie_assist.PopTipInfo " .. tostring(tip.ID))
  end
  log_tree("logic_newbie_assist.PopTipInfo", logic_newbie_assist.tipQueue)
  return tip
end
function logic_newbie_assist.RemoveTipInfo(tipInfo)
  if not (logic_newbie_assist.tipQueue and tipInfo and tipInfo.Priority) or not tonumber(tipInfo.Priority) then
    return
  end
  local priority = tonumber(tipInfo.Priority)
  if not logic_newbie_assist.tipQueue[priority] then
    return
  end
  local index
  for k, v in pairs(logic_newbie_assist.tipQueue[priority]) do
    if v == tipInfo then
      index = k
      break
    end
  end
  if index then
    table.remove(logic_newbie_assist.tipQueue[priority], index)
    log(bWriteLog and "logic_newbie_assist.RemoveTipInfo " .. tostring(tipInfo.ID))
  end
  log_tree("logic_newbie_assist.RemoveTipInfo", logic_newbie_assist.tipQueue)
end
function logic_newbie_assist.EmptyTipQueue()
  logic_newbie_assist.tipQueue = nil
end
function logic_newbie_assist.IsTipQueueEmpty()
  if logic_newbie_assist.tipQueue and next(logic_newbie_assist.tipQueue) then
    for k, v in pairs(logic_newbie_assist.tipQueue) do
      if v and next(v) then
        return false
      end
    end
  end
  return true
end
function logic_newbie_assist.CheckTipCondition(tipInfo)
  if tipInfo then
    local check_func = logic_newbie_assist[logic_newbie_assist.tipCondition[tipInfo.ConditionType]]
    if check_func and type(check_func) == "function" then
      return check_func(tipInfo.ConditionParams, tipInfo)
    end
  end
  return true
end
function logic_newbie_assist.CheckWeapon(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckWeapon(arg)
  end
  return false
end
function logic_newbie_assist.CheckSubItem(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckSubItem(arg)
  end
  return false
end
function logic_newbie_assist.CheckWeaponBullet(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckWeaponBullet(arg)
  end
  return false
end
function logic_newbie_assist.CheckHp(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckHp(arg)
  end
  return false
end
function logic_newbie_assist.CheckInBlueCircle(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckInBlueCircle(arg)
  end
  return false
end
function logic_newbie_assist.CheckInWhiteCircle(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckInWhiteCircle(arg)
  end
  return false
end
function logic_newbie_assist.CheckHelmet(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckHelmet(arg)
  end
  return false
end
function logic_newbie_assist.CheckCloth(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckCloth(arg)
  end
  return false
end
function logic_newbie_assist.CheckSpecificItem(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckSpecificItem(arg)
  end
  return false
end
function logic_newbie_assist.CheckLevel(params, tipInfo)
  local arg = params and tonumber(params[1]) or nil
  local ui = logic_newbie_assist.GetNewbieGuideTipUI()
  if arg and ui then
    return ui:CheckLevel(arg)
  end
  return false
end
function logic_newbie_assist.CheckDyingTeammateDistance(params, tipInfo)
  local MaxDistance = params and tonumber(params[1]) or nil
  log(bWriteLog and "[NewbieAssist] CheckDyingTeammateDistance " .. tostring(MaxDistance))
  if not MaxDistance then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    return false
  end
  local uTeamMatePlayerStateList
  if uPlayerState.GetTeamMatePlayerStateList then
    uTeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  end
  if not uTeamMatePlayerStateList then
    return false
  end
  local uEPlayerLiveState = import("ExtraPlayerLiveState")
  local uPawnLoc = uPlayerController:GetCurPawnLocation()
  for _, uTeammatePlayerState in pairs(uTeamMatePlayerStateList) do
    if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.LiveState == uEPlayerLiveState.InDying then
      local uTeammateCharacter = uTeammatePlayerState.CharacterOwner
      if slua.isValid(uTeammateCharacter) then
        local uTeammateLoc = uTeammateCharacter:K2_GetActorLocation()
        local nDistance = FVector.DistXY(uPawnLoc, uTeammateLoc) * 0.01
        if MaxDistance >= nDistance then
          log(bWriteLog and "[NewbieAssist] CheckDyingTeammateDistance in dying " .. tostring(nDistance))
          local LogicNewbieAssitst = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicNewbieAssist)
          LogicNewbieAssitst:AddPendingTipAction(tipInfo, logic_newbie_assist.ENUM_TIP_ACTION_TYPE.SCREEN_MARK_BY_ACTOR, {markActor = uTeammateCharacter})
          return true
        end
      end
    end
  end
  return false
end
function logic_newbie_assist.AddNearestReviveTowerScreenMark(tipInfo)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    log(bWriteLog and "[NewbieAssist] AddNearestReviveTowerScreenMark GameState invalid")
    return
  end
  if not GameState.CheckReviveTimeEnd or GameState:CheckReviveTimeEnd() == true then
    log(bWriteLog and "[NewbieAssist] AddNearestReviveTowerScreenMark ReviveTime End")
    return
  end
  local ReviveBattleUIComponentClass = import("ReviveBattleUIComponent")
  local ReviveBattleUIComponent = GameState:GetComponentByClass(ReviveBattleUIComponentClass)
  if not slua.isValid(ReviveBattleUIComponent) then
    log(bWriteLog and "[NewbieAssist] AddNearestReviveTowerScreenMark ReviveBattleUIComponent invalid")
    return
  end
  local loc = ReviveBattleUIComponent:GetNearestReviveTowerLoc()
  if not loc then
    log(bWriteLog and "[NewbieAssist] AddNearestReviveTowerScreenMark loc invalid")
    return
  end
  local LogicNewbieAssitst = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicNewbieAssist)
  LogicNewbieAssitst:AddPendingTipAction(tipInfo, logic_newbie_assist.ENUM_TIP_ACTION_TYPE.SCREEN_MARK_BY_LOC, {markLoc = loc})
end
function logic_newbie_assist.CheckHaveRevivableTeamate(params, tipInfo)
  log(bWriteLog and "[NewbieAssist] CheckHaveRevivableTeamate ")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    return false
  end
  local uTeamMatePlayerStateList
  if uPlayerState.GetTeamMatePlayerStateList then
    uTeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  end
  if not uTeamMatePlayerStateList then
    return false
  end
  local uEPlayerLiveState = import("ExtraPlayerLiveState")
  local uPawnLoc = uPlayerController:GetCurPawnLocation()
  for _, uTeammatePlayerState in pairs(uTeamMatePlayerStateList) do
    if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.LiveState == uEPlayerLiveState.InDied and uTeammatePlayerState.GetRevivalCount and uTeammatePlayerState:GetRevivalCount() > 0 then
      logic_newbie_assist.AddNearestReviveTowerScreenMark(tipInfo)
      return true
    end
  end
  return false
end
function logic_newbie_assist.CheckHaveActorInDistance(params, tipInfo)
  local MaxDistance = params and tonumber(params[1]) or nil
  local FindType = params and tostring(params[2]) or nil
  local Cls
  if FindType then
    if FindType == "Vehicle" then
      Cls = "STExtraVehicleBase"
    elseif FindType == "AirDropBox" then
      Cls = "/Script/ShadowTrackerExtra.AirDropBoxActor"
    end
  end
  log(bWriteLog and "[NewbieAssist] CheckHaveActorInDistance " .. tostring(MaxDistance) .. " " .. tostring(FindType))
  if not MaxDistance or not Cls then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local GameplayStatics = import("GameplayStatics")
  local ActorCls = import("/Script/Engine.Actor")
  local RealCls = import(Cls)
  local Actors = GameplayStatics.GetAllActorsOfClass(uPlayerController, RealCls, slua.Array(UEnums.EPropertyClass.Object, ActorCls))
  if slua.isValid(Actors) then
    local uPawnLoc = uPlayerController:GetCurPawnLocation()
    for k, a in pairs(Actors) do
      local flag = true
      if FindType == "Vehicle" then
        local uDriver = a:GetDriver()
        if slua.isValid(uDriver) then
          flag = false
        end
      end
      local actorLoc = a:K2_GetActorLocation()
      local nDistance = FVector.DistXY(uPawnLoc, actorLoc) * 0.01
      if MaxDistance >= nDistance and flag then
        log(bWriteLog and "[NewbieAssist] CheckHaveActorInDistance " .. tostring(FindType) .. " in distance " .. tostring(nDistance))
        local LogicNewbieAssitst = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicNewbieAssist)
        LogicNewbieAssitst:AddPendingTipAction(tipInfo, logic_newbie_assist.ENUM_TIP_ACTION_TYPE.SCREEN_MARK_BY_ACTOR, {markActor = a})
        return true
      end
    end
  end
  return false
end
return logic_newbie_assist