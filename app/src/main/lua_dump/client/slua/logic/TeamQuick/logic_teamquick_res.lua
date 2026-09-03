local logic_teamquick_res = {}
function logic_teamquick_res:ctor()
  self.E_PERKSTYLE_STATUS = {
    USING = 1,
    HAS = 2,
    HAS_NOT = 3
  }
  self.E_PERK_TYPE = {
    NAME_SKIN = 1,
    BG_SKIN = 2,
    BROADCAST_SKIN = 3
  }
  self.C_DEFAULT_NAME_COLOR_ID = 62510001
  self.C_DEFAULT_SKIN_ID = 62520001
  self.C_DEFAULT_BROADCAST_ID = 62530001
  self.C_UnlockHomeCeremonyItemID = 16801000
  self.CREAT_TEAM_INDEX = 0
end
function logic_teamquick_res:DefineAndResetData()
  self.squad_data = nil
  self.name_color_id = nil
  self.bg_skin_id = nil
  self.broadcast_id = nil
  self.owned_name_color_list = nil
  self.owned_bg_skin_list = nil
  self.owned_broadcast_list = nil
  self.flash_squad_perk_styles = nil
  self.flash_squad_name_color = nil
  self.flash_squad_bg_skin = nil
  self.flash_squad_broadcast = nil
  self.flash_squad_perk_params = nil
end
function logic_teamquick_res:OnInitialize()
  self:_ReqPerkStylesConfig()
  self:_ReqFlashSquadPerkParams()
end
function logic_teamquick_res:GetCurNameColorId(squad_id)
  if squad_id and self.name_color_id then
    return self.name_color_id[squad_id]
  end
  return nil
end
function logic_teamquick_res:GetCurBgSkinId(squad_id)
  if squad_id and self.bg_skin_id then
    return self.bg_skin_id[squad_id]
  end
  return nil
end
function logic_teamquick_res:GetCurBroadcastId(squad_id)
  if squad_id and self.broadcast_id then
    return self.broadcast_id[squad_id]
  end
  return nil
end
function logic_teamquick_res:GetDefaultStyle()
  return self.C_DEFAULT_NAME_COLOR_ID, self.C_DEFAULT_SKIN_ID, self.C_DEFAULT_BROADCAST_ID
end
function logic_teamquick_res:GetSquadData(squad_id)
  if squad_id and self.squad_data then
    return self.squad_data[squad_id]
  end
  return nil
end
function logic_teamquick_res:GetSquadStyle(squad_id)
  if not squad_id then
    log("logic_teamquick_res:GetSquadStyle squad_id is nil")
    return self.C_DEFAULT_NAME_COLOR_ID, self.C_DEFAULT_SKIN_ID, self.C_DEFAULT_BROADCAST_ID
  end
  local color = self.name_color_id and self.name_color_id[squad_id] or self.C_DEFAULT_NAME_COLOR_ID
  local bg = self.bg_skin_id and self.bg_skin_id[squad_id] or self.C_DEFAULT_SKIN_ID
  local broadcast = self.broadcast_id and self.broadcast_id[squad_id] or self.C_DEFAULT_BROADCAST_ID
  return color, bg, broadcast
end
function logic_teamquick_res:SetCreateSquadStyle(usingColor, usingBG, usingBroadcast)
  log("logic_teamquick_res:SetCreateSquadStyle" .. tostring(usingColor) .. " " .. tostring(usingBG) .. " " .. tostring(usingBroadcast))
  local squad_id = self.CREAT_TEAM_INDEX
  if usingColor then
    if self.name_color_id == nil then
      self.name_color_id = {}
      self.owned_name_color_list = {}
    end
    self.name_color_id[squad_id] = usingColor
  end
  if usingBG then
    if self.bg_skin_id == nil then
      self.bg_skin_id = {}
      self.owned_bg_skin_list = {}
    end
    self.bg_skin_id[squad_id] = usingBG
  end
  if usingBroadcast then
    if self.broadcast_id == nil then
      self.broadcast_id = {}
      self.owned_broadcast_list = {}
    end
    self.broadcast_id[squad_id] = usingBroadcast
  end
end
function logic_teamquick_res:GetNameColorStatus(squad_id, item_id)
  if self.owned_name_color_list == nil or self.name_color_id == nil then
    return self.E_PERKSTYLE_STATUS.HAS_NOT
  end
  if self.owned_name_color_list[squad_id] and self.owned_name_color_list[squad_id][item_id] == true and item_id == self:GetCurNameColorId(squad_id) then
    return self.E_PERKSTYLE_STATUS.USING
  elseif self.owned_name_color_list[squad_id] and self.owned_name_color_list[squad_id][item_id] == true then
    return self.E_PERKSTYLE_STATUS.HAS
  else
    return self.E_PERKSTYLE_STATUS.HAS_NOT
  end
end
function logic_teamquick_res:GetBGSkinStatus(squad_id, item_id)
  if self.owned_bg_skin_list == nil or self.bg_skin_id == nil then
    return self.E_PERKSTYLE_STATUS.HAS_NOT
  end
  if self.owned_bg_skin_list[squad_id] and self.owned_bg_skin_list[squad_id][item_id] == true and item_id == self:GetCurBgSkinId(squad_id) then
    return self.E_PERKSTYLE_STATUS.USING
  elseif self.owned_bg_skin_list[squad_id] and self.owned_bg_skin_list[squad_id][item_id] == true then
    return self.E_PERKSTYLE_STATUS.HAS
  else
    return self.E_PERKSTYLE_STATUS.HAS_NOT
  end
end
function logic_teamquick_res:GetBroadcastStatus(squad_id, item_id)
  if self.owned_broadcast_list == nil or self.broadcast_id == nil then
    return self.E_PERKSTYLE_STATUS.HAS_NOT
  end
  if self.owned_broadcast_list[squad_id] and self.owned_broadcast_list[squad_id][item_id] == true and item_id == self:GetCurBroadcastId(squad_id) then
    return self.E_PERKSTYLE_STATUS.USING
  elseif self.owned_broadcast_list[squad_id] and self.owned_broadcast_list[squad_id][item_id] == true then
    return self.E_PERKSTYLE_STATUS.HAS
  else
    return self.E_PERKSTYLE_STATUS.HAS_NOT
  end
end
function logic_teamquick_res:GetPerkStylesConfig()
  if not self.flash_squad_perk_styles or not next(self.flash_squad_perk_styles) then
    self:_ReqPerkStylesConfig()
    log(bWriteLog and "logic_teamquick_res:GetPerkStylesConfig self.flash_squad_perk_styles is nil")
    return nil
  end
  return self.flash_squad_perk_styles
end
function logic_teamquick_res:GetFlashSquadPerkParams()
  if not self.flash_squad_perk_params or not next(self.flash_squad_perk_params) then
    self:_ReqFlashSquadPerkParams()
    log(bWriteLog and "logic_teamquick_res:GetPerkStylesConfig self.flash_squad_perk_params is nil")
    return nil
  end
  return self.flash_squad_perk_params
end
function logic_teamquick_res:GetNameColorConfig()
  if self.flash_squad_name_color then
    return self.flash_squad_name_color
  end
  local cfgs = self:GetPerkStylesConfig()
  if cfgs == nil then
    return nil
  end
  self.flash_squad_name_color = {}
  for _, v in pairs(cfgs) do
    if v.perk_type == self.E_PERK_TYPE.NAME_SKIN then
      self.flash_squad_name_color[v.style_id] = v
    end
  end
  return self.flash_squad_name_color
end
function logic_teamquick_res:GetBGSkinConfig()
  if self.flash_squad_bg_skin then
    return self.flash_squad_bg_skin
  end
  local cfgs = self:GetPerkStylesConfig()
  if cfgs == nil then
    return nil
  end
  self.flash_squad_bg_skin = {}
  for _, v in pairs(cfgs) do
    if v.perk_type == self.E_PERK_TYPE.BG_SKIN then
      self.flash_squad_bg_skin[v.style_id] = v
    end
  end
  return self.flash_squad_bg_skin
end
function logic_teamquick_res:GetBroadcastConfig()
  if self.flash_squad_broadcast then
    return self.flash_squad_broadcast
  end
  local cfgs = self:GetPerkStylesConfig()
  if cfgs == nil then
    return nil
  end
  self.flash_squad_broadcast = {}
  for _, v in pairs(cfgs) do
    if v.perk_type == self.E_PERK_TYPE.BROADCAST_SKIN then
      self.flash_squad_broadcast[v.style_id] = v
    end
  end
  return self.flash_squad_broadcast
end
function logic_teamquick_res:IsLeader(squad_id)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local teamSummary = logic_flash_match_team:GetFlashTeamSummaryById(squad_id)
  local is_leader = teamSummary and tonumber(teamSummary.leader_uid) == tonumber(DataMgr.roleData.uid)
  return is_leader
end
function logic_teamquick_res:IsCurSeasonStyle(style_id)
  local rewardData = CDataTable.GetTableDataByFilter("TeamTacitReward", "SeasonID", DataMgr.season_id, "RewardItemID", style_id)
  if rewardData then
    return true
  end
  return false
end
function logic_teamquick_res:_ReqPerkStylesConfig()
  log(bWriteLog and "logic_teamquick_res:_ReqPromotionBaseConfig")
  local callback = function(table_name, table_data)
    log_tree(bWriteLog and "logic_teamquick_res:_ReqPromotionBaseConfig callback table_data: ", table_data)
    self.flash_squad_perk_styles = table_data
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_PERK_STYLES_CONFIG)
  end
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(data_config_marco.flash_squad_perk_styles, callback)
end
function logic_teamquick_res:_ReqFlashSquadPerkParams()
  log(bWriteLog and "logic_teamquick_res:_ReqFlashSquadPerkParams")
  local callback = function(table_name, table_data)
    log_tree(bWriteLog and "logic_teamquick_res:_ReqFlashSquadPerkParams callback table_data: ", table_data)
    self.flash_squad_perk_params = table_data
  end
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(data_config_marco.flash_squad_perk_params, callback)
end
function logic_teamquick_res:NeedTeamSkinTabRedPoint(squad_id, tab_id)
  local is_leader = self:IsLeader(squad_id)
  if not is_leader then
    return nil
  end
  local squad_data = self:GetSquadData(squad_id)
  if squad_data and squad_data.perk_red_dot then
    return squad_data.perk_red_dot[tab_id]
  end
  return nil
end
function logic_teamquick_res:NeedTeamSkinRedPoint(squad_id)
  local is_leader = self:IsLeader(squad_id)
  if not is_leader then
    return nil
  end
  local squad_data = self:GetSquadData(squad_id)
  if squad_data and squad_data.perk_red_dot and next(squad_data.perk_red_dot) then
    return true
  end
  return nil
end
function logic_teamquick_res:NeedTeamSkinItemRedPoint(squad_id, tab_id, style_id)
  local hasTabRedPoint = self:NeedTeamSkinTabRedPoint(squad_id, tab_id)
  local isCurSeasonStyle = self:IsCurSeasonStyle(style_id)
  return hasTabRedPoint and isCurSeasonStyle
end
function logic_teamquick_res:send_get_flash_squad_info_req(squad_id)
  log(bWriteLog and "logic_teamquick_res:send_get_flash_squad_info_req")
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_get_flash_squad_info_req(squad_id)
end
function logic_teamquick_res:on_get_flash_squad_info_rsp(ret, squad_data)
  log(bWriteLog and "logic_teamquick_res:on_get_flash_squad_info_rsp")
  if ret == 0 then
    if self.squad_data == nil then
      self.squad_data = {}
    end
    if self.name_color_id == nil then
      self.name_color_id = {}
    end
    if self.bg_skin_id == nil then
      self.bg_skin_id = {}
    end
    if self.broadcast_id == nil then
      self.broadcast_id = {}
    end
    if self.owned_name_color_list == nil then
      self.owned_name_color_list = {}
    end
    if self.owned_bg_skin_list == nil then
      self.owned_bg_skin_list = {}
    end
    if self.owned_broadcast_list == nil then
      self.owned_broadcast_list = {}
    end
    local squad_id = squad_data.squad_id
    self.squad_data[squad_id] = squad_data
    self.name_color_id[squad_id] = squad_data.name_color_id
    self.bg_skin_id[squad_id] = squad_data.bg_skin_id
    self.broadcast_id[squad_id] = squad_data.broadcast_id
    self.owned_name_color_list[squad_id] = squad_data.owned_styles[self.E_PERK_TYPE.NAME_SKIN] or {}
    self.owned_bg_skin_list[squad_id] = squad_data.owned_styles[self.E_PERK_TYPE.BG_SKIN] or {}
    self.owned_broadcast_list[squad_id] = squad_data.owned_styles[self.E_PERK_TYPE.BROADCAST_SKIN] or {}
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_INFO_RSP, squad_data)
  end
end
function logic_teamquick_res:send_update_flash_squad_setting_req(squad_id, setting)
  log(bWriteLog and "logic_teamquick_res:send_update_flash_squad_setting_req")
  if setting.name_color_id then
    self.name_color_id[squad_id] = setting.name_color_id
  end
  if setting.bg_skin_id then
    self.bg_skin_id[squad_id] = setting.bg_skin_id
  end
  if setting.broadcast_id then
    self.broadcast_id[squad_id] = setting.broadcast_id
  end
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_update_flash_squad_setting_req(squad_id, setting)
end
function logic_teamquick_res:send_clear_squad_perk_red_dot_req(squad_id, perk_types)
  log(bWriteLog and "logic_teamquick_res:send_clear_squad_perk_red_dot_req")
  local squad_data = self:GetSquadData(squad_id)
  if squad_data and squad_data.perk_red_dot then
    for _, v in pairs(perk_types) do
      squad_data.perk_red_dot[v] = nil
    end
  end
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_clear_squad_perk_red_dot_req(squad_id, perk_types)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RES_TAB_RED_DOT)
end
function logic_teamquick_res:on_claim_rapport_reward_rsp(ret, squad_id, reward_items)
  log(bWriteLog and "logic_teamquick_res:on_claim_rapport_reward_rsp")
  log_tree(bWriteLog and "logic_teamquick_res:on_claim_rapport_reward_rsp reward_items: ", reward_items)
  if not reward_items or not next(reward_items) then
    return
  end
  local TEAM_UP_BONUS_CARD_ID = 2189104
  local perkParams = self:GetFlashSquadPerkParams()
  local converted_item_id = perkParams and perkParams.TeamUpBonusCard_CapConvertItemID and perkParams.TeamUpBonusCard_CapConvertItemID.value or 0
  local subTypeToTabIndex = {
    [ENUM_ITEM_SUBTYPE.TeamQuick_Name_Skin] = 1,
    [ENUM_ITEM_SUBTYPE.TeamQuick_BG_Skin] = 2,
    [ENUM_ITEM_SUBTYPE.TeamQuick_Broadcast] = 3
  }
  local awardList = {}
  local bHasTeamUpCard = false
  local bHasConverted = false
  local convertedItemData, jumpTabIndex
  local hasUnlockHomeCeremony = false
  for i, reward in pairs(reward_items) do
    awardList[i] = {
      res_id = reward.item_id,
      count = reward.count
    }
    local item_data = CDataTable.GetTableData("Item", reward.item_id)
    if reward.item_id == TEAM_UP_BONUS_CARD_ID then
      bHasTeamUpCard = true
    elseif reward.item_id == converted_item_id then
      bHasConverted = true
      convertedItemData = item_data
    elseif reward.item_id == self.C_UnlockHomeCeremonyItemID then
      hasUnlockHomeCeremony = true
    end
    if item_data and subTypeToTabIndex[item_data.ItemSubType] then
      jumpTabIndex = subTypeToTabIndex[item_data.ItemSubType]
    end
  end
  local tExtendData = {}
  if bHasConverted then
    if convertedItemData then
      tExtendData.sBottomTipStr = LocUtil.LocalizeResFormat(85424, convertedItemData.ItemName)
    end
  elseif bHasTeamUpCard then
    local cap = perkParams and perkParams.TeamUpBonusCard_SeasonPersonalCap and perkParams.TeamUpBonusCard_SeasonPersonalCap.value or 0
    tExtendData.sBottomTipStr = LocUtil.LocalizeResFormat(85423, cap)
  end
  if jumpTabIndex then
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    local teamSummary = logic_flash_match_team:GetFlashTeamSummaryById(squad_id)
    local bIsLeader = teamSummary and tonumber(teamSummary.leader_uid) == tonumber(DataMgr.roleData.uid)
    if bIsLeader then
      tExtendData.sBottomTipStr = LocUtil.GetLocalizeResStr(85431)
      local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
      local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
      tExtendData.tAllBtnShowData = {
        CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
        CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(85425), CommonItemGet_Const.Enum_BtnStyle.Orange, function()
          UIManager.ShowUI(UIManager.UI_Config.TeamQuick_TeamSkin_UIBP, squad_id, jumpTabIndex)
        end)
      }
    else
      tExtendData.sBottomTipStr = LocUtil.GetLocalizeResStr(85432)
    end
  end
  if hasUnlockHomeCeremony then
    function tExtendData.fCloseCallback()
      UIManager.ShowUI(UIManager.UI_Config.TeamQuick_RewardDetails_Popup)
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(awardList, nil, nil, tExtendData)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_teamquick_res = class(CModuleBase, nil, logic_teamquick_res)
return Clogic_teamquick_res