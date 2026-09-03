local SkillAction_ReportBlackboardValueToTLog = {
  sObjectName = "SkillAction_ReportBlackboardValueToTLog"
}
function SkillAction_ReportBlackboardValueToTLog:ctor(selfType)
end
function SkillAction_ReportBlackboardValueToTLog:LuaRealDoAction()
  print(bWriteLog and string.format("%s:LuaRealDoAction", self.sObjectName))
  local TlogID = self.TlogID
  local TlogFieldName = self.TlogFieldName
  local ValueName = self.ValueName
  local uOwnerPawn = self:GetOwnerPawn()
  local ENetRole = import("ENetRole")
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    local playerState = uOwnerPawn:GetPlayerStateSafety()
    if slua.isValid(playerState) and ValueName then
      local nValue = self:GetValueAsInt(ValueName)
      if 0 < TlogID then
        playerState:AddGeneralCount(TlogID, nValue, false)
        print(bWriteLog and "SkillAction_ReportBlackboardValueToTLog AddGeneralCount UID", playerState.UID, "TlogID", TlogID, "Value", nValue)
      end
      if TlogFieldName and 0 < #TlogFieldName then
        local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
        ServerPlayerDataMgr.AddValueTLog(playerState.UID, TlogFieldName, nValue)
        print(bWriteLog and "SkillAction_ReportBlackboardValueToTLog AddValueTLog UID", playerState.UID, "TlogFieldName", TlogFieldName, "Value", nValue)
      end
    end
  end
  return true
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillAction_ReportBlackboardValueToTLog = class(CObjectBase, nil, SkillAction_ReportBlackboardValueToTLog)
return CSkillAction_ReportBlackboardValueToTLog