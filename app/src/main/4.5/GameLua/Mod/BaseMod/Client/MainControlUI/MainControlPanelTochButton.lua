local MainControlPanelTochButton = {}
local ESlateVisibility = import("ESlateVisibility")
local EGameModeType = import("EGameModeType")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
local CustomType = require("client.logic.setting.CustomType")
function MainControlPanelTochButton:ctor()
  self.bNeedDelayRegistEvents = true
end
function MainControlPanelTochButton:Construct()
  MainControlPanelTochButton.__super.Construct(self)
  self.CurrentLayoutName = nil
  self.CurrentRecoverLayout = {}
  self.CacheLayoutIndex = nil
  self.CacheUIElemSaveGame = nil
  self.bStartResultCount = false
  self:ClearClassWidgetTreeFowSaveMemory()
  InGameUITools.SetMainControlPanelTochButton(self.Object)
end
function MainControlPanelTochButton:Destruct()
  MainControlPanelTochButton.__super.Destruct(self)
  InGameUITools.SetMainControlPanelTochButton(nil)
end
function MainControlPanelTochButton:RegistEvents()
  self:AddUIMessageEvent("UIMsgEnterVehicleCompleted", self.OnEnterVehicleCompleted, self)
  self:AddUIMessageEvent("UIMsgExitVehicleCompleted", self.OnExitVehicleCompleted, self)
  self:AddUIMessageEvent("UIMsg_CloseMap", self.UIMsg_CloseMap, self)
  self:AddUIMessageEvent("UIMsg_MakePictureTrue", self.UIMsg_MakePictureTrue, self)
  self:AddUIMessageEvent("UIMsg_MakePictureFalse", self.UIMsg_MakePictureFalse, self)
  self:AddUIMessageEvent("UIMsg_ShowOrHideSelf", self.UIMsg_ShowOrHideSelf, self)
  self:AddUIMessageEvent("UIMsg_WeaponUnequipAttachment", self.UIMsg_WeaponUnequipAttachment, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.UIMsg_RespawnSetUI, self)
  self:AddUIMessageEvent("UIMsg_FightingReadyGoToFlying", self.UIMsg_FightingReadyGoToFlying, self)
  self:AddUIMessageEvent("UIMsg_ForceHideMap", self.UIMsg_ForceHideMap, self)
  self:AddUIMessageEvent("UIMsg_ShowIngameMainUI", self.UIMsg_ShowIngameMainUI, self)
  self:AddUIMessageEvent("UIMsg_HideIngameMainUI", self.UIMsg_HideIngameMainUI, self)
  self:AddUIMessageEvent("UIMsg_ActivitySeatsShowUI", self.UIMsg_ActivitySeatsShowUI, self)
  self:AddUIMessageEvent("UIMsg_ActivitySeatsHideUI", self.UIMsg_ActivitySeatsHideUI, self)
  self:AddUIMessageEvent("UIMsg_HideWateringBtnPanel", self.UIMsg_HideWateringBtnPanel, self)
  self:AddUIMessageEvent("UIMsg_ShowWateringBtnPanel", self.UIMsg_ShowWateringBtnPanel, self)
  self:AddUIMessageEvent("PrintWidgetNum", self.PrintWidgetNum, self)
  self:AddUIMessageEvent("EnterSpectatingStatus", self.EnterSpectatingStatus, self)
  self:AddUIMessageEvent("EnterObserverStatus", self.EnterObserverStatus, self)
  self:AddUIMessageEvent("MainControlPanel_ShowWinnerTimePanel", self.MainControlPanel_ShowWinnerTimePanel, self)
  self:AddUIMessageEvent("MainControlPanel_HideWinnerTimePanel", self.MainControlPanel_HideWinnerTimePanel, self)
  self:AddUIMessageEvent("UIMsg_ShowSomeUIAfterMiniGameMachine", self.UIMsg_ShowSomeUIAfterMiniGameMachine, self)
  self:AddUIMessageEvent("ReadyToSendFinishedGuideToServer", self.ReadyToSendFinishedGuideToServer, self)
  self:AddUIMessageEvent("ReadyToRequestNewbieGuide", self.ReadyToRetriveBeginnerFinishedGuide, self)
  self:AddUIMessageEvent("UIMsg_RefreshSightVision", self.UIMsg_RefreshSightVision, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_REVIVAL, self.OnQuitSpectating, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_START, self.OnStartResultCount, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END, self.OnEndResultCount, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SCREENPADDING_CHANGED, self.SetAdaptationDataToController, self)
  self:SetAdaptationDataToController()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  local UserInputCache = import("UserInputCache")
  UserInputCache.ResetReportComplaintNames()
  self:InitSpecialUI()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", self.UIMSG_PlayerControllerStateChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "NewbieShowCurGuide", self.ShowOrHideNewbieGuide, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.ShowAirborneUI, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", self.HandleOnPlayerControllerStateChanged, self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.VehicleControlLayer)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.BaseLayer)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.ShootingLayer)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.CanvasPanel_IPX)
  self:CheckDisableInvalidationBoxes()
end
function MainControlPanelTochButton:ResetUIStateAfterRespawn()
end
function MainControlPanelTochButton:ReadyToRetriveBeginnerFinishedGuide()
  BeginnerGuideSystem.send_refresher_info_req()
end
function MainControlPanelTochButton:NewbieGuide_ShowCurNewbieGuide()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and slua.isValid(PlayerController.NewbieComponent) then
    self:HandlNewbieGuideUpdate(PlayerController.NewbieComponent.CurTipsID, true)
  end
end
function MainControlPanelTochButton:NewbieGuide_HideCurNewbieGuide()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and slua.isValid(PlayerController.NewbieComponent) then
    self:HandlNewbieGuideUpdate(PlayerController.NewbieComponent.CurTipsID, false)
  end
end
function MainControlPanelTochButton:ShowOrHideNewbieGuide(TipsID, bShow)
  self:HandlNewbieGuideUpdate(TipsID, bShow)
end
function MainControlPanelTochButton:HandlNewbieGuideUpdate(GuideID, bIsShow)
  self.Super:HandlNewbieGuideUpdate(GuideID, bIsShow)
end
function MainControlPanelTochButton:NewBieGuide_FinishedCurGuide()
end
function MainControlPanelTochButton:ReadyToSendFinishedGuideToServer()
  local ScriptHelperClient = import("ScriptHelperClient")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.NewbieComponent then
    ScriptHelperClient.SendRecordFinishedGuideReq(slua_GameFrontendHUD, tostring(PlayerController.NewbieComponent.CurTipsID))
  end
end
function MainControlPanelTochButton:DumpIPXState(tag)
  if not bWriteLog then
    return
  end
  local utility = require("common.utility")
  xpcall(function()
    local ipx = self.CanvasPanel_IPX
    local ok, info = pcall(function()
      local baseUI = InGameUITools.GetMainControlBaseUI()
      local baseUIValid = slua.isValid(baseUI)
      local baseUIVis = "nil"
      if baseUIValid and baseUI.GetVisibility then
        baseUIVis = tostring(baseUI:GetVisibility())
      end
      return string.format("MainControlPanelTochButton:DumpIPXState[%s] " .. "[MCP] selfValid=%s selfAddr=%s selfVis=%s " .. "[BaseUI] baseUIValid=%s baseUIAddr=%s baseUIVis=%s " .. "[IPX] ipxValid=%s ipxAddr=%s ipxVis=%s", tostring(tag), tostring(slua.isValid(self)), tostring(self), tostring(slua.isValid(self) and self.GetVisibility and self:GetVisibility()), tostring(baseUIValid), tostring(baseUI), baseUIVis, tostring(slua.isValid(ipx)), tostring(ipx), tostring(slua.isValid(ipx) and ipx:GetVisibility()))
    end)
    print(ok and info or "MainControlPanelTochButton:DumpIPXState DumpIPXState error: " .. tostring(info))
  end, utility.ErrorMessageHandler)
end
function MainControlPanelTochButton:EnterSpectatingStatus()
  self:ShowSpectatingUI()
end
function MainControlPanelTochButton:ShowSpectatingUI()
  print(bWriteLog and "MainControlPanelTochButton:ShowSpectatingUI")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI)
  self:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:ShowHeavyWeaponModePanel(true)
  self:ShowPVEVPModePanel()
  self.CanvasPanel_IPX:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:DumpIPXState("ShowSpectatingUI_End")
  self:AddGameTimer(1, false, function()
    self:DumpIPXState("ShowSpectatingUI_End_1s")
  end)
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameModeType ~= nil and GameState.GameModeType == EGameModeType.EActivityGameMode then
    self:ShowWalkingDeathModePanel(false)
  end
end
function MainControlPanelTochButton:EnterObserverStatus()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:EnterObserverStatus()
  end
end
function MainControlPanelTochButton:LeaveSpectatingStatus()
  print(bWriteLog and "MainControlPanelTochButton:LeaveSpectatingStatus")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_LEAVE_SPECTATING_STATUS)
  self:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_IPX:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:LeaveSpectatingStatus()
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HAS_LEAVED_SPECTATING_STATUS)
end
function MainControlPanelTochButton:PlayerInfo_SpectatorChangeUpdateEnergy()
end
function MainControlPanelTochButton:PlayerInfo_UpdateEnergy()
end
function MainControlPanelTochButton:ShowAirborneUI()
  print(bWriteLog and "MainControlPanelTochButton:ShowAirborneUI")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_AIRBORNE_UI)
  self.OperationState = UEnums.UIOperation.Parachute
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:ShowQuickMsgInfo(true)
  end
  self:SwitchOperationUI()
end
function MainControlPanelTochButton:ShowFreeFallUI()
end
function MainControlPanelTochButton:MainControlPanel_ShowWinnerTimePanel()
  print(bWriteLog and "MainControlPanel_ShowWinnerTimePanel")
  self:Show()
  self.CanvasPanel_IPX:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.ED_OnShowWinnerTime:BroadCast()
  self:ShowWalkingDeathModePanel(true)
  self:ShowHeavyWeaponModePanel(true)
  local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.ShowWinnerTime, true)
end
function MainControlPanelTochButton:MainControlPanel_HideWinnerTimePanel()
  print(bWriteLog and "MainControlPanelHideAllUI! Hide cross hair")
  self:Hide()
  self.CanvasPanel_IPX:SetWidgetVisibility(ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:ShowTouchInterface(false)
    self:ShowWalkingDeathModePanel(false)
    self:ShowHeavyWeaponModePanel(false)
  end
end
function MainControlPanelTochButton:CheckShowPVEVPGuide()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController:IsSpectator() then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  if GameState.GuideImageName == nil or #GameState.GuideImageName == 0 then
    return
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  ScriptHelperClient.CallIngameFirstTimeTips(slua_GameFrontendHUD, GameState.GuideLuaTableName, GameState.GuideLuaFunctionName)
end
function MainControlPanelTochButton:IsPVEVPMode()
  local GlobalUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
  return GlobalUIFunctionLibrary.IsConfigGameModeType(EGameModeType.EActivityGameMode, slua_GameFrontendHUD)
end
function MainControlPanelTochButton:CheckInitPVEVPModeUI()
  if self:IsPVEVPMode() then
    self:CheckInitPVEVPMainUI()
  end
end
function MainControlPanelTochButton:CheckInitPVEVPMainUI()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local PVPBossComponentClass = import("PVPBossComponent")
  local PVPBossComponent = GameState:GetComponentByClass(PVPBossComponentClass)
  if slua.isValid(PVPBossComponent) then
    self:AddControlEventByControl(PVPBossComponent, "BossBeginFlow", self.ShowBossWarning, self)
  end
end
function MainControlPanelTochButton:HidePVEVPModePanel()
end
function MainControlPanelTochButton:ShowPVEVPModePanel()
end
function MainControlPanelTochButton:ShowWalkingDeathModePanel(bIsShow)
end
function MainControlPanelTochButton:ShowHeavyWeaponModePanel(bIsShow)
  local EGameModeType = import("EGameModeType")
  local GameState = GameplayData.GetGameState()
  if not (slua.isValid(GameState) and GameState.GameModeType) or GameState.GameModeType ~= EGameModeType.EHeavyWeaponGameMode and EGameModeType.ECreativeModeGameMode then
    return
  end
  local FireModeMainPanel = UIManager.GetUI(UIManager.UI_Config_InGame.FireModeMainPanel)
  if not FireModeMainPanel then
    return
  end
  if bIsShow then
    FireModeMainPanel:ShowModeUI()
  else
    FireModeMainPanel:Hide()
  end
end
function MainControlPanelTochButton:DynamicallyCreateOBMapPlayerList()
  if slua.isValid(self.DynamicOBMapPlayerList) then
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  self.DynamicOBMapPlayerList = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/UI/OBUI/OB_MapPlayerList_BP.OB_MapPlayerList_BP_C", slua_GameFrontendHUD)
  self.DynamicOBMapPlayerList:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_IPX:AddChild(self.DynamicOBMapPlayerList)
  local Slot = self.DynamicOBMapPlayerList.Slot
  Slot:SetSize(FVector2D(346.675262, 0.0))
  Slot:SetZOrder(120)
end
function MainControlPanelTochButton:DynamicallyCreateSelfieUI()
  if slua.isValid(self.DynamicSelfieUI) then
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  self.DynamicSelfieUI = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/SelfieUI.SelfieUI_C", slua_GameFrontendHUD)
  self.DynamicSelfieUI:SetParentWidget(self.Object)
  self.DynamicSelfieUI:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.CanvasPanel_IPX:AddChild(self.DynamicSelfieUI)
  self.DynamicSelfieUI.Slot:SetZOrder(100)
end
function MainControlPanelTochButton:UIMsg_UpdateSurfBoardBtnPanel(visible)
  if visible then
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_Surfing")
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_Surfing")
  end
end
function MainControlPanelTochButton:UIMsg_SwitchSurfBoard()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(PlayerCharacter)
  local ItemDefineID = BackpackComponent:GetFirstItemBySubType(506)
  if not ItemDefineID then
    return
  end
  local DefineID = ItemDefineID.DefineID
  if DefineID.TypeSpecificID == 0 then
    return
  end
  local CurrentVehicle = PlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(CurrentVehicle) then
    return
  end
  local SurfBoardCompClass = import("SurfBoardComp")
  local SurfBoardComp = CurrentVehicle:GetComponentByClass(SurfBoardCompClass)
  if slua.isValid(SurfBoardComp) then
    BackpackComponent:ServerEnableItem(DefineID, false)
  else
    local BackpackUtils = import("BackpackUtils")
    local SurfboardHandle = BackpackUtils.CreateBattleItemHandle(DefineID, self.Object, false)
    if slua.isValid(SurfboardHandle) and SurfboardHandle.BackpackComp then
      SurfboardHandle.BackpackComp = BackpackComponent
      if SurfboardHandle:CheckCanEnable() then
        BackpackComponent:ServerEnableItem(DefineID, true)
      else
        local PlayerController = GameplayData.GetPlayerController()
        if slua.isValid(PlayerController) and PlayerController.DisplayGameTipWithMsgID then
          PlayerController:DisplayGameTipWithMsgID(32001)
        end
      end
    end
  end
end
function MainControlPanelTochButton:ShowBtnByState()
end
function MainControlPanelTochButton:ShowCanOpenTips(bIsShowGuide, uGuideText)
  self.Super:ShowCanOpenTips()
  local ParachutingControl = UIManager.GetUI(UIManager.UI_Config_InGame.ParachutingControl)
  if ParachutingControl then
    ParachutingControl:ShowCanOpenTips(bIsShowGuide, uGuideText)
  end
end
function MainControlPanelTochButton:ShowShooterUI()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    if PlayerController:IsSpectator() then
      return
    end
    local CurrentStateType = PlayerController:GetCurrentStateType()
    local EStateType = import("EStateType")
    if CurrentStateType == EStateType.State_InExPlane or CurrentStateType == EStateType.State_Dead then
      return
    end
  end
  self:ShowShooterUIForce()
end
function MainControlPanelTochButton:ShowShooterUIForce()
  self.OperationState = UEnums.UIOperation.Shoot
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SHOOTING_UI)
  self:SwitchOperationUI()
end
function MainControlPanelTochButton:SwitchOperationUI()
  print(bWriteLog and "Operation switch to " .. tostring(self.OperationState))
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  EventSystem:postEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_OPERATION_CHANGE, self.OperationState)
  if self.OperationState == UEnums.UIOperation.Parachute then
    if ShootingUIPanelLuaClass then
      ShootingUIPanelLuaClass:ShowUIByOperation(UEnums.UIOperation.Parachute)
    end
    self.ParachutingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_KICK_PLAYER_BUTTON)
  elseif self.OperationState == UEnums.UIOperation.Shoot then
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
      local VehicleUserComp = PlayerController:GetVehicleUserComp()
      if not slua.isValid(VehicleUserComp) and not self:LuaCanShowShootingLayer() then
        return
      end
      if slua.isValid(VehicleUserComp) and VehicleUserComp.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_OutOfVehicle then
        return
      end
      self.ShootingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      if ShootingUIPanelLuaClass then
        ShootingUIPanelLuaClass:ShowUIByOperation(UEnums.UIOperation.Shoot)
      end
      self.ParachutingLayer:SetWidgetVisibility(ESlateVisibility.Collapsed)
      PlayerController:ShowTouchInterface(true)
      PlayerController.CharacterTouchMove = true
      if MainControlBaseUI then
        MainControlBaseUI:SetEmoteControlVisibility(MainControlBaseUI.Emote_DrivingControl, true)
      end
    end
  elseif self.OperationState == UEnums.UIOperation.Drive then
    self.ParachutingLayer:SetWidgetVisibility(ESlateVisibility.Collapsed)
    if MainControlBaseUI then
      MainControlBaseUI:SetEmoteControlVisibility(MainControlBaseUI.Emote_DrivingControl, false)
    end
    if self:IsDriving() then
      if ShootingUIPanelLuaClass then
        ShootingUIPanelLuaClass:ShowUIByOperation(UEnums.UIOperation.Drive)
      end
    else
      self.ShootingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      if ShootingUIPanelLuaClass then
        ShootingUIPanelLuaClass:ShowUIByOperation(UEnums.UIOperation.DriveAsPassenger)
      end
    end
  end
end
function MainControlPanelTochButton:OperatingRules2()
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass then
    ShootingUIPanelLuaClass:SelfHitTestInvisible()
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
end
function MainControlPanelTochButton:ShowDriveUI()
  self.OperationState = UEnums.UIOperation.Drive
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_DRIVE_UI)
  self:SwitchOperationUI()
end
function MainControlPanelTochButton:DebugSetAllUIVisibility(IsVisible)
  local Clor = FLinearColor(1, 1, 1, 0)
  if IsVisible then
    Clor = FLinearColor(1, 1, 1, 1)
  end
  local VehicleControlPanelLuaClass = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanelLuaClass then
    VehicleControlPanelLuaClass:SetColorAndOpacity(Clor)
  end
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass then
    ShootingUIPanelLuaClass.UIRoot:SetColorAndOpacity(Clor)
  end
  local ParachutingUserWidget = self.ParachutingLayer:GetChildAt(0)
  if slua.isValid(ParachutingUserWidget) then
    ParachutingUserWidget:SetColorAndOpacity(Clor)
  end
end
function MainControlPanelTochButton:IsInHideAllUIState()
  return self.CanvasPanel_IPX:GetVisibility() == ESlateVisibility.Collapsed
end
function MainControlPanelTochButton:MainControlPanel_HideAllUI()
  print(bWriteLog and "[UIStateRefresh LLP] MainControlPanelTochButton:MainControlPanel_HideAllUI", debug.traceback())
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI)
  self.CanvasPanel_IPX:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self:DumpIPXState("AfterHideAllUI")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local HUD = PlayerController:GetHUD()
  if slua.isValid(HUD) then
    HUD:SetActorHiddenInGame(true)
  end
  PlayerController.CharacterTouchMove = false
  PlayerController:ShowTouchInterface(false)
  self:HidePVEVPModePanel()
  self:ShowWalkingDeathModePanel(false)
  self:ShowHeavyWeaponModePanel(false)
  self.ED_MainControlPanelHide:BroadCast()
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ClearBattleGeneralTip()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI_POST)
end
function MainControlPanelTochButton:Reconnect_ResetUIByPlayerControllerState()
  self:HideSelfieUI()
end
function MainControlPanelTochButton:ShowBattleUI()
  print(bWriteLog and "Show battle ui!")
  self:Show()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController.InGameUIRoot = self.Object
  end
end
function MainControlPanelTochButton:FingWidget(widget, data)
  return self.Super:FingWidget(widget, data)
end
function MainControlPanelTochButton:InitSpecialUI()
  self:CheckInitPVEVPModeUI()
end
function MainControlPanelTochButton:IsPlayerOutOfVehicle()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return true
  end
  return VehicleUserComponent.VehicleUserState == ESTExtraVehicleUserState.EVUS_OutOfVehicle
end
function MainControlPanelTochButton:GetNextFireMode(InpuptValue)
  return self.Super:GetNextFireMode(InpuptValue)
end
function MainControlPanelTochButton:UIMsg_RefreshSightVision()
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_REFRESH_SIGHT_VISION)
end
function MainControlPanelTochButton:SetAdaptationDataToController()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local Margin = UIUtil.GetScreenPadding()
  local Left = Margin.Left
  local Top = Margin.Top
  local Right = Margin.Right
  local Bottom = Margin.Bottom
  local Margin = FMargin(Left, Top, Right, Bottom)
  self.CurDeviceAdaptationData.LeftOffset = Left
  self.CurDeviceAdaptationData.TopOffset = Top
  self.CurDeviceAdaptationData.RightOffset = Right
  self.CurDeviceAdaptationData.BottomOffset = Bottom
  self:SetAdapation(Left, Top, Right, Bottom)
  PlayerController.CurDeviceAdaptationOffset = self.CurDeviceAdaptationData
  self.InvalidationBox_1.Slot:SetOffsets(Margin)
end
function MainControlPanelTochButton:HideSelfieUI()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter:GetIsSelfieMode() then
    return
  end
  if slua.isValid(self.DynamicSelfieUI) then
    self.DynamicSelfieUI:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.DynamicSelfieUI:ExitSelfie()
    self.DynamicSelfieUI:DestroyWidget()
    self.DynamicSelfieUI = nil
  end
  self.ParachutingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.ShootingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.VehicleControlLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.MainControlBaseUI.CanvasPanel_42:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.ED_HideSelfieUI:BroadCast()
  ShareSelfieHideUI()
  if PlayerCharacter.IsFPP then
    local EPlayerCameraMode = import("EPlayerCameraMode")
    PlayerController:SwitchCameraMode(EPlayerCameraMode.PCM_FPP, PlayerCharacter, true, true)
  end
end
function MainControlPanelTochButton:ShowSelfieUI()
  self.Super:ShowSelfieUI()
end
function MainControlPanelTochButton:CloseBackpack()
  local BackpackUI = InGameUITools.GetBackpackUI()
  if not BackpackUI then
    print(bWriteLog and "MainControlPanelTochButton:CallBackpackLuaFunction(%s) BackpackUI is nil")
    return
  end
  BackpackUI:ClickCloseBackpack()
end
function MainControlPanelTochButton:CloseMap()
  BatttleWindowMgr.OpenOrHideEntireMap()
end
function MainControlPanelTochButton:HandleAndroidBack()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:HandleAndroidBack()
  end
  if slua.isValid(self.DynamicSelfieUI) and self.DynamicSelfieUI:GetVisibility() ~= ESlateVisibility.Collapsed then
    self:HideSelfieUI()
    self.hasOpenedSubPanel = true
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("HandleAndroidBack", 0, "", "")
  end
end
function MainControlPanelTochButton:BackToLobby()
  if slua_GameFrontendHUD then
    slua_GameFrontendHUD:CallGlobalScriptFunction("EventShowBackToLobbyNotice")
  end
end
function MainControlPanelTochButton:ShowBossWarning()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:DisplayBossWarning()
  end
end
function MainControlPanelTochButton:IsZombieMode()
  return false
end
function MainControlPanelTochButton:ShowAllUIForDelayResult()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  print(bWriteLog and "MainControlPanelTochButton:ShowAllUIForDelayResult")
  self:MainControlPanel_ShowAllUI()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SET_NAVIGATOR_VISIBLE, self.HideNavigator)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWALLUIFORDELATRESULT)
  if self:IsPlayerOutOfVehicle() then
    PlayerController.CharacterTouchMove = true
    PlayerController:ShowTouchInterface(true)
  end
  local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.ShowAllUIForDelayResult, true)
end
function MainControlPanelTochButton:MainControlPanel_ShowAllUI()
  if not self.CanvasPanel_IPX then
    return
  end
  print(bWriteLog and "MainControlPanelTochButton:MainControlPanel_ShowAllUI")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_ALL_UI)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  self.CanvasPanel_IPX:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self:DumpIPXState("AfterShowAllUI")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local HUD = PlayerController:GetHUD()
    if slua.isValid(HUD) then
      HUD:SetActorHiddenInGame(false)
    end
    PlayerController.CharacterTouchMove = true
    if self:IsPlayerOutOfVehicle() then
      PlayerController:ShowTouchInterface(true)
      PlayerController:SetVirtualStickAutoSprintStatus(false)
      InGameUITools.SetJoystickSprintState(false)
    end
  end
  self:EventReportBugClose()
  if MainControlBaseUI then
    MainControlBaseUI:HideQuickChatMenu()
  end
  self:ShowWalkingDeathModePanel(true)
  self:ShowHeavyWeaponModePanel(true)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_ALL_UI_POST)
end
function MainControlPanelTochButton:ShowCompletePlaybackUI()
  print(bWriteLog and "MainControlPanelTochButton:ShowCompletePlaybackUI 0")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController:IsDemoPlaySpectator() then
    return
  end
  print(bWriteLog and "MainControlPanelTochButton:ShowCompletePlaybackUI 1")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_COMPLETE_PLAYBACK_UI)
  self:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanel_IPX:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.ShootingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  PlayerController:ShowTouchInterface(false)
  UIManager.CloseUI(UIManager.UI_Config_InGame.ParachutingControl)
end
function MainControlPanelTochButton:CurGameMode()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return 0
  end
  return PlayerController:CurGameMode()
end
function MainControlPanelTochButton:SendQuickNeedText(ChatText)
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  if GameState.GameModeType == EGameModeType.ESocialIsland then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  if GameplayStatics.GetRealTimeSeconds(slua_GameFrontendHUD) <= MainControlBaseUI.ChatOpenTime then
    return
  end
  local QuickSignComponent = PlayerController:GetQuickSignComponent()
  if not slua.isValid(QuickSignComponent) then
    return
  end
  QuickSignComponent:MakeQuickNeed(ChatText)
  MainControlBaseUI:HideQuickChatMenu()
  local ChatComponent = PlayerController:GetChatComponent()
  if not slua.isValid(ChatComponent) then
    return
  end
  MainControlBaseUI:StartChatBarAnima(ChatComponent.SendMsgCD)
end
function MainControlPanelTochButton:UIMsg_HideSomeUIForMiniGameMachine()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if not self.HasOpenMiniGameOnce then
    self.HasOpenMiniGameOnce = true
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:UIMsg_HideSomeUIForMiniGameMachine()
  end
  self.ShootingLayer:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.VehicleControlLayer:SetWidgetVisibility(ESlateVisibility.Collapsed)
  PlayerController:ShowTouchInterface(false)
end
function MainControlPanelTochButton:UIMsg_ShowSomeUIAfterMiniGameMachine()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self.ShootingLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  self.VehicleControlLayer:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if not PlayerController:IsInPlane() then
    PlayerController:ShowTouchInterface(true)
  end
  local PlayerCharacter = PlayerController:GetCurPawn()
  if not slua.isValid(PlayerCharacter) then
    PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  end
  PlayerController:BluePrintSetViewTarget(PlayerCharacter)
end
function MainControlPanelTochButton:AddModeUIChild(parentpanel, childwidget, parentwgt)
  parentpanel:AddChild(childwidget)
  parentpanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  if childwidget.SetParentWidget then
    childwidget:SetParentWidget(parentwgt)
  end
end
function MainControlPanelTochButton:IsInInteraction()
  return false
end
function MainControlPanelTochButton:BlackScreenFadOut(FadTime)
  self.ScreenFadingPanel:BlackScreenFadeOut(FadTime)
end
function MainControlPanelTochButton:UIMsg_UpdateUseVehicleWeaponUI(bUse, VehicleWeapon)
  local VehicleControlPanelLuaClass = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanelLuaClass then
    return VehicleControlPanelLuaClass:OnUpdateVehicleWeaponUI(bUse, VehicleWeapon)
  end
end
function MainControlPanelTochButton:UIMsg_SwitchDriverFireState(bFire)
  local VehicleControlPanelLuaClass = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanelLuaClass then
    return VehicleControlPanelLuaClass:OnSwitchDriverFireState(bFire)
  end
end
function MainControlPanelTochButton:CanDriveVehicle(InVehicle, InCharacter)
  local COwnerShipComponent = import("/Script/ShadowTrackerExtra.OwnershipComponent")
  local uOwnerShip = InVehicle:GetComponentByClass(COwnerShipComponent)
  if not slua.isValid(uOwnerShip) then
    return true
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return false
  end
  local bCanDrive = InVehicle:CanDrive(uPlayerPawn)
  if not bCanDrive then
    uPlayerController:DisplayGameTipWithMsgID(InVehicle.CannotDriveTips)
  end
  local sPlayerKey = InCharacter:GetPlayerKey()
  if bCanDrive and (uOwnerShip:BelongToBP(sPlayerKey) or uOwnerShip:BorrowedByBP(sPlayerKey)) then
    return true
  end
  return false
end
function MainControlPanelTochButton:IsVehicleExclusive(InVehicle)
  local COwnerShipComponent = import("/Script/ShadowTrackerExtra.OwnershipComponent")
  local uOwnerShip = InVehicle:GetComponentByClass(COwnerShipComponent)
  if not slua.isValid(uOwnerShip) then
    return false
  end
  return uOwnerShip.bExclusive
end
function MainControlPanelTochButton:CanPickVehicle(InVehicle)
  if not slua.isValid(InVehicle) then
    return false
  end
  local VehiclePickableComponent = InVehicle:GetPickupComponent()
  if not slua.isValid(VehiclePickableComponent) then
    return false
  end
  return VehiclePickableComponent:CanShowPickedUpButton()
end
function MainControlPanelTochButton:LuaCanShowShootingLayer()
  local EGameModeType = import("EGameModeType")
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.GameModeType == EGameModeType.ESocialIsland then
    local SI_BattleUIMgr = require("GameLua.Mod.SocialIsland.Client.SI_BattleUIMgr")
    if SI_BattleUIMgr:CanShowShootingLayer() == false then
      return false
    end
  end
  return true
end
function MainControlPanelTochButton:HandleChangeSightUIAndroidBack()
  local ChangeSightUI = UIManager.GetUI(UIManager.UI_Config_InGame.ChangeSightUI)
  if ChangeSightUI and ChangeSightUI.UIRoot.CanvasPanelList:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed then
    ChangeSightUI:HideList()
    self.hasOpenedSubPanel = true
  end
end
function MainControlPanelTochButton:HandleChangeSightUIShowDeathMatch()
  local ChangeSightUI = UIManager.GetUI(UIManager.UI_Config_InGame.ChangeSightUI)
  if ChangeSightUI then
    ChangeSightUI:Collapsed()
  end
end
function MainControlPanelTochButton:IsDriving()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return false
  end
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_AsDriver then
    return false
  end
  return true
end
function MainControlPanelTochButton:EventReportBugClose()
  print(bWriteLog and "MainControlPanelTochButton:EventReportBugClose")
  if UIManager.UI_Config_InGame.BattleReportBug then
    UIManager.CloseUI(UIManager.UI_Config_InGame.BattleReportBug)
  end
end
function MainControlPanelTochButton:PickUpListPanelShowHideExpandDeadBoxTips(isShow, TempGuideText)
  print(bWriteLog and "MainControlPanelTochButton:PickUpListPanelShowHideExpandDeadBoxTips")
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel then
    PickUpListPanel:Show_HideExpandDeadBoxTips(isShow, TempGuideText)
  end
end
function MainControlPanelTochButton:OnStartResultCount()
  print(bWriteLog and "MainControlPanelTochButton:OnStartResultCount")
  self.bStartResultCount = true
end
function MainControlPanelTochButton:OnEndResultCount()
  print(bWriteLog and "MainControlPanelTochButton:OnEndResultCount")
  self.bStartResultCount = false
end
function MainControlPanelTochButton:PrintWidgetNum()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  print(bWriteLog and "MainControlPanelTochButton:PrintWidgetNum: ", STExtraBlueprintFunctionLibrary.GetNumberOfWidget(self.Object))
end
function MainControlPanelTochButton:OnQuitSpectating(_, _, InPlayerKey)
end
function MainControlPanelTochButton:ApplyLayout(LayoutName)
  if self.CurrentRecoverLayout == nil then
    self.CurrentRecoverLayout = {}
  end
  local LayoutConfig = UILayoutConfig.Config
  local ThisConfig = LayoutConfig[LayoutName]
  if not ThisConfig then
    sandbox.LogError("LayoutName Config Not Find: ", LayoutName)
    return
  end
  self:DealLayoutCollision(ThisConfig)
  for WidgetName, Translation in pairs(ThisConfig) do
    local Widget = self:GetControlByName(WidgetName, self)
    if Widget then
      local CurrentTranslation = Widget.RenderTransform.Translation:clone()
      self.CurrentRecoverLayout[WidgetName] = CurrentTranslation
      Widget:SetRenderTranslation(Translation)
    end
  end
end
function MainControlPanelTochButton:UnApplyLayout(LayoutName)
  if self.CurrentRecoverLayout == nil then
    self.CurrentRecoverLayout = {}
  end
  local LayoutConfig = UILayoutConfig.Config
  local ThisConfig = LayoutConfig[LayoutName]
  if not ThisConfig then
    sandbox.LogError("LayoutName Config Not Find: ", LayoutName)
    return
  end
  for WidgetName, _ in pairs(ThisConfig) do
    if self.CurrentRecoverLayout[WidgetName] then
      local Widget = self:GetControlByName(WidgetName, self)
      if Widget then
        Widget:SetRenderTranslation(self.CurrentRecoverLayout[WidgetName])
      end
      self.CurrentRecoverLayout[WidgetName] = nil
    end
  end
end
function MainControlPanelTochButton:DealLayoutCollision(NewConfig)
  for WidgetName, _ in pairs(NewConfig) do
    if self.CurrentRecoverLayout[WidgetName] then
      local Widget = self:GetControlByName(WidgetName, self)
      if Widget then
        Widget:SetRenderTranslation(self.CurrentRecoverLayout[WidgetName])
      end
      self.CurrentRecoverLayout[WidgetName] = nil
    end
  end
end
function MainControlPanelTochButton:UIMsg_ActivitySeatsHideUI()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self.ShootingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  PlayerController:ShowTouchInterface(false)
  PlayerController:BroadcastUIMessage("UIMsg_UpdateVehicleBtn", 0, "", "")
end
function MainControlPanelTochButton:UIMsg_ActivitySeatsShowUI()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self.ShootingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  PlayerController:ShowTouchInterface(true)
  PlayerController:BroadcastUIMessage("UIMsg_UpdateVehicleBtn", 0, "", "")
end
function MainControlPanelTochButton:UIMsg_HideIngameMainUI()
  self.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:ShowTouchInterface(false)
  end
end
function MainControlPanelTochButton:UIMsg_ShowIngameMainUI()
  self.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:ShowTouchInterface(true)
  end
end
function MainControlPanelTochButton:UIMsg_ForceHideMap()
  if BatttleWindowMgr.CheckWindowOpen("EntireMapWindow") then
    BatttleWindowMgr.HideUI("EntireMapWindow")
  end
end
function MainControlPanelTochButton:UIMsg_FightingReadyGoToFlying()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.GameModeType == nil then
    return
  end
  local EGameModeType = import("EGameModeType")
  if GameState.GameModeType == EGameModeType.EBattleRoyalCorpsWarMode or GameState.GameModeType == EGameModeType.EWarGameMode then
    self:ShowAirborneUI()
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      PlayerController:ShowTouchInterface(false)
    end
  end
end
function MainControlPanelTochButton:UIMsg_RespawnSetUI()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.GetGameModeState == nil then
    return
  end
  if GameState:GetGameModeState() ~= "ReadyState" then
    self:ResetUIStateAfterRespawn()
  end
end
function MainControlPanelTochButton:UIMsg_WeaponUnequipAttachment()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.FPPComponent) then
    local ESTEScopeType = import("ESTEScopeType")
    PlayerCharacter.FPPComponent:ScopeOut(ESTEScopeType.Normal)
  end
end
function MainControlPanelTochButton:UIMsg_ShowOrHideSelf()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController.IsShowInputControl then
    if self:IsInViewport() then
      self:Show()
    end
  else
    self:Hide()
  end
end
function MainControlPanelTochButton:UIMSG_PlayerControllerStateChange()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and (PlayerController:IsInPlane() or PlayerController:IsInParachute()) then
    self:ShowAirborneUI()
  end
end
function MainControlPanelTochButton:UIMsg_MakePictureFalse()
  local ScreenshotMaker = import("ScreenshotMaker")
  ScreenshotMaker.MakePicture(false)
end
function MainControlPanelTochButton:UIMsg_MakePictureTrue()
  local ScreenshotMaker = import("ScreenshotMaker")
  ScreenshotMaker.MakePicture(true)
end
function MainControlPanelTochButton:UIMsg_CloseMap()
  BatttleWindowMgr.HideUI("EntireMapWindow")
end
function MainControlPanelTochButton:GetVehicleUserComponent()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return nil
  end
  return VehicleUserComponent
end
function MainControlPanelTochButton:UIMsg_ShowAutoSprintIcon()
  self.Super:UIMsg_ShowAutoSprintIcon()
  if self.MainControlBaseUI then
    self.MainControlBaseUI.InvalidationBox_6:InvalidateCache()
  end
end
function MainControlPanelTochButton:ClearClassWidgetTreeFowSaveMemory()
end
function MainControlPanelTochButton:HandleOnPlayerControllerStateChanged(ClientStateType)
  print(bWriteLog and "HandleOnPlayerControllerStateChanged call")
  self:UIMSGPlayerControllerStateChange()
end
function MainControlPanelTochButton:UIMSGPlayerControllerStateChange()
  print(bWriteLog and "UIMSG_PlayerControllerStateChange call")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if uPlayerController and (uPlayerController:IsInPlane() or uPlayerController:IsInParachute()) then
    self:ShowAirborneUI()
  end
end
function MainControlPanelTochButton:OnEnterVehicleCompleted()
  local PC = GameplayData.GetPlayerController()
  if slua.isValid(PC) and slua.isValid(PC.BP_VehicleUser) and slua.isValid(PC.BP_VehicleUser.Vehicle) then
    local ESTExtraVehicleType = import("ESTExtraVehicleType")
    if PC.BP_VehicleUser.Vehicle.VehicleType == ESTExtraVehicleType.VT_Surfboard then
      local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
      MainControlBaseUI:UIMsg_EnterSurfBoard()
    end
  end
end
function MainControlPanelTochButton:OnExitVehicleCompleted()
  local PC = GameplayData.GetPlayerController()
  if slua.isValid(PC) and slua.isValid(PC.BP_VehicleUser) and slua.isValid(PC.BP_VehicleUser.Vehicle) then
    local ESTExtraVehicleType = import("ESTExtraVehicleType")
    if PC.BP_VehicleUser.Vehicle.VehicleType == ESTExtraVehicleType.VT_Surfboard then
      local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
      MainControlBaseUI:UIMsg_ExitSurfBoard()
    end
  end
end
function MainControlPanelTochButton:UIMsg_HideWateringBtnPanel()
  local BasicSkillMenuUI = InGameUITools.GetBasicSkillsMenuUI()
  if BasicSkillMenuUI then
    BasicSkillMenuUI:HideNormalBtn("Type_DesertDrinkMachine")
  end
end
function MainControlPanelTochButton:UIMsg_ShowWateringBtnPanel()
  local BasicSkillMenuUI = InGameUITools.GetBasicSkillsMenuUI()
  if BasicSkillMenuUI then
    BasicSkillMenuUI:ShowNormalBtn("Type_DesertDrinkMachine")
  end
end
function MainControlPanelTochButton:HandleChangeSightUISwitchCameraStart()
end
function MainControlPanelTochButton:GetControlByName(Name, Root)
  local Control = Root
  Control = Control or self
  if Control ~= "" then
    if not string.find(Name, ".", 1, true) then
      return Control[Name]
    end
    string.gsub(Name, "([^.]*)", function(c)
      Control = Control[c]
      if not Control then
        error(string.format("control is nil! controlName\239\188\154[%s]", Name))
      end
    end)
  end
  return Control
end
function MainControlPanelTochButton:SwitchWeapon(bIsShowGuide, TempGuideText)
  self:ShowHideSlotTips(0, bIsShowGuide, TempGuideText)
end
function MainControlPanelTochButton:TakeDownWeapon(bIsShowGuide, TempGuideText)
  self:ShowHideSlotTips(1, bIsShowGuide, TempGuideText)
end
function MainControlPanelTochButton:ShowHideSlotTips(Type, bIsShowGuide, TempGuideText)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUILua = InGameUITools.GetShootingUIPanelLuaClass()
  if not ShootingUILua then
    return
  end
  if bIsShowGuide then
    local PC = GameplayData.GetPlayerController()
    if not slua.isValid(PC) then
      return
    end
    local PlayerCharacter = PC:K2_GetPawn()
    if not slua.isValid(PlayerCharacter) then
      return
    end
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if not slua.isValid(WeaponManager) then
      return
    end
    local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
    local CurSlot = WeaponManager:GetCurrentUsingPropSlot()
    if not ShootingUILua.FirWeaponSlot or not ShootingUILua.SecWeaponSlot then
      return
    end
    if CurSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
      if Type == 0 then
        ShootingUILua.SecWeaponSlot:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
      else
        ShootingUILua.FirWeaponSlot:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
      end
    elseif CurSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
      if Type == 0 then
        ShootingUILua.FirWeaponSlot:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
      else
        ShootingUILua.SecWeaponSlot:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
      end
    end
  else
    ShootingUILua.SecWeaponSlot:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
    ShootingUILua.FirWeaponSlot:ShowHideSwitchWeaponTips(bIsShowGuide, TempGuideText)
  end
end
function MainControlPanelTochButton:OnDestroy()
  print(bWriteLog and "MainControlPanelTochButton:OnDestroy 0")
  local CommonLogoUI = UIManager.GetUI(UIManager.UI_Config_InGame.Common_Logo_UIBP)
  if CommonLogoUI then
    CommonLogoUI:CloseSelf()
  end
  MainControlPanelTochButton.__super.OnDestroy(self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.VehicleControlLayer)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.BaseLayer)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.ShootingLayer)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.CanvasPanel_IPX)
end
function MainControlPanelTochButton:CheckDisableInvalidationBoxes()
  if self.InvalidationBox_1 then
    self.InvalidationBox_1:SetCanCache(false)
  end
  self:AddTimer(0.1, function()
    if self.InvalidationBox_1 then
      self.InvalidationBox_1:SetCanCache(true)
    end
    local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
    if ClientEVOConfig.IsCreativeMode() then
      if self.InvalidationBox_1 then
        self.InvalidationBox_1:SetCanCache(false)
      end
      return
    end
    if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableInvalidationBox", false) == true then
      log_shipping_client("MainControlPanelTochButton:CheckDisableInvalidationBoxes Disable InvalidationBox Cache")
      if self.InvalidationBox_1 then
        self.InvalidationBox_1:SetCanCache(false)
      end
    end
  end)
end
local class = require("class")
local UILuaUserWidget = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
local CMainControlPanelTochButton = class(UILuaUserWidget, nil, MainControlPanelTochButton)
return CMainControlPanelTochButton