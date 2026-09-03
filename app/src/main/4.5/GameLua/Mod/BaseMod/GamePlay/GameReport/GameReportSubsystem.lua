local GameReportSubsystem = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameReportConfig = require("GameLua.Mod.BaseMod.GamePlay.GameReport.Config.GameReportConfig")
function GameReportSubsystem:ctor(selfType)
  print(bWriteLog and "GameReportSubsystem:ctor")
  self.BugglyReportRecordMap = {}
end
function GameReportSubsystem:OnInit()
  GameReportSubsystem.__super.OnInit(self)
  print(bWriteLog and "GameReportSubsystem:OnInit")
  self:InitGameModeData()
end
function GameReportSubsystem:OnRelease()
  print(bWriteLog and "GameReportSubsystem:OnRelease")
  self.BugglyReportRecordMap = {}
  self.Reporter = nil
  GameReportSubsystem.__super.OnRelease(self)
end
function GameReportSubsystem:InitGameModeData()
  print(bWriteLog and "GameReportSubsystem:InitGameModeData")
  if not self.GameModeID then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    self.GameModeID = GameMainConfig.GetModeID()
    self.GameModeType, _ = GameMainConfig.GetModType()
    self.bBRMode = GamePlayTools.IsBRMode(self.GameModeID)
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    self.DeviceLevel = GameInstance and GameInstance:GetDeviceLevel() or 0
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    self.bIOS = Client and Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS or false
    print(bWriteLog and string.format("GameReportSubsystem:InitGameModeData - ModeID:%d, ModeType:%s, BRMode:%s, DeviceLevel:%d, IOS:%s", self.GameModeID, tostring(self.GameModeType), tostring(self.bBRMode), self.DeviceLevel, tostring(self.bIOS)))
  end
end
function GameReportSubsystem:GetBugglyReportRecord(ReportName)
  if not self.BugglyReportRecordMap then
    self.BugglyReportRecordMap = {}
  end
  if not self.BugglyReportRecordMap[ReportName] then
    self:InitGameModeData()
    local BugglyReportRecordClass = require("GameLua.Mod.BaseMod.Client.BugglyReport.BugglyReportRecord")
    local Config = GameReportConfig.GetBugglyConfig(ReportName)
    if not Config then
      return nil
    end
    local BugglyConfig = self:ConvertToBugglyParam(Config)
    self.BugglyReportRecordMap[ReportName] = BugglyReportRecordClass(ReportName, BugglyConfig, self.GameModeID, self.GameModeType, self.bBRMode, self.DeviceLevel, self.bIOS)
  end
  return self.BugglyReportRecordMap[ReportName]
end
function GameReportSubsystem:ConvertToBugglyParam(Config)
  if not Config or not Config.Conditions then
    return nil
  end
  local Param = {
    ReportIndex = Config.ReportIndex,
    ReportType = Config.Conditions.ModeType or UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = Config.Conditions.FreqType or UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = Config.Conditions.Probability,
    ReportHitCount = Config.Conditions.HitCount or 1,
    ReportLowestDeviceLevel = Config.Conditions.LowestDeviceLevel or 0,
    ReportModeID = Config.Conditions.ModeID,
    ReportModeType = Config.Conditions.ModeTypeList,
    ReportInfo = Config.ReportInfo
  }
  return Param
end
function GameReportSubsystem:CheckCanBugglyPostException(ReportName)
  if not self:IsValid() then
    return false
  end
  print(bWriteLog and "GameReportSubsystem:CheckCanBugglyPostException - ReportName:" .. tostring(ReportName))
  local BugglyReportRecord = self:GetBugglyReportRecord(ReportName)
  if BugglyReportRecord then
    return BugglyReportRecord:CheckCanBugglyPostException()
  end
  return false
end
function GameReportSubsystem:BugglyPostExceptionFull(ReportName, ReportString, bPrintLog, ReportInfo)
  if not self:IsValid() then
    return false
  end
  print(bWriteLog and "GameReportSubsystem:BugglyPostExceptionFull - ReportName:" .. tostring(ReportName))
  local BugglyReportRecord = self:GetBugglyReportRecord(ReportName)
  if BugglyReportRecord then
    return BugglyReportRecord:BugglyPostExceptionFull(ReportString, bPrintLog, ReportInfo)
  end
  return false
end
function GameReportSubsystem:GetClientReplayDataReporter()
  if self.Reporter and slua.isValid(self.Reporter) then
    return self.Reporter
  end
  local ClientReplayDataReporterCls = import("/Script/ShadowTrackerExtra.ClientReplayDataReporter")
  if not ClientReplayDataReporterCls then
    print(bWriteLog and "GameReportSubsystem:GetClientReplayDataReporter - ClientReplayDataReporter class not found")
    return nil
  end
  local ClientReplayDataReporters = CGame:GetActorsByClass(ClientReplayDataReporterCls)
  if not ClientReplayDataReporters or ClientReplayDataReporters:Num() <= 0 then
    print(bWriteLog and "GameReportSubsystem:GetClientReplayDataReporter - No ClientReplayDataReporter found in scene")
    return nil
  end
  print(bWriteLog and "GameReportSubsystem:GetClientReplayDataReporter - ClientReplayDataReporters:" .. tostring(ClientReplayDataReporters))
  for k, Reporter in pairs(ClientReplayDataReporters) do
    if Reporter and slua.isValid(Reporter) then
      print(bWriteLog and "GameReportSubsystem:GetClientReplayDataReporter 1 - Reporter:" .. tostring(Reporter))
      self.      return Reporter
    end
  end
end
function GameReportSubsystem:ReplayReportData(ID, Array)
  if not Client then
    return false
  end
  print(bWriteLog and "GameReportSubsystem:ReplayReportData - ID:" .. tostring(ID))
  if Client.IsEditor() then
    self:EditorTestReplayReportData(ID, Array)
  end
  local ClientReplayDataReporter = self:GetClientReplayDataReporter()
  if not ClientReplayDataReporter or not ClientReplayDataReporter.ReportIntArrayData then
    print(bWriteLog and "GameReportSubsystem:ReplayReportData - ClientReplayDataReporter is invalid")
    return false
  end
  local Config = GameReportConfig.GetReplayConfig(ID)
  if not Config then
    print(bWriteLog and "GameReportSubsystem:ReplayReportData - Config not found for ID:" .. tostring(ID))
    return false
  end
  local RPCType = Config.Type
  if RPCType == UEnums.EReplayReportRPCType.IntArrayReliable or RPCType == UEnums.EReplayReportRPCType.IntArrayUnReliable then
    if ClientReplayDataReporter.ReportIntArrayData then
      ClientReplayDataReporter:ReportIntArrayData(ID, Array)
      return true
    end
  elseif RPCType == UEnums.EReplayReportRPCType.UInt8ArrayReliable or RPCType == UEnums.EReplayReportRPCType.UInt8ArrayUnReliable then
    if ClientReplayDataReporter.ReportUInt8ArrayData then
      ClientReplayDataReporter:ReportUInt8ArrayData(ID, Array)
      return true
    end
  elseif RPCType == UEnums.EReplayReportRPCType.FloatArrayReliable or RPCType == UEnums.EReplayReportRPCType.FloatArrayUnReliable then
    if ClientReplayDataReporter.ReportFloatArrayData then
      ClientReplayDataReporter:ReportFloatArrayData(ID, Array)
      return true
    end
  else
    print(bWriteLog and "GameReportSubsystem:ReplayReportData - Unknown RPC type:" .. tostring(RPCType))
  end
  return false
end
function GameReportSubsystem:EditorTestReplayReportData(ID, Array)
  local utility = require("common.utility")
  xpcall(function()
    if not self.ReplayReportHandler then
      self.ReplayReportHandler = require("GameLua.Mod.BaseMod.Client.Replay.ReplayReportHandler")()
    end
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerController = GameplayData.GetPlayerController()
    if PlayerController then
      local PlayerKey = PlayerController.PlayerKey
      local Config = GameReportConfig.GetReplayConfig(ID)
      if Config and PlayerKey then
        local RPCType = Config.Type
        if RPCType == UEnums.EReplayReportRPCType.IntArrayReliable or RPCType == UEnums.EReplayReportRPCType.IntArrayUnReliable then
          local luaArray = slua.Array(UEnums.EPropertyClass.Int)
          for _, Value in ipairs(Array) do
            luaArray:Add(Value)
          end
          self.ReplayReportHandler[Config.HandleFunc](self.ReplayReportHandler, PlayerKey, luaArray)
        elseif RPCType == UEnums.EReplayReportRPCType.UInt8ArrayReliable or RPCType == UEnums.EReplayReportRPCType.UInt8ArrayUnReliable then
          local luaArray = slua.Array(UEnums.EPropertyClass.Int)
          for _, Value in ipairs(Array) do
            luaArray:Add(Value)
          end
          self.ReplayReportHandler[Config.HandleFunc](self.ReplayReportHandler, PlayerKey, luaArray)
        elseif RPCType == UEnums.EReplayReportRPCType.FloatArrayReliable or RPCType == UEnums.EReplayReportRPCType.FloatArrayUnReliable then
          local luaArray = slua.Array(UEnums.EPropertyClass.Float)
          for _, Value in ipairs(Array) do
            luaArray:Add(Value)
          end
          self.ReplayReportHandler[Config.HandleFunc](self.ReplayReportHandler, PlayerKey, luaArray)
        else
          print(bWriteLog and "GameReportSubsystem:ReplayReportData - Unknown RPC type:" .. tostring(RPCType))
        end
      end
    end
  end, utility.ErrorMessageHandler)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
local CGameReportSubsystem = class(SubsystemBase, nil, GameReportSubsystem)
return CGameReportSubsystem