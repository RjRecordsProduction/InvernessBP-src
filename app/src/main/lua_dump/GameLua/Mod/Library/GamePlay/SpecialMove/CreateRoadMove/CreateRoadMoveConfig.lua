local EPawnState = import("EPawnState")
local Config = {
  MoveAnimInstanceID = 80,
  CreateRoadBeginSkillID = 4100011,
  CreateRoadEndSkillID = 4100012,
  CreateRoadDuration = 30,
  CreateRoadStateDuration = 5,
  CreateRoadBuffID = 60467,
  MeshBrokenParticle = "/Game/Library/Res/Skills/IceRoad/Arts_Effect/Par/P_IceRoad_End_L4.P_IceRoad_End_L4",
  OnRoadKnockDownSomeone = 1880,
  OnRoadBeKnockedDown = 1881,
  UseCreateRoadSkill = 1920,
  PartDestroyEffect = "/Game/Library/Res/Skills/IceRoad/WwiseEvent/Iceworld4_IceRoad_410/Play_Iceworld4_IceRoad_Break.Play_Iceworld4_IceRoad_Break",
  AllDestroyEffect = "/Game/Library/Res/Skills/IceRoad/WwiseEvent/Iceworld4_IceRoad_410/Play_Iceworld4_IceRoad_Break_End.Play_Iceworld4_IceRoad_Break_End"
}
return Config