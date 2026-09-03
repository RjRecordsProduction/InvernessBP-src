ENUM_RECRUIT_OPENMIC = {HAVETO = 1, ARBITRARILY = 0}
ENUM_RECRUIT_OPENSAMELANG = {HAVETO = 1, ARBITRARILY = 2}
local RecruitSystem = {
  T_PLAN_TAB_ID = 15,
  perspectiveList = {},
  voiceTypeList = {}
}
local bufstr_table_pool_file = "client.slua.logic.lobby_chat.logic_chat_recruit_bufstr_table_pool"
function RecruitSystem.OpenRecruitFilter()
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.TeamRecruit) then
    return
  end
  local isroom = RoomSystem.IsShowWaiting()
  if isroom == true then
    ShowNotice(301294)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local curPlayer = TeamUpNewSystem.GetTeamNum()
  if 4 <= curPlayer then
    ShowNotice(110019)
    return
  end
  local logic_recruit_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_new)
  logic_recruit_new:OpenRecruitUI()
end
function RecruitSystem.GetTabName(tabID)
  local ModeTabConfig = CDataTable.GetTable("ModeTabConfig")
  for _, v in pairs(ModeTabConfig) do
    if v.TabID == tabID then
      return v.Name
    end
  end
  return ""
end
function RecruitSystem.InitPerspectiveList()
  RecruitSystem.perspectiveList = {}
  for id = 100053, 100054 do
    table.insert(RecruitSystem.perspectiveList, id)
  end
end
function RecruitSystem.VoiceTypeList()
  RecruitSystem.voiceTypeList = {}
  for id = 4717, 4719 do
    table.insert(RecruitSystem.voiceTypeList, id)
  end
end
function RecruitSystem.CheckInit()
  if #RecruitSystem.perspectiveList == 0 then
    RecruitSystem.InitPerspectiveList()
  end
  if #RecruitSystem.voiceTypeList == 0 then
    RecruitSystem.VoiceTypeList()
  end
end
local _GetMaxPlayerNumByMapData = function(viewID, isTPlan)
  if isTPlan then
    return 4
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  return logic_mode_selection:GetMaxPlayerNumByViewId(viewID)
end
function RecruitSystem.GetMapStrAndPveMapNewMode(tabID, mapData)
  local Pve_Map = mapData
  local mapStr = ""
  local mapId = 0
  local logic_recruit_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_new)
  mapStr, mapId = logic_recruit_new:GetMapNamesNew(mapData, tabID)
  return mapStr, Pve_Map, mapId
end
function RecruitSystem.TeamRecruitMap(msg, mapData)
  if not msg then
    return nil, nil, false
  end
  RecruitSystem.CheckInit()
  local StringUtil = require("common.string_util")
  local msgArr = StringUtil.Split(msg, "-")
  local resultMsg = ""
  local mapmod = tonumber(msgArr[1])
  if not mapmod or #msgArr < 4 then
    return nil, nil, false
  end
  local isInTPlan = false
  local tablepool = require(bufstr_table_pool_file)
  local msgArr1 = int32ToBufStr(tonumber(msgArr[1]) or 0)
  local tabID = msgArr1[1] or 0
  local modelString = ""
  local perspectiveString = ""
  if tabID == RecruitSystem.T_PLAN_TAB_ID then
    if mapData then
      local modeName = RecruitSystem.GetTPlanModeName(mapData[1])
      perspectiveString = modeName
    end
    isInTPlan = true
  else
    local perspectiveIndex = msgArr1[2] or 2
    if perspectiveIndex == 0 then
      perspectiveIndex = 2
    end
    local txtLocalizeId = RecruitSystem.perspectiveList[perspectiveIndex]
    perspectiveString = LocUtil.GetLocalizeResStr(txtLocalizeId)
    local logic_recruit_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_new)
    modelString = logic_recruit_new:GetTabName(tabID)
    if modelString == nil or perspectiveString == nil then
      log_warning("[recruit] msgError msg:" .. tostring(msg))
      log_tree("mapData", mapData)
      tablepool.Recycle(msgArr1)
      return nil, nil, false
    end
  end
  log(bWriteLog and "god test resultMsg -1 " .. tostring(modelString))
  local conditionStr, matchLang = RecruitSystem.GetConditionStr(msgArr)
  resultMsg = resultMsg .. modelString
  log(bWriteLog and "god test resultMsg 0 " .. tostring(resultMsg))
  log_tree("god test mapData ", mapData)
  local mapStr, Pve_Map, mapId
  mapStr, Pve_Map, mapId = RecruitSystem.GetMapStrAndPveMapNewMode(tabID, mapData)
  if mapStr then
    resultMsg = resultMsg .. "|" .. mapStr
  end
  log(bWriteLog and "god test resultMsg 1 " .. tostring(resultMsg))
  resultMsg = resultMsg .. " (" .. perspectiveString .. ")"
  log(bWriteLog and "god test resultMsg 2 " .. tostring(resultMsg))
  local index = msgArr1[3] or 0
  local voiceTextId = RecruitSystem.voiceTypeList[index + 1]
  resultMsg = resultMsg .. "|" .. LocUtil.GetLocalizeResStr(voiceTextId)
  log(bWriteLog and "god test resultMsg 3 " .. tostring(resultMsg))
  local maxPlayNum = _GetMaxPlayerNumByMapData(mapId, isInTPlan) or 0
  if maxPlayNum < 4 then
    log(bWriteLog and "[v_wllwu] test resultMsg maxPlayNum is error and maxPlayNum is " .. tostring(maxPlayNum))
    maxPlayNum = 4
  end
  resultMsg = string.format("%s|%s/%s", resultMsg, tostring(msgArr1[4] or 1), maxPlayNum)
  log(bWriteLog and "god test resultMsg 4 " .. tostring(resultMsg))
  resultMsg = resultMsg .. "|" .. mapId
  resultMsg = resultMsg .. "|" .. (conditionStr or "")
  resultMsg = resultMsg .. "|" .. matchLang
  tablepool.Recycle(msgArr1)
  return resultMsg, Pve_Map, isInTPlan
end
function RecruitSystem.GetConditionStr(msgArr)
  local msgArr1 = int32ToBufStr(tonumber(msgArr[1]) or 0)
  local msgArr3 = int32ToBufStr(tonumber(msgArr[3]) or 0)
  local strPos = ""
  if msgArr3[1] ~= "" then
    if tonumber(msgArr3[1]) == 0 then
      strPos = ""
    else
      local id = tonumber(msgArr3[1]) + 1
      local posInfo = CDataTable.GetTableData("MatchStrategyConfig", id)
      if posInfo then
        strPos = posInfo.Name
      end
    end
  end
  local conditionStr = ""
  local segment = ""
  if msgArr3[2] == 0 then
    segment = ""
  else
    local tempTable = {}
    local rankTable = FuncUtil.GetRankTable()
    for k, v in pairs(rankTable) do
      if tempTable[v.IntegralTypeNew] == nil then
        tempTable[v.IntegralTypeNew] = v.IntegralTypeName
      end
    end
    for k, v in pairs(tempTable) do
      if k == msgArr3[2] then
        segment = v
        break
      end
    end
  end
  if segment ~= "" then
    conditionStr = segment .. "/"
  end
  local micro = msgArr1[3] or 2
  if micro ~= 2 then
    conditionStr = conditionStr .. LocUtil.GetLocalizeResStr("7931") .. "/"
  end
  if msgArr3[3] ~= 2 then
    conditionStr = conditionStr .. LocUtil.GetLocalizeResStr("7930") .. "/"
  end
  if strPos ~= "" then
    conditionStr = conditionStr .. strPos .. "/"
  end
  if conditionStr == "" then
    if tonumber(msgArr1[1]) == RecruitSystem.T_PLAN_TAB_ID then
      conditionStr = LocUtil.GetLocalizeResStr("35185")
    else
      conditionStr = LocUtil.GetLocalizeResStr("7929")
    end
  else
    conditionStr = string.sub(conditionStr, 0, string.len(conditionStr) - 1)
  end
  local matchLanguage = ""
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id == tonumber(msgArr3[4]) then
      matchLanguage = v.langName
      break
    end
  end
  local tablepool = require(bufstr_table_pool_file)
  tablepool.Recycle(msgArr1)
  tablepool.Recycle(msgArr3)
  return conditionStr, matchLanguage
end
function RecruitSystem.GetModeIDByViewID(viewID)
  local groupConfig = CDataTable.GetTable("GroupingTable")
  for k, v in pairs(groupConfig) do
    if v.ViewId == viewID then
      return v.ModeTeamId
    end
  end
  return 0
end
function RecruitSystem.GetTPlanMapNamesNew(msgArr, _)
  local mapStr = ""
  local viewID = tonumber(msgArr[1])
  local mode_id = RecruitSystem.GetModeIDByViewID(viewID)
  local modeMapInfo = CDataTable.GetTableData("TxMissionMapMode", mode_id)
  if modeMapInfo and modeMapInfo.MapID then
    local mapInfo = CDataTable.GetTableData("TxMissionMap", modeMapInfo.MapID)
    if mapInfo and mapInfo.Name then
      mapStr = mapInfo.Name
    end
  end
  return mapStr, mode_id
end
function RecruitSystem.GetTPlanModeName(viewID)
  local mode_id = RecruitSystem.GetModeIDByViewID(viewID)
  local modeMapInfo = CDataTable.GetTableData("TxMissionMapMode", mode_id)
  if modeMapInfo and modeMapInfo.ModeType then
    local modeInfo = CDataTable.GetTableData("TxMissionMode", modeMapInfo.ModeType)
    if modeInfo and modeInfo.Name then
      return modeInfo.Name
    end
  end
  return ""
end
function RecruitSystem.IsTPlanRecruit(msg, need_group)
  if not (msg and msg.content) or not msg.content.text then
    return false, 0
  end
  local StringUtil = require("common.string_util")
  local msgArr = StringUtil.Split(msg.content.text, "-")
  local mapmod = tonumber(msgArr[1])
  if not mapmod or #msgArr < 4 then
    return false, 0
  end
  local tablepool = require(bufstr_table_pool_file)
  local msgArr1 = int32ToBufStr(tonumber(msgArr[1]) or 0)
  local tabID = msgArr1[1] or 0
  tablepool.Recycle(msgArr1)
  if tabID == RecruitSystem.T_PLAN_TAB_ID then
    if need_group then
      local mode_id = RecruitSystem.GetTPlanModeGroup(msg.mapData)
      if 0 < mode_id then
        return true, mode_id
      end
      return false, 0
    end
    return true, 0
  end
  return false, 0
end
function RecruitSystem.GetTPlanModeGroup(mapData)
  if mapData then
    local viewID = tonumber(mapData[1])
    local mode_id = RecruitSystem.GetModeIDByViewID(viewID)
    if 0 < mode_id then
      return mode_id
    end
  end
  return 0
end
function RecruitSystem.IsTPlanRecruitMsg(msg)
  if not msg then
    return
  end
  log(bWriteLog and "[v_wllwu] RecruitSystem.IsTPlanRecruitMsg" .. tostring(msg.tab_id))
  return msg.tab_id == RecruitSystem.T_PLAN_TAB_ID
end
return RecruitSystem