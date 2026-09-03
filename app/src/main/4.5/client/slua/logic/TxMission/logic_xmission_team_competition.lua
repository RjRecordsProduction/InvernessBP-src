local logic_xmission_team_competition = {}
local xmission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
function logic_xmission_team_competition:DefineAndResetData()
  self.vsSlots = {}
  self.needAutoShow = true
end
function logic_xmission_team_competition:RegistEvents()
end
function logic_xmission_team_competition:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    self:SetNeedAutoShow(true)
  end
  if nextState == GameStatus.Lobby then
    self:AddTimerOnce(10, function()
      local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
      local data_config_marco = require("client.logic.data.data_config_marco")
      BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_free_type_consumables_table, function(_, config)
        log_tree(bWriteLog and "logic_xmission_team_competition:OnPostSwitchGameStatus vs_metro_free_type_consumables_table", config)
      end)
      BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_ban_consumables_table, function(_, config)
        log_tree(bWriteLog and "logic_xmission_team_competition:OnPostSwitchGameStatus vs_metro_ban_consumables_table", config)
      end)
      BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_free_consumables_table, function(_, config)
        log_tree(bWriteLog and "logic_xmission_team_competition:OnPostSwitchGameStatus vs_metro_free_consumables_table", config)
      end)
    end)
  end
end
function logic_xmission_team_competition:GetSkinIDByWeaponID(weapon_id)
  log(bWriteLog and string.format("logic_xmission_team_competition:GetSkinIDByWeaponID, weapon_id:%s", weapon_id))
  local multiWeaponCfg = CDataTable.GetTableData("UpWeaponTable", weapon_id)
  if not multiWeaponCfg then
    log(bWriteLog and "logic_xmission_team_competition:GetSkinIDByWeaponID return of not multiWeaponCfg")
    return nil
  end
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local skinInsID = logic_wardrobe_gun:GetSkinIdByWeaponID(multiWeaponCfg.OriginWeaponID)
  if not skinInsID then
    log(bWriteLog and "logic_xmission_team_competition:GetSkinIDByWeaponID return of not skinInsID")
    return nil
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local data = wardrobe_data:GetValidHallDepotItemDataByInsID(skinInsID)
  if not data then
    log(bWriteLog and "logic_xmission_team_competition:GetSkinIDByWeaponID return of not data")
    return nil
  end
  return data.resID
end
function logic_xmission_team_competition:IsShowGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionTeamCompetitionGuide) or {}
  if cfg and cfg[DataMgr.roleData.uid] and cfg[DataMgr.roleData.uid].isShowGuide then
    return false
  else
    return true
  end
end
function logic_xmission_team_competition:GetConsumablesWhiteList(modeType)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  if modeType == xmission_macro.ENUM_MODE_TYPE.VS_STANDARD then
    return BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_restricted_consumables_table)
  else
    return BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_free_consumables_table)
  end
  return nil
end
function logic_xmission_team_competition:PreCheckAutoShow(action)
  if self:GetNeedAutoShow() then
    self:OpenVSPrepareUI(action)
    return true
  end
  return false
end
function logic_xmission_team_competition:CheckIllegalTipShow()
  local modeType = self:GetModeType()
  if modeType ~= xmission_macro.ENUM_MODE_TYPE.VS_FREE then
    return
  end
  local ShowMsgBox = function()
    local msg = LocUtil.GetLocalizeResStr(75967)
    local btnOK = LocUtil.GetLocalizeResStr(75969)
    local btnCancel = LocUtil.GetLocalizeResStr(75968)
    local okCallback = function()
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_uninstall_unbag_items_req()
    end
    local cancelCallback = function()
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_MEMBER_DETAIL)
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_HIDE_MATCH_TIPS)
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_QUIT_LOBBY)
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      LogicTxMissionMain.ShowWardrobeMain("talent")
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.ShowTPlan(CommonMsgBoxMgr.SHOW_TYPE_FOUR, nil, msg, okCallback, cancelCallback, btnOK, btnCancel)
  end
  local xmission_prepare_data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local bagItemList = xmission_prepare_data.GetBagList()
  for i, v in ipairs(bagItemList) do
    if self:CheckIllegalItem(v.item_id, v.item_num) then
      ShowMsgBox()
      return true
    end
  end
  local safeBagItemList = xmission_prepare_data.GetSafeBagList()
  for i, v in ipairs(safeBagItemList) do
    if self:CheckIllegalItem(v.item_id, v.item_num) then
      ShowMsgBox()
      return true
    end
  end
  return false
end
function logic_xmission_team_competition:CheckIllegalItem(itemID, count)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local blackItemIDMap = BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_ban_consumables_table)
  if blackItemIDMap and blackItemIDMap[itemID] then
    return true
  end
  local itemCfg = CDataTable.GetTableData("TxMissionItem", itemID)
  if not itemCfg then
    return false
  end
  local bIsIllegal = true
  local whiteItemTypeMap = BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_free_type_consumables_table)
  if whiteItemTypeMap and whiteItemTypeMap[itemCfg.ItemType] and whiteItemTypeMap[itemCfg.ItemType][itemCfg.ItemSubType] ~= nil then
    bIsIllegal = false
  end
  local whiteItemMap = BasicDataServerTable:GetOrReqData(data_config_marco.vs_metro_free_consumables_table)
  if whiteItemMap and whiteItemMap[itemID] and count <= whiteItemMap[itemID] then
    bIsIllegal = false
  end
  return bIsIllegal
end
function logic_xmission_team_competition:GetNeedAutoShow()
  if not self:IsTeamCompetitionType() then
    return false
  end
  return self.needAutoShow
end
function logic_xmission_team_competition:SetNeedAutoShow(bShow)
  self.needAutoShow = bShow
end
function logic_xmission_team_competition:OpenVSPrepareUI(action)
  UIManager.ShowUI(UIManager.UI_Config.Xmission_Popup_TeamCompetition_UIBP, action)
end
function logic_xmission_team_competition:IsTeamCompetitionType()
  local logic_xmission_match = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local selModeID = logic_xmission_match.GetSelModel()
  local MapModeInfo = CDataTable.GetTableData("TxMissionMapMode", selModeID)
  if not MapModeInfo then
    return
  end
  return MapModeInfo.MapID == xmission_macro.TeamCompetitionMapID
end
function logic_xmission_team_competition:GetModeType()
  local logic_xmission_match = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local selModeID = logic_xmission_match.GetSelModel()
  local MapModeInfo = CDataTable.GetTableData("TxMissionMapMode", selModeID)
  if not MapModeInfo then
    return
  end
  return MapModeInfo.ModeType
end
function logic_xmission_team_competition:GetVSSlots()
  return self.vsSlots
end
function logic_xmission_team_competition:GetBagItemListBySubType(itemSubType)
  local itemList = {}
  local bagItemList = self.vsBag and self.vsBag.items
  if not bagItemList then
    return itemList
  end
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  if bagItemList and next(bagItemList) then
    for _, v in pairs(bagItemList) do
      if v.item_id and v.item_num > 0 then
        local itemCfg = xmission_wardrobe_data.FastGetItemData(v.item_id)
        if itemCfg and itemCfg.ItemSubType == itemSubType then
          table.insert(itemList, v)
        end
      end
    end
  end
  table.sort(itemList, function(itemInfoA, itemInfoB)
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemCfgA = CDataTable.GetTableData("Item", itemInfoA.item_id)
    local itemCfgB = CDataTable.GetTableData("Item", itemInfoB.item_id)
    if not itemCfgA or not itemCfgB then
      return false
    end
    if itemCfgA.ItemQuality ~= itemCfgB.ItemQuality then
      return itemCfgA.ItemQuality > itemCfgB.ItemQuality
    end
  end)
  return itemList
end
function logic_xmission_team_competition:CheckFreeModeFilter(itemList)
  local whiteList = self:GetConsumablesWhiteList(xmission_macro.ENUM_MODE_TYPE.VS_FREE)
  if not whiteList then
    return itemList
  end
  local filterList = {}
  for i, v in ipairs(itemList) do
    local num = whiteList[v.item_id]
    if num then
      v.item_      table.insert(filterList, v)
    end
  end
  return filterList
end
function logic_xmission_team_competition:send_get_metro_vs_slots_req(selModeID)
  if not self:IsTeamCompetitionType() then
    log(bWriteLog and "logic_xmission_team_competition:send_get_metro_vs_slots_req return of not vs type")
    return
  end
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_get_metro_vs_slots_req(selModeID)
end
function logic_xmission_team_competition:on_get_metro_vs_slots_rsp(metro_vs_slots, metro_vs_bag)
  self.vsSlots = metro_vs_slots
  self.vsBag = metro_vs_bag
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_VS_PLAN_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_xmission_team_competition = class(CModuleBase, nil, logic_xmission_team_competition)
return Clogic_xmission_team_competition