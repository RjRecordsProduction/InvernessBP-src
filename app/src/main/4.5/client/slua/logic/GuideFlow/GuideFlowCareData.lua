local GuideFlowCareData = {}
local dataRsp = {}
local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
GuideFlowCareData.CareTypeEnums = {
  CombatNum = 1,
  MissionEntry = 2,
  MissionProgress = 3,
  MissionAwardGet = 4
}
GuideFlowCareData.DataTypeEnums = {
  [GuideFlowCareData.CareTypeEnums.CombatNum] = {
    Classical = 1,
    Entertainment = 2,
    Evolve = 3,
    TPlan = 4
  },
  [GuideFlowCareData.CareTypeEnums.MissionEntry] = {
    EveryDay = 1,
    Season = 2,
    Grow = 3,
    Achievement = 4
  },
  [GuideFlowCareData.CareTypeEnums.MissionProgress] = {
    EveryDay = 1,
    WeekActive = 2,
    RP = 3,
    SeasonChallenge = 4
  },
  [GuideFlowCareData.CareTypeEnums.MissionAwardGet] = {
    EveryDayLogIn = 1,
    EveryDay = 2,
    WeekActive = 3,
    RP = 4,
    SeasonChallenge = 5
  }
}
function GuideFlowCareData.SetFullData(fullData)
  GuideFlowLog.log(GuideFlowLog.bLog and "[GuideFlowCareData] SetFullData")
  if not fullData then
    GuideFlowLog.log(GuideFlowLog.bLog and "[GuideFlowCareData] SetFullData | fullData is nil")
    return
  end
  dataRsp = fullData
end
function GuideFlowCareData.UpdateCareTypeData(careType, careTypeData)
  GuideFlowLog.log(GuideFlowLog.bLog and "[GuideFlowCareData] UpdateCareTypeData | " .. tostring(careType))
  if not dataRsp then
    GuideFlowLog.log(GuideFlowLog.bLog and "[GuideFlowCareData] UpdateCareTypeData | careTypeData is nil")
    dataRsp = {}
  end
  dataRsp[careType] = careTypeData
end
function GuideFlowCareData.GetDataByCareType(careType)
  if not dataRsp or not dataRsp[careType] then
    GuideFlowLog.log(GuideFlowLog.bLog and "[GuideFlowCareData] GetDataByCareType | no care data")
    return
  end
  return dataRsp[careType]
end
function GuideFlowCareData.IsCareAvailable(careType, dateRangeStr, countRangeStr, modeRangeStr, countFunc)
  GuideFlowLog.log(GuideFlowLog.bLog and string.format("[GuideFlowCareData] IsCareAvailable | dateRange : %s, time : %s, countRange : %s, modeRange : %s", tostring(careType), tostring(dateRangeStr), tostring(countRangeStr), tostring(modeRangeStr)))
  local dayBegin, dayEnd = GuideFlowCareData.ParseRangeBoundary(dateRangeStr)
  GuideFlowLog.log(GuideFlowLog.bLog and string.format("[GuideFlowCareData]IsCareAvailable | dayBegin : %s, dayEnd : %s", tostring(dayBegin), tostring(dayEnd)))
  if not dayBegin or not dayEnd then
    log_error("[GuideFlowCareData] IsCareAvailable | day boundary is nil")
    return false
  end
  local minActiveCount, maxActiveCount = GuideFlowCareData.ParseRangeBoundary(countRangeStr)
  GuideFlowLog.log(GuideFlowLog.bLog and string.format("[GuideFlowCareData] IsCareAvailable | minActiveCount : %s, maxActiveCount : %s", tostring(minActiveCount), tostring(maxActiveCount)))
  if not minActiveCount or not maxActiveCount then
    log_error("[GuideFlowCareData] IsCareAvailable | active count boundary is nil")
    return false
  end
  local careTypeData = GuideFlowCareData.GetDataByCareType(careType)
  if not careTypeData then
    GuideFlowLog.log(GuideFlowLog.bLog and "[GuideFlowCareData] IsCareAvailable | no care data")
    careTypeData = {}
  end
  local activeCount = 0
  local activeModeMap = GuideFlowCareData.ParseActiveModeMap(careType, modeRangeStr)
  for dayIndex = dayBegin, dayEnd do
    if careTypeData[dayIndex] then
      activeCount = activeCount + countFunc(careTypeData[dayIndex], activeModeMap)
      GuideFlowLog.log(GuideFlowLog.bLog and string.format("[GuideFlowCareData] IsCareAvailable | after day : %s, activeCount : %s", tostring(dayIndex), tostring(activeCount)))
    end
  end
  GuideFlowLog.log(GuideFlowLog.bLog and string.format("[GuideFlowCareData] IsCareAvailable | minActiveCount : %s, activeCount : %s, maxActiveCount %s", tostring(minActiveCount), tostring(activeCount), tostring(maxActiveCount)))
  return minActiveCount <= activeCount and maxActiveCount >= activeCount
end
function GuideFlowCareData.ParseRangeBoundary(range)
  if not range then
    return
  end
  local lowerBoundary, upperBoundary = string.match(range, "(%d+)%s*|%s*(%d+)")
  return tonumber(lowerBoundary), tonumber(upperBoundary)
end
function GuideFlowCareData.ParseActiveModeMap(careType, modeRangeStr)
  local activeModeMap = {}
  for _, mode in pairs(GuideFlowCareData.DataTypeEnums[careType]) do
    if string.find(modeRangeStr or "", mode) then
      activeModeMap[mode] = true
    end
  end
  return activeModeMap
end
function GuideFlowCareData.CalcCombatCount(careTypeData, activeModeMap)
  local countAcc = 0
  for mode, count in pairs(careTypeData) do
    if activeModeMap[mode] and type(count) == "number" then
      countAcc = countAcc + count
    end
  end
  return countAcc
end
function GuideFlowCareData.CalcActionCount(careTypeData, activeModeMap)
  local isActionDone = false
  for mode, count in pairs(careTypeData) do
    if activeModeMap[mode] and count then
      isActionDone = true
    end
  end
  if isActionDone then
    return 1
  else
    return 0
  end
end
return GuideFlowCareData