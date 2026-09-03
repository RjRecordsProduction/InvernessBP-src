local SkillInstData = {
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 602115},
      CurrentWeapon01 = {ItemType = 6, ItemID = 602115},
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_UI/AFD/2300/Fireworks/BluePrints/BP_Grenade_Fireworks230.BP_Grenade_Fireworks230_C"
        }
      },
      AttachActor01 = {bWidgetEnabled = false}
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 602115}
    },
    [2] = {
      HandleItemLimit01 = {ItemID = 602115}
    },
    [3] = {
      ConsumeHandleItem01 = {
        ItemID = 602115,
        Type = 6,
        Count = 1,
        IsNeedNotifyLobbyServer = true
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 602115}
      }
    },
    [4] = {
      HandleItemLimit01 = {ItemID = 602115}
    },
    [5] = {
      HandleItemLimit01 = {ItemID = 602115}
    },
    [6] = {
      ConsumeHandleItem01 = {
        ItemID = 602115,
        Type = 6,
        Count = 1,
        IsNeedNotifyLobbyServer = true
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 602115}
      }
    }
  }
}
return SkillInstData