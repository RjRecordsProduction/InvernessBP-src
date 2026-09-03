local CreateRoomSystem = {
  basicParam = {},
  advanceParam = nil,
  advanceParamShowList = nil,
  bChangeMap = false,
  IsFromDeepLink = false,
  thirdPartyInfo = {},
  thirdParty_callback_link = {},
  is_Asia_Games_white = false,
  is_Asia_GM = false,
  ESportRoomCardConfig = {},
  ESportRoomCardMapList = {},
  ESportRoomCardDefaultMapId = {},
  limitMaps = nil
}
local C_DefaultBasicParam = {
  nMapID = 1,
  bOB = false,
  bPCParam = false,
  bInnerTest = false,
  sRoomName = "",
  nPerspective = ENUM_PerspectiveType.TPP,
  nPlayerNum = 4,
  bNeedPsw = true,
  sPassword = "",
  nMemMax = 100,
  quick_create_room_params = {bring_team_in = false},
  weather = {id = 0, level = ""}
}
local C_EmptyWeatherParam = {
  [0] = ""
}
local C_AsiaRoomCardConfig = {
  [2105003] = true,
  [2105004] = true,
  [2105005] = true,
  [2105006] = true,
  [2105007] = true
}
local C_ESportTestRoomCard = 2103051
local C_CallBackLink_ErrorCode = {
  Uid_Invalid = "uid_invalid",
  Nick_Invalid = "nick_invalid"
}
local data_config_marco = require("client.logic.data.data_config_marco")
local C_ServerConfigName_ESport = data_config_marco.custom_room_privilege_table
function CreateRoomSystem.OnLogin()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(C_ServerConfigName_ESport)
end
function CreateRoomSystem.GetSwitchCfgByMapId(nMapId)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local uCfg = CDataTable.GetTableData("MapSwitchCfg_JK", nMapId)
    if uCfg then
      return uCfg
    end
  end
  return CDataTable.GetTableData("MapSwitchCfg", nMapId)
end
function CreateRoomSystem.ConvertRoomTypes(sRoomTypes)
  if sRoomTypes == "" then
    return
  end
  local tRoomTypes = {}
  local StringUtil = require("common.string_util")
  local tAllRoomTypes = StringUtil.Split(sRoomTypes, ";")
  for _, v in pairs(tAllRoomTypes) do
    tRoomTypes[v] = true
  end
  return tRoomTypes
end
function CreateRoomSystem.GetPrivilegeConfig()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  return BasicDataServerTable:GetCacheData(C_ServerConfigName_ESport)
end
function CreateRoomSystem.ShowCreateOrdinaryRoom()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomSystem.ShowCreateRoomUI(CreateRoomConfig.C_RoomTypeMap.Ordinary)
end
function CreateRoomSystem.ShowCreateAdvanceRoom()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomSystem.ShowCreateRoomUI(CreateRoomConfig.C_RoomTypeMap.Advance)
end
function CreateRoomSystem.ShowCreateMatchRoom()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomSystem.ShowCreateRoomUI(CreateRoomConfig.C_RoomTypeMap.Match)
end
function CreateRoomSystem.CheckDev()
  if Client and not Client.IsShipping() then
    return true
  end
  return false
end
function CreateRoomSystem.ShowRoomByDeepLink(eventType, eventID, vars)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_THIRD_PARTY_DEEPLINK) then
    return
  end
  local params = vars
  if params and params.action_id then
    if CreateRoomSystem.CheckDev() then
      ShowNotice(25520)
    end
    if params.action_id == "create" then
      log_tree("ShowRoomByDeepLink=====create_parameters", vars)
      CreateRoomSystem.ShowCreateRoomByDeepLink(vars)
    elseif params.action_id == "join" then
      CreateRoomSystem.ShowJoinRoomByDeepLink(vars)
    elseif params.action_id == "validation" then
      CreateRoomSystem.GetThirdPartyUserID(params)
    end
  elseif CreateRoomSystem.CheckDev() then
    ShowNotice(25521)
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  AdjustSystem:ClearAdjustDeepLink()
end
function CreateRoomSystem.ParseThirdPartyFullCallBackLink(params, s)
  if not (params and s) or type(s) ~= "string" then
    return
  end
  local moduleId = tonumber(params.module)
  local action_id = params.action_id
  if not (moduleId and moduleId == BP_ENUM_MODULE_MATCH_GTV_TOROOM and action_id) or action_id ~= "validation" then
    return
  end
  local curSuccessLink = params.thirdparty_success_callback_link
  local curFailureLink = params.thirdparty_failure_callback_link
  local JumpUtils = require("client.logic.store.jump_utils")
  if curSuccessLink and curFailureLink and (JumpUtils.IsHttpOrHttpsJumpUrl(curSuccessLink) or JumpUtils.IsHttpOrHttpsJumpUrl(curFailureLink)) then
    return
  end
  local successStartIndex, successEndIndex = string.find(s, "&thirdparty_success_callback_link=", 1, true)
  local failureStartIndex, failureEndIndex = string.find(s, "&thirdparty_failure_callback_link=", 1, true)
  if successStartIndex and failureStartIndex then
    local successFullLink = string.sub(s, successEndIndex + 1, failureStartIndex - 1)
    log(bWriteLog and "[YY]successLink==" .. tostring(successFullLink))
    local failureFullLink = string.sub(s, failureEndIndex + 1, string.len(s))
    log(bWriteLog and "[YY]failureFullLink==" .. tostring(failureFullLink))
    if JumpUtils.IsHttpOrHttpsJumpUrl(successFullLink) or JumpUtils.IsHttpOrHttpsJumpUrl(failureFullLink) then
      return
    end
    params.thirdparty_success_callback_link = successFullLink
    params.thirdparty_failure_callback_link = failureFullLink
  end
end
function CreateRoomSystem.ShowCreateRoomByDeepLink(vars)
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local paramList = vars
  if paramList and paramList.room_type then
    if paramList.room_type == CreateRoomConfig.C_RoomTypeMap.Advance then
      CreateRoomConfig.InitParamList(paramList.room_type)
      CreateRoomSystem.ResetBasicParam()
      CreateRoomSystem.InitAdvanceParam(paramList.room_type)
      CreateRoomSystem.SetBasicParamByDeepLink(paramList)
      CreateRoomSystem.IsFromDeepLink = true
      log(bWriteLog and "[YY]ShrinkSpeed==" .. type(paramList.ShrinkSpeed))
      if tonumber(paramList.pubgm_uid) ~= tonumber(DataMgr.roleData.uid) then
        ShowNotice(4180)
        return
      end
      local basicParam = CreateRoomSystem.basicParam
      if not CreateRoomSystem.CheckRoomNameValid(basicParam.sRoomName) then
        return
      end
      if basicParam.bNeedPsw and not CreateRoomSystem.CheckPasswordValid(basicParam.sPassword) then
        return
      end
      CreateRoomSystem.CreateRoom(paramList.room_type, nil, paramList)
    elseif paramList.room_type == CreateRoomConfig.C_RoomTypeMap.Match or paramList.room_type == CreateRoomConfig.C_RoomTypeMap.Bonus then
    elseif paramList.room_type == CreateRoomConfig.C_RoomTypeMap.Ordinary then
    end
  else
    CreateRoomSystem.IsFromDeepLink = false
  end
end
function CreateRoomSystem.CheckAdvancedRoomCard()
  local expire_ts = DataMgr.room_card_info_adv.expire_ts
  local rest_times = DataMgr.room_card_info_adv.rest_times
  local TimeUtil = require("client.common.time_util")
  local leftTs = expire_ts - TimeUtil.GetServerTimeInSec()
  local isCan = false
  if expire_ts < 0 then
    isCan = true
  elseif 0 < leftTs then
    isCan = true
  else
    local leftTimes = rest_times
    if 0 < leftTimes then
      isCan = true
    end
  end
  if not isCan then
    CreateRoomSystem.ShowBuyRoomCard()
  end
  return isCan
end
function CreateRoomSystem.ShowBuyRoomCard()
  local str = LocUtil.GetLocalizeResStr(6024)
  local tip = LocUtil.GetLocalizeResStr(117082)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, tip, str, function()
    if UIManager.IsUIShow(UIManager.UI_Config.mode_selection_main) then
      UIManager.CloseUI(UIManager.UI_Config.mode_selection_main)
    end
    LobbySystem.CloseOtherMenu()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      log(bWriteLog and "[YY]\230\151\165\233\159\169\231\137\136\228\187\142\229\149\134\229\159\142\232\180\173\228\185\176\230\136\191\229\141\161\229\144\142\232\183\179\232\189\172")
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      store_supply_manager:JumpToStoreCrateByItemId(2103006, nil, BP_ENUM_MODULE_ROOM)
    else
      log(bWriteLog and "[YY]\229\133\168\231\144\131\231\137\136\228\187\142\229\149\134\229\159\142\232\180\173\228\185\176\230\136\191\229\141\161\229\144\142\232\183\179\232\189\172")
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      store_supply_manager:JumpToStoreCrateByItemId(2104006, nil, BP_ENUM_MODULE_ROOM)
    end
  end)
end
function CreateRoomSystem.ShowJoinRoomByDeepLink(vars)
  local paramList = vars
  if paramList then
    if CreateRoomSystem.CheckDev() then
      ShowNotice(25520)
    end
    local uid = paramList.pubgm_uid or "0"
    local room_id = paramList.room_id or 0
    local password = paramList.password or ""
    CreateRoomSystem.thirdPartyInfo = {
      action_id = paramList.action_id or "",
      platform_type = tonumber(paramList.platform_type or 1),
      password = tostring(paramList.password or ""),
      room_code = paramList.room_code or paramList.third_party_room_id or 0,
      sign_time = tonumber(paramList.sign_time or 0),
      pubgm_uid = paramList.pubgm_uid or tonumber(DataMgr.roleData.uid),
      signature = paramList.signature or ""
    }
    if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
      ShowNotice(4180)
      return
    end
    RoomSystem.req_join_room(tonumber(room_id), tostring(password), CreateRoomSystem.thirdPartyInfo, nil)
  else
    CreateRoomSystem.IsFromDeepLink = false
    if CreateRoomSystem.CheckDev() then
      ShowNotice(25521)
    end
  end
end
function CreateRoomSystem.GetThirdPartyUserID(vars)
  local userInfo = {
    third_party_uid = vars and vars.third_party_uid or 0,
    uid = vars and vars.pubgm_uid or 0,
    nickname = vars and vars.nick_name or "",
    signature = vars and vars.signature or "",
    signtime = tonumber(vars and vars.sign_time or 0),
    platform_type = tonumber(vars and vars.platform_type or 1),
    success_callback_link = vars and vars.thirdparty_success_callback_link or "",
    failure_callback_link = vars and vars.thirdparty_failure_callback_link or ""
  }
  CreateRoomSystem.thirdParty_callback_link = {
    success_callback_link = userInfo.success_callback_link,
    failure_callback_link = userInfo.failure_callback_link
  }
  if tonumber(userInfo.uid) ~= tonumber(DataMgr.roleData.uid) then
    ShowNotice(9931)
    CreateRoomSystem.On_Third_Party_Uid_Validation_Fail(C_CallBackLink_ErrorCode.Uid_Invalid)
    return
  end
  if userInfo.nickname ~= DataMgr.roleData.nickName then
    ShowNotice(200015)
    CreateRoomSystem.On_Third_Party_Uid_Validation_Fail(C_CallBackLink_ErrorCode.Nick_Invalid)
    return
  end
  local CreateRoomHandler = require("client.network.Protocol.CreateRoomHandler")
  CreateRoomHandler.send_third_party_uid_validation_req(userInfo.uid, userInfo.signature, userInfo.signtime, userInfo.third_party_uid, userInfo.platform_type, userInfo.nickname)
end
function CreateRoomSystem.On_Third_Party_Uid_Validation_Success()
  local linkInfo = CreateRoomSystem.thirdParty_callback_link
  log(bWriteLog and "[YY]linkInfo==success==" .. tostring(linkInfo and linkInfo.success_callback_link))
  if linkInfo and type(linkInfo.success_callback_link) == "string" and string.find(linkInfo.success_callback_link, "http") then
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(linkInfo and linkInfo.success_callback_link)
  elseif linkInfo and type(linkInfo.success_callback_link) == "string" and string.find(linkInfo.success_callback_link, "com") then
    local url = linkInfo.success_callback_link
    Client.LaunchUrl(url)
  else
    ShowNotice(501076)
  end
  CreateRoomSystem.thirdParty_callback_link = {}
end
function CreateRoomSystem.On_Third_Party_Uid_Validation_Fail(error)
  local linkInfo = CreateRoomSystem.thirdParty_callback_link
  log(bWriteLog and "[YY]linkInfo==failure=" .. tostring(linkInfo and linkInfo.failure_callback_link))
  if linkInfo and type(linkInfo.failure_callback_link) == "string" and string.find(linkInfo.failure_callback_link, "http") then
    local url = linkInfo.failure_callback_link
    if error then
      url = url .. "&error_msg=" .. tostring(error)
    end
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(url)
  elseif linkInfo and type(linkInfo.failure_callback_link) == "string" and string.find(linkInfo.failure_callback_link, "com") then
    local url = linkInfo.failure_callback_link
    if error then
      url = url .. "&error_msg=" .. tostring(error)
    end
    Client.LaunchUrl(url)
  else
    ShowNotice(501076)
  end
  CreateRoomSystem.thirdParty_callback_link = {}
end
function CreateRoomSystem.ShowCreateRoomUI(roomType, specialMapIds)
  local privilegeList = {}
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomConfig.InitParamList(roomType)
  CreateRoomSystem.ResetBasicParam()
  CreateRoomSystem.InitAdvanceParam(roomType)
  return UIManager.ShowUI(UIManager.UI_Config.room_create, roomType, privilegeList, nil, specialMapIds)
end
function CreateRoomSystem.ShowEditRoomUI()
  if not RoomSystem.HasRoomData() then
    return nil
  end
  CreateRoomSystem.RefreshBasicParam()
  local roomType, privilegeList = CreateRoomSystem.RefreshAdvanceParam()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomConfig.InitParamList(roomType)
  return UIManager.ShowUI(UIManager.UI_Config.room_create, roomType, privilegeList)
end
function CreateRoomSystem.IsAsiaGamesRoomCard(id)
  if C_AsiaRoomCardConfig and C_AsiaRoomCardConfig[id] then
    return true
  end
  return false
end
function CreateRoomSystem.IsESportMatchRoomCard(id)
  local eRoomCardCfg = CDataTable.GetTableData("EsportsRoomCard", id or 0)
  return eRoomCardCfg and true or false
end
function CreateRoomSystem.IsESportMatchMapId(card_id, map_id)
  local _, mapList, _ = CreateRoomSystem.GetESportRoomCardMapList()
  if mapList and card_id and mapList[card_id] and mapList[card_id][map_id] then
    return true
  end
  return false
end
function CreateRoomSystem.IsESportTestMapId(map_id)
  return CreateRoomSystem.IsESportMatchMapId(C_ESportTestRoomCard, map_id)
end
function CreateRoomSystem.GetESportRoomCardMapList()
  if CreateRoomSystem.ESportRoomCardConfig and next(CreateRoomSystem.ESportRoomCardConfig) and CreateRoomSystem.ESportRoomCardMapList and next(CreateRoomSystem.ESportRoomCardMapList) and CreateRoomSystem.ESportRoomCardDefaultMapId and next(CreateRoomSystem.ESportRoomCardDefaultMapId) then
    return CreateRoomSystem.ESportRoomCardConfig, CreateRoomSystem.ESportRoomCardMapList, CreateRoomSystem.ESportRoomCardDefaultMapId
  end
  CreateRoomSystem.ESportRoomCardConfig = {}
  CreateRoomSystem.ESportRoomCardMapList = {}
  CreateRoomSystem.ESportRoomCardDefaultMapId = {}
  local privilegeConfig = CreateRoomSystem.GetPrivilegeConfig()
  if privilegeConfig and next(privilegeConfig) then
    for card_id, v in pairs(privilegeConfig) do
      for privilegeType, value in pairs(v.privileges) do
        if privilegeType == "map_ids" then
          CreateRoomSystem.ESportRoomCardConfig[card_id] = true
          if value and type(value) == "table" then
            CreateRoomSystem.ESportRoomCardMapList[card_id] = value
            for mapId, _ in pairs(value) do
              if not CreateRoomSystem.ESportRoomCardDefaultMapId[card_id] then
                CreateRoomSystem.ESportRoomCardDefaultMapId[card_id] = tonumber(mapId)
              end
              if mapId < CreateRoomSystem.ESportRoomCardDefaultMapId[card_id] then
                CreateRoomSystem.ESportRoomCardDefaultMapId[card_id] = tonumber(mapId)
              end
            end
          end
        end
      end
    end
  end
  log_tree("ESportRoomCardConfig", CreateRoomSystem.ESportRoomCardConfig)
  log_tree("ESportRoomCardMapList", CreateRoomSystem.ESportRoomCardMapList)
  log_tree("ESportRoomCardDefaultMapId", CreateRoomSystem.ESportRoomCardDefaultMapId)
  return CreateRoomSystem.ESportRoomCardConfig, CreateRoomSystem.ESportRoomCardMapList, CreateRoomSystem.ESportRoomCardDefaultMapId
end
function CreateRoomSystem.HaveDownloadAsiaGamesMap(mapKey)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    mapKey or "map_planag"
  })
  if state ~= ENUM_DownloadState.Done then
    local content = LocUtil.LocalizeResFormat(29746)
    local clickOkCallback = function()
      PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
        mapKey or "map_planag"
      }, PufferTlog.Enum_TLog_From.Click)
      local info = {isNotLobbyBtnClick = true}
      UIManager.ShowUI(UIManager.UI_Config.Download_Main_UIBP, info)
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      ui_jump_manager.Clear()
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, nil, content, clickOkCallback, nil)
    return false
  end
  return true
end
function CreateRoomSystem.send_check_is_asian_games_white_req()
  local CreateRoomHandler = require("client.network.Protocol.CreateRoomHandler")
  CreateRoomHandler.send_check_is_asian_games_white_req()
end
function CreateRoomSystem.IsAsiaGamesWhite()
  return CreateRoomSystem.is_Asia_Games_white
end
function CreateRoomSystem.ShowCreateRoomUIByItemID(id)
  local roomType
  local privilegeList = {}
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  if CreateRoomSystem.IsAsiaGamesRoomCard(id) then
    if not CreateRoomSystem.IsAsiaGamesWhite() then
      ShowNotice(18951)
      return
    end
    CreateRoomSystem.ResetBasicParam()
    UIManager.ShowUI(UIManager.UI_Config.room_create, CreateRoomConfig.C_RoomTypeMap.AG, privilegeList, id)
    return
  end
  local RoomPrivilege = CDataTable.GetTable("RoomPrivilege")
  for k, v in pairs(RoomPrivilege) do
    if v.ItemID == id then
      roomType = v.RoomType
      table.insert(privilegeList, v.Privilege)
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not roomType and Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    RoomPrivilege = CDataTable.GetTable("RoomPrivilege_IN")
    for _, v in pairs(RoomPrivilege) do
      if v.ItemID == id then
        roomType = v.RoomType
        table.insert(privilegeList, v.Privilege)
      end
    end
  end
  if not roomType then
    log_shipping_client(bWriteLog and "[edward][logic_create_room] CreateRoomSystem.ShowCreateRoomUIByItemID Config is Error")
    if not Client.IsShipping() then
      ShowNotice(86788)
    end
    return
  end
  if 1 < #privilegeList then
    table.sort(privilegeList, function(a, b)
      return a < b
    end)
  end
  CreateRoomConfig.InitParamList(roomType)
  CreateRoomSystem.ResetBasicParam()
  CreateRoomSystem.InitAdvanceParam(roomType, privilegeList)
  local config = CreateRoomSystem.GetPrivilegeConfig()
  if config and config[id] then
    CreateRoomSystem.basicParam.bPCParam = true
  end
  if CreateRoomSystem.IsESportMatchRoomCard(id) then
    CreateRoomSystem.InitCircleParam(privilegeList)
  end
  UIManager.ShowUI(UIManager.UI_Config.room_create, roomType, privilegeList, id)
end
function CreateRoomSystem.CreateRoomByItemID(id)
  local mapID = 20048
  local mapInfo = CDataTable.GetTableData("Map", mapID)
  if not mapInfo then
    return
  end
  local _send_create_privilege_room = function()
    local CreateRoomHandler = require("client.network.Protocol.TournamentHandler")
    CreateRoomHandler.send_create_privilege_room_req(LocUtil.LocalizeResFormat(7649, DataMgr.roleData.nickName), mapID, nil, 4, true, CreateRoomSystem.GetOrdinaryBattleConfig(), false, id, {bring_team_in = true}, C_EmptyWeatherParam)
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    mapInfo.MapKey
  })
  if state ~= ENUM_DownloadState.Done then
    local params = {
      locText = LocUtil.GetLocalizeResStr(505089),
      callBack = _send_create_privilege_room,
      mapKey = mapInfo.MapKey
    }
    UIManager.ShowUI(UIManager.UI_Config.Common_Room_Download_Popup_UIBP, params)
  else
    _send_create_privilege_room()
  end
end
function CreateRoomSystem.ShowRoomOptionUI()
  local roomType, privilegeList = CreateRoomSystem.RefreshAdvanceParam()
  return UIManager.ShowUI(UIManager.UI_Config.room_option, roomType or 1, privilegeList or {})
end
function CreateRoomSystem.RefreshAdvanceParam()
  if not RoomSystem.HasRoomData() then
    return
  end
  local roomType = RoomSystem.CurrentRoomInfo.room_type
  local mapID = RoomSystem.CurrentRoomInfo.map_id
  local MapConfig = CDataTable.GetTableData("Map", mapID)
  if not MapConfig then
    return
  end
  local roomID = MapConfig.RoomModeId
  local privilegeList = {}
  if RoomSystem.CurrentRoomInfo.privileges and next(RoomSystem.CurrentRoomInfo.privileges) then
    for k, v in pairs(RoomSystem.CurrentRoomInfo.privileges) do
      table.insert(privilegeList, k)
    end
  end
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomConfig.InitParamList(roomType)
  CreateRoomSystem.advanceParamShowList = CreateRoomConfig.GetParamList(roomType, privilegeList, roomID)
  local showList = {}
  for i, v in ipairs(CreateRoomSystem.advanceParamShowList or {}) do
    if v[1] then
      if v[1].TagID then
        if v[1].TagID == 1 then
          table.insert(showList, v)
        end
      else
        local basicTagName = CDataTable.GetTableData("RoomParamTitleConfig", 1).TagName
        if v[1].ParamName and v[1].ParamName == basicTagName then
          table.insert(showList, v)
        end
      end
    end
  end
  CreateRoomSystem.advanceParamShowList = showList
  local TableUtil = require("common.table_util")
  CreateRoomSystem.advanceParam = TableUtil.CopyTable(RoomSystem.CurrentRoomInfo.battle_custom_cfg)
  if CreateRoomConfig.IsSignalMode(privilegeList) then
    CreateRoomSystem.advanceParam.SignalMod = true
  end
  return roomType, privilegeList
end
function CreateRoomSystem.IsOBOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_ANCHOR_OB) then
    return false
  end
  return GlobalData.IsJapanOrKorea()
end
function CreateRoomSystem.ResetBasicParam()
  CreateRoomSystem.thirdPartyInfo = {}
  if not next(CreateRoomSystem.basicParam) then
    local SuperData = require("common.super_data")
    local TableUtil = require("common.table_util")
    CreateRoomSystem.basicParam = SuperData.CreateSuperData(TableUtil.CopyTable(C_DefaultBasicParam))
    return
  end
  local TableUtil = require("common.table_util")
  for k, v in pairs(C_DefaultBasicParam) do
    if CreateRoomSystem.basicParam[k] ~= nil then
      if type(v) == "table" then
        CreateRoomSystem.basicParam[k] = TableUtil.CopyTable(v)
      else
        CreateRoomSystem.basicParam[k] = v
      end
    end
  end
end
function CreateRoomSystem.RefreshBasicParam()
  if not RoomSystem.HasRoomData() then
    return
  end
  if not next(CreateRoomSystem.basicParam) then
    local SuperData = require("common.super_data")
    local TableUtil = require("common.table_util")
    CreateRoomSystem.basicParam = SuperData.CreateSuperData(TableUtil.CopyTable(C_DefaultBasicParam))
    for k, v in pairs(C_DefaultBasicParam) do
      if CreateRoomSystem.basicParam[k] ~= nil then
        CreateRoomSystem.basicParam[k] = v
      end
    end
  end
  local CurrentRoomInfo = RoomSystem.CurrentRoomInfo
  local basicParam = CreateRoomSystem.basicParam
  local nMapID = CurrentRoomInfo.map_id or C_DefaultBasicParam.nMapID
  basicParam.  local bOB = CurrentRoomInfo.is_anchor_ob or C_DefaultBasicParam.bOB
  basicParam.  local use_pc_param = CurrentRoomInfo.use_pc_param or C_DefaultBasicParam.bPCParam
  basicParam.bPCParam = use_pc_param
  local sRoomName = CurrentRoomInfo.name or C_DefaultBasicParam.sRoomName
  basicParam.  local nPerspective = CurrentRoomInfo.is_fpp and ENUM_PerspectiveType.FPP or ENUM_PerspectiveType.TPP
  basicParam.  local nPlayerNum = CurrentRoomInfo.group_type or C_DefaultBasicParam.nPlayerNum
  basicParam.  local bNeedPsw = CurrentRoomInfo.password and CurrentRoomInfo.password ~= "" and true or false
  basicParam.  local sPassword = CurrentRoomInfo.password or C_DefaultBasicParam.sPassword
  basicParam.  local nMemMax = CurrentRoomInfo.member_number_max or CurrentRoomInfo.max_room_player or C_DefaultBasicParam.nMemMax
  basicParam.  CreateRoomSystem.SetBasicParamWeather(basicParam, CurrentRoomInfo.weather_client)
end
function CreateRoomSystem.SetBasicParamByDeepLink(paramList)
  local data = paramList or {}
  if data.mapName then
    CreateRoomSystem.basicParam.nMapID = tonumber(data.map_name)
  end
  if data.room_name then
    CreateRoomSystem.basicParam.sRoomName = tostring(data.room_name)
  end
  if data.is_fpp then
    CreateRoomSystem.basicParam.nPerspective = tonumber(data.is_fpp) == 1 and ENUM_PerspectiveType.FPP or ENUM_PerspectiveType.TPP
  end
  if data.group_type then
    CreateRoomSystem.basicParam.nPlayerNum = tonumber(data.group_type)
  end
  if data.password and data.password ~= "" then
    CreateRoomSystem.basicParam.bNeedPsw = true
    CreateRoomSystem.basicParam.sPassword = tostring(data.password)
  else
    CreateRoomSystem.basicParam.bNeedPsw = false
    CreateRoomSystem.basicParam.sPassword = ""
  end
  if data.platform_type then
    CreateRoomSystem.basicParam.platform_type = tonumber(data.platform_type)
  else
    CreateRoomSystem.basicParam.platform_type = nil
  end
  CreateRoomSystem.thirdPartyInfo = {
    action_id = data and data.action_id or "",
    platform_type = tonumber(data and data.platform_type or 1),
    password = tostring(data and data.password or ""),
    room_code = data and data.room_code or "",
    sign_time = tonumber(data and data.sign_time or 0),
    pubgm_uid = data and data.pubgm_uid or tonumber(DataMgr.roleData.uid),
    signature = data and data.signature or ""
  }
end
function CreateRoomSystem.SetAdvancedParamByDeepLink(battleCfg, paramList)
  if battleCfg.ShrinkSpeed and paramList.ShrinkSpeed then
    battleCfg.ShrinkSpeed = tonumber(paramList.ShrinkSpeed or 100)
  end
  if battleCfg.Firegun and paramList.Firegun then
    battleCfg.Firegun = paramList.Firegun ~= "false"
  end
  if battleCfg.BluecircleDamage and paramList.BluecircleDamage then
    battleCfg.BluecircleDamage = tonumber(paramList.BluecircleDamage or 100)
  end
  if battleCfg.WhitecircleStarttime and paramList.WhitecircleStarttime then
    battleCfg.WhitecircleStarttime = tonumber(paramList.WhitecircleStarttime or 300)
  end
  if battleCfg.WhitecircleDiameter and paramList.WhitecircleDiameter then
    battleCfg.WhitecircleDiameter = tonumber(paramList.WhitecircleDiameter or 100)
  end
  if battleCfg.WSniperRifles and paramList.WSniperRifles then
    battleCfg.WSniperRifles = tonumber(paramList.WSniperRifles or 100)
  end
  if battleCfg.WAssaultRifles and paramList.WAssaultRifles then
    battleCfg.WAssaultRifles = tonumber(paramList.WAssaultRifles or 100)
  end
  if battleCfg.Wshotguns and paramList.Wshotguns then
    battleCfg.Wshotguns = tonumber(paramList.Wshotguns or 100)
  end
  if battleCfg.WSMG and paramList.WSMG then
    battleCfg.WSMG = tonumber(paramList.WSMG or 100)
  end
  if battleCfg.Whandguns and paramList.Whandguns then
    battleCfg.Whandguns = tonumber(paramList.Whandguns or 100)
  end
  if battleCfg.Wmelee and paramList.Wmelee then
    battleCfg.Wmelee = tonumber(paramList.Wmelee or 100)
  end
  if battleCfg.Wbow and paramList.Wbow then
    battleCfg.Wbow = tonumber(paramList.Wbow or 100)
  end
  if battleCfg.Wthrowables and paramList.Wthrowables then
    battleCfg.Wthrowables = tonumber(paramList.Wthrowables or 100)
  end
  if battleCfg.WLMG and paramList.WLMG then
    battleCfg.WLMG = tonumber(paramList.WLMG or 100)
  end
  if battleCfg.Ascope and paramList.Ascope then
    battleCfg.Ascope = tonumber(paramList.Ascope or 100)
  end
  if battleCfg.Amagazine and paramList.Amagazine then
    battleCfg.Amagazine = tonumber(paramList.Amagazine or 100)
  end
  if battleCfg.Amuzzle and paramList.Amuzzle then
    battleCfg.Amuzzle = tonumber(paramList.Amuzzle or 100)
  end
  if battleCfg.Aforegrip and paramList.Aforegrip then
    battleCfg.Aforegrip = tonumber(paramList.Aforegrip or 100)
  end
  if battleCfg.Astock and paramList.Astock then
    battleCfg.Astock = tonumber(paramList.Astock or 100)
  end
  if battleCfg.Uheal and paramList.Uheal then
    battleCfg.Uheal = tonumber(paramList.Uheal or 100)
  end
  if battleCfg.Uboost and paramList.Uboost then
    battleCfg.Uboost = tonumber(paramList.Uboost or 100)
  end
  if battleCfg.Ujerrycan and paramList.Ujerrycan then
    battleCfg.Ujerrycan = tonumber(paramList.Ujerrycan or 100)
  end
  if battleCfg.Ebag and paramList.Ebag then
    battleCfg.Ebag = tonumber(paramList.Ebag or 100)
  end
  if battleCfg.Ehelmet and paramList.Ehelmet then
    battleCfg.Ehelmet = tonumber(paramList.Ehelmet or 100)
  end
  if battleCfg.Earmor and paramList.Earmor then
    battleCfg.Earmor = tonumber(paramList.Earmor or 100)
  end
  if battleCfg.Ammo and paramList.Ammo then
    battleCfg.Ammo = tonumber(paramList.Ammo or 100)
  end
  if battleCfg.Wflaregun and paramList.Wflaregun then
    battleCfg.Wflaregun = tonumber(paramList.Wflaregun or 100)
  end
end
local _ResetParamConfig = function(paramList)
  if not paramList or not next(paramList) then
    return
  end
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local cfg = {}
  for i, v in ipairs(paramList) do
    for ii, vv in ipairs(v) do
      if vv.ParamKey and vv.ParamKey ~= "" then
        if vv.ParamType == CreateRoomConfig.C_ParamWidgetType.Switch then
          cfg[vv.ParamKey] = vv.DefaultValue == "true"
        else
          cfg[vv.ParamKey] = tonumber(vv.DefaultValue)
        end
      end
    end
  end
  return cfg
end
function CreateRoomSystem.ResetAdvanceParam()
  if CreateRoomSystem.advanceParamShowList then
    CreateRoomSystem.advanceParam = _ResetParamConfig(CreateRoomSystem.advanceParamShowList)
  end
end
function CreateRoomSystem.InitAdvanceParam(roomType, privilegeList, roomID)
  local cfg
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomSystem.advanceParamShowList = CreateRoomConfig.GetParamList(roomType, privilegeList, roomID)
  if CreateRoomSystem.advanceParamShowList then
    cfg = _ResetParamConfig(CreateRoomSystem.advanceParamShowList)
  else
    cfg = CreateRoomSystem.GetOrdinaryBattleConfig()
  end
  CreateRoomSystem.advanceParam = cfg
end
function CreateRoomSystem.UpdateAdvanceParam(roomType, privilegeList, roomID)
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  CreateRoomSystem.advanceParamShowList = CreateRoomConfig.GetParamList(roomType, privilegeList, roomID)
  if CreateRoomSystem.advanceParamShowList then
    local cfg = {}
    for i, v in pairs(CreateRoomSystem.advanceParamShowList) do
      for ii, vv in ipairs(v) do
        if vv.ParamKey and vv.ParamKey ~= "" then
          if vv[vv.ParamKey] then
            cfg[vv.ParamKey] = vv[vv.ParamKey]
            if vv.ParamType == CreateRoomConfig.C_ParamWidgetType.Value then
              local valueList = load("return " .. vv.ValueListStr)()
              if cfg[vv.ParamKey] < tonumber(valueList[1]) or cfg[vv.ParamKey] > tonumber(valueList[#valueList]) then
                cfg[vv.ParamKey] = tonumber(vv.DefaultValue)
              end
            end
          elseif vv.ParamType == CreateRoomConfig.C_ParamWidgetType.Switch then
            cfg[vv.ParamKey] = vv.DefaultValue == "true"
          else
            cfg[vv.ParamKey] = tonumber(vv.DefaultValue)
          end
        end
      end
    end
    CreateRoomSystem.advanceParam = cfg
  end
end
function CreateRoomSystem.GetOrdinaryBattleConfig()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local cfg = _ResetParamConfig(CreateRoomConfig.GetBasicParamList())
  return cfg
end
function CreateRoomSystem.CheckRoomNameValid(name)
  if not name or name == "" then
    ShowNotice(111020)
    return false
  end
  local StringUtil = require("common.string_util")
  local _, unitLen = StringUtil.CheckName(name, true)
  if 40 < unitLen then
    ShowNotice(110089)
    return false
  end
  return true
end
function CreateRoomSystem.CheckPasswordValid(pwd)
  if not pwd or pwd == "" then
    ShowNotice(110080)
    return false
  end
  local pswLen = string.len(pwd)
  if 6 < pswLen then
    ShowNotice(110086)
    return false
  end
  for i = 1, pswLen do
    local curByte = string.byte(pwd, i)
    if curByte < 48 or 57 < curByte and curByte < 65 or 90 < curByte and curByte < 97 or 122 < curByte then
      ShowNotice(110086)
      return false
    end
  end
  return true
end
function CreateRoomSystem.CheckAdvanceParamIsDefault()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local advanceParam = CreateRoomSystem.advanceParam
  if CreateRoomSystem.advanceParamShowList then
    for i, v in pairs(CreateRoomSystem.advanceParamShowList) do
      for ii, vv in ipairs(v) do
        if vv.ParamKey and vv.ParamKey ~= "" then
          if vv.ParamType == CreateRoomConfig.C_ParamWidgetType.Switch then
            if advanceParam[vv.ParamKey] and advanceParam[vv.ParamKey] ~= (vv.DefaultValue == "true") then
              return false
            end
          elseif advanceParam[vv.ParamKey] and advanceParam[vv.ParamKey] ~= tonumber(vv.DefaultValue) then
            return false
          end
        end
      end
    end
  end
  return true
end
function CreateRoomSystem.CreateRoom(type, itemID, thirdPartyInfo)
  local battleCfg = {}
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  if type == CreateRoomConfig.C_RoomTypeMap.Advance or type == CreateRoomConfig.C_RoomTypeMap.Match then
    battleCfg = CreateRoomSystem.advanceParam
  else
    battleCfg = CreateRoomSystem.advanceParam or CreateRoomSystem.GetOrdinaryBattleConfig()
  end
  if thirdPartyInfo then
    CreateRoomSystem.SetAdvancedParamByDeepLink(battleCfg, thirdPartyInfo)
  end
  local basicParam = CreateRoomSystem.basicParam
  local selectMapList = {}
  if CreateRoomSystem.limitMaps and next(CreateRoomSystem.limitMaps) then
    log(bWriteLog and "CreateRoomSystem.CreateRoom: Using limitMaps restriction with count:" .. #CreateRoomSystem.limitMaps)
    selectMapList = CreateRoomConfig.GetMapListByIdList(CreateRoomSystem.limitMaps)
  else
    local TableUtil = require("common.table_util")
    selectMapList = CreateRoomConfig.GetValidMapList(TableUtil.CopyTable(CreateRoomConfig.GetMapList(basicParam.nPerspective)), type)
    if CreateRoomSystem.IsESportMatchRoomCard(itemID) then
      selectMapList = CreateRoomConfig.GetESportCardMapList(itemID, basicParam.nPerspective)
    end
    if type == CreateRoomConfig.C_RoomTypeMap.TMode or type == CreateRoomConfig.C_RoomTypeMap.TMatch then
      selectMapList = CreateRoomConfig.GetTmodeMapList()
    end
  end
  local bSelect = false
  if #selectMapList == 0 then
    ShowNotice(4723)
    return
  end
  for _, v in ipairs(selectMapList) do
    if v.ResId == basicParam.nMapID then
      bSelect = true
      break
    end
  end
  if not bSelect then
    ShowNotice(4723)
    return
  end
  if itemID and 0 < itemID then
    log(bWriteLog and "CreateRoomSystem.create_room PR" .. basicParam.nPlayerNum)
    local logic_room_circle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_circle)
    local cirParams = logic_room_circle:GetTempParamValueList(basicParam.nMapID)
    if cirParams then
      battleCfg.custom_params_circle = cirParams
    end
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      basicParam.bPCParam = false
    end
    local CreateRoomHandler = require("client.network.Protocol.TournamentHandler")
    CreateRoomHandler.send_create_privilege_room_req(basicParam.sRoomName, basicParam.nMapID, basicParam.bNeedPsw and basicParam.sPassword or nil, basicParam.nPlayerNum, true, battleCfg, basicParam.bPCParam, itemID, {
      bring_team_in = basicParam.quick_create_room_params.bring_team_in
    }, {
      [basicParam.weather.id] = basicParam.weather.level
    })
  else
    log(bWriteLog and "CreateRoomSystem.create_room PT" .. basicParam.nPlayerNum)
    local MapConfig = CDataTable.GetTableData("Map", basicParam.nMapID)
    local CreateRoomHandler = require("client.network.Protocol.CreateRoomHandler")
    CreateRoomHandler.send_create_room_request(basicParam.sRoomName, basicParam.nMapID, basicParam.bNeedPsw and basicParam.sPassword or nil, basicParam.nPlayerNum, basicParam.bOB, true, type, battleCfg, MapConfig.IsFpp == 1, basicParam.bPCParam, CreateRoomSystem.thirdPartyInfo, nil, basicParam.nMemMax, {
      bring_team_in = basicParam.quick_create_room_params.bring_team_in
    }, {
      [basicParam.weather.id] = basicParam.weather.level
    })
  end
  log_tree("\233\171\152\231\186\167\229\143\130\230\149\176====battleCfg====", battleCfg)
end
function CreateRoomSystem.SaveParam()
  if RoomSystem.IsShowWaiting() then
    local RoomHandler = require("client.network.Protocol.RoomHandler")
    RoomHandler.send_change_room_adv_param_req(CreateRoomSystem.advanceParam)
  end
end
function CreateRoomSystem.GetTeamModeMaxPlayerNum(map_id)
  local map_info = CDataTable.GetTableData("Map", map_id)
  if map_info and map_info.IsTeamValid > 0 then
    local bt_mode = CDataTable.GetTableData("MatchModeTable", map_info.IsTeamValid)
    if bt_mode then
      return bt_mode.MaxTeamPlayerNum
    end
  end
  return 0
end
function CreateRoomSystem.InitCircleParam(privilegeList)
  local logic_room_circle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_circle)
  if not logic_room_circle:isHaveCirclePrivilge(privilegeList) then
    return
  end
  logic_room_circle:GetCircleParamList()
end
function CreateRoomSystem.GetQuickCreateRoomParam(key)
  if not CreateRoomSystem.basicParam.quick_create_room_params then
    return nil
  end
  return CreateRoomSystem.basicParam.quick_create_room_params[key]
end
function CreateRoomSystem.ResetRoomWeather()
  if CreateRoomSystem.basicParam then
    CreateRoomSystem.basicParam.weather.id = C_DefaultBasicParam.weather.id
    CreateRoomSystem.basicParam.weather.level = C_DefaultBasicParam.weather.level
  end
end
function CreateRoomSystem.UpdateRoomWeather(id, level)
  if CreateRoomSystem.basicParam and CreateRoomSystem.basicParam.weather then
    CreateRoomSystem.basicParam.weather.    CreateRoomSystem.basicParam.weather.    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_UPDATE_WEATHER)
  end
end
function CreateRoomSystem.SetBasicParamWeather(basicParam, weather_client)
  basicParam = basicParam or CreateRoomSystem.basicParam
  if basicParam then
    local id, level
    if weather_client then
      for k, v in pairs(weather_client) do
        id = k
        level = v
        break
      end
    else
      local roomWeather = RoomSystem.GetRoomWeather()
      id = roomWeather.id
      level = roomWeather.level
    end
    basicParam.weather.    basicParam.weather.  end
end
function CreateRoomSystem.SetLimitMaps(limitMaps)
  log_format("CreateRoomSystem:SetLimitMaps. limitMaps count:%s", limitMaps and #limitMaps or 0)
  CreateRoomSystem.  log(bWriteLog and "CreateRoomSystem:SetLimitMaps. Limit maps updated")
end
function CreateRoomSystem.GetDefaultWeather()
  return C_DefaultBasicParam.weather
end
function CreateRoomSystem.GetTestGameTVParam()
  return {
    map_name = 1,
    room_name = "Tourney",
    Is_fpp = 0,
    platform_type = 2,
    group_type = 4,
    password = "123456",
    room_type = "advanced",
    room_code = "61752ef863b846c5b680ef764a9efe5a$$tier1$$match1",
    sign_time = 1629102163,
    signature = "0b603bf5512cbb7153f1d86b245ab6922fdb2255"
  }
end
return CreateRoomSystem