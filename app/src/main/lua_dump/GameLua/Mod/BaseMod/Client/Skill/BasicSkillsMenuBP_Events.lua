local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
local Util = require("client.slua_ui_framework.util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UIUtil = require("client.common.ui_util")
local CustomType = require("client.logic.setting.CustomType")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function BasicSkillsMenuBP:RegistEvents()
  print(bWriteLog and "BasicSkillsMenuBP:RegistEvents-")
  self.UIRoot.InvalidationBox_0:SetCanCache(false)
  self:AddControlEventByControl(self.UIRoot.Button_Door, "OnClicked", self.Action_OpenOrCloseDoor, self)
  self:AddControlEventByControl(self.UIRoot.Button_PushDoor, "OnClicked", self.Action_PushDoor, self)
  self:AddControlEventByControl(self.UIRoot.Button_PullDoor, "OnClicked", self.Action_PullDoor, self)
  self:AddControlEventByControl(self.UIRoot.Button_AutoDoor, "OnClicked", self.OnClickAutoDoor, self)
  self:AddControlEventByControl(self.UIRoot.Button_InteractiveMove, "OnClicked", self.OnClickInteractiveMove, self)
  self:AddControlEventByControl(self.UIRoot.Button_PutDown, "OnClicked", self.OnClickCarryBackBtn, self)
  self:AddControlEventByControl(self.UIRoot.Button_PutDownInVehicle, "OnClicked", self.OnClickCarryToVehicle, self)
  self:AddControlEventByControl(self.UIRoot.BtnRescue, "OnClicked", self.OnClickBtnRescue, self)
  self:AddControlEventByControl(self.UIRoot.Button_Captive, "OnClicked", self.OnClickCaptiveBtn, self)
  self:AddControlEventByControl(self.UIRoot.Button_CancelUse, "OnClicked", self.OnClickInteractiveCancel, self)
  self:AddControlEventByControl(self.UIRoot.Button_PutDownDeadBox, "OnClicked", self.OnClick_Button_PutDownDeadBox, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_REFUSE_TO_CAPTIVED, self.OnRefuseToCaptived, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_RECEIVED_BEGGING_PLAYER, self.OnReceivedBeggingPlayer, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CAPTIVATE_FINISH_TO_CAPTIVING_PLAYER, self.OnCaptivateFinishToCaptivingPlayer, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CAPTIVATE_FINISH_TO_CAPTIVED_PLAYER, self.OnCaptivateFinishToCaptivedPlayer, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_PROMPT_PLAYER_SOLE_TO_KILLER, self.OnPromptPlayerSoleToKiller, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CAPTIVATE_ROLLBACK, self.CaptivatingInterrupt, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CAPTIVATE_FINISH_TO_TEAMMATE, self.OnCaptivateFinishToTeammate, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE, self.OnEnterSelifeMode, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_PUT_DOWN_BTN, self.ShowCarryBackBtnProxy, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_PUT_DOWN_BTN, self.HideCarryBackBtnProxy, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_HIDE_RESCUE_BTN, self.HideRescueBtnProxy, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_DONE, self.OnPlayerCarryBoxDone, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_INTERUPT, self.OnPlayerCarryBoxInterupt, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_OR_HIDE_CAN_DRIVE_TIPS, self.ShowOrHideCanDriveTips, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UPDATE_DOOR_BTN, self.UpdateDoorBtn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_ENTER_VEHICLE_BUTTONS, self.ShowEnterVehicleButtons, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_ENTER_VEHICLE_BUTTONS, self.HideEnterVehicleButtons, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_DOOR_BTN_PANEL, self.ShowDoorBtnPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_DOOR_BTN_PANEL, self.HideDoorBtnPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UIMSG_SHOW_INTERACTIVE_MOVE_BTN_PANEL, self.UIMsg_ShowInteractiveMoveBtnPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UIMSG_HIDE_INTERACTIVE_MOVE_BTN_PANEL, self.UIMsg_HideInteractiveMoveBtnPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_RESCUE_CANVAS, self.UIMsg_ShowRescueCanvas, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_RESCUE_CANVAS, self.UIMsg_HideRescueCanvas, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_MINITV_BANNER, self.UIMsg_HideMiniTvBannerUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UIMSG_UPDATE_INTERACTIVE_MOVE_BTN_PANEL, self.Action_Activity1Show, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, self.OnShowNormalButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, self.OnHideNormalButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UPDATE_NORMAL_BTN, self.OnUpdateNormalButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_CDBAR_BTN, self.OnShowCDBarButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_CDBAR_BTN, self.OnHideCDBarButton, self)
  self:AddUIMessageEvent("UIMsgEnterVehicleCompleted", self.OnEnterVehicleCompleted, self)
  self:AddUIMessageEvent("UIMsg_UpdateVehicleBtn", self.CheckEnterVehicleButtonVisibility, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_DEATH_PLAYBACK_START, self.OnDeathPlaybackStart, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterRescueingStatus", self.OnPlayerEnterRescueingStatus, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  if slua.isValid(CGameState) then
    local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
    local DelegateMgrInstance = uSTExtraDelegateMgr.STExtraDelegateMgrInstance(CGameState)
    self:AddControlEventByControl(DelegateMgrInstance, "OnCanCarryOtherChange", self.OnCanCarryOtherEvent, self)
    self:AddControlEventByControl(DelegateMgrInstance, "OnCanCarryAnyActorChange", self.OnCanCarryAnyActorEvent, self)
    self:AddControlEventByControl(DelegateMgrInstance, "OnCanRescueOtherChange", self.OnCanRescueOtherEvent, self)
    self:AddControlEventByControl(DelegateMgrInstance, "OnCaptivingStatusChangeChange", self.OnCanCaptivateOtherEvent, self)
    self:AddControlEventByControl(DelegateMgrInstance, "OnCharacterStateChangeDelegate", self.OnCharacterStateChange, self)
    self:AddControlEventByControl(DelegateMgrInstance, "OnNearDeathOrRescueingNotify", self.OnCharacterNearDeathOrRescueingOtherNotify, self)
  end
  local GameplayStatics = import("GameplayStatics")
  local uPlayerController = GameplayStatics.GetPlayerController(self.UIRoot, 0)
  local uCharacter = uPlayerController and uPlayerController.GetPlayerCharacterSafety and uPlayerController:GetPlayerCharacterSafety()
  if uCharacter and slua.isValid(uCharacter) then
    self:AddControlEventByControl(uCharacter, "OnHandleSkillStartDelegate", self.OnSkillStarted, self)
    self:AddControlEventByControl(uCharacter, "OnHandleSkillEndDelegate", self.OnSkillEnded, self)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_BASIC_SKILL_MENU_REGIST_DONE)
  self:AddUIMessageEvent("UIMsg_UpdateDoorBtnAndShowDoorBtn", self.UIMsg_UpdateDoorBtnAndShowDoorBtn, self)
  self:AddUIMessageEvent("UIMsg_ShowInteractiveMoveBtnPanel", self.UIMsg_ShowInteractiveMoveBtnPanel, self)
  self:AddUIMessageEvent("UIMsg_HideInteractiveMoveBtnPanel", self.UIMsg_HideInteractiveMoveBtnPanel, self)
  self:AddUIMessageEvent("UIMsg_ShowActivityInteractiveBtn", self.UIMsg_ShowActivityInteractiveBtn, self)
  self:AddUIMessageEvent("UIMsg_HideActivityInteractiveBtn", self.UIMsg_HideActivityInteractiveBtn, self)
  self:AddUIMessageEvent("UIMsg_ShowActivityCancleBtn", self.UIMsg_ShowActivityCancleBtn, self)
  self:AddUIMessageEvent("UIMsg_HideActivityCancleBtn", self.UIMsg_HideActivityCancleBtn, self)
  self:AddUIMessageEvent("UIMsg_UpdateActivityInteractiveBtn", self.UIMsg_UpdateActivityInteractiveBtn, self)
  self:AddUIMessageEvent("UIMsg_HideActivityBtn", self.UIMsg_HideActivityBtn, self)
  self:AddUIMessageEvent("UIMsg_ShowRescueCanvas", self.UIMsg_ShowRescueCanvas, self)
  self:AddUIMessageEvent("UIMsg_HideRescueCanvas", self.UIMsg_HideRescueCanvas, self)
  self:AddUIMessageEvent("UIMsg_ShowActivityBtn_2", self.UIMsg_ShowActivityBtn_2, self)
  self:AddUIMessageEvent("UIMsg_HideActivityBtn_2", self.UIMsg_HideActivityBtn_2, self)
  self:AddUIMessageEvent("UIMsg_HideMiniTvBannerUI", self.UIMsg_HideMiniTvBannerUI, self)
  self:AddUIMessageEvent("UIMsg_CanSelfRescue", self.CheckShowNearDeathGiveupButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_CDBAR, self.OnShowCDBar, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, self.OnHideCDBar, self)
  self:CheckShowNearDeathGiveupButton()
  self:CheckShowCarryBackBtn()
end
function BasicSkillsMenuBP:OnShowCDBar(_, _, CDBarType, params)
  print("BasicSkillsMenuBP:OnShowCDBar", CDBarType, params and params.PromptID or 0)
  if CDBarType == UEnums.CDBarType.Skill then
    self:OnCharacterShowOrHideSkillPrompt(true)
  end
end
function BasicSkillsMenuBP:OnHideCDBar(_, _, CDBarType, params)
  print("BasicSkillsMenuBP:OnHideCDBar", CDBarType, params and params.PromptID or 0)
  if CDBarType == UEnums.CDBarType.RescueOther or CDBarType == UEnums.CDBarType.BeingRescue then
    self:CheckShowNearDeathGiveupButton()
  elseif CDBarType == UEnums.CDBarType.Skill then
    self:OnCharacterShowOrHideSkillPrompt(false)
  end
end
function BasicSkillsMenuBP:UIMsg_HideActivityBtn_2()
  self:OnHideNormalButton(nil, nil, "Type_Activity2")
end
function BasicSkillsMenuBP:UIMsg_ShowActivityBtn_2()
  self:OnShowNormalButton(nil, nil, "Type_Activity2")
end
function BasicSkillsMenuBP:UIMsg_HideActivityBtn()
  self:OnHideNormalButton(nil, nil, "Type_Activity1")
  self:OnHideNormalButton(nil, nil, "Type_ActivityCancel")
end
function BasicSkillsMenuBP:UIMsg_UpdateActivityInteractiveBtn()
  self:Action_Activity1Show()
end
function BasicSkillsMenuBP:UIMsg_HideActivityCancleBtn()
  self:OnHideNormalButton(nil, nil, "Type_ActivityCancel")
end
function BasicSkillsMenuBP:UIMsg_ShowActivityCancleBtn()
  self:OnShowNormalButton(nil, nil, "Type_ActivityCancel")
  self:OnHideNormalButton(nil, nil, "Type_Activity1")
end
function BasicSkillsMenuBP:UIMsg_HideActivityInteractiveBtn()
  self:OnHideNormalButton(nil, nil, "Type_Activity1")
  self:OnHideNormalButton(nil, nil, "Type_Activity2")
end
function BasicSkillsMenuBP:UIMsg_ShowActivityInteractiveBtn()
  self:OnShowNormalButton(nil, nil, "Type_Activity1")
  self:OnHideNormalButton(nil, nil, "Type_ActivityCancel")
end
function BasicSkillsMenuBP:UIMsg_UpdateDoorBtnAndShowDoorBtn()
  self:AddGameTimer(0, false, function()
    self:UpdateDoorBtnAndShowDoorBtnInternal()
  end)
end
function BasicSkillsMenuBP:UpdateDoorBtnAndShowDoorBtnInternal()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local BP_CommonBtn = PlayerController.BP_CommonBtn
  if not slua.isValid(BP_CommonBtn) then
    return
  end
  local ECommonBtn = UEnums.ECommonBtn
  local OpenMode = BP_CommonBtn.OpenMode
  if not BP_CommonBtn.bShow then
    self:UpdateDoorBtn(nil, nil, ECommonBtn.None, OpenMode)
    return
  end
  if BP_CommonBtn.bOpen then
    self:UpdateDoorBtn(nil, nil, ECommonBtn.OpenDoorIn, OpenMode)
  else
    self:UpdateDoorBtn(nil, nil, ECommonBtn.CloseDoor, OpenMode)
  end
end
function BasicSkillsMenuBP:OnSkillStarted(character, skillId)
  print(bWriteLog and "BasicSkillsMenuBP:OnSkillStarted, skillId = " .. tostring(skillId))
  self.CurrentSkills[skillId] = true
end
function BasicSkillsMenuBP:OnSkillEnded(character, reason, skillId)
  if self.CurrentSkills[skillId] then
    self.CurrentSkills[skillId] = nil
    print(bWriteLog and "BasicSkillsMenuBP:OnSkillEnded, reason = " .. tostring(reason) .. ", skillId = " .. tostring(skillId))
  end
end
function BasicSkillsMenuBP:OnEnterVehicleCompleted()
  self:HideEnterVehicleButtons()
  self:HideDoorBtnPanel()
  self:HideNormalBtn("Type_DesertDrinkMachine")
  self:HideNormalBtn("Type_MechaDance")
end
function BasicSkillsMenuBP:OnShowNormalButton(_, _, Type, InteractiveConfig)
  self:ShowNormalBtn(Type, InteractiveConfig)
end
function BasicSkillsMenuBP:OnHideNormalButton(_, _, Type, InteractiveConfig)
  self:HideNormalBtn(Type, InteractiveConfig)
end
function BasicSkillsMenuBP:OnUpdateNormalButton(_, _, Type, InteractiveConfig)
  self:UpdateNormalButton(Type, InteractiveConfig)
end
function BasicSkillsMenuBP:OnShowCDBarButton(_, _, InteractiveConfig)
  self:ShowNormalCDBar(InteractiveConfig)
end
function BasicSkillsMenuBP:OnHideCDBarButton(_, _, InteractiveConfig)
  self:HideNormalCDBar(InteractiveConfig)
end
function BasicSkillsMenuBP:OnClickInteractItem(Widget, Index)
  print(bWriteLog and "BasicSkillsMenuBP:OnClickInteractItem")
  local Data = self.LoopScrollBoxInteract:GetItemData(Index)
  if not Data then
    print(bWriteLog and "BasicSkillsMenuBP:OnClickInteractItem Fail not Data Index=" .. tostring(Index))
    return
  end
  if Data.ActionOnClick then
    local ActionFn = self[Data.ActionOnClick]
    if ActionFn then
      ActionFn(self, Data.InteractiveConfig)
    else
      print(bWriteLog and "BasicSkillsMenuBP:OnClickInteractItem No Action")
    end
  end
end
function BasicSkillsMenuBP:OnPressInteractItem(Widget, Index)
  print(bWriteLog and "BasicSkillsMenuBP:OnPressInteractItem")
  local Data = self.LoopScrollBoxInteract:GetItemData(Index)
  if not Data then
    print(bWriteLog and "BasicSkillsMenuBP:OnPressInteractItem Fail not Data Index=" .. tostring(Index))
    return
  end
  if Data.ActionOnPress then
    local ActionFn = self[Data.ActionOnPress]
    if ActionFn then
      ActionFn(self, Data.InteractiveConfig)
    else
      print(bWriteLog and "BasicSkillsMenuBP:OnPressInteractItem No Action")
    end
  end
end
function BasicSkillsMenuBP:OnClickOperationItem(Widget, Index)
  print(bWriteLog and "BasicSkillsMenuBP:OnClickOperationItem")
  local Data = self.LoopScrollBoxOperation:GetItemData(Index)
  if not Data then
    print(bWriteLog and "BasicSkillsMenuBP:OnClickOperationItem Fail not Data Index=" .. tostring(Index))
    return
  end
  if Data.ActionOnClick then
    local ActionFn = self[Data.ActionOnClick]
    if ActionFn then
      ActionFn(self, Data.InteractiveConfig)
    else
      print(bWriteLog and "BasicSkillsMenuBP:OnClickOperationItem No Action")
    end
  end
end
function BasicSkillsMenuBP:ShowCarryBackBtnProxy(_, _, uPlayerCharacter, bSuccess)
  self:NewShowCarryBackBtnProxy(_, _, uPlayerCharacter, bSuccess)
end
function BasicSkillsMenuBP:HideCarryBackBtnProxy(_, _, uPlayerCharacter)
  print(bWriteLog and "BasicSkillsMenuBP:HideCarryBackBtnProxy")
  self:HideCarryBackBtn(uPlayerCharacter)
end
function BasicSkillsMenuBP:HideRescueBtnProxy(_, _, uPlayerCharacter)
  print(bWriteLog and "BasicSkillsMenuBP:HideRescueBtnProxy")
  self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "BtnRescue", "CarryBackAndRescue")
  self:SetBtnVisibleFlag(UEnums.ESlateVisibility.Collapsed, "CanvasPanel_NewBieGuideSave", "CarryBackAndRescue")
end
function BasicSkillsMenuBP:SetBtnVisibleFlag(InVisibility, WidgetName, FlagKey)
  if not self.BtnVisibleFlags[WidgetName] then
    self.BtnVisibleFlags[WidgetName] = {}
  end
  if bWriteLog and self.BtnVisibleFlags[WidgetName][FlagKey] ~= InVisibility then
    print(string.format("BasicSkillsMenuBP:SetBtnVisibleFlag In:%s %s %s", InVisibility, WidgetName, FlagKey))
  end
  self.BtnVisibleFlags[WidgetName][FlagKey] = InVisibility
  local OutVisibility = InVisibility
  local bShow
  if InVisibility ~= nil then
    bShow = InVisibility ~= UEnums.ESlateVisibility.Collapsed and InVisibility ~= UEnums.ESlateVisibility.Hidden
  end
  if bShow or bShow == nil then
    for _, Visibility in pairs(self.BtnVisibleFlags[WidgetName]) do
      if Visibility then
        local bCurShow = Visibility ~= UEnums.ESlateVisibility.Collapsed and Visibility ~= UEnums.ESlateVisibility.Hidden
        if bShow == nil then
          bShow = bCurShow
          Out        end
        bShow = bShow and bCurShow
        if not bShow then
          Out          break
        end
      end
    end
  else
  end
  if self.UIRoot[WidgetName] and OutVisibility ~= nil then
    self.UIRoot[WidgetName]:SetWidgetVisibility(OutVisibility)
  end
  local RescueBtnSub = SubsystemMgr:Get("RescueBtnReplayTraceSubsystem")
  if RescueBtnSub then
    RescueBtnSub:TraceSetBtnVisibleFlag(WidgetName, InVisibility, OutVisibility, FlagKey)
  end
end
function BasicSkillsMenuBP:OnClickAutoDoor()
  print(bWriteLog and "BasicSkillsMenuBP:OnClickAutoDoor")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:OnClickAutoDoor not slua.isValid(uPlayerController)")
    return
  end
  if self.OpenDoorMode == 1 then
    self.OpenDoorMode = 2
    self.UIRoot.TextBlock_BtnName:SetText(LocUtil.GetLocalizeResStr(33865))
    local BP_CommonBtn = uPlayerController.BP_CommonBtn
    if slua.isValid(BP_CommonBtn) then
      BP_CommonBtn:OnChangeOpenDoorMode(2)
    end
  else
    self.OpenDoorMode = 1
    self.UIRoot.TextBlock_BtnName:SetText(LocUtil.GetLocalizeResStr(33864))
    local BP_CommonBtn = uPlayerController.BP_CommonBtn
    if slua.isValid(BP_CommonBtn) then
      BP_CommonBtn:OnChangeOpenDoorMode(1)
    end
  end
end
function BasicSkillsMenuBP:OnClickInteractiveMove()
  print(bWriteLog and "BasicSkillsMenuBP:OnClickInteractiveMove")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  uPlayerCharacter:InteractiveMoveComponentHandleEnterInput()
end
function BasicSkillsMenuBP:OnClickCarryToVehicle()
  print(bWriteLog and "BasicSkillsMenuBP:OnClickCarryToVehicle")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local EPawnState = import("EPawnState")
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:IsCarryBackEnable() then
    if uPlayerCharacter:HasState(EPawnState.CarryBack) then
      local USTExtraVehicleUtils = import("STExtraVehicleUtils")
      local VehicleUserComp = USTExtraVehicleUtils.GetVehicleUserComp(uPlayerCharacter)
      if not slua.isValid(VehicleUserComp) then
        print(bWriteLog and "BasicSkillsMenuBP:OnClickCarryToVehicle VehicleUserComp = null")
        return
      end
      local CurrentClosestVehicle = VehicleUserComp.CurrentClosestVehicle
      if not slua.isValid(CurrentClosestVehicle) then
        print(bWriteLog and "BasicSkillsMenuBP:OnClickCarryToVehicle CurrentClosestVehicle = null")
        return
      end
      local VehicleSeats = CurrentClosestVehicle.VehicleSeats
      local bHasSameTeam = VehicleSeats:IsSeatAvailableTeam()
      if not bHasSameTeam then
        local uController = uPlayerCharacter:GetPlayerControllerSafety()
        if slua.isValid(uController) then
          print(bWriteLog and "BasicSkillsMenuBP:OnClickCarryToVehicle not bHasSameTeam")
          uController:DisplayGameTipWithMsgID(49665)
        end
      else
        uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1013194, true)
      end
      self:SetPutDownInVehicleBtnVisiable(false)
    end
  else
    print(bWriteLog and "BasicSkillsMenuBP:OnClickCarryToVehicle Failed")
  end
end
function BasicSkillsMenuBP:OnClickCarryBackBtn()
  self:NewOnClickCarryBackBtn()
end
function BasicSkillsMenuBP:OnClick_Button_PutDownDeadBox()
  self:NewOnClickPutDownDeadBoxBtn()
end
function BasicSkillsMenuBP:OnClickBtnRescue()
  self:NewOnClickBtnRescue()
end
function BasicSkillsMenuBP:CanClickSelfRescue(uPawn)
  local bCanClick = true
  local uRescueOtherCom = uPawn.RescueOtherComponent
  if uRescueOtherCom and slua.isValid(uRescueOtherCom) and uRescueOtherCom.RescueWho and slua.isValid(uRescueOtherCom.RescueWho) and uPawn.PlayerKey == uRescueOtherCom.RescueWho.PlayerKey then
    local LeftTime = uPawn.SelfRescueCoolDownLeftTime
    if 0 < LeftTime then
      bCanClick = false
      IngameTipsTools.BattleNormalTipsByTextID(77862)
      print(bWriteLog and "BasicSkillsMenuBP:CanClickSelfRescue, LeftTime = " .. tostring(LeftTime))
    end
    local bFeatureCanSelfRescueFinalConfirm = true
    if uPawn.ElectromagneticPulseFeature and uPawn.ElectromagneticPulseFeature:IsInDisableArea() then
      bFeatureCanSelfRescueFinalConfirm = false
    end
    if bCanClick and not bFeatureCanSelfRescueFinalConfirm then
      bCanClick = false
      local NeonConfig = require("GameLua.Mod.Neon.Gameplay.Config.NeonConfig")
      IngameTipsTools.BattleGeneralTip(NeonConfig.ElectromagneticPulseConfig.ElectromagneticCanntUseTipsID)
    end
  end
  return bCanClick
end
function BasicSkillsMenuBP:OnClickCaptiveBtn()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1013702, true)
    self.UIRoot.Button_Captive:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_TeamUpFail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BasicSkillsMenuBP:CaptivatingInterrupt()
  self.bCanShowCaptiveBtnByCaptiveFail = false
  self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_TeamUpFail:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:AddGameTimer(3.5, false, function()
    self.UIRoot.CanvasPanel_TeamUpFail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.bCanShowCaptiveBtnByCaptiveFail = true
  end)
end
function BasicSkillsMenuBP:OnClickInteractiveCancel()
  local Component = self.InteractiveComponent
  if Component and slua.isValid(Component) then
    print(bWriteLog and "[YY-D]BasicSkillsMenuBP:OnClickInteractiveCancel, Component = " .. tostring(Component))
    if Component.bAllowWhenCoolDown == true and Component:IsCoolingDown() == true and Component:GetCoolDownLeftTimeForShow() > 0 and 0 < Component.TipsIdWhenClickedInCoolDown then
      local LeftTime = Component:GetCoolDownLeftTimeForShow()
      IngameTipsTools.BattleNormalTipsByTextID(Component.TipsIdWhenClickedInCoolDown, tostring(LeftTime))
      return
    end
    if Component.GetOwner then
      local owner = Component:GetOwner()
      if owner then
        local GameplayStatics = import("GameplayStatics")
        local playerController = GameplayStatics.GetPlayerController(owner, 0)
        local character = playerController and playerController:GetPlayerCharacterSafety()
        if character then
          if owner.OnClientClickInteractiveButton then
            if owner:OnClientClickInteractiveButton(character, Component) == false then
              return
            end
          elseif Component.LuaOnClientClickInteractiveButton and Component:LuaOnClientClickInteractiveButton(character) == false then
            return
          end
          character:ServerRPCOnClickInteractiveButton(Component, 1)
        end
      end
    end
  else
    print(bWriteLog and "BasicSkillsMenuBP:Action_InteractiveComponent, HideNormalBtn, Component = " .. tostring(Component))
    self:HideNormalCDBar()
  end
end
function BasicSkillsMenuBP:ShowNormalCDBar(InteractiveConfig)
  local nDuration = InteractiveConfig.Duration or 0
  self.InteractiveComponent = InteractiveConfig.Component
  if self.bIsShowCDBar then
    return
  end
  self.bIsShowCDBar = true
  if 0 < nDuration then
    if self.nTimerID then
      self:HideNormalCDBar()
      return
    end
    local UGameplayStatics = import("GameplayStatics")
    self.StartCDRealTime = UGameplayStatics.GetRealTimeSeconds(UIUtil.GetGameInstance())
    self.CountDownTotalTime = nDuration
    self:UpdateCDCircleBar(0)
    self.UIRoot.InteractiveComponentCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if InteractiveConfig.ShowCancleButton then
      self.UIRoot.CanvasPanel_CancelUse:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      self.UIRoot.CanvasPanel_CancelUse:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if InteractiveConfig.IconPath then
      self:UpdateUI(InteractiveConfig.IconPath)
    end
    self.UIRoot.CircleBox:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.CDBox:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.nTimerID = self:AddGameTimer(0.1, true, function()
      self:CDCircle()
    end)
  else
    print(bWriteLog and "[YY-E] InteractiveUI:ShowCDBar nCountDownTotalTime is Not Valid")
  end
end
function BasicSkillsMenuBP:UpdateUI(IconPath)
  if IconPath ~= nil and self.CDBarImage ~= IconPath then
    self.CDBarImage = IconPath
    local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
    local textureOrSprite = LogicLoadTexture.LoadTextureOrSprite(self.CDBarImage)
    if textureOrSprite ~= nil then
      local Texture2D = import("/Script/Engine.Texture2D")
      local PaperSprite = import("PaperSprite")
      local BusinessHelper = import("BusinessHelper")
      if BusinessHelper.IsClassOf(textureOrSprite, PaperSprite) then
        local width, height = self.UIRoot.ICon.Brush.ImageSize.X, self.UIRoot.ICon.Brush.ImageSize.Y
        width = math.floor(width + 0.5)
        height = math.floor(height + 0.5)
        local PaperSpriteBlueprintLibrary = import("PaperSpriteBlueprintLibrary")
        local brush = PaperSpriteBlueprintLibrary.MakeBrushFromSprite(textureOrSprite, width, height)
        local controlBrush = self.UIRoot.ICon.Brush
        if controlBrush then
          brush.Margin = controlBrush.Margin
          brush.TintColor = controlBrush.TintColor
          brush.bAsyncEnabled = controlBrush.bAsyncEnabled
          brush.bOnlySoftInEditor = controlBrush.bOnlySoftInEditor
          brush.DrawAs = controlBrush.DrawAs
          brush.Tiling = controlBrush.Tiling
          brush.Mirroring = controlBrush.Mirroring
        end
        self.UIRoot.ICon:SetBrush(brush)
      elseif BusinessHelper.IsClassOf(textureOrSprite, Texture2D) then
        self.UIRoot.ICon:SetBrushFromTexture(textureOrSprite, true)
      else
        print(bWriteLog and "InteractiveUI:UpdateUI, not PaperSprite or Texture2D when path = " .. tostring(self.btnImage.AssetPathName))
      end
    end
  end
end
function BasicSkillsMenuBP:CDCircle()
  local UGameplayStatics = import("GameplayStatics")
  local CountDownElapsedTime = UGameplayStatics.GetRealTimeSeconds(UIUtil.GetGameInstance()) - self.StartCDRealTime
  local nShowCDTime = self.CountDownTotalTime - CountDownElapsedTime
  local sTime = FuncUtil.Conv_FloatToText(nShowCDTime, 1)
  local nPercent = CountDownElapsedTime / self.CountDownTotalTime
  self.UIRoot.TextBlock_ItemCDTime2:SetText(sTime)
  self:UpdateCDCircleBar(nPercent)
  if nShowCDTime <= 0 then
    self:HideNormalCDBar()
  end
end
function BasicSkillsMenuBP:UpdateCDCircleBar(nPercent)
  if nPercent then
    local uMaterial = self.UIRoot.Image_ItemCDBar:GetDynamicMaterial()
    if slua.isValid(uMaterial) then
      uMaterial:SetScalarParameterValue("Mask_Percent", nPercent)
    end
  end
end
function BasicSkillsMenuBP:HideNormalCDBar(InteractiveConfig)
  self.bIsShowCDBar = false
  self.UIRoot.InteractiveComponentCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.nTimerID then
    self:RemoveGameTimer(self.nTimerID)
    self.nTimerID = nil
  end
end
function BasicSkillsMenuBP:OnRefuseToCaptived()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter:RPC_Server_TriggerEntryEventByID(1013703, true)
  end
end
function BasicSkillsMenuBP:OnReceivedBeggingPlayer(_, _, BeggingPlayer)
  if BeggingPlayer.GetPlayerNameSafety ~= nil then
    local BeggingPlayerName = BeggingPlayer:GetPlayerNameSafety()
    print(bWriteLog and "BasicSkillsMenuBP:OnReceivedBeggingPlayer " .. BeggingPlayerName)
    IngameTipsTools.BattleNormalTipsByTextID(17382, BeggingPlayerName)
  end
end
function BasicSkillsMenuBP:OnCaptivateFinishToCaptivingPlayer(_, _, CaptivedPlayer, IsTeamSolo)
  if CaptivedPlayer.GetPlayerNameSafety ~= nil then
    local CaptivedPlayerName = CaptivedPlayer:GetPlayerNameSafety()
    local CaptivedPlayerTeamIndex = CaptivedPlayer:GetPlayerTeamIndex()
    print(bWriteLog and "BasicSkillsMenuBP:OnCaptivateFinishToCaptivingPlayer CaptivedPlayer:" .. CaptivedPlayerName .. ", CaptivedPlayerTeamIndex:" .. tostring(CaptivedPlayerTeamIndex) .. ", " .. tostring(IsTeamSolo))
    IngameTipsTools.BattleNormalTipsByTextID(29848, CaptivedPlayerName)
  end
end
function BasicSkillsMenuBP:OnCaptivateFinishToCaptivedPlayer(_, _, CaptivingPlayer)
  if CaptivingPlayer.GetPlayerNameSafety ~= nil then
    local CaptivingPlayerName = CaptivingPlayer:GetPlayerNameSafety()
    local CaptivingPlayerTeamIndex = CaptivingPlayer:GetPlayerTeamIndex()
    print(bWriteLog and "BasicSkillsMenuBP:OnCaptivateFinishToCaptivedPlayer CaptivingPlayer:" .. CaptivingPlayerName .. ", CaptivingPlayerTeamIndex:" .. tostring(CaptivingPlayerTeamIndex))
  end
end
function BasicSkillsMenuBP:OnPromptPlayerSoleToKiller(_, _, SolePlayerName)
  IngameTipsTools.BattleNormalTipsByTextID(17383, SolePlayerName)
end
function BasicSkillsMenuBP:OnCaptivateFinishToTeammate(_, _, CaptivedPlayer)
  if CaptivedPlayer.GetPlayerNameSafety ~= nil then
    local CaptivedPlayerName = CaptivedPlayer:GetPlayerNameSafety()
    print(bWriteLog and "BasicSkillsMenuBP:OnCaptivateFinishToTeammate CaptivedPlayer:" .. CaptivedPlayerName)
  end
end
function BasicSkillsMenuBP:OnCharacterNearDeathOrRescueingOtherNotify(bNearDeath, bRescueingOther)
  print(bWriteLog and "BasicSkillsMenuBP:OnCharacterNearDeathOrRescueingOtherNotify", bNearDeath, bRescueingOther)
  if bNearDeath then
    local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uLocalPlayerCharacter) then
      self:OnCanRescueOtherEvent(nil, uLocalPlayerCharacter, false)
      self:OnCanCarryOtherEvent(nil, uLocalPlayerCharacter, false)
    end
  end
  self:CheckShowNearDeathGiveupButton()
end
function BasicSkillsMenuBP:CheckShowNearDeathGiveupButton()
  printf(bWriteLog and "BasicSkillsMenuBP CheckShowNearDeathGiveupButton call")
  local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uLocalPlayerCharacter) and uLocalPlayerCharacter.bCanNearDeathGiveup then
    local bCanSelfRescue = uLocalPlayerCharacter:CanSelfRescue()
    local ECharacterHealthStatus = import("ECharacterHealthStatus")
    local bShowGiveup = not bCanSelfRescue and uLocalPlayerCharacter.HealthStatus == ECharacterHealthStatus.HasLastBreath
    local uPlayerState = uLocalPlayerCharacter:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and bShowGiveup then
      bShowGiveup = not uPlayerState.IsShowingRescueingUI
    end
    if bShowGiveup then
      printf(bWriteLog and "BasicSkillsMenuBP CheckShowNearDeathGiveupButton bShowGiveup")
      if UIManager.UI_Config_InGame.NearDeathGiveupUI then
        UIManager.ShowUI(UIManager.UI_Config_InGame.NearDeathGiveupUI)
      end
    else
      printf(bWriteLog and "BasicSkillsMenuBP CheckShowNearDeathGiveupButton !bShowGiveup")
      if UIManager.UI_Config_InGame.NearDeathGiveupUI then
        local uNearDeathUI = UIManager.GetUI(UIManager.UI_Config_InGame.NearDeathGiveupUI)
        if uNearDeathUI ~= nil and uNearDeathUI.HideUI then
          uNearDeathUI:HideUI()
        end
        UIManager.HideUI(UIManager.UI_Config_InGame.NearDeathGiveupUI)
      end
    end
  else
    printf(bWriteLog and "BasicSkillsMenuBP CheckShowNearDeathGiveupButton !uLocalPlayerCharacter or !bCanNearDeathGiveup")
  end
end
function BasicSkillsMenuBP:OnReconnect()
  print(bWriteLog and "BasicSkillsMenuBP:OnReconnect")
  self:CheckShowNearDeathGiveupButton()
end
function BasicSkillsMenuBP:OnCharacterShowOrHideSkillPrompt(bShowPrompt)
  print(bWriteLog and "BasicSkillsMenuBP:OnCharacterShowOrHideSkillPrompt bShowPrompt=" .. tostring(bShowPrompt))
  local ButtonVisibility = bShowPrompt and UEnums.ESlateVisibility.Collapsed or nil
  local NewbieVisibility = bShowPrompt and UEnums.ESlateVisibility.Collapsed or nil
  self:SetBtnVisibleFlag(ButtonVisibility, "BtnRescue", "ShowPrompt")
  self:SetBtnVisibleFlag(NewbieVisibility, "CanvasPanel_NewBieGuideSave", "ShowPrompt")
  self:SetBtnVisibleFlag(ButtonVisibility, "Button_PutDown", "ShowPrompt")
  self:SetBtnVisibleFlag(NewbieVisibility, "CanvasPanel_NewBieGuidePutDown", "ShowPrompt")
end
function BasicSkillsMenuBP:OnPlayerEnterRescueingStatus(uPlayerCharacter, bIsRescueing, bSelfRescue)
  print(bWriteLog and "BasicSkillsMenuBP:OnPlayerEnterRescueingStatus bIsRescueing=" .. tostring(bIsRescueing) .. " bSelfRescue=" .. tostring(bSelfRescue))
  if bIsRescueing and self.UIRoot.Button_PutDown:IsVisible() and slua.isValid(uPlayerCharacter) then
    self:HideCarryBackBtn(uPlayerCharacter)
  end
end
function BasicSkillsMenuBP:OnCanCarryOtherEvent(CarryWho, Owner, IsTurnInto)
  self:NewOnCanCarryOtherEvent(CarryWho, Owner, IsTurnInto)
end
function BasicSkillsMenuBP:OnCanRescueOtherEvent(RescueWho, Owner, IsTurnInto)
  self:NewOnCanRescueOtherEvent(RescueWho, Owner, IsTurnInto)
end
function BasicSkillsMenuBP:OnCanCaptivateOtherEvent(CaptivateWho, Owner, IsTurnInto)
  print(bWriteLog and "BasicSkillsMenuBP:OnCanCaptivateOtherEvent IsTurnInto=" .. tostring(IsTurnInto))
  local uOwnerPlayerController = Owner:GetPlayerControllerSafety()
  local uPlayerController = GameplayData.GetPlayerController()
  if uOwnerPlayerController ~= uPlayerController then
    return
  end
  if self.UIRoot.BtnRescue:IsVisible() then
    return
  end
  if not self.bCanShowCaptiveBtnByCaptiveFail then
    return
  end
  if not slua.isValid(CaptivateWho) then
    self:HideCaptiveBtn(Owner)
    return
  end
  self:ShowCaptiveBtn(Owner)
  local NewTint = FSlateColor(FLinearColor(1.0, 0.919986, 0.057882, 1))
  if not IsTurnInto then
    NewTint = FSlateColor(FLinearColor(1.0, 1.0, 1.0, 1))
  end
  local Brush = slua.IndexReference(self.UIRoot.Image_Captive, "Brush"):clone()
  Brush.Tint = NewTint
  self.UIRoot.Image_Captive:SetBrush(Brush)
  self.UIRoot.CanvasPanel_TeamUpFail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BasicSkillsMenuBP:OnCharacterStateChange(LiveState, uTargetCharacter)
  if not slua.isValid(self.UIRoot) then
    return
  end
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if LiveState == ExtraPlayerLiveState.InDefault then
    self:CheckColdBtn()
  else
    self.UIRoot.WidgetSwitcher_ModeSwitch:SetActiveWidgetIndex(0)
  end
end
function BasicSkillsMenuBP:OnEnterSelifeMode()
  self:HideButtonEnterSelifeMode()
end
function BasicSkillsMenuBP:OnDeathPlaybackStart()
  print(bWriteLog and "BasicSkillsMenuBP:OnDeathPlaybackStart")
  if not slua.isValid(self.UIRoot) or not self.UIRoot.LoopScrollBox_Interact then
    return
  end
  self.UIRoot.LoopScrollBox_Interact:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end