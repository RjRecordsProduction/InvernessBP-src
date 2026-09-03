local post_switch_popup_config = require("client.slua.logic.post_switch_popup.post_switch_popup_config")
local EState = post_switch_popup_config.EState
local EOneCantExecuteReason = post_switch_popup_config.EOneCantExecuteReason
local post_switch_popup_check_config = require("client.slua.logic.post_switch_popup.post_switch_popup_check_config")
local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
local pairs = _G.pairs
local ipairs = _G.ipairs
local table_insert = _G.table.insert
local table_sort = _G.table.sort
local string_format = _G.string.format
local log = _G.log
local log_format = _G.log_format
local log_warning = _G.log_warning
local log_tree = _G.log_tree
local log_warning_format = _G.log_warning_format
local log_error_format = _G.log_error_format
local logic_post_switch_popup = {}
local CWaitEventOnDelay = false
function logic_post_switch_popup:DefineAndResetData()
  log(bWriteLog and "logic_post_switch_popup:DefineAndResetData")
  self:InitData()
  self:_Clear()
  self:_InitGMVars()
end
function logic_post_switch_popup:InitData()
  if self._mainList or self._mainConfig then
    log_warning(bWriteLog and "logic_post_switch_popup:InitData is already initialized")
    return
  end
  self._mainList = {}
  self._mainConfig = {}
  self._eventMap = {}
  local config = CDataTable.GetTable("LobbyQueueControl_PostSwitchPopup")
  local TableUtil = require("common.table_util")
  for _, v in pairs(config) do
    local id = v.ID
    local element = TableUtil.FastCopyTable(post_switch_popup_config.SElement)
    element.executeOnce = v.ExecuteOnce
    element.onlyPostSwitch = v.OnlyPostSwitch
    element.moduleID = v.ModuleID
    local checkFunction = v.CheckFunction
    local targetFunction
    if checkFunction ~= "" then
      targetFunction = post_switch_popup_check_config[checkFunction]
      if not targetFunction or type(targetFunction) ~= "function" then
        log_warning_format("logic_post_switch_popup:InitData checkFunction not exist. ID = [%s], checkFunction = [%s]", id, checkFunction)
      end
    end
    local isOrderElement = v.Order ~= post_switch_popup_config.CDefaultOrder
    if isOrderElement and not targetFunction then
      log_warning_format("logic_post_switch_popup:InitData orderElement need checkFunction. ID = [%s]", id)
    end
    element.checkFunction = targetFunction
    local configEventType = v.EventType
    local configEventID = v.EventID
    local eventType, eventID = 0, 0
    if configEventType ~= "" and configEventID ~= "" then
      eventType = _G[configEventType]
      eventID = _G[configEventID]
      if not eventType or not eventID then
        log_error_format("logic_post_switch_popup:InitData eventType or eventID is nil. ID = [%s], eventType = [%s], eventID = [%s]", id, configEventType, configEventID)
      end
    end
    element.    element.    self._mainConfig[id] = element
    table_insert(self._mainList, {
      id = id,
      order = v.Order
    })
    if eventType ~= 0 and eventID ~= 0 then
      local eventKey = string_format(post_switch_popup_config.CEventKeyFormat, eventType, eventID)
      if not self._eventMap then
        self._eventMap = {}
      end
      if not self._eventMap[eventKey] then
        self._eventMap[eventKey] = {}
      end
      table_insert(self._eventMap[eventKey], id)
    end
  end
  table_sort(self._mainList, function(a, b)
    if a.order == b.order then
      return a.id < b.id
    end
    return a.order < b.order
  end)
  log_tree("logic_post_switch_popup:InitData _mainList = ", self._mainList)
  log_tree("logic_post_switch_popup:InitData _mainConfig = ", self._mainConfig)
end
function logic_post_switch_popup:OnInitialize()
end
function logic_post_switch_popup:RegistEvents()
  local registeredEvents = {}
  for id, _ in pairs(self._eventWaitList) do
    local config = self:_GetConfig(id)
    if config and config.eventType ~= 0 and config.eventID ~= 0 then
      local eventKey = string_format(post_switch_popup_config.CEventKeyFormat, config.eventType, config.eventID)
      if not registeredEvents[eventKey] then
        registeredEvents[eventKey] = true
        self:AddCommonEvent(config.eventType, config.eventID, self.OnEventReceive, self)
      end
    end
  end
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, self.OnFaceSlapEnd, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_SEQ_BEGIN, self.OnMainCityEnterSeqBegin, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_SEQ_FINISH, self.OnMainCityEnterSeqFinish, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_DEPOT_GUIDE_MATCH, self.OnNewbieActivityEntryGuideFinish, self)
end
function logic_post_switch_popup:OnLogin(bReLogin)
  log(bWriteLog and "logic_post_switch_popup:OnLogin")
  self:_Clear()
end
function logic_post_switch_popup:OnLogOut()
  log(bWriteLog and "logic_post_switch_popup:OnLogOut")
  self:_Clear()
end
function logic_post_switch_popup:OnPreSwitchGameStatus(preState, nextState)
  log_warning_format("logic_post_switch_popup:OnPreSwitchGameStatus. pre = [%s], nextState = [%s]", preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    log_warning(bWriteLog and "logic_post_switch_popup:OnPreSwitchGameStatus enter fighting")
    self:_Clear()
  end
end
function logic_post_switch_popup:OnPostSwitchGameStatus(preState, nextState)
  log_warning_format("logic_post_switch_popup:OnPostSwitchGameStatus. pre = [%s], nextState = [%s]", preState, nextState)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    log_warning(bWriteLog and "logic_post_switch_popup:OnPostSwitchGameStatus return from fighting")
    self:_PostSwitchFromFighting()
  end
end
function logic_post_switch_popup:OnEventReceive(eventType, eventID)
  log(bWriteLog and "--------------------------------------------------logic_post_switch_popup.TryExecute From OnEventReceive----------------------------------------------------")
  log_format("logic_post_switch_popup:OnEventReceive. eventType = [%s], eventID = [%s]", eventType, eventID)
  local targetList = {}
  local eventKey = string_format(post_switch_popup_config.CEventKeyFormat, eventType, eventID)
  local idList = self._eventMap and self._eventMap[eventKey]
  local needRestartMainExecute = false
  if idList then
    for _, id in ipairs(idList) do
      needRestartMainExecute = self:_OnWaitingEventFinished(id) or needRestartMainExecute
      local canAddToTargetList = self:_CheckCanAddToTargetList(id)
      if canAddToTargetList then
        table_insert(targetList, id)
      end
    end
  end
  if #targetList == 0 then
    log_warning_format("logic_post_switch_popup:OnEventReceive no target. needRestartMainExecute = %s", needRestartMainExecute)
  else
    table_sort(targetList, function(a, b)
      return a < b
    end)
    log_tree("logic_post_switch_popup:OnEventReceive targetList = ", targetList)
    self:TryExecute(targetList)
  end
  if needRestartMainExecute then
    self:StartExecute()
  end
end
function logic_post_switch_popup:OnFaceSlapEnd()
  log(bWriteLog and "logic_post_switch_popup:OnFaceSlapEnd")
  self:StartExecute()
end
function logic_post_switch_popup:OnMainCityEnterSeqBegin()
  log(bWriteLog and "logic_post_switch_popup:OnMainCityEnterSeqBegin")
  self._waitingMainCitySeqEnd = true
end
function logic_post_switch_popup:OnMainCityEnterSeqFinish()
  log(bWriteLog and "logic_post_switch_popup:OnMainCityEnterSeqFinish")
  self._waitingMainCitySeqEnd = false
  self:StartExecute()
end
function logic_post_switch_popup:OnWidgetHide(_, _, keyName)
  if self._state ~= EState.InProgress then
    log_warning(bWriteLog and "logic_post_switch_popup:OnWidgetHide. not in progress")
    if keyName == UIManager.UI_Config.Activity_Newbie_Main.keyName then
      self:OnNewbieActivityClose()
    end
    return
  end
  if self._widgetHideExecuteTimer then
    self:RemoveTimer(self._widgetHideExecuteTimer)
    self._widgetHideExecuteTimer = nil
  end
  self._widgetHideExecuteTimer = self:AddTimerOnce(0.2, function()
    log(bWriteLog and "--------------------------------------------------logic_post_switch_popup.TryExecute From OnWidgetHide----------------------------------------------------")
    log_format("logic_post_switch_popup:OnWidgetHide timer fired. state = [%s]", self._state)
    local isAndroidStackEmpty, failUIName = UIManager.IsAndroidStackEmpty()
    if not isAndroidStackEmpty then
      log_warning_format("logic_post_switch_popup:OnWidgetHide return not IsAndroidStackEmpty. failUIName = [%s]", failUIName)
      return
    end
    self:TryExecute()
  end)
end
function logic_post_switch_popup:OnNewbieActivityEntryGuideFinish()
  log(bWriteLog and "logic_post_switch_popup:OnNewbieActivityEntryGuideFinish")
  if self._newbieActivityGuideFinishTimer then
    self:RemoveTimer(self._newbieActivityGuideFinishTimer)
    self._newbieActivityGuideFinishTimer = nil
  end
  self._newbieActivityGuideFinishTimer = self:AddTimerOnce(0.1, function()
    log(bWriteLog and "logic_post_switch_popup:OnNewbieActivityEntryGuideFinish timer fired")
    self._newbieActivityGuideFinishTimer = nil
    local isEmpty, topUI = UIManager.IsAndroidStackEmpty()
    if not isEmpty and topUI == UIManager.UI_Config.Activity_Newbie_Main.keyName then
      log_warning(bWriteLog and "logic_post_switch_popup:OnNewbieActivityEntryGuideFinish return topUI is still Activity_Newbie_Main")
      return
    end
    self:OnNewbieActivityClose()
  end)
end
function logic_post_switch_popup:OnNewbieActivityClose()
  log(bWriteLog and "logic_post_switch_popup:OnNewbieActivityClose")
  if self._newbieActivityCloseHandled then
    log_warning(bWriteLog and "logic_post_switch_popup:OnNewbieActivityClose return already handled")
    return
  end
  if not self._isNewbieActivityGuideFinished then
    log_warning(bWriteLog and "logic_post_switch_popup:OnNewbieActivityClose return not _isNewbieActivityGuideFinished")
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local ELobbyGuideID = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ELobbyGuideID
  if not LogicNewbie.NeedShowNewbieGuide(ELobbyGuideID.LOBBY_NEWBIE_THEME_SLAP_GUIDE_ID) then
    log_warning(bWriteLog and "logic_post_switch_popup:OnNewbieActivityClose return not NeedShowNewbieGuide(LOBBY_NEWBIE_THEME_SLAP_GUIDE_ID)")
    return
  end
  self._newbieActivityCloseHandled = true
  self._isNewbieActivityGuideFinished = false
  self:StartExecute()
end
function logic_post_switch_popup:TryExecuteOne(jumpID)
  log(bWriteLog and "--------------------------------------------------logic_post_switch_popup.TryExecute From TryExecuteOne----------------------------------------------------")
  log_format("logic_post_switch_popup:TryExecuteOne jumpID = [%s]", jumpID)
  local targetIDList = {}
  for id, config in pairs(self._mainConfig) do
    if config.moduleID == jumpID then
      if self:_CheckCanAddToTargetList(id) then
        table_insert(targetIDList, id)
      end
      break
    end
  end
  if #targetIDList == 0 then
    log_warning(bWriteLog and "logic_post_switch_popup:TryExecuteOne no target")
    return
  end
  self:TryExecute(targetIDList)
end
function logic_post_switch_popup:StartExecute()
  log(bWriteLog and "--------------------------------------------------logic_post_switch_popup.TryExecute From StartExecute----------------------------------------------------")
  log(bWriteLog and "logic_post_switch_popup:StartExecute")
  self:TryExecute(nil, true)
end
function logic_post_switch_popup:TryExecute(targetList, fromStartExecute)
  log_format("logic_post_switch_popup:TryExecute targetList = [%s], fromStartExecute = [%s]", targetList, fromStartExecute)
  if fromStartExecute and self._state == EState.Executing then
    log_warning_format("logic_post_switch_popup:TryExecute return state is Executing. state = [%s]", self._state)
    return
  end
  local canExecute = self:_CheckCanExecute()
  if not canExecute then
    log_warning(bWriteLog and "logic_post_switch_popup:TryExecute return not canExecute")
    return
  end
  if fromStartExecute then
    self:_SetState(EState.InProgress)
  end
  self:_Execute(targetList)
end
function logic_post_switch_popup:TryExecuteByTask()
  log(bWriteLog and "logic_post_switch_popup:TryExecuteByTask")
  self:StartExecute()
end
function logic_post_switch_popup:CheckIsFinish()
  return self._state == EState.Finished
end
function logic_post_switch_popup:SetNewbieActivityGuideFinished()
  log(bWriteLog and "logic_post_switch_popup:SetNewbieActivityGuideFinished")
  self._isNewbieActivityGuideFinished = true
end
function logic_post_switch_popup:_SetState(state)
  log_format("logic_post_switch_popup:_SetState state = [%s]", state)
  self._end
function logic_post_switch_popup:_GetConfig(id)
  if id then
    return self._mainConfig[id]
  end
end
function logic_post_switch_popup:_PostSwitchFromFighting()
  log(bWriteLog and "logic_post_switch_popup:_PostSwitchFromFighting")
  self._isReturnFromBattle = true
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_post_switch_popup:_PostSwitchFromFighting is in main city. execute by queue_task_module")
    local task = {
      module = self,
      funcName = "TryExecuteByTask",
      param = self,
      protect = true
    }
    local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
    queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
    log(bWriteLog and "logic_post_switch_popup:_PostSwitchFromFighting enqueue task success")
    return
  end
  log(bWriteLog and "logic_post_switch_popup:_PostSwitchFromFighting is not in main city. execute by self")
  self:StartExecute()
end
function logic_post_switch_popup:_CheckCanExecute()
  log(bWriteLog and "logic_post_switch_popup:_CheckCanExecute")
  if not GameStatus.IsInLobbyOrMainCity() then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanExecute return not IsInLobbyOrMainCity")
    return false
  end
  local LobbySystem = require("client.logic.login.logic_lobby")
  if LobbySystem.CheckUseNewGuide() and LobbySystem.roleData and (LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole or LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.Init) then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanExecute return is_first_login: " .. tostring(LobbySystem.roleData.is_first_login))
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local IsSlapEnd = NewFaceSlapSystem:IsSlapEnd()
  local IsNewbie = NewFaceSlapSystem:CheckIsNewBie()
  log_format("logic_post_switch_popup:_CheckCanExecute IsSlapEnd = [%s], IsNewbie = [%s]", IsSlapEnd, IsNewbie)
  if not IsNewbie and not IsSlapEnd then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanExecute return not IsSlapEnd")
    return false
  end
  if GameStatus.IsIn2DLobby() and not self:_CheckCanShowInLobby() then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanExecute return not CheckCanShowInLobby")
    return false
  end
  if GameStatus.IsInMainCity() and not self:_CheckCanShowInMainCity() then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanExecute return not CheckCanShowInMainCity")
    return false
  end
  return true
end
function logic_post_switch_popup:_CheckCanShowInLobby()
  log(bWriteLog and "logic_post_switch_popup:_CheckCanShowInLobby")
  if main_city_process_util.CheckIsPendingAutoEnterMainCity() then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanShowInLobby return not CheckIsPendingAutoEnterMainCity")
    return false
  end
  return true
end
function logic_post_switch_popup:_CheckCanShowInMainCity()
  log(bWriteLog and "logic_post_switch_popup:_CheckCanShowInMainCity")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanShowInMainCity return is bEnterMainCityLoading")
    return false
  end
  if main_city_process_util.CheckNeedShowEnterSequence() then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanShowInMainCity return not CheckNeedShowEnterSequence")
    return false
  end
  if self._waitingMainCitySeqEnd then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckCanShowInMainCity return main city Sequence not end")
    return false
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local flag = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_POPUP_GUIDE_ID)
  if not flag then
    log_warning_format("logic_post_switch_popup:_CheckCanShowInMainCity return main city popup guide not finished")
    return false
  end
  return true
end
function logic_post_switch_popup:_Execute(targetList)
  log_format("logic_post_switch_popup:_Execute targetList = [%s]", targetList)
  if targetList and type(targetList) == "table" then
    if 0 < #targetList then
      self:_ExecuteTargetList(targetList)
    end
    return
  end
  self:_ExecuteMainConfig()
end
function logic_post_switch_popup:_ExecuteTargetList(targetList)
  targetList = targetList or {}
  for _, id in ipairs(targetList) do
    self:_ExecuteOne(id)
  end
  log(bWriteLog and "--------------------------------------------------logic_post_switch_popup.ExecuteTargetList----------------------------------------------------")
end
function logic_post_switch_popup:_ExecuteMainConfig()
  log_format("logic_post_switch_popup:_ExecuteMainConfig. currentIndex = [%s]", self._currentIndex)
  if self:CheckIsFinish() then
    log_warning(bWriteLog and "logic_post_switch_popup:_ExecuteMainConfig return is already finished")
    return
  end
  local startIndex = self._currentIndex + 1
  local totalLength = #self._mainList
  if startIndex > totalLength then
    log_warning(bWriteLog and "logic_post_switch_popup:_ExecuteMainConfig return is in end index")
    return
  end
  for index = startIndex, totalLength do
    local v = self._mainList[index]
    local id = v.id
    local needEnd, needReturn = self:_ExecuteOne(id, true)
    log_format("logic_post_switch_popup:_ExecuteMainConfig. index = [%s], needEnd = [%s], needReturn = [%s]", index, needEnd, needReturn)
    if needReturn then
      return
    end
    self:_SetCurrentIndex(index)
    if needEnd then
      return
    end
  end
  self:_SetState(EState.Finished)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_POST_SWITCH_POPUP_FINISHED)
  log(bWriteLog and "--------------------------------------------------logic_post_switch_popup.ExecuteMainConfig Finished----------------------------------------------------")
end
function logic_post_switch_popup:_ExecuteOne(id, isMainExecute)
  log_format("logic_post_switch_popup:_ExecuteOne id = [%s]", id)
  local config = self:_GetConfig(id)
  if not id or not config then
    log_warning(bWriteLog and "logic_post_switch_popup:_ExecuteOne config is nil")
    return false, false
  end
  local checkFunction = config.checkFunction
  local needEnd = checkFunction ~= nil
  local oneCanExecute, cantReason = self:_CheckOneCanExecute(id)
  if not oneCanExecute then
    if isMainExecute and needEnd and cantReason == EOneCantExecuteReason.EventNotReady then
      if not CWaitEventOnDelay then
        log_warning_format("logic_post_switch_popup:_ExecuteOne event not ready, skip by CWaitEventOnDelay=false. id = [%s]", id)
        return false, false
      end
      log_warning(bWriteLog and "logic_post_switch_popup:_ExecuteOne start waiting event timer")
      self:_StartWaitingEventTimer(id)
      return false, true
    else
      log_warning(bWriteLog and "logic_post_switch_popup:_ExecuteOne return not CheckOneCanExecute")
      return false, false
    end
  end
  local moduleID = config.moduleID
  if not moduleID then
    log_warning(bWriteLog and "logic_post_switch_popup:_ExecuteOne return not moduleID")
    return false, false
  end
  if checkFunction and not checkFunction() then
    log_warning_format("logic_post_switch_popup:_ExecuteOne return not pass checkFunction. id = [%s]", id)
    return false, false
  end
  if self._state == EState.InProgress then
    log(bWriteLog and "logic_post_switch_popup:_ExecuteOne ready to execute")
    self:_SetState(EState.Executing)
  end
  local jumpUrl = string_format(post_switch_popup_config.CJumpFormat, moduleID)
  log_format("logic_post_switch_popup:_ExecuteOne executed. moduleID = [%s]", moduleID)
  GlobalData.JumpUrl(jumpUrl)
  if self._state == EState.Executing then
    log(bWriteLog and "logic_post_switch_popup:_ExecuteOne execute one finish")
    self:_SetState(EState.InProgress)
  end
  if config.executeOnce then
    self:_SetIsExecutedOnce(id)
  end
  return needEnd, false
end
function logic_post_switch_popup:_CheckOneCanExecute(id)
  log_format("logic_post_switch_popup:_CheckOneCanExecute id = [%s]", id)
  local config = self:_GetConfig(id)
  if not id or not config then
    log_warning(bWriteLog and "logic_post_switch_popup:_CheckOneCanExecute config is nil")
    return false, EOneCantExecuteReason.ConfigNone
  end
  if config.executeOnce and self._executedOnceList[id] then
    log_warning_format("logic_post_switch_popup:_CheckOneCanExecute id = [%s] has already executed once", id)
    return false, EOneCantExecuteReason.ExecuteOnce
  end
  if config.onlyPostSwitch and not self._isReturnFromBattle then
    log_warning_format("logic_post_switch_popup:_CheckOneCanExecute id = [%s] need return from battle", id)
    return false, EOneCantExecuteReason.OnlyPostSwitch
  end
  local needEvent = self._eventWaitList[id] == true
  if needEvent then
    log_warning_format("logic_post_switch_popup:_CheckOneCanExecute id = [%s] need event", id)
    return false, EOneCantExecuteReason.EventNotReady
  end
  log(bWriteLog and "logic_post_switch_popup:_CheckOneCanExecute pass")
  return true
end
function logic_post_switch_popup:_CheckCanAddToTargetList(id)
  log_format("logic_post_switch_popup:_CheckCanAddToTargetList id = [%s], currentIndex = [%s]", id, self._currentIndex)
  local config = self:_GetConfig(id)
  if not config then
    log_warning_format("logic_post_switch_popup:_CheckCanAddToTargetList config is nil. id = [%s]", id)
    return false
  end
  if not self._GM_IgnoreMainExecution then
    for index, v in ipairs(self._mainList) do
      if v.id == id then
        if index > self._currentIndex then
          log_warning_format("logic_post_switch_popup:_CheckCanAddToTargetList return need wait for main execute. index = [%s], currentIndex = [%s]", index, self._currentIndex)
          return false
        end
        break
      end
    end
  end
  return true
end
function logic_post_switch_popup:_SetIsExecutedOnce(id)
  log_format("logic_post_switch_popup:_SetIsExecutedOnce id = [%s]", id)
  if not id then
    log_warning(bWriteLog and "logic_post_switch_popup:_SetIsExecutedOnce id is nil")
    return
  end
  self._executedOnceList[id] = true
end
function logic_post_switch_popup:_Clear()
  log(bWriteLog and "logic_post_switch_popup:_Clear")
  self:_ResetBooleanVars()
  self:_SetCurrentIndex(0)
  self:_SetState(EState.NotStart)
  self:_SetWaitingEventID(nil)
  self:_ClearWaitingEventTimer()
  self:_ClearNewbieActivityGuideFinishTimer()
  self:_ResetEventWaitList()
  self:_ResetExecutedOnceList()
end
function logic_post_switch_popup:_ResetBooleanVars()
  log(bWriteLog and "logic_post_switch_popup:_ResetBooleanVars")
  self._waitingMainCitySeqEnd = false
  self._isReturnFromBattle = false
  self._newbieActivityCloseHandled = false
  self._isNewbieActivityGuideFinished = false
end
function logic_post_switch_popup:_ResetEventWaitList()
  log(bWriteLog and "logic_post_switch_popup:_ResetEventWaitList")
  if not self._eventWaitList then
    self._eventWaitList = {}
    for _, v in ipairs(self._mainList) do
      local id = v.id
      local config = self:_GetConfig(id)
      if config.eventType > 0 and 0 < config.eventID then
        self._eventWaitList[id] = true
      end
    end
  end
  for id, _ in pairs(self._eventWaitList) do
    self._eventWaitList[id] = true
  end
  log_tree("logic_post_switch_popup:_ResetEventWaitList result = ", self._eventWaitList)
end
function logic_post_switch_popup:_ResetExecutedOnceList()
  log(bWriteLog and "logic_post_switch_popup:_ResetExecutedOnceList")
  if not self._executedOnceList then
    self._executedOnceList = {}
    for _, v in ipairs(self._mainList) do
      local id = v.id
      local config = self:_GetConfig(id)
      if config.executeOnce then
        self._executedOnceList[id] = false
      end
    end
  end
  for id, _ in pairs(self._executedOnceList) do
    self._executedOnceList[id] = false
  end
  log_tree("logic_post_switch_popup:_ResetExecutedOnceList result = ", self._executedOnceList)
end
function logic_post_switch_popup:_StartWaitingEventTimer(id)
  log(bWriteLog and "logic_post_switch_popup:_StartWaitingEventTimer")
  self:_ClearWaitingEventTimer()
  self:_SetWaitingEventID(id)
  self:_SetState(EState.EventWaiting)
  self._waitingEventTimer = self:AddTimerOnce(3, function()
    self:_OnEventWaitingTimeOut(id)
  end)
end
function logic_post_switch_popup:_OnEventWaitingTimeOut(id)
  log(bWriteLog and "logic_post_switch_popup:_OnEventWaitingTimeOut")
  self:_OnWaitingEventFinished(id)
  self:StartExecute()
end
function logic_post_switch_popup:_OnWaitingEventFinished(id)
  log_format("logic_post_switch_popup:_OnWaitingEventFinished id = [%s]", id)
  local config = self:_GetConfig(id)
  if not id or not config then
    log_warning(bWriteLog and "logic_post_switch_popup:_OnWaitingEventFinished id or config is nil.")
    return
  end
  local checkFunction = config.checkFunction
  local isOrderElement = checkFunction ~= nil
  self._eventWaitList[id] = false
  if self._waitingEventID ~= id then
    log(bWriteLog and "logic_post_switch_popup:_OnWaitingEventFinished waiting event id is not equal to current event id.")
    return false
  end
  if not isOrderElement then
    log(bWriteLog and "logic_post_switch_popup:_OnWaitingEventFinished is not order element.")
    return false
  end
  if self._state ~= EState.EventWaiting then
    log(bWriteLog and "logic_post_switch_popup:_OnWaitingEventFinished is not event waiting state.")
    return false
  end
  self:_ClearWaitingEventTimer()
  self:_SetWaitingEventID(nil)
  log(bWriteLog and "logic_post_switch_popup:_OnWaitingEventFinished order element event finished, will restart main execute")
  return true
end
function logic_post_switch_popup:_ClearWaitingEventTimer()
  log(bWriteLog and "logic_post_switch_popup:_ClearWaitingEventTimer")
  if self._waitingEventTimer then
    self:RemoveTimer(self._waitingEventTimer)
    self._waitingEventTimer = nil
  end
end
function logic_post_switch_popup:_ClearNewbieActivityGuideFinishTimer()
  log(bWriteLog and "logic_post_switch_popup:_ClearNewbieActivityGuideFinishTimer")
  if self._newbieActivityGuideFinishTimer then
    self:RemoveTimer(self._newbieActivityGuideFinishTimer)
    self._newbieActivityGuideFinishTimer = nil
  end
end
function logic_post_switch_popup:_SetWaitingEventID(id)
  log_format("logic_post_switch_popup:_SetWaitingEventID id = [%s]", id)
  self._waitingEventID = id
end
function logic_post_switch_popup:_SetCurrentIndex(index)
  log_format("logic_post_switch_popup:_SetCurrentIndex index = [%s]", index)
  self._currentIndex = index
end
function logic_post_switch_popup:_InitGMVars()
  self._GM_IgnoreMainExecution = false
end
function logic_post_switch_popup:SetGMIgnoreMainExecution(ignore)
  self._GM_IgnoreMainExecution = ignore
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_post_switch_popup = class(CModuleBase, nil, logic_post_switch_popup)
return Clogic_post_switch_popup