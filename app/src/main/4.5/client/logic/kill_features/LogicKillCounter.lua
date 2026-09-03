local LogicKillCounter = {}
local EnumOperateType = {PotOn = 0, PotOff = 1}
function LogicKillCounter:DefineAndResetData()
  self.uidTokillInfoMap = nil
  self.uidToCurBattlekillCountListMap = nil
  self.weaponFeatureList = nil
end
function LogicKillCounter:OnInitialize()
end
function LogicKillCounter:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "LogicKillCounter:OnPostSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  if preState == GameStatus.Fighting then
    self:ClearCacheData()
  end
  if nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    self.uidToCurBattlekillCountListMap = nil
    self:send_get_accumulation_kill_info_req()
  else
    log(bWriteLog and "LogicKillCounter:OnPostSwitchGameStatus IsInLobbyOrMainCity " .. tostring(GameStatus.IsInLobbyOrMainCity()))
  end
end
function LogicKillCounter:ClearCacheData()
  self.uidTokillInfoMap = nil
  self.uidToCurBattlekillCountListMap = nil
  self.weaponFeatureList = nil
end
function LogicKillCounter:GetWeaponKillCountByUid(uid, weaponId)
  uid = tonumber(uid)
  if not uid or not weaponId then
    log(bWriteLog and "LogicKillCounter:GetWeaponKillCountByUid invalid params")
    return -1
  end
  log(bWriteLog and "LogicKillCounter:GetWeaponKillCountByUid uid:" .. tostring(uid) .. " weaponId:" .. tostring(weaponId))
  self.uidTokillInfoMap = self.uidTokillInfoMap or {}
  if not self.uidTokillInfoMap[uid] then
    log(bWriteLog and "LogicKillCounter:GetWeaponKillCountByUid invalid uidTokillInfo")
    return -1
  end
  local UAvatarUtils = import("AvatarUtils")
  local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
  if not realWeaponId then
    log(bWriteLog and "LogicKillCounter:GetWeaponKillCountByUid realWeaponId invalid")
    return -1
  end
  local killCountInfo = self.uidTokillInfoMap[uid].kill_info or {}
  return killCountInfo and killCountInfo[realWeaponId] or -1
end
function LogicKillCounter:GetCurBattleWeaponKillCountByUid(uid, weaponId)
  if not uid or not weaponId then
    log(bWriteLog and "LogicKillCounter:GetCurBattleWeaponKillCountByUid invalid params")
    return 0
  end
  log(bWriteLog and "LogicKillCounter:GetCurBattleWeaponKillCountByUid uid:" .. tostring(uid) .. " weaponId:" .. tostring(weaponId))
  self.uidToCurBattlekillCountListMap = self.uidToCurBattlekillCountListMap or {}
  if not self.uidToCurBattlekillCountListMap[uid] then
    log(bWriteLog and "LogicKillCounter:GetCurBattleWeaponKillCountByUid invalid uidTokillInfo")
    return 0
  end
  local UAvatarUtils = import("AvatarUtils")
  local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
  if not realWeaponId then
    log(bWriteLog and "LogicKillCounter:GetCurBattleWeaponKillCountByUid realWeaponId invalid")
    return 0
  end
  return self.uidToCurBattlekillCountListMap[uid][realWeaponId] or 0
end
function LogicKillCounter:CheckHaveKillCounter(featureItemid)
  local itemNum = self:GetMyKillCounterNum(featureItemid)
  return 0 < itemNum
end
function LogicKillCounter:CheckHaveKillCounterByWeaponId(originWeaponId)
  if not originWeaponId then
    log(bWriteLog and "LogicKillCounter:CheckHaveKillCounterByWeaponId originWeaponId is nil")
    return false
  end
  local featureList = CDataTable.GetTableByFilter("KillCounterToWeaponIdCfg", "WeaponID", originWeaponId)
  if not featureList then
    log(bWriteLog and "LogicKillCounter:CheckHaveKillCounterByWeaponId featureList is nil")
    return false
  end
  for _, featureCfg in pairs(featureList) do
    if self:CheckHaveKillCounter(featureCfg.FeatureID) then
      log(bWriteLog and "LogicKillCounter:CheckHaveKillCounterByWeaponId true")
      return true
    end
  end
  log(bWriteLog and "LogicKillCounter:CheckHaveKillCounterByWeaponId false")
  return false
end
function LogicKillCounter:GetBaseKillCounterIdByWeaponId(originWeaponId)
  if not originWeaponId then
    log(bWriteLog and "LogicKillCounter:GetBaseKillCounterIdByWeaponId originWeaponId is nil")
    return nil
  end
  local featureCfg = CDataTable.GetTableDataByFilter("KillCounterToWeaponIdCfg", "WeaponID", originWeaponId, "IsBaseCounter", true)
  if not featureCfg then
    log(bWriteLog and "LogicKillCounter:GetBaseKillCounterIdByWeaponId featureCfg is nil")
    return nil
  end
  return featureCfg.FeatureID
end
function LogicKillCounter:GetOriginWeaponIdByFeatureItemId(featureItemid)
  if not featureItemid then
    log(bWriteLog and "LogicKillCounter:GetOriginWeaponIdByFeatureItemId featureItemid is nil")
    return nil
  end
  local featureCfg = CDataTable.GetTableData("KillCounterToWeaponIdCfg", featureItemid)
  if not featureCfg then
    log(bWriteLog and "LogicKillCounter:GetOriginWeaponIdByFeatureItemId featureCfg is nil")
    return nil
  end
  return featureCfg.WeaponID
end
function LogicKillCounter:CheckIsSameWeaponCounter(featureItemid1, featureItemid2)
  if featureItemid1 == featureItemid2 then
    log(bWriteLog and "LogicKillCounter:CheckIsSameWeaponCounter featureItemid1 == featureItemid2")
    return true
  end
  log(bWriteLog and "LogicKillCounter:CheckIsSameWeaponCounter featureItemid1:" .. tostring(featureItemid1) .. " featureItemid2:" .. tostring(featureItemid2))
  if not featureItemid1 or not featureItemid2 then
    log(bWriteLog and "LogicKillCounter:CheckIsSameWeaponCounter one featureItemid is nil")
    return false
  end
  local weaponId1 = self:GetOriginWeaponIdByFeatureItemId(featureItemid1)
  local weaponId2 = self:GetOriginWeaponIdByFeatureItemId(featureItemid2)
  if weaponId1 and weaponId2 and weaponId1 == weaponId2 then
    log(bWriteLog and "LogicKillCounter:CheckIsSameWeaponCounter true")
    return true
  else
    log(bWriteLog and "LogicKillCounter:CheckIsSameWeaponCounter false")
    return false
  end
end
function LogicKillCounter:PutOnKillCounterByFeatureItemId(featureItemid)
  if not featureItemid then
    log(bWriteLog and "LogicKillCounter:PutOnKillCounterByFeatureItemId featureItemid is nil")
    return
  end
  local weaponId = self:GetOriginWeaponIdByFeatureItemId(featureItemid)
  self:PutOnKillCounter(weaponId, featureItemid)
end
function LogicKillCounter:PutOnKillCounter(weaponId, featureItemid)
  if not weaponId or not featureItemid then
    log(bWriteLog and "LogicKillCounter:PutOnKillCounter params is nil")
    return
  end
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_arm_accumulate_feature_req(EnumOperateType.PotOn, featureItemid, weaponId)
end
function LogicKillCounter:PutOffKillCounter(weaponId, featureItemid)
  if not weaponId then
    log(bWriteLog and "LogicKillCounter:PutOnKillCounter params is nil")
    return
  end
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_arm_accumulate_feature_req(EnumOperateType.PotOff, featureItemid, weaponId)
end
function LogicKillCounter:GetMyKillCounterNum(featureItemid)
  local uid = tonumber(DataMgr.roleData.uid)
  if not featureItemid then
    log(bWriteLog and "LogicKillCounter:GetMyKillCounterNum params invalid")
    return 0
  end
  if not (self.uidTokillInfoMap and self.uidTokillInfoMap[uid]) or not self.uidTokillInfoMap[uid].item_info then
    log(bWriteLog and "LogicKillCounter:GetMyKillCounterNum invalid data")
    return 0
  end
  return self.uidTokillInfoMap[uid].item_info[featureItemid] or 0
end
function LogicKillCounter:GetMyEquipedKillCounterId(weaponId)
  if not weaponId then
    log(bWriteLog and "LogicKillCounter:GetMyEquipedKillCounterId weaponId invalid")
    return nil
  end
  local uid = tonumber(DataMgr.roleData.uid)
  if not (self.uidTokillInfoMap and self.uidTokillInfoMap[uid]) or not self.uidTokillInfoMap[uid].arm_info then
    log(bWriteLog and "LogicKillCounter:GetMyEquipedKillCounterId invalid data")
    return nil
  end
  local UAvatarUtils = import("AvatarUtils")
  local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
  if not realWeaponId then
    log(bWriteLog and "LogicKillCounter:GetMyEquipedKillCounterId realWeaponId invalid")
    return nil
  end
  return self.uidTokillInfoMap[uid].arm_info[realWeaponId]
end
function LogicKillCounter:GetEquipedKillCounterId(uid, weaponId)
  local uid = tonumber(uid)
  if not weaponId or not uid then
    log(bWriteLog and "LogicKillCounter:GetEquipedKillCounterId weaponId invalid")
    return nil
  end
  if not (self.uidTokillInfoMap and self.uidTokillInfoMap[uid]) or not self.uidTokillInfoMap[uid].arm_info then
    log(bWriteLog and "LogicKillCounter:GetEquipedKillCounterId invalid data")
    return nil
  end
  local UAvatarUtils = import("AvatarUtils")
  local realWeaponId = UAvatarUtils.GetAdjustWeaponID(weaponId)
  if not realWeaponId then
    log(bWriteLog and "LogicKillCounter:GetEquipedKillCounterId realWeaponId invalid")
    return nil
  end
  return self.uidTokillInfoMap[uid].arm_info[realWeaponId]
end
function LogicKillCounter:ReqAccumulationKillInfo(targetUid)
  targetUid = tonumber(targetUid)
  if not targetUid then
    return
  end
  if self.uidTokillInfoMap and self.uidTokillInfoMap[targetUid] and self.uidTokillInfoMap[targetUid].kill_info then
    EventSystem:postEvent(EVENTTYPE_WEAPON_KILLCOUNTER, EVENTID_WEAPON_KILLCOUNTER_INFO_RSP, targetUid)
    return
  end
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_get_accumulation_kill_info_req(targetUid)
end
function LogicKillCounter:GetWeaponIdBySkinId(weaponSkinID)
  if not weaponSkinID then
    log(bWriteLog and "LogicKillCounter:GetWeaponIdBySkinId weaponSkinID invalid")
    return
  end
  local OriginID = weaponSkinID
  local SkinCfg = CDataTable.GetTableData("WeaponSkinMapping", weaponSkinID)
  if SkinCfg and SkinCfg.WeaponID then
    OriginID = SkinCfg.WeaponID
  end
  log(bWriteLog and "LogicKillCounter:GetWeaponIdBySkinId weaponSkinID:" .. tostring(weaponSkinID) .. " OriginID:" .. tostring(OriginID))
  return OriginID
end
function LogicKillCounter:GetPreviewVideoPath(featureItemid)
  local KillCounterShowCfg = CDataTable.GetTableData("KillCounterShowCfg", featureItemid)
  if not KillCounterShowCfg then
    return nil
  end
  return KillCounterShowCfg.PreviewVideoPath
end
function LogicKillCounter:CheckHasWeaponKillCounter(weaponId)
  local uid = tonumber(DataMgr.roleData.uid)
  if not weaponId then
    log(bWriteLog and "LogicKillCounter:CheckHasWeaponKillCounter params invalid")
    return false
  end
  if not (self.uidTokillInfoMap and self.uidTokillInfoMap[uid]) or not self.uidTokillInfoMap[uid].item_info then
    log(bWriteLog and "LogicKillCounter:CheckHasWeaponKillCounter invalid data")
    return false
  end
  local featureCfgs = CDataTable.GetTableByFilter("KillCounterToWeaponIdCfg", "WeaponID", weaponId)
  if not featureCfgs then
    log(bWriteLog and "LogicKillCounter:CheckHasWeaponKillCounter featureCfgs is nil")
    return false
  end
  local itemInfo = self.uidTokillInfoMap[uid].item_info
  for _, featureCfg in pairs(featureCfgs) do
    if itemInfo[featureCfg.FeatureID] and itemInfo[featureCfg.FeatureID] > 0 then
      log(bWriteLog and "LogicKillCounter:CheckHasWeaponKillCounter true")
      return true
    end
  end
  log(bWriteLog and "LogicKillCounter:CheckHasWeaponKillCounter false")
  return false
end
function LogicKillCounter:GetKillCounterItemJumpUrl(weaponSkinId)
  local weaponId = self:GetWeaponIdBySkinId(weaponSkinId)
  local featureId = self:GetBaseKillCounterIdByWeaponId(weaponId)
  if not featureId then
    log(bWriteLog and "LogicKillCounter:GetKillCounterItemJumpUrl featureId is nil")
    return nil
  end
  local featureCfg = CDataTable.GetTableData("KillCounterToWeaponIdCfg", featureId)
  if not (featureCfg and featureCfg.ItemJumpUrl) or featureCfg.ItemJumpUrl == "" then
    log(bWriteLog and "LogicKillCounter:GetKillCounterItemJumpUrl featureCfg is nil or ItemJumpUrl is empty")
    return nil
  end
  return featureCfg.ItemJumpUrl
end
function LogicKillCounter:GetOneWeaponKillCountInBattle(uid, weaponId)
  if not uid or not weaponId then
    log(bWriteLog and "LogicKillCounter:GetOneWeaponKillCountInBattle invalid params")
    return
  end
  local curBattleCount = self:GetCurBattleWeaponKillCountByUid(uid, weaponId)
  local lastCount = self:GetWeaponKillCountByUid(uid, weaponId)
  if lastCount < 0 then
    lastCount = 0
  end
  log(bWriteLog and "LogicKillCounter:GetOneWeaponKillCountInBattle curBattleCount:" .. tostring(curBattleCount) .. " lastCount:" .. tostring(lastCount))
  return curBattleCount + lastCount
end
function LogicKillCounter:IncrementalUpdateWeaponKillCount(uid, incrementalData)
  if not uid or not incrementalData then
    log(bWriteLog and "LogicKillCounter:IncrementalUpdateWeaponKillCount invalid params")
    return
  end
  log(bWriteLog and "LogicKillCounter:IncrementalUpdateWeaponKillCount uid:" .. tostring(uid))
  log_tree(bWriteLog and "LogicKillCounter:IncrementalUpdateWeaponKillCount incrementalData:", incrementalData)
  self.uidToCurBattlekillCountListMap = self.uidToCurBattlekillCountListMap or {}
  self.uidToCurBattlekillCountListMap[uid] = self.uidToCurBattlekillCountListMap[uid] or {}
  local curBattlekillCount = self.uidToCurBattlekillCountListMap[uid]
  for weaponId, killCount in pairs(incrementalData) do
    curBattlekillCount[weaponId] = curBattlekillCount[weaponId] or 0
    curBattlekillCount[weaponId] = curBattlekillCount[weaponId] + killCount
  end
end
function LogicKillCounter:AddOneWeaponKillCount(uid, weaponId, addCount)
  if not (uid and weaponId) or not addCount then
    log(bWriteLog and "LogicKillCounter:AddOneWeaponKillCount invalid params")
    return
  end
  self.uidToCurBattlekillCountListMap = self.uidToCurBattlekillCountListMap or {}
  self.uidToCurBattlekillCountListMap[uid] = self.uidToCurBattlekillCountListMap[uid] or {}
  local oldCount = self.uidToCurBattlekillCountListMap[weaponId] or 0
  self.uidToCurBattlekillCountListMap[weaponId] = oldCount + addCount
end
function LogicKillCounter:SetCurBattleWeaponKillCount(uid, killCountInfo)
  if not uid or not killCountInfo then
    log(bWriteLog and "LogicKillCounter:SetCurBattleWeaponKillCount invalid params")
    return
  end
  log(bWriteLog and "LogicKillCounter:SetCurBattleWeaponKillCount uid:" .. tostring(uid))
  log_tree(bWriteLog and "LogicKillCounter:SetCurBattleWeaponKillCount killCountInfo:", killCountInfo)
  self.uidToCurBattlekillCountListMap = self.uidToCurBattlekillCountListMap or {}
  self.uidToCurBattlekillCountListMap[uid] = killCountInfo
end
function LogicKillCounter:UpdateCurBattleOneWeaponKillCount(uid, weaponId, count)
  if not (uid and weaponId) or not count then
    log(bWriteLog and "LogicKillCounter:UpdateCurBattleOneWeaponKillCount invalid params")
    return
  end
  log(bWriteLog and "LogicKillCounter:UpdateCurBattleOneWeaponKillCount uid:" .. tostring(uid) .. " weaponId:" .. tostring(weaponId) .. " count:" .. tostring(count))
  self.uidToCurBattlekillCountListMap = self.uidToCurBattlekillCountListMap or {}
  self.uidToCurBattlekillCountListMap[uid] = self.uidToCurBattlekillCountListMap[uid] or {}
  self.uidToCurBattlekillCountListMap[uid][weaponId] = count
end
function LogicKillCounter:CheckEquipedWeaponCounter(uid, weaponId)
  if not uid or not weaponId then
    log(bWriteLog and "LogicKillCounter:CheckEquipedWeaponCounter invalid params")
    return false
  end
  log(bWriteLog and "LogicKillCounter:CheckEquipedWeaponCounter uid:" .. tostring(uid) .. " weaponId:" .. tostring(weaponId))
  if not (self.uidTokillInfoMap and self.uidTokillInfoMap[uid]) or not self.uidTokillInfoMap[uid].arm_info then
    log(bWriteLog and "LogicKillCounter:CheckEquipedWeaponCounter invalid uidTokillInfo")
    return false
  end
  local featureId = self.uidTokillInfoMap[uid].arm_info[weaponId]
  return featureId and 0 < featureId
end
function LogicKillCounter:CheckCounterShowInMainUI()
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local KillCounterShowData = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eKillCounterShowData)
  if not KillCounterShowData or KillCounterShowData.isMainUIShow == nil then
    log(bWriteLog and "LogicKillCounter:CheckCounterShowInMainUI KillCounterShowData.isMainUIShow == nil ")
    return true
  end
  log(bWriteLog and "LogicKillCounter:CheckCounterShowInMainUI KillCounterShowData.isMainUIShow: " .. tostring(KillCounterShowData.isMainUIShow))
  return KillCounterShowData.isMainUIShow
end
function LogicKillCounter:SetCounterMainUISwitch(bShow)
  bShow = bShow or false
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local KillCounterShowData = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eKillCounterShowData) or {}
  if KillCounterShowData.isMainUIShow == bShow then
    log(bWriteLog and "LogicKillCounter:SetCounterMainUISwitch same")
    return
  end
  KillCounterShowData.isMainUIShow = bShow
  LogicPlayerPrefs.SaveDataToFile_N(KillCounterShowData, PlayerPrefsConfig.eKillCounterShowData)
end
function LogicKillCounter:send_get_accumulation_kill_info_req(targetUid)
  targetUid = tonumber(targetUid)
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_get_accumulation_kill_info_req(targetUid)
end
function LogicKillCounter:on_get_accumulation_kill_info_rsp(uid, kill_counter_data)
  if not kill_counter_data or not uid then
    log(bWriteLog and "LogicKillCounter:on_get_accumulation_kill_info_rsp targetUid is nil")
    return
  end
  self.uidTokillInfoMap = self.uidTokillInfoMap or {}
  self.uidTokillInfoMap[uid] = kill_counter_data
  EventSystem:postEvent(EVENTTYPE_WEAPON_KILLCOUNTER, EVENTID_WEAPON_KILLCOUNTER_INFO_RSP, uid)
  local ResearchRedDot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ResearchRedDot)
  ResearchRedDot:SetKillCounterRedDot(kill_counter_data.item_info)
end
function LogicKillCounter:on_arm_accumulate_feature_rsp(cur_arm_list)
  if not cur_arm_list then
    log(bWriteLog and "LogicKillCounter:on_arm_accumulate_feature_rsp cur_arm_list is nil")
    return
  end
  local uid = tonumber(DataMgr.roleData.uid)
  if self.uidTokillInfoMap and self.uidTokillInfoMap[uid] then
    self.uidTokillInfoMap[uid].arm_info = cur_arm_list
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_KILLCOUNTER, EVENTID_WEAPON_KILLCOUNTER_EQUIP_UPDATE)
end
function LogicKillCounter:GetWeaponAndFeatureList()
  if self.weaponFeatureList then
    return self.weaponFeatureList
  end
  local KillCounterToWeaponIdCfg = CDataTable.GetTable("KillCounterToWeaponIdCfg")
  if not KillCounterToWeaponIdCfg then
    return {}
  end
  local tWeaponList = {}
  for _, cfg in pairs(KillCounterToWeaponIdCfg) do
    if cfg.WeaponID then
      tWeaponList[cfg.WeaponID] = tWeaponList[cfg.WeaponID] or {}
      table.insert(tWeaponList[cfg.WeaponID], cfg.FeatureID)
    end
  end
  table.sort(tWeaponList, function(a, b)
    return b < a
  end)
  log_tree(bWriteLog and "ItemUpgrade_KillCounter_UIBP:SetWeaponAndFeatureList tWeaponList:", tWeaponList)
  self.weaponFeatureList = tWeaponList
  return self.weaponFeatureList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicKillCounter)
return CModuleTemplate