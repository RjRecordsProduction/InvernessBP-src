local AttachToOtherConfig = {}
AttachToOtherConfig.WeaponBlackList = {
  107008,
  107009,
  107005
}
function AttachToOtherConfig.CheckIsWeaponInBlackList(weaponId)
  for k, v in pairs(AttachToOtherConfig.WeaponBlackList) do
    if v == weaponId then
      return true
    end
  end
  return false
end
return AttachToOtherConfig