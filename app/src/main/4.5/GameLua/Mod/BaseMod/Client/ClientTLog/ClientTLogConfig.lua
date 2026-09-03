local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
local ClientTLogConfig = {
  PlayerSkillUIClickFlow = {
    KeysOrder = {
      "bViewOtherSkill",
      "bClickSelectSkill",
      "bClickGuide",
      "ModID"
    }
  },
  PlayerUseWeaponCheckFlow = {
    ToString = ClientTLogUtil.ConvertDataContentToString_Comma_Dash
  },
  PlayerUpgradeWeaponUIClick = {
    KeysOrder = {
      "ItemUse",
      "ClickWeapon",
      "DropItemToWeapon",
      "ClickUpgradeInfoButton",
      "QuickUpgrade",
      "ModID"
    }
  },
  CollectDetailReportType = {
    KeysOrder = {
      "CollectScore",
      "NextLevelScore",
      "Level",
      "NextLevel",
      "QualityCount1",
      "QualityCount2",
      "QualityCount3",
      "QualityCount4",
      "CollectTypeCount1",
      "CollectTypeCount2",
      "CollectTypeCount3",
      "CollectTypeCount4"
    }
  }
}
return ClientTLogConfig