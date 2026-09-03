local ArenaConfig = {
  IsInited = false,
  PrepareSlot = nil,
  PrepareWeapon = nil,
  PrepareTab = nil,
  SegmentTypeScore = nil,
  DefaultSegmentID = 101,
  ModeMenuId = 130,
  RankType = 20001,
  SeasonState = {
    End = 0,
    NotStart = 1,
    InProgress = 2
  },
  BattleType = {Squad = 723},
  ShowStartHMS = " 00:00:00",
  ShowEndHMS = " 23:59:59"
}
function ArenaConfig.InitCfgFromTable()
  if ArenaConfig.IsInited == false then
    local arena_table = CDataTable.GetTable("ArenaPrepareSlot")
    ArenaConfig.PrepareSlot = {}
    for _, v in pairs(arena_table) do
      local temp = {
        ID = v.ID,
        WeaponList = v.WeaponList,
        Plan = v.Plan,
        UnlockLv = v.UnlockLv,
        InitWeapon = v.InitWeapon
      }
      table.insert(ArenaConfig.PrepareSlot, temp)
    end
    arena_table = CDataTable.GetTable("ArenaPrepareWeapon")
    ArenaConfig.PrepareWeapon = {}
    for _, v in pairs(arena_table) do
      local temp = {
        ID = v.ID,
        UnlockLv = v.UnlockLv,
        WeaponType = v.WeaponType,
        Slot = {},
        Level = {},
        Power = v.Power,
        ShotRange = v.ShotRange
      }
      for key, u in pairs(v) do
        if string.find(key, "Slot") == 1 then
          local Slot = tonumber(string.sub(key, 5))
          table.insert(temp.Slot, {Slot = Slot, value = u})
        elseif string.find(key, "UnlockComp") == 1 and u ~= "" and u ~= "0" then
          local StringUtil = require("common.string_util")
          local unlockArr = StringUtil.Split(u, ";")
          if unlockArr and 0 < #unlockArr then
            local unlockID = tonumber(unlockArr[1])
            local level = tonumber(string.sub(key, 11))
            table.insert(temp.Level, {level = level, unlock = unlockID})
          end
        end
      end
      table.sort(temp.Level, function(a, b)
        return a.level < b.level
      end)
      table.insert(ArenaConfig.PrepareWeapon, temp)
    end
    arena_table = CDataTable.GetTable("ArenaPrepareLevel")
    for _, v in pairs(arena_table) do
      local levelList = ArenaConfig.GetLevelCfgList(v.ID)
      if levelList then
        for key, u in pairs(v) do
          if string.find(key, "levelexp") == 1 then
            local level = tonumber(string.sub(key, 9))
            for _, y in pairs(levelList) do
              if level == y.level then
                y.exp = u
                break
              end
            end
          end
        end
      end
    end
    arena_table = CDataTable.GetTable("ArenaPrepareTab")
    ArenaConfig.PrepareTab = {}
    for _, v in pairs(arena_table) do
      local temp = {
        ID = v.ID,
        WeaponType = v.WeaponType,
        Icon = v.Icon
      }
      table.insert(ArenaConfig.PrepareTab, temp)
    end
    ArenaConfig.IsInited = true
  end
end
function ArenaConfig.GetLevelCfgList(ID)
  if ArenaConfig.PrepareWeapon == nil then
    log(bWriteLog and "ArenaConfig.InitCfgFromTable PrepareWeapon = nil")
    return nil
  end
  for _, v in pairs(ArenaConfig.PrepareWeapon) do
    if v.ID == ID then
      return v.Level
    end
  end
  return nil
end
function ArenaConfig.GetLevelExp(ID, level)
  if ArenaConfig.PrepareWeapon == nil then
    log(bWriteLog and "ArenaConfig.InitCfgFromTable PrepareWeapon = nil")
    return 0
  end
  for _, v in pairs(ArenaConfig.PrepareWeapon) do
    if v.ID == ID then
      for _, u in pairs(v.Level) do
        if u.level == level then
          return u.exp
        end
      end
    end
  end
  return 0
end
function ArenaConfig.GetCurrentSegmentWithCurrentScore(score)
  log(bWriteLog and "ArenaSystem.GetCurrentSegmentFromRecordData")
  local segmentId = 0
  local minSegID = 0
  local minSegScore = math.maxinteger
  local maxSegID = 0
  local maxSegScore = 0
  local resultData
  local ArenaSegmentConfig = CDataTable.GetTable("ArenaSegmentConfig")
  for k, v in pairs(ArenaSegmentConfig) do
    local minScore = v.SegmentMinScore
    local maxScore = v.SegmentMaxScore
    if score >= v.SegmentMinScore then
      segmentId = math.max(segmentId, v.SegmentId)
    end
    if minSegScore > minScore then
      minSegID = v.SegmentId
      minSegScore = minScore
    end
    if maxSegScore < maxScore then
      maxSegID = v.SegmentId
      maxSegScore = minScore
    end
  end
  if segmentId == 0 then
    log_warning(bWriteLog and "ArenaSystem.GetCurrentSegmentFromRecordData segmentId = 0 and score = " .. score)
    log(bWriteLog and "ArenaSystem.GetCurrentSegmentFromRecordData minSegID = " .. minSegID .. " and maxSegID = " .. maxSegID)
    if score < minSegScore then
      segmentId = minSegID
    elseif score > maxSegScore then
      segmentId = maxSegID
    end
  end
  resultData = CDataTable.GetTableData("ArenaSegmentConfig", segmentId)
  return resultData
end
function ArenaConfig.GetRankChartData()
  if not ArenaConfig.SegmentTypeScore then
    local temp = {}
    local ArenaSegmentConfig = CDataTable.GetTable("ArenaSegmentConfig")
    for k, v in pairs(ArenaSegmentConfig) do
      if not temp[v.SegmentType] then
        temp[v.SegmentType] = {name = nil, score = 9999999}
      end
      local pre = temp[v.SegmentType]
      pre.name = v.SegmentTypeName
      pre.score = math.min(v.SegmentMinScore, pre.score)
    end
    ArenaConfig.SegmentTypeScore = temp
  end
  local list = {}
  for k, v in pairs(ArenaConfig.SegmentTypeScore) do
    table.insert(list, {
      typeId = k,
      value1 = v.name,
      value2 = v.score
    })
  end
  table.sort(list, function(a, b)
    return a.typeId < b.typeId
  end)
  return list
end
return ArenaConfig