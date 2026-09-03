local collect_gun_module = {}
function collect_gun_module:DefineAndResetData()
  self.WeaponsCfg = {}
end
function collect_gun_module:GetListOfAvailableRewards()
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  local configs = self:GetWeaponsCfg()
  local result, seriesID = {}
  local curScore = 0
  for gunType, levels in pairs(configs) do
    local score = self:GetWeaponScore(gunType)
    if 0 < score then
      for level, cfg in ipairs(levels) do
        curScore = tonumber(cfg.Score)
        for i = 1, 2 do
          if 0 < cfg["Drop" .. i] and cfg["Cost" .. i] == 0 then
            local status = collect_library_module:GetGunAwardStatus(level, i, cfg.Gun, score)
            if status == ActivityProgressStatus.Done then
              seriesID = seriesID or gunType
              table.insert(result, {
                itemId = cfg["Drop" .. i],
                num = cfg["Num" .. i],
                time = cfg["Time" .. i],
                idx = cfg.Level,
                subIdx = i
              })
            end
          end
        end
        if score < curScore then
          break
        end
      end
    end
  end
  return result, seriesID
end
function collect_gun_module:HasRed()
  local configs = self:GetWeaponsCfg()
  for gunType, levels in pairs(configs) do
    if self:IsRedOneGun(gunType, levels) then
      return true
    end
  end
  return false
end
function collect_gun_module:IsRedOneGun(gunType)
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  local score = self:GetWeaponScore(gunType)
  if score <= 0 then
    return false
  end
  local configs = self:GetWeaponsCfg()
  local curScore = 0
  local levels = configs[gunType]
  for level, v in ipairs(levels) do
    curScore = tonumber(v.Score)
    for subIndex = 1, 2 do
      if 0 < v["Drop" .. subIndex] then
        local status = collect_library_module:GetGunAwardStatus(level, subIndex, v.Gun, score)
        if status == ActivityProgressStatus.Done then
          log_warning(bWriteLog and "   OneGunIsRed: " .. tostring(level) .. ": " .. tostring(gunType))
          return true
        end
      end
    end
    if score < curScore then
      break
    end
  end
  return false
end
function collect_gun_module:GetWeaponScore(gunType)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module:GetCollectData()
  if not collect_data then
    return 0
  end
  local weapon_score = collect_data.weapon_score or {}
  return weapon_score[gunType] or 0
end
function collect_gun_module:GetWeaponsCfg()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not next(self.WeaponsCfg) then
    for _, v in pairs(collect_module:GetSplitTable("CollectGunCfg", collect_module.E_ColCfgMode.JK)) do
      local level = v.Level
      if 0 < level then
        local gunType = v.Gun
        if not self.WeaponsCfg[gunType] then
          self.WeaponsCfg[gunType] = {}
        end
        self.WeaponsCfg[gunType][level] = v
      end
    end
  end
  return self.WeaponsCfg
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_gun_module)
return CModuleTemplate