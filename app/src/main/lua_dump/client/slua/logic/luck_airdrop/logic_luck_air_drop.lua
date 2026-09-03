local LuckAirDropSystem = {
  LuckAirData = {},
  _AirDataNum = 0,
  _DelayLobbyCreate = nil,
  LastSelectIndex = 0,
  LastSelectSubIndex = 0,
  _NeedShowPopup = false,
  _CurEquipedList = nil,
  target_airdrop_data = {},
  AirDropType = 0,
  _nNeedUCCount = 0
}
local local NCurPage = ENUM_LobbyPageType.Mid
local LoadResourceCfg = false
function LuckAirDropSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[ :LuckAirDropSystem.OnModePostSwitch   nextState" .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, LuckAirDropSystem.OnSwitchToPageEnd)
  end
end
function LuckAirDropSystem.OnSwitchToPageEnd(_, _, _, toPage)
  log(bWriteLog and "LuckAirDropSystem:OnSwitchToPageEnd toPage" .. tostring(toPage))
  NCurPage = toPage
  if toPage == ENUM_LobbyPageType.Mid then
    if LuckAirDropSystem.CanShowPopup() then
      LuckAirDropSystem.ShowPopup()
    end
  else
    local ui = UIManager.GetUI(UIManager.UI_Config.LuckyAirDrop_FaceSlap_UIBP)
    if ui then
      UIManager.CloseUI(UIManager.UI_Config.LuckyAirDrop_FaceSlap_UIBP)
      LuckAirDropSystem._NeedShowPopup = true
    end
  end
end
function LuckAirDropSystem.CachedLuckAirData(data)
  if data then
    log_tree("CachedLogLuckAirData", data)
    LuckAirDropSystem.LuckAirData = data
    LuckAirDropSystem.CachedDropList()
    EventSystem:postEvent(EVENTTYPE_LUCKAIR, EVENTID_EVALUATE_AFTER_BUY)
  end
end
function LuckAirDropSystem.DataPushShowUI(data)
  log_tree("  :DataPushShowUI data", data)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.CloseAchievementTip()
  if not data then
    return
  end
  if data.items_info == nil or not next(data.items_info) then
    return
  end
  LuckAirDropSystem.CachedLuckAirData(data)
  local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
  if AirDropMesh.GetAirBox() then
    log(bWriteLog and "  : AirDropMesh isExitst")
    return
  end
  if LuckAirDropSystem.GetLeftTime() <= 0 then
    return
  end
  LuckAirDropSystem._NeedShowPopup = true
  if GameStatus.IsInLobbyOrMainCity() then
    LuckAirDropSystem.ShowQuery()
  else
    log(bWriteLog and "not in lobby")
    LuckAirDropSystem._DelayLobbyCreate = coroutine.create(function()
      LuckAirDropSystem.ShowQuery()
    end)
  end
end
function LuckAirDropSystem.GetMovies()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.LuckAir)
  local TableUtil = require("common.table_util")
  local lastIndex = TableUtil.GetTableValue(saveCfg, "lastIndex") or 0
  log(bWriteLog and "  : lastIndex" .. tostring(lastIndex))
  local uCurMovies
  local uAllMoviesCfg = CDataTable.GetTable("LuckAirDropMovies")
  for _, v in pairs(uAllMoviesCfg) do
    local nStartTime = TimeUtil.TimeStringToUnixstamp(v.StartTime)
    local nEndTime = TimeUtil.TimeStringToUnixstamp(v.EndTime)
    if TimeUtil.UnixTimeBetween(nStartTime, nEndTime) == 0 then
      uCurMovies = uCurMovies or v
      if lastIndex < v.Index then
        log(bWriteLog and "[ : index > lastIndex")
        return {
          index = v.Index,
          path = v.MoviesPath,
          time = v.DiscountTime
        }
      end
    end
  end
  if uCurMovies then
    log(bWriteLog and "  : use uCurMovies >>> " .. tostring(uCurMovies.MoviesPath))
    return {
      index = uCurMovies.Index,
      path = uCurMovies.MoviesPath,
      time = uCurMovies.DiscountTime
    }
  end
  log(bWriteLog and "  : LuckAirDropSystem can't GetMovies")
end
function LuckAirDropSystem.ShowQuery()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "LuckAirDropSystem.ShowQuery()")
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(10602) then
    log(bWriteLog and "  : LogicNewbie.IsNewbie()")
    return
  end
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    local bUIAutoTest = GameAutotest:IsUIAutoTest()
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    if bUIAutoTest or RoleInfoMainSystem.IsShow() then
      return
    end
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if LuckAirDropSystem.CanShowPopup() then
    LuckAirDropSystem.ShowPopup()
  end
end
local CheckPopup = function()
  if not LuckAirDropSystem._NeedShowPopup then
    log(bWriteLog and string.format("CheckPopup. LuckAirDropSystem._NeedShowPopup:%s", tostring(LuckAirDropSystem._NeedShowPopup)))
    return false
  end
  if NCurPage ~= ENUM_LobbyPageType.Mid then
    log(bWriteLog and "CheckPopup. isn't in mid page!")
    return false
  end
  if not LuckAirDropSystem.LuckAirData then
    log(bWriteLog and "CheckPopup. LuckAirDropSystem.LuckAirData is unvalid")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "CheckPopup. is in XMission!")
    return false
  end
  return true
end
function LuckAirDropSystem.CanShowPopup()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  if bHaveLockedFeature then
    log(bWriteLog and "LuckAirDropSystem.CanShowPopup bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
    LuckAirDropSystem._NeedShowPopup = false
    return false
  end
  if CheckPopup() then
    return true
  end
  return false
end
function LuckAirDropSystem.ShowPopup()
  log(bWriteLog and "LuckAirDropSystem.ShowPopup.")
  local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
  logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_LUCKY_AIR_DROP_PANEL)
end
function LuckAirDropSystem:TryShowPopup()
  if not LuckAirDropSystem._NeedShowPopup then
    return
  end
  log(bWriteLog and "LuckAirDropSystem:TryShowPopup.")
  EventSystem:postEvent(EVENTTYPE_LUCKAIR, EVENTID_SHOW_POPUP)
  LuckAirDropSystem._NeedShowPopup = false
  if LuckAirDropSystem.GetLeftTime() > 0 then
    local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
    AirDropMesh._BoxShow = true
    UIManager.ShowUI(UIManager.UI_Config.LuckyAirDrop_FaceSlap_UIBP)
  end
end
function LuckAirDropSystem.GetLeftTime()
  if LuckAirDropSystem.LuckAirData == nil then
    log(bWriteLog and "LuckAirDropSystem.LuckAirData == nil")
    return 0
  end
  if LuckAirDropSystem.LuckAirData.last_luck_time == nil then
    log(bWriteLog and "LuckAirDropSystem.LuckAirData.last_luck_time == nil")
    return 0
  end
  if LuckAirDropSystem.LuckAirData.duration == nil then
    log(bWriteLog and " LuckAirDropSystem.LuckAirData.duration == nil ")
    return 0
  end
  local last_luck_time = LuckAirDropSystem.LuckAirData.last_luck_time
  local durationSec = LuckAirDropSystem.LuckAirData.duration
  if last_luck_time and durationSec then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local left_time = last_luck_time + durationSec - curTime
    if left_time == 0 then
      log(bWriteLog and string.format("LuckAirDropSystem.GetLeftTime. last_luck_time:%s, durationSec:%s, CurTime:%s", last_luck_time, durationSec, curTime))
    end
    return left_time
  end
end
function LuckAirDropSystem.GetQuality()
  if LuckAirDropSystem.LuckAirData == nil then
    log(bWriteLog and "LuckAirDropSystem.LuckAirData == nil")
    return 0
  end
  if LuckAirDropSystem.LuckAirData.last_luck_time == nil then
    log(bWriteLog and "LuckAirDropSystem.LuckAirData.last_luck_time == nil")
    return 0
  end
  if LuckAirDropSystem.LuckAirData.quality == nil then
    log(bWriteLog and " LuckAirDropSystem.LuckAirData.duration == nil ")
    return 0
  end
  return LuckAirDropSystem.LuckAirData.quality
end
function LuckAirDropSystem.ShowLuckShopUI()
  if not LuckAirDropSystem.LuckAirData then
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if LoadingSystem.IsShowing() then
    return
  end
  local AirDataNum = 0
  if LuckAirDropSystem.LuckAirData.items_info then
    for _, _ in pairs(LuckAirDropSystem.LuckAirData.items_info) do
      AirDataNum = AirDataNum + 1
    end
  end
  LuckAirDropSystem._  log(bWriteLog and "AirDropSystem._AirDataNum: " .. tostring(LuckAirDropSystem._AirDataNum))
  if not LoadResourceCfg then
    LuckAirDropSystem.SetUIBPName()
    LuckAirDropSystem.SetUIItemBPName()
    LoadResourceCfg = true
  end
  UIManager.ShowUI(UIManager.UI_Config.LuckyAirDrop_Main_UIBP)
  LuckAirDropSystem.CachedDropList()
end
function LuckAirDropSystem.AfterBuy()
  log_tree("[ : AfterBuyLuckAirDropSystem._CurEquipedList[index]", LuckAirDropSystem._CurEquipedList)
  local isCloseLuckDrop = true
  if LuckAirDropSystem.LuckAirData.items_info and next(LuckAirDropSystem.LuckAirData.items_info) then
    for _, v in pairs(LuckAirDropSystem.LuckAirData.items_info) do
      if v.has_buy_num < v.num then
        isCloseLuckDrop = false
      end
    end
  end
  if isCloseLuckDrop then
    LuckAirDropSystem.CloseLuckAirDrop()
    LuckAirDropSystem.ClearData()
    local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
    AirDropMesh.Clear()
  else
    if UIManager.GetUI(UIManager.UI_Config.LuckyAirDrop_Main_UIBP) then
      LuckAirDropSystem:CachedDropList()
    end
    EventSystem:postEvent(EVENTTYPE_LUCKAIR, EVENTID_EVALUATE_AFTER_BUY)
  end
end
function LuckAirDropSystem.CachedDropList()
  if not LuckAirDropSystem.LuckAirData or not LuckAirDropSystem.LuckAirData.items_info then
    return
  end
  for _, v in pairs(LuckAirDropSystem.LuckAirData.items_info) do
    LuckAirDropSystem.GetOneChest(v)
  end
end
function LuckAirDropSystem.GetOneChest(v)
  local onGetDropRsp = function(drop_id, chestList)
    if drop_id == v.res_id then
      LuckAirDropSystem.CachedOneDropList(v, chestList)
    end
  end
  local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
  BasicDataChestTable:GetOrReqData(v.res_id, onGetDropRsp)
end
function LuckAirDropSystem.CachedOneDropList(v, dropItemList)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if v and dropItemList and next(dropItemList) then
    local TotalReturnMoney = 0
    v.DropInfo = {}
    for _, vv in pairs(dropItemList) do
      local tempSingleDropItemInfo = {
        itemid = vv.DropItemID,
        num = vv.DropItemNum,
        dropChance = vv.DropChance
      }
      if vv.DropItemTime then
        tempSingleDropItemInfo.valid_hours = vv.DropItemTime
        if vv.DropItemTime == 0 and StoreUtils.IsPossessed(vv.DropItemID, 0, 0) then
          local dropitemCfg = CDataTable.GetTableData("Item", vv.DropItemID)
          if dropitemCfg and dropitemCfg.ItemType ~= 100 and dropitemCfg.ItemType ~= 15 and dropitemCfg.ItemType ~= 16 then
            tempSingleDropItemInfo.isPossessed = true
            if vv.ReturnMoney and 0 < vv.ReturnMoney then
              tempSingleDropItemInfo.ReturnMoney = vv.ReturnMoney
              TotalReturnMoney = TotalReturnMoney + vv.ReturnMoney
            end
          end
        end
      end
      table.insert(v.DropInfo, tempSingleDropItemInfo)
      v.discount_sale_uc = v.old_uc - TotalReturnMoney
    end
  end
end
function LuckAirDropSystem.OnApplicationReactivated()
end
function LuckAirDropSystem.RefreshLuckAirDropLoacation()
end
function LuckAirDropSystem.OnReceivedEvaluateRsp(EVENTTYPE_LUCKAIR, _, item_id, score)
  if not item_id or not score then
    log(bWriteLog and "OnReceivedEvaluateRsp exception")
    return
  end
  if not LuckAirDropSystem.LuckAirData.items_info or not next(LuckAirDropSystem.LuckAirData.items_info) then
    log(bWriteLog and "OnReceivedEvaluateRsp exception")
    return
  end
  for i, v in pairs(LuckAirDropSystem.LuckAirData.items_info) do
    if i == item_id then
      v.    end
  end
  EventSystem:postEvent(EVENTTYPE_LUCKAIR, EVENTID_EVALUATE_RSPDATA_PUSHUI)
end
function LuckAirDropSystem.FakeLuckAirData(data)
  for k, v in pairs(data.items_info) do
    k = 1521576
    v.res_id = 1521576
  end
end
function LuckAirDropSystem.SetEquipedInfo(index, data)
  if LuckAirDropSystem._CurEquipedList == nil then
    LuckAirDropSystem._CurEquipedList = {}
  end
  LuckAirDropSystem._CurEquipedList[index] = data
  log_tree("[ : LuckAirDropSystem._CurEquipedList[index]", LuckAirDropSystem._CurEquipedList)
end
function LuckAirDropSystem.GetEquipedInfo()
  return LuckAirDropSystem._CurEquipedList
end
function LuckAirDropSystem.GetAssetsCfg()
  local result = CDataTable.GetTableData("LuckDropAssets", 1)
  return result
end
function LuckAirDropSystem.GetBoxMeshPath()
  local RegionParams = LuckAirDropSystem.GetRegionParams()
  return RegionParams.BoxMeshPath
end
function LuckAirDropSystem.GetAirDropClassPath()
  local classPath = "/Game/Arts_UI/AlwaysSplit/AirDropBox/Airdropbox_Mesh.Airdropbox_Mesh"
  return classPath
end
function LuckAirDropSystem.GetMeshAssetPath()
  if LuckAirDropSystem.AirDropType == 1 then
    log(bWriteLog and "LuckAirDropSystem.GetMeshAssetPath. Target Air drop Mesh Path")
    return "/Game/Arts_UI/AlwaysSplit/AirDropBox/CarePackage_int_027/CarePackage_int_027.CarePackage_int_027"
  end
  local mesh = "/Game/Arts_Player/Prop/CarePackage/Mesh/Prop_CarePackage01_ST.Prop_CarePackage01_ST"
  local boxMeshPath = LuckAirDropSystem.GetBoxMeshPath()
  if boxMeshPath then
    mesh = boxMeshPath
  end
  log(bWriteLog and string.format("LuckAirDropSystem.GetMeshAssetPath. Box Mesh Path:%s", tostring(mesh)))
  return mesh
end
function LuckAirDropSystem.GetLightName()
  local light = "Lobby_Light"
  local cfg = LuckAirDropSystem.GetAssetsCfg()
  local cfgMesh = cfg and cfg.Light
  if cfgMesh then
    log(bWriteLog and "[ : Get cfglight")
    light = cfgMesh
  end
  log(bWriteLog and "[ : light" .. tostring(light))
  return light
end
function LuckAirDropSystem.GetUISmokeName()
end
function LuckAirDropSystem.SetUIBPName()
  local cfg = LuckAirDropSystem.GetAssetsCfg()
  local cfgMesh = cfg and cfg.MainBpPath
  if cfgMesh then
    log(bWriteLog and "[ : Get cfglight")
    UIManager.UI_Config.LuckyAirDrop_Main_UIBP.path = cfgMesh
  end
end
function LuckAirDropSystem.SetUIItemBPName()
  local cfg = LuckAirDropSystem.GetAssetsCfg()
  local cfgMesh = cfg and cfg.MainItemBpPath
  if cfgMesh then
    log(bWriteLog and "[ : Get cfglight")
    UIManager.UI_Config.LuckyAirDrop_Item_UIBP.path = cfgMesh
  end
end
function LuckAirDropSystem.ShowVideo(redId)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  log(bWriteLog and "  : index" .. tostring(redId))
  local curMovie = LuckAirDropSystem.GetMovies()
  if not curMovie then
    log(bWriteLog and "  : not curMovie")
    return false
  end
  local videoPath = curMovie.path
  log(bWriteLog and "  : videoPath" .. tostring(videoPath))
  local result = false
  if VideoLibrary.IsCanPlayVideo() == true and VideoLibrary.IsVideoFileReady(videoPath) == true then
    UIManager.ShowUI(UIManager.UI_Config.LuckyAirDrop_Video_UIBP, videoPath, redId, curMovie.index, curMovie.time)
    result = true
  end
  log(bWriteLog and "VideoLibrary.PlayVideo, result = " .. tostring(result))
  return result
end
function LuckAirDropSystem.ClearData()
  LuckAirDropSystem.LuckAirData = nil
  LuckAirDropSystem._AirDataNum = 0
  LuckAirDropSystem._CurEquipedList = nil
end
function LuckAirDropSystem.CloseLuckAirDrop()
  log(bWriteLog and "AirDropSystem._AirDataNum: " .. tostring(LuckAirDropSystem._AirDataNum))
  UIManager.CloseUI(UIManager.UI_Config.LuckyAirDrop_Main_UIBP)
end
function LuckAirDropSystem.HandleTargetAirdropData(scene_id, airdrop_list, end_time, discount, pre_price, cur_price, is_first)
  LuckAirDropSystem.target_airdrop_data = LuckAirDropSystem.target_airdrop_data or {}
  LuckAirDropSystem.target_airdrop_data[scene_id] = LuckAirDropSystem.target_airdrop_data[scene_id] or {}
  LuckAirDropSystem.target_airdrop_data[scene_id].  LuckAirDropSystem.target_airdrop_data[scene_id].  LuckAirDropSystem.target_airdrop_data[scene_id].  LuckAirDropSystem.target_airdrop_data[scene_id].  LuckAirDropSystem.target_airdrop_data[scene_id].  log(bWriteLog and "LuckAirDropSystem.HandleTargetAirdropData " .. scene_id)
  log(bWriteLog and "LuckAirDropSystem.HandleTargetAirdropData " .. tostring(is_first))
  log_tree("LuckAirDropSystem.HandleTargetAirdropData ", LuckAirDropSystem.target_airdrop_data[scene_id])
  if LuckAirDropSystem.CheckHasAirDropByScene(1) then
    if is_first and is_first == 1 then
      UIManager.ShowUI(UIManager.UI_Config.SmallKT_UIBP, 1)
    end
    EventSystem:postEvent(EVENTTYPE_LUCKAIR_TARGET, EVENTID_LUCKY_AIRDROP_TARGET_SHOW)
  elseif LuckAirDropSystem.CheckHasAirDropByScene(2) then
    if is_first and is_first == 1 then
      UIManager.ShowUI(UIManager.UI_Config.SmallKT_UIBP, 2)
    end
    EventSystem:postEvent(EVENTTYPE_LUCKAIR_TARGET, EVENTID_LUCKY_AIRDROP_TARGET_SHOW)
  elseif LuckAirDropSystem.CheckHasAirDropByScene(3) or LuckAirDropSystem.CheckHasAirDropByScene(4) then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local isAndroidStackEmpty = UIManager.IsAndroidStackEmpty()
    if not LogicTxMissionMain.IsInXMission(false) and isAndroidStackEmpty and is_first and is_first == 1 then
      UIManager.ShowUI(UIManager.UI_Config.SmallKT_UIBP, 4)
    end
  end
  local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
  AirDropMesh.Create()
end
function LuckAirDropSystem.HandleTargetAirdropAllData(scene_list)
  LuckAirDropSystem.target_airdrop_data = scene_list.scene_list
  log_tree("LuckAirDropSystem.target_airdrop_data ", LuckAirDropSystem.target_airdrop_data)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  if LuckAirDropSystem.CheckHasAirDropByScene(1) and (UIManager.GetUI(UIManager.UI_Config.StoreGeneralPage) or UIManager.GetUI(UIManager.UI_Config.StoreRecommendPage)) then
    UIManager.ShowUI(UIManager.UI_Config.SmallKT_UIBP, 1)
    EventSystem:postEvent(EVENTTYPE_LUCKAIR_TARGET, EVENTID_LUCKY_AIRDROP_TARGET_SHOW)
  elseif LuckAirDropSystem.CheckHasAirDropByScene(2) and UIManager.GetUI(UIManager.UI_Config.SupplyGeneralPage) then
    UIManager.ShowUI(UIManager.UI_Config.SmallKT_UIBP, 2)
    EventSystem:postEvent(EVENTTYPE_LUCKAIR_TARGET, EVENTID_LUCKY_AIRDROP_TARGET_SHOW)
  elseif LuckAirDropSystem.CheckHasAirDropByScene(3) or LuckAirDropSystem.CheckHasAirDropByScene(4) then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local isAndroidStackEmpty = UIManager.IsAndroidStackEmpty()
    if not LogicTxMissionMain.IsInXMission(false) and isAndroidStackEmpty then
      UIManager.ShowUI(UIManager.UI_Config.SmallKT_UIBP, 4)
    end
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission(false) then
    local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
    AirDropMesh.Create()
  end
end
function LuckAirDropSystem.CheckHasAirDropByScene(scene_id)
  log(bWriteLog and "LuckAirDropSystem.CheckHasAirDropByScene " .. tostring(scene_id))
  if LuckAirDropSystem.target_airdrop_data == nil or next(LuckAirDropSystem.target_airdrop_data) == nil then
    return false
  end
  if LuckAirDropSystem.target_airdrop_data[scene_id] == nil or next(LuckAirDropSystem.target_airdrop_data[scene_id]) == nil then
    return false
  end
  local info = LuckAirDropSystem.target_airdrop_data[scene_id]
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "LuckAirDropSystem.CheckHasAirDropByScene " .. tostring(info.end_time) .. " " .. tostring(TimeUtil.GetServerTimeInSec()) .. " " .. tostring(info.is_buy))
  if info.end_time and info.end_time >= TimeUtil.GetServerTimeInSec() and not info.is_buy then
    return true
  end
  return false
end
function LuckAirDropSystem.GetTargetEndTimeByScene(scene_id)
  local TimeUtil = require("client.common.time_util")
  if LuckAirDropSystem.target_airdrop_data == nil or next(LuckAirDropSystem.target_airdrop_data) == nil then
    return TimeUtil.GetServerTimeInSec()
  end
  if LuckAirDropSystem.target_airdrop_data[scene_id] == nil or next(LuckAirDropSystem.target_airdrop_data[scene_id]) == nil then
    return TimeUtil.GetServerTimeInSec()
  end
  local info = LuckAirDropSystem.target_airdrop_data[scene_id]
  return info.end_time
end
function LuckAirDropSystem.SetNeedUCCount(nCount)
  LuckAirDropSystem._nNeedUCCount = nCount
end
function LuckAirDropSystem.GetNeedUCCount()
  return LuckAirDropSystem._nNeedUCCount or 0
end
function LuckAirDropSystem.GetRegionParams()
  if LuckAirDropSystem.RegionParams then
    return LuckAirDropSystem.RegionParams
  end
  local Region = Client.GetPublishRegion()
  LuckAirDropSystem.RegionParams = CDataTable.GetTableData("LuckyAirDropRegionDiff", Region)
  if not LuckAirDropSystem.RegionParams then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    Region = PublishRegionMacros.GLOBAL
    LuckAirDropSystem.RegionParams = CDataTable.GetTableData("LuckyAirDropRegionDiff", Region)
  end
  return LuckAirDropSystem.RegionParams
end
local BoxTransform
function LuckAirDropSystem.GetBoxTransform()
  if BoxTransform then
    return BoxTransform.Location, BoxTransform.Rotation, BoxTransform.Scale
  end
  LuckAirDropSystem.GetRegionParams()
  local TransformString = LuckAirDropSystem.RegionParams.BoxTransform
  local StringUtil = require("common.string_util")
  local split = StringUtil.Split(TransformString, "|")
  local VectorStr = split[1]
  local VectorSplit = StringUtil.Split(VectorStr, ";")
  local Location = FVector(VectorSplit[1], VectorSplit[2], VectorSplit[3])
  local RotationStr = split[2]
  local RotationSplit = StringUtil.Split(RotationStr, ";")
  local Rotation = FRotator(RotationSplit[2], RotationSplit[3], RotationSplit[1])
  local ScaleStr = split[3]
  local ScaleSplit = StringUtil.Split(ScaleStr, ";")
  local Scale = FVector(ScaleSplit[1], ScaleSplit[2], ScaleSplit[3])
  BoxTransform = {
    Location = Location,
    Rotation = Rotation,
      }
  return Location, Rotation, Scale
end
return LuckAirDropSystem