local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 601005, ItemId = 601005},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 601005,
        ItemId = 601005
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/Grenade_Medicine/GrenadeActor/BP_GrenadePackage_Firstaid.BP_GrenadePackage_Firstaid_C"
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 601005, ItemId = 601005}
    },
    [2] = {
      ConsumeHandleItem01 = {
        ItemID = 601005,
        ItemId = 601005,
        bCalTakeItemFlow = false
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 601005}
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 601005, ItemId = 601005}
    }
  }
}
return SkillInstData