local collect_pet_module = {}
local 
function collect_pet_module:DefineAndResetData()
  self.petTb = {}
  self.petClothesTb = {}
  self.petAwardMap = nil
end
function collect_pet_module:GetListOfAvailableRewards()
  local result = {}
  local awards = self:GetAllPetSeriesData()
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  local score = self:GetCollectPetScore()
  for Level, cfg in pairs(awards) do
    for i = 1, 2 do
      local status = collect_library_module:GetSeriesAwardStatus(nil, Level, i, score, cfg.MinScore, 6)
      if cfg["Drop" .. i] ~= 0 and cfg["CostNum" .. i] == 0 and status == ActivityProgressStatus.Done then
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
  return result
end
function collect_pet_module:GetAllPetSeriesData()
  if self.petAwardMap then
    return self.petAwardMap
  end
  self.petAwardMap = {}
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local list = collect_module:GetSplitTable("CollectPetAward")
  for _, v in pairs(list) do
    self.petAwardMap[tonumber(v.Level)] = v
  end
  table.sort(self.petAwardMap, function(a, b)
    if a.Level and b.Level then
      return a.Level < b.Level
    end
    return true
  end)
  return self.petAwardMap
end
function collect_pet_module:GetPetOwnedData()
  return self.petTb
end
function collect_pet_module:GetPetClotheOwnedData()
  return self.petClothesTb
end
function collect_pet_module:HasRed()
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  local petAwards = self:GetAllPetSeriesData()
  local score = self:GetCollectPetScore()
  for Level, cfg in pairs(petAwards) do
    for i = 1, 2 do
      if cfg["Drop" .. i] ~= 0 and cfg["CostNum" .. i] == 0 and not collect_encryption_module:IsEncryption(cfg["Drop" .. i]) then
        local status = collect_library_module:GetSeriesAwardStatus(nil, Level, i, score, cfg.MinScore, 6)
        if status == ActivityProgressStatus.Done then
          return true
        end
      end
    end
  end
  return false
end
function collect_pet_module:GetCollectPetScore()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module.collect_data then
    return collect_module.collect_data.pet_score or 0
  end
  return 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_pet_module)
return CModuleTemplate