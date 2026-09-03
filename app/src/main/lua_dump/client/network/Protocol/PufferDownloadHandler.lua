local NetManager = require("client.network.comm.NetManager")
local PufferDownloadHandler = {err_mini_client_reward_id_not_exist = 880101, err_mini_client_reward_is_got = 880102}
function PufferDownloadHandler.send_mini_client_reward_get_req(type)
  log(bWriteLog and "PufferDownloadHandler.send_mini_client_reward_get_req type: " .. tostring(type))
  NetManager.SendPkg(1047370536, type)
end
function PufferDownloadHandler.on_mini_client_reward_get_res(errcode, type)
  log(bWriteLog and string.format("on_mini_client_reward_get_res: errcode: %s, type: %s", tostring(errcode), tostring(type)))
  if errcode == 0 then
    if PufferDownloader.DownloadRewardCfg and PufferDownloader.DownloadRewardCfg[type] then
      local cfg = PufferDownloader.DownloadRewardCfg[type]
      cfg.is_got = true
      local arrayItemList = {}
      if 0 < cfg.itemid1 then
        local arrayItem1 = {}
        arrayItem1.res_id = cfg.itemid1
        arrayItem1.expire_ts = 0
        arrayItem1.valid_hours = 0
        arrayItem1.count = cfg.itemcnt1
        table.insert(arrayItemList, arrayItem1)
      end
      if 0 < cfg.itemid2 then
        local arrayItem2 = {}
        arrayItem2.res_id = cfg.itemid2
        arrayItem2.expire_ts = 0
        arrayItem2.valid_hours = 0
        arrayItem2.count = cfg.itemcnt2
        table.insert(arrayItemList, arrayItem2)
      end
      if 0 < cfg.itemid3 then
        local arrayItem3 = {}
        arrayItem3.res_id = cfg.itemid3
        arrayItem3.expire_ts = 0
        arrayItem3.valid_hours = 0
        arrayItem3.count = cfg.itemcnt3
        table.insert(arrayItemList, arrayItem3)
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
    else
      log(bWriteLog and "on_mini_client_reward_get_res: PufferDownloader.DownloadRewardCfg is nil")
    end
    EventSystem:postEvent(EVENTTYPE_ODPAKS, EVENTID_ODPAKS_UPDATEBUTTON)
  elseif errcode == PufferDownloadHandler.err_mini_client_reward_id_not_exist then
  elseif errcode == PufferDownloadHandler.err_mini_client_reward_is_got then
  end
end
function PufferDownloadHandler.send_mini_client_reward_cfg_get_req(type)
  log(bWriteLog and "PufferDownloadHandler.send_mini_client_reward_cfg_get_req type: " .. tostring(type))
  local cfg = CDataTable.GetTableData("PakInfoTable", type)
  if not cfg or cfg.HaveReward == 0 then
    return
  end
  NetManager.SendPkg(465058184, type)
end
function PufferDownloadHandler.on_mini_client_reward_cfg_get_res(cfg, type)
  log_tree("PufferDownloadHandler.on_mini_client_reward_cfg_get_res cfg = " .. tostring(type), cfg)
  PufferDownloader.DownloadRewardCfg[type] = cfg
  EventSystem:postEvent(EVENTTYPE_ODPAKS, EVENTID_ODPAKS_UPDATEBUTTON)
end
function PufferDownloadHandler.send_client_pak_report(pak_num)
  NetManager.SendPkg(843715389, pak_num)
end
function PufferDownloadHandler.send_report_res_download_log(info)
  NetManager.SendPkg(713385013, info)
end
function PufferDownloadHandler.send_paks_batch_download_log(button_type, reason, reason_tbl)
  NetManager.SendPkg(1953522048, button_type, reason, reason_tbl)
end
function PufferDownloadHandler.send_mini_client_reward_cfg_req()
  NetManager.SendPkg(1807671272)
end
function PufferDownloadHandler.on_mini_client_reward_cfg_res(cfg)
  if cfg and next(cfg) then
    for i, v in pairs(cfg) do
      log(bWriteLog and "PufferDownloadHandler.on_mini_client_reward_cfg_res id = " .. tostring(i))
      PufferDownloader.DownloadRewardCfg[i] = v
    end
    EventSystem:postEvent(EVENTTYPE_ODPAKS, EVENTID_ODPAKS_UPDATEBUTTON)
  end
end
function PufferDownloadHandler.send_reserve_download(flag)
  NetManager.SendPkg(772226931, flag)
end
function PufferDownloadHandler.on_reserve_download_res(errcode, reserve_download)
  log(bWriteLog and string.format("PufferDownloadHandler.on_reserve_download_res errcode:%s reserve_download:%s", tostring(errcode), tostring(reserve_download)))
  if errcode ~= 0 then
    return
  end
  local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
  PufferPrefetchManager:InitReserve()
  EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_RESERVE_REFRESH)
end
function PufferDownloadHandler.send_save_download_setting_req(type, setting, trigger_source)
  printf("PufferDownloadHandler.send_save_download_setting_req. type=%s", tostring(type))
  log_tree("PufferDownloadHandler.send_save_download_setting_req. setting = ", setting)
  setting = Encode(setting)
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local data = Util_UGC.BufferCompressData(setting)
  log(bWriteLog and "PufferDownloadHandler.send_save_download_setting_req. len = " .. tostring(string.len(data)))
  NetManager.SendPkg(1212171871, type, data, trigger_source)
end
function PufferDownloadHandler.on_save_download_setting_rsp(err_code, type)
  printf("PufferDownloadHandler.on_save_download_setting_rsp. err_code=%s, type=%s", tostring(err_code), tostring(type))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_SMARTDOWNLOAD_SAVED, type)
end
function PufferDownloadHandler.send_get_download_setting_req(type)
  printf("PufferDownloadHandler.send_get_download_setting_req. type=%s", tostring(type))
  NetManager.SendPkg(1689090855, type)
end
function PufferDownloadHandler.on_get_download_setting_rsp(err_code, type, setting)
  printf("PufferDownloadHandler.on_get_download_setting_rsp. err_code=%s, type=%s, setting=%s", tostring(err_code), tostring(type), tostring(setting))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local data = Util_UGC.DecompressData(setting)
  data = Decode(data)
  log_tree("PufferDownloadHandler.on_get_download_setting_rsp. data = ", data)
  EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_SMARTDOWNLOAD_LOADED, type, data)
end
return PufferDownloadHandler