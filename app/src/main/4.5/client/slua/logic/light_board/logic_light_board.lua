local logic_light_board = {}
function logic_light_board:ctor()
  self.LightBoardEquipped = nil
  self.LightBoardListHave = nil
  self.LightBoardCount = 0
  self.AllTeamDevoteInfo = nil
  self.HasRedPoint = false
end
function logic_light_board:InitLightBoardInfo(roleData)
  if not roleData or not roleData.light_board_info then
    log(bWriteLog and "logic_light_board:InitLightBoardInfo invalid param")
    return
  end
  self:SetLightBoardEquipped(roleData.light_board_info.equip_info)
  self:SetLightBoardCount(roleData.light_board_info.cur_cnt)
  self:SetHasRedPoint(roleData.light_board_info.has_redpoint)
end
function logic_light_board:GetLightBoardEquipped()
  return self.LightBoardEquipped
end
function logic_light_board:GetLightBoardListHave()
  return self.LightBoardListHave
end
function logic_light_board:HasNew()
  return self.HasRedPoint
end
function logic_light_board:GetLightBoardCount()
  return self.LightBoardCount
end
function logic_light_board:GetLightBoardHave(pk_team_id, season)
  if self.LightBoardListHave == nil or self.LightBoardListHave[season] == nil then
    return nil
  end
  return self.LightBoardListHave[season][pk_team_id]
end
function logic_light_board:SetTeamDevote(teamGift)
  if not teamGift or not next(teamGift) then
    log(bWriteLog and "logic_light_board:SetTeamDevote invalid teamGift")
    return
  end
  log_tree(bWriteLog and "logic_light_board:SetTeamDevote teamGift:", teamGift)
  if self.AllTeamDevoteInfo == nil then
    self.AllTeamDevoteInfo = {}
  end
  for team_id, devote in pairs(teamGift) do
    self.AllTeamDevoteInfo[team_id] = devote
  end
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_UPDATE_TEAM_GIFT_INFO)
end
function logic_light_board:GetTeamDevote(targetUid)
  if not self.AllTeamDevoteInfo then
    log(bWriteLog and "logic_light_board:GetTeamDevote not AllTeamDevoteInfo")
    return 0
  end
  local logic_popular_team_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk)
  local target_pk_team_id = logic_popular_team_pk:GetOtherPKTeamID(targetUid)
  log(bWriteLog and "logic_light_board:GetTeamDevote target_pk_team_id:" .. tostring(target_pk_team_id))
  if target_pk_team_id == 0 then
    return 0
  end
  log_tree(bWriteLog and "logic_light_board:GetTeamDevote AllTeamDevoteInfo:", self.AllTeamDevoteInfo)
  return self.AllTeamDevoteInfo[target_pk_team_id] or 0
end
function logic_light_board:send_psmatch_team_modify_light_board_req(pk_team_id, nick_name)
  local LightBoardHander = require("client.network.Protocol.LightBoardHander")
  LightBoardHander.send_psmatch_team_modify_light_board_req(pk_team_id, nick_name)
end
function logic_light_board:on_psmatch_team_modify_light_board_rsp(nick_name)
  local logic_popular_team_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk)
  logic_popular_team_pk:UpdateMyTeamNickName(nick_name)
  local season = logic_popular_team_pk:GetTeamPkSeasonID()
  local pk_team_id = logic_popular_team_pk:GetPKTeamID()
  self:UpdateLightBoardInfo(nick_name, season, pk_team_id)
  ShowNotice(62252)
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_MODIFY_NICK_NAME_SUCCESS)
end
function logic_light_board:on_psmatch_team_mod_nick_name_ntf(nick_name, season, pk_team_id)
  local logic_popular_team_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk)
  logic_popular_team_pk:UpdateMyTeamNickName(nick_name)
  self:UpdateLightBoardInfo(nick_name, season, pk_team_id)
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_MODIFY_NICK_NAME_SUCCESS)
end
function logic_light_board:UpdateLightBoardInfo(nick_name, season, pk_team_id)
  log(bWriteLog and string.format("[v_wllwu] logic_light_board:UpdateLightBoardInfo, nick_name is: %s, season is: %s, pk_team_id is: %s", tostring(nick_name), tostring(season), tostring(pk_team_id)))
  if not (nick_name and season) or not pk_team_id then
    return
  end
  if self.LightBoardListHave then
    for _, v in pairs(self.LightBoardListHave) do
      for team_id, lightBoardInfo in pairs(v) do
        if team_id == pk_team_id then
          lightBoardInfo.          log(bWriteLog and "[v_wllwu] logic_light_board:UpdateLightBoardInfo update have")
        end
      end
    end
  end
  if self.LightBoardEquipped and self.LightBoardEquipped.team_id == pk_team_id then
    self.LightBoardEquipped.    log(bWriteLog and "[v_wllwu] logic_light_board:UpdateLightBoardInfo update equip")
  end
end
function logic_light_board:send_psmatch_team_equip_light_board_req(pk_team_id, season, is_equip)
  local LightBoardHander = require("client.network.Protocol.LightBoardHander")
  LightBoardHander.send_psmatch_team_equip_light_board_req(pk_team_id, season, is_equip)
end
function logic_light_board:on_psmatch_team_equip_light_board_rsp(pk_team_id, season, is_equip)
  if is_equip == 0 then
    self:UnEquipLightBoard()
  else
    self:EquipLightBoard(pk_team_id, season)
    ShowNotice(301192)
  end
end
function logic_light_board:send_psmatch_team_light_board_list_req()
  local LightBoardHander = require("client.network.Protocol.LightBoardHander")
  LightBoardHander.send_psmatch_team_light_board_list_req()
end
function logic_light_board:on_psmatch_team_light_board_list_rsp(ret_list)
  self.LightBoardListHave = ret_list
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_LIGHT_BOARD_LIST_RSP)
  if ret_list and self.LightBoardEquipped then
    local season = self.LightBoardEquipped.season
    local team_id = self.LightBoardEquipped.team_id
    local TableUtil = require("common.table_util")
    local newData = TableUtil.GetTableValue(ret_list, season, team_id)
    if not newData or newData.nick_name == self.LightBoardEquipped.nick_name then
      log(bWriteLog and "[v_wllwu] logic_light_board:on_psmatch_team_light_board_list_rsp return same nick_name")
      return
    end
    log(bWriteLog and "[v_wllwu] logic_light_board:on_psmatch_team_light_board_list_rsp\239\188\140 refresh new nick_name is:" .. tostring(newData.nick_name))
    self.LightBoardEquipped.nick_name = newData.nick_name
    EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_LIGHT_BOARD_LEVEL_CHANGE)
  end
end
function logic_light_board:send_read_new_light_board_req(pk_team_id, season)
  local LightBoardHander = require("client.network.Protocol.LightBoardHander")
  LightBoardHander.send_read_new_light_board_req(pk_team_id, season)
end
function logic_light_board:on_read_new_light_board_rsp(pk_team_id, season)
  if not self:GetLightBoardHave(pk_team_id, season) then
    return
  end
  self.LightBoardListHave[season][pk_team_id].is_new = false
  self:CalculateRedPoint()
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_READ_NEW_LIGHT_BOARD_RSP, pk_team_id, season)
end
function logic_light_board:on_new_get_light_board_ntf(info_list, is_pop)
  if self.LightBoardListHave == nil then
    self.LightBoardListHave = {}
  end
  for _, info in ipairs(info_list) do
    if self.LightBoardListHave[info.season] == nil then
      self.LightBoardListHave[info.season] = {}
    end
    self.LightBoardCount = self.LightBoardCount + 1
    self.LightBoardListHave[info.season][info.team_id] = info
    if info.is_equip then
      log_tree(bWriteLog and "logic_light_board:on_new_get_light_board_ntf auto equip:", info)
      self.LightBoardEquipped = info
      EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_NEW_LIGHT_BOARD_EQUIP)
    end
  end
  local isInLobby = GameStatus.IsInLobbyOrMainCity()
  if is_pop and isInLobby then
    local arrayItemData = {}
    for _, info in ipairs(info_list) do
      local id = 1000 * info.season + info.level
      log(bWriteLog and "logic_light_board:on_new_get_light_board_ntf id:" .. tostring(id))
      local lightBoardCfg = CDataTable.GetTableData("LightBoardCfg", id)
      if lightBoardCfg and lightBoardCfg.ItemID > 0 then
        table.insert(arrayItemData, {
          res_id = lightBoardCfg.ItemID,
          count = 1
        })
      end
    end
    if next(arrayItemData) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
    end
  end
  self:CalculateRedPoint()
end
function logic_light_board:on_psmatch_team_level_change_ntf(season, pk_team_id, level)
  self:UpdateEquippedLightBoardLevel(season, pk_team_id, level)
end
function logic_light_board:SetLightBoardEquipped(lightBoardEquipped)
  if not lightBoardEquipped then
    log(bWriteLog and "logic_light_board:SetLightBoardEquipped not lightBoardEquipped")
    return
  end
  log_tree(bWriteLog and "logic_light_board:SetLightBoardEquipped lightBoardEquipped:", lightBoardEquipped)
  self.LightBoardEquipped = lightBoardEquipped
end
function logic_light_board:SetLightBoardCount(count)
  log(bWriteLog and "logic_light_board:SetLightBoardCount count:" .. tostring(count))
  self.LightBoardCount = count or 0
end
function logic_light_board:SetHasRedPoint(hasRedPoint)
  log(bWriteLog and "logic_light_board:SetHasRedPoint hasRedPoint:" .. tostring(hasRedPoint))
  self.HasRedPoint = hasRedPoint or false
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_UPDATE_LIGHT_BOARD_RED_POINT)
end
function logic_light_board:EquipLightBoard(pk_team_id, season)
  if not self:GetLightBoardHave(pk_team_id, season) then
    return
  end
  self:UnEquipLightBoard()
  local lightBoardHave = self.LightBoardListHave[season][pk_team_id]
  lightBoardHave.is_equip = true
  self.LightBoardEquipped = {
    season = season,
    team_id = pk_team_id,
    level = lightBoardHave.level,
    expire_ts = lightBoardHave.expire_ts,
    nick_name = lightBoardHave.nick_name
  }
  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_EQUIP_LIGHT_BOARD_RSP, pk_team_id, season)
end
function logic_light_board:UnEquipLightBoard()
  for _, seasonLightBoards in pairs(self.LightBoardListHave) do
    for _, lightBoard in pairs(seasonLightBoards) do
      if lightBoard.is_equip then
        lightBoard.is_equip = false
      end
    end
  end
  if self.LightBoardEquipped then
    EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_UNEQUIP_LIGHT_BOARD_RSP, self.LightBoardEquipped.team_id, self.LightBoardEquipped.season)
  end
  self.LightBoardEquipped = nil
end
function logic_light_board:CalculateRedPoint()
  log(bWriteLog and "logic_light_board:CalculateRedPoint")
  if self.LightBoardListHave == nil then
    log(bWriteLog and "logic_light_board:CalculateRedPoint no LightBoardListHave")
    return
  end
  local hasRedPoint = false
  for _, seasonLightBoards in pairs(self.LightBoardListHave) do
    for _, lightBoard in pairs(seasonLightBoards) do
      if lightBoard.is_new then
        hasRedPoint = true
        break
      end
    end
  end
  if hasRedPoint ~= self.HasRedPoint then
    log(bWriteLog and "logic_light_board:CalculateRedPoint hasRedPoint:" .. tostring(hasRedPoint))
    self:SetHasRedPoint(hasRedPoint)
  end
end
function logic_light_board:UpdateEquippedLightBoardLevel(season, pk_team_id, level)
  if not self.LightBoardEquipped then
    log(bWriteLog and "logic_light_board:UpdateEquippedLightBoardLevel no equipped")
    return
  end
  if self.LightBoardEquipped.season ~= season or self.LightBoardEquipped.team_id ~= pk_team_id then
    log(bWriteLog and "logic_light_board:UpdateEquippedLightBoardLevel not same light board")
    return
  end
  if self.LightBoardEquipped.level == level then
    log(bWriteLog and "logic_light_board:UpdateEquippedLightBoardLevel same level")
    return
  end
  log(bWriteLog and "logic_light_board:UpdateEquippedLightBoardLevel update ok")
  self.LightBoardEquipped.  EventSystem:postEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_LIGHT_BOARD_LEVEL_CHANGE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_light_board = class(CModuleBase, nil, logic_light_board)
return Clogic_light_board