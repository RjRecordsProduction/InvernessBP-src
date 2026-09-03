local EPawnState = import("EPawnState")
local STExtraUIUtils = import("STExtraUIUtils")
local CustomType = require("client.logic.setting.CustomType")
local UIDataProcessingFunctionLibrary = import("UIDataProcessingFunctionLibrary")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local GameplayStatics = import("GameplayStatics")
local KismetMathLibrary = import("KismetMathLibrary")
local audio_util = require("client.common.audio_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local QuickExpressionDecalUI = {}
local ShowState = {
  None = 1,
  SubPanel = 2,
  ExpressionRing = 3
}
local BUTTON_CHANGE_SIGHT_LONG_PRESS_TIME = 0.4
function QuickExpressionDecalUI:ctor()
  print(bWriteLog and "QuickExpressionDecalUI:ctor")
  self.CurrentShowState = ShowState.None
  self.ConflictPanelList = {}
  self.SelectedPetID = 0
end
function QuickExpressionDecalUI:OnClose()
  print(bWriteLog and "QuickExpressionDecalUI:OnDestroy")
  self.StateInterruptedDelegate = nil
  self.ConflictPanelList = nil
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root)
  QuickExpressionDecalUI.__super.OnClose(self)
end
function QuickExpressionDecalUI:OnInitialize()
  print(bWriteLog and "QuickExpressionDecalUI:OnInitialize")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    self:AttachToPanel(MainControlBaseUI.Emote_DrivingControl)
  end
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0.0, 0, 0, 0)
  self:SetAlignment(0, 0)
  if self:IsSocialIsland() then
    if UIManager.UI_Config_InGame.Armory_Shop_UIBP then
      self.ConflictPanelList[UIManager.UI_Config_InGame.Armory_Shop_UIBP] = ShowState.ExpressionRing
    end
    if UIManager.UI_Config_InGame.Armory_Equip_Shop_UIBP then
      self.ConflictPanelList[UIManager.UI_Config_InGame.Armory_Equip_Shop_UIBP] = ShowState.ExpressionRing
    end
  end
  if UIManager.UI_Config_InGame.MicphoneSettingPanel then
    self.ConflictPanelList[UIManager.UI_Config_InGame.MicphoneSettingPanel] = ShowState.SubPanel
  end
  if UIManager.UI_Config_InGame.SpeakerSettingPanel then
    self.ConflictPanelList[UIManager.UI_Config_InGame.SpeakerSettingPanel] = ShowState.SubPanel
  end
  self:RefreshAndSaveRed()
end
function QuickExpressionDecalUI:RegistEvents()
  print(bWriteLog and "QuickExpressionDecalUI:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Button_ChangeSight, "OnPressed", self.OnPressedButton_ChangeSight, self)
  self:AddControlEventByControl(self.UIRoot.Button_ChangeSight, "OnReleased", self.OnReleasedButton_ChangeSight, self)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    self.StateInterruptedDelegate = PlayerCharacter.StateInterruptedHandlerBP:Add(function(state)
      if state == EPawnState.DetectPaintDecal then
        print(bWriteLog and "QuickExpressionDecalUI:RegistEvents:StateInterruptedHandlerBP()")
        self:CloseCommonPart()
      end
    end, {
      State = EPawnState.DetectPaintDecal
    })
  end
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_ON_PET_ID_CHANGE, function(_, _, _, PetID)
    print(bWriteLog and "QuickExpressionDecalUI:RegistEvents:EVENTID_ON_PET_ID_CHANGE", PetID)
    self.Selected  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET, self.OnPoccessOnPet, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_UNPOSSESSONPET, self.OnUnPoccessOnPet, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SOCIALLAND_TELEPORT_CLIENT, function()
    print(bWriteLog and "QuickExpressionDecalUI:RegistEvents:EVENTID_SOCIALLAND_TELEPORT_CLIENT")
    self:CloseCommonPart()
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.OnHideAllUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_OLD_EXPRESSION_PLAY_EMOTE, function()
    print(bWriteLog and "QuickExpressionDecalUI:RegistEvents:EVENTID_INGAME_OLD_EXPRESSION_PLAY_EMOTE")
    self:CloseCommonPart()
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, function(_, _, _, isShow)
    print(bWriteLog and "QuickExpressionDecalUI:RegistEvents:EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION", isShow)
    if not isShow then
      self:CloseCommonPart()
    end
  end, self)
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW_FOR_BATTLE, function(_, _, _, UIConfig)
    if not self.ConflictPanelList[UIConfig] or self.ConflictPanelList[UIConfig] <= 1 then
      return
    end
    print(bWriteLog and "QuickExpressionDecalUI:RegistEvents:BP_ENUM_UI_SHOW_FOR_BATTLE", UIConfig.moduleName, self.ConflictPanelList[UIConfig], self.CurrentShowState)
    if self.ConflictPanelList[UIConfig] == self.CurrentShowState then
      self:CloseCommonPart()
    end
  end, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_LOCAL_PLAYEREVENT_AVATAR_ALL_MESH_LOADED, self.OnAvatarAllMeshLoaded, self)
  self:ShowChangeFormGuide1()
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root, self, "QuickExpressionDecalUI_CanvasPanelRoot")
end
function QuickExpressionDecalUI:OnPressedButton_ChangeSight()
  print(bWriteLog and "QuickExpressionDecalUI:OnPressedButton_ChangeSight")
  self:RefreshAndSaveRed(true)
  if self.Button_ChangeSightTimer ~= nil then
    self:RemoveGameTimer(self.Button_ChangeSightTimer)
    self.Button_ChangeSightTimer = nil
  end
  if self.CurrentShowState == ShowState.None then
    self.Button_ChangeSightTimer = self:AddGameTimer(BUTTON_CHANGE_SIGHT_LONG_PRESS_TIME, false, function()
      print(bWriteLog and "QuickExpressionDecalUI Long Pressed")
      self:RemoveGameTimer(self.Button_ChangeSightTimer)
      self.Button_ChangeSightTimer = nil
      if self:ShowExpressionRing() then
        self:OpenCommonPart()
      end
      ClientTLogUtil.ReportGeneralCountByBRPhase(12001, 12003)
    end)
  else
    self:CloseCommonPart()
    audio_util.PlayAudioAsync("/Game/WwiseEvent/UI/Play_UI_Item_Expand.Play_UI_Item_Expand")
  end
  local Visibility = self.UIRoot.CanvasPanel_Guide1:GetVisibility()
  if Visibility ~= UEnums.ESlateVisibility.Collapsed then
    local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
    if AvatarChangeFormSubsystem then
      AvatarChangeFormSubsystem:UpdateGuideState(1)
    end
  end
end
function QuickExpressionDecalUI:RefreshAndSaveRed(hide)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if hide then
    self:SetWidgetVisible(self.UIRoot.Image_MoreRedPoint, false)
    log(bWriteLog and "  QuickExpressionDecalUI:RefreshAndSaveRed.  hide")
    PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eActionInBattleRed)
    return
  end
  local show = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActionInBattleRed)
  log(bWriteLog and "  QuickExpressionDecalUI:RefreshAndSaveRed. loaded show: " .. tostring(show))
  if not show or show == 0 then
    local PlayerController = GameplayData.GetPlayerController()
    show = PlayerController and PlayerController.CommerFeature.bHasPetBubblePrivilege or false
  else
    show = false
  end
  log(bWriteLog and "  QuickExpressionDecalUI:RefreshAndSaveRed. show: " .. tostring(show))
  self:SetWidgetVisible(self.UIRoot.Image_MoreRedPoint, show)
end
function QuickExpressionDecalUI:OnReleasedButton_ChangeSight()
  print(bWriteLog and "QuickExpressionDecalUI:OnReleasedButton_ChangeSight")
  if self.Button_ChangeSightTimer ~= nil then
    self:RemoveGameTimer(self.Button_ChangeSightTimer)
    self.Button_ChangeSightTimer = nil
    self.CurrentShowState = ShowState.SubPanel
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      self:AddControlEventByControl(PlayerController, "OnCharacterStatesChangeFilter", self.OnCharacterStatesChange, self)
    end
    local QuickExpressionDecalSubPanel = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalSubPanel)
    QuickExpressionDecalSubPanel = QuickExpressionDecalSubPanel or UIManager.ShowUI(UIManager.UI_Config_InGame.QuickExpressionDecalSubPanel)
    QuickExpressionDecalSubPanel:SelfHitTestInvisible()
    self:OpenCommonPart()
    ClientTLogUtil.ReportGeneralCountByBRPhase(12000, 12002)
  end
end
function QuickExpressionDecalUI:OpenCommonPart()
  print(bWriteLog and "QuickExpressionDecalUI:OpenCommonPart")
  self.UIRoot.WidgetSwitcher_ChangeSight:SetActiveWidgetIndex(1)
  self:HideGuide()
end
function QuickExpressionDecalUI:CloseCommonPart()
  print(bWriteLog and "QuickExpressionDecalUI:CloseCommonPart, self.CurrentShowState:" .. self.CurrentShowState)
  if self.CurrentShowState == ShowState.SubPanel then
    local QuickExpressionDecalSubPanel = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalSubPanel)
    if QuickExpressionDecalSubPanel then
      QuickExpressionDecalSubPanel:Collapsed()
    end
  elseif self.CurrentShowState == ShowState.ExpressionRing then
    local QuickExpression = UIManager.GetUI(UIManager.UI_Config_InGame.CommonExpression)
    if QuickExpression then
      QuickExpression:ShowOrHideRing(false)
    end
  end
  self.CurrentShowState = ShowState.None
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self:RemoveControlEventByControl(PlayerController, "OnCharacterStatesChangeFilter")
  end
  self.UIRoot.WidgetSwitcher_ChangeSight:SetActiveWidgetIndex(0)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    PlayerCharacter:DoDetectPaintDecalTarget(false, 0)
  end
end
function QuickExpressionDecalUI:ShowExpressionRing()
  if self.ConflictPanelList then
    for UIConfig, ConflictShowState in pairs(self.ConflictPanelList) do
      if UIManager.IsUIShow(UIConfig) and ConflictShowState == ShowState.ExpressionRing then
        return false
      end
    end
  end
  self.CurrentShowState = ShowState.ExpressionRing
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self:AddControlEventByControl(PlayerController, "OnCharacterStatesChangeFilter", self.OnCharacterStatesChange, self)
  end
  local ExpressionRing = self:GetExpressionRing()
  if not ExpressionRing then
    if self:IsSocialIsland() then
      ExpressionRing = UIManager.ShowUI(UIManager.UI_Config_InGame.CommonExpression)
    else
      ExpressionRing = UIManager.ShowUI(UIManager.UI_Config_InGame.CommonExpression)
    end
  end
  if self.UIRoot.CanvasPanel_Root and ExpressionRing then
    ExpressionRing:AttachToPanel(self.UIRoot.CanvasPanel_Root)
    ExpressionRing:SetAnchors(0, 0, 1, 1)
    ExpressionRing:SetOffsets(0, 0, 0, 0)
    ExpressionRing:SetAlignment(0, 0)
    ExpressionRing:SelfHitTestInvisible()
  end
  if ExpressionRing then
    ExpressionRing:ShowOrHideRing(true)
  end
  return true
end
function QuickExpressionDecalUI:GetExpressionRing()
  if self:IsSocialIsland() then
    return UIManager.GetUI(UIManager.UI_Config_InGame.CommonExpression)
  else
    return UIManager.GetUI(UIManager.UI_Config_InGame.CommonExpression)
  end
end
function QuickExpressionDecalUI:HideExpressionRing()
  local ExpressionRing = self:GetExpressionRing()
  if ExpressionRing then
    ExpressionRing:ShowOrHideRing(false)
  end
end
function QuickExpressionDecalUI:OnAvatarAllMeshLoaded()
  print(bWriteLog and "QuickExpressionDecalUI:OnAvatarAllMeshLoaded")
  self:ShowChangeFormGuide1()
end
function QuickExpressionDecalUI:OnPoccessOnPet()
  local PlayerController = GameplayData.GetPlayerController()
  print(bWriteLog and "QuickExpressionDecalUI:OnPoccessOnPet---1---" .. tostring(PlayerController))
  if not slua.isValid(PlayerController) or not PlayerController.IsInPetSpectator then
    return
  end
  local IsInPetSpectator = PlayerController:IsInPetSpectator()
  print(bWriteLog and "QuickExpressionDecalUI:OnPoccessOnPet---2---, " .. self.SelectedPetID .. ", " .. tostring(IsInPetSpectator))
  if IsInPetSpectator then
    local PetID = self.SelectedPetID
    print(bWriteLog and "QuickExpressionDecalUI:OnPoccessOnPet---3---" .. PetID)
    if PetID == 50000 or PetID == 0 then
      self.UIRoot.CanvasPanel_Root:Setvisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.CanvasPanel_Root:Setvisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if slua.isValid(MainControlBaseUI) then
      local EmoteControlWidgets = {
        MainControlBaseUI.Emote_SwimingControl,
        MainControlBaseUI.STInvalidationBox_1,
        MainControlBaseUI.Emote_DrivingControl,
        MainControlBaseUI.Emote_FlyingControl,
        MainControlBaseUI.Emote_SpectatingControl,
        MainControlBaseUI.Emote_SettingControl
      }
      for _, Widget in pairs(EmoteControlWidgets) do
        if slua.isValid(Widget) and Widget:GetVisibility() ~= UEnums.ESlateVisibility.SelfHitTestInvisible then
          Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  end
end
function QuickExpressionDecalUI:OnUnPoccessOnPet()
  print(bWriteLog and "QuickExpressionDecalUI:OnUnPoccessOnPet")
  self.UIRoot.CanvasPanel_Root:Setvisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function QuickExpressionDecalUI:OnCharacterStatesChange()
  if self.CurrentShowState ~= ShowState.None then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and (PlayerCharacter:HasState(EPawnState.GunADS) or PlayerCharacter:HasState(EPawnState.GunFire) or PlayerCharacter:HasState(EPawnState.InVehicle) or PlayerCharacter:HasState(EPawnState.DriveVehicle) or PlayerCharacter:HasState(EPawnState.InPlane) or PlayerCharacter:HasState(EPawnState.MeleeAttack)) then
      print(bWriteLog and "QuickExpressionDecalUI:OnCharacterStatesChange() CloseCommonPart")
      self:CloseCommonPart()
    end
  end
end
function QuickExpressionDecalUI:OnHideAllUI()
  print(bWriteLog and "QuickExpressionDecalUI:OnHideAllUI")
  self:CloseCommonPart()
end
function QuickExpressionDecalUI:IsSocialIsland()
  local GameState = GameplayStatics.GetGameState(self.UIRoot)
  if slua.isValid(GameState) and GameState.IsNonePlayerOnIsland then
    return true
  end
  return false
end
function QuickExpressionDecalUI:ShowChangeFormGuide1()
  print(bWriteLog and "QuickExpressionDecalUI:ShowChangeFormGuide1")
  local index = self.UIRoot.WidgetSwitcher_ChangeSight:GetActiveWidgetIndex()
  if index == 1 then
    print(bWriteLog and "QuickExpressionDecalUI:ShowChangeFormGuide1 index == 1")
    self.UIRoot.CanvasPanel_Guide1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not OwningActor or not slua.isValid(OwningActor) then
    self.UIRoot.CanvasPanel_Guide1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "QuickExpressionDecalUI:ShowChangeFormGuide1 OwningActor is invalid")
    return
  end
  local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
  if AvatarChangeFormSubsystem then
    local bShow = AvatarChangeFormSubsystem:GetGuideState(OwningActor, 1)
    print(bWriteLog and "QuickExpressionDecalUI:ShowChangeFormGuide1 bShow = " .. tostring(bShow))
    if bShow then
      self:ShowGuide(49720)
      AvatarChangeFormSubsystem:UpdateShowGuideNum()
    else
      self.UIRoot.CanvasPanel_Guide1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.CanvasPanel_Guide1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpressionDecalUI:ShowGuide(guideTipsID, showTime)
  log_format(bWriteLog and "QuickExpressionDecalUI:ShowGuide guideTipsID = %d, showTime = %s", guideTipsID, tostring(showTime))
  if self.guideTimer then
    self:RemoveGameTimer(self.GuideTimer)
    self.guideTimer = nil
  end
  self.UIRoot.TextBlock_Guide1:SetText(LocUtil.GetLocalizeResStr(guideTipsID))
  self.UIRoot.CanvasPanel_Guide1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if showTime and 0 < showTime then
    self.guideTimer = self:AddGameTimer(showTime, false, function()
      self:HideGuide()
    end)
  end
end
function QuickExpressionDecalUI:HideGuide()
  log(bWriteLog and "QuickExpressionDecalUI:HideGuide")
  if self.guideTimer then
    self:RemoveGameTimer(self.GuideTimer)
    self.guideTimer = nil
  end
  self.UIRoot.CanvasPanel_Guide1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, QuickExpressionDecalUI)