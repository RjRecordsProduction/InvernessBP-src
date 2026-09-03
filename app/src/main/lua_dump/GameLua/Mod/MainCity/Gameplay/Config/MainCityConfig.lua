local MainCityConfig = {
  CharClass = "/Game/BluePrints/Core/BP_PlayerCharacter_MainCity.BP_PlayerCharacter_MainCity_C",
  DefaultLocation = FVector(479999, 30477, 113),
  DefaultRotation = FRotator(0, 91, 0),
  StartNum = 35,
  StartLocation = {
    [1] = FVector(478371, 31154, 113),
    [2] = FVector(481854, 29671, 113),
    [3] = FVector(480219, 29676, 113),
    [4] = FVector(480229, 30477, 113),
    [5] = FVector(479749, 30477, 113),
    [6] = FVector(480401, 29880, 113),
    [7] = FVector(480401, 30290, 113),
    [8] = FVector(479605, 30270, 113),
    [9] = FVector(479605, 29890, 113),
    [10] = FVector(480289, 32420, 113),
    [11] = FVector(479769, 29676, 113),
    [12] = FVector(479295, 30080, 113),
    [13] = FVector(479999, 29366, 113),
    [14] = FVector(479999, 30777, 113),
    [15] = FVector(480691, 30080, 113),
    [16] = FVector(478955, 30080, 113),
    [17] = FVector(479999, 31107, 113),
    [18] = FVector(481041, 30080, 113),
    [19] = FVector(479999, 29056, 113),
    [20] = FVector(480998, 30956, 113),
    [21] = FVector(480700, 31235, 113),
    [22] = FVector(481204, 31250, 113),
    [23] = FVector(481489, 30916, 113),
    [24] = FVector(481771, 31296, 113),
    [25] = FVector(481221, 29311, 113),
    [26] = FVector(481592, 29311, 113),
    [27] = FVector(481301, 30461, 113),
    [28] = FVector(479999, 31421, 113),
    [29] = FVector(478490, 30080, 113),
    [30] = FVector(478578, 30463, 113),
    [31] = FVector(478733, 30943, 113),
    [32] = FVector(479107, 31094, 113),
    [33] = FVector(481388, 29639, 113),
    [34] = FVector(481388, 30015, 113),
    [35] = FVector(479711, 32398, 113)
  },
  StartRotation = {
    [1] = FRotator(0, 91, 0),
    [2] = FRotator(0, 1, 0),
    [3] = FRotator(0, -89, 0),
    [4] = FRotator(0, 91, 0),
    [5] = FRotator(0, 91, 0),
    [6] = FRotator(0, 1, 0),
    [7] = FRotator(0, 1, 0),
    [8] = FRotator(0, -179, 0),
    [9] = FRotator(0, -179, 0),
    [10] = FRotator(0, -89, 0),
    [11] = FRotator(0, -89, 0),
    [12] = FRotator(0, -179, 0),
    [13] = FRotator(0, -89, 0),
    [14] = FRotator(0, 91, 0),
    [15] = FRotator(0, 1, 0),
    [16] = FRotator(0, -179, 0),
    [17] = FRotator(0, 91, 0),
    [18] = FRotator(0, 1, 0),
    [19] = FRotator(0, -69, 0),
    [20] = FRotator(0, 31, 0),
    [21] = FRotator(0, 51, 0),
    [22] = FRotator(0, 51, 0),
    [23] = FRotator(0, 31, 0),
    [24] = FRotator(0, 31, 0),
    [25] = FRotator(0, -9, 0),
    [26] = FRotator(0, -9, 0),
    [27] = FRotator(0, 21, 0),
    [28] = FRotator(0, 91, 0),
    [29] = FRotator(0, -179, 0),
    [30] = FRotator(0, 131, 0),
    [31] = FRotator(0, 91, 0),
    [32] = FRotator(0, 91, 0),
    [33] = FRotator(0, -19, 0),
    [34] = FRotator(0, -19, 0),
    [35] = FRotator(0, -89, 0)
  },
  IngameWidgetList = {
    {
      Path = "/Game/BluePrints/ControlInput/MainControlPanelTochButton.MainControlPanelTochButton_C",
      Container = "Default",
      ZOrder = 0
    }
  },
  EJoinLeaveStatus = {Join = 1, Leave = 2},
  EBuildType = {
    Clothing = 1,
    Vehicles = 2,
    HomeBuilding = 3,
    HomeStore = 4
  },
  bOptimization = true,
  bOptimization_2 = true,
  bOptimization_3 = false
}
function MainCityConfig:Init()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("kh.maincity.lowmemory") ~= 0 then
    print(bWriteLog and "MainCityConfig:Init 1")
    self.bOptimization_3 = true
  else
    print(bWriteLog and "MainCityConfig:Init 2")
    self.bOptimization_3 = false
  end
end
MainCityConfig:Init()
return MainCityConfig