local MAX_SHOW_LIMIT = 2
local ASYNC_TIME_OUT = 10
local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
local LobbyType = ui_show_queue_config.EShowLobbyType
local NewFaceSlapSystem = {}
local WaitDataStatus = {
  Wait = 1,
  TimeOut = 2,
  Completed = 3
}
local FaceSlapType = {
  Pre = 1,
  Commercial = 2,
  Rear = 3
}
function NewFaceSlapSystem:DefineAndResetData()
  self.bClose = true
  self.iCurShowIndex = 0
  self.iCurLobbyType = nil
  self.tLobbyStatus = {}
  self.tEventStatus = {}
  self.iPreSlapCount = 0
  self.iCommercialCount = 0
  self.bGMTest = false
  self.gmIgnoreNewPlayer = false
end
function NewFaceSlapSystem:OnInitialize()
  log(bWriteLog and "NewFaceSlapSystem:OnInitialize.")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  self:_SetActivityReady(ActivityNewSystem.bIsInit)
  self.bClose = self:_GetLocalCacheFaceSlapSwitch()
end
function NewFaceSlapSystem:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, self.OnActivityInitDone, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
end
function NewFaceSlapSystem:OnLogOut()
  self:DefineAndResetData()
end
function NewFaceSlapSystem:OnPostSwitchGameStatus(preState, nextState)
end
function NewFaceSlapSystem:OnActivityInitDone()
  self:_SetActivityReady(WaitDataStatus.Completed)
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  NoticesModule:PreHandleDependResource(NoticesConst.Scene.Lobby)
  NoticesModule:PreHandleDependResource(NoticesConst.Scene.TxMission)
  if not self.bStart then
    log(bWriteLog and "NewFaceSlapSystem:OnActivityInitDone return of bStart = false")
    return
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_ACTIVITY_READY)
end
function NewFaceSlapSystem:OnWidgetHide(_, _, keyName)
  log(bWriteLog and "NewFaceSlapSystem:OnWidgetHide keyName = " .. tostring(keyName))
  self:_ShowNext()
end
function NewFaceSlapSystem:OnDelayEvent(eventType, eventID)
  local key = eventType .. "_" .. eventID
  self.tEventStatus[key] = WaitDataStatus.Completed
end
function NewFaceSlapSystem:StartFaceSlap2DLobby()
  log(bWriteLog and "NewFaceSlapSystem:StartFaceSlap2DLobby")
  self:SaveLobbyStatus()
  self.iCurLobbyType = LobbyType.Lobby_2D
  self:InitLobbyFaceSlapStatus()
  local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
  if PushSystem:IsLaunchedByNotification() then
    log(bWriteLog and "NewFaceSlapSystem:StartFaceSlap2DLobby return of IsLaunchedByNotification = true ")
    self:SkipAllSlap()
    return
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  if AdjustSystem:IsAwakedByAdjust() then
    log(bWriteLog and "NewFaceSlapSystem:StartFaceSlap2DLobby return of bIsAwakedByAdjust = true ")
    self:SkipAllSlap()
    return
  end
  self.bStart = true
  if not self:CheckIsAndroidStackEmpty() then
    log(bWriteLog and "NewFaceSlapSystem:StartFaceSlap2DLobby CheckIsAndroidStackEmpty is false")
    return
  end
  self.waitingMainCity = false
  if GameStatus.IsIn2DLobby() then
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    local defaultEnterMainCity = main_city_process_util.GetMainCityEnterSwitch()
    if defaultEnterMainCity then
      log_warning(bWriteLog and "NewFaceSlapSystem:StartFaceSlap2DLobby return of defaultEnterMainCity = true")
      self.waitingMainCity = true
      return
    end
    if main_city_process_util.CheckIsPendingAutoEnterMainCity() then
      log(bWriteLog and "NewFaceSlapSystem:StartFaceSlap2DLobby return of CheckIsPendingAutoEnterMainCity = true")
      self.waitingMainCity = true
      return
    end
  end
  self:_ShowNext()
end
function NewFaceSlapSystem:ShowFaceSlapMainCity()
  log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapMainCity")
  self:SaveLobbyStatus()
  self.iCurLobbyType = LobbyType.Lobby_2D
  self:InitLobbyFaceSlapStatus()
  self:RemoveWaitingMainCity()
  self:ReleaseBlockSlap()
  if not self:CheckCanShowInMainCity() then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapMainCity CheckCanShowInMainCity = false")
    return
  end
  self.bStart = true
  self:_ShowNext()
end
function NewFaceSlapSystem:StartFaceSlapTxMission()
  log(bWriteLog and "NewFaceSlapSystem:StartFaceSlapTxMission.")
  local logic_xmission_beginner_guide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  if not logic_xmission_beginner_guide.HaveFinishedBeginnerGuide() then
    log(bWriteLog and "NewFaceSlapSystem:StartFaceSlapTxMission return of HaveFinishedBeginnerGuide = false")
    return
  end
  self:SaveLobbyStatus()
  self.iCurLobbyType = LobbyType.XMission
  self:InitLobbyFaceSlapStatus()
  self:ReleaseBlockSlap()
  self.bStart = true
  self:_ShowNext()
end
function NewFaceSlapSystem:_ShowNext()
  log(bWriteLog and "NewFaceSlapSystem:_ShowNext iCurShowIndex = " .. tostring(self.iCurShowIndex) .. " bActivityReady = " .. tostring(self:_IsActivityReady()))
  if not self:IsCanShow() then
    log(bWriteLog and "NewFaceSlapSystem:_ShowNext return of IsCanShow = false ")
    return
  end
  if self:_ShowWait() then
    log(bWriteLog and "NewFaceSlapSystem:_ShowNext return of _ShowWait is true ")
    return
  end
  local iShowIndex = self:_GetNextShowIndex()
  log(bWriteLog and "NewFaceSlapSystem:_ShowNext iShowIndex = " .. tostring(iShowIndex))
  local info = self.tFaceSlapCategory[iShowIndex]
  log(bWriteLog and "NewFaceSlapSystem:_ShowNext info id = " .. tostring(info and info.ModuleID))
  if info and info.TriggerEventType ~= "" and info.TriggerEventID ~= "" then
    local EventType = _G[info.TriggerEventType]
    local EventID = _G[info.TriggerEventID]
    local key = EventType .. "_" .. EventID
    local status = self.tEventStatus[key]
    if status == WaitDataStatus.TimeOut then
      log(bWriteLog and string.format("NewFaceSlapSystem:_ShowNext. iShowIndex=%s is timeout, show next one!", iShowIndex))
      self:_ShowNext()
      return
    end
  end
  if 0 < iShowIndex and iShowIndex <= self.iPreSlapCount then
    self:_Show(iShowIndex)
    return
  end
  if not self:_IsActivityReady() then
    self:_DelayCheckExtEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_ACTIVITY_READY)
    return
  end
  if iShowIndex == 0 then
    log(bWriteLog and "NewFaceSlapSystem:_ShowNext return of iShowIndex = 0")
    if self.bStart and self:_IsActivityReady() and not self:_HasWaitData() then
      self:_EndSlap()
    end
    return
  end
  self:_Show(iShowIndex)
end
function NewFaceSlapSystem:_ShowWait()
  if not self.tWaitingSlap or #self.tWaitingSlap <= 0 then
    log(bWriteLog and "NewFaceSlapSystem:_ShowWait return of self.tWaitingSlap is Empty ")
    return false
  end
  local waitIndex = self.tWaitingSlap[1]
  log(bWriteLog and string.format("NewFaceSlapSystem:CanShowWaitFaceSlap waitIndex : %s, iCurShowIndex : %s", tostring(waitIndex), tostring(self.iCurShowIndex)))
  if waitIndex > self.iCurShowIndex then
    log(bWriteLog and "NewFaceSlapSystem:_ShowWait current is can't show wait face slap, follow the face slap process")
    return false
  end
  local idx = table.remove(self.tWaitingSlap, 1)
  self:_Show(idx)
  return true
end
function NewFaceSlapSystem:_Show(index)
  log(bWriteLog and "NewFaceSlapSystem:_Show, index = " .. index)
  local info = self.tFaceSlapCategory and self.tFaceSlapCategory[index]
  if not info then
    log(bWriteLog and "NewFaceSlapSystem:_Show return of info = nil, index = " .. tostring(index))
    self:_EndSlap()
    return
  end
  log(bWriteLog and "NewFaceSlapSystem:_Show, index = " .. index .. " id = " .. tostring(info.ModuleID))
  log_tree("NewFaceSlapSystem:_Show, index = " .. index .. " id = " .. tostring(info.ModuleID) .. " info = ", info)
  if info.NeedLimit then
    if self.iShowLimit <= 0 then
      log(bWriteLog and "NewFaceSlapSystem:_Show, return of iShowLimit = " .. tostring(self.iShowLimit))
      self:SkipLimitSlap()
      return
    end
    self.iShowLimit = self.iShowLimit - 1
  end
  logic_connection_waiting:Hide(0)
  self.iCurShowIndex = index
  local urlConfig
  if info.ModuleID == BP_ENUM_MODULE_PANDORA then
    local pandora_slap_system = require("client.slua.logic.Pandora.pandora_slap_system")
    urlConfig = pandora_slap_system.GetJumpUrl()
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(urlConfig)
    local actid = tonumber(params.actid)
    pandora_slap_system.SaveSlapInfo(actid)
  elseif info.ModuleID == BP_ENUM_MODULE_ACTIVITY_SIGN_IN then
    urlConfig = string.format("game://?module=%d&IsSlapIn=true", info.ModuleID)
  else
    urlConfig = string.format("game://?module=%d", info.ModuleID)
  end
  log(bWriteLog and "NewFaceSlapSystem:_Show iCurShowIndex = " .. tostring(self.iCurShowIndex) .. " urlConfig = " .. tostring(urlConfig))
  GlobalData.JumpUrl(urlConfig)
  self.tShownMap[info.ModuleID] = true
end
function NewFaceSlapSystem:_EndSlap()
  log(bWriteLog and "NewFaceSlapSystem:_EndSlap iCurShowIndex = " .. tostring(self.iCurShowIndex))
  self.bEnd = true
  self.iCurShowIndex = self.iFaceSlapCategoryCount + 1
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END)
end
function NewFaceSlapSystem:IsCanShow(ignoreAndroidStack)
  log_format("NewFaceSlapSystem:IsCanShow ignoreAndroidStack = %s", ignoreAndroidStack)
  if self.bGMTest then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return true of bGMTest = " .. tostring(self.bGMTest))
    return true
  end
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    local bUIAutoTest = GameAutotest:IsUIAutoTest()
    if bUIAutoTest then
      print(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of bUIAutoTest=", bUIAutoTest)
      return false
    end
  end
  if Client.IsWindowOB() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsWindowOB = true")
    return false
  end
  if GlobalData.IsIOSCheck() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsIOSCheck = true")
    return false
  end
  if self:IsCloseFaceSlap() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsCloseFaceSlap = true")
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of gameStatus = " .. tostring(GameStatus.GetGameStatus()) .. " and not in MainCity")
    return false
  elseif GameStatus.IsInMainCity() and not self:CheckCanShowInMainCity() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return of not CheckCanShowInMainCity")
    return
  end
  if self.iCurLobbyType == LobbyType.Lobby_2D then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow. Lobby2D Judge")
    if self.waitingMainCity then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return waitingMainCity ")
      return false
    end
    local IsInXMission = LobbySystem.roleData.is_in_metro
    log(bWriteLog and string.format("NewFaceSlapSystem:IsCanShow. IsInXMission=%s", tostring(IsInXMission)))
    if IsInXMission then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsInXMission = true")
      return false
    end
  elseif self.iCurLobbyType == LobbyType.XMission then
    local logic_xmission_beginner_guide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
    if not logic_xmission_beginner_guide.HaveFinishedBeginnerGuide() then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of HaveFinishedBeginnerGuide = false")
      return false
    end
  end
  if not self.bStart or self.bEnd or self.bClose or self.IsGMClose then
    log(bWriteLog and string.format("NewFaceSlapSystem:IsCanShow. bStart=%s, bEnd=%s, bClose=%s, IsGMClose=%s", tostring(self.bStart), tostring(self.bEnd), tostring(self.bClose), tostring(self.IsGMClose)))
    return false
  end
  if not self.gmIgnoreNewPlayer then
    if LobbySystem.isNewPlayer == true then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of isNewPlayer = true")
      return false
    end
    if LobbySystem.CheckUseNewGuide() and LobbySystem.roleData and (LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole or LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.Init) then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of CheckUseNewGuide is_first_login:" .. tostring(LobbySystem.roleData.is_first_login))
      return false
    end
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    if LogicNewbie.IsNewbie(true) and not LogicNewbie.NeedShowNewbieGuide(10033) then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsNewbie = true")
      return false
    end
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    if not growthprojectMgrB.IsFinishAllNewGuide() then
      log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsFinishAllNewGuide")
      return false
    end
  end
  local SceneSwitchLatenQueueSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SceneSwitchLatenQueueSystem)
  if SceneSwitchLatenQueueSystem:HasLobbyQueueLimitFaceSlap() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of HasLobbyQueueLimitFaceSlap")
    return false
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if logic_enter_game:IsReEnterGame() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return false of IsReEnterGame")
    return false
  end
  if not ignoreAndroidStack and not self:CheckIsAndroidStackEmpty() then
    log(bWriteLog and "NewFaceSlapSystem:IsCanShow return Android Stack isn't empty!")
    return false
  end
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  if NoticesModule:IsLeftNotices() then
    log(bWriteLog and "NewFaceSlapSystem:_CheckAndroidStack return ShowNoticeUI ")
    NoticesModule:ShowLeftNotices()
    return
  end
  return true
end
function NewFaceSlapSystem:CheckIsNewBie()
  if self.gmIgnoreNewPlayer then
    return false
  end
  if LobbySystem.isNewPlayer == true then
    log(bWriteLog and "NewFaceSlapSystem:CheckIsNewBie return of isNewPlayer = true")
    return true
  end
  if LobbySystem.CheckUseNewGuide() and LobbySystem.roleData and (LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole or LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.Init) then
    log(bWriteLog and "NewFaceSlapSystem:CheckIsNewBie return of CheckUseNewGuide is_first_login:" .. tostring(LobbySystem.roleData.is_first_login))
    return true
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie(true) and not LogicNewbie.NeedShowNewbieGuide(10033) then
    log(bWriteLog and "NewFaceSlapSystem:CheckIsNewBie return of IsNewbie = true")
    return true
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "NewFaceSlapSystem:CheckIsNewBie return of IsFinishAllNewGuide")
    return true
  end
  return false
end
function NewFaceSlapSystem:BlockSlap()
  log(bWriteLog and "NewFaceSlapSystem:BlockSlap ")
  self:SetSlapClose(true)
end
function NewFaceSlapSystem:ReleaseBlockSlap()
  log(bWriteLog and "NewFaceSlapSystem:ReleaseBlockSlap ")
  self:SetSlapClose(false)
end
function NewFaceSlapSystem:SetSlapClose(bClose)
  log(bWriteLog and "NewFaceSlapSystem:SetSlapClose bClose = " .. tostring(bClose))
  self.  self:_SaveFaceSlapShowSwitch(bClose)
end
function NewFaceSlapSystem:IsCloseFaceSlap()
  local common_config = require("client.slua.common.common_config")
  return self.bClose or common_config:IsBlockingPopupTip() or self.IsGMClose
end
function NewFaceSlapSystem:IsSlapStart()
  log(bWriteLog and "NewFaceSlapSystem:IsSlapStart " .. tostring(self.bStart))
  return self.bStart
end
function NewFaceSlapSystem:IsSlapEnd()
  log(bWriteLog and "NewFaceSlapSystem:IsSlapEnd " .. tostring(self.bStart) .. " " .. tostring(self.bEnd) .. " " .. tostring(self:_IsActivityReady()))
  return self.bStart and self:_IsActivityReady() and self.bEnd
end
function NewFaceSlapSystem:IsInSlap()
  if not self.bStart and not self.bEnd then
    log(bWriteLog and "NewFaceSlapSystem:IsInSlap. not bStart and not bEnd")
    return false
  end
  return true
end
function NewFaceSlapSystem:BlockLimitSlap()
  log(bWriteLog and "NewFaceSlapSystem:BlockLimitSlap ")
  self.iShowLimit = 0
  self.iCurShowIndex = self.iPreSlapCount + self.iCommercialCount
end
function NewFaceSlapSystem:SkipLimitSlap()
  log(bWriteLog and "NewFaceSlapSystem:SkipLimitSlap ")
  self:BlockLimitSlap()
  self:RevertSlap()
end
function NewFaceSlapSystem:SkipAllSlap()
  log(bWriteLog and "NewFaceSlapSystem:SkipAllSlap ")
  self.bClose = true
  self.bEnd = true
  self.bStart = true
  self.iCurShowIndex = self.iFaceSlapCategoryCount and self.iFaceSlapCategoryCount + 1 or 0
  self.tFaceSlapCategory = {}
  self.tWaitingSlap = {}
end
function NewFaceSlapSystem:RevertSlap()
  log(bWriteLog and "NewFaceSlapSystem:RevertSlap ")
  self:ReleaseBlockSlap()
  self:_ShowNext()
end
function NewFaceSlapSystem:ShowFaceSlapByID(id, bShowMore)
  if not self:IsCanShow() then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapByID return of not IsCanShow, id : " .. tostring(id))
    return
  end
  local index = self:_GetShowIndexByID(id)
  if index <= 0 then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapByID return of index = " .. tostring(index) .. " id = " .. tostring(id))
    return
  end
  if self.tShownMap[id] and not bShowMore then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapByID already shows the face slap, id : " .. tostring(id))
    return
  end
  if not self:IsExistInWaitFaceSlap() then
    table.insert(self.tWaitingSlap, index)
    table.sort(self.tWaitingSlap, function(a, b)
      return a < b
    end)
  end
  if not self:CheckIsAndroidStackEmpty() then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapByID CheckIsAndroidStackEmpty is false")
    return
  end
  log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapByID show the face slap, id : " .. tostring(id))
  self:_ShowWait()
end
function NewFaceSlapSystem:ShowFaceSlapForce(id, ignoreAndroidStack)
  if not self:IsCanShow(ignoreAndroidStack) then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapForce return of not IsCanShow, id : " .. tostring(id))
    return
  end
  local index = self:_GetShowIndexByID(id)
  if index <= 0 then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapForce return of index = " .. tostring(index) .. " id = " .. tostring(id))
    return
  end
  if self.tShownMap[id] then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapForce already shows the face slap, id : " .. tostring(id))
    return
  end
  self:HandleForceShow(index)
  self.iCurShowIndex = index
  log(bWriteLog and string.format("NewFaceSlapSystem:ShowFaceSlapForce. JumpIndex, index=%s, iCurShowIndex=%s", tostring(index), tostring(self.iCurShowIndex)))
  if not ignoreAndroidStack and not self:CheckIsAndroidStackEmpty() then
    log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapForce CheckIsAndroidStackEmpty is false")
    return
  end
  log(bWriteLog and "NewFaceSlapSystem:ShowFaceSlapForce show the face slap, id : " .. tostring(id))
  self:_ShowWait()
end
function NewFaceSlapSystem:IsExistInWaitFaceSlap(index)
  for _, waitIndex in ipairs(self.tWaitingSlap) do
    if waitIndex == index then
      return true
    end
  end
  return false
end
function NewFaceSlapSystem:HandleForceShow(index)
  if not self:IsExistInWaitFaceSlap(index) then
    table.insert(self.tWaitingSlap, index)
  end
  table.sort(self.tWaitingSlap, function(a, b)
    return a < b
  end)
  for i = #self.tWaitingSlap, 1, -1 do
    if index > self.tWaitingSlap[i] then
      table.remove(self.tWaitingSlap, i)
    end
  end
end
function NewFaceSlapSystem:_GetNextShowIndex()
  local iListCount = self.tFaceSlapCategory and #self.tFaceSlapCategory or 0
  log(bWriteLog and "NewFaceSlapSystem:_GetNextShowIndex, iCurShowIndex = " .. tostring(self.iCurShowIndex) .. " FaceSlapListCount = " .. tostring(iListCount))
  self.iCurShowIndex = FuncUtil.Clamp(self.iCurShowIndex, 0, iListCount)
  for i = self.iCurShowIndex + 1, iListCount do
    local info = self.tFaceSlapCategory[i]
    if not info or info.NeedLimit and 0 >= self.iShowLimit then
    elseif info.TriggerEventType ~= "" and info.TriggerEventID ~= "" then
      local EventType = _G[info.TriggerEventType]
      local EventID = _G[info.TriggerEventID]
      local key = EventType .. "_" .. EventID
      if not self.tEventStatus[key] then
        log_warning_format("NewFaceSlapSystem:_GetNextShowIndex return event ID = %d, key = %s", info.ID, key)
        self:_DelayCheckExtEvent(EventType, EventID)
        return 0
      end
      if self.tEventStatus[key] == WaitDataStatus.Wait then
        log_warning_format("NewFaceSlapSystem:_GetNextShowIndex return WaitDataStatus ID = %d, key = %s", info.ID, key)
        return 0
      elseif self.tEventStatus[key] == WaitDataStatus.Completed then
        local NewFaceSlapConfig = require("client.slua.logic.FaceSlap.NewFaceSlapConfig")
        local CheckFunc = NewFaceSlapConfig[info.ModuleID]
        if CheckFunc and CheckFunc() then
          log_format("NewFaceSlapSystem:_GetNextShowIndex return real index by event ID = %d, key = %s", info.ID, key)
          return i
        end
      end
    else
      local NewFaceSlapConfig = require("client.slua.logic.FaceSlap.NewFaceSlapConfig")
      local CheckFunc = NewFaceSlapConfig[info.ModuleID]
      if CheckFunc and CheckFunc() then
        log_format("NewFaceSlapSystem:_GetNextShowIndex return real index by checkFunc ID = %d", info.ID)
        return i
      end
    end
  end
  return 0
end
function NewFaceSlapSystem:_GetShowIndexByID(id)
  local iListCount = self.tFaceSlapCategory and #self.tFaceSlapCategory or 0
  log(bWriteLog and "NewFaceSlapSystem:_GetShowIndexByID, iCurShowIndex = " .. tostring(self.iCurShowIndex) .. " FaceSlapListCount = " .. tostring(iListCount))
  for i = 1, iListCount do
    local info = self.tFaceSlapCategory[i]
    if info and info.ModuleID == id then
      local NewFaceSlapConfig = require("client.slua.logic.FaceSlap.NewFaceSlapConfig")
      local CheckFunc = NewFaceSlapConfig[info.ModuleID]
      if CheckFunc and CheckFunc() then
        return i
      else
        break
      end
    end
  end
  return 0
end
function NewFaceSlapSystem:_DelayCheckExtEvent(eventType, eventId)
  local key = eventType .. "_" .. eventId
  if not self.tEventStatus[key] then
    log(bWriteLog and "NewFaceSlapSystem:_DelayCheckExtEvent async start, key = " .. key)
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, ASYNC_TIME_OUT, eventType, eventId)
      log(bWriteLog and "NewFaceSlapSystem:_DelayCheckExtEvent async end, key = " .. key)
      if self.tEventStatus[key] ~= WaitDataStatus.Completed then
        log(bWriteLog and "NewFaceSlapSystem:_DelayCheckExtEvent async end, time out, key = " .. key)
        self.tEventStatus[key] = WaitDataStatus.TimeOut
      end
      self:_ShowNext()
    end)
    self.tEventStatus[key] = WaitDataStatus.Wait
  else
    log(bWriteLog and "NewFaceSlapSystem:_DelayCheckExtEvent async is running, key = " .. key)
  end
end
function NewFaceSlapSystem:_GetLocalCache()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFaceSlapDataCache)
  tCacheData = tCacheData or {}
  return tCacheData
end
function NewFaceSlapSystem:_SaveFaceSlapShowSwitch(bClose)
  self.  local tCacheData = self:_GetLocalCache()
  tCacheData.bIsCloseFaceSlap = bClose
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(tCacheData, PlayerPrefsSystem.ePlayerPrefsType.eFaceSlapDataCache)
end
function NewFaceSlapSystem:_GetLocalCacheFaceSlapSwitch()
  local tCacheData = self:_GetLocalCache()
  if type(tCacheData.bIsCloseFaceSlap) == "nil" then
    return false
  end
  return tCacheData.bIsCloseFaceSlap
end
function NewFaceSlapSystem:RemoveWaitingMainCity()
  log(bWriteLog and "NewFaceSlapSystem:RemoveWaitingMainCity")
  self.waitingMainCity = false
end
function NewFaceSlapSystem:_HasWaitData()
  for _, status in pairs(self.tEventStatus) do
    if status == WaitDataStatus.Wait then
      return true
    end
  end
  return false
end
function NewFaceSlapSystem:_IsActivityReady()
  local key = string.format("%s_%s", EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_ACTIVITY_READY)
  return self.tEventStatus[key] and self.tEventStatus[key] == WaitDataStatus.Completed or false
end
function NewFaceSlapSystem:_SetActivityReady(bReady)
  if not bReady then
    return
  end
  local key = string.format("%s_%s", EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_ACTIVITY_READY)
  if type(bReady) == "boolean" then
    if bReady then
      self.tEventStatus[key] = WaitDataStatus.Completed
    else
      self.tEventStatus[key] = WaitDataStatus.Wait
    end
  else
    self.tEventStatus[key] = bReady
  end
end
function NewFaceSlapSystem:HasShowedFaceSlap(ModuleId)
  if not ModuleId then
    return false
  end
  return self.tShownMap[ModuleId]
end
local AS_Key_Map = {
  [UIManager.UI_Config.xmission_main.keyName] = true
}
function NewFaceSlapSystem:CheckIsAndroidStackEmpty()
  local isAndroidStackEmpty = UIManager.IsAndroidStackEmpty(AS_Key_Map)
  log(bWriteLog and string.format("NewFaceSlapSystem:CheckIsAndroidStackEmpty. isAndroidStackEmpty=%s", tostring(isAndroidStackEmpty)))
  if not isAndroidStackEmpty then
    local topUIName = tostring(UIManager.GetTopUIName())
    log(bWriteLog and string.format("NewFaceSlapSystem:CheckIsAndroidStackEmpty. topUIName=%s", tostring(topUIName)))
    log_tree("NewFaceSlapSystem:_CheckAndroidStack return isAndroidStackEmpty = false GetTopUINameList:", UIManager.GetTopUINameList(3))
    return false
  end
  return true
end
function NewFaceSlapSystem:CheckCanShowInMainCity()
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local defaultEnterMainCity = main_city_process_util.GetMainCityEnterSwitch()
  log(bWriteLog and "NewFaceSlapSystem:CheckCanShowInMainCity defaultEnterMainCity = " .. tostring(defaultEnterMainCity))
  return defaultEnterMainCity
end
function NewFaceSlapSystem:InitLobbyFaceSlapStatus()
  self:_SetupStatus()
  self:_HandleFaceSlapCategory()
end
function NewFaceSlapSystem:_SetupStatus()
  local Status = self.tLobbyStatus[self.iCurLobbyType]
  self.iShowLimit = Status and Status.iShowLimit or MAX_SHOW_LIMIT
  self.iCurShowIndex = Status and Status.iCurShowIndex or 0
  self.bStart = Status and Status.bStart or false
  self.bEnd = Status and Status.bEnd or false
  self.tWaitingSlap = Status and Status.tWaitingSlap or {}
  self.tShownMap = Status and Status.tShownMap or {}
  log_tree("NewFaceSlapSystem:_SetupStatus = ", Status)
end
function NewFaceSlapSystem:_HandleFaceSlapCategory()
  self.tFaceSlapCategory = {}
  local TD = CDataTable.GetTableByFilter("FaceSlapCategory", "LobbyType", self.iCurLobbyType)
  for _, v in pairs(TD) do
    table.insert(self.tFaceSlapCategory, v)
  end
  table.sort(self.tFaceSlapCategory, function(a, b)
    return a.Sort < b.Sort
  end)
  self.iPreSlapCount = 0
  self.iCommercialCount = 0
  self.iFaceSlapCategoryCount = #self.tFaceSlapCategory
  for _, v in pairs(self.tFaceSlapCategory) do
    if v.TriggerEventType ~= "" and v.TriggerEventID ~= "" then
      local EventType = _G[v.TriggerEventType]
      local EventID = _G[v.TriggerEventID]
      self:AddCommonEvent(EventType, EventID, self.OnDelayEvent, self)
    end
    if v.FaceSlapType == FaceSlapType.Pre then
      self.iPreSlapCount = self.iPreSlapCount + 1
    elseif v.FaceSlapType == FaceSlapType.Commercial then
      self.iCommercialCount = self.iCommercialCount + 1
    end
  end
end
function NewFaceSlapSystem:SaveLobbyStatus()
  if not self.iCurLobbyType then
    return
  end
  local Status = {
    iShowLimit = self.iShowLimit,
    iCurShowIndex = self.iCurShowIndex,
    bStart = self.bStart,
    bEnd = self.bEnd,
    tWaitingSlap = self.tWaitingSlap,
    tShownMap = self.tShownMap
  }
  self.tLobbyStatus[self.iCurLobbyType] = Status
end
function NewFaceSlapSystem:SetGMTest(value)
  self.bGMTest = value
  if value then
    self.iShowLimit = 9999
  else
    self.iShowLimit = MAX_SHOW_LIMIT
  end
end
function NewFaceSlapSystem:GetGMTest()
  return self.bGMTest
end
function NewFaceSlapSystem:SetGMIgnoreNewPlayer(ignore)
  self.gmIgnoreNewPlayer = ignore
  if self.gmIgnoreNewPlayer then
    self:RevertSlap()
  end
end
function NewFaceSlapSystem:SetIsGMClose(close)
  self.IsGMClose = close
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CNewFaceSlapSystem = class(CModuleBase, nil, NewFaceSlapSystem)
return CNewFaceSlapSystem