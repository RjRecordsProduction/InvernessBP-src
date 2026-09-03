local SoundMonitorSubsystem = {}
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local uAkGameplayStatics = import("AkGameplayStatics")
local AkAudioMonitor = import("AkAudioMonitor")
local ErrorInfoFilterMap = {
  LoadBank = {Monster = true, StickyBomb = true},
  UnloadBank = {
    Monster = true,
    StickyBomb = true,
    UI_hall_180 = true,
    Pandora = true
  },
  PostEvent = {UI_hall_Return = true, Play_StickyBomb_Explosion = true}
}
local ErrorCodeFilterMap = {Play_UnderWater_Out_Camera = true}
function SoundMonitorSubsystem:ctor()
  self.bDebug = true
  self.tRet = {}
  self.CriticalDetailStr = ""
  self.TotalPlayThreshold = 80
  self.ObjectPlayThreshold = 10
  self.Flags = {
    1,
    2,
    6
  }
  self.bEnable = false
  self.GraySwitch = false
  self.bHasSent = false
end
function SoundMonitorSubsystem:_PostConstruct()
  self:InitSwitches()
  if self.bEnable and self.GraySwitch then
    AkAudioMonitor.GetMonitorDataPtr()
    AkAudioMonitor.InitMonitorDataPtr()
    AkAudioMonitor.SetMonitorFlag(self.Flags, self.TotalPlayThreshold, self.ObjectPlayThreshold)
  end
end
function SoundMonitorSubsystem:InitSwitches()
  self.bEnable = LobbySystem.CheckOpen(BP_ENUM_SOUND_MONITOR_SWITCH)
  self.GraySwitch = DataMgr.isSoundMonitorOpen
  if Client and Client.IsDevelopment() then
    self.bEnable = true
    self.GraySwitch = true
    self.Flags = {65535}
  end
end
function SoundMonitorSubsystem:OnInit()
  if self.bEnable and self.GraySwitch then
    print(bWriteLog and "SoundMonitorSubsystem:OnInit")
    self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnCollectMonitorData, self)
  end
  self:TriggerAutoProfile(true)
end
function SoundMonitorSubsystem:OnRelease()
  self:TriggerAutoProfile(false)
  SoundMonitorSubsystem.__super.OnRelease(self)
end
function SoundMonitorSubsystem:OnRegister()
  print(bWriteLog and "SoundMonitorSubsystem:OnRegister")
  local MonitorData = AkAudioMonitor.GetMonitorDataPtr()
  self:AddControlEvent(MonitorData, "AkAudioEventTrigger", self.OnAudioEventSatusChanged, self)
  self:AddControlEvent(MonitorData, "AkAudioDetailErrorCodeDelegate", self.TraceNotEnoughMemoryToAllocError, self)
end
function SoundMonitorSubsystem:OnCollectMonitorData(_, _)
  if self.bHasSent then
    return
  end
  print(bWriteLog and string.format("SoundMonitorSubsystem:OnCollectMonitorData"))
  self.tRet = {}
  self:GetBasicInfo(self.tRet)
  self:GetTotalPlayInfo(self.tRet)
  self:GetObjectPlayInfo(self.tRet)
  self:GetCriticalInfo(self.tRet)
  self:GetReportErrorInfo(self.tRet)
  self:GetDetailErrorCodeRecord(self.tRet)
  self:SendSoundMonitorTlog(self.tRet)
end
function SoundMonitorSubsystem:SendSoundMonitorTlog(tContent)
  local sSendRet = table.concat(tContent, "|")
  if self.bDebug then
    print(bWriteLog and string.format("SoundMonitorSubsystem:SendSoundMonitorTlog %s", sSendRet))
  end
  local ClientTlogHandler = require("client.network.Protocol.ClientTlogHandler")
  ClientTlogHandler.send_report_lobby_common_tlog("SoundAbnormalFlow", sSendRet)
  self.bHasSent = true
end
function SoundMonitorSubsystem:GetBasicInfo(tContent)
  local BattleID = 0
  local MainMod = -1
  local ModeID = -1
  local BattleDuration = 0
  local UserAudioSetting = -1
  if type(g_game_id) == "number" then
    BattleID = g_game_id
    table.insert(tContent, BattleID)
  end
  MainMod = self:GetMainModeID()
  table.insert(tContent, MainMod)
  ModeID = GameMainConfig.GetModeID()
  table.insert(tContent, ModeID)
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    BattleDuration = uGameState:GetServerWorldTimeSeconds()
  end
  table.insert(tContent, math.floor(BattleDuration))
  UserAudioSetting = Client.GetSoundEffectQuality()
  table.insert(tContent, UserAudioSetting)
end
function SoundMonitorSubsystem:GetTotalPlayInfo(tContent)
  local TotalPlayRec = AkAudioMonitor.GetTotalPlayRecord()
  local TempRes = {}
  if TotalPlayRec and type(TotalPlayRec) ~= "string" then
    TempRes = FuncUtil.LuaArrayToTable(TotalPlayRec)
  end
  local nCount = #TempRes
  local sDetails = ""
  if 0 < nCount then
    table.sort(TempRes)
    sDetails = tostring(TempRes[#TempRes])
  end
  table.insert(tContent, self.TotalPlayThreshold)
  table.insert(tContent, nCount)
  table.insert(tContent, sDetails)
end
function SoundMonitorSubsystem:GetObjectPlayInfo(tContent)
  local TempRes = AkAudioMonitor.GetObjectPlayRecord()
  self:DebugContentData(TempRes)
  local nCount, tObjectInfo = self:SumObjectPlayInfo(TempRes)
  table.insert(tContent, self.ObjectPlayThreshold)
  table.insert(tContent, nCount)
end
function SoundMonitorSubsystem:GetCriticalInfo(tContent)
  table.insert(tContent, self.CriticalDetailStr)
end
function SoundMonitorSubsystem:SumObjectPlayInfo(tArray)
  local nSum = 0
  local tObjectNames = {}
  if tArray and type(tArray) ~= "string" then
    for key, value in pairs(tArray) do
      nSum = nSum + value
      local sFilterName = string.match(key, "[%a_%d]+") or ""
      local ObjectInfo = {sName = sFilterName, nCount = value}
      table.insert(tObjectNames, ObjectInfo)
      print(bWriteLog and "SoundMonitorSubsystem:SumObjectPlayInfo ", key, sFilterName)
    end
  end
  return nSum, tObjectNames
end
function SoundMonitorSubsystem:GetDetailErrorCodeRecord(tContent)
  local DetailErrorCodeRecord = AkAudioMonitor.GetDetailErrorCodeRecord()
  local TotalErrorInfoList = {}
  for ErrorCode, AKErrorInfo in pairs(DetailErrorCodeRecord) do
    local DetailStrList = {}
    for _, AKFunctionInfo in pairs(AKErrorInfo.DetailInfo) do
      if not ErrorCodeFilterMap[AKFunctionInfo.StrParam] then
        local InfoStr = string.format("%s-%s", AKFunctionInfo.FunctionName, AKFunctionInfo.StrParam)
        table.insert(DetailStrList, InfoStr)
      end
    end
    if 0 < #DetailStrList then
      local ErrorInfo = {}
      ErrorInfo.AkResultID = AKErrorInfo.AKRESULT_ID
      ErrorInfo.Detail = table.concat(DetailStrList, "+")
      ErrorInfo.nCount = #DetailStrList
      table.insert(TotalErrorInfoList, ErrorInfo)
    end
  end
  table.sort(TotalErrorInfoList, function(k1, k2)
    return k1.nCount > k2.nCount
  end)
  for i = 1, 5 do
    if TotalErrorInfoList[i] then
      table.insert(tContent, TotalErrorInfoList[i].nCount)
      table.insert(tContent, string.format("%d-%s", TotalErrorInfoList[i].AkResultID, TotalErrorInfoList[i].Detail))
    else
      table.insert(tContent, 0)
      table.insert(tContent, "")
    end
  end
end
function SoundMonitorSubsystem:GetReportErrorInfo(tContent)
  local tErrorInfoList = self:SortErrorInfo()
  for i = 1, 5 do
    if tErrorInfoList[i] then
      table.insert(tContent, tErrorInfoList[i].nCount)
      table.insert(tContent, string.format("%d-%s", tErrorInfoList[i].AkResultID, tErrorInfoList[i].Detail))
    else
      table.insert(tContent, 0)
      table.insert(tContent, "")
    end
  end
end
function SoundMonitorSubsystem:SortErrorInfo()
  local TempRes = AkAudioMonitor.GetReportErrorRecord()
  local tTotalErrorInfoList = {}
  for key, value in pairs(TempRes) do
    if value.AKRESULT_ID ~= 69 then
      local tErrorInfo = {}
      tErrorInfo.AkResultID = value.AKRESULT_ID
      tErrorInfo.Detail, tErrorInfo.nCount = self:GetFunctionInfo(slua.IndexReference(value, "DetailInfo"))
      if tErrorInfo.nCount > 0 then
        table.insert(tTotalErrorInfoList, tErrorInfo)
      end
    end
  end
  table.sort(tTotalErrorInfoList, function(k1, k2)
    return k1.nCount > k2.nCount
  end)
  self:DebugContentData(tTotalErrorInfoList, true)
  return tTotalErrorInfoList
end
function SoundMonitorSubsystem:ErrorInfoFilterOK(FunctionName, StrParam)
  if ErrorInfoFilterMap[FunctionName] and ErrorInfoFilterMap[FunctionName][StrParam] then
    return false
  end
  return true
end
function SoundMonitorSubsystem:SortObjectInfo(tData)
  table.sort(tData, function(k1, k2)
    return k1.nCount > k2.nCount
  end)
  local tTempRes = {}
  for index, value in ipairs(tData) do
    local sDetails = string.format("%s-%d", value.sName, value.nCount)
    tTempRes[index] = sDetails
  end
  return table.concat(tTempRes, "+")
end
function SoundMonitorSubsystem:GetFunctionInfo(tArray)
  local tFunctionInfo = {}
  for key, value in pairs(tArray) do
    if self:ErrorInfoFilterOK(value.FunctionName, value.StrParam) then
      local sInfo = string.format("%s-%s", value.FunctionName, value.StrParam)
      if not tFunctionInfo[sInfo] then
        tFunctionInfo[sInfo] = true
      end
    end
  end
  local TempRes = {}
  local nCount = 0
  for key, value in pairs(tFunctionInfo) do
    nCount = nCount + 1
    table.insert(TempRes, key)
  end
  return table.concat(TempRes, "+"), nCount
end
function SoundMonitorSubsystem:GetMainModeID()
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  if slua.isValid(uGameInstance) then
    local nMainModeID = uGameInstance:GetMainModeID()
    if 0 < nMainModeID then
      return nMainModeID
    end
  end
  return -1
end
function SoundMonitorSubsystem:DebugContentData(tContent, bIndex)
  if self.bDebug then
    if bIndex then
      for index, value in ipairs(tContent) do
        print(bWriteLog and string.format("SoundMonitorSubsystem:DebugContentDataIndex %d, %s", index, tostring(value)))
      end
    else
      for key, value in pairs(tContent) do
        print(bWriteLog and string.format("SoundMonitorSubsystem:DebugContentDataKey %s, %s", tostring(key), tostring(value)))
      end
    end
  end
end
function SoundMonitorSubsystem:OnAudioEventSatusChanged(AkName, Status)
  if Status == 0 then
    if not self.SoundNums then
      self.SoundNums = {}
    end
    if not self.SoundNums[AkName] then
      self.SoundNums[AkName] = 1
    else
      self.SoundNums[AkName] = self.SoundNums[AkName] + 1
    end
    local TotalNumber = 0
    local IsOutNum = false
    for Name, Number in pairs(self.SoundNums) do
      TotalNumber = TotalNumber + Number
      if TotalNumber > self.TotalPlayThreshold then
        IsOutNum = true
      end
    end
    local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
    if IsOutNum and GameReportUtils.CheckCanBugglyPostException("AudioNumberTooMuch") then
      local MsgStr = ""
      for Name, Number in pairs(self.SoundNums) do
        if 0 < Number then
          MsgStr = MsgStr .. " SoundName : " .. Name .. " Num : " .. Number .. " |"
        end
      end
      MsgStr = MsgStr .. "  TotalNum : " .. TotalNumber
      GameReportUtils.BugglyPostExceptionFull("AudioNumberTooMuch", MsgStr, true)
    end
  else
    if not self.SoundNums then
      self.SoundNums = {}
    end
    if self.SoundNums[AkName] and 0 < self.SoundNums[AkName] then
      self.SoundNums[AkName] = self.SoundNums[AkName] - 1
    end
  end
end
function SoundMonitorSubsystem:TriggerAutoProfile(bEnable)
  if not IsEditor and Client and Client.IsDevelopment() and (not Client.IsWindows() or Client.IsWindowOB() or Client.IsWindowsClientReplay()) then
    print(bWriteLog and string.format("SoundMonitorSubsystem:TriggerAutoProfile %s", bEnable))
    if bEnable then
      uAkGameplayStatics.StartProfilerCapture("Wwise_Profile_Auto.prof")
    else
      uAkGameplayStatics.StopProfilerCapture()
    end
  end
end
function SoundMonitorSubsystem:TraceNotEnoughMemoryToAllocError(ObjectName, EventName, DetailErrorCode)
  if DetailErrorCode == 83 then
    self:HandleNotEnoughMemoryToAlloc()
    local MonitorData = AkAudioMonitor.GetMonitorDataPtr()
    self:RemoveControlEvent(MonitorData, "AkAudioDetailErrorCodeDelegate")
  end
end
function SoundMonitorSubsystem:HandleNotEnoughMemoryToAlloc()
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  self.CriticalDetailStr = string.format("83:%d-%d-%d", AkAudioMonitor.GetActiveBankCount(), AkAudioMonitor.GetActiveEventCount(), AkAudioMonitor.GetActiveObjCount())
  if self.SoundNums then
    local EventList = {}
    for EventName, Count in pairs(self.SoundNums) do
      if 0 < Count then
        table.insert(EventList, {sName = EventName, nCount = Count})
      end
    end
    if 0 < #EventList then
      table.sort(EventList, function(a, b)
        return a.nCount > b.nCount
      end)
      local Top5List = {}
      for i = 1, math.min(5, #EventList) do
        table.insert(Top5List, string.format("%s:%d", EventList[i].sName, EventList[i].nCount))
      end
      self.CriticalDetailStr = self.CriticalDetailStr .. "\n" .. table.concat(Top5List, "+")
    end
  end
  print(bWriteLog and string.format("SoundMonitorSubsystem:HandleNotEnoughMemoryToAlloc %s", self.CriticalDetailStr))
  GameReportUtils.BugglyPostExceptionFull("AudioNotEnoughMemoryToAlloc", self.CriticalDetailStr, true)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, SoundMonitorSubsystem)