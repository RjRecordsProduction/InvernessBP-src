local AIConfig = {
  EAITrainDifficultyLevel = {
    Low = 1,
    Mid = 2,
    High = 3,
    MaxLevel = 4
  },
  EAITrainStatus = {
    Ready = 1,
    Training = 2,
    Finished = 3
  },
  EFinishType = {
    Success = 1,
    TimeOut = 2,
    Exit = 3,
    Failed = 4
  },
  EEventType = {
    Start = 1,
    SkipPrepare = 2,
    Exit = 3,
    FinishCountDownAck = 4
  },
  MaxWaveCount = 30,
  BuiltinMaxFakePlayerNum = 5,
  BuiltinCreatePawnInterval = 0.2,
  WavePointCount = 4,
  GetActorsDistance = 100000,
  ResetPointID = 1000,
  DropItemTypes = {
    5,
    6,
    12
  },
  DropWeaponItemTypes = {
    1,
    2,
    3
  },
  FailedSkill = 1013002,
  DistanceSquaredThreshold = 40000
}
function AIConfig.RandomSelectByWeight(StrWeightGroup)
  local TotalWeight = 0
  local SplitElements = SplitStr(StrWeightGroup, ";")
  local WeightList = {}
  local ValueList = {}
  for Index = 1, #SplitElements, 2 do
    local Value = SplitElements[Index]
    local Weight = tonumber(SplitElements[Index + 1])
    if Weight == nil or Weight <= 0 then
      sandbox.LogError(string.format("RandomSelectByWeight, Str:%s, \231\172\172%d\228\184\170\230\157\131\233\135\141\233\157\158\230\179\149:%s", tostring(StrWeightGroup), Index, tostring(Weight)))
      return false, nil
    end
    table.insert(ValueList, Value)
    table.insert(WeightList, Weight)
    TotalWeight = TotalWeight + Weight
  end
  if _G.next(ValueList) then
    return true, ValueList[Game:RandomByWeight(WeightList, 1)[1]]
  else
    return false, nil
  end
end
function AIConfig.GenerateAITrainingWaves(level)
  local WaveInfoTable = {}
  for WaveIndex = 1, AIConfig.MaxWaveCount do
    local WaveId = tostring(level) .. "-" .. tostring(WaveIndex)
    local WaveData = CDataTable.GetTableData("TrainingAIWaveTable", WaveId)
    if WaveData == nil then
      break
    end
    local WaveElement = {
      TotalDuration = WaveData.TotalDuration,
      PrepareDuration = WaveData.PrepareDuration,
      GenerateInfo = {},
      InitItemList = {},
      RefreshPickUpList = {}
    }
    if WaveIndex == 1 and WaveData.InitItemList ~= nil and WaveData.InitItemList ~= "" then
      local SplitItemList = SplitStr(WaveData.InitItemList, ";")
      for ItemIndex = 1, #SplitItemList, 2 do
        local ItemId = tonumber(SplitItemList[ItemIndex])
        local ItemCount = tonumber(SplitItemList[ItemIndex + 1])
        table.insert(WaveElement.InitItemList, {ItemId = ItemId, ItemCount = ItemCount})
      end
    end
    if WaveData.RefreshPickUpList ~= nil and WaveData.RefreshPickUpList ~= "" then
      local SplitPickUpList = SplitStr(WaveData.RefreshPickUpList, ";")
      for PickUpIndex = 1, #SplitPickUpList, 5 do
        local ItemId = tonumber(SplitPickUpList[PickUpIndex])
        local ItemCount = tonumber(SplitPickUpList[PickUpIndex + 1])
        local StartTime = tonumber(SplitPickUpList[PickUpIndex + 2])
        local CountDown = tonumber(SplitPickUpList[PickUpIndex + 3])
        local Point = tonumber(SplitPickUpList[PickUpIndex + 4])
        table.insert(WaveElement.RefreshPickUpList, {
          ItemId = ItemId,
          ItemCount = ItemCount,
          StartTime = StartTime,
          CountDown = CountDown,
                  })
      end
    end
    local TotalAINum = 0
    for PointIndex = 1, AIConfig.WavePointCount do
      local BornPointsStr = WaveData[string.format("BornPoints%02d", PointIndex)]
      if BornPointsStr == nil or BornPointsStr == "" then
        if PointIndex == 1 then
          sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \232\135\179\229\176\145\233\156\128\232\166\129\228\184\128\230\179\162\233\133\141\231\189\174\230\149\176\230\141\174, \230\179\162\230\172\161:[%s]", WaveId))
        end
        break
      end
      local Success, Value = AIConfig.RandomSelectByWeight(BornPointsStr)
      if not Success then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185\228\189\141\231\189\174\231\187\132%d\231\188\150\229\143\183\229\143\138\230\157\131\233\135\141 \233\133\141\231\189\174\233\148\153\232\175\175, \230\179\162\230\172\161:[%s]", PointIndex, WaveId))
        break
      end
      local BornPoint = tonumber(Value)
      if BornPoint == nil then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185ID:[%s]\233\148\153\232\175\175, \230\179\162\230\172\161:[%s]", tostring(Value), WaveId))
        break
      end
      local PointAIInfo = WaveData[string.format("PointAIInfo%02d", PointIndex)]
      if PointAIInfo == nil or PointAIInfo == "" then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185:[%d]\231\188\186\229\176\145AI\230\149\176\230\141\174, \230\179\162\230\172\161:[%s]", PointIndex, WaveId))
        break
      end
      local BornNum = WaveData[string.format("BornNum%02d", PointIndex)]
      if BornNum == nil or BornNum <= 0 then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185:[%d]\228\186\167\231\148\159\230\149\176\231\155\174\232\135\179\229\176\145\228\184\1861, \230\179\162\230\172\161:[%s]", PointIndex, WaveId))
        break
      end
      TotalAINum = BornNum + TotalAINum
      Success, Value = AIConfig.RandomSelectByWeight(PointAIInfo)
      if not Success then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185[%d]AI\231\188\150\229\143\183\229\143\138\230\157\131\233\135\141 \233\133\141\231\189\174\233\148\153\232\175\175, \230\179\162\230\172\161:[%s]", PointIndex, WaveId))
        break
      end
      local SelectedAI = tonumber(Value)
      if SelectedAI == nil then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, AI ID:[%s]\233\148\153\232\175\175, \230\179\162\230\172\161:[%s]", tostring(Value), WaveId))
        break
      end
      local AIData = CDataTable.GetTableData("TrainingAISettingTable", SelectedAI)
      if AIData == nil then
        sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185:[%d] AI:[%d]\228\184\141\229\173\152\229\156\168, \230\179\162\230\172\161:[%s]", PointIndex, SelectedAI, WaveId))
        break
      end
      local ItemList = {}
      if AIData.ItemList then
        local ItemStrList = SplitStr(AIData.ItemList, ";")
        for ItemIndex = 1, #ItemStrList, 2 do
          local ItemId = tonumber(ItemStrList[ItemIndex])
          local ItemCount = tonumber(ItemStrList[ItemIndex + 1])
          if ItemId and 0 < ItemCount then
            table.insert(ItemList, {ItemId = ItemId, ItemCount = ItemCount})
          else
            sandbox.LogError(string.format("AIConfig:GenerateAITrainingWaves, \229\135\186\231\148\159\231\130\185:[%d] AI:[%d]\233\133\141\231\189\174\231\137\169\229\147\129\229\136\151\232\161\168\233\148\153\232\175\175, \230\179\162\230\172\161:[%s]", PointIndex, SelectedAI, WaveId))
          end
        end
      end
      local InjuryFreeRateTable = {}
      if AIData.InjuryFreeRate then
        local InjuryFreeRateStrList = SplitStr(AIData.InjuryFreeRate, ";")
        for InjuryFreeIndex = 1, #InjuryFreeRateStrList, 2 do
          local BodyPart = tonumber(InjuryFreeRateStrList[InjuryFreeIndex])
          local InjuryFreeRate = tonumber(InjuryFreeRateStrList[InjuryFreeIndex + 1])
          table.insert(InjuryFreeRateTable, BodyPart)
          table.insert(InjuryFreeRateTable, InjuryFreeRate)
        end
      end
      WaveElement.GenerateInfo[PointIndex] = {
        BornNum = BornNum,
        BornPoint = BornPoint,
        FakePlayerID = AIData.FakePlayerID,
        ItemList = ItemList,
        AttributeID = AIData.AIAttributeID,
              }
    end
    WaveElement.    table.insert(WaveInfoTable, WaveIndex, WaveElement)
  end
  return WaveInfoTable
end
return AIConfig