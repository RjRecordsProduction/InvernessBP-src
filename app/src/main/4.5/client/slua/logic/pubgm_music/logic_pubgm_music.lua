local logic_music_const = require("client.slua.logic.pubgm_music.logic_music_const")
local logic_pubgm_music_util = require("client.slua.logic.pubgm_music.logic_pubgm_music_util")
local TableUtil = require("common.table_util")
local C_ServerConfigName = logic_music_const.C_ServerConfigName
local E_MusicOwnedState = logic_music_const.E_MusicOwnedState
local E_CurPage = logic_music_const.E_CurPage
local E_MusicPlayMode = logic_music_const.E_MusicPlayMode
local logic_pubgm_music = {
  cantPlayWithCar = {
    [1988002] = false,
    [1988003] = false,
    [1988004] = false,
    [1988005] = false
  }
}
function logic_pubgm_music.OnLogin()
  log(bWriteLog and " logic_pubgm_music.OnLogin")
  logic_pubgm_music.InitData()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(C_ServerConfigName, function()
    local TimeUtil = require("client.common.time_util")
    logic_pubgm_music._changeLobbyBGMTime = TimeUtil.GetServerTimeInSec()
    logic_pubgm_music.SendMusicBoxRequest()
  end)
end
function logic_pubgm_music.OnModePreSwitch(preState, nextState)
  log(bWriteLog and "logic_pubgm_music.OnModePreSwitch. preState: " .. tostring(preState) .. type(preState))
  if nextState == GameStatus.Lobby then
    EventSystem:registEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_CLEAR, logic_pubgm_music.CheckUiStack)
  else
    if preState ~= GameStatus.None then
      GlobalData.StopLobbyBGM()
    end
    logic_pubgm_music.ResetAllMusicDownloadState()
    if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
      EventSystem:unregistEvent(EVENTTYPE_JUMP, EVENTID_JUMP_MODULE_CLEAR, logic_pubgm_music.CheckUiStack)
    end
  end
end
function logic_pubgm_music.OnModePostSwitch(preState, nextState)
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local switch = main_city_process_util.GetMainCityEnterSwitch()
  if nextState == GameStatus.Lobby and not switch then
    GlobalData.RestoreLobbyBGM()
  end
end
function logic_pubgm_music.InitData()
  logic_pubgm_music.bSwitch = true
  logic_pubgm_music.svr_data = nil
  logic_pubgm_music.allMap = nil
  logic_pubgm_music.checkGiftedCache = nil
  logic_pubgm_music.redDotJson = nil
  logic_pubgm_music.region = nil
  logic_pubgm_music.musicList = {
    [E_MusicOwnedState.All] = nil,
    [E_MusicOwnedState.Expire] = nil,
    [E_MusicOwnedState.AllValid] = nil,
    [E_MusicOwnedState.Owned] = nil,
    [E_MusicOwnedState.NotOwned] = nil
  }
  logic_pubgm_music.curRegionCode = nil
end
function logic_pubgm_music.CheckCanPlayMusic()
  return logic_pubgm_music.svr_data ~= nil
end
function logic_pubgm_music.CheckUiStack(_, _, uiStack)
  log(bWriteLog and " logic_pubgm_music.CheckUiStack()")
  for i, v in ipairs(uiStack) do
    if v.moduleID == BP_ENUM_MODULE_ROLE_SPACE and logic_pubgm_music.CheckPlayingOtherBGM() then
      log(bWriteLog and " logic_pubgm_music.CheckUiStack: GlobalData.RestoreLobbyBGM()")
      GlobalData.RestoreLobbyBGM()
    end
  end
end
function logic_pubgm_music.ResetAllMusicDownloadState()
  log(bWriteLog and " logic_pubgm_music.ResetAllMusicDownloadState()")
  if not logic_pubgm_music.musicList then
    log(bWriteLog and string.format("logic_pubgm_music.ResetAllMusicDownloadState(), self.musicList = nil"))
    return
  end
  if not logic_pubgm_music.musicList or not logic_pubgm_music.musicList[E_MusicOwnedState.All] then
    log(bWriteLog and " logic_pubgm_music.ResetAllMusicDownloadState(), self.musicList[E_MusicOwnedState.All] = nil")
    return
  end
  for i = 1, TableUtil.CountTable(E_MusicOwnedState) do
    for _, v in ipairs(logic_pubgm_music.musicList[i]) do
      if v.nState == ENUM_DownloadState.Download then
        v.nState = ENUM_DownloadState.Not
      end
    end
  end
end
function logic_pubgm_music.IsOpen()
  return logic_pubgm_music.bSwitch
end
function logic_pubgm_music.GetMusicDetailInfoByID(id)
  if not logic_pubgm_music.allMap then
    logic_pubgm_music.allMap = {}
  end
  if logic_pubgm_music.allMap[id] then
    return logic_pubgm_music.allMap[id]
  else
    local allList = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.All)
    if not allList then
      log(bWriteLog and " logic_pubgm_music.GetMusicDetailInfoByID, id:" .. tostring(id))
      return
    end
    for k, v in ipairs(allList) do
      if v.nID == id then
        logic_pubgm_music.allMap[k] = v
        return v
      end
    end
  end
end
function logic_pubgm_music.GetSvrLobbyList()
  if not logic_pubgm_music.GetSvrDataForServer() then
    return
  end
  return TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music"), TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music_type"), TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music_single"), TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music_max_count")
end
function logic_pubgm_music.GetSvrCarList()
  if not logic_pubgm_music.GetSvrDataForServer() then
    return
  end
  return TableUtil.GetTableValue(logic_pubgm_music.svr_data, "car_music"), TableUtil.GetTableValue(logic_pubgm_music.svr_data, "car_music_max_count")
end
function logic_pubgm_music.GetSvrHomePlayerList()
  if not logic_pubgm_music.GetSvrDataForServer() then
    return
  end
  return TableUtil.GetTableValue(logic_pubgm_music.svr_data, "manor_scene_music"), TableUtil.GetTableValue(logic_pubgm_music.svr_data, "manor_scene_music_max_count")
end
function logic_pubgm_music.GetMusicDetailDataListByMusicIdList(idList)
  if not idList or not next(idList) then
    log(bWriteLog and " self.GetMusicDetailDataListByMusicIdList: nil or {}")
    return
  end
  local allList = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.All)
  local retList = {}
  for k, v in ipairs(idList) do
    for kk, vv in ipairs(allList) do
      if v == vv.nID then
        table.insert(retList, vv)
      end
    end
  end
  return retList
end
function logic_pubgm_music.SetCurRegionCode(regionCode)
  logic_pubgm_music.curRegionCode = regionCode
  logic_pubgm_music.GetMusicDataByOwnedState(logic_music_const.E_MusicOwnedState.All)
end
function logic_pubgm_music.GetSvrDataForServer()
  log(bWriteLog and "xcc logic_pubgm_music.GetSvrDataForServer()")
  if not logic_pubgm_music.svr_data then
    log(bWriteLog and "xcc logic_pubgm_music.GetSvrDataForServer(), no svr_data.")
    logic_pubgm_music.SendMusicBoxRequest()
    return false
  end
  return true
end
function logic_pubgm_music.ProcessAllMusic()
  log(bWriteLog and " logic_pubgm_music.ProcessAllMusic()")
  for i = 1, TableUtil.CountTable(E_MusicOwnedState) do
    logic_pubgm_music.musicList[i] = {}
  end
  local configs = logic_pubgm_music_util.GetConfig()
  if not configs or not next(configs) then
    log(bWriteLog and " logic_pubgm_music.ProcessAllMusic(), no music configs.")
    return
  end
  logic_pubgm_music.musicList = logic_pubgm_music.ProcessMusic(configs)
end
function logic_pubgm_music.ProcessLobbyMusic(state, lobbyMusicList)
  log(bWriteLog and " logic_pubgm_music.ProcessLobbyMusic()")
  local configs = logic_pubgm_music_util.GetConfig()
  if not configs or not next(configs) then
    log(bWriteLog and " logic_pubgm_music.ProcessLobbyMusic(), no music configs.")
    return {}
  end
  local _lobbyMusicList = logic_pubgm_music.ProcessMusic(lobbyMusicList, configs)
  return _lobbyMusicList[state]
end
function logic_pubgm_music.ProcessMusic(musicList, configs)
  local gameid = tostring(Client.GetITopGameId())
  log(bWriteLog and "logic_pubgm_music.ProcessMusic, gameid:" .. tostring(gameid))
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  log(bWriteLog and "logic_pubgm_music.ProcessMusic, clientVersion:" .. tostring(clientVersion))
  local logic_pubgm_music_download = require("client.slua.logic.pubgm_music.logic_pubgm_music_download")
  if not logic_pubgm_music.curRegionCode then
    logic_pubgm_music.curRegionCode = FuncUtil.GetAccountRegionForBP()
    log(bWriteLog and " logic_pubgm_music.ProcessMusic, curRegionCode" .. logic_pubgm_music.curRegionCode)
  end
  local musicListCache = {}
  for i = 1, TableUtil.CountTable(E_MusicOwnedState) do
    musicListCache[i] = {}
  end
  for k, v in pairs(musicList) do
    local id = configs and v or k
    local data = configs and configs[v] or v
    local bHaveData = type(data) == "table"
    if not (not bHaveData or data.play_event) or data.play_event == "" then
      data.play_event = "/Game/WwiseEvent/Music/MusicPlayer/Play_MusicPlayer_NothingsGettingInOurWay.Play_MusicPlayer_NothingsGettingInOurWay"
      log(bWriteLog and " logic_pubgm_music.ProcessMusic(), music.nID\239\188\154" .. tostring(id) .. " no play event.")
    end
    local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
    if bHaveData and data.appid_set[gameid] and not musicManager:IsBlackWithRegionAndPath(nil, data.play_event) and logic_pubgm_music_util.IsMusicValidByVersion(data.min_version, clientVersion) and logic_pubgm_music_util.IsMusicValidByCounrty(logic_pubgm_music.curRegionCode, data.country) then
      local musicCfg = CDataTable.GetTableData("VehicleMusic", id)
      local PreviewDuration = musicCfg and musicCfg.PreviewDuration
      if not PreviewDuration or PreviewDuration == 0 then
        PreviewDuration = logic_music_const.SAMPLETIME
      end
      local music = {
        nID = id,
        cfg = data,
        itemCfg = CDataTable.GetTableData("Item", id),
        data = TableUtil.GetTableValue(logic_pubgm_music.svr_data, "depot", id),
        nState = logic_pubgm_music_download.GetMusicDownloadState(id, data),
        bNew = version_util.IsMatchVersion(data.min_version),
              }
      if logic_pubgm_music_util.IsMusicValidByTime(data.start_time, data.end_time) then
        if music.data and next(music.data) then
          table.insert(musicListCache[E_MusicOwnedState.Owned], music)
          table.insert(musicListCache[E_MusicOwnedState.AllValid], music)
        else
          table.insert(musicListCache[E_MusicOwnedState.NotOwned], music)
          table.insert(musicListCache[E_MusicOwnedState.AllValid], music)
        end
        table.insert(musicListCache[E_MusicOwnedState.All], music)
      elseif TableUtil.GetTableValue(music, "data", "expire_notify") then
        table.insert(musicListCache[E_MusicOwnedState.Expire], music)
      end
    end
  end
  if not configs then
    for i = E_MusicOwnedState.All, E_MusicOwnedState.NotOwned do
      table.sort(musicListCache[i], logic_pubgm_music_util.SortMusicList)
    end
  end
  return musicListCache
end
function logic_pubgm_music.ClearAllMusic()
  logic_pubgm_music.musicList = {}
  local configs = logic_pubgm_music_util.GetConfig()
  if logic_pubgm_music.svr_data and next(logic_pubgm_music.svr_data) and configs and next(configs) then
    local logic_lobby_music = require("client.slua.logic.lobby.logic_lobby_music")
    logic_lobby_music.ClearPlayerTicker()
    GlobalData.RestoreLobbyBGM()
    log(bWriteLog and "logic_pubgm_music.ClearAllMusic")
  end
end
function logic_pubgm_music.GetMusicDataByOwnedStateById(id)
  local list = logic_pubgm_music.GetMusicDataByOwnedState(logic_music_const.E_MusicOwnedState.Owned) or {}
  for _, musicInfo in ipairs(list) do
    if musicInfo.nID == id then
      return musicInfo
    end
  end
end
function logic_pubgm_music.GetMusicDataByOwnedState(state)
  log(bWriteLog and string.format("logic_pubgm_music.GetMusicDataByOwnedState, state:%s", state))
  if not logic_pubgm_music.GetSvrDataForServer() or logic_pubgm_music.curRegionCode == nil then
    return {}
  end
  if not logic_pubgm_music.musicList or not next(logic_pubgm_music.musicList) then
    log(bWriteLog and string.format("logic_pubgm_music.GetMusicDataByOwnedState, strCode:%s", "not self.musicList"))
    logic_pubgm_music.ProcessAllMusic()
  end
  local logic_pubgm_music_download = require("client.slua.logic.pubgm_music.logic_pubgm_music_download")
  for _, v in pairs(logic_pubgm_music.musicList[state]) do
    v.nState = logic_pubgm_music_download.GetMusicDownloadStateByID(v.nID)
  end
  log(bWriteLog and string.format("logic_pubgm_music.GetMusicDataByOwnedState, self.musicList[state]:%s", logic_pubgm_music.musicList[state]))
  return logic_pubgm_music.musicList[state]
end
function logic_pubgm_music.GetDownloadedWardrobeList()
  local musicList = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.Owned)
  local list = {}
  for i, v in ipairs(musicList) do
    if v.nState == ENUM_DownloadState.Done then
      table.insert(list, v)
    end
  end
  return list
end
function logic_pubgm_music.GetRandomDownloadedMusicList()
  local list = logic_pubgm_music.GetDownloadedWardrobeList()
  local randomList = {}
  while 0 < #list do
    local random = math.random(#list)
    table.insert(randomList, table.remove(list, random))
  end
  return randomList
end
function logic_pubgm_music.CheckFirstGiftGet()
  log(bWriteLog and " logic_pubgm_music.CheckFirstGiftGet()")
  local isNewbieGiftGet = TableUtil.GetTableValue(logic_pubgm_music.svr_data, "newbie_gift")
  if isNewbieGiftGet then
    return false
  end
  return true
end
function logic_pubgm_music.GetExpireList()
  log(bWriteLog and " logic_pubgm_music.GetExpireList()")
  return logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.Expire)
end
function logic_pubgm_music.PutOnMusic(musicId)
  log(bWriteLog and " logic_pubgm_music.PutOnMusic, musicId:" .. tostring(musicId))
  if not logic_pubgm_music.svr_data then
    logic_pubgm_music.svr_data = {}
  end
  logic_pubgm_music.PutOnLobbyMusic(musicId)
  logic_pubgm_music.PutOnVehicleMusic(musicId)
end
function logic_pubgm_music.PutOnLobbyMusic(musicId)
  log(bWriteLog and " logic_pubgm_music.PutOnLobbyMusic()")
  if TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music") then
    TableUtil.Remove(logic_pubgm_music.svr_data.bgm_music, musicId)
    table.insert(logic_pubgm_music.svr_data.bgm_music, 1, musicId)
    local maxCount = TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music_max_count") or 10
    if maxCount < #logic_pubgm_music.svr_data.bgm_music then
      table.remove(logic_pubgm_music.svr_data.bgm_music)
    end
  else
    logic_pubgm_music.svr_data.bgm_music = {
      [1] = musicId
    }
  end
  logic_pubgm_music.SetBackgroundMusicList(logic_pubgm_music.svr_data.bgm_music, TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music_type") or E_MusicPlayMode.Loop, TableUtil.GetTableValue(logic_pubgm_music.svr_data, "bgm_music_single"))
end
function logic_pubgm_music.PutOnVehicleMusic(musicId)
  log(bWriteLog and " logic_pubgm_music.PutOnVehicleMusic()")
  if logic_pubgm_music.IsOwnSelfMusicVehicle() then
    if TableUtil.GetTableValue(logic_pubgm_music.svr_data, "car_music") then
      TableUtil.Remove(logic_pubgm_music.svr_data.car_music, musicId)
      table.insert(logic_pubgm_music.svr_data.car_music, 1, musicId)
      local maxCount = TableUtil.GetTableValue(logic_pubgm_music.svr_data, "car_music_max_count") or 5
      if maxCount < #logic_pubgm_music.svr_data.car_music then
        table.remove(logic_pubgm_music.svr_data.car_music)
      end
    else
      logic_pubgm_music.svr_data.car_music = {
        [1] = musicId
      }
    end
    logic_pubgm_music.SetCarMusicList(logic_pubgm_music.svr_data.car_music)
  end
end
function logic_pubgm_music.SetBackgroundMusicList(musicList, mode, song)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({backgroundMusicList = musicList}, PlayerPrefsSystem.ePlayerPrefsType.ePubgmMusicBGM)
  if musicList then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.PubgmMusic_SetBGM)
  end
  local PubgmMusicHandler = require("client.network.Protocol.PubgmMusicHandler")
  if mode == E_MusicPlayMode.SingleLoop then
    musicList = {
      [1] = song
    }
  end
  PubgmMusicHandler.send_music_box_set_bgm_music_req(musicList, mode, song)
end
function logic_pubgm_music.SetCarMusicList(musicList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({carMusicList = musicList}, PlayerPrefsSystem.ePlayerPrefsType.ePubgmMusicBGM)
  local PubgmMusicHandler = require("client.network.Protocol.PubgmMusicHandler")
  PubgmMusicHandler.send_music_box_set_car_music_req(musicList)
end
function logic_pubgm_music.OnCarMusicSetRsp(carMusic)
  if not logic_pubgm_music.svr_data then
    logic_pubgm_music.svr_data = {car_music = carMusic}
  else
    logic_pubgm_music.svr_data.car_music = carMusic
  end
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_OPTION_MUSIC)
end
function logic_pubgm_music.OnMusicBoxSetBgmRsp(bgmMusic, bgmMusicType, bgmMusicSingle)
  if not logic_pubgm_music.svr_data then
    logic_pubgm_music.svr_data = {
      bgm_music = bgmMusic,
      bgm_music_type = bgmMusicType or E_MusicPlayMode.Loop,
      bgm_music_single = bgmMusicSingle
    }
  else
    logic_pubgm_music.svr_data.bgm_music = bgmMusic
    logic_pubgm_music.svr_data.bgm_music_type = bgmMusicType or E_MusicPlayMode.Loop
    logic_pubgm_music.svr_data.bgm_music_single = bgmMusicSingle
  end
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_OPTION_MUSIC)
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  if musicManager:GetCurrentPage() == E_CurPage.Lobby then
    log(bWriteLog and " logic_pubgm_music.OnMusicBoxSetBgmRsp, \229\189\147\229\137\141\228\189\141\231\189\174\229\156\168\229\164\167\229\142\133\239\188\140\233\135\141\230\146\173\233\159\179\228\185\144.")
    GlobalData.StopLobbyBGM()
    GlobalData.RestoreLobbyBGM()
  end
end
function logic_pubgm_music.SetHomePlayerMusicListReq(musicList)
  local PubgmMusicHandler = require("client.network.Protocol.PubgmMusicHandler")
  PubgmMusicHandler.send_set_scene_music_req(musicList)
end
function logic_pubgm_music.SetHomePlayerMusicListRsp(musicList)
  if not logic_pubgm_music.svr_data then
    logic_pubgm_music.svr_data = {manor_scene_music = musicList}
  else
    logic_pubgm_music.svr_data.manor_scene_music = musicList
  end
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_OPTION_MUSIC)
end
function logic_pubgm_music.GetOtherMusicDetailList(_, musicList)
  return logic_pubgm_music.GetMusicDetailDataListByMusicIdList(musicList)
end
function logic_pubgm_music.CheckPlayingOtherBGM()
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  return musicManager:GetCurrentPage() == logic_music_const.E_CurPage.OtherSocialLobby
end
function logic_pubgm_music.PlayOtherBGM()
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  return musicManager:BeginPlayMusicList()
end
function logic_pubgm_music.StopOtherBGM()
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  if musicManager:GetCurrentPage() == E_CurPage.OtherSocialLobby then
    musicManager:StopMusic()
    GlobalData.RestoreLobbyBGM()
  end
end
function logic_pubgm_music.UpdateCacheGiftList(mid, uid, state)
  if not logic_pubgm_music.checkGiftedCache then
    logic_pubgm_music.checkGiftedCache = {}
  end
  if not logic_pubgm_music.checkGiftedCache[mid] then
    logic_pubgm_music.checkGiftedCache[mid] = {}
  end
  logic_pubgm_music.checkGiftedCache[mid][uid] = state
end
function logic_pubgm_music.CheckCanGift(mid)
  local ownedMusicList = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.Owned)
  if not ownedMusicList or #ownedMusicList then
    return false
  end
  for i, v in ipairs(ownedMusicList) do
    if v.nID == mid then
      local count = v.data.permanent_count or 0
      if 1 < count then
        return true
      end
      break
    end
  end
  return false
end
function logic_pubgm_music.CheckGifted(mid, uid)
  if not logic_pubgm_music.checkGiftedCache then
    return logic_music_const.E_MusicGiftState.Can
  end
  if not logic_pubgm_music.checkGiftedCache[mid] then
    return logic_music_const.E_MusicGiftState.Can
  end
  if not logic_pubgm_music.checkGiftedCache[mid][uid] then
    return logic_music_const.E_MusicGiftState.Can
  end
  return logic_pubgm_music.checkGiftedCache[mid][uid]
end
function logic_pubgm_music.ClearGiftedCache()
  logic_pubgm_music.checkGiftedCache = nil
end
function logic_pubgm_music.IsOwnSelfMusicVehicle()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  local carData = VehicleRefitHandler.ShowAbleCars()
  for _, v in pairs(carData) do
    if wardrobe_data:GetHallDepotItemDataByResID(v.vehicle_id) and logic_pubgm_music.cantPlayWithCar[v.vehicle_id] ~= false then
      return true
    end
  end
  local VehicleFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleFeature)
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local vMusicFeature = VehiclePlateLicenseUtil.GetUpgradeVehicleMusicFeatureId()
  if VehicleFeature:IsUnlockFeature(vMusicFeature) then
    return true
  end
  local BetterVehicleEffect = CDataTable.GetTable("BetterVehicleEffect")
  if not BetterVehicleEffect then
    return false
  end
  for k, v in pairs(BetterVehicleEffect) do
    if wardrobe_data:GetHallDepotItemDataByResID(v.ID) and v.VehicleMusic == 1 then
      return true
    end
  end
  return false
end
function logic_pubgm_music.IsShowHomePlayerMusic()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and " logic_pubgm_music.IsShowHomePlayerMusic, Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE")
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if not logic_home_switch:CheckHomeSwitchOpen() then
      log(bWriteLog and " logic_pubgm_music.IsShowHomePlayerMusic, not logic_home_switch:CheckHomeSwitchOpen()")
      return false
    end
  end
  return true
end
function logic_pubgm_music.ShouldRedDotShow()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not logic_pubgm_music.redDotJson then
    logic_pubgm_music.redDotJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePubgmMusicRedDot)
  end
  if type(logic_pubgm_music.redDotJson) == "number" then
    logic_pubgm_music.redDotJson = {}
  end
  if not logic_pubgm_music.redDotJson or not logic_pubgm_music.redDotJson.lobby then
    return true
  end
  if not logic_pubgm_music.redDotJson.car and logic_pubgm_music.IsOwnSelfMusicVehicle() then
    return true
  end
  return false
end
function logic_pubgm_music.SaveRedDotData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not logic_pubgm_music.redDotJson then
    logic_pubgm_music.redDotJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePubgmMusicRedDot) or {}
  end
  if type(logic_pubgm_music.redDotJson) == "number" then
    logic_pubgm_music.redDotJson = {}
  end
  if not logic_pubgm_music.redDotJson.lobby then
    logic_pubgm_music.redDotJson.lobby = 1
  end
  if logic_pubgm_music.IsOwnSelfMusicVehicle() and not logic_pubgm_music.redDotJson.car then
    logic_pubgm_music.redDotJson.car = 1
  end
  PlayerPrefsSystem.SaveTableToFile_N(logic_pubgm_music.redDotJson, PlayerPrefsSystem.ePlayerPrefsType.ePubgmMusicRedDot)
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_CLICK_OPTION)
end
function logic_pubgm_music.OnMusicBoxCheckOpenRsp(isOpen)
  log(bWriteLog and "[edward][self] self.OnMusicBoxCheckOpenRsp, isOpen = " .. tostring(isOpen))
  logic_pubgm_music.bSwitch = isOpen
  if isOpen then
    log(bWriteLog and " logic_pubgm_music.OnMusicBoxCheckOpenRsp, isOpen == true, SendMusicBoxRequest()")
    logic_pubgm_music.SendMusicBoxRequest()
  end
end
function logic_pubgm_music.SendMusicBoxRequest()
  local PubgmMusicHandler = require("client.network.Protocol.PubgmMusicHandler")
  PubgmMusicHandler.send_music_box_data_req()
end
function logic_pubgm_music.OnMusicBoxDataRsp(data)
  log_tree("[edward][self] self.OnMusicBoxDataRsp", data)
  logic_pubgm_music.svr_  logic_pubgm_music.ClearAllMusic()
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_GET_DATA)
end
function logic_pubgm_music.OnMusicBoxReceiveNewbieGiftRsp(res_map)
  log_tree(" logic_pubgm_music.OnMusicBoxReceiveNewbieGiftRsp, ", res_map)
  logic_pubgm_music.svr_data.newbie_gift = nil
  local ownedMusicList = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.Owned)
  local notOwnedMusicList = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.NotOwned)
  for k, v in pairs(res_map) do
    local updateMusic
    for kk, vv in ipairs(notOwnedMusicList) do
      if k == vv.nID then
        updateMusic = table.remove(notOwnedMusicList, kk)
        table.insert(ownedMusicList, updateMusic)
        table.sort(ownedMusicList, function(a, b)
          if a.nState == b.nState then
            return a.nID < b.nID
          else
            return a.nState > b.nState
          end
        end)
        break
      end
    end
    if not updateMusic then
      for _, vvv in ipairs(ownedMusicList) do
        if k == vvv.nID then
          updateMusic = v
          break
        end
      end
    end
    updateMusic = updateMusic or {}
    local TimeUtil = require("client.common.time_util")
    if not updateMusic.data then
      updateMusic.data = {
        first_own_time = TimeUtil.GetServerTimeInSec(),
        permanent_count = 0,
        expire_notify = false,
        expire_time = TimeUtil.GetServerTimeInSec()
      }
    end
    updateMusic.data.permanent_count = TableUtil.GetTableValue(updateMusic, "data", "permanent_count") + v.count
    updateMusic.data.expire_notify = false
    updateMusic.data.expire_time = TableUtil.GetTableValue(updateMusic, "data", "expire_time") + v.valid_hour * 86400
  end
  local list = {}
  for k, v in pairs(res_map) do
    local data = {
      res_id = k,
      count = v.count,
      valid_hours = v.valid_hour,
      expire_time = 0
    }
    table.insert(list, data)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(list)
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_GET_GIFT)
end
function logic_pubgm_music.OnMusicBoxClearExpireRsp(data)
  log_tree(" logic_pubgm_music.OnMusicBoxClearExpireRsp", data)
  logic_pubgm_music.svr_  logic_pubgm_music.ClearAllMusic()
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_GET_DATA)
end
function logic_pubgm_music.OnMusicBoxCheckGiftRsp(err, to_uid, music_res_id)
  if err == 0 then
    EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_CAN_GIFT, music_res_id, to_uid)
  else
    logic_pubgm_music.UpdateCacheGiftList(music_res_id, to_uid, logic_music_const.E_MusicGiftState.Cannot)
    EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_CANNOT_GIFT, music_res_id, to_uid)
  end
end
function logic_pubgm_music.OnMusicBoxSendGiftRsp(err, to_uid, music_res_id)
  if err == 0 then
    logic_pubgm_music.UpdateCacheGiftList(music_res_id, to_uid, logic_music_const.E_MusicGiftState.Gifted)
    ShowNotice(200018)
    UIManager.CloseUI(UIManager.UI_Config.New_Shop_gift_All_UIBP)
  else
    logic_pubgm_music.UpdateCacheGiftList(music_res_id, to_uid, logic_music_const.E_MusicGiftState.Cannot)
  end
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_GIFT_SUCCESS, music_res_id, to_uid)
end
function logic_pubgm_music.OnMusicBoxGetFriendBgmRsp(fri_uid, music_list, bgm_music_type, bgm_music_single)
  local data = {
    fri_uid = fri_uid,
    music_list = music_list,
    bgm_music_type = bgm_music_type,
      }
  log_tree(" logic_pubgm_music.OnMusicBoxGetFriendBgmRsp data:", data)
  EventSystem:postEvent(EVENTTYPE_PUBGM_MUSIC, EVENTID_PUBGM_MUSIC_GET_FRIEND_BGM, data)
end
function logic_pubgm_music.GetMusicInfoById(id)
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  if musicManager:IsInHome() then
    local logic_home_music = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_music)
    return logic_home_music:GetHomeMusicInfoById(id)
  end
  local allMusicData = logic_pubgm_music.GetMusicDataByOwnedState(E_MusicOwnedState.All)
  for _, v in ipairs(allMusicData) do
    if v.nID == id then
      local logic_pubgm_music_download = require("client.slua.logic.pubgm_music.logic_pubgm_music_download")
      v.nState = logic_pubgm_music_download.GetMusicDownloadStateByID(v.nID)
      return v
    end
  end
  return nil
end
function logic_pubgm_music.GetMusicJumpUrl()
  if not logic_pubgm_music.svr_data then
    log(bWriteLog and "[muidarzhang] logic_pubgm_music.GetMusicJumpUrl, not self.svr_data. ")
    return
  end
  return TableUtil.GetTableValue(logic_pubgm_music.svr_data, "music_website_url")
end
function logic_pubgm_music.IsMusicListEmpty()
  return not logic_pubgm_music.musicList or not next(logic_pubgm_music.musicList)
end
return logic_pubgm_music