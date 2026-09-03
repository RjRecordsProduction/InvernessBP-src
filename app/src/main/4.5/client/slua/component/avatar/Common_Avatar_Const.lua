local Common_Avatar_Const = {
  Enum_ChildName = {
    Ban = "_cObj_Ban",
    DynamicIcon = "_cObj_DynamicIcon",
    DynamicFrame = "_cObj_DynamicFrame",
    CollectLevel = "_cObj_CollectLevel",
    Reddot = "_cObj_Reddot"
  }
}
local Enum_ChildName = Common_Avatar_Const.Enum_ChildName
Common_Avatar_Const.Enum_ItemChildZOrder = {
  Default = 0,
  Icon = 0,
  [Enum_ChildName.DynamicIcon] = 1,
  [Enum_ChildName.Ban] = 1,
  [Enum_ChildName.DynamicFrame] = 2,
  Frame = 2,
  [Enum_ChildName.Reddot] = 3,
  [Enum_ChildName.CollectLevel] = 3
}
Common_Avatar_Const.Enum_BaseType = {
  CreateChildWindowBPPathInBaseCfg = 0,
  CreateChildWindowBPPathInCode = 1,
  CreateChildWindowBPPathInChildCfg = 2
}
return Common_Avatar_Const