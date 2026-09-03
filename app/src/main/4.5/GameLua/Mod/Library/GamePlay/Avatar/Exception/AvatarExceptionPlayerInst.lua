local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
local AvatarExceptionConfig = require("GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionConfig")
local UGameplayStatics = import("GameplayStatics")
local UAvatarAssetUtils = import("AvatarAssetUtils")
local TableUtil = require("common.table_util")
local AvatarExceptionPlayerInst = {
  bPrintAvatarExceptionLog = bWriteLog and true,
  AvatarCheckExceptionName = "AvatarExceptionReport_AllSlotCheck"
}
function AvatarExceptionPlayerInst:ctor(selfType, PlayerKey, uPlayerPawn, ExceptionName, tConfig, bInFightingState)
  self.  self.  self.  self.  self.tCheckCountTable = {}
  self.DisableAvatarMsgBox = false
  self.HasAvatarMsgBox = false
  self.bHasReport = false
  self.bActive = false
  self.CurTriggerType = 0
  self.AvatarLoadedCheckTimer = nil
  self.ClickReportCheckTimer = nil
  self.bPanwRecentlyRendered = false
  self.PlayerName = ""
  if Client and Client.IsDevelopment() then
    self.PlayerName = uPlayerPawn:GetPlayerNameSafety()
  end
  self.TickCheckCount = 0
  self.AllMeshLoadedCheckCount = 0
  self.ClickReportEventCheckCount = 0
end
function AvatarExceptionPlayerInst:IsActive()
  return self.bActive and not self.bHasReport
end
function AvatarExceptionPlayerInst:ClearAllTimer()
  if self.AvatarLoadedCheckTimer then
    self:RemoveTimer(self.AvatarLoadedCheckTimer)
    self.AvatarLoadedCheckTimer = nil
  end
  if self.ClickReportCheckTimer then
    self:RemoveTimer(self.ClickReportCheckTimer)
    self.ClickReportCheckTimer = nil
  end
end
function AvatarExceptionPlayerInst:CheckAvatarException(TriggerType)
  print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckAvatarException Name:%s Type:%d", self.PlayerName, TriggerType))
  if TriggerType == UEnums.EAvatarExceptionTriggerType.Tick then
    self.TickCheckCount = self.TickCheckCount + 1
    self:CheckAvatarExceptionOnce(TriggerType)
  elseif TriggerType == UEnums.EAvatarExceptionTriggerType.AllMeshLoadedEvent then
    local tTiggerConfig = self.tConfig.Trigger[TriggerType]
    if self.AvatarLoadedCheckTimer then
      self:RemoveTimer(self.AvatarLoadedCheckTimer)
    end
    self.AllMeshLoadedCheckCount = 0
    self.AvatarLoadedCheckTimer = self:AddTimerLoop(tTiggerConfig.Interval, function(deltaTime)
      self.AllMeshLoadedCheckCount = self.AllMeshLoadedCheckCount + 1
      self:CheckAvatarExceptionOnce(TriggerType)
    end, tTiggerConfig.LoopCount, tTiggerConfig.Interval)
  elseif TriggerType == UEnums.EAvatarExceptionTriggerType.ClickReportEvent then
    local tTiggerConfig = self.tConfig.Trigger[TriggerType]
    if self.ClickReportCheckTimer then
      self:RemoveTimer(self.ClickReportCheckTimer)
    end
    self.ClickReportEventCheckCount = 0
    self.ClickReportCheckTimer = self:AddTimerLoop(tTiggerConfig.Interval, function(deltaTime)
      self.ClickReportEventCheckCount = self.ClickReportEventCheckCount + 1
      self:CheckAvatarExceptionOnce(TriggerType, 1)
    end, tTiggerConfig.LoopCount, tTiggerConfig.Interval)
  end
end
function AvatarExceptionPlayerInst:GetCheckCount(TriggerType)
  if TriggerType == UEnums.EAvatarExceptionTriggerType.Tick then
    return self.TickCheckCount
  elseif TriggerType == UEnums.EAvatarExceptionTriggerType.AllMeshLoadedEvent then
    return self.AllMeshLoadedCheckCount
  elseif TriggerType == UEnums.EAvatarExceptionTriggerType.ClickReportEvent then
    return self.ClickReportEventCheckCount
  else
    return 0
  end
end
function AvatarExceptionPlayerInst:CheckCanBugglyPostException(TriggerType)
  if TriggerType == UEnums.EAvatarExceptionTriggerType.ClickReportEvent then
    return true
  end
  return GameReportUtils.CheckCanBugglyPostException(self.AvatarCheckExceptionName)
end
function AvatarExceptionPlayerInst:CheckAvatarExceptionOnce(TriggerType, nFixCount)
  if not self:CheckCanBugglyPostException(TriggerType) then
    return
  end
  self.Cur  local uPlayerController = GameplayData.GetPlayerController()
  local uSelfPlayerPawn = GameplayData.GetPlayerCharacter()
  local uPlayerPawn = GameplayData.GetPlayerCharacter(self.PlayerKey)
  local bCheckStateIsValid = self:CheckPlayerStateIsValid(uPlayerController, uPlayerPawn, uSelfPlayerPawn)
  if self.bPrintAvatarExceptionLog then
    if nFixCount and 0 < nFixCount then
      print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckAvatarExceptionOnce Name:%s Type:%d(%d) FixCount:%d CheckState:%s", self.PlayerName, TriggerType, self:GetCheckCount(TriggerType), nFixCount, bCheckStateIsValid and "True" or "False"))
    else
      print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckAvatarExceptionOnce Name:%s Type:%d(%d) CheckState:%s", self.PlayerName, TriggerType, self:GetCheckCount(TriggerType), bCheckStateIsValid and "True" or "False"))
    end
  end
  if not bCheckStateIsValid then
    return
  end
  local nFixCount = nFixCount and nFixCount or 99999
  local nAllCount = 0
  if self.tConfig.PawnCheck and self.tConfig.PawnCheck.CheckAction and self.tConfig.PawnCheck.CheckCount and self:CheckPawnVisible(uPlayerPawn, self.tConfig.PawnCheck.CheckAction) then
    nAllCount = nAllCount + self.tCheckCountTable[0].AllCount
    if self.tCheckCountTable[0].AllCount >= math.min(self.tConfig.PawnCheck.CheckCount, nFixCount) then
      self:ReportAvatarException(uPlayerPawn)
    end
    return
  end
  local uAvatarComponent = uPlayerPawn.CharacterAvatarComp2_BP
  if self.tConfig.SlotCheck and slua.isValid(uAvatarComponent) then
    self.bPanwRecentlyRendered, _ = uAvatarComponent:WasAvatarRecentlyRendered(-1.0, 0.2, false, true)
    for SlotID, tCheckConfig in pairs(self.tConfig.SlotCheck) do
      if self:CheckSlotMeshVisible(uPlayerPawn, uAvatarComponent, SlotID, tCheckConfig.CheckAction) then
        nAllCount = nAllCount + self.tCheckCountTable[SlotID].AllCount
        if self.tCheckCountTable[SlotID].AllCount >= math.min(tCheckConfig.CheckCount, nFixCount) then
          self:ReportAvatarException(uPlayerPawn)
          return
        end
      end
    end
  end
  if self.tConfig.AllCheckCount and nAllCount > self.tConfig.AllCheckCount then
    self:ReportAvatarException(uPlayerPawn)
  end
end
local _GetSlotString = function(SlotID, tCountTable)
  if SlotID == 0 and tCountTable and tCountTable.VisbileTimer then
    return string.format("%d-%d(%d-%d-%d-%d-%d)(%s)", SlotID, tCountTable.AllCount, tCountTable.VisibleCount, tCountTable.RecentlyRenderedCount, tCountTable.BoundSizeCount, tCountTable.ScaleCount, tCountTable.LocationCount, tCountTable.VisbileTimer)
  else
    return string.format("%d-%d(%d-%d-%d-%d-%d)", SlotID, tCountTable.AllCount, tCountTable.VisibleCount, tCountTable.RecentlyRenderedCount, tCountTable.BoundSizeCount, tCountTable.ScaleCount, tCountTable.LocationCount)
  end
end
function AvatarExceptionPlayerInst:_GetAllCountString()
  local CheckCountString = ""
  for SlotID, tCountTable in pairs(self.tCheckCountTable) do
    CheckCountString = string.format("%s, %s", _GetSlotString(SlotID, tCountTable), CheckCountString)
  end
  return CheckCountString
end
function AvatarExceptionPlayerInst:_GetSlotCountString(SlotID)
  return _GetSlotString(SlotID, self.tCheckCountTable[SlotID])
end
function AvatarExceptionPlayerInst:ReportAvatarException(uPlayerPawn)
  if not self:CheckCanBugglyPostException(self.CurTriggerType) then
    return
  end
  local CheckCountString = self:_GetAllCountString()
  local uSelfPlayerPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uSelfPlayerPawn) then
    local tReportInfo = self.tConfig.ReportInfo
    if uSelfPlayerPawn ~= uPlayerPawn then
      local Index = TableUtil.Find(tReportInfo, "SpecifiedCharacterMeshInfo")
      if Index ~= -1 then
        tReportInfo[Index] = {
          Name = "SpecifiedCharacterMeshInfo",
          Param = uPlayerPawn
        }
      end
    end
    local AvatarCheckExceptionString = string.format("AllSlotCheck:Trigger:%d LocalPlayer:%s ExceptionPlayer:%s %s Count:%s", self.CurTriggerType, uSelfPlayerPawn:GetPlayerNameSafety(), uPlayerPawn:GetPlayerNameSafety(), self.ExceptionName, CheckCountString)
    print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:ReportAvatarException Name:%s %s", self.PlayerName, AvatarCheckExceptionString))
    GameReportUtils.BugglyPostExceptionFull(self.AvatarCheckExceptionName, AvatarCheckExceptionString, Client.IsEditor() or Client.IsDevelopment(), tReportInfo)
    local GameReportConfig = require("GameLua.Mod.BaseMod.GamePlay.GameReport.Config.GameReportConfig")
    local AvatarReportConfig = GameReportConfig and GameReportConfig.BugglyConfigs and GameReportConfig.BugglyConfigs.AvatarExceptionReport_AllSlotCheck or nil
    if AvatarReportConfig and (AvatarReportConfig.Conditions.FreqType == UEnums.EBugglyReportFreqType.GameOnce or AvatarReportConfig.Conditions.FreqType == UEnums.EBugglyReportFreqType.LoadingOnce) then
      self.bHasReport = true
      local AvatarExceptionSubsystem = SubsystemMgr:Get("AvatarExceptionSubsystem")
      if AvatarExceptionSubsystem then
        AvatarExceptionSubsystem:ClearAllCheckCharacterTimer()
      end
    end
    if Client and Client.IsShipping() then
      return
    end
    if Client and (Client.IsEditor() or Client.IsDevelopment() or Client.IsTest()) then
      if self.DisableAvatarMsgBox or self.HasAvatarMsgBox then
        return
      end
      do
        local OkFunc = function()
          Client.ClipBoardCopy(AvatarCheckExceptionString)
          self.HasAvatarMsgBox = false
        end
        local CancelFunc = function()
          self.DisableAvatarMsgBox = true
          self.HasAvatarMsgBox = false
        end
        print(bWriteLog and string.format("AvatarExceptionPlayerInst:ReportAvatarException CommonMsgBoxMgr Name:%s", self.PlayerName))
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        IngameTipsTools.ShowMsgBox(2, "\229\189\147\229\137\141\229\175\185\229\177\128\229\173\152\229\156\168\232\167\146\232\137\178\230\168\161\229\158\139\230\182\136\229\164\177\233\151\174\233\162\152" .. CGame:GetCurDateTimeString(), "\232\175\183\230\143\144\229\143\150log\231\187\153\229\136\176 lepengli \229\164\132\231\144\134:\n" .. AvatarCheckExceptionString, OkFunc, CancelFunc, "\229\164\141\229\136\182\233\148\153\232\175\175", "\229\133\179\233\151\173\230\143\144\231\164\186")
        self.HasAvatarMsgBox = true
      end
    end
  end
end
local EPlayerCameraMode = import("EPlayerCameraMode")
function AvatarExceptionPlayerInst:CheckPlayerStateIsValid(uPlayerController, uPlayerPawn, uSelfPlayerPawn)
  if not slua.isValid(uPlayerPawn) or not slua.isValid(uPlayerController) then
    return false
  end
  if self.tConfig.IgnoreCheckHiddenMask then
    for _, v in ipairs(self.tConfig.IgnoreCheckHiddenMask) do
      if uPlayerPawn:IsMaskHidden(v) then
        return false
      end
    end
  end
  if uPlayerPawn:GetEnsure() then
    return false
  end
  if uPlayerPawn.bDead then
    return false
  end
  if uPlayerController.IsSpectator and uPlayerController:IsSpectator() or uPlayerController.bIsForReplay then
    return false
  end
  if uPlayerPawn == uSelfPlayerPawn and uPlayerController.CurCameraMode ~= EPlayerCameraMode.PCM_Normal then
    return false
  end
  if uPlayerPawn.CheckIsRecycled and uPlayerPawn:CheckIsRecycled() then
    return false
  end
  local uAvatarComp2 = uPlayerPawn:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) or not uAvatarComp2.IsLoadMeshProcessed then
    return false
  end
  if uPlayerPawn.HeroPropFeature and uPlayerPawn.HeroPropFeature:GetCurrentHeroID() > 0 then
    return false
  end
  local BornIslandTeamShowSubSystem = SubsystemMgr:Get("BornIslandTeamShowSubSystem")
  if BornIslandTeamShowSubSystem and BornIslandTeamShowSubSystem:IsShowing() then
    return false
  end
  if uPlayerPawn:HasState(UEnums.EPawnState.Dead) then
    return false
  end
  if uPlayerPawn:HasState(UEnums.EPawnState.InPlane) then
    return false
  end
  if uPlayerPawn.bPlayingLookBackSequence then
    return false
  end
  if uPlayerPawn ~= uSelfPlayerPawn and slua.isValid(uSelfPlayerPawn) then
    local uLocation = uPlayerPawn:K2_GetActorLocation()
    local uSelfLocation = uSelfPlayerPawn:K2_GetActorLocation()
    if math.abs(uLocation.X - uSelfLocation.X) > AvatarExceptionConfig.OtherPlayerCheckDistance or math.abs(uLocation.Y - uSelfLocation.Y) > AvatarExceptionConfig.OtherPlayerCheckDistance or math.abs(uLocation.Z - uSelfLocation.Z) > AvatarExceptionConfig.OtherPlayerCheckDistance then
      return false
    end
  end
  if slua.isValid(uSelfPlayerPawn) then
    local uPlayerState = uSelfPlayerPawn:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and uPlayerState.PhotoGrapherFeature and uPlayerState.PhotoGrapherFeature:IsPhotoGrapherOpenState() then
      return false
    end
  end
  return true
end
function AvatarExceptionPlayerInst:InitCheckCountTable(SlotID)
  if self.tCheckCountTable == nil then
    self.tCheckCountTable = {}
  end
  if self.tCheckCountTable[SlotID] == nil then
    self.tCheckCountTable[SlotID] = {}
    self.tCheckCountTable[SlotID].VisibleCount = 0
    self.tCheckCountTable[SlotID].RecentlyRenderedCount = 0
    self.tCheckCountTable[SlotID].BoundSizeCount = 0
    self.tCheckCountTable[SlotID].ScaleCount = 0
    self.tCheckCountTable[SlotID].LocationCount = 0
    self.tCheckCountTable[SlotID].AllCount = 0
  end
end
function AvatarExceptionPlayerInst:CheckSlotMeshVisible(uPlayerPawn, uAvatarComponent, SlotID, tCheckCondition)
  self:InitCheckCountTable(SlotID)
  if uPlayerPawn.CharacterHide.bCharacterHideIngame or uPlayerPawn.bHidden then
    return false
  end
  uSlotDesc = uAvatarComponent.ViewSlotDesc:Get(SlotID)
  if uSlotDesc and slua.isValid(uSlotDesc) then
    if uSlotDesc.ItemDefineID.TypeSpecificID <= 0 and 0 >= uSlotDesc.RealShowItemDefineID.TypeSpecificID then
      return false
    end
    if 0 < uSlotDesc.HideState or uSlotDesc.bForceHideState then
      return false
    end
    local uMeshComponent = uAvatarComponent:GetMeshCompBySlotID(SlotID)
    if not slua.isValid(uMeshComponent) then
      return false
    end
    local bMeshVisible = uMeshComponent:IsVisible()
    if not bMeshVisible then
      if uMeshComponent.bVisibleWithLOD ~= false then
        self.tCheckCountTable[SlotID].VisibleCount = self.tCheckCountTable[SlotID].VisibleCount + 1
        self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
        print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckSlotMeshVisible Visible Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
        return true
      end
      return false
    end
    local bRencentlyRendered = uMeshComponent:WasRecentlyRendered(0.5)
    if not bRencentlyRendered then
      if tCheckCondition.RecentlyRendered and self.bPanwRecentlyRendered then
        self.tCheckCountTable[SlotID].RecentlyRenderedCount = self.tCheckCountTable[SlotID].RecentlyRenderedCount + 1
        self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
        print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckSlotMeshVisible RecentlyRendered Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
        return true
      end
      return false
    end
    if tCheckCondition.Scale then
      local uMeshScale = uMeshComponent:K2_GetComponentScale()
      local ScaleSize = AvatarExceptionConfig.PawnCheckScaleSize
      if ScaleSize > uMeshScale.X or ScaleSize > uMeshScale.Y or ScaleSize > uMeshScale.Z then
        self.tCheckCountTable[SlotID].ScaleCount = self.tCheckCountTable[SlotID].ScaleCount + 1
        self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
        print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckSlotMeshVisible Scale Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
        return true
      end
    end
    if tCheckCondition.Location then
      local uPawnLocation = uPlayerPawn:K2_GetActorLocation()
      local uMeshLocation = uMeshComponent:K2_GetComponentLocation()
      if uMeshLocation.X > -80000 and uMeshLocation.Y > -80000 and (math.abs(uPawnLocation.X - uMeshLocation.X) > AvatarExceptionConfig.SlotCheckLocationThreshold or math.abs(uPawnLocation.Y - uMeshLocation.Y) > AvatarExceptionConfig.SlotCheckLocationThreshold or math.abs(uPawnLocation.Z - uMeshLocation.Z) > AvatarExceptionConfig.SlotCheckLocationThreshold) then
        self.tCheckCountTable[SlotID].LocationCount = self.tCheckCountTable[SlotID].LocationCount + 1
        self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
        print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckSlotMeshVisible Location Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
        return true
      end
    end
    if tCheckCondition.BoundSize then
      if SlotID == 1 then
        local uPelvisBoneScale = UAvatarAssetUtils.GetMeshBoneScale3D(uMeshComponent, "pelvis")
        if uPelvisBoneScale.X > 0.3 and uPelvisBoneScale.Y > 0.3 and uPelvisBoneScale.Z > 0.3 and uMeshComponent.bCachedLocalBoundsUpToDate and uMeshComponent.CachedLocalBounds.SphereRadius < AvatarExceptionConfig.SlotCheckMeshBoundSizeThreshold then
          self.tCheckCountTable[SlotID].BoundSizeCount = self.tCheckCountTable[SlotID].BoundSizeCount + 1
          self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
          print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckSlotMeshVisible BoundSize Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
          return true
        else
        end
      elseif uMeshComponent.bCachedLocalBoundsUpToDate and uMeshComponent.CachedLocalBounds.SphereRadius < AvatarExceptionConfig.SlotCheckMeshBoundSizeThreshold then
        self.tCheckCountTable[SlotID].BoundSizeCount = self.tCheckCountTable[SlotID].BoundSizeCount + 1
        self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
        print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckSlotMeshVisible BoundSize Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
        return true
      end
    end
  end
  return false
end
function AvatarExceptionPlayerInst:CheckPawnVisible(uPlayerPawn, tCheckCondition)
  if Client and not Client.IsDevelopment() and not self.bInFightingState then
    return
  end
  local uCharacterHide = uPlayerPawn.CharacterHide
  if uCharacterHide.bCharacterHideIngame then
    return false
  end
  local SlotID = 0
  self:InitCheckCountTable(SlotID)
  if uPlayerPawn.bHidden then
    self.tCheckCountTable[SlotID].VisibleCount = self.tCheckCountTable[SlotID].VisibleCount + 1
    self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
    if CGameState and slua.isValid(CGameState) then
      if self.tCheckCountTable[SlotID].VisbileTimer == "" or self.tCheckCountTable[SlotID].VisbileTimer == nil then
        self.tCheckCountTable[SlotID].VisbileTimer = string.format("%.1f", CGameState:GetServerWorldTimeSeconds())
      else
        self.tCheckCountTable[SlotID].VisbileTimer = string.format("%s,%.1f", self.tCheckCountTable[SlotID].VisbileTimer, CGameState:GetServerWorldTimeSeconds())
      end
    end
    print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckPawnVisible Visible Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
    return true
  end
  if tCheckCondition.Scale then
    local uActorScale = uPlayerPawn:GetActorScale3D()
    local ScaleSize = AvatarExceptionConfig.PawnCheckScaleSize
    if ScaleSize > uActorScale.X or ScaleSize > uActorScale.Y or ScaleSize > uActorScale.Z then
      self.tCheckCountTable[SlotID].ScaleCount = self.tCheckCountTable[SlotID].ScaleCount + 1
      self.tCheckCountTable[SlotID].AllCount = self.tCheckCountTable[SlotID].AllCount + 1
      print(bWriteLog and self.bPrintAvatarExceptionLog and string.format("AvatarExceptionPlayerInst:CheckPawnVisible Scale Name:%s %s", self.PlayerName, self:_GetSlotCountString(SlotID)))
      return true
    end
  end
  return false
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CAvatarExceptionPlayerInst = class(CDelegateContainer, nil, AvatarExceptionPlayerInst)
return CAvatarExceptionPlayerInst