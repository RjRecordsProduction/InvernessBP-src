local data_config_marco = require("client.logic.data.data_config_marco")
local LadderDrawSystem = {
  defaultShowingUIKey = "apollo_car_main",
  svrDrawData = {},
  svrRandomAwardData = {},
  nShowingActivityID = 0,
  sShowingUIKey = nil,
  notShowFreeTip = {},
  notShowConfirmTip = {},
  luckyRebate = nil,
  drawFinishedStep = nil,
  bIsUpdateAward = false,
  bIsRandowAwardRsp = true,
  svrStoreData = nil,
  cltStoreData = nil,
  curCarView = 2,
  isJumpAnimation = {},
  havePlayedEntranceAnim = false,
  bNeedAdjustPosZ = false,
  bIsDrawing = false,
  bIsTriggerLucky = false,
  bIsDrawRsp = false,
  rspTimer = nil,
  bSkipRetryPlay = false,
  poolConfig = {},
  priceConfig = {},
  levelConfig = {},
  drawpoolConfig = {},
  tResDownloadList = {},
  tSportsCarGetList = {},
  CONST = {
    E_AwardPoolActiveType = {
      Idle = 0,
      Active = 1,
      Finish = 2
    },
    E_DrawOperateType = {Free = 1, Pay = 2},
    E_UICfg = {
      porsche_car_main = "client.slua.umg.lobby_activity.SportsCarSpin.4100.SportsCar4100_UIConfig",
      apollo_car_main = "client.slua.umg.lobby_activity.SportsCarSpin.4300.SportsCar4300_UIConfig"
    },
    E_StoreUIToCarUICfg = {
      porsche_car_store_4100 = "porsche_car_main",
      apollo_car_store_4300 = "apollo_car_main"
    },
    C_ServerConfigName = data_config_marco.lotter_client_table,
    C_ServerParamConfigName = data_config_marco.lottery_common_table,
    C_UIkeyList = {
      "Maserati_main_230",
      "Bugatti_car_250"
    },
    C_GiftOpen = {global = 20146, blueHole = 20147}
  },
  ENUM_REBATE_TYPE = {UC = 1, LuckyTicket = 2}
}
function LadderDrawSystem.IsOpen(activity_id)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local TimeUtil = require("client.common.time_util")
  for _, v in ipairs(ActivityNewSystem.data) do
    if v.ID == activity_id then
      local now = TimeUtil.GetServerTimeInSec()
      if now > v.StartTime and now < v.EndTime then
        return true
      end
    end
  end
  return false
end
function LadderDrawSystem.SetUIKeyByTabId(supplyTabId)
  if not GlobalData.IsJapanOrKorea() then
    return
  end
  for uikey, _ in pairs(LadderDrawSystem.CONST.E_UICfg) do
    local config = LadderDrawSystem.GetUIConfig(uikey)
    if config and type(config) == "table" and supplyTabId == config.KJSuppyTabId then
      LadderDrawSystem.defaultShowingUIKey = uikey
      break
    end
  end
end
function LadderDrawSystem.ShowUI(_, _, vars)
  log_tree("LadderDrawSystem.ShowUI vars:", vars)
  local actID = tonumber(vars.activityid)
  if not actID then
    ShowNotice(120101)
    log_warning(bWriteLog and "[cw][ladderDraw] not actID")
    return
  end
  LadderDrawSystem.activityId = actID
  local uiKey = vars.ui
  LadderDrawSystem.defaultShowingUIKey = uiKey
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetStateByModuleIDActivityID(nil, actID)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log_warning(bWriteLog and "[cw][ladderDraw] not downloaded")
    return
  end
  log(bWriteLog and "[cw][ladderDraw] actID:" .. tostring(actID))
  log(bWriteLog and "[cw][ladderDraw] uiKey:" .. tostring(uiKey))
  local actData = LadderDrawSystem.GetActData(actID)
  local config = LadderDrawSystem.GetUIConfig(uiKey)
  if not (actData and type(actData) == "table" and next(actData) and config) or type(config) ~= "table" or not next(config) then
    log_error(bWriteLog and "[cw][xpcall] actData or uiConfig is nil")
    ShowNotice(9960027)
    return
  end
  local paramCfg = LadderDrawSystem.GetParamConfig(actID)
  if not paramCfg or type(paramCfg) ~= "table" or not next(paramCfg) then
    log_error(bWriteLog and "[cw][xpcall] lottery_common_table's data is nil")
    ShowNotice(9960027)
    return
  end
  local awardPoolCfg = LadderDrawSystem.GetAwardPoolAndPriceConfig(actID)
  if not awardPoolCfg or type(awardPoolCfg) ~= "table" or not next(awardPoolCfg) then
    log_error(bWriteLog and "[cw][xpcall] lotter_client_table's data is nil")
    ShowNotice(9960027)
    return
  end
  if LadderDrawSystem.IsOpen(actID) then
    LadderDrawSystem.sShowingUIKey = uiKey
    UIManager.ShowUI(UIManager.UI_Config.SportsCarSpinContainer, actID, vars.jumpReturn)
  else
    log_warning(bWriteLog and "[cw][ladderDraw] activity is closed")
    ShowNotice(4002)
  end
end
function LadderDrawSystem.CloseMainUI()
  LadderDrawSystem.luckyRebate = nil
  UIManager.CloseUI(UIManager.UI_Config.SportsCarSpinBrand)
  UIManager.CloseUI(UIManager.UI_Config.SportsCarSpinContainer)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  log(bWriteLog and "LadderDrawSystem.CloseMainUI()  " .. tostring(LadderDrawSystem.activityId))
  ActivityHandler.send_get_activity_one_req(LadderDrawSystem.activityId)
  LadderDrawSystem.svrDrawData = {}
end
function LadderDrawSystem.OpenCarStore(_, _, vars)
  local ui = vars.car or "ld_car_store"
  local mainUIKey = LadderDrawSystem.CONST.E_StoreUIToCarUICfg[ui]
  if not mainUIKey then
    log_error(bWriteLog and "[cw] mainUIKey is error, Please check the config")
    return
  end
  local activityID = vars.activityid or LadderDrawSystem.activityId
  if activityID then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetStateByModuleIDActivityID(nil, activityID)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
  end
  LadderDrawSystem.sShowingUIKey = mainUIKey
  LadderDrawSystem.defaultShowingUIKey = mainUIKey
  UIManager.ShowUI(UIManager.UI_Config.SportsCarExchangeContainer, tonumber(vars.tab), tonumber(vars.activityid or LadderDrawSystem.activityId), tonumber(vars.nVehicleItemID or 0))
end
function LadderDrawSystem.OnLogin()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(LadderDrawSystem.CONST.C_ServerConfigName)
  BasicDataServerTable:GetOrReqData(LadderDrawSystem.CONST.C_ServerParamConfigName)
end
function LadderDrawSystem.OnModePostSwitch(preState, nextState)
  if nextState ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    LadderDrawSystem.Clear()
  end
end
function LadderDrawSystem.Clear()
  LadderDrawSystem.svrDrawData = {}
  LadderDrawSystem.svrRandomAwardData = {}
  LadderDrawSystem.nShowingActivityID = 0
end
function LadderDrawSystem.GetActData(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  for _, v in ipairs(ActivityNewSystem.data) do
    if v.ID == activity_id then
      return v
    end
  end
  return nil
end
function LadderDrawSystem.GetUIConfig(uiKey)
  uiKey = uiKey or LadderDrawSystem.sShowingUIKey or LadderDrawSystem.defaultShowingUIKey
  if LadderDrawSystem.CONST.E_UICfg[uiKey] then
    return require(LadderDrawSystem.CONST.E_UICfg[uiKey])
  end
  log_error(bWriteLog and "[cw] can't find uiCfg base one UIkey: " .. tostring(uiKey))
  return nil
end
function LadderDrawSystem.GetAwardPoolAndPriceConfig(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local config = BasicDataServerTable:GetCacheData(LadderDrawSystem.CONST.C_ServerConfigName)
  if not config then
    return {}
  end
  return config[activity_id] or {}
end
function LadderDrawSystem.GetAwardPoolAndPriceConfig_Autoestudio()
  local config = LadderDrawSystem.priceConfig
  if not config then
    return {}
  end
  return config or {}
end
function LadderDrawSystem.sGetAwardPoolAndPriceConfig_Autoestudio()
  local config = LadderDrawSystem.levelConfig
  if not config then
    return {}
  end
  return config or {}
end
function LadderDrawSystem:GetSmallPool()
  local config = LadderDrawSystem.poolConfig
  if not config then
    return {}
  end
  return config or {}
end
function LadderDrawSystem.GetParamConfig(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local config = BasicDataServerTable:GetCacheData(LadderDrawSystem.CONST.C_ServerParamConfigName)
  if not config then
    return {}
  end
  return config[activity_id] or {}
end
function LadderDrawSystem.SetShowingActivityID(activity_id)
  log(bWriteLog and "[sports_car][activity] LadderDrawSystem.SetShowingActivityID activity_id: " .. tostring(activity_id))
  LadderDrawSystem.nShowingActivityID = activity_id
  if not activity_id or activity_id == 0 then
    LadderDrawSystem.sShowingUIKey = nil
  end
end
function LadderDrawSystem.SetNotShowFreeTip(flag, activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  LadderDrawSystem.notShowFreeTip[activity_id] = flag
end
function LadderDrawSystem.GetNotShowFreeTip(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  return LadderDrawSystem.notShowFreeTip[activity_id]
end
function LadderDrawSystem.SetNotShowConfirmTip(flag, activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  LadderDrawSystem.notShowConfirmTip[activity_id] = flag
end
function LadderDrawSystem.GetNotShowConfirmTip(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  return LadderDrawSystem.notShowConfirmTip[activity_id]
end
function LadderDrawSystem.GetDrawData(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  if LadderDrawSystem.svrDrawData[activity_id] then
    return LadderDrawSystem.svrDrawData[activity_id]
  end
  local data = LadderDrawSystem.GetActData(activity_id)
  if not data then
    return nil
  end
  return data.other
end
function LadderDrawSystem.GetRandomAwardData(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  log(bWriteLog and "[ljw] nShowingActivityID" .. tostring(LadderDrawSystem.nShowingActivityID))
  log_tree("[ljw] self.svrRandomAwardData1111", LadderDrawSystem.svrRandomAwardData)
  if LadderDrawSystem.svrRandomAwardData[activity_id] then
    return LadderDrawSystem.svrRandomAwardData[activity_id]
  end
  local data = LadderDrawSystem.GetActData(activity_id)
  if not data then
    return nil
  end
  log_tree("[ljw] data", data)
  return data.other
end
function LadderDrawSystem.SplitAwardData(award_data)
  if not award_data then
    return
  end
  local data = {
    [1] = {
      resid = award_data.resid,
      count = 2,
      valid_hours = award_data.valid_hours
    },
    [2] = {
      resid = award_data.resid,
      count = 1,
      valid_hours = award_data.valid_hours,
      is_extra_bonus = true
    }
  }
  return data
end
function LadderDrawSystem.GetGiftOpenCfg()
  return LadderDrawSystem.CONST.C_GiftOpen or {}
end
function LadderDrawSystem.IsINDOrKR()
  local prm = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  local publishRegion = Client.GetPublishRegion()
  log(bWriteLog and "[cw] publishRegion:" .. tostring(Client.GetPublishRegion()))
  log(bWriteLog and "[cw] accountRegionForBP:" .. tostring(FuncUtil.GetAccountRegionForBP()))
  if GlobalData.IsJapanOrKorea() and FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.KR then
    log(bWriteLog and "[cw] publishRegion == prm.KOREA and FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.KR ")
    return true
  elseif publishRegion == prm.BLUEHOLE then
    log(bWriteLog and "[cw] publishRegion == prm.BLUEHOLE ")
    return true
  else
    log(bWriteLog and "[cw] publishRegion is other ")
    return false
  end
end
function LadderDrawSystem.IsINDOrJPKP()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local publishRegion = Client.GetPublishRegion()
  log(bWriteLog and "publishRegion:" .. tostring(Client.GetPublishRegion()))
  return publishRegion == PublishRegionMacros.JAPAN or publishRegion == PublishRegionMacros.KOREA or publishRegion == PublishRegionMacros.BLUEHOLE
end
function LadderDrawSystem.GetTriggerRebateType()
  local ucId = 1006
  if LadderDrawSystem.luckyRebate then
    if LadderDrawSystem.luckyRebate.resid == ucId then
      return LadderDrawSystem.ENUM_REBATE_TYPE.UC
    else
      return LadderDrawSystem.ENUM_REBATE_TYPE.LuckyTicket
    end
  end
  return
end
function LadderDrawSystem.IsGetThreeKey()
end
function LadderDrawSystem.GetLadder(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local data = LadderDrawSystem.GetDrawData(activity_id)
  if data then
    return data.pos or 0
  end
  return 0
end
function LadderDrawSystem.GetLadder_Autoestudio(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local data = LadderDrawSystem.GetDrawData(activity_id)
  if data then
    return data.level_id or 0
  end
  return 0
end
function LadderDrawSystem.IsMaxLadder(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local ladder = LadderDrawSystem.GetLadder(activity_id)
  local config = LadderDrawSystem.GetAwardPoolAndPriceConfig()
  if 0 < ladder and config[ladder] and (config[ladder].paid_count == 0 or not config[ladder].paid_count) then
    return true
  end
  return false
end
function LadderDrawSystem.IsMaxLadder_Autoestudio(activity_id)
  activity_id = activity_id or LadderDrawSystem.nShowingActivityID
  local ladder = LadderDrawSystem.GetLadder_Autoestudio(activity_id)
  local config = LadderDrawSystem.GetUIConfig()
  log(bWriteLog and "[ljw] config.maxLadder" .. tostring(config.maxLadder))
  if 0 < ladder and ladder == config.maxLadder then
    return true
  end
  return false
end
function LadderDrawSystem.SetLoadStreamLevel(bForceNormal)
  if DataMgr.season_id >= 20 and not bForceNormal then
    local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
    logic_lobby_garage_scene.UpdateCurrSystemType(logic_lobby_garage_scene.LoadSystemType.Store)
    local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
    logic_SuperCar_200Version.SetNextCreateInfo({
      DefaultCameraOffset = {Y = 0.0}
    })
    logic_lobby_garage_scene.LoadSuperCarVehicleScene()
  else
    local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
    logic_lobby_garage_scene.LoadVehicleCenterCamera()
    logic_lobby_garage_scene.LoadVehicleScene()
  end
end
function LadderDrawSystem.DestoryStreamLevel(bForceNormal)
  local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
  local seasonID = tonumber(DataMgr.season_id)
  if 20 <= seasonID and not bForceNormal then
    logic_lobby_garage_scene.UnLoadSuperCarVehicleScene()
  else
    logic_lobby_garage_scene.UnLoadVehicleScene()
  end
end
function LadderDrawSystem.OnRotateRsp(info)
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_BEGIN_LOTTERY)
  log_tree("[edward][logic_ladder_draw] LadderDrawSystem.OnRotateRsp", info)
  if not LadderDrawSystem.svrDrawData then
    LadderDrawSystem.svrDrawData = {}
  end
  if info.extra_award then
    LadderDrawSystem.luckyRebate = info.extra_award[1]
    if LadderDrawSystem.luckyRebate then
      LadderDrawSystem.luckyRebate.lastUcNum = DataMgr.ticket
    end
  end
  LadderDrawSystem.svrDrawData[info.activity_id] = info
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_ROTATE)
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_PLAY_FLY_COIN_ANIMATION)
end
function LadderDrawSystem.OnRotateError()
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_ROTATE_ERROR)
end
function LadderDrawSystem.OnRandomAwardRsp(info)
  log_tree("[edward][logic_ladder_draw] LadderDrawSystem.OnRandomAwardRsp", info)
  if not LadderDrawSystem.svrRandomAwardData then
    LadderDrawSystem.svrRandomAwardData = {}
  end
  LadderDrawSystem.svrRandomAwardData[info.activity_id] = info
  log_tree("[ljw] info", info)
  log_tree("[ljw] self.svrRandomAwardData", LadderDrawSystem.svrRandomAwardData)
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_RANDOM_AWARD)
  if LadderDrawSystem.bIsUpdateAward then
    EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_RANDOM_AWARD_UPDATE)
  end
  LadderDrawSystem.bIsRandowAwardRsp = true
  LadderDrawSystem.bIsUpdateAward = false
end
function LadderDrawSystem.OnRecvAwardRsp(info)
  log_tree("[edward][logic_ladder_draw] LadderDrawSystem.OnRecvAwardRsp", info)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if info.decompose_list and info.decompose_list[1] then
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(info.reward_list, info.decompose_list)
    if info.reward_list and info.reward_list[1] then
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local tRewardItemCfg = CDataTable.GetTableData("Item", info.reward_list[1].resid)
      local tDecomposeItemCfg = CDataTable.GetTableData("Item", info.decompose_list[1].resid)
      local sGetRewardDesc = LocUtil.LocalizeResFormat(6345, tRewardItemCfg.ItemName, info.decompose_list[1].count, tDecomposeItemCfg.ItemName)
      ShowNotice(sGetRewardDesc)
    end
  elseif info.real_list[1].count > 2 and LadderDrawSystem.IsMaxLadder() then
    local split_award_data = LadderDrawSystem.SplitAwardData(info.real_list[1])
    Logic_CommonItemGet.ShowPanel_DefaultStyle(split_award_data)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(info.real_list)
  end
  if LadderDrawSystem.svrDrawData then
    LadderDrawSystem.svrDrawData[info.activity_id] = nil
  end
  if LadderDrawSystem.svrRandomAwardData then
    LadderDrawSystem.svrRandomAwardData[info.activity_id] = nil
  end
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_DRAW_RECV_AWARD)
end
function LadderDrawSystem.SetWaitRotateFlag(bWaitRotate)
  LadderDrawSystem.end
function LadderDrawSystem.GetWaitRotateFlag()
  return LadderDrawSystem.bWaitRotate
end
function LadderDrawSystem.IsForceCloseMainUI()
  local time_ticker = require("common.time_ticker")
  if LadderDrawSystem.rspTimer then
    time_ticker.RemoveTimer(LadderDrawSystem.rspTimer)
  end
  LadderDrawSystem.rspTimer = time_ticker.AddTimerOnce(10, function()
    if not LadderDrawSystem.bIsDrawRsp then
      LadderDrawSystem.CloseMainUI()
    end
    time_ticker.RemoveTimer(LadderDrawSystem.rspTimer)
    return
  end)
end
function LadderDrawSystem.OpenMainUiById(_, _, var)
  log(bWriteLog and "OpenMainUiById")
  LadderDrawSystem.uiKey = var.ui
  LadderDrawSystem.jumpReturn = var.jumpReturn
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.send_get_draw_act_info_req(tonumber(var.id))
end
function LadderDrawSystem.GetPoolItemShow(index)
  local level = LadderDrawSystem.GetLadder_Autoestudio()
  if level == 0 then
    level = 1
  end
  local tmp = {}
  for _, v in pairs(LadderDrawSystem.poolConfig[level]) do
    if v.optype == index then
      table.insert(tmp, v)
    end
  end
  return tmp
end
function LadderDrawSystem.GetNowGrandCnt(level)
  return LadderDrawSystem.levelConfig[level].guar_need_cnt
end
function LadderDrawSystem.ShowSportsCarShare(itemID, callback)
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if not LadderCarDetailConfig.IsRareCar(itemID) then
    return
  end
  local util = require("client.slua_ui_framework.util")
  local config = LadderDrawSystem.GetUIConfig()
  local TableUtil = require("common.table_util")
  local uiConfigKey = TableUtil.GetTableValue(config, "uiConfigs", "share", "uiConfigKey")
  local bpPath = TableUtil.GetTableValue(config, "uiConfigs", "share", "bp")
  if not bpPath then
    log_error(bWriteLog and "[sports_car] ShowSportsCarShare: bpPath is nil")
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {bpPath})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local giftData = require("client.slua.umg.NewStoreV280.NewStoreMove.handsel.shop_gift_data")
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    local tGiftData = giftData.GetIndexDataList(giftSystem.GetGiftRecvList(), giftSystem.GetClickIndex())
    local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
    ShopGiftPacketLogic.ShowShare(tGiftData)
    return
  end
  UIManager.UI_Config[uiConfigKey].path = bpPath
  local logic_community = require("client.slua.logic.community.logic_community")
  local shareCfg = {
    sceneType = 1,
    nItemId = itemID,
    actId = itemID,
    campaign = "vehicleGetPanel_astonmartin_270",
    share_type = ShareBtnTLogShareTypeDefine.Congratulations,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      itemId = itemID
    }),
    checkargs = {
      {
        name = LocUtil.GetLocalizeResStr(49681),
        bopen = true,
        widgetName = "TextBlock_uid"
      }
    },
    clubShareParams = {
      bShowShareClub = logic_community.CheckItemCanShare(itemID),
      publishFeedType = logic_community.PublishFeedType.GotItem,
      gameScene = logic_community.GameScene.GotItemShare,
      itemId = itemID
    }
  }
  util.ShowShareWithUICfg(UIManager.UI_Config.ShareinterfaceFull_UIBP, shareCfg, UIManager.UI_Config[uiConfigKey], itemID, callback)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.KonisekSportsCarTurntableSharing, nil, itemID)
end
function LadderDrawSystem.SaveSportCarDrawLocalData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSportCarDrawInfo) or {}
  localData[LadderDrawSystem.activityId] = true
  PlayerPrefsSystem.SaveTableToFile_N(localData, PlayerPrefsSystem.ePlayerPrefsType.eSportCarDrawInfo)
end
function LadderDrawSystem.GetIsPopupUpgradePanel()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSportCarDrawInfo)
  if not localData or not localData[LadderDrawSystem.activityId] then
    return true
  end
  return false
end
function LadderDrawSystem.OpenSportsCarGet()
  if LadderDrawSystem.tSportsCarGetList[1] then
    local TableUtil = require("common.table_util")
    local config = LadderDrawSystem.GetUIConfig(LadderDrawSystem.defaultShowingUIKey)
    local cfg = TableUtil.GetTableValue(config, "uiConfigs", "get")
    local ui_cfg = UIManager.UI_Config.SportsCarGet
    ui_cfg.path = cfg.bp
    UIManager.ShowUI(ui_cfg, LadderDrawSystem.tSportsCarGetList[1])
    table.remove(LadderDrawSystem.tSportsCarGetList, 1)
  else
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ITEM_GET_RARE_DONE)
  end
end
function LadderDrawSystem.GetGiveCarUIConfig()
  local TableUtil = require("common.table_util")
  local config = LadderDrawSystem.GetUIConfig(LadderDrawSystem.defaultShowingUIKey)
  local cfg = TableUtil.GetTableValue(config, "uiConfigs", "give")
  if not cfg then
    log_error(bWriteLog and "[cw] common_vehicle_give_panel: cfg is nil")
    return
  end
  local luaPath = TableUtil.GetTableValue(cfg, "lua")
  if not luaPath then
    log_error(bWriteLog and "[cw] common_vehicle_give_panel: class is nil")
    return
  end
  local bpPath = TableUtil.GetTableValue(cfg, "bp")
  if not bpPath then
    log_error(bWriteLog and "[cw] common_vehicle_give_panel: ui is nil")
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.IsExistBlueprintPath(bpPath) then
    return
  end
  return luaPath, bpPath
end
function LadderDrawSystem.OnRecvThemeExchangeRsp(award_item)
  log(bWriteLog and "LadderDrawSystem.OnRecvThemeExchangeRsp  ")
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(award_item)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RECEIVED_GARAGE)
end
function LadderDrawSystem.SetSkipRetryPlay(bSkipRetryPlay)
  LadderDrawSystem.end
return LadderDrawSystem