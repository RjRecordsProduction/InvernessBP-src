local Codes = {
  Global = {
    InternalFailed = 8100,
    ParseCodeError = 8200,
    ExecuteTimeTooLong = 8103,
    CodeException = 8299
  },
  Camera = {InvalidMCPFeatureParams = 8202, InvalidPlanesParams = 8203},
  Debug = {
    InvalidArgument = 8210,
    InvalidFVector = 8211,
    InvalidFRotator = 8212,
    InvalidPositiveNumber = 8213,
    InvalidString = 8214
  },
  MarkPoint = {
    InvalidMCPFeatureParams = 8222,
    InvalidPlanesParams = 8223,
    InvalidRadius = 8224
  },
  LocatorBox = {InvalidMCPFeatureParams = 8232, InvalidPlanesParams = 8233},
  Player = {MissingPlayerCharacter = 8241},
  Instance = {
    InvalidArgument = 8251,
    NotFound = 8253,
    CostExceeded = 8101,
    LimitExceeded = 8102,
    PermissionDenied = 8255,
    NotAllowed = 8256,
    SpawnLimitPerExecution = 8257,
    PlacementNotAllowed = 8258
  },
  SceneDetect = {
    InvalidArgument = 8271,
    NotFound = 8273,
    PreconditionFailed = 8274,
    OperationFailed = 8275
  }
}
do
  local seen = {}
  local checkOne = function(moduleName, key, code)
    assert(type(code) == "number", string.format("ModsErrorCodes: %s.%s must be number", tostring(moduleName), tostring(key)))
    assert(8100 <= code and code <= 8299, string.format("ModsErrorCodes: %s.%s out of range: %d", tostring(moduleName), tostring(key), code))
    assert(not seen[code], string.format("ModsErrorCodes: duplicate code %d (%s.%s and %s)", code, tostring(moduleName), tostring(key), tostring(seen[code])))
    seen[code] = string.format("%s.%s", tostring(moduleName), tostring(key))
  end
  for moduleName, t in pairs(Codes) do
    for key, code in pairs(t) do
      checkOne(moduleName, key, code)
    end
  end
end
return Codes