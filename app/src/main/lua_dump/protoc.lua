local protoc = {}
local loaded = {}
function protoc.LoadFile(fileName)
  if loaded[fileName] then
    return
  end
  local pb = require("pb")
  pb.loadfile(fileName)
  loaded[fileName] = true
end
function protoc.Reload()
  loaded = {}
end
return protoc