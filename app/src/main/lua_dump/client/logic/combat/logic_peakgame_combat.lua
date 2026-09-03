local logic_peakgame_combat = {}
function logic_peakgame_combat:DefineAndResetData()
  self.cur_player_peakgame_info = {}
  self.history_peakgame_info = {}
  self.my_peakgame_info = {}
end
function logic_peakgame_combat:OnInitialize()
end
function logic_peakgame_combat:RegistEvents()
end
function logic_peakgame_combat:OnLogin(bReLogin)
end
function logic_peakgame_combat:OnLogOut()
end
function logic_peakgame_combat:OnPreSwitchGameStatus(preState, nextState)
  self:DefineAndResetData()
end
function logic_peakgame_combat:OnPostSwitchGameStatus(preState, nextState)
end
function logic_peakgame_combat:ClearData()
  log(bWriteLog and "logic_peakgame_combat:ClearData")
  self:DefineAndResetData()
end
function logic_peakgame_combat:GetPeakGameBattleSeasonList()
  log(bWriteLog and "logic_peakgame_combat:GetPeakGameBattleSeasonList")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local minPeakGameSeasonId = PeakGameConfig.MinPeakGameSeasonId
  local season_id = DataMgr.season_id
  local seasonList = {}
  if minPeakGameSeasonId <= season_id then
    for index = season_id, minPeakGameSeasonId, -1 do
      if season_id == index then
        local curname = LocUtil.GetLocalizeResStr(105010)
        table.insert(seasonList, {text = curname, season_id = index})
      else
        local seasondata = CDataTable.GetTableData("SeasonInfo", index)
        if seasondata then
          table.insert(seasonList, {
            text = seasondata.SeasonName,
            season_id = index
          })
        end
      end
    end
  end
  log_tree("logic_peakgame_combat:GetPeakGameBattleSeasonList seasonList = ", seasonList)
  return seasonList
end
function logic_peakgame_combat:GetPeakGameInfo(season_id, zone_id)
  log(bWriteLog and "logic_peakgame_combat:GetPeakGameInfo season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  if not season_id or not zone_id then
    return
  end
  local peakgame_info
  local cur_season_id = DataMgr.season_id
  if season_id == cur_season_id then
    peakgame_info = self:GetCurPeakGameInfo(zone_id)
  else
    peakgame_info = self:GetHistroyPeakGameInfo(season_id, zone_id)
  end
  log_tree("logic_peakgame_combat:GetPeakGameInfo peakgame_info = ", peakgame_info)
  if peakgame_info ~= nil then
    local new_peakgame_info = self:FillDefaultValue(peakgame_info.squad or {})
    return new_peakgame_info
  end
  return nil
end
function logic_peakgame_combat:GetMyPeakGameInfo()
  log(bWriteLog and "logic_peakgame_combat:GetMyPeakGameInfo")
  if self.my_peakgame_info ~= nil then
    local new_peakgame_info = self:FillDefaultValue(self.my_peakgame_info.squad or {})
    return new_peakgame_info
  end
  return nil
end
function logic_peakgame_combat:FillDefaultValue(peakgame_info)
  log(bWriteLog and "logic_peakgame_combat:FillDefaultValue")
  log_tree("logic_peakgame_combat:FillDefaultValue peakgame_info = ", peakgame_info)
  local new_peakgame_info = {}
  local default_peakgame_combat = require("client.logic.combat.default_peakgame_combat")
  local battle_info = default_peakgame_combat.battle_info
  local battle_info_format = default_peakgame_combat.battle_info_format
  for key, value in pairs(battle_info) do
    if peakgame_info[key] then
      new_peakgame_info[key] = peakgame_info[key]
    else
      new_peakgame_info[key] = value
    end
    if battle_info_format[key] then
      new_peakgame_info[key] = battle_info_format[key](new_peakgame_info[key])
    end
  end
  if new_peakgame_info.game_num and new_peakgame_info.game_num == 0 then
    new_peakgame_info.win_rate = 0
    new_peakgame_info.top10_rate = 0
    new_peakgame_info.avg_assist = 0
  else
    new_peakgame_info.win_rate = new_peakgame_info.win_num / new_peakgame_info.game_num * 100
    new_peakgame_info.top10_rate = new_peakgame_info.top10_count / new_peakgame_info.game_num * 100
    new_peakgame_info.avg_assist = new_peakgame_info.total_assist / new_peakgame_info.game_num
  end
  new_peakgame_info.win_rate = string.format("%.1f%%", new_peakgame_info.win_rate)
  new_peakgame_info.top10_rate = string.format("%.1f%%", new_peakgame_info.top10_rate)
  new_peakgame_info.avg_assist = string.format("%.1f", new_peakgame_info.avg_assist)
  log_tree("logic_peakgame_combat:FillDefaultValue new_peakgame_info = ", new_peakgame_info)
  return new_peakgame_info
end
function logic_peakgame_combat:GetDetailDataList(peakgame_info)
  log(bWriteLog and "logic_peakgame_combat:GetDetailDataList")
  if peakgame_info == nil or not next(peakgame_info) then
    log(bWriteLog and "logic_peakgame_combat:GetDetailDataList peakgame_info is invalid")
    return nil
  end
  local item_data = {}
  local item_data1 = {}
  item_data1.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_01.Players_icon_gerenshuju_sence_01"
  item_data1.text1 = LocUtil.GetLocalizeResStr(618)
  item_data1.text2 = LocUtil.GetLocalizeResStr(619)
  item_data1.text3 = LocUtil.GetLocalizeResStr(620)
  item_data1.data1 = peakgame_info.win_rate
  item_data1.data2 = peakgame_info.top10_rate
  item_data1.data3 = peakgame_info.avg_shot_hit_ratio
  table.insert(item_data, item_data1)
  local item_data2 = {}
  item_data2.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_02.Players_icon_gerenshuju_sence_02"
  item_data2.text1 = LocUtil.GetLocalizeResStr(621)
  item_data2.text2 = LocUtil.GetLocalizeResStr(622)
  item_data2.text3 = LocUtil.GetLocalizeResStr(623)
  item_data2.data1 = peakgame_info.head_shot_ratio
  item_data2.data2 = peakgame_info.head_shot_num
  item_data2.data3 = peakgame_info.avg_hurt
  table.insert(item_data, item_data2)
  local item_data3 = {}
  item_data3.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_04.Players_icon_gerenshuju_sence_04"
  item_data3.text1 = LocUtil.GetLocalizeResStr(624)
  item_data3.text2 = LocUtil.GetLocalizeResStr(625)
  item_data3.text3 = LocUtil.GetLocalizeResStr(626)
  item_data3.data1 = peakgame_info.total_hurt
  item_data3.data2 = peakgame_info.max_kill
  item_data3.data3 = peakgame_info.max_hurt
  table.insert(item_data, item_data3)
  local item_data4 = {}
  item_data4.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_06.Players_icon_gerenshuju_sence_06"
  item_data4.text1 = LocUtil.GetLocalizeResStr(43699)
  item_data4.text2 = LocUtil.GetLocalizeResStr(43700)
  item_data4.text3 = LocUtil.GetLocalizeResStr(632)
  item_data4.data1 = peakgame_info.total_assist
  item_data4.data2 = peakgame_info.avg_assist
  item_data4.data3 = peakgame_info.max_move
  table.insert(item_data, item_data4)
  local item_data5 = {}
  item_data5.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_05.Players_icon_gerenshuju_sence_05"
  item_data5.text1 = LocUtil.GetLocalizeResStr(627)
  item_data5.text2 = LocUtil.GetLocalizeResStr(628)
  item_data5.text3 = LocUtil.GetLocalizeResStr(629)
  item_data5.data1 = peakgame_info.avg_cure
  item_data5.data2 = LocUtil.LocalizeResFormat(6007, peakgame_info.avg_live_time)
  item_data5.data3 = peakgame_info.avg_move
  table.insert(item_data, item_data5)
  local item_data6 = {}
  item_data6.icon_path = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/Players_icon_gerenshuju_sence_03.Players_icon_gerenshuju_sence_03"
  item_data6.text1 = LocUtil.GetLocalizeResStr(630)
  item_data6.text2 = LocUtil.GetLocalizeResStr(631)
  item_data6.text3 = ""
  item_data6.data1 = peakgame_info.rescue_teammates
  item_data6.data2 = LocUtil.LocalizeResFormat(6007, peakgame_info.max_live_time)
  item_data6.data3 = ""
  table.insert(item_data, item_data6)
  return item_data
end
function logic_peakgame_combat:GetCurPeakGameInfo(zone_id)
  log(bWriteLog and "logic_peakgame_combat:GetCurPeakGameInfo zone_id = " .. tostring(zone_id))
  return self.cur_player_peakgame_info[zone_id]
end
function logic_peakgame_combat:GetHistroyPeakGameInfo(season_id, zone_id)
  log(bWriteLog and "logic_peakgame_combat:GetHistroyPeakGameInfo season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  if self.history_peakgame_info[zone_id] and self.history_peakgame_info[zone_id][season_id] then
    return self.history_peakgame_info[zone_id][season_id]
  end
  return nil
end
function logic_peakgame_combat:SharePeakGameCombatInfo()
  log(bWriteLog and "logic_peakgame_combat:SharePeakGameCombatInfo")
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local segment_id = LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameSegmentId()
  if not segment_id then
    local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
    segment_id = PeakGameConfig.DefaultPeakGameSegment
  end
  local shareCfg = {
    sceneType = 3,
    isOld = true,
    campaign = "roleinfo",
    reasonStr = "peakgame",
    bShowPoseSelect = true,
    share_type = ShareBtnTLogShareTypeDefine.IndividualAchievements,
    peakGameSegmentLevel = segment_id,
    isPeakGame = true
  }
  local logic_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_combat)
  local modeList = logic_combat:GetModeListCfg()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local modeName = modeList[RoleInfoMainSystem.GetCombatMode()].text
  local seasonName
  local seasonListID = RoleInfoMainSystem.GetRoleinfoSeasonListID()
  if seasonListID == 1 then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local seasonData = CDataTable.GetTableData("SeasonInfo", RoleInfoSystem.curseasonid)
    seasonName = seasonData and seasonData.SeasonName or ""
  else
    local logic_rank_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_combat)
    local seasonNameList = logic_rank_combat:GetRankBattleSeasonList()
    if seasonNameList and seasonNameList[seasonListID] then
      seasonName = seasonNameList[seasonListID].text or ""
    else
      seasonName = ""
    end
  end
  local sModeSeasonTitle = LocUtil.LocalizeResFormat(7545, modeName, seasonName)
  log(bWriteLog and "logic_peakgame_combat:SharePeakGameCombatInfo sModeSeasonTitle = " .. tostring(sModeSeasonTitle))
  local Util = require("client.slua_ui_framework.util")
  Util.ShowShare(shareCfg, UIManager.UI_Config.Sharerecord_SingleBureau_UIBP_New, 3, 1, sModeSeasonTitle)
  ShareMgr.ReportClickShare("roleInfo")
end
function logic_peakgame_combat:ReqPeakGameInfo(season_id, zone_id)
  log(bWriteLog and "logic_peakgame_combat:ReqPeakGameInfo season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  if not season_id or not zone_id then
    return
  end
  local cur_season_id = DataMgr.season_id
  if season_id == cur_season_id then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.RequestBattleInfo(zone_id)
  else
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    self:ReqHistorySeasonPeakGameInfo(RoleInfoSystem.CurShowPlayerInfoUid, season_id, zone_id)
  end
end
function logic_peakgame_combat:OnGetPeakGameInfoRsp(zone_id, peakgame_info)
  log(bWriteLog and "logic_peakgame_combat:OnGetPeakGameInfoRsp zone_id = " .. tostring(zone_id))
  log_tree("logic_peakgame_combat:OnGetPeakGameInfoRsp peakgame_info = ", peakgame_info)
  if not zone_id or not peakgame_info then
    return
  end
  self.cur_player_peakgame_info[zone_id] = self.cur_player_peakgame_info[zone_id] or {}
  self.cur_player_peakgame_info[zone_id] = peakgame_info
end
function logic_peakgame_combat:OnGetMyPeakGameInfo(peakgame_info)
  log(bWriteLog and "logic_peakgame_combat:OnGetMyPeakGameInfo")
  self.my_end
function logic_peakgame_combat:ReqHistorySeasonPeakGameInfo(uid, season_id, zone_id)
  log(bWriteLog and "logic_peakgame_combat:ReqHistorySeasonPeakGameInfo uid = " .. tostring(uid) .. " season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_history_season_peakgame_req(tonumber(uid), season_id, zone_id)
end
function logic_peakgame_combat:OnGetHistorySeasonPeakGameInfoRsp(res, season_id, zone_id, peakgame_info)
  log(bWriteLog and "logic_peakgame_combat:OnGetHistorySeasonPeakGameInfoRsp res = " .. tostring(res) .. " season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  log_tree("logic_peakgame_combat:OnGetHistorySeasonPeakGameInfoRsp peakgame_info = ", peakgame_info)
  if zone_id and season_id then
    self.history_peakgame_info[zone_id] = self.history_peakgame_info[zone_id] or {}
    self.history_peakgame_info[zone_id][season_id] = peakgame_info or {}
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_GET_PEAKGAME_HISTORY_SEASON_BATTLE_INFO_SUCCESS)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicPeakGameBattleInfo = class(CModuleBase, nil, logic_peakgame_combat)
return CLogicPeakGameBattleInfo