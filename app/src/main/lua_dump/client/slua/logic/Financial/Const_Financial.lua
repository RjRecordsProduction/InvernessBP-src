local Const_Financial = {
  E_TaskState = {
    Processing = 0,
    Available = 1,
    Received = 2
  },
  E_BoxState = {
    CanBuy = 1,
    DontBuy = 2,
    Bought = 3
  },
  E_BoxRewardState = {NotReceived = 0, Received = 1},
  E_AreaType = {
    Global = 0,
    SouthAsia = 1,
    EasternEurope = 2,
    SoutheastAsia = 3,
    MiddleEast = 4,
    WesternEurope = 5,
    NorthAmerica = 6
  }
}
return Const_Financial