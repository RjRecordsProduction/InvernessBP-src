local MainControlBaseUI = {}
local ESlateVisibility = import("ESlateVisibility")
local GameplayStatics = import("GameplayStatics")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local CustomType = require("client.logic.setting.CustomType")
local UIDataProcessingFunctionLibrary = import("UIDataProcessingFunctionLibrary")
local ECharacterSubType = import("ECharacterSubType")
local KismetSystemLibrary = import("KismetSystemLibrary")
local EWidgetVisible = import("EWidgetVisible")
local EPawnState = import("EPawnState")
local EUMGSequencePlayMode = import("EUMGSequencePlayMode")
local EGameModeType = import("EGameModeType")
local BusinessHelper = import("BusinessHelper")
local ScriptHelperClient = import("ScriptHelperClient")
local KismetTextLibrary = import("KismetTextLibrary")
local BackpackUtils = import("BackpackUtils")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local STExtraDelegateMgr = import("STExtraDelegateMgr")
local PaperSpriteBlueprintLibrary = import("PaperSpriteBlueprintLibrary")
local EGameModeSubType = import("EGameModeSubType")
local ESTEScopeType = import("ESTEScopeType")
local EUAESkillEvent = import("EUAESkillEvent")
local ThrowComponent = import("Script/ShadowTrackerExtra.ThrowComponent")
local UKismetMathLibrary = import("KismetMathLibrary")
local IntlHelper = import("IntlHelper")
local EGameReplayType = import("EGameReplayType")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
local UIUtil = require("client.common.ui_util")
local util = require("client.slua_ui_framework.util")
local CommonRotaryTableUITool = require("GameLua.Mod.BaseMod.Client.MainControlUI.CommonRotaryTableUITool")
local Enum_HUDType = require("GameLua.Mod.BaseMod.Client.Config.RuntimeHUDChangeConfig").Enum_HUDType
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local audio_util = require("client.common.audio_util")
local TimeUtil = require("client.common.time_util")
local TableUtil = require("common.table_util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local table_insert = table.insert
local RefreshInterval = 0.1
local GuideUITipsConfig = {
  [1017] = {
    UIConfigName = "MoveAimTips",
    SocketName = "CanvasPanel_ForTips"
  },
  [1030] = {
    UIConfigName = "KillZoneAndSafeZoneTips",
    SocketName = "CanvasPanel_ForTips"
  },
  [1032] = {
    UIConfigName = "KillZoneCountDownTips",
    SocketName = "CanvasPanel_ForTips"
  },
  [1043] = {
    UIConfigName = "TurnplateQuickMsgTips"
  },
  [1047] = {
    UIConfigName = "KillZoneAndSafeZoneTips",
    SocketName = "CanvasPanel_ForTips"
  }
}
local PickTipsGuideConfig = {
  TipsFlyAnim = "Anim_TipsFly",
  TipsLoopAnim = "Anim_SpreadFX",
  MinX = -157,
  MaxX = -153,
  MinY = -2,
  MaxY = 2,
  LoopDuration = 60
}
function MainControlBaseUI:ctor()
  self.bNeedDelayRegistEvents = true
  self.HasInit = false
  self.QuickMenu = nil
  self.BackPackPickUpPanel = nil
  self.BasicSkillsMenuUI = nil
  self.CanHideUIMainModeID = {
    [101] = {},
    [102] = {},
    [103] = {},
    [111] = {},
    [112] = {},
    [113] = {},
    [401] = {},
    [402] = {},
    [403] = {},
    [411] = {},
    [412] = {},
    [413] = {}
  }
  self.GoldNum = 0
  self.ChatTurnplateCommonRotaryTableUITool = CommonRotaryTableUITool()
  self.ChatTurnplateCommonRotaryTableUITool:Initialize(78, 1, 8, 60)
  self.BuffListCloseStartCountDown = false
  self.DynamicBattleFBTipsWidget = nil
  self.RolewearTabArray = {}
  self.ForceShowWidgets = {}
  self.ForceHideWidgets = {}
  self.HideWidgetsNames = {}
  self.IsInitHideUIFunc = false
  self.HighLayerHideWidgetsNames = {BuffAddHp_UIBP_C = "HPPanel"}
  self.IsFirstHideUI = true
  self.HasRecevieInitWidgetEvent = false
  self.QuickMsgIndex = -1
  self.CurBuffListCloseCountTime = 0.0
  self.IsCurTurnplateTipsShow = false
  self.bFinishedLoadBattleUI = false
  self.BigEvent_Btn = nil
  self.ChatBtnNormalOpacity = 0.0
  self.HideNavigator = false
  self.ShowNavigator = true
  self.NavigatorIsShow = true
  self.bIsQuickMenuCoolingDown = false
  self.VoiceForbidBtn = false
  self.bGuideLoopAnim = false
  self.GuideLoopTimer = nil
  self.GuideBtnShowMap = {}
  self.HitTipsTimer = nil
  self.DamageCauserLocation = nil
end
function MainControlBaseUI:RegistEvents()
  print(bWriteLog and "MainControlBaseUI:RegistEvents")
  self:AddControlEvent(self.Button_IngameGM, "OnClicked", self.OpenIngameGMPanel, self)
  self:AddControlEvent(self.Button_Border_close, "OnClicked", self.OnClickQuickChatClose, self)
  self:AddControlEvent(self.Image_25, "OnMouseButtonDownEvent", self.OnCreateGMUI, self)
  self:AddControlEvent(self.EntireMapTrigger, "OnPressDown", self.OnEntireMapTriggerOnPressDown, self)
  self:AddControlEvent(self.EntireMapTrigger, "OnHoldEnded", self.OnEntireMapTriggerHoldEnded, self)
  self:AddControlEvent(self.EntireMapTrigger, "OnClickWithoutHold", self.OnEntireMapTriggerClick, self)
  self:AddControlEvent(self.TurnplateBtn_UIBP_0, "ED_TurnplateBtnTouchStart", self.OnTurnplateBtnTouchStart, self)
  self:AddControlEvent(self.TurnplateBtn_UIBP_0, "ED_TurnplateBtnTouchMove", self.OnTurnplateBtnTouchMove, self)
  self:AddControlEvent(self.TurnplateBtn_UIBP_0, "ED_TurnplateBtnTouchEnd", self.OnTurnplateBtnTouchEnd, self)
  self:AddControlEvent(self.Button_ReportBug, "OnClicked", self.OnClicked_Button_ReportBug, self)
  self:AddControlEvent(self.Button_0, "OnClicked", self.OnClicked_Button_0, self)
  self:AddControlEvent(self.Button_B_Sigh_yellow, "OnClicked", self.OnClicked_Button_B_Sigh_yellow, self)
  self:AddControlEvent(self.MultiButton_EntireMapTrigger, "OnClicked", self.OnClicked_MultiButton_EntireMapTrigger, self)
  self:AddControlEvent(self.Button_ExitTraining, "OnClicked", self.OnClicked_Button_ExitTraining, self)
  self:AddControlEvent(self.Button_GameGuide, "OnClicked", self.OnClicked_Button_GameGuide, self)
  self:AddControlEvent(self[PickTipsGuideConfig.TipsFlyAnim], "OnAnimationFinished", self.OnTipsAnimationFinished, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTERPRISEGMMOD_CHANGE, self.CheckEnterpriseGMMod, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_CLICK, self.HandleQuickExpressClick, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, self.OnShowOrHideQuickExpressionRing, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY_FINISH, self.OnPlayerControllerBeginplayFinish, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_OPEN_HIDE_SPEECH_TO_TEXT, self.OnShowSpeechToText, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWOFF_TIPS, self.OnShowOffTips, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_ENTER_PLANE, self.OnEnterPlane, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_PRESSED_LOGO_BUTTON, self.OnPressedLogoButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_RELEASED_LOGO_BUTTON, self.OnReleasedLogoButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_OBSERVE_LAST_ATTACKER, self.ObserveLastAttacker, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_ATTACH_UI, self.ShowAttachUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT, self.ShowAllUIForDelayResult, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_ALL_UI, self.OnTurnplateBtnTouchEnd, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_COMPLETE_PLAYBACK_UI, self.OnEnterCompletePlayback, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_WONDERFUL, self.OnEnterWonderfulPlayback, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.ShowSpectatingUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CHANGE_MAP_BUTTON_SHOW, self.ChangeMapBtnShow, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.HandleOnGameModeStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_READY, self.HideTurnplateUIBP, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_DARK_NIGHT, self.OnShowDarkNight, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_REMINDCHATBTN, self.RemindQuickChatBtn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_CHECKSHOWWMODEUI, function()
    self:CheckShowWModeUI(true)
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_STARTCHATBARANIMA, function(_, __, ___, CD)
    self:StartChatBarAnima(CD)
  end, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  local ModType = GameMainConfig.GetModType()
  local BasicSkillsMenuBPModPath = string.format("GameLua.Mod.%s.Client.Skill.BasicSkillsMenuBP_Main", ModType)
  local BasicSkillsMenuBPDefaultPath = "GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Main"
  local BasicSkillsMenuBPFinalPath = GamePlayTools.LuaFileExits(BasicSkillsMenuBPModPath) and BasicSkillsMenuBPModPath or BasicSkillsMenuBPDefaultPath
  self.QuickMenu_BP:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.QuickMenu = self:AddChildWidget(self.QuickMenu_BP, "GameLua.Mod.BaseMod.Client.QuickMenu")
  self.BasicSkillsMenuUI = self:AddChildWidget(self.BasicSkillsMenu_BP, BasicSkillsMenuBPFinalPath)
  self.BackPackPickUpPanel = self:AddChildWidget(self.BackPackPickUpPanel_BP, "GameLua.Mod.BaseMod.Client.BackPack.BackPackPickUpPanel")
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_ON_CLOSE, self.OnBackPackClose, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_OPEN_BACKPACK, self.HandleEntireMapTrigger, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_CLOSE_BACKPACK, self.HandleEntireMapTrigger, self)
  self:CreateAndGetQuickExpressionDecalUI()
  self:InitDelegate()
  self:InitMap()
  self:InitTraining()
  self:UpdateVoiceCheckByGameState()
  self:InitCircleInfo(false)
  local BP_MiniMapStandardPoint = import("/Game/BluePrints/Core/BP_MiniMapStandardPoint.BP_MiniMapStandardPoint_C")
  local uActorClass = import("/Script/Engine.Actor")
  local OutActors = slua.Array(UEnums.EPropertyClass.Object, uActorClass)
  OutActors = GameplayStatics.GetAllActorsOfClass(self, BP_MiniMapStandardPoint, OutActors)
  if OutActors:Num() > 0 then
    local OutActor = OutActors:Get(0)
    if slua.isValid(OutActor) then
      self.NavigateCorrecteAngle = OutActor:K2_GetActorRotation().Yaw
    end
  end
  self:CloseLbsMicWhenCorpsMode()
  if not self.HasRecevieInitWidgetEvent then
    local bIsNeedOpenGameJoy = self:CheckIsNeedOpenGameJoy()
    if bIsNeedOpenGameJoy then
      ScriptHelperClient.GameJoyStartMomentsRecord()
    end
  end
  self:OpenGMInterface()
  local BattleIDHexStr = slua_GameFrontendHUD:GetBattleIDHexStr()
  self.TextBlock_BID:SetText(BattleIDHexStr)
  self.HasRecevieInitWidgetEvent = true
  self:UIMSG_GameModeDisplayNameChanged()
  self:AddGameTimer(1, false, function()
    self:UIMSG_GameModeDisplayNameChanged()
  end)
  self:HandleEmoteSetting()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_INIT_LEFT_KILL_INFO)
  self:SetHitBloodImg()
  local bShow = self:ShouldShowNavigator()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, bShow)
  self.NavigatorIsShow = bShow
  self:CheckShowTaskButton()
  self:RegShowQuickDecal()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    self:AddControlEvent(GameState, "OnInfectedAreaWarn", self.OnInfectedAreaWarnBroadcast, self)
  else
    print(bWriteLog and "Get gamestatebase failed")
  end
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.BasicSkillsMenu_BP, self, "BasicSkillsMenu_BP")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.CanvasPanel_BackpackPanel, self, "CanvasPanelBackpackPanel")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.Emote_SwimingControl, self, "EmoteSwimingControl")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.CircleChasingProgress, self, "MainControlBaseUI_CircleChasingProgress")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.CanvasPanel_MiniMapAndSetting, self, "MainControlBaseUI_CanvasPanel_MiniMapAndSetting")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.Border_NewBackPack, self, "CanvasPanelBackpackPanel")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.BackPackPickUpPanel_BP, self, "MainControlBaseUI_BackPackPickUpPanel_BP")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.CanvasPanel_FreeCamera, self, "MainControlBaseUI_CanvasPanel_FreeCamera")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.CanvasPanel_ChangeSight, self, "MainControlBaseUI_CanvasPanel_ChangeSight")
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.OnNavigatorVisibleChanged, self)
  local ChangeSightUI = UIManager.ShowUI(UIManager.UI_Config_InGame.ChangeSightUI, self)
  if ChangeSightUI then
    ChangeSightUI:AttachToPanel(self.CanvasPanel_ChangeSight)
    ChangeSightUI:SetAnchors(0, 0, 1, 1)
    ChangeSightUI:SetOffsets(0, 0, 0, 0)
  end
  self:ShowNavigatorPanel()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController.BackpackComponent) then
      self.GoldNum = PlayerController.BackpackComponent:GetItemCountByItemSpecialID(StoreConfig.GoldID)
    end
  end)
  self:AddUIMessageEvent("UIMsg_ScopeChanged", self.UIMsg_ScopeChanged, self)
  self:AddUIMessageEvent("UIMsg_HideJoinGameUI", self.UIMsg_HideJoinGameUI, self)
  self:AddUIMessageEvent("UIMsg_EnterTrainingMode", self.UIMsg_EnterTrainingMode, self)
  self:AddUIMessageEvent("UIMsg_RefreshEmote", self.UIMsg_RefreshEmote, self)
  self:AddUIMessageEvent("UIMsg_UpdateBackpackCloth", self.UIMsg_UpdateBackpackCloth, self)
  self:AddUIMessageEvent("UIMsg_InitTurnplateQuickChat", self.UIMsg_InitTurnplateQuickChat, self)
  self:AddUIMessageEvent("UIMsg_PlayArmorEffect", self.UIMsg_PlayArmorEffect, self)
  self:AddUIMessageEvent("UIMsg_PlayHelmetEffect", self.UIMsg_PlayHelmetEffect, self)
  self:AddUIMessageEvent("UIMsg_ShowDeathMatchUI", self.UIMsg_ShowDeathMatchUI, self)
  self:AddUIMessageEvent("UIMsg_CloseQuickExpressionRing", self.UIMsg_CloseQuickExpressionRing, self)
  self:AddUIMessageEvent("UIMsg_ShowEntireMapUI", self.UIMsg_ShowEntireMapUI, self)
  self:AddUIMessageEvent("OnChatPrivacyAccepted", self.OnChatPrivacyAccepted, self)
  self:AddUIMessageEvent("DidBroadcastDarkMost", self.DidBroadcastDarkMost, self)
  self:AddUIMessageEvent("DidBroadcastDawnBegin", self.DidBroadcastDawnBegin, self)
  self:AddUIMessageEvent("DidBroadcastShowZombieWarningTips", self.DidBroadcastShowZombieWarningTips, self)
  self:AddUIMessageEvent("DidBroadcastShowPVETipsEvent1", self.DidBroadcastShowPVETipsEvent1, self)
  self:AddUIMessageEvent("DidBroadcastShowPVETipsEvent2", self.DidBroadcastShowPVETipsEvent2, self)
  self:AddUIMessageEvent("DidBroadcastShowPVETipsEvent3", self.DidBroadcastShowPVETipsEvent3, self)
  self:AddUIMessageEvent("DidBroadcastShowPVETipsEvent4", self.DidBroadcastShowPVETipsEvent4, self)
  self:AddUIMessageEvent("DidBroadcastShowPVETipsEvent5", self.DidBroadcastShowPVETipsEvent5, self)
  self:AddUIMessageEvent("DidBroadcastShowPVETipsEvent6", self.DidBroadcastShowPVETipsEvent6, self)
  self:AddUIMessageEvent("DidBroadcastShowPoisonFogTipsEvent", self.DidBroadcastShowPoisonFogTipsEvent, self)
  self:AddUIMessageEvent("FogComing1", self.FogComing1, self)
  self:AddUIMessageEvent("FogComing2", self.FogComing2, self)
  self:AddUIMessageEvent("FogEnd1", self.FogEnd1, self)
  self:AddUIMessageEvent("LevelStart", self.LevelStart, self)
  self:AddUIMessageEvent("NightCome", self.NightCome, self)
  self:AddUIMessageEvent("Victory1", self.Victory1, self)
  self:AddUIMessageEvent("Victory2", self.Victory2, self)
  self:AddUIMessageEvent("SetNavigationPanelVisible", self.SetNavigationPanelVisible, self)
  self:AddUIMessageEvent("UIMsg_ChangeShowTipSwitch", self.UIMsg_ChangeShowTipSwitch, self)
  self:AddUIMessageEvent("DisplayCharStateWhenOperateUAV", self.DisplayCharStateWhenOperateUAV, self)
  self:AddUIMessageEvent("UIMsg_ShowSomeUIAfterMiniGameMachine", self.UIMsg_ShowSomeUIAfterMiniGameMachine, self)
  self:AddUIMessageEvent("SwitchCameraModeScope_Aim", self.SwitchCameraModeScope_Aim, self)
  self:AddUIMessageEvent("UIMSG_GameModeDisplayNameChanged", self.UIMSG_GameModeDisplayNameChanged, self)
  self:AddUIMessageEvent("StopFreeCamera", self.StopFreeCamera, self)
  self:AddUIMessageEvent("UIMsg_ShowEnemyLaunchRocketTips", self.UIMsg_ShowEnemyLaunchRocketTips, self)
  self:AddUIMessageEvent("UIMsg_ShowFreeCamera", self.UIMsg_ShowFreeCamera, self)
  self:AddUIMessageEvent("UIMsg_HideFreeCamera", self.UIMsg_HideFreeCamera, self)
  self:AddUIMessageEvent("UIMsg_GameReplay_SyncPlayerState", self.HideForReplayUI, self)
  self:AddUIMessageEvent("UIMsg_HideQuickChatMenu", function()
    self:HideQuickChatMenu()
  end, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnFreeViewChangedDelegate", function()
    self.nLastAttackerPlayerKey = 0
  end, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", function()
    self.nLastAttackerPlayerKey = 0
  end, self)
  self.Button_IngameGM:SetWidgetVisibility(ESlateVisibility.Collapsed)
  if UIManager.UI_Config_InGame.VehicleHPPanel then
    if slua.isValid(CGameState) then
      local DelegateMgrInstance = STExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
      if slua.isValid(DelegateMgrInstance) then
        self:AddControlEvent(DelegateMgrInstance, "OnVehicleHPChange", self.OnVehicleHPChange, self)
      end
    end
    self:AddCommonEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_CONTROL_PANEL_SHOW, self.HandleAttachedToVehicle, self)
    self:AddCommonEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_CONTROL_PANEL_HIDE, self.HandleDetachedFromVehicle, self)
    self:AddCommonEvent(EVENTTYPE_CREATIVE, EVENTID_ON_HUD_CHANGE, self.HandleOnHUDSettingChange, self)
  end
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", function()
    print(bWriteLog and "Lua MainControlBaseUI UIMsg_Onplayercontrollerstatechanged")
    self:UIMsg_Onplayercontrollerstatechanged()
  end)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStateChange", self.ongamemodestatechanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "NewbieShowCurGuide", self.ShowOrHideNewbieGuide, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnTakeDamagedDelegate", self.OnTakeDamage, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterJumping", self.EnterJumping, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterParachute", self.EnterJumping, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.EnterFlying, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  self.BtnEnterSelfie:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self:ShowServerTime()
  self:CheckShowGameGuideButton()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.bUseFootPrint then
    self:AddGameTimer(0.1, true, function()
      self:UpdateSnowBoardBtn()
    end)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.Object)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.Chat)
  self:CheckDisableInvalidationBoxes()
end
function MainControlBaseUI:ReceivedInitWidget()
  self:OnInitializeDelay()
  self:RegistEventsDelay()
end
function MainControlBaseUI:OnInitializeDelay()
  self:InitQuickSignUI()
  self:InitSpeakerUIUI()
  self:CreateChildWindow(self.CanvasPanel_ZTK, UIManager.UI_Config_InGame.SettingButton)
end
function MainControlBaseUI:RegistEventsDelay()
end
function MainControlBaseUI:InitQuickSignUI()
  self:CreateChildWindow(self.CanvasPanel_QuickSign, UIManager.UI_Config_InGame.QuickSignUI)
end
function MainControlBaseUI:InitSpeakerUIUI()
  self:CreateChildWindow(self.SpeakerCanvasPanel, UIManager.UI_Config_InGame.SpeakerUI)
end
function MainControlBaseUI:OnPlayerCharacterChange()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:ExitFreeCamera(true)
  end
  self:StopFreeCamera()
end
function MainControlBaseUI:SwitchCameraModeScope_Aim()
  if self.NewFreeCameraBtn then
    self.NewFreeCameraBtn:SwitchCameraModeScope_Aim()
  end
end
local _GetServerTimeInSec = function()
  if slua.isValid(slua_GameFrontendHUD) then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.GameReplayType == EGameReplayType.EGameReplayType_CompletePlayback then
      local uGameState = slua_GameFrontendHUD:GetGameState()
      if slua.isValid(uGameState) and uGameState.GetServerStartUnixTimestamp then
        local ServerStartTime = uGameState:GetServerStartUnixTimestamp()
        local TimePass = math.floor(uGameState:GetServerWorldTimeSeconds())
        return ServerStartTime + TimePass
      end
    end
  end
  return TimeUtil.GetServerTimeInSec()
end
function MainControlBaseUI:ShowServerTime()
  local ServerTime = _GetServerTimeInSec()
  local Suffix = "(UTC+0)"
  local TimeFormat = "!%Y-%m-%d %H:%M"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local StrRegion = Client.GetPublishRegion()
  if StrRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    Suffix = ""
    TimeFormat = "%Y-%m-%d %H:%M"
  end
  local TimeString = TimeUtil.OSDate(TimeFormat, ServerTime)
  self.TextBlock_Hour:SetText(TimeString .. Suffix)
  self:AddGameTimer(1, true, function()
    local ServerTime = _GetServerTimeInSec()
    if ServerTime % 60 == 0 then
      local TimeString = TimeUtil.OSDate(TimeFormat, ServerTime)
      self.TextBlock_Hour:SetText(TimeString .. Suffix)
    end
  end)
end
function MainControlBaseUI:ongamemodestatechanged()
  self:UIMsg_Onplayercontrollerstatechanged()
end
function MainControlBaseUI:ShowAttachUI(_, __, ChildWidget)
  if slua.isValid(ChildWidget) then
    self.CanvasPanel_ActorUISlot:AddChild(ChildWidget)
  end
end
function MainControlBaseUI:UIMsg_Onplayercontrollerstatechanged()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.GetGameModeState == nil then
    return
  end
  if GameState:GetGameModeState() == "ReadyState" then
    self:EnterReadyState()
  else
    self:ExitReadyState()
  end
end
function MainControlBaseUI:EnterReadyState()
  UIManager.ShowUI(UIManager.UI_Config_InGame.IslandSurviveCountPanel)
  local SurviveInfoPanel = InGameUITools.GetSurviveInfoPanel()
  if SurviveInfoPanel then
    SurviveInfoPanel:ShowSurvivePanel(false)
  end
end
function MainControlBaseUI:ExitReadyState()
  if UIManager.UI_Config_InGame.IslandSurviveCountPanel then
    UIManager.CloseUI(UIManager.UI_Config_InGame.IslandSurviveCountPanel)
  end
  local SurviveInfoPanel = InGameUITools.GetSurviveInfoPanel()
  if SurviveInfoPanel then
    SurviveInfoPanel:ShowSurvivePanel(true)
  end
end
function MainControlBaseUI:ShowOrHideNewbieGuide(TipsID, bShow)
  local Config = GuideUITipsConfig[TipsID]
  if not Config then
    return
  end
  local UIConfigName = Config.UIConfigName
  if not UIManager.UI_Config_InGame or not UIManager.UI_Config_InGame[UIConfigName] then
    return
  end
  if not bShow then
    UIManager.CloseUI(UIManager.UI_Config_InGame[UIConfigName])
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController:IsSpectator() then
    return
  end
  local ThisGuideText = CDataTable.GetTableData("GuideText", TipsID)
  if not ThisGuideText then
    return
  end
  local SocketWidget = self[Config.SocketName]
  local TipsUI = UIManager.ShowUI(UIManager.UI_Config_InGame[UIConfigName], ThisGuideText)
  if TipsUI and SocketWidget then
    TipsUI:AttachToPanel(self.CanvasPanel_ForTips)
    TipsUI:SetAnchors(0, 0, 1, 1)
    TipsUI:SetOffsets(0, 0, 0, 0)
  end
end
function MainControlBaseUI:OnBackPackClose()
  self:ShowQuickMsgInfo(true)
end
function MainControlBaseUI:UIMsg_ShowDeathMatchUI()
  self:ShowDeathMatchUI()
end
function MainControlBaseUI:UIMsg_PlayHelmetEffect()
  self:PlayUserWidgetAnimation(self.HelmetFull, 0, 1, 0, 1)
end
function MainControlBaseUI:UIMsg_PlayArmorEffect()
  self:PlayUserWidgetAnimation(self.ArmorFull, 0, 1, 0, 1)
end
function MainControlBaseUI:UIMsg_InitTurnplateQuickChat()
  self:AddGameTimer(0.2, false, function()
    self:DelayInitQuickMsgMenu()
  end)
end
function MainControlBaseUI:UIMsg_UpdateBackpackCloth()
  self:CallBackpackLuaFunction("UpdateClothItemList")
  self:RefreshEmoteWhenShow()
end
function MainControlBaseUI:UIMsg_ExitSurfBoard()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(PlayerCharacter)
  if BackpackUtils.HasItemBySubType(506, BackPackComp) then
    local ArmorSlotItem = self:BackpackGetArmorSlotItem(EBackpackClothArmorType.SurfBoard)
    if slua.isValid(ArmorSlotItem) then
      ArmorSlotItem:RefreshSurfBoardSwitch(false)
    end
  end
end
function MainControlBaseUI:UIMsg_EnterSurfBoard()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(PlayerCharacter)
  if BackpackUtils.HasItemBySubType(506, BackPackComp) then
    local ArmorSlotItem = self:BackpackGetArmorSlotItem(EBackpackClothArmorType.SurfBoard)
    if slua.isValid(ArmorSlotItem) then
      ArmorSlotItem:RefreshSurfBoardSwitch(true)
    end
  end
end
function MainControlBaseUI:UIMsg_RefreshEmote()
  self:RefreshEmote()
end
function MainControlBaseUI:UIMsg_EnterTrainingMode()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  if not GameState.bIsTrainingMode then
    self.Button_ExitTraining:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) then
      return
    end
    if PlayerController:IsFriendObserver() then
      self.Button_ExitTraining:SetWidgetVisibility(ESlateVisibility.Collapsed)
    else
      self.Button_ExitTraining:SetWidgetVisibility(ESlateVisibility.Visible)
    end
  end
end
function MainControlBaseUI:UIMsg_HideJoinGameUI()
  self:HideJoinGameUI()
end
function MainControlBaseUI:UIMsg_ScopeChanged()
  if not self.NewFreeCameraBtn then
    return
  end
  self.NewFreeCameraBtn:UIMsg_ScopeChanged()
end
function MainControlBaseUI:OnPressedLogoButton()
  self:OnLogoBtnPress()
end
function MainControlBaseUI:OnReleasedLogoButton()
  self:OnLogoBtnRelease()
end
function MainControlBaseUI:HandleOnHUDSettingChange()
  print(bWriteLog and "MainControlBaseUI:HandleOnHUDSettingChange")
  self:RefreshVehicleHPPanel()
end
function MainControlBaseUI:HandleAttachedToVehicle()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  print(bWriteLog and "MainControlBaseUI:HandleAttachedToVehicle", VehicleUserComponent)
  if not VehicleUserComponent then
    print(bWriteLog and "MainControlBaseUI:HandleAttachedToVehicle nil")
    return
  end
  self.CurVehicle = VehicleUserComponent:GetVehicle()
  print(bWriteLog and "MainControlBaseUI:HandleAttachedToVehicle", self.CurVehicle)
  if not slua.isValid(self.CurVehicle) then
    return
  end
  self:RefreshVehicleHPPanel()
end
function MainControlBaseUI:HandleDetachedFromVehicle()
  print(bWriteLog and "MainControlBaseUI:HandleDetachedFromVehicle")
  self.CurVehicle = nil
  self:RefreshVehicleHPPanel()
end
function MainControlBaseUI:RefreshVehicleHPPanel()
  print(bWriteLog and "MainControlBaseUI:RefreshVehicleHPPanel", self.CurVehicle)
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "MainControlBaseUI:HandleOnHUDSettingChange nil")
    return
  end
  local CurVehicle = VehicleUserComponent:GetVehicle()
  local uVehicleCommon
  if slua.isValid(CurVehicle) then
    uVehicleCommon = CurVehicle:GetVehicleCommon()
  end
  if UIManager.UI_Config_InGame.VehicleHPPanel == nil then
    return
  end
  if self.CurVehicle == nil then
    if UIManager.IsUIShow(UIManager.UI_Config_InGame.VehicleHPPanel) then
      UIManager.HideUI(UIManager.UI_Config_InGame.VehicleHPPanel)
    end
    local PlayerInfoPanelMain = UIManager.GetUI(UIManager.UI_Config_InGame.PlayerInfoPanelMain)
    if PlayerInfoPanelMain then
      PlayerInfoPanelMain:SetWidgetVisible(PlayerInfoPanelMain.UIRoot.WidgetSwitcher_SelfStatus, true, false)
    end
    return
  end
  if uVehicleCommon and slua.isValid(uVehicleCommon) then
    if uVehicleCommon.GetUGCHUDStatus and uVehicleCommon:GetUGCHUDStatus() == Enum_HUDType.VehicleHPOn then
      if not UIManager.IsUIShow(UIManager.UI_Config_InGame.VehicleHPPanel) then
        local VehicleHPPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.VehicleHPPanel)
        if VehicleHPPanel then
          VehicleHPPanel:AddVehicleHPChangedListener(uVehicleCommon)
          self:UIMsg_VehicleHPChanged(uVehicleCommon)
          local PlayerInfoPanelMain = UIManager.GetUI(UIManager.UI_Config_InGame.PlayerInfoPanelMain)
          if PlayerInfoPanelMain then
            PlayerInfoPanelMain:SetWidgetVisible(PlayerInfoPanelMain.UIRoot.WidgetSwitcher_SelfStatus, false, false)
          end
        end
      end
    else
      if UIManager.IsUIShow(UIManager.UI_Config_InGame.VehicleHPPanel) then
        local VehicleHPPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleHPPanel)
        VehicleHPPanel:RemoveVehicleHPChangedListener(uVehicleCommon)
        UIManager.HideUI(UIManager.UI_Config_InGame.VehicleHPPanel)
      end
      local PlayerInfoPanelMain = UIManager.GetUI(UIManager.UI_Config_InGame.PlayerInfoPanelMain)
      if PlayerInfoPanelMain then
        PlayerInfoPanelMain:SetWidgetVisible(PlayerInfoPanelMain.UIRoot.WidgetSwitcher_SelfStatus, true, false)
      end
    end
  end
end
function MainControlBaseUI:OnVehicleHPChange(Health, RatioHealth, InController)
  print(bWriteLog and "MainControlBaseUI:OnVehicleHPChange " .. Health(", ") .. RatioHealth)
  if UIManager.UI_Config_InGame.VehicleHPPanel == nil then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.VehicleHPPanel) then
    local VehicleHPPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleHPPanel)
    VehicleHPPanel:SetHP(Health, RatioHealth)
  end
end
function MainControlBaseUI:UIMsg_VehicleHPChanged(uVehicleCommon)
  if UIManager.UI_Config_InGame.VehicleHPPanel == nil or not slua.isValid(uVehicleCommon) then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.VehicleHPPanel) then
    local VehicleHPPanel = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleHPPanel)
    VehicleHPPanel:UpdateGUIHP(uVehicleCommon.HP, uVehicleCommon.HPMax)
  end
end
function MainControlBaseUI:GetVehicleUserComponent()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComponent) then
    return nil
  end
  return VehicleUserComponent
end
function MainControlBaseUI:OnClickBackPackButton()
  if UIManager.UI_Config_InGame.BRTDMStoreUI then
    local BRTDMStoreUI = UIManager.GetUI(UIManager.UI_Config_InGame.BRTDMStoreUI)
    if BRTDMStoreUI and BRTDMStoreUI.UIRoot:IsVisible() then
      BRTDMStoreUI:OnClicked_Leave()
    end
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:InterruptThrow()
  end
  if self:IsBackpackCollapsed() then
    self:HideBuffList()
    BatttleWindowMgr.HideUI("EntireMapWindow")
    self:ShowQuickMsgInfo(false)
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL)
  else
    self:ShowQuickMsgInfo(true)
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL)
  end
  self.BackpackClothingGuide:SetWidgetVisibility(ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:OnPressBackpackBtn()
  end
end
function MainControlBaseUI:GetBackPackPickUpPanel()
  return self.BackPackPickUpPanel
end
function MainControlBaseUI:GetBasicSkillsMenuUI()
  return self.BasicSkillsMenuUI
end
function MainControlBaseUI:Reconnect_ResetUIByPlayerControllerState()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    if PlayerController:IsInFight() then
      self:ShowOrHideFreeCam(true)
    elseif PlayerController:IsInPlane() then
      self:ShowOrHideFreeCam(false)
      PlayerController:ShowTouchInterface(false)
    elseif PlayerController:IsInParachute() then
      self:EnterJumpingSetUI()
    end
    self:UIMsg_Onplayercontrollerstatechanged()
  end
  self.NewFreeCameraBtn:StopFreeCamera()
  self.NewFreeCameraBtn:InvalidateLayoutAndVolatility()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GetSuperData then
    local SPData = GameState:GetSuperData()
    if SPData.NeedUpdateAllWarModeUI == nil then
      SPData.NeedUpdateAllWarModeUI = 0
    end
    SPData.NeedUpdateAllWarModeUI = 1 - SPData.NeedUpdateAllWarModeUI
  else
  end
end
function MainControlBaseUI:StopFreeCamera()
  self.NewFreeCameraBtn:StopFreeCamera()
end
function MainControlBaseUI:HideQuickChatMenu(bIgnoreQuickMenu)
  print(bWriteLog and "MainControlBaseUI:HideQuickChatMenu", bIgnoreQuickMenu)
  if not bIgnoreQuickMenu and self.QuickMenu then
    if self.QuickMenu:IsShow() then
      self.QuickMenu:HideWithAnim()
    else
      self.QuickMenu:Collapsed()
    end
  end
  self.Image_hot:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.Image_Sigh_yellow:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_ShowOffTips:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if not self.WidgetSwitcher_Chat:GetActiveWidgetIndex() == 2 then
    return
  end
  self.WidgetSwitcher_Chat:SetActiveWidgetIndex(0)
  self.Image_ChatBG:SetRenderScale(FVector2D(1, 1))
  self.Image_ChatBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and slua.isValid(PlayerController:GetChatComponent()) then
    local ChatComponent = PlayerController:GetChatComponent()
    ChatComponent:ShowQuickPanel(false)
    Client.ResetSlateTickEveryFrame(SlateUI_ID.MAINCONTROL_BASE_UI_QUICK_CHAT_MENU)
  end
end
function MainControlBaseUI:ShowQuickChatMenu()
  local BackPackPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if BackPackPanel and BackPackPanel:IsCollapsed() then
    self.QuickMenu:SelfHitTestInvisible()
    self.WidgetSwitcher_Chat:SetActiveWidgetIndex(2)
    self.Image_ChatBG:SetWidgetVisibility(ESlateVisibility.Collapsed)
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(PlayerController) then
      return
    end
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentfromController(PlayerController)
    if not slua.isValid(ChatComponent) then
      return
    end
    ChatComponent:ShowQuickPanel(true)
    local ImageHotVisibility = self.Image_hot:GetVisibility()
    local bIsVisible = ImageHotVisibility == ESlateVisibility.Visible or ImageHotVisibility == ESlateVisibility.HitTestInvisible or ImageHotVisibility == ESlateVisibility.SelfHitTestInvisible
    if bIsVisible then
      if self.QuickMenu then
        self.QuickMenu:SelectOpt(2)
      end
      self.Image_hot:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
  self.CanvasPanel_ShowOffTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
  Client.RequireSlateTickEveryFrame(SlateUI_ID.MAINCONTROL_BASE_UI_QUICK_CHAT_MENU)
end
function MainControlBaseUI:DelayInitQuickMsgMenu()
  if self.QuickMenu then
    self.QuickMenu:EnableMsgToReset()
    self.QuickMenu:InitQuickMsg()
  end
end
function MainControlBaseUI:HandleQuickExpressClick(_, _)
  if self.HideBuffList then
    self:HideBuffList()
  end
end
function MainControlBaseUI:OnShowOrHideQuickExpressionRing(nEventType, nEventID, bIsShow)
  if bIsShow then
    self:ShowExpressionRing()
  else
    self:HideExpressionRing()
  end
end
function MainControlBaseUI:ShowExpressionRing()
  local QuickExpression = self:GetExpressionRing()
  QuickExpression = QuickExpression or UIManager.ShowUI(UIManager.UI_Config_InGame.QuickExpression)
  self:AddChildWidget(QuickExpression)
  if self.Emote_SettingControl and QuickExpression then
    QuickExpression:AttachToPanel(self.Emote_SettingControl)
    QuickExpression:SetAnchors(0, 0, 1, 1)
    QuickExpression:SetOffsets(0, 0, 0, 0)
    QuickExpression:SetPosition(0, 0)
  end
  if QuickExpression then
    QuickExpression:ShowOrHideRing(true)
  end
end
function MainControlBaseUI:GetExpressionRing()
  return UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpression)
end
function MainControlBaseUI:HideExpressionRing()
  local QuickExpression = self:GetExpressionRing()
  if QuickExpression then
    QuickExpression:ShowOrHideRing(false)
  end
end
function MainControlBaseUI:RefreshEmoteWhenShow()
  local QuickExpression = self:GetExpressionRing()
  if QuickExpression then
    QuickExpression:RefreshEmoteWhenShow()
  end
end
function MainControlBaseUI:RefreshEmote()
  local QuickExpression = self:GetExpressionRing()
  if QuickExpression then
    QuickExpression:RefreshEmote()
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local uPlayEmoteComp = uPlayerCharacter:GetPlayEmoteComponent()
    if slua.isValid(uPlayEmoteComp) then
      print(bWriteLog and "MainControlBaseUI:RefreshEmote uPlayEmoteComp:ReplaySpectatorEmote")
      uPlayEmoteComp:ReplaySpectatorEmote()
    end
  end
end
function MainControlBaseUI:OpenIngameGMPanel()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsAGMPlayer and (uPlayerController:IsAGMPlayer() or uPlayerController:IsEnterpriseGMMod()) and UIManager.UI_Config_InGame.BattleGMPanel and not UIManager.IsUIShow(UIManager.UI_Config_InGame.BattleGMPanel) then
    local GMPanel = UIManager.ShowUI(UIManager.UI_Config_InGame.BattleGMPanel)
  end
end
function MainControlBaseUI:OnPlayerControllerBeginplayFinish()
  self:CheckEnterpriseGMMod()
  self:CheckGMButtonVisibility()
end
function MainControlBaseUI:OnCreateGMUI()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController:IsAGMPlayer() then
    if not slua.isValid(self.GMUI) then
      local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local sGMUI_Path = "/Game/BluePrints/UI/GMConsole/GMUI.GMUI_C"
      local GMUI = USTExtraBlueprintFunctionLibrary.CreateWidgetByPathName(sGMUI_Path, uPlayerController)
      self.    end
    self.GMUI:AddtoViewport(30001)
  end
end
function MainControlBaseUI:CheckGMButtonVisibility()
  if not slua.isValid(self.Button_IngameGM) then
    return
  end
  if not slua.isValid(self.TextBlock_GMUI) then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and (uPlayerController:IsAGMPlayer() or uPlayerController:IsEnterpriseGMMod()) then
    self.Button_IngameGM:SetWidgetVisibility(ESlateVisibility.Visible)
    if not Client.IsEditor() then
      self.TextBlock_GMUI:SetWidgetVisibility(ESlateVisibility.Collapsed)
    else
      self.TextBlock_GMUI:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.Button_IngameGM:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:CheckEnterpriseGMMod()
  local bEnterpriseGMMod = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    bEnterpriseGMMod = uPlayerController:IsEnterpriseGMMod()
  end
  if bEnterpriseGMMod then
    self.InvalidationBox_GM:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:IsBackpackCollapsed()
  local BackPackPanel = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
  if not BackPackPanel then
    return true
  end
  return BackPackPanel:IsCollapsed()
end
function MainControlBaseUI:CallBackpackLuaFunction(FunctionName)
  local BackpackUI = InGameUITools.GetBackpackUI()
  if not BackpackUI then
    print(bWriteLog and "MainControlBaseUI:CallBackpackLuaFunction(%s) BackpackUI is nil, " .. FunctionName)
    return
  end
  if BackpackUI[FunctionName] then
    BackpackUI[FunctionName](BackpackUI)
  end
end
function MainControlBaseUI:BackpackGetArmorSlotItem(ArmorSlotType)
  local BackpackUI = InGameUITools.GetBackpackUI()
  return BackpackUI:GetArmorSlotItem(ArmorSlotType)
end
function MainControlBaseUI:CheckAddNewMiniMap()
  local MiniMapUI = UIManager.GetUI(UIManager.UI_Config_InGame.MiniMapWindow)
  if MiniMapUI then
    MiniMapUI:CheckInitialize()
  end
end
function MainControlBaseUI:OnChatPrivacyAccepted()
  local VoiceChatSubsytem = SubsystemMgr:Get("VoiceChatSubsystem")
  if VoiceChatSubsytem then
    local VoiceChatSPData = VoiceChatSubsytem:GetSuperData()
    VoiceChatSPData.bOnChatPrivacyAccepted = true
  end
end
function MainControlBaseUI:UpdateSnowBoardBtn()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not (slua.isValid(uPlayerCharacter) and uPlayerCharacter.IsCanDriveSnowBoard) or not uPlayerCharacter:IsCanDriveSnowBoard() then
    if self.BasicSkillsMenuUI then
      self.BasicSkillsMenuUI:HideNormalBtn("Type_SnowBoard")
    end
    return
  end
  if self.BasicSkillsMenuUI then
    self.BasicSkillsMenuUI:ShowNormalBtn("Type_SnowBoard")
  end
end
function MainControlBaseUI:GetBlueCirclePreWarningGeneralTipId(FontType)
  local IsWinOBCN = self:IsWinOBCN()
  if IsWinOBCN then
    return 1000207
  elseif FontType == 0 then
    return 1000201
  elseif FontType == 1 then
    return 1000202
  elseif FontType == 2 then
    return 1000203
  else
    return 1000201
  end
end
function MainControlBaseUI:OnShowSpeechToText(_, _, bShow)
  if bShow then
    self:CreateChildWindow(self.ChatAndChatPanelCanvas, UIManager.UI_Config_InGame.SpeechToText)
    self:HideQuickChatMenu()
  else
    if UIManager.GetUI(UIManager.UI_Config_InGame.SpeechToText) then
      UIManager.CloseUI(UIManager.UI_Config_InGame.SpeechToText)
    end
    self:ShowQuickChatMenu()
  end
  self.CanvasPanel_ShowOffTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:OnShowOffTips(_, _, ShowOffType)
  print(bWriteLog and "MainControlBaseUI:OnShowOffTips", ShowOffType)
  if UIManager.UI_Config_InGame.ShowOffTipsUI then
    local ShowOffTipsUI = UIManager.ShowUI(UIManager.UI_Config_InGame.ShowOffTipsUI, ShowOffType)
    if ShowOffTipsUI then
      ShowOffTipsUI:AttachToPanel(self.CanvasPanel_ShowOffTips)
      ShowOffTipsUI:SetAnchors(1, 0, 1, 0)
      ShowOffTipsUI:SetAlignment(1, 0)
      ShowOffTipsUI:SetOffsets(0, 0, 0, 0)
    end
  end
  local ShowOffTime = 30
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  ShowOffTime = IngameLikeConfig.ShowOffTime
  self:AddGameTimer(ShowOffTime, true, function()
    if UIManager.UI_Config_InGame.ShowOffTipsUI and UIManager.IsUIShow(UIManager.UI_Config_InGame.ShowOffTipsUI) then
      UIManager.CloseUI(UIManager.UI_Config_InGame.ShowOffTipsUI)
    end
  end)
end
function MainControlBaseUI:OnEnterPlane()
  print(bWriteLog and "MainControlBaseUI:OnEnterPlane")
  if UIManager.UI_Config_InGame.ShowOffTipsUI and UIManager.IsUIShow(UIManager.UI_Config_InGame.ShowOffTipsUI) then
    UIManager.CloseUI(UIManager.UI_Config_InGame.ShowOffTipsUI)
  end
  self:CallBackpackLuaFunction("ClickCloseBackpack")
end
function MainControlBaseUI:OnClickQuickChatClose()
  if self.bIsQuickMenuCoolingDown then
    return
  end
  self.bIsQuickMenuCoolingDown = true
  self:AddGameTimer(0.2, false, function()
    self.bIsQuickMenuCoolingDown = false
  end)
  self:HideQuickChatMenu()
end
function MainControlBaseUI:OnDestroy()
  print(bWriteLog and "MainControlBaseUI:OnDestroy")
  self.HasInit = false
  self.BackPackPickUpPanel = nil
  self.BasicSkillsMenuUI = nil
  self.GMUI = nil
  self.QuickMenu = nil
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.Object)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.Chat)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.BasicSkillsMenu_BP)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.CanvasPanel_BackpackPanel)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.Emote_SwimingControl)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.CircleChasingProgress)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.CanvasPanel_MiniMapAndSetting)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.Border_NewBackPack)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.BackPackPickUpPanel_BP)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.CanvasPanel_FreeCamera)
  if self.UpdateTrainingTimer then
    self:RemoveGameTimer(self.UpdateTrainingTimer)
    self.UpdateTrainingTimer = nil
  end
  if self.HitTipsTimer then
    print(bWriteLog and "MainControlBaseUI:OnTakeDamage Remove HitTipsTimer")
    self:RemoveGameTimer(self.HitTipsTimer)
    self.HitTipsTimer = nil
  end
  self.DamageCauserLocation = nil
  self.DynamicBattleFBTipsWidget = nil
  self.RolewearTabArray = nil
  self.ForceShowWidgets = nil
  self.ForceHideWidgets = nil
  self.BigEvent_Btn = nil
  if UIManager and UIManager.UI_Config_InGame.ChangeSightUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.ChangeSightUI)
  end
  if UIManager and UIManager.UI_Config_InGame.QuickExpression then
    UIManager.CloseUI(UIManager.UI_Config_InGame.QuickExpression)
  end
  if UIManager and UIManager.UI_Config_InGame.SpeechToText then
    UIManager.CloseUI(UIManager.UI_Config_InGame.SpeechToText)
  end
  if UIManager and UIManager.UI_Config_InGame.MicrophoneButton then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MicrophoneButton)
  end
  if self.VoiceForbidBtn then
    self.VoiceForbidBtn:Close()
    self.VoiceForbidBtn = nil
  end
  MainControlBaseUI.__super.OnDestroy(self)
end
function MainControlBaseUI:ClearBPArray(array)
  if array and array.Clear then
    array:Clear()
  end
end
function MainControlBaseUI:OnEntireMapTriggerOnPressDown(PointerIndex)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("Slate.EnableUIDynamicBatch", 0)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local Setting = SettingModule:GetOptionValue("bCanMapLongPress")
  if Setting == nil or Setting == true then
    self.EntireMapTrigger.ButtonType = 3
    self:ShowEntireMapWindow()
  else
    self.EntireMapTrigger.ButtonType = 1
  end
end
function MainControlBaseUI:OnEntireMapTriggerHoldEnded()
  BatttleWindowMgr.HideUI("EntireMapWindow")
end
function MainControlBaseUI:OnEntireMapTriggerClick()
  if self.EntireMapTrigger.ButtonType == 1 then
    self:ShowEntireMapWindow()
  end
end
function MainControlBaseUI:ShowEntireMapWindow()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI then
    if UIManager.IsUIShow(EntireMapUIConfig) then
      UIManager.HideUI(EntireMapUIConfig)
    else
      UIManager.ShowUI(EntireMapUIConfig)
    end
  else
    UIManager.ShowUI(EntireMapUIConfig)
  end
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    PlayerState:RPC_ServerAddGeneralCount(11527, 1, false)
  end
  self:HideBuffList()
  self:HideQuickChatMenu()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("UIMsg_ParachutingHeightBarMoveLeft", 0, "", "")
  end
end
function MainControlBaseUI:OnTurnplateBtnTouchStart()
  print(bWriteLog and "MainControlBaseUI:OnTurnplateBtnTouchStart", self.bIsQuickMenuCoolingDown, self.ChatOpenTime)
  if self.bIsQuickMenuCoolingDown then
    return
  end
  if GameplayStatics.GetRealTimeSeconds(self) > self.ChatOpenTime then
    self.ChatTurnplateCommonRotaryTableUITool:OnTouchedStart(self.TurnplateBtn_UIBP_0.PressedPosition)
    self:HideQuickChatMenu(true)
    self.ChatBtnLongPressTimerID = self:AddGameTimer(0.2, false, function()
      self.ChatBtnLongPressTimerID = nil
      self:ShowTurnplateUI()
    end)
    self.bIsQuickMenuCoolingDown = true
    self:AddGameTimer(0.5, false, function()
      self.bIsQuickMenuCoolingDown = false
    end)
  end
end
function MainControlBaseUI:ShowTurnplateUI()
  self.Image_ChatBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.Image_ChatBG:SetRenderScale(FVector2D(1.25, 1.25))
  self.Image_ChatBG:SetOpacity(1)
  self:HideBuffList()
  local TurnplateUIControl = UIManager.GetUI(UIManager.UI_Config_InGame.TurnplateUIControl)
  TurnplateUIControl = TurnplateUIControl or UIManager.ShowUI(UIManager.UI_Config_InGame.TurnplateUIControl)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(PlayerController)
    if not slua.isValid(ChatComponent) then
      return
    end
    ChatComponent:ShowQuickPanel(true)
  end
end
function MainControlBaseUI:OnTurnplateBtnTouchMove()
  print(bWriteLog and "MainControlBaseUI:OnTurnplateBtnTouchMove")
  if GameplayStatics.GetRealTimeSeconds(self) > self.ChatOpenTime and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.TurnplateUIControl then
    local TurnplateUIControl = UIManager.GetUI(UIManager.UI_Config_InGame.TurnplateUIControl)
    if TurnplateUIControl then
      self:QuickMsgTurnplateBtnMove()
    else
      self.Image_ChatBG:SetRenderScale(FVector2D(1.25, 1.25))
      if self.ChatTurnplateCommonRotaryTableUITool:IsValidedMove(slua.IndexReference(self.TurnplateBtn_UIBP_0, "CurPosition"), 5) and self.ChatBtnLongPressTimerID then
        self:RemoveGameTimer(self.ChatBtnLongPressTimerID)
        self.ChatBtnLongPressTimerID = nil
        self:ShowTurnplateUI()
      end
    end
  end
end
function MainControlBaseUI:QuickMsgTurnplateBtnMove()
  local LocalPos = self.ChatTurnplateCommonRotaryTableUITool:OnTouchedMove(self.TurnplateBtn_UIBP_0.CurPosition)
  local TurnplateUIControl = UIManager.GetUI(UIManager.UI_Config_InGame.TurnplateUIControl)
  if TurnplateUIControl then
    TurnplateUIControl:SetSelectedIconTranslation(LocalPos)
  end
  LocalPos = self.ChatTurnplateCommonRotaryTableUITool:GetLocalPos(30)
  self.Border_Normal:SetRenderTranslation(LocalPos)
  if self.ChatTurnplateCommonRotaryTableUITool.CurIndex == -1 then
    self.QuickMsgIndex = -1
    TurnplateUIControl:SelectQuickMsg(-1)
  else
    local QuickMsgIndex = self.ChatTurnplateCommonRotaryTableUITool.CurIndex
    if QuickMsgIndex ~= self.QuickMsgIndex then
      self.      TurnplateUIControl:SelectQuickMsg(QuickMsgIndex)
    end
  end
end
function MainControlBaseUI:OnTurnplateBtnTouchEnd()
  print(bWriteLog and "MainControlBaseUI:OnTurnplateBtnTouchEnd")
  if self.ChatBtnLongPressTimerID then
    self:RemoveGameTimer(self.ChatBtnLongPressTimerID)
    self.ChatBtnLongPressTimerID = nil
    if GameplayStatics.GetRealTimeSeconds(self) > self.ChatOpenTime then
      self:CheckTopChatMsg()
      self:ShowQuickChatMenu()
      ClientTLogUtil.ReportGeneralCountByBRPhase(12008, 12010)
    end
  else
    local TurnplateUIControl = UIManager.GetUI(UIManager.UI_Config_InGame.TurnplateUIControl)
    if TurnplateUIControl then
      TurnplateUIControl.UIRoot:SendTurnplateQuickMsg(self.QuickMsgIndex)
      if TurnplateUIControl.UIRoot:IsIndexValid(self.QuickMsgIndex) and self.QuickMsgIndex >= 0 then
        local PlayerController = GameplayData.GetPlayerController()
        if slua.isValid(PlayerController) then
          local ChatComponent = USTExtraBlueprintFunctionLibrary.GetChatComponentFromController(PlayerController)
          if slua.isValid(ChatComponent) then
            self:StartChatBarAnimation(ChatComponent.SendMsgCD)
            ClientTLogUtil.ReportGeneralCountByBRPhase(12009, 12011)
            local QuickMsgID = 0
            if slua.isValid(ChatComponent.TurnplateChatQuickList) then
              local MsgItem = ChatComponent.TurnplateChatQuickList:Get(self.QuickMsgIndex)
              if MsgItem then
                QuickMsgID = MsgItem.chatTextID or 0
                if QuickMsgID ~= 0 then
                  ClientTLogUtil.ReportCommonTLogDataByBRPhase(213, 213, tostring(QuickMsgID), 1)
                end
              end
            end
          end
        end
      end
    end
    self:HideTurnplateUIBP()
  end
end
function MainControlBaseUI:HideTurnplateUIBP()
  self.Image_ChatBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.Image_ChatBG:SetRenderScale(FVector2D(1, 1))
  self.Image_ChatBG:SetOpacity(self.ChatBtnNormalOpacity)
  self.Image_SelectedChatCircle:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.Border_Normal:SetRenderTranslation(FVector2D(0, 0))
  if not self.QuickMenu:IsShow() then
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:OnPressTurnplateQuickMsgBtn()
      local ChatComponent = USTExtraBlueprintFunctionLibrary.GetChatComponentFromController(PlayerController)
      if slua.isValid(ChatComponent) then
        ChatComponent:ShowQuickPanel(false)
      end
    end
  end
  self.QuickMsgIndex = -1
  UIManager.CloseUI(UIManager.UI_Config_InGame.TurnplateUIControl)
end
function MainControlBaseUI:CheckTopChatMsg()
  local VoiceRecommendationSubsystem = SubsystemMgr:Get("VoiceRecommendationSubsystem")
  if not VoiceRecommendationSubsystem then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local ChatComponent = USTExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
  if not slua.isValid(ChatComponent) then
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    ChatComponent:ClearSpecialChat()
    return
  end
  local Voice, TypeIndex = VoiceRecommendationSubsystem:DoCheckCondition()
  if Voice ~= nil and TypeIndex ~= -1 then
    VoiceRecommendationSubsystem:AddTotalRecommendationTimes(TypeIndex)
  end
  if self.LastRecommendIndex ~= nil and self.LastRecommendIndex == TypeIndex then
    return
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI or not MainControlBaseUI.QuickMenu then
    return
  end
  local QuickMenu = MainControlBaseUI.QuickMenu
  self.LastRecommendIndex = TypeIndex
  ChatComponent:ClearSpecialChat()
  if Voice ~= nil then
    for _, VoiceID in pairs(Voice) do
      ChatComponent:AddSpecialChat(VoiceID, TypeIndex)
    end
  end
  QuickMenu:RefreshQuickChatScroll()
end
function MainControlBaseUI:StartChatBarAnimation(CDTime)
  if 0 < CDTime then
    Client.RequireSlateTickEveryFrame(SlateUI_ID.MAINCONTROL_BASE_UI_CHATBAR_CD)
    local UIUtil = require("client.common.ui_util")
    self.ChatOpenTime = GameplayStatics.GetRealTimeSeconds(self) + CDTime
    self.Image_ChatCDBar:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.Chat_Bar, 0, 1, 0, 1 / CDTime)
    self:AddGameTimer(CDTime, false, function()
      Client.ResetSlateTickEveryFrame(SlateUI_ID.MAINCONTROL_BASE_UI_CHATBAR_CD)
      self.Image_ChatCDBar:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end)
  end
end
function MainControlBaseUI:HandleChangeSightUIAndroidBack()
  local ChangeSightUI = UIManager.GetUI(UIManager.UI_Config_InGame.ChangeSightUI)
  if ChangeSightUI and ChangeSightUI.UIRoot.CanvasPanelList:GetVisibility() ~= ESlateVisibility.Collapsed then
    ChangeSightUI:HideList()
    self.hasOpenedSubPanel = true
  end
end
function MainControlBaseUI:IsUseNewHitEffect()
  local SoundVisualizationSubsystem = SubsystemMgr:Get("SoundVisualizationSubsystem")
  if not SoundVisualizationSubsystem then
    return false
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) and uPlayerController.IsObserver and uPlayerController:IsObserver() then
    return false
  end
  return SoundVisualizationSubsystem:UseNewHitStyle()
end
function MainControlBaseUI:ShowNavigatorPanel()
  if not UIManager.GetUI(UIManager.UI_Config_InGame.NavigatorPanel) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.NavigatorPanel)
  end
end
function MainControlBaseUI:OnNavigatorVisibleChanged(_, _, bIsShow)
  self.NavigatorIsShow = bIsShow
end
function MainControlBaseUI:ShowOrHideBackPackBtnTips(bShow, Info)
  local BackpackClothingEntryUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackClothingEntryUI)
  if BackpackClothingEntryUI then
    if Info then
      Info.text1 = Info.Text1
    end
    BackpackClothingEntryUI:ShowOrHideBackPackBtnTips(bShow, Info)
  end
end
function MainControlBaseUI:TickHitTips()
  if not self.DamageCauserLocation then
    print(bWriteLog and "MainControlBaseUI:TickHitTips Failed")
    self.CanvasPanel_HItTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.CanvasPanel_OBAttackerTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
    if self.HitTipsTimer then
      print(bWriteLog and "MainControlBaseUI:OnTakeDamage Remove HitTipsTimer")
      self:RemoveGameTimer(self.HitTipsTimer)
      self.HitTipsTimer = nil
    end
    return
  end
  local bSuccess, Angle = USTExtraBlueprintFunctionLibrary.CalculateDirectionAngle(self.DamageCauserLocation, 0)
  if bSuccess then
    self.CanvasPanel_HItTips:SetRenderAngle(Angle)
  end
end
function MainControlBaseUI:OnTakeDamage(Angle, uCauser, nDamage)
  print(bWriteLog and "MainControlBaseUI:OnTakeDamage Angle", Angle, uCauser, nDamage)
  local IsShowHit = self:IsShowHit()
  local IsShowBlood = false
  local IsObserver = false
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    if uPlayerController.IsShowBlood then
      IsShowBlood = uPlayerController:IsShowBlood()
    end
    if uPlayerController.IsObserver then
      IsObserver = uPlayerController:IsObserver()
    end
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and nDamage <= 0 and uPlayerCharacter.bIgnoreShowHurtEffectWhenAttackByTeammate then
    return
  end
  print(bWriteLog and "MainControlBaseUI:OnTakeDamage", IsShowBlood, IsShowHit, IsObserver)
  if not (IsShowBlood and IsShowHit) or not Angle then
    if self.HitTipsTimer then
      self:RemoveGameTimer(self.HitTipsTimer)
      self.HitTipsTimer = nil
    end
    return
  end
  if not slua.isValid(uCauser) then
    print(bWriteLog and "MainControlBaseUI:OnTakeDamage - uCauser is nil")
    return
  end
  self.DamageCauserLocation = uCauser:K2_GetActorLocation()
  self:TickHitTips()
  if not self.HitTipsTimer then
    print(bWriteLog and "MainControlBaseUI:OnTakeDamage Add HitTipsTimer")
    self.HitTipsTimer = self:AddGameTimer(RefreshInterval, true, function()
      self:TickHitTips()
      self.CanvasPanel_HItTips:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    end)
    self:AddGameTimer(1, false, function()
      self.CanvasPanel_HItTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.CanvasPanel_OBAttackerTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
      if self.HitTipsTimer then
        print(bWriteLog and "MainControlBaseUI:OnTakeDamage Remove HitTipsTimer")
        self:RemoveGameTimer(self.HitTipsTimer)
        self.HitTipsTimer = nil
        self.DamageCauserLocation = nil
      end
    end)
  end
  if IsObserver and slua.isValid(uCauser) then
    local bIsMonster = Game:IsMonster(uCauser) or Game:IsAI(uCauser) and 0 < uCauser.ResId
    if not bIsMonster then
      self:GetPCOBAttackerTips()
      self.CanvasPanel_OBAttackerTips:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
      local x = math.cos(math.rad(-Angle + 90)) * 200
      local y = -math.sin(math.rad(-Angle + 90)) * 200
      print(bWriteLog and "MainControlBaseUI:OnTakeDamageAngle ", Angle, x, y, self.AttackerTips)
      if slua.isValid(self.AttackerTips) and x and y then
        self.CanvasPanel_OBAttackerTips.Slot:SetPosition(FVector2D(x, y))
        util.SetOffsets(self.CanvasPanel_OBAttackerTips, x, y)
        if 0 < x then
          self.AttackerTips.Slot:SetAlignment(FVector2D(0, 0.5))
        else
          self.AttackerTips.Slot:SetAlignment(FVector2D(1, 0.5))
        end
        self.AttackerTips.TextBlock_Damage:SetText(tostring(math.ceil(nDamage)))
        local TeamID = uCauser.TeamID
        local PlayerName = uCauser:GetPlayerNameSafety()
        local TeamName = ""
        local OBUtilitySubsystem = SubsystemMgr:Get("OBUtilitySubsystem")
        if OBUtilitySubsystem then
          local uSyncOBDataActor = OBUtilitySubsystem:GetSyncOBDataActor()
          if uSyncOBDataActor then
            for _, PlayerInfoOB in pairs(uSyncOBDataActor.TotalPlayerList) do
              if PlayerInfoOB.PlayerKey == uCauser.PlayerKey then
                PlayerName = PlayerInfoOB.PlayerName
                TeamName = PlayerInfoOB.TeamName
              end
            end
          end
        end
        print(bWriteLog and "MainControlBaseUI:OnTakeDamage TeamID", TeamID, PlayerName, uCauser.PlayerKey, TeamName)
        if OBUtilitySubsystem and TeamID then
          OBUtilitySubsystem:LoadTeamLogoByTeamID(TeamID, function(Texture)
            self.AttackerTips.Image_TeamLogo:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
            self.AttackerTips.Image_TeamLogo:SetBrushFromTexture(Texture, false)
          end)
        end
        if PlayerName then
          self.AttackerTips.TextBlock_PlayerName:SetText(PlayerName)
        end
        if TeamName then
          self.AttackerTips.TextBlock_TeamName:SetText(TeamName)
        end
      end
    end
  end
  if slua.isValid(uCauser) and uCauser.PlayerKey then
    self.nLastAttackerPlayerKey = uCauser.PlayerKey
  end
end
function MainControlBaseUI:GetPCOBAttackerTips()
  if self.AttackerTips then
    return self.AttackerTips
  end
  self.AttackerTips = slua.loadUI("/Game/BluePrints/UI/OBUI/Item/OB_AttackerTips.OB_AttackerTips")
  if self.AttackerTips then
    self.CanvasPanel_OBAttackerTips:AddChild(self.AttackerTips)
    self.AttackerTips.Slot:SetAnchors(FAnchors(0, 0, 0, 0))
    self.AttackerTips.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self.AttackerTips.Slot:SetAutoSize(true)
    return self.AttackerTips
  end
end
function MainControlBaseUI:ObserveLastAttacker()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.ServerObserveCharacter and uPlayerController:IsObserver() and self.nLastAttackerPlayerKey and self.nLastAttackerPlayerKey > 0 then
    print(bWriteLog and "MainControlBaseUI:ObserveLastAttacker", self.nLastAttackerPlayerKey)
    uPlayerController:ServerObserveCharacter(self.nLastAttackerPlayerKey)
  end
end
function MainControlBaseUI:GetVoiceSDKInterface()
  local UIUtil = require("client.common.ui_util")
  return UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
end
function MainControlBaseUI:OpenReportBug()
  print(bWriteLog and "MainControlBaseUI:OpenReportBug")
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local bIsPlanPHMode = logic_home_entry:IsPlanPHMode()
  if not bIsPlanPHMode then
    UIManager.ShowUI(UIManager.UI_Config_InGame.BattleReportBug)
  else
    local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
    local reportInfo = logic_home_detail.reportInfo or {}
    local logic_home_report = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_report)
    local home_report_macros = require("client.slua.logic.home.home_report_macros")
    logic_home_report:ShowInGameReportUI(home_report_macros.ENUM_REPORT_TYPE.Detail, reportInfo)
  end
end
function MainControlBaseUI:RegShowQuickDecal()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self:AddControlEvent(PlayerController, "OnChangeCharacterLogicDelegate", self.OnShowQuickDecalButton, self)
  end
end
function MainControlBaseUI:OnShowQuickDecalButton(NewPawnType)
  local QuickExpressionDecalUI = self:CreateAndGetQuickExpressionDecalUI()
  if QuickExpressionDecalUI and NewPawnType == ECharacterSubType.NormalPlayer then
    UIManager.ShowUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  else
    UIManager.HideUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  end
end
function MainControlBaseUI:CreateAndGetQuickExpressionDecalUI()
  local QuickExpressionDecalUI = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  QuickExpressionDecalUI = QuickExpressionDecalUI or UIManager.ShowUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  return QuickExpressionDecalUI
end
function MainControlBaseUI:HideQuickExpressionDecalUI()
  local QuickExpressionDecalUI = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  if QuickExpressionDecalUI then
    QuickExpressionDecalUI:Collapsed()
  end
end
function MainControlBaseUI:HandleAndroidBack()
  self:CallBackpackLuaFunction("ClickCloseBackpack")
  self:ShowQuickMsgInfo(true)
  self:HideQuickChatMenu()
  self:ShowOrHideQuickExpressionRing(false)
  BatttleWindowMgr.CheckCloseMiniMap()
  self:HandleChangeSightUIAndroidBack()
  self:HideBuffList()
end
function MainControlBaseUI:HandleEntireMapTrigger(_, EventID)
  if not slua.isValid(self.EntireMapTrigger) then
    print(bWriteLog and string.format("MainControlBaseUI:HandleEntireMapTrigger -EntireMapTrigger is nil"))
    return
  end
  if EventID == EVENTID_OPEN_BACKPACK then
    self.EntireMapTrigger:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif EventID == EVENTID_CLOSE_BACKPACK then
    self.EntireMapTrigger:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  print(bWriteLog and string.format("MainControlBaseUI:HandleEntireMapTrigger -EntireMapTrigger visibility: %d", self.EntireMapTrigger:GetVisibility()))
end
function MainControlBaseUI:OpenGMInterface()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    if PlayerController:IsAGMPlayer() then
      print(bWriteLog and "=====E>Show the Gear")
      self.InvalidationBox_GM:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.InvalidationBox_GM:InvalidateCache()
      if Client.IsEditor() then
        self.Image_24:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
        return
      end
    end
  else
    self:AddGameTimer(0.5, false, function()
      self:OpenGMInterface()
    end)
  end
end
function MainControlBaseUI:EnterFlying()
  self:ShowOrHideFreeCam(false)
end
function MainControlBaseUI:HandleEmoteSetting()
  self:AddSettingOptionEvent("ActorAnimationSwitch", function(ActorAnimationSwitch)
    self:SetEmoteControlVisibility(self.Emote_SettingControl, ActorAnimationSwitch)
  end)
  self:AddSettingOptionEvent("OBSBulletTrack", function(OBSBulletTrack)
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:ToggleEnableOBBulletTrackEffectSetting(OBSBulletTrack)
    end
  end)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    self:SetEmoteControlVisibility(self.Emote_SettingControl, SettingConfig.ActorAnimationSwitch)
  end
end
function MainControlBaseUI:UIMsg_ShowEnemyLaunchRocketTips()
  self.CanvasPanel_EnemyLaunchRocketTip:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self:AddGameTimer(3.0, false, function()
    self.CanvasPanel_EnemyLaunchRocketTip:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end)
  self.CanvasPanel_CircleTipsPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:EnterJumping()
  self:EnterJumpingSetUI()
end
function MainControlBaseUI:OnClicked_Button_ReportBug()
  audio_util.PlayAudio(sound_config.set)
  self:OpenReportBug()
  print(bWriteLog and "[songGT]  before  play sound ")
end
function MainControlBaseUI:OnClicked_MultiButton_EntireMapTrigger()
  self:TriggerEntireMap()
end
function MainControlBaseUI:TriggerEntireMap()
  BatttleWindowMgr.OpenOrHideEntireMap()
  self:HideBuffList()
  self:HideQuickChatMenu()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("UIMsg_ParachutingHeightBarMoveLeft", 0, "", "")
  end
end
function MainControlBaseUI:OnClicked_Button_0()
  if GameplayStatics.GetRealTimeSeconds(self) > self.ChatOpenTime then
    self:ShowQuickChatMenu()
  end
end
function MainControlBaseUI:OnClicked_Button_B_Sigh_yellow()
  if GameplayStatics.GetRealTimeSeconds(self) > self.ChatOpenTime then
    self:ShowQuickChatMenu()
  end
end
function MainControlBaseUI:StartChatBarAnima(CDtime)
  if 0.0 < CDtime then
    Client.RequireSlateTickEveryFrame(SlateUI_ID.MAINCONTROL_BASE_UI_CHATBAR_CD)
    self.ChatOpenTime = GameplayStatics.GetRealTimeSeconds(self) + CDtime
    self.Image_ChatCDBar:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.Chat_Bar, 0.0, 1, EUMGSequencePlayMode.Forward, 1.0 / CDtime)
    self:DelayHideChatCD(CDtime)
  end
end
function MainControlBaseUI:DelayHideChatCD(CDTime)
  self:AddGameTimer(CDTime, false, function()
    Client.ResetSlateTickEveryFrame(SlateUI_ID.MAINCONTROL_BASE_UI_CHATBAR_CD)
    self.Image_ChatCDBar:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end)
end
function MainControlBaseUI:OnClicked_Button_ExitTraining()
  self:ExitTraining()
end
function MainControlBaseUI:ExitTraining()
  audio_util.PlayAudio(sound_config.confirm)
  if EventShowBackToLobbyFromTrainingNotice ~= nil then
    EventShowBackToLobbyFromTrainingNotice()
  end
end
function MainControlBaseUI:BuffDisplayListBtnClickEvent()
  if self.BuffEffectDisplayIDList:Num() > 0 then
    if self.DynamicBattleFBTipsWidget:GetVisibility() == ESlateVisibility.Collapsed then
      self.DynamicBattleFBTipsWidget:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    else
      self.DynamicBattleFBTipsWidget:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.BuffListCloseStartCountDown = false
    end
  end
end
function MainControlBaseUI:ShowHelpIcon()
  self.DynamicBattleFBTipsWidget.GridPanel_Help:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
end
function MainControlBaseUI:HideHelpIcon()
  self.DynamicBattleFBTipsWidget.GridPanel_Help:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:ShowPowerIcon()
  self.DynamicBattleFBTipsWidget.GridPanel_Power:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
end
function MainControlBaseUI:HidePowerIcon()
  self.DynamicBattleFBTipsWidget.GridPanel_Power:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:HideBuffListEvent()
  self:HideBuffList()
end
function MainControlBaseUI:BindEventToBattleFBTips()
  self:AddControlEvent(self.QuickExpressionUIBPDynamic, "ED_QuickExpressBtnClick", self.HideBuffListEvent, self)
  self:AddControlEvent(self.DynamicBattleFBTipsWidget, "ED_HideBuffListHotAreaClick", self.HideBuffListEvent, self)
end
function MainControlBaseUI:OnClicked_Button_Normal_EX()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    audio_util.PlayAudio(sound_config.CircleChoose_ListExpand)
    self:ShowOrHideQuickExpressionRing(true)
  end
end
function MainControlBaseUI:OnClicked_EXButton_close()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    audio_util.PlayAudio(sound_config.CircleChoose_ListExpand)
    self:ShowOrHideQuickExpressionRing(false)
  end
end
function MainControlBaseUI:UIMsg_CloseQuickExpressionRing()
  self:ShowOrHideQuickExpressionRing(false)
end
function MainControlBaseUI:DemoReplay_ReInit()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("ED_GameReplayReint", 0, "", "")
  end
end
function MainControlBaseUI:OnInfectedAreaWarnBroadcast()
  self:DisplayInfectAreaWarning()
end
function MainControlBaseUI:OnClicked_Button_Setting()
  audio_util.PlayAudio(sound_config.set)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX)
  if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.EntireMapWindow then
    UIManager.HideUI(UIManager.UI_Config_InGame.EntireMapWindow)
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:InterruptThrow()
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.EndTouchScreen and PlayerController.OnFireTouchFingerIndex then
    PlayerController:EndTouchScreen(FVector(0.0, 0.0, 0.0), PlayerController.OnFireTouchFingerIndex, true)
  end
  if self._settingClickTimer then
    self:RemoveTimer(self._settingClickTimer)
    self._settingClickTimer = nil
    UIManager.ShowUI(UIManager.UI_Config.QuickTweakPanel_CustomLayout)
    return
  end
  self._settingClickTimer = self:AddTimerOnce(0.2, function()
    self._settingClickTimer = nil
    UIManager.ShowUI(UIManager.UI_Config.setting_main, GamePlayTools.GetCurrentConfig("SettingCatalog"))
  end)
end
function MainControlBaseUI:InitCircleInfo(bUnbind)
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    if bUnbind then
      self:RemoveControlEvent(GameState, "OnBlueCirclePreWarning")
      self:RemoveControlEvent(GameState, "OnBlueCircleRun")
    else
      self:AddControlEvent(GameState, "OnBlueCirclePreWarning", self.OnCircleBlueCirclePreWarning, self)
      self:AddControlEvent(GameState, "OnBlueCircleRun", self.OnCircleBlueCircleRun, self)
    end
  end
end
function MainControlBaseUI:OnCircleBlueCirclePreWarning(Time)
  local ReturnValue = math.floor(Time + 0.5)
  local IsShow = self:IsBlueCirclePreWarningShouldShow(ReturnValue)
  print(bWriteLog and "MainControlBaseUI:OnCircleBlueCirclePreWarning", Time, ReturnValue, IsShow)
  if IsShow then
    local FontType = self:GetSecondsFontType(ReturnValue)
    self:DisplayGeneralTip(self:GetBlueCirclePreWarningGeneralTipId(FontType), self:FormatSecondsToString(ReturnValue), "")
  end
end
function MainControlBaseUI:GetSecondsFontType(Seconds)
  if 180 <= Seconds then
    return 0
  elseif 30 <= Seconds then
    return 1
  else
    return 2
  end
end
function MainControlBaseUI:OnCircleBlueCircleRun(time)
  local IsWinOBCN = self:IsWinOBCN()
  if IsWinOBCN then
    self:DisplayGeneralTip(1000301, "", "")
  else
    self:DisplayGeneralTip(10003, "", "")
  end
end
function MainControlBaseUI:CloseLbsMicWhenCorpsMode()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and (GameState.GameModeType == EGameModeType.EBattleRoyalCorpsWarMode or GameState.GameModeType == EGameModeType.EDeathMatchGameMode) then
    local VoiceSDKInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if not slua.isValid(VoiceSDKInterface) then
      VoiceSDKInterface:SwitchMicphoneWhenCorpsMode()
    end
  end
end
function MainControlBaseUI:InitRolewearTab(NeedCD)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.RolewearIndex and PlayerController.FashionBagStartIndex then
    for ArrayIndex, ArrayElement in pairs(self.RolewearTabArray) do
      ArrayElement:SetData(ArrayIndex, ArrayIndex == PlayerController.RolewearIndex - PlayerController.FashionBagStartIndex, slua.IndexReference(PlayerController, "InitialAllWear"):Get(ArrayIndex).IsLocked, NeedCD)
    end
  end
end
function MainControlBaseUI:DynamicallyCreateBattleFBTipsUI()
  if not slua.isValid(self.DynamicBattleFBTipsWidget) then
    self.DynamicBattleFBTipsWidget = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/UMG/UI_BP/Common/Battle_FBTips_UIBP.Battle_FBTips_UIBP_C", self)
    self.DynamicBattleFBTipsWidget:SetParentWidget(self)
    self.DynamicBattleFBTipsWidget:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_42:AddChild(self.DynamicBattleFBTipsWidget)
    local CanvasPanelSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.DynamicBattleFBTipsWidget)
    CanvasPanelSlot:SetAnchors(FAnchors(0.5, 1.0, 0.5, 1.0))
    CanvasPanelSlot:SetOffsets(FMargin(0.0, 0.0, 0.0, 0.0))
    CanvasPanelSlot:SetAlignment(FVector2D(0.5, 1.0))
    CanvasPanelSlot:SetZOrder(6)
    CanvasPanelSlot:SetAutoSize(true)
    local ActiveDeviceProfileName = Client.GetActiveProfileName()
    if ActiveDeviceProfileName == "IPhoneX" or ActiveDeviceProfileName == "IPhoneXS" or ActiveDeviceProfileName == "IPhoneXSMax" or ActiveDeviceProfileName == "IPhoneXR" then
      self:OnFBTipsIPXAdapt(CanvasPanelSlot)
    else
      CanvasPanelSlot:SetPosition(FVector2D(0.0, -37.0))
    end
    self:BindEventToBattleFBTips()
  end
end
function MainControlBaseUI:CreateHotAirBallonControl()
  if slua.isValid(self.HotAirBallonControl) then
    self:SetHotAirBallonControlVisible(true)
    return self.HotAirBallonControl
  end
  self.HotAirBallonControl = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/Mod/EvoBase/BluePrints/UI/Ingame_HotAirBalloonControl_UIBP.Ingame_HotAirBalloonControl_UIBP_C", self)
  if not slua.isValid(self.HotAirBallonControl) then
    print(bWriteLog and "MainControlBaseUI:CreateHotAirBallonControl - Create widget failed")
    return
  end
  self.HotAirBallonControl:SetParentWidget(self)
  self.HotAirBallonControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_42:AddChild(self.HotAirBallonControl)
  self.HotAirBallonControl:UpdateObservationAreaUI()
  local CanvasPanelSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.HotAirBallonControl)
  CanvasPanelSlot:SetAnchors(FAnchors(0, 0, 1, 1))
  CanvasPanelSlot:SetOffsets(FMargin(0, 0, 0, 0))
  CanvasPanelSlot:SetZOrder(10)
  CanvasPanelSlot:SetAutoSize(true)
  print(bWriteLog and "MainControlBaseUI:CreateHotAirBallonControl - Widget created and attached")
  return self.HotAirBallonControl
end
function MainControlBaseUI:SetHotAirBallonControlVisible(IsVisible)
  if slua.isValid(self.HotAirBallonControl) then
    self.HotAirBallonControl:UpdateObservationAreaUI()
    self.HotAirBallonControl:SetWidgetVisibility(IsVisible and ESlateVisibility.SelfHitTestInvisible or ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:AddModeUI(ModeUI)
  self.TmodePanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.TmodePanel.Slot:SetAnchors(FAnchors(0.0, 0.0, 1.0, 1.0))
  local ModeUISlot = self.TmodePanel:AddChildToCanvas(ModeUI)
  ModeUISlot:SetAnchors(FAnchors(0.0, 0.0, 1.0, 1.0))
  ModeUISlot:SetOffsets(FMargin(0.0, 0.0, 0.0, 0.0))
end
function MainControlBaseUI:ShowOrHideQuickExpressionRing(IsShow)
  if IsShow then
    self:ShowExpressionRing()
  else
    self:HideExpressionRing()
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    self.bLowDevice = GameInstance:IsIOSOneGigabyteDevice()
    if STExtraGameInstance then
      self:DestroyExpressionRing()
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, false)
end
function MainControlBaseUI:DestroyExpressionRing()
  UIManager.CloseUI(UIManager.UI_Config_InGame.QuickExpression)
end
function MainControlBaseUI:InitMap()
  self:CheckAddNewMiniMap()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and not PlayerController:IsObserver() and slua.isValid(PlayerController:GetComponentByClass(import("MapUIMarkManager"))) then
    print(bWriteLog and "ShowBattleUI: Finish setting MapUIMarkComponent")
  end
end
function MainControlBaseUI:OnFBTipsIPXAdapt(CanvasPanelSlot)
  CanvasPanelSlot:SetPosition(FVector2D(0.0, -57.0))
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("UIMsg_AdaptFBTipsWithIPX", 0, "", "")
  end
end
function MainControlBaseUI:InitDelegate()
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, function(_, __, NeedCD)
    self:InitRolewearTab(NeedCD)
  end)
end
function MainControlBaseUI:UpdatePickupList()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and UIManager.UI_Config_InGame.PickUpListPanel then
    if PlayerController.bInItemGenerator then
      if PlayerController.bInItemGenerator or PlayerController.bInTombBoxGenerator then
        local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
        if PickUpListPanel then
          PickUpListPanel:UpdateListData()
        end
      else
        local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
        if PickUpListPanel then
          PickUpListPanel:Collapsed()
          PickUpListPanel:ShowPickupWeaponInfo(false)
        end
      end
    else
      local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
      if PickUpListPanel then
        PickUpListPanel:ResetChecksum()
      end
    end
  end
end
function MainControlBaseUI:HideJoinGameUI()
  self.CanvasPanel_AutoJoinPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:EnterJumpingSetUI()
  self:ShowOrHideFreeCam(true)
  local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
  if not TransparentUIModeSubsystem then
    print(bWriteLog and "MainControlBaseUI:ResetJoystickWidgetRender - TransparentUIModeSubsystem is nil")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local bIsOpen = TransparentUIModeSubsystem:GetIsHideUIFunctionOpen()
  local bIsHidden = TransparentUIModeSubsystem and not TransparentUIModeSubsystem.IsShow
  if bIsOpen and bIsHidden then
    PlayerController:SetVirtualJoystickWidgetRender(EWidgetVisible.ForceNotVisible)
  else
    PlayerController:SetVirtualJoystickWidgetRender(EWidgetVisible.Default)
  end
end
function MainControlBaseUI:RemindQuickChatBtn(_, __, bIsShowRedPoint)
  print(bWriteLog and "MainControlBaseUI:RemindQuickChatBtn", bIsShowRedPoint)
  if not self.QuickMenu:IsShow() then
    self.Image_Sigh_yellow:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.Image_ChatBG:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    if bIsShowRedPoint then
      self.Image_hot:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function MainControlBaseUI:UIInGameEvent_HideQuickChatMenu()
  self:HideQuickChatMenu()
end
function MainControlBaseUI:ShowOrHideFreeCam(IsShow)
  if IsShow then
    self.NewFreeCameraBtn:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    self.NewFreeCameraBtn:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:UIMsg_ShowEntireMapUI()
  self:TriggerEntireMap()
end
function MainControlBaseUI:IsShowHit()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    local IsUse = self:IsUseNewHitEffect()
    return not IsUse and not GameState.bForbitHurtEffect
  end
end
function MainControlBaseUI:ShowDeathMatchUI()
  self.CanvasPanelSurviveKill:SetWidgetVisibility(ESlateVisibility.Collapsed)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.HideNavigator)
  self:HideJoinGameUI()
  self.NavigatorIsShow = false
end
function MainControlBaseUI:InitTraining()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    if GameState.bIsTrainingMode then
      self.CanvasPanelSurviveKill:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.TrainingCourse:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      if GameState.GameModeType == EGameModeType.ETypicalGameMode then
        self.TrainingCourse:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
      self.UpdateTrainingTimer = self:AddGameTimer(0.5, true, function()
        self:UpdateTraining()
      end)
    else
      if self.IsNeedSurviveKillPanel then
        self.CanvasPanelSurviveKill:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      end
      self.TrainingCourse:SetWidgetVisibility(ESlateVisibility.Collapsed)
      if GameState.GameModeType == EGameModeType.EDeathMatchGameMode then
        self.CanvasPanelSurviveKill:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    end
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and (PlayerController:IsObserver() or PlayerController:IsDemoPlayGlobalObserver()) then
      self.CanvasPanelSurviveKill:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.TrainingCourse:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
end
function MainControlBaseUI:UpdateTraining()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.EndStateTime then
    local Time = TimeUtil.GetTimeLengthStr(GameState.EndStateTime - math.modf(GameState:GetServerWorldTimeSeconds()), true)
    self.TextBlock_6:SetText(Time)
  end
end
function MainControlBaseUI:UIMSG_GameModeDisplayNameChanged()
  local sModeName = self:GetChangedModelName()
  print(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged", sModeName)
  if sModeName ~= "" then
    self.CanvasPanel_Ring:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_ModeName:SetText(sModeName)
  else
    self.CanvasPanel_Ring:SetWidgetVisibility(ESlateVisibility.Collapsed)
    log_warning(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged sModeName is empty")
  end
end
function MainControlBaseUI:GetChangedModelName()
  local sRet = ""
  local MapRankModeConfig = GamePlayTools.GetCurrentConfig("MapRankModeConfig")
  if not MapRankModeConfig then
    print(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged MapRankModeConfig is nil")
    return sRet
  end
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if not slua.isValid(uGameInstance) then
    print(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged uGameInstance is invalid")
    return sRet
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameModeDisplayName then
    local kismet_string_library = require("common.kismet_string_library")
    if kismet_string_library.Len(GameState.GameModeDisplayName) > 0 then
      sRet = UIUtil.GetLocalizationString(GameState.GameModeDisplayName)
    end
  end
  local MapName = GameMainConfig.GetMapNameInternal()
  if MapName and MapName ~= "" then
    if sRet and sRet ~= "" then
      sRet = sRet .. "-"
    end
    sRet = sRet .. MapName
  end
  local MainModeID = uGameInstance:GetMainModeID()
  local bIsPeakGame = MainModeID == 11201
  local SubModeID = uGameInstance:GetModeID()
  local BattleType = slua.isValid(GameState) and GameState.GetBattleType and GameState:GetBattleType() or 0
  local TableUtil = require("common.table_util")
  local uController = GameplayData.GetPlayerController()
  local bIsRoomMode = slua.isValid(uController) and uController:IsRoomMode()
  print(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged bIsRoomMode", bIsRoomMode, SubModeID, BattleType, bIsPeakGame)
  if not bIsRoomMode and not bIsPeakGame then
    if TableUtil.Find(MapRankModeConfig.MatchMainModeList, BattleType) ~= -1 then
      sRet = LocUtil.LocalizeResFormat(73201, sRet)
    elseif TableUtil.Find(MapRankModeConfig.RankMainModeList, BattleType) ~= -1 then
      local PlayerState = GameplayData.GetPlayerState()
      local bIsPromotion = slua.isValid(PlayerState) and PlayerState.PromotionLayer and 0 < PlayerState.PromotionLayer
      print(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged RankModeList SubModeID", SubModeID, bIsPromotion)
      print(bWriteLog and "MainControlBaseUI:UIMSG_GameModeDisplayNameChanged bIsPromotion", bIsPromotion, slua.isValid(PlayerState) and PlayerState.PromotionLayer or -11)
      if bIsPromotion then
        sRet = LocUtil.LocalizeResFormat(85469, sRet)
      else
        sRet = LocUtil.LocalizeResFormat(73202, sRet)
      end
    end
  end
  return sRet
end
function MainControlBaseUI:UpdateVoiceCheckByGameState()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    if GameState.bForbitAudioVisual then
      if slua.isValid(self.VoiceCheckPanel) then
        self.VoiceCheckPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    elseif slua.isValid(self.VoiceCheckPanel) then
      self.VoiceCheckPanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function MainControlBaseUI:SetEmoteControlVisibility(Panel, IsVisible)
  if slua.isValid(Panel) then
    if IsVisible then
      Panel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    else
      Panel:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self:ShowOrHideQuickExpressionRing(false)
    end
  end
end
function MainControlBaseUI:DidBroadcastDarkMost()
  self:DisplayGeneralTip(10005, "", "")
end
function MainControlBaseUI:DidBroadcastDawnBegin()
  self:DisplayGeneralTip(10006, "", "")
end
function MainControlBaseUI:OpenSettingPanel()
  audio_util.PlayAudio(sound_config.set)
  slua_GameFrontendHUD:CallGlobalScriptFunction("ShowOrHideSetting")
end
function MainControlBaseUI:CheckIsNeedOpenGameJoy()
  local bIsOpen = true
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController:IsSpectator() then
    bIsOpen = false
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.CorpsInfoArray ~= nil then
    bIsOpen = false
  end
  return bIsOpen
end
function MainControlBaseUI:IsObserver()
  local PlayerController = GameplayData.GetPlayerController()
  return slua.isValid(PlayerController) and PlayerController:IsObserver()
end
function MainControlBaseUI:DisplayInfectAreaWarning()
  self:DisplayGeneralTip(10024, "", "")
end
function MainControlBaseUI:DidBroadcastShowZombieWarningTips()
  self:DisplayGeneralTip(10007, "", "")
end
function MainControlBaseUI:DidBroadcastShowPVETipsEvent1()
  self:DisplayGeneralTip(10008, "", "")
end
function MainControlBaseUI:DidBroadcastShowPVETipsEvent2()
  self:DisplayGeneralTip(10009, "", "")
end
function MainControlBaseUI:DidBroadcastShowPVETipsEvent3()
  self:DisplayGeneralTip(10007, "", "")
end
function MainControlBaseUI:DidBroadcastShowPVETipsEvent4()
  self:DisplayGeneralTip(10010, "", "")
end
function MainControlBaseUI:DidBroadcastShowPVETipsEvent5()
  self:DisplayGeneralTip(10011, "", "")
end
function MainControlBaseUI:DidBroadcastShowPVETipsEvent6()
  self:DisplayGeneralTip(10012, "", "")
end
function MainControlBaseUI:DisplayBossWarning()
  self:DisplayGeneralTip(10023, "", "")
end
function MainControlBaseUI:DidBroadcastShowPoisonFogTipsEvent()
  self:DisplayGeneralTip(10013, "", "")
end
function MainControlBaseUI:SetHitBloodImg()
  local PublishRegion = Client.GetPublishRegion()
  local asset_util = require("common.asset_util")
  if PublishRegion == "VNG" then
    local PaperSprite = asset_util.GetAssetSync("/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_shoujifangxiang_png.ZD_shoujifangxiang_png")
    if slua.isValid(PaperSprite) then
      self.ImageHitBlood:SetBrush(PaperSpriteBlueprintLibrary.MakeBrushFromSprite(PaperSprite, 0, 0))
      local ColorBlindnessMgr = slua_GameFrontendHUD:GetColorBlindnessMgr()
      if slua.isValid(ColorBlindnessMgr) then
        ColorBlindnessMgr:AddImage(self.ImageHitBlood, FLinearColor(1.0, 1.0, 1.0, 1.0), 6)
      end
    end
  else
    local PaperSprite = asset_util.GetAssetSync("/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_shoujifangxiang_png.ZD_shoujifangxiang_png")
    if slua.isValid(PaperSprite) then
      self.ImageHitBlood:SetBrush(PaperSpriteBlueprintLibrary.MakeBrushFromSprite(PaperSprite, 0, 0))
      local ColorBlindnessMgr_1 = slua_GameFrontendHUD:GetColorBlindnessMgr()
      if slua.isValid(ColorBlindnessMgr_1) then
        local PlayerController = GameplayData.GetPlayerController()
        if slua.isValid(PlayerController) then
          if PlayerController:IsObserver() and Client.GetCurrentLanguage() == "zh" then
            self.ImageHitBlood:SetColorAndOpacity(FLinearColor(0.0185, 0.679542, 0.287441, 1.0))
          else
            ColorBlindnessMgr_1:AddImage(self.ImageHitBlood, FLinearColor(1.0, 1.0, 1.0, 1.0), 6)
          end
        end
      end
    end
  end
end
function MainControlBaseUI:FogComing1()
  self:DisplayGeneralTip(10014, "", "")
end
function MainControlBaseUI:FogComing2()
  self:DisplayGeneralTip(10015, "", "")
end
function MainControlBaseUI:FogEnd1()
  self:DisplayGeneralTip(10016, "", "")
end
function MainControlBaseUI:LevelStart()
  self:DisplayGeneralTip(10017, "", "")
end
function MainControlBaseUI:NightCome()
  self:DisplayGeneralTip(10018, "", "")
end
function MainControlBaseUI:Victory1()
  self:DisplayGeneralTip(10019, "", "")
end
function MainControlBaseUI:Victory2()
  self:DisplayGeneralTip(10020, "", "")
end
function MainControlBaseUI:ShowQuickMsgInfo(NeekShow)
  local MergeExecutionPath0 = function()
    if NeekShow then
      self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Visible)
      self.Button_Border_close:SetWidgetVisibility(ESlateVisibility.Visible)
      if self.IsCurTurnplateTipsShow then
        self.TurnplateNewbieTips:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      else
        self.TurnplateNewbieTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    else
      self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.Button_Border_close:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.IsCurTurnplateTipsShow = self.TurnplateNewbieTips:IsVisible()
      self.TurnplateNewbieTips:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self:HideTurnplateUIBP()
    end
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local GameModeType = self:GetGameModeType()
    if not PlayerController:IsFriendObserver() and not PlayerController:IsObserver() and not PlayerController:IsDemoPlaySpectator() and GameModeType ~= EGameModeType.ESocialIsland and GameModeType ~= EGameModeType.EBigEventGameMode then
      MergeExecutionPath0()
    end
  else
    MergeExecutionPath0()
  end
end
function MainControlBaseUI:CountDownToCloseBuffList(deltatime)
  local ReturnValue_1 = deltatime + self.CurBuffListCloseCountTime
  if 10.0 <= ReturnValue_1 then
    self.CurBuffListCloseCountTime = 0.0
    return true
  else
    self.CurBuffListCloseCountTime = ReturnValue_1
    return false
  end
end
function MainControlBaseUI:HideBuffList()
  if slua.isValid(self.DynamicBattleFBTipsWidget) then
    self.DynamicBattleFBTipsWidget:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.BuffListCloseStartCountDown = false
  end
end
function MainControlBaseUI:SetMinMapTriggerEnable(IsEnable2)
  if IsEnable2 then
    self.MultiButton_EntireMapTrigger:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    self.MultiButton_EntireMapTrigger:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:IsEvoGroundGameMode()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    if GameState.GameModeType == EGameModeType.EDeathMatchGameMode or GameState.GameModeType == EGameModeType.EActivityGameMode or GameState.GameModeType == EGameModeType.EHeavyWeaponGameMode or GameState.GameModeType == EGameModeType.EVehicleWar or GameState.GameModeType == EGameModeType.EVehicleWar_CAMP then
      return true
    else
      return false
    end
  else
    return false
  end
end
function MainControlBaseUI:FinishedLoadBattleUI()
  self.bFinishedLoadBattleUI = true
end
function MainControlBaseUI:SetNavigationPanelVisible(IsSHow)
  local MergeExecutionPath0 = function()
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.HideNavigator)
    self.NavigatorIsShow = false
  end
  if IsSHow then
    local bShow = self:ShouldShowNavigator()
    if bShow then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.ShowNavigator)
      self.NavigatorIsShow = true
    else
      MergeExecutionPath0()
    end
  else
    MergeExecutionPath0()
  end
end
function MainControlBaseUI:HideForReplayUI()
  print(bWriteLog and "Hide for Replay UI")
  UIManager.CloseUI(UIManager.UI_Config_InGame.MicrophoneButton)
  self.InvalidationBox_GM:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:OnShowDarkNight()
  print(bWriteLog and "MainControlBaseUI:OnShowDarkNight")
  local Item = self:BackpackGetArmorSlotItem()
  if slua.isValid(Item) then
    Item:RefreshVisionSwitch()
  end
end
function MainControlBaseUI:HideBattleVoiceUI()
  print(bWriteLog and "MainControlBaseUI:HideBattleVoiceUI")
  UIManager.CloseUI(UIManager.UI_Config_InGame.MicrophoneButton)
  local SpeakerUI = UIManager.GetUI(UIManager.UI_Config_InGame.SpeakerUI)
  if SpeakerUI then
    SpeakerUI:SetSpeakerUIVisible(false)
  end
end
function MainControlBaseUI:ShowBattleVoiceUI()
  print(bWriteLog and "MainControlBaseUI:ShowBattleVoiceUI")
  UIManager.ShowUI(UIManager.UI_Config_InGame.MicrophoneButton)
  local SpeakerUI = UIManager.GetUI(UIManager.UI_Config_InGame.SpeakerUI)
  if SpeakerUI then
    SpeakerUI:SetSpeakerUIVisible(true)
  end
end
function MainControlBaseUI:UIMsg_ChangeShowTipSwitch()
end
function MainControlBaseUI:UIMsg_SwitchShowSpecialUI()
  self:ShowQuickMsgInfo(false)
  if self.TextBlock_BID:IsVisible() then
    self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.TextBlock_BID:SetWidgetVisibility(ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.HideNavigator)
    self.NavigatorIsShow = false
  else
    self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_BID:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    local bShow = self:ShouldShowNavigator()
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, bShow)
    self.NavigatorIsShow = bShow
  end
end
function MainControlBaseUI:DisplayGeneralTip(MsgID, Param1, Param2)
  IngameTipsTools.BattleGeneralTip(MsgID, Param1, Param2)
end
function MainControlBaseUI:GetGameModeType()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameModeType ~= nil then
    return GameState.GameModeType
  else
    return EGameModeType.EUnknownGameMode
  end
end
function MainControlBaseUI:ShouldShowNavigator()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    if GameState.GameModeType == EGameModeType.EDeathMatchGameMode then
      return false
    elseif GameState.GameModeConfigType == EGameModeType.ETraining then
      return true
    else
      return true
    end
  end
end
function MainControlBaseUI:CheckShowTaskButton()
  local ShouldShowTaskBtn = false
  ShouldShowTaskBtn = false
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController:IsDemoPlaySpectator() then
  else
    local GameState = GameplayData.GetGameState()
    if slua.isValid(GameState) then
      if GameState.GameModeSubType == EGameModeSubType.EAceMode then
        ShouldShowTaskBtn = true
      elseif GameState.GameModeConfigSubType == EGameModeSubType.EAceMode then
        ShouldShowTaskBtn = true
      end
    end
  end
  if ShouldShowTaskBtn and not slua.isValid(self.BigEvent_Btn) then
    local ReturnValue_2 = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/Mod/BigEvent/Blueprints/UIBP/BigEvent_Btn_UIBP.BigEvent_Btn_UIBP_C", self)
    if slua.isValid(ReturnValue_2) then
      self.BigEvent_Btn = ReturnValue_2
      self.CanvasPanel_DummyRoot:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanel_DummyRoot:AddChild(self.BigEvent_Btn)
      self.BigEvent_Btn:InitWidget(true)
      print(bWriteLog and "TaskInfo-- UI CheckShowTaskButton")
    end
  end
end
function MainControlBaseUI:UIMsg_ShowFreeCamera()
  print(bWriteLog and "Exec UIMsg Show Free Camera")
  self.CanvasPanel_FreeCamera:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
end
function MainControlBaseUI:UIMsg_HideFreeCamera()
  print(bWriteLog and "Exec UIMsg Hide Free Camera")
  self.CanvasPanel_FreeCamera:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:ShowSpeakerAndMicFx()
  if Seconds >= 180 then
    return 0
  elseif Seconds >= 30 then
    return 1
  else
    return 2
  end
end
function MainControlBaseUI:IsBlueCirclePreWarningShouldShow(Time)
  if Time <= 0 then
    return false
  end
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) then
    return GameState.bIsShowCircleWarningTips
  else
    return true
  end
end
function MainControlBaseUI:DisplayCharStateWhenOperateUAV()
  EventSystem:postEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_ON_OPERATE_UAV)
end
function MainControlBaseUI:IsWinOBCN()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local IsObserver = PlayerController:IsObserver()
    local CurrentLanguage = Client.GetCurrentLanguage()
    print(bWriteLog and "MainControlBaseUI:iswinobcn" .. tostring(IsObserver) .. CurrentLanguage)
    return IsObserver and CurrentLanguage == "zh"
  else
    return false
  end
end
function MainControlBaseUI:FormatSecondsToString(TotalSeconds)
  local Minute = TotalSeconds // 60
  local Second = TotalSeconds % 60
  local MinuteText = ""
  local SecondText = ""
  if 0 < Minute then
    MinuteText = LocUtil.LocalizeResFormat(10002, Minute)
  end
  if 0 < Second then
    SecondText = LocUtil.LocalizeResFormat(10003, Second)
  end
  if Minute <= 0 then
    return SecondText
  end
  if Second <= 0 then
    return MinuteText
  end
  return MinuteText .. " " .. SecondText
end
function MainControlBaseUI:ShowOrHideBackpack_Border(bShow)
  local BackpackClothingEntryUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackClothingEntryUI)
  if BackpackClothingEntryUI then
    BackpackClothingEntryUI:ShowOrHideBackpack_Border(bShow)
  end
end
function MainControlBaseUI:ShowSpectatingUI()
  self.CanvasPanel_FreeCamera:SetWidgetVisibility(ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController:IsFriendObserver() then
    self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:EnterObserverStatus()
  self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanelSurviveKill:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:LeaveSpectatingStatus()
  print(bWriteLog and "MainControlBaseUI:LeaveSpectatingStatus")
  self.CanvasPanel_FreeCamera:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
end
function MainControlBaseUI:ShowAllUIForDelayResult()
  self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Hidden)
  self.InvalidationBox_0:SetWidgetVisibility(ESlateVisibility.Hidden)
end
function MainControlBaseUI:OnEnterCompletePlayback()
  self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_FreeCamera:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:OnEnterWonderfulPlayback()
  self.CanvasPanel_ZTK:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_FreeCamera:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.ChatAndChatPanelCanvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:UIMsg_HideSomeUIForMiniGameMachine()
  if not self.HasOpenMiniGameOnce then
    self.HasOpenMiniGameOnce = true
    local CachedMiniMapLayout = self.CanvasPanel_MiniMapAndSetting.Slot:GetLayout()
    self.CanvasPanel_0:AddChildToCanvas(self.CanvasPanel_MiniMapAndSetting)
    self.CanvasPanel_MiniMapAndSetting.Slot:SetLayout(CachedMiniMapLayout)
    self.CanvasPanel_MiniMapAndSetting.Slot:SetZOrder(-1)
  end
  self.CanvasPanel_42:SetWidgetVisibility(ESlateVisibility.Collapsed)
end
function MainControlBaseUI:UIMsg_ShowSomeUIAfterMiniGameMachine()
  self.CanvasPanel_42:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
end
function MainControlBaseUI:HandleOnGameModeStateChange()
  self:CheckShowGameGuideButton()
end
function MainControlBaseUI:CheckShowGameGuideButton()
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  local GameGuideConfig = GameGuideUIUtil.GetGameGuideConfig()
  self:ChangeGuideBtnShow(false)
  if not GameGuideConfig then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.GetGameModeState == nil then
    return
  end
  if GameState:GetGameModeState() == "ReadyState" then
    self:ChangeGuideBtnShow(true)
  end
end
function MainControlBaseUI:StopPickTipGuide()
  print(bWriteLog and "MainControlBaseUI:StopPickTipGuide")
  local LoopAnimation = self[PickTipsGuideConfig.TipsLoopAnim]
  self.bGuideLoopAnim = false
  self:ChangeGuideBtnShow(false, 2)
  if self.GuideLoopTimer then
    self:RemoveGameTimer(self.GuideLoopTimer)
    self.GuideLoopTimer = nil
  end
  if self:IsAnimationPlaying(LoopAnimation) then
    self:StopAnimation(LoopAnimation)
  end
end
function MainControlBaseUI:OnTipsAnimationFinished()
  if not self.bGuideLoopAnim then
    return
  end
  local LoopAnimation = self[PickTipsGuideConfig.TipsLoopAnim]
  local Duration = PickTipsGuideConfig.LoopDuration
  self:PlayUserWidgetAnimation(LoopAnimation, 0, Duration, 0, 1)
end
function MainControlBaseUI:StartPickTipGuide(nItemID)
  print(bWriteLog and "MainControlBaseUI:StartPickTipGuide")
  self.bGuideLoopAnim = true
  self.nGuideItemID = nItemID
  self:ChangeGuideBtnShow(true, 2)
  if self.GuideLoopTimer then
    self:RemoveGameTimer(self.GuideLoopTimer)
    self.GuideLoopTimer = nil
  end
  self.GuideLoopTimer = self:AddGameTimer(60, false, function()
    self:StopPickTipGuide()
  end)
  if self.CanvasPanel_MiniMapAndSetting.Slot then
    local CurPosition = self.CanvasPanel_MiniMapAndSetting.Slot:GetPosition()
    local CurX = CurPosition.X
    local CurY = CurPosition.Y
    if CurX < PickTipsGuideConfig.MinX or CurX > PickTipsGuideConfig.MaxX or CurY < PickTipsGuideConfig.MinY or CurY > PickTipsGuideConfig.MaxY then
      print(bWriteLog and "MainControlBaseUI:StartPickTipGuide: not in range")
      self:OnTipsAnimationFinished()
      return
    end
  end
  local FlyAnimation = self[PickTipsGuideConfig.TipsFlyAnim]
  self:PlayUserWidgetAnimation(FlyAnimation, 0, 1, 0, 1)
end
function MainControlBaseUI:OnClicked_Button_GameGuide()
  self:ShowEntireMapWindow()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI then
    local TlogConfig = require("GameLua.Mod.BaseMod.Client.Config.TlogConfig")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) and TlogConfig then
      uPlayerState:RPC_ServerAddGeneralCount(TlogConfig.NewbieGuideImageTxt2, 1, false)
    end
    EntireMapUI:SelectGameGuide(true)
    if self.bGuideLoopAnim and self.nGuideItemID then
      local GameGuideUIMain = UIManager.GetUI(UIManager.UI_Config_InGame.GameGuideUIMain)
      if GameGuideUIMain then
        GameGuideUIMain:ShowSelectItem(self.nGuideItemID)
      end
      EventSystem:postEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_ONGAMEGUIDE_TRIGGER, self.nGuideItemID)
    end
    self:StopPickTipGuide()
  end
end
function MainControlBaseUI:StartIntroAnimation()
  self:PlayUserWidgetAnimation(self.Anim_Collect, 0, 1, 0, 1)
  self.ShowThemeGunIntro = true
end
function MainControlBaseUI:ChangeMapBtnShow(_, _, bIsShow)
  if bIsShow then
    self:ChangeGuideBtnShow(true)
  else
    self:ChangeGuideBtnShow(false)
  end
end
function MainControlBaseUI:ChangeGuideBtnShow(bIsShow, nIndex)
  print(bWriteLog and "MainControlBaseUI:ChangeGuideBtnShow" .. tostring(bIsShow) .. tostring(nIndex))
  if not self.GuideBtnShowMap then
    self.GuideBtnShowMap = {}
  end
  nIndex = nIndex or 1
  if 99 < nIndex then
    self.GuideBtnShowMap = {}
  end
  local bEndShow = false
  self.GuideBtnShowMap[nIndex] = bIsShow
  for i, v in ipairs(self.GuideBtnShowMap) do
    if v then
      bEndShow = true
      break
    end
  end
  if bEndShow then
    self.Button_GameGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.Button_GameGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function MainControlBaseUI:CheckDisableInvalidationBoxes()
  if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableInvalidationBox", false) == true then
    log_shipping_client("MainControlBaseUI:CheckDisableInvalidationBoxes Disable Invalidation Boxes")
    if self.InvalidationBox_9 then
      self.InvalidationBox_9:SetCanCache(false)
    end
    if self.InvalidationBox_0 then
      self.InvalidationBox_0:SetCanCache(false)
    end
    if self.InvalidationBox_3 then
      self.InvalidationBox_3:SetCanCache(false)
    end
    if self.STInvalidationBox_1 then
      self.STInvalidationBox_1:SetCanCache(false)
    end
    if self.InvalidationBox_5 then
      self.InvalidationBox_5:SetCanCache(false)
    end
  end
end
local class = require("class")
local UILuaUserWidget = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
local CMainControlBaseUI = class(UILuaUserWidget, nil, MainControlBaseUI)
return CMainControlBaseUI