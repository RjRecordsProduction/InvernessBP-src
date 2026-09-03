local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 602003, ItemId = 602003},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 602003,
        ItemId = 602003
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Projectile/BurnGrenade/BP_Projectile_BurnGrenade.BP_Projectile_BurnGrenade_C"
        }
      },
      AttachActor01 = {bWidgetEnabled = false}
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 602003, ItemId = 602003},
      ["/Script/Addons.UTSkillAppearance_RomoveParticle"] = {
        ParticleCompTag = "Flame",
        UndoRemove = true,
        BaseData = {DelayTime = 0.05}
      },
      ["/Script/Addons.UTSkillAppearance_AddParticle"] = {
        TemplateParticle_Effect = "/Game/Arts_Effect/ParticleSystems/Grenade/P_Grenade_Fire_Trail_01.P_Grenade_Fire_Trail_01",
        bMustAttach = false,
        bUndoRemove = true,
        HangMeshTagName = "WeaponMeshComp",
        ParticleCompTag = "Flame",
        LocationPosition = {
          X = 0,
          Y = 0,
          Z = 20
        },
        FPPScale = {
          X = 0.3,
          Y = 0.3,
          Z = 0.3
        },
        FPPLocationPosition = {
          X = 0,
          Y = 0,
          Z = 17
        },
        BaseData = {DelayTime = 0.15}
      }
    },
    [2] = {
      HandleItemLimit01 = {ItemID = 602003, ItemId = 602003},
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602003}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 602003, ItemId = 602003},
      AttrModify01 = {
        AttrModifier = {ModifierValue = 602003}
      },
      ["/Script/Addons.UTSkillAppearance_RomoveParticle"] = {
        ParticleCompTag = "Flame",
        UndoRemove = true,
        BaseData = {DelayTime = 0.15}
      },
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602003}
      }
    },
    [4] = {
      HandleItemLimit01 = {ItemID = 602003, ItemId = 602003},
      ["/Script/Addons.UTSkillAppearance_RomoveParticle"] = {
        ParticleCompTag = "Flame",
        UndoRemove = true,
        BaseData = {DelayTime = 0.05}
      },
      ["/Script/Addons.UTSkillAppearance_AddParticle"] = {
        TemplateParticle_Effect = "/Game/Arts_Effect/ParticleSystems/Grenade/P_Grenade_Fire_Trail_01.P_Grenade_Fire_Trail_01",
        bMustAttach = false,
        HangMeshTagName = "WeaponMeshComp",
        ParticleCompTag = "Flame",
        LocationPosition = {
          X = 0,
          Y = 0,
          Z = 20
        },
        FPPScale = {
          X = 0.3,
          Y = 0.3,
          Z = 0.3
        },
        FPPLocationPosition = {
          X = 0,
          Y = 0,
          Z = 17
        },
        BaseData = {DelayTime = 0.15}
      }
    },
    [5] = {
      HandleItemLimit01 = {ItemID = 602003, ItemId = 602003},
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602003}
      }
    },
    [6] = {
      ConsumeHandleItem01 = {ItemID = 602003, ItemId = 602003},
      AttrModify01 = {
        AttrModifier = {ModifierValue = 602003}
      },
      ["/Script/Addons.UTSkillAppearance_RomoveParticle"] = {
        ParticleCompTag = "Flame",
        UndoRemove = true,
        BaseData = {DelayTime = 0.15}
      },
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602003}
      }
    },
    [7] = {
      ConsumeHandleItem01 = {ItemID = 602003, ItemId = 602003}
    },
    [8] = {
      ["/Script/Addons.UTSkillAppearance_RomoveParticle"] = {ParticleCompTag = "Flame"}
    },
    [9] = {
      ["/Script/Addons.UTSkillAppearance_RomoveParticle"] = {ParticleCompTag = "Flame"}
    }
  }
}
return SkillInstData