local logic_friendlist_custom_utils = {}
local ENUM_SWITCH_STATE = {Open = 1, Close = 0}
local ENUM_DISPLAY_SWITCH_VALUE = {
  CollectLevel = 1,
  Alias = 2,
  Pass = 4,
  WowPass = 8,
  Gender = 16,
  NationFlag = 32,
  Certification = 64
}
local ALL_SWITCHES_ON = 127
function logic_friendlist_custom_utils.SetSwitch(switchValue, switchMask, isOn)
  switchValue = switchValue or 0
  if isOn then
    if switchMask <= switchValue % (switchMask * 2) then
      return switchValue
    end
    return switchValue + switchMask
  else
    if switchMask > switchValue % (switchMask * 2) then
      return switchValue
    end
    return switchValue - switchMask
  end
end
function logic_friendlist_custom_utils.GetSwitch(switchValue, switchMask)
  switchValue = switchValue or 0
  return switchMask <= switchValue % (switchMask * 2)
end
logic_friendlist_custom_utils.SWITCH_MASK = ENUM_DISPLAY_SWITCH_VALUE
function logic_friendlist_custom_utils.GetEnabledItemSwitchCount(switchValue)
  switchValue = switchValue or 0
  local count = 0
  local itemSwitches = {
    ENUM_DISPLAY_SWITCH_VALUE.Pass,
    ENUM_DISPLAY_SWITCH_VALUE.WowPass,
    ENUM_DISPLAY_SWITCH_VALUE.Gender,
    ENUM_DISPLAY_SWITCH_VALUE.NationFlag,
    ENUM_DISPLAY_SWITCH_VALUE.Certification
  }
  for _, maskValue in ipairs(itemSwitches) do
    if logic_friendlist_custom_utils.GetSwitch(switchValue, maskValue) then
      count = count + 1
    end
  end
  log(bWriteLog and string.format("logic_friendlist_custom_utils.GetEnabledItemSwitchCount: switchValue=%d (0x%X), itemCount=%d", switchValue, switchValue, count))
  return count
end
function logic_friendlist_custom_utils.CalculateDefaultSwitch(profile)
  if not profile then
    log(bWriteLog and "logic_friendlist_custom_utils.CalculateDefaultSwitch: profile is nil")
    return 0
  end
  local defaultSwitch = 0
  local ownedItems = {}
  local hasCollectData = profile.collect_data and next(profile.collect_data)
  if hasCollectData then
    defaultSwitch = defaultSwitch + ENUM_DISPLAY_SWITCH_VALUE.CollectLevel
    log(bWriteLog and "logic_friendlist_custom_utils: CollectLevel default ON")
  end
  local hasAlias = false
  if profile.alias and profile.alias.id and 0 < profile.alias.id then
    hasAlias = true
  else
    local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
    local aliasListData = logic_roleinfo_title.GetAliasListData()
    if aliasListData and next(aliasListData) then
      for aliasId, aliasData in pairs(aliasListData) do
        if aliasData.state and (aliasData.state == 1 or aliasData.state == 2) then
          hasAlias = true
          break
        end
      end
    end
  end
  if hasAlias then
    defaultSwitch = defaultSwitch + ENUM_DISPLAY_SWITCH_VALUE.Alias
    log(bWriteLog and "logic_friendlist_custom_utils: Alias default ON")
  end
  if profile.social_card and profile.social_card.new_sex and 0 < profile.social_card.new_sex then
    table.insert(ownedItems, {
      mask = ENUM_DISPLAY_SWITCH_VALUE.Gender,
      priority = 1,
      name = "Gender"
    })
  end
  if profile.nation then
    table.insert(ownedItems, {
      mask = ENUM_DISPLAY_SWITCH_VALUE.NationFlag,
      priority = 2,
      name = "NationFlag"
    })
  end
  local logic_teammate_info = require("client.slua.umg.MainCity.Lobby_Friend.logic_teammate_info")
  if logic_teammate_info.CheckAuthInfoOpen(profile.auth_type, profile.auth_end_time) then
    table.insert(ownedItems, {
      mask = ENUM_DISPLAY_SWITCH_VALUE.Certification,
      priority = 3,
      name = "Certification"
    })
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local UPassIsBuy, UPassIsShow, UPassKeepBuy, UPassValue, pass_type = LogicFriend.ParsePassInfo(profile.upass)
  if UPassIsShow then
    table.insert(ownedItems, {
      mask = ENUM_DISPLAY_SWITCH_VALUE.Pass,
      priority = 4,
      name = "Pass"
    })
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if Util_UGC.WoWPassActive(profile) then
    local iconPath = Util_UGC.GetWoWPassIconPath(profile)
    if iconPath and iconPath ~= "" then
      table.insert(ownedItems, {
        mask = ENUM_DISPLAY_SWITCH_VALUE.WowPass,
        priority = 5,
        name = "WowPass"
      })
    end
  end
  table.sort(ownedItems, function(a, b)
    return a.priority < b.priority
  end)
  local enableCount = math.min(2, #ownedItems)
  for i = 1, enableCount do
    defaultSwitch = defaultSwitch + ownedItems[i].mask
    log(bWriteLog and string.format("logic_friendlist_custom_utils: %s default ON (priority %d)", ownedItems[i].name, ownedItems[i].priority))
  end
  log(bWriteLog and string.format("logic_friendlist_custom_utils.CalculateDefaultSwitch: result=%d (0x%X), owned=%d, enabled=%d", defaultSwitch, defaultSwitch, #ownedItems, enableCount))
  return defaultSwitch
end
local displayItems = {
  {
    iconPath = "/Game/UMG/Texture/Lobby_NoAtlas/Common/UnknowPass/RPA_Record_Icon_LV_None.RPA_Record_Icon_LV_None",
    itemName = 4547,
    bitMask = ENUM_DISPLAY_SWITCH_VALUE.Pass,
    hasSettingPage = false
  },
  {
    iconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Ugc/Ugc_Icon_WoWPass_Badge01.Ugc_Icon_WoWPass_Badge01",
    itemName = 68890,
    bitMask = ENUM_DISPLAY_SWITCH_VALUE.WowPass,
    hasSettingPage = false
  },
  {
    iconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Boy_png.Common_Icon_Boy_png",
    itemName = 69101,
    bitMask = ENUM_DISPLAY_SWITCH_VALUE.Gender,
    hasSettingPage = true
  },
  {
    iconPath = "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_iland_png.T_icon_flag_iland_png",
    itemName = 43275,
    bitMask = ENUM_DISPLAY_SWITCH_VALUE.NationFlag,
    hasSettingPage = true
  },
  {
    iconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Image_Certification_png.Common_Image_Certification_png",
    itemName = 87394,
    bitMask = ENUM_DISPLAY_SWITCH_VALUE.Certification,
    hasSettingPage = false
  }
}
logic_friendlist_custom_utils.return logic_friendlist_custom_utils