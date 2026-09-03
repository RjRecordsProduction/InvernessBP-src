local logic_popular_home_pk_util = {}
function logic_popular_home_pk_util.GetPKRoundIdAndConfig()
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local homePKConfig = logic_popular_home_pk:GetActConfig()
  if not homePKConfig then
    log(bWriteLog and "logic_popular_home_pk_util.GetPKRoundId, not homePKConfig")
    return
  end
  if not homePKConfig.round_list then
    log(bWriteLog and "logic_popular_home_pk_util.GetPKRoundId, not homePKConfig.round_list:")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_popular_home_pk_util.GetPKRoundIdAndConfig curTime is:" .. tostring(curTime))
  for id, data in ipairs(homePKConfig.round_list) do
    if curTime >= data.start_matching_ts and curTime <= data.end_segment_ts then
      log(bWriteLog and string.format("logic_popular_home_pk_util.GetPKRoundId, id:%s", id))
      return id, data
    end
  end
  log_tree(bWriteLog and "logic_popular_home_pk_util.GetPKRoundIdAndConfig, homePKConfig.round_list is:", homePKConfig.round_list)
  return nil
end
function logic_popular_home_pk_util.GetPKLevelByScore(score)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local homePKConfig = logic_popular_home_pk:GetActConfig()
  if not homePKConfig then
    log(bWriteLog and "logic_popular_home_pk_util.GetPKLevelByScore, not homePKConfig")
    return
  end
  if not homePKConfig.level_awards_list then
    log(bWriteLog and "logic_popular_home_pk_util.GetPKLevelByScore, not homePKConfig.level_awards_list:")
    return
  end
  local maxLevel = #homePKConfig.level_awards_list
  if score > homePKConfig.level_awards_list[maxLevel].point_up then
    return maxLevel
  end
  for level, data in ipairs(homePKConfig.level_awards_list) do
    if score >= data.point_down and score <= data.point_up then
      log(bWriteLog and string.format("logic_popular_home_pk_util.GetPKLevelByScore, level:%s", level))
      return level
    end
  end
  return 0
end
function logic_popular_home_pk_util.GetPlayerActState(uid)
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  if PopularityHomePKHandler.bGMTest then
    return PopularityHomePKHandler.GMState
  end
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local actData = logic_popular_home_pk:GetActConfig()
  if not actData then
    return PopularHomePKMacros.ENUM_PLAYER_STATE.CLOSE
  end
  local homePKData = logic_popular_home_pk:GetHomePkData(uid)
  if not homePKData then
    log(bWriteLog and "logic_popular_home_pk_util.GetPlayerActState, not homePKData")
    return PopularHomePKMacros.ENUM_PLAYER_STATE.CLOSE
  end
  local enroll_time = homePKData.enroll_time or 0
  if enroll_time == 0 then
    return PopularHomePKMacros.ENUM_PLAYER_STATE.SIGN
  end
  local _, roundCfg = logic_popular_home_pk_util.GetPKRoundIdAndConfig()
  log_tree(bWriteLog and "logic_popular_home_pk_util.GetPlayerActState, roundCfg is:", roundCfg)
  if not roundCfg then
    log(bWriteLog and "logic_popular_home_pk_util.GetPlayerActState, not roundCfg")
    return PopularHomePKMacros.ENUM_PLAYER_STATE.SIGNED
  end
  if enroll_time >= roundCfg.start_matching_ts then
    log(bWriteLog and "logic_popular_home_pk_util.GetPlayerActState enroll_time >= roundCfg.start_matching_ts, enroll_time = " .. tostring(enroll_time) .. ", start_matching_ts = " .. tostring(roundCfg.start_matching_ts))
    return PopularHomePKMacros.ENUM_PLAYER_STATE.SIGNED
  end
  local state = logic_popular_home_pk_util.GetCurrentRoundState(roundCfg)
  log(bWriteLog and "logic_popular_home_pk_util.GetPlayerActState, state is:" .. tostring(state))
  return state
end
function logic_popular_home_pk_util:IsInCurrentRoundPKTime()
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local _, roundCfg = logic_popular_home_pk_util.GetPKRoundIdAndConfig()
  if not roundCfg then
    log(bWriteLog and "logic_popular_home_pk_util.IsInCurrentRoundPKTime, not roundCfg")
    return false
  end
  local state = logic_popular_home_pk_util.GetCurrentRoundState(roundCfg)
  log(bWriteLog and "logic_popular_home_pk_util.IsInCurrentRoundPKTime, state is:" .. tostring(state))
  return state == PopularHomePKMacros.ENUM_PLAYER_STATE.PK
end
function logic_popular_home_pk_util.GetCurrentRoundState(roundCfg)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_popular_home_pk_util.GetCurrentRoundState, curTime is:" .. tostring(curTime))
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  if curTime >= roundCfg.start_matching_ts and curTime <= roundCfg.end_matching_ts then
    return PopularHomePKMacros.ENUM_PLAYER_STATE.MATCH
  end
  if curTime >= roundCfg.start_duel_ts and curTime <= roundCfg.end_duel_ts then
    return PopularHomePKMacros.ENUM_PLAYER_STATE.PK
  end
  return PopularHomePKMacros.ENUM_PLAYER_STATE.RESULT
end
function logic_popular_home_pk_util.GetActState()
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  if PopularityHomePKHandler.bGMTest then
    return PopularityHomePKHandler.GMActTimeState
  end
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local actData = logic_popular_home_pk:GetActConfig()
  if not actData then
    log(bWriteLog and "logic_popular_home_pk_util.GetActState is close")
    return PopularHomePKMacros.ENUM_STATE.CLOSE
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_popular_home_pk_util.GetActState, curTime is:" .. tostring(curTime))
  if curTime >= actData.enroll_start_ts and curTime < actData.enroll_end_ts then
    log(bWriteLog and "logic_popular_home_pk_util.GetActState is sign")
    return PopularHomePKMacros.ENUM_STATE.SIGN
  end
  if curTime >= actData.match_start_ts and curTime < actData.match_end_ts then
    log(bWriteLog and "logic_popular_home_pk_util.GetActState is pk")
    return PopularHomePKMacros.ENUM_STATE.PK
  end
  log(bWriteLog and "logic_popular_home_pk_util.GetActState is other")
  return PopularHomePKMacros.ENUM_STATE.OTHER
end
function logic_popular_home_pk_util.GetNextRoundPkStartTime()
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local actCfg = logic_popular_home_pk:GetActConfig()
  if not actCfg then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.GetServerTimeInSec()
  for id, v in ipairs(actCfg.round_list) do
    if tNow < v.start_duel_ts then
      return id, v.start_duel_ts
    end
  end
  return nil
end
function logic_popular_home_pk_util.GetGMTimeStr(state, roundId)
  log(bWriteLog and "logic_popular_home_pk_util.GetGMTimeStr roundId is:" .. tostring(roundId) .. "; state is " .. tostring(state))
  local homePKConfig = logic_popular_home_pk_util.GetGMPkConfig()
  if not (homePKConfig and homePKConfig.round_list) or not homePKConfig.round_list[roundId] then
    log(bWriteLog and "logic_popular_home_pk_util.GetGMTimeStr return, not round_list ")
    return
  end
  local nTimeStamp
  local roundCfg = homePKConfig.round_list[roundId]
  log_tree(bWriteLog and "logic_popular_home_pk_util.GetGMTimeStr, roundCfg is:", roundCfg)
  if state == 1 then
    nTimeStamp = homePKConfig.enroll_start_ts
  elseif state == 2 then
    nTimeStamp = roundCfg.start_matching_ts
  elseif state == 3 then
    nTimeStamp = roundCfg.start_duel_ts
  elseif state == 4 then
    nTimeStamp = roundCfg.start_segment_ts
  end
  if nTimeStamp ~= nil then
    local TimeUtil = require("client.common.time_util")
    local str = TimeUtil.OSDate("!%Y-%m-%d %H:%M:%S", nTimeStamp)
    log(bWriteLog and "logic_popular_home_pk_util.GetGMTimeStr str is:" .. tostring(str))
    return str
  end
  return nil
end
function logic_popular_home_pk_util.GetGMPkConfig()
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local actTableConfig = logic_popular_home_pk:GetNetActTableConfig()
  if not actTableConfig then
    log(bWriteLog and "logic_popular_home_pk_util.GetGMPkConfig return, not actTableConfig ")
    return
  end
  local homePKConfig
  local version_util = require("client.common.version_util")
  local curVersion = Client.GetAppVersion()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, cfg in pairs(actTableConfig) do
    if cfg.cli_ver_str and version_util.HigherVersion(curVersion, cfg.cli_ver_str) then
      if not homePKConfig then
        homePKConfig = cfg
      elseif curTime < cfg.act_start_ts and homePKConfig.act_start_ts > cfg.act_start_ts then
        homePKConfig = cfg
      end
    end
  end
  return homePKConfig
end
function logic_popular_home_pk_util.GetPkResult(resultData)
  local selfHomeScore = resultData.pk_detail.self_vote_cnt
  local enemyHomeScore = resultData.pk_detail.enemy_vote_cnt
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  if selfHomeScore > enemyHomeScore then
    return PopularHomePKMacros.ENUM_GAME_RESULT.WIN
  elseif selfHomeScore < enemyHomeScore then
    return PopularHomePKMacros.ENUM_GAME_RESULT.LOSS
  else
    return PopularHomePKMacros.ENUM_GAME_RESULT.TIE
  end
end
function logic_popular_home_pk_util.GetCurLevelMaxScore(pkLevel, seasonIndex)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  local actConfig = logic_popular_home_pk:GetNetActTableConfig()
  if not actConfig then
    log(bWriteLog and "logic_popular_home_pk_util.GetCurLevelMaxScore no actConfig ")
    return
  end
  local homePKConfig = actConfig[seasonIndex]
  if not homePKConfig or not homePKConfig.level_awards_list then
    log(bWriteLog and "logic_popular_home_pk_util.GetCurLevelMaxScore no homePKConfig, seasonIndex is " .. tostring(seasonIndex))
    return
  end
  local nextLevel = pkLevel + 1
  local cfg = homePKConfig.level_awards_list[nextLevel]
  if cfg then
    return cfg.point_down
  end
  cfg = homePKConfig.level_awards_list[pkLevel]
  if cfg then
    return cfg.point_up
  end
  log_error(bWriteLog and "logic_popular_home_pk_util.GetCurLevelMaxScore config not find! pkLevel = " .. tostring(pkLevel) .. "; seasonIndex = " .. tostring(seasonIndex))
  return 0
end
function logic_popular_home_pk_util.CheckInValidInterval(lastTime, intervalSecond)
  lastTime = lastTime or 0
  if lastTime <= 0 then
    return false
  end
  intervalSecond = intervalSecond or 1
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.OSTime()
  if intervalSecond < math.abs(nowTime - lastTime) then
    return false
  end
  return true
end
function logic_popular_home_pk_util.GetModelMaxLength(sceneObject)
  local scene_prop = sceneObject:GetSceneProp()
  local minX = scene_prop.size.minX
  local maxX = scene_prop.size.maxX
  local minY = scene_prop.size.minY
  local maxY = scene_prop.size.maxY
  local minPos = sceneObject.gridInfoMap.areaParam:GetGridCenterPosition(minX - 0.5, minY - 0.5, 0)
  local maxPos = sceneObject.gridInfoMap.areaParam:GetGridCenterPosition(maxX + 0.5, maxY + 0.5, scene_prop.tier_height)
  local maxPosWithZeroZ = sceneObject.gridInfoMap.areaParam:GetGridCenterPosition(maxX + 0.5, maxY + 0.5, 0)
  local mediumPos = (maxPosWithZeroZ + minPos) * 0.5
  local maxLength = math.max(maxPos.X - minPos.X, maxPos.Y - minPos.Y, maxPos.Z - minPos.Z)
  return maxLength, mediumPos
end
function logic_popular_home_pk_util.RefreshHomePKLevel(pkLevel, imageWidget, textWidget, bLock)
  log(bWriteLog and "logic_popular_home_pk_util.RefreshHomePKLevel pkLevel = " .. tostring(pkLevel))
  local C_PKLevelColor = {
    [0] = FLinearColor(1, 1, 1, 1),
    [1] = FLinearColor(1, 1, 1, 1),
    [2] = FLinearColor(0.033105, 0.496933, 0.226966, 1),
    [3] = FLinearColor(0.082283, 0.254152, 0.64448, 1),
    [4] = FLinearColor(0.296138, 0.08022, 0.701102, 1),
    [5] = FLinearColor(0.879623, 0.099899, 0.679543, 1),
    [6] = FLinearColor(0.879623, 0.074214, 0.074214, 1)
  }
  local C_PKLevelColorGrey = {
    [0] = FLinearColor(1, 1, 1, 0.5),
    [1] = FLinearColor(1, 1, 1, 0.5),
    [2] = FLinearColor(0.033105, 0.496933, 0.226966, 0.5),
    [3] = FLinearColor(0.082283, 0.254152, 0.64448, 0.5),
    [4] = FLinearColor(0.296138, 0.08022, 0.701102, 0.5),
    [5] = FLinearColor(0.879623, 0.099899, 0.679543, 0.5),
    [6] = FLinearColor(0.879623, 0.074214, 0.074214, 0.5)
  }
  if not pkLevel or pkLevel < 0 then
    log_warning("logic_popular_home_pk_util.RefreshHomePKLevel invalid params")
    pkLevel = 0
  end
  local colorIndex = FuncUtil.Clamp(pkLevel, 0, 6)
  local color = bLock and C_PKLevelColorGrey[colorIndex] or C_PKLevelColor[colorIndex]
  if imageWidget then
    imageWidget:SetColorAndOpacity(color)
  end
  if textWidget then
    local curFontInfo = textWidget.Font
    local outlineSettings = slua.IndexReference(curFontInfo, "OutlineSettings")
    local outlineColorAlpha = bLock and 0.5 or 1
    outlineSettings.OutlineColor = FLinearColor(0, 0, 0, outlineColorAlpha)
    textWidget:SetFont(curFontInfo)
    textWidget:SetColorAndOpacity(FSlateColor(color))
    textWidget:SetText(LocUtil.LocalizeResFormat(46008, pkLevel))
  end
end
function logic_popular_home_pk_util.RefreshHomePKWidget(widget, pkLevel, bLock)
  logic_popular_home_pk_util.RefreshHomePKLevel(pkLevel, widget.Image_PK, widget.TextBlock_Level, bLock)
end
return logic_popular_home_pk_util