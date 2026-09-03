local GameReplay = {}
function GameReplay:ctor()
  print("GameReplay:ctor")
end
local class = require("class")
local object = require("object")
return class(object, nil, GameReplay)