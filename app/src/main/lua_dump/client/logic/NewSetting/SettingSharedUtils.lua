local SettingSharedUtils = {
  WeaponTypeName = {
    [0] = 4462,
    [1] = 180013,
    [2] = 180014,
    [3] = 180015,
    [4] = 180016,
    [5] = 180017,
    [6] = 180018,
    [7] = 180019,
    [8] = 180029,
    [9] = 4965
  },
  IgnoreWeapon = {
    [105003] = 1,
    [105004] = 1,
    [101901] = 1,
    [101903] = 1,
    [101908] = 1,
    [102901] = 1,
    [102903] = 1,
    [103902] = 1,
    [106908] = 1
  },
  AidList = {
    601006,
    601005,
    601004,
    601001,
    601003,
    601002
  },
  ThrowList = {
    602004,
    602002,
    602001,
    602003,
    602123
  },
  ScopeList = {
    203001,
    203002,
    203003,
    203014,
    203004,
    203015,
    203005
  },
  TPlanAmmoTable = {
    {
      3010011,
      3010012,
      3010013,
      3010014,
      3010015,
      3010016
    },
    {
      3020011,
      3020012,
      3020013,
      3020014,
      3020015,
      3020016
    },
    {
      3030011,
      3030012,
      3030013,
      3030014,
      3030015,
      3030016
    },
    {
      3040011,
      3040012,
      3040013,
      3040014,
      3040015,
      3040016
    },
    {
      3050011,
      3050012,
      3050013,
      3050014,
      3050015,
      3050016
    },
    {
      3010021,
      3010022,
      3010023,
      3010024,
      3010025,
      3010026
    },
    {
      3060011,
      3060012,
      3060013,
      3060014,
      3060015,
      3060016
    },
    {
      3060021,
      3060022,
      3060023,
      3060024,
      3060025,
      3060026
    },
    {
      3070501,
      3070502,
      3070503,
      3070504,
      3070505,
      3070506
    }
  }
}
function SettingSharedUtils.GetUserAutoLootCount(SettingConfig, ItemID, bTPlan)
  if not bTPlan then
    local Count = SettingConfig.PickUpCountSetting_Season:Get(ItemID)
    if Count then
      return Count
    end
    Count = SettingConfig.PickUpCountSetting_Drug:Get(ItemID)
    if Count then
      return Count
    end
    Count = SettingConfig.PickUpCountSetting_ThrowObj:Get(ItemID)
    if Count then
      return Count
    end
    Count = SettingConfig.PickUpCountSetting_MultipleMirror:Get(ItemID)
    if Count then
      return Count
    end
    if SettingConfig.PickUpCountSetting:Get(ItemID) then
      return SettingConfig.PickUpCountSetting:Get(ItemID)
    end
    Count = SettingConfig.PickUpCountSetting_Drug:Get(ItemID)
    if Count then
      return Count
    end
  end
  if SettingConfig.BulletPickUpCountSetting_XT:Get(ItemID) then
    return SettingConfig.BulletPickUpCountSetting_XT:Get(ItemID)
  end
  if SettingConfig.Drug_PickUpCountSetting_XT:Get(ItemID) then
    return SettingConfig.Drug_PickUpCountSetting_XT:Get(ItemID)
  end
  if SettingConfig.NormalInfilling_PickUpCountSetting_XT:Get(ItemID) then
    return SettingConfig.NormalInfilling_PickUpCountSetting_XT:Get(ItemID)
  end
  if SettingConfig.HalloweenInfilling_PickUpCountSetting_XT:Get(ItemID) then
    return SettingConfig.HalloweenInfilling_PickUpCountSetting_XT:Get(ItemID)
  end
  if SettingConfig.ThrowObj_PickUpCountSetting_XT:Get(ItemID) then
    return SettingConfig.ThrowObj_PickUpCountSetting_XT:Get(ItemID)
  end
  if SettingConfig.MultipleMirror_PickUpCountSetting_XT:Get(ItemID) then
    return SettingConfig.MultipleMirror_PickUpCountSetting_XT:Get(ItemID)
  end
  print(bWriteLog and "Setting_Pickup:GetSettingValue2 NotFind ItemID = " .. ItemID)
  return 0
end
local _PickupItemMapLookup
local GetPickupItemMapLookup = function()
  if _PickupItemMapLookup then
    return _PickupItemMapLookup
  end
  _PickupItemMapLookup = {}
  for _, id in ipairs(SettingSharedUtils.AidList) do
    _PickupItemMapLookup[id] = "PickUpCountSetting_Drug"
  end
  for _, id in ipairs(SettingSharedUtils.ThrowList) do
    _PickupItemMapLookup[id] = "PickUpCountSetting_ThrowObj"
  end
  for _, id in ipairs(SettingSharedUtils.ScopeList) do
    _PickupItemMapLookup[id] = "PickUpCountSetting_MultipleMirror"
  end
  return _PickupItemMapLookup
end
function SettingSharedUtils.SetUserAutoLootCount(SettingConfig, ItemID, Value)
  local lookup = GetPickupItemMapLookup()
  local mapName = lookup[ItemID]
  if mapName then
    SettingConfig[mapName]:Add(ItemID, Value)
  else
    SettingConfig.PickUpCountSetting:Add(ItemID, Value)
  end
end
function SettingSharedUtils.SetSeasonAutoLoot()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local TempNeedRemoveIDList = {}
  for ID, Count in pairs(SettingConfig.PickUpCountSetting_Season) do
    local Config = CDataTable.GetTableData("SeasonPickUpCountSetting", ID)
    if not Config then
      table.insert(TempNeedRemoveIDList, ID)
    end
  end
  for Index, ID in ipairs(TempNeedRemoveIDList) do
    SettingConfig.PickUpCountSetting_Season:Remove(ID)
  end
  local SeasonPickUpCountSetting = CDataTable.GetTable("SeasonPickUpCountSetting")
  if not SeasonPickUpCountSetting then
    print(bWriteLog and "SettingSharedUtils.SetSeasonAutoLoot GetTable Failed")
    return
  end
  for ID, Data in pairs(SeasonPickUpCountSetting) do
    if ID ~= 0 and ID ~= "0" then
      local Count = SettingConfig.PickUpCountSetting_Season:Get(ID)
      if not Count or Count < 0 then
        SettingConfig.PickUpCountSetting_Season:Add(ID, Data.PickUpDefaultCount)
      end
    end
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
return SettingSharedUtils