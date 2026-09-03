local SkillCDDefine = require("GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCDDefine")
local ESkillIconStatus = import("ESkillIconStatus")
local CreateRoadConfig = require("GameLua.Mod.Library.GamePlay.SpecialMove.CreateRoadMove.CreateRoadMoveConfig")
local Config = {
  SyncDisableSkillIDs = {
    4401001,
    4401002,
    4401003,
    4401006,
    4401007
  },
  [4400003] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 1.5}
      }
    }
  },
  [4400004] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 30}
      }
    }
  },
  [4400005] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 30}
      }
    }
  },
  [4402001] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 10}
      }
    }
  },
  [4402002] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 60}
      }
    }
  },
  [4402003] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 15}
      }
    }
  },
  [4402005] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 60}
      }
    }
  },
  [4402006] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 15}
      }
    }
  }
}
return Config