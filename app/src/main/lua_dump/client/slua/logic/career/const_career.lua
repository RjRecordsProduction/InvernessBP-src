local ConstCareer = {
  MEDALS_MAX_LEVEL = 3,
  EQUIP_ITEM_GET_MAX_CONDITION = 3,
  MEDALS_EQUIP_SLOT_MAX = 3,
  MIN_DIS = 99999,
  E_CareerModule = {
    Weapon = 1001,
    Vehicle = 1002,
    Mode = 1003,
    Character = 1004
  },
  E_WeaponType = {
    All = 0,
    AR = 1,
    SR = 2,
    DMR = 3,
    SMG = 4,
    SG = 5,
    LMG = 6,
    Pistol = 7,
    Melee = 8,
    Other = 9
  },
  E_ModeType = {
    AllType = 0,
    Classic = 1,
    Team = 2,
    Theme = 3
  },
  E_VehicleType = {
    All = 0,
    Jeep = 1,
    Pickup = 2,
    Car = 3,
    Motor = 4,
    SUV = 5,
    Vessel = 6,
    Other = 7
  },
  E_RedPointType = {NewSeason = 1, NewItem = 2},
  E_EditBaseTabType = {Medals = 1, Personalize = 2},
  E_EditItemGetType = {
    DefaultGet = 101,
    RPGet = 102,
    BoxGet = 103,
    LuckDrawGet = 104,
    ActivityGet = 105
  },
  E_PersonalizeType = {
    Material = 1,
    Posture = 2,
    Frame = 3
  },
  E_CareerItemSubType = {
    WeaponMedals = 6004,
    ModeMedals = 6005,
    VehicleMedals = 6006
  }
}
return ConstCareer