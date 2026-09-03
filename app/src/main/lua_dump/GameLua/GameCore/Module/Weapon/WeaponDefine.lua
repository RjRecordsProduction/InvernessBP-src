local WeaponDefine = {}
WeaponDefine.ConfigKey = {
  ItemHandle = 1,
  Fov = 2,
  Attachment = 3,
  Attribute = 4,
  AttackIcon = 5,
  SkipWeaponSystemInit = 6
}
WeaponDefine.Attribute = {
  AutoShootInter = "ShootInterval",
  BaseImpactDamage = "BaseImpactDamage",
  BulletRange = "BulletRange",
  RangeModifier = "RangeModifier",
  ReferenceDistance = "RangeModifier"
}
WeaponDefine.AttachmentType = {
  Constant = 1,
  Muzzle = 2,
  Upper = 3,
  Stock = 4,
  Magazine = 5,
  Lower = 6,
  UpperSide = 7
}
WeaponDefine.AttachmentName = {
  [WeaponDefine.AttachmentType.Constant] = "Constant",
  [WeaponDefine.AttachmentType.Muzzle] = "Muzzle",
  [WeaponDefine.AttachmentType.Upper] = "Upper",
  [WeaponDefine.AttachmentType.Stock] = "Stock",
  [WeaponDefine.AttachmentType.Magazine] = "Magazine",
  [WeaponDefine.AttachmentType.Lower] = "Lower",
  [WeaponDefine.AttachmentType.UpperSide] = "UpperSide"
}
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
WeaponDefine.ConfigKeyToSocketType = {
  [WeaponDefine.AttachmentType.Muzzle] = EWeaponAttachmentSocketType.GunPoint,
  [WeaponDefine.AttachmentType.Upper] = EWeaponAttachmentSocketType.OpticalSight,
  [WeaponDefine.AttachmentType.Stock] = EWeaponAttachmentSocketType.Gunstock,
  [WeaponDefine.AttachmentType.Magazine] = EWeaponAttachmentSocketType.Magazine
}
return WeaponDefine