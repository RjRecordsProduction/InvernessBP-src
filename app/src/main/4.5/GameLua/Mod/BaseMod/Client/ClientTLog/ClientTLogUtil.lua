local ClientTLogUtil = {}
function ClientTLogUtil.ConvertValueToString(Value, bDefaultNum)
  if Value == nil then
    return bDefaultNum and "0" or ""
  end
  if type(Value) == "table" and Value.ToString then
    return Value.ToString(Value)
  end
  return tostring(Value)
end
function ClientTLogUtil.ConvertArrayDataContentToString(tDataContent, separator)
  if tDataContent == nil then
    return ""
  end
  separator = separator or "|"
  local sResult = ""
  local nIndex = 1
  for i, v in ipairs(tDataContent) do
    if nIndex ~= 1 then
      sResult = sResult .. separator
    end
    sResult = sResult .. ClientTLogUtil.ConvertValueToString(v)
    nIndex = nIndex + 1
  end
  return sResult
end
function ClientTLogUtil.ConvertMapDataContentToString(tDataContent, tKeysOrder, bDefaultNum)
  if tDataContent == nil or tKeysOrder == nil then
    return ""
  end
  local sResult = ""
  local nIndex = 1
  for i, v in ipairs(tKeysOrder) do
    if nIndex ~= 1 then
      sResult = sResult .. "|"
    end
    sResult = sResult .. ClientTLogUtil.ConvertValueToString(tDataContent[v], bDefaultNum)
    nIndex = nIndex + 1
  end
  return sResult
end
function ClientTLogUtil.ConvertDataContentToString_Comma_Dash(Manager, sTableName)
  if sTableName == nil or type(sTableName) ~= "string" then
    error("ConvertDataContentToString_Comma_Dash Error A", sTableName)
    return nil
  end
  local tData = Manager:GetTableByName(sTableName)
  if tData == nil then
    error("ConvertDataContentToString_Comma_Dash Error B", sTableName)
    return nil
  end
  local tDataContent = tData.DataContent
  if tDataContent == nil then
    error("ConvertDataContentToString_Comma_Dash Error C", sTableName)
    return nil
  end
  local sResult = ""
  local nIndex = 1
  for k, v in pairs(tDataContent) do
    if nIndex ~= 1 then
      sResult = sResult .. ","
    end
    sResult = sResult .. k .. "-" .. ClientTLogUtil.ConvertValueToString(v)
    nIndex = nIndex + 1
  end
  return sResult
end
function ClientTLogUtil.ReportGeneralCountByParachutePhase(nReadyIslandTLogID, nOnAircraftTLogID, nParachutingTLogID)
  print(bWriteLog and string.format("ReportGeneralCountByParachutePhase - ReadyIsland:%s OnAircraft:%s Parachuting:%s", tostring(nReadyIslandTLogID), tostring(nOnAircraftTLogID), tostring(nParachutingTLogID)))
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.RPC_ServerAddGeneralCount then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.GetCurrentStateType then
    return
  end
  local EStateType = import("EStateType")
  local CurrentStateType = uPlayerController:GetCurrentStateType()
  if CurrentStateType == EStateType.State_InPlane or CurrentStateType == EStateType.State_InExPlane then
    if nOnAircraftTLogID and 0 < nOnAircraftTLogID then
      print(bWriteLog and "ReportGeneralCountByParachutePhase - Phase: OnAircraft, TLogID:" .. tostring(nOnAircraftTLogID))
      uPlayerState:RPC_ServerAddGeneralCount(nOnAircraftTLogID, 1, false)
    end
  elseif CurrentStateType == EStateType.State_ParachuteJump or CurrentStateType == EStateType.State_ParachuteOpen or CurrentStateType == EStateType.State_Launch then
    if nParachutingTLogID and 0 < nParachutingTLogID then
      print(bWriteLog and "ReportGeneralCountByParachutePhase - Phase: Parachuting, TLogID:" .. tostring(nParachutingTLogID))
      uPlayerState:RPC_ServerAddGeneralCount(nParachutingTLogID, 1, false)
    end
  elseif nReadyIslandTLogID and 0 < nReadyIslandTLogID then
    print(bWriteLog and "ReportGeneralCountByParachutePhase - Phase: ReadyIsland, TLogID:" .. tostring(nReadyIslandTLogID))
    uPlayerState:RPC_ServerAddGeneralCount(nReadyIslandTLogID, 1, false)
  end
end
function ClientTLogUtil.ReportGeneralCountByBRPhase(nBirthIslandTLogID, nFightingTLogID)
  print(bWriteLog and string.format("ReportGeneralCountByBRPhase - BirthIsland:%s Fighting:%s", tostring(nBirthIslandTLogID), tostring(nFightingTLogID)))
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.RPC_ServerAddGeneralCount then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.GetGameModeState then
    return
  end
  local GameModeState = uGameState:GetGameModeState() or ""
  if GameModeState == "ReadyState" then
    if nBirthIslandTLogID and 0 < nBirthIslandTLogID then
      print(bWriteLog and "ReportGeneralCountByBRPhase - Phase: BirthIsland, TLogID:" .. tostring(nBirthIslandTLogID))
      uPlayerState:RPC_ServerAddGeneralCount(nBirthIslandTLogID, 1, false)
    end
  elseif GameModeState == "FightingState" and nFightingTLogID and 0 < nFightingTLogID then
    print(bWriteLog and "ReportGeneralCountByBRPhase - Phase: Fighting, TLogID:" .. tostring(nFightingTLogID))
    uPlayerState:RPC_ServerAddGeneralCount(nFightingTLogID, 1, false)
  end
end
function ClientTLogUtil.ReportCommonTLogDataByBRPhase(nBirthIslandTLogID, nFightingTLogID, sInfoID, nCount)
  print(bWriteLog and string.format("ReportCommonTLogDataByBRPhase - BirthIsland:%s Fighting:%s nInfoID:%s nCount:%s", tostring(nBirthIslandTLogID), tostring(nFightingTLogID), tostring(sInfoID), tostring(nCount)))
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.ServerRPC_AddCommonTLogData then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.GetGameModeState then
    return
  end
  local GameModeState = uGameState:GetGameModeState() or ""
  local nTLogID
  if GameModeState == "ReadyState" then
    nTLogID = nBirthIslandTLogID
  elseif GameModeState == "FightingState" then
    nTLogID = nFightingTLogID
  end
  if nTLogID and 0 < nTLogID then
    print(bWriteLog and "ReportCommonTLogDataByBRPhase - Phase:" .. tostring(GameModeState) .. " TLogID:" .. tostring(nTLogID))
    uPlayerState:ServerRPC_AddCommonTLogData(nTLogID, sInfoID or 0, nCount or 1)
  end
end
return ClientTLogUtil