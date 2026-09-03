local EntityLoaderAPI = {
  GetComponentPosition = {
    type = "get",
    default = FVector(0, 0, 0)
  },
  GetSocketTransform = {
    type = "get",
    default = FTransform.Identity
  },
  SetWeaponPendantSocketType = {type = "set"},
  SetHolderBack = {type = "set"},
  PutonEquipmentByResid = {type = "set"},
  PutoffEquipmentByResid = {type = "set"},
  AttachModelCenter = {type = "set"},
  AttachToAttachPoint = {type = "set"},
  SetModelRelativeLocationRotationScale = {type = "set"},
  RefreshExtraTableDataShow = {type = "set"},
  MakeShowTypeCanRotateBack = {type = "set"},
  ModelSimulatePhysics = {type = "set"}
}
return EntityLoaderAPI