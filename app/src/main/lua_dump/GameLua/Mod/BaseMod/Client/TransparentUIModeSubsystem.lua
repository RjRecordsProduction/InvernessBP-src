local EWidgetVisible = import("EWidgetVisible")
local TableUtil = require("common.table_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TransparentUIConfig = require("GameLua.Mod.BaseMod.Client.Config.TransparentUIConfig")
local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
local TransparentUIModeSubsystem = {}
function TransparentUIModeSubsystem:ctor()
  self.IsShow = true
  self.SpecialHideWidgets = {}
  self.IsInitHideUIFunc = false
end
function TransparentUIModeSubsystem:_PostConstruct()
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_REPLAYUI, self.OnInitReplayUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.ShowSpectatingUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.HideForReplayUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, function(_, __, TargetWidget)
    self:AddUIToForceHideWidgets(TargetWidget)
  end)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, function(_, __, TargetWidget)
    self:RemoveUIFromForceHideWidgets(TargetWidget)
  end)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("bHideIngameUIAvailable", function(bHideIngameUIAvailable)
      self:OnHideInGameUISettingChanged(bHideIngameUIAvailable)
    end)
  end
end
function TransparentUIModeSubsystem:OnInit()
end
function TransparentUIModeSubsystem:AddUIToForceHideWidgets(TargetWidget)
  table.insert(self.SpecialHideWidgets, TargetWidget)
  self:SetWidgetForceNotVisible(self.IsShow, TargetWidget)
end
function TransparentUIModeSubsystem:RemoveUIFromForceHideWidgets(TargetWidget)
  TableUtil.Remove(self.SpecialHideWidgets, TargetWidget)
  self:SetWidgetForceNotVisible(true, TargetWidget)
end
function TransparentUIModeSubsystem:ShowSpectatingUI()
  self:ForceShowUI()
end
function TransparentUIModeSubsystem:HideForReplayUI()
  self:ForceShowUI()
end
function TransparentUIModeSubsystem:OnInitReplayUI()
  self:ForceShowUI()
end
function TransparentUIModeSubsystem:OnHideInGameUISettingChanged(bHideIngameUIAvailable)
  if not bHideIngameUIAvailable then
    self:ForceShowUI()
  end
end
function TransparentUIModeSubsystem:ForceShowUI()
  if not self.IsShow then
    self:ShowOrHideWidgets()
  end
end
function TransparentUIModeSubsystem:ShowOrHideWidgets()
  if self.PreviousSlateGIState == nil then
    self.PreviousSlateGIState = ClientEVOConfig.GetSlateGIState()
    log_shipping_client("TransparentUIModeSubsystem:ShowOrHideWidgets PreviousSlateGIState: " .. tostring(self.PreviousSlateGIState))
  end
  self.IsShow = not self.IsShow
  if self.IsShow == false then
    ClientEVOConfig.ToggleSlateGI(false)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local WidgetVisible = self.IsShow and EWidgetVisible.Default or EWidgetVisible.ForceNotVisible
    PlayerController:SetVirtualJoystickWidgetRender(WidgetVisible)
  end
  for _, TargetWidget in pairs(self.SpecialHideWidgets) do
    self:SetWidgetForceNotVisible(self.IsShow, TargetWidget)
  end
  if self.IsShow == true and self.PreviousSlateGIState then
    log_shipping_client("TransparentUIModeSubsystem:ShowOrHideWidgets restore SlateGIState: " .. tostring(self.PreviousSlateGIState))
    ClientEVOConfig.ToggleSlateGI(self.PreviousSlateGIState)
    self.PreviousSlateGIState = nil
  end
end
function TransparentUIModeSubsystem:SetWidgetForceNotVisible(IsShowUI, TargetWidget)
  if slua.isValid(TargetWidget) then
    if IsShowUI then
      TargetWidget:SetWidgetRender(EWidgetVisible.Default)
    else
      TargetWidget:SetWidgetRender(EWidgetVisible.ForceNotVisible)
    end
  end
end
function TransparentUIModeSubsystem:GetIsHideUIFunctionOpen()
  if not self.IsInitHideUIFunc then
    self:ChekIsModeCanHideUI()
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local WidgetRenderCanChange = slua_GameFrontendHUD:GetWidgetRenderCanChange()
    if not WidgetRenderCanChange or PlayerController:IsSpectator() or PlayerController:IsDemoPlaySpectator() then
      return false
    else
      local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
      if SettingConfig then
        return SettingConfig.bHideIngameUIAvailable and self.IsModeCanHideUI
      else
        return false
      end
    end
  else
    return false
  end
end
function TransparentUIModeSubsystem:ChekIsModeCanHideUI()
  self.IsModeCanHideUI = false
  local uGameInstance = slua.getGameInstance()
  if not slua.isValid(uGameInstance) then
    return
  end
  local MainModeID = uGameInstance:GetMainModeID()
  print(bWriteLog and "TransparentUIModeSubsystem:ChekIsModeCanHideUI MainModeID: " .. tostring(MainModeID))
  if not MainModeID or MainModeID == 0 then
    return
  end
  if TransparentUIConfig.CanHideUIMainModeID[MainModeID] then
    local ModeID = uGameInstance:GetModeID()
    if TransparentUIConfig.CanHideUIMainModeID[MainModeID][ModeID] ~= false then
      self.IsModeCanHideUI = true
    end
  end
  self.IsInitHideUIFunc = true
end
function TransparentUIModeSubsystem:GetIsShowedGuide()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    return SettingConfig.bIsShowedHideUIGuide
  else
    return true
  end
end
function TransparentUIModeSubsystem:SetIsShowedGuide()
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    SettingConfig.bIsShowedHideUIGuide = true
    slua_GameFrontendHUD:FinishModifyUserSettings()
  end
end
function TransparentUIModeSubsystem:OnRelease()
  TransparentUIModeSubsystem.__super.OnRelease(self)
  self.SpecialHideWidgets = {}
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, TransparentUIModeSubsystem)