local HomeStoreChestPatial = {}
function HomeStoreChestPatial:GetAvailableChestCfg(bReset)
  if bReset then
    self.cachedChestCfg = nil
  end
  if not IsEditor and self.cachedChestCfg then
    return self.cachedChestCfg
  end
  local PHomeStoreConst = require("client.slua.logic.homestore.PHomeStoreConst")
  local version_util = require("client.common.version_util")
  local PHomeStoreUtils = require("GameLua.Mod.SocialIsland.Client.UI.PHome.PHomeStoreUtils")
  local TimeUtil = require("client.common.time_util")
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local chestCfgs = BasicDataServerTable:GetCacheData(data_config_marco.manor_chest_global_table)
  if nil == chestCfgs then
    printf("HomeStoreChestPatial:GetCurrentChestCfg chestCfgs is nil")
    return nil
  end
  local clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable
  clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  now = TimeUtil.GetServerTimeInSec()
  FnCmpVersion = version_util.CompareVersionStandard
  FnCmpTime = TimeUtil.TimeStringToUnixstamp_LoopOptimize
  timeZone = TimeUtil.GetTimeZone(nil, true)
  refTimeTable = {}
  local itop_app_id = tostring(Client.GetITopGameId())
  local count = 0
  for chestId, chestCfg in pairs(chestCfgs) do
    if false == PHomeStoreUtils.CheckVersionPassed_LoopOptimize(chestCfg.open_version, chestCfg.close_ver, chestCfg.begin_time, chestCfg.end_time, clientVersion, now, FnCmpVersion, FnCmpTime, timeZone, refTimeTable) then
      printf("HomeStoreChestPatial:GetCurrentChestCfg CheckVersionPassed failed. chestId:%s", chestId)
    elseif false == PHomeStoreUtils.CheckAppIdList(chestCfg.appids, itop_app_id) then
      printf("HomeStoreChestPatial:GetCurrentChestCfg CheckAppIdList failed. chestId:%s", chestId)
    else
      count = count + 1
      self.cachedChestCfg = chestCfg
      self.cachedChestCfg.activity_id = chestId
    end
  end
  return self.cachedChestCfg
end
function HomeStoreChestPatial:SetChestInfo(box_energy, daily_chest_cnt)
  printf("HomeStoreChestPatial:SetChestInfo box_energy:%s daily_chest_cnt:%s", box_energy, daily_chest_cnt)
  self.  if daily_chest_cnt then
    self.  end
end
return HomeStoreChestPatial