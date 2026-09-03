local collect_encryption_module = {}
function collect_encryption_module:DefineAndResetData()
  self.cacheEncryptionConfig = {}
end
function collect_encryption_module:OnPreSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self.cacheEncryptionConfig = {}
  end
end
function collect_encryption_module:GetEncryptionConfig(itemID)
  if not itemID then
    return nil
  end
  if not self.cacheEncryptionConfig then
    self.cacheEncryptionConfig = {}
  end
  local cache = self.cacheEncryptionConfig[itemID]
  if cache == nil then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local config = collect_module:GetSplitTableData("CollectEncryptionConfig", collect_module.E_ColCfgMode.JK, itemID)
    if not config then
      self.cacheEncryptionConfig[itemID] = false
    elseif config.ShowTime and config.ShowTime ~= "" then
      self.cacheEncryptionConfig[itemID] = config
    end
    cache = self.cacheEncryptionConfig[itemID]
  end
  if cache == false then
    log(bWriteLog and string.format("collect_encryption_module:GetEncryptionConfig this item is not config. itemID = %s", itemID))
    return nil
  end
  return cache
end
function collect_encryption_module:IsEncryption(itemID)
  local config = self:GetEncryptionConfig(itemID)
  if not config then
    log(bWriteLog and string.format("collect_encryption_module:IsEncryption this item is not config. itemID = %s", itemID))
    return false
  end
  local Version = config.Version
  local Time = config.ShowTime
  if Version == "" and Time == "" then
    log(bWriteLog and string.format("collect_encryption_module:IsEncryption configuration information is empty. itemID = %s", itemID))
    return false
  end
  if Version and not FuncUtil.CompareVersion(Client.GetApplicationVersion(), Version) then
    log(bWriteLog and string.format("collect_encryption_module:IsEncryption not in the latest version. Version = %s", Version))
    return true
  end
  if Time then
    local TimeUtil = require("client.common.time_util")
    local current = TimeUtil.GetServerTimeInSec()
    local show = TimeUtil.TimeStringToUnixstamp(Time)
    if current < show then
      return true
    end
  end
  return false
end
function collect_encryption_module:IsEncryptionSeries(Version, Time)
  if not Version and not Time then
    return false
  end
  if Version and not FuncUtil.CompareVersion(Client.GetApplicationVersion(), Version) then
    return true
  end
  if Time then
    local TimeUtil = require("client.common.time_util")
    local current = TimeUtil.GetServerTimeInSec()
    local show = TimeUtil.TimeStringToUnixstamp(Time)
    if current < show then
      return true
    end
  end
  return false
end
function collect_encryption_module:ShowEncryptionTips(itemID, hideName)
  local config = self:GetEncryptionConfig(itemID)
  if not config then
    log(bWriteLog and string.format("collect_encryption_module:ShowEncryptionTips this item is not config. itemID = %s", itemID))
    return
  end
  local Time = config.ShowTime
  local TimeUtil = require("client.common.time_util")
  local unixTime = TimeUtil.TimeStringToUnixstamp(Time)
  local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(unixTime - TimeUtil.GetServerTimeInSec(), true)
  if hideName then
    local str = LocUtil.GetLocalizeResStr(720000)
    ShowNotice(LocUtil.LocalizeResFormat(77586, str, timeStr))
    return
  end
  local itemData = CDataTable.GetTableData("Item", itemID)
  if itemData then
    ShowNotice(LocUtil.LocalizeResFormat(77586, itemData.ItemName, timeStr))
  end
end
function collect_encryption_module:GetEncryptionCfgJumpUrlData(cObj_encryptionCfg)
  if not cObj_encryptionCfg then
    return ""
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if PublishRegionMacros.IsJapanOrKorea() and FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.KR and cObj_encryptionCfg.ActJumpURL_KR and cObj_encryptionCfg.ActJumpURL_KR ~= "" then
    return cObj_encryptionCfg.ActJumpURL_KR
  end
  return cObj_encryptionCfg.ActJumpURL
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_encryption_module)
return CModuleTemplate