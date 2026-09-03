local ESkillActionRole = import("ESkillActionRole")
local SkillInstData = {
  Inst = {
    [0] = {
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Projectile/FragGrenade/BP_Projectile_FragGrenade.BP_Projectile_FragGrenade_C"
        }
      }
    },
    [1] = {
      AttachActor01 = {bWidgetEnabled = true}
    },
    [2] = {
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602004}
      }
    },
    [3] = {
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602004}
      },
      ["/Script/Skill.UTSkillAction_Lua"] = {
        LuaFilePath = "GameLua.Mod.BaseMod.GamePlay.Skill.Action.SkillAction_GrenadeThrowReport",
        BaseData = {
          ActionRole = ESkillActionRole.ESAR_AutonomousAuthority
        }
      }
    },
    [4] = {
      AttachActor01 = {bWidgetEnabled = true}
    },
    [5] = {
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602004}
      }
    },
    [6] = {
      ReportCollectedEventData01 = {
        CollectedEventDataGetter = {TypeSpecificID = 602004}
      }
    }
  }
}
return SkillInstData