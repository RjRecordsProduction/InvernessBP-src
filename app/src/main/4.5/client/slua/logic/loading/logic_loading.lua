local _bIsToLobby = true
local _SpecifyToMapID, BIsFromBigEvent
local random = math.random
local local local StringUtil = require("common.string_util")
local NInitPercent = 0
local NSliderPercent = 0
local NBreakMinValue = 0
local BTimerSwitch = false
local SelectedLoadingCfg, NSelectedLoadingId, _nShowLoadingResGroup
local _nShowLoadingResIndex = 1
local _tCacheLocalLoading
local LoadingSystem = {
  DefaultPath = "/Game/UMG/Texture/LoadingUI/Default_Loading_Image.Default_Loading_Image",
  TeamDefaultPath = "/Game/UMG/Texture/Lobby_NoAtlas/Team_Competition/Team_Default_Loading_Image.Team_Default_Loading_Image"
}
local BP_LoadingBgPath = LoadingSystem.DefaultPath
local BUseGm = false
local _bIsUseLocalCfg = false
local SLoadingTip = ""
local _tNeedDownloadPic = {}
local _tPicDownloadParams
local _nTestMapId = -1
local TimeUtil = require("client.common.time_util")
local SEnableEnterBattleAsyncLoadingTimeLimitScale = "EnableEnterBattleAsyncLoadingTimeLimitScale"
local NDefaultAsyncLoadingTimeLimitScale = 1
local BEnterBattleAsyncLoadingTimeLimitScaleOpened = false
function LoadingSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "LoadingSystem.OnModePostSwitch nextState = " .. tostring(nextState))
  if nextState ~= GameStatus.Fighting and nextState ~= GameStatus.Loading then
    log(bWriteLog and "LoadingSystem.OnModePostSwitch,  nextState ~= GameStatus.Fighting and nextState ~= GameStatus.Loading. ")
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission(true) then
      log(bWriteLog and "LoadingSystem.OnModePostSwitch, LogicTxMissionMain.IsInXMission(true). ")
      local timer_tick = require("common.time_ticker")
      if LoadingSystem.xmission_timer then
        timer_tick.RemoveTimer(LoadingSystem.xmission_timer)
        LoadingSystem.xmission_timer = nil
      end
      LoadingSystem.xmission_timer = timer_tick.AddTimerOnce(30, function()
        log(bWriteLog and "LoadingSystem.OnModePostSwitch, timer_tick.")
        LoadingSystem.RefreshLoadPercent(1)
      end)
    else
      LoadingSystem.RefreshLoadPercent(1)
    end
    LoadingSystem.TriggerDownloadPicCache()
  end
end
function LoadingSystem.InitOnlyOne()
  log(bWriteLog and "  : LoadingSystem Init")
end
function LoadingSystem.IsShowing()
  return UIManager.IsUIShow(UIManager.UI_Config.loading)
end
function LoadingSystem.UseGm()
  BUseGm = true
end
function LoadingSystem.GetUseGm()
  return BUseGm
end
function LoadingSystem.SetTestMapId(nMapId)
  _nTestMapId = nMapId
end
function LoadingSystem.SetIsUseLocalCfg(bUseLocalCfg)
  _bIsUseLocalCfg = bUseLocalCfg
end
LoadingSystem.E_ShowLoadingSceneType = {
  Default = 1,
  VisitManorRsp = 2,
  ReEnterGame = 3,
  EnterGame = 4
}
local SetEnterBattleAsyncLoadingTimeLimitScale = function(scale)
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  if gameInstance == nil then
    return false
  end
  gameInstance:ExecuteCMD("s.AsyncLoadingTimeLimitScale", scale)
  return true
end
local TryOpenEnterBattleAsyncLoadingTimeLimitScale = function(showLoadingSceneType)
  local NAsyncLoadingTimeLimitScale = HDmpveRemote.HDmpveRemoteConfigGetInt(SEnableEnterBattleAsyncLoadingTimeLimitScale, 0)
  if NAsyncLoadingTimeLimitScale <= 0 then
    return
  end
  if showLoadingSceneType ~= LoadingSystem.E_ShowLoadingSceneType.EnterGame and showLoadingSceneType ~= LoadingSystem.E_ShowLoadingSceneType.ReEnterGame then
    return
  end
  if BEnterBattleAsyncLoadingTimeLimitScaleOpened then
    return
  end
  BEnterBattleAsyncLoadingTimeLimitScaleOpened = SetEnterBattleAsyncLoadingTimeLimitScale(NAsyncLoadingTimeLimitScale)
end
local ResetEnterBattleAsyncLoadingTimeLimitScale = function()
  if not BEnterBattleAsyncLoadingTimeLimitScaleOpened then
    return
  end
  SetEnterBattleAsyncLoadingTimeLimitScale(NDefaultAsyncLoadingTimeLimitScale)
  BEnterBattleAsyncLoadingTimeLimitScaleOpened = false
end
function LoadingSystem.ShowLoading(toLobby, ToMapID, sub_mode, showLoadingSceneType, main_mode)
  print(bWriteLog and "LoadingSystem.ShowLoading, toLobby = " .. tostring(toLobby))
  print(bWriteLog and "LoadingSystem.ShowLoading, ToMapID = " .. tostring(ToMapID))
  print(bWriteLog and "LoadingSystem.ShowLoading, sub_mode = " .. tostring(sub_mode))
  showLoadingSceneType = showLoadingSceneType or LoadingSystem.E_ShowLoadingSceneType.Default
  print(bWriteLog and "LoadingSystem.ShowLoading, showLoadingSceneType = " .. tostring(showLoadingSceneType))
  _bIsToLobby = toLobby
  _Specify  local logic_teamcomp_loading = require("client.slua.logic.loading.logic_teamcomp_loading")
  if logic_teamcomp_loading.GetShowing() then
    return
  end
  if sub_mode == 64783 or sub_mode == 64787 then
    local logic_solo_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_solo_pk)
    logic_solo_pk:ShowLoadingUI()
    return
  end
  TryOpenEnterBattleAsyncLoadingTimeLimitScale(showLoadingSceneType)
  if not LoadingSystem.IsShowing() then
    EventSystem:postEvent(EVENTTYPE_WOW_EDITOR, EVENTID_WOW_EDITOR_SHOW_LOADING)
    EventSystem:postEvent(EVENTTYPE_WOW_EDITOR, EVENTID_WOW_EDITOR_LOADING, 0)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_BEGIN, toLobby, showLoadingSceneType)
    LoadingSystem._InitLoading()
    LoadingSystem.SetShow450Naruto(toLobby, ToMapID, sub_mode)
    UIManager.ShowUI(UIManager.UI_Config.loading)
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, toLobby, showLoadingSceneType)
    log(bWriteLog and "Client.EnableIosStuckWork(GameFrontendHUD, false);")
    Client.EnableIosStuckWork(GameFrontendHUD, false)
  end
  if sub_mode then
    local LoadingUI = UIManager.GetUI(UIManager.UI_Config.loading)
    if LoadingUI then
      LoadingUI:Refresh(sub_mode, main_mode)
    end
  end
end
function LoadingSystem._InitLoading()
  log(bWriteLog and "LoadingSystem._InitLoading")
  if not LobbySystem.isWaittingEnterBattle then
    log(bWriteLog and "LoadingSystem._InitLoading not LobbySystem.isWaittingEnterBattle")
    NBreakMinValue = math.random(55, 85) / 100
  end
  log(bWriteLog and "LoadingSystem._InitLoading NBreakMinValue = " .. tostring(NBreakMinValue))
  BTimerSwitch = true
  NSliderPercent = NInitPercent / 100
  log(bWriteLog and "NSliderPercent" .. tostring(NSliderPercent))
  xpcall(function()
    LoadingSystem.SetLoadGroup()
  end, function(msg)
    local utility = require("common.utility")
    utility.ErrorMessageHandler("Loading get path Error >>>> " .. msg)
    BP_LoadingBgPath = LoadingSystem.DefaultPath
  end)
end
function LoadingSystem.OnLoadingFinished()
  local memorySize = Client.GetMemorySize()
  if memorySize < 3 and nextState ~= GameStatus.Loading then
    log(bWriteLog and "LoadingSystem.OnModePostSwitch, ready to close loading BP.")
    UIManager.CloseUI(UIManager.UI_Config.loading)
    log(bWriteLog and "LoadingSystem.OnModePostSwitch, close loading BP.")
  end
end
function LoadingSystem.LoadingFinishedRelease()
  ResetEnterBattleAsyncLoadingTimeLimitScale()
  _tCacheLocalLoading = nil
end
function LoadingSystem.SetInitPercent(percent)
  NSliderPercent = percent / 100
  NInitPercent = percent
end
function LoadingSystem.SetSliderPercent()
  local ui = UIManager.GetUI(UIManager.UI_Config.loading)
  if ui then
    ui:UpdatePercent(NSliderPercent)
  end
end
function LoadingSystem.Tick()
  if not BTimerSwitch then
    return
  end
  local rand = random(20, 30) / 100
  local percent = NSliderPercent + rand
  if percent < NBreakMinValue or 1 <= NBreakMinValue then
    NSliderPercent = percent
  end
  if 1 <= NSliderPercent then
    log(bWriteLog and "LoadingSystem.Tick EVENTTYPE_LOBBY EVENTID_LOADING_PRE_FINISH")
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH)
    EventSystem:postEvent(EVENTTYPE_WOW_EDITOR, EVENTID_WOW_EDITOR_LOADING, 100)
    BTimerSwitch = false
  end
  LoadingSystem.SetSliderPercent()
end
function LoadingSystem.GetToLobby()
  log(bWriteLog and "  :get bToLobby" .. tostring(_bIsToLobby))
  return _bIsToLobby
end
function LoadingSystem.SetBigEvent(bBigEvent)
  BIsFromBigEvent = bBigEvent
  log(bWriteLog and "  : BIsFromBigEvent" .. tostring(BIsFromBigEvent))
end
function LoadingSystem.GetBigEvent()
  log(bWriteLog and "  :get BIsFromBigEvent" .. tostring(BIsFromBigEvent))
  return BIsFromBigEvent
end
function LoadingSystem.GetBgPath()
  return BP_LoadingBgPath
end
function LoadingSystem.GetDefaultPath()
  return LoadingSystem.DefaultPath
end
function LoadingSystem.GetTeamDefaultPath()
  return LoadingSystem.TeamDefaultPath
end
function LoadingSystem.loadpic_cfg_refresh(serverTableSetTime)
  local GlobalNetHandler = require("client.network.Protocol.GlobalNetHandler")
  GlobalNetHandler.send_get_loading_show_cfg_req()
end
function LoadingSystem.SetLoadGroup()
  if _nTestMapId ~= -1 then
    _nShowLoadingResGroup = _nTestMapId
    LoadingSystem.GetResourcePathByID(_nTestMapId)
    return
  end
  local mapId = _SpecifyToMapID or _bIsToLobby and 0 or LoadingSystem.GetCurrentMapId()
  _SpecifyToMapID = nil
  local tRoomInfo = RoomSystem.CurrentRoomInfo
  if tRoomInfo and tRoomInfo.map_id then
    mapId = tRoomInfo.map_id
    log(bWriteLog and string.format("LoadingSystem.SetLoadGroup Room MapId = %d", mapId))
  end
  log(bWriteLog and string.format(" LoadingSystem.SetLoadGroup mapId = %d >>> bIsToLobby = %s >>> CurMapId = %d", mapId, tostring(_bIsToLobby), LoadingSystem.GetCurrentMapId()))
  local maps_cfg = CDataTable.GetTable("LoadingMapConfig")
  if not maps_cfg then
    BP_LoadingBgPath = LoadingSystem.DefaultPath
    NSelectedLoadingId = nil
    return
  end
  local sMapId = tostring(mapId)
  local bIsFindMap = false
  for _, v in pairs(maps_cfg) do
    if v.maps ~= "" then
      local maps = StringUtil.Split(v.maps, ";")
      for _, vv in pairs(maps) do
        if vv == sMapId then
          bIsFindMap = true
          break
        end
      end
    end
  end
  LoadingSystem.GetLoadingBgPathByMapId(mapId, bIsFindMap)
  log(bWriteLog and "BP_LoadingBgPath" .. tostring(BP_LoadingBgPath))
end
function LoadingSystem.GetCurrentMapId()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local BTMode = CDataTable.GetTableData("BTMode", MatchModeMgrSystem.nInGameModeID)
  log(bWriteLog and "  : MatchModeMgrSystem.nInGameModeID" .. tostring(MatchModeMgrSystem.nInGameModeID))
  if BTMode and BTMode.MapID then
    log(bWriteLog and "  : BTMode" .. tostring(BTMode.MapID))
    return BTMode.MapID
  end
  return 0
end
function LoadingSystem.GetLoadingBgPathByMapId(mapId, strictMatching)
  local sMapIdStr = tostring(mapId)
  local gameId = Client.GetITopGameId()
  local tShowCfg = {}
  local self_zone = DataMgr.RegionData.region
  if not self_zone then
    local sRegionArea = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if sRegionArea == PublishRegionMacros.JAPAN then
      self_zone = "JP"
    elseif sRegionArea == PublishRegionMacros.KOREA then
      self_zone = "KR"
    end
  end
  log(bWriteLog and "LoadingSystem.GetLoadingBgPathByMapId >>> mapId = " .. tostring(mapId) .. " gameId = " .. tostring(gameId) .. " self_zone = " .. tostring(self_zone))
  local uObj_mapsCfg = CDataTable.GetTable("LoadingMapConfig") or {}
  for _, v in pairs(uObj_mapsCfg) do
    local isMap = false
    if v.maps ~= "" then
      if strictMatching then
        local maps = StringUtil.Split(v.maps, ";")
        for _, vv in pairs(maps) do
          if vv == sMapIdStr then
            isMap = true
            break
          end
        end
      end
    else
      isMap = not strictMatching
    end
    local isZone = false
    if v.zones == "" then
      isZone = true
    elseif self_zone and string.find(v.zones, self_zone) then
      isZone = true
    end
    local isAppValid = false
    if v.switch and v.switch ~= "" then
      local gameIds = StringUtil.Split(v.switch, ";")
      for _, vv in pairs(gameIds) do
        if vv == gameId then
          isAppValid = true
        end
      end
    else
      isAppValid = true
    end
    if isMap and isZone and isAppValid then
      tShowCfg = v
      break
    end
  end
  log(bWriteLog and "tShowCfg.id = " .. tostring(tShowCfg.id))
  if tShowCfg.id then
    _nShowLoadingResGroup = tShowCfg.id
    return LoadingSystem.GetResourcePathByID(_nShowLoadingResGroup)
  else
    log(bWriteLog and "  :loadingSystem no cfg")
    return LoadingSystem.DefaultPath
  end
end
function LoadingSystem.GetResourcePathByID(index)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local NetData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoadingConfig)
  if not (NetData and next(NetData)) or _bIsUseLocalCfg then
    if not _tCacheLocalLoading then
      _tCacheLocalLoading = CDataTable.GetTable("LoadingResourceConfig")
    end
    NetData = _tCacheLocalLoading
    log(bWriteLog and " LoadingSystem.GetResourcePathByID NetData Use Local Table")
  end
  local NetRet = LoadingSystem.GetResourcePath(index, NetData)
  return NetRet or LoadingSystem.DefaultPath
end
local _ConvertTime = function(aTimeData)
  return type(aTimeData) == "string" and TimeUtil.TimeStringToUnixstamp(aTimeData) or aTimeData
end
function LoadingSystem.GetResourcePath(index, loading_cfg)
  NSelectedLoadingId = nil
  local sIndexStr = tostring(index)
  local nTempCount = 0
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local tTempInfoTb = {}
  for nId, tCurCfg in pairs(loading_cfg) do
    tCurCfg.Id = nId
    local bIsInGroup = false
    local nBeginTime = _ConvertTime(tCurCfg.begin_time)
    local nEndTime = _ConvertTime(tCurCfg.end_time)
    if nNowTime > nBeginTime and nNowTime < nEndTime then
      local groups = StringUtil.Split(tCurCfg.groups or "", ";")
      for _, vv in pairs(groups) do
        if vv == sIndexStr then
          bIsInGroup = true
          break
        end
      end
    end
    if bIsInGroup then
      nTempCount = nTempCount + 1
      tTempInfoTb[nTempCount] = tCurCfg
    end
  end
  table.sort(tTempInfoTb, function(a, b)
    local a_weight = a.weight or 0
    local b_weight = b.weight or 0
    if a_weight == b_weight then
      return a.Id < b.Id
    end
    return a_weight < b_weight
  end)
  SelectedLoadingCfg = tTempInfoTb
  return LoadingSystem.GetLoadingShowData(true)
end
function LoadingSystem.GetLoadingShowData(bIsUseNew)
  NSelectedLoadingId = nil
  local nMapGroupId = _nShowLoadingResGroup or 1
  local tLoadingCfg = SelectedLoadingCfg or {}
  local sBgPath
  local sTip = ""
  local nShowIndex = LoadingSystem.GetMapGroupShowIndex(tLoadingCfg, nMapGroupId, bIsUseNew)
  local tShowCfg = tLoadingCfg[nShowIndex]
  if tShowCfg then
    sBgPath = tShowCfg.path
    sTip = tShowCfg.loading_tip or ""
    NSelectedLoadingId = tShowCfg.Id
  end
  local util = require("client.slua_ui_framework.util")
  sBgPath = sBgPath and util.GetUrlByLanguage(sBgPath) or LoadingSystem.DefaultPath
  log(bWriteLog and string.format(" LoadingSystem.GetLoadingShowData: sBgPath = %s, sTip = %s", sBgPath, sTip))
  BP_LoadingBgPath = sBgPath
  SLoadingTip = sTip
  return sBgPath, SLoadingTip
end
function LoadingSystem.GetMapGroupShowIndex(tLoadingCfg, nMapGroupId, bIsUseNew)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tMapShowCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoadingGroupShowCache) or {}
  local nShowIndex = tMapShowCache[tostring(nMapGroupId)]
  if not nShowIndex or type(nShowIndex) ~= "number" then
    nShowIndex = 1
  end
  if bIsUseNew then
    nShowIndex = nShowIndex + 1
    if nShowIndex > #tLoadingCfg then
      nShowIndex = 1
    end
  end
  log(bWriteLog and " LoadingSystem.GetMapGroupShowIndex >>> nShowIndex = " .. nShowIndex .. " >>>> #tLoadingCfg = " .. #tLoadingCfg)
  _nShowLoadingResIndex = nShowIndex
  return nShowIndex
end
function LoadingSystem.SaveMapGroupShowIndex()
  if not _nShowLoadingResGroup then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tMapShowCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoadingGroupShowCache) or {}
  tMapShowCache[tostring(_nShowLoadingResGroup)] = _nShowLoadingResIndex
  PlayerPrefsSystem.SaveTableToFile_N(tMapShowCache, PlayerPrefsSystem.ePlayerPrefsType.eLoadingGroupShowCache)
end
function LoadingSystem.GetLoadingTempInfo()
  return SelectedLoadingCfg
end
function LoadingSystem.SetSelectedLoadingId(nId)
  NSelectedLoadingId = nId
end
function LoadingSystem.GetSelectedLoadingId()
  return NSelectedLoadingId
end
function LoadingSystem.SetLoadingTipStr(sTip)
  SLoadingTip = sTip or ""
end
function LoadingSystem.GetLoadingTipInfo()
  return SLoadingTip
end
function LoadingSystem.RefreshLoadPercent(p, bForceSetToSlider)
  log(bWriteLog and "LoadingSystem.RefreshLoadPercent p = " .. tostring(p) .. ", bForceSetToSlider = " .. tostring(bForceSetToSlider))
  if not p then
    return
  end
  if 1 <= p and not LoadingSystem.CheckLoadingCanSetToComplete() then
    print(bWriteLog and "LoadingSystem.RefreshLoadPercent not cansettocomplete")
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if 1 <= p then
    log_shipping_client(bWriteLog and "rain profile Login -> Lobby done")
    TeamAvatarManager.PlayBigEventToLobbyAction()
  end
  if bForceSetToSlider and p > NSliderPercent then
    NSliderPercent = p
  end
  NBreakMinValue = p
  BUseGm = nil
end
function LoadingSystem.SetNBreakMinValue(p)
  log(bWriteLog and "LoadingSystem.SetNBreakMinValue p = " .. tostring(p))
  NBreakMinValue = p
end
function LoadingSystem.CheckLoadingCanSetToComplete()
  local CanToComplete = true
  local logic_ugc_loading = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_loading)
  if not logic_ugc_loading:CheckLoadingCanSetToComplete() then
    CanToComplete = false
  end
  return CanToComplete
end
function LoadingSystem.SetBTimerSwitch(bIsValid)
  BTimerSwitch = bIsValid
end
function LoadingSystem.DownloadInGameImages()
  if slua_GameFrontendHUD then
    log(bWriteLog and "[YY-D] LoadingSystem.DownloadInGameImages")
    local uGameState = slua_GameFrontendHUD:GetGameState()
    local GameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameState) and uGameState.GetGameModeState then
      local sGameModeState = uGameState:GetGameModeState()
      if sGameModeState == "FightingState" then
        log(bWriteLog and "[YY-D] LoadingSystem.DownloadInGameImages FightingState Don't DownLoad Image")
        return
      end
    end
    if slua.isValid(GameInstance) then
      do
        local nDeviceLevel = GameInstance:GetDeviceLevel()
        if nDeviceLevel < 1 then
          log(bWriteLog and "[YY-D] DownloadInGameImages nDeviceLevel < 1")
          return
        end
        if slua.isValid(GameInstance.ClientBaseInfo) and slua.isValid(GameInstance.ClientBaseInfo.AdvTextureList) then
          local AdvTextureList = slua.IndexReference(GameInstance, "ClientBaseInfo", "AdvTextureList")
          AdvTextureList:Clear()
        else
          log(bWriteLog and "[YY-E] DownloadInGameImages AdvTextureList not Valid")
          return
        end
        local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
        local tHasDownload = {}
        FuncUtil.UE4ExecuteConsoleCommand("s.EnableCompressFormatDownload 1")
        local downloadExtendedParams = {enableCDNCompress = true}
        if slua.isValid(GameInstance) and slua.isValid(GameInstance.ClientBaseInfo) and slua.isValid(GameInstance.ClientBaseInfo.AdvConfig) then
          local ad_conf = GameInstance.ClientBaseInfo.AdvConfig
          for _, UrlPath in pairs(ad_conf) do
            if UrlPath and UrlPath ~= "" then
              local StringUtil = require("common.string_util")
              local UrlPathList = StringUtil.Split(UrlPath, "|")
              if UrlPathList and next(UrlPathList) then
                for _, sUrl in pairs(UrlPathList) do
                  if not tHasDownload[sUrl] then
                    image_download_mgr:DownloadImageByHttpWrapper(sUrl, function(texture, imgUrl)
                      if imgUrl and slua.isValid(GameInstance.ClientBaseInfo) and slua.isValid(GameInstance.ClientBaseInfo.AdvTextureList) then
                        local AdvTextureList = slua.IndexReference(GameInstance, "ClientBaseInfo", "AdvTextureList")
                        if not slua.isValid(AdvTextureList:Get(imgUrl)) then
                          log(bWriteLog and "[YY-D] DownloadInGameImages Success sUrl = " .. imgUrl)
                          AdvTextureList:Add(imgUrl, texture)
                        end
                      end
                      log(bWriteLog and "[YY-D] DownloadInGameImages download success")
                    end, function()
                      log(bWriteLog and "[YY-E] DownloadInGameImages download failed")
                    end, downloadExtendedParams)
                    log(bWriteLog and "[YY-D] DownloadInGameImages sUrl = " .. sUrl)
                    tHasDownload[sUrl] = true
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
function LoadingSystem.ClearInGameImages()
  if slua_GameFrontendHUD then
    log(bWriteLog and "[YY-D] LoadingSystem.ClearInGameImages Start")
    local ScriptHelperClient = import("ScriptHelperClient")
    FuncUtil.SafeCallFun(ScriptHelperClient, "RunConsoleCommond", "s.EnableCompressFormatDownload 0")
    local GameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(GameInstance) then
      if slua.isValid(GameInstance.ClientBaseInfo) and slua.isValid(GameInstance.ClientBaseInfo.AdvTextureList) then
        local AdvTextureList = slua.IndexReference(GameInstance, "ClientBaseInfo", "AdvTextureList")
        AdvTextureList:Clear()
        log(bWriteLog and "[YY-D] LoadingSystem.ClearInGameImages Finished")
      else
        log(bWriteLog and "[YY-E] DownloadInGameImages AdvTextureList not Valid")
        return
      end
    end
  end
end
function LoadingSystem.AddDownloadPicCache(sPicUrl)
  _tNeedDownloadPic[sPicUrl] = true
end
function LoadingSystem.RemoveDownloadPicCache(_, sPicUrl)
  _tNeedDownloadPic[sPicUrl] = nil
end
function LoadingSystem.TriggerLoadingPicPakDownload(sImagePath)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {sImagePath}, PufferTlog.Enum_TLog_From.Loading, function()
    log(bWriteLog and "LoadingSystem.TriggerLoadingPicPakDownload Download Suc, Path >>> " .. sImagePath)
    LoadingSystem.RemoveDownloadPicCache(nil, sImagePath)
  end, {bAutoDownload = true})
end
function LoadingSystem.TriggerDownloadPicCache()
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  if not _tPicDownloadParams then
    local DiskCacheTypeEnum = image_download_mgr:GetDiskCacheTypeEnum()
    _tPicDownloadParams = {
      enableCDNCompress = true,
      diskCacheType = DiskCacheTypeEnum.WeeklyUpdate,
      bDownloadOnModeSwitch = true
    }
  end
  local util = require("client.slua_ui_framework.util")
  for k, _ in pairs(_tNeedDownloadPic) do
    if util.IsOnlineImageUrl(k) then
      image_download_mgr:DownloadImageByHttpWrapper(k, LoadingSystem.RemoveDownloadPicCache, nil, _tPicDownloadParams)
    else
      LoadingSystem.TriggerLoadingPicPakDownload(k)
    end
  end
end
function LoadingSystem.GetGuideConfig()
  local loading_attach_ui_config = require("client.slua.logic.loading.loading_attach_ui_config")
  table.sort(loading_attach_ui_config, function(a, b)
    return a.priority > b.priority
  end)
  return loading_attach_ui_config
end
function LoadingSystem.SetShow450Naruto(toLobby, ToMapID, sub_mode)
  local LobbySystem = require("client.logic.login.logic_lobby")
  local inTime = LobbySystem.IsInNarutoVersionTime()
  LoadingSystem.bShow450Naruto = false
  local string_util = require("common.string_util")
  local LinkedElementDisplayDuration = CDataTable.GetTableData("LinkedElementDisplayDuration", 1)
  if sub_mode then
    local bFindNarutoSubMode = false
    if LinkedElementDisplayDuration and LinkedElementDisplayDuration.SubMod then
      local subModInfo = string_util.Split(LinkedElementDisplayDuration.SubMod, "|")
      for _, v in ipairs(subModInfo) do
        if tonumber(v) == sub_mode then
          bFindNarutoSubMode = true
          break
        end
      end
    end
    if inTime and not toLobby and bFindNarutoSubMode then
      log(bWriteLog and "LoadingSystem.SetShow450Naruto sub_mode")
      LoadingSystem.bShow450Naruto = true
    end
  else
    local nCurMapId = LoadingSystem.GetCurrentMapId()
    local bIsInNarutoMap = nCurMapId == 0
    if not bIsInNarutoMap and LinkedElementDisplayDuration and LinkedElementDisplayDuration.MapList then
      local mapInfo = string_util.Split(LinkedElementDisplayDuration.MapList, "|")
      for _, v in ipairs(mapInfo) do
        if tonumber(v) == nCurMapId then
          bIsInNarutoMap = true
          break
        end
      end
    end
    if inTime and toLobby and bIsInNarutoMap then
      log(bWriteLog and "LoadingSystem.SetShow450Naruto map nCurMapId : " .. tostring(nCurMapId))
      LoadingSystem.bShow450Naruto = true
    end
  end
end
function LoadingSystem.GetShow450Naruto()
  return LoadingSystem.bShow450Naruto or false
end
return LoadingSystem