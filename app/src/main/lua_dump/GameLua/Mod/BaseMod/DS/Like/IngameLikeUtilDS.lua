local IngameLikeUtilDS = {}
function IngameLikeUtilDS.IsPlayerInSpectating(PlayerKey)
  local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if not Game:IsValid(PlayerController) then
    return
  end
  return PlayerController:IsInSpectating()
end
function IngameLikeUtilDS.GetPlayerIdentifier(PlayerState)
  local Identifier = PlayerState.PlayerKey
  if 0 == Identifier and 0 < PlayerState.PlayerId then
    Identifier = PlayerState.PlayerId
  end
  return Identifier
end
function IngameLikeUtilDS.IsMultiClassicMode()
  if not CGameMode or CGameMode.PlayerNumPerTeam <= 1 or tonumber(CGameMode.GameModeType) ~= 1 and tonumber(CGameMode.GameModeType) ~= 20 then
    return false
  end
  return true
end
function IngameLikeUtilDS.GetLikeTypeByConditionID(ConditionID, bTriggerLike, bLike, bTriggerResponseLike, bResponseLike)
  if ConditionID == 5 then
    return 1
  end
  if ConditionID == 6 then
    return 18
  end
  local TriggerLikeType = {
    2,
    14,
    6,
    10
  }
  local LikeType = {
    3,
    15,
    7,
    11
  }
  local TriggerResponseLikeType = {
    4,
    16,
    8,
    12
  }
  local ResponseLikeType = {
    5,
    17,
    9,
    13
  }
  if bTriggerLike then
    return TriggerLikeType[ConditionID]
  end
  if bLike then
    return LikeType[ConditionID]
  end
  if bTriggerResponseLike then
    return TriggerResponseLikeType[ConditionID]
  end
  if bResponseLike then
    return ResponseLikeType[ConditionID]
  end
end
return IngameLikeUtilDS