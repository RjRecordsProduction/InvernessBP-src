local StarterPackSystem = {
  lastLogoutTime = nil,
  PurchaseStatus = {NONE = 0, ALREADY = 1},
  DirectPurchaseInfoDefine = {
    configPrice = "",
    productPriceDesc = "",
    actEndTime = 0,
    CentauriProductId = 0,
    CentauriPrice = "",
    CentauriCountry = "",
    CentauriCurrency = "",
    CentauriCurrencyUnit = "",
    CentauriPayItem = 1,
    rewardItems = {},
    discount = 1,
    item_id = 0,
    awards_uc_num = 0
  },
  PurchaseTriggerUI = {
    NONE = 0,
    POPWINDOW = 1,
    CAROUSEL = 2,
    UCSTORE = 3,
    FINAL_POPWINDOW = 4
  }
}
StarterPackSystem.StaticEnabled = true
StarterPackSystem.Enabled = true
StarterPackSystem.ServerEnabled = false
StarterPackSystem.IsCouldPurchase = false
StarterPackSystem.IsCouldPurchaseEffectiveTime = 0
StarterPackSystem.CurPurchaseStatus = StarterPackSystem.PurchaseStatus.NONE
StarterPackSystem.IsWaiting = false
StarterPackSystem.IsAlreadyReqOpenDirectPurchase = false
StarterPackSystem.IsValidDirectPurchasePackItem = false
StarterPackSystem.IsValidCentauriDirectPurchasePack = false
StarterPackSystem.DirectPurchaseItemID = 0
local TableUtil = require("common.table_util")
StarterPackSystem.DirectPurchaseInfo = TableUtil.CopyTable(StarterPackSystem.DirectPurchaseInfoDefine)
StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE
StarterPackSystem.IsDirectPurchaseCentauriReq = false
StarterPackSystem.bStarterPackUnlocked = false
StarterPackSystem.fStarterpack_UnlockTime = 0
StarterPackSystem.fStarterPackValidPeriod = 0
StarterPackSystem.sStarterPack_RemainingTime = ""
StarterPackSystem.fStarterPack_LastUpdateFromServerTime = 0
StarterPackSystem.bForceUpdate = false
StarterPackSystem.bForceUpdatePurchaseInf = false
StarterPackSystem.iLimitedPopupCount = 0
StarterPackSystem.iCurrentPopupCount = 0
StarterPackSystem.iLastLoginTime = 0
StarterPackSystem.iStarterPackDirectPurchaseId = 0
StarterPackSystem.bShowStarterPackUI = false
StarterPackSystem.bShowStarterPackUnlockUI = false
StarterPackSystem.bShowFinalOfferUI = false
StarterPackSystem.bShowedFinalOfferServer = false
StarterPackSystem.CloseFinaUICB = nil
StarterPackSystem.EnablePermanent = false
StarterPackSystem.UpdateTimer = nil
StarterPackSystem.TelemetryFileName = "SaveGames/starterP"
StarterPackSystem.DownloadedImage_Path = ""
StarterPackSystem.DownloadedImage_UCStore = ""
StarterPackSystem.DownloadedImage_PopUp_A = ""
StarterPackSystem.DownloadedImage_PopUp_B = ""
StarterPackSystem.DownloadedImage_PopUp_FO_A = ""
StarterPackSystem.DownloadedImage_PopUp_FO_B = ""
StarterPackSystem.DownloadedImage_PopUp_Unlocked_A = ""
StarterPackSystem.DownloadedImage_PopUp_Unlocked_B = ""
StarterPackSystem.DownloadedImage_UCStore_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_storepanel_default.starterpack_storepanel_default"
StarterPackSystem.DownloadedImage_PopUp_A_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_popup_default_a.starterpack_popup_default_a"
StarterPackSystem.DownloadedImage_PopUp_B_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_popup_default_b.starterpack_popup_default_b"
StarterPackSystem.DownloadedImage_PopUp_FO_A_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_popup_default_a.starterpack_popup_default_a"
StarterPackSystem.DownloadedImage_PopUp_FO_B_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_popup_default_b.starterpack_popup_default_b"
StarterPackSystem.DownloadedImage_PopUp_Unlocked_A_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_popup_default_a.starterpack_popup_default_a"
StarterPackSystem.DownloadedImage_PopUp_Unlocked_B_Default = "/Game/UMG/Texture/Lobby_NoAtlas/StarterPack/starterpack_popup_default_b.starterpack_popup_default_b"
function StarterPackSystem.Init()
  if StarterPackSystem.StaticEnabled == false then
    return
  end
  if StarterPackSystem.Enabled == false then
    return
  end
  log(bWriteLog and "StarterPackSystem.Init()")
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, StarterPackSystem.OnLogin)
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, StarterPackSystem.OnLogout)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, StarterPackSystem.OnGameStateChange)
  EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED, StarterPackSystem.OnIsOpenChanged)
end
function StarterPackSystem.SetLastLoginTime(time)
  StarterPackSystem.lastLogoutTime = time
  log_warning(bWriteLog and "  :SetLastLoginTime time: " .. tostring(time))
end
function StarterPackSystem.OnLogin()
  log(bWriteLog and "StarterPackSystem.OnLogin")
  log(bWriteLog and "StarterPackSystem OnLogin. " .. tostring(StarterPackSystem.IsOpen()))
end
function StarterPackSystem.OnLogout()
  log(bWriteLog and "StarterPackSystem.OnLogout")
  StarterPackSystem.Enabled = true
  StarterPackSystem.IsCouldPurchase = false
  StarterPackSystem.IsCouldPurchaseEffectiveTime = 0
  StarterPackSystem.CurPurchaseStatus = StarterPackSystem.PurchaseStatus.NONE
  StarterPackSystem.IsWaiting = false
  StarterPackSystem.IsAlreadyReqOpenDirectPurchase = false
  StarterPackSystem.IsValidDirectPurchasePackItem = false
  StarterPackSystem.IsValidCentauriDirectPurchasePack = false
  StarterPackSystem.DirectPurchaseItemID = 0
  StarterPackSystem.DirectPurchaseInfo = TableUtil.CopyTable(StarterPackSystem.DirectPurchaseInfoDefine)
  StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE
  StarterPackSystem.bStarterPackUnlocked = false
  StarterPackSystem.fStarterpack_UnlockTime = 0
  StarterPackSystem.fStarterPackValidPeriod = 0
  StarterPackSystem.sStarterPack_RemainingTime = ""
  StarterPackSystem.fStarterPack_LastUpdateFromServerTime = 0
  StarterPackSystem.iLimitedPopupCount = 0
  StarterPackSystem.iCurrentPopupCount = 0
  StarterPackSystem.iLastLoginTime = 0
  StarterPackSystem.iStarterPackDirectPurchaseId = 0
  StarterPackSystem.bShowStarterPackUI = false
  StarterPackSystem.bShowStarterPackUnlockUI = false
  StarterPackSystem.bShowFinalOfferUI = false
  StarterPackSystem.bShowedFinalOfferServer = false
  StarterPackSystem.EnablePermanent = false
  StarterPackSystem.DownloadedImage_Path = ""
  StarterPackSystem.DownloadedImage_UCStore = ""
  StarterPackSystem.DownloadedImage_PopUp_A = ""
  StarterPackSystem.DownloadedImage_PopUp_B = ""
  StarterPackSystem.DownloadedImage_PopUp_FO_A = ""
  StarterPackSystem.DownloadedImage_PopUp_FO_B = ""
  StarterPackSystem.DownloadedImage_PopUp_Unlocked_A = ""
  StarterPackSystem.DownloadedImage_PopUp_Unlocked_B = ""
  StarterPackSystem.CloseDirectPurchase()
end
function StarterPackSystem.OnGameStateChange(eventType, eventID, vars)
  log(bWriteLog and "StarterPackSystem.OnGameStateChange  " .. vars.current .. "  " .. vars.pre)
  if StarterPackSystem.StaticEnabled == false then
    return
  end
  if StarterPackSystem.Enabled == false then
    return
  end
  if StarterPackSystem.bStarterPackUnlocked == false then
    return
  end
  log(bWriteLog and "StarterPackSystem.OnGameStateChange  StarterPackSystem.Enabled" .. tostring(StarterPackSystem.Enabled))
  if vars.current == GameStatus.Lobby then
    log(bWriteLog and "Start StarterPackSystem timer for purchase countdown")
    StarterPackSystem.bForceUpdate = true
    StarterPackSystem.StartCountDown(1)
  elseif vars.current == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "stop StarterPackSystem timer for purchase countdown")
    StarterPackSystem.StopCountDown()
  end
  if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Fighting and StarterPackSystem.bShowStarterPackUnlockUI == true then
    StarterPackSystem.SetIsCouldPurchase(true)
    if StarterPackSystem.iStarterPackDirectPurchaseId == nil or StarterPackSystem.iStarterPackDirectPurchaseId == 0 then
      StarterPackSystem.bForceUpdatePurchaseInf = true
    else
      StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
    end
    log(bWriteLog and "on OnGameStateChange trying to OpenUnlockStarterPackPanel")
    StarterPackSystem.OpenUnlockStarterPackPanel()
    StarterPackSystem.bShowStarterPackUnlockUI = false
  end
end
function StarterPackSystem.GM_Command_OpenPurchase()
  log(bWriteLog and "StarterPackSystem.GM_Command_OpenPurchase()")
  StarterPackSystem.UpdateDateFromServer()
  StarterPackSystem.SetIsCouldPurchase(true)
  StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
end
function StarterPackSystem.GM_Command_ClosePurchase()
  log(bWriteLog and "StarterPackSystem.GM_Command_ClosePurchase()")
  StarterPackSystem.EndPurchase()
end
function StarterPackSystem.EndPurchase()
  log(bWriteLog and "StarterPackSystem.EndPurchase()")
  if StarterPackSystem.IsDirectPurchaseCentauriReq == true then
    StarterPackSystem.ReportPurchaseLog()
  end
  StarterPackSystem.iStarterPackDirectPurchaseId = 0
  StarterPackSystem.SetIsCouldPurchase(false)
end
function StarterPackSystem.SetIsCouldPurchase(isCouldPurchase)
  log(bWriteLog and "StarterPackSystem.SetIsCouldPurchase," .. tostring(isCouldPurchase))
  StarterPackSystem.IsCouldPurchase = isCouldPurchase
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED)
end
function StarterPackSystem.ReqOpenDirectPurchase(directPurchaseItemID)
  log(bWriteLog and "StarterPackSystem.ReqOpenDirectPurchase, id = " .. tostring(directPurchaseItemID))
  if not StarterPackSystem.IsCouldPurchase or directPurchaseItemID == nil or directPurchaseItemID == 0 then
    return
  end
  StarterPackSystem.DirectPurchaseItemID = directPurchaseItemID
  if StarterPackSystem.IsDirectPurchaseInfoValid() == true and StarterPackSystem.IsAlreadyReqOpenDirectPurchase == true then
    return
  end
  EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO_ERROR, StarterPackSystem.GetDirectPurchaseInfoRspError)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, StarterPackSystem.GetCentauriGoodsInfoRsp)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, StarterPackSystem.GetCentauriGoodsInfoRsp)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_BUY_GOODS_NOTIFY, StarterPackSystem.DirectPurchaseCentauriRsp)
  StarterPackSystem.IsAlreadyReqOpenDirectPurchase = true
  StarterPackSystem.GetDirectBuyInfoReq()
end
function StarterPackSystem.CloseDirectPurchase()
  log(bWriteLog and "StarterPackSystem.CloseDirectPurchase")
  StarterPackSystem.IsCouldPurchase = false
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_OLOSE)
  EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO_ERROR, StarterPackSystem.GetDirectPurchaseInfoRspError)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, StarterPackSystem.GetCentauriGoodsInfoRsp)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, StarterPackSystem.GetCentauriGoodsInfoRsp)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_BUY_GOODS_NOTIFY, StarterPackSystem.DirectPurchaseCentauriRsp)
end
function StarterPackSystem.StartDirectPurchase()
  log(bWriteLog and "StarterPackSystem.StartDirectPurchase")
  if StarterPackSystem.IsOpen() then
    StarterPackSystem.DirectPurchaseCentauriReq()
  end
end
function StarterPackSystem.LogicStart()
  log(bWriteLog and "Start StarterPackSystem logic")
  StarterPackSystem.UpdateDateFromServer()
  StarterPackSystem.InitStatusOnStartup()
  if GameStatus.IsInLobbyOrMainCity() then
    StarterPackSystem.StartCountDown(1)
  end
end
function StarterPackSystem.LogicStop()
  log(bWriteLog and "Stop StarterPackSystem logic")
  StarterPackSystem.bStarterPackUnlocked = false
  StarterPackSystem.EndPurchase()
  StarterPackSystem.StopCountDown()
end
function StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(msg)
  log(bWriteLog and "StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData ," .. tostring(msg))
  local str = json.encode(msg)
  local fileName = "StarterP"
  local fullFileName = string.format("SaveGames/%s.sav", fileName)
  Client.SaveStringToFile(str, fullFileName)
end
function StarterPackSystem.LoadStarterPackUIShowOffCountBySaveData()
  log(bWriteLog and "StarterPackSystem.LoadStarterPackUIShowOffCountBySaveData")
  local fileName = "StarterP"
  local fullFileName = string.format("SaveGames/%s.sav", fileName)
  local str = Client.LoadFileToString(fullFileName)
  if str == nil or str == "" then
    return nil
  end
  local data = json.decode(str)
  StarterPackSystem.iCurrentPopupCount = tonumber(data)
  log(bWriteLog and "StarterPackSystem. load data: " .. data)
end
function StarterPackSystem.InitLastlogin(lastlogin)
  if StarterPackSystem.StaticEnabled == false then
    return
  end
  if StarterPackSystem.Enabled == false then
    return
  end
  log(bWriteLog and "StarterPackSystem.InitLastlogin")
  log(bWriteLog and "Init Last Login time " .. tostring(lastlogin))
  if StarterPackSystem.iLastLoginTime ~= nil and StarterPackSystem.iLastLoginTime > 0 then
    log(bWriteLog and "Since we already had a last login time, so won't set it this time")
    return
  end
  StarterPackSystem.iLastLoginTime = lastlogin
end
function StarterPackSystem.shouldRemindFinalOffer()
  if StarterPackSystem.bStarterPackUnlocked == false then
    return false
  end
  return StarterPackSystem.bShowFinalOfferUI
end
function StarterPackSystem.shouldRemindStarterpack()
  if StarterPackSystem.bStarterPackUnlocked == false then
    return false
  end
  return StarterPackSystem.bShowStarterPackUI
end
function StarterPackSystem.OpenUnlockStarterPackPanel()
  log(bWriteLog and "UnlockStarterPackSystem.OpenUnlockStarterPackPanel")
  if UIManager then
    StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.POPWINDOW, true)
    UIManager.ShowUI(UIManager.UI_Config.starterpack_unlock_panel)
  end
end
function StarterPackSystem.CloseStarterFinalOfferUI()
  return
end
function StarterPackSystem.OpenStarterPackFinalOfferUI(cb)
  log(bWriteLog and "StarterPackSystem.OpenStarterPackFinalOfferUI")
  if cb ~= nil then
    StarterPackSystem.CloseFinaUICB = cb
    log(bWriteLog and "set starterpack final offer close cb")
  end
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.starterpack_finaloffer_panel)
  end
end
function StarterPackSystem.InitStatusOnStartup()
  log(bWriteLog and "StarterPackSystem.InitStatusOnStartup")
  if StarterPackSystem.bStarterPackUnlocked == false then
    return false
  end
  StarterPackSystem.LoadStarterPackUIShowOffCountBySaveData()
  log(bWriteLog and "Limit popup Count: " .. tostring(StarterPackSystem.iLimitedPopupCount) .. "   current count:  " .. tostring(StarterPackSystem.iCurrentPopupCount))
  if not StarterPackSystem.lastLogoutTime == nil or StarterPackSystem.lastLogoutTime == 0 or not StarterPackSystem.iLastLoginTime then
    log(bWriteLog and "clean local save data for new user")
    StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(0)
    if StarterPackSystem.iLastLoginTime == nil then
      StarterPackSystem.iLastLoginTime = 0
    end
  end
  local TimeUtil = require("client.common.time_util")
  local ServerTime = TimeUtil.GetServerTimeInSec()
  local ExpiredTime = StarterPackSystem.fStarterpack_UnlockTime + StarterPackSystem.fStarterPackValidPeriod
  log(bWriteLog and "Last login Time" .. tostring(StarterPackSystem.iLastLoginTime))
  log(bWriteLog and "last Logout Time: " .. StarterPackSystem.lastLogoutTime)
  log(bWriteLog and "Unlock Time: " .. StarterPackSystem.fStarterpack_UnlockTime .. " and Now time: " .. ServerTime .. "  valid period " .. StarterPackSystem.fStarterPackValidPeriod)
  log(bWriteLog and "Starterpack Expired time : " .. ExpiredTime)
  if ServerTime > ExpiredTime and StarterPackSystem.EnablePermanent == false then
    if StarterPackSystem.bShowStarterPackUI == true or StarterPackSystem.bShowFinalOfferUI == true then
      return false
    end
    log(bWriteLog and "on shouldRemind Final Offer, final offer alread expired")
    local LastLoginTime = StarterPackSystem.lastLogoutTime
    if DataMgr.roleData ~= nil and DataMgr.roleData.old_last_login_time ~= nil then
      LastLoginTime = DataMgr.roleData.old_last_login_time
      StarterPackSystem.i    end
    if StarterPackSystem.iLastLoginTime == 0 then
      log(bWriteLog and "Get last ShowStarterPackUi time 0, then use last logout time instead")
      StarterPackSystem.iLastLoginTime = StarterPackSystem.lastLogoutTime
    end
    local LastLoginSinceUnlock = StarterPackSystem.iLastLoginTime - StarterPackSystem.fStarterpack_UnlockTime
    if LastLoginSinceUnlock < StarterPackSystem.fStarterPackValidPeriod then
      log(bWriteLog and "here shouldRemindFinalOffer")
      StarterPackSystem.bShowFinalOfferUI = true
      StarterPackSystem.SetIsCouldPurchase(true)
      StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
    else
      log(bWriteLog and "StarterPack disable and stop count down for offer already expired for already showed final offer")
      StarterPackSystem.LogicStop()
    end
  else
    StarterPackSystem.SetIsCouldPurchase(true)
    StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
    StarterPackSystem.bShowStarterPackUI = true
    if StarterPackSystem.iLimitedPopupCount > 0 and StarterPackSystem.iLimitedPopupCount <= StarterPackSystem.iCurrentPopupCount then
      StarterPackSystem.bShowStarterPackUI = false
    end
  end
  return false
end
function StarterPackSystem.UpdateDateFromServer()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByType(ActivityType.STARTER_PACK_US)
  if actData == nil or actData.List[1] == nil or actData.List[1].Status == nil then
    return false
  end
  if actData.List[1].Status == 1 then
    log_tree("On StarterPackSystem::UpdateDateFromServer, Get Server Data: ", actData)
    StarterPackSystem.bStarterPackUnlocked = true
    if actData.other ~= nil and actData.other.starter_pack_unlock_time ~= nil then
      StarterPackSystem.fStarterpack_UnlockTime = actData.other.starter_pack_unlock_time
    else
      local TimeUtil = require("client.common.time_util")
      StarterPackSystem.fStarterpack_UnlockTime = TimeUtil.GetServerTimeInSec()
    end
    local StringUtil = require("common.string_util")
    if actData.Condition ~= nil then
      local extraInf = actData.Condition
      local msgArr = StringUtil.Split(extraInf, ",")
      if msgArr == nil or #msgArr < 4 then
        log(bWriteLog and "try to decode server extra info failed")
        StarterPackSystem.fStarterPackValidPeriod = 259200
      else
        log(bWriteLog and "Get array from server\239\188\140 length : " .. #msgArr .. " value: " .. msgArr[1] .. msgArr[2] .. msgArr[3] .. msgArr[4])
        StarterPackSystem.fStarterPackValidPeriod = tonumber(msgArr[3]) * 60
        StarterPackSystem.iLimitedPopupCount = tonumber(msgArr[4])
        log(bWriteLog and "fStarterPackValidPeriod  " .. tostring(StarterPackSystem.fStarterPackValidPeriod))
        log(bWriteLog and "iLimitedPopupCount  " .. tostring(StarterPackSystem.iLimitedPopupCount))
        if StarterPackSystem.iLimitedPopupCount > 0 then
          StarterPackSystem.EnablePermanent = true
          log(bWriteLog and "Set Starter Pack permanent on")
        else
          StarterPackSystem.EnablePermanent = false
          log(bWriteLog and "Set Starter Pack permanent off")
        end
      end
    end
    StarterPackSystem.iStarterPackDirectPurchaseId = actData.List[1].Drop[1].itemId
    log(bWriteLog and "on Update data from serve get direct purchase Id: " .. tostring(StarterPackSystem.iStarterPackDirectPurchaseId))
    StarterPackSystem.bForceUpdate = false
    StarterPackSystem.generateDownloadedImage(tostring(actData.ImgUrl))
  else
    StarterPackSystem.bStarterPackUnlocked = false
    StarterPackSystem.bForceUpdate = false
  end
  return true
end
function StarterPackSystem.generateDownloadedImage(img_url)
  log(bWriteLog and "StarterPackSystem.generateDownloadedImage" .. tostring(img_url))
  StarterPackSystem.DownloadedImage_Path = ""
  StarterPackSystem.DownloadedImage_UCStore = ""
  StarterPackSystem.DownloadedImage_PopUp_A = ""
  StarterPackSystem.DownloadedImage_PopUp_B = ""
  StarterPackSystem.DownloadedImage_PopUp_FO_A = ""
  StarterPackSystem.DownloadedImage_PopUp_FO_B = ""
  StarterPackSystem.DownloadedImage_PopUp_Unlocked_A = ""
  StarterPackSystem.DownloadedImage_PopUp_Unlocked_B = ""
  if img_url == nil or img_url == "" then
    return
  end
  local util = require("client.slua_ui_framework.util")
  if util.IsOnlineImageUrl(img_url) then
    local suffix = ""
    if string.find(img_url, "localize") then
      local lan = Client.GetCurrentLanguage()
      suffix = tostring("_") .. tostring(lan)
    end
    if string.find(img_url, "jpg") then
      suffix = tostring(suffix) .. tostring(".jpg")
    else
      suffix = tostring(suffix) .. tostring(".png")
    end
    log(bWriteLog and "StarterPackSystem.generateDownloadedImage : suffix:" .. tostring(suffix))
    StarterPackSystem.DownloadedImage_Path = img_url
    StarterPackSystem.DownloadedImage_UCStore = img_url .. tostring("/UCStore") .. tostring(suffix)
    StarterPackSystem.DownloadedImage_PopUp_A = img_url .. tostring("/PopUp_A") .. tostring(suffix)
    StarterPackSystem.DownloadedImage_PopUp_B = img_url .. tostring("/PopUp_B") .. tostring(suffix)
    StarterPackSystem.DownloadedImage_PopUp_FO_A = img_url .. tostring("/PopUp_FO_A") .. tostring(suffix)
    StarterPackSystem.DownloadedImage_PopUp_FO_B = img_url .. tostring("/PopUp_FO_B") .. tostring(suffix)
    StarterPackSystem.DownloadedImage_PopUp_Unlocked_A = img_url .. tostring("/PopUp_Unlocked_A") .. tostring(suffix)
    StarterPackSystem.DownloadedImage_PopUp_Unlocked_B = img_url .. tostring("/PopUp_Unlocked_B") .. tostring(suffix)
  else
    StarterPackSystem.DownloadedImage_Path = img_url
    StarterPackSystem.DownloadedImage_UCStore = img_url .. tostring("/UCStore.png")
    StarterPackSystem.DownloadedImage_PopUp_A = img_url .. tostring("/PopUp_A.png")
    StarterPackSystem.DownloadedImage_PopUp_B = img_url .. tostring("/PopUp_B.png")
    StarterPackSystem.DownloadedImage_PopUp_FO_A = img_url .. tostring("/PopUp_FO_A.png")
    StarterPackSystem.DownloadedImage_PopUp_FO_B = img_url .. tostring("/PopUp_FO_B.png")
    StarterPackSystem.DownloadedImage_PopUp_Unlocked_A = img_url .. tostring("/PopUp_Unlocked_A.png")
    StarterPackSystem.DownloadedImage_PopUp_Unlocked_B = img_url .. tostring("/PopUp_Unlocked_B.png")
  end
end
function StarterPackSystem.UpdateCarousalIconPath(data)
  local util = require("client.slua_ui_framework.util")
  local img_url = data.IconPath
  if util.IsOnlineImageUrl(img_url) and string.find(img_url, "localize") then
    data.IconPath = util.GetUrlByLanguage(img_url)
    log(bWriteLog and "StarterPackSystem UpdateCarousalIconPath" .. tostring(data.IconPath))
  end
end
function StarterPackSystem.internalUpdateTimer()
  StarterPackSystem.GetPurchaseEffectiveTimeDesc()
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED, StarterPackSystem.sStarterPack_RemainingTime)
  if StarterPackSystem.bForceUpdate == true then
    StarterPackSystem.UpdateDateFromServer()
  end
  if StarterPackSystem.bForceUpdatePurchaseInf == true then
    if StarterPackSystem.iStarterPackDirectPurchaseId == nil or StarterPackSystem.iStarterPackDirectPurchaseId == 0 then
      log(bWriteLog and "still need to get direct purchase info as just unlock start pack")
    else
      StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
      StarterPackSystem.bForceUpdatePurchaseInf = false
    end
  end
  if StarterPackSystem.EnablePermanent == true then
    StarterPackSystem.sStarterPack_RemainingTime = "SOON"
  elseif StarterPackSystem.bStarterPackUnlocked == true then
    local TimeUtil = require("client.common.time_util")
    local fStarterPackRemainTime = StarterPackSystem.fStarterpack_UnlockTime + StarterPackSystem.fStarterPackValidPeriod - TimeUtil.GetServerTimeInSec()
    if fStarterPackRemainTime < 0 then
      fStarterPackRemainTime = 0
    end
    StarterPackSystem.sStarterPack_RemainingTime = StarterPackSystem.CovertTimeInSecondToString(fStarterPackRemainTime)
    StarterPackSystem.fStarterPack_LastUpdateFromServerTime = TimeUtil.OSTime()
  end
  LobbySystem.refresh_activity_display_starterpack_countdown()
end
function StarterPackSystem.StartCountDown(fTimeInterval)
  log(bWriteLog and "call StarterPackSystem.StartCountDown")
  if StarterPackSystem.UpdateTimer ~= nil then
    StarterPackSystem.StopCountDown()
  end
  log(bWriteLog and "StarterPackSystem CountDown add Timer")
  local time_ticker = require("common.time_ticker")
  if StarterPackSystem.UpdateTimer then
    time_ticker.RemoveTimer(StarterPackSystem.UpdateTimer)
  end
  StarterPackSystem.UpdateTimer = time_ticker.AddTimerLoop(fTimeInterval, function()
    StarterPackSystem.internalUpdateTimer()
  end, TIMER_INFINITE, fTimeInterval)
end
function StarterPackSystem.StopCountDown()
  log(bWriteLog and "call StarterPackSystem.StopCountDown")
  if nil ~= StarterPackSystem.UpdateTimer then
    log(bWriteLog and "StarterPackSystem CountDown remove Timer")
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(StarterPackSystem.UpdateTimer)
    StarterPackSystem.UpdateTimer = nil
    InitiallyTimeOffset = 0
  end
end
function StarterPackSystem.SetPurchaseUITrigger(ui_enum, isOpen)
  log(bWriteLog and "StarterPackSystem.SetPurchaseUITrigger ui_enum =" .. tostring(ui_enum) .. ", " .. tostring(isOpen))
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  if isOpen == false then
    StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if ui_enum == StarterPackSystem.PurchaseTriggerUI.CAROUSEL then
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_StarterPackCarouselClick, login_module.sIpRegion)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StarterPackCarouselClick, 0)
  end
  if StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.CAROUSEL then
    if ui_enum == StarterPackSystem.PurchaseTriggerUI.POPWINDOW then
      return
    end
    if ui_enum == StarterPackSystem.PurchaseTriggerUI.FINAL_POPWINDOW then
      return
    end
  end
  if isOpen == true then
    StarterPackSystem.CurePurchaseTriggerUI = ui_enum
  end
end
function StarterPackSystem.ReportPurchaseLog()
  log(bWriteLog and "StarterPackSystem.ReportPurchaseLog ui = " .. tostring(StarterPackSystem.CurePurchaseTriggerUI))
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.POPWINDOW then
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_StarterPackBuyThroughPopUp, login_module.sIpRegion)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StarterPackBuyThroughPopUp, 0)
  elseif StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.CAROUSEL then
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_StarterPackBuyThroughCarousel, login_module.sIpRegion)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StarterPackBuyThroughCarousel, 0)
  elseif StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.UCSTORE then
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_StarterPackBuyThroughUCStore, login_module.sIpRegion)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StarterPackBuyThroughUCStore, 0)
  elseif StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.FINAL_POPWINDOW then
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_StarterPackBuyThroughFinalOffer, login_module.sIpRegion)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StarterPackBuyThroughFinalOffer, 0)
  else
    return
  end
  gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_StarterPackPopUpTimeBeforeBuy, StarterPackSystem.iCurrentPopupCount, login_module.sIpRegion)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.StarterPackPopUpTimeBeforeBuy, 0, tostring(StarterPackSystem.iCurrentPopupCount))
  StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE
end
function StarterPackSystem.IsOpen()
  if not StarterPackSystem.StaticEnabled then
    log(bWriteLog and "StarterPackSystem.StaticEnabled false")
    return false
  end
  if not StarterPackSystem.Enabled then
    log(bWriteLog and "StarterPackSystem.Enabled false")
    return false
  end
  StarterPackSystem.ServerEnabled = LobbySystem.CheckOpen(BP_ENUM_MODULE_STARTER_PACK)
  if not StarterPackSystem.ServerEnabled then
    log(bWriteLog and "StarterPackSystem.ServerEnabled false")
    return false
  end
  if not StarterPackSystem.IsCouldPurchase then
    log(bWriteLog and "StarterPackSystem.IsCouldPurchase false")
    return false
  end
  log(bWriteLog and "StarterPackSystem.IsOpen true")
  return true
end
function StarterPackSystem.IsDownloadedDisplayImage()
  if string.find(StarterPackSystem.DownloadedImage_PopUp_A, "http") ~= 1 then
    return false
  end
  return true
end
function StarterPackSystem.IsValidActivity(data)
  log(bWriteLog and "StarterPackSystem.IsValidActivity : " .. tostring(data.ID) .. tostring(" : ") .. tostring(data.IconPath) .. tostring(":") .. tostring(StarterPackSystem.DownloadedImage_Path))
  return true
end
function StarterPackSystem.CovertTimeInSecondToString(TimeLeft)
  local TimeSeconds = 0
  local TimeMinutes = 0
  local TimeHours = 0
  local TimeDays = 0
  local result = ""
  TimeSeconds = TimeLeft % 60
  TimeMinutes = (TimeLeft - TimeSeconds) / 60
  if TimeMinutes < 60 then
    if TimeSeconds == 0 and TimeMinutes == 0 and TimeHours == 0 and TimeDays == 0 then
      result = ""
    else
      result = string.format("%dd, %.2d:%.2d:%.2d", TimeDays, TimeHours, TimeMinutes, TimeSeconds)
    end
    return result
  else
    local tmpMinute = TimeMinutes
    TimeMinutes = tmpMinute % 60
    TimeHours = (tmpMinute - TimeMinutes) / 60
  end
  if TimeHours < 24 then
    result = string.format("%dd, %.2d:%.2d:%.2d", TimeDays, TimeHours, TimeMinutes, TimeSeconds)
    return result
  else
    local tmpHour = TimeHours
    TimeHours = tmpHour % 24
    TimeDays = (tmpHour - TimeHours) / 24
  end
  result = string.format("%dd, %.2d:%.2d:%.2d", TimeDays, TimeHours, TimeMinutes, TimeSeconds)
  return result
end
function StarterPackSystem.GetPurchaseEffectiveTimeDesc()
  return StarterPackSystem.sStarterPack_RemainingTime
end
function StarterPackSystem.GetPackItemDesc()
  return ""
end
function StarterPackSystem.GetPriceDesc()
  local price_desc = StarterPackSystem.DirectPurchaseInfo.productPriceDesc
  if price_desc == "" then
    price_desc = "Updating"
  end
  log(bWriteLog and "StarterPackSystem.GetPriceDesc, " .. tostring(price_desc))
  return price_desc
end
function StarterPackSystem.GetUCRewardsDesc()
  local uc_desc = StarterPackSystem.DirectPurchaseInfo.awards_uc_num
  log(bWriteLog and "StarterPackSystem.GetUCRewardsDesc, " .. tostring(uc_desc))
  if uc_desc == 0 or uc_desc == nil then
    return ""
  end
  return uc_desc
end
function StarterPackSystem.ShowWaitingUI()
  log(bWriteLog and "StarterPackSystem.ShowWaitingUI")
  logic_connection_waiting:Show(1)
end
function StarterPackSystem.HideWaitingUI()
  log(bWriteLog and "StarterPackSystem.HideWaitingUI")
  logic_connection_waiting:Hide(1)
end
function StarterPackSystem.OnIsOpenChanged()
  log(bWriteLog and "StarterPackSystem.OnIsOpenChanged")
  LobbySystem.refresh_activity_display_bystarterpack()
end
function StarterPackSystem.OnGetDirectPurchaseItemInfo()
  log(bWriteLog and "StarterPackSystem.OnGetDirectPurchaseItemInfo")
  StarterPackSystem.IsValidDirectPurchasePackItem = true
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_INFO_UPDATED)
  StarterPackSystem.CheckOpenDirectPurchaseSucceed()
end
function StarterPackSystem.OnGetDirectPurchaseItemPrice()
  log(bWriteLog and "StarterPackSystem.OnGetDirectPurchaseItemPrice")
  StarterPackSystem.IsValidCentauriDirectPurchasePack = true
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_PRICE_UPDATED)
  StarterPackSystem.CheckOpenDirectPurchaseSucceed()
end
function StarterPackSystem.CheckOpenDirectPurchaseSucceed()
  log(bWriteLog and "StarterPackSystem.OnOpenDirectPurchaseSucceed")
  if StarterPackSystem.IsValidDirectPurchasePackItem and StarterPackSystem.IsValidCentauriDirectPurchasePack then
    StarterPackSystem.OnOpenDirectPurchaseSucceed()
  end
end
function StarterPackSystem.OnOpenDirectPurchaseSucceed()
  log(bWriteLog and "StarterPackSystem.OnOpenDirectPurchaseSucceed")
  StarterPackSystem.IsValidDirectPurchasePack = true
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_OPEN_VERIFY_SUCCEED)
end
StarterPackSystem.IsReqDirectPurchase = false
function StarterPackSystem.GetDirectBuyInfoReq()
  log(bWriteLog and "StarterPackSystem.GetDirectBuyInfoReq From Server, itemid=" .. tostring(StarterPackSystem.DirectPurchaseItemID))
  StarterPackSystem.IsReqDirectPurchase = true
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_query_direct_buy_info(StarterPackSystem.DirectPurchaseItemID)
end
function StarterPackSystem.GetDirectPurchaseInfoRspError()
  log(bWriteLog and "StarterPackSystem.GetDirectPurchaseInfoRspError")
  if StarterPackSystem.IsReqDirectPurchase == true then
    StarterPackSystem.DirectPurchaseItemID = 0
    StarterPackSystem.SetIsCouldPurchase(false)
  end
end
function StarterPackSystem.GetDirectPurchaseInfoRsp(res, info)
  local MallSystem = require("client.logic.mall.logic_mall")
  log(bWriteLog and "StarterPackSystem.GetDirectPurchaseInfoRsp from server" .. tostring(res))
  if info == nil then
    log(bWriteLog and "StarterPackSystem. GetDirectPurchaseInfoRsp info fail: return")
    return false
  end
  if info.item_id ~= StarterPackSystem.DirectPurchaseItemID then
    log(bWriteLog and "StarterPackSystem.GetDirectPurchaseInfoRsp info not match: return")
    return false
  end
  if not StarterPackSystem.IsReqDirectPurchase then
    return false
  end
  StarterPackSystem.IsReqDirectPurchase = false
  log_tree("StarterPackSystem. list", info)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    log(bWriteLog and "StarterPackSystem. GetDirectPurchaseInfoRsp res is not ok , return:")
    return false
  end
  local rewardPkgInfo = StarterPackSystem.DirectPurchaseInfo
  rewardPkgInfo.CentauriProductId = info.productid
  rewardPkgInfo.CentauriCountry = info.country
  rewardPkgInfo.CentauriCurrencyUnit = info.curency
  rewardPkgInfo.CentauriCurrency = info.curency_unit
  rewardPkgInfo.CentauriPrice = info.CentauriPrice
  rewardPkgInfo.CentauriPayItem = info.payItem
  rewardPkgInfo.discount = info.discount
  rewardPkgInfo.item_id = info.item_id
  rewardPkgInfo.configPrice = info.price
  rewardPkgInfo.productPriceDesc = info.price
  rewardPkgInfo.rewardItems = {}
  rewardPkgInfo.awards_uc_num = 0
  if info.parm2 and info.parm2 ~= "" then
    local returnUC = MallSystem.ParseDirectPurchaseParam(info.parm2)
    if 0 < returnUC then
      rewardPkgInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC}
      rewardPkgInfo.awards_uc_num = returnUC
    end
  end
  for index, item in ipairs(info.item_content) do
    rewardPkgInfo.rewardItems[#rewardPkgInfo.rewardItems + 1] = {
      itemId = item.DropItemID,
      itemNum = item.DropItemNum
    }
    if item.DropItemID == 1006 then
      rewardPkgInfo.awards_uc_num = item.DropItemNum
    end
  end
  log_tree("StarterPackSystem list", StarterPackSystem.DirectPurchaseInfo)
  if StarterPackSystem.IsDirectPurchaseInfoValid() then
    StarterPackSystem.OnGetDirectPurchaseItemInfo()
    StarterPackSystem.DirectBuyCentauriInfoReq(rewardPkgInfo.CentauriProductId, "", true)
  end
  return true
end
function StarterPackSystem.IsDirectPurchaseInfoValid()
  if StarterPackSystem.DirectPurchaseItemID == 0 then
    return false
  end
  if StarterPackSystem.DirectPurchaseInfo.item_id == 0 then
    return false
  end
  if tostring(StarterPackSystem.DirectPurchaseInfo.item_id) ~= tostring(StarterPackSystem.DirectPurchaseItemID) then
    return false
  end
  return true
end
function StarterPackSystem.DirectBuyResultNotify(res, id, limit_num)
  log(bWriteLog and "StarterPackSystem.DirectBuyResultNotify, res =" .. tostring(res) .. ", id =" .. tostring(id))
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  elseif StarterPackSystem.IsDirectPurchaseCentauriReq == true then
    StarterPackSystem.ReportPurchaseLog()
    StarterPackSystem.EndPurchase()
  end
  StarterPackSystem.IsDirectPurchaseCentauriReq = false
  StarterPackSystem.DirectPurchaseServerRsp(id, limit_num)
end
function StarterPackSystem.DirectBuyCentauriInfoReq(productId, oldPrice, needReload)
  log(bWriteLog and "StarterPackSystem.DirectBuyCentauriInfoReq,  productId:" .. tostring(productId))
  local result, productInfos = CentauriManager.LoadCachedCentauriProductInfo(productId)
  if not (result and productInfos) or #productInfos <= 0 then
    if needReload then
      local funcCall = function()
        log(bWriteLog and "StarterPackSystem. DirectBuyCentauriInfoReq : Client.LoadCentauriProductInfo, " .. tostring(productId))
        local logic_payment_api = require("client.logic.pay.logic_payment_api")
        logic_payment_api:load_Centauri_product_info(productId)
      end
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(0.2, funcCall, false, false)
    end
  else
    local info = productInfos[1]
    log(bWriteLog and "StarterPackSystem.StarterPackSystem, get cache price:" .. tostring(info.price))
    StarterPackSystem.SetCentauriGoodsInfo(productId, info.price or oldPrice)
    return
  end
end
function StarterPackSystem.SetCentauriGoodsInfo(productId, price)
  log(bWriteLog and "StarterPackSystem.SetCentauriGoodsInfo, productId = " .. tostring(productId) .. ",price_desc=" .. tostring(price))
  if tostring(productId) == StarterPackSystem.DirectPurchaseInfo.CentauriProductId then
    log(bWriteLog and "StarterPackSystem. update productId price:" .. tostring(price))
    StarterPackSystem.DirectPurchaseInfo.configPrice = tostring(price)
    StarterPackSystem.DirectPurchaseInfo.productPriceDesc = tostring(price)
    StarterPackSystem.OnGetDirectPurchaseItemPrice()
  end
end
function StarterPackSystem.GetCentauriGoodsInfoRsp(evenType, eventID, resultTable)
  log(bWriteLog and "StarterPackSystem.GetCentauriGoodsInfoRsp")
  if resultTable == nil then
    log(bWriteLog and "StarterPackSystem.GetCentauriGoodsInfoRsp, resultTable is null return")
    return
  end
  for k, product in pairs(resultTable) do
    if tostring(product.productId) == tostring(StarterPackSystem.DirectPurchaseInfo.CentauriProductId) then
      StarterPackSystem.SetCentauriGoodsInfo(product.productId, product.price)
    end
  end
  log_tree("StarterPackSystem. resultTable", resultTable)
end
function StarterPackSystem.DirectPurchaseCentauriReq()
  log(bWriteLog and "StarterPackSystem.DirectPurchaseCentauriReq")
  StarterPackSystem.ShowWaitingUI()
  local funcCall1 = function()
    StarterPackSystem.HideWaitingUI()
  end
  StarterPackSystem.IsDirectPurchaseCentauriReq = true
  local funcCall2 = function()
    local info = StarterPackSystem.DirectPurchaseInfo
    log_tree("StarterPackSystem. RewardPkgInfo", info)
    log(bWriteLog and "StarterPackSystem. Centauri buy goods")
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:Goods(info.CentauriProductId, info.CentauriPayItem, info.CentauriPrice, info.CentauriCountry, info.CentauriCurrency)
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(2, funcCall1)
  time_ticker.AddTimerOnce(0.2, funcCall2)
end
function StarterPackSystem.DirectPurchaseCentauriRsp(eventType, eventID, result)
  log(bWriteLog and "StarterPackSystem.DirectPurchaseCentauriRsp, result = " .. tostring(result))
  if tostring(result) ~= "0" then
    StarterPackSystem.HideWaitingUI()
  elseif StarterPackSystem.IsDirectPurchaseCentauriReq == true then
    log(bWriteLog and "StarterPackSystem.DirectPurchaseCentauriRsp, IsDirectPurchaseCentauriReq is true")
    StarterPackSystem.ReportPurchaseLog()
    StarterPackSystem.EndPurchase()
  end
  StarterPackSystem.IsDirectPurchaseCentauriReq = false
end
function StarterPackSystem.DirectPurchaseServerRsp(id, limit_num)
  log(bWriteLog and "StarterPackSystem.DirectPurchaseServerRsp")
  StarterPackSystem.HideWaitingUI()
end
return StarterPackSystem