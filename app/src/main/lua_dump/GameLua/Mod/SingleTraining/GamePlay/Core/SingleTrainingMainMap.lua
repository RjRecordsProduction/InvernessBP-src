local SingleTrainingMainMap = {}
function SingleTrainingMainMap:ReceiveBeginPlay()
  local GameplayStatics = import("GameplayStatics")
  local gameInstance = GameplayStatics.GetGameInstance(self)
  gameInstance:AutoActiveLDR()
end
local class = require("class")
local object = require("object")
local CSingleTraining = class(object, nil, SingleTrainingMainMap)
return CSingleTraining