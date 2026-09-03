local SocialCardSystem = {
  MySocialCard = {},
  SocialCard = {},
  preUnloadTime = 0
}
function SocialCardSystem.OnLogOut()
  log(bWriteLog and "SocialCardSystem.OnLogOut")
  SocialCardSystem.MySocialCard = {}
  SocialCardSystem.SocialCard = {}
end
function SocialCardSystem.get_social_card()
  log(bWriteLog and "SocialCardSystem.get_social_card")
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_social_card()
end
function SocialCardSystem.get_social_card_rsp(ok, social_card)
  log(bWriteLog and string.format("SocialCardSystem.get_social_card_rsp ok:%s", tostring(ok)))
  if ok == 0 then
    log(bWriteLog and string.format("SocialCardSystem.get_social_card_rsp birthday:%s", tostring(social_card.birthday)))
    SocialCardSystem.MySocialCard = social_card
    SocialCardSystem.SocialCard = social_card
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CARD_UPDATE, social_card)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARD)
  else
    DataMgr.ShowMessageBoxByID(ok)
  end
end
local GetTableDataValue = function(tableName, ID, columnName)
  local cfg = CDataTable.GetTableData(tableName, ID)
  if not cfg then
    return "--"
  end
  return cfg[columnName]
end
local GetTableDataList = function(tableName, columnName)
  local List = {}
  local t1Table = CDataTable.GetTable(tableName)
  if t1Table then
    for j, cfg in pairs(t1Table) do
      List[tonumber(j)] = cfg[columnName]
    end
  end
  return List
end
function SocialCardSystem.GetTendencyValue(ID)
  return GetTableDataValue("SocialCardTendency", ID, "Tendency")
end
function SocialCardSystem.GetTendencyList()
  return GetTableDataList("SocialCardTendency", "Tendency")
end
function SocialCardSystem.GetExpertAreaValue(ID)
  return GetTableDataValue("SocialCardExpertArea", ID, "ExpertArea")
end
function SocialCardSystem.GetExpertAreaList()
  return GetTableDataList("SocialCardExpertArea", "ExpertArea")
end
function SocialCardSystem.GetModeValue(ID)
  return GetTableDataValue("SocialCardMode", ID, "Mode")
end
function SocialCardSystem.GetModeList()
  return GetTableDataList("SocialCardMode", "Mode")
end
function SocialCardSystem.GetDataValue(ID)
  return GetTableDataValue("SocialCardDate", ID, "Date")
end
function SocialCardSystem.GetDataList()
  return GetTableDataList("SocialCardDate", "Date")
end
function SocialCardSystem.GetTimeList()
  return GetTableDataList("SocialCardTime", "Time")
end
function SocialCardSystem.GetTimeValue(ID)
  return GetTableDataValue("SocialCardTime", ID, "Time")
end
function SocialCardSystem.GetVoiceValue(ID)
  return GetTableDataValue("SocialCardVoice", ID, "Voice")
end
function SocialCardSystem.GetVoiceList()
  return GetTableDataList("SocialCardVoice", "Voice")
end
function SocialCardSystem.GetWeaponTypeValue(ID)
  return GetTableDataValue("SocialCardWeaponType", ID, "Type")
end
function SocialCardSystem.GetWeaponTypeList()
  return GetTableDataList("SocialCardWeaponType", "Type")
end
function SocialCardSystem.GetWeaponValue(ID)
  local cfg = CDataTable.GetTableData("SocialCardWeapon", ID)
  return {
    type = cfg.Type,
    Weapon = cfg.Weapon
  }
end
function SocialCardSystem.GetWeaponList()
  local ListWeapon = {}
  local t6Table = CDataTable.GetTable("SocialCardWeapon")
  for j, cfg in pairs(t6Table) do
    ListWeapon[tonumber(j)] = {
      type = cfg.Type,
      Weapon = cfg.Weapon
    }
  end
  return ListWeapon
end
function SocialCardSystem.GetWeaponListByType(weaponType)
  local List = {}
  local t1Table = CDataTable.GetTableByFilter("SocialCardWeapon", "Type", weaponType)
  if t1Table then
    for key, cfg in pairs(t1Table) do
      table.insert(List, {
        index = key,
        weapon = cfg.weapon
      })
    end
  end
  return List
end
function SocialCardSystem.GetPreServerValue(index)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  local bIsBluehole = strRegion == PublishRegionMacros.BLUEHOLE
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussiaArea = logic_multiple_area:IsConnectToRussiaArea()
  if bIsBluehole then
    return {
      zoneId = 3,
      displayName = logic_multiple_area:GetDisplayNameByZoneID(3)
    }
  elseif isRussiaArea then
    return {
      zoneId = 2,
      displayName = logic_multiple_area:GetDisplayNameByZoneID(2)
    }
  else
    local cfg = CDataTable.GetTableData("ZoneConfig", index)
    if cfg then
      return {
        zoneId = cfg.ZoneID,
        displayName = cfg.NameInChinese
      }
    else
      return nil
    end
  end
end
function SocialCardSystem.GetPreServerList()
  local ListPreServer = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  local bIsBluehole = strRegion == PublishRegionMacros.BLUEHOLE
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussiaArea = logic_multiple_area:IsConnectToRussiaArea()
  if bIsBluehole then
    ListPreServer[1] = {
      zoneId = 3,
      displayName = logic_multiple_area:GetDisplayNameByZoneID(3)
    }
  elseif isRussiaArea then
    ListPreServer[1] = {
      zoneId = 2,
      displayName = logic_multiple_area:GetDisplayNameByZoneID(2)
    }
  else
    local cfg = CDataTable.GetTable("ZoneConfig")
    for _, v in pairs(cfg) do
      ListPreServer[v.ZoneID] = {
        zoneId = v.ZoneID,
        displayName = v.NameInChinese
      }
    end
  end
  return ListPreServer
end
function SocialCardSystem.GetOtherText()
  return "--"
end
function SocialCardSystem.UnifyCardData(SocialCard)
  local CardTagList = {}
  if SocialCard and type(SocialCard.label) == "table" then
    local tmp = {}
    for i, v in ipairs(SocialCard.label) do
      local cfg = CDataTable.GetTableData("SocialCardLabel", v)
      if cfg then
        table.insert(tmp, cfg)
      end
    end
    table.sort(tmp, function(a, b)
      return a.ID < b.ID
    end)
    for i, v in ipairs(tmp) do
      table.insert(CardTagList, v.Label)
    end
  end
  return CardTagList
end
function SocialCardSystem.GetFormatData(showData, func)
  local data1 = ""
  local data2 = ""
  if showData and type(showData) == "table" then
    if showData[1] then
      data1 = func(showData[1])
    end
    if showData[2] then
      data2 = func(showData[2])
    end
  end
  log(bWriteLog and "SocialCardSystem.GetFormatData data1 = " .. tostring(data1) .. " data2 = " .. tostring(data2))
  local result = SocialCardSystem.GetConnectStr(data1, data2)
  log(bWriteLog and "SocialCardSystem.GetFormatData result = " .. tostring(result))
  return result
end
function SocialCardSystem.GetConnectStr(str1, str2)
  local result = ""
  if str1 ~= "" and str2 ~= "" then
    result = LocUtil.LocalizeResFormat(45903, tostring(str1), tostring(str2))
  elseif str1 == "" and str2 == "" then
    result = "--"
  else
    result = tostring(str1) .. tostring(str2)
  end
  return result
end
function SocialCardSystem.CheckHasSocialData()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(DataMgr.roleData.uid)
  if profile and profile.social_card then
    local social_card = profile.social_card
    if SocialCardSystem.CheckBlockNewData() then
      local cardTagList = SocialCardSystem.UnifyCardData(social_card)
      local hasLabel = cardTagList and next(cardTagList)
      return hasLabel
    end
    local mainSwitch = SocialCardSystem.GetSocialCardMainSwitch()
    local graySwitch = SocialCardSystem.GetSocialCardGraySwitch()
    local voice_card = social_card.voice_card or {}
    local fileid = voice_card.fileid
    local length = voice_card.length
    local isBlackMarket = DataMgr.roleData.social_card_share_limit
    local hasRecord = fileid and length
    log(bWriteLog and "SocialCardSystem.CheckHasSocialData hasRecord = " .. tostring(hasRecord))
    if mainSwitch and graySwitch and not isBlackMarket and (hasRecord == nil or hasRecord == false) then
      return false
    end
    local voice = social_card.voice_state
    local mode = social_card.expert_mode
    local cardTagList = SocialCardSystem.UnifyCardData(social_card)
    local hasVoice = voice and voice ~= ""
    log(bWriteLog and "SocialCardSystem.CheckHasSocialData hasVoice = " .. tostring(hasVoice))
    local hasMode = mode and type(mode) == "table" and next(mode) and mode[1] and mode[1] ~= ""
    log(bWriteLog and "SocialCardSystem.CheckHasSocialData hasMode = " .. tostring(hasMode))
    local hasLabel = cardTagList and next(cardTagList)
    log(bWriteLog and "SocialCardSystem.CheckHasSocialData hasLabel = " .. tostring(hasLabel))
    return hasVoice or hasMode or hasLabel
  end
  return false
end
function SocialCardSystem.CheckHasRecord()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(DataMgr.roleData.uid)
  if profile and profile.social_card then
    local mainSwitch = SocialCardSystem.GetSocialCardMainSwitch()
    if not mainSwitch then
      return false
    end
    local graySwitch = SocialCardSystem.GetSocialCardGraySwitch()
    if not graySwitch then
      return false
    end
    local social_card = profile.social_card
    local voice_card = social_card.voice_card or {}
    local fileid = voice_card.fileid
    local length = voice_card.length
    local hasRecord = fileid and length
    if hasRecord then
      return true
    end
  end
  return false
end
function SocialCardSystem.CheckBlockNewData()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and "SocialCardSystem.CheckBlockNewData BLUEHOLE version")
    return true
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local region = login_module.sIpRegion
  log(bWriteLog and "SocialCardSystem.CheckBlockNewData region = " .. tostring(region))
  if region == "US" then
    log(bWriteLog and "SocialCardSystem.CheckBlockNewData ip_region is US")
    return true
  end
  if FuncUtil.GetAccountRegionForBP() == "US" then
    log(bWriteLog and "SocialCardSystem.CheckBlockNewData accountRegion is US")
    return true
  end
  log(bWriteLog and "SocialCardSystem.CheckBlockNewData region is not US")
  return false
end
function SocialCardSystem.GetShareCardData(isCheck)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(DataMgr.roleData.uid)
  if profile and profile.social_card then
    local social_card = {
      tendency = profile.social_card.tendency,
      label = profile.social_card.label,
      play_date = profile.social_card.play_date,
      play_time = profile.social_card.play_time
    }
    local bBlock = SocialCardSystem.CheckBlockNewData()
    log(bWriteLog and "SocialCardSystem.GetShareCardData bBlock = " .. tostring(bBlock))
    if not bBlock then
      social_card.voice_state = profile.social_card.voice_state
      social_card.expert_mode = profile.social_card.expert_mode
    end
    if isCheck and not bBlock then
      social_card.voice_card = profile.social_card.voice_card
    end
    log_tree("SocialCardSystem.GetShareCardData social_card", social_card)
    return social_card
  end
  log(bWriteLog and "SocialCardSystem.GetShareCardData profile is invalid")
  return {}
end
function SocialCardSystem.GetSocialCardGraySwitch()
  log(bWriteLog and "SocialCardSystem.GetSocialCardGraySwitch")
  local graySwitch = false
  if LobbySystem.roleData.all_gray_switch and LobbySystem.roleData.all_gray_switch[2] then
    graySwitch = true
  end
  log(bWriteLog and "SocialCardSystem.GetSocialCardGraySwitch graySwitch = " .. tostring(graySwitch))
  return graySwitch
end
function SocialCardSystem.GetSocialCardMainSwitch()
  local bOpen = LobbySystem.CheckOpen(BP_ENUM_SOCIAL_CARD_SWITCH)
  log(bWriteLog and "SocialCardSystem.GetSocialCardMainSwitch bOpen = " .. tostring(bOpen))
  return bOpen
end
function SocialCardSystem.GetCarteFrameEquipIdByProfile(profile)
  if not profile or not profile.social_card then
    return nil
  end
  local carte_frame_equip_id = profile.social_card.carte_frame_equip_id
  if tonumber(profile.uid) == tonumber(DataMgr.roleData.uid) and profile.social_card.carte_frame and profile.social_card.carte_frame[carte_frame_equip_id] and profile.social_card.carte_frame[carte_frame_equip_id].expire_ts then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    local time = profile.social_card.carte_frame[carte_frame_equip_id].expire_ts
    if 1 < time and now >= time then
      local logic_roleinfo_carte_frame = require("client.slua.logic.roleInfo.logic_roleinfo_carte_frame")
      local defaultID = logic_roleinfo_carte_frame:GetDefaultSkinID()
      if SocialCardSystem.preUnloadTime ~= now then
        SocialCardSystem.preUnloadTime = now
        logic_roleinfo_carte_frame:equip_carte_frame_req(carte_frame_equip_id, false)
        profile.social_card.carte_frame_equip_id = defaultID
        SocialCardSystem.SocialCard.carte_frame_equip_id = defaultID
        SocialCardSystem.MySocialCard.carte_frame_equip_id = defaultID
      end
      return defaultID
    end
  end
  return carte_frame_equip_id
end
return SocialCardSystem