local psSkill_sprint_config = {}
psSkill_sprint_config.ERoleID = {
  Aim = 1,
  Scan = 2,
  Heal = 3,
  Vehicle = 4,
  Kill = 5
}
psSkill_sprint_config.CDefaultRoleID = psSkill_sprint_config.ERoleID.Vehicle
psSkill_sprint_config.CTransmissionKey = "ZNQ8th_PlayerRoleID"
psSkill_sprint_config.SRoleConfig = {
  ID = 0,
  Name = 0,
  LabelColor = "",
  Icon = "",
  LobbyIcon = "",
  GrayIcon = "",
  LeftColorBg = "",
  RightColorBg = "",
  SelectSound = "",
  skillLevelList = {}
}
psSkill_sprint_config.SLevelSkillConfig = {
  RoleID = 0,
  LevelID = 0,
  SkillName = 0,
  SkillDesc = 0,
  SkillIcon = "",
  SkillTipPic1 = "",
  SkillTipPic2 = ""
}
psSkill_sprint_config.SLevelConfig = {
  ID = 0,
  Name = 0,
  TreasureName = 0
}
return psSkill_sprint_config