local ConfigUtils = {}
ConfigUtils.EOpType = {
  Add = 1,
  Remove = 2,
  ModifyAttibute = 3
}
ConfigUtils.ENetSide = {
  Client = 1,
  Server = 2,
  Both = 3
}
ConfigUtils.EFeaturePolicy = {Override = 1, Addition = 2}
ConfigUtils.EAudioType = {
  Audio_Burning = 1,
  Audio_Burning_Destroyed = 2,
  Audio_EngineBooming = 3,
  Audio_Boost = 4,
  Audio_WaterSplash = 5,
  Audio_TrackRolling = 6,
  Audio_TrackSlip = 7
}
ConfigUtils.EEffectType = {
  Effect_WaterSplash_1 = 1,
  Effect_WaterSplash_2 = 2,
  Effect_Light = 3,
  Effect_Drift = 4,
  Effect_Dust = 5,
  Effect_Exhuast = 6
}
function ConfigUtils.MergeTable(TargetTable, NewTable)
  if not TargetTable then
    return TargetTable
  end
  if not NewTable or not next(NewTable) then
    return TargetTable
  end
  for Key, Value in pairs(NewTable) do
    if Value then
      TargetTable[Key] = Value
    else
      TargetTable[Key] = nil
    end
  end
  return TargetTable
end
function ConfigUtils.GenArray(InType, InValues, InStructType, SortByKey)
  local OutArray
  if InStructType then
    OutArray = slua.Array(InType, InStructType)
  else
    OutArray = slua.Array(InType)
  end
  if InValues and next(InValues) then
    local Keys = {}
    for k in pairs(InValues) do
      table.insert(Keys, k)
    end
    if SortByKey then
      table.sort(Keys)
    end
    for _, k in pairs(Keys) do
      OutArray:Add(InValues[k])
    end
  end
  return OutArray
end
return ConfigUtils