local achievement_cfg_tool = {
  ConditionFirstSplit = {},
  ConditionSecondSplit = {},
  ConditionMap = {},
  DescMap = {}
}
local CONST_MAX_MEDAL_COUNT = 6
local StringUtil = require("common.string_util")
local IntlHelper = import("IntlHelper")
function achievement_cfg_tool.ResetCache()
  achievement_cfg_tool.ConditionFirstSplit = {}
  achievement_cfg_tool.ConditionSecondSplit = {}
  achievement_cfg_tool.ConditionMap = {}
  achievement_cfg_tool.DescMap = {}
end
function achievement_cfg_tool._GetConditionFirstSplit(condition)
  local data = achievement_cfg_tool.ConditionFirstSplit[condition]
  if not data then
    data = StringUtil.Split(condition, ";")
    if #data <= 0 then
      log(bWriteLog and "achievement_cfg_tool._GetConditionFirstSplit #data <= 0 condition = " .. condition)
      return nil
    end
    achievement_cfg_tool.ConditionFirstSplit[condition] = data
  end
  return data
end
function achievement_cfg_tool._GetConditionSecondSplit(condition)
  local data = achievement_cfg_tool.ConditionSecondSplit[condition]
  if not data then
    data = StringUtil.SplitToNum(condition, "-")
    achievement_cfg_tool.ConditionSecondSplit[condition] = data
  end
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  if logic_achievement.IsRankConditionByConditionID(data[1]) then
    return data[1], data[2], data[2]
  end
  return data[1], data[2], data[3]
end
function achievement_cfg_tool.ParserCondition(condition)
  local savaConditionData = achievement_cfg_tool.ConditionMap[condition]
  if savaConditionData and next(savaConditionData) then
    return savaConditionData
  end
  local data = achievement_cfg_tool._GetConditionFirstSplit(condition)
  if not data then
    return nil
  end
  local conditionList = {}
  for i = 1, #data do
    if data[i] and data[i] ~= "" then
      local tempConditionID, tempTotalProcess, tempParam2TypeID = achievement_cfg_tool._GetConditionSecondSplit(data[i])
      local info = {
        ConditionID = tempConditionID,
        TotalProcess = tempTotalProcess,
        Param2TypeID = tempParam2TypeID
      }
      table.insert(conditionList, info)
    end
  end
  achievement_cfg_tool.ConditionMap[condition] = conditionList
  return conditionList
end
local conditionProgress2LocID = {
  [199] = {
    [1] = 69810,
    [2] = 69809,
    [3] = 69808,
    [4] = 69807,
    [5] = 69806
  }
}
function achievement_cfg_tool.GetAchievementDesc(condition)
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  local DescList = achievement_cfg_tool.DescMap[condition]
  if DescList then
    return DescList
  end
  DescList = {}
  local data = achievement_cfg_tool._GetConditionFirstSplit(condition)
  if not data then
    return nil
  end
  local achievement_macro = require("client.slua.logic.achievement.achievement_macro")
  for i = 1, #data do
    if data[i] and data[i] ~= "" then
      local tempConditionID, tempTotalProcess, tempParam2TypeID = achievement_cfg_tool._GetConditionSecondSplit(data[i])
      local condiCfg = CDataTable.GetTableData("AchievementCondCfg", tempConditionID)
      if condiCfg == nil then
        return nil
      end
      local AchievementCondTypeCfg = achievement_cfg_helper.Load_AchievementCondTypeCfg()
      local Desc
      if tempConditionID == achievement_macro.VIRTUAL_CONDITION_ID then
        local virtualCfg = CDataTable.GetTableData("AchievementVirtualCondCfg", tempParam2TypeID)
        if StringUtil.StrFind(virtualCfg.Desc, "{0}") then
          Desc = LocUtil.LocalizeResFormatByStr(virtualCfg.Desc, tempTotalProcess)
        else
          Desc = virtualCfg.Desc
        end
      elseif condiCfg.Param2ID and condiCfg.Param2ID > 0 then
        if condiCfg.Param2ID == 3 then
          local itemCfg = CDataTable.GetTableData("Item", tempParam2TypeID)
          if itemCfg then
            local str = condiCfg.Desc
            local _tempProcess = tempTotalProcess
            if StringUtil.StrFind(condiCfg.Desc, "{0}") then
            else
              str = condiCfg.Desc .. "{0}"
              _tempProcess = ""
            end
            Desc = LocUtil.LocalizeResFormatByStr(str, _tempProcess, itemCfg.ItemName)
          end
        elseif AchievementCondTypeCfg[condiCfg.Param2ID] and AchievementCondTypeCfg[condiCfg.Param2ID][tempParam2TypeID] then
          local childDesc = AchievementCondTypeCfg[condiCfg.Param2ID][tempParam2TypeID].Desc
          local str = condiCfg.Desc
          local _tempProcess = tempTotalProcess
          if StringUtil.StrFind(condiCfg.Desc, "{0}") then
          else
            str = condiCfg.Desc .. "{0}"
            _tempProcess = ""
          end
          Desc = LocUtil.LocalizeResFormatByStr(str, _tempProcess, childDesc)
          printf("achievement_cfg_tool.GetConditionDesc 3 %s", Desc)
          if StringUtil.StrFind(childDesc, "{0}") then
            Desc = LocUtil.LocalizeResFormatByStr(Desc, tempTotalProcess)
            printf("achievement_cfg_tool.GetConditionDesc 4 %s", Desc)
          end
        elseif condiCfg.Param2ID == 48 then
          local str = condiCfg.Desc .. " "
          Desc = achievement_cfg_tool.GetSpecialFormatStr(str, tempTotalProcess, tempParam2TypeID)
        else
          Desc = achievement_cfg_tool.GetSpecialFormatStr(condiCfg.Desc, tempTotalProcess, nil)
        end
      else
        local des = ""
        local id
        if StringUtil.StrFind(condiCfg.Desc, "{1}") then
          local cfg = CDataTable.GetTableData("AchievementCondCfg", tempConditionID)
          id = cfg.Param2ID
          if AchievementCondTypeCfg[id] and AchievementCondTypeCfg[id][tempParam2TypeID] then
            des = AchievementCondTypeCfg[id][tempParam2TypeID].Desc
          end
        end
        if id == 0 then
          local tb = CDataTable.GetTableByFilter("AchievementParamCfg", "EventID", tempConditionID)
          for _, cfg in pairs(tb) do
            local str = ""
            local _tempProcess = tempTotalProcess
            if StringUtil.StrFind(condiCfg.Desc, "{0}") then
            else
              str = condiCfg.Desc .. "{0}"
              _tempProcess = ""
            end
            Desc = LocUtil.LocalizeResFormatByStr(str, _tempProcess, cfg.Param)
            break
          end
        elseif conditionProgress2LocID[tempConditionID] and conditionProgress2LocID[tempConditionID][tempTotalProcess] then
          Desc = LocUtil.LocalizeResFormatByStr(condiCfg.Desc, LocUtil.GetLocalizeResStr(conditionProgress2LocID[tempConditionID][tempTotalProcess]))
        else
          Desc = achievement_cfg_tool.GetSpecialFormatStr(condiCfg.Desc, tempTotalProcess, des)
        end
      end
      table.insert(DescList, Desc)
    end
  end
  achievement_cfg_tool.DescMap[condition] = DescList
  return DescList
end
function achievement_cfg_tool.GetVirtualProcess(virtualCondID, totalProcess)
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local virtualCfg = CDataTable.GetTableData("AchievementVirtualCondCfg", virtualCondID)
  if not virtualCfg then
    log_warning(bWriteLog and "achievement_cfg_tool.GetVirtualProcess not virtualCfg, virtualCondID = " .. tostring(virtualCondID))
    return {
      [1] = 0
    }
  end
  local AssociatedConds = achievement_cfg_tool._GetConditionFirstSplit(virtualCfg.AssociatedConds)
  if not AssociatedConds then
    log_warning(bWriteLog and "achievement_cfg_tool.GetVirtualProcess not AssociatedConds, virtualCondID = " .. tostring(virtualCondID))
    return {
      [1] = 0
    }
  end
  local process = 0
  local finishTime = -1
  for _, v in pairs(AssociatedConds) do
    local info = StringUtil.SplitToNum(v, "-")
    local ProcessInfo = AchieveHandler.GetConditionProcess(info[1], info[2])
    local curProcess = ProcessInfo and ProcessInfo[1] or 0
    local curFinishTime = ProcessInfo and ProcessInfo[2] or -1
    process = process + curProcess
    if finishTime < curFinishTime then
      finishTime = curFinishTime
    end
  end
  return {process, finishTime}
end
function achievement_cfg_tool.GetAchievementProcessInfo(condition, bGetStatus)
  local _beginTime = slua.getMicroseconds()
  local savaConditionData = achievement_cfg_tool.ParserCondition(condition)
  local canFinish = true
  local LastFinishTime = -1
  local ProcessInfoList = {}
  if not savaConditionData or not next(savaConditionData) then
    return ProcessInfoList, false, LastFinishTime
  end
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local achievement_macro = require("client.slua.logic.achievement.achievement_macro")
  for _, data in pairs(savaConditionData) do
    local ProcessInfo
    if data.ConditionID == achievement_macro.VIRTUAL_CONDITION_ID then
      ProcessInfo = achievement_cfg_tool.GetVirtualProcess(data.Param2TypeID, data.TotalProcess)
    else
      ProcessInfo = AchieveHandler.GetConditionProcess(data.ConditionID, data.Param2TypeID)
    end
    if bGetStatus then
      if not ProcessInfo then
        ProcessInfo = {
          [1] = 0
        }
        canFinish = false
      end
      if canFinish then
        if ProcessInfo[1] < data.TotalProcess then
          canFinish = false
        end
        if ProcessInfo[2] and LastFinishTime < ProcessInfo[2] then
          LastFinishTime = ProcessInfo[2]
        end
      end
    else
      ProcessInfo = ProcessInfo or {
        [1] = 0
      }
    end
    table.insert(ProcessInfoList, ProcessInfo)
  end
  if not canFinish then
    LastFinishTime = -1
  end
  log(bWriteLog and "achievement_cfg_tool.GetAchievementProcessInfo \232\128\151\230\151\182:" .. slua.getMicroseconds() - _beginTime)
  return ProcessInfoList, canFinish, LastFinishTime
end
function achievement_cfg_tool.GetAchievementProgressDesc(condition)
  local ProgressDescList = {}
  local data = achievement_cfg_tool._GetConditionFirstSplit(condition)
  if not data then
    return nil
  end
  for i = 1, #data do
    if data[i] and data[i] ~= "" then
      local tempConditionID, tempTotalProcess, tempParam2TypeID = achievement_cfg_tool._GetConditionSecondSplit(data[i])
      local condiCfg = CDataTable.GetTableData("AchievementCondCfg", tempConditionID)
      if condiCfg == nil then
        return nil
      end
      local ProgressDesc = achievement_cfg_tool._InnerGetProgressDesc(condiCfg, tempConditionID, tempParam2TypeID)
      table.insert(ProgressDescList, ProgressDesc)
    end
  end
  return ProgressDescList
end
function achievement_cfg_tool._InnerGetProgressDesc(AchievementCondCfg, ConditionID, tempParam2TypeID)
  local ProgressDesc = ""
  if AchievementCondCfg.ProgressDesc == "" then
    return ProgressDesc
  else
    local AchieveHandler = require("client.network.Protocol.AchieveHandler")
    local processInfo = AchieveHandler.GetConditionProcess(ConditionID, tempParam2TypeID)
    local curProc = 0
    if processInfo ~= nil then
      curProc = processInfo[1]
    end
    local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
    local AchievementCondTypeCfg = achievement_cfg_helper.Load_AchievementCondTypeCfg()
    if AchievementCondCfg.Param2ID and 0 < AchievementCondCfg.Param2ID then
      if AchievementCondCfg.Param2ID == 3 then
        local itemCfg = CDataTable.GetTableData("Item", tempParam2TypeID)
        if itemCfg then
          ProgressDesc = achievement_cfg_tool.GetSpecialFormatStr(AchievementCondCfg.ProgressDesc, curProc, itemCfg.ItemName)
        end
      elseif AchievementCondTypeCfg[AchievementCondCfg.Param2ID] and AchievementCondTypeCfg[AchievementCondCfg.Param2ID][tempParam2TypeID] then
        ProgressDesc = achievement_cfg_tool.GetSpecialFormatStr(AchievementCondCfg.ProgressDesc, curProc, AchievementCondTypeCfg[AchievementCondCfg.Param2ID][tempParam2TypeID].Desc)
      else
        ProgressDesc = achievement_cfg_tool.GetSpecialFormatStr(AchievementCondCfg.ProgressDesc, curProc, nil)
      end
    else
      ProgressDesc = achievement_cfg_tool.GetSpecialFormatStr(AchievementCondCfg.ProgressDesc, curProc, nil)
    end
  end
  return ProgressDesc
end
function achievement_cfg_tool.GetAchiveInfo(id)
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg == nil then
    return nil
  end
  local ProcessInfoList = achievement_cfg_tool.GetAchievementProcessInfo(cfg.Conditions)
  local ConditionList = achievement_cfg_tool.ParserCondition(cfg.Conditions)
  local DescList = achievement_cfg_tool.GetAchievementDesc(cfg.Conditions)
  if ProcessInfoList == nil then
    return nil
  end
  if #ConditionList == 1 then
    local processInfo = ProcessInfoList[1]
    local proc = 0
    if processInfo == nil then
      proc = 0
    else
      proc = processInfo[1]
    end
    if proc > ConditionList[1].TotalProcess then
      proc = ConditionList[1].TotalProcess
    end
    local info = {
      des = DescList[1],
      proc = proc,
      total = ConditionList[1].TotalProcess
    }
    if info.des == "" then
      local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
      info.des = logic_achievement:AchievementSpecialHandler(ConditionList[1].TotalProcess, id, "")
    else
      info.des = achievement_cfg_tool.GetSpecialFormatStr(info.des, proc, nil)
    end
    return info
  else
    local info = {
      des = cfg.Desc,
      proc = 0,
      total = #ConditionList
    }
    info.proc = 0
    for i = 1, #ConditionList do
      local condi = ConditionList[i]
      local processInfo = ProcessInfoList[i]
      if processInfo ~= nil and processInfo[1] >= condi.TotalProcess then
        info.proc = info.proc + 1
      end
    end
    return info
  end
end
function achievement_cfg_tool.GetSpecialFormatStr(strFormat, param1, param2)
  if strFormat == nil or strFormat == "" then
    return ""
  end
  if StringUtil.StrFind(strFormat, "{0}") == nil then
    return strFormat
  else
    strFormat = IntlHelper.GetLocalizationString(strFormat)
    local tmpParamTb = {param1, param2}
    return IntlHelper.FormatLocalizeStrByStr(strFormat, tmpParamTb)
  end
end
function achievement_cfg_tool.GetMaxMedalCount()
  return CONST_MAX_MEDAL_COUNT
end
return achievement_cfg_tool