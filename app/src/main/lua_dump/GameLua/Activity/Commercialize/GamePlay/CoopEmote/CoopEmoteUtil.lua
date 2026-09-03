local CoopEmoteUtil = {}
function CoopEmoteUtil.IsCoopEmote(emoteID)
  if not emoteID then
    return false
  end
  local CoopEmoteConfig = CDataTable.GetTableData("CoopEmoteConfig", emoteID)
  return CoopEmoteConfig ~= nil
end
function CoopEmoteUtil.CanShowInLobby(emoteID)
  if not emoteID then
    return false
  end
  local CoopEmoteConfig = CDataTable.GetTableData("CoopEmoteConfig", emoteID)
  if not CoopEmoteConfig then
    return true
  end
  return CoopEmoteConfig.bCanShowInLobby
end
function CoopEmoteUtil.IsCasterEmote(emoteID)
  local config = CDataTable.GetTableDataByFilter("CoopEmoteConfig", "CasterEmotionID", emoteID)
  return config ~= nil
end
function CoopEmoteUtil.IsJoinerEmote(emoteID)
  local config = CDataTable.GetTableDataByFilter("CoopEmoteConfig", "JoinerEmotionID", emoteID)
  return config ~= nil
end
function CoopEmoteUtil.IsCoopRelateEmote(emoteID)
  return CoopEmoteUtil.IsCoopEmote(emoteID) or CoopEmoteUtil.IsCasterEmote(emoteID) or CoopEmoteUtil.IsJoinerEmote(emoteID)
end
function CoopEmoteUtil.GetEmoteByCoopPhase(preEmotionID, coopPhase)
  if not preEmotionID or preEmotionID == 0 or not coopPhase then
    return 0
  end
  if coopPhase == 1 then
    return preEmotionID
  end
  local CoopEmoteConfig = CDataTable.GetTableData("CoopEmoteConfig", preEmotionID)
  if not CoopEmoteConfig then
    return 0
  end
  if coopPhase == 2 then
    return CoopEmoteConfig.CasterEmotionID
  end
  if coopPhase == 3 then
    return CoopEmoteConfig.JoinerEmotionID
  end
  return 0
end
function CoopEmoteUtil.GetCoopEmoteTarget(preEmotionID)
  if not preEmotionID or preEmotionID == 0 then
    return FVector(200, 0, 0), FRotator(0, 0, 0)
  end
  local CoopEmoteConfig = CDataTable.GetTableData("CoopEmoteConfig", preEmotionID)
  if not CoopEmoteConfig then
    return FVector(200, 0, 0), FRotator(0, 0, 0)
  end
  local dx = CoopEmoteConfig.TargetOffsetArray_a:Num() >= 1 and CoopEmoteConfig.TargetOffsetArray_a:Get(0) or 200
  local dy = CoopEmoteConfig.TargetOffsetArray_a:Num() >= 2 and CoopEmoteConfig.TargetOffsetArray_a:Get(1) or 0
  return FVector(dx, dy, 0), FRotator(0, CoopEmoteConfig.TargetRotate, 0)
end
function CoopEmoteUtil.GetAllCoopEmote()
  local allEmote = {}
  local CoopEmoteConfigs = CDataTable.GetTable("CoopEmoteConfig")
  if CoopEmoteConfigs then
    for _, cfg in pairs(CoopEmoteConfigs) do
      table.insert(allEmote, cfg.PreEmotionID)
    end
  end
  return allEmote
end
function CoopEmoteUtil.GetAllRelateEmote(emoteID)
  local allEmote = {}
  if not emoteID then
    return allEmote
  end
  table.insert(allEmote, emoteID)
  local CoopEmoteConfig = CDataTable.GetTableData("CoopEmoteConfig", emoteID)
  if not CoopEmoteConfig then
    return allEmote
  end
  table.insert(allEmote, CoopEmoteConfig.CasterEmotionID)
  table.insert(allEmote, CoopEmoteConfig.JoinerEmotionID)
  return allEmote
end
return CoopEmoteUtil