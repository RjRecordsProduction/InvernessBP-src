local SingleTrainClientLogic = {
  cache_throwBombUserSelect = 1,
  AIMachineID = 16001,
  ShootingMachineID = 16002,
  BombMachineID = 16003,
  TrainClientTLog = {}
}
function SingleTrainClientLogic:OnInitModeUI()
  log(bWriteLog and "SingleTrainClientLogic OnInitModeUI")
  SingleTrainClientLogic.__super.OnInitModeUI(self)
  local SingleTrainingHandler = require("client.network.Protocol.SingleTrainingHandler")
  SingleTrainingHandler.ClearUserRankData()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState and slua.isValid(uGameState) then
    self:AddControlEvent(uGameState, "OnUpdateTrainButton", function(bShow, iMachineID)
      log(bWriteLog and "OnUpdateTrainButton" .. tostring(bShow))
      if bShow then
        UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_RuleDescription, iMachineID)
        local ruleUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_RuleDescription)
        ruleUI.UIRoot.Slot:SetZOrder(0)
      else
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_RuleDescription)
      end
    end)
    self:AddControlEvent(uGameState, "OnClickMachineButton", function(iMachineID)
      log(bWriteLog and "OnClickMachineButton " .. iMachineID)
      if iMachineID == self.AIMachineID then
        UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode)
      elseif iMachineID == self.ShootingMachineID then
        UIManager.ShowUI(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect)
      else
        if iMachineID == self.BombMachineID then
          UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode)
        else
        end
      end
    end)
    self:AddControlEvent(uGameState, "OnLeaveActiveAera", function(iMachineID)
      log(bWriteLog and "OnLeaveActiveAera " .. iMachineID)
      if iMachineID == self.AIMachineID and UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode) then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode)
      elseif iMachineID == self.ShootingMachineID and UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect) then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect)
      else
        if iMachineID == self.BombMachineID and UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode) then
          UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode)
        else
        end
      end
    end)
    self:AddControlEvent(uGameState, "OnClickMapGuide", function()
      log(bWriteLog and "OnClickMapGuide")
      UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_MapGuide)
    end)
  end
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local playerController = UGameplayStatics.GetPlayerController(worldContextObject, 0)
  if playerController and slua.isValid(playerController) then
    local uTargetTrain = playerController.TargetTrain
    if uTargetTrain and slua.isValid(uTargetTrain) then
      local ShootingLogic = require("GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic")
      uTargetTrain.ShootingAreaID = ShootingLogic.nInAreaID
      self:AddControlEvent(uTargetTrain, "OnInAreaIDUpdate", function(InAreaID)
        log(bWriteLog and "SingleTrainClientLogic OnIsInAreaUpdate:" .. tostring(InAreaID))
        EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_UPDATE_INAREA_STAT, InAreaID)
      end)
    end
    self:AddControlEvent(playerController, "ClientOnEnterVehicle", function(SeatType)
      log(bWriteLog and "SingleTrainClientLogic ClientOnEnterVehicle")
      if UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode) then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode)
      elseif UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect) then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect)
      elseif UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode) then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode)
      end
    end)
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sensitivity_Enter)
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_PlayingHUDUI)
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleShootingTrainBattleUI)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_SHOOTING_END, self.HandleShootingResult, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_START, self.HandleTrainStart, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_END, self.HandleTrainEnd, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_ThrowBombResult, self.HandleThowBombResult, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_CLIENT_TLOG, self.HandleTLogTrigger, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_INIT, self.HandleInitWeapon, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_RECONNECT, self.HandleReconnectWeapon, self)
  self.TrainClientTLog = {}
end
function SingleTrainClientLogic:HandleShootingResult(eventType, eventid, tresultData)
  log_tree("HandleShootingResult", tresultData)
  if tresultData then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleShootingTrainResult, tresultData)
  end
end
function SingleTrainClientLogic:HandleTrainStart(eventType, eventid, tresultData)
  log(bWriteLog and "HandleTrainStart")
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState and slua.isValid(uGameState) then
    uGameState.bIsTraining = true
  end
end
function SingleTrainClientLogic:HandleTrainEnd(eventType, eventid, tresultData)
  log(bWriteLog and "HandleTrainEnd")
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState and slua.isValid(uGameState) then
    uGameState.STDeadBoxClientShowFeature:CleanAIDeadBox()
    uGameState.bIsTraining = false
  end
end
function SingleTrainClientLogic:HandleThowBombResult(eventType, eventid, tresultData)
  log_tree("HandleThowBombResult", tresultData)
  if tresultData.UseTime < 0 then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_Result, tresultData)
end
function SingleTrainClientLogic:HandleInitWeapon(nEventType, nEventID, nPlayerKey, uWeapon)
  print(bWriteLog and "SingleTraining Logic:HandleInitWeapon..", uWeapon)
  self:SetWeaponReloadWithNoCostFromEntity(uWeapon)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and Game:GetPlayerKey(uPlayerCharacter) == nPlayerKey then
    local WeaponAvatarComponent = uWeapon.WeaponAvatarComponent
    if slua.isValid(WeaponAvatarComponent) and WeaponAvatarComponent.OnWeaponPartsRender then
      if uWeapon.WeaponAttachmentEquippedRegisterFun then
        WeaponAvatarComponent.OnWeaponPartsRender:Remove(uWeapon.WeaponAttachmentEquippedRegisterFun)
      end
      uWeapon.WeaponAttachmentEquippedRegisterFun = WeaponAvatarComponent.OnWeaponPartsRender:Add(function(SlotID)
        FuncUtil.SafeCallFun(self, "HandleWeaponEquipParts", self, uWeapon.Object, SlotID)
      end)
    end
  end
end
function SingleTrainClientLogic:HandleWeaponEquipParts(uWeapon, SlotID)
  print(bWriteLog and "SingleTrainClientLogic:HandleWeaponEquipParts")
end
function SingleTrainClientLogic:HandleReconnectWeapon(nEventType, nEventID, uWeapon)
  print(bWriteLog and "SingleTraining Logic:HandleReconnectWeapon..", uWeapon)
  self:SetWeaponReloadWithNoCostFromEntity(uWeapon)
end
function SingleTrainClientLogic:SetWeaponReloadWithNoCostFromEntity(uWeapon)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local EGameModeCPPType = import("EGameModeType")
    if uGameState.GameModeType == EGameModeCPPType.ETraining and slua.isValid(uWeapon) and uWeapon.SetReloadWithNoCostFromEntity then
      uWeapon:SetReloadWithNoCostFromEntity(true)
    end
  end
end
function SingleTrainClientLogic:CheckTimeEnough(InCallBack)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState and slua.isValid(uGameState) and uGameState.EndStateTime then
    local nCurrentTime = uGameState:GetServerWorldTimeSeconds()
    local nLeftTime = uGameState.EndStateTime - nCurrentTime
    if nLeftTime < 300 then
      if UIManager then
        UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrainEndTrainTipsUI, 34867, function()
          InCallBack()
        end)
      end
    else
      InCallBack()
    end
  end
end
function SingleTrainClientLogic:OnPreExit()
  SingleTrainClientLogic.__super.OnPreExit(self)
  log(bWriteLog and "SingleTrainClientLogic OnPreExit")
  local ClientNet = require("GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic")
  if ClientNet then
    ClientNet.Clear()
  end
  self:SendClientTLog()
end
function SingleTrainClientLogic:HandleTLogTrigger(_, _, TLogKey)
  if TLogKey then
    if self.TrainClientTLog[TLogKey] == nil then
      self.TrainClientTLog[TLogKey] = 1
    else
      self.TrainClientTLog[TLogKey] = self.TrainClientTLog[TLogKey] + 1
    end
    log(bWriteLog and "SingleTrainClientLogic: HandleTLogTrigger" .. TLogKey .. " Value:" .. tostring(self.TrainClientTLog[TLogKey]))
  end
end
function SingleTrainClientLogic:SendClientTLog()
  log_tree("SingleTrainClientLogic:SendClientTLog", self.TrainClientTLog)
  local sens_info = {}
  sens_info.IsClickedSensEntry = self.TrainClientTLog.IsClickedSensEntry or 0
  sens_info.SensChangedCount = self.TrainClientTLog.SensChangedCount or 0
  sens_info.UploadSensSettingsCount = self.TrainClientTLog.UploadSensSettingsCount or 0
  sens_info.ResetSensSettingsCount = self.TrainClientTLog.ResetSensSettingsCount or 0
  NetUtil.SendPkg("log_sensitivity_settings_in_training", sens_info)
  self.TrainClientTLog = {}
end
function SingleTrainClientLogic:CheckShouldShowMapLegend()
  return false
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Client.ClientLogicEntry")
local CSingleTrainClientLogic = class(object, nil, SingleTrainClientLogic)
return CSingleTrainClientLogic