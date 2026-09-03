local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local BaseClientLogic = {
  OldUIConfig = nil,
  ShowAliasTipMap = nil,
  bHasInitModeUI = false,
  bHasGenerateAutoCreateUI = false,
  CountYellow = 0.25,
  CountRed = 0.1
}
function BaseClientLogic:OnPostEnter(status)
  local TApmSystem = require("GameLua.Mod.Library.Client.TApm.TApmSystem")
  TApmSystem.Init()
  local BornIslandSoundUtils = require("GameLua.Mod.Library.Client.BornIslandSoundUtils")
  BornIslandSoundUtils:GunshotAttenuation()
end
function BaseClientLogic:RegistEvents()
  print(bWriteLog and "BaseClientLogic:RegistEvents")
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(playerController) then
    return
  end
  self:AddControlEvent(playerController, "OnPlayerChangeViewtargetToPlane", function()
    self:OnPlayerChangeViewtargetToPlane()
  end)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_KICK_PLAYER_BUTTON, self.ShowKickPlayerButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_DARK_NIGHT, self.OnShowDarkNight, self)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local bIsStandalone = UKismetSystemLibrary.IsStandalone(playerController)
  print(bWriteLog and "[YY-D]BaseClientLogic:RegistEvent bIsStandalone = " .. tostring(bIsStandalone))
  if not bIsStandalone then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnImprisonStateChange", self.OnImprisonStateChange, self)
  end
  GameplayData.AddGameStateEvent(self, "OnUICustomBehavior", self.OnUICustomBehavior, self)
  self:AddUIMessageEvent("TestRealTimeBan", function()
    local RealTimeBlocking = UIManager.GetUI(UIManager.UI_Config_InGame.RealTimeBlocking)
    RealTimeBlocking = RealTimeBlocking or UIManager.ShowUI(UIManager.UI_Config_InGame.RealTimeBlocking)
    if RealTimeBlocking then
      RealTimeBlocking:SetShowData("BehaviorType", "Params")
    end
  end)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_DANCESTATE_CHANGED, self.OnDanceStateChange, self)
  print(bWriteLog and "BaseClientLogic:RegistEvents success")
end
function BaseClientLogic:ShowKickPlayerButton()
  local ButtonKickPlayer = UIManager.GetUI(UIManager.UI_Config_InGame.ButtonKickPlayer)
  if not ButtonKickPlayer then
    UIManager.ShowUI(UIManager.UI_Config_InGame.ButtonKickPlayer)
  end
end
function BaseClientLogic:OnShowDarkNight()
  local ConfirmInfo = {
    Style = "Simple",
    Content = LocUtil.GetLocalizeResStr(6287),
    LeftLable = LocUtil.GetLocalizeResStr(6309),
    RightLable = LocUtil.GetLocalizeResStr(6310)
  }
  function ConfirmInfo.RightCB(ConfirmUI)
    local STExtraUIUtils = import("STExtraUIUtils")
    local PlayerCharacter = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(ConfirmUI:GetUIRoot())
    if slua.isValid(PlayerCharacter) then
      local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local BackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(PlayerCharacter)
      if slua.isValid(BackPackComp) then
        local BackpackUtils = import("BackpackUtils")
        BackpackUtils.EnableItemBySubType(504, true, BackPackComp)
      end
    end
  end
  local CommonConfirm = require("GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm")
  CommonConfirm.ShowConfirm(ConfirmInfo)
end
function BaseClientLogic:OnShowLowFPSWaring()
  local PC = slua_GameFrontendHUD:GetPlayerController()
  local GameInstance = slua_GameFrontendHUD:GetGameInstance()
  if not (slua.isValid(PC) and slua.isValid(PC.PlayerState) and slua.isValid(GameInstance)) or not GameInstance:GetEnableLowFPSRender() then
    return
  end
  if slua.isValid(PC) and PC.GameTipMsgID then
    local ConfirmInfo = {
      Style = "Simple",
      Content = LocUtil.GetLocalizeResStr(PC.GameTipMsgID),
      LeftLable = LocUtil.GetLocalizeResStr(12718),
      RightLable = LocUtil.GetLocalizeResStr(6752),
      RightCountDownTime = 10
    }
    function ConfirmInfo.LeftCB()
      local PC = slua_GameFrontendHUD:GetPlayerController()
      if slua.isValid(PC) and slua.isValid(PC.PlayerState) and PC.PlayerState.UserCancelCnt then
        PC.PlayerState.UserCancelCnt = PC.PlayerState.UserCancelCnt + 1
      end
      GameInstance:RefuseRenderForLowFPS()
    end
    function ConfirmInfo.RightCB()
      local PC = slua_GameFrontendHUD:GetPlayerController()
      if slua.isValid(PC) and slua.isValid(PC.PlayerState) and PC.PlayerState.UserConfirmCnt then
        PC.PlayerState.UserConfirmCnt = PC.PlayerState.UserConfirmCnt + 1
      end
      GameInstance:RenderForLowFPS()
    end
    local CommonConfirm = require("GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm")
    CommonConfirm.ShowConfirm(ConfirmInfo)
  end
end
function BaseClientLogic:OnImprisonStateChange(bEnterImprison)
  local PC = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PC) then
    return
  end
  if PC.GetPlayerCharacterSafety == nil then
    return
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local bIsStandalone = UKismetSystemLibrary.IsStandalone(PC)
  if bIsStandalone then
    print(bWriteLog and "[YY-D]BaseClientLogic:OnImprisonStateChange StandAloneMode Do Not ShowTips")
    return
  end
  if not UIManager.UI_Config_InGame or not UIManager.UI_Config_InGame.ImprisonmentTip then
    return
  end
  local bHawkReported = false
  local uPlayer = PC:GetPlayerCharacterSafety()
  if slua.isValid(uPlayer) then
    bHawkReported = uPlayer:HasState(EPawnState.HawkReported)
  end
  local ImprisonmentTip = UIManager.GetUI(UIManager.UI_Config_InGame.ImprisonmentTip)
  if (bHawkReported or not bEnterImprison) and ImprisonmentTip then
    ImprisonmentTip:CloseSelf()
    return
  end
  local bIsSpectator = (not PC.IsSpectator or not PC:IsSpectator()) and PC.IsInPetSpectator and PC:IsInPetSpectator()
  if bEnterImprison and not bIsSpectator and not ImprisonmentTip and not bHawkReported and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.ImprisonmentTip then
    UIManager.ShowUI(UIManager.UI_Config_InGame.ImprisonmentTip)
    if not self._nCheckImprisonmentTipTimerID then
      self._nCheckImprisonmentTipTimerID = self:AddGameTimer(3, true, function()
        local uMyController = slua_GameFrontendHUD:GetPlayerController()
        local bIsShouldShow = false
        if slua.isValid(uMyController) and uMyController.GetPlayerCharacterSafety then
          local uMyCharacter = uMyController:GetPlayerCharacterSafety()
          bIsShouldShow = not uMyController:IsSpectator() and (not uMyController.IsInPetSpectator or not uMyController:IsInPetSpectator()) and slua.isValid(uMyCharacter) and uMyCharacter:HasState(EPawnState.Imprisonment) and not uMyCharacter:HasState(EPawnState.HawkReported)
        end
        self:OnImprisonStateChange(bIsShouldShow)
      end)
    end
  end
end
function BaseClientLogic:OnUICustomBehavior(BehaviorTag, BehaviorType, Params)
  if BehaviorTag == "ShowRealTimeBlockingTips" and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.RealTimeBlocking then
    local RealTimeBlocking = UIManager.GetUI(UIManager.UI_Config_InGame.RealTimeBlocking)
    RealTimeBlocking = RealTimeBlocking or UIManager.ShowUI(UIManager.UI_Config_InGame.RealTimeBlocking)
    if RealTimeBlocking then
      RealTimeBlocking:SetShowData(BehaviorType, Params)
    end
  end
end
function BaseClientLogic:OnDanceStateChange(EventType, EventID, AttrValue, uCharacter)
  print(bWriteLog and "BaseClientLogic:OnDanceStateChange:", AttrValue, uCharacter)
  if not slua.isValid(uCharacter) then
    return
  end
  local uPlayerController = uCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  print(bWriteLog and "BaseClientLogic:OnDanceStateChange Handle ui")
  if math.abs(AttrValue - UEnums.EDanceStageState.EState_InAreaAndDance) < 0.001 then
    if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.DanceStageButtonUI then
      UIManager.ShowUI(UIManager.UI_Config_InGame.DanceStageButtonUI)
    end
  elseif UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.DanceStageButtonUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.DanceStageButtonUI)
  end
end
function BaseClientLogic:OnControllerBeginPlay()
  print(bWriteLog and "BaseClientLogic:OnControllerBeginPlay")
end
function BaseClientLogic:OnInitModeUI()
  log(bWriteLog and "BaseClientLogic Init Mod UI")
  if self.bHasInitModeUI then
    log(bWriteLog and "BaseClientLogic Init Mod UI has init")
    return false
  end
  self:InitGameplaySys()
  self:LoadGrenadeMarkerUI()
  self:InitBasicBattleUI()
  if self.OldUIConfig then
    ingamesub_CreateSubBattleUI(self.OldUIConfig.Default, self.OldUIConfig.ModAdd)
  end
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  NewbieGuideMgr.HandleEnterGame()
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  ClientBanLogic.ReqBanInfo()
  self.bHasInitModeUI = true
  self:InitIngameLikeUI()
  self:InitBattleResult()
  local PlayerController = GameplayData.GetPlayerController()
  local IsHawkEyeSpectator = false
  if PlayerController and Game:IsClassOf(PlayerController, import("UAEPlayerController")) then
    IsHawkEyeSpectator = PlayerController:IsHawkEyeSpectator()
  end
  if not IsHawkEyeSpectator then
    UIManager.ShowUI(UIManager.UI_Config_InGame.BattlePass02)
  end
  if UIManager.GetConfigByKey("PhoneStateUI") ~= nil then
    UIManager.ShowUI(UIManager.UI_Config_InGame.PhoneStateUI)
  end
  self.ShowAliasTipMap = {}
  self:RegistEvents()
  self:CheckLeftBulletCountColor()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local modType, _ = GameMainConfig.GetModType()
  if modType == "BaseMod" or modType == "Sink" then
    self:ShowNewbieGuideTip()
  end
  self:PreloadGeneralInteractiveUI()
  log_shipping_client("[tinghaohu] BaseClientLogic:OnInitModeUI. End.")
  self:InitTeammateReviveCountUI()
  self:HandleSuspiciousMark()
  if self:CheckShouldShowMapLegend() and UIManager then
    local EntireMapWindow = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
    if EntireMapWindow then
      EntireMapWindow:ShowMapLegend()
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENT_ID_SHOW_MAP_LEGEND)
    self:PreloadClassicStoreUI()
  end
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioAsync("/Game/WwiseEvent/UI/Play_UI_ResetLPF.Play_UI_ResetLPF")
  self:InitImprisonTipUI()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and MainControlBaseUI.Border_NewBackPack then
    MainControlBaseUI.Border_NewBackPack:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  return true
end
function BaseClientLogic:InitIngameLikeUI()
end
function BaseClientLogic:InitBattleResult()
  print(bWriteLog and "BaseClientLogic:InitBattleResult", LobbySystem.CheckOpen(BP_ENUM_RESULT_SUBSYSTEM_SWITH))
  if not Client.IsEditor() then
    BattleResult.BattleResultSubSystemSwltch = LobbySystem.CheckOpen(BP_ENUM_RESULT_SUBSYSTEM_SWITH)
  end
end
function BaseClientLogic:CheckShouldShowMapLegend()
  return true
end
function BaseClientLogic:GenerateAutoCreateUI(AutoCreateUIConfig)
  if self.bHasGenerateAutoCreateUI or not AutoCreateUIConfig then
    return
  end
  InGameSubUIManager.ClearQueue()
  self.bHasGenerateAutoCreateUI = true
  for _, UIName in pairs(AutoCreateUIConfig) do
    local UIConfig = UIManager.UI_Config_InGame[UIName]
    if UIConfig then
      UIManager.ShowUI(UIConfig)
      InGameSubUIManager.AddUIConfigName(UIConfig)
    end
  end
end
function BaseClientLogic:ShowNewbieGuideTip()
  log(bWriteLog and "BaseClientLogic:ShowNewbieGuideTip")
  if GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "BaseClientLogic:ShowNewbieGuideTip 1")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local spectator = uPlayerController:IsSpectator()
    if not spectator then
      local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
      if logic_newbie_assist.CheckIsNewBie() then
        local needTip = false
        local newbieAssistantHandler = require("client.network.Protocol.NewbieAssistantHandler")
        if newbieAssistantHandler then
          local matchCount = newbieAssistantHandler.matchCount
          if matchCount and matchCount <= 2 then
            newbieAssistantHandler.matchCount = nil
            needTip = true
          end
        end
        if needTip then
          UIManager.ShowUI(UIManager.UI_Config_InGame.NewbieGuideTip, 25607)
        else
          UIManager.ShowUI(UIManager.UI_Config_InGame.NewbieGuideTip)
        end
      end
    end
  end
end
function BaseClientLogic:InitTeammateReviveCountUI()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState then
    local ReviveBattleUIComponentClass = import("ReviveBattleUIComponent")
    local ReviveBattleUIComponent = uGameState:GetComponentByClass(ReviveBattleUIComponentClass)
    if slua.isValid(ReviveBattleUIComponent) then
      ReviveBattleUIComponent:CheckIsAddReviveTeamItemMark()
    end
  end
end
function BaseClientLogic:PreloadGeneralInteractiveUI()
  print(bWriteLog and "BaseClientLogic:PreloadGeneralInteractiveUI")
  local ui = UIManager.GetUI(UIManager.UI_Config_InGame.InteractiveUI)
  if ui == nil then
    ui = UIManager.ShowUI(UIManager.UI_Config_InGame.InteractiveUI)
  end
  if ui ~= nil then
    ui:Hide()
  end
end
function BaseClientLogic:InitGameplaySys()
  local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
  _G.SubsystemMgr:CallOnInit()
end
function BaseClientLogic:LoadGrenadeMarkerUI()
  print(bWriteLog and "BaseClientLogic:LoadGrenadeMarkerUI")
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState then
    local DSSwitch_OpenGrenadeMark = uGameState:GetDSSwitchValue(32)
    print(bWriteLog and "BaseClientLogic:LoadGrenadeMarkerUI DSSwitch_OpenGrenadeMark:", DSSwitch_OpenGrenadeMark)
    if DSSwitch_OpenGrenadeMark == false or DSSwitch_OpenGrenadeMark == 0 or DSSwitch_OpenGrenadeMark == "0" then
      print(bWriteLog and "BaseClientLogic:LoadGrenadeMarkerUI DSSwitch_OpenGrenadeMark is false!")
      return
    end
  end
  if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.GrenadeMarkerUI then
    print(bWriteLog and "BaseClientLogic:LoadGrenadeMarkerUI Load Sucess")
    UIManager.ShowUI(UIManager.UI_Config_InGame.GrenadeMarkerUI)
  end
end
function BaseClientLogic:CheckLeftBulletCountColor()
  local InGameLogic = slua_GameFrontendHUD:GetLogicManagerByName("ingame")
  if not InGameLogic then
    return
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUILua = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUILua then
    if ShootingUILua.FirWeaponSlot then
      ShootingUILua.FirWeaponSlot:SetLeftBulletRate(self.CountYellow, self.CountRed)
    end
    if ShootingUILua.SecWeaponSlot then
      ShootingUILua.SecWeaponSlot:SetLeftBulletRate(self.CountYellow, self.CountRed)
    end
    if ShootingUILua.PistolModeUI then
      ShootingUILua.PistolModeUI:SetLeftBulletRate(self.CountYellow, self.CountRed)
    end
  end
end
function BaseClientLogic:CheckTeammatesAlias()
  if Client then
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(uGameState) then
      local CurGameState = uGameState:GetGameModeState()
      if CurGameState ~= "ReadyState" then
        print(bWriteLog and "BaseClientLogic:CheckTeammatesAlias is not ReadyState")
        return
      end
    end
    if self.ShowAliasTipMap == nil then
      self.ShowAliasTipMap = {}
    end
    print(bWriteLog and "BaseClientLogic:CheckTeammatesAlias")
    local OwnerPC = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(OwnerPC) then
      print(bWriteLog and "BaseClientLogic:CheckTeammatesAlias OwnerPC is not valid")
      return
    end
    if not slua.isValid(OwnerPC.PlayerState) or OwnerPC.PlayerState.GetTeamMatePlayerStateList == nil then
      print(bWriteLog and "BaseClientLogic:CheckTeammatesAlias OwnerPC PlayerState is not valid")
      return
    end
    print(bWriteLog and "BaseClientLogic:CheckTeammatesAlias OwnerPC PlayerState UID", OwnerPC.PlayerState.UID)
    local TeammatePlayerStateList = OwnerPC.PlayerState:GetTeamMatePlayerStateList({}, false)
    if TeammatePlayerStateList == nil then
      print(bWriteLog and "BaseClientLogic:CheckTeammatesAlias return, invalid TeammatePlayerState")
      return
    end
    self:ShowAliasByPlayerState(OwnerPC.PlayerState)
    for k, TeammatePlayerState in pairs(TeammatePlayerStateList) do
      self:ShowAliasByPlayerState(TeammatePlayerState)
    end
  end
end
function BaseClientLogic:ShowAliasByPlayerState(PlayerState)
  if PlayerState and PlayerState.AliasInfo and PlayerState.AliasInfo.aliasID then
    print(bWriteLog and "BaseClientLogic:ShowAliasByPlayerState", PlayerState.UID, PlayerState.AliasInfo.aliasID)
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    if self.ShowAliasTipMap[PlayerState] ~= true and PlayerState.AliasInfo.aliasID == 2493180 then
      self:AddTimer(0, function()
        while LoadingSystem.IsShowing() do
          coroutine.yield(1)
        end
        IngameTipsTools.BattleGeneralTip(10147, PlayerState.PlayerName)
      end)
      self.ShowAliasTipMap[PlayerState] = true
    end
  elseif PlayerState then
    print(bWriteLog and "BaseClientLogic:ShowAliasByPlayerState aliasID not OK", PlayerState.UID)
    self.ShowAliasTipMap[PlayerState] = false
  else
    print(bWriteLog and "BaseClientLogic:ShowAliasByPlayerState PlayerState is nil")
  end
end
function BaseClientLogic:OnPreExit(status)
  if not self.bHasInitModeUI then
    log(bWriteLog and "BaseClientLogic:OnPreExit ModeUI not init")
    return false
  end
  print(bWriteLog and "BaseClientLogic:OnPreExit")
  self.bHasInitModeUI = false
  self.bHasGenerateAutoCreateUI = false
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  NewbieGuideMgr.HandleExitGame()
  local BornIslandSoundUtils = require("GameLua.Mod.Library.Client.BornIslandSoundUtils")
  BornIslandSoundUtils:ResetVoice()
  self:Dispose()
  local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
  GameplaySysMgr.EndPlay()
  local TApmSystem = require("GameLua.Mod.Library.Client.TApm.TApmSystem")
  TApmSystem.Shutdown()
  self.ShowAliasTipMap = nil
  local GoldenSuitTreeLogic = require("GameLua.Activity.IG1900.Client.GoldenSuitTreeLogic")
  GoldenSuitTreeLogic.Destroy()
  if UIManager.GetConfigByKey("BattleGMPanel") ~= nil then
    UIManager.CloseUI(UIManager.UI_Config_InGame.BattleGMPanel)
  end
  if UIManager.GetConfigByKey("PhoneStateUI") ~= nil then
    UIManager.CloseUI(UIManager.UI_Config_InGame.PhoneStateUI)
  end
  local ResultsRankingLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ResultsRankingLogic")
  ResultsRankingLogic:OnRelease()
  _G.SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  _G.SubsystemMgr:EndPlay()
  if not import("STExtraBlueprintFunctionLibrary").IsRelease() then
    local IngameGMManager = require("GameLua.Dev.IngameGM.IngameGMManager")
    if IngameGMManager then
      IngameGMManager:CleanGMPool()
    end
  end
end
function BaseClientLogic:OnPostExit(status)
  print(bWriteLog and "BaseClientLogic:OnPostExit")
  if _G.SubsystemMgr then
    _G.SubsystemMgr:Destroy()
  end
end
function BaseClientLogic:OnGameResult(battle_result)
end
function BaseClientLogic:ShowCustomGameResult()
end
function BaseClientLogic:OnPlayerChangeViewtargetToPlane()
  print(bWriteLog and "BaseClientLogic:OnPlayerChangeViewtargetToPlane")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uCurPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uCurPlayerState) then
      uCurPlayerState:RefreshAirplaneRoute()
    end
  end
end
function BaseClientLogic:HandleSuspiciousMark()
  print(bWriteLog and "BaseClientLogic:HandleSuspiciousMark")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uCurPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uCurPlayerState) and uCurPlayerState.GetSuspiciousFlag then
      local sFlag = uCurPlayerState:GetSuspiciousFlag()
      print(bWriteLog and "BaseClientLogic:HandleSuspiciousMark", sFlag)
      if sFlag == 1 then
        local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
        if slua.isValid(uAntsVoiceInterface) then
          uAntsVoiceInterface:EnableReportForAbroad(true)
          uAntsVoiceInterface:ReportFileForAbroad("", true, false, 60)
          print(bWriteLog and "BaseClientLogic:HandleSuspiciousMark report success")
        end
      end
    end
  end
end
function BaseClientLogic:PreloadClassicStoreUI()
  print(bWriteLog and "BaseClientLogic:PreloadClassicStoreUI")
  local ClassicStoreUI = UIManager.ShowUI(UIManager.UI_Config_InGame.ClassicStoreUI)
  if ClassicStoreUI then
    ClassicStoreUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    print(bWriteLog and "BaseClientLogic:PreloadClassicStoreUI Error ClassicStoreUI is nil")
  end
end
function BaseClientLogic:InitBasicBattleUI()
  self:InitTeamPanelUI()
  self:InitHelmetArmorUI()
  self:InitSingleReviveUI()
end
function BaseClientLogic:InitTeamPanelUI()
  local uGameState = GameplayData.GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(uGameState) then
    local uGameModeType = uGameState.GameModeType
    if uGameModeType ~= EGameModeType.EDeathMatchGameMode then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local TeamPanelConfig = GamePlayTools.GetCurrentConfig("TeamPanelUIConfig")
      local PlayerNumPerTeam = uGameState.PlayerNumPerTeam
      if UIManager.UI_Config_InGame.TeamPanel and TeamPanelConfig and not TeamPanelConfig.bDisableTeamPanel and 1 < PlayerNumPerTeam then
        UIManager.ShowUI(UIManager.UI_Config_InGame.TeamPanel)
      end
    end
  end
end
function BaseClientLogic:InitHelmetArmorUI()
  if UIManager.UI_Config_InGame.HelmetArmor then
    UIManager.ShowUI(UIManager.UI_Config_InGame.HelmetArmor)
  end
end
function BaseClientLogic:InitSingleReviveUI()
  local uGameState = GameplayData.GetGameState()
  if Game:IsValid(uGameState) then
    local PlayerNumPerTeam = uGameState.PlayerNumPerTeam
    local ReviveState = uGameState.ReviveState
    if Game:IsValid(ReviveState) and UIManager.UI_Config_InGame.SingleReviveCountUI and PlayerNumPerTeam <= 1 and ReviveState.GetDefaultRevivalCount and ReviveState:GetDefaultRevivalCount() > 0 then
      UIManager.ShowUI(UIManager.UI_Config_InGame.SingleReviveCountUI)
    end
  end
end
function BaseClientLogic:InitImprisonTipUI()
  local EPawnState = import("EPawnState")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:HasState(EPawnState.Imprisonment) then
    self:OnImprisonStateChange(true)
  end
end
local class = require("class")
local object = require("common.delegate_container")
local CBaseClientLogic = class(object, nil, BaseClientLogic)
return CBaseClientLogic