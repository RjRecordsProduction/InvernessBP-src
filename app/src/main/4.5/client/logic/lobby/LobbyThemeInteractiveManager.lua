local LobbyThemeInteractiveManager = {}
function LobbyThemeInteractiveManager:DefineAndResetData()
  log(bWriteLog and "LobbyThemeInteractiveManager:DefineAndResetData")
  self.sequencePlayer = nil
  self.InteractiveActor = nil
  self.InteractiveUI = nil
  self.InteractiveSeqPlayer = nil
  self.InteractiveSeqActor = nil
  self.ChangeRateTimer = nil
  self.InteractiveTickActor = nil
end
function LobbyThemeInteractiveManager:OnInitialize()
end
function LobbyThemeInteractiveManager:OnLogOut()
end
function LobbyThemeInteractiveManager:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "LobbyThemeInteractiveManager:OnPreSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  self.sequencePlayer = nil
end
function LobbyThemeInteractiveManager:GetDisplayItemID()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  return LobbyThemeManager:GetDisplayItemID()
end
function LobbyThemeInteractiveManager:DestroyInteractive()
  log(bWriteLog and "LobbyThemeInteractiveManager:DestroyInteractive")
  if self.InteractiveUI and self.InteractiveUI.UIRoot and slua.isValid(self.InteractiveUI.UIRoot) then
    self.InteractiveUI:Close()
  end
  self.InteractiveUI = nil
  if self.InteractiveActor and slua.isValid(self.InteractiveActor) then
    self.InteractiveActor:K2_DestroyActor()
  end
  self.InteractiveActor = nil
end
function LobbyThemeInteractiveManager:DestroyInteractiveSequencePlayer()
  log(bWriteLog and "LobbyThemeInteractiveManager:DestroyInteractiveSequencePlayer")
  if self.sequencePlayer and slua.isValid(self.sequencePlayer) and self.ChangeRateTimer then
    local preRate = self.sequencePlayer:GetPlayRate()
    if math.abs(preRate - 1.0) >= 1.0E-4 then
      self.sequencePlayer:SetPlayRate(1.0)
    end
  end
  if self.InteractiveSeqPlayer and slua.isValid(self.InteractiveSeqPlayer) then
    self:RemoveControlEvent(self.InteractiveSeqPlayer, "OnFinished")
  end
  self.InteractiveSeqPlayer = nil
  if self.InteractiveSeqActor and slua.isValid(self.InteractiveSeqActor) then
    self.InteractiveSeqActor:K2_DestroyActor()
  end
  self.InteractiveSeqActor = nil
  if self.InteractiveTickActor and slua.isValid(self.InteractiveTickActor) then
    self.InteractiveTickActor:K2_DestroyActor()
  end
  self.InteractiveTickActor = nil
end
function LobbyThemeInteractiveManager:RemoveChangeRateTimer()
  if self.ChangeRateTimer then
    self:RemoveTimer(self.ChangeRateTimer)
  end
  self.ChangeRateTimer = nil
end
function LobbyThemeInteractiveManager:CreateInteractive(sequencePlayer)
  self.  local DisplayItemID = self:GetDisplayItemID()
  local HallThemeFeture = CDataTable.GetTableData("HallThemeFeture", DisplayItemID)
  if not HallThemeFeture then
    return
  end
  local HallThemeItem = CDataTable.GetTableData("HallThemeItem", DisplayItemID)
  if not HallThemeItem or HallThemeItem.SwitchPosition == "" then
    return
  end
  self:DestroyInteractive()
  local world = slua_GameFrontendHUD:GetWorld()
  local tClass = import("/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_SwitchIight_3D_UIBP.Lobby_Main_SwitchIight_3D_UIBP_C")
  self.InteractiveActor = world:SpawnActor(tClass, nil, nil, nil)
  if not slua.isValid(self.InteractiveActor) then
    return
  end
  log(bWriteLog and string.format("LobbyThemeInteractiveManager:CreateInteractive. DisplayItemID:%s", DisplayItemID))
  local location = LobbySceneManager.ParseVec3(HallThemeItem.SwitchPosition)
  self.InteractiveActor:K2_SetActorLocation(FVector(location.x_f, location.y_f, location.z_f), false, nil, false)
  self.InteractiveActor:K2_SetActorRotation(FRotator(0, 90, 0), false)
  local scale = LobbySceneManager.ParseVec3(HallThemeItem.SwitchScale)
  self.InteractiveActor:SetActorScale3D(FVector(scale.x_f, scale.y_f, scale.z_f))
  local userWidget = self.InteractiveActor.Widget:GetUserWidgetObject()
  local UIClass = require(UIManager.UI_Config.Lobby_Main_SwitchIight_UIBP.moduleName)
  self.InteractiveUI = UIClass(DisplayItemID)
  self.InteractiveUI:InitWithWidget(userWidget)
  self.InteractiveUI:OnShow()
end
function LobbyThemeInteractiveManager:StartInteractive()
  local DisplayItemID = self:GetDisplayItemID()
  if self.InteractiveSeqPlayer then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:StartInteractive InteractiveSeqPlayer is not nil . DisplayItemID:%s", DisplayItemID))
    return
  end
  local HallThemeFeture = CDataTable.GetTableData("HallThemeFeture", DisplayItemID)
  if not (HallThemeFeture and HallThemeFeture.seqID) or HallThemeFeture.seqID <= 0 then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:StartInteractive HallThemeFeture is nil or seqID is 0. DisplayItemID:%s", DisplayItemID))
    return
  end
  local LobbyLevelSequence = CDataTable.GetTableData("LobbyLevelSequence", HallThemeFeture.seqID)
  if not (LobbyLevelSequence and LobbyLevelSequence.BluePrintPath) or LobbyLevelSequence.BluePrintPath == "" then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:StartInteractive LobbyLevelSequence is nil or BluePrintPath is nil. seqID:%s", HallThemeFeture.seqID))
    return
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  local skinId = LobbyThemeManager:GetDisplayLobbySkin()
  self:AsyncLoadAsset(LobbyLevelSequence.BluePrintPath, function(sequence)
    local curSkinId = LobbyThemeManager:GetDisplayLobbySkin()
    if skinId ~= curSkinId then
      log(bWriteLog and string.format("LobbyThemeInteractiveManager:StartInteractive skinId is changed. skinId:%s, curSkinId:%s", skinId, curSkinId))
      return
    end
    local LobbyCameraFunctionLibrary = import("/Game/UMG/UI_Utility/LobbyCameraFunctionLibrary.LobbyCameraFunctionLibrary_C")
    local UIUtil = require("client.common.ui_util")
    self:DestroyInteractiveSequencePlayer()
    self.InteractiveSeqPlayer, self.InteractiveSeqActor = LobbyCameraFunctionLibrary.CreateLevelSequencePlayerAndActor(sequence, UIUtil.GetGameInstance())
    if not self.InteractiveSeqPlayer then
      log(bWriteLog and string.format("LobbyThemeInteractiveManager:StartInteractive InteractiveSeqPlayer is nil"))
      return
    end
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:StartInteractive DisplayItemID:%s", DisplayItemID))
    self:AddControlEvent(self.InteractiveSeqPlayer, "OnFinished", self.OnFinishedInteractiveSequence, self)
    self.InteractiveSeqPlayer:PlayLooping(0)
    self:_SpeedUpInteractive(HallThemeFeture.speed)
    self:InteractiveToTeam(DisplayItemID)
    if self:GetDisplayItemID() == 202408101 then
      local uWorld = slua_GameFrontendHUD:GetWorld()
      local ActorClass = import("/Game/Arts_Scenes/Lobby/LobbyTheme/Lobby_Tarot_SSS_400/TarotHermitLobbySkySpinActor.TarotHermitLobbySkySpinActor_C")
      if slua.isValid(uWorld) and ActorClass then
        self.InteractiveTickActor = uWorld:SpawnActor(ActorClass, nil, nil, nil)
      end
    end
  end)
end
function LobbyThemeInteractiveManager:OnFinishedInteractiveSequence()
  if self.InteractiveSeqPlayer then
    self:RemoveControlEvent(self.InteractiveSeqPlayer, "OnFinished")
  end
  self:_SpeedDownInteractive()
  self:DestroyInteractiveSequencePlayer()
end
function LobbyThemeInteractiveManager:InteractiveToTeam(DisplayItemID)
  if self.previewStatus then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:InteractiveToTeam previewStatus is true. DisplayItemID:%s", DisplayItemID))
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local iTeamNum = TeamUpNewSystem.GetTeamNum()
  local bIsTeamLeader = TeamUpNewSystem.IsTeamLeader()
  if iTeamNum <= 1 or not bIsTeamLeader then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:InteractiveToTeam iTeamNum:%s, bIsTeamLeader:%s. DisplayItemID:%s", iTeamNum, tostring(bIsTeamLeader), DisplayItemID))
    return
  end
  log(bWriteLog and string.format("LobbyThemeManager:InteractiveToTeam DisplayItemID:%s", DisplayItemID))
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_player_action(DisplayItemID, 0, 1)
end
function LobbyThemeInteractiveManager:IsPreviewStatus()
  return self.previewStatus
end
function LobbyThemeInteractiveManager:_GetSpeedTable(speed)
  if not (self.sequencePlayer and speed) or type(speed) ~= "string" or speed == "" then
    return nil
  end
  local StringUtil = require("common.string_util")
  local arrSpeed = StringUtil.Split(speed, "|")
  if not arrSpeed or #arrSpeed < 3 then
    return nil
  end
  return {
    speed = tonumber(arrSpeed[1]),
    increase = tonumber(arrSpeed[2]),
    decrease = tonumber(arrSpeed[3])
  }
end
function LobbyThemeInteractiveManager:_SpeedUpInteractive(speed)
  local speedTable = self:_GetSpeedTable(speed)
  if not speedTable then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:_SpeedUpInteractive speedTable is nil. speed:%s", speed))
    return
  end
  local curRate = 1
  local totalTickNum = math.ceil(speedTable.increase / 0.1)
  local perChangeSpeed = math.ceil((speedTable.speed - 1) / totalTickNum)
  self:RemoveChangeRateTimer()
  self.ChangeRateTimer = self:AddTimerLoop(0, function()
    curRate = curRate + perChangeSpeed
    if curRate >= speedTable.speed then
      curRate = speedTable.speed
      self:RemoveChangeRateTimer()
    end
    if self.sequencePlayer then
      self.sequencePlayer:SetPlayRate(curRate)
    end
  end, totalTickNum, 0.1)
end
function LobbyThemeInteractiveManager:_SpeedDownInteractive()
  local DisplayItemID = self:GetDisplayItemID()
  local HallThemeFeture = CDataTable.GetTableData("HallThemeFeture", DisplayItemID)
  if not (HallThemeFeture and HallThemeFeture.speed) or type(HallThemeFeture.speed) ~= "string" or HallThemeFeture.speed == "" then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:_SpeedDownInteractive HallThemeFeture is nil or seqID is 0. DisplayItemID:%s", DisplayItemID))
    return
  end
  local speedTable = self:_GetSpeedTable(HallThemeFeture.speed)
  if not speedTable then
    log(bWriteLog and string.format("LobbyThemeInteractiveManager:_SpeedDownInteractive speedTable is nil. speed:%s, DisplayItemID:%s", HallThemeFeture.speed, DisplayItemID))
    return
  end
  local curRate = speedTable.speed
  local totalTickNum = math.ceil(speedTable.decrease / 0.1)
  local perChangeSpeed = math.ceil((speedTable.speed - 1) / totalTickNum)
  self:RemoveChangeRateTimer()
  self.ChangeRateTimer = self:AddTimerLoop(0, function()
    curRate = curRate - perChangeSpeed
    if curRate <= 1 then
      curRate = 1
      self:RemoveChangeRateTimer()
    end
    if self.sequencePlayer then
      self.sequencePlayer:SetPlayRate(curRate)
    end
  end, totalTickNum, 0.1)
end
function LobbyThemeInteractiveManager:UpdateSequencePlayer(sequencePlayer)
  self.end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyThemeInteractiveManager = class(CModuleBase, nil, LobbyThemeInteractiveManager)
return CLobbyThemeInteractiveManager