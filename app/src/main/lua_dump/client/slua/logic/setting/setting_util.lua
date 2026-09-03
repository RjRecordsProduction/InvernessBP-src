local setting_util = {
  UseNewSetting = false,
  KRJPDelAccountSwitch = false,
  KRJPDelAccountLeftTime = 0
}
local SDefaultRedPath = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/T_icon_hongdian_png.T_icon_hongdian_png"
local SNewRedPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Image_NEW3_png.Common_Image_NEW3_png"
local BAutoBind, BScrollToEnd, SOepnCustomServiceSceneId
function setting_util.SetAutoBind(value)
  BAutoBind = value
end
function setting_util.GetAutoBind()
  return BAutoBind
end
function setting_util.SetScrollToEnd(value)
  BScrollToEnd = value
end
function setting_util.GetScrollToEnd()
  return BScrollToEnd
end
function setting_util.SetOepnCustomServiceSceneId(value)
  SOepnCustomServiceSceneId = value
end
function setting_util.GetOepnCustomServiceSceneId()
  return SOepnCustomServiceSceneId
end
function setting_util.JumpBindMail()
  setting_util.Enter("Account")
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local mailInfo = SettingAccount.GetSettingAccountData()
  if mailInfo.bind_mail then
    return
  end
  local setting_macro = require("client.slua.logic.setting.setting_macro")
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  local bIsExtraBind = logic_account_sensitive_aciton:CheckbIsExtraBind()
  local opType = bIsExtraBind and setting_macro.AccountNewOperationType.ExtraBindMail or setting_macro.AccountNewOperationType.FirstBindMail
  logic_account_sensitive_aciton:ShowCommonPopupUI(opType)
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.NBindExtType = 1
end
function setting_util.JumpUrl(_, _, vars)
  log_tree("  : vars", vars)
  local SettingMacro = require("client.slua.logic.setting.setting_macro")
  local page = vars and tonumber(vars.page)
  local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
  local SettingJumpEnum = {
    [5] = SettingPageDefine.Sens.Key,
    [6] = SettingPageDefine.Pickup.Key,
    [10] = SettingPageDefine.LanguageAndNet.Key,
    [13] = SettingPageDefine.TV.Key,
    [16] = SettingPageDefine.VFX.Key,
    [17] = SettingPageDefine.Other.Key,
    [20] = SettingPageDefine.Account.Key,
    [21] = SettingPageDefine.PrivacyAndSocial.Key,
    [22] = SettingPageDefine.Graphic.Key,
    [23] = SettingPageDefine.Audio.Key,
    [24] = SettingPageDefine.CustomLayout.Key,
    [25] = SettingPageDefine.Notif.Key
  }
  if page then
    page = SettingJumpEnum[page]
  else
    page = vars and vars.page
  end
  if vars then
    if vars.source == "bindfacebook" then
      page = "Account"
      BAutoBind = true
    elseif vars.source == "protectsetting" then
      page = "Account"
      BScrollToEnd = true
      if vars.sceneid then
        SOepnCustomServiceSceneId = vars.sceneid
      end
    end
  end
  setting_util.Enter(page)
end
function setting_util.Enter(page, params)
  log(bWriteLog and "  : page" .. tostring(page))
  local UI = UIManager.GetUI(UIManager.UI_Config.setting_main)
  if UI then
    UI:SwitchPage(page, params)
  else
    local LobbySettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    UI = UIManager.ShowUI(UIManager.UI_Config.setting_main, LobbySettingCatalog, page, params)
  end
  ClientSendBAReport(TLogEventDefine.LobbySettings, 0)
end
function setting_util.GetRedPointPath(isNew)
  if isNew then
    return SNewRedPath
  end
  return SDefaultRedPath
end
function setting_util.CloseSetting()
  UIManager.CloseUI(UIManager.UI_Config.setting_main)
end
function setting_util.GetSettingConfig()
  local game_frontend_hud = require("game_frontend_hud")
  local gameFrontendHUDInst = game_frontend_hud.GetInstance()
  return gameFrontendHUDInst:GetUserSettings()
end
function setting_util.GetGameInstance()
  local GameInstClass = import("STExtraGameInstance")
  return GameInstClass.GetInstance()
end
function setting_util.GetGameFrontendHUD()
  local game_frontend_hud = require("game_frontend_hud")
  return game_frontend_hud.GetInstance()
end
function setting_util.GetPlayerController()
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local PlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  return PlayerController
end
function setting_util.GetGameState()
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local GameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  return GameState
end
function setting_util.GetThemeModeMapId()
  local nCurGameModeID = Client.GetGameModeID(GameFrontendHUD)
  if not nCurGameModeID then
    return
  end
  local uObj_modeCfg = CDataTable.GetTableData("BTMode", nCurGameModeID)
  if uObj_modeCfg and uObj_modeCfg.BattleModeFightType == 1 then
    return uObj_modeCfg.MapID
  end
end
local OnlyFriendJudge = {
  open = 1,
  close = 2,
  onlyFriend = 3
}
local ReturnType = {boolType = 1, numberType = 2}
function setting_util.OnlyFriend(uid, judge, type)
  if not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    log(bWriteLog and "setting_util.OnlyFriend not BP_ENUM_ONLY_FRIENFRIEND_PRIVACY judge:" .. tostring(judge))
    return judge
  end
  log(bWriteLog and "setting_util.OnlyFriend judge:" .. tostring(judge) .. " type:" .. tostring(type))
  if judge and judge ~= OnlyFriendJudge.close then
    if type == ReturnType.boolType then
      if judge == OnlyFriendJudge.open or judge == true then
        return true
      else
        return false
      end
    elseif type == ReturnType.numberType then
      if judge == OnlyFriendJudge.open or judge == true then
        return 1
      else
        return 0
      end
    end
  else
    if not judge then
      if type == ReturnType.boolType then
        return false
      else
        return 0
      end
    end
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    log(bWriteLog and "setting_util.OnlyFriend LogicFriend.IsMyFriend:" .. tostring(LogicFriend.IsMyFriend(uid)))
    if LogicFriend.IsMyFriend(uid) or tonumber(DataMgr.roleData.uid) == tonumber(uid) then
      if type == ReturnType.boolType then
        return true
      else
        return 1
      end
    elseif type == ReturnType.boolType then
      return false
    else
      return 0
    end
  end
end
return setting_util