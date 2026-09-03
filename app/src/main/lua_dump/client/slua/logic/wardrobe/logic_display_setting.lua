local logic_display_setting = {
  Enum_TrappedState = {None = 0, AppearanceTrapped = 1}
}
local super_data = require("common.super_data")
local data = super_data.CreateSuperData({
  OpenBag = true,
  OpenGun = true,
  OpenHelmet = true,
  OpenVehicle = true,
  OpenAction = true,
  ShowMiniTv = true,
  OpenIdle = true,
  OpenEnterPlayVoice = true,
  OpenSocialWeapon = true,
  OpenGlide = false,
  keepBagInsID = 0,
  keepHelmetInsID = 0,
  OpenGloves = true,
  HideMetroHelmet = false,
  HideMetroBag = false,
  HideMetroFashionArmor = false,
  LobbyHideMetroFashionArmor = false,
  HideMetroFashionBackpack = false,
  LobbyHideMetroFashionBackpack = false,
  HideFightHelmet = false,
  ShowGlideEffectBanner = false,
  LobbyHideMetroFashionHelmet = false,
  HideMetroFashionHelmet = false,
  GamePerformanceVoice = true,
  TeamUpActionType = 0,
  MVPActionType = 0,
  OpenUpgradeGunAttach = true
})
local DisplayTrappedState = logic_display_setting.Enum_TrappedState.None
function logic_display_setting.UpdateDepotShowSettings(settings)
  log_tree("UpdateDepotShowSettings", settings)
  if not settings then
    return
  end
  if settings.weapon ~= nil then
    data.OpenGun = settings.weapon
  end
  if settings.bag ~= nil then
    data.OpenBag = settings.bag
  end
  if settings.helmet ~= nil then
    data.OpenHelmet = settings.helmet
  end
  if settings.vehicle ~= nil then
    data.OpenVehicle = settings.vehicle
  end
  if settings.action ~= nil then
    data.OpenAction = settings.action
  end
  if settings.glide ~= nil then
    data.OpenGlide = settings.glide
  end
  if settings.social_weapon ~= nil then
    data.OpenSocialWeapon = settings.social_weapon
  end
  if settings.idle ~= nil then
    data.OpenIdle = settings.idle
  end
  if settings.play_voice ~= nil then
    data.OpenEnterPlayVoice = settings.play_voice
  end
  if settings.fightHelmet ~= nil then
    data.HideFightHelmet = settings.fightHelmet
  end
  if settings.glideShow ~= nil then
    data.ShowGlideEffectBanner = settings.glideShow
  end
  if settings.miniTVShow ~= nil then
    data.ShowMiniTv = settings.miniTVShow
  end
  if settings.metroFashionArmor ~= nil then
    data.HideMetroFashionArmor = settings.metroFashionArmor
  end
  if settings.lobbyMetroFashionArmor ~= nil then
    data.LobbyHideMetroFashionArmor = settings.lobbyMetroFashionArmor
  end
  if settings.metroFashionBackpack ~= nil then
    data.HideMetroFashionBackpack = settings.metroFashionBackpack
  end
  if settings.lobbyHideMetroFashionBackpack ~= nil then
    data.LobbyHideMetroFashionBackpack = settings.lobbyHideMetroFashionBackpack
  end
  if settings.LobbyHideMetroFashionHelmet ~= nil then
    data.LobbyHideMetroFashionHelmet = settings.LobbyHideMetroFashionHelmet
  end
  if settings.metroFashionHelmet ~= nil then
    data.HideMetroFashionHelmet = settings.metroFashionHelmet
  end
  if settings.hand ~= nil then
    data.OpenGloves = settings.hand
    if LobbySystem.roleData.depot_show_info then
      LobbySystem.roleData.depot_show_info.hand = settings.hand
    end
  end
  if settings.isMetroLobbyHiddenHelmet ~= nil then
    data.HideMetroHelmet = settings.isMetroLobbyHiddenHelmet
  end
  if settings.isMetroLobbyHiddenBag ~= nil then
    data.HideMetroBag = settings.isMetroLobbyHiddenBag
  end
  if settings.game_performance_voice ~= nil then
    data.GamePerformanceVoice = settings.game_performance_voice
  end
  if settings.lobby_performance_voice ~= nil then
    data.LobbyPerformanceVoice = settings.lobby_performance_voice
  end
  if settings.GunUpgradeAccessories ~= nil then
    data.OpenUpgradeGunAttach = settings.GunUpgradeAccessories
  else
    data.OpenUpgradeGunAttach = true
  end
  logic_display_setting.SyncSettingConfig()
  logic_display_setting.SyncLobbyMetroFashionArmor()
end
function logic_display_setting.SendDepotShowSettings()
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  local DepotShowSetting = {
    bag = data.OpenBag,
    weapon = data.OpenGun,
    helmet = data.OpenHelmet,
    vehicle = data.OpenVehicle,
    action = data.OpenAction,
    glide = data.OpenGlide,
    play_voice = data.OpenEnterPlayVoice,
    social_weapon = data.OpenSocialWeapon,
    idle = data.OpenIdle,
    glideShow = data.ShowGlideEffectBanner,
    fightHelmet = data.HideFightHelmet,
    miniTVShow = data.ShowMiniTv,
    metroFashionArmor = data.HideMetroFashionArmor,
    lobbyMetroFashionArmor = data.LobbyHideMetroFashionArmor,
    metroFashionBackpack = data.HideMetroFashionBackpack,
    lobbyHideMetroFashionBackpack = data.LobbyHideMetroFashionBackpack,
    LobbyHideMetroFashionHelmet = data.LobbyHideMetroFashionHelmet,
    metroFashionHelmet = data.HideMetroFashionHelmet,
    hand = data.OpenGloves,
    isMetroLobbyHiddenHelmet = data.HideMetroHelmet,
    isMetroLobbyHiddenBag = data.HideMetroBag,
    game_performance_voice = data.GamePerformanceVoice,
    lobby_performance_voice = data.LobbyPerformanceVoice,
    mvpActionType = data.MVPActionType,
    GunUpgradeAccessories = data.OpenUpgradeGunAttach
  }
  WardRobeHandler.send_set_show_info_req(DepotShowSetting)
end
function logic_display_setting.GetDepotShowSettings()
  return {
    weapon = data.OpenGun,
    vehicle = data.OpenVehicle,
    helmet = data.OpenHelmet,
    bag = data.OpenBag,
    action = data.OpenAction,
    glide = data.OpenGlide,
    social_weapon = data.OpenSocialWeapon,
    idle = data.OpenIdle,
    play_voice = data.OpenEnterPlayVoice,
    fightHelmet = data.HideFightHelmet,
    miniTVShow = data.ShowMiniTv,
    TeamUpActionType = data.TeamUpActionType,
    metroFashionArmor = data.HideMetroFashionArmor,
    lobbyMetroFashionArmor = data.LobbyHideMetroFashionArmor,
    metroFashionBackpack = data.HideMetroFashionBackpack,
    lobbyHideMetroFashionBackpack = data.LobbyHideMetroFashionBackpack,
    LobbyHideMetroFashionHelmet = data.LobbyHideMetroFashionHelmet,
    metroFashionHelmet = data.HideMetroFashionHelmet,
    hand = data.OpenGloves,
    metroHelmet = data.HideMetroHelmet,
    metroBag = data.HideMetroBag,
    MVPActionType = data.MVPActionType,
    GunUpgradeAccessories = data.OpenUpgradeGunAttach
  }
end
function logic_display_setting.GetData()
  return data
end
function logic_display_setting.ShowHelmet()
  return data.OpenHelmet
end
function logic_display_setting.ShowBag()
  return data.OpenBag
end
function logic_display_setting.ShowGloves()
  return data.OpenGloves
end
function logic_display_setting.ShowIdle()
  return data.OpenIdle
end
function logic_display_setting.ShowGun()
  return data.OpenGun
end
function logic_display_setting.ShowEnterPlayVoice()
  return data.OpenEnterPlayVoice
end
function logic_display_setting.ShowMiniTv()
  return data.ShowMiniTv
end
function logic_display_setting.MVPActionType()
  return data.MVPActionType
end
function logic_display_setting.HideMetroLobbyHelmet()
  return data.HideMetroHelmet
end
function logic_display_setting.HideMetroLobbyBag()
  return data.HideMetroBag
end
function logic_display_setting.HideMetroFashionArmor()
  return data.HideMetroFashionArmor
end
function logic_display_setting.LobbyHideMetroFashionArmor()
  return data.LobbyHideMetroFashionArmor
end
function logic_display_setting.HideMetroFashionBackpack()
  return data.HideMetroFashionBackpack
end
function logic_display_setting.LobbyHideMetroFashionBackpack()
  return data.LobbyHideMetroFashionBackpack
end
function logic_display_setting.LobbyHideMetroFashionHelmet()
  return data.LobbyHideMetroFashionHelmet
end
function logic_display_setting.HideMetroFashionHelmet()
  return data.HideMetroFashionHelmet
end
function logic_display_setting.GamePerformanceVoice()
  return data.GamePerformanceVoice
end
function logic_display_setting.LobbyPerformanceVoice()
  return data.LobbyPerformanceVoice
end
function logic_display_setting.OpenUpgradeGunAttach()
  return data.OpenUpgradeGunAttach
end
function logic_display_setting.IsDisplayTrappedInState(state)
  if state then
    return DisplayTrappedState == state
  else
    return DisplayTrappedState ~= logic_display_setting.Enum_TrappedState.None
  end
end
function logic_display_setting.GetPutOnAvatarHelmetInsId()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetCurrentFashionBag()
  if not bag then
    return 0
  end
  local helmetInsId
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if fashionbag_data:GetDepotBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) then
    local helmetLevel = bag.helmet_level or 3
    helmetInsId = fashionbag_data:GetHelmetSkinByLevel(helmetLevel)
  else
    helmetInsId = bag.helmet_skin
  end
  return helmetInsId or 0
end
function logic_display_setting.GetPutOnAvatarBagInsId()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetCurrentFashionBag()
  if not bag then
    log(bWriteLog and string.format("GetPutOnAvatarBagInsId: bag is nil."))
    return 0
  end
  local bagInsId
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if fashionbag_data:GetDepotBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) then
    local bagLevel = bag.bag_level or 3
    bagInsId = fashionbag_data:GetBagSkinByLevel(bagLevel)
    log(bWriteLog and string.format("GetPutOnAvatarBagInsId: bagLevel = %s, bagInsId = %s", bagLevel, bagInsId))
  else
    bagInsId = bag.bag_skin
    log(bWriteLog and string.format("GetPutOnAvatarBagInsId: bagInsId = %s", bagInsId))
  end
  return bagInsId or 0
end
function logic_display_setting.GetPutOnAvatarGlovesInsId()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetCurrentFashionBag()
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, InsID in pairs(bag.rolewear_list) do
    local itemData = wardrobeData:GetValidHallDepotItemDataByInsID(InsID)
    if itemData and itemData.itemSubType == ENUM_ITEM_SUBTYPE.Gloves then
      return InsID
    end
  end
  return 0
end
function logic_display_setting.TrapIntoState(state)
  DisplayTrappedState = state or logic_display_setting.Enum_TrappedState.None
end
function logic_display_setting.ChangeAvatar(itemInsId, putOnFlag)
  log(bWriteLog and "ChangeAvatar..")
  if itemInsId and itemInsId ~= 0 then
    local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobeData:GetValidHallDepotItemDataByInsID(itemInsId)
    if itemData and itemData.resID then
      local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
      logic_wardrobe_avatar:AvatarChange(itemData.resID, putOnFlag)
    end
  end
end
function logic_display_setting.SwitchGun()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenGun = not data.OpenGun
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  logic_wardrobe_gun:SwitchShowGun(data.OpenGun)
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchVehicle()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenVehicle = not data.OpenVehicle
  HallThemeUtils.set_knapsack_pos_show_req(data.OpenVehicle)
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchHelmet()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenHelmet = not data.OpenHelmet
  if data.OpenHelmet then
    local keepHelmetInsID = logic_display_setting.GetPutOnAvatarHelmetInsId()
    if 0 < keepHelmetInsID then
      if not logic_display_setting.IsDisplayTrappedInState(logic_display_setting.Enum_TrappedState.AppearanceTrapped) then
        logic_display_setting.ChangeAvatar(keepHelmetInsID, true)
      end
      local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
      fashionbag_data:SetHeadShow(keepHelmetInsID)
      local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
      WardRobeHandler.send_depot_set_head_show_req(keepHelmetInsID)
    end
  end
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.GetCurrentHeadShow()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetCurrentFashionBag()
  local head_show = bag and bag.head_show
  return head_show or 0
end
function logic_display_setting.SwitchBag()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenBag = not data.OpenBag
  if data.OpenBag then
    local keepBagInsID = logic_display_setting.GetPutOnAvatarBagInsId()
    log(bWriteLog and string.format("logic_display_setting.SwitchBag, keepBagInsID: %s", keepBagInsID))
    logic_display_setting.ChangeAvatar(keepBagInsID, true)
  end
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchGloves()
  data.OpenGloves = not data.OpenGloves
  if data.OpenGloves then
    local keepBagInsID = logic_display_setting.GetPutOnAvatarGlovesInsId()
    logic_display_setting.ChangeAvatar(keepBagInsID, data.OpenGloves)
  end
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchAction()
  if data.OpenAction then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.CheckHasEquipXSuit() == false then
      ShowNotice(10342)
      return
    end
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenAction = not data.OpenAction
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.RefreshActions()
  local logic_teamup_action = require("client.slua.logic.teamup.logic_teamup_action")
  logic_teamup_action.AutoChangeActionType(data.TeamUpActionType)
end
function logic_display_setting.UpdateTeamUpActionSetting(teamup_action_type)
  data.TeamUpActionType = teamup_action_type or 0
end
function logic_display_setting.UpdateMVPActionSetting(mvp_action_type)
  data.MVPActionType = mvp_action_type or 0
end
function logic_display_setting.SendChangeTeamUpActionSetting(teamup_action_type)
  if not teamup_action_type or teamup_action_type == data.TeamUpActionType then
    return
  end
  local logic_teamup_action = require("client.slua.logic.teamup.logic_teamup_action")
  if teamup_action_type == logic_teamup_action.ActionEnum.GoldenSuit then
    local WearRealGoldenSuitWithEnterAction = false
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    local avatar = TeamAvatarManager.GetMainAvatar()
    local RealGoldenSuitFeature = CDataTable.GetTable("RealGoldenSuitFeature")
    if avatar and RealGoldenSuitFeature then
      for ID, _ in pairs(RealGoldenSuitFeature) do
        if avatar:HasEquiped(ID) then
          WearRealGoldenSuitWithEnterAction = true
        end
      end
    end
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.CheckHasEquipXSuit() == false and WearRealGoldenSuitWithEnterAction == false then
      ShowNotice(62119)
      return
    end
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.TeamUpActionType = teamup_action_type
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_set_teamup_action_type_req(teamup_action_type)
end
function logic_display_setting.SendChangeMVPActionSetting(mvp_action_type)
  if not mvp_action_type or mvp_action_type == data.MVPActionType then
    return
  end
  ShowNotice(18010335)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.MVPActionType = mvp_action_type
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_set_mvp_action_type_req(mvp_action_type)
end
function logic_display_setting.SwitchGlide()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenGlide = not data.OpenGlide
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchMetroFashionArmor()
  data.HideMetroFashionArmor = not data.HideMetroFashionArmor
  log(bWriteLog and string.format("logic_display_setting.SwitchMetroFashionArmor, data.HideMetroFashionArmor:%s", data.HideMetroFashionArmor))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchLobbyMetroFashionArmor()
  data.LobbyHideMetroFashionArmor = not data.LobbyHideMetroFashionArmor
  log(bWriteLog and string.format("logic_display_setting.SwitchMetroFashionArmor, data.LobbyHideMetroFashionArmor:%s", data.LobbyHideMetroFashionArmor))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchMetroFashionBackpack()
  data.HideMetroFashionBackpack = not data.HideMetroFashionBackpack
  log(bWriteLog and string.format("logic_display_setting.SwitchMetroFashionBackpack, data.HideMetroFashionBackpack:%s", data.HideMetroFashionBackpack))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchLobbyMetroFashionBackpack()
  data.LobbyHideMetroFashionBackpack = not data.LobbyHideMetroFashionBackpack
  log(bWriteLog and string.format("logic_display_setting.SwitchLobbyMetroFashionBackpack, data.LobbyHideMetroFashionBackpack:%s", data.LobbyHideMetroFashionBackpack))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchLobbyMetroFashionHelmet()
  data.LobbyHideMetroFashionHelmet = not data.LobbyHideMetroFashionHelmet
  log(bWriteLog and string.format("logic_display_setting.SwitchLobbyMetroFashionBackpack, data.LobbyHideMetroFashionHelmet:%s", data.LobbyHideMetroFashionHelmet))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchMetroFashionHelmet()
  data.HideMetroFashionHelmet = not data.HideMetroFashionHelmet
  log(bWriteLog and string.format("logic_display_setting.SwitchLobbyMetroFashionBackpack, data.HideMetroFashionHelmet:%s", data.HideMetroFashionHelmet))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchLobbyMetroHelmet(newValue)
  newValue = newValue or not data.HideMetroHelmet
  data.HideMetroHelmet = newValue
  log(bWriteLog and string.format("logic_display_setting.SwitchLobbyMetroHelmet, data.HideMetroHelmet:%s", data.HideMetroHelmet))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchLobbyMetroBag(newValue)
  newValue = newValue or not data.HideMetroBag
  data.HideMetroBag = newValue
  log(bWriteLog and string.format("logic_display_setting.SwitchLobbyMetroBag, data.HideMetroBag:%s", data.HideMetroBag))
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchOpenUpgradeGunAttach()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenUpgradeGunAttach = not data.OpenUpgradeGunAttach
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SetAircastUsed(isUsed)
  data.OpenGlide = isUsed
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.ShowGlideBanner(isShow)
  data.ShowGlideEffectBanner = isShow
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchSocialWeaponShow()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenSocialWeapon = not data.OpenSocialWeapon
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchIdle()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenIdle = not data.OpenIdle
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.SetOpenSpeicalIdle(DataMgr.roleData.uid, data.OpenIdle)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SPECIAL_IDLE_SWITCH, not data.OpenIdle)
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchEnterPlayVoice()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.OpenEnterPlayVoice = not data.OpenEnterPlayVoice
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.RefreshAvatar()
  log(bWriteLog and "logic_display_setting.RefreshAvatar")
  if not data.OpenHelmet then
    local keepHelmetInsID = logic_display_setting.GetPutOnAvatarHelmetInsId()
    logic_display_setting.ChangeAvatar(keepHelmetInsID, false)
  end
  if not data.OpenBag then
    local keepBagInsID = logic_display_setting.GetPutOnAvatarBagInsId()
    logic_display_setting.ChangeAvatar(keepBagInsID, false)
  end
  if not data.OpenGloves then
    local keepGlovesInsID = logic_display_setting.GetPutOnAvatarGlovesInsId()
    logic_display_setting.ChangeAvatar(keepGlovesInsID, false)
  end
  logic_display_setting.RefreshGun()
end
function logic_display_setting.RefreshGun()
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  logic_wardrobe_gun:RevertGun(data.OpenGun)
end
function logic_display_setting.IsOpenHelmet()
  return data.OpenHelmet
end
function logic_display_setting.SwitchFightHelmet()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.HideFightHelmet = not data.HideFightHelmet
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchLobbyVoice()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.LobbyPerformanceVoice = not data.LobbyPerformanceVoice
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SwitchFightVoice()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.logic_display_setting) then
    return false
  end
  data.GamePerformanceVoice = not data.GamePerformanceVoice
  logic_display_setting.SendDepotShowSettings()
end
function logic_display_setting.SyncSettingConfig()
  local   local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  if settingConfig.LocalHideHelmet ~= nil then
    settingConfig.LocalHideHelmet = data.HideFightHelmet
  end
  if settingConfig.LocalHideMetroArmor ~= nil then
    settingConfig.LocalHideMetroArmor = data.HideMetroFashionArmor
  end
  if settingConfig.LocalHideMetroBackpack ~= nil then
    settingConfig.LocalHideMetroBackpack = data.HideMetroFashionBackpack
  end
  if settingConfig.LocalHideMetroHelmet ~= nil then
    settingConfig.LocalHideMetroHelmet = data.HideMetroFashionHelmet
  end
  if settingConfig.LocalGamePerformanceVoice ~= nil then
    settingConfig.LocalGamePerformanceVoice = data.GamePerformanceVoice
  end
  log(bWriteLog and string.format("FinishModifyUserSettings aaaaaaaaaaaaaa"))
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function logic_display_setting.SyncLobbyMetroFashionArmor()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission(true) then
    return
  end
  local LogicTxMissionTeam = require("client.slua.logic.TxMission.logic_xmission_team")
  LogicTxMissionTeam.UpdateAvatar(DataMgr.roleData.uid)
end
function logic_display_setting.IsOpenLobbyHandDisplay()
  if LobbySystem.roleData then
    local depot_show_info = LobbySystem.roleData.depot_show_info or {}
    if depot_show_info.hand then
      return true
    end
  end
  return false
end
return logic_display_setting