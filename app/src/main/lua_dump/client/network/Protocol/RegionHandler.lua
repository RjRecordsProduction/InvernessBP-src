local NetManager = require("client.network.comm.NetManager")
local RegionHandler = {}
function RegionHandler.on_sync_player_region_info(regionData, regionList, isBlockUser)
  DataMgr.SyncRegionData(regionData, regionList)
  local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
  logic_region_block.bIsCrossRegionBlocked = isBlockUser
  log(bWriteLog and "[DeanJYT] RegionHandler.on_sync_player_region_info isBlockUser = " .. tostring(isBlockUser))
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:SetClientVersionAndRegionStatus()
end
function RegionHandler.send_set_account_region_req(region)
  NetManager.SendPkg(1227306343, region)
end
function RegionHandler.on_set_account_region_rsp(res, region)
  if res == 0 then
    log(bWriteLog and "[edward][RegionHandler] on_set_account_region_rsp = " .. region)
  elseif res == 100150049 then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
  elseif res == 550005 then
    log(bWriteLog and "[v_gpingban][RegionHandler] on_set_account_region_rsp res = " .. res)
    local ui = UIManager.GetUI(UIManager.UI_Config.setting_set_region)
    if ui then
      ui:OpenPhoneBindUI()
    end
  elseif res == 550007 then
    ShowNotice(34614)
    log(bWriteLog and "[edward][RegionHandler] on_set_account_region_rsp res = " .. res)
  else
    ShowNotice(res)
    log_error("[edward][RegionHandler] on_set_account_region_rsp res = " .. res)
  end
end
function RegionHandler.send_set_shop_region_req(region)
  log(bWriteLog and "[SY]RegionHandler.send_set_shop_region_req.region:" .. tostring(region))
  local bEnableIOSThirdPay = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableIOSThirdPay", false)
  if not bEnableIOSThirdPay then
    log(bWriteLog and "[SY]RegionHandler.send_set_shop_region_req.bEnableIOSThirdPay is false")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isGlobal = PublishRegionMacros.IsGlobalVersion()
  if not isGlobal then
    log(bWriteLog and "[SY]RegionHandler.send_set_shop_region_req.isGlobal is false")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
  if bGuest then
    log(bWriteLog and "[SY]RegionHandler.send_set_shop_region_req.bGuest is false")
    return
  end
  NetManager.SendPkg(623605923, region)
end
function RegionHandler.on_set_shop_region_rsp(err_code, region)
  log(bWriteLog and "[SY]RegionHandler.on_set_shop_region_rsp.err_code:" .. tostring(err_code) .. " region:" .. tostring(region))
  if not err_code == 0 then
    ShowNotice(err_code)
    return
  end
  CentauriManager.country = region
end
return RegionHandler