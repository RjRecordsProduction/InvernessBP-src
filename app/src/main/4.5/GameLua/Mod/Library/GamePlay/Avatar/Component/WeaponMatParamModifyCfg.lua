local ENUM_PRAM_TYPE = {
  Kill = 1,
  Loop = 2,
  LoopActivate = 3
}
local MatParamCfg = {
  [1101005037] = {
    ParamName = "Radius",
    ContinueTime = 2,
    StartValue = 0,
    EndValue = 100,
    Type = ENUM_PRAM_TYPE.Kill
  },
  [1101005038] = {
    ParamName = "Radius",
    ContinueTime = 2,
    StartValue = 0,
    EndValue = 100,
    Type = ENUM_PRAM_TYPE.Kill
  },
  [1101003134] = {
    CfgIndexList = {0},
    ParticleName = "MatLoop",
    Type = ENUM_PRAM_TYPE.Loop
  },
  [1103001136] = {
    ParticleName = "LoopActivate",
    Type = ENUM_PRAM_TYPE.LoopActivate,
    ActivateTime = 8
  },
  [1103001143] = {
    ParticleName = "LoopActivate",
    Type = ENUM_PRAM_TYPE.LoopActivate,
    ActivateTime = 8
  },
  [1103001144] = {
    ParticleName = "LoopActivate",
    Type = ENUM_PRAM_TYPE.LoopActivate,
    ActivateTime = 8
  },
  [1101008102] = {
    CfgIndexList = {0},
    ParticleName = "MatLoop",
    Type = ENUM_PRAM_TYPE.Loop
  },
  [1101008103] = {
    CfgIndexList = {0},
    ParticleName = "MatLoop",
    Type = ENUM_PRAM_TYPE.Loop
  },
  [1101008104] = {
    CfgIndexList = {0},
    ParticleName = "MatLoop",
    Type = ENUM_PRAM_TYPE.Loop
  }
}
return MatParamCfg