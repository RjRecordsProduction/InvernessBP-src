local peakgame_combat_ui = {}
function peakgame_combat_ui:RefreshRaderInfo(ui)
  log(bWriteLog and "peakgame_combat_ui:RefreshRaderInfo")
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zone_id = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  local seasonList = logic_peakgame_combat:GetPeakGameBattleSeasonList()
  local season_id = seasonList[RoleInfoMainSystem.GetRoleinfoSeasonListID()].season_id
  local peakgame_info = logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
  peakgame_combat_ui:RefershCombatRadarDescInfo(ui, peakgame_info)
  peakgame_combat_ui:RefershRadarChartImage(ui, peakgame_info)
end
function peakgame_combat_ui:RefershCombatRadarDescInfo(ui, peakgame_info)
  log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo")
  local root = ui.UIRoot
  local isShowCompare = ui.isShowCompare
  if peakgame_info and next(peakgame_info) then
    root.TextBlock_RadarSurvive:SetText(peakgame_info.survive_score)
    root.TextBlock_RadarTop1:SetText(peakgame_info.top1_score)
    root.TextBlock_RadarRating:SetText(peakgame_info.rating_score)
    root.TextBlock_RadarAssist:SetText(peakgame_info.assist_score)
    root.TextBlock_RadarFight:SetText(peakgame_info.fight_score)
    local strScore = LocUtil.LocalizeResFormat(7490, peakgame_info.sum_score)
    root.TextBlock_GradeScore:SetText(strScore)
    log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo peakgame_info.grade" .. tostring(peakgame_info.grade))
    local RoleInfoCombatSystem = require("client.slua.logic.lobby.Left.logic_roleinfo_combat")
    local grade = ConvertGrade(peakgame_info.grade)
    local imgPath = RoleInfoCombatSystem.GetGradeImgPathByIndex(grade)
    ui:SetTexture(root.Image_Score, imgPath, {sync = false})
  end
  local strHelp = LocUtil.GetLocalizeResStr(105013)
  root.TextBlock_RadarName4:SetText(strHelp)
  root.TextBlock_RadarName2:SetText(LocUtil.GetLocalizeResStr(636))
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if not (not RoleInfoMainSystem.IsShowSelf() and peakgame_info) or not isShowCompare then
    ui:SetWidgetVisible(root.TextBlock_Dsurvive, false, false)
    ui:SetWidgetVisible(root.TextBlock_Dtop1, false, false)
    ui:SetWidgetVisible(root.TextBlock_Drating, false, false)
    ui:SetWidgetVisible(root.TextBlock_Dassit, false, false)
    ui:SetWidgetVisible(root.TextBlock_Dfight, false, false)
    return
  end
  ui:SetWidgetVisible(root.TextBlock_Dsurvive, true, false)
  ui:SetWidgetVisible(root.TextBlock_Dtop1, true, false)
  ui:SetWidgetVisible(root.TextBlock_Drating, true, false)
  ui:SetWidgetVisible(root.TextBlock_Dassit, true, false)
  ui:SetWidgetVisible(root.TextBlock_Dfight, true, false)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  local my_peakgame_info = logic_peakgame_combat:GetMyPeakGameInfo()
  if my_peakgame_info and next(my_peakgame_info) then
    local survive_score = tonumber(my_peakgame_info.survive_score) - tonumber(peakgame_info.survive_score)
    log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo survive_score = " .. tostring(survive_score))
    local top1_score = tonumber(my_peakgame_info.top1_score) - tonumber(peakgame_info.top1_score)
    log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo top1_score = " .. tostring(top1_score))
    local rating_score = tonumber(my_peakgame_info.rating_score) - tonumber(peakgame_info.rating_score)
    log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo rating_score = " .. tostring(rating_score))
    local assist_score = tonumber(my_peakgame_info.assist_score) - tonumber(peakgame_info.assist_score)
    log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo assist_score = " .. tostring(assist_score))
    local fight_score = tonumber(my_peakgame_info.fight_score) - tonumber(peakgame_info.fight_score)
    log(bWriteLog and "peakgame_combat_ui:RefershCombatRadarDescInfo fight_score = " .. tostring(fight_score))
    peakgame_combat_ui:SetClolorAndText(root.TextBlock_Dsurvive, survive_score)
    peakgame_combat_ui:SetClolorAndText(root.TextBlock_Dtop1, top1_score)
    peakgame_combat_ui:SetClolorAndText(root.TextBlock_Drating, rating_score)
    peakgame_combat_ui:SetClolorAndText(root.TextBlock_Dassit, assist_score)
    peakgame_combat_ui:SetClolorAndText(root.TextBlock_Dfight, fight_score)
  end
end
function peakgame_combat_ui:RefershRadarChartImage(ui, peakgame_info)
  log(bWriteLog and "peakgame_combat_ui:RefershRadarChartImage")
  local root = ui.UIRoot
  local isShowCompare = ui.isShowCompare
  if peakgame_info and next(peakgame_info) then
    peakgame_combat_ui:ShowRadarChart(ui, root.RadarChart, peakgame_info)
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if RoleInfoMainSystem.IsShowSelf() or not isShowCompare then
    ui:SetWidgetVisible(root.MyRadarChart, false, false)
    return
  end
  ui:SetWidgetVisible(root.MyRadarChart, true, false)
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  local my_peakgame_info = logic_peakgame_combat:GetMyPeakGameInfo()
  if my_peakgame_info and next(my_peakgame_info) then
    peakgame_combat_ui:ShowRadarChart(ui, root.MyRadarChart, my_peakgame_info)
  end
end
function peakgame_combat_ui:ShowRadarChart(ui, RadarChart, radarInfo)
  log(bWriteLog and "peakgame_combat_ui:ShowRadarChart")
  local root = ui.UIRoot
  ui:SetWidgetVisible(RadarChart, true, false)
  RadarChart.CenterPointImg = root.Image_MidPoint
  RadarChart.VertexFarPointImg:Clear()
  for i = 1, 5 do
    RadarChart.VertexFarPointImg:Add(root["Image_Point" .. i])
  end
  RadarChart.VertexScale:Clear()
  RadarChart.VertexScale:Add(tonumber(radarInfo.top1_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.rating_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.assist_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.survive_score) / 100)
  RadarChart.VertexScale:Add(tonumber(radarInfo.fight_score) / 100)
  local timer_tick = require("common.time_ticker")
  timer_tick.AddTimerOnce(0, function()
    RadarChart:FreshChartDataToContent()
  end)
end
function peakgame_combat_ui:SetClolorAndText(widget, value)
  value = tonumber(string.format("%.1f", value))
  log(bWriteLog and "peakgame_combat_ui:SetClolorAndText value = " .. tostring(value))
  if value < 0 then
    widget:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0, 0, 1)))
    local text = tostring(value)
    widget:SetText(text)
  elseif 0 < value then
    widget:SetColorAndOpacity(FSlateColor(FLinearColor(0, 1, 0, 1)))
    local text = "+" .. tostring(value)
    widget:SetText(text)
  else
    value = math.abs(value)
    widget:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    local text = "+" .. tostring(value)
    widget:SetText(text)
  end
end
return peakgame_combat_ui