local BattleResultCountDownLogic = {}
local utility = require("common.utility")
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
function BattleResultCountDownLogic:OnInit()
  print(bWriteLog and "BattleResultCountDownLogic:OnInit")
  self.BattleResultCakePlacementDelayTime = 60
  self.BattleResultCakePlacementDelayTime_SkipFreeStage = 4.5
  self.BattleResultWinnerFreeMoveTime = 10
  self.BattleResultHeavyWeaponWinnerFreeMoveTime = 40
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_COUNTDOWN_CLOSE, self.OnCountDownClose, self)
  self.IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
end
function BattleResultCountDownLogic:OnRelease()
  print(bWriteLog and "BattleResultCountDownLogic:OnRelease")
end
function BattleResultCountDownLogic:OnBattleResult(result)
  print(bWriteLog and "BattleResultCountDownLogic:OnBattleResult")
  self.BattleReason = result.Reason
  self.Rank = result.team_rank
  self.Terminator = result.terminator or ""
  self.sub_mode = result.sub_mode
  local commonData = self:GetBattleResultData()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local Config = GamePlayTools.GetCurrentConfig("HighlightMomentConfig")
  self.HighlightList = {}
  if commonData and Config and Config.BattleResultAchievementHighlightMap then
    for i, info in pairs(result.TeammateList) do
      if commonData.BP_myname == info.Name and info.Achievements then
        for AchievementID, HighlightID in pairs(Config.BattleResultAchievementHighlightMap) do
          if info.Achievements[AchievementID] then
            print(bWriteLog and "BattleResultCountDownLogic:OnBattleResult AchievementID:" .. AchievementID .. " HighlightID:" .. HighlightID)
            table.insert(self.HighlightList, HighlightID)
          end
        end
      end
    end
  end
end
function BattleResultCountDownLogic:OnSwitchCheck()
  if self.BattleReason == "win" and self.Rank == 1 then
    return true
  end
  self:HidBattleMainUI()
  return false
end
function BattleResultCountDownLogic:OnResultProcessStart()
  print(bWriteLog and "BattleResultCountDownLogic:OnResultProcessStart")
  local isTerminator = false
  local resultData = self:GetBattleResultData()
  log(bWriteLog and "Terminator:" .. self.Terminator .. " Myname:" .. (resultData.BP_myname or ""))
  if self.Terminator == resultData.BP_myname then
    isTerminator = true
  end
  self.delayTime = self.BattleResultCakePlacementDelayTime
  xpcall(function()
    self.delayTime = self:GetWinnerTimeDelayTime()
  end, utility.ErrorMessageHandler)
  local countDownCfg = {
    DelayTime = self.delayTime,
    IsTerminator = isTerminator,
    ShowedWinLogo = true,
    Reason = self.BattleReason
  }
  if UIManager and UIManager.ShowUI(UIManager.UI_Config_InGame.GameOverCountDown_UIBP, countDownCfg) then
    print(bWriteLog and "BattleResultCountDownLogic:OnResultProcessStart Show Suc")
  end
  local is_ob = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectator and uPlayerController.IsInPetSpectator then
    if uPlayerController:IsSpectator() or uPlayerController:IsInPetSpectator() or uPlayerController.bIsForReplay then
      is_ob = true
    end
    print(bWriteLog and "uPlayerController.IsSpectator", uPlayerController.IsSpectator, uPlayerController:IsSpectator(), uPlayerController.bIsForReplay)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PHOTOGRAPHER_STATE, self.OnPhotoGrapherStateChange, self)
  local bShowMainRT = true
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem and PhotoGrapherSubSystem.bIsPhotoGrapherMode then
    bShowMainRT = false
  end
  if bShowMainRT and UIManager.UI_Config_InGame.MVPStatueMainRT then
    UIManager.ShowUI(UIManager.UI_Config_InGame.MVPStatueMainRT)
  end
  if not ResultUtil.SimplifiedWinnerTime(self.sub_mode) and not ResultUtil.SkipWinFreeStage() then
    print(bWriteLog and "ingame_battle_result_mvp_statue", LobbySystem.CheckOpen(BP_ENUM_RESULT_MVP_STATUE_LIKE))
    local HighestAlivePlayerUID = self:GetHighestAlivePlayerUID()
    if DataMgr ~= nil and DataMgr.roleData ~= nil and HighestAlivePlayerUID == tonumber(DataMgr.roleData.uid) then
      local ds_net = require("ds_net")
      ds_net.SendMessage("ingame_battle_result_mvp_statue", {})
      if LobbySystem.CheckOpen(BP_ENUM_RESULT_MVP_STATUE_LIKE) then
        self.bIsMVP = true
        if self:GetIngameLikeClientSubSystem() then
          print(bWriteLog and "BattleResultCountDownLogic:OnResultProcessStart bIsMVP")
          self.IngameLikeClientSubSystem.bIsMVP = true
          if UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
            UIManager.HideUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
          end
        end
      end
    end
  end
  self:AddGameTimer(4.5, false, function()
    if not self.bIsMVP then
      self:ShowTriggerLike()
    end
    if not is_ob then
      local WinFireworksClientLogic = require("GameLua.Activity.IG1700.Client.WinFireworksClientLogic")
      WinFireworksClientLogic.SendWinFireworksReady()
    end
  end)
  EventSystem:postEventSafety(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_START)
  if slua.isValid(uPlayerController) and uPlayerController.SetIsShowBlood then
    print(bWriteLog and "BattleResultCountDownLogic:OnResultProcessStart SetIsShowBlood")
    uPlayerController:SetIsShowBlood(false)
  end
  local HighlightMomentSubsystem = SubsystemMgr:Get("HighlightMomentSubsystem")
  if HighlightMomentSubsystem then
    for i, HighlightID in ipairs(self.HighlightList) do
      HighlightMomentSubsystem:ClientTriggeredByBattleResult(HighlightID)
    end
  end
  return true
end
function BattleResultCountDownLogic:OnPhotoGrapherStateChange(_, __, bState)
  print(bWriteLog and "BattleResultCountDownLogic:OnPhotoGrapherStateChange ")
  if bState then
    if UIManager.UI_Config_InGame.MVPStatueMainRT then
      UIManager.HideUI(UIManager.UI_Config_InGame.MVPStatueMainRT)
      print(bWriteLog and "BattleResultCountDownLogic:OnPhotoGrapherStateChange Hide")
    end
  elseif UIManager.IsUIShow(UIManager.UI_Config_InGame.GameOverCountDown_UIBP) and not UIManager.IsUIShow(UIManager.UI_Config_InGame.MVPStatueMainRT) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.MVPStatueMainRT)
    print(bWriteLog and "BattleResultCountDownLogic:OnPhotoGrapherStateChange Show")
  end
end
function BattleResultCountDownLogic:OnPostReconnection(curProcessIndex)
  print(bWriteLog and "BattleResultCountDownLogic:OnPostReconnection", curProcessIndex)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    uPlayerController:CastUIMsg("ShowAllUIForDelayResult", "ingame")
  end
end
function BattleResultCountDownLogic:OnApplicationReactived(curProcessIndex)
  print(bWriteLog and "BattleResultCountDownLogic:OnApplicationReactived", curProcessIndex)
  if UIManager and UIManager.IsUIShow(UIManager.UI_Config_InGame.TeamPanel) then
    UIManager.HideUI(UIManager.UI_Config_InGame.TeamPanel)
  end
end
function BattleResultCountDownLogic:GetWinnerTimeDelayTime()
  local delay_time = self.BattleResultCakePlacementDelayTime
  if ResultUtil.SimplifiedWinnerTime(self.sub_mode) then
    delay_time = self.BattleResultWinnerFreeMoveTime
    local uGameState = slua_GameFrontendHUD:GetGameState()
    local EGameModeType = import("EGameModeType")
    if slua.isValid(uGameState) and uGameState.GameModeType and uGameState.GameModeType == EGameModeType.EHeavyWeaponGameMode then
      delay_time = self.BattleResultHeavyWeaponWinnerFreeMoveTime
    end
  elseif ResultUtil.SkipWinFreeStage() then
    delay_time = self.BattleResultCakePlacementDelayTime_SkipFreeStage
  end
  return delay_time
end
function BattleResultCountDownLogic:GetHighestAlivePlayerUID()
  local showAvatarLogic = self:GetResultProcessLogic("BattleResultShowAvatarLogic")
  if showAvatarLogic then
    return showAvatarLogic:GetHighestAlivePlayerUID()
  else
    return 0
  end
end
function BattleResultCountDownLogic:OnResultProcessEnd()
  print(bWriteLog and "BattleResultCountDownLogic:OnResultProcessEnd")
  self:HidBattleMainUI()
  if UIManager and UIManager.IsUIShow(UIManager.UI_Config_InGame.GameOverCountDown_UIBP) then
    print(bWriteLog and "BattleResultCountDownLogic:OnResultProcessEnd close GameOverCountDown_UIBP")
    UIManager.HideUI(UIManager.UI_Config_InGame.GameOverCountDown_UIBP)
  end
end
function BattleResultCountDownLogic:HidBattleMainUI()
  print(bWriteLog and "BattleResultCountDownLogic:HidBattleMainUI")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    if uPlayerController.CharacterTouchMove then
      uPlayerController.CharacterTouchMove = false
    end
    if uPlayerController.CastUIMsg then
      uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
    end
  end
end
function BattleResultCountDownLogic:OnCountDownClose()
  print(bWriteLog and "BattleResultCountDownLogic:OnCountDownClose")
  EventSystem:postEventSafety(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END)
  if UIManager.UI_Config_InGame.MVPStatueMainRT ~= nil then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MVPStatueMainRT)
  end
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:CloseAllLikeUI()
  end
  self:EndResultProcess()
end
function BattleResultCountDownLogic:ShowTriggerLike()
  print(bWriteLog and "[BattleResultCountDownLogic] ShowTriggerLike")
  local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
  local MyPlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(MyPlayerState) then
    print(bWriteLog and "[BattleResultCountDownLogic] invalid player state")
    return
  end
  if not MyPlayerState.GetTeamMatePlayerStateList then
    print(bWriteLog and "[BattleResultCountDownLogic] invalid GetTeamMatePlayerStateList")
    return
  end
  local TeammatePlayerState = MyPlayerState:GetTeamMatePlayerStateList({}, true)
  if not TeammatePlayerState or TeammatePlayerState:Num() <= 0 then
    print(bWriteLog and "[BattleResultCountDownLogic] invalid teammate")
    return
  end
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  local Message = {}
  Message.PlayerKey = MyPlayerState.PlayerKey
  Message.OtherPlayerUID = 0
  Message.ConditionID = IngameLikeConfig.Win
  Message.ItemID = 0
  if self:GetIngameLikeClientSubSystem() then
    local MyCharacter = MyPlayerState:GetPlayerCharacter()
    if slua.isValid(MyCharacter) and MyCharacter:IsAlive() then
      self.IngameLikeClientSubSystem:ReceiveTirggerLike(Message)
    elseif IngameLikeUtilClient.HasAliveTeammate(false) then
      self.IngameLikeClientSubSystem:ReceiveTriggerWatchLike(Message)
    end
  end
end
function BattleResultCountDownLogic:GetIngameLikeClientSubSystem()
  if nil == self.IngameLikeClientSubSystem then
    self.IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
    if self.IngameLikeClientSubSystem == nil then
      print(bWriteLog and "Ingame_WatchLike_UIBP cannot get IngameLikeClientSubSystem!!!")
    end
  end
  return self.IngameLikeClientSubSystem
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CBattleResultCountDownLogic = class(BattleResultProcessBaseLogic, nil, BattleResultCountDownLogic)
return CBattleResultCountDownLogic