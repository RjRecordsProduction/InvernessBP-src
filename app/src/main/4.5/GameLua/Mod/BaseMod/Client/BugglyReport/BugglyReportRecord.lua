local utility = require("common.utility")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local USkillUtils = import("SkillUtils")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local StringUtil = require("common.string_util")
local BugglyReportRecord = {bPrintLog = false}
local tSpecialTeamUIDList = {
  5172606493,
  5145139909,
  5290148913,
  51412334912,
  5274921875,
  5225834340,
  51211701386
}
local DefaultConfig = {
  ReportType = UEnums.EBugglyReportModeType.AllMode,
  ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
  ReportProbability = 1000,
  ReportHitCount = 1,
  ReportLowestDeviceLevel = 0,
  ReportInfo = {"PlayerInfo"}
}
local GHasReportMap = {}
function BugglyReportRecord:ctor(selfType, ReportName, tConfig, GameModeID, GameModeType, bBRMode, DeviceLevel, bIOS)
  self.  self.tConfig = tConfig or DefaultConfig
  self.  self.  self.  self.  self.  local ReportProbability = self.tConfig.ReportProbability
  if not ReportProbability or type(ReportProbability) ~= "number" then
    if Client and Client.IsDevelopment() then
      ReportProbability = 1
    else
      ReportProbability = 1000
    end
  end
  self.RandProbability = math.random(1, ReportProbability)
  self.ReportCount = 0
  self.bHasReport = false
end
function BugglyReportRecord:IsInSpecialUIDList(nCurUID)
  for i, v in ipairs(tSpecialTeamUIDList) do
    if nCurUID == v then
      return true
    end
  end
  return false
end
function BugglyReportRecord:CheckCanBugglyPostException()
  if not self:CheckReportDSSwitch(self.tConfig.ReportIndex) then
    print(bWriteLog and self.bPrintLog and string.format("BugglyReportRecord:CheckCanBugglyPostException not CheckReportDSSwitch Name:%s", self.ReportName))
    return false
  end
  if not self:CheckReportLowestDeviceLevel(self.tConfig.ReportLowestDeviceLevel) then
    print(bWriteLog and self.bPrintLog and string.format("BugglyReportRecord:CheckCanBugglyPostException not CheckReportLowestDeviceLevel Name:%s", self.ReportName))
    return false
  end
  if not self:CheckReportModeType(self.tConfig.ReportType, self.tConfig.ReportModeID, self.tConfig.ReportModeType) then
    print(bWriteLog and self.bPrintLog and string.format("BugglyReportRecord:CheckCanBugglyPostException not CheckReportModeType Name:%s", self.ReportName))
    return false
  end
  if not self:CheckReportProbability() then
    print(bWriteLog and self.bPrintLog and string.format("BugglyReportRecord:CheckCanBugglyPostException not CheckReportProbability Name:%s", self.ReportName))
    return false
  end
  if not self:CheckReportFrequency(self.tConfig.ReportFreqType) then
    print(bWriteLog and self.bPrintLog and string.format("BugglyReportRecord:CheckCanBugglyPostException not CheckReportFrequency Name:%s", self.ReportName))
    if self.tConfig.ReportIndex == 23 and DataMgr and DataMgr.roleData and DataMgr.roleData.uid and self:IsInSpecialUIDList(tonumber(DataMgr.roleData.uid)) then
      return true
    end
    return false
  end
  if Client.GetAndroidSOVersion() == 32 then
    log(bWriteLog and "BugglyReportRecord:CheckCanBugglyPostException return Android so version is 32")
    return false
  end
  return true
end
function BugglyReportRecord:BugglyPostExceptionFull(ReportString, bPrintLog, ReportInfo)
  if not self:CheckCanBugglyPostException() then
    return false
  end
  self.ReportCount = self.ReportCount + 1
  if not self:CheckReportHitCount(self.tConfig.ReportHitCount) then
    print(bWriteLog and self.bPrintLog and string.format("BugglyReportRecord:BugglyPostExceptionFull not CheckReportHitCount Name:%s, Count:%s", self.ReportName, self.ReportCount))
    return false
  end
  local sGameInfo = ""
  local uPlayerController = GameplayData.GetPlayerController()
  if CGameState and slua.isValid(CGameState) and slua.isValid(uPlayerController) then
    local nGameServerTime = CGameState:GetServerWorldTimeSeconds()
    local nAlivePlayerNum = CGameState.AlivePlayerNum or -1
    local nKillPlayerNum = -1
    local CurrentPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(CurrentPlayerState) then
      nKillPlayerNum = CurrentPlayerState.Kills
    end
    sGameInfo = string.format(" GameTime:%.1f AliveNum:%d KillNum:%d", nGameServerTime, nAlivePlayerNum, nKillPlayerNum)
  end
  local ResultReportString = ""
  local tReportInfo = ReportInfo or self.tConfig.ReportInfo
  if slua.isValid(uPlayerController) and tReportInfo then
    local tReportStringList = {}
    if self.bIOS then
      table.insert(tReportStringList, sGameInfo)
    end
    table.insert(tReportStringList, ReportString)
    for _, NameOrTable in pairs(tReportInfo) do
      if type(NameOrTable) == "string" then
        xpcall(self[string.format("Record%s", NameOrTable)], utility.ErrorMessageHandler, self, tReportStringList, uPlayerController)
      elseif type(NameOrTable) == "table" then
        xpcall(self[string.format("Record%s", NameOrTable.Name)], utility.ErrorMessageHandler, self, tReportStringList, uPlayerController, NameOrTable.Param)
      end
    end
    ResultReportString = table.concat(tReportStringList, "\n") .. "\n"
  end
  self.bHasReport = true
  GHasReportMap[self.ReportName] = os.time()
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  local Category = ClientToolsReport.Enum_CrashKit_Type.Enum_JS
  if self.bIOS then
    sGameInfo = ""
  end
  local ReportMsg = ""
  if CGameState and slua.isValid(CGameState) then
    if DataMgr and DataMgr.roleData then
      ReportMsg = string.format("GameID:%d GameModeID:%s UID:%s%s", CGameState.GameID, CGameState.GameModeID, tostring(DataMgr.roleData.uid), sGameInfo)
    else
      ReportMsg = string.format("GameID:%d GameModeID:%s%s", CGameState.GameID, CGameState.GameModeID, sGameInfo)
    end
  else
    ReportMsg = "GameState is nil"
  end
  if bPrintLog then
    print(bWriteLog and "BugglyReportRecord:BugglyPostExceptionFull " .. ResultReportString)
  end
  Client.CrashPostExceptionFull(NetInterface, Category, self.ReportName, ReportMsg, ResultReportString)
  return true
end
function BugglyReportRecord:CheckReportDSSwitch(ReportIndex)
  if ReportIndex and type(ReportIndex) == "number" then
    local nDisableBugglyReport = 0
    local uGameState = GameplayData.GetGameState()
    if slua.isValid(uGameState) and uGameState.GetDSSwitchValue then
      local DSSwitch_DisableBugglyReport = uGameState:GetDSSwitchValue(67)
      if DSSwitch_DisableBugglyReport and type(DSSwitch_DisableBugglyReport) == "string" then
        nDisableBugglyReport = tonumber(DSSwitch_DisableBugglyReport) or 0
      end
    end
    if 0 < 2 ^ ReportIndex & nDisableBugglyReport then
      return false
    end
  end
  return true
end
function BugglyReportRecord:CheckReportLowestDeviceLevel(LowestDeviceLevel)
  if LowestDeviceLevel and type(LowestDeviceLevel) == "number" then
    return LowestDeviceLevel <= self.DeviceLevel
  end
  return true
end
function BugglyReportRecord:CheckReportModeType(ReportType, ReportModeID, ReportModeType)
  ReportType = ReportType or UEnums.EBugglyReportModeType.AllMode
  if ReportType == UEnums.EBugglyReportModeType.None then
    return false
  elseif ReportType == UEnums.EBugglyReportModeType.AllMode then
    return true
  elseif ReportType == UEnums.EBugglyReportModeType.BRMode then
    return self.bBRMode
  elseif ReportType == UEnums.EBugglyReportModeType.TDMMode then
    return self.GameModeType == "TDM" or self.GameModeType == "BRTDM"
  elseif ReportType == UEnums.EBugglyReportModeType.TPlanMode then
    return StringUtil.StrFind(self.GameModeType, "TPlan")
  elseif ReportType == UEnums.EBugglyReportModeType.BRAndTPlanMode then
    return self.bBRMode or StringUtil.StrFind(self.GameModeType, "TPlan")
  elseif ReportType == UEnums.EBugglyReportModeType.LimitMode then
    local TableUtil = require("common.table_util")
    if ReportModeID then
      return TableUtil.IsInTable(ReportModeID, self.GameModeID)
    end
    if ReportModeType then
      return TableUtil.IsInTable(ReportModeType, self.GameModeType)
    end
  end
  return false
end
function BugglyReportRecord:CheckReportFrequency(ReportFreqType)
  ReportFreqType = ReportFreqType or UEnums.EBugglyReportFreqType.Always
  if ReportFreqType == UEnums.EBugglyReportFreqType.None then
    return false
  elseif ReportFreqType == UEnums.EBugglyReportFreqType.Always then
    return true
  elseif ReportFreqType == UEnums.EBugglyReportFreqType.GameOnce then
    return not self.bHasReport
  elseif ReportFreqType == UEnums.EBugglyReportFreqType.LoadingOnce then
    local LastReportTime = GHasReportMap[self.ReportName]
    if LastReportTime and type(LastReportTime) == "number" then
      return os.time() - LastReportTime > 86400
    else
      return true
    end
  end
  return false
end
function BugglyReportRecord:CheckReportHitCount(ReportHitCount)
  if not ReportHitCount or type(ReportHitCount) ~= "number" then
    ReportHitCount = 1
  end
  if self.ReportCount % ReportHitCount == 0 then
    return true
  end
  return false
end
function BugglyReportRecord:CheckReportProbability()
  if self.RandProbability == 1 then
    return true
  end
  return false
end
local BoolToInt = function(bBool)
  return bBool and 1 or 0
end
local GetItemDetailName = function(nItemID)
  local sDetail = ""
  local ItemTableCfg = CDataTable.GetTableData("Item", nItemID)
  if ItemTableCfg then
    local BPTableCfg = CDataTable.GetTableData("AvatarBPTable", ItemTableCfg.BPID)
    if BPTableCfg then
      local AvatarTableCfg = CDataTable.GetTableData("AvatarSlotTable", BPTableCfg.TemplateID)
      if AvatarTableCfg then
        sDetail = string.format("BPID:%d, Slot:%d-%d, %s", ItemTableCfg.BPID, AvatarTableCfg.SlotID, AvatarTableCfg.SubSlotID, ItemTableCfg.ItemName)
      else
        sDetail = string.format("BPID:%d, %s", ItemTableCfg.BPID, ItemTableCfg.ItemName)
      end
    else
      sDetail = ItemTableCfg.ItemName
    end
  end
  return sDetail
end
local GetItemName = function(nItemID)
  local sDetail = ""
  local ItemTableCfg = CDataTable.GetTableData("Item", nItemID)
  if ItemTableCfg then
    sDetail = ItemTableCfg.ItemName
  end
  return sDetail
end
local GetObjectShortPathName = function(uObject)
  local sPathName = UKismetSystemLibrary.GetPathName(uObject)
  local tParamTable = StringUtil.Split(sPathName, ".")
  return tParamTable[#tParamTable]
end
local GetMeshComponentResName = function(uObject)
  local StaticMeshComponentClass = import("StaticMeshComponent")
  local SkinnedMeshComponentClass = import("SkinnedMeshComponent")
  local ParticleSystemComponentClass = import("/Script/Engine.ParticleSystemComponent")
  if Game:IsClassOf(uObject, StaticMeshComponentClass) and slua.isValid(uObject.StaticMesh) then
    return UKismetSystemLibrary.GetObjectName(uObject.StaticMesh)
  elseif Game:IsClassOf(uObject, SkinnedMeshComponentClass) and slua.isValid(uObject.SkeletalMesh) then
    return UKismetSystemLibrary.GetObjectName(uObject.SkeletalMesh)
  elseif Game:IsClassOf(uObject, ParticleSystemComponentClass) and slua.isValid(uObject.Template) then
    return UKismetSystemLibrary.GetObjectName(uObject.Template)
  end
  return GetObjectShortPathName(uObject)
end
local GetActorTransformString = function(uObject, bWithRotation, bWithScale)
  if not slua.isValid(uObject) then
    return ""
  end
  local uObjectLocation = uObject:K2_GetActorLocation()
  local sObjectLocationString = string.format("(WL=%.1f,%.1f,%.1f)", uObjectLocation.X, uObjectLocation.Y, uObjectLocation.Z)
  local sObjectRotationString = ""
  if bWithRotation then
    local uObjectRotation = uObject:K2_GetActorRotation()
    sObjectRotationString = string.format("(WR=%.1f,%.1f,%.1f)", uObjectRotation.Pitch, uObjectRotation.Roll, uObjectRotation.Yaw) or ""
  end
  local sObjectScaleString = ""
  if bWithScale then
    local uObjectScale = uObject:GetActorScale3D()
    sObjectScaleString = string.format("(WS=%.1f,%.1f,%.1f)", uObjectScale.X, uObjectScale.Y, uObjectScale.Z)
  end
  return string.format("%s  %s  %s", sObjectLocationString, sObjectRotationString, sObjectScaleString)
end
local GetCompWorldTransformString = function(uComp, bWithRotation, bWithScale)
  if not slua.isValid(uComp) then
    return ""
  end
  local uCompLocation = uComp:K2_GetComponentLocation()
  local sCompLocationString = string.format("(WL=%.1f,%.1f,%.1f)", uCompLocation.X, uCompLocation.Y, uCompLocation.Z)
  local sCompRotationString = ""
  if bWithRotation then
    local uCompRotation = uComp:K2_GetComponentRotation()
    sCompRotationString = string.format("(WR=%.1f,%.1f,%.1f)", uCompRotation.Pitch, uCompRotation.Roll, uCompRotation.Yaw) or ""
  end
  local sCompScaleString = ""
  if bWithScale then
    local uCompScale = uComp:K2_GetComponentScale()
    sCompScaleString = string.format("(WS=%.1f,%.1f,%.1f)", uCompScale.X, uCompScale.Y, uCompScale.Z)
  end
  return string.format("%s  %s  %s", sCompLocationString, sCompRotationString, sCompScaleString)
end
local GetCompRelaiveTransformString = function(uComp, bWithRotation, bWithScale)
  if not slua.isValid(uComp) then
    return ""
  end
  local uCompRelaiveTransform = uComp:GetRelativeTransform()
  local uCompLocation = uCompRelaiveTransform:GetLocation()
  local sCompRelativeLocationString = string.format("(RL=%.1f,%.1f,%.1f)", uCompLocation.X, uCompLocation.Y, uCompLocation.Z)
  local sCompRelativeRotationString = ""
  if bWithRotation then
    local uCompRotation = uCompRelaiveTransform:Rotator()
    sCompRelativeRotationString = string.format("(RR=%.1f,%.1f,%.1f)", uCompRotation.Pitch, uCompRotation.Roll, uCompRotation.Yaw) or ""
  end
  local sCompRelativeScaleString = ""
  if bWithScale then
    local uCompScale = uCompRelaiveTransform:GetScale3D()
    sCompRelativeScaleString = string.format("(RS=%.1f,%.1f,%.1f)", uCompScale.X, uCompScale.Y, uCompScale.Z)
  end
  return string.format("%s  %s  %s", sCompRelativeLocationString, sCompRelativeRotationString, sCompRelativeScaleString)
end
local GetCompTransformString = function(uComp, bWithRelative, bWithRotation, bWithScale)
  if not slua.isValid(uComp) then
    return ""
  end
  if bWithRelative then
    return string.format("%s || %s", GetCompWorldTransformString(uComp, bWithRotation, bWithScale), GetCompRelaiveTransformString(uComp, bWithRotation, bWithScale))
  end
  return GetCompWorldTransformString(bWithRotation, bWithScale)
end
function BugglyReportRecord:RecordGameInfo(tShowInfo, uPlayerController)
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and slua.isValid(uPlayerController) then
    local nGameServerTime = uGameState:GetServerWorldTimeSeconds()
    local nAlivePlayerNum = uGameState.AlivePlayerNum or -1
    local nKillPlayerNum = -1
    local CurrentPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(CurrentPlayerState) then
      nKillPlayerNum = CurrentPlayerState.Kills
    end
    table.insert(tShowInfo, string.format("GameTime:%.1f, AliveNum:%d, KillNum:%d", nGameServerTime, nAlivePlayerNum, nKillPlayerNum))
  else
    table.insert(tShowInfo, "GameState is nil")
  end
end
function BugglyReportRecord:RecordPlayerInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  table.insert(tShowInfo, string.format("----------------- Local PlayerInfo->PlayerKey : %d, PlayerName:%s -----------------", uPlayerPawn.PlayerKey, uPlayerPawn:GetPlayerNameSafety()))
  table.insert(tShowInfo, string.format("Local PlayerInfo->ControlRotation : %s", uPlayerPawn:GetControlRotation():ToString()))
  table.insert(tShowInfo, string.format("bHidden:%s  Location : %s   Rotation : %s", uPlayerPawn.bHidden, uPlayerPawn:K2_GetActorLocation():ToString(), uPlayerPawn:K2_GetActorRotation():ToString()))
  local uMesh = uPlayerPawn.Mesh
  if slua.isValid(uMesh) then
    table.insert(tShowInfo, string.format("Mesh Location : %s   Rotation : %s", uMesh:K2_GetComponentLocation():ToString(), uMesh:K2_GetComponentRotation():ToString()))
  end
end
function BugglyReportRecord:RecordPlayerTransformInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local bWithRelative = true
  local bWithRotation = true
  local bWithScale = false
  table.insert(tShowInfo, "------------------------PlayerTransform----------------------------------")
  table.insert(tShowInfo, string.format("PlayerPawn: %s ", GetActorTransformString(uPlayerPawn, bWithRotation, bWithScale)))
  table.insert(tShowInfo, "")
  table.insert(tShowInfo, string.format("--CapsuleComponent: %s ", GetCompTransformString(uPlayerPawn.CapsuleComponent, bWithRelative, bWithRotation, bWithScale)))
  if slua.isValid(uPlayerPawn.Capsule) then
    table.insert(tShowInfo, string.format("----Capsule: %s ", GetCompTransformString(uPlayerPawn.Capsule, bWithRelative, bWithRotation, bWithScale)))
  else
    table.insert(tShowInfo, string.format("----MeshBoundCapsuleComponent: %s ", GetCompTransformString(uPlayerPawn.MeshBoundCapsuleComonent, bWithRelative, bWithRotation, bWithScale)))
  end
  table.insert(tShowInfo, string.format("------MeshContainer: %s ", GetCompTransformString(uPlayerPawn.MeshContainer, bWithRelative, bWithRotation, bWithScale)))
  table.insert(tShowInfo, string.format("--------Mesh: %s ", GetCompTransformString(uPlayerPawn.Mesh, bWithRelative, bWithRotation, bWithScale)))
  table.insert(tShowInfo, "")
  table.insert(tShowInfo, string.format("--CustomSpringArm: %s ", GetCompTransformString(uPlayerPawn.CustomSpringArm, bWithRelative, bWithRotation, bWithScale)))
  table.insert(tShowInfo, string.format("----CameraRoot: %s ", GetCompTransformString(uPlayerPawn.CameraRoot, bWithRelative, bWithRotation, bWithScale)))
  table.insert(tShowInfo, string.format("------ShareBounds: %s ", GetCompTransformString(uPlayerPawn.ShareBounds, bWithRelative, bWithRotation, bWithScale)))
  table.insert(tShowInfo, string.format("--------Camera: %s ", GetCompTransformString(uPlayerPawn.Camera, bWithRelative, bWithRotation, bWithScale)))
end
function BugglyReportRecord:RecordPlayerStateInfo(tShowInfo, uPlayerController)
  local uPlayer = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayer) then
    return
  end
  local nBreath = 0
  if slua.isValid(uPlayer.PlayerState) then
    nBreath = uPlayer.PlayerState.Breath
  end
  local uCharacterMovement = uPlayer.CharacterMovement
  local MaxWalkSpeed = slua.isValid(uCharacterMovement) and uCharacterMovement.MaxWalkSpeed or 0
  local MovementName = slua.isValid(uCharacterMovement) and uCharacterMovement:K2_GetMovementName() or "None"
  table.insert(tShowInfo, string.format("-----------------PlayerStateInfo Name: %s--------------", uPlayer:GetPlayerNameSafety()))
  table.insert(tShowInfo, string.format("Health:%.3f(%.3f) Breath:%.3f MaxWalkSpeed:%.3f RealTimeSpeed:%.3f SpeedValue:%.3f SpeedScale:%.3f SpeedRate:%.3f BattleState:%s MovementMode:%s", uPlayer.Health, uPlayer.HealthMax, nBreath, MaxWalkSpeed, UKismetMathLibrary.VSize(uPlayer:GetVelocity()), uPlayer.SpeedValue, uPlayer.SpeedScale, uPlayer.SpeedRate, uPlayer.bInBattleState, MovementName))
  local uPlane = uPlayerController.ThePlane
  if slua.isValid(uPlane) then
    table.insert(tShowInfo, string.format("PlaneLocation : %s   PlaneRotation : %s", uPlane:K2_GetActorLocation():ToString(), uPlane:K2_GetActorRotation():ToString()))
  end
  table.insert(tShowInfo, string.format("PoseStates : %d", uPlayer.PoseState))
  table.insert(tShowInfo, string.format("States : %d    %s", uPlayer.CurrentStates, USTExtraBlueprintFunctionLibrary.GetPlayerStatesString(uPlayer)))
  local USTExtraGameplayStatics = import("STExtraGameplayStatics")
  table.insert(tShowInfo, string.format("PCState : %s", USTExtraGameplayStatics.GetEnumString("EStateType", uPlayerController:GetCurrentStateType())))
end
function BugglyReportRecord:RecordWeaponInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local uWeapon = uPlayerPawn:GetCurrentWeapon()
  if slua.isValid(uWeapon) then
    USTExtraGameplayStatics = import("STExtraGameplayStatics")
    table.insert(tShowInfo, string.format("Weapon: WeaponID:[%d] , WeaponState:[%s] , GetCurReloadTime:[%s] , AimRate:[%s] ", uWeapon:GetWeaponID(), USTExtraGameplayStatics.GetEnumString("EFreshWeaponStateType", uWeapon.CurFreshWeaponState), uWeapon.GetCurReloadTime and uWeapon:GetCurReloadTime() or 0, uWeapon.ShootWeaponEntityComp and uWeapon.ShootWeaponEntityComp.WeaponAimInTime))
    table.insert(tShowInfo, string.format("Weapon Location : %s ", uWeapon:K2_GetActorLocation():ToString()))
    table.insert(tShowInfo, string.format("Weapon Rotation : %s ", uWeapon:K2_GetActorRotation():ToString()))
    if slua.isValid(uWeapon.WeaponAvatarComponent) then
      local uScopeMesh = uWeapon.WeaponAvatarComponent:GetMeshCompBySlotID(4)
      if slua.isValid(uScopeMesh) then
        table.insert(tShowInfo, string.format("Weapon Scope Location : %s ", uScopeMesh:K2_GetComponentLocation():ToString()))
        table.insert(tShowInfo, string.format("Weapon Scope Rotation : %s ", uScopeMesh:K2_GetComponentRotation():ToString()))
      end
    end
  end
end
function BugglyReportRecord:RecordSkillInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local uSkillComp = uPlayerPawn:GetSkillManager()
  if slua.isValid(uSkillComp) then
    local sCurSkill = "CurSkill : "
    local uCurSkillArray = uSkillComp:GetCurAllSkillIDs()
    for index = 1, uCurSkillArray:Num() do
      sCurSkill = string.format("%s%d , ", sCurSkill, uCurSkillArray:Get(index - 1))
    end
    table.insert(tShowInfo, sCurSkill)
    local StringArray = uSkillComp:GetSkillExecString()
    for k, v in pairs(StringArray) do
      table.insert(tShowInfo, string.format("SkillInst----%s", v))
    end
  end
end
function BugglyReportRecord:RecordBuffInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local uBuffComp = uPlayerPawn.BuffSystem
  if slua.isValid(uBuffComp) then
    local sCurBuff = "CurBuff : "
    local uAllBuffsArray = uBuffComp:GetAllBuffInfo()
    for index = 1, uAllBuffsArray:Num() do
      local uBuff = uAllBuffsArray:Get(index - 1)
      if slua.isValid(uBuff) then
        sCurBuff = string.format("%s[%d-%d-%d-%d] , ", sCurBuff, uBuff.BuffID, uBuff.InstID, uBuff.CauseSkillID, uBuff.LayerCount)
      end
    end
    table.insert(tShowInfo, sCurBuff)
  end
end
function BugglyReportRecord:RecordPlayerAttrInfo(tShowInfo, uPlayerController)
  local uCharacter = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  if slua.isValid(uCharacter.AttrModifyComp) then
    local sCurAttrStr = "Attrs:"
    sCurAttrStr = string.format("%s %u", sCurAttrStr, uCharacter.AttrModifyComp.AttrModifyStateList)
    for index = 1, uCharacter.AttrModifyComp.ConfigAttrModifyList:Num() do
      local AttrModifyItem = uCharacter.AttrModifyComp.ConfigAttrModifyList:Get(index - 1)
      if AttrModifyItem.IsEnable then
        sCurAttrStr = string.format("%s%s,", sCurAttrStr, AttrModifyItem.AttrModifyItemName)
      end
    end
    table.insert(tShowInfo, sCurAttrStr)
    local sCurModeAttrStr = "ModAttrs:"
    for i = 1, uCharacter.AttrModifyComp.ModSimulateSyncList:Num() do
      local AttrModModifyItem = uCharacter.AttrModifyComp.ModSimulateSyncList:Get(i - 1)
      sCurModeAttrStr = string.format("%s%d[%.2f],", sCurModeAttrStr, AttrModModifyItem.AttrID, AttrModModifyItem.FinalValue)
    end
    table.insert(tShowInfo, sCurModeAttrStr)
  end
end
function BugglyReportRecord:RecordDSSwitchInfo(tShowInfo, uPlayerController)
  if not slua_GameFrontendHUD then
    return
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local sDsSwitch = "DsSwitch:"
    for i = 1, uGameState.DsSwitch:Num() do
      local item = uGameState.DsSwitch:Get(i - 1)
      if item then
        sDsSwitch = string.format("%s (%d=%s)", sDsSwitch, item.KeyNum, item.SValue)
      end
    end
    table.insert(tShowInfo, sDsSwitch)
  end
end
local WasPlayerPawnAvatarRecentlyRendered = function(uPlayerPawn, Tolerance, bIngoreOpMesh)
  local bRecentlyRendered = false
  local LastRenderTime = -1000.0
  bRecentlyRendered, LastRenderTime = uPlayerPawn.CharacterAvatarComp2_BP:WasAvatarRecentlyRendered(LastRenderTime, Tolerance, false, bIngoreOpMesh)
  return bRecentlyRendered, LastRenderTime
end
local _AddCharacterMeshBaseInfo = function(tShowInfo, uPlayerPawn)
  if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.Mesh) then
    table.insert(tShowInfo, string.format("-----------------PlayerDetailAvatarInfo Name: %s--------------", uPlayerPawn:GetPlayerNameSafety()))
    local bRecentlyRendered, LastRenderTime = WasPlayerPawnAvatarRecentlyRendered(uPlayerPawn, 0.2, false)
    local bRecentlyRendered1, LastRenderTime1 = WasPlayerPawnAvatarRecentlyRendered(uPlayerPawn, 0.2, true)
    table.insert(tShowInfo, string.format(" Pawn V:%s R:%d(%.1f) %s", not uPlayerPawn.bHidden, bRecentlyRendered and 1 or 0, LastRenderTime, bRecentlyRendered1 and 1 or 0, LastRenderTime1, GetActorTransformString(uPlayerPawn, false, true)))
    table.insert(tShowInfo, string.format(" Mesh V:%s-%s %s", uPlayerPawn.Mesh.bVisible, uPlayerPawn.Mesh.bHiddenInGame, GetCompWorldTransformString(uPlayerPawn.Mesh, false, true)))
    table.insert(tShowInfo, string.format(" Mesh Relative %s", GetCompRelaiveTransformString(uPlayerPawn.Mesh, false, true)))
  end
end
local _AddCharacterAvatarInfo = function(tShowInfo, uPlayerPawn)
  if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.CharacterAvatarComp2_BP) then
    local uAvatarComponent = uPlayerPawn.CharacterAvatarComp2_BP
    local TempSlotSyncData = slua.IndexReference(uAvatarComponent.NetAvatarData, "SlotSyncData")
    table.insert(tShowInfo, string.format("-----------------CharacterAvatar.NetAvatarData(%d)------------------", uAvatarComponent.NetAvatarData.Gender))
    for Index, AvatarSynData in pairs(TempSlotSyncData) do
      local SlotID = AvatarSynData.SlotID
      if (SlotID == 1 or SlotID == 2 or SlotID == 5 or SlotID == 6 or SlotID == 7) and (AvatarSynData.ItemID > 0 or 0 < AvatarSynData.FakeItemID) then
        local sAvatarString = string.format(" Avatar Net:%d-%d(%d) %s HRF:%d-%d-%d DescDiff:%d Op:%d", AvatarSynData.SlotID, AvatarSynData.ItemID, AvatarSynData.FakeItemID, GetItemName(AvatarSynData.ItemID), AvatarSynData.HideState, AvatarSynData.ReplaceState, AvatarSynData.ForceHideState, AvatarSynData.ForceDescDiff, AvatarSynData.OperationType)
        table.insert(tShowInfo, sAvatarString)
      end
    end
    table.insert(tShowInfo, "-----------------CharacterAvatar.ViewSlotDesc------------------")
    for SlotID, uSlotDesc in pairs(uAvatarComponent.ViewSlotDesc) do
      if SlotID == 1 or SlotID == 2 or SlotID == 5 or SlotID == 6 or SlotID == 7 then
        local sAvatarString = string.format(" Avatar Desc:%d-%d(%d) %s HRF:%d-%d-%d Ext:%d Dif:%d", uSlotDesc.SlotID, uSlotDesc.ItemDefineID.TypeSpecificID, uSlotDesc.RealShowItemDefineID.TypeSpecificID, GetItemName(uSlotDesc.ItemDefineID.TypeSpecificID), uSlotDesc.HideState, uSlotDesc.ReplaceState, uSlotDesc.bForceHideState and 1 or 0, uSlotDesc.IsExist and 1 or 0, uSlotDesc.SlotDescDiff)
        if slua.isValid(uAvatarComponent:GetLoadedHandle(SlotID)) then
          sAvatarString = string.format("%s H:1", sAvatarString)
        else
          sAvatarString = string.format("%s H:0", sAvatarString)
        end
        local uMesh = uAvatarComponent:GetMeshCompBySlotID(SlotID)
        if slua.isValid(uMesh) then
          local sVisionOptimizationString = string.format("%d-%d-%d-%d", BoolToInt(uPlayerPawn:IsVisionOptimizationComponent(uMesh)), BoolToInt(uMesh.bAbsoluteLocation), BoolToInt(uMesh.bAbsoluteRotation), BoolToInt(uMesh.bAbsoluteScale))
          sAvatarString = string.format("%s LOD:%d(%d)  N:%s  R:%d(%.1f)  V:%d-%d  B:%.1f  OP:%s  %s", sAvatarString, uMesh.GetPredictedLODLevel and uMesh:GetPredictedLODLevel() or -1, uMesh.ForcedLodModel or -1, GetMeshComponentResName(uMesh), uMesh:WasRecentlyRendered(0.2) and 1 or 0, uMesh.LastRenderTime, uMesh.bVisible and 1 or 0, uMesh.bHiddenInGame and 1 or 0, uMesh.CachedLocalBounds and uMesh.CachedLocalBounds.SphereRadius or -1, sVisionOptimizationString, GetCompWorldTransformString(uMesh, false, true))
        else
          sAvatarString = string.format("%s V:null", sAvatarString)
        end
        table.insert(tShowInfo, sAvatarString)
      end
    end
  end
end
local _AddCharacterMeshInfo = function(tShowInfo, uPlayerPawn)
  if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.Mesh) then
    local ActorComponentClass = import("ActorComponent")
    local MeshComponentClass = import("/Script/Engine.PrimitiveComponent")
    table.insert(tShowInfo, "-----------------PlayerPawn.Mesh.Children------------------")
    local uPawnMesh = uPlayerPawn.Mesh
    table.insert(tShowInfo, string.format(" --- MasterMesh N:%s", GetMeshComponentResName(uPawnMesh)))
    local uChildMeshArray = uPlayerPawn.Mesh:GetChildrenComponents(false, slua.Array(UEnums.EPropertyClass.Object, ActorComponentClass))
    for _, uChildMesh in pairs(uChildMeshArray) do
      if slua.isValid(uChildMesh) and Game:IsClassOf(uChildMesh, MeshComponentClass) then
        local sChildNameStrings = ""
        local uChildMeshArray2 = uChildMesh:GetChildrenComponents(false, slua.Array(UEnums.EPropertyClass.Object, ActorComponentClass))
        for _, uChildMesh2 in pairs(uChildMeshArray2) do
          sChildNameStrings = string.format("%s(%s),%s", GetMeshComponentResName(uChildMesh2), uChildMesh2:GetAttachSocketName(), sChildNameStrings)
        end
        table.insert(tShowInfo, string.format(" --- ChildMesh N:%s(%s) {%s}", GetMeshComponentResName(uChildMesh), uChildMesh:GetAttachSocketName(), sChildNameStrings))
      end
    end
  end
end
function BugglyReportRecord:RecordCharacterMeshInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.Mesh) then
    _AddCharacterMeshBaseInfo(tShowInfo, uPlayerPawn)
    _AddCharacterAvatarInfo(tShowInfo, uPlayerPawn)
    _AddCharacterMeshInfo(tShowInfo, uPlayerPawn)
  end
end
local _AddCharacterMeshSimpleInfo = function(tShowInfo, uPlayerPawn)
  if not (slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.Mesh)) or not slua.isValid(uPlayerPawn.CharacterAvatarComp2_BP) then
    return
  end
  local uAvatarComponent = uPlayerPawn.CharacterAvatarComp2_BP
  table.insert(tShowInfo, string.format("-----------------PlayerAvatarInfo Name: %s--------------", uPlayerPawn:GetPlayerNameSafety()))
  local bRecentlyRendered, LastRenderTime = WasPlayerPawnAvatarRecentlyRendered(uPlayerPawn, 0.2, false)
  local bRecentlyRendered1, LastRenderTime1 = WasPlayerPawnAvatarRecentlyRendered(uPlayerPawn, 0.2, true)
  table.insert(tShowInfo, string.format("Pawn G:%d V:%s R:%d(%.1f) %s", uAvatarComponent.NetAvatarData.Gender, not uPlayerPawn.bHidden, bRecentlyRendered and 1 or 0, LastRenderTime, bRecentlyRendered1 and 1 or 0, LastRenderTime1, GetActorTransformString(uPlayerPawn, false, true)))
  table.insert(tShowInfo, string.format("Mesh V:%s-%s %s", uPlayerPawn.Mesh.bVisible, uPlayerPawn.Mesh.bHiddenInGame, GetCompWorldTransformString(uPlayerPawn.Mesh, false, true)))
  local TempSlotSyncData = slua.IndexReference(uAvatarComponent.NetAvatarData, "SlotSyncData")
  for Index, AvatarSynData in pairs(TempSlotSyncData) do
    local SlotID = AvatarSynData.SlotID
    if (SlotID == 1 or SlotID == 2 or SlotID == 5 or SlotID == 6 or SlotID == 7) and AvatarSynData.OperationType == 0 and (0 < AvatarSynData.ItemID or 0 < AvatarSynData.FakeItemID) then
      local sAvatarString = string.format(" Avatar NetAvatarData:%d-%d(%d) %s HRF:%d-%d-%d", AvatarSynData.SlotID, AvatarSynData.ItemID, AvatarSynData.FakeItemID, GetItemName(AvatarSynData.ItemID), AvatarSynData.HideState, AvatarSynData.ReplaceState, AvatarSynData.ForceHideState)
      uSlotDesc = uAvatarComponent.ViewSlotDesc:Get(SlotID)
      if uSlotDesc and slua.isValid(uSlotDesc) then
        sAvatarString = string.format("%s R:%d Ext:%d", sAvatarString, uSlotDesc.RealShowItemDefineID.TypeSpecificID, uSlotDesc.IsExist and 1 or 0)
      else
        sAvatarString = string.format("%s DesNull", sAvatarString)
      end
      if slua.isValid(uAvatarComponent:GetLoadedHandle(SlotID)) then
        sAvatarString = string.format("%s H:1", sAvatarString)
      else
        sAvatarString = string.format("%s H:0", sAvatarString)
      end
      local uMesh = uAvatarComponent:GetMeshCompBySlotID(SlotID)
      if slua.isValid(uMesh) then
        local sVisionOptimizationString = string.format("%d-%d-%d-%d", BoolToInt(uPlayerPawn:IsVisionOptimizationComponent(uMesh)), BoolToInt(uMesh.bAbsoluteLocation), BoolToInt(uMesh.bAbsoluteRotation), BoolToInt(uMesh.bAbsoluteScale))
        sAvatarString = string.format("%s LOD:%d(%d)    N:%s   R:%d(%.1f)  V:%d-%d  B:%.1f  OP:%s  %s", sAvatarString, uMesh.GetPredictedLODLevel and uMesh:GetPredictedLODLevel() or -1, uMesh.ForcedLodModel or -1, GetMeshComponentResName(uMesh), uMesh:WasRecentlyRendered(0.2) and 1 or 0, uMesh.LastRenderTime, uMesh.bVisible and 1 or 0, uMesh.bHiddenInGame and 1 or 0, uMesh.CachedLocalBounds and uMesh.CachedLocalBounds.SphereRadius or -1, sVisionOptimizationString, GetCompWorldTransformString(uMesh, false, true))
      else
        sAvatarString = string.format("%s V:null", sAvatarString)
      end
      table.insert(tShowInfo, sAvatarString)
    end
  end
end
local _AddCharacterStateInfo = function(tShowInfo, uPlayerPawn)
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local nBreath = 0
  if slua.isValid(uPlayerPawn.PlayerState) then
    nBreath = uPlayerPawn.PlayerState.Breath
  end
  local uCharacterMovement = uPlayerPawn.CharacterMovement
  local MaxWalkSpeed = slua.isValid(uCharacterMovement) and uCharacterMovement.MaxWalkSpeed or 0
  local MovementName = slua.isValid(uCharacterMovement) and uCharacterMovement:K2_GetMovementName() or "None"
  table.insert(tShowInfo, string.format("-----------------PlayerStateInfo Name: %s--------------", uPlayerPawn:GetPlayerNameSafety()))
  table.insert(tShowInfo, string.format("Health:%.2f(%.2f) Breath:%.1f MaxWalkSpeed:%.1f RealTimeSpeed:%.1f SpeedValue:%.1f SpeedScale:%.1f SpeedRate:%.1f BattleState:%s MovementMode:%s", uPlayerPawn.Health, uPlayerPawn.HealthMax, nBreath, MaxWalkSpeed, UKismetMathLibrary.VSize(uPlayerPawn:GetVelocity()), uPlayerPawn.SpeedValue, uPlayerPawn.SpeedScale, uPlayerPawn.SpeedRate, uPlayerPawn.bInBattleState, MovementName))
  table.insert(tShowInfo, string.format("PoseStates : %d", uPlayerPawn.PoseState))
  table.insert(tShowInfo, string.format("States : %d    %s", uPlayerPawn.CurrentStates, USTExtraBlueprintFunctionLibrary.GetPlayerStatesString(uPlayerPawn)))
end
function BugglyReportRecord:RecordSpecifiedCharacterMeshInfo(tShowInfo, uPlayerController, uSpecifiedPawn)
  if slua.isValid(uSpecifiedPawn) and slua.isValid(uSpecifiedPawn.Mesh) then
    _AddCharacterMeshSimpleInfo(tShowInfo, uSpecifiedPawn)
    _AddCharacterStateInfo(tShowInfo, uSpecifiedPawn)
  end
end
function BugglyReportRecord:RecordOtherCharacterMeshInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local sPawnPath = "STExtraBaseCharacter"
  local uOtherPawnArray = ActorTools.GetAllActors(uPlayerController, sPawnPath)
  local nMinDistance = 9000000
  local uMinDistPawn
  for _, uActor in pairs(uOtherPawnArray) do
    if uActor and slua.isValid(uActor) and uActor ~= uPlayerPawn then
      local uCurDistance = FVector.DistSquared(uPlayerPawn:K2_GetActorLocation(), uActor:K2_GetActorLocation())
      if nMinDistance >= uCurDistance then
        _AddCharacterMeshSimpleInfo(tShowInfo, uActor)
        _AddCharacterStateInfo(tShowInfo, uActor)
      end
    end
  end
end
function BugglyReportRecord:RecordAllCharacterMeshInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local sPawnPath = "STExtraBaseCharacter"
  local uOtherPawnArray = ActorTools.GetAllActors(uPlayerController, sPawnPath)
  local nMinDistance = 9000000
  local uMinDistPawn
  for _, uActor in pairs(uOtherPawnArray) do
    if uActor and slua.isValid(uActor) then
      local uCurDistance = FVector.DistSquared(uPlayerPawn:K2_GetActorLocation(), uActor:K2_GetActorLocation())
      if nMinDistance >= uCurDistance then
        _AddCharacterMeshSimpleInfo(tShowInfo, uActor)
      end
    end
  end
end
function BugglyReportRecord:RecordSkillNetInfo(tShowInfo, uPlayerController)
  local uPlayerPawn = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local uSkillComp = uPlayerPawn:GetSkillManager()
  if slua.isValid(uSkillComp) then
    if uSkillComp.NewSkillSinglePhaseData.SkillData:Num() > 0 then
      table.insert(tShowInfo, "SingleSkillPhaseData : ")
    end
    if uSkillComp.GetSkillSinglePhaseDataString then
      local StringArray = uSkillComp:GetSkillSinglePhaseDataString("SingleSkillPhaseData----", false)
      for k, v in pairs(StringArray) do
        table.insert(tShowInfo, v)
      end
    else
      local SkillDataList = uSkillComp.NewSkillSinglePhaseData.SkillData
      for _, SkillData in pairs(SkillDataList) do
        table.insert(tShowInfo, string.format("SingleSkillPhaseData----Inst=%d, SkillID=%d, Phase=%d, bStop=%s", SkillData.InstanceID, SkillData.SkillID, SkillData.CurSkillPhase, SkillData.bSkillStop))
      end
    end
    if 0 < uSkillComp.NewSkillSynData.SkillData:Num() then
      table.insert(tShowInfo, "MultiSkillSynData : ")
    end
    if uSkillComp.GetSkillSynDataString then
      local StringArray = uSkillComp:GetSkillSynDataString("MultiSkillSynData----", false)
      for k, v in pairs(StringArray) do
        table.insert(tShowInfo, v)
      end
    else
      local SkillDataList = uSkillComp.NewSkillSynData.SkillData
      for _, SkillData in pairs(SkillDataList) do
        table.insert(tShowInfo, string.format("MultiSkillSynData----Inst=%d, SkillID=%d, Phase=%d, bStop=%s", SkillData.InstanceID, SkillData.SkillID, SkillData.PhaseIndexes, SkillData.bSkillStop))
      end
    end
  end
end
local class = require("class")
local object = require("object")
local CBugglyReportRecord = class(object, nil, BugglyReportRecord)
return CBugglyReportRecord