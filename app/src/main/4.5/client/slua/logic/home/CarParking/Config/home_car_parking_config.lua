local SocialBottomVehicleSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_vehicle")
local home_car_parking_config = {
  carParkingSwitch = true,
  carParkingTabType = {
    Manage = 1,
    myCar = 2,
    Upgrade = 3,
    Skin = 4,
    Rank = 5,
    Shop = 6
  },
  parkingSlotType = {Public = 1, Friend = 2},
  ignoreVehicleTypes = {
    [1] = SocialBottomVehicleSystem.ENUM_VEHICLE_CATEGORY_TYPE.Boat,
    [2] = SocialBottomVehicleSystem.ENUM_VEHICLE_CATEGORY_TYPE.Wingman
  },
  validSubTypesInOtherCategory = {
    [953] = true
  },
  vehicleState = {
    None = 1,
    Idle = 2,
    Parking = 3
  },
  parkingSlotState = {
    Idle = 1,
    MyCarParking = 2,
    OtherCarParking = 3
  },
  C_RecommendListPageSize = 20,
  vehicleSubTypesScale = {
    [953] = 0.7
  },
  vehicleSubTypesOffset = {
    [902] = FVector(0, -40, 0)
  },
  ESortType = {
    Income = 1,
    ParkingSlotNum = 2,
    CarNum = 3
  }
}
return home_car_parking_config