local SkillAction_ReportToTLog = {
  sObjectName = "SkillAction_ReportToTLog"
}
function SkillAction_ReportToTLog:ctor(selfType)
end
function SkillAction_ReportToTLog:LuaRealDoAction()
  print(bWriteLog and string.format("%s:LuaRealDoAction", self.sObjectName))
  local TlogTypeName = self.TlogTypeName
  local TlogID = self.TlogID
  local TlogFieldName = self.TlogFieldName
  local nValue = self.nValue
  local uOwnerPawn = self:GetOwnerPawn()
  local ENetRole = import("ENetRole")
  local bReset = false
  if self.bReset then
    bReset = true
  end
  local bAIMaster = false
  if self.bAIMaster then
    bAIMaster = true
  end
  if bAIMaster and uOwnerPawn.bIsMercenary then
    uOwnerPawn = uOwnerPawn:GetOwner()
  end
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    if TlogTypeName and TlogTypeName == "TlogActionTime" and 0 < TlogID then
      local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
      if DSCommonTLogSubsystem then
        local UGameplayStatics = import("GameplayStatics")
        local uGameMode = UGameplayStatics.GetGameMode(self)
        if slua.isValid(uGameMode) then
          local uGameModeState = uGameMode:GetCurrentState()
          local LeftTime = ""
          if uGameModeState and slua.isValid(uGameModeState) then
            LeftTime = tostring(uGameModeState:GetLeftTime())
          end
          print("SkillAction_ReportToTLog TlogActionTime:", LeftTime)
          DSCommonTLogSubsystem:AddCommonTLog(TlogID, LeftTime, bReset)
        end
      end
    elseif TlogTypeName and TlogTypeName == "TlogForRound" and 0 < TlogID then
      local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
      if DSCommonTLogSubsystem then
        print("SkillAction_ReportToTLog TlogForRound:", nValue)
        DSCommonTLogSubsystem:AddCommonTLog(TlogID, nValue, bReset)
      end
    elseif uOwnerPawn.GetPlayerStateSafety then
      local playerState = uOwnerPawn:GetPlayerStateSafety()
      if slua.isValid(playerState) then
        if 0 < TlogID then
          playerState:AddGeneralCount(TlogID, nValue, bReset)
          print(bWriteLog and "SkillAction_ReportToTLog AddGeneralCount UID", playerState.UID, "TlogID", TlogID, "Value", nValue)
        end
        if TlogFieldName and 0 < #TlogFieldName then
          local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
          ServerPlayerDataMgr.AddValueTLog(playerState.UID, TlogFieldName, nValue)
          print(bWriteLog and "SkillAction_ReportToTLog AddValueTLog UID", playerState.UID, "TlogFieldName", TlogFieldName, "Value", nValue)
        end
      end
    end
  end
  return true
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillAction_ReportToTLog = class(CObjectBase, nil, SkillAction_ReportToTLog)
return CSkillAction_ReportToTLog