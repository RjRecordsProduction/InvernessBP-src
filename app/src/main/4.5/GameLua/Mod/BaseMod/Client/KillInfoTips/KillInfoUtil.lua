local KillInfoUtil = {}
local KillInfoCfg = require("GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfoCfg")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local BackpackUtils = import("BackpackUtils")
local DefaultDamagePath = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_death.killfeed_cause_death"
function KillInfoUtil.GetWeaponIconPath(damageType, additionalParam, previousHealthStatus)
  if previousHealthStatus == ECharacterHealthStatus.FinishedLastBreath or previousHealthStatus == ECharacterHealthStatus.MAX then
    return
  end
  local iconPath = ""
  if KillInfoUtil.CheckIsSpecialWeapon(additionalParam) then
    iconPath = KillInfoUtil.GetIconPathByItemID(additionalParam)
  else
    iconPath = KillInfoUtil.GetIconPathByItemID(additionalParam)
    if not iconPath or iconPath == "" then
      iconPath = KillInfoUtil.GetKillIconPathByDamageType(damageType)
    end
  end
  if not iconPath or iconPath == "" then
    iconPath = DefaultDamagePath
  end
  return iconPath
end
function KillInfoUtil.GetSkillIconPath(damageType, additionalParam, previousHealthStatus)
  if previousHealthStatus == ECharacterHealthStatus.FinishedLastBreath or previousHealthStatus == ECharacterHealthStatus.MAX then
    return ""
  end
  if additionalParam == nil or additionalParam == 0 then
    print(bWriteLog and string.format("KillInfoUtil.GetSkillIconPath additionalParam is nil"))
    return ""
  end
  local SkillID = additionalParam
  print(bWriteLog and string.format("KillInfoUtil.GetSkillIconPath skillid:%d", SkillID))
  local iconPath = ""
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local SkillConfig = GamePlayTools.GetCurrentConfig("SkillConfig")
  if SkillConfig and SkillConfig[SkillID] and SkillConfig[SkillID].KillInfoIcon then
    iconPath = SkillConfig[SkillID].KillInfoIcon
  end
  return iconPath
end
function KillInfoUtil.CheckIsSpecialWeapon(AdditionalParam)
  for _, v in ipairs(KillInfoCfg.AdditionalWeaponList) do
    if v == AdditionalParam then
      return true
    end
  end
  return false
end
function KillInfoUtil.GetIconPathByItemID(itemID)
  local itemRecord = CDataTable.GetTableData("Item", itemID)
  if not (itemRecord and itemRecord.ItemID ~= nil and not (itemRecord.ItemID <= 0) and itemRecord.KillWhiteIcon) or 0 >= #itemRecord.KillWhiteIcon then
    return ""
  end
  return itemRecord.KillWhiteIcon
end
function KillInfoUtil.GetKillIconPathByDamageType(damageType)
  return KillInfoCfg.DamageType2WeaponIconMap[damageType]
end
function KillInfoUtil.GetGeneralKillIconPath()
  return KillInfoCfg.DamageType2WeaponGeneralIconPath
end
return KillInfoUtil