local ItemConfig = {
  AKM_UpgradeItemID = 206101,
  M416_UpgradeItemID = 206102,
  P90_UpgradeItemID = 206103,
  MK12_UpgradeItemID = 206104,
  M24_UpgradeItemID = 206105,
  DP28_UpgradeItemID = 206106,
  M762_UpgradeItemID = 206107,
  UMP45_UpgradeItemID = 206108,
  SKS_UpgradeItemID = 206109,
  SinglePlayerReviveItemID = 602092,
  MelleeWeaponList = {
    108001,
    108004,
    108005
  }
}
ItemConfig.WeaponUpgradeSkill = {
  [ItemConfig.AKM_UpgradeItemID] = true,
  [ItemConfig.M416_UpgradeItemID] = true,
  [ItemConfig.P90_UpgradeItemID] = true,
  [ItemConfig.MK12_UpgradeItemID] = true,
  [ItemConfig.M24_UpgradeItemID] = true,
  [ItemConfig.DP28_UpgradeItemID] = true,
  [ItemConfig.M762_UpgradeItemID] = true,
  [ItemConfig.UMP45_UpgradeItemID] = true,
  [ItemConfig.SKS_UpgradeItemID] = true
}
ItemConfig.DisableSaveToSafetyBoxList = {1000075}
function ItemConfig.CanSaveToSafetyBox(TypeSpecificID)
  for _, ID in ipairs(ItemConfig.DisableSaveToSafetyBoxList) do
    if ID == TypeSpecificID then
      return false
    end
  end
  return true
end
return ItemConfig