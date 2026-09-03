local ui_depth_manager = {}
local GMOpenLog = false
local base_config_util = require("client.common.uibase.base_config_util")
local local local local table_insert = table.insert
local table_remove = table.remove
local _uiMap = {}
local _uiShowStack = {}
local _registerUIMap = {}
function ui_depth_manager.RegisterUI(keyName)
  local uiInfo = prealloctable(0, 4)
  uiInfo.  _registerUIMap[keyName] = uiInfo
end
function ui_depth_manager.UnRegisterUI(keyName)
  if _registerUIMap[keyName] then
    _registerUIMap[keyName] = nil
  end
end
function ui_depth_manager._AddUI(uiInfo)
  if _uiMap[uiInfo.keyName] ~= nil then
    return
  end
  _uiMap[uiInfo.keyName] = uiInfo
end
function ui_depth_manager._RemoveUI(uiInfo)
  if _uiMap[uiInfo.keyName] == nil then
    return
  end
  _uiMap[uiInfo.keyName] = nil
end
function ui_depth_manager._GetUIInfo(keyName)
  if _uiMap[keyName] == nil then
    return nil
  end
  return _uiMap[keyName]
end
function ui_depth_manager._RemoveUIFromStack(uiInfo)
  local len = #_uiShowStack
  for index = len, 1, -1 do
    if _uiShowStack[index] == uiInfo then
      table_remove(_uiShowStack, index)
      break
    end
  end
end
local ShowUIPrintStack = function(uiInfo, zOrder)
  if GMOpenLog then
    local num = #_uiShowStack
    log(bWriteLog and "ui_depth_manager.ShowUIPrintStack keyName=" .. uiInfo.keyName .. " zOrder=" .. zOrder .. " StackSize=" .. num)
    for index = num, 1, -1 do
      log(bWriteLog and "ui_depth_manager.ShowUIPrintStack stack index:" .. index .. " depth:" .. _uiShowStack[index].depth .. ", keyName:" .. _uiShowStack[index].keyName)
    end
  end
end
local HideUIPrintStack = function(uiInfo)
  if GMOpenLog then
    local num = #_uiShowStack
    log(bWriteLog and "ui_depth_manager.HideUIPrintStack keyName=" .. uiInfo.keyName .. " StackSize=" .. num)
  end
end
function ui_depth_manager._OnRefreshUI(uiInfo, UIBase)
  ui_depth_manager._RemoveUIFromStack(uiInfo)
  local zOrder = ui_depth_manager._AutoPanelDepth(uiInfo, UIBase)
  table_insert(_uiShowStack, uiInfo)
  ShowUIPrintStack(uiInfo, zOrder)
end
function ui_depth_manager._OnShowUI(uiInfo, UIBase)
  local ui = ui_depth_manager._GetUIInfo(uiInfo.keyName)
  if ui ~= nil then
    return
  end
  ui_depth_manager._AddUI(uiInfo)
  ui_depth_manager._RemoveUIFromStack(uiInfo)
  local zOrder = ui_depth_manager._AutoPanelDepth(uiInfo, UIBase)
  table_insert(_uiShowStack, uiInfo)
  ShowUIPrintStack(uiInfo, zOrder)
end
function ui_depth_manager._HideUI(uiInfo)
  local ui = ui_depth_manager._GetUIInfo(uiInfo.keyName)
  if ui == nil then
    return
  end
  ui_depth_manager._RemoveUI(uiInfo)
  ui_depth_manager._RemoveUIFromStack(uiInfo)
  HideUIPrintStack(uiInfo)
end
function ui_depth_manager.GetTopDepth()
  local depth = 100
  local num = #_uiShowStack
  if 0 < num then
    depth = _uiShowStack[num].depth + 100
  end
  return depth
end
function ui_depth_manager._AutoPanelDepth(uiInfo, UIBase)
  local depth = 100
  local num = #_uiShowStack
  if 0 < num then
    depth = _uiShowStack[num].depth + 100
  end
  uiInfo.  if UIBase then
    UIBase:SetZOrder(depth)
  else
  end
  return depth
end
function ui_depth_manager.ShowSluaUI(keyName, UIBase, config)
  if keyName == nil then
    log_error("ui_depth_manager.ShowSluaUI keyName == nil")
    return
  end
  if not config then
    log_error("ui_depth_manager.ShowSluaUI config is nil!")
    return
  end
  if not base_config_util.IsSingleton(config) then
    return
  end
  if not base_config_util.IsMainUI(config) then
    return
  end
  if config.zOrder then
    if GMOpenLog then
      log(bWriteLog and "ui_depth_manager.ShowSluaUI config.zOrder keyName:" .. keyName)
    end
    return
  end
  local uiInfo = _registerUIMap[keyName]
  if uiInfo == nil then
    log_error("ui_depth_manager.ShowSluaUI uiInfo == nil keyName:" .. keyName)
    return
  end
  if uiInfo._bShow then
    ui_depth_manager._OnRefreshUI(uiInfo, UIBase)
  else
    uiInfo._bShow = true
    ui_depth_manager._OnShowUI(uiInfo, UIBase)
  end
end
function ui_depth_manager.HideSluaUI(keyName)
  if keyName == nil then
    log_error("ui_depth_manager.HideSluaUI keyName == nil")
    return
  end
  local uiInfo = _registerUIMap[keyName]
  if uiInfo == nil then
    log_error("ui_depth_manager.HideSluaUI uiInfo == nil keyName:" .. keyName)
    return
  end
  if uiInfo._bShow == false then
    return
  end
  uiInfo._bShow = false
  ui_depth_manager._HideUI(uiInfo)
end
function ui_depth_manager.ShowPandaUI(keyName)
  if keyName == nil then
    return nil
  end
  if GMOpenLog then
    log(bWriteLog and "ui_depth_manager.ShowPandaUI keyName=" .. keyName)
  end
  local uiInfo = ui_depth_manager._GetUIInfo(keyName)
  if uiInfo then
  else
    uiInfo = prealloctable(0, 4)
    uiInfo.  end
  if uiInfo._bShow then
    ui_depth_manager._OnRefreshUI(uiInfo, nil)
  else
    uiInfo._bShow = true
    ui_depth_manager._OnShowUI(uiInfo, nil)
  end
  return uiInfo.depth
end
function ui_depth_manager.HidePandaUI(keyName)
  if keyName == nil then
    return
  end
  if GMOpenLog then
    log(bWriteLog and "ui_depth_manager.HidePandaUI keyName=" .. keyName)
  end
  local uiInfo = ui_depth_manager._GetUIInfo(keyName)
  if uiInfo == nil then
    return
  end
  if uiInfo._bShow == false then
    return
  end
  uiInfo._bShow = false
  ui_depth_manager._HideUI(uiInfo)
end
function ui_depth_manager.ApplyPreRegisteredDepth(keyName, UIBase)
  local uiInfo = _registerUIMap[keyName]
  if uiInfo and uiInfo._bShow and uiInfo.depth then
    if UIBase then
      UIBase:SetZOrder(uiInfo.depth)
    end
    if GMOpenLog then
      log(bWriteLog and "ui_depth_manager.ApplyPreRegisteredDepth keyName=" .. keyName .. " depth=" .. uiInfo.depth)
    end
    return true
  end
  return false
end
function ui_depth_manager.GetUIShowStack()
  return _uiShowStack
end
return ui_depth_manager