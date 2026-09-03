local HelmetArmor = require("GameLua.Mod.BaseMod.Client.PlayerInfoPanel.HelmetArmor.HelmetArmorConfig")
local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
function HelmetArmor:GetLevelImage(nLevel)
  return self.LevelImageMap[nLevel]
end
function HelmetArmor:GetHelmetLevelImage(nLevel)
  return self.HelmetLevelImageMap[nLevel]
end
function HelmetArmor:GetArmorLevelImage(nLevel)
  return self.ArmorLevelImageMap[nLevel]
end
function HelmetArmor:GetTargetAvatarCurDurability(AdditionalDataList)
  local truncate = function(x)
    if 0 < x then
      return math.floor(x)
    else
      return math.ceil(x)
    end
  end
  for _, AdditionalData in pairs(AdditionalDataList) do
    if AdditionalData.EDataType == EBattleItemAdditionalDataType.RemainingDuability then
      return truncate(AdditionalData.FloatData)
    end
  end
  return 0
end
function HelmetArmor:GetDynamicBattleFBTipsWidget()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    return MainControlBaseUI.DynamicBattleFBTipsWidget
  end
end