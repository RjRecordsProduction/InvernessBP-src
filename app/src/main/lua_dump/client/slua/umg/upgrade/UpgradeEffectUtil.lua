local UpgradeEffectUtil = {
  EffectResPathsMap = {},
  SubEffectResPathsMap = {},
  AllRelatedEffectResPathsMap = {}
}
function UpgradeEffectUtil:_GetRefTableAndColByEffectID(EffectID)
  local EffectCfg = CDataTable.GetTableData("ItemUpgradeEffectConfig", EffectID)
  if not EffectCfg then
    return {}, {}
  end
  local TableNames = {}
  local ColNames = {}
  if EffectCfg.HitEffect ~= "" then
    TableNames = {
      "ItemUpgradeEffectConfig",
      "AvatarWeaponHitFXData"
    }
    ColNames = {
      {"HitEffect"},
      {"EffectPath"}
    }
  elseif EffectCfg.KillEffect ~= "" or EffectCfg.DeadSmokeSeqPath ~= "" then
    TableNames = {
      "ItemUpgradeEffectConfig",
      "WeaponAttrBPTable"
    }
    ColNames = {
      {
        "KillEffect",
        "DeadSmokeSeqPath"
      },
      {
        "DeadInventoryBoxPath"
      }
    }
  elseif EffectCfg.DeadBox ~= "" then
    TableNames = {
      "ItemUpgradeEffectConfig",
      "WeaponAttrBPTable"
    }
    ColNames = {
      {"DeadBox"},
      {
        "DeadInventoryBoxPath"
      }
    }
  elseif EffectCfg.DeadShow ~= "" then
    TableNames = {
      "ItemUpgradeEffectConfig",
      "WeaponAttrBPTable"
    }
    ColNames = {
      {"DeadShow"},
      {
        "DeadInventoryBoxPath"
      }
    }
  elseif EffectCfg.KillBroadcast ~= "" then
    TableNames = {
      "WeaponAvatarBattleEffect"
    }
    ColNames = {
      {"BgPath", "EffectPath"}
    }
  elseif EffectCfg.DefenseSeqPath ~= "" then
    TableNames = {
      "ItemUpgradeEffectConfig"
    }
    ColNames = {
      {
        "DefenseSeqPath"
      }
    }
  end
  return TableNames, ColNames
end
function UpgradeEffectUtil:GetResListByEffectID(WeaponID, EffectID)
  if self.EffectResPathsMap[WeaponID] and self.EffectResPathsMap[WeaponID][EffectID] then
    log(bWriteLog and "UpgradeEffectUtil:GetResListByEffectID WeaponID" .. tostring(WeaponID) .. " EffectID " .. tostring(EffectID))
    log_tree("UpgradeEffectUtil:GetResListByEffectID", self.EffectResPathsMap[WeaponID][EffectID])
    return self.EffectResPathsMap[WeaponID][EffectID]
  end
  local TableNames, ColNames = self:_GetRefTableAndColByEffectID(EffectID)
  if not next(TableNames) or not next(ColNames) then
    return {}
  end
  local pak_util = require("client.common.pak_util")
  local PathList = {}
  local n = #TableNames
  for i = 1, n do
    if TableNames[i] and ColNames[i] and next(ColNames[i]) then
      local Paths
      if TableNames[i] == "ItemUpgradeEffectConfig" then
        Paths = pak_util.GetResPathListFromTable(TableNames[i], ColNames[i], EffectID)
      else
        Paths = pak_util.GetResPathListFromTable(TableNames[i], ColNames[i], WeaponID)
      end
      if Paths and next(Paths) then
        for _, Path in pairs(Paths) do
          table.insert(PathList, Path)
        end
      end
    end
  end
  if not self.EffectResPathsMap[WeaponID] then
    self.EffectResPathsMap[WeaponID] = {}
  end
  self.EffectResPathsMap[WeaponID][EffectID] = PathList
  log(bWriteLog and "UpgradeEffectUtil:GetResListByEffectID WeaponID" .. tostring(WeaponID) .. " EffectID " .. tostring(EffectID))
  log_tree("UpgradeEffectUtil:GetResListByEffectID", self.EffectResPathsMap[WeaponID][EffectID])
  return PathList
end
function UpgradeEffectUtil:IsResDownloadedByEffectID(WeaponID, EffectID, bPassiveDownload)
  local PathList = self:GetResListByEffectID(WeaponID, EffectID)
  local pak_util = require("client.common.pak_util")
  local bDownloaded = pak_util.IsPufferDownloadedByPathList(PathList, bPassiveDownload)
  return bDownloaded
end
function UpgradeEffectUtil:_GetRefTableAndColBySubEffectID(SubEffectID)
  local ItemUpgradeModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local TableNames = {}
  local ColNames = {}
  if SubEffectID == ItemUpgradeModule.ENUM_MaxWeaponSubEffectType.ExplosionFx then
    TableNames = {
      "GrenadeBindWeaponFx"
    }
    ColNames = {
      {"FxPath", "FxSeqPath"}
    }
  elseif SubEffectID == ItemUpgradeModule.ENUM_MaxWeaponSubEffectType.HitEffect then
    TableNames = {
      "ItemUpgradeEffectConfig",
      "AvatarWeaponHitFXData"
    }
    ColNames = {
      {"HitEffect"},
      {"EffectPath"}
    }
  elseif SubEffectID == ItemUpgradeModule.ENUM_MaxWeaponSubEffectType.KillBroadcast then
    TableNames = {
      "WeaponAvatarBattleEffect"
    }
    ColNames = {
      {"BgPath", "EffectPath"}
    }
  elseif SubEffectID == ItemUpgradeModule.ENUM_MaxWeaponSubEffectType.TeamKillBroadcast then
    TableNames = {
      "TeamKillBroadcast"
    }
    ColNames = {
      {"EffectPath"}
    }
  end
  return TableNames, ColNames
end
function UpgradeEffectUtil:GetResListBySubEffectID(WeaponID, SubEffectID)
  if self.SubEffectResPathsMap[WeaponID] and self.SubEffectResPathsMap[WeaponID][SubEffectID] then
    return self.SubEffectResPathsMap[WeaponID][SubEffectID]
  end
  local TableNames, ColNames = self:_GetRefTableAndColBySubEffectID(SubEffectID)
  if not next(TableNames) or not next(ColNames) then
    return {}
  end
  local pak_util = require("client.common.pak_util")
  local PathList = {}
  local n = #TableNames
  for i = 1, n do
    if TableNames[i] and ColNames[i] and next(ColNames[i]) then
      local Paths = pak_util.GetResPathListFromTable(TableNames[i], ColNames[i], WeaponID)
      if Paths and next(Paths) then
        for _, Path in pairs(Paths) do
          table.insert(PathList, Path)
        end
      end
    end
  end
  if not self.SubEffectResPathsMap[WeaponID] then
    self.SubEffectResPathsMap[WeaponID] = {}
  end
  self.SubEffectResPathsMap[WeaponID][SubEffectID] = PathList
  return PathList
end
function UpgradeEffectUtil:IsResDownloadedBySubEffectID(WeaponID, SubEffectID, bPassiveDownload)
  local PathList = self:GetResListBySubEffectID(WeaponID, SubEffectID)
  local pak_util = require("client.common.pak_util")
  local bDownloaded = pak_util.IsPufferDownloadedByPathList(PathList, bPassiveDownload)
  return bDownloaded
end
function UpgradeEffectUtil:GetAllRelatedResPathByWeaponID(WeaponID)
  if self.AllRelatedEffectResPathsMap[WeaponID] then
    return self.AllRelatedEffectResPathsMap[WeaponID]
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local GroupID = ItemUpgradeMgr:GetGroupID(WeaponID)
  if not GroupID then
    return {}
  end
  local GroupList = ItemUpgradeMgr:GetUpgradeGroupByID(GroupID)
  if not GroupList then
    return {}
  end
  local FinalPathList = {}
  for _, cfg in pairs(GroupList) do
    local EffectResPathList = self:GetResListByEffectID(cfg.ItemID, cfg.EffectID)
    for _, Path in pairs(EffectResPathList) do
      table.insert(FinalPathList, Path)
    end
    local SubEffectCfg = CDataTable.GetTableData("ItemUpgradeSubEffect", cfg.ItemID)
    if SubEffectCfg then
      for i = 1, 4 do
        local SubEffectType = SubEffectCfg["subEffect" .. tostring(i) .. "Type"]
        if SubEffectType and 0 < SubEffectType then
          local SubEffectResPathList = self:GetResListBySubEffectID(cfg.ItemID, SubEffectType)
          for _, Path in pairs(SubEffectResPathList) do
            table.insert(FinalPathList, Path)
          end
        end
      end
    end
    local TeamKillBroadcastCfg = CDataTable.GetTableData("TeamKillBroadcast", cfg.ItemID)
    if TeamKillBroadcastCfg and TeamKillBroadcastCfg.EffectPath then
      table.insert(FinalPathList, TeamKillBroadcastCfg.EffectPath)
    end
  end
  for _, cfg in pairs(GroupList) do
    self.AllRelatedEffectResPathsMap[cfg.ItemID] = FinalPathList
  end
  return FinalPathList
end
return UpgradeEffectUtil