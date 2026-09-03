local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
local ScriptHelperEngine = import("ScriptHelperEngine")
local WardrobeLogic = {
  SortConfig = {
    version = 0,
    SortPreference = {},
    SortPreference_Inherit = {},
    SortPreferenceByMatch = 1,
    SortPreferenceByMatch_Inherit = 1
  },
  lastThemeItemInsID = 0,
  VehicleSceneType = {
    None = 0,
    SuperCar = 1,
    Ordinary = 2
  },
  lastSubTabString = "",
  recordTime = 0,
  bTriggerPutOn = false,
  bTriggerSuitDye = false,
  bFirstEnter = true,
  wardrobeEditMode = wardrobe_macro.EWardrobeEditMode.None,
  RecordForShareSkinCmp = nil,
  depotItemPackageArray = nil,
  depotPackageTimeOut = nil,
  isInShareSubscribeSetup = false,
  currentShareList = {},
  currentShareType = nil,
  searchString = "",
  _LazySortType = 1,
  characterUseCache = {},
  IsLowMemoryDevice = ScriptHelperEngine.IsLowMemoryDevice()
}
local depotPackageTimeOutLimit = 1
local super_data = require("common.super_data")
local currentData = super_data.CreateSuperData({
  pageId = -1,
  tabId = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_empty
})
local CurrVehicleSceneType
local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
local clickItemInsId = 0
local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local wardrobeTabString = wardrobeMacro.ENUM_WardrobeSubTabString
local wardrobePageTypeId = wardrobeMacro.ENUM_WardrobePageTypeId
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
function WardrobeLogic.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[tinghaohu]WardrobeLogic.OnModePostSwitch. nextState = " .. tostring(nextState))
  local wardrobe_data_util = require("client.slua.logic.wardrobe.wardrobe_data_util")
  wardrobe_data_util.OnModePostSwitch(preState, nextState)
end
function WardrobeLogic.on_sync_depot_info(depot)
  if LobbySystem.roleData.depot then
    return
  end
  LobbySystem.roleData.  wardrobe_data:InitHallDepotData(depot.items)
  if LobbySystem.WaitDepotInfo then
    LobbySystem.CreatLobbyAvatar()
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.OnRecvRoleDepotData(depot)
  local task = {
    module = wardrobe_data,
    funcName = "TLogReportExIdle",
    param = wardrobe_data,
    debugInfo = "WardrobeData:TLogReportExIdle",
    protect = true
  }
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function WardrobeLogic.on_sync_depot_item_info(cur_item_cnt, items, total_cnt)
  log(bWriteLog and string.format("WardrobeLogic.on_sync_depot_item_info  cur_item_cnt = %s, total = %s ", tostring(cur_item_cnt), tostring(total_cnt)))
  if cur_item_cnt == total_cnt then
    local depot = {
      items = {items},
      itemcount = total_cnt
    }
    WardrobeLogic.on_sync_depot_info(depot)
  else
    log(bWriteLog and "WardrobeLogic.on_sync_depot_item_info , add package")
    if not WardrobeLogic.depotItemPackageArray then
      WardrobeLogic.depotItemPackageArray = {
        itemcount = cur_item_cnt,
        items = {items},
        totalCount = -1
      }
    else
      WardrobeLogic.depotItemPackageArray.itemcount = WardrobeLogic.depotItemPackageArray.itemcount + cur_item_cnt
      table.insert(WardrobeLogic.depotItemPackageArray.items, items)
    end
    if 0 <= total_cnt then
      WardrobeLogic.depotItemPackageArray.totalCount = total_cnt
    end
    if WardrobeLogic.depotItemPackageArray.itemcount == total_cnt then
      WardrobeLogic.on_sync_depot_info(WardrobeLogic.depotItemPackageArray)
      WardrobeLogic.clearSyncDepotItemInfo()
    elseif not WardrobeLogic.depotPackageTimeOut then
      local time_ticker = require("common.time_ticker")
      WardrobeLogic.depotPackageTimeOut = time_ticker.AddTimerOnce(depotPackageTimeOutLimit, WardrobeLogic.clearSyncDepotItemInfo)
    end
  end
end
function WardrobeLogic.clearSyncDepotItemInfo()
  log(bWriteLog and "WardrobeLogic.clearSyncDepotItemInfo  itemcount = " .. tostring(WardrobeLogic.depotItemPackageArray and WardrobeLogic.depotItemPackageArray.itemcount))
  log(bWriteLog and "WardrobeLogic.clearSyncDepotItemInfo  totalCount = " .. tostring(WardrobeLogic.depotItemPackageArray and WardrobeLogic.depotItemPackageArray.totalCount))
  if WardrobeLogic.depotPackageTimeOut then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(WardrobeLogic.depotPackageTimeOut)
  end
  WardrobeLogic.depotPackageTimeOut = nil
  WardrobeLogic.depotItemPackageArray = nil
end
function WardrobeLogic:GetCurrSceneType()
  return CurrVehicleSceneType
end
function WardrobeLogic:SetCurrSceneType(type)
  CurrVehicleSceneType = type or WardrobeLogic.VehicleSceneType.None
end
function WardrobeLogic:Enter(jumpPageId, jumpSubTabId, args, eWardrobeEditMode)
  log(bWriteLog and "WardrobeLogic:Enter")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictDepotCheck() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  WardrobeLogic:EnterBeforShowUI()
  UIManager.ShowUI(UIManager.UI_Config.wardrobe, jumpPageId, jumpSubTabId, args, eWardrobeEditMode)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    local logic_wardrobe_Index_new = require("client.slua.logic.wardrobe.logic_wardrobe_Index_new")
    logic_wardrobe_Index_new:JudgeIsShow()
  end)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_ENTER_WARDROBE)
end
function WardrobeLogic:EnterBeforShowUI()
  local JumpUtils = require("client.logic.store.jump_utils")
  log(bWriteLog and "WardrobeLogic:Enter ")
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_client_in_depot()
  log(bWriteLog and "WardrobeLogic:EnterBeforShowUI RequestJumpMapInfo")
  JumpUtils.RequestJumpMapInfo()
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_shared_backpack_table_params_req()
end
function WardrobeLogic.EnterWardrobe(itemData)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WARDROBE) then
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.wardrobe) then
    LobbySystem.CloseOtherMenu()
  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if itemData and itemData.itemId then
    local itemCfg = CDataTable.GetTableData("Item", itemData.itemId)
    if itemCfg and itemCfg.WardrobeMainTab and itemCfg.WardrobeTab then
      wardrobeLogic:Enter(itemCfg.WardrobeMainTab, itemCfg.WardrobeTab)
    else
      wardrobeLogic:Enter()
    end
  else
    wardrobeLogic:Enter()
  end
  ClientSendBAReport(TLogEventDefine.LobbyInventory, 0)
end
function WardrobeLogic.JumpTo(eventType, eventID, vars)
  log_tree("WardrobeLogic:JumpTo", vars)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictDepotCheck() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  WardrobeLogic.EnterWardrobe(vars)
  if vars and vars.OpenDecompose then
    local logic_decompose = require("client.logic.decompose.logic_decompose")
    logic_decompose.Show()
  end
end
function WardrobeLogic:IsWearValid(insID, serverTime)
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insID)
  if itemData == nil or itemData.expireTS ~= 0 and serverTime > itemData.expireTS then
    log_tree("WardrobeLogic:IsWearValid", itemData)
    return false
  end
  if wardrobe_data:GetItemSource(insID) == EWardrobeDataSource.InheritWardrobe then
    local LogicInheritSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritSystem)
    if LogicInheritSystem.WaitingToClearData then
      return false
    end
  end
  return true
end
function WardrobeLogic:UpdateInvalidWearInfo(invalidIDList)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local tRoleWear = AvatarData.GetRoleWear()
  if tRoleWear ~= nil then
    for i = #tRoleWear, 1, -1 do
      local curWear = tRoleWear[i]
      if not self:IsWearValid(curWear, serverTime) then
        if invalidIDList then
          table.insert(invalidIDList, curWear)
        end
        AvatarData.RemoveRoleWearDataByIndex(i)
      end
    end
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  if invalidIDList then
    local helmetSkin = fashionbag_data:GetHelmetSkin()
    if helmetSkin ~= 0 and not self:IsWearValid(helmetSkin, serverTime) then
      table.insert(invalidIDList, helmetSkin)
      fashionbag_data:SetHelmetSkin(0)
    end
    local bagSkin = fashionbag_data:GetBagSkin()
    if bagSkin ~= 0 and not self:IsWearValid(bagSkin, serverTime) then
      table.insert(invalidIDList, bagSkin)
      fashionbag_data:SetBagSkin(0)
    end
  end
  fashionbag_data:SaveRolewearToFashionBag(fashionbag_data:GetFashionBagUseIndex())
  if fashionbag_data:GetParachute() ~= 0 and not self:IsWearValid(fashionbag_data:GetParachute(), serverTime) then
    fashionbag_data:SetParachute(DataMgr.defaultParachuteInsID)
  end
  if fashionbag_data:GetPlanSkin() ~= 0 and not self:IsWearValid(fashionbag_data:GetPlanSkin(), serverTime) then
    fashionbag_data:SetPlanSkin(DataMgr.defaultPlaneSkinInsID)
  end
  if fashionbag_data:GetWingmanSkin() ~= 0 and not self:IsWearValid(fashionbag_data:GetWingmanSkin(), serverTime) then
    fashionbag_data:SetWingmanSkin(DataMgr.defaultWingmanSkinInsID)
  end
  if next(DataMgr.vehicleSkinInsIDTable) ~= nil then
    local skinTable = {}
    for k, v in pairs(DataMgr.vehicleSkinInsIDTable) do
      local itemResID = DataMgr.defaultVehicleSkinResIDTable[k]
      if v ~= 0 and not self:IsWearValid(v, serverTime) and itemResID ~= nil then
        local insID = DataMgr.defaultVehicleSkinInsIDTable[itemResID]
        skinTable[k] = insID
        if DataMgr.vst_skin and DataMgr.vst_skin == v then
          HallThemeUtils.ProcPutOnVehicle({
            res_id = itemResID,
            instid = tonumber(insID)
          }, true)
        end
      else
        skinTable[k] = v
      end
    end
    DataMgr.vehicleSkinInsIDTable = skinTable
  end
  fashionbag_data:ProcessInvalidThrowObject()
  fashionbag_data:ProcessInvalidBagPendants()
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  logic_weapon_pendant:ProcessInvalidPendant()
end
function WardrobeLogic:GetItemPart(itemId)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if itemCfg == nil then
    return 0
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(itemCfg.ItemType) then
    return 6
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Extra then
    if itemCfg.ItemSubType == 401 then
      return 1
    elseif itemCfg.ItemSubType == 402 then
      return 2
    elseif itemCfg.ItemSubType == 403 then
      return 3
    elseif itemCfg.ItemSubType == 404 then
      return 4
    elseif itemCfg.ItemSubType == 405 then
      return 5
    else
      return 0
    end
  end
  return 0
end
local HasWearResId = function(resId)
  local hasData = wardrobe_data:GetHallDepotItemDataByResID(resId)
  local hasId = hasData and hasData.insID
  local TableUtil = require("common.table_util")
  if hasId then
    local tRoleData = AvatarData.GetRoleWear()
    if TableUtil.Find(tRoleData, hasId) > 0 then
      return true
    end
  end
end
function WardrobeLogic:wardrobe_puton_data_req(itemData)
  if not itemData then
    log(bWriteLog and "  WardrobeLogic:wardrobe_puton_data_req.  no itemData")
    return
  end
  local resId = itemData.resID or itemData.res_id
  log_warning(bWriteLog and "  WardrobeLogic:wardrobe_puton_data_req. resId: " .. tostring(resId))
  self:wardrobe_puton_req(itemData.ins_id or itemData.insID)
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  golden_suit_module:ModifyVehicleWhenPutOn(resId)
end
function WardrobeLogic:wardrobe_puton_req(insID, extra)
  if not insID then
    log_warning(bWriteLog and "WardrobeLogic:wardrobe_puton_req.  no insID")
    return
  end
  log(bWriteLog and "god test wardrobe wardrobe_puton_req insID " .. tostring(insID))
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local relicInfo = LogicXSuit.relicInfoList[DataMgr.roleData.uid]
  if relicInfo and relicInfo.status then
    local XSuitHandler = require("client.network.Protocol.XSuitHandler")
    XSuitHandler.send_wear_gold_dress_req(1, relicInfo.wearID)
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_depot_put_on_req(tonumber(insID), extra)
end
function WardrobeLogic:on_puton_rsp(res, item, olditem, index, extra)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  log_tree("WardrobeLogic puton_item:", item)
  if res == NetErrorCode_NONE then
    if item == nil then
      return
    end
    local itemCfg = CDataTable.GetTableData("Item", item.res_id)
    if itemCfg ~= nil then
      if not item.expire_ts then
        local defaultData = CDataTable.GetTableData("DefaultItem", item.res_id)
        if not defaultData then
          WardrobeLogic:UpdateLastEquipForeverSkin(itemCfg.ItemType, itemCfg.itemSubType, item.instid)
        end
      end
      if item then
        logic_wardrobe_avatar:AddToWearInfo(itemCfg.ItemSubType, item.instid, item.res_id, 0, 0)
      end
      if itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_parachute then
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:UpdateParachute(item.instid)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_plane then
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:UpdatePlaneSkin(item.instid)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_Wingman then
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:UpdataWingmanSkin(item.instid)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_effect then
        local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:UpdateAircraftOrGliding(item.instid, ModelDisplayTypeHelper.IsGlideSmoke(itemCfg.itemSubType))
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_MiniTVSuit then
        DataMgr.UpdateMiniTvDress(item.res_id)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_character_MVP_MOTION then
        DataMgr.UpdateStatueSkin(item.instid)
      end
      if itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Helmet or itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
        HallThemeUtils.ProcPutOnHelmet(item, olditem)
        local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
        WardRobeHandler.send_depot_set_head_show_req(item.instid)
      elseif itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Upgrade_Backpack or itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Backpack then
        HallThemeUtils.ProcPutOnBagSkin(item, olditem)
      elseif itemCfg.WardrobeMainTab == wardrobePageTypeId.ENUM_WardrobePageType_Avatar then
        if logic_wardrobe_avatar:IsTabString_Bag_Helmet_Armor(itemCfg.WardrobeTab) then
          DataMgr.UpdateEquipmentSkin(itemCfg.ItemSubType, item.instid)
          logic_wardrobe_avatar:CheckPutoffHatAvatar(itemCfg)
          if itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_helmet then
            local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
            WardRobeHandler.send_depot_set_head_show_req(item.instid)
          end
          local itemResID = logic_wardrobe_avatar:GetEquipmentItemIDBySkinInsID(itemCfg.ItemSubType, item.instid)
          if olditem then
            DataMgr.UpdateRoleWearData(item.instid, olditem.instid)
          else
            DataMgr.UpdateRoleWearData(item.instid, 0)
          end
          if 0 <= itemResID then
            local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
            TeamAvatarManager.ChangeAvatarEquipment(DataMgr.roleData.uid, AvatarData.CreateAvatarCustom(itemResID, item.color, item.pattern), true)
          end
        else
          if olditem then
            logic_wardrobe_avatar:ResetCurrentWearPreviewMapInited()
            DataMgr.UpdateRoleWearData(item.instid, olditem.instid)
          else
            DataMgr.UpdateRoleWearData(item.instid, 0)
          end
          logic_wardrobe_avatar:CheckPutOffHelmetAvatar(itemCfg)
          if itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_head then
            HallThemeUtils.ProcPutOnHat(item)
            local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
            WardRobeHandler.send_depot_set_head_show_req(item.instid)
          end
          local displayResID = item.res_id
          local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
          if LogicXSuit.IsXSuit(displayResID) then
            displayResID = LogicXSuit.GetItemShowID(item.instid)
            local level = LogicXSuit.GetDefaultSwitchLevelByItemID(item.res_id)
            LogicXSuit.SetSwitchLevelByPeriod(LogicXSuit.GetPeriodByItemId(item.res_id), level)
            local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
            local subtab_gliding = require("client.slua.umg.Wardrobe.subtab_gliding")
            local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
            local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXsuitMotionCoast) or {}
            local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local gliding = fashionbag_data:GetAircraftOrGliding()
            gliding = tostring(gliding)
            if Record[item.res_id] and Record[Record[item.res_id]] ~= gliding then
              local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
              local data = wardrobeData:GetHallDepotItemListByResID(Record[item.res_id])
              if Record[Record[item.res_id]] and #Record[Record[item.res_id]] > 6 then
                subtab_gliding:SetDisplaySetting(true)
                WardrobeLogicManager:wardrobe_puton_req(Record[Record[item.res_id]])
              elseif data and data[1] and data[1].insID then
                WardrobeLogicManager:wardrobe_puton_req(data[1].insID)
              end
              subtab_gliding:SetDisplaySetting(true)
              local txt = LocUtil.LocalizeResFormat(200000266, itemCfg.ItemName)
              ShowNotice(txt)
            end
          end
          logic_wardrobe_avatar:AvatarChange(displayResID, true, item.color, item.pattern)
          LogicXSuit.RefreshSharedRelicInfo()
        end
        logic_wardrobe_avatar:ProcessTakeOff()
      elseif itemCfg.WardrobeMainTab == wardrobePageTypeId.ENUM_WardrobePageType_Parachute then
        if itemCfg.ItemType == ENUM_ITEM_TYPE.Hall_Theme then
          HallThemeUtils.ProcPutOnHallTheme(item, olditem)
        elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_throw_object then
          self:ShowGrenadeModel(item.res_id)
          local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
          fashionbag_data:PutOnThrowObjectSkin(item.instid, index)
        elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_bag_pendant then
          local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
          fashionbag_data:PutOnBagPendants(item.instid, olditem and olditem.instid or 0)
          self:ShowBagPendantModel(item.instid, true)
        elseif wardrobe_data.IsGlideType(itemCfg.ItemSubType) then
          local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
          local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
          if wardrobeData:HasParaEffectCar() and wardrobeData:HasGlide() then
            logic_display_setting.ShowGlideBanner(true)
          end
          self:ShowAircraftNotice(itemCfg, true)
        elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_FootEffect then
          if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Foot_Effect then
            DataMgr.UpdateFootEffect(item.instid)
          else
            DataMgr.UpdateCommonPutOnDataBy(itemCfg.ItemSubType, item.instid)
          end
          local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
          TeamAvatarManager.PutonEquipment(DataMgr.roleData.uid, item.res_id)
        elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_Wingman then
          HallThemeUtils.ProcPutOnWingman(item.res_id)
        end
      elseif itemCfg.WardrobeMainTab == wardrobePageTypeId.ENUM_WardrobePageType_Vehicle then
        if itemCfg.WardrobeTab ~= wardrobeTabString.ENUM_WardrobeSubTabString_parachute and itemCfg.WardrobeTab ~= wardrobeTabString.ENUM_WardrobeSubTabString_plane then
          DataMgr.UpdateVehicleSkin(itemCfg.ItemSubType, item.instid)
          local bIgnoreSetSlot = extra and extra.bFromVehicleType
          local bUpdateLobbyVehicle = extra and extra.bUpdateLobbyVehicle
          if not bIgnoreSetSlot then
            self:EquipSlotVehicle(item.res_id, tonumber(item.instid), 1)
          end
          HallThemeUtils.ProcPutOnVehicle(item, bUpdateLobbyVehicle)
        end
      elseif itemCfg.WardrobeMainTab == wardrobePageTypeId.ENUM_WardrobePageType_Tool then
        local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
        local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
        if wardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE == item.res_id or wardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE_SEASON == item.res_id or LogicAddScordCard:IsPutOnSeasonAddScoreCard(item.res_id) or wardrobeMacro.ENUM_WardrobePropResId.VS_TEAM_RATING_PROTECT_TIMES_CARD == item.res_id or PeakGameConfig.ProtectCard.PointsProtectionCard == item.res_id then
          local msg = LocUtil.LocalizeResFormat("9910112", itemCfg.ItemName)
          ShowNotice(msg)
        end
        if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.ClickEffect then
          local ClickEffectModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ClickEffectModule)
          ClickEffectModule:SetCurrentUse(itemCfg.ItemID)
          DataMgr.UpdateCommonPutOnDataBy(itemCfg.ItemSubType, item.instid)
          ShowNotice(20051011)
        end
      elseif CDataTable.GetTableData("ThemeSkinItemTypeConfig", itemCfg.itemSubType) then
        ShowNotice(792644)
        AvatarData.UpdateCommonSubtypeWearData(itemCfg.itemSubType, item.instid, true)
      end
      if olditem ~= nil then
        self:OnPutOffAircraft(olditem, itemCfg)
      end
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, item, olditem)
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
    end, {bForceReq = true}, Enum_AvatarShowSource.WardrobeLogic)
  else
    ShowNotice(res)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_FAIL, item, olditem)
  end
  local TimeUtil = require("client.common.time_util")
  WardrobeLogic.recordTime = TimeUtil.GetServerTimeInSec()
  WardrobeLogic.bTriggerPutOn = true
  local logic_gm_wear = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_wear")
  if logic_gm_wear then
    logic_gm_wear.OnEquipItem(res, item)
  end
end
function WardrobeLogic:wardrobe_put_down_data_req(itemData)
  WardrobeLogic:wardrobe_put_down_req(itemData.ins_id or itemData.insID)
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  golden_suit_module:ModifyVehicleWhenPutOff(itemData)
end
function WardrobeLogic:wardrobe_put_down_req(insID)
  log(bWriteLog and "god test wardrobe wardrobe_put_down_req ..... " .. insID)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_depot_put_down_req(tonumber(insID))
end
function WardrobeLogic:on_putdown_rsp(res, item)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if res == NetErrorCode_NONE then
    local itemCfg = CDataTable.GetTableData("Item", item.res_id)
    if itemCfg ~= nil then
      if itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Helmet or itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
        HallThemeUtils.ProcPutDownHelmet(item)
        local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
        WardRobeHandler.send_depot_set_head_show_req(0)
      elseif itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Upgrade_Backpack or itemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Backpack then
        HallThemeUtils.ProcPutDownBagSkin(item)
      elseif itemCfg.WardrobeMainTab == wardrobePageTypeId.ENUM_WardrobePageType_Avatar then
        local instID = item.instid
        if logic_wardrobe_avatar:IsTabString_Bag_Helmet_Armor(itemCfg.WardrobeTab) then
          if DataMgr.equipmentSkinInsIDTable[itemCfg.ItemSubType] == instID then
            DataMgr.UpdateEquipmentSkin(itemCfg.ItemSubType, 0)
            local itemResID = logic_wardrobe_avatar:GetEquipmentItemIDBySkinInsID(itemCfg.ItemSubType, instID)
            if 0 <= itemResID then
              if itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_helmet then
                local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
                WardRobeHandler.send_depot_set_head_show_req(0)
              end
              local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
              TeamAvatarManager.ChangeAvatarEquipment(DataMgr.roleData.uid, AvatarData.CreateAvatarCustom(itemResID), false)
            end
            EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
          end
        else
          local isPutOn = false
          local tRoleData = AvatarData.GetRoleWear()
          for _, v in pairs(tRoleData) do
            if v == instID then
              isPutOn = true
              break
            end
          end
          if isPutOn then
            DataMgr.UpdateRoleWearData(0, instID)
            if itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_head then
              local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
              fashionbag_data:SetHeadShow(0)
              local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
              WardRobeHandler.send_depot_set_head_show_req(0)
              HallThemeUtils.ProcPutDownHat()
            end
            local displayResID = item.res_id
            local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
            if LogicXSuit.IsXSuit(displayResID) then
              displayResID = LogicXSuit.GetItemShowID(item.instid)
            end
            logic_wardrobe_avatar:AvatarChange(displayResID, false)
            EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
            LogicXSuit.RefreshSharedRelicInfo()
          end
        end
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_effect then
        self:OnPutOffAircraft(item)
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:ClearAircraftOrGliding()
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_items then
        local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
        local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
        if wardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE == item.res_id or wardrobeMacro.ENUM_WardrobePropResId.RATING_SHIELD_ONCE_SEASON == item.res_id or LogicAddScordCard:IsPutOnSeasonAddScoreCard(item.res_id) or wardrobeMacro.ENUM_WardrobePropResId.VS_TEAM_RATING_PROTECT_TIMES_CARD == item.res_id or PeakGameConfig.ProtectCard.PointsProtectionCard == item.res_id then
          local msg = LocUtil.LocalizeResFormat("7348", itemCfg.ItemName)
          ShowNotice(msg)
        end
        if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.ClickEffect then
          local ClickEffectModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ClickEffectModule)
          ClickEffectModule:SetCurrentUse(0)
          DataMgr.UpdateCommonPutOnDataBy(itemCfg.ItemSubType, 0)
          ShowNotice(20051012)
        end
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_throw_object then
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:PutDownThrowObjectSkin(item.instid)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_bag_pendant then
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fashionbag_data:PutDownBagPendants(item.instid)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      elseif itemCfg.WardrobeTab == wardrobeTabString.ENUM_WardrobeSubTabString_FootEffect then
        if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Foot_Effect then
          DataMgr.UpdateFootEffect(0)
        else
          DataMgr.UpdateCommonPutOnDataBy(itemCfg.ItemSubType, 0)
        end
        local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
        TeamAvatarManager.PutoffEquipment(DataMgr.roleData.uid, item.res_id)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      elseif itemCfg.itemType == 61 then
        DataMgr.UpdateStatueSkin(0)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      elseif CDataTable.GetTableData("ThemeSkinItemTypeConfig", itemCfg.itemSubType) then
        ShowNotice(792645)
        AvatarData.UpdateCommonSubtypeWearData(itemCfg.itemSubType, item.instid, false)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, item)
      end
    end
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
    end, {bForceReq = true}, Enum_AvatarShowSource.WardrobeLogic)
  else
    DataMgr.ShowMessageBoxByID(res)
  end
  WardrobeLogic.bTriggerPutOn = true
  local logic_gm_wear = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_wear")
  if logic_gm_wear then
    logic_gm_wear.OnTakeOffItem(res, item)
  end
end
function WardrobeLogic:wardrobe_change_item_new_status(instID)
  wardrobe_data:ChangeHallDepotItemNewStatus(instID)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  wardrobe_red_point:ClearItemNew(tonumber(instID))
end
function WardrobeLogic:wardrobe_change_item_list_new_status(inst_id_list)
  for _, v in pairs(inst_id_list) do
    wardrobe_data:ChangeHallDepotItemNewStatus(v)
  end
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  wardrobe_red_point:ClearItemListNew(inst_id_list)
end
function WardrobeLogic:FindMotion(instid)
  for i, v in ipairs(DataMgr.MotionSlotList) do
    if v == instid then
      return i
    end
  end
  return -1
end
function WardrobeLogic:EquipMotion(instid, dst_slot)
  local insSlot = self:FindMotion(instid)
  local curIns = DataMgr.MotionSlotList[dst_slot]
  local WardrobeHandler = require("client.network.Protocol.WardRobeHandler")
  if 0 < insSlot then
    if curIns == instid then
      return
    end
    WardrobeHandler.send_exchange_motion_req(insSlot, dst_slot)
  else
    WardrobeHandler.send_equip_motion_req(instid, dst_slot)
  end
end
function WardrobeLogic:equip_motion_list_req(motion_list)
  local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
  WardrobeNewHandler.send_equip_motion_list_req(motion_list)
end
function WardrobeLogic:unequip_motion_req(instid, slot)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_unequip_motion_req(instid, slot)
end
function WardrobeLogic:PlayMotion(motionResID, inSimpleUIEdit)
  local LogicLobbyExpression = require("client.slua.logic.lobby.logic_lobby_expression")
  log(bWriteLog and "WardrobeLogic:PlayMotion motionResID " .. tostring(motionResID))
  local itemCfg = CDataTable.GetTableData("Item", motionResID)
  if itemCfg then
    if GlobalData.IsJapanOrKorea() and itemCfg.JKBPID > 0 then
      motionResID = itemCfg.JKBPID
    else
      motionResID = itemCfg.BPID
    end
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = AvatarData.GetGameGender()
  local randSoundId = LogicLobbyExpression.GetTauntRandSoundID(motionResID, sex)
  local extraInfo = LogicLobbyExpression.GetExtraInfo(motionResID)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local bCanPlay = LobbyAvatarManager.PlayEmoteAction(DataMgr.roleData.uid, motionResID, sex, randSoundId, nil, extraInfo)
  if inSimpleUIEdit then
    return
  end
  local extraParam
  if extraInfo then
    extraParam = {extraInfo = extraInfo}
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and bCanPlay then
    TeamUpNewSystem.team_player_action(motionResID, randSoundId, extraParam)
    if TeamUpNewSystem.IsTeamLeader() and TeamUpNewSystem.CheckEmoteCanFollow(motionResID) then
      local FollowerUIDS = TeamUpNewSystem.GetEmoteFollowersUID()
      for _, uid in pairs(FollowerUIDS) do
        local EmoteID = TeamUpNewSystem.GetFollowPlayEmoteID(uid, motionResID)
        LobbyAvatarManager.PlayEmoteAction(uid, EmoteID, logic_profile:GetRoleSexByUid(uid, true), nil, nil, extraInfo)
      end
    end
  end
end
function WardrobeLogic:StopMVPMotionLocalPlay()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.StopEmoteAction(DataMgr.roleData.uid)
end
function WardrobeLogic:IsValidTime(serverTime, itemTime)
  return itemTime == 0 or itemTime == nil or serverTime < itemTime
end
function WardrobeLogic:GetRemainTimeStr(expireTS)
  local result = ""
  local TimeUtil = require("client.common.time_util")
  local remainTime = expireTS - TimeUtil.GetServerTimeInSec()
  if remainTime <= 0 then
    remainTime = 1
  end
  return self:GetTimeStr(remainTime)
end
function WardrobeLogic:GetTimeStr(remainTime)
  local hour = math.floor(remainTime * SecToHour)
  local day = math.floor(hour * HourToDay)
  if 1 < hour then
    hour = hour % 24
  else
    hour = 1
  end
  local transableStr = ""
  if day ~= 0 then
    transableStr = LocUtil.LocalizeResFormat(301152, day, hour)
  elseif hour ~= 0 then
    transableStr = LocUtil.LocalizeResFormat(9910107, tostring(hour))
  end
  return transableStr
end
function WardrobeLogic:ShowLobbyHotDot(isShow)
  self:UpdateLobbyHotDot()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ARMORY, isShow)
end
function WardrobeLogic:IsServerJK()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local iServerRegion = ZoneSystem.nChooseZoneID
  return iServerRegion == 6
end
function WardrobeLogic:IsCharacterUse(resId)
  if not resId or resId == 0 then
    return false
  end
  if WardrobeLogic.characterUseCache[resId] then
    return true
  end
  local itemCfg = CDataTable.GetTableData("character_param_table", resId)
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  if itemCfg and itemCfg.character_param ~= 0 then
    if not NewCharacterNetSystem:IsUsedCharacter(itemCfg.character_param) then
      return false
    end
  else
    if WardrobeLogic.IsLowMemoryDevice then
      return true
    end
    WardrobeLogic.characterUseCache[resId] = true
  end
  return true
end
function WardrobeLogic:IsItemIsolated(resId)
  if resId == 0 then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", resId)
  if itemCfg then
    local strRegion = itemCfg.ItemRegion
    local bItemJk = strRegion == "krjp"
    local bItemGlobal = strRegion == "global"
    local bServerJk = self:IsServerJK()
    if bItemGlobal and bServerJk or bItemJk and not bServerJk then
      return true
    end
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    local StringUtil = require("common.string_util")
    local validRegionCodes = StringUtil.Split(itemCfg.ValidRegionCodes, "|")
    if 1 < #validRegionCodes then
      for i, regionCode in ipairs(validRegionCodes) do
        if regionCode == login_module.sIpRegion then
          return false
        end
      end
      return true
    end
  end
  return false
end
function WardrobeLogic:IsCanUse(resId)
  return self:IsCharacterUse(resId) and not self:IsItemIsolated(resId)
end
function WardrobeLogic:HasSameDiySuit(resID, colorID, patternID)
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  for k, v in pairs(arrayHallDepotItemInfo) do
    if v.resID == resID and v.colorID == colorID and v.patternID == patternID then
      return true
    end
  end
  return false
end
function WardrobeLogic:GetShaoJiItemId()
  if FuncUtil.IsPlayerJPKR() then
    return 1602908
  else
    return 1602008
  end
end
function WardrobeLogic:GetShaoJiItemId()
  if FuncUtil.IsPlayerJPKR() then
    return 1602908
  else
    return 1602008
  end
end
function WardrobeLogic:GetItemResId(instId)
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(instId)
  if itemInfo == nil then
    return 0
  end
  return itemInfo.resID
end
function WardrobeLogic:GetWardrobeInsIdByResId(resid)
  local insID = 0
  local insIdArray = wardrobe_data:GetHallDepotItemListByResID(resid)
  for k, v in pairs(insIdArray) do
    local dataInfo = wardrobe_data:GetHallDepotItemDataByInsID(v.insID)
    local time = 0
    if dataInfo ~= nil then
      if dataInfo.expireTS == 0 then
        insID = dataInfo.insID
        break
      elseif time < dataInfo.expireTS then
        time = dataInfo.expireTS
        insID = dataInfo.insID
      end
    end
  end
  return insID
end
function WardrobeLogic:IsValidCurrentPageItem(MainTab, SubTab, v, serverTime)
  if not serverTime then
    local TimeUtil = require("client.common.time_util")
    serverTime = TimeUtil.GetServerTimeInSec()
  end
  if v.mainTabType == MainTab and v.subTabType == SubTab and (v.expireTS == 0 or serverTime < v.expireTS) then
    return true
  end
  return false
end
function WardrobeLogic:IsValidCurrentPageItemBySubTabGroup(MainTab, SubTabGroup, v, serverTime)
  SubTabGroup = SubTabGroup or {}
  if not serverTime then
    local TimeUtil = require("client.common.time_util")
    serverTime = TimeUtil.GetServerTimeInSec()
  end
  if v.mainTabType == MainTab and SubTabGroup[v.subTabType] and (v.expireTS == 0 or serverTime < v.expireTS) then
    return true
  end
  return false
end
function WardrobeLogic:SetDisplayItemId(itemInfo, id)
  log(bWriteLog and "  setDisplayResId.  " .. tostring(id))
  local extra = itemInfo.extra
  if extra then
    extra.displayResId = id
  else
    itemInfo.extra = {displayResId = id}
  end
end
function WardrobeLogic:RemoveDisplayItemId(itemInfo)
  local extra = itemInfo.extra
  if extra then
    extra.displayResId = nil
  end
end
function WardrobeLogic:ArrayHallDepotToCommonItem(data, index, isUsing, showUseCount, isSelected, isSourceBook, isRolewear)
  local itemCfg = CDataTable.GetTableData("Item", data.resID)
  if itemCfg == nil then
    log_warning("ArrayHallDepotToCommonItem itemCfg nil. insID:" .. tostring(data.insID))
    log_warning("ArrayHallDepotToCommonItem itemCfg nil. resID:" .. tostring(data.resID))
  end
  local insID = tonumber(data.insID)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local isNew = wardrobe_red_point:Touch(insID, data)
  local itemInfo = {
    index = index or 0,
    isUsing = isUsing or false,
    showUseCount = showUseCount,
    isSelected = isSelected or false,
    isSourceBook = isSourceBook or false,
    hasLock = isSourceBook or false,
    isRolewear = isRolewear or false,
    itemName = itemCfg and itemCfg.itemName or nil,
    count = data.count,
    lock_cnt = data.lock_cnt or 0,
    isNew = isNew,
    ins_id = data.insID,
    res_id = data.resID,
    color_id = data.colorID or 0,
    pattern_id = data.patternID or 0,
    validHours = data.validHours or 0,
    itemSubType = itemCfg and itemCfg.itemSubType or 0,
    expireTS = data.expireTS or 0,
    quality = data.itemQuality or 0,
    hasLimitTime = 0 < data.validHours or 0 < data.expireTS
  }
  local UIUtil = require("client.common.ui_util")
  local specialQuality = UIUtil.GetSpecialQuality(data.resID)
  if 0 < specialQuality then
    itemInfo.quality = specialQuality
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local resID = data.resID
  if LogicXSuit.IsXSuit(resID) then
    local displayItemID = LogicXSuit.ChangeItemIDByInsID(data.insID)
    if displayItemID ~= resID then
      self:SetDisplayItemId(itemInfo, displayItemID)
    end
  elseif resID == 1410923 then
    local WearInfo = AvatarData.GetWearInfo()
    for _, v in pairs(WearInfo) do
      if v.ItemID == 1407726 then
        self:SetDisplayItemId(itemInfo, 1410945)
        break
      end
    end
  end
  local High32Bits = self:ExtractHigh32Bits(itemInfo.ins_id)
  local Low19Bits = self:ExtractLow19Bits(itemInfo.ins_id)
  itemInfo.  itemInfo.  return itemInfo
end
function WardrobeLogic:on_use_item_rsp(res, itemData, params)
  log(bWriteLog and "WardrobeLogic:on_use_item_rsp, res = " .. tostring(res))
  log_tree("WardrobeLogic:on_use_item_rsp", params)
  if res == NetErrorCode_NONE then
    local itemCfg = CDataTable.GetTableData("Item", itemData.res_id)
    if itemCfg then
      if itemCfg.ItemSubType == 2101 or itemCfg.ItemSubType == 2102 or itemCfg.ItemSubType == 2197 then
        local msg = LocUtil.LocalizeResFormat("9910112", itemCfg.ItemName)
        ShowNotice(msg)
      elseif logic_wardrobe_avatar:IsActiveSubType(itemCfg.ItemSubType) then
        local msg = "\229\183\178\230\191\128\230\180\187\239\188\140\232\175\183\229\137\141\229\190\128\230\155\180\230\141\162\229\189\162\232\177\161\231\179\187\231\187\159\228\189\191\231\148\168"
        ShowNotice(msg)
      end
      if itemCfg.ItemType == 800 and itemCfg.ItemSubType == 8001 then
        ShowNotice(29629)
      end
      if itemCfg.ItemType == ENUM_ITEM_TYPE.Item_Card and itemCfg.ItemSubType == 2110 and params then
        local arrayItemList = {}
        local arrayItem = {}
        arrayItem.res_id = params.choice_id
        arrayItem.expire_ts = 0
        arrayItem.valid_hours = params.choice_hours
        arrayItem.count = params.choice_count
        table.insert(arrayItemList, arrayItem)
        local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
        Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
      end
    end
    local logic_challenge_add_score_card = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_challenge_add_score_card)
    logic_challenge_add_score_card:ShowChallengeCardTips(itemData.res_id)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, itemData)
  else
    ShowNotice(res)
    if res == 9910101 then
    end
  end
end
function WardrobeLogic:on_depot_set_skin_info_rsp(error_code, skin_info)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if error_code == 0 or error_code == "0" then
    log(bWriteLog and "depot_set_skin_info_rsp success")
    log_tree("skin_info", skin_info)
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    fashionbag_data:SetBagLevel(skin_info.bag_level)
    fashionbag_data:SetHelmetLevel(skin_info.helmet_level)
    HallThemeUtils.ProcSetSkinInfo(skin_info)
    DataMgr.bag_level = fashionbag_data:GetBagLevel() or DataMgr.bag_level
    DataMgr.helmet_level = fashionbag_data:GetHelmetLevel() or DataMgr.helmet_level
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    if skin_info.bag_level ~= nil then
      if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) then
        local newSkin = fashionbag_data:GetBagSkinByLevel(skin_info.bag_level)
        fashionbag_data:SetBagSkin(newSkin)
        DataMgr.UpdateEquipmentSkin(ENUM_ITEM_SUBTYPE.Backpack, newSkin)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_EQUIPMENT_LEVEL)
      else
        self:UpdateSkinInfo(ENUM_ITEM_SUBTYPE.Backpack)
      end
    end
    if skin_info.helmet_level ~= nil then
      if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) then
        local newSkin = fashionbag_data:GetHelmetSkinByLevel(skin_info.helmet_level)
        fashionbag_data:SetHelmetSkin(newSkin)
        DataMgr.UpdateEquipmentSkin(ENUM_ITEM_SUBTYPE.Helmet_NoLevel, newSkin)
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_EQUIPMENT_LEVEL)
      else
        self:UpdateSkinInfo(ENUM_ITEM_SUBTYPE.Helmet_NoLevel)
      end
      if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
        local new_ins = fashionbag_data:GetHelmetSkinByLevel(skin_info.helmet_level)
        if new_ins and new_ins ~= 0 then
          local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
          WardRobeHandler.send_depot_set_head_show_req(new_ins)
        end
      end
    end
  else
    log(bWriteLog and "errorCode is : " .. error_code)
  end
end
function WardrobeLogic:UpdateLastEquipForeverSkin(ItemType, ItemSubType, skin)
  DataMgr.UpdateLastEquipForeverSkin(ItemType, ItemSubType, skin)
end
function WardrobeLogic:UpdateSkinInfo(itemSubType)
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(itemSubType)
  if wearInfo ~= nil then
    local itemInsID = wearInfo.insID
    logic_wardrobe_avatar:AddToWearInfo(itemSubType, itemInsID, wearInfo.resID, wearInfo.colorID, wearInfo.patternID)
    logic_wardrobe_avatar:AvatarChange(wearInfo.resID, true)
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_EQUIPMENT_LEVEL)
end
function WardrobeLogic:RecordCurrentFashion()
  local fashionBag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local TableUtil = require("common.table_util")
  local Old = TableUtil.CopyTable(fashionBag_data:GetCurrentFashionBag())
  self.RecordForShareSkinCmp = Old
end
function WardrobeLogic:SetWardrobeEditMode(wardrobeEditMode, shareBagSubType)
  log(bWriteLog and string.format(" WardrobeLogic:SetWardrobeEditMode wardrobeEditMode:%s", wardrobeEditMode))
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  self.wardrobeEditMode = wardrobeEditMode or wardrobe_macro.EWardrobeEditMode.None
  if wardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None and self.lastWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.FashionBag and self.lastWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None then
    if self.RecordForShareSkinCmp then
      local fashionBag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
      local TableUtil = require("common.table_util")
      local Cur = TableUtil.CopyTable(fashionBag_data:GetCurrentFashionBag())
      local revDiff = TableUtil.Diff(Cur, self.RecordForShareSkinCmp)
      if revDiff then
        log_tree(" WardrobeLogic:SetWardrobeEditMode calc revDiff", revDiff)
        local putDownList = TableUtil.CollectValues(revDiff)
        putDownList = TableUtil.ArrayUnique(putDownList)
        log(bWriteLog and " WardrobeLogic:SetWardrobeEditMode calc revDiff putDownList:" .. #putDownList)
        if 0 < #putDownList then
          for i, v in pairs(putDownList) do
            local dataInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
            if dataInfo then
              self:wardrobe_put_down_req(v)
            else
              log(bWriteLog and "WardrobeLogic:SetWardrobeEditMode dataInfo not found")
            end
          end
        end
      else
        log(bWriteLog and " WardrobeLogic:SetWardrobeEditMode revDiff is nil")
      end
      local diff = TableUtil.Diff(self.RecordForShareSkinCmp, Cur)
      if diff then
        log_tree(" WardrobeLogic:SetWardrobeEditMode calc diff", diff)
        local putOnList = TableUtil.CollectValues(diff)
        putOnList = TableUtil.ArrayUnique(putOnList)
        print(bWriteLog and " WardrobeLogic:SetWardrobeEditMode calc diff putOnList:" .. #putOnList)
        if 0 < #putOnList then
          for i, v in pairs(putOnList) do
            local dataInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
            if dataInfo then
              self:wardrobe_puton_req(v)
            else
              log(bWriteLog and "WardrobeLogic:SetWardrobeEditMode dataInfo not found")
            end
          end
        end
      else
        log(bWriteLog and " WardrobeLogic:SetWardrobeEditMode diff is nil")
      end
    end
    self.RecordForShareSkinCmp = nil
  end
  self.lastWardrobeEditMode = self.wardrobeEditMode
  self.  local isInShareSubscribeSetupOld = self.isInShareSubscribeSetup
  self.isInShareSubscribeSetup = wardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
  if isInShareSubscribeSetupOld and not self.isInShareSubscribeSetup then
    self:SyncSubscribeShareItemListToServer()
  end
end
function WardrobeLogic:GetWardrobeEditMode()
  print(bWriteLog and string.format(" WardrobeLogic:GetWardrobeEditMode self.wardrobeEditMode:%s", self.wardrobeEditMode))
  return self.wardrobeEditMode
end
function WardrobeLogic:IsInFashionBagEditMode()
  return self.wardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag
end
function WardrobeLogic:IsInInheritMode()
  return self.wardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit
end
function WardrobeLogic:GetShareType()
  return self.currentShareType
end
function WardrobeLogic:SetCurrentPageId(pageId)
  currentData.end
function WardrobeLogic:GetCurrentPageId()
  return currentData.pageId
end
function WardrobeLogic:SetCurrentTabId(tabId)
  currentData.end
function WardrobeLogic:GetCurrentTabId()
  return currentData.tabId
end
function WardrobeLogic:SetCurrentThrowObjectType(type)
  currentData.ThrowObjectType = type
end
function WardrobeLogic:GetCurrentThrowObjectType()
  return currentData.ThrowObjectType
end
function WardrobeLogic:SetCurrentPlaneType(type)
  currentData.PlaneType = type
end
function WardrobeLogic:GetCurrentPlaneObjectType()
  return currentData.PlaneType
end
function WardrobeLogic:GetCurrentPageAndTabData()
  return currentData
end
function WardrobeLogic:CheckCanUseRedEmotion(redEmotionId)
  return false
end
function WardrobeLogic:SetClickItemInsId(ins_id)
  clickItemInsId = ins_id
end
function WardrobeLogic:GetClickItemInsId()
  return clickItemInsId
end
local _GetDefaultCharacterSuitItemID = function()
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local currentCharacterId = NewCharacterNetSystem:GetCurUsedCharacterID()
  local defaultCharacterSuitItemID = CharacterUtils:GetDefaultSuitItemID(currentCharacterId)
  if defaultCharacterSuitItemID and 0 < #defaultCharacterSuitItemID then
    return tonumber(defaultCharacterSuitItemID[1])
  end
  return 0
end
function WardrobeLogic:GetSortCmpFunction(sortViaTime, ignoreCharacter, bOutfitCombination, bSortUseTimes)
  log(bWriteLog and "WardrobeLogic:GetSortCmpFunction " .. tostring(sortViaTime))
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  local charSkinList = NewCharacterSystem:GetCurCharSkinList()
  local charSkinMap = {}
  if charSkinList then
    for _, v in pairs(charSkinList) do
      charSkinMap[v.ID] = true
    end
  end
  local defaultCharacterSuitItemID = _GetDefaultCharacterSuitItemID()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local bInFashionBagEditMode = self:IsInFashionBagEditMode()
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  local UIUtil = require("client.common.ui_util")
  local SortCommonItem = function(a, b)
    if bOutfitCombination then
      if a.randomButton ~= b.randomButton then
        return a.randomButton
      else
        local aUsing = logic_outfit_combination:IsSuitWearing(a)
        local bUsing = logic_outfit_combination:IsSuitWearing(b)
        if aUsing ~= bUsing then
          return aUsing
        end
        if bSortUseTimes and a.times ~= b.times then
          return a.times > b.times
        end
      end
      a = a.mainItem
      b = b.mainItem
    end
    if not bInFashionBagEditMode then
      if a.isUsing ~= b.isUsing then
        return a.isUsing
      end
    else
      local bIsInTryMapA = FashionBagEditUtils:IsItemInTryMap(a.res_id, false)
      local bIsInTryMapB = FashionBagEditUtils:IsItemInTryMap(b.res_id, false)
      if bIsInTryMapA ~= bIsInTryMapB then
        return bIsInTryMapA
      end
    end
    if sortViaTime then
      if a.High32Bits ~= b.High32Bits then
        return a.High32Bits > b.High32Bits
      elseif a.Low19Bits ~= b.Low19Bits then
        return a.Low19Bits > b.Low19Bits
      end
    end
    if not ignoreCharacter then
      if a.isCharUse == nil then
        a.isCharUse = self:IsCharacterUse(a.res_id)
      end
      if b.isCharUse == nil then
        b.isCharUse = self:IsCharacterUse(b.res_id)
      end
      if a.isCharUse ~= b.isCharUse then
        return a.isCharUse
      end
    end
    if a.isNew == true ~= (b.isNew == true) then
      return a.isNew
    end
    if charSkinMap[a.res_id] ~= charSkinMap[b.res_id] then
      return charSkinMap[a.res_id]
    end
    local qualityA = a.quality
    local qualityB = b.quality
    if a.extra and a.extra.displayQuality then
      qualityA = a.extra.displayQuality
    end
    if b.extra and b.extra.displayQuality then
      qualityB = b.extra.displayQuality
    end
    if qualityA ~= qualityB then
      return qualityA > qualityB
    end
    if not a.priority then
      a.priority = self:CalcSortPriorityOfSubType(a.res_id)
    end
    if not b.priority then
      b.priority = self:CalcSortPriorityOfSubType(b.res_id)
    end
    if a.priority ~= b.priority then
      return a.priority < b.priority
    end
    if defaultCharacterSuitItemID and a.res_id == defaultCharacterSuitItemID ~= (b.res_id == defaultCharacterSuitItemID) then
      return a.res_id == defaultCharacterSuitItemID
    end
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    local aIsGoldenSuit = LogicXSuit.IsXSuit(a.res_id)
    local bIsGoldenSuit = LogicXSuit.IsXSuit(b.res_id)
    if aIsGoldenSuit ~= bIsGoldenSuit then
      return aIsGoldenSuit
    elseif aIsGoldenSuit == true then
      return LogicXSuit.GetPeriodByItemId(a.res_id) > LogicXSuit.GetPeriodByItemId(b.res_id)
    end
    local aHasTime = a.expireTS ~= 0
    local bHasTime = b.expireTS ~= 0
    if aHasTime ~= bHasTime then
      return bHasTime
    elseif a.res_id ~= b.res_id then
      return a.res_id < b.res_id
    elseif a.expireTS ~= b.expireTS then
      return a.expireTS < b.expireTS
    else
      return false
    end
  end
  return SortCommonItem
end
function WardrobeLogic:GetSortFuncForLazyInit(wearInsMap, subTabConfig, ignoreCharacter)
  local sortViaTime = self:GetSortPreference(subTabConfig)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local Tab = wardrobe_red_point:GetTabByWardrobeTab(subTabConfig.subTabId)
  local NewCharacterSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterSystem)
  local charSkinList = NewCharacterSystem:GetCurCharSkinList()
  local charSkinMap = {}
  if charSkinList then
    for _, v in pairs(charSkinList) do
      charSkinMap[v.ID] = true
    end
  end
  local defaultCharacterSuitItemID = _GetDefaultCharacterSuitItemID()
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local bInFashionBagEditMode = self:IsInFashionBagEditMode()
  local SortCommonItem = function(a, b)
    if not bInFashionBagEditMode then
      if wearInsMap[a.insID] ~= wearInsMap[b.insID] then
        return wearInsMap[a.insID]
      end
    else
      local bIsInTryMapA = FashionBagEditUtils:IsItemInTryMap(a.resID, false)
      local bIsInTryMapB = FashionBagEditUtils:IsItemInTryMap(b.resID, false)
      if bIsInTryMapA ~= bIsInTryMapB then
        return bIsInTryMapA
      end
    end
    if sortViaTime then
      if not a.High32Bits then
        a.High32Bits = self:ExtractHigh32Bits(a.insID)
      end
      if not b.High32Bits then
        b.High32Bits = self:ExtractHigh32Bits(b.insID)
      end
      if a.High32Bits ~= b.High32Bits then
        return a.High32Bits > b.High32Bits
      end
      if not a.Low19Bits then
        a.Low19Bits = self:ExtractLow19Bits(a.insID)
      end
      if not b.Low19Bits then
        b.Low19Bits = self:ExtractLow19Bits(b.insID)
      end
      if a.High32Bits ~= b.High32Bits then
        return a.High32Bits > b.High32Bits
      end
      if a.Low19Bits ~= b.Low19Bits then
        return a.Low19Bits > b.Low19Bits
      end
    end
    if not ignoreCharacter then
      local AisCharUse = self:IsCharacterUse(a.resID)
      local BisCharUse = self:IsCharacterUse(b.resID)
      if AisCharUse ~= BisCharUse then
        return AisCharUse
      end
    end
    if Tab then
      local AisNew = Tab:CheckInstance(tonumber(a.insID))
      local BisNew = Tab:CheckInstance(tonumber(b.insID))
      if AisNew ~= BisNew then
        return AisNew
      end
    end
    if charSkinMap[a.resID] ~= charSkinMap[b.resID] then
      return charSkinMap[a.resID]
    end
    if a.itemQuality ~= b.itemQuality then
      return not b.itemQuality or a.itemQuality > b.itemQuality
    end
    if a.itemSubType ~= b.itemSubType then
      return not b.itemSubType or a.itemSubType > b.itemSubType
    end
    if defaultCharacterSuitItemID and a.resID == defaultCharacterSuitItemID ~= (b.resID == defaultCharacterSuitItemID) then
      return a.resID == defaultCharacterSuitItemID
    end
    local aIsGoldenSuit = LogicXSuit.IsXSuit(a.resID)
    local bIsGoldenSuit = LogicXSuit.IsXSuit(b.resID)
    if aIsGoldenSuit ~= bIsGoldenSuit then
      return aIsGoldenSuit
    elseif aIsGoldenSuit then
      return LogicXSuit.GetPeriodByItemId(a.resID) > LogicXSuit.GetPeriodByItemId(b.resID)
    end
    local aHasTime = a.expireTS ~= 0
    local bHasTime = b.expireTS ~= 0
    if aHasTime ~= bHasTime then
      return bHasTime
    elseif a.resID ~= b.resID then
      return a.resID < b.resID
    elseif a.expireTS ~= b.expireTS then
      return a.expireTS < b.expireTS
    end
    return false
  end
  return SortCommonItem
end
function WardrobeLogic:SortItemTable(itemListTable, sortViaTime, ignoreCharacter)
  table.sort(itemListTable, self:GetSortCmpFunction(sortViaTime, ignoreCharacter))
end
function WardrobeLogic:CanLazySort()
  return self._CanLazySort
end
function WardrobeLogic:LazySortType()
  return self._LazySortType
end
function WardrobeLogic:CalcSortPriorityOfSubType(resId)
  local itemData = CDataTable.GetTableData("Item", resId)
  return itemData and itemData.ItemSubType or 0
end
function WardrobeLogic:wardrobe_batch_put_down_req(instid_list)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_depot_batch_put_down_req(instid_list)
end
function WardrobeLogic:isVehicle(insID)
  if DataMgr.vehicleSkinInsIDTable ~= nil then
    for _, v in pairs(DataMgr.vehicleSkinInsIDTable) do
      if v == insID then
        return true
      end
    end
  end
  return false
end
function WardrobeLogic:wardrobe_batch_put_on_req(instid_list, putOnExtra, additionalParts)
  log_tree(bWriteLog and "WardrobeLogic:wardrobe_batch_put_on_req additionalParts", additionalParts)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_depot_batch_put_on_req(instid_list, putOnExtra)
  local hasVehicle
  if additionalParts then
    for _, v in pairs(additionalParts) do
      if self:isVehicle(v) then
        hasVehicle = true
        break
      end
    end
  end
  for _, insId in ipairs(instid_list) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
    local resId = itemData.resID or itemData.res_id
    local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
    golden_suit_module:ModifyVehicleWhenPutOn(resId, hasVehicle)
  end
end
function WardrobeLogic:ChangeToLobbyScene(nextPage)
  log(bWriteLog and string.format("WardrobeLogic:ChangeToLobbyScene nextPage: %s", nextPage))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
  local macroPageTypeId = wardrobe_macro.ENUM_WardrobePageTypeId
  if nextPage == macroTabString.ENUM_WardrobeSubTabString_throw_object or nextPage == macroTabString.ENUM_WardrobeSubTabString_effect then
    log(bWriteLog and "ChangeToLobbyScene not need")
    return
  end
  if self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_throw_object or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_plating or self:GetCurrentPageId() == macroPageTypeId.ENUM_WardrobePageType_Vehicle or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_parachute or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_emoji_bubble or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_holography or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_plane or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_effect or self:GetCurrentTabId() == macroTabString.Enum_WardrobeSubTabString_SpecialVehicle or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_MiniTVSuit then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(10002)
    TeamAvatarManager.ShowAllAvatar()
  end
end
function WardrobeLogic:EnterGrenadeScene()
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  self:EnterWardrobeScene(Lobby_camera_manager_module.Enum_CameraID.store_general, LobbySceneManager.LEVEL_NAME.MALL)
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:EnterGrenadeScene:" .. tostring((endTime - startTime) / 1000))
end
function WardrobeLogic:EnterHolographyScene()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  self:EnterWardrobeScene(Lobby_camera_manager_module.Enum_CameraID.store_general, LobbySceneManager.LEVEL_NAME.MALL)
end
function WardrobeLogic:EnterPlatingScene()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  self:EnterWardrobeScene(Lobby_camera_manager_module.Enum_CameraID.store_general, LobbySceneManager.LEVEL_NAME.MALL)
end
function WardrobeLogic:EnterGarageScene(View)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.HideAllAvatar()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
  if View and View == wardrobe_macro.ENUM_CAR_DEFAULT_VIEW.TopView then
    logic_lobby_garage_scene.LoadVehicleStoreTopCamera()
  else
    logic_lobby_garage_scene.LoadVehicleStoreCamera()
  end
  logic_lobby_garage_scene.LoadVehicleScene()
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:EnterGarageScene:" .. tostring((endTime - startTime) / 1000))
end
function WardrobeLogic:EnterVehicleSceneByItemID(item_id)
  log(bWriteLog and "[bgp] EnterVehicleSceneByItemID:item_id" .. tostring(item_id))
  local vehicleSceneType
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if LadderCarDetailConfig.IsRareCar(item_id) then
    vehicleSceneType = WardrobeLogic.VehicleSceneType.SuperCar
  else
    vehicleSceneType = WardrobeLogic.VehicleSceneType.Ordinary
  end
  if vehicleSceneType == CurrVehicleSceneType then
    if CurrVehicleSceneType == WardrobeLogic.VehicleSceneType.SuperCar then
      local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
      logic_SuperCar_200Version.TryToResetCameraRotate()
    end
    return
  end
  WardrobeLogic:SetCurrSceneType(vehicleSceneType)
  log(bWriteLog and "[bgp] EnterVehicleSceneByItemID->vehicleSceneType\239\188\154" .. tostring(vehicleSceneType))
  if vehicleSceneType == WardrobeLogic.VehicleSceneType.SuperCar then
    local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
    logic_lobby_garage_scene.UpdateCurrSystemType(logic_lobby_garage_scene.LoadSystemType.Wardrobe)
    logic_lobby_garage_scene.LoadSuperCarVehicleScene()
  else
    WardrobeLogic:EnterGarageScene()
  end
end
function WardrobeLogic:EnterParachuteScene()
  log(bWriteLog and "WardrobeLogic: EnterParachuteScene ")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  self:EnterWardrobeScene(Lobby_camera_manager_module.Enum_CameraID.store_general, LobbySceneManager.LEVEL_NAME.MALL)
end
function WardrobeLogic:EnterWardrobeScene(cameraID, levelName, sceneName)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  LobbySceneManager.LoadStreamLevel(true, levelName, cameraID)
  TeamAvatarManager.HideAllAvatar()
end
function WardrobeLogic:EnterAvatarPageAndOpenSubscribePopup(ShareType)
  local tab = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
  local subTab = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit
  if ShareType == share_bag_macros.ENUM_ShareType.Weapon then
    tab = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
    subTab = nil
  end
  self:Enter(tab, subTab, {bShowSubscribeSharePopup = true, ShareType = ShareType})
end
function WardrobeLogic:EnterSubscribeEditModeWithoutPopup(ShareType, sharedList)
  local tab = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
  local subTab = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit
  if ShareType == share_bag_macros.ENUM_ShareType.Weapon then
    tab = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
    subTab = nil
  end
  self:Enter(tab, subTab, {
    bEnterSubscribeShareEditMode = true,
    ShareType = ShareType,
    initSharedList = sharedList
  })
end
function WardrobeLogic:ExitWardrobeScene()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
  local macroPageTypeId = wardrobe_macro.ENUM_WardrobePageTypeId
  if self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_throw_object or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_plating or self:GetCurrentPageId() == macroPageTypeId.ENUM_WardrobePageType_Vehicle or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_parachute or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_emoji_bubble or self:GetCurrentTabId() == macroTabString.ENUM_WardrobeSubTabString_plane then
    TeamAvatarManager.ShowAllAvatar()
  else
    LobbySceneManager.SwitchMainOrTeamCamera(true)
  end
end
function WardrobeLogic:ShowGrenadeModel(res_id, force)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
  local macroPageString = wardrobe_macro.ENUM_WardrobePageTypeId
  local pageId = logic_wardrobe.GetCurrentPageId()
  local tabId = logic_wardrobe.GetCurrentTabId()
  if not force then
    if pageId ~= macroPageString.ENUM_WardrobePageType_Parachute or tabId ~= macroTabString.ENUM_WardrobeSubTabString_throw_object then
      return
    end
    local ThrowObjectType = logic_wardrobe:GetCurrentThrowObjectType()
    if ThrowObjectType then
      local itemData = wardrobe_data:GetHallDepotItemDataByResID(res_id)
      if itemData and itemData.itemSubType ~= ThrowObjectType then
        log(bWriteLog and "WardrobeLogic:ShowGrenadeModel not in current page " .. tostring(res_id) .. "  " .. tostring(ThrowObjectType))
        return
      end
    end
  end
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Init()
  ModelDisplayer.SetNeedAutoRotate(true)
  ModelDisplayer.Display(res_id, true)
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:ShowGrenadeModel:" .. tostring((endTime - startTime) / 1000))
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, res_id)
end
function WardrobeLogic:PlayMVPTabDisplay(widget, currentTabId, ins_id, res_id)
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  if currentTabId == 1 then
  elseif currentTabId == 2 then
    local mvp_icon_preview = require("client.slua.umg.mvp_motion.mvp_icon_preview")
    mvp_icon_preview.Show(widget, UIManager.UI_Config.wardrobe, "CanvasPanel_9", res_id)
  elseif currentTabId == 3 then
    local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
    local type = LogicDisplaySetting.MVPActionType()
    if type ~= 5 then
      ShowNotice(18010296)
    end
    local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
    local emoteId = LogicParticleEmote:GetParticleEmoteID(res_id)
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    WardrobeLogicManager:PlayMotion(emoteId, true)
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, ins_id, res_id)
  end
end
function WardrobeLogic:ShowVehicleModel(res_id, source)
  source = source or EWardrobeDataSource.Wardrobe
  local extraData = {}
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
  logic_lobby_garage_scene.SetTAA(false)
  local VehicleLicense = VehicleCollectSystem:GetVehicleLicense(res_id, source)
  local EnableHighTire = VehicleCollectSystem:IsOpenHighTire(res_id, DataMgr.roleData.uid, nil, source)
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  local AccessoryList = LogicVehicleAccessory:GetEquipedAccessoryList(res_id, source)
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  local ChassisLight = LogicVehicleExtendedFeature:GetEquipedChassisLightData(res_id, source)
  local LicenseBgId = LogicVehicleExtendedFeature:GetCurEquippedPlateBg(res_id, source)
  extraData.ExtraTable = {
    License = VehicleLicense,
    EnableHighTire = EnableHighTire,
    AccessoryList = AccessoryList,
    ChassisLight = ChassisLight,
    LicenseBgId = LicenseBgId,
    Source = source
  }
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Init(nil, nil, nil, true)
  ModelDisplayer.SetNeedAutoRotate(false)
  ModelDisplayer.Display(res_id, true, extraData)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if slua.isValid(actor) then
    local vehicle = actor:GetVehicleActor()
    if slua.isValid(vehicle) and vehicle.BP_VehicleDIYComp then
      vehicle.BP_VehicleDIYComp:UpdateCarOwnerInLobby(DataMgr.roleData.uid, res_id)
    end
  end
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:ShowVehicleModel:" .. tostring((endTime - startTime) / 1000))
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, res_id)
end
function WardrobeLogic:ShowBagPendantModel(insId, puton)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
  if itemData then
    logic_wardrobe_avatar:AvatarChange(itemData.resID, puton)
  end
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:ShowBagPendantModel:" .. tostring((endTime - startTime) / 1000))
end
function WardrobeLogic:ShowParachuteModel(res_id)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Init(nil, nil, nil, true)
  ModelDisplayer.SetNeedAutoRotate(false)
  ModelDisplayer.Display(res_id, true)
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:ShowBagPendantModel:" .. tostring((endTime - startTime) / 1000))
end
function WardrobeLogic:ShowMinitvModel(res_id)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Init()
  ModelDisplayer.SetNeedAutoRotate(false)
  ModelDisplayer.Display(res_id, true)
end
function WardrobeLogic:ShowHolographyModel(res_id)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Init()
  ModelDisplayer.SetNeedAutoRotate(false)
  ModelDisplayer.Display(res_id, true)
end
function WardrobeLogic:ExtractHigh32Bits(id)
  local High32Bits = tonumber(id)
  High32Bits = High32Bits >> 32
  return High32Bits
end
function WardrobeLogic:ExtractLow19Bits(id)
  local Low19Bits = tonumber(id)
  return Low19Bits & 524287
end
function WardrobeLogic:GetSortPreference(subTabConfig)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local config = WardrobeLogicManager.SortConfig
  if config and subTabConfig then
    if self:IsInInheritMode() then
      return config.SortPreference_Inherit and config.SortPreference_Inherit[subTabConfig.subTabId]
    else
      return config.SortPreference and config.SortPreference[subTabConfig.subTabId]
    end
  end
  return nil
end
function WardrobeLogic:SetSortPreference(subTabConfig, type)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local config = WardrobeLogicManager.SortConfig
  if config and subTabConfig then
    if self:IsInInheritMode() then
      config.SortPreference_Inherit = config.SortPreference_Inherit or {}
      config.SortPreference_Inherit[subTabConfig.subTabId] = type
    else
      config.SortPreference = config.SortPreference or {}
      config.SortPreference[subTabConfig.subTabId] = type
    end
  end
end
function WardrobeLogic:GetMatchTabSortPreference()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local config = WardrobeLogicManager.SortConfig
  if config then
    if self:IsInInheritMode() then
      return config.SortPreferenceByMatch_Inherit or 1
    else
      return config.SortPreferenceByMatch or 1
    end
  end
  return nil
end
function WardrobeLogic:SetMatchSortPreference(nType)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local config = WardrobeLogicManager.SortConfig
  if config then
    if self:IsInInheritMode() then
      config.SortPreferenceByMatch_Inherit = nType or 1
    else
      config.SortPreferenceByMatch = nType or 1
    end
  end
end
function WardrobeLogic:IsWardrobeShow(item_cfg)
  if not item_cfg then
    return true
  end
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  local logic_team_add_score_card = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_add_score_card)
  if item_cfg.itemType == 501 or item_cfg.itemSubType == 2111 or item_cfg.itemSubType == 30010 or item_cfg.itemSubType == 30012 or item_cfg.itemSubType == 30013 or item_cfg.itemSubType == 7011 or item_cfg.itemSubType == 30008 then
    return false
  elseif item_cfg.itemSubType == 1630 then
    local aosShop = Client.GetAOSSHOP()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and aosShop ~= AOSSHOPMacros.Google and aosShop ~= AOSSHOPMacros.ThirdPartyPayment then
      return false
    end
  elseif LogicAddScordCard:IsDefaultUseSeasonAddScoreCard(item_cfg.ItemID or item_cfg.resID) then
    return false
  elseif logic_team_add_score_card:IsDefaultUseTeamAddScoreCard(item_cfg.ItemID or item_cfg.resID) then
    return false
  end
  return true
end
function WardrobeLogic:SwitchCameraInWardrobe()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if GameStatus.IsInMainCity() then
    Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Team)
  elseif Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Team then
    if Lobby_camera_manager_module.currentCameraID == Lobby_camera_manager_module.Enum_CameraID.Lobby_Default then
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Team, 0.7)
    else
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.Lobby_Team)
    end
  end
end
function WardrobeLogic:IsCharacterAction(resId)
  if resId == 0 then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", resId)
  if itemCfg then
    local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
    if itemCfg.ItemType == CharacterUtils.Enum_Item_Type.EnumType_Mvp_Action then
      return true
    end
    if itemCfg.ItemType == CharacterUtils.Enum_Item_Type.EnumType_Com_Action then
      return true
    end
  end
  return false
end
local GetAvatarShowInfo = function(bagIndex, showType)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(bagIndex)
  if bagInfo == nil then
    return
  end
  local showInfo = bagInfo.avatar_show and bagInfo.avatar_show[showType]
  if not showInfo then
    return
  end
  return showInfo
end
function WardrobeLogic:ShowAircraftNotice(item_cfg, isPutOn)
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if isPutOn then
    if self:IsFirstPutOnAircraft() then
      ShowNotice(27719)
    else
      local content = LocUtil.LocalizeResFormat(27712, item_cfg.ItemName)
      ShowNotice(content)
    end
  else
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
    local info = GetAvatarShowInfo(nUseWearBagIndex, HallThemeUtils.knapsack_ext_vst_skin)
    if info == nil then
      return
    end
    local itemConf = WardrobeDataManager:GetValidHallDepotItemDataByInsID(info.instid)
    if itemConf == nil then
      return
    end
    local Item = CDataTable.GetTableData("Item", itemConf.resID)
    local BetterVehicleEffect = CDataTable.GetTableData("BetterVehicleEffect", itemConf.resID)
    if BetterVehicleEffect and BetterVehicleEffect.Parachute == 1 then
      local content = LocUtil.LocalizeResFormat(27713, Item.ItemName)
      ShowNotice(content)
    end
  end
end
function WardrobeLogic:IsFirstPutOnAircraft()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAircraftFirstPutOn)
  if data == nil or data.firstPutOnAircast == true then
    data = {firstPutOnAircast = false}
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eAircraftFirstPutOn)
    return true
  end
  return false
end
function WardrobeLogic:OnPutOffAircraft(olditem, itemCfg)
  local oldItemCfg = CDataTable.GetTableData("Item", olditem.res_id)
  if not oldItemCfg then
    log(bWriteLog and "WardrobeLogic OnPutOffAircraft " .. tostring(olditem.res_id))
    return
  end
  if wardrobe_data.IsGlideType(oldItemCfg.ItemSubType) then
    if itemCfg == nil then
      self:ShowAircraftNotice(olditem, false)
    elseif not wardrobe_data.IsGlideType(itemCfg.ItemSubType) then
      self:ShowAircraftNotice(olditem, false)
    end
  end
end
function WardrobeLogic:EquipSlotVehicle(resid, dragVehicleInsID, Index)
  if resid then
    for type, Default_resid in pairs(wardrobeMacro.DefaultVehiclesId) do
      if resid == Default_resid then
        return
      end
    end
  end
  local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
  WardrobeNewHandler.send_depot_modify_combat_vehicle_req(tonumber(dragVehicleInsID), Index, true)
end
function WardrobeLogic:SetFristEnter(bFirst)
  WardrobeLogic.bFirstEnter = bFirst
end
function WardrobeLogic:SetTriggerPutOn(bTrigger)
  WardrobeLogic.bTriggerPutOn = bTrigger
end
function WardrobeLogic:SetTriggerSuitDye(bTrigger)
  WardrobeLogic.bTriggerSuitDye = bTrigger
end
function WardrobeLogic:GetSearchString()
  return WardrobeLogic.searchString
end
function WardrobeLogic:SetSearchString(str)
  WardrobeLogic.searchString = str
end
function WardrobeLogic:PutItemToShareList(resId, index)
  if not index or not resId then
    return false
  end
  local currentListCount = #self.currentShareList
  local bEmptySlot = index > currentListCount
  local oldIndex = self:FindItemInShareList(resId)
  if bEmptySlot then
    if oldIndex then
      self.currentShareList[oldIndex] = resId
      self.currentShareList[currentListCount], self.currentShareList[oldIndex] = self.currentShareList[oldIndex], self.currentShareList[currentListCount]
    else
      if 10 <= currentListCount then
        ShowNotice(48613)
        return false
      end
      local bonus_pass_util = require("client.slua.logic.unknow_pass.BonusPass.bonus_pass_util")
      for i, v in ipairs(self.currentShareList) do
        if bonus_pass_util.IsTheSameItem(v, resId) then
          self.currentShareList[i] = resId
          return true
        end
      end
      table.insert(self.currentShareList, resId)
    end
  elseif oldIndex then
    self.currentShareList[oldIndex] = resId
    self.currentShareList[index], self.currentShareList[oldIndex] = self.currentShareList[oldIndex], self.currentShareList[index]
  else
    self.currentShareList[index] = resId
  end
  return true
end
function WardrobeLogic:RemoveItemFromShareList(resId)
  if not resId then
    return false
  end
  local index = self:FindItemInShareList(resId)
  if index then
    table.remove(self.currentShareList, index)
    return true
  end
  return false
end
function WardrobeLogic:FindItemInShareList(resId)
  if not resId then
    return nil
  end
  local bonus_pass_util = require("client.slua.logic.unknow_pass.BonusPass.bonus_pass_util")
  for i, v in ipairs(self.currentShareList) do
    if v == resId or bonus_pass_util.IsTheSameItem(v, resId) then
      return i
    end
  end
  return nil
end
function WardrobeLogic:SetSubscribeShareList(resIdTable, ShareType)
  self.currentShareList = {}
  self.current  if not resIdTable then
    return
  end
  for _, resId in pairs(resIdTable) do
    if wardrobe_data:HasItem(resId, true) then
      table.insert(self.currentShareList, resId)
    end
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARE_BAG_LIST_UPDATE)
end
function WardrobeLogic:GetShareBagItemList()
  return self.currentShareList
end
function WardrobeLogic:SyncSubscribeShareItemListToServer()
  if self.currentShareList then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    local insIdList = {}
    for i, resId in pairs(self.currentShareList) do
      local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(resId, false)
      if itemData then
        table.insert(insIdList, itemData.insID)
      end
    end
    WardRobeHandler.send_shared_backpack_batch_config_item_req(self.currentShareType, insIdList)
  end
  self.currentShareList = {}
  self.isInShareSubscribeSetup = false
end
function WardrobeLogic:SetSharedBackpackParams(param)
  if not param then
    return
  end
  self.shareBackpackParam = param
  self.shareBackpackBlackItems = param.black_item_table
end
function WardrobeLogic:GetSharedBackpackQualityLimit(ShareType)
  if not self.shareBackpackParam then
    return 6
  end
  return ShareType == 2 and self.shareBackpackParam.collect_bp_quality_limit or self.shareBackpackParam.item_quality_limit or 6
end
function WardrobeLogic:GetSharedBackpackBlackItemTable()
  return self.shareBackpackBlackItems or {}
end
function WardrobeLogic:TryLoadSaveOperation()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local tabId = logic_wardrobe:GetCurrentPageId()
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  local operationData = logic_wardrobe_tag_mgr:GetLocalOperationData()
  local data = operationData[tabId]
  log(bWriteLog and "WardrobeLogic:TryLoadSaveOperation tabId: " .. tostring(tabId))
  if not (data and data.SelectCheckSaveOperation) or data.SelectCheckSaveOperation == 0 then
    log(bWriteLog and "WardrobeLogic:TryLoadSaveOperation no saved tag for current tabId: " .. tostring(tabId) .. " refresh using default")
  else
    local DateInfo = {
      StartYear = data.StartYear,
      StartMonth = data.StartMonth,
      EndYear = data.EndYear,
      EndMonth = data.EndMonth
    }
    log(bWriteLog and string.format("WardrobeLogic:TryLoadSaveOperation. tabId = %s", tabId))
    local SelectCornerTagList = self:CompatibilityCornerTagCache(data.SelectCornerTagList)
    logic_wardrobe_tag_mgr:ConfirmSelection(SelectCornerTagList, data.SelectCustomTagList, DateInfo, false)
  end
end
function WardrobeLogic:CompatibilityCornerTagCache(selectCornerTagList)
  log_tree("WardrobeLogic:CompatibilityCornerTagCache", selectCornerTagList)
  local res = {}
  if selectCornerTagList and next(selectCornerTagList) then
    local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
    for k, v in pairs(selectCornerTagList) do
      if v == true then
        if type(k) == "string" then
          local typeID = logic_outfit_combination:GetCornerTagIDByTypeName(k)
          res[typeID] = true
        elseif type(k) == "number" then
          res[k] = true
        end
      end
    end
  end
  log_tree("WardrobeLogic:CompatibilityCornerTagCache res", res)
  return res
end
function WardrobeLogic:WardrobeSelectWithSaveOperation(itemList)
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:UpdateItemList(itemList)
  self:TryLoadSaveOperation()
end
function WardrobeLogic.ReportTLog(form, itemData)
  local str = ""
  if form == WardrobeLogic.ReportTLogEnum.Wardrobe then
    local ID = itemData.resID or itemData.res_id or 0
    str = string.format("%s", ID)
  elseif form == WardrobeLogic.ReportTLogEnum.WardrobeSuit then
    local suitID = itemData or 0
    str = string.format("%s", suitID)
  elseif form == WardrobeLogic.ReportTLogEnum.FashionBag then
    str = ""
    if itemData and next(itemData) then
      str = str .. table.concat(itemData, ",")
    end
  elseif form == WardrobeLogic.ReportTLogEnum.SharePackage then
    str = ""
    if itemData and next(itemData) then
      str = str .. table.concat(itemData, ",")
    end
  end
  str = str .. ";"
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MainCity_Dress_Click, 0, str)
end
function WardrobeLogic.OnGameStateChange(_, _, vars)
  local pre, current = vars.pre, vars.current
  if current == GameStatus.Fighting and not GameStatus.IsInMainCity() and not GameStatus.IsCollectionHallMode() then
    log(bWriteLog and string.format("WardrobeLogic.OnGameStateChange Fighting."))
    wardrobe_data:PauseFrameLoading()
  end
  if pre == GameStatus.Fighting and current == GameStatus.Lobby then
    log(bWriteLog and string.format("WardrobeLogic.OnGameStateChange Lobby."))
    wardrobe_data:RestoreFrameLoading()
  end
end
WardrobeLogic.ReportTLogEnum = {
  Wardrobe = 1,
  WardrobeSuit = 2,
  FashionBag = 3,
  SharePackage = 4
}
return WardrobeLogic