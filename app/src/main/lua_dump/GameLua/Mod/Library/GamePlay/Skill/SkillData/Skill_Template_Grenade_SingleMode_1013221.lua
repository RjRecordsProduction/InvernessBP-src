local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 601001, ItemId = 601001},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 601001,
        ItemId = 601001
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/Grenade_Medicine/GrenadeActor/BP_GrenadePackage_Drink.BP_GrenadePackage_Drink_C"
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 601001, ItemId = 601001}
    },
    [2] = {
      ConsumeHandleItem01 = {
        ItemID = 601001,
        ItemId = 601001,
        bCalTakeItemFlow = false
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 601001}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 601001, ItemId = 601001}
    }
  }
}
return SkillInstData