local ENetRole = import("ENetRole")
local USTExtraGameInstance = import("STExtraGameInstance")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local FSingleStrategyRecordInReplay = import("/Script/ShadowTrackerExtra.SingleStrategyRecordInReplay")
local UGameplayStatics = import("GameplayStatics")
local UHiggsBosonComponent = import("HiggsBosonComponent")
local sluaIsValid = slua.isValid
local FormatLog = FuncUtil.FormatLog
local LogIf = SecurityCommonUtils.LogIf
local IsNonemptyString = SecurityCommonUtils.IsNonemptyString
local bIsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local bIsNotRelease = not USTExtraBlueprintFunctionLibrary.IsRelease()
local GetEnumNameByValue = USTExtraBlueprintFunctionLibrary.GetEnumNameByValue
local IsBool = SecurityCommonUtils.IsBool
local IsNumber = SecurityCommonUtils.IsNumber
local IsString = SecurityCommonUtils.IsString
local IsNonemptyString = SecurityCommonUtils.IsNonemptyString
local _nReportNosChatTimerID
local _nReportNosChatMessageID = 1
local _tReportNosChatQueue = {}
local sEnableAlertWindowConsoleVariableName = "higgs.EnableClientShowSecurityAlert"
local bIsSkipAlertServer = false
local LastTimeHandleAlert = -1
local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
local _GetUserdataName = function(uUserdata)
  if not sluaIsValid(uUserdata) then
    return ""
  end
  local StringUtil = require("common.string_util")
  local tSplitArray = StringUtil.Split(tostring(uUserdata), " ")
  local Result = ""
  if tSplitArray and tSplitArray[1] and tSplitArray[3] then
    Result = tSplitArray[1] .. tSplitArray[3]
  end
  if uUserdata.GetItemDefineID then
    local DefineID = uUserdata:GetItemDefineID().TypeSpecificID
    Result = string.format("%s, DefineID=%s", Result, DefineID)
  end
  return Result
end
local _GetServerNameInClient = function()
  if not Client then
    return ""
  end
  local logicGMServer = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_server")
  if not logicGMServer then
    return ""
  end
  local sServerName = logicGMServer._cur_server
  if not IsNonemptyString(sServerName) then
    return ""
  end
  return sServerName
end
local IsCellPhone = function()
  if not Client then
    return false
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local sPlatform = Client.GetDevicePlatformName()
  return sPlatform == DevicePlatformNameMacros.IOS or sPlatform == DevicePlatformNameMacros.Android
end
local ExtractFieldFromPackageInfo = function(sPackageInfo, sPrefix, sSuffix)
  if not (IsNonemptyString(sPackageInfo) and IsNonemptyString(sPrefix)) or not IsNonemptyString(sSuffix) then
    FormatLog("invalid %s, %s, %s", sPackageInfo, sPrefix, sSuffix)
    return ""
  end
  if not string.find(sPackageInfo, sPrefix) then
    return ""
  end
  if not string.find(sPackageInfo, sSuffix) then
    return ""
  end
  local _, nStart = string.find(sPackageInfo, sPrefix)
  nStart = nStart + 1
  local nEnd, _ = string.find(sPackageInfo, sSuffix, nStart)
  nEnd = nEnd - 1
  if nStart > nEnd then
    return ""
  end
  return string.sub(sPackageInfo, nStart, nEnd)
end
function IsCanHandleAlert()
  if not slua.isValid(CGameWorld) then
    return true
  end
  local CurrentTime = import("GameplayStatics").GetTimeSeconds(CGameWorld)
  local Result = true
  if 0 < LastTimeHandleAlert and CurrentTime > LastTimeHandleAlert and CurrentTime - LastTimeHandleAlert < 1 then
    Result = false
  end
  LastTimeHandleAlert = CurrentTime
  return Result
end
local CHiggsBosonComponent = {
  ClientRPC = {},
  ServerRPC = {},
  sMutualServerName = ""
}
CHiggsBosonComponent.ClientRPC.RPC_Client_ShowSecurityAlertWindow = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
CHiggsBosonComponent.ClientRPC.RPC_Client_ServerNameAck = {Reliable = false}
CHiggsBosonComponent.ServerRPC.RPC_Server_TellServerName = {
  Reliable = false,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function CHiggsBosonComponent.SetClientAlertWindowEnabled(bIsEnabled)
  if LogIf(not IsBool(bIsEnabled), "invalid bIsEnabled") then
    return
  end
  local uGameInstance = USTExtraGameInstance.GetInstance()
  if not slua.isValid(uGameInstance) then
    return
  end
  local nEnableInteger = 0
  if bIsEnabled then
    nEnableInteger = 1
  end
  uGameInstance:ExecuteCMD(sEnableAlertWindowConsoleVariableName, nEnableInteger)
end
function CHiggsBosonComponent:_IsAuthority()
  local uController = self:GetOwner()
  if not sluaIsValid(uController) then
    return false
  end
  return uController.Role == ENetRole.ROLE_Authority
end
function CHiggsBosonComponent:_IsAutonomousProxy()
  local uController = self:GetOwner()
  if not sluaIsValid(uController) then
    return false
  end
  return uController.Role == ENetRole.ROLE_AutonomousProxy
end
function CHiggsBosonComponent:ReceiveBeginPlay()
  CHiggsBosonComponent.__super.ReceiveBeginPlay(self)
  if bIsNotRelease and self:_IsAutonomousProxy() and not self._nTellServerNameTimerID and IsCellPhone() then
    self._nTellServerNameTimerID = self:AddGameTimer(10, true, function()
      local sServerName = _GetServerNameInClient()
      if not IsNonemptyString(sServerName) then
        return
      end
      self:RPC_Server_TellServerName(sServerName)
    end)
  end
  if bIsDevelopment then
    if _nReportNosChatTimerID then
      Game:ClearTimer(_nReportNosChatTimerID)
      _nReportNosChatTimerID = nil
    end
    _nReportNosChatTimerID = Game:SetTimer(2, true, function()
      CHiggsBosonComponent._ProcessReportChatRobotQueue()
    end)
  end
  if self:_IsAutonomousProxy() and EVENTTYPE_STATE then
    self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnBattleResult, self)
    log(bWriteLog and "CHiggsBosonComponent AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnBattleResult, self)")
  end
  if Client and EVENTTYPE_INGAME_NORMAL and EVENTID_GAME_MODE_TYPE_CHANGE then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_TYPE_CHANGE, self.OnGameModeType, self)
  end
end
function CHiggsBosonComponent.RecordStrategyTimestampInReplay(nStrategyTypeInReplay, nValue, uController, nTimeInSecondsOffSet)
  nValue = math.tointeger(tonumber(nValue))
  if not (nValue and 0 <= nValue) or not (nValue <= 255) then
    return
  end
  if uController and uController.Object then
    uController = uController.Object
  end
  if not sluaIsValid(uController) then
    return
  end
  local uPlayerState = uController.PlayerState
  if not sluaIsValid(uPlayerState) then
    return
  end
  local sUID = uPlayerState.PlayerUID
  if not IsNonemptyString(sUID) then
    return
  end
  if not sluaIsValid(CGameWorld) then
    return
  end
  local uGameInstance = UGameplayStatics.GetGameInstance(CGameWorld)
  if not sluaIsValid(uGameInstance) then
    return
  end
  local uCompletePlayBack = uGameInstance:GetCompletePlayback()
  if not sluaIsValid(uCompletePlayBack) then
    return
  end
  if not uCompletePlayBack:IsInRecordState() then
    return
  end
  local nReplayTimeInSeconds = math.floor(uCompletePlayBack:GetCurrentTimeInReplay())
  if nTimeInSecondsOffSet == nil then
    nTimeInSecondsOffSet = 0
  end
  nReplayTimeInSeconds = nReplayTimeInSeconds + nTimeInSecondsOffSet
  if nTimeInSecondsOffSet < 0 and nReplayTimeInSeconds < 0 then
    nReplayTimeInSeconds = 0
  end
  if not (0 <= nReplayTimeInSeconds) or not (nReplayTimeInSeconds <= 65535) then
    return
  end
  local uSingleRecord = FSingleStrategyRecordInReplay()
  uSingleRecord.CountValue = nValue
  uSingleRecord.ReplayTimeStampInSeconds = nReplayTimeInSeconds
  uCompletePlayBack:AddStrategyRecord(sUID, nStrategyTypeInReplay, uSingleRecord)
end
function CHiggsBosonComponent:RPC_Server_TellServerName(sServerName)
  if not bIsDevelopment then
    return
  end
  if LogIf(not IsNonemptyString(sServerName), "invalid sServerName=%s", sServerName) then
    return
  end
  if not IsNonemptyString(CHiggsBosonComponent.sMutualServerName) then
    CHiggsBosonComponent.sMutualServerName = sServerName
    FormatLog("CHiggsBosonComponent.sMutualServerName=%s", CHiggsBosonComponent.sMutualServerName)
  end
  self:RPC_Client_ServerNameAck()
end
function CHiggsBosonComponent:RPC_Client_ShowSecurityAlertWindow(sMessage)
  if not bIsDevelopment then
    return
  end
  CHiggsBosonComponent._ClientShowSecurityAlertWindow(sMessage)
end
function CHiggsBosonComponent:RPC_Client_ServerNameAck()
  if not bIsDevelopment then
    return
  end
  if not self._nTellServerNameTimerID then
    return
  end
  self:RemoveGameTimer(self._nTellServerNameTimerID)
  self._nTellServerNameTimerID = nil
end
if bIsDevelopment then
  function CHiggsBosonComponent.StaticShowSecurityAlertInDev(uPlayerController, sMessage, bIsClientShowWindow, bSkipServer)
    if uPlayerController and uPlayerController.Object then
      uPlayerController = uPlayerController.Object
    end
    if LogIf(not sluaIsValid(uPlayerController), "invalid uPlayerController") then
      return
    end
    if LogIf(not IsString(sMessage), "invalid sMessage") then
      return
    end
    if not IsBool(bIsClientShowWindow) then
      bIsClientShowWindow = true
    end
    if not bIsDevelopment then
      return
    end
    if not IsCanHandleAlert() then
      return
    end
    local uHiggsBosonComponent = uPlayerController:GetComponentByClass(UHiggsBosonComponent)
    if LogIf(not sluaIsValid(uHiggsBosonComponent), "invalid higgs") then
      if Client then
        if bIsClientShowWindow then
          CHiggsBosonComponent._ClientShowSecurityAlertWindow(sMessage)
        end
        if Client then
          sMessage = string.format([[
	Name=%s, UID=%s, OpenID=%s
	%s]], tostring(DataMgr.roleData.nickName), tostring(DataMgr.roleData.uid), tostring(DataMgr.roleData.openID), sMessage)
        end
        CHiggsBosonComponent._ReportChatRobot(string.format([[
server=%s
%s]], _GetServerNameInClient(), sMessage), nil)
      end
      return
    end
    local OldSkipServer = uHiggsBosonComponent.bSkipAlertServer
    uHiggsBosonComponent.bSkipAlertServer = bSkipServer
    uHiggsBosonComponent:ShowABCD(sMessage, bIsClientShowWindow)
    uHiggsBosonComponent.bSkipAlertServer = OldSkipServer
  end
  function CHiggsBosonComponent:ShowABCD(sMessage, bIsClientShowWindow)
    if LogIf(not IsString(sMessage), "invalid sMessage") then
      return
    end
    if not IsBool(bIsClientShowWindow) then
      bIsClientShowWindow = true
    end
    if not bIsDevelopment then
      return
    end
    if not IsCanHandleAlert() then
      return
    end
    if bIsClientShowWindow then
      if self:_IsAutonomousProxy() then
        CHiggsBosonComponent._ClientShowSecurityAlertWindow(sMessage)
      elseif self:_IsAuthority() then
        self:RPC_Client_ShowSecurityAlertWindow(sMessage)
      end
    end
    if self:_IsAutonomousProxy() then
      local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
      sMessage = string.format([[
%s
ClientVersion=%s]], sMessage, tostring(ToolReportUtil:GetPackageInfo()))
    end
    if not self.bSkipAlertServer then
      self:C2SSendAlert(sMessage)
    end
  end
  function CHiggsBosonComponent._ClientShowSecurityAlertWindow(sMessage)
    if LogIf(not IsString(sMessage), "invalid sMessage") then
      return
    end
    if not bIsDevelopment then
      return
    end
    if LogIf(not Client, "not client") then
      return
    end
    if USTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue(sEnableAlertWindowConsoleVariableName) <= 0 then
      return
    end
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(IngameTipsTools.MSGBOX_SHOW_TYPE_TWO, "SecurityAlert(only show in development build)", sMessage, function()
      CHiggsBosonComponent.SetClientAlertWindowEnabled(false)
    end, nil, "Leave me alone", "I know")
    FormatLog("sMessage=%s", sMessage)
  end
  function CHiggsBosonComponent._ReportChatRobot(sMessage, uHiggsBosonComponent)
    if LogIf(not IsString(sMessage), "invalid sMessage") then
      return
    end
    if not bIsDevelopment then
      return
    end
    local bIsReleaseBranch = true
    local bIsStableBranch = true
    local sBranchBuildDate = false
    local sBranchName
    FormatLog("global_package_make_time_map=%s", global_package_make_time_map)
    if global_package_make_time_map then
      sBranchBuildDate = sBranchBuildDate or global_package_make_time_map["Mfg. Date"]
      sBranchName = sBranchName or tostring(global_package_make_time_map.Branch)
    end
    local sPackageInfo = tostring(require("client.config.PackageInfo").GetAssistInfoMsg())
    FormatLog("sPackageInfo=%s", sPackageInfo)
    if sPackageInfo then
      sBranchName = sBranchName or ExtractFieldFromPackageInfo(sPackageInfo, "Branch:%[", "%]")
      sBranchBuildDate = sBranchBuildDate or ExtractFieldFromPackageInfo(sPackageInfo, "MfgDate:%[", "%]")
    end
    FormatLog("sBranchName=%s, BuildDate=%s", sBranchName, sBranchBuildDate)
    if sBranchName then
      sBranchName = string.lower(sBranchName)
      if not string.find(sBranchName, "release") then
        bIsReleaseBranch = false
        FormatLog("not release")
      end
      if not string.find(sBranchName, "stable") then
        bIsStableBranch = false
        FormatLog("not stable")
      end
    end
    local nSkipAlertTimeSinceBuild = -1
    if bIsStableBranch then
      nSkipAlertTimeSinceBuild = 172800
      FormatLog("stable alert time=%s", nSkipAlertTimeSinceBuild)
    end
    if bIsReleaseBranch then
      nSkipAlertTimeSinceBuild = 1209600
      FormatLog("release alert time=%s", nSkipAlertTimeSinceBuild)
    end
    if not _G.IsEditor and 0 < nSkipAlertTimeSinceBuild and IsString(sBranchBuildDate) then
      local nYear, nMonth, nDay, nHour, nMinute, nSeconds = sBranchBuildDate:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
      FormatLog("YMDHMS=%s,%s,%s,%s,%s,%s", nYear, nMonth, nDay, nHour, nMinute, nSeconds)
      local nBuildTime = os.time({
        year = nYear,
        month = nMonth,
        day = nDay,
        hour = nHour,
        min = nMinute,
        sec = nSeconds
      })
      local nCurrentTime = os.time()
      local nElapsedSecondsSinceBuild = os.difftime(nCurrentTime, nBuildTime)
      FormatLog("%s,%s", nElapsedSecondsSinceBuild, nSkipAlertTimeSinceBuild)
      if nSkipAlertTimeSinceBuild < nElapsedSecondsSinceBuild then
        bSkipUploadNoschat = true
        FormatLog("nElapsedSecondsSinceBuild > nSkipAlertTimeSinceBuild")
      end
    end
    local version = ""
    local PackageInfo = require("client.config.PackageInfo")
    if PackageInfo then
      version = PackageInfo.GetAssistInfoMsg()
    end
    sMessage = string.format([[
	version=%s, %s, battle=%s, ModeID=%s
	%s]], version, CHiggsBosonComponent.sMutualServerName, _G.GameID, _G.ModeID, sMessage)
    if _G.IsEditor then
      bSkipUploadNoschat = true
      FormatLog("is editor")
    end
    if string.find(CHiggsBosonComponent.sMutualServerName, "SR") then
      bSkipUploadNoschat = true
      FormatLog("is SR safe")
    end
    if sBranchName and not bIsReleaseBranch and not bIsStableBranch then
      bSkipUploadNoschat = true
      FormatLog("not release or stable")
    end
    if bIsSkipAlertServer then
      bSkipUploadNoschat = true
      FormatLog("bIsSkipAlertServer")
    end
    if bSkipUploadNoschat then
      FormatLog("bSkipUploadNoschat")
      FormatLog(sMessage)
      return
    end
    local sNoschatLog = string.format([[
AntiCheatStrategyTriggered, id=%d
stack traceback:
%s
]], _nReportNosChatMessageID, sMessage)
    _nReportNosChatMessageID = _nReportNosChatMessageID + 1
    table.insert(_tReportNosChatQueue, {sNoschatLog, 4})
  end
  function CHiggsBosonComponent._ProcessReportChatRobotQueue()
    for nKey, LogTable in pairs(_tReportNosChatQueue) do
      local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
      GameReportUtils.ReportException(LogTable[1], ClientToolsReport.Enum_CrashKit_Type.Enum_JS)
      LogTable[2] = LogTable[2] - 1
      if LogTable[2] <= 0 then
        _tReportNosChatQueue[nKey] = nil
      end
      break
    end
  end
else
  function CHiggsBosonComponent.StaticShowSecurityAlertInDev(uPlayerController, sMessage, bIsClientShowWindow, bSkipServer)
    return
  end
end
function CHiggsBosonComponent.SkipAlertServer()
  bIsSkipAlertServer = true
  FormatLog("")
end
function CHiggsBosonComponent:SendAntiDataFlow()
  log(bWriteLog and "[CHiggsBosonComponent:SendAntiDataFlow] start")
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  log(bWriteLog and string.format("[CHiggsBosonComponent:SendAntiDataFlow] MoveInputAngleSample Count=%d, MoveInputAngleDistribution Count=%d", uGameInstance.MoveInputAngleSample:Num(), uGameInstance.MoveInputAngleDistribution:Num()))
  if not (uGameInstance.MoveInputAngleSample:Num() > 0) then
    log(bWriteLog and string.format("[CHiggsBosonComponent:SendAntiDataFlow] invalid MoveInputAngleSample"))
    return
  end
  if not (uGameInstance.MoveInputAngleDistribution:Num() > 0) then
    log(bWriteLog and string.format("[CHiggsBosonComponent:SendAntiDataFlow] invalid MoveInputAngleDistribution"))
    return
  end
  local MoveInputAngleSample = slua.ToPureTable(uGameInstance.MoveInputAngleSample)
  local MoveInputAngleDistribution = slua.ToPureTable(uGameInstance.MoveInputAngleDistribution)
  local AntiDataFlow = {}
  AntiDataFlow.GameSvrId = uGameInstance.AntiDataFlow.GameSvrId
  AntiDataFlow.dtEventTime = uGameInstance.AntiDataFlow.dtEventTime
  AntiDataFlow.GameAppID = uGameInstance.AntiDataFlow.GameAppID
  AntiDataFlow.OpenID = uGameInstance.AntiDataFlow.OpenID
  AntiDataFlow.PlatID = uGameInstance.AntiDataFlow.PlatID
  AntiDataFlow.AreaID = uGameInstance.AntiDataFlow.AreaID
  AntiDataFlow.BattleID = uGameInstance.AntiDataFlow.BattleID
  AntiDataFlow.UID = uGameInstance.AntiDataFlow.UID
  AntiDataFlow.ClientVersion = uGameInstance.AntiDataFlow.ClientVersion
  AntiDataFlow.MatchMode = uGameInstance.AntiDataFlow.MatchMode
  log_tree("AntiDataFlow", AntiDataFlow)
  log_tree("MoveInputAngleDistribution", MoveInputAngleDistribution)
  NetUtil.SendPkg("on_crow_update_ntf2", AntiDataFlow, MoveInputAngleSample, MoveInputAngleDistribution)
  uGameInstance.MoveInputAngleSample:Clear()
  uGameInstance.MoveInputAngleDistribution:Clear()
  log(bWriteLog and "[CHiggsBosonComponent:SendAntiDataFlow] data send finished")
end
function CHiggsBosonComponent:SendHitFireBtnFlow()
  log(bWriteLog and "[CHiggsBosonComponent:SendHitFireBtnFlow] start")
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  local SampleClusterArrayNum = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Num()
  if SampleClusterArrayNum <= 0 then
    log(bWriteLog and "[CHiggsBosonComponent:SendHitFireBtnFlow] SampleClusterArrayNum is 0, skip")
    return
  end
  local HitFireBtnFlow = {}
  HitFireBtnFlow.GameSvrId = uGameInstance.HitFireBtnFlow.GameSvrId
  HitFireBtnFlow.dtEventTime = uGameInstance.HitFireBtnFlow.dtEventTime
  HitFireBtnFlow.GameAppID = uGameInstance.HitFireBtnFlow.GameAppID
  HitFireBtnFlow.OpenID = uGameInstance.HitFireBtnFlow.OpenID
  HitFireBtnFlow.PlatID = uGameInstance.HitFireBtnFlow.PlatID
  HitFireBtnFlow.AreaID = uGameInstance.HitFireBtnFlow.AreaID
  HitFireBtnFlow.BattleID = uGameInstance.HitFireBtnFlow.BattleID
  HitFireBtnFlow.UID = uGameInstance.HitFireBtnFlow.UID
  HitFireBtnFlow.MapID = uGameInstance.HitFireBtnFlow.MapID
  HitFireBtnFlow.ClientVersion = uGameInstance.HitFireBtnFlow.ClientVersion
  HitFireBtnFlow.MatchMode = uGameInstance.HitFireBtnFlow.MatchMode
  HitFireBtnFlow.HitFireBtnSampleClusterArray = {}
  for CppClusterIndex = 0, SampleClusterArrayNum - 1 do
    local SampleArrayNum = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Get(CppClusterIndex).HitFireBtnSampleArray:Num()
    HitFireBtnFlow.HitFireBtnSampleClusterArray[CppClusterIndex + 1] = {
      StartTime = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Get(CppClusterIndex).StartTime,
      HitFireBtnSampleArray = {
        Count = SampleArrayNum,
        LocX = {},
        LocY = {},
        StartFrame = {},
        EndFrame = {}
      }
    }
    for CppSampleIndex = 0, SampleArrayNum - 1 do
      HitFireBtnFlow.HitFireBtnSampleClusterArray[CppClusterIndex + 1].HitFireBtnSampleArray.LocX[CppSampleIndex + 1] = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Get(CppClusterIndex).HitFireBtnSampleArray:Get(CppSampleIndex).LocX
      HitFireBtnFlow.HitFireBtnSampleClusterArray[CppClusterIndex + 1].HitFireBtnSampleArray.LocY[CppSampleIndex + 1] = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Get(CppClusterIndex).HitFireBtnSampleArray:Get(CppSampleIndex).LocY
      HitFireBtnFlow.HitFireBtnSampleClusterArray[CppClusterIndex + 1].HitFireBtnSampleArray.StartFrame[CppSampleIndex + 1] = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Get(CppClusterIndex).HitFireBtnSampleArray:Get(CppSampleIndex).StartFrame
      HitFireBtnFlow.HitFireBtnSampleClusterArray[CppClusterIndex + 1].HitFireBtnSampleArray.EndFrame[CppSampleIndex + 1] = uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Get(CppClusterIndex).HitFireBtnSampleArray:Get(CppSampleIndex).EndFrame
    end
  end
  log_tree("HitFireBtnFlow", HitFireBtnFlow)
  NetUtil.SendPkg("on_crow_update_ntf3", HitFireBtnFlow)
  uGameInstance.HitFireBtnFlow.HitFireBtnSampleClusterArray:Clear()
  log(bWriteLog and "[CHiggsBosonComponent:SendHitFireBtnFlow] data send finished")
end
function CHiggsBosonComponent:OnBattleResult()
  log(bWriteLog and "CHiggsBosonComponent:OnBattleResult start")
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  local BattleID = uGameInstance.ClientBaseInfo.BattleID
  local MainModeID = uGameInstance:GetMainModeID()
  local ModeID = uGameInstance:GetModeID()
  local MoveInputsBitmapSize = uGameInstance.MoveInputsBitmapSize
  local MoveInputsBitmapData = uGameInstance.MoveInputsBitmapData
  local MinValidMoveInputSampleCount = uGameInstance.MinValidMoveInputSampleCount
  local InvalidMoveInputSampleCount = uGameInstance.InvalidMoveInputSampleCount
  log(bWriteLog and string.format("CHiggsBosonComponent:OnBattleResult] BattleID=%d, MainModeID=%d, ModeID=%d, MoveInputsBitmapSize=%d, MinValidMoveInputSampleCount=%d, InvalidMoveInputSampleCount=%d", BattleID, MainModeID, ModeID, MoveInputsBitmapSize, MinValidMoveInputSampleCount, InvalidMoveInputSampleCount))
  local BitmapDataSend = {}
  if 0 < MoveInputsBitmapSize and 0 < MoveInputsBitmapData:Num() then
    local ValidMoveInputSampleCount = 0
    for _, Count in pairs(MoveInputsBitmapData) do
      ValidMoveInputSampleCount = ValidMoveInputSampleCount + Count
    end
    if MinValidMoveInputSampleCount < ValidMoveInputSampleCount then
      for _, Count in pairs(MoveInputsBitmapData) do
        table.insert(BitmapDataSend, Count)
      end
      NetUtil.SendPkg("on_crow_update_ntf", BattleID, MainModeID, ModeID, MoveInputsBitmapSize, BitmapDataSend, ValidMoveInputSampleCount, InvalidMoveInputSampleCount)
      log(bWriteLog and "[CHiggsBosonComponent:OnBattleResult] BitmapDataSend send finished")
    else
      log(bWriteLog and string.format("[CHiggsBosonComponent:OnBattleResult] ValidMoveInputSampleCount=%d, MinValidMoveInputSampleCount=%d, not send to backend", ValidMoveInputSampleCount, MinValidMoveInputSampleCount))
    end
    uGameInstance.MoveInputsBitmapSize = -1
    uGameInstance.MoveInputsBitmapData:Clear()
    log(bWriteLog and "[CHiggsBosonComponent:OnBattleResult] Reset MoveInputsBitmapSize and MoveInputsBitmapData")
  end
  self:SendAntiDataFlow()
  self:SendHitFireBtnFlow()
end
function CHiggsBosonComponent:OnGameModeType(_, __, nGameModeType)
  printf(bWriteLog and "CHiggsBosonComponent:OnGameModeType nGameModeType[%s]", tostring(nGameModeType))
  local EGameModeCPPType = import("EGameModeType")
  if nGameModeType == EGameModeCPPType.EDeathMatchGameMode then
    self.bOfflineMoveReady = true
    print(bWriteLog and "CHiggsBosonComponent:OnGameModeType OfflineMoveReady set true")
  end
end
function CHiggsBosonComponent:IsCharacterOwnerWerewolf()
  if not slua.isValid(self.CharacterOwner) then
    return false
  end
  if self.CharacterOwner.HeroPropFeature then
    local nHeroID = self.CharacterOwner.HeroPropFeature:GetCurrentHeroID()
    if nHeroID == UEnums.HeroID.Werewolf then
      printf(bWriteLog and "[CHiggsBosonComponent:IsCharacterOwnerWerewolf] CharacterOwner is a Werewolf, nHeroID:%s", tostring(nHeroID))
      return true
    end
  end
  return false
end
function CHiggsBosonComponent:IsCharacterOwnerButcher()
  if not slua.isValid(self.CharacterOwner) then
    return false
  end
  if self.CharacterOwner.HeroPropFeature then
    local nHeroID = self.CharacterOwner.HeroPropFeature:GetCurrentHeroID()
    if 0 < nHeroID then
      printf(bWriteLog and "[CHiggsBosonComponent:IsCharacterOwnerButcher] CharacterOwner is butcher, nHeroID:%s", tostring(nHeroID))
      return true
    end
  end
  return false
end
function CHiggsBosonComponent.OnLogin()
  print(bWriteLog and "[CHiggsBosonComponent.OnLogin] start")
  if Client and Client.GetDevicePlatformName() == "Android" then
    print(bWriteLog and "[CHiggsBosonComponent.OnLogin] Android")
    local time_ticker = require("common.time_ticker")
    local timer = time_ticker.AddTimerOnce(15, function()
      CHiggsBosonComponent.SendHisarData()
    end)
  end
end
function CHiggsBosonComponent.SendHisarData()
  print(bWriteLog and "[CHiggsBosonComponent.SendHisarData] start")
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  local HisarData = uGameInstance.HisarData
  NetUtil.SendPkg("hisar", HisarData.AppInstallData.FirstInstallTime, HisarData.AppInstallData.GuidStr, HisarData.DeviceId)
  print(bWriteLog and "[CHiggsBosonComponent.SendHisarData] end")
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CActorComponentBase, nil, CHiggsBosonComponent)