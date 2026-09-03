local CreateRoleSystem = {
  NCreateRoleMode = 1,
  SCreateRoleName = "",
  NCreateRoleSex = 2,
  NCreateRoleFace = 10007,
  NCreateRoleHeadId = 0,
  NCreateRoleHairType = 1,
  NCreateRoleHairColor = 1,
  NCreateRoleBeardType = 0,
  NCreateRoleBeardID = 0,
  NCreateRoleBeardColor = 0,
  NCreateRoleBeardColorID = 0,
  NCreateRoleHairID = 0,
  SCreateRoleNation = "",
  NCreateRoleLobbyToAvatar = 0,
  NCreateRoleCardCount = 0,
  NCreateRoleBuyMode = 1,
  TCreateRoleSelectTip = {
    avatar_id = 0,
    avatar_name = "",
    remain_time_str = "",
    avatar_price = 0,
    show_price = true,
    has_item = false,
    is_ticket = false,
    pass_season = 0
  },
  NDefaultHat = 0,
  NDefaultFace = 0,
  NDefaultClothes = 0,
  NDefaultPants = 0,
  NDefaultShoes = 0,
  BUseSocialAvatar = true,
  NTempSex = 0,
  NTempFace = 0,
  NTempHairType = 0,
  NTempHairColor = 0,
  NCardID = 1601001,
  BCreateRoleNameInit = false,
  CloseCallBack = nil,
  CloseCllBackPara = nil,
  BIsPlayVideoBeforeShow = false,
  CreateRoleBuyAvatars = {},
  CreateRoleUCBuyAvatars = {},
  newAvatarMap = {},
  nameValidMap = {},
  weakCameraCache = {}
}
local EAvatarType = {
  Race = 1,
  Hair = 2,
  Beard = 5,
  BeardColor = 6
}
local DEFAULT_BEARD_TYPE = 50001
local NEWGUIDE_MATCH_TIMEOUT = false
local arrayAvatarInitTable = {}
local activate_avatar_list = {}
local cameraName = {
  FarCameraName = "close_up_all",
  NearCameraName = "close_up"
}
function CreateRoleSystem.OnModePreSwitch(_, _, gamestatus)
  log(bWriteLog and "CreateRoleSystem.OnModePreSwitch")
  CreateRoleSystem.CloseCllBackPara = nil
  CreateRoleSystem.CloseCallBack = nil
  CreateRoleSystem.weakCameraCache = {}
end
function CreateRoleSystem.OnModePostSwitch(_, _, gamestatus)
  log(bWriteLog and "  :CreateRoleSystem.OnModePostSwitch gamestatus" .. tostring(gamestatus.current))
  local status = gamestatus.current
  if status == GameStatus.Createrole then
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    CreateRoleSystem.Init()
    LoadingSystem.RefreshLoadPercent(1)
    log(bWriteLog and "  :CreateRoleSystem   Createrole")
    log(bWriteLog and "  :CreateRoleSystem  Init Createrole")
  else
    CreateRoleSystem.ClosePanel()
    CreateRoleSystem.NCreateRoleLobbyToAvatar = 0
    if CreateRoleSystem.IsShowing() then
      log(bWriteLog and "close createroleui")
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, SceneType.AvatarReset)
      if UIManager.IsUIShow(UIManager.UI_Config.wardrobe) then
        UIManager.CloseUI(UIManager.UI_Config.wardrobe)
      end
    end
    CreateRoleSystem.BCreateRoleNameInit = false
  end
end
function CreateRoleSystem.Init()
  log(bWriteLog and "  : CreateRoleSystem.Init")
  CreateRoleSystem.NCreateRoleSex = 2
  CreateRoleSystem.NCreateRoleFace = CreateRoleSystem.GetDefaultFace()
  CreateRoleSystem.NCreateRoleHeadId = 0
  CreateRoleSystem.NCreateRoleHairType = 20001
  CreateRoleSystem.NCreateRoleHairColor = 1
  CreateRoleSystem.NCreateRoleHairID = 0
  CreateRoleSystem.NCreateRoleBeardType = DEFAULT_BEARD_TYPE
  CreateRoleSystem.NCreateRoleBeardID = 0
  CreateRoleSystem.NCreateRoleBeardColor = 60001
  CreateRoleSystem.NCreateRoleBeardColorID = 1
  CreateRoleSystem.NCreateRoleCardCount = 0
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if IsBLUEHOLE then
    log(bWriteLog and "CreateRoleSystem.Init IsBLUEHOLE")
    CreateRoleSystem.NCreateRoleSex = 1
    CreateRoleSystem.NCreateRoleHairType = 20002
  end
  CreateRoleSystem.InitDefaultWearInfo()
  CreateRoleSystem.InitFaces()
  CreateRoleSystem.InitHairs()
  CreateRoleSystem.InitBeards()
  CreateRoleSystem.InitNewAvatarList()
  if CreateRoleSystem.NCreateRoleMode == 1 and BP_Platform == BP_ENUM_PLAYFORM_TOURIST then
    CreateRoleSystem.SCreateRoleName = ""
  end
  EventSystem:registEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, CreateRoleSystem.OnVideoEnd)
  local StatManager = import("StatManager")
  log(bWriteLog and "[stat] report event 27")
  StatManager.GetInstance():ReportEventWithNoParam(27, true)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_CreatRole)
  GlobalData.StopLobbyBGM()
end
function CreateRoleSystem.IsShowing()
  return UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole)
end
function CreateRoleSystem.IsInCreateRolePhase()
  return CreateRoleSystem.NCreateRoleMode == 1 and CreateRoleSystem.IsShowing()
end
function CreateRoleSystem.SetNickName(platform, notReq)
  log_format("CreateRoleSystem.SetNickName. platform = [%s], notReq = [%s]", platform, notReq)
  if CreateRoleSystem.BCreateRoleNameInit then
    log_warning(bWriteLog and "CreateRoleSystem.SetNickName: BCreateRoleNameInit")
    return
  end
  CreateRoleSystem.BCreateRoleNameInit = true
  CreateRoleSystem.SCreateRoleName = platform
  if not platform or platform == "" then
    log_warning(bWriteLog and "CreateRoleSystem.SetNickName: platform is nil")
    return
  end
  if notReq then
    log(bWriteLog and "CreateRoleSystem.SetNickName: notReq")
    return
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_validate_nickname_req(platform)
  CreateRoleSystem.nameValidMap = {}
end
function CreateRoleSystem.OnVideoEnd()
  if CreateRoleSystem.BIsPlayVideoBeforeShow then
    log(bWriteLog and "[DeanJYT] CreateRoleUI.OnVideoEnd bIsPlayVideoBeforeShow")
    CreateRoleSystem.BIsPlayVideoBeforeShow = false
    return
  end
  if GameStatus.GetGameStatus() == GameStatus.Createrole then
    EventSystem:unregistEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, CreateRoleSystem.OnVideoEnd)
    CreateRoleSystem.RealEnterLobby()
  end
end
function CreateRoleSystem.InitDefaultWearInfo()
  log_tree("  : LobbySystem.PlayerDefaultWearInfo", LobbySystem.PlayerDefaultWearInfo)
  if LobbySystem.PlayerDefaultWearInfo == nil then
    log(bWriteLog and "Defalut WearInfo is nil")
    return
  end
  local sex = CreateRoleSystem.NCreateRoleSex
  CreateRoleSystem.NDefaultHat = LobbySystem.PlayerDefaultWearInfo[sex][1] or 0
  CreateRoleSystem.NDefaultFace = LobbySystem.PlayerDefaultWearInfo[sex][2] or 0
  CreateRoleSystem.NDefaultClothes = LobbySystem.PlayerDefaultWearInfo[sex][3] or 0
  CreateRoleSystem.NDefaultPants = LobbySystem.PlayerDefaultWearInfo[sex][4] or 0
  CreateRoleSystem.NDefaultShoes = LobbySystem.PlayerDefaultWearInfo[sex][5] or 0
end
function CreateRoleSystem.TryToShowEUGDPRInCreateRole()
  log(bWriteLog and "  :CreateRoleSystem TryToShowEUGDPRInCreateRole")
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.SetEugdprNewUser(true)
  GdprSystem.TryToShowEuGdpr()
end
function CreateRoleSystem.TryCtrAvatarData()
  if not next(arrayAvatarInitTable) then
    for k, v in pairs(CDataTable.GetTable("AvatarInit")) do
      arrayAvatarInitTable[tonumber(k)] = v
    end
  end
end
function CreateRoleSystem.EventGetCreateRoleSex()
  CreateRoleSystem.TryCtrAvatarData()
  local avatar_id = 0
  for k, v in pairs(arrayAvatarInitTable) do
    if v.AvatarType == 4 and CreateRoleSystem.NCreateRoleSex == v.Sex then
      avatar_id = k
      break
    end
  end
  return avatar_id
end
function CreateRoleSystem.SetCreateRoleHairID()
  CreateRoleSystem.TryCtrAvatarData()
  local avatar = arrayAvatarInitTable[tonumber(CreateRoleSystem.NCreateRoleHairType)]
  local hairType = 1
  if avatar ~= nil then
    hairType = tonumber(avatar.Hair)
  end
  local hairIdStr = string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, CreateRoleSystem.NCreateRoleHairColor, hairType)
  CreateRoleSystem.NCreateRoleHairID = tonumber(hairIdStr, 10)
  log(bWriteLog and "  :hairIdStr CreateRoleSystem.BP_CreateRole_HairID" .. tostring(CreateRoleSystem.NCreateRoleHairID))
end
function CreateRoleSystem.DataMgrToAvatarData()
  CreateRoleSystem.TryCtrAvatarData()
  if AvatarData.GetHairID() < 500000 then
    log(bWriteLog and "log old style hairid = " .. AvatarData.GetHairID())
    AvatarData.SetHairID(CreateRoleSystem:GetDefaultHairID())
  end
  LobbySystem.check_avatar_time()
  local data = AvatarData.GetHairID() % (BP_ENUM_AVATAR_HAIR * 100000)
  local hairColor = math.floor(data / 1000)
  local hairtype = data % 1000
  CreateRoleSystem.NCreateRoleSex = AvatarData.GetGameGender()
  CreateRoleSystem.NCreateRoleHeadId = AvatarData.GetHeadID()
  log(bWriteLog and "  : CreateRoleSystem.NCreateRoleHeadIdd CreateRoleSystem.BP_CreateRole_HeadId" .. tostring(CreateRoleSystem.NCreateRoleHeadId))
  activate_avatar_list = {}
  for k, v in pairs(DataMgr.avatarData.activate_avatar_list) do
    activate_avatar_list[k] = v
  end
  CreateRoleSystem.InitFaces()
  CreateRoleSystem.InitHairs()
  CreateRoleSystem.InitBeards()
  CreateRoleSystem.InitNewAvatarList()
  CreateRoleSystem.GetCreateRoleHeadOrRace(false)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  wardrobe_red_point:OnAvatarPanelOpen()
  for k, v in pairs(arrayAvatarInitTable) do
    if v.AvatarType == 2 and hairtype == tonumber(v.Hair) then
      CreateRoleSystem.NCreateRoleHairType = k
      break
    end
  end
  CreateRoleSystem.NCreateRoleHairColor = hairColor
  CreateRoleSystem.NCreateRoleHairID = AvatarData.GetHairID()
  log(bWriteLog and "  :CreateRoleSystem.NCreateRoleHairID CreateRoleSystem.BP_CreateRole_HairID" .. tostring(CreateRoleSystem.NCreateRoleHairID))
  CreateRoleSystem.NCreateRoleBeardID = AvatarData.GetBeardID() or 0
  CreateRoleSystem.NCreateRoleBeardType = DEFAULT_BEARD_TYPE
  for k, v in pairs(arrayAvatarInitTable) do
    if v.AvatarType == 5 and v.BodyID == CreateRoleSystem.NCreateRoleBeardID then
      CreateRoleSystem.NCreateRoleBeardType = k
      break
    end
  end
  CreateRoleSystem.NCreateRoleBeardColorID = AvatarData.GetBeardColorID() or 0
  CreateRoleSystem.NCreateRoleBeardColor = 60001
  if CreateRoleSystem.NCreateRoleBeardColorID ~= 0 then
    for k, v in pairs(arrayAvatarInitTable) do
      if v.AvatarType == 6 and v.BeardColor == CreateRoleSystem.NCreateRoleBeardColorID then
        CreateRoleSystem.NCreateRoleBeardColor = k
        break
      end
    end
  end
  CreateRoleSystem.NTempSex = AvatarData.GetGameGender()
  CreateRoleSystem.NTempFace = CreateRoleSystem.NCreateRoleFace
  CreateRoleSystem.NTempHairType = CreateRoleSystem.NCreateRoleHairType
  CreateRoleSystem.NTempHairColor = CreateRoleSystem.NCreateRoleHairColor
  CreateRoleSystem.beardType = CreateRoleSystem.NCreateRoleBeardType
  CreateRoleSystem.beardColor = CreateRoleSystem.NCreateRoleBeardColor
  CreateRoleSystem.UpdateSelectTip(CreateRoleSystem.NCreateRoleFace)
end
function CreateRoleSystem.UpdateSelectTip(avatar_id)
  local TimeUtil = require("client.common.time_util")
  CreateRoleSystem.TCreateRoleSelectTip.  CreateRoleSystem.TCreateRoleSelectTip.is_ticket = false
  local activate_avatars = DataMgr.avatarData.activate_avatar_list
  activate_avatars[avatar_id] = nil
  DataMgr.avatarData.activate_avatar_list = activate_avatars
  CreateRoleSystem.SelectNewAvatarList(avatar_id)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_AVATAR_ACTIVATE)
  local avatar = arrayAvatarInitTable[avatar_id]
  if avatar == nil then
    CreateRoleSystem.TCreateRoleSelectTip.avatar_name = ""
    CreateRoleSystem.TCreateRoleSelectTip.remain_time_str = ""
    CreateRoleSystem.TCreateRoleSelectTip.avatar_price = 0
    CreateRoleSystem.TCreateRoleSelectTip.show_price = false
    CreateRoleSystem.TCreateRoleSelectTip.has_item = false
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local headDepotItem = wardrobe_data:GetHallDepotItemDataByResID(avatar_id)
  CreateRoleSystem.TCreateRoleSelectTip.avatar_name = avatar.AvatarName
  local remainTime = DataMgr.GetAvatarRemainTime(avatar_id)
  if 0 < remainTime then
    CreateRoleSystem.TCreateRoleSelectTip.avatar_name = LocUtil.GetLocalizeResStr("990010")
    CreateRoleSystem.TCreateRoleSelectTip.remain_time_str = TimeUtil.FormatCountDownTime_DH_or_HM(remainTime) .. LocUtil.GetLocalizeResStr("990011")
    CreateRoleSystem.TCreateRoleSelectTip.avatar_price = 0
    CreateRoleSystem.TCreateRoleSelectTip.show_price = false
    CreateRoleSystem.TCreateRoleSelectTip.has_item = false
  else
    CreateRoleSystem.TCreateRoleSelectTip.remain_time_str = ""
    if avatar_id == CreateRoleSystem.NTempFace or avatar_id == CreateRoleSystem.NTempHairType or avatar.AvatarType == 3 and avatar.HairColor == CreateRoleSystem.NTempHairColor or avatar.AvatarType == 4 and avatar.Sex == CreateRoleSystem.NTempSex then
      CreateRoleSystem.TCreateRoleSelectTip.avatar_name = ""
      CreateRoleSystem.TCreateRoleSelectTip.avatar_price = 0
      CreateRoleSystem.TCreateRoleSelectTip.show_price = false
      CreateRoleSystem.TCreateRoleSelectTip.has_item = false
    elseif avatar.AcquireMode == 1 then
      CreateRoleSystem.TCreateRoleSelectTip.avatar_name = LocUtil.GetLocalizeResStr("990010")
      CreateRoleSystem.TCreateRoleSelectTip.avatar_price = avatar.ResetCost
      CreateRoleSystem.TCreateRoleSelectTip.show_price = true
      CreateRoleSystem.TCreateRoleSelectTip.has_item = headDepotItem ~= nil
    else
      local beOwner = 0 <= DataMgr.GetAvatarRemainTime(avatar_id)
      if 0 < avatar.ForeverCost then
        CreateRoleSystem.TCreateRoleSelectTip.avatar_name = LocUtil.GetLocalizeResStr("990010")
        CreateRoleSystem.TCreateRoleSelectTip.avatar_price = beOwner and 0 or avatar.ForeverCost
        CreateRoleSystem.TCreateRoleSelectTip.is_ticket = not beOwner
      end
      CreateRoleSystem.TCreateRoleSelectTip.show_price = true
      CreateRoleSystem.TCreateRoleSelectTip.has_item = headDepotItem ~= nil
    end
  end
  CreateRoleSystem.TCreateRoleSelectTip.pass_season = CDataTable.GetTableData("AvatarInit", avatar_id).RoyalePassSeason
  if 0 < CreateRoleSystem.TCreateRoleSelectTip.pass_season then
    CreateRoleSystem.TCreateRoleSelectTip.show_price = false
  end
end
function CreateRoleSystem.CtrAvatarListByType(avatarList, avatarType)
  CreateRoleSystem.TryCtrAvatarData()
  local avatars = arrayAvatarInitTable
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for k, v in pairs(avatars) do
    if v.AvatarType == avatarType then
      local show = true
      local remain_time = DataMgr.GetAvatarRemainTime(k)
      local pass_season = v.RoyalePassSeason
      if CreateRoleSystem.NCreateRoleMode == 1 and (v.ForeverCost > 0 or 0 < pass_season) then
        show = false
      end
      if show then
        local avatar = {}
        avatar.avatar_id = k
        if 0 <= remain_time then
          avatar.        elseif v.ForeverCost > 0 or v.RoyalePassSeason > 0 then
          avatar.        else
          avatar.remain_time = 0
        end
        avatar.has_item = wardrobe_data:GetHallDepotItemDataByResID(avatar.avatar_id) ~= nil
        avatar.is_new = activate_avatar_list[avatar.avatar_id] == 1 and avatar.has_item
        avatar.        table.insert(avatarList, avatar)
      end
    end
  end
  table.sort(avatarList, function(a, b)
    return avatars[a.avatar_id].Sort < avatars[b.avatar_id].Sort
  end)
end
function CreateRoleSystem.InitFaces()
  CreateRoleSystem.BP_ARRAY_CreateRole_Races = {}
  CreateRoleSystem.CtrAvatarListByType(CreateRoleSystem.BP_ARRAY_CreateRole_Races, EAvatarType.Race)
end
function CreateRoleSystem.InitHairs()
  CreateRoleSystem.BP_ARRAY_CreateRole_Hairs = {}
  CreateRoleSystem.CtrAvatarListByType(CreateRoleSystem.BP_ARRAY_CreateRole_Hairs, EAvatarType.Hair)
end
function CreateRoleSystem.InitBeards()
  CreateRoleSystem.BP_ARRAY_CreateRole_Beards = {}
  CreateRoleSystem.CtrAvatarListByType(CreateRoleSystem.BP_ARRAY_CreateRole_Beards, EAvatarType.Beard)
  CreateRoleSystem.BP_ARRAY_CreateRole_BeardColors = {}
end
function CreateRoleSystem.InitNewAvatarList()
  CreateRoleSystem.BP_ARRAY_CreateRole_NewAvatarList = {}
  CreateRoleSystem.newAvatarMap = {}
  for k, v in pairs(activate_avatar_list) do
    if v == 1 then
      table.insert(CreateRoleSystem.BP_ARRAY_CreateRole_NewAvatarList, k)
      CreateRoleSystem.newAvatarMap[k] = true
    end
  end
  log_tree("  CreateRoleSystem:InitNewAvatarList:", CreateRoleSystem.BP_ARRAY_CreateRole_NewAvatarList)
end
function CreateRoleSystem.SelectNewAvatarList(avatar_id)
  for k, v in pairs(CreateRoleSystem.BP_ARRAY_CreateRole_NewAvatarList) do
    if v == avatar_id then
      local RedpointHandler = require("client.network.Protocol.RedpointHandler")
      RedpointHandler.send_select_avatar(avatar_id)
      CreateRoleSystem.BP_ARRAY_CreateRole_NewAvatarList[k] = nil
      CreateRoleSystem.newAvatarMap[avatar_id] = nil
    end
  end
end
function CreateRoleSystem.GetCreateRoleHairColor()
  local avatar_id = 0
  for k, v in pairs(arrayAvatarInitTable) do
    if v.AvatarType == 3 and CreateRoleSystem.NCreateRoleHairColor == v.HairColor then
      avatar_id = k
      break
    end
  end
  return avatar_id
end
function CreateRoleSystem.ClosePanel()
  log(bWriteLog and "  :CreateRoleSystem.NCreateRoleMode" .. tostring(CreateRoleSystem.NCreateRoleMode))
  if CreateRoleSystem.NCreateRoleMode == 2 then
    CreateRoleSystem.OnCloseAvatarResetPanel(true)
  end
  UIManager.CloseUI(UIManager.UI_Config.Lobby_CreatRole)
  if CreateRoleSystem.IsShowing() and GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "  : CreateRoleSystem.ClosePanel")
    LobbySceneManager.LoadStreamLevel(false, LobbySceneManager.LEVEL_NAME.CHANGE_BODY)
  end
end
function CreateRoleSystem.CheckCanClosePanel()
  local isShow = UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole)
  log_format(bWriteLog and "CreateRoleSystem.CheckCanClosePanel isShow:%s NEWGUIDE_MATCH_TIMEOUT:%s", tostring(isShow), tostring(NEWGUIDE_MATCH_TIMEOUT))
  if isShow and NEWGUIDE_MATCH_TIMEOUT then
    return false
  end
  return true
end
function CreateRoleSystem.SetNewGuideMatchTimeOut(isTimeOut)
  log(bWriteLog and "CreateRoleSystem.SetNewGuideMatchTimeOut: " .. tostring(isTimeOut))
  NEWGUIDE_MATCH_TIMEOUT = isTimeOut
end
local errorTable = {
  ["name-too-long"] = 990002,
  ["name-too-short"] = 990003,
  ["have-dirty-in-name"] = 990004,
  ["name-exist"] = 990005,
  ["bad-request"] = 990006,
  ip_limit_gu_account = 7565,
  ip_limit_socail_account = 22001,
  ip_limit_1 = 101101,
  ip_limit_2 = 101103,
  ip_limit_3 = 101104,
  ip_limit_4 = 101106,
  ip_limit_5 = 101110,
  device_limit_1 = 101112,
  device_limit_2 = 101113,
  device_limit_3 = 101301,
  device_limit_4 = 101302,
  device_limit_5 = 101307,
  nonage_limit_1 = 101115,
  nonage_limit_2 = 101116,
  nonage_limit_3 = 101117,
  nonage_limit_4 = 101118,
  aq_ban = 29089,
  ["name-in-invalid-range"] = 29920
}
function CreateRoleSystem.ShowError(info)
  local word = errorTable[info] or info
  local tipContent2 = LocUtil.GetLocalizeResStr(word) or word
  if tipContent2 ~= word then
    tipContent2 = tipContent2 .. string.format(" (%d)", word)
  end
  ShowNotice(tipContent2)
end
function CreateRoleSystem.EventRandomName()
  local name = ""
  local nameTable = CDataTable.GetTable("NameTable")
  if not nameTable then
    return name
  end
  local n = #nameTable
  local n0 = math.random(n)
  local n1 = math.random(n)
  if CreateRoleSystem.NCreateRoleSex == 1 then
    name = nameTable[n0].b
  else
    name = nameTable[n0].c
  end
  name = nameTable[n1].a .. name
  CreateRoleSystem.SCreateRoleName = name
end
function CreateRoleSystem.GetCreateRoleHeadOrRace(race2head)
  CreateRoleSystem.TryCtrAvatarData()
  local avatars = arrayAvatarInitTable
  log(bWriteLog and "  : CreateRoleSystem.BP_CreateRole_Race" .. tostring(CreateRoleSystem.NCreateRoleFace))
  if race2head then
    CreateRoleSystem.NCreateRoleHeadId = avatars[CreateRoleSystem.NCreateRoleFace].BodyID
  else
    CreateRoleSystem.NCreateRoleFace = CreateRoleSystem.GetDefaultFace()
    for _, v in ipairs(CreateRoleSystem.BP_ARRAY_CreateRole_Races) do
      if avatars[v.avatar_id].BodyID == CreateRoleSystem.NCreateRoleHeadId then
        CreateRoleSystem.NCreateRoleFace = v.avatar_id or CreateRoleSystem.GetDefaultFace()
        log(bWriteLog and "  : CreateRoleSystem.BP_CreateRole_Race  v.avatar_id" .. tostring(CreateRoleSystem.NCreateRoleFace))
        break
      end
    end
  end
end
function CreateRoleSystem.OpenAvatarResetPanel()
  log(bWriteLog and "  : EventOpenAvatarResetPanelInter")
  CreateRoleSystem.NCreateRoleMode = 2
  CreateRoleSystem.UpdateCardCount()
  CreateRoleSystem.DataMgrToAvatarData()
  local ui = UIManager.ShowUI(UIManager.UI_Config.Lobby_CreatRole)
  ui:HideResetButton()
  UIManager.ShowUI(UIManager.UI_Config.FADE_UIBP)
end
function CreateRoleSystem.CloseAvatarResetPanel(clicked)
  log(bWriteLog and "CloseAvatarResetPanel" .. tostring(clicked))
  if CreateRoleSystem.CloseCllBackPara and CreateRoleSystem.CloseCllBackPara.noReset then
  else
    local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
    newbie_guide_util.EnterSceneByABTestGroup()
  end
  if clicked and CreateRoleSystem.CloseCallBack ~= nil then
    CreateRoleSystem.CloseCallBack()
  end
  CreateRoleSystem.CloseCllBackPara = nil
  CreateRoleSystem.CloseCallBack = nil
end
function CreateRoleSystem.OpenAvatarResetPanelWithAnim()
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  CreateRoleSystem.NCreateRoleLobbyToAvatar = 1
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  local TimeTicker = require("common.time_ticker")
  TimeTicker.AddTimerOnce(0.3, function()
    CreateRoleSystem.DataMgrToAvatarData()
  end)
  CreateRoleSystem.UIShowAvatarAni()
  CreateRoleSystem.SwitchCameraFarImmediate()
  if GameStatus.IsInLobbyOrMainCity() then
    LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.CHANGE_BODY)
  end
  logic_achievement_float_tip.CloseAchievementTip()
end
function CreateRoleSystem.UpdateCardCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(CreateRoleSystem.NCardID)
  if itemData ~= nil then
    CreateRoleSystem.NCreateRoleCardCount = itemData.count
  else
    CreateRoleSystem.NCreateRoleCardCount = 0
  end
end
function CreateRoleSystem.SwitchCameraFarImmediate()
  log(bWriteLog and "CreateRoleSystem.SwitchCameraFarImmediate")
  CreateRoleSystem.SwitchCameraFar(0)
end
function CreateRoleSystem.SwitchCameraFar(nBlendTime)
  log(bWriteLog and "CreateRoleSystem.SwitchCameraFar nBlendTime:" .. tostring(nBlendTime))
  nBlendTime = tonumber(nBlendTime) or 0
  if GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "CreateRoleSystem.SwitchCameraFar IsInLobbyOrMainCity")
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(10103, nBlendTime)
  else
    log(bWriteLog and "CreateRoleSystem.SwitchCameraFar Not in LobbyOrMainCity")
    CreateRoleSystem.SwitchCameraByName(cameraName.FarCameraName, nBlendTime)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SWITCH_CAMERA, cameraName.FarCameraName)
  end
end
function CreateRoleSystem.SwitchCameraNear(nBlendTime)
  log(bWriteLog and "CreateRoleSystem.SwitchCameraNear nBlendTime:" .. tostring(nBlendTime))
  nBlendTime = tonumber(nBlendTime) or 0
  if GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "CreateRoleSystem.SwitchCameraNear IsInLobbyOrMainCity")
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(10102, nBlendTime)
  else
    log(bWriteLog and "CreateRoleSystem.SwitchCameraNear Not in LobbyOrMainCity")
    CreateRoleSystem.SwitchCameraByName(cameraName.NearCameraName, nBlendTime)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SWITCH_CAMERA, cameraName.NearCameraName)
  end
end
function CreateRoleSystem.NewbieUpdateAvatar(wear)
  CreateRoleSystem.Init()
  CreateRoleSystem.NCreateRoleMode = 1
  log_tree("  :NewbieUpdateAvatar wear", wear)
  if wear then
    for i = 1, #wear do
      CreateRoleSystem.NDefaultClothes = wear[i].ItemID
      CreateRoleSystem.newbieRolewear = wear[i].ItemID
      log(bWriteLog and "   NewbieUpdateAvatar:CreateRoleSystem.NDefaultClothes" .. tostring(CreateRoleSystem.NDefaultClothes))
    end
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  CreateRoleSystem.DataMgrToAvatarData()
  CreateRoleSystem.SwitchCameraFarImmediate()
  log(bWriteLog and "  : CreateRoleSystem.NewbieUpdateAvatar" .. tostring(GameStatus.GetGameStatus()))
  if GameStatus.IsInLobbyOrMainCity() then
    LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.CHANGE_BODY)
  end
end
function CreateRoleSystem.CancelAvatar()
  CreateRoleSystem.DataMgrToAvatarData()
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_RESET_AVATR)
  CreateRoleSystem.SwitchCameraFar()
end
function CreateRoleSystem.OnCloseAvatarResetPanel(clicked)
  CreateRoleSystem.NCreateRoleLobbyToAvatar = 0
  if CreateRoleSystem.NCreateRoleMode == 1 then
    CreateRoleSystem.UIShowAvatarAni(clicked)
    return
  end
  CreateRoleSystem.NCreateRoleMode = 1
  log(bWriteLog and "  :clicked" .. tostring(clicked))
  if clicked then
    CreateRoleSystem.UIShowAvatarAni(clicked)
  end
end
function CreateRoleSystem.UIShowAvatarAni(clicked)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_AvatarAnim_UIBP, clicked)
end
function CreateRoleSystem.GatherBuyInfo(avatarId, buyList, ucBuyList)
  CreateRoleSystem.TryCtrAvatarData()
  local info = {}
  info.avatar_id = avatarId
  info.selected = 1
  info.owned = false
  info.remain_time_str = ""
  local arrayAvatarInit = arrayAvatarInitTable
  if arrayAvatarInit[avatarId].ForeverCost > 0 then
    info.buy_time_type = 4
    if 0 <= DataMgr.GetAvatarRemainTime(info.avatar_id) then
      info.owned = true
    else
      table.insert(ucBuyList, info)
    end
  elseif arrayAvatarInit[avatarId].AcquireMode == 1 then
    info.buy_time_type = 1
  else
    info.buy_time_type = 0
    info.owned = 0 <= DataMgr.GetAvatarRemainTime(info.avatar_id)
  end
  table.insert(buyList, info)
end
function CreateRoleSystem.GatherAvatarBuyInfos(buyList, ucBuyList)
  if CreateRoleSystem.NCreateRoleFace ~= CreateRoleSystem.NTempFace then
    CreateRoleSystem.GatherBuyInfo(CreateRoleSystem.NCreateRoleFace, buyList, ucBuyList)
  end
  if CreateRoleSystem.NCreateRoleHairType ~= CreateRoleSystem.NTempHairType then
    CreateRoleSystem.GatherBuyInfo(CreateRoleSystem.NCreateRoleHairType, buyList, ucBuyList)
  end
  if CreateRoleSystem.NCreateRoleBeardType ~= CreateRoleSystem.beardType and CreateRoleSystem.NCreateRoleSex == 1 then
    CreateRoleSystem.GatherBuyInfo(CreateRoleSystem.NCreateRoleBeardType, buyList, ucBuyList)
  end
  if CreateRoleSystem.NCreateRoleBeardColor ~= CreateRoleSystem.beardColor and CreateRoleSystem.NCreateRoleSex == 1 then
    CreateRoleSystem.GatherBuyInfo(CreateRoleSystem.NCreateRoleBeardColor, buyList, ucBuyList)
  end
  local arrayAvatarInit = arrayAvatarInitTable
  if CreateRoleSystem.NCreateRoleHairColor ~= CreateRoleSystem.NTempHairColor then
    for k, v in pairs(arrayAvatarInit) do
      if v.AvatarType == 3 and CreateRoleSystem.NCreateRoleHairColor == v.HairColor then
        local info = {}
        info.avatar_id = k
        info.selected = 1
        info.owned = false
        info.buy_time_type = 1
        table.insert(buyList, info)
        break
      end
    end
  end
  if CreateRoleSystem.NCreateRoleSex ~= CreateRoleSystem.NTempSex then
    for k, v in pairs(arrayAvatarInit) do
      if v.AvatarType == 4 and CreateRoleSystem.NCreateRoleSex == v.Sex then
        local info = {}
        info.avatar_id = k
        info.selected = 1
        info.owned = false
        info.buy_time_type = 1
        table.insert(buyList, info)
        break
      end
    end
  end
end
function CreateRoleSystem.ShowAvatarResetBuyPanel()
  CreateRoleSystem.CreateRoleBuyAvatars = {}
  CreateRoleSystem.CreateRoleUCBuyAvatars = {}
  CreateRoleSystem.GatherAvatarBuyInfos(CreateRoleSystem.CreateRoleBuyAvatars, CreateRoleSystem.CreateRoleUCBuyAvatars)
  if next(CreateRoleSystem.CreateRoleUCBuyAvatars) ~= nil then
    CreateRoleSystem.NCreateRoleBuyMode = 2
  else
    CreateRoleSystem.NCreateRoleBuyMode = 1
  end
  UIManager.ShowUI(UIManager.UI_Config.ResetPurchaseNew_UIBP)
end
function CreateRoleSystem.BuyAvatar()
  local list = {}
  local GetSelectedAvatar = function(array)
    for _, v in pairs(array) do
      if v.selected == 1 then
        list[v.avatar_id] = v.buy_time_type
      end
    end
  end
  if CreateRoleSystem.NCreateRoleBuyMode == 1 then
    GetSelectedAvatar(CreateRoleSystem.CreateRoleBuyAvatars)
  else
    GetSelectedAvatar(CreateRoleSystem.CreateRoleUCBuyAvatars)
  end
  if next(list) then
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_batch_buy_avatar_features_req(list)
  end
end
function CreateRoleSystem.BuyAvatarOK(avatar_list)
  CreateRoleSystem.TryCtrAvatarData()
  log_tree("  CreateRoleUI:BuyAvatarOK", avatar_list)
  log_tree("  CreateRoleUI:BuyAvatarOK Before", DataMgr.avatarData)
  local gamegender = AvatarData.GetGameGender()
  local headid = AvatarData.GetHeadID()
  local hairid = AvatarData.GetHairID()
  local beardid = AvatarData.GetBeardID()
  local beardcolorid = AvatarData.GetBeardColorID()
  local data = hairid % (BP_ENUM_AVATAR_HAIR * 100000)
  local haircolor = math.floor(data / 1000)
  local hairtype = data % 1000
  local avatars = arrayAvatarInitTable
  for k, _ in pairs(avatar_list) do
    local avatar = avatars[k]
    if avatar ~= nil then
      if avatar.AvatarType == 1 then
        headid = avatar.BodyID
      elseif avatar.AvatarType == 2 then
        hairtype = tonumber(avatar.Hair)
      elseif avatar.AvatarType == 3 then
        haircolor = avatar.HairColor
      elseif avatar.AvatarType == 4 then
        gamegender = avatar.Sex
      elseif avatar.AvatarType == 5 then
        beardid = avatar.BodyID
      elseif avatar.AvatarType == 6 then
        beardcolorid = avatar.BeardColor
      end
    end
  end
  AvatarData.SetGameGender(gamegender)
  AvatarData.SetHeadID(headid)
  AvatarData.SetHairID(tonumber(string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, haircolor, hairtype), 10))
  AvatarData.SetBeardID(beardid)
  AvatarData.SetBeardColorID(beardcolorid)
  CreateRoleSystem.DataMgrToAvatarData()
  log_tree("  CreateRoleUI:BuyAvatarOK After", DataMgr.avatarData)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HIDE_BUTTON)
  CreateRoleSystem.SwitchCameraFar()
end
function CreateRoleSystem.EventEnterLobby()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local NewbieGuideHandler = require("client.network.Protocol.NewbieGuideHandler")
  local bPlayVideo = false
  local videoId = NewbieGuideHandler.create_role_video_id or 0
  log(bWriteLog and "EventEnterLobby videoId = " .. videoId)
  if 0 < videoId then
    local tb = CDataTable.GetTable("VedioBarrage")
    for _, v in pairs(tb) do
      if v.ID == videoId then
        bPlayVideo = VideoLibrary.PlayVideo(v.VedioPath)
        break
      end
    end
  end
  if not bPlayVideo then
    CreateRoleSystem.RealEnterLobby()
  end
end
function CreateRoleSystem.RealEnterLobby()
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local StringUtil = require("common.string_util")
  local ret, len, _ = StringUtil.CheckName(CreateRoleSystem.SCreateRoleName, true)
  local bCheckNameSuccess = true
  if ret then
    ShowNotice(990004)
    bCheckNameSuccess = false
  elseif 14 < len then
    ShowNotice(990002)
    bCheckNameSuccess = false
  elseif len == 0 then
    ShowNotice(990003)
    bCheckNameSuccess = false
  end
  local StatManager = import("StatManager")
  if not bCheckNameSuccess then
    log(bWriteLog and "[stat] report event 28")
    StatManager.GetInstance():ReportEventWithNoParam(28, true)
    return
  end
  log(bWriteLog and "[stat] report event 29")
  StatManager.GetInstance():ReportEventWithNoParam(29, true)
  DeviceOSInfo.getDeviceOSInfo()
  CreateRoleSystem.GetCreateRoleHeadOrRace(true)
  CreateRoleSystem.SetCreateRoleHairID()
  local beard_info = {
    beard_id = CreateRoleSystem.NCreateRoleBeardID,
    beard_color = CreateRoleSystem.NCreateRoleBeardColorID
  }
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  local funcName = "send_create_role_request"
  if LobbySystem.CheckUseNewGuide() then
    funcName = "send_modify_newbie_info_req"
  end
  log(bWriteLog and "  :funcName" .. tostring(funcName))
  log(bWriteLog and "  :CreateRoleSystem.NCreateRoleSex" .. tostring(CreateRoleSystem.NCreateRoleSex))
  LobbyHandler[funcName](CreateRoleSystem.SCreateRoleName, CreateRoleSystem.NCreateRoleSex, CreateRoleSystem.NCreateRoleHeadId, CreateRoleSystem.NCreateRoleHairID, DeviceOSInfo.InfoList, CreateRoleSystem.SCreateRoleNation, beard_info, CreateRoleSystem.BUseSocialAvatar)
end
function CreateRoleSystem.SetCloseBackFunction(callBack, para)
  CreateRoleSystem.CloseCallBack = callBack
  CreateRoleSystem.CloseCllBackPara = para or {}
end
function CreateRoleSystem:GetDefaultFace()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if IsBLUEHOLE then
    log(bWriteLog and "CreateRoleSystem:GetDefaultFace IsBLUEHOLE")
    return 10009
  end
  return 10007
end
function CreateRoleSystem:GetDefaultHairID()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if IsBLUEHOLE then
    log(bWriteLog and "CreateRoleSystem:GetDefaultHairID IsBLUEHOLE")
    return 40601002
  end
  return 40601001
end
function CreateRoleSystem.proc_validate_nickname_rsp(err_code, nickname)
  log_format(bWriteLog and "CreateRoleSystem.proc_validate_nickname_rsp err_code: %s   nickname: %s ", tostring(err_code), tostring(nickname))
  if not nickname then
    return
  end
  CreateRoleSystem.nameValidMap = CreateRoleSystem.nameValidMap or {}
  CreateRoleSystem.nameValidMap[nickname] = err_code and err_code == 0
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATEROLE_VALID)
end
function CreateRoleSystem.proc_get_valid_nickname_list_rsp(nick_list)
  if not nick_list then
    return
  end
  log_tree("CreateRoleSystem.proc_get_valid_nickname_list_rsp", nick_list)
  CreateRoleSystem.validNameList = {}
  for k, v in pairs(nick_list) do
    table.insert(CreateRoleSystem.validNameList, k)
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATEROLE_NAMELIST)
end
function CreateRoleSystem.send_get_valid_nickname_list_req()
  local nickname = CreateRoleSystem.SCreateRoleName or ""
  local lang = Client.GetCurrentLanguage()
  if nickname == "" then
    return
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  log(bWriteLog and string.format("CreateRoleSystem.send_get_valid_nickname_list_req %s, %s", lang, nickname))
  LobbyHandler.send_get_valid_nickname_list_req(lang, nickname)
end
function CreateRoleSystem.GetCameraByName(cameraName)
  if not CreateRoleSystem.weakCameraCache then
    CreateRoleSystem.weakCameraCache = {}
  end
  local camera = CreateRoleSystem.weakCameraCache[cameraName]
  if slua.isValid(camera) then
    log(bWriteLog and "CreateRoleSystem.GetCameraByName cache name: " .. tostring(cameraName))
    return camera
  end
  local GameplayStatics = import("GameplayStatics")
  local uActorClass = import("/Script/Engine.Actor")
  local uWorldActorClass = import("CameraActor")
  local UIUtil = require("client.common.ui_util")
  local uWorldActorArray = GameplayStatics.GetAllActorsOfClass(UIUtil.GetGameInstance(), uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, uActorClass))
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if uWorldActorArray then
    for _, uTarget in pairs(uWorldActorArray) do
      if uTarget and slua.isValid(uTarget) then
        local name = KismetSystemLibrary.GetObjectName(uTarget)
        log_format(bWriteLog and "Lobby_CreatRoleNew_UIBP:GetCurrentCamera name:%s cameraName:%s", tostring(name), tostring(cameraName))
        if tostring(name) == tostring(cameraName) then
          CreateRoleSystem.weakCameraCache[cameraName] = uTarget
          return uTarget
        end
      end
    end
  end
end
function CreateRoleSystem.SwitchCameraByName(cameraName, nBlendTime)
  local cameraActor = CreateRoleSystem.GetCameraByName(cameraName)
  if slua.isValid(cameraActor) then
    nBlendTime = tonumber(nBlendTime) or 0
    local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    PlayerController:SetViewTargetWithBlend(cameraActor, nBlendTime, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
  else
    log(bWriteLog and "CreateRoleSystem.SwitchCameraByName no camera: " .. tostring(cameraName))
  end
end
return CreateRoleSystem