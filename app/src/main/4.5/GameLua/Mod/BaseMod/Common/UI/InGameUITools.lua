local InGameUITools = {}
local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EGameModeType = import("EGameModeType")
local CachedMainControlPanelTochButton
function InGameUITools.SetMainControlPanelTochButton(MainControlPanelTochButton)
  Cachedend
function InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(CachedMainControlPanelTochButton) then
    print(bWriteLog and "InGameUITools.GetMainControlPanelTochButton nil")
    return nil
  end
  return CachedMainControlPanelTochButton
end
function InGameUITools.GetMainControlBaseUI()
  local UIUtil = require("client.common.ui_util")
  local uMainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(uMainControlPanelTochButton) then
    print(bWriteLog and "InGameUITools.GetMainControlBaseUI uMainControlPanelTochButton nil")
    return nil
  end
  return uMainControlPanelTochButton.MainControlBaseUI
end
function InGameUITools.GetShootingUIPanel()
  local UIUtil = require("client.common.ui_util")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    print(bWriteLog and "InGameUITools.GetShootingUIPanel MainControlPanelTochButton nil")
    return nil
  end
  return MainControlPanelTochButton.ShootingUIPanel
end
function InGameUITools.GetShootingUIPanelLuaClass()
  local UIUtil = require("client.common.ui_util")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not Game:IsValid(MainControlPanelTochButton) then
    return nil
  end
  local ShootingUIPanel = MainControlPanelTochButton.ShootingUIPanel
  if not Game:IsValid(ShootingUIPanel) then
    return nil
  end
  if not Game:IsValid(ShootingUIPanel.ShootingUIPanelMain) then
    return nil
  end
  return ShootingUIPanel.ShootingUIPanelMain.Super
end
function InGameUITools.GetSurviveInfoPanel()
  if not UIManager.UI_Config_InGame.SurviveInfoPanel then
    return nil
  end
  return UIManager.GetUI(UIManager.UI_Config_InGame.SurviveInfoPanel)
end
function InGameUITools.GetBackPackPickUpPanel()
  local uMainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(uMainControlBaseUI) then
    return nil
  end
  return uMainControlBaseUI:GetBackPackPickUpPanel()
end
function InGameUITools.GetBackpackUI()
  return UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
end
function InGameUITools.GetBasicSkillsMenuUI()
  local uMainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(uMainControlBaseUI) then
    return nil
  end
  local BasicSkillsMenuUI = uMainControlBaseUI:GetBasicSkillsMenuUI()
  if not BasicSkillsMenuUI then
    return nil
  end
  return BasicSkillsMenuUI
end
function InGameUITools.GetNewFreeCameraBtn()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return
  end
  return MainControlBaseUI.NewFreeCameraBtn
end
function InGameUITools:GetVehicleControlPanelLuaClass()
  return UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlPanel)
end
function InGameUITools.GetPlayerHPColor(nPercent, bIsDying, CustomHPColorConfig, CustomHPColorTable)
  local Default_HP_Phase_Color = CustomHPColorTable or {
    [1] = FLinearColor(0.863157, 0.090842, 0.008023, 1),
    [2] = FLinearColor(0.947917, 0.232042, 0.232042, 0.812),
    [3] = FLinearColor(1, 1, 1, 1),
    [4] = FLinearColor(1, 1, 1, 0.5)
  }
  local Default_HP_Phase_Config = CustomHPColorConfig or {
    0,
    0.25,
    0.75,
    0.99
  }
  local HPBarColor
  if bIsDying then
    HPBarColor = Default_HP_Phase_Color[1]
  else
    for nIndex, HP_Phase_Config in pairs(Default_HP_Phase_Config) do
      if HP_Phase_Config <= nPercent and Default_HP_Phase_Color[nIndex] then
        HPBarColor = Default_HP_Phase_Color[nIndex]
      end
    end
  end
  return HPBarColor
end
function InGameUITools.NeedShowVeteran()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uCurPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uCurPlayerState) then
      local eMentorPlayerType = uCurPlayerState:GetMentorPlayerType()
      local uEMentorPlayerType = import("EMentorPlayerType")
      if eMentorPlayerType and eMentorPlayerType ~= uEMentorPlayerType.MPT_NormalPlayer then
        return true
      end
    end
  end
  return false
end
function InGameUITools.GetPlayerVeteranIconPath(uPlayerState)
  if not slua.isValid(uPlayerState) then
    return
  end
  local nVeteranLevel = uPlayerState:GetVeteranPlayerLevel()
  local sPath = InGameUITools.GetPlayerVeteranIconPathByLevel(nVeteranLevel)
  return sPath
end
function InGameUITools.GetPlayerVeteranIconPathByLevel(nVeteranLevel)
  local sPath
  if nVeteranLevel == 0 then
    sPath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_duiyou_laodaixin_hui_1_png.ZD_icon_duiyou_laodaixin_hui_1_png"
  else
    local nIndex = nVeteranLevel or 0
    nIndex = nIndex + 1
    if nIndex < 2 then
      nIndex = 2
    elseif 6 < nIndex then
      nIndex = 6
    end
    sPath = string.format("/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_duiyou_laodaixin0%d_png.ZD_icon_duiyou_laodaixin0%d_png", nIndex, nIndex)
  end
  return sPath
end
function InGameUITools.IsFPP()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "InGameUITools.IsFPP GameState not valid")
    return false
  end
  return GameState.IsFPPGameMode
end
function InGameUITools.IsTDM()
  log_error("InGameUITools.IsTDM has been deprecated, please use GamePlayTools.IsTDMode()")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  return GamePlayTools.IsTDMode()
end
function InGameUITools.IsUGC()
  log_error("InGameUITools.IsUGC has been deprecated, please use GamePlayTools.IsUGCMode()")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  return GamePlayTools.IsUGCMode()
end
function InGameUITools.GetControlMode()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not slua.isValid(SettingConfig) then
    return 1
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return 1
  end
  return SettingConfig.FireMode
end
function InGameUITools.GetVehicleMode()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not slua.isValid(SettingConfig) then
    return 1
  end
  if SettingConfig.VehicleControlMode then
    return SettingConfig.VehicleControlMode
  else
    return 1
  end
end
function InGameUITools.CheckApplyCustomizeUI()
  if IsWoWEditor then
    return false
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local result = ModType ~= "PrimeGuide"
  print(bWriteLog and "InGameUITools.CheckApplyCustomizeUI " .. tostring(result))
  return result
end
function InGameUITools.GetTeamColorByIndex(nInTeamIndex)
  local TeamPanelConfig = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
  if TeamPanelConfig and TeamPanelConfig.TeamPlayerColorTable and TeamPanelConfig.TeamPlayerColorTable[nInTeamIndex] then
    return TeamPanelConfig.TeamPlayerColorTable[nInTeamIndex]
  end
  print(bWriteLog and "InGameUITools.GetTeamColorByIndex nInTeamIndex in not valid", nInTeamIndex)
  return nil
end
function InGameUITools.CheckIsDriver()
  local PC = GameplayData.GetPlayerController()
  if not slua.isValid(PC) or not PC.BP_VehicleUser then
    return false
  end
  local SeatType = PC.BP_VehicleUser.CurrentSeatType
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  return SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat
end
function InGameUITools.GetWidgetByName(UIRoot, sWidgetName)
  if not Game:IsValid(UIRoot) then
    return nil
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local UKismetStringLibrary = import("KismetStringLibrary")
  for i = 0, UIRoot:GetChildrenCount() - 1 do
    local ChildWidget = UIRoot:GetChildAt(i)
    local sName = UKismetSystemLibrary.GetObjectName(ChildWidget)
    if UKismetStringLibrary.MatchesWildcard(sName, sWidgetName, 1) then
      return ChildWidget
    end
  end
  return nil
end
function InGameUITools.SetJoystickSprintState(bShow)
  local UI = UIManager.GetUI(UIManager.UI_Config_InGame.VirtualJoystickProxy)
  if UI then
    UI:SetAutoSprintUI(bShow)
  end
end
function InGameUITools.DisplayMessageInGame(Text)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = PlayerController:GetChatComponent()
    if slua.isValid(ChatComponent) then
      ChatComponent:AddMsgInClient(Text)
    end
  end
end
return InGameUITools