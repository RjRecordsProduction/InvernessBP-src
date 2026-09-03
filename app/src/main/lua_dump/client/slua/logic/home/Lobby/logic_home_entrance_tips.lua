local logic_home_entrance_tips = {}
local typeInfoMap = {
  [27] = {
    iconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Home/Anniversary/First/Home_Anniversary_1th_Icon_Text.Home_Anniversary_1th_Icon_Text",
    title = "###Anniversary",
    jumpLink = "game://?module=1002306"
  },
  [24] = {
    iconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Home/Anniversary/First/Home_Anniversary_1th_Image_MiddlePoster_03.Home_Anniversary_1th_Image_MiddlePoster_03",
    title = "###SecretMerchant",
    jumpLink = "game://?module=1002309"
  },
  [14] = {
    iconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Home/AnniversaryActivity/Home_AnniversaryActivity_Title.Home_AnniversaryActivity_Title",
    title = "###HomeStore",
    jumpLink = "game://?module=1002514&Tab1=1&Tab2=1002"
  },
  [30] = {
    iconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Home/AnniversaryActivity/Home_AnniversaryActivity_Tips_Icon.Home_AnniversaryActivity_Tips_Icon",
    title = "###SelectFormThree",
    jumpLink = "game://?module=1002306"
  }
}
function logic_home_entrance_tips.ProcClickTips(type)
  log_format(bWriteLog and "logic_home_entrance_tips.ProcClickTips - type:%s", type)
  local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
  if type == logic_lobby_home_entry_item.eRedDotModule.HomeStoreAward or type == logic_lobby_home_entry_item.eRedDotModule.ManorMysteryNotify then
    local logic_lobby_home_entrance_tips_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entrance_tips_File")
    local fileTb = logic_lobby_home_entrance_tips_File.LoadFile()
    fileTb.show_info[type] = true
    logic_lobby_home_entrance_tips_File.SaveFile(fileTb)
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRANCE_TIPS_ITEM_UPDATE)
end
function logic_home_entrance_tips.GetTipsInfo(uid)
  log(bWriteLog and "logic_home_entrance_tips.GetTipsInfo", uid)
  uid = uid or 0
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(false) then
    log(bWriteLog and "logic_home_entrance_red_dot.GetShowInfo limit")
    return
  end
  local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
  local logic_lobby_home_entrance_tips_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entrance_tips_File")
  local fileTb = logic_lobby_home_entrance_tips_File.LoadFile()
  local curType = logic_lobby_home_entry_item.eRedDotModule.None
  curType = logic_lobby_home_entry_item.eRedDotModule.homePkRedDot
  if logic_home_entrance_tips.CheckHomePKTips(uid) then
    return curType
  end
  curType = logic_lobby_home_entry_item.eRedDotModule.HomeAnniversaryTips
  if logic_home_entrance_tips.CheckAnniversaryTips() then
    return curType
  end
  curType = logic_lobby_home_entry_item.eRedDotModule.GetOneFromThree
  if logic_home_entrance_tips.CheckGetOneFromThreeTips() then
    return curType
  end
  curType = logic_lobby_home_entry_item.eRedDotModule.HomeStoreAward
  local hasClick = fileTb.show_info[curType]
  if not hasClick and logic_home_entrance_tips.CheckHomeShopUpdateTips() then
    return curType
  end
  curType = logic_lobby_home_entry_item.eRedDotModule.ManorMysteryNotify
  hasClick = fileTb.show_info[curType]
  if not hasClick then
    if logic_home_entrance_tips.CheckManorMysteryTips() then
      return curType
    end
  else
    log(bWriteLog and "logic_home_entrance_tips.GetTipsInfo ManorMysteryNotify hasClick")
  end
end
function logic_home_entrance_tips.GetTipsConfig(Type)
  log(bWriteLog and "logic_home_entrance_tips.GetTipsConfig - type:%s", Type)
  if not Type or type(Type) ~= "number" then
    log_error_format(bWriteLog and "logic_home_entrance_tips.GetTipsConfig - Invalid Type parameter")
    return nil
  end
  local cfg = CDataTable.GetTableData("PlanPH_Bubble_Text", Type)
  if cfg and cfg.EntranceTipsIconPath then
    local data = {
      iconPath = cfg.EntranceTipsIconPath,
      title = LocUtil.GetLocalizeResStr(cfg.EntranceTipsTitleID),
      jumpLink = cfg.EntranceTipsJumpLink
    }
    return data
  else
    log_error_format(bWriteLog and "logic_home_entrance_tips.GetTipsConfig - type:%s not found use temp info", Type)
  end
end
function logic_home_entrance_tips.CheckManorMysteryTips()
  local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
  log(bWriteLog and "logic_home_entrance_tips.CheckManorMysteryTips ", logic_lobby_home_entry_item.manorMysteryNotify)
  if logic_lobby_home_entry_item.manorMysteryNotify then
    return true
  else
    return false
  end
end
function logic_home_entrance_tips.CheckAnniversaryTips()
  log(bWriteLog and "logic_home_entrance_tips.CheckAnniversaryTips")
  local logic_home_anniversary_activity = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_anniversary_activity)
  if logic_home_anniversary_activity:IsActivityOpen() then
    return true
  else
    return false
  end
end
function logic_home_entrance_tips.CheckGetOneFromThreeTips()
  log(bWriteLog and "logic_home_entrance_tips.CheckGetOneFromThreeTips")
  local logic_home_theme = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_theme)
  if logic_home_theme:GetCurrentConfig(true) and logic_home_theme:NotGetOneFromThree() then
    return true
  end
  return false
end
function logic_home_entrance_tips.CheckHomeShopUpdateTips()
  log(bWriteLog and "logic_home_entrance_tips.CheckHomeShopUpdateTips")
  local logic_lobby_home_entry_item_HomeStore_Award = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_HomeStore_Award")
  local info = logic_lobby_home_entry_item_HomeStore_Award.GetShowInfo()
  if info.bShow then
    return true
  else
    return false
  end
end
function logic_home_entrance_tips.CheckHomePKTips(uid)
  log(bWriteLog and "logic_home_entrance_tips.CheckHomePKTips")
  if not uid then
    log(bWriteLog and "logic_home_entrance_tips.CheckHomePKTips, uid is nil")
    return false
  end
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
  local actState = logic_popular_home_pk_util.GetActState()
  if actState == PopularHomePKMacros.ENUM_STATE.CLOSE then
    log(bWriteLog and "logic_home_entrance_tips:CheckHomePKTips, act is close")
    return false
  end
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  if not logic_popular_home_pk:IsHomePkDataValid(tonumber(uid), 2) then
    logic_popular_home_pk:RequestGetHomePKData(tonumber(uid))
    log(bWriteLog and "logic_home_entrance_tips:CheckHomePKTips not valid pk data ")
    return false
  end
  local playerActState = logic_popular_home_pk_util.GetPlayerActState(uid)
  if playerActState ~= PopularHomePKMacros.ENUM_PLAYER_STATE.PK then
    log(bWriteLog and "logic_home_entrance_tips:CheckHomePKTips, player act state is not PK")
    return false
  end
  if not logic_popular_home_pk_util:IsInCurrentRoundPKTime() then
    log(bWriteLog and "logic_home_entrance_tips:CheckHomePKTips not self, actState is not PK")
    return false
  end
  if not logic_popular_home_pk:CanShowTipsEntry(tonumber(uid)) then
    log(bWriteLog and "logic_home_entrance_tips:CheckHomePKTips can not show tips")
    return false
  end
  return true
end
return logic_home_entrance_tips