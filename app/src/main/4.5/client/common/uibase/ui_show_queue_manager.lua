local StringUtil = require("common.string_util")
local TableUtil = require("common.table_util")
local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
local ui_show_queue_element_builder = require("client.common.uibase.ui_show_queue_element_builder")
local ui_show_queue_server_data = require("client.common.uibase.ui_show_queue_server_data")
local ui_show_queue_limit_check = require("client.common.uibase.ui_show_queue_limit_check")
local ui_show_queue_gm_notice = require("client.common.uibase.ui_show_queue_gm_notice")
local ui_show_queue_table_query = require("client.common.uibase.ui_show_queue_table_query")
local ui_show_manager = require("client.common.uibase.ui_show_manager")
local timer_ticker = require("common.time_ticker")
local EShowLobbyType = ui_show_queue_config.EShowLobbyType
local EPlayerType = ui_show_queue_config.EPlayerType
local EPlayerReturnType = ui_show_queue_config.EPlayerReturnType
local EUIBigType = ui_show_queue_config.EUIBigType
local EUISmallType = ui_show_queue_config.EUISmallType
local InTargetLobbyFuncTable = ui_show_queue_config.InTargetLobbyFuncTable
local ECantAddReason = ui_show_queue_config.ECantAddReason
local ui_show_queue_manager = {
  sortList = {},
  sortListCurUI = nil,
  directList = {},
  directListUIShowStatus = {},
  queueTimer = nil,
  reShowTimer = nil,
  pendingImmediateReShow = false,
  isBlock = false,
  ignoreControlCfg = false,
  onceBlockDelayTimer = false,
  smallTypeBlockContainer = {}
}
function ui_show_queue_manager.OnLogin()
  ui_show_queue_manager._Init()
  ui_show_queue_manager._RegisterEvent()
end
function ui_show_queue_manager.OnLogOut()
  ui_show_queue_manager._Clear()
  ui_show_queue_server_data.Clear()
  ui_show_queue_gm_notice.Clear()
  ui_show_queue_manager._UnRegisterEvent()
end
function ui_show_queue_manager.AddOneUI(uiConfig, ...)
  log(bWriteLog and "ui_show_queue_manager.AddOneUI keyName = " .. tostring(uiConfig.keyName))
  if not uiConfig.keyName then
    log_tree("ui_show_queue_manager.AddOneUI empty keyNameConfig = ", uiConfig)
    return UIManager.DirectShowUI(uiConfig, ...), false
  end
  local lqcUIConfig, ignorePlayerType = ui_show_queue_manager.GetLobbyQueueControl_UIConfig(uiConfig, ...)
  if not lqcUIConfig then
    log_warning(bWriteLog and "ui_show_queue_manager.AddOneUI lqcUIConfig is nil")
    return UIManager.DirectShowUI(uiConfig, ...), false
  end
  ui_show_queue_manager._SetUIConfigContainer(uiConfig, lqcUIConfig)
  local canAdd, returnData
  local isUnLimitUI = ui_show_queue_manager._IsUnLimitUI(lqcUIConfig)
  log(bWriteLog and "ui_show_queue_manager.AddOneUI isUnLimitUI = " .. tostring(isUnLimitUI))
  if ignorePlayerType then
    canAdd = true
    returnData = nil
  else
    canAdd, returnData = ui_show_queue_manager._CheckCanAdd(lqcUIConfig)
  end
  if not canAdd then
    log_warning(bWriteLog and "ui_show_queue_manager.AddOneUI return _CheckCanAdd")
    ui_show_queue_gm_notice.ShowGMNotice(lqcUIConfig, returnData, canAdd)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_SHOW_QUEUE_NOT_CAN_ADD, uiConfig, returnData)
    return nil, false
  end
  if not isUnLimitUI then
    return ui_show_queue_manager._AddOneUIToSortList(lqcUIConfig, uiConfig, ...)
  else
    return ui_show_queue_manager._AddOneUIToDirectList(lqcUIConfig, uiConfig, ...)
  end
end
function ui_show_queue_manager.GetLobbyQueueControl_UIConfig(uiConfig, ...)
  if not uiConfig then
    log(bWriteLog and "ui_show_queue_manager.GetLobbyQueueControl_UIConfig uiConfig is nil")
    return
  end
  local uiParams = table.pack(...)
  local ParamTablesTab = uiParams[uiParams.n]
  local queueUIKey, param1, ignorePlayerType = ui_show_queue_table_query.GetConfigParam(uiConfig, ParamTablesTab)
  local lqcUIConfig = ui_show_queue_table_query.GetTargetLobbyQueueControl_UIConfig(uiConfig.keyName, param1, queueUIKey)
  return lqcUIConfig, ignorePlayerType
end
function ui_show_queue_manager.CheckCanUseQueue(uiConfig, ...)
  if not uiConfig then
    log(bWriteLog and "ui_show_queue_manager.CheckCanUseQueue uiConfig is nil")
    return
  end
  local uiParams = table.pack(...)
  local queueUIKey, param1 = ui_show_queue_table_query.GetConfigParam(uiConfig, uiParams[uiParams.n])
  local uiKey = ui_show_queue_table_query.GetTargetLobbyQueueControl_UIKey(uiConfig.keyName, param1, queueUIKey)
  return uiKey ~= nil
end
function ui_show_queue_manager.OnUIClose(uiConfig, ParamTable)
  local keyName = uiConfig.keyName
  local isClearSign = false
  if ui_show_queue_manager.sortListCurUI == keyName then
    log(bWriteLog and "ui_show_queue_manager.OnUIClose sortListCurUI clear keyName = " .. tostring(keyName))
    ui_show_queue_manager.sortListCurUI = nil
    isClearSign = true
  end
  if ui_show_queue_manager.directListUIShowStatus[keyName] then
    log(bWriteLog and "ui_show_queue_manager.OnUIClose directListUIShowStatus clear keyName = " .. tostring(keyName))
    ui_show_queue_manager.directListUIShowStatus[keyName] = nil
    isClearSign = true
  end
  if not isClearSign then
    local isRemoveSort, isRemoveDirect
    if ui_show_queue_manager.CheckCanUseQueue(uiConfig, ParamTable) then
      isRemoveSort = ui_show_queue_manager._RemoveOneFromSortList(uiConfig, ParamTable)
      isRemoveDirect = ui_show_queue_manager._RemoveOneFromDirectList(uiConfig, ParamTable)
    end
    if isRemoveSort or isRemoveDirect then
      log_format("ui_show_queue_manager.OnUIClose return keyName = %s, isRemoveSort = %s, isRemoveDirect = %s", keyName, isRemoveSort, isRemoveDirect)
      return
    end
  end
  ui_show_queue_manager._ReShowUI()
end
function ui_show_queue_manager.SetIsBlock(isBlock, forceCloseCurrentShow)
  log_format("ui_show_queue_manager.SetIsBlock isBlock = %s, forceCloseCurrentShow = %s", isBlock, forceCloseCurrentShow)
  ui_show_queue_manager.  if not ui_show_queue_manager.isBlock then
    ui_show_queue_manager._ReShowUI()
  elseif forceCloseCurrentShow then
    ui_show_queue_manager._CloseCurrentSortUI()
  end
end
function ui_show_queue_manager.SetIgnoreControlCfg(isIgnore)
  ui_show_queue_manager.ignoreControlCfg = isIgnore
end
function ui_show_queue_manager.SetOnceBlockDelayTimer()
  log(bWriteLog and "ui_show_queue_manager.SetOnceBlockDelayTimer set true")
  ui_show_queue_manager.onceBlockDelayTimer = true
end
function ui_show_queue_manager.CancelOnceBlockDelayTimer()
  log(bWriteLog and "ui_show_queue_manager.CancelOnceBlockDelayTimer set false")
  ui_show_queue_manager.onceBlockDelayTimer = false
end
function ui_show_queue_manager.BlockSmallType(list)
  log_tree("ui_show_queue_manager.BlockSmallType list = ", list)
  for _, smallTypeID in pairs(list) do
    ui_show_queue_manager._SetSmallTypeBlock(smallTypeID, true)
  end
end
function ui_show_queue_manager.ReleaseSmallTypeBlock(list)
  log_tree("ui_show_queue_manager.ReleaseSmallTypeBlock list = ", list)
  for _, smallTypeID in pairs(list) do
    ui_show_queue_manager._SetSmallTypeBlock(smallTypeID, false)
  end
end
function ui_show_queue_manager.RemoveSortListByMatcher(UIKey, matcher)
  if not UIKey or type(matcher) ~= "function" then
    log_warning("ui_show_queue_manager.RemoveSortListByMatcher invalid arg, UIKey = " .. tostring(UIKey))
    return 0
  end
  local removeCount = 0
  local len = #ui_show_queue_manager.sortList
  log_format("ui_show_queue_manager.RemoveSortListByMatcher enter, UIKey = %s, sortList len = %d", UIKey, len)
  for i = len, 1, -1 do
    local element = ui_show_queue_manager.sortList[i]
    if element and element.lqcUIConfig and element.lqcUIConfig.UIKey == UIKey then
      local ok, hit = pcall(matcher, element.args)
      if ok and hit then
        table.remove(ui_show_queue_manager.sortList, i)
        removeCount = removeCount + 1
        log_format("ui_show_queue_manager.RemoveSortListByMatcher removed UIKey = %s, addQueueTime = %s", UIKey, element.addQueueTime)
      elseif not ok then
        log_warning_format("ui_show_queue_manager.RemoveSortListByMatcher matcher error, UIKey = %s, err = %s", UIKey, tostring(hit))
      end
    end
  end
  log_format("ui_show_queue_manager.RemoveSortListByMatcher exit, UIKey = %s, removeCount = %d", UIKey, removeCount)
  return removeCount
end
function ui_show_queue_manager.OnPreSwitchGameStatus(_, _, data)
  if not data then
    return
  end
  local preStatus = data.pre
  local currentStatus = data.current
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preStatus, currentStatus) then
    log(bWriteLog and "ui_show_queue_manager.OnPreSwitchGameStatus Enter fighting from lobby or main city")
    ui_show_queue_manager._ClearQueueData()
  end
end
function ui_show_queue_manager._Init()
  local LogicLobbyPopuiHandler = require("client.network.Protocol.LogicLobbyPopuiHandler")
  LogicLobbyPopuiHandler.send_get_popui_show_count_req()
  if not ui_show_queue_manager.queueTimer then
    ui_show_queue_manager.queueTimer = timer_ticker.AddTimerLoop(1, ui_show_queue_manager._OnTimerHandler, TIMER_INFINITE, ui_show_queue_config.TimerInterval)
  end
  ui_show_queue_manager._InitSmallTypeBlockContainer()
end
function ui_show_queue_manager._InitSmallTypeBlockContainer()
  ui_show_queue_manager.smallTypeBlockContainer = {}
  for _, smallTypeID in pairs(EUISmallType) do
    ui_show_queue_manager.smallTypeBlockContainer[smallTypeID] = false
  end
end
function ui_show_queue_manager._RegisterEvent()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, ui_show_queue_manager.OnPreSwitchGameStatus)
  EventSystem:registEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_OPEN, ui_show_queue_manager._OnJumpModuleOpen)
end
function ui_show_queue_manager._UnRegisterEvent()
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, ui_show_queue_manager.OnPreSwitchGameStatus)
  EventSystem:unregistEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_OPEN, ui_show_queue_manager._OnJumpModuleOpen)
end
function ui_show_queue_manager._Clear()
  ui_show_queue_manager._ClearReShowTimer()
  ui_show_queue_manager._ClearQueueTimer()
  ui_show_queue_manager._ClearQueueData()
  ui_show_queue_manager.CancelOnceBlockDelayTimer()
end
function ui_show_queue_manager._ClearQueueTimer()
  if ui_show_queue_manager.queueTimer then
    timer_ticker.RemoveTimer(ui_show_queue_manager.queueTimer)
    ui_show_queue_manager.queueTimer = nil
  end
end
function ui_show_queue_manager._ClearReShowTimer()
  if ui_show_queue_manager.reShowTimer then
    timer_ticker.RemoveTimer(ui_show_queue_manager.reShowTimer)
    ui_show_queue_manager.reShowTimer = nil
  end
  ui_show_queue_manager.pendingImmediateReShow = false
end
function ui_show_queue_manager._ClearQueueData()
  ui_show_queue_manager.sortList = {}
  ui_show_queue_manager.sortListCurUI = nil
  ui_show_queue_manager.directList = {}
  ui_show_queue_manager.directListUIShowStatus = {}
end
function ui_show_queue_manager._OnTimerHandler()
  ui_show_queue_manager._DoReShowUI()
end
function ui_show_queue_manager._CheckCanAdd(lqcUIConfig)
  log(bWriteLog and "ui_show_queue_manager._CheckCanAdd id = " .. (lqcUIConfig and lqcUIConfig.UIKey or "nil"))
  if ui_show_queue_manager.ignoreControlCfg then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckCanAdd ignoreControlCfg")
    return true
  end
  local lqcUIPlayerTypeConfig = ui_show_queue_table_query.GetTargetLobbyQueueControl_UIPlayerTypeConfig(lqcUIConfig.UIKey)
  if not lqcUIPlayerTypeConfig then
    log(bWriteLog and "ui_show_queue_manager._CheckCanAdd UIPlayerTypeConfig is nil")
    return true
  end
  local pReturnData = ui_show_queue_limit_check.CheckIsReturnLimit(lqcUIPlayerTypeConfig)
  local dayFromRegister = pReturnData.dayFromRegister
  local returnData = TableUtil.FastCopyTable(ui_show_queue_config.GMReturnStruct)
  returnData.uiPlayerTypeConfigID = lqcUIPlayerTypeConfig.ID
  returnData.registerDay = dayFromRegister
  returnData.returnType = pReturnData.ReturnType
  returnData.returnParam = pReturnData.returnParam
  returnData.returnLoginCount = pReturnData.returnLoginCount
  returnData.returnFirstDay = pReturnData.isReturnFirstDay
  returnData.returnLimitEndTime = pReturnData.returnLimitEndTime
  returnData.cantAddReason = pReturnData.cantAddReason
  if pReturnData.isReturnLimit then
    log(bWriteLog and "ui_show_queue_manager._CheckCanAdd return isReturnLimit")
    return false, returnData
  end
  if ui_show_queue_limit_check.CheckIsShowCountLimit(lqcUIConfig, lqcUIPlayerTypeConfig, returnData) then
    log(bWriteLog and "ui_show_queue_manager._CheckCanAdd return isShowCountLimit")
    return false, returnData
  end
  return true, returnData
end
function ui_show_queue_manager._SetUIConfigContainer(uiConfig, lqcUIConfig)
  if not uiConfig or not lqcUIConfig then
    return
  end
  local smallType = lqcUIConfig.SmallType
  local targetContainerName
  if smallType == EUISmallType.Popup_RightBottom then
    targetContainerName = UIContainers.Top
  end
  uiConfig.containerName = uiConfig.containerName or targetContainerName
end
function ui_show_queue_manager._CheckOneCanShow(lqcUIConfig, showLobbyStatusCache)
  if ui_show_queue_manager.isBlock then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneCanShow isBlock")
    return false
  end
  if ui_show_queue_manager.smallTypeBlockContainer[lqcUIConfig.SmallType] then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneCanShow isSmallTypeBlock, smallType = " .. lqcUIConfig.SmallType)
    return false
  end
  local hasShowWaitingInfo = ui_show_manager.CheckHasShowWaitingInfo()
  if hasShowWaitingInfo then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneCanShow return hasShowWaitingInfo")
    return false
  end
  local filterUIMap = {}
  local hasRoleData = DataMgr.roleData and DataMgr.roleData.uid ~= ""
  local isInTargetLobby = not hasRoleData
  if hasRoleData then
    showLobbyStatusCache = showLobbyStatusCache or {}
    local showLobbyArr = StringUtil.Split(lqcUIConfig.LobbyType, "|")
    for _, v in ipairs(showLobbyArr) do
      local lobbyID = tonumber(v)
      local lobbyFunc = InTargetLobbyFuncTable[lobbyID]
      if not lobbyFunc then
        log_warning(bWriteLog and "ui_show_queue_manager._CheckOneCanShow lobbyFunc is nil, lobbyID = " .. tostring(lobbyID))
        return false
      end
      if showLobbyStatusCache[lobbyID] == nil then
        showLobbyStatusCache[lobbyID] = lobbyFunc and lobbyFunc() or false
      end
      local tempInTargetLobby = showLobbyStatusCache[lobbyID]
      log(bWriteLog and "ui_show_queue_manager._CheckOneCanShow lobbyID = " .. lobbyID .. ", tempInTargetLobby = " .. tostring(tempInTargetLobby))
      if tempInTargetLobby then
        isInTargetLobby = true
        local tempFilterMap = ui_show_queue_table_query.GetLobbyTypeConfig(lobbyID)
        for uikeyName, _ in pairs(tempFilterMap.filterMap) do
          filterUIMap[uikeyName] = true
        end
      end
    end
  end
  if not isInTargetLobby then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneCanShow return isInTargetLobby")
    return false
  end
  log_tree("ui_show_queue_manager._CheckOneCanShow filterUIMap", filterUIMap)
  if lqcUIConfig.UIStackCheck then
    local isAndroidStackEmpty, failUIKey = UIManager.IsAndroidStackEmpty(filterUIMap)
    if not isAndroidStackEmpty then
      log_warning(bWriteLog and "ui_show_queue_manager._CheckOneCanShow return isAndroidStackEmpty. failUIKey = " .. failUIKey)
      return false
    end
  end
  log(bWriteLog and "ui_show_queue_manager._CheckOneCanShow UIKey = " .. tostring(lqcUIConfig.UIKey) .. " return true")
  return true
end
function ui_show_queue_manager._CheckOneDirectCanShow(lqcUIConfig)
  if ui_show_queue_manager.isBlock then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneDirectCanShow isBlock")
    return false
  end
  if ui_show_queue_manager.smallTypeBlockContainer[lqcUIConfig.SmallType] then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneDirectCanShow isSmallTypeBlock, smallType = " .. lqcUIConfig.SmallType)
    return false
  end
  local keyName = lqcUIConfig.KeyName
  log(bWriteLog and "ui_show_queue_manager._CheckOneDirectCanShow keyName = " .. tostring(keyName))
  local uiConfig = UIManager.GetConfigByKey(keyName)
  if not uiConfig then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneDirectCanShow keyName = " .. tostring(keyName) .. " config is nil")
    return false
  end
  if ui_show_queue_manager.directListUIShowStatus[keyName] then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckOneDirectCanShow keyName = " .. tostring(keyName) .. " ui is exist")
    return false
  end
  return true
end
function ui_show_queue_manager._IsUnLimitUI(lqcUIConfig)
  return lqcUIConfig.IsUnlimited
end
function ui_show_queue_manager._ReShowUI(delayTime, skipOnceBlock)
  log_format("ui_show_queue_manager._ReShowUI delayTime = %s, skipOnceBlock = %s", delayTime, skipOnceBlock)
  if ui_show_queue_manager.pendingImmediateReShow and delayTime ~= 0 then
    log(bWriteLog and "ui_show_queue_manager._ReShowUI ignored because pendingImmediateReShow = true")
    return
  end
  if ui_show_queue_manager.reShowTimer then
    timer_ticker.RemoveTimer(ui_show_queue_manager.reShowTimer)
    ui_show_queue_manager.reShowTimer = nil
  end
  log(bWriteLog and "ui_show_queue_manager._ReShowUI onceBlockDelayTimer = " .. tostring(ui_show_queue_manager.onceBlockDelayTimer))
  if not skipOnceBlock and ui_show_queue_manager.onceBlockDelayTimer then
    log(bWriteLog and "ui_show_queue_manager._ReShowUI Now Show")
    ui_show_queue_manager.CancelOnceBlockDelayTimer()
    ui_show_queue_manager.pendingImmediateReShow = false
    ui_show_queue_manager._DoReShowUI()
    return
  end
  local actualDelay = delayTime or ui_show_queue_config.ReShowDelayTime
  log(bWriteLog and "ui_show_queue_manager._ReShowUI delayTime = " .. actualDelay)
  if actualDelay == 0 then
    ui_show_queue_manager.pendingImmediateReShow = true
  end
  ui_show_queue_manager.reShowTimer = timer_ticker.AddTimerOnce(actualDelay, function()
    log(bWriteLog and "ui_show_queue_manager._ReShowUI Delay Show")
    ui_show_queue_manager.reShowTimer = nil
    ui_show_queue_manager.pendingImmediateReShow = false
    ui_show_queue_manager._DoReShowUI()
  end)
end
function ui_show_queue_manager._DoReShowUI()
  log(bWriteLog and "ui_show_queue_manager._DoReShowUI")
  ui_show_queue_manager._CheckListSignIsExist()
  ui_show_queue_manager._ShowUIFromSortList()
  ui_show_queue_manager._ShowUIFromDirectList()
end
function ui_show_queue_manager._SetSmallTypeBlock(smallTypeID, isBlock)
  log_format("ui_show_queue_manager._SetSmallTypeBlock smallTypeID = %d, isBlock = %s", smallTypeID, isBlock)
  if not smallTypeID then
    return
  end
  if ui_show_queue_manager.smallTypeBlockContainer[smallTypeID] ~= nil then
    ui_show_queue_manager.smallTypeBlockContainer[smallTypeID] = isBlock
  end
end
function ui_show_queue_manager._CheckIsSmallTypeBlock(smallTypeID)
  return ui_show_queue_manager.smallTypeBlockContainer[smallTypeID]
end
function ui_show_queue_manager._SafeLogSortList()
  log_format("ui_show_queue_manager._SafeLogSortList. sortList count = %s", #ui_show_queue_manager.sortList)
  for i, element in ipairs(ui_show_queue_manager.sortList) do
    local lqcUIConfig = element.lqcUIConfig
    local argsStr = ""
    if element.args then
      for j = 1, element.args.n do
        local argVal = element.args[j]
        local argType = type(argVal)
        local safeStr
        if argType == "userdata" then
          safeStr = slua.isValid(argVal) and "<userdata>" or "<freed userdata>"
        elseif argType == "table" then
          safeStr = "{keyName=" .. tostring(argVal.keyName) .. "}"
        else
          safeStr = tostring(argVal)
        end
        argsStr = argsStr == "" and safeStr or argsStr .. ", " .. safeStr
      end
    end
    log_format("ui_show_queue_manager._SafeLogSortList. [%s] UIKey = %s, KeyName = %s, sortWeight = %s, addQueueTime = %s, args = [%s]", i, lqcUIConfig and lqcUIConfig.UIKey, lqcUIConfig and lqcUIConfig.KeyName, element.sortWeight, element.addQueueTime, argsStr)
  end
end
function ui_show_queue_manager._AddOneUIToSortList(lqcUIConfig, uiConfig, ...)
  log(bWriteLog and "ui_show_queue_manager._AddOneUIToSortList keyName = " .. tostring(uiConfig.keyName))
  local len = #ui_show_queue_manager.sortList
  log_format("ui_show_queue_manager._AddOneUIToSortList sortListCurUI = %s, len = %d", ui_show_queue_manager.sortListCurUI, len)
  local element = ui_show_queue_element_builder.GetQueueElement(lqcUIConfig, uiConfig, ...)
  log(bWriteLog and "ui_show_queue_manager._AddOneUIToSortList UIKey = " .. tostring(element.lqcUIConfig.UIKey))
  table.insert(ui_show_queue_manager.sortList, element)
  ui_show_queue_manager._RemoveNotValidArgsElement()
  ui_show_queue_manager._SortShowList()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_SHOW_QUEUE_ADD_ONE_TO_SORT_LIST, uiConfig)
  if ui_show_queue_manager.sortListCurUI == nil then
    ui_show_queue_manager._ReShowUI(0, true)
  end
  return nil, true
end
function ui_show_queue_manager._RemoveNotValidArgsElement()
  local len = #ui_show_queue_manager.sortList
  for i = len, 1, -1 do
    local element = ui_show_queue_manager.sortList[i]
    local args = element.args
    for _, argVal in ipairs(args) do
      if type(argVal) == "userdata" and not slua.isValid(argVal) then
        table.remove(ui_show_queue_manager.sortList, i)
        log_warning("ui_show_queue_manager._RemoveNotValidArgsElement. args contain released userdata. remove element. UIKey = " .. tostring(element.lqcUIConfig.UIKey))
        break
      end
    end
  end
end
function ui_show_queue_manager._SortShowList()
  table.sort(ui_show_queue_manager.sortList, function(a, b)
    if a.sortWeight == b.sortWeight then
      return a.addQueueTime < b.addQueueTime
    end
    return a.sortWeight < b.sortWeight
  end)
  ui_show_queue_manager._SafeLogSortList()
end
function ui_show_queue_manager._AddOneUIToDirectList(lqcUIConfig, uiConfig, ...)
  log(bWriteLog and "ui_show_queue_manager._AddOneUIToDirectList keyName = " .. tostring(uiConfig.keyName))
  local count = #ui_show_queue_manager.directList
  log_format("ui_show_queue_manager._AddOneUIToDirectList count = %d", count)
  if count == 0 then
    local canShow = ui_show_queue_manager._CheckOneDirectCanShow(lqcUIConfig)
    if canShow then
      local showUIInfo = UIManager.DirectShowUI(uiConfig, ...)
      local showSuccess = showUIInfo ~= nil
      ui_show_queue_manager.directListUIShowStatus[uiConfig.keyName] = showSuccess
      return showUIInfo, false
    end
  end
  local element = ui_show_queue_element_builder.GetQueueElement(lqcUIConfig, uiConfig, ...)
  log(bWriteLog and "ui_show_queue_manager._AddOneUIToDirectList UIKey = " .. tostring(lqcUIConfig.UIKey))
  table.insert(ui_show_queue_manager.directList, element)
  return nil, true
end
function ui_show_queue_manager._RemoveOneFromSortList(uiConfig, ParamTable)
  local keyName = uiConfig.keyName
  local UIKey, Param = ui_show_queue_table_query.GetConfigParam(uiConfig, ParamTable)
  local hasParam = UIKey ~= nil and Param ~= nil
  local isRemove = false
  local len = #ui_show_queue_manager.sortList
  for i = len, 1, -1 do
    local element = ui_show_queue_manager.sortList[i]
    if element.args[1].keyName == keyName and hasParam and element.lqcUIConfig.UIKey == UIKey and element.lqcUIConfig.Param == Param then
      table.remove(ui_show_queue_manager.sortList, i)
      isRemove = true
      break
    end
  end
  if isRemove then
    log_format("ui_show_queue_manager._RemoveOneFromSortList keyName = %s", keyName)
  end
  return isRemove
end
function ui_show_queue_manager._RemoveOneFromDirectList(uiConfig, ParamTable)
  local keyName = uiConfig.keyName
  local UIKey, Param = ui_show_queue_table_query.GetConfigParam(uiConfig, ParamTable)
  local hasParam = UIKey ~= nil and Param ~= nil
  local isRemove = false
  local len = #ui_show_queue_manager.directList
  for i = len, 1, -1 do
    local element = ui_show_queue_manager.directList[i]
    if element.args[1].keyName == keyName and hasParam and element.lqcUIConfig.UIKey == UIKey and element.lqcUIConfig.Param == Param then
      table.remove(ui_show_queue_manager.directList, i)
      isRemove = true
      break
    end
  end
  if isRemove then
    log_format("ui_show_queue_manager._RemoveOneFromDirectList keyName = %s", keyName)
  end
  return isRemove
end
function ui_show_queue_manager._CloseCurrentSortUI(targetUIConfig)
  local canClose = true
  if targetUIConfig then
    local targetKeyName = targetUIConfig.keyName
    canClose = ui_show_queue_manager.sortListCurUI ~= targetKeyName
  end
  if ui_show_queue_manager.sortListCurUI and canClose then
    local keyName = ui_show_queue_manager.sortListCurUI
    local uiConfig = UIManager.GetConfigByKey(keyName)
    if uiConfig and UIManager.IsUIShow(uiConfig) then
      log(bWriteLog and "ui_show_queue_manager._CloseCurrentSortUI keyName = " .. tostring(keyName))
      UIManager.CloseUI(uiConfig)
    end
  end
end
function ui_show_queue_manager._OnJumpModuleOpen()
  log(bWriteLog and "ui_show_queue_manager._OnJumpModuleOpen sortListCurUI = " .. tostring(ui_show_queue_manager.sortListCurUI))
  if not ui_show_queue_manager.sortListCurUI then
    return
  end
  local keyName = ui_show_queue_manager.sortListCurUI
  local uiConfig = UIManager.GetConfigByKey(keyName)
  if not uiConfig then
    return
  end
  if not uiConfig.asy then
    log_warning(bWriteLog and "ui_show_queue_manager._OnJumpModuleOpen return not asy keyName = " .. keyName)
    return
  end
  local base_config_util = require("client.common.uibase.base_config_util")
  if not base_config_util.IsMainUI(uiConfig) then
    log_warning(bWriteLog and "ui_show_queue_manager._OnJumpModuleOpen return not MainUI keyName = " .. keyName)
    return
  end
  local uiInstance = UIManager.GetUI(uiConfig)
  if not uiInstance or not uiInstance:IsAsyncLoading() then
    log_warning(bWriteLog and "ui_show_queue_manager._OnJumpModuleOpen return not AsyncLoading keyName = " .. keyName)
    return
  end
  uiInstance:MarkRefreshZOrderOnLoaded()
end
function ui_show_queue_manager._ShowUIFromSortList()
  if ui_show_queue_manager.isBlock then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromSortList return isBlock")
    return
  end
  if #ui_show_queue_manager.sortList == 0 then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromSortList return sortList is empty")
    return
  end
  if ui_show_queue_manager.sortListCurUI ~= nil then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromSortList return sortListCurUI = " .. tostring(ui_show_queue_manager.sortListCurUI))
    return
  end
  local element, removeIndex
  local showLobbyStatusCache = {}
  local checkOneCanShowCache = {}
  for i, v in ipairs(ui_show_queue_manager.sortList) do
    local UIKey = v.lqcUIConfig.UIKey
    if checkOneCanShowCache[UIKey] == nil then
      checkOneCanShowCache[UIKey] = ui_show_queue_manager._CheckOneCanShow(v.lqcUIConfig, showLobbyStatusCache)
    end
    if checkOneCanShowCache[UIKey] then
      element = v
      removeIndex = i
      break
    end
  end
  if not element then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromSortList return not element can show")
    return
  end
  log(bWriteLog and "ui_show_queue_manager._ShowUIFromSortList removeIndex = " .. removeIndex)
  log_format("ui_show_queue_manager._ShowUIFromSortList element UIKey = %s, sortWeight = %s, addQueueTime = %s", element.lqcUIConfig and element.lqcUIConfig.UIKey, element.sortWeight, element.addQueueTime)
  ui_show_queue_manager._SanitizeArgs(element.args, "_ShowUIFromSortList")
  table.remove(ui_show_queue_manager.sortList, removeIndex)
  ui_show_queue_manager._RealShowUI(element.args, true)
end
function ui_show_queue_manager._ShowUIFromDirectList()
  if ui_show_queue_manager.isBlock then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromDirectList return isBlock")
    return
  end
  if #ui_show_queue_manager.directList == 0 then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromDirectList return directList is empty")
    return
  end
  local element, removeIndex
  local checkOneCanShowCache = {}
  for k, v in ipairs(ui_show_queue_manager.directList) do
    local UIKey = v.lqcUIConfig.UIKey
    if checkOneCanShowCache[UIKey] == nil then
      checkOneCanShowCache[UIKey] = ui_show_queue_manager._CheckOneDirectCanShow(v.lqcUIConfig)
    end
    if checkOneCanShowCache[UIKey] then
      element = v
      removeIndex = k
      break
    end
  end
  if not element then
    log_warning(bWriteLog and "ui_show_queue_manager._ShowUIFromDirectList return not element can show")
    return
  end
  log(bWriteLog and "ui_show_queue_manager._ShowUIFromDirectList removeIndex = " .. removeIndex)
  log_format("ui_show_queue_manager._ShowUIFromDirectList element UIKey = %s, addQueueTime = %s", element.lqcUIConfig and element.lqcUIConfig.UIKey, element.addQueueTime)
  ui_show_queue_manager._SanitizeArgs(element.args, "_ShowUIFromDirectList")
  table.remove(ui_show_queue_manager.directList, removeIndex)
  ui_show_queue_manager._RealShowUI(element.args, false)
end
function ui_show_queue_manager._RealShowUI(args, isSortListUI)
  log(bWriteLog and "ui_show_queue_manager._RealShowUI isSortListUI = " .. tostring(isSortListUI))
  local keyName = args and args[1].keyName or ""
  local uiConfig = UIManager.GetConfigByKey(keyName)
  if not uiConfig then
    log_warning(bWriteLog and "ui_show_queue_manager._RealShowUI keyName = " .. tostring(keyName) .. " uiConfig is not exist")
    return
  end
  local showUIInfo = UIManager.DirectShowUI(uiConfig, table.unpack(args, 2, args.n))
  local showSuccess = showUIInfo ~= nil
  log(bWriteLog and "ui_show_queue_manager._RealShowUI keyName = " .. keyName .. ". showSuccess = " .. tostring(showSuccess))
  if not isSortListUI then
    ui_show_queue_manager.directListUIShowStatus[keyName] = showSuccess
  end
  if showUIInfo then
    log(bWriteLog and "ui_show_queue_manager._RealShowUI keyName = " .. tostring(keyName) .. " showUIInfo")
    if isSortListUI then
      ui_show_queue_manager.sortListCurUI = keyName
    end
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_SHOW_QUEUE_SHOW_ONE_FROM_SORT_LIST, uiConfig)
    return
  end
  if isSortListUI then
    ui_show_queue_manager._ShowUIFromSortList()
  else
    ui_show_queue_manager._ShowUIFromDirectList()
  end
end
function ui_show_queue_manager._SanitizeArgs(args, callerName)
  if not args then
    return
  end
  for i = 2, args.n do
    local argVal = args[i]
    if argVal ~= nil and type(argVal) == "userdata" and not slua.isValid(argVal) then
      log_warning_format("ui_show_queue_manager.%s args[%d] had been freed, set to nil.", callerName, i)
      args[i] = nil
    end
  end
end
function ui_show_queue_manager._CheckListSignIsExist()
  local existFunc = function(keyName)
    local uiConfig = UIManager.GetConfigByKey(keyName)
    if not uiConfig then
      return false
    end
    local uiInfo = UIManager.GetUI(uiConfig)
    if uiInfo then
      return true
    end
    return false
  end
  if ui_show_queue_manager.sortListCurUI and not existFunc(ui_show_queue_manager.sortListCurUI) then
    log_warning(bWriteLog and "ui_show_queue_manager._CheckListSignIsExist sortListCurUI = " .. ui_show_queue_manager.sortListCurUI .. " not exist")
    ui_show_queue_manager.sortListCurUI = nil
  end
  for keyName, _ in pairs(ui_show_queue_manager.directListUIShowStatus) do
    if not existFunc(keyName) then
      log_warning(bWriteLog and "ui_show_queue_manager._CheckListSignIsExist directListUIShowStatus keyName = " .. tostring(keyName) .. " not exist")
      ui_show_queue_manager.directListUIShowStatus[keyName] = nil
    end
  end
end
function ui_show_queue_manager.IsLimitByReturn(UIKey)
  local lqcUIPlayerTypeConfig = ui_show_queue_table_query.GetTargetLobbyQueueControl_UIPlayerTypeConfig(UIKey)
  if not lqcUIPlayerTypeConfig then
    return false
  end
  local pReturnData = ui_show_queue_limit_check.CheckIsReturnLimit(lqcUIPlayerTypeConfig)
  if pReturnData.isReturnLimit then
    return true
  end
  return false
end
return ui_show_queue_manager