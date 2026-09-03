local lobby_avatar_function_library = {}
function lobby_avatar_function_library.OnPlayerRotate(_, AvatarComp)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.OnPlayerRotate(AvatarComp)
end
local class = require("class")
local object = require("object")
local LobbyAvatarFunctionLibraryClass = class(object, nil, lobby_avatar_function_library)
return LobbyAvatarFunctionLibraryClass