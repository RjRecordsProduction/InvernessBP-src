local ui_navigation_manager = {}
local GMOpenTraceBackLog = false
local GMOpenLog = false
local local local local local table_insert = table.insert
local table_remove = table.remove
local SLobbyMainKeyName = UIManager.UI_Config.Lobby_Main_UIBP.keyName
local SLoginKeyName = UIManager.UI_Config.Login_UIBP.keyName
local old_androidback = require("client.slua.logic.androidback.androidback")
local base_config_util = require("client.common.uibase.base_config_util")
local AskQuitMap = {
  [SLoginKeyName] = true,
  [SLobbyMainKeyName] = true
}
local CannotCloseUIMap = {
  [SLoginKeyName] = true,
  [SLobbyMainKeyName] = true,
  [UIManager.UI_Config.loading.keyName] = true,
  [UIManager.UI_Config.team_comp_loading.keyName] = true,
  [UIManager.UI_Config.ModeSelection_Opening_Train_UIBP.keyName] = true,
  [UIManager.UI_Config.Lobby_Team_competition1v1_UIBP.keyName] = true
}
local MainUIStack = {}
local MainUIMap = {}
function ui_navigation_manager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ANDROID_BACK, ui_navigation_manager._OnAndroidBackWithClick, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_END, ui_navigation_manager._ClearUIStack, self)
end
function ui_navigation_manager:DefineAndResetData()
  self.EnumStyleType = {
    SLuaUI = 1,
    OldUI = 2,
    PandoraUI = 3
  }
end
local ShowUIPrintStack = function(keyName)
  if GMOpenLog then
    local num = #MainUIStack
    log(bWriteLog and "ui_navigation_manager.ShowUIPrintStack keyName=" .. keyName .. " StackSize=" .. num)
  end
end
local HideUIPrintStack = function(keyName)
  if GMOpenLog then
    local num = #MainUIStack
    log(bWriteLog and "ui_navigation_manager.HideUIPrintStack keyName=" .. keyName .. " StackSize=" .. num)
  end
end
function ui_navigation_manager:DontNeedPush(name, styleType)
  if MainUIMap[name] then
    return true
  end
  if styleType == self.EnumStyleType.OldUI and not old_androidback[name] then
    return true
  end
  return false
end
function ui_navigation_manager:UIPushOn(name, styleType)
  table_insert(MainUIStack, {name = name, styleType = styleType})
  MainUIMap[name] = true
  ShowUIPrintStack(name)
end
function ui_navigation_manager:PandoraPushOn(actId)
  if self:DontNeedPush(actId, self.EnumStyleType.PandoraUI) then
    return
  end
  table_insert(MainUIStack, {
    name = actId,
    styleType = self.EnumStyleType.PandoraUI
  })
  MainUIMap[actId] = true
end
function ui_navigation_manager:IsHavePandoraUI()
  for i, v in pairs(MainUIStack) do
    if v.styleType == self.EnumStyleType.PandoraUI then
      return true
    end
  end
  return false
end
function ui_navigation_manager:UIPop(name)
  if not MainUIMap[name] then
    return nil
  end
  MainUIMap[name] = nil
  local len = #MainUIStack
  for i = len, 1, -1 do
    local v = MainUIStack[i]
    if v.name == name then
      table_remove(MainUIStack, i)
      break
    end
  end
  HideUIPrintStack(name)
end
function ui_navigation_manager:PandoraUIPop(actId)
  self:UIPop(actId)
end
function ui_navigation_manager:IsUIInStack(name)
  return MainUIMap[name] == true
end
function ui_navigation_manager:IsAndroidStackEmpty(filterMap)
  local lastIdx = #MainUIStack
  if lastIdx == 0 then
    log_error("ui_navigation_manager:IsAndroidStackEmpty() lastIdx == 0")
    return true
  end
  local count = 0
  local uiInfo = MainUIStack[#MainUIStack]
  local config = UIManager.GetConfigByKey(uiInfo.name)
  while uiInfo do
    local isFilterUI = filterMap and filterMap[uiInfo.name]
    if not isFilterUI then
      if uiInfo.styleType == self.EnumStyleType.SLuaUI then
        if not base_config_util.IsSkipAndroidBack(config) then
          return false, uiInfo.name
        else
        end
      elseif uiInfo.styleType == self.EnumStyleType.PandoraUI then
        return false, uiInfo.name
      end
    end
    count = count + 1
    if count >= #MainUIStack then
      return true
    end
    uiInfo = MainUIStack[#MainUIStack - count]
    config = UIManager.GetConfigByKey(uiInfo.name)
  end
  return false
end
function ui_navigation_manager:GetTopUIName()
  local lastIdx = #MainUIStack
  if lastIdx == 0 then
    log_error("ui_navigation_manager:GetTopUIName() lastIdx == 0")
    return ""
  end
  local count = 0
  local uiInfo = MainUIStack[#MainUIStack]
  local config = UIManager.GetConfigByKey(uiInfo.name)
  while uiInfo do
    if uiInfo.styleType == self.EnumStyleType.SLuaUI then
      if not base_config_util.IsSkipAndroidBack(config) then
        return uiInfo.name
      end
    else
      return uiInfo.name
    end
    count = count + 1
    if count >= #MainUIStack then
      return ""
    end
    uiInfo = MainUIStack[#MainUIStack - count]
    config = UIManager.GetConfigByKey(uiInfo.name)
  end
  return ""
end
function ui_navigation_manager:GetTopVisibleUIName()
  local lastIdx = #MainUIStack
  if lastIdx == 0 then
    log_error("ui_navigation_manager:GetTopVisibleUIName() lastIdx == 0")
    return ""
  end
  local count = 0
  local uiInfo = MainUIStack[#MainUIStack]
  local config = UIManager.GetConfigByKey(uiInfo.name)
  while uiInfo do
    if uiInfo.styleType == self.EnumStyleType.SLuaUI then
      if not base_config_util.IsSkipAndroidBack(config) then
        local UI = UIManager.GetUI(config)
        if UI and UI.UIRoot:IsVisible() then
          return uiInfo.name
        end
      end
    else
      return uiInfo.name
    end
    count = count + 1
    if count >= #MainUIStack then
      return ""
    end
    uiInfo = MainUIStack[#MainUIStack - count]
    config = UIManager.GetConfigByKey(uiInfo.name)
  end
  return ""
end
function ui_navigation_manager:GetTopLargeVisibleUIName(minScreenRatio, blacklist)
  local UIUtil = require("client.common.ui_util")
  minScreenRatio = minScreenRatio or 0.9
  local lastIdx = #MainUIStack
  if lastIdx == 0 then
    log_error("ui_navigation_manager:GetTopLargeVisibleUIName() lastIdx == 0")
    return ""
  end
  local viewportSize = UIUtil.GetViewportSize()
  if not viewportSize then
    log_error("ui_navigation_manager:GetTopLargeVisibleUIName() viewportSize is nil")
    return ""
  end
  local viewportArea = viewportSize.X * viewportSize.Y
  if viewportArea <= 0 then
    log_error("ui_navigation_manager:GetTopLargeVisibleUIName() viewportArea <= 0")
    return ""
  end
  local count = 0
  local uiInfo = MainUIStack[#MainUIStack]
  local config = UIManager.GetConfigByKey(uiInfo.name)
  while uiInfo do
    if blacklist and blacklist[uiInfo.name] then
    elseif uiInfo.styleType == self.EnumStyleType.SLuaUI then
      if not base_config_util.IsSkipAndroidBack(config) then
        local UI = UIManager.GetUI(config)
        if UI and UI.UIRoot and UI.UIRoot:IsVisible() then
          local uiSize = UIUtil.GetAbsoluteSize(UI.UIRoot)
          if uiSize then
            local uiArea = uiSize.X * uiSize.Y
            local ratio = uiArea / viewportArea
            if minScreenRatio <= ratio then
              return uiInfo.name
            end
          end
        end
      end
    else
      return uiInfo.name
    end
    count = count + 1
    if count >= #MainUIStack then
      return ""
    end
    uiInfo = MainUIStack[#MainUIStack - count]
    config = UIManager.GetConfigByKey(uiInfo.name)
  end
  return ""
end
function ui_navigation_manager:GetTopUINameList(n)
  local keyNameList = {}
  local topIdx = #MainUIStack
  if topIdx == 0 then
    log_error("ui_navigation_manager:GetTopUINameList() topIdx == 0")
    return keyNameList
  end
  local uiInfo = MainUIStack[#MainUIStack]
  local config = UIManager.GetConfigByKey(uiInfo.name)
  local allCount = 0
  local matchCount = 0
  while uiInfo do
    if uiInfo.styleType == self.EnumStyleType.SLuaUI then
      if not base_config_util.IsSkipAndroidBack(config) then
        table_insert(keyNameList, uiInfo.name)
        matchCount = matchCount + 1
      end
    else
      table_insert(keyNameList, uiInfo.name)
      matchCount = matchCount + 1
    end
    allCount = allCount + 1
    if n <= matchCount then
      return keyNameList
    end
    if allCount >= #MainUIStack then
      return keyNameList
    end
    uiInfo = MainUIStack[#MainUIStack - allCount]
    config = UIManager.GetConfigByKey(uiInfo.name)
  end
  return keyNameList
end
local AndroidBackForSLuaUI = function(config, auto)
  if not config then
    log_error("ui_navigation_manager:AndroidBackForSLuaUI config == nil")
    return
  end
  local uiInst = UIManager.GetUI(config)
  if uiInst == nil then
    log_error("ui_navigation_manager:AndroidBackForSLuaUI uiInst == nil" .. config.keyName)
    return
  end
  if GMOpenLog then
    log(bWriteLog and "ui_navigation_manager:AndroidBackForSLuaUI " .. config.keyName)
  end
  if auto == nil then
    log_error("AndroidBackForSLuaUI auto == nil ")
    auto = true
  end
  if uiInst.OnAndroidBack then
    uiInst:OnAndroidBack(auto)
  else
    UIManager.CloseUI(config)
  end
end
local AndroidBackForOldUI = function(className)
  local closeFunc = old_androidback[className]
  closeFunc()
end
local AndroidBackForPandora = function(name)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  pandoraLogic.CloseCurAct(name)
end
local AskQuitGame = function()
  require("client.umg.bp_global")
  EventAndroidQuitGame()
end
function ui_navigation_manager:_OnAndroidBackWithClick()
  local uiInfo = MainUIStack[#MainUIStack]
  if not uiInfo then
    AskQuitGame()
    return
  end
  if uiInfo.styleType == self.EnumStyleType.SLuaUI then
    local func = function(uiInfo2)
      local config = UIManager.GetConfigByKey(uiInfo2.name)
      if AskQuitMap[uiInfo2.name] then
        AskQuitGame()
        return true
      elseif base_config_util.IsSkipAndroidBack(config) then
        return false
      elseif base_config_util.IsBanAndroidBack(config) then
        if GMOpenLog then
          log(bWriteLog and "  : ui_navigation_manager:_OnAndroidBackWithClick BanAndroidBack: " .. tostring(uiInfo2.name))
        end
        return true
      else
        AndroidBackForSLuaUI(config, false)
        return true
      end
    end
    local count = 0
    while uiInfo do
      local bBreak = func(uiInfo)
      if bBreak then
        break
      end
      count = count + 1
      if count >= #MainUIStack then
        log_error(string.format("ui_navigation_manager:_OnAndroidBackWithClick:stack count >= #MainUIStack. count=%d, stackSize=%d, topUI=%s", count, #MainUIStack, MainUIStack[#MainUIStack] and MainUIStack[#MainUIStack].name or "nil"))
        return
      end
      uiInfo = MainUIStack[#MainUIStack - count]
    end
  elseif uiInfo.styleType == self.EnumStyleType.PandoraUI then
    AndroidBackForPandora(uiInfo.name)
  else
    AndroidBackForOldUI(uiInfo.name)
  end
end
function ui_navigation_manager:AndroidBackToLobby()
  if GMOpenLog then
    log(bWriteLog and "ui_navigation_manager:AndroidBackToLobby")
  end
  self:AndroidBackToUI(SLobbyMainKeyName, false)
end
function ui_navigation_manager:ForceAndroidBackToLobby()
  if GMOpenLog then
    log(bWriteLog and "ui_navigation_manager:ForceAndroidBackToLobby")
  end
  self:AndroidBackToUI(SLobbyMainKeyName, true)
end
function ui_navigation_manager:AndroidBackToUI(keyName, ignoreBan)
  if GMOpenTraceBackLog then
    log(bWriteLog and "ui_navigation_manager:AndroidBackUIStack traceback:" .. debug.traceback())
  end
  if keyName == SLobbyMainKeyName then
    EventSystem:postEvent(EVENTTYPE_OLD_WIDGET, EVENTID_PRE_CLOSE_ALL_UI)
  end
  local uiInfo = MainUIStack[#MainUIStack]
  if uiInfo and uiInfo.name == keyName then
    return
  end
  local skipCount = 0
  local lastUIInfo
  local count = 0
  local maxCount = 50
  while uiInfo do
    if lastUIInfo == uiInfo then
      skipCount = skipCount + 1
    elseif uiInfo.styleType == self.EnumStyleType.SLuaUI then
      local config = UIManager.GetConfigByKey(uiInfo.name)
      if ignoreBan then
        if base_config_util.IsSkipAndroidBack(config) then
          skipCount = skipCount + 1
        elseif not CannotCloseUIMap[uiInfo.name] then
          AndroidBackForSLuaUI(config, true)
        else
          skipCount = skipCount + 1
        end
      elseif base_config_util.IsSkipAndroidBack(config) then
        skipCount = skipCount + 1
      elseif base_config_util.IsBanAndroidBack(config) then
        skipCount = skipCount + 1
      else
        AndroidBackForSLuaUI(config, true)
      end
    elseif uiInfo.styleType == self.EnumStyleType.PandoraUI then
      AndroidBackForPandora(uiInfo.name)
    else
      AndroidBackForOldUI(uiInfo.name)
    end
    if skipCount >= #MainUIStack then
      log_error(string.format("ui_navigation_manager:AndroidBackToUI:stack skipCount >= #MainUIStack. keyName=%s, skipCount=%d, stackSize=%d, topUI=%s, ignoreBan=%s", tostring(keyName), skipCount, #MainUIStack, MainUIStack[#MainUIStack] and MainUIStack[#MainUIStack].name or "nil", tostring(ignoreBan)))
      return
    end
    lastUIInfo = uiInfo
    uiInfo = MainUIStack[#MainUIStack - skipCount]
    if uiInfo.name == keyName then
      break
    end
    count = count + 1
    if maxCount < count then
      log_error(string.format("ui_navigation_manager:AndroidBackToUI:stack count >= maxCount. keyName=%s, count=%d, stackSize=%d, topUI=%s, ignoreBan=%s", tostring(keyName), count, #MainUIStack, MainUIStack[#MainUIStack] and MainUIStack[#MainUIStack].name or "nil", tostring(ignoreBan)))
      return
    end
  end
end
function ui_navigation_manager:_ClearUIStack()
  if GMOpenLog then
    log(bWriteLog and "ui_navigation_manager:ClearUIStack #MainUIStack\239\188\154" .. #MainUIStack)
  end
  MainUIStack = {}
  MainUIMap = {}
end
local FilterTopUI = {
  GM_WhitePoint = 1,
  LoginLobby_Timestamp_BP = 1,
  Lobby_Click_Animation = 1,
  Lobby_Watermark_BP = 1,
  Common_Mask_UIBP = 1,
  connect_wait = 1,
  team_main = 1,
  PopupTip = 1
}
local PlaceholderChildUI = {
  ChildUIWithoutBpPath = true,
  ChildUIWithoutBpPathForChat = true,
  ChildUIWithoutBpPathAsy = true,
  ChildUIWithoutLuaAndBpPath = true,
  ChildUIWithoutLuaAndBpPathAsy = true
}
function ui_navigation_manager:DEV_GetRealTopUIConfig()
  local lastIdx = #MainUIStack
  if lastIdx == 0 then
    return ""
  end
  local topConfig
  for i = #MainUIStack, 1, -1 do
    local name = MainUIStack[i].name
    if name and name ~= "" and not FilterTopUI[name] then
      topConfig = UIManager.GetConfigByKey(name)
      if topConfig and topConfig.path then
        break
      end
      topConfig = nil
    end
  end
  if not topConfig then
    return ""
  end
  local result = topConfig.path:match("%.([^%.]+)$") or topConfig.keyName or ""
  local maxDepth = 1
  local depth = 0
  local ui = UIManager.GetUI(topConfig)
  while ui and ui._childUIList and maxDepth > depth do
    depth = depth + 1
    local found
    for i = #ui._childUIList, 1, -1 do
      local child = ui._childUIList[i]
      local cfg = child._config
      if cfg and cfg.keyName and not PlaceholderChildUI[cfg.keyName] and UIManager.GetConfigByKey(cfg.keyName) then
        found = child
        break
      end
    end
    if not found then
      break
    end
    local childPath = found._config.path
    local shortName = childPath and childPath:match("%.([^%.]+)$") or found._config.keyName or "?"
    result = result .. ">" .. shortName
    ui = found
  end
  return result
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cui_navigation_manager = class(CModuleBase, nil, ui_navigation_manager)
return Cui_navigation_manager