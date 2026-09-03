local logic_lobby_system_entrance = {}
function logic_lobby_system_entrance.CloseOtherMenu()
  UIManager.AndroidBackToLobby()
end
function logic_lobby_system_entrance.OnInviteJoin(eventType, eventID, vars)
  LobbySystem.CloseOtherMenu()
  if vars.teamid ~= nil and vars.uid ~= nil then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.teamInfo ~= nil and TeamUpNewSystem.teamInfo.leader == vars.uid and TeamUpNewSystem.teamInfo.id == vars.teamid then
      log(bWriteLog and "LobbyUI.OnInviteJoin, aready in the team!")
      return
    end
    log(bWriteLog and "[v_ywuyuan] OnInviteJoin log")
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.SideBar_Invite_Messenger_Offline, 0, "ClickMessageInviteLink")
    local source = vars.src or ShareSource.Facebook
    TeamUpNewSystem.JoinTeamByChat(vars.uid, vars.teamid, source)
  end
end
function logic_lobby_system_entrance.JumpToStore(eventType, eventID, vars)
  local JumpUtils = require("client.logic.store.jump_utils")
  if LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MALL) == false then
    return
  end
  local moneyComponentSystem = require("client.slua.logic.store.logic_money_component")
  moneyComponentSystem.GetStoreCurrencyConfig()
  if not JumpUtils.bGetJumpMap then
    log(bWriteLog and "logic_lobby_system_entrance.JumpToStore RequestJumpMapInfo")
    JumpUtils.RequestJumpMapInfo(false, function()
      logic_lobby_system_entrance._JumpToStore(vars)
    end)
    return
  end
  logic_lobby_system_entrance._JumpToStore(vars)
end
function logic_lobby_system_entrance._JumpToStore(vars)
  local JumpUtils = require("client.logic.store.jump_utils")
  local JumpToStoreImpl = function(param)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
    if PublishRegionMacros.IsJapanOrKorea() then
      store_supply_switcher:OpenSupply(param)
    elseif param.moduleId and param.moduleId == JumpUtils.MODEL_ID_SUPPLY then
      store_supply_switcher:OpenSupply(param)
    else
      store_supply_switcher:OpenStore(param)
    end
  end
  if vars ~= nil then
    vars = DeepCopy(vars)
    vars.itemId = tonumber(vars.itemId or 0)
    vars.Tab1 = tonumber(vars.Tab1 or 0)
    vars.Tab2 = tonumber(vars.Tab2 or 0)
    vars.productId = tonumber(vars.productId or 0)
    if vars.Tab1 == 0 then
      local temp = JumpUtils.FindStoreProductJumpInfo(vars.productId)
      if temp == nil and vars.itemId ~= 0 then
        temp = JumpUtils.FindJumpInfoFirst(vars.itemId, JumpUtils.MODEL_ID_STORE)
      end
      if temp ~= nil then
        vars = temp
      elseif vars.from == tostring(BP_ENUM_MODULE_CLUB_TO_MALL_CHILD) then
        ShowNotice(39276)
      end
    end
  end
  logic_lobby_system_entrance.CheckOldTab(vars)
  log_tree("[tinghaohu]logic_lobby_system_entrance.JumpToStore. vars = ", vars)
  JumpToStoreImpl(vars)
end
function logic_lobby_system_entrance.CheckOldTab(vars)
  if GlobalData.IsJapanOrKorea() then
    return
  end
  if not vars then
    return
  end
  local tab1, tab2 = logic_lobby_system_entrance.ConversionTab(vars.Tab1, vars.Tab2, vars.itemId)
  log(bWriteLog and string.format("logic_lobby_system_entrance.CheckOldTab tab1 = %s, tab2 = %s", tab1, tab2))
  if tab1 then
    vars.Tab1 = tab1
  end
  if tab2 then
    vars.Tab2 = tab2
  end
end
function logic_lobby_system_entrance.ConversionTab(tab1, tab2, itemId)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local tempT1, tempT2 = tab1, tab2
  local isOldTab = false
  if tab1 == StoreConst.Page_ID_Exchange then
    tempT1, tempT2 = StoreConst.Page_ID_New_Exchange, StoreConst.label_subtype_new_exchange
    isOldTab = true
  elseif tab1 == StoreConst.Page_ID_Prime then
    tempT1, tempT2 = StoreConst.Page_ID_New_Exchange, StoreConst.label_subtype_new_prime
    isOldTab = true
  elseif tab1 == StoreConst.Page_ID_Season then
    tempT1, tempT2 = StoreConst.Page_ID_New_Exchange, StoreConst.label_subtype_new_season_mall
    isOldTab = true
  elseif tab1 == StoreConst.Page_ID_Regional_Mall then
    tempT1, tempT2 = StoreConst.Page_ID_New_Exchange, StoreConst.label_subtype_new_regional_mall
    isOldTab = true
  elseif tab1 == StoreConst.Page_ID_Item and (tab2 == StoreConst.label_subtype_treasure or tab2 == 0) then
    tempT1, tempT2 = StoreConst.Page_ID_New_Direct_Buy, StoreConst.label_subtype_new_props_direct
    isOldTab = true
  elseif tab1 == StoreConst.Page_ID_Item and tab2 == StoreConst.label_subtype_purchase then
    tempT1, tempT2 = StoreConst.Page_ID_New_Direct_Buy, StoreConst.label_subtype_new_USD_buy
    isOldTab = true
  elseif tab1 == StoreConst.Page_ID_Collect then
    isOldTab = true
  elseif tab2 == StoreConst.subtype_new_exchange_bps or tab2 == StoreConst.subtype_new_exchange_bpf then
    isOldTab = true
  end
  if tempT2 == StoreConst.label_subtype_new_props_direct and itemId then
    local cfg = CDataTable.GetTableData("Item", itemId)
    if cfg and StoreUtils.IsTreasuresAndSpecialChests(cfg.ItemType, cfg.ItemSubType) then
      tempT1 = StoreConst.Page_New_ID_Recommend
      tempT2 = StoreConst.subtype_new_recommend_ucb
    end
  end
  if isOldTab then
    tempT1, tempT2 = logic_lobby_system_entrance.NewConversionTabByConfig(tempT1, tempT2, itemId)
  end
  return tempT1, tempT2
end
function logic_lobby_system_entrance.NewConversionTabByConfig(tab1, tab2, itemId)
  local tempT1, tempT2 = tab1, tab2
  local StoreTabMapConfig = CDataTable.GetTable("StoreTabMapConfig")
  for _, cfg in pairs(StoreTabMapConfig) do
    local valid = logic_lobby_system_entrance.CheckVersion(cfg.startVersion, cfg.endVersion)
    local temp = tempT2 == 0 and tempT1 * 100 + 1 or tempT2
    if valid and cfg.oldTab == tempT1 and cfg.oldSubTab == temp then
      tempT1 = cfg.newTab
      tempT2 = cfg.newSubTab
      break
    end
  end
  if itemId ~= 0 and (tempT2 == StoreConst.subtype_new_exchange_bps or tempT2 == StoreConst.subtype_new_exchange_bpf) then
    tempT2 = logic_lobby_system_entrance.SelectBPSubTab(tempT2, itemId)
  end
  if itemId ~= 0 and tempT2 == StoreConst.subtype_new_treasure_com then
    tempT2 = logic_lobby_system_entrance.SelectTreasureSubTab(tempT2, itemId)
  end
  return tempT1, tempT2
end
function logic_lobby_system_entrance.SelectBPSubTab(tab2, itemId)
  local temp = tab2
  if itemId then
    local cfg = CDataTable.GetTableData("NonSubscriptionBPConfig", itemId)
    if cfg and logic_lobby_system_entrance.CheckVersion(cfg.startVersion, cfg.endVersion) then
      temp = StoreConst.subtype_new_exchange_bpf
    else
      temp = StoreConst.subtype_new_exchange_bps
    end
  end
  return temp
end
function logic_lobby_system_entrance.SelectTreasureSubTab(tab2, itemId)
  local temp = tab2
  if itemId and itemId ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    if not itemCfg then
      return temp
    end
    local configs = CDataTable.GetTable("StoreTabIconConfig")
    for _, cfg in pairs(configs) do
      if cfg and cfg.subTypeToSubTab ~= "" then
        local StringUtil = require("common.string_util")
        local subTypeList = StringUtil.Split(cfg.subTypeToSubTab, ";")
        for _, subType in pairs(subTypeList) do
          if tonumber(subType) == itemCfg.ItemSubType then
            return cfg.tab2Id
          end
        end
      end
    end
  end
  return temp
end
function logic_lobby_system_entrance.CheckVersion(startVersion, endVersion)
  local result = true
  local currVersion = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  if startVersion and startVersion ~= "" and not version_util.HigherVersion(currVersion, startVersion) then
    result = false
  end
  if endVersion and endVersion ~= "" and version_util.LowerVersion(currVersion, endVersion) then
    result = false
  end
  return result
end
function logic_lobby_system_entrance.JumpToCrate(eventType, eventID, vars)
  local JumpUtils = require("client.logic.store.jump_utils")
  if LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY) == false then
    return
  end
  local moneyComponentSystem = require("client.slua.logic.store.logic_money_component")
  moneyComponentSystem.GetStoreCurrencyConfig()
  if not JumpUtils.bGetJumpMap then
    log(bWriteLog and "logic_lobby_system_entrance.JumpToCrate RequestJumpMapInfo")
    JumpUtils.RequestJumpMapInfo(false, function()
      logic_lobby_system_entrance._JumpToCrate(vars)
    end)
    return
  end
  logic_lobby_system_entrance._JumpToCrate(vars)
end
function logic_lobby_system_entrance._JumpToCrate(vars)
  local JumpUtils = require("client.logic.store.jump_utils")
  if vars ~= nil then
    local store_jump_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_jump_manager)
    if not store_jump_manager:CheckEndTimeByEmail(vars) then
      return
    end
    vars = store_jump_manager:CollationJumpInfo(vars)
  end
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  store_supply_switcher:OpenSupply(vars)
end
function logic_lobby_system_entrance.OnJumpBindFB(eventType, eventID, vars)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local logic_bind_facebook = require("client.slua.logic.activity.logic_bind_facebook")
  local bindType = ActivityType.BIND_SEND_GIFT
  if not ActivityNewSystem.IsModuleOnline(logic_bind_facebook.activityId, bindType) then
    GlobalData.JumpGameUrl("game://?module=" .. BP_ENUM_MODULE_ACCOUNT_SENSITIVE_ACTION .. "&type=1")
    return
  end
  logic_bind_facebook.OpenUIByJump()
end
function logic_lobby_system_entrance.OnJumpBuyPass(eventType, eventID, vars)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.ShowRPDownloadTips() then
    return
  end
  local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
  local groupID
  if vars and vars.invitecode ~= nil then
    groupID = vars.invitecode
  end
  log(bWriteLog and "logic_lobby_system_entrance.OnJumpBuyPass groupID = " .. tostring(groupID))
  if groupID == nil then
    UnknowPassBuyActSystem.OpenBuyActUI(groupID)
  else
    UnknowPassBuyActSystem.OpenBuyActUIFromInviteURL(groupID)
  end
end
function logic_lobby_system_entrance.OnJumpCorps()
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_CORPS) then
    return
  end
  LobbySystem.CloseOtherMenu()
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.OpenCorpsUI()
end
function logic_lobby_system_entrance.JumpLuckyPack(eventType, eventID, params)
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.OpenMainUI(eventType, eventID, params)
end
function logic_lobby_system_entrance.JumpLuckyVehicle(eventType, eventID, params)
  local LogicHalloweenVehicle = require("client.logic.activity.logic_halloween_vehicle")
  LogicHalloweenVehicle.OpenUI()
end
function logic_lobby_system_entrance.JumpPurchase(eventType, eventID, params)
  local activityId = tonumber(params.dpid)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actInfo = ActivityNewSystem.GetActivityByID(activityId)
  if not actInfo then
    ShowNotice(4002)
    log(bWriteLog and "[LobbyUI.ShowDirectPurchaseBanner] has none Direct_Purchase_By_Ativity activity info!!!")
    return
  end
  if UIManager then
    local ui = UIManager.ShowUI(UIManager.UI_Config.direct_purchase_banner)
    ui:InitUI(activityId)
  end
end
function logic_lobby_system_entrance.OnGetWegameUrl(eventType, eventID, vars)
  log_tree("LobbyUI.OnGetWegameUrl", vars)
  local logic_platform = require("client.slua.logic.setting.logic_platform")
  local platform = "wegame"
  if vars.platform ~= nil then
    platform = vars.platform
  end
  if logic_platform then
    local handler = function()
      if logic_platform.IsBindingPlatform(platform) then
        ShowNotice(7101)
        return
      end
      if logic_platform.CheckIsRegionAvailable(platform) then
        logic_platform.SetPlatformInfo(platform, vars)
        if UIManager then
          local ui = UIManager.ShowUI(UIManager.UI_Config.setting_platform_popup)
          ui:InitBindingUI(platform)
        end
      else
        ShowNotice(7051)
      end
    end
    if logic_platform.platformInfo[platform] == nil then
      logic_platform.getInfoHandler = handler
    else
      handler()
    end
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  AdjustSystem:ClearAdjustDeepLink()
end
function logic_lobby_system_entrance.OnGetRecruitUrl(eventType, eventID, vars)
  local LogicRecruit = require("client.slua.logic.recruit.logic_recruit_newer")
  if vars.invitecode ~= nil then
    LogicRecruit:GetRecruitedAward(vars.invitecode, 1)
  else
    UIManager.ShowUI(UIManager.UI_Config.recruit_main)
  end
end
function logic_lobby_system_entrance.UpdateActivityBtnList()
  LobbySystem.QueryActivityDisplayStatus()
end
function logic_lobby_system_entrance.OnLobbyNextDayHandler()
  log(bWriteLog and "LobbyUI.OnLobbyNextDayHandler")
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.shop_itemlist_req(16)
  ShopSystem.shop_itemlist_req(17)
end
function logic_lobby_system_entrance.OnLobbyRedPointUpdate(eventType, eventID, menuId, show)
  LobbySystem.LobbyRedPointUpdate(menuId, show)
end
function logic_lobby_system_entrance.UpdateGoldenSuitPopEvent()
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  giftSystem.PopCommonTip()
end
function logic_lobby_system_entrance.OnSeasonKing()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing")
  local logic_season_const = require("client.logic.season.logic_season_const")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if not LobbySystem.CheckOpen(BP_ENUM_BIG_SEGMENT_UP_VIDEO_SWITCH) then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "switchClose")
    log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing BP_ENUM_BIG_SEGMENT_UP_VIDEO_SWITCH false")
    logic_lobby_system_entrance.ShowSeasonSlapFace2()
    return logic_season_const.PlayConquerorVideoResult.SwitchClose
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  if nDeviceLevel < 1 then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "lowDevice")
    log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing nDeviceLevel:" .. tostring(nDeviceLevel))
    logic_lobby_system_entrance.ShowSeasonSlapFace2()
    return logic_season_const.PlayConquerorVideoResult.LowDevice
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local bigSegmentUpConfig = promotion_match_util.GetBigSementUpConfig(10)
  if not (bigSegmentUpConfig and bigSegmentUpConfig.VideoPath) or bigSegmentUpConfig.VideoPath == "" then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "invalidConfig")
    log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing config error")
    logic_lobby_system_entrance.ShowSeasonSlapFace2()
    return logic_season_const.PlayConquerorVideoResult.ConfigError
  end
  if not VideoLibrary.IsVideoFileReady(bigSegmentUpConfig.VideoPath) then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "notDownloadVideo")
    log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing not download")
    logic_lobby_system_entrance.ShowSeasonSlapFace2()
    return logic_season_const.PlayConquerorVideoResult.NotDownloadVideo
  end
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, logic_lobby_system_entrance.OnKingVideoEnd)
  logic_lobby_system_entrance.KingVideoPath = bigSegmentUpConfig.VideoPath
  local playResult = VideoLibrary.PlayVideo(bigSegmentUpConfig.VideoPath)
  log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing playResult = " .. tostring(playResult))
  if playResult == true then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "playVideoSuccess1")
    logic_lobby_system_entrance.ShowSeasonSlapFace2()
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.01, function()
      local slap_ui = UIManager.GetUI(UIManager.UI_Config.ui_season_slapface2_s47)
      if slap_ui then
        slap_ui:Hide()
      else
        log(bWriteLog and "logic_lobby_system_entrance.OnSeasonKing slap_ui is nil")
      end
    end)
    return logic_season_const.PlayConquerorVideoResult.Success
  else
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "playVideoFailed")
    logic_lobby_system_entrance.KingVideoPath = nil
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, logic_lobby_system_entrance.OnKingVideoEnd)
    logic_lobby_system_entrance.ShowSeasonSlapFace2()
    return logic_season_const.PlayConquerorVideoResult.PlayFailed
  end
end
function logic_lobby_system_entrance.OnKingVideoEnd(_, _, filePath)
  log(bWriteLog and "logic_lobby_system_entrance.OnKingVideoEnd filePath:" .. tostring(filePath))
  if not filePath or filePath == logic_lobby_system_entrance.KingVideoPath then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "playVideoSuccess2")
    logic_lobby_system_entrance.KingVideoPath = nil
    local slap_ui = UIManager.GetUI(UIManager.UI_Config.ui_season_slapface2_s47)
    if slap_ui then
      slap_ui:Show()
    end
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, logic_lobby_system_entrance.OnKingVideoEnd)
  end
end
function logic_lobby_system_entrance.ShowSeasonSlapFace2()
  log(bWriteLog and "SeasonSystem.ShowSeasonSlapFace2")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
  UIManager.ShowUI(UIManager.UI_Config.ui_season_slapface2_s47, info)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
  local AceImprintHandler = require("client.network.Protocol.AceImprintHandler")
  AceImprintHandler.send_get_ace_imprint_detail_req(tonumber(DataMgr.roleData.uid))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  local aceImprintBaseId = AceImprintLogic.GetCurSeasonBestImprintID()
  if aceImprintBaseId then
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem._pendingImprintBaseId = aceImprintBaseId
    SeasonSystem.ShowImprintSlap()
  end
end
function logic_lobby_system_entrance.OnRedPointInfoUpdate()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
end
function logic_lobby_system_entrance.OnServerChange()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local bIsolate = false
  local tRoleWear = AvatarData.GetRoleWear()
  if tRoleWear then
    for _, v in pairs(tRoleWear) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo ~= nil and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
        bIsolate = true
        break
      end
    end
  end
  if not bIsolate then
    local weaponId = DataMgr.GetCurrentWeaponID()
    if wardrobeLogic:IsItemIsolated(weaponId) then
      bIsolate = true
    end
  end
  if not bIsolate and DataMgr.Extra_Weapon_Info_List then
    for _, v in pairs(DataMgr.Extra_Weapon_Info_List) do
      local weaponID = DataMgr.GerExtraWeaponID(v.weapon_id, v.skin_id, v.is_using_recommend, v.cur_use_plan)
      if wardrobeLogic:IsItemIsolated(weaponID) then
        bIsolate = true
        break
      end
    end
  end
  if not bIsolate then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local parachuteId = fashionbag_data:GetParachute()
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(parachuteId)
    if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
      bIsolate = true
    end
  end
  if not bIsolate then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local planeSkinInsID = fashionbag_data:GetPlanSkin()
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(planeSkinInsID)
    if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
      bIsolate = true
    end
  end
  if not bIsolate then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local wingmanSkinInsID = fashionbag_data:GetWingmanSkin()
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(wingmanSkinInsID)
    if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
      bIsolate = true
    end
  end
  if not bIsolate then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local gliding = fashionbag_data:GetAircraftOrGliding()
    local glidingID = gliding
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(glidingID)
    if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
      bIsolate = true
    end
  end
  if not bIsolate then
    local footEffectInsID = DataMgr.foot_special_effect_id
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(footEffectInsID)
    if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
      bIsolate = true
    end
  end
  if not bIsolate then
    for k, v in pairs(DataMgr.vehicleSkinInsIDTable) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
        bIsolate = true
        break
      end
    end
  end
  if not bIsolate then
    for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo and wardrobeLogic:IsItemIsolated(itemInfo.resID) then
        bIsolate = true
        break
      end
    end
  end
  if bIsolate then
    ShowNotice(4986)
  end
  TeamAvatarManager.PutoffInvalidEquipments()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
end
function logic_lobby_system_entrance.OnJumpItemUpgrade(eventType, eventID, vars)
  if vars then
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop, BP_ENUM_ITEM_UPGRADE) then
      ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.item_upgrade, vars.itemId)
  end
end
function logic_lobby_system_entrance.PlayerDataChange(eventType, eventID, vars, isClickReward)
  if eventType ~= EVENTTYPE_DATA_MGR then
    return
  end
  if eventID == EVENTID_DATAMGR_ROLE_LEVEL_CHANGE then
    local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
    local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
    log(bWriteLog and "logic_lobby_system_entrance.PlayerDataChange bLevelUnlockSwitchOpen = " .. tostring(bLevelUnlockSwitchOpen))
    if not bLevelUnlockSwitchOpen then
      if GameStatus.IsInLobbyOrMainCity() then
        log(bWriteLog and "remm levelup lobby direct popup")
        BP_LevelChange = true
        if isClickReward == 0 then
          local LevelUpSystem = require("client.logic.levelup.logic_levelup")
          LevelUpSystem.OpenLevelupPanel()
        else
          log(bWriteLog and "logic_lobby_system_entrance.PlayerDataChange is MinitvOneClickReward")
        end
        BP_LevelChange = false
        local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
        CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.unlock)
      else
        log(bWriteLog and "remm levelup lobby BP_LevelChange true")
        BP_LevelChange = true
      end
    end
  elseif eventID == EVENTID_DATAMGR_ROLE_EXP_CHANGE then
    log(bWriteLog and "EVENTID_DATAMGR_ROLE_EXP_CHANGE")
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    if level_unlock_manager:NeedShowLevelup() then
      log(bWriteLog and "need show levelup in level unlock UIManager")
      if GameStatus.IsInLobbyOrMainCity() then
        log(bWriteLog and "show levelup in lobby" .. tostring(isClickReward))
        if isClickReward == 0 then
          level_unlock_manager:OpenLevelupPanel()
        else
          log(bWriteLog and "logic_lobby_system_entrance.PlayerDataChange is MinitvOneClickReward")
        end
        local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
        CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.unlock)
      end
    end
  elseif eventID == EVENTID_DATAMGR_PVE_LEVEL_CHANGE then
    log(bWriteLog and "EVENTID_DATAMGR_PVE_LEVEL_CHANGE:" .. tostring(vars))
    local LevelUpSystem = require("client.logic.levelup.logic_levelup")
    if LevelUpSystem and GameStatus.IsInLobbyOrMainCity() then
      LevelUpSystem.IsPveLevelUp = true
    elseif LevelUpSystem then
      log(bWriteLog and "pve levelup lobby BP_LevelChange true")
      LevelUpSystem.IsPveLevelUp = true
    end
  end
end
function logic_lobby_system_entrance.lobbyEventHandler(eventType, eventID, vars)
  GameStatus.SwitchToLobbyState()
  if not logic_lobby_system_entrance.HasSend_get_championship_info then
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_get_championship_info()
    logic_lobby_system_entrance.HasSend_get_championship_info = true
  end
  if not logic_lobby_system_entrance.HasSend_commerce_entrance_info then
    local logic_lobby_mid_entrance = require("client.slua.logic.lobby.Mid.logic_lobby_mid_entrance")
    logic_lobby_mid_entrance.SendCommerceEntranceInfoReq()
    logic_lobby_mid_entrance.HasSend_commerce_entrance_info = true
  end
end
function logic_lobby_system_entrance.OpenBan()
  local ban_reddot_system = require("client.slua.logic.ban_reddot.ban_reddot_system")
  ban_reddot_system.EnterSafeStation()
end
function logic_lobby_system_entrance.OpenReport()
  local LogicReportBug = require("client.logic.battle.logic_reportbug")
  LogicReportBug.ShowLobbyReportPanel()
end
function logic_lobby_system_entrance.OpenXunYou()
  local GameMasterSystem = require("client.slua.logic.gamemaster.logic_gamemaster")
  GameMasterSystem.OpenGameMasterRechargePage()
end
return logic_lobby_system_entrance