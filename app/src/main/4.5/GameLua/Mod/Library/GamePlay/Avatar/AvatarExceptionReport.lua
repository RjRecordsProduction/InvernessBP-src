local AvatarExceptionReportSubsystem = {}
local EAvatarEnum = import("EAvatarEnum")
local EAvatarExceptReason = import("EAvatarExceptReason")
local GBattleAvatarLoadFailedStackString = {
  [EAvatarExceptReason.EAER_MeshLoadFailed] = {
    [EAvatarEnum.CharacterAvatar] = "BattleAvatarMeshLoadFailed_Character",
    [EAvatarEnum.WeaponAvatar] = "BattleAvatarMeshLoadFailed_Weapon",
    [EAvatarEnum.VehicleAvatar] = "BattleAvatarMeshLoadFailed_Vehicle",
    [EAvatarEnum.VehicleAdAvatar] = "BattleAvatarMeshLoadFailed_VehicleAd",
    [EAvatarEnum.PetAvatar] = "BattleAvatarMeshLoadFailed_Pet",
    [EAvatarEnum.PlaneAvatar] = "BattleAvatarMeshLoadFailed_Plane"
  },
  [EAvatarExceptReason.EAER_HandleLoadFailed] = {
    [EAvatarEnum.CharacterAvatar] = "BattleAvatarHandleLoadFailed_Character",
    [EAvatarEnum.WeaponAvatar] = "BattleAvatarHandleLoadFailed_Weapon",
    [EAvatarEnum.VehicleAvatar] = "BattleAvatarHandleLoadFailed_Vehicle",
    [EAvatarEnum.VehicleAdAvatar] = "BattleAvatarHandleLoadFailed_VehicleAd",
    [EAvatarEnum.PetAvatar] = "BattleAvatarHandleLoadFailed_Pet",
    [EAvatarEnum.PlaneAvatar] = "BattleAvatarHandleLoadFailed_Plane"
  }
}
function AvatarExceptionReportSubsystem:ctor(SelfType)
  self.AvatarExceptionDetailString = ""
  self.AvatarExceptionSummaryString = ""
  self.bHasReported = false
  self.AvatarChecked = {}
  self.bRealTimeReported = false
  self.bEnableAvatarExceptionReport = false
  self.DisableAvatarMsgBox = false
end
function AvatarExceptionReportSubsystem:OnInit()
  self.bHasReported = false
  self.bRealTimeReported = false
  if not slua.isValid(CGameState) then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local uGameInstance = UGameplayStatics.GetGameInstance(CGameState)
  if slua.isValid(uGameInstance) then
    self:AddControlEvent(uGameInstance, "OnPreBattleResult", self.OnPreBattleResult, self)
  end
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR_EXCEPTION, EVENTID_PLAYEREVENT_AVATAR_ALARM, self.OnAvatarAlarm, self)
  if Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR_EXCEPTION, EVENTID_PLAYEREVENT_AVATAR_EXCEPTION_RECORD, self.OnRecordAvatarException, self)
    if Client.IsEditor() or Client.IsDevelopment() or Client.IsTest() then
      self.bEnableAvatarExceptionReport = true
    else
      self.bEnableAvatarExceptionReport = HDmpveRemote.HDmpveRemoteConfigGetBool("LobbyAvatarExceptionReport", false)
    end
  end
end
function AvatarExceptionReportSubsystem:OnRelease()
  self.bHasReported = false
  self.bRealTimeReported = false
  self.AvatarExceptionDetail = nil
  self.AvatarExceptionSummaryString = nil
  self.AvatarExceptionSummaryCount = nil
  AvatarExceptionReportSubsystem.__super.OnRelease(self)
end
function AvatarExceptionReportSubsystem:OnPreBattleResult()
  print(bWriteLog and "AvatarExceptionReportSubsystem:OnPreBattleResult")
  if self.AvatarExceptionDetail == nil then
    self.AvatarExceptionDetail = {}
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if self.bHasReported then
    print(bWriteLog and "AvatarExceptionReportSubsystem:OnPreBattleResult, has reported")
    return
  end
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  local AvatarExceptionName = "AvatarExceptionReport"
  if not GameReportUtils.CheckCanBugglyPostException(AvatarExceptionName) then
    print(bWriteLog and "AvatarExceptionReportSubsystem:OnPreBattleResult, donot ReportAvatarException, CheckCanBugglyPostException")
    return
  end
  print(bWriteLog and "AvatarExceptionReportSubsystem:OnPreBattleResult, ReportAvatarException")
  local PlayerNumLimit = 20
  local DetailStringLimit = 100
  local SumaryStingLimit = 300
  local UAvatarExceptionReport = import("AvatarExceptionReport")
  self.AvatarExceptionDetailString = UAvatarExceptionReport.GetPlayerUID2AvatarExceptionData(CGameState, "", PlayerNumLimit, DetailStringLimit)
  self.AvatarExceptionSummaryString = UAvatarExceptionReport.GetAvatar2CountExceptionData(CGameState, "", SumaryStingLimit)
  if bWriteLog then
    print(bWriteLog and "AvatarExceptionReportSubsystem:OnPreBattleResult1 DetailString", self.AvatarExceptionDetailString)
    print(bWriteLog and "AvatarExceptionReportSubsystem:OnPreBattleResult2 SummaryString", self.AvatarExceptionSummaryString)
  end
  if self.AvatarExceptionDetailString ~= "" or self.AvatarExceptionSummaryString ~= "" then
    local AvatarExceptionString = string.format([[
%s
%s]], self.AvatarExceptionDetailString, self.AvatarExceptionSummaryString)
    GameReportUtils.BugglyPostExceptionFull(AvatarExceptionName, AvatarExceptionString, true)
    self.bHasReported = true
  end
end
function AvatarExceptionReportSubsystem:OnRecordAvatarException(_, _, ExcptionPlayer, PlayerUID, AvatarEnum, AvatarID, Reason)
  local BattleAvatarLoadFailedString = GBattleAvatarLoadFailedStackString[Reason][AvatarEnum]
  if BattleAvatarLoadFailedString == nil or BattleAvatarLoadFailedString == "" then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local SelfPlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(SelfPlayerPawn) or not slua.isValid(ExcptionPlayer) then
    return
  end
  if self.bEnableAvatarExceptionReport then
    local ItemData = CDataTable.GetTableData("Item", AvatarID)
    if ItemData and ItemData.ItemType == ENUM_ITEM_TYPE.Extra and ItemData.ItemSubType == 701 and AvatarID ~= 703001 then
      return
    end
  end
  local sReportSting = ""
  if self.bEnableAvatarExceptionReport and not self.bRealTimeReported and Client then
    local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
    local HandlePath = self:GetAvatarHandlePath(AvatarID)
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PakName = PufferManager.GetPakName(HandlePath)
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if PakName == PufferConst.LOCK_PAKNAME or PakName == PufferConst.CE_LOCK_PAKNAME then
      print(bWriteLog and "AvatarExceptionReportSubsystem:OnRecordAvatarException Skip Lock Res " .. HandlePath)
      return
    end
    local bDownloadState = AvatarUtil.DoubleCheckPakIsValid and AvatarUtil.DoubleCheckPakIsValid(AvatarID, PakName) or false
    local FilePathPak = Client.ProjectSavedDir() .. "Paks/" .. PakName
    local FileSizePak = Client.GetFileSizeOnDiskBytes(FilePathPak)
    sReportSting = string.format("Self:%s Excption:%s, UID:%s, AvatarID:%d-%d-%d, Path:%s-%s, FileSize:%s DownloadState:%s PufferInit:%s", SelfPlayerPawn:GetPlayerNameSafety(), ExcptionPlayer:GetPlayerNameSafety(), PlayerUID, AvatarEnum, AvatarID, Reason, tostring(HandlePath), tostring(PakName), tostring(FileSizePak), tostring(bDownloadState), tostring(PufferDownloader and PufferDownloader.InitSucces or "nil"))
    print(bWriteLog and "AvatarExceptionReportSubsystem:OnRecordAvatarException " .. sReportSting)
    Client.AddAttachFileString(BattleAvatarLoadFailedString, true, sReportSting)
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    local Category = ClientToolsReport.Enum_CrashKit_Type.Enum_Custom
    if Client and Client.CrashPostException and not Client.IsEditor() then
      Client.CrashPostException(NetInterface, Category, BattleAvatarLoadFailedString .. " " .. sReportSting)
    end
    self.bRealTimeReported = true
  end
  if Client and (Client.IsEditor() or Client.IsDevelopment() or Client.IsTest()) then
    if sReportSting == "" then
      local HandlePath = self:GetAvatarHandlePath(AvatarID)
      sReportSting = string.format("Self:%s Excption:%s, UID:%s, AvatarID:%d-%d-%d Path:%s", SelfPlayerPawn:GetPlayerNameSafety(), ExcptionPlayer:GetPlayerNameSafety(), PlayerUID, AvatarEnum, AvatarID, Reason, tostring(HandlePath))
    end
    self:ReportExceptionMsgBox(sReportSting)
  end
end
function AvatarExceptionReportSubsystem:GetAvatarHandlePath(ResID)
  local UBackpackUtils = import("BackpackUtils")
  local ItemDefineID = UBackpackUtils.GetItemDefineIDByItemID(ResID)
  return UBackpackUtils.GetBattleItemHandlePath(ItemDefineID, false, false)
end
function AvatarExceptionReportSubsystem:ReportExceptionMsgBox(sReportSting)
  if Client and Client.IsShipping() then
    return
  end
  if self.DisableAvatarMsgBox then
    return
  end
  local AvatarCheckExceptionString = string.format("AvatarResException: %s", sReportSting)
  local CancelFunc = function()
    self.DisableAvatarMsgBox = true
  end
  print(bWriteLog and string.format("AvatarExceptionReportSubsystem:ReportExceptionMsgBox CommonMsgBoxMgr %s", sReportSting))
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(1, "\229\189\147\229\137\141\229\175\185\229\177\128\229\173\152\229\156\168\232\167\146\232\137\178Avatar\229\138\160\232\189\189\229\188\130\229\184\184" .. CGame:GetCurDateTimeString(), "\232\175\183\230\143\144\229\143\150log\232\129\148\231\179\187 lepengli \231\161\174\232\174\164:\n" .. AvatarCheckExceptionString, CancelFunc)
  self.DisableAvatarMsgBox = true
end
function AvatarExceptionReportSubsystem:OnAvatarAlarm(_, _, tips, AvatarID, AvatarCheckResult)
  if self.DisableAvatarAlarm then
    return
  end
  if self.AvatarChecked[AvatarID] then
    return
  end
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  self.AvatarChecked[AvatarID] = true
  print(bWriteLog and "AvatarExceptionReportSubsystem:OnAvatarAlarm: ", tips)
  local OkFunc = function()
    Client.ClipBoardCopy(tips)
  end
  local CancelFunc = function()
    self.DisableAvatarAlarm = true
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AvatarExceptionReportSubsystem)