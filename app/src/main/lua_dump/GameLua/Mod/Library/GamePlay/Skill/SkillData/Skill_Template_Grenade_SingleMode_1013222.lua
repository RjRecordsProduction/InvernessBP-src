local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 601002, ItemId = 601002},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 601002,
        ItemId = 601002
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/Grenade_Medicine/GrenadeActor/BP_GrenadePackage_Injection.BP_GrenadePackage_Injection_C"
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 601002, ItemId = 601002}
    },
    [2] = {
      ConsumeHandleItem01 = {
        ItemID = 601002,
        ItemId = 601002,
        bCalTakeItemFlow = false
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 601002}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 601002, ItemId = 601002}
    }
  }
}
return SkillInstData