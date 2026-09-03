local ReviveConfig = {
  ReviveInfo = {
    Baltic = {
      SubModeID = "65132,65133,65134,65135,65136,65137,65138,65139,65140,65141,65142,65143",
      ClearRevivalCountTime = 1065,
      ExceptionalRevive = {WaitingTime = 6}
    },
    Livik = {
      SubModeID = "65144,65145,65146,65147,65148,65149,65150,65151,65152,65153,65154,65155",
      ClearRevivalCountTime = 690,
      ExceptionalRevive = {WaitingTime = 6}
    },
    Neon = {
      SubModeID = "65156,65157,65158,65159,65160,65161,65162,65163,65164,65165,65166,65167",
      ClearRevivalCountTime = 995,
      ExceptionalRevive = {WaitingTime = 6}
    }
  },
  IndependentReviveWeaponPoor = {
    Default = {
      BeginEquip = {
        [1] = {
          [{
            {501005, 1},
            {502002, 1},
            {503002, 1},
            {601005, 2},
            {601003, 2},
            {203002, 1}
          }] = 100
        },
        [2] = {
          [{
            {101003, 1},
            {303001, 60}
          }] = 30,
          [{
            {101001, 1},
            {302001, 60}
          }] = 20,
          [{
            {101006, 1},
            {303001, 60}
          }] = 20,
          [{
            {101008, 1},
            {302001, 60}
          }] = 10,
          [{
            {101004, 1},
            {303001, 60}
          }] = 15,
          [{
            {101102, 1},
            {302001, 60}
          }] = 5
        }
      }
    }
  },
  PlaneInfoRevivedBySelf = {
    Default = {
      PlaneHeight = 70000,
      CanOpenParachuteHeight = 56000,
      ForceOpenParachuteHeight = 16000,
      CloseParachuteHeight = 200,
      PlaneSpeed = 6000,
      AirLineLengthLimit = 2000000,
      SamePlaneInterval = 3,
      AvoidPOI = {}
    },
    Baltic = {
      PlaneHeight = 70000,
      CanOpenParachuteHeight = 56000,
      ForceOpenParachuteHeight = 16000,
      CloseParachuteHeight = 200,
      PlaneSpeed = 6000,
      AirLineLengthLimit = 2000000,
      SamePlaneInterval = 3,
      TryTimes = 6,
      AvoidPOI = {}
    },
    Livik = {
      PlaneHeight = 70000,
      CanOpenParachuteHeight = 35000,
      ForceOpenParachuteHeight = 10000,
      CloseParachuteHeight = 200,
      PlaneSpeed = 4500,
      AirLineLengthLimit = 2000000,
      SamePlaneInterval = 3,
      AvoidPOI = {}
    }
  }
}
return ReviveConfig