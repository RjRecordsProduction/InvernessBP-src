local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
local LogicTxMissionMatch = {
  bWeaponCheck = false,
  bBulletCheck = false,
  bDrugCheck = false,
  bArmorCheck = false,
  bBagWeightCheck = false,
  nRickCheckCount = -1,
  metro_scene_data = {}
}
local C_RickCheckDailyCount = 2
function LogicTxMissionMatch.IsXMissionMode(modeID)
  local TxMissionMapMode = CDataTable.GetTableData("TxMissionMapMode", modeID)
  if TxMissionMapMode then
    return true
  end
  return false
end
function LogicTxMissionMatch.InitData(metro_scene_data)
  LogicTxMissionMatch.metro_scene_data = metro_scene_data or {}
  LogicTxMissionMatch.CheckModeHaveDropRiskReset()
  LogicTxMissionMatch.JustifyModForTeamNum()
  LogicTxMissionMatch.CacheNewbieRestrictionConfig()
end
function LogicTxMissionMatch.CacheNewbieRestrictionConfig()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.newbie_restriction_table, function(_, config)
    log_tree(bWriteLog and "LogicTxMissionMatch.CacheNewbieRestrictionConfig newbie_restriction_table", config)
  end)
  BasicDataServerTable:GetOrReqData(data_config_marco.newbie_restriction_white_list_table, function(_, config)
    log_tree(bWriteLog and "LogicTxMissionMatch.CacheNewbieRestrictionConfig newbie_restriction_white_list_table", config)
  end)
end
function LogicTxMissionMatch.JustifyModForTeamNum()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamNum = TeamUpNewSystem.GetTeamNum()
  if teamNum < 2 then
    log(bWriteLog and "LogicTxMissionMatch.JustifyModForTeamNum single return")
    return
  end
  local modeID = LogicTxMissionMatch.GetSelModel()
  local modeInfo = CDataTable.GetTableData("TxMissionMapMode", modeID)
  if not modeInfo then
    log(bWriteLog and "LogicTxMissionMatch.JustifyModForTeamNum data return")
    return
  end
  local modeTeamInfo = CDataTable.GetTableData("ModeTeamTable", modeID)
  local maxMember = modeTeamInfo.MaxMember or 4
  if teamNum <= maxMember then
    log(bWriteLog and "LogicTxMissionMatch.JustifyModForTeamNum teamSize return")
    return
  end
  local TxMissionMap = CDataTable.GetTable("TxMissionMapMode")
  local newModId = modeID
  local curTeamInfo
  for k, v in pairs(TxMissionMap) do
    if v.MapID == modeInfo.MapID and v.ModeType == modeInfo.ModeType then
      curTeamInfo = CDataTable.GetTableData("ModeTeamTable", v.ModeID)
      if teamNum <= curTeamInfo.MaxMember then
        newModId = v.ModeID
        break
      end
    end
  end
  if newModId == modeID then
    log(bWriteLog and "LogicTxMissionMatch.JustifyModForTeamNum matain return")
    return
  end
  log(bWriteLog and "LogicTxMissionMatch.JustifyModForTeamNum changeMode " .. tostring(newModId))
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_select_confirm_req(newModId, LogicTxMissionMatch.GetAutoMatch())
end
function LogicTxMissionMatch.GetSelModel()
  if LogicTxMissionMatch.metro_scene_data and LogicTxMissionMatch.metro_scene_data.match_params and LogicTxMissionMatch.metro_scene_data.match_params.mode_group and tonumber(LogicTxMissionMatch.metro_scene_data.match_params.mode_group) > 0 then
    return tonumber(LogicTxMissionMatch.metro_scene_data.match_params.mode_group)
  end
  local TxMissionMap = CDataTable.GetTable("TxMissionMapMode")
  for k, v in pairs(TxMissionMap) do
    if v.IsDefault and tonumber(v.IsDefault) == 1 then
      return tonumber(k)
    end
  end
  return 0
end
function LogicTxMissionMatch.SetSelModel(params)
  local pre_mode_group = 0
  local cur_mode_group = 0
  if params and params.mode_group then
    cur_mode_group = params.mode_group
    LogicTxMissionMatch.metro_scene_data = LogicTxMissionMatch.metro_scene_data or {}
    if LogicTxMissionMatch.metro_scene_data.match_params and LogicTxMissionMatch.metro_scene_data.match_params.mode_group then
      pre_mode_group = LogicTxMissionMatch.metro_scene_data.match_params.mode_group
    end
    LogicTxMissionMatch.oldMatch_params = LogicTxMissionMatch.metro_scene_data.match_params
    LogicTxMissionMatch.metro_scene_data.match_  end
  return pre_mode_group ~= cur_mode_group
end
function LogicTxMissionMatch.GetAutoMatch()
  local selModeID = LogicTxMissionMatch.GetSelModel()
  if LogicTxMissionMatch.IsForceFill(selModeID) then
    return 1
  end
  if LogicTxMissionMatch.metro_scene_data and LogicTxMissionMatch.metro_scene_data.match_params and LogicTxMissionMatch.metro_scene_data.match_params.fill then
    return tonumber(LogicTxMissionMatch.metro_scene_data.match_params.fill)
  end
  return 0
end
function LogicTxMissionMatch.IsForceFill(selModeID)
  local config = CDataTable.GetTableData("TxMissionMapMode", selModeID)
  if config.MapID == xMission_macro.TeamCompetitionMapID then
    return true
  end
  return false
end
function LogicTxMissionMatch.GetMatchTeam(isOld)
  local ModeID = LogicTxMissionMatch.GetSelModel()
  if isOld and LogicTxMissionMatch.oldMatch_params then
    ModeID = LogicTxMissionMatch.oldMatch_params.mode_group
  end
  local modeInfo = CDataTable.GetTableData("ModeTeamTable", ModeID)
  local MaxMember = modeInfo and modeInfo.MaxMember or 4
  return MaxMember
end
function LogicTxMissionMatch.GetMatchStrategy()
  if LogicTxMissionMatch.metro_scene_data and LogicTxMissionMatch.metro_scene_data.match_params and LogicTxMissionMatch.metro_scene_data.match_params.match_strategy then
    return tonumber(LogicTxMissionMatch.metro_scene_data.match_params.match_strategy)
  end
  local MatchStrategyConfig = CDataTable.GetTable("MatchStrategyConfig")
  for i, v in pairs(MatchStrategyConfig) do
    if v.IsDefault == 1 and v.IsOpen == 1 and v.UseScence == 1 then
      return v.ID
    end
  end
  return 0
end
function LogicTxMissionMatch.SetMatchStrategy(value)
  LogicTxMissionMatch.metro_scene_data = LogicTxMissionMatch.metro_scene_data or {}
  LogicTxMissionMatch.metro_scene_data.match_params = LogicTxMissionMatch.metro_scene_data.match_params or {}
  LogicTxMissionMatch.metro_scene_data.match_params.match_strategy = value
end
function LogicTxMissionMatch.StartMatch()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    LobbySystem.change_status_req()
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not TeamUpNewSystem.IsEverybodyReady() then
    if LogicTxMissionMain.IsInXMission(false) and TeamUpNewSystem.IsAnyoneInGuiding() then
      ShowNotice(LocUtil.GetLocalizeResStr(22014))
    else
      local data = LocUtil.GetLocalizeResStr(111013)
      ShowNotice(data)
    end
    return false
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if not MatchSystem.CanMatchInBan(1) then
    return false
  end
  if LogicTxMissionMatch.metro_scene_data and LogicTxMissionMatch.metro_scene_data.match_params and LogicTxMissionMatch.metro_scene_data.match_params.team_type then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.nSelectMatchID = LogicTxMissionMatch.metro_scene_data.match_params.team_type
  end
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_match_req()
  return true
end
function LogicTxMissionMatch.CheckModeIsUnlock(mode_group, showTips)
  local mapModeInfo = CDataTable.GetTableData("TxMissionMapMode", mode_group)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if mapModeInfo then
    if mapModeInfo.Prestige > 0 and LogicTxMissionMain.prestige_level < mapModeInfo.Prestige then
      if showTips then
        ShowNotice(LocUtil.LocalizeResFormat(69568, mapModeInfo.Prestige))
      end
      return false
    end
    if 0 < mapModeInfo.TicketID and 0 < mapModeInfo.TicketNum then
      local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
      local curNum = logic_xmission_warpre.GetItemNumByItemId(mapModeInfo.TicketID, true)
      if curNum < mapModeInfo.TicketNum then
        if showTips then
          local itemCfg = CDataTable.GetTableData("Item", mapModeInfo.TicketID)
          if itemCfg and itemCfg.ItemName then
            ShowNotice(LocUtil.LocalizeResFormat(7055, itemCfg.ItemName))
          end
        end
        return false
      end
    end
  end
  return true
end
function LogicTxMissionMatch.ShowTakeNoBagItemsPopup()
  local strTile = LocUtil.LocalizeResFormat(35188)
  local strOK = LocUtil.LocalizeResFormat(4110)
  local strCancel = LocUtil.LocalizeResFormat(4115)
  local strMsg = LocUtil.LocalizeResFormat(12786)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, function()
    local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
    TxMissionHandler.send_uninstall_unbag_items_req()
  end, nil, strOK, strCancel)
end
function LogicTxMissionMatch.CheckBagMaterial(okCallBack)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local strTile = LocUtil.LocalizeResFormat(35188)
  local strOK = LocUtil.LocalizeResFormat(4110)
  local strCancel = LocUtil.LocalizeResFormat(4115)
  local strMsg = ""
  if LogicTxMissionMatch.CheckTakeNoBagItems() then
    LogicTxMissionMatch.ShowTakeNoBagItemsPopup()
    log(bWriteLog and "LogicTxMissionMatch.CheckBagMaterial return of CheckTakeNoBagItems")
    return
  end
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  local result = LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide()
  if not result then
    if okCallBack then
      okCallBack()
    end
    log(bWriteLog and "LogicTxMissionMatch.CheckBagMaterial return HaveFinishedBeginnerGuide is false")
    return
  end
  local sel_model = LogicTxMissionMatch.GetSelModel()
  local mapModeInfo = CDataTable.GetTableData("TxMissionMapMode", sel_model)
  if mapModeInfo and mapModeInfo.ModeType and mapModeInfo.ModeType == xMission_macro.ENUM_MODE_TYPE.UNDERCOVER then
    if okCallBack then
      okCallBack()
    end
    log(bWriteLog and "LogicTxMissionMatch.CheckBagMaterial return ModeType is UNDERCOVER")
    return
  end
  strOK = DataMgr.GetMsgByID(35187)
  strCancel = DataMgr.GetMsgByID(60039)
  local logic_xmission_team_competition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_team_competition)
  local modeType = logic_xmission_team_competition:GetModeType()
  if modeType == xMission_macro.ENUM_MODE_TYPE.VS_STANDARD then
    if okCallBack then
      okCallBack()
    end
    return
  end
  if LogicTxMissionMatch.CheckNewbieRestriction() then
    log(bWriteLog and "LogicTxMissionMatch.CheckBagMaterial return of CheckNewbieRestriction")
    return
  end
  if not LogicTxMissionMatch.bWeaponCheck then
    local firsWeapon = xMission_Prepare_Data.GetFirstEquipWeapon()
    if not firsWeapon then
      LogicTxMissionMatch.bWeaponCheck = true
      if xmission_wardrobe_data.HaveWeapon() then
        strMsg = LocUtil.LocalizeResFormat(35184)
        CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
          LogicTxMissionMain.HideLobbyUI()
          LogicTxMissionMain.ShowWardrobeMain("material_weapon")
        end, strCancel, strOK)
      else
        strMsg = LocUtil.LocalizeResFormat(60038, LocUtil.GetLocalizeResStr(4661))
        local cancelCallBack = function()
          LogicTxMissionMain.HideLobbyUI()
          local jumpInfo = {Tab1 = 1006}
          local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
          logic_xmission_black_market.GoToBlackMarket(jumpInfo)
        end
        CommonMsgBoxMgr.ShowTPlan(4, strTile, strMsg, okCallBack, cancelCallBack, strCancel, strOK)
      end
      return
    end
  end
  if not LogicTxMissionMatch.bBulletCheck then
    local cfg = CDataTable.GetTableData("TxMissionExtra", "play_need_min_bullet")
    if cfg and cfg.value and tonumber(cfg.value) > 0 then
      local needEnough, weaponID = LogicTxMissionMatch.CheckModeHaveEnoughBullet(tonumber(cfg.value))
      if not needEnough then
        LogicTxMissionMatch.bBulletCheck = true
        local haveBullet, originBulletID, bulletID = xmission_wardrobe_data.HaveBullet(weaponID)
        local bulletConfig = CDataTable.GetTableData("Item", originBulletID)
        local bulletName = bulletConfig and bulletConfig.ItemName or ""
        if haveBullet then
          strMsg = LocUtil.LocalizeResFormat(60042, bulletName, tostring(cfg.value))
          CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
            LogicTxMissionMain.HideLobbyUI()
            LogicTxMissionMain.ShowWardrobeMain("material_bullet")
          end, strCancel, strOK)
        else
          strMsg = LocUtil.LocalizeResFormat(60043, bulletName, tostring(cfg.value))
          CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
            LogicTxMissionMain.HideLobbyUI()
            bulletConfig = CDataTable.GetTableData("TxMissionItem", bulletID)
            local jumpInfo = {
              Tab1 = 1003,
              Tab2 = bulletConfig and bulletConfig.QuickBuyTabID or 0
            }
            local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
            logic_xmission_black_market.GoToBlackMarket(jumpInfo)
          end, strCancel, strOK)
        end
        return
      end
    end
  end
  if not LogicTxMissionMatch.bDrugCheck and modeType ~= xMission_macro.ENUM_MODE_TYPE.VS_FREE then
    local isEquipDrugs = xMission_Prepare_Data.IsEquipDrugsInBag(true)
    if not isEquipDrugs then
      LogicTxMissionMatch.bDrugCheck = true
      if xmission_wardrobe_data.HaveDrug() then
        strMsg = LocUtil.LocalizeResFormat(60037, LocUtil.GetLocalizeResStr(60031))
        CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
          LogicTxMissionMain.HideLobbyUI()
          LogicTxMissionMain.ShowWardrobeMain("material_drug")
        end, strCancel, strOK)
      else
        strMsg = LocUtil.LocalizeResFormat(60038, LocUtil.GetLocalizeResStr(60031))
        local cancelCallBack = function()
          LogicTxMissionMain.HideLobbyUI()
          local jumpInfo = {Tab1 = 1003, Tab2 = 1003010}
          local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
          logic_xmission_black_market.GoToBlackMarket(jumpInfo)
        end
        CommonMsgBoxMgr.ShowTPlan(4, strTile, strMsg, okCallBack, cancelCallBack, strCancel, strOK)
      end
      return
    end
  end
  if not LogicTxMissionMatch.bArmorCheck and modeType ~= xMission_macro.ENUM_MODE_TYPE.VS_FREE then
    local isEquipHelmet = xMission_Prepare_Data.IsEquipHelmet()
    if not isEquipHelmet then
      LogicTxMissionMatch.bArmorCheck = true
      if xmission_wardrobe_data.HaveHelmet() then
        strMsg = LocUtil.LocalizeResFormat(60037, LocUtil.GetLocalizeResStr(60028))
        CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
          LogicTxMissionMain.HideLobbyUI()
          LogicTxMissionMain.ShowWardrobeMain("material_helmet")
        end, strCancel, strOK)
      else
        strMsg = LocUtil.LocalizeResFormat(60038, LocUtil.GetLocalizeResStr(60028))
        local cancelCallBack = function()
          LogicTxMissionMain.HideLobbyUI()
          local jumpInfo = {Tab1 = 1004, Tab2 = 1004001}
          local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
          logic_xmission_black_market.GoToBlackMarket(jumpInfo)
        end
        CommonMsgBoxMgr.ShowTPlan(4, strTile, strMsg, okCallBack, cancelCallBack, strCancel, strOK)
      end
      return
    end
    local isEquipArmor = xMission_Prepare_Data.IsEquipArmor()
    if not isEquipArmor then
      LogicTxMissionMatch.bArmorCheck = true
      if xmission_wardrobe_data.HaveArmor() then
        strMsg = LocUtil.LocalizeResFormat(60037, LocUtil.GetLocalizeResStr(60029))
        CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
          LogicTxMissionMain.HideLobbyUI()
          LogicTxMissionMain.ShowWardrobeMain("material_armor")
        end, strCancel, strOK)
      else
        strMsg = LocUtil.LocalizeResFormat(60038, LocUtil.GetLocalizeResStr(60029))
        local cancelCallBack = function()
          LogicTxMissionMain.HideLobbyUI()
          local jumpInfo = {Tab1 = 1004, Tab2 = 1004002}
          local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
          logic_xmission_black_market.GoToBlackMarket(jumpInfo)
        end
        CommonMsgBoxMgr.ShowTPlan(4, strTile, strMsg, okCallBack, cancelCallBack, strCancel, strOK)
      end
      return
    end
  end
  if not LogicTxMissionMatch.bBagWeightCheck then
    local cfg = CDataTable.GetTableData("TxMissionExtra", "play_bag_use_percent")
    if cfg and cfg.value and tonumber(cfg.value) > 0 then
      local weight = xMission_Prepare_Data.GetBagWeight()
      local capacity = xMission_Prepare_Data.GetBagCapacity()
      if tonumber(weight) / tonumber(capacity) > tonumber(cfg.value) / 100 then
        LogicTxMissionMatch.bBagWeightCheck = true
        strMsg = LocUtil.LocalizeResFormat(35186)
        CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack, function()
          LogicTxMissionMain.HideLobbyUI()
          LogicTxMissionMain.ShowWardrobeMain("material_baguse")
        end, strCancel, strOK)
        return
      end
    end
  end
  if okCallBack then
    okCallBack()
  end
end
function LogicTxMissionMatch.CheckModeHaveEnoughBullet(need_bullet)
  if not need_bullet or need_bullet <= 0 then
    return true
  end
  local num = 0
  local item_id = 0
  local slotInfo = xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Pistol)
  if slotInfo and slotInfo.item_id and 0 < slotInfo.item_num then
    num = LogicTxMissionMatch.GetBulletListNum(slotInfo.item_id)
    if need_bullet > num then
      item_id = slotInfo.item_id
    end
  end
  if item_id == 0 then
    slotInfo = xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_2)
    if slotInfo and slotInfo.item_id and 0 < slotInfo.item_num then
      num = LogicTxMissionMatch.GetBulletListNum(slotInfo.item_id)
      if need_bullet > num then
        item_id = slotInfo.item_id
      else
        item_id = 0
      end
    end
  end
  if item_id == 0 then
    slotInfo = xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_1)
    if slotInfo and slotInfo.item_id and 0 < slotInfo.item_num then
      num = LogicTxMissionMatch.GetBulletListNum(slotInfo.item_id)
      if need_bullet > num then
        item_id = slotInfo.item_id
      end
    end
  end
  if 0 < item_id then
    return false, item_id
  else
    return true
  end
end
function LogicTxMissionMatch.GetBulletListByWeaponID(weapon_id)
  if not weapon_id or weapon_id <= 0 then
    return nil
  end
  local bulletList = {}
  local originBulletID = 0
  local multiWeaponCfg = CDataTable.GetTableData("UpWeaponTable", weapon_id)
  if multiWeaponCfg and multiWeaponCfg.OriginWeaponID and 0 < multiWeaponCfg.OriginWeaponID then
    local weaponAttCfg = CDataTable.GetTableData("WeaponAttachments", multiWeaponCfg.OriginWeaponID)
    originBulletID = weaponAttCfg and weaponAttCfg.BulletID
    if weaponAttCfg and originBulletID and 0 < originBulletID then
      local multiBulletCfg = CDataTable.GetTable("MultiBulletAttr")
      for k, v in pairs(multiBulletCfg) do
        if v.ParentBulletID == originBulletID then
          table.insert(bulletList, v.KeyID)
        end
      end
    end
  end
  return bulletList, originBulletID
end
function LogicTxMissionMatch.GetBulletListNum(weapon_id)
  local num = 0
  local bulletList = LogicTxMissionMatch.GetBulletListByWeaponID(weapon_id)
  if bulletList and 0 < #bulletList then
    for k, v in pairs(bulletList) do
      num = num + xMission_Prepare_Data.GetItemNumInBag(v, true)
    end
  end
  return num
end
function LogicTxMissionMatch.GetMinMode(MapID)
  local TxMissionMap = CDataTable.GetTable("TxMissionMapMode")
  local minPrestigeInfo
  for k, v in pairs(TxMissionMap) do
    if MapID == v.MapID then
      if minPrestigeInfo == nil then
        minPrestigeInfo = v
      end
      if v.Prestige < minPrestigeInfo.Prestige then
        minPrestigeInfo = v
      end
    end
  end
  return minPrestigeInfo
end
function LogicTxMissionMatch.CheckMapIsUnlock(MapID)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local minPrestigeInfo = LogicTxMissionMatch.GetMinMode(MapID)
  if minPrestigeInfo and minPrestigeInfo.Prestige > 0 and LogicTxMissionMain.prestige_level < minPrestigeInfo.Prestige then
    return false
  end
  return true
end
function LogicTxMissionMatch.CheckTakeNoBagItems()
  local logic_xmission_team_competition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_team_competition)
  if logic_xmission_team_competition:IsTeamCompetitionType() then
    return false
  end
  local itemCfg
  local prepareBagList = xMission_Prepare_Data.GetBagList()
  if prepareBagList and 0 < #prepareBagList then
    for k, v in pairs(prepareBagList) do
      itemCfg = CDataTable.GetTableData("TxMissionItem", v.item_id)
      if itemCfg and (not itemCfg.CanIntoBag or itemCfg.CanIntoBag ~= 1) then
        return true
      end
    end
  end
  prepareBagList = xMission_Prepare_Data.GetSafeBagList()
  if prepareBagList and 0 < #prepareBagList then
    for k, v in pairs(prepareBagList) do
      itemCfg = CDataTable.GetTableData("TxMissionItem", v.item_id)
      if itemCfg and (not itemCfg.CanIntoBag or itemCfg.CanIntoBag ~= 1) then
        return true
      end
    end
  end
  return false
end
function LogicTxMissionMatch.CheckModeHaveDropRisk(okCallBack, model)
  log(bWriteLog and string.format("LogicTxMissionMatch.CheckModeHaveDropRisk, model:%s", model))
  local sel_model = model or LogicTxMissionMatch.GetSelModel()
  log(bWriteLog and string.format("LogicTxMissionMatch.CheckModeHaveDropRisk, sel_model:%s", sel_model))
  local BTMode = CDataTable.GetTableData("BTMode", sel_model)
  local mapId = BTMode and BTMode.MapID
  if not mapId then
    log(bWriteLog and "LogicTxMissionMatch.CheckModeHaveDropRisk not mapId")
    return false
  end
  if not LogicTxMissionMatch.IsMapDropItem(mapId) then
    log(bWriteLog and "LogicTxMissionMatch.CheckModeHaveDropRisk not IsMapDropItem")
    return false
  end
  if LogicTxMissionMatch.nRickCheckCount < C_RickCheckDailyCount then
    log(bWriteLog and string.format("LogicTxMissionMatch.CheckModeHaveDropRisk,LogicTxMissionMatch.nRickCheckCount < C_RickCheckDailyCount %s < %s", LogicTxMissionMatch.nRickCheckCount, C_RickCheckDailyCount))
    return false
  end
  LogicTxMissionMatch.nRickCheckCount = LogicTxMissionMatch.nRickCheckCount + 1
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionRickCheck)
  if data then
    data.checkCount = LogicTxMissionMatch.nRickCheckCount
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eXMissionRickCheck)
  end
  local strTile = LocUtil.GetLocalizeResStr(35188)
  local strMsg = LocUtil.GetLocalizeResStr(11602)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.ShowTPlan(2, strTile, strMsg, okCallBack)
  return true
end
function LogicTxMissionMatch.IsMapDropItem(mapId)
  local TPlanDeadRemainItemRule = CDataTable.GetTable("TPlanDeadRemainItemRule")
  local TableUtil = require("common.table_util")
  for _, v in pairs(TPlanDeadRemainItemRule) do
    if TableUtil.IsInTable(v.GameMapIDList_a, mapId) and v.RemainPerc < 100 then
      return true
    end
  end
  return false
end
function LogicTxMissionMatch.CheckModeHaveDropRiskReset()
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionRickCheck)
  if data then
    if LogicTxMissionMatch.nRickCheckCount == -1 then
      LogicTxMissionMatch.nRickCheckCount = data.checkCount or 0
    end
    local now = TimeUtil.GetServerTimeInSec()
    local last = data.checkTime or 0
    if not TimeUtil.IsSameDay(now, last) then
      LogicTxMissionMatch.nRickCheckCount = 0
      data.checkCount = 0
      data.checkTime = now
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eXMissionRickCheck)
    end
  else
    if LogicTxMissionMatch.nRickCheckCount == -1 then
      LogicTxMissionMatch.nRickCheckCount = 0
    end
    local saveData = {
      checkCount = LogicTxMissionMatch.nRickCheckCount,
      checkTime = TimeUtil.GetServerTimeInSec()
    }
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eXMissionRickCheck)
  end
end
function LogicTxMissionMatch.CheckWorthReadiness()
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local teamMemberNum = logic_team_up.GetTeamNum()
  if teamMemberNum <= 1 then
    log(bWriteLog and "LogicTxMissionMatch.CheckWorthReadiness, not team leader")
    return
  end
  if not logic_team_up.IsTeamLeader(tonumber(DataMgr.roleData.uid)) then
    log(bWriteLog and "LogicTxMissionMatch.CheckWorthReadiness, not team leader")
    return
  end
  local logic_xmission_team = require("client.slua.logic.TxMission.logic_xmission_team")
  local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
  local teamInfoMap = logic_xmission_team.teamInfo or {}
  local myWorth = logic_xmission_main.GetWorth()
  local minWorth = myWorth
  local sumWorth = 0
  for _, info in pairs(teamInfoMap) do
    if info.uid ~= DataMgr.roleData.uid and info.metro_team_info and info.metro_team_info.metro_worth then
      sumWorth = sumWorth + info.metro_team_info.metro_worth
      minWorth = math.min(minWorth, info.metro_team_info.metro_worth)
    end
  end
  if myWorth > minWorth then
    log(bWriteLog and string.format("LogicTxMissionMatch.CheckWorthReadiness, myWorth > minWorth:%s > %s", myWorth, minWorth))
    return false
  end
  local avgWorth = sumWorth / (logic_team_up.GetTeamNum() - 1)
  local configThreshold = 0.8
  if configThreshold < myWorth / avgWorth then
    log(bWriteLog and string.format("LogicTxMissionMatch.CheckWorthReadiness, myWorth / avgWorth > configThreshold:%s / %s > %s", myWorth, avgWorth, configThreshold))
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.Xmission_Readiness_Popup_UIBP)
  return true
end
function LogicTxMissionMatch.CheckNewbieRestriction()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local config = BasicDataServerTable:GetCacheData(data_config_marco.newbie_restriction_table)
  if not config then
    log(bWriteLog and "LogicTxMissionMatch.CheckNewbieRestriction return of not config")
    return false
  end
  local logic_xmission_match = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local selModeID = logic_xmission_match.GetSelModel()
  if not selModeID then
    log(bWriteLog and string.format("LogicTxMissionMatch.CheckNewbieRestriction return of not selModeID, selModeID:%s", selModeID))
    return false
  end
  if not config[selModeID] then
    log(bWriteLog and "LogicTxMissionMatch.CheckNewbieRestriction return of not not config[selModeID]")
    return false
  end
  local whiteMap = BasicDataServerTable:GetCacheData(data_config_marco.newbie_restriction_white_list_table) or {}
  local modeConfig = config[selModeID]
  local WeaponLimitQuality = modeConfig.weapon_quality_limit
  local BulletLimitQuality = modeConfig.bullet_quality_limit
  local HelmetLimitQuality = modeConfig.helmet_quality_limit
  local ArmorLimitQuality = modeConfig.armor_quality_limit
  local bWeaponLimit = false
  local bHelmetLimit = false
  local bArmorLimit = false
  local bBulletLimit = false
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local slotItemList = xMission_Prepare_Data:GetSlotItemTable()
  for id, info in pairs(slotItemList) do
    if not whiteMap[info.item_id] then
      local itemCfg = CDataTable.GetTableData("Item", info.item_id)
      if itemCfg then
        if id <= xMission_macro.Enum_Slot.EnumSlot_Pistol and WeaponLimitQuality < itemCfg.ItemQuality then
          bWeaponLimit = true
        elseif id == xMission_macro.Enum_Slot.EnumSlot_Helmet and HelmetLimitQuality < itemCfg.ItemQuality then
          bHelmetLimit = true
        elseif id == xMission_macro.Enum_Slot.EnumSlot_Armor and ArmorLimitQuality < itemCfg.ItemQuality then
          bArmorLimit = true
        end
      end
    end
  end
  local CheckItemListValid = function(itemList)
    for _, info in ipairs(itemList) do
      if bWeaponLimit and bHelmetLimit and bArmorLimit and bBulletLimit then
        break
      end
      if not whiteMap[info.item_id] then
        local tItemCfg = CDataTable.GetTableData("TxMissionItem", info.item_id)
        local itemCfg = CDataTable.GetTableData("Item", info.item_id)
        if itemCfg then
          if not bWeaponLimit and tItemCfg.ItemType <= xMission_macro.Enum_Type.EnumType_Pistol and itemCfg.ItemQuality > WeaponLimitQuality then
            bWeaponLimit = true
          elseif not bHelmetLimit and tItemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Helmet and itemCfg.ItemQuality > HelmetLimitQuality then
            bHelmetLimit = true
          elseif not bArmorLimit and tItemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Armor and itemCfg.ItemQuality > ArmorLimitQuality then
            bArmorLimit = true
          elseif not bBulletLimit and tItemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Bullet and itemCfg.ItemQuality > BulletLimitQuality then
            bBulletLimit = true
          end
        end
      end
    end
  end
  local xmission_prepare_data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local bagItemList = xmission_prepare_data.GetBagList()
  CheckItemListValid(bagItemList)
  local safeBagItemList = xmission_prepare_data.GetSafeBagList()
  CheckItemListValid(safeBagItemList)
  if bWeaponLimit or bHelmetLimit or bArmorLimit or bBulletLimit then
    local statusList = {
      [1] = {
        check = bWeaponLimit,
        limit = WeaponLimitQuality,
        locID = 4661
      },
      [2] = {
        check = bHelmetLimit,
        limit = HelmetLimitQuality,
        locID = 100020
      },
      [3] = {
        check = bArmorLimit,
        limit = ArmorLimitQuality,
        locID = 100021
      },
      [4] = {
        check = bBulletLimit,
        limit = BulletLimitQuality,
        locID = 33928
      }
    }
    UIManager.ShowUI(UIManager.UI_Config.Xmission_Popup_Newbie_Restriction_UIBP, statusList)
    return true
  end
  return false
end
function LogicTxMissionMatch.ShowNewbieRestrictionUIByCode(code)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local config = BasicDataServerTable:GetCacheData(data_config_marco.newbie_restriction_table)
  if not config then
    log(bWriteLog and "LogicTxMissionMatch.ShowNewbieRestrictionUIByCode return of not config")
    return false
  end
  local logic_xmission_match = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local selModeID = logic_xmission_match.GetSelModel()
  if not selModeID then
    log(bWriteLog and string.format("LogicTxMissionMatch.ShowNewbieRestrictionUIByCode return of not selModeID, selModeID:%s", selModeID))
    return false
  end
  if not config[selModeID] then
    log(bWriteLog and "LogicTxMissionMatch.ShowNewbieRestrictionUIByCode return of not not config[selModeID]")
    return false
  end
  local modeConfig = config[selModeID]
  local WeaponLimitQuality = modeConfig.weapon_quality_limit
  local BulletLimitQuality = modeConfig.bullet_quality_limit
  local HelmetLimitQuality = modeConfig.helmet_quality_limit
  local ArmorLimitQuality = modeConfig.armor_quality_limit
  local newbie_submode_restriction_code = {
    weapon = 1,
    helmet = 2,
    armor = 4,
    bullet = 8
  }
  local statusList = {
    [1] = {
      check = code & newbie_submode_restriction_code.weapon ~= 0,
      limit = WeaponLimitQuality,
      locID = 4661
    },
    [2] = {
      check = code & newbie_submode_restriction_code.helmet ~= 0,
      limit = HelmetLimitQuality,
      locID = 100020
    },
    [3] = {
      check = code & newbie_submode_restriction_code.armor ~= 0,
      limit = ArmorLimitQuality,
      locID = 100021
    },
    [4] = {
      check = code & newbie_submode_restriction_code.bullet ~= 0,
      limit = BulletLimitQuality,
      locID = 33928
    }
  }
  UIManager.ShowUI(UIManager.UI_Config.Xmission_Popup_Newbie_Restriction_UIBP, statusList)
end
function LogicTxMissionMatch.DestroyData()
  LogicTxMissionMatch.bWeaponCheck = false
  LogicTxMissionMatch.bBulletCheck = false
  LogicTxMissionMatch.bDrugCheck = false
  LogicTxMissionMatch.bArmorCheck = false
  LogicTxMissionMatch.bBagWeightCheck = false
end
return LogicTxMissionMatch