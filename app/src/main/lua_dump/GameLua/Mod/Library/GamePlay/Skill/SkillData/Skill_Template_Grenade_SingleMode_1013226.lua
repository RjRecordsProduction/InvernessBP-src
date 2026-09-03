local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 601006, ItemId = 601006},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 601006,
        ItemId = 601006
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/Grenade_Medicine/GrenadeActor/BP_GrenadePackage_FirstAidbox.BP_GrenadePackage_FirstAidbox_C"
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 601006, ItemId = 601006}
    },
    [2] = {
      ConsumeHandleItem01 = {
        ItemID = 601006,
        ItemId = 601006,
        bCalTakeItemFlow = false
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 601006}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 601006, ItemId = 601006}
    }
  }
}
return SkillInstData