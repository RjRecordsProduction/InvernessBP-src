local PUBGDoor = {}
function PUBGDoor:ctor()
end
local Class = require("class")
local CActorBase = require("common.delegate_container")
local PUBGDoorClass = Class(CActorBase, nil, PUBGDoor)
return PUBGDoorClass