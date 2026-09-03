local UpgradeCfg = {
  AKM_ID = 101001,
  M416_ID = 101004,
  P90_ID = 102105,
  MK12_ID = 103100,
  M24_ID = 103002,
  AKM_UpgradeItemID = 206101,
  M416_UpgradeItemID = 206102,
  P90_UpgradeItemID = 206103,
  MK12_UpgradeItemID = 206104,
  M24_UpgradeItemID = 206105,
  UpgradingText = 37278,
  UpgradeFinishedText = 37279,
  AKM_UpgredeStrings = {34127, 34136},
  M416_UpgredeStrings = {34133, 34146},
  P90_UpgredeStrings = {34130},
  MK12_UpgredeStrings = {34147, 34145},
  M24_UpgredeStrings = {34148, 34136}
}
UpgradeCfg.UpgradeItemID = {
  [UpgradeCfg.AKM_ID] = UpgradeCfg.AKM_UpgradeItemID,
  [UpgradeCfg.M416_ID] = UpgradeCfg.M416_UpgradeItemID,
  [UpgradeCfg.P90_ID] = UpgradeCfg.P90_UpgradeItemID,
  [UpgradeCfg.MK12_ID] = UpgradeCfg.MK12_UpgradeItemID,
  [UpgradeCfg.M24_ID] = UpgradeCfg.M24_UpgradeItemID
}
UpgradeCfg.WeaponUpgradeStrings = {
  [UpgradeCfg.AKM_ID] = UpgradeCfg.AKM_UpgredeStrings,
  [UpgradeCfg.M416_ID] = UpgradeCfg.M416_UpgredeStrings,
  [UpgradeCfg.P90_ID] = UpgradeCfg.P90_UpgredeStrings,
  [UpgradeCfg.MK12_ID] = UpgradeCfg.MK12_UpgredeStrings,
  [UpgradeCfg.M24_ID] = UpgradeCfg.M24_UpgredeStrings
}
UpgradeCfg.WeaponUpgradeTime = {
  [UpgradeCfg.AKM_ID] = 6,
  [UpgradeCfg.M416_ID] = 6,
  [UpgradeCfg.P90_ID] = 6,
  [UpgradeCfg.MK12_ID] = 6,
  [UpgradeCfg.M24_ID] = 6
}
UpgradeCfg.UpgradeItemStrings = {
  [UpgradeCfg.AKM_UpgradeItemID] = UpgradeCfg.AKM_UpgredeStrings,
  [UpgradeCfg.M416_UpgradeItemID] = UpgradeCfg.M416_UpgredeStrings,
  [UpgradeCfg.P90_UpgradeItemID] = UpgradeCfg.P90_UpgredeStrings,
  [UpgradeCfg.MK12_UpgradeItemID] = UpgradeCfg.MK12_UpgredeStrings,
  [UpgradeCfg.M24_UpgradeItemID] = UpgradeCfg.M24_UpgredeStrings
}
UpgradeCfg.UpgradeCfg = {
  [UpgradeCfg.AKM_UpgradeItemID] = {
    [UpgradeCfg.AKM_ID] = {
      ModifAttr = {
        {
          AttrName = "AccessoriesVRecoilFactor",
          OP = 1,
          Value = -0.08
        },
        {
          AttrName = "AccessoriesHRecoilFactor",
          OP = 1,
          Value = -0.05
        },
        {
          AttrName = "AnimationKick",
          OP = 1,
          Value = -0.2
        },
        {
          AttrName = "RecoilKickADS",
          OP = 1,
          Value = -0.1
        },
        {
          AttrName = "MaxBulletNumInOneClip",
          OP = 2,
          Value = 3
        }
      }
    }
  },
  [UpgradeCfg.M416_UpgradeItemID] = {
    [UpgradeCfg.M416_ID] = {
      ModifAttr = {
        {
          AttrName = "ReloadTime",
          OP = 1,
          Value = -0.1
        },
        {
          AttrName = "ReloadTimeTactical",
          OP = 1,
          Value = -0.1
        },
        {
          AttrName = "ReloadTimeMagOut",
          OP = 1,
          Value = -0.1
        },
        {
          AttrName = "ReloadTimeMagIn",
          OP = 1,
          Value = -0.1
        },
        {
          AttrName = "SpeedRate",
          OP = 1,
          Value = 0.0328,
          Special = 1
        }
      }
    }
  },
  [UpgradeCfg.P90_UpgradeItemID] = {
    [UpgradeCfg.P90_ID] = {
      ModifAttr = {
        {
          AttrName = "GameDeviationFactor",
          OP = 1,
          Value = -0.2
        }
      }
    }
  },
  [UpgradeCfg.MK12_UpgradeItemID] = {
    [UpgradeCfg.MK12_ID] = {
      ModifAttr = {
        {
          AttrName = "RangeModifier",
          OP = 2,
          Value = 0.03
        },
        {
          AttrName = "ReferenceDistance",
          OP = 2,
          Value = 35000
        },
        {
          AttrName = "WeaponHitPartCoffLimbs",
          OP = 2,
          Value = 0.125
        },
        {
          AttrName = "WeaponHitPartCoffHand",
          OP = 2,
          Value = 0.125
        },
        {
          AttrName = "WeaponHitPartCoffFoot",
          OP = 2,
          Value = 0.075
        }
      }
    }
  },
  [UpgradeCfg.M24_UpgradeItemID] = {
    [UpgradeCfg.M24_ID] = {
      ModifAttr = {
        {
          AttrName = "PreFireTime",
          OP = 1,
          Value = -0.15
        },
        {
          AttrName = "PreFireAnimScale",
          OP = 1,
          Value = 0.2
        },
        {
          AttrName = "ShootInterval",
          OP = 1,
          Value = -0.15
        },
        {
          AttrName = "BurstShootInterval",
          OP = 1,
          Value = -0.15
        },
        {
          AttrName = "MaxBulletNumInOneClip",
          OP = 2,
          Value = 1
        }
      }
    }
  }
}
UpgradeCfg.Target = UpgradeCfg.UpgradeCfg
return UpgradeCfg