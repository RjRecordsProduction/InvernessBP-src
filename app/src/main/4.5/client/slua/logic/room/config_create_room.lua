local CreateRoomConfig = {
  basicParamList = nil,
  privilegeParamList = nil,
  paramList = nil,
  mapList = {},
  ESportRoomCardMapList = {},
  currentModeName = nil
}
local C_RoomTypeMap = {
  Ordinary = "ordinary",
  Advance = "advanced",
  Match = "match",
  Bonus = "bonus",
  AG = "asian_games",
  TMode = "tmode",
  TMatch = "tmode_match"
}
CreateRoomConfig.local C_RoomCardInfo = {
  ordinary = "room_card_info",
  wow = "room_card_info_wow",
  advanced = "room_card_info_adv",
  match = "room_card_info_mat",
  tmode = "room_card_info_tmode"
}
CreateRoomConfig.local C_RoomPrivilegeMap = {
  IDC = "idc",
  Replay = "replay",
  Signal = "signal_mod",
  TLog = "tlog",
  Circle = "circle_test"
}
CreateRoomConfig.local C_CreateRoomUITabID = {
  Normal = 1,
  Advance = 2,
  Circle = 3
}
CreateRoomConfig.local C_ParamWidgetType = {
  Value = 1,
  Switch = 2,
  Slider = 3,
  Title = 100
}
CreateRoomConfig.CreateRoomConfig.C_TmodeItemID = 2130001
CreateRoomConfig.C_TmodeMatchItemID = 2130004
local C_RoomCardConfig = {
  [2104006] = {
    LocId = 86805,
    ParamDesc = "1",
    ButtonTextId = 86809,
    IconIndex = 1,
    AdvanceParamDescId = 86807,
    Type = C_RoomTypeMap.Advance
  },
  [2104008] = {
    LocId = 86805,
    ParamDesc = "7",
    ButtonTextId = 86809,
    IconIndex = 1,
    AdvanceParamDescId = 86807,
    Type = C_RoomTypeMap.Advance
  },
  [2103006] = {
    LocId = 86804,
    ParamDesc = "1",
    ButtonTextId = 86809,
    IconIndex = 1,
    AdvanceParamDescId = 86807,
    Type = C_RoomTypeMap.Advance
  },
  [2103008] = {
    LocId = 86804,
    ParamDesc = "7",
    ButtonTextId = 86809,
    IconIndex = 1,
    AdvanceParamDescId = 86807,
    Type = C_RoomTypeMap.Advance
  },
  [2103010] = {
    LocId = 86804,
    ParamDesc = "30",
    ButtonTextId = 86809,
    IconIndex = 1,
    AdvanceParamDescId = 86807,
    Type = C_RoomTypeMap.Advance
  },
  [2113002] = {
    LocId = 86805,
    ParamDesc = "1",
    ButtonTextId = 86809,
    IconIndex = 1,
    AdvanceParamDescId = 86807,
    Type = C_RoomTypeMap.Advance
  },
  [2104001] = {
    LocId = 86805,
    ParamDesc = "1",
    ButtonTextId = 86808,
    IconIndex = 0,
    AdvanceParamDescId = 86806,
    Type = C_RoomTypeMap.Ordinary
  },
  [2104003] = {
    LocId = 86805,
    ParamDesc = "7",
    ButtonTextId = 86808,
    IconIndex = 0,
    AdvanceParamDescId = 86806,
    Type = C_RoomTypeMap.Ordinary
  },
  [2103001] = {
    LocId = 86804,
    ParamDesc = "1",
    ButtonTextId = 86808,
    IconIndex = 0,
    AdvanceParamDescId = 86806,
    Type = C_RoomTypeMap.Ordinary
  },
  [2103003] = {
    LocId = 86804,
    ParamDesc = "7",
    ButtonTextId = 86808,
    IconIndex = 0,
    AdvanceParamDescId = 86806,
    Type = C_RoomTypeMap.Ordinary
  },
  [2103005] = {
    LocId = 86804,
    ParamDesc = "30",
    ButtonTextId = 86808,
    IconIndex = 0,
    AdvanceParamDescId = 86806,
    Type = C_RoomTypeMap.Ordinary
  },
  [2113001] = {
    LocId = 86805,
    ParamDesc = "1",
    ButtonTextId = 86808,
    IconIndex = 0,
    AdvanceParamDescId = 86806,
    Type = C_RoomTypeMap.Ordinary
  }
}
CreateRoomConfig.local C_RoomCardTypeMap = {
  [2103] = C_RoomTypeMap.Ordinary,
  [2104] = C_RoomTypeMap.Ordinary,
  [2105] = C_RoomTypeMap.Ordinary,
  [2106] = C_RoomTypeMap.Advance,
  [2107] = C_RoomTypeMap.Advance,
  [2108] = C_RoomTypeMap.Advance,
  [6601] = C_RoomTypeMap.Advance
}
CreateRoomConfig.local C_RoomCardSubTypeList = {
  ordinary = {
    2103,
    2104,
    2105
  },
  advanced = {
    2106,
    2107,
    2108,
    6601
  }
}
CreateRoomConfig.local C_SPECIAL_MAP = {
  [20048] = {itemCount = 4}
}
CreateRoomConfig.local C_ParamKey_TimeType = {
  WhitecircleShowtime = true,
  WhitecircleStarttime = true,
  ExitOpeningDelay = true,
  ExitOpeningTime = true,
  StateTime = true
}
CreateRoomConfig.local C_CirParamType = {
  DelayValueListStr = 1,
  WaitValueListStr = 2,
  MoveValueListStr = 3,
  DamageValueListStr = 4,
  BuleCirValueListStr = 5,
  WhiteCirValueListStr = 6
}
CreateRoomConfig.local C_CpModeIdList = {
  [20037] = {nKey = 20037, sPackageName = "Lucid"},
  [20038] = {nKey = 20038, sPackageName = "Lightpaw"},
  [20039] = {nKey = 20039, sPackageName = "Behaviour"}
}
CreateRoomConfig.local C_ParamKey_CustomStyle = {
  DeathMatchWinScore = {
    baseRate = 1,
    CurValID = 0,
    MinValID = 0,
    MaxValID = 0,
    RangStrID = 7545
  },
  WhitecircleShowtime = {
    baseRate = 1,
    CurValID = 19294,
    MinValID = 0,
    MaxValID = 19294,
    RangStrID = 7545
  },
  WhitecircleStarttime = {
    baseRate = 1,
    CurValID = 19294,
    MinValID = 0,
    MaxValID = 19294,
    RangStrID = 7545
  },
  ExitOpeningDelay = {
    baseRate = 1,
    CurValID = 19294,
    MinValID = 0,
    MaxValID = 19294,
    RangStrID = 7545
  },
  ExitOpeningTime = {
    baseRate = 60,
    CurValID = 69975,
    MinValID = 0,
    MaxValID = 69975,
    RangStrID = 7545
  },
  StateTime = {
    baseRate = 60,
    CurValID = 69975,
    MinValID = 0,
    MaxValID = 69975,
    RangStrID = 7545
  },
  GameTime = {
    baseRate = 1,
    CurValID = 0,
    MinValID = 0,
    MaxValID = 0,
    RangStrID = 7545
  },
  FrameLimit = {
    baseRate = 1,
    CurValID = 0,
    MinValID = 0,
    MaxValID = 0,
    RangStrID = 7545
  },
  DeathMatchGameTime = {
    baseRate = 1,
    CurValID = 0,
    MinValID = 0,
    MaxValID = 0,
    RangStrID = 7545
  }
}
CreateRoomConfig.local _BasicTab = {
  nNameID = 19601,
  nID = C_CreateRoomUITabID.Normal
}
local _AdvanceTab = {
  nNameID = 19602,
  nID = C_CreateRoomUITabID.Advance
}
local _MatchTab = {
  nNameID = 6858,
  nID = C_CreateRoomUITabID.Advance
}
local _CircleTab = {
  nNameID = 49149,
  nID = C_CreateRoomUITabID.Circle
}
function CreateRoomConfig.GetCommonTabList()
  return {
    [1] = _BasicTab
  }
end
function CreateRoomConfig.GetAdvanceTabList()
  return {
    [1] = _BasicTab,
    [2] = _AdvanceTab
  }
end
function CreateRoomConfig.GetMatchTabList(privilegeList)
  if privilegeList and 0 < #privilegeList then
    for _, v in ipairs(privilegeList) do
      if v == C_RoomPrivilegeMap.Circle then
        return {
          [1] = _BasicTab,
          [2] = _MatchTab,
          [3] = _CircleTab
        }
      end
    end
  end
  return {
    [1] = _BasicTab,
    [2] = _MatchTab
  }
end
function CreateRoomConfig.GetAdvanceOptionTabList()
  return {
    [1] = _AdvanceTab
  }
end
function CreateRoomConfig.GetMatchOptionTabList()
  return {
    [1] = _MatchTab
  }
end
function CreateRoomConfig.IsValidByVersion(version, appVersion)
  if not version or version == "" then
    return true
  end
  local version_util = require("client.common.version_util")
  if version_util.CompareVersionStandard(appVersion, version) >= 0 then
    return true
  end
  return false
end
function CreateRoomConfig.GetMapList(perspective)
  if not CreateRoomConfig.mapList[perspective] then
    local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
    local tppList = {}
    local fppList = {}
    local Map = CDataTable.GetTable("Map")
    local tResIdSortMap = {}
    for k, v in pairs(Map) do
      if v.RoomModeId > 0 and v.WatchingName ~= "T" then
        local container = v.IsFpp == 1 and fppList or tppList
        if CreateRoomConfig.IsCpMode(v) then
          table.insert(container, v)
          local uMapCfg = CreateRoomSystem.GetSwitchCfgByMapId(v.ResId)
          if uMapCfg then
            tResIdSortMap[v.ResId] = uMapCfg.SortID
          end
        end
      end
    end
    table.sort(fppList, function(a, b)
      local SortA = tResIdSortMap[a.ResId]
      local SortB = tResIdSortMap[b.ResId]
      if SortA and SortB then
        return SortA < SortB
      end
      return a.ResId < b.ResId
    end)
    CreateRoomConfig.mapList[ENUM_PerspectiveType.FPP] = fppList
    table.sort(tppList, function(a, b)
      local SortA = tResIdSortMap[a.ResId]
      local SortB = tResIdSortMap[b.ResId]
      if SortA and SortB then
        return SortA < SortB
      end
      return a.ResId < b.ResId
    end)
    CreateRoomConfig.mapList[ENUM_PerspectiveType.TPP] = tppList
  end
  local result = CreateRoomConfig.mapList[perspective]
  if not result or not next(result) then
    return {
      CDataTable.GetTableData("Map", 1)
    }
  end
  return result
end
function CreateRoomConfig.GetMapListByIdList(idList)
  if not idList or type(idList) ~= "table" or not next(idList) then
    log(bWriteLog and "CreateRoomConfig:GetMapListByIdList. idList is empty or invalid")
    return {}
  end
  local Map = CDataTable.GetTable("Map")
  if not Map then
    log_warning_format("CreateRoomConfig:GetMapListByIdList. Map table not found")
    return {}
  end
  local mapList = {}
  local validCount = 0
  for i, mapId in ipairs(idList) do
    if mapId and tonumber(mapId) then
      local mapCfg = CDataTable.GetTableData("Map", tonumber(mapId))
      if mapCfg then
        table.insert(mapList, mapCfg)
        validCount = validCount + 1
      else
        log_warning_format("CreateRoomConfig:GetMapListByIdList. Map config not found for id:%s", tostring(mapId))
      end
    else
      log_warning_format("CreateRoomConfig:GetMapListByIdList. Invalid map id:%s", tostring(mapId))
    end
  end
  log_format("CreateRoomConfig:GetMapListByIdList. Input count:%s, valid count:%s", #idList, validCount)
  return mapList
end
function CreateRoomConfig.GetTmodeMapList()
  local filtered = CDataTable.GetTableByFilter("Map", "WatchingName", "T")
  local list = {}
  for k, v in pairs(filtered) do
    if v.RoomModeId > 0 then
      table.insert(list, v)
    end
  end
  table.sort(list, function(a, b)
    local AsortCfg = CDataTable.GetTableData("MapSwitchCfg", a.ResId)
    local BsortCfg = CDataTable.GetTableData("MapSwitchCfg", b.ResId)
    if not AsortCfg or not BsortCfg then
      return a.ResId < b.ResId
    else
      return AsortCfg.SortID < BsortCfg.SortID
    end
  end)
  return list
end
function CreateRoomConfig.GetValidMapList(mapList, curRoomType)
  if not mapList or not next(mapList) then
    return {}
  end
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local TimeUtil = require("client.common.time_util")
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local now = TimeUtil.GetServerTimeInSec()
  local validList = {}
  local tSortIdList = {}
  local topValidList = {}
  local sortCfg, isTop
  local hasTop = false
  for i, v in ipairs(mapList) do
    local uMapCfg = CreateRoomSystem.GetSwitchCfgByMapId(v.ResId)
    local bIsInsert = false
    if uMapCfg and CreateRoomConfig.IsValidByVersion(uMapCfg.LowerVersion, clientVersion) and CreateRoomConfig.FilterMapIdByRoomType(curRoomType, uMapCfg.RoomTypes) then
      local nStartTime = TimeUtil.TimeStringToUnixstamp(uMapCfg.StartTime)
      local nEndTime = TimeUtil.TimeStringToUnixstamp(uMapCfg.EndTime)
      if now >= nStartTime and now <= nEndTime then
        tSortIdList[v.ResId] = uMapCfg.SortID
        bIsInsert = true
      end
    end
    if bIsInsert then
      isTop = false
      sortCfg = CDataTable.GetTableData("RoomMapSortConfig", v.ResId)
      if sortCfg then
        local beginTime = TimeUtil.TimeStringToUnixstamp(sortCfg.BeginTime)
        local endTime = TimeUtil.TimeStringToUnixstamp(sortCfg.EndTime)
        if now >= beginTime and now <= endTime then
          table.insert(topValidList, v)
          isTop = true
        end
      end
      if not isTop then
        table.insert(validList, v)
      end
    end
  end
  table.sort(validList, function(a, b)
    local sortA = tSortIdList[a.ResId] or 0
    local sortB = tSortIdList[b.ResId] or 0
    return sortA > sortB
  end)
  validList, hasTop = CreateRoomConfig.GetMapListBySubsideFeature(validList, 1)
  if 1 < #topValidList then
    table.sort(topValidList, function(a, b)
      local sortInfoA = CDataTable.GetTableData("RoomMapSortConfig", a.ResId)
      local sortInfoB = CDataTable.GetTableData("RoomMapSortConfig", b.ResId)
      if not sortInfoA and sortInfoB then
        return true
      elseif sortInfoA and sortInfoB then
        return sortInfoA.Sort < sortInfoB.Sort
      else
        return false
      end
    end)
  end
  if 0 < #topValidList then
    local TableUtil = require("common.table_util")
    validList = TableUtil.TableConcat(topValidList, validList)
  end
  return validList, hasTop
end
function CreateRoomConfig.GetESportCardMapList(card_id, perspective)
  card_id = card_id or 0
  if not card_id then
    return {}
  end
  if not CreateRoomConfig.ESportRoomCardMapList[card_id] then
    CreateRoomConfig.ESportRoomCardMapList[card_id] = {}
  end
  if CreateRoomConfig.ESportRoomCardMapList[card_id][perspective] and next(CreateRoomConfig.ESportRoomCardMapList[card_id][perspective]) then
    return CreateRoomConfig.ESportRoomCardMapList[card_id][perspective]
  end
  CreateRoomConfig.ESportRoomCardMapList[card_id][perspective] = {}
  local list = {}
  local pp = perspective == ENUM_PerspectiveType.FPP and 1 or 0
  local eMapCfgs = CDataTable.GetTable("EsportsMap")
  for key, value in pairs(eMapCfgs) do
    local mapCfg = CDataTable.GetTableData("Map", key)
    if mapCfg and mapCfg.IsFpp == pp then
      table.insert(list, mapCfg)
    end
  end
  table.sort(list, function(a, b)
    local cfgA = CDataTable.GetTableData("EsportsMap", tonumber(a.ResId))
    local cfgB = CDataTable.GetTableData("EsportsMap", tonumber(b.ResId))
    return cfgA.ID < cfgB.ID
  end)
  CreateRoomConfig.ESportRoomCardMapList[card_id][perspective] = list
  return list
end
function CreateRoomConfig.GetMapListBySubsideFeature(validList, defaultMapId)
  validList = validList or {}
  local topValidList = {}
  local hasTop = false
  for i, v in ipairs(validList) do
    if v.ResId == defaultMapId then
      table.insert(topValidList, v)
      hasTop = true
      table.remove(validList, i)
      break
    end
  end
  if 0 < #topValidList then
    local TableUtil = require("common.table_util")
    validList = TableUtil.TableConcat(topValidList, validList)
  end
  return validList, hasTop
end
function CreateRoomConfig.FilterMapIdByRoomType(curRoomType, sRoomTypes)
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local roomTypeConfig = CreateRoomSystem.ConvertRoomTypes(sRoomTypes)
  if roomTypeConfig and next(roomTypeConfig) then
    local bUGC = roomTypeConfig.ugc
    if bUGC then
      log(bWriteLog and "CreateRoomConfig.FilterMapIdByRoomType ugc room Type")
      return false
    end
  end
  if not curRoomType or not roomTypeConfig then
    return true
  end
  log(bWriteLog and "[YY]FilterMapIdByRoomType==" .. tostring(curRoomType))
  if curRoomType ~= C_RoomTypeMap.Ordinary and curRoomType ~= C_RoomTypeMap.Advance and curRoomType ~= C_RoomTypeMap.Match and curRoomType ~= C_RoomTypeMap.TMode and curRoomType ~= CreateRoomConfig.C_RoomTypeMap.TMatch then
    return true
  end
  if roomTypeConfig[curRoomType] then
    return true
  end
  return false
end
function CreateRoomConfig.InitParamList(roomType)
  roomType = roomType or C_RoomTypeMap.Advance
  if CreateRoomConfig.basicParamList and CreateRoomConfig.basicParamList[roomType] and next(CreateRoomConfig.basicParamList[roomType]) then
    return
  end
  local paramList = {}
  local CustomRoomParameter = CDataTable.GetTableByFilter("CustomRoomParameter", "RoomType", roomType)
  for k, v in pairs(CustomRoomParameter) do
    if not paramList[v.CustomNumber] then
      paramList[v.CustomNumber] = {}
    end
    table.insert(paramList[v.CustomNumber], v)
  end
  table.sort(paramList, function(a, b)
    return a.Sort < b.Sort
  end)
  if not CreateRoomConfig.basicParamList then
    CreateRoomConfig.basicParamList = {}
  end
  CreateRoomConfig.basicParamList[roomType] = paramList
  if not CreateRoomConfig.paramList then
    CreateRoomConfig.paramList = {}
  end
  if not CreateRoomConfig.paramList[roomType] then
    CreateRoomConfig.paramList[roomType] = {}
  end
  CreateRoomConfig.privilegeParamList = {}
end
function CreateRoomConfig.GetBasicParamList()
  local id = 1001
  if not CreateRoomConfig.basicParamList then
    return nil
  end
  if not CreateRoomConfig.basicParamList[C_RoomTypeMap.Ordinary] then
    return nil
  end
  return CreateRoomConfig.basicParamList[C_RoomTypeMap.Ordinary][id]
end
function CreateRoomConfig.GetParamList(tp, privilegeList, id)
  if privilegeList and next(privilegeList) then
    return CreateRoomConfig.GetPrivilegeParamListByID(tp, privilegeList, id)
  end
  return CreateRoomConfig.GetParamListByID(tp, id)
end
local _NewTitleParamInfo = function(tagID)
  local tabConfig = CDataTable.GetTableData("RoomParamTitleConfig", tagID)
  local info = {
    ParamType = C_ParamWidgetType.Title,
    ParamName = tabConfig and CDataTable.GetTableData("RoomParamTitleConfig", tagID).TagName or "",
    TagID = tagID
  }
  return info
end
function CreateRoomConfig.GetParamListByID(tp, id)
  if not id or id <= 0 then
    if tp == C_RoomTypeMap.Match then
      id = 10002
    elseif tp == C_RoomTypeMap.TMode or tp == C_RoomTypeMap.TMatch then
      id = 2001
    else
      id = 1001
    end
  end
  if not CreateRoomConfig.basicParamList then
    return nil
  end
  if not CreateRoomConfig.basicParamList[tp] or not CreateRoomConfig.basicParamList[tp][id] then
    return nil
  end
  if not CreateRoomConfig.paramList[tp] then
    CreateRoomConfig.paramList[tp] = {}
  end
  if not CreateRoomConfig.paramList[tp][id] then
    local list = {}
    local tagID = -1
    for i, v in ipairs(CreateRoomConfig.basicParamList[tp][id]) do
      if v.SpecialShow == "" then
        if tagID ~= v.TagID then
          tagID = v.TagID
          table.insert(list, {
            [1] = _NewTitleParamInfo(v.TagID)
          })
        end
        table.insert(list, {
          [1] = v
        })
      end
    end
    CreateRoomConfig.paramList[tp][id] = list
  end
  return CreateRoomConfig.paramList[tp][id]
end
function CreateRoomConfig.FormatWeatherItemByMapid(mapid)
  local mapCfg = CDataTable.GetTableData("Map", mapid)
  if not mapCfg then
    return nil
  elseif not mapCfg.WeatherIds or mapCfg.WeatherIds == "" then
    return nil
  end
  local weights = load("return " .. mapCfg.WeatherWeights)()
  local levels = load("return " .. mapCfg.WeatherLevels)()
  local filteredLevels = {}
  for k, v in ipairs(weights or {}) do
    if tonumber(v) and tonumber(v) > 0 then
      table.insert(filteredLevels, levels[k])
    end
  end
  if not next(filteredLevels) then
    return nil
  end
  local TableUtil = require("common.table_util")
  local itemParam = {}
  itemParam.ID = -1
  itemParam.CustomNumber = 0
  itemParam.RoomType = "All"
  itemParam.TagID = 6
  itemParam.Sort = 0
  itemParam.ParamName = LocUtil.LocalizeResFormat(8205403)
  itemParam.ParamKey = "Weather"
  itemParam.ParamType = C_ParamWidgetType.Weather
  itemParam.ValueListStr = TableUtil.TableToString(filteredLevels)
  itemParam.DefaultValue = filteredLevels[1]
  itemParam.CanEdit = "TRUE"
  itemParam.SpecialShow = ""
  return itemParam
end
local IsMatchPrivilege = function(privilege, privilegeList)
  if not privilegeList or not next(privilegeList) then
    return false
  end
  for i, v in ipairs(privilegeList) do
    if v == privilege then
      return true
    end
  end
  return false
end
function CreateRoomConfig.GetPrivilegeParamListByID(tp, privilegeList, id)
  if not id or id <= 0 then
    id = 10002
  end
  if not (CreateRoomConfig.basicParamList and CreateRoomConfig.basicParamList[tp]) or not CreateRoomConfig.basicParamList[tp][id] then
    return nil
  end
  local roomKey = tp .. "-" .. table.concat(privilegeList, "-")
  if not CreateRoomConfig.privilegeParamList[roomKey] then
    CreateRoomConfig.privilegeParamList[roomKey] = {}
  end
  if not CreateRoomConfig.privilegeParamList[roomKey][id] then
    local list = {}
    local tagID = -1
    for i, v in ipairs(CreateRoomConfig.basicParamList[tp][id]) do
      if v.SpecialShow == "" or IsMatchPrivilege(v.SpecialShow, privilegeList) then
        if tagID ~= v.TagID then
          tagID = v.TagID
          table.insert(list, {
            [1] = _NewTitleParamInfo(v.TagID)
          })
        end
        table.insert(list, {
          [1] = v
        })
      end
    end
    CreateRoomConfig.privilegeParamList[roomKey][id] = list
  end
  return CreateRoomConfig.privilegeParamList[roomKey][id]
end
function CreateRoomConfig.IsSignalMode(privilegeList)
  if not privilegeList or not next(privilegeList) then
    return false
  end
  for i, v in ipairs(privilegeList) do
    if v == C_RoomPrivilegeMap.Signal then
      return true
    end
  end
  return false
end
function CreateRoomConfig.GetMapSpeicialConfig(mapID)
  if not mapID then
    return nil
  end
  return C_SPECIAL_MAP[mapID]
end
function CreateRoomConfig.GetRoomCardPanelDescConfig(cardId)
  if not cardId then
    return nil
  end
  return C_RoomCardConfig[cardId]
end
function CreateRoomConfig.GetRoomTypeByCardSubType(subType)
  if not subType then
    return nil
  end
  return C_RoomCardTypeMap[subType]
end
function CreateRoomConfig.GetRoomTypeByCardId(cardId)
  if not cardId then
    return nil
  end
  return C_RoomCardConfig[cardId].Type
end
function CreateRoomConfig.GetRoomCardSubTypeList(roomType)
  if not roomType then
    return nil
  end
  return C_RoomCardSubTypeList[roomType]
end
function CreateRoomConfig.IsCpMode(mapinfo)
  local uCfg = CDataTable.GetTableData("SpecialPackageConfig", mapinfo.ResId)
  if uCfg then
    log_format(bWriteLog and "CreateRoomConfig.IsCpMode. cfg.ID = %s , cfg.PackageName = %s , cfg.ModeViewID = %s", tostring(uCfg.ID), tostring(uCfg.PackageName), tostring(uCfg.ModeViewID))
    CreateRoomConfig.currentModeName = CreateRoomConfig.currentModeName or Client.GetUEPUBGMCPName()
    if uCfg.PackageName == CreateRoomConfig.currentModeName then
      return true
    else
      return false
    end
  else
    log_format(bWriteLog and "CreateRoomConfig.IsCpMode mapinfo.ResId = %s not SpecialPackageConfig", tostring(mapinfo.ResId))
  end
  return true
end
return CreateRoomConfig