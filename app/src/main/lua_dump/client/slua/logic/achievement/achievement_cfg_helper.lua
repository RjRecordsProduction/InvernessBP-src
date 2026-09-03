local achievement_cfg_helper = {
  tb_AchievementCondTypeCfg = nil,
  tb_AchievementScoreCfg = nil,
  tb_AchievementSeqCfgList = nil,
  tb_idList = nil,
  tb_CondiParam2AchieveIDMap = nil,
  tb_CondID2AcheieveIDMap = nil,
  tb_MultiLvGroupID2AchiveIDMap = nil
}
function achievement_cfg_helper.Init()
  achievement_cfg_helper.tb_AchievementCondTypeCfg = nil
  achievement_cfg_helper.tb_AchievementScoreCfg = nil
  achievement_cfg_helper.tb_CondiParam2AchieveIDMap = nil
  achievement_cfg_helper.tb_MultiLvGroupID2AchiveIDMap = nil
  achievement_cfg_helper.tb_CondID2AcheieveIDMap = nil
  achievement_cfg_helper.tb_AchievementSeqCfgList = nil
end
function achievement_cfg_helper.Load_AchievementCondTypeCfg()
  if achievement_cfg_helper.tb_AchievementCondTypeCfg then
    return achievement_cfg_helper.tb_AchievementCondTypeCfg
  end
  log(bWriteLog and "achievement_cfg_helper.Load_AchievementCondTypeCfg Load")
  local tbData = {}
  local tb = CDataTable.GetTable("AchievementCondTypeCfg")
  for k, v in pairs(tb) do
    if v.Param2ID then
      if tbData[v.Param2ID] == nil then
        tbData[v.Param2ID] = {}
      end
      if tbData[v.Param2ID][v.Param2TypeID] == nil then
        tbData[v.Param2ID][v.Param2TypeID] = {}
      end
      tbData[v.Param2ID][v.Param2TypeID].Desc = v.Desc
    end
  end
  achievement_cfg_helper.tb_AchievementCondTypeCfg = tbData
  return tbData
end
local NetDataAward
function achievement_cfg_helper.Load_AchievementScoreCfg()
  log(bWriteLog and "achievement_cfg_helper.Load_AchievementScoreCfg")
  if achievement_cfg_helper.tb_AchievementScoreCfg then
    return achievement_cfg_helper.tb_AchievementScoreCfg
  end
  log(bWriteLog and "achievement_cfg_helper.Load_AchievementScoreCfg Load")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  if not NetDataAward or not next(NetDataAward) then
    log(bWriteLog and "achievement_cfg_helper.Load_AchievementScoreCfg not NetDataAward")
    BasicDataServerTable:GetOrReqData(data_config_marco.achievement_score_table, achievement_cfg_helper.OnGetAwardTable)
  end
  local tbData = {}
  if not NetDataAward then
    return
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetMainFormat(Client.GetAppVersion())
  for k, v in pairs(NetDataAward) do
    if version_util.CompareVersionStandard(ClientVersion, v.min_ver) >= 0 then
      local info = {}
      info.ID = k
      info.Score = v.score
      local reward_list = NetDataAward[k].reward_list
      info.res_id = tonumber(reward_list[1].res_id)
      info.cnt = tonumber(reward_list[1].count)
      tbData[info.ID] = info
    end
  end
  log(bWriteLog and "achievement_cfg_helper.Load_AchievementScoreCfg Load")
  achievement_cfg_helper.tb_AchievementScoreCfg = tbData
  return tbData
end
function achievement_cfg_helper.OnGetAwardTable(tableName, data)
  if data then
    log(bWriteLog and "achievement_cfg_helper.OnGetAwardTable tableName:" .. tostring(tableName))
    log_tree(bWriteLog and "achievement_cfg_helper.OnGetAwardTable data:", data)
    NetDataAward = data
    EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_GET_AWARD_TABLE)
  end
end
function achievement_cfg_helper.InitMap()
  log(bWriteLog and "achievement_cfg_helper.InitMap begin")
  local achievement_cfg_tool = require("client.slua.logic.achievement.achievement_cfg_tool")
  local CreateCondiParamAchiveMap_tbData = {}
  achievement_cfg_helper.tb_CondiParam2AchieveIDMap = CreateCondiParamAchiveMap_tbData
  local CreateCondID2CfgID_tbData = {}
  achievement_cfg_helper.tb_CondID2AcheieveIDMap = CreateCondID2CfgID_tbData
  local CreatedMultiLvGroupIdAchiveMap_tbData = {}
  achievement_cfg_helper.tb_MultiLvGroupID2AchiveIDMap = CreatedMultiLvGroupIdAchiveMap_tbData
  local ZerotbData = {}
  CreatedMultiLvGroupIdAchiveMap_tbData[0] = ZerotbData
  local AchievementCfg = CDataTable.GetTable("AchievementCfg")
  if AchievementCfg then
    local config_ugc_authorhome = require("client.slua.umg.ugc.AuthorHome.config_ugc_authorhome")
    for _, cfg in pairs(AchievementCfg) do
      if not cfg.UGCFlag or cfg.UGCFlag == 0 then
        local conditionList = achievement_cfg_tool.ParserCondition(cfg.Conditions)
        local configID = cfg.ID
        if conditionList and 0 < #conditionList then
          for kk, vv in pairs(conditionList) do
            local conditionID = vv.ConditionID
            local tbCondiID = CreateCondiParamAchiveMap_tbData[conditionID]
            if tbCondiID == nil then
              tbCondiID = {}
              CreateCondiParamAchiveMap_tbData[conditionID] = tbCondiID
            end
            local tbParam = tbCondiID[vv.Param2TypeID]
            if tbParam == nil then
              tbParam = {}
              tbCondiID[vv.Param2TypeID] = tbParam
            end
            table.insert(tbParam, configID)
            local CondID2CfgIDTable = CreateCondID2CfgID_tbData[conditionID]
            if not CondID2CfgIDTable then
              CondID2CfgIDTable = {}
              CreateCondID2CfgID_tbData[conditionID] = CondID2CfgIDTable
            end
            table.insert(CondID2CfgIDTable, configID)
          end
        end
        local GroupID = cfg.GroupID
        local MultiLvGroupID = cfg.MultiLvGroupID
        if achievement_cfg_helper.IsValidAchievementID(configID, cfg) then
          local tbGroupID = CreatedMultiLvGroupIdAchiveMap_tbData[GroupID]
          if tbGroupID == nil then
            tbGroupID = {}
            CreatedMultiLvGroupIdAchiveMap_tbData[GroupID] = tbGroupID
          end
          if 0 < MultiLvGroupID then
            local tbMultiLvGroup = tbGroupID[MultiLvGroupID]
            if tbMultiLvGroup == nil then
              tbMultiLvGroup = {}
              tbGroupID[MultiLvGroupID] = tbMultiLvGroup
            end
            table.insert(tbMultiLvGroup, configID)
            local zeroTBMultiLvGroupID = ZerotbData[MultiLvGroupID]
            if zeroTBMultiLvGroupID == nil then
              ZerotbData[MultiLvGroupID] = tbMultiLvGroup
            end
          else
            local tbGroupID_ID = tbGroupID[configID]
            if tbGroupID_ID == nil then
              tbGroupID_ID = {}
              tbGroupID[configID] = tbGroupID_ID
            end
            table.insert(tbGroupID_ID, configID)
            local zeroTBData_ID = ZerotbData[configID]
            if zeroTBData_ID == nil then
              ZerotbData[configID] = tbGroupID_ID
            end
          end
        end
      end
    end
  end
  log(bWriteLog and "achievement_cfg_helper.InitMap end")
end
function achievement_cfg_helper.CreateCondiParamAchiveMap()
  if not achievement_cfg_helper.tb_CondiParam2AchieveIDMap then
    log(bWriteLog and "achievement_cfg_helper.CreateCondiParamAchiveMap")
    achievement_cfg_helper.InitMap()
  end
  return achievement_cfg_helper.tb_CondiParam2AchieveIDMap
end
function achievement_cfg_helper.CreateCondID2CfgID()
  if not achievement_cfg_helper.tb_CondID2AcheieveIDMap then
    log(bWriteLog and "achievement_cfg_helper.CreateCondID2CfgID")
    achievement_cfg_helper.InitMap()
  end
  return achievement_cfg_helper.tb_CondID2AcheieveIDMap
end
function achievement_cfg_helper.CreatedMultiLvGroupIdAchiveMap()
  if not achievement_cfg_helper.tb_MultiLvGroupID2AchiveIDMap then
    log(bWriteLog and "achievement_cfg_helper.CreatedMultiLvGroupIdAchiveMap")
    achievement_cfg_helper.InitMap()
  end
  return achievement_cfg_helper.tb_MultiLvGroupID2AchiveIDMap
end
function achievement_cfg_helper.IsValidAchievementID(id, cfg)
  if cfg == nil then
    cfg = CDataTable.GetTableData("AchievementCfg", id)
  end
  if cfg == nil then
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return cfg.JPKREnable
  end
  if PublishRegionMacros.IsBLUEHOLE() then
    return cfg.BLUEHOLEEnable
  end
  return cfg.GlobalEnable
end
function achievement_cfg_helper.GetAchievementSeqCfg()
  log(bWriteLog and "achievement_cfg_helper.GetAchievementSeqCfg")
  if achievement_cfg_helper.tb_AchievementSeqCfgList then
    return achievement_cfg_helper.tb_AchievementSeqCfgList
  end
  local tabCfg = CDataTable.GetTable("AchievementSeqCfg")
  local tempCfg = {}
  for i, v in pairs(tabCfg) do
    table.insert(tempCfg, {
      ID = v.ID,
      Index = v.Index,
      Name = v.Name
    })
  end
  table.sort(tempCfg, function(a, b)
    return a.Index < b.Index
  end)
  log(bWriteLog and "achievement_cfg_helper.GetAchievementSeqCfg load")
  achievement_cfg_helper.tb_AchievementSeqCfgList = tempCfg
  return tempCfg
end
function achievement_cfg_helper.AppendList(list1, list2)
  if list1 == nil or list2 == nil then
    return
  end
  for k, v in pairs(list2) do
    table.insert(list1, v)
  end
end
function achievement_cfg_helper.GetAchieveIdListFromConditionProcess(res)
  if res == nil then
    return nil
  end
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  local idList = {}
  local condiMap = achievement_cfg_helper.CreateCondiParamAchiveMap()
  for k, v in pairs(res) do
    local info1 = condiMap[k]
    if info1 then
      if logic_achievement.IsRankConditionByConditionID(k) then
        for kk, vv in pairs(info1) do
          achievement_cfg_helper.AppendList(idList, vv)
        end
      else
        for kk, vv in pairs(v) do
          achievement_cfg_helper.AppendList(idList, info1[kk])
        end
      end
    else
      log(bWriteLog and "achievement_cfg_helper.GetAchieveIdListFromConditionProcess k = " .. k)
    end
  end
  return idList
end
function achievement_cfg_helper.InitUGCMap()
  log(bWriteLog and "achievement_cfg_helper.InitUGCMap begin")
  local achievement_cfg_tool = require("client.slua.logic.achievement.achievement_cfg_tool")
  local CreateCondiParamAchiveMap_UGC_tbData = {}
  achievement_cfg_helper.tb_CondiParam2AchieveID_UGC_Map = CreateCondiParamAchiveMap_UGC_tbData
  local CreateCondID2CfgID_UGC_tbData = {}
  achievement_cfg_helper.tb_CondID2AchieveID_UGC_Map = CreateCondID2CfgID_UGC_tbData
  local CreatedMultiLvGroupIdAchiveMap_UGC_tbData = {}
  achievement_cfg_helper.tb_MultiLvGroupID2AchiveID_UGC_Map = CreatedMultiLvGroupIdAchiveMap_UGC_tbData
  local Zerotb_UGCData = {}
  CreatedMultiLvGroupIdAchiveMap_UGC_tbData[0] = Zerotb_UGCData
  local AchievementCfg = CDataTable.GetTable("AchievementCfg")
  if AchievementCfg then
    local config_ugc_authorhome = require("client.slua.umg.ugc.AuthorHome.config_ugc_authorhome")
    for _, cfg in pairs(AchievementCfg) do
      if cfg.UGCFlag and cfg.UGCFlag == 1 then
        local conditionList = achievement_cfg_tool.ParserCondition(cfg.Conditions)
        local configID = cfg.ID
        if conditionList and 0 < #conditionList then
          for kk, vv in pairs(conditionList) do
            local conditionID = vv.ConditionID
            local tbCondiID = CreateCondiParamAchiveMap_UGC_tbData[conditionID]
            if tbCondiID == nil then
              tbCondiID = {}
              CreateCondiParamAchiveMap_UGC_tbData[conditionID] = tbCondiID
            end
            local tbParam = tbCondiID[vv.Param2TypeID]
            if tbParam == nil then
              tbParam = {}
              tbCondiID[vv.Param2TypeID] = tbParam
            end
            table.insert(tbParam, configID)
            local CondID2CfgIDTable = CreateCondID2CfgID_UGC_tbData[conditionID]
            if not CondID2CfgIDTable then
              CondID2CfgIDTable = {}
              CreateCondID2CfgID_UGC_tbData[conditionID] = CondID2CfgIDTable
            end
            table.insert(CondID2CfgIDTable, configID)
          end
        end
        local GroupID = cfg.GroupID
        local MultiLvGroupID = cfg.MultiLvGroupID
        if achievement_cfg_helper.IsValidAchievementID(configID, cfg) then
          local tbGroupID = CreatedMultiLvGroupIdAchiveMap_UGC_tbData[GroupID]
          if tbGroupID == nil then
            tbGroupID = {}
            CreatedMultiLvGroupIdAchiveMap_UGC_tbData[GroupID] = tbGroupID
          end
          if 0 < MultiLvGroupID then
            local tbMultiLvGroup = tbGroupID[MultiLvGroupID]
            if tbMultiLvGroup == nil then
              tbMultiLvGroup = {}
              tbGroupID[MultiLvGroupID] = tbMultiLvGroup
            end
            table.insert(tbMultiLvGroup, configID)
            local zeroTBMultiLvGroupID = Zerotb_UGCData[MultiLvGroupID]
            if zeroTBMultiLvGroupID == nil then
              Zerotb_UGCData[MultiLvGroupID] = tbMultiLvGroup
            end
          else
            local tbGroupID_ID = tbGroupID[configID]
            if tbGroupID_ID == nil then
              tbGroupID_ID = {}
              tbGroupID[configID] = tbGroupID_ID
            end
            table.insert(tbGroupID_ID, configID)
            local zeroTBData_ID = Zerotb_UGCData[configID]
            if zeroTBData_ID == nil then
              Zerotb_UGCData[configID] = tbGroupID_ID
            end
          end
        end
      end
    end
  end
  log(bWriteLog and "achievement_cfg_helper.InitUGCMap end")
end
return achievement_cfg_helper