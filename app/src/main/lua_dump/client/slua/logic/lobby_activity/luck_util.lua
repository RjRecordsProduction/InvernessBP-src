local JPDrawRateDomain = FuncUtil.GetDomainByID(3366039) or ""
local KRDrawRateDomain = FuncUtil.GetDomainByID(3366040) or ""
local luck_util = {
  CONST = {
    LuckyBack_JPDrawRate = JPDrawRateDomain .. "/wanderer.html",
    LuckyBack_KRDrawRate = KRDrawRateDomain .. "/battlegroundsmobile/3",
    LuckyBack_JPKRDrawDescLocalKey = 44507
  }
}
function luck_util.ActIsValid(actId)
  if actId == nil or actId == 0 then
    ShowNotice(120106)
    log(bWriteLog and "luck_util.CheckActId id is NULL")
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local data = activityDataTable[tonumber(actId)]
  if data == nil then
    log(bWriteLog and " not exist ")
    ShowNotice(4002)
    return false
  end
  return true
end
function luck_util.SetDecomposeDelay(needDelay)
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.end
function luck_util.SetAchievementPopBlock(needBlock)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  if needBlock then
    logic_achievement_float_tip.BlockPopTip()
  else
    logic_achievement_float_tip.UnblockPopTip()
  end
end
function luck_util.GetKeyInBaseConfig(resourceType)
  local config = require("client.slua.logic.lobby_activity.LuckySpinConfig")
  local cfg = config.MainPool[resourceType]
  if type(cfg) == "table" then
    cfg = cfg.BaseBp
  elseif type(cfg) == "string" then
  else
    log_error(bWriteLog and "[cw] cfg is nil, please check the LuckySpinConfig base on the resource type: " .. tostring(resourceType))
    return
  end
  return cfg
end
function luck_util.isJapan()
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  return FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP
end
function luck_util.isKorea()
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  return FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.KR
end
function luck_util.GetJPKRLuckyBackDrawRateLink()
  if not GlobalData.IsJapanOrKorea() then
    log_error(bWriteLog and "[cw] trying to run GetJPKRLuckyBackDrawRateLink() on neither the JP nor the KR version, return nil")
    return nil
  end
  if luck_util.isJapan() then
    return luck_util.CONST.LuckyBack_JPDrawRate
  else
    return luck_util.CONST.LuckyBack_KRDrawRate
  end
end
function luck_util.OpenJPKRLuckyBackDrawWeb()
  local link = luck_util.GetJPKRLuckyBackDrawRateLink()
  if not link then
    log_error(bWriteLog and "[cw] trying to run OpenJPKRLuckyBackDrawWeb() on neither the JP nor the KR version")
    return
  end
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(link)
end
function luck_util.GetJPKRLuckyBackDrawRateDesc()
  if not GlobalData.IsJapanOrKorea() then
    log_error(bWriteLog and "[cw] trying to run GetJPKRLuckyBackDrawRateDesc() on neither the JP nor the KR version, return nil")
    return nil
  end
  return LocUtil.GetLocalizeResStr(luck_util.CONST.LuckyBack_JPKRDrawDescLocalKey)
end
function luck_util.CheckLuckyBackActIsSmallRPRelated(nActFlagType, nActId)
  local Logic_LuckConst = require("client.slua.logic.lobby_activity.Logic_LuckConst")
  local Enum_DrawBackFlag = Logic_LuckConst.Enum_DrawBackFlag
  if not (nActId and nActFlagType) or nActFlagType ~= Enum_DrawBackFlag.SmallRP then
    return false
  end
  local cObj_smallRPModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  if not cObj_smallRPModule:GetIsOpen() then
    cObj_smallRPModule:send_small_rp_player_data_req()
    return false
  end
  return cObj_smallRPModule:IsConnectedRPByID(nActId)
end
function luck_util.ShowSupplyCurrencyBar_IPScore()
  local cObj_smallRPModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nIPScoreItemId = cObj_smallRPModule:GetIPScoreId()
  if not nIPScoreItemId then
    return
  end
  local tExtraData = {
    fClickCallback = function(node_showWidget, nItemId)
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId) or {}
      local tTipsParam = {
        iconItem = nItemId,
        widget = node_showWidget,
        content = uObj_itemCfg.ItemDesc,
        jumpText = LocUtil.GetLocalizeResStr(6343),
        jumpCallback = function()
          local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", nItemId)
          if not jumpConfig then
            return
          end
          GlobalData.JumpUrl(jumpConfig.JumpExchangeUrl)
        end,
        offsetX = -280,
        offsetY = 60
      }
      UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tTipsParam)
    end
  }
  EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_CRATE_UPDATE_CURRENCY, nIPScoreItemId, tExtraData)
end
return luck_util