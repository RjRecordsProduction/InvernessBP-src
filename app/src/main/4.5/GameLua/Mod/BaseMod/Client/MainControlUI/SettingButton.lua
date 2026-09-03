local SettingButton = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local audio_util = require("client.common.audio_util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function SettingButton:OnInitialize()
  print(bWriteLog and "SettingButton:OnInitialize")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local CV = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("CustomLayout.EnableEditableInGame")
  if CV == 1 then
    self.bQuickTweakAvailable = GamePlayTools.IsBRMode() or GamePlayTools.IsThemeBRMode() or GamePlayTools.IsTDMode()
  else
    self.bQuickTweakAvailable = false
  end
end
function SettingButton:RegistEvents()
  if self.bQuickTweakAvailable then
    self:AddControlEventByControl(self.UIRoot.EzButton_Setting, "OnTapped", self.OnTapped, self)
    self:AddControlEventByControl(self.UIRoot.EzButton_Setting, "OnLongPressed", self.OnLongPressed, self)
  end
  self:AddControlEventByControl(self.UIRoot.EzButton_Setting, "OnPressed", self.PressButtonFX, self)
  self:AddControlEventByControl(self.UIRoot.EzButton_Setting, "OnCancelled", self.ResetButtonFX, self)
  self:AddControlEventByControl(self.UIRoot.EzButton_Setting, "OnReleased", self.OnReleased, self)
  local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CustomPanel_Setting, self, "MainControlBaseUI_CustomPanel_Setting")
end
function SettingButton:OnClose()
  print(bWriteLog and "SettingButton:OnClose")
end
function SettingButton:PreEnterSetting()
  print(bWriteLog and "SettingButton:OnClicked_Button_Setting")
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
end
function SettingButton:OnTapped()
  audio_util.PlayAudio(sound_config.set)
  self:PreEnterSetting()
  UIManager.ShowUI(UIManager.UI_Config.setting_main, GamePlayTools.GetCurrentConfig("SettingCatalog"))
end
function SettingButton:OnLongPressed()
  self:ResetButtonFX()
  self:PreEnterSetting()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local EPawnState = import("EPawnState")
    if PlayerCharacter:HasState(EPawnState.Swim) or PlayerCharacter:HasState(EPawnState.Dying) then
      ShowNotice(612401128)
      return
    end
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and (PlayerController:IsSpectator() or PlayerController:IsInPetSpectator()) then
    ShowNotice(612401128)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.QuickTweakPanel_CustomLayout)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QuickTweakLayout, g_game_id, "")
end
function SettingButton:OnReleased()
  self:ResetButtonFX()
  if not self.bQuickTweakAvailable then
    self:PreEnterSetting()
    UIManager.ShowUI(UIManager.UI_Config.setting_main, GamePlayTools.GetCurrentConfig("SettingCatalog"))
  end
end
function SettingButton:ResetButtonFX()
  self.UIRoot.Image_Icon:SetColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
  self.UIRoot.Image_Icon:SetRenderTranslation(FVector2D(0.0, 0.0))
  self.UIRoot.RadialPanel_Hold:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:StopAnimation("Holding")
end
function SettingButton:PressButtonFX()
  self.UIRoot.Image_Icon:SetColorAndOpacity(FLinearColor(0.8, 0.8, 0.8, 1.0))
  self.UIRoot.Image_Icon:SetRenderTranslation(FVector2D(0.0, 1.0))
  if self.bQuickTweakAvailable then
    self.UIRoot.RadialPanel_Hold:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation("Holding", 0.0, 1, 0, 1.0)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, SettingButton)