local level_unlock_jump_config = require("client.logic.level_unlock.config.level_unlock_jump_config")
local level_unlock_get_widget_config = require("client.logic.level_unlock.config.level_unlock_get_widget_config")
local level_unlock_ui_util = {}
function level_unlock_ui_util:GetTargetWidget(guideConfig, isMain, bGetLobbyMainUI)
  local TargetWidget = guideConfig.TargetWidget
  if TargetWidget ~= "" then
    return level_unlock_ui_util:GetChildWidget(guideConfig.TargetUIConfig, TargetWidget, isMain, bGetLobbyMainUI)
  end
  local GetWidgetFunction = guideConfig.GetWidgetFunction
  if GetWidgetFunction ~= "" then
    local func = level_unlock_get_widget_config[GetWidgetFunction]
    if type(func) == "function" then
      return func()
    end
  end
end
function level_unlock_ui_util:GetChildWidget(TargetUIConfig, TargetWidget, isMain, bGetLobbyMainUI)
  log(bWriteLog and "level_unlock_ui_util:GetChildWidget TargetUIConfig = " .. tostring(TargetUIConfig) .. " TargetWidget = " .. tostring(TargetWidget) .. " isMain = " .. tostring(isMain) .. " bGetLobbyMainUI = " .. tostring(bGetLobbyMainUI))
  if not TargetUIConfig or not TargetWidget then
    return
  end
  local childUI = level_unlock_ui_util:GetChild(TargetUIConfig, isMain, bGetLobbyMainUI)
  if childUI then
    log(bWriteLog and "level_unlock_ui_util:GetChildWidget 1")
    return childUI.UIRoot[TargetWidget]
  else
    log(bWriteLog and "level_unlock_ui_util:GetChildWidget 2")
  end
end
function level_unlock_ui_util:GetChild(TargetUIConfig, isMain, bGetLobbyMainUI)
  log(bWriteLog and "level_unlock_ui_util:GetChild TargetUIConfig = " .. tostring(TargetUIConfig) .. " isMain = " .. tostring(isMain) .. " bGetLobbyMainUI = " .. tostring(bGetLobbyMainUI))
  if isMain then
    if bGetLobbyMainUI then
      local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
      if mainUI then
        local childUI = mainUI:GetChildUI(UIManager.UI_Config[TargetUIConfig])
        return childUI
      end
    end
    local isInMainCity = GameStatus.IsInMainCity()
    local mainUIConfig = isInMainCity and UIManager.UI_Config.MainCity_Main_UIBP or UIManager.UI_Config.Lobby_Main_UIBP
    local mainUI = UIManager.GetUI(mainUIConfig)
    if mainUI then
      local childUI = mainUI:GetChildUI(UIManager.UI_Config[TargetUIConfig])
      return childUI
    end
  else
    local uiConfig = UIManager.UI_Config[TargetUIConfig]
    if uiConfig then
      return UIManager.GetUI(uiConfig)
    end
  end
  return nil
end
function level_unlock_ui_util:ShowNewMark(guideConfig, isMain)
  local NewSignWidget = guideConfig and guideConfig.NewSignWidget
  log_format("level_unlock_ui_util:ShowNewMark. NewSignWidget = [%s], isMain = [%s]", NewSignWidget, isMain)
  if NewSignWidget then
    local childWidget = level_unlock_ui_util:GetChildWidget(guideConfig.TargetUIConfig, NewSignWidget, isMain)
    if not childWidget then
      local targetWidget = level_unlock_ui_util:GetTargetWidget(guideConfig, isMain)
      childWidget = targetWidget and targetWidget[NewSignWidget]
    end
    if childWidget then
      level_unlock_ui_util:SetWidgetVisible(childWidget, true, NewSignWidget)
      level_unlock_ui_util:SetRedDotVisible(guideConfig, isMain, false)
    end
  end
end
function level_unlock_ui_util:HideNewMark(guideConfig, isMain)
  local NewSignWidget = guideConfig and guideConfig.NewSignWidget
  log_format("level_unlock_ui_util:HideNewMark. NewSignWidget = [%s], isMain = [%s]", NewSignWidget, isMain)
  if NewSignWidget ~= "" then
    local childWidget = level_unlock_ui_util:GetChildWidget(guideConfig.TargetUIConfig, NewSignWidget, isMain)
    if not childWidget then
      local targetWidget = level_unlock_ui_util:GetTargetWidget(guideConfig, isMain)
      childWidget = targetWidget and targetWidget[NewSignWidget]
    end
    if childWidget then
      level_unlock_ui_util:SetWidgetVisible(childWidget, false, NewSignWidget)
      level_unlock_ui_util:SetRedDotVisible(guideConfig, isMain, true)
    end
  end
end
function level_unlock_ui_util:SetRedDotVisible(guideConfig, isMain, visible)
  if guideConfig and guideConfig.TargetRedPointWidget ~= "" then
    local TargetRedPointWidget = guideConfig.TargetRedPointWidget
    log_format("level_unlock_ui_util:SetRedDotVisible. TargetRedPointWidget = [%s], isMain = [%s], visible = [%s]", TargetRedPointWidget, isMain, visible)
    local childWidget = level_unlock_ui_util:GetChildWidget(guideConfig.TargetUIConfig, TargetRedPointWidget, isMain)
    if not childWidget then
      local targetWidget = level_unlock_ui_util:GetTargetWidget(guideConfig, isMain)
      childWidget = targetWidget and targetWidget[TargetRedPointWidget]
    end
    if not childWidget then
      log_warning(bWriteLog and "level_unlock_ui_util:SetRedDotVisible not find childWidget")
      return
    end
    level_unlock_ui_util:SetWidgetVisible(childWidget, visible, TargetRedPointWidget)
  end
end
function level_unlock_ui_util:SetDynamicVisibleWidget(guideConfig, visible)
  if guideConfig and guideConfig.DynamicVisibleWidget ~= "" then
    local DynamicVisibleWidget = guideConfig.DynamicVisibleWidget
    log_format("level_unlock_ui_util:SetDynamicVisibleWidget. DynamicVisibleWidget = [%s], visible = [%s]", DynamicVisibleWidget, visible)
    local childWidget = level_unlock_ui_util:GetChildWidget(guideConfig.TargetUIConfig, DynamicVisibleWidget, false)
    if childWidget then
      level_unlock_ui_util:SetWidgetVisible(childWidget, visible)
    end
  end
end
function level_unlock_ui_util:FindFlyWidget(feature)
  log(bWriteLog and "level_unlock_ui_util:FindFlyWidget feature = " .. tostring(feature))
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local systemList = level_unlock_manager:GetSystemList()
  local unlockGuideConfig = systemList[feature]
  if not unlockGuideConfig then
    log_format("level_unlock_ui_util:FindFlyWidget not config. feature = [%s]", feature)
    return
  end
  local animConfig = level_unlock_ui_util:GetAnimConfig(unlockGuideConfig)
  if not animConfig then
    log_format("level_unlock_ui_util:FindFlyWidget not anim config. feature = [%s]", feature)
    return
  end
  local animTargetUIConfig = animConfig.AnimTargetUIConfig
  local animTargetWidget = animConfig.AnimTargetWidget
  local targetWidget = level_unlock_ui_util:GetChildWidget(animTargetUIConfig, animTargetWidget, true)
  if not targetWidget then
    return level_unlock_ui_util:GetChildWidget(animTargetUIConfig, animTargetWidget, false)
  else
    return targetWidget
  end
end
function level_unlock_ui_util:FindFlyWidgetOffset(feature)
  log(bWriteLog and "level_unlock_ui_util:FindFlyWidgetOffset feature = " .. tostring(feature))
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local systemList = level_unlock_manager:GetSystemList()
  local unlockGuideConfig = systemList[feature]
  if not unlockGuideConfig then
    log_format("level_unlock_ui_util:FindFlyWidgetOffset not config. feature = [%s]", feature)
    return
  end
  local animConfig = level_unlock_ui_util:GetAnimConfig(unlockGuideConfig)
  if not animConfig then
    log_format("level_unlock_ui_util:FindFlyWidgetOffset not config. feature = [%s]", feature)
    return
  end
  local offset = animConfig.AnimTargetOffset
  local StringUtil = require("common.string_util")
  local splits = StringUtil.SplitToNum(offset, ";")
  return {
    x = splits[1],
    y = splits[2]
  }
end
function level_unlock_ui_util:JumpToModule(feature, isMain)
  log(bWriteLog and "level_unlock_ui_util:JumpToModule feature = " .. tostring(feature) .. " isMain = " .. tostring(isMain))
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local unlockGuideConfigMap = level_unlock_manager:GetSystemList()
  local allGuideConfig = unlockGuideConfigMap[feature]
  if not allGuideConfig then
    log(bWriteLog and "level_unlock_ui_util:JumpToModule feature = " .. tostring(feature) .. " config is nil")
    return
  end
  local real_config, CallbackFunction
  local mainConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 1)
  local secondaryConfig = level_unlock_ui_util:GetGuideStepConfig(allGuideConfig, 2)
  if not isMain then
    if secondaryConfig and secondaryConfig.CallbackFunction ~= "" then
      local func = level_unlock_jump_config[secondaryConfig.CallbackFunction]
      if type(func) == "function" then
        real_config = secondaryConfig
        CallbackFunction = func
      end
    end
  elseif mainConfig and mainConfig.CallbackFunction ~= "" then
    local func = level_unlock_jump_config[mainConfig.CallbackFunction]
    if type(func) == "function" then
      real_config = mainConfig
      CallbackFunction = func
    end
  end
  if CallbackFunction then
    CallbackFunction(real_config, feature)
  elseif isMain then
    EventSystem:postEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_OPEN_MAIN, feature)
  else
    EventSystem:postEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_OPEN_SECONDARY, feature)
  end
end
local getLobbyType = function(lobbyType)
  if not lobbyType then
    local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
    local ELobbyType = level_unlock_config.ELobbyType
    if GameStatus.IsInMainCity() then
      lobbyType = ELobbyType.MainCity
    elseif GameStatus.IsIn2DLobby() then
      lobbyType = ELobbyType.Lobby
    end
    if not lobbyType then
      return nil
    end
  end
  return lobbyType
end
function level_unlock_ui_util:GetGuideStepConfig(guideConfig, step, lobbyType)
  if not guideConfig then
    return nil
  end
  lobbyType = getLobbyType(lobbyType)
  local guideList = guideConfig.guideList
  return guideList and guideList[lobbyType] and guideList[lobbyType][step]
end
function level_unlock_ui_util:GetAnimConfig(guideConfig, lobbyType)
  lobbyType = getLobbyType(lobbyType)
  local animList = guideConfig.animList
  return animList and animList[lobbyType]
end
function level_unlock_ui_util:SetWidgetVisible(widget, visible, widgetName, isButton)
  if not widget or not slua.isValid(widget) then
    return
  end
  log_format("level_unlock_ui_util:SetWidgetVisible. widgetName = [%s], widget = [%s], visible = [%s]", widgetName, widget, visible)
  local visibility
  if visible then
    if isButton then
      visibility = UEnums.ESlateVisibility.Visible
    else
      visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
    end
  else
    visibility = UEnums.ESlateVisibility.Collapsed
  end
  widget:SetWidgetVisibility(visibility)
end
function level_unlock_ui_util:CheckIsGuest()
  local loginChannel = Client.GetLoginChannel(NetInterface)
  local isGuest = loginChannel == BP_ENUM_PLAYFORM_TOURIST
  log_format("level_unlock_ui_util:CheckIsGuest. isGuest = [%s]", isGuest)
  return isGuest
end
return level_unlock_ui_util