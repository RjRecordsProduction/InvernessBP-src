local NinjaTrainingConfig = {}
function NinjaTrainingConfig.IsActivityOpen()
  return LobbySystem.IsInNarutoVersionTime()
end
function NinjaTrainingConfig.GetLevelConfig()
  local levelConfig = {}
  local configTable = CDataTable.GetTable("NinjaLevelConfig")
  if configTable then
    for _, v in pairs(configTable) do
      levelConfig[v.LevelID] = {
        level = v.LevelID,
        name = v.LevelName or "",
        desc = v.LevelDesc or "",
        icon = v.LevelIcon or "",
        chakra = v.ChakraCount or "",
        taskIds = NinjaTrainingConfig._ParseLevelTask(v.LevelTask)
      }
    end
  end
  return levelConfig
end
function NinjaTrainingConfig.GetChakraCount(level)
  local levelConfig = NinjaTrainingConfig.GetLevelConfig()
  if levelConfig[level] then
    return levelConfig[level].chakra or ""
  end
  return ""
end
function NinjaTrainingConfig._ParsePipeNumberList(raw)
  local list = {}
  if raw == nil or raw == "" then
    return list
  end
  if type(raw) == "number" then
    table.insert(list, raw)
    return list
  end
  for seg in string.gmatch(tostring(raw), "([^|]+)") do
    seg = seg:match("^%s*(.-)%s*$")
    local n = tonumber(seg)
    if n then
      table.insert(list, n)
    end
  end
  return list
end
function NinjaTrainingConfig._ParseLevelTask(raw)
  return NinjaTrainingConfig._ParsePipeNumberList(raw)
end
function NinjaTrainingConfig.BuildTaskAwardList(cfg)
  local awards = {}
  if not cfg then
    return awards
  end
  if 0 < (cfg.ItemID2 or 0) then
    table.insert(awards, {
      itemId = cfg.ItemID2,
      count = cfg.Count2 or 1
    })
  end
  local ids = NinjaTrainingConfig._ParsePipeNumberList(cfg.ExtraItemID)
  local counts = NinjaTrainingConfig._ParsePipeNumberList(cfg.ExtraItemCount)
  for i, itemId in ipairs(ids) do
    if 0 < itemId then
      table.insert(awards, {
        itemId = itemId,
        count = counts[i] or 1
      })
    end
  end
  return awards
end
function NinjaTrainingConfig.GetLevelTaskList(level)
  local levelConfig = NinjaTrainingConfig.GetLevelConfig()
  local one = levelConfig and levelConfig[level]
  return one and one.taskIds or {}
end
function NinjaTrainingConfig.GetMaxLevel()
  local levelConfig = NinjaTrainingConfig.GetLevelConfig()
  local maxLevel = 0
  for level, _ in pairs(levelConfig) do
    if level > maxLevel then
      maxLevel = level
    end
  end
  return maxLevel
end
function NinjaTrainingConfig.GetLevelName(level)
  local levelConfig = NinjaTrainingConfig.GetLevelConfig()
  if levelConfig[level] then
    return levelConfig[level].name or ""
  end
  return ""
end
function NinjaTrainingConfig.GetTaskConfig(taskId)
  if not taskId then
    return nil
  end
  local row = CDataTable.GetTableData("ThemeModTaskConfig", taskId)
  if not row then
    return nil
  end
  return {
    ID = row.ID,
    TaskName = row.TaskName,
    Progress1 = row.Progress1 or 0,
    ItemID1 = row.ItemID1 or 0,
    Count1 = row.Count1 or 0,
    Progress2 = row.Progress2 or 0,
    ItemID2 = row.ItemID2 or 0,
    Count2 = row.Count2 or 0,
    ExtraItemID = row.ExtraItemID or "",
    ExtraItemCount = row.ExtraItemCount or "",
    JumpUrl = row.JumpUrl or "",
    GetType = row.GetType or 0
  }
end
function NinjaTrainingConfig.GetTaskName(taskId)
  local cfg = NinjaTrainingConfig.GetTaskConfig(taskId)
  if cfg and cfg.TaskName then
    local taskName = cfg.TaskName
    if type(taskName) == "number" then
      return LocUtil.GetLocalizeResStr(taskName)
    end
    return taskName
  end
  return ""
end
function NinjaTrainingConfig.GetPromotionTaskConfig(level)
  if not level then
    return nil
  end
  local row = CDataTable.GetTableData("NinjaPromotionTaskConfig", level)
  if not row then
    return nil
  end
  return {
    level = row.Level,
    taskDesc = row.TaskDesc or "",
    jumpLink = row.JumpLink or ""
  }
end
return NinjaTrainingConfig