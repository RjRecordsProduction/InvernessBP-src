local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 601003, ItemId = 601003},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 601003,
        ItemId = 601003
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/Grenade_Medicine/GrenadeActor/BP_GrenadePackage_Pills.BP_GrenadePackage_Pills_C"
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 601003, ItemId = 601003}
    },
    [2] = {
      ConsumeHandleItem01 = {
        ItemID = 601003,
        ItemId = 601003,
        bCalTakeItemFlow = false
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 601003}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 601003, ItemId = 601003}
    }
  }
}
return SkillInstData