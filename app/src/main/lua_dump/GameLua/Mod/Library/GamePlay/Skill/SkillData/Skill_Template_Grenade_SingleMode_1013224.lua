local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 601004, ItemId = 601004},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 601004,
        ItemId = 601004
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/Grenade_Medicine/GrenadeActor/BP_GrenadePackage_Bandage.BP_GrenadePackage_Bandage_C"
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 601004, ItemId = 601004}
    },
    [2] = {
      ConsumeHandleItem01 = {
        ItemID = 601004,
        ItemId = 601004,
        bCalTakeItemFlow = false
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 601004}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 601004, ItemId = 601004}
    }
  }
}
return SkillInstData