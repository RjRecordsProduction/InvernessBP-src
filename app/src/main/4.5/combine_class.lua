local utility = require("common.utility")
local TableUtil = require("common.table_util")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local CombineClass = {}
local ForcePrintLog = _G.print
local FindLoader = function()
  local TestModuleName = "class"
  for _, loader in ipairs(package.searchers) do
    local f = loader(TestModuleName)
    local t = type(f)
    if t == "function" then
      return loader
    end
  end
end
local Loader = FindLoader()
function CombineClass.GenerateFeatureClass(BaseClass, ...)
  local class = require("class")
  if IsDevelopment then
    assert(getmetatable(BaseClass) ~= nil, "getmetatable(BaseClass) ~= nil")
  end
  local NewClass = BaseClass
  local function GenerateClass(...)
    local ClassCount = select("#", ...)
    for i = 1, ClassCount - 1 do
      local ClassImpName = select(i, ...)
      if IsDevelopment then
        assert(type(ClassImpName) == "string", "type(ClassImpName) == \"string\"")
      end
      local SubModule = Loader(ClassImpName)
      GenerateClass(SubModule())
    end
    local ClassImp = select(ClassCount, ...)
    if IsDevelopment then
      assert(not getmetatable(ClassImp), "not getmetatable(ClassImp)")
    end
    NewClass = class(NewClass, nil, ClassImp)
  end
  local ModuleCount = select("#", ...)
  for i = 1, ModuleCount do
    local SubClassModuleName = select(i, ...)
    local Module = Loader(SubClassModuleName)
    GenerateClass(Module())
  end
  return NewClass
end
local OriginRequire = _G.require
local LuaModuleRedirectMap = {}
local LuaModuleRedirectLoaded = {}
local LuaModuleUsingFeature = {}
local LuaClassExtraFeatures = {}
local LogLuaRepInfo = false
local ExtractFeatureDefine = function(FeatureDefine)
  for Name, Path in pairs(FeatureDefine) do
    return Name, Path
  end
end
local InternalLogFormat = function(Format, ...)
  if _G.IsEditor then
    ForcePrintLog(string.format(Format, ...))
  else
    print(bWriteLog and string.format(Format, ...))
  end
end
local LogWarning = function(Format, ...)
  log_warning(string.format(Format, ...))
end
local cachePreFixMap = {}
local function LXLog_log_tree_var(level, varName, keyType, varValue, ignoreKeys, bVisitedMap)
  local formatValue = function(value, ValueType)
    if ValueType == "string" and tonumber(value) then
      return "\"" .. tostring(value) .. "\""
    end
    return tostring(value)
  end
  local preFix = ""
  keyType = keyType or "number"
  ignoreKeys = ignoreKeys or {}
  if level == 0 then
  else
    if cachePreFixMap[level - 1] then
      preFix = cachePreFixMap[level - 1]
    else
      preFix = string.rep("\226\148\130  ", level - 1)
      cachePreFixMap[level - 1] = preFix
    end
    preFix = preFix .. "\226\148\156\226\148\128 "
  end
  if type(varValue) == "table" then
    if bVisitedMap[varValue] then
      InternalLogFormat(preFix .. formatValue(varName, keyType) .. ": repeated")
      return
    end
    bVisitedMap[varValue] = true
    InternalLogFormat(preFix .. formatValue(varName, keyType))
    for k, v in pairs(varValue) do
      if not ignoreKeys[k] then
        LXLog_log_tree_var(level + 1, tostring(k), type(k), v, ignoreKeys, bVisitedMap)
      end
    end
  else
    InternalLogFormat(preFix .. formatValue(varName, keyType) .. ": " .. formatValue(varValue, type(varValue)))
  end
end
local LogTree = function(desc, var, ignoreKeys)
  if LogLuaRepInfo then
    local bVisitedMap = {}
    LXLog_log_tree_var(0, desc, nil, var, ignoreKeys, bVisitedMap)
  end
end
local RecordFeatureClassForUnload = function(FeatureClass, FeatureModulePath)
  if LuaModuleUsingFeature[FeatureClass] then
    return
  end
  InternalLogFormat("[Feature] RecordFeatureClassForUnload FeatureClass = %s ModulePath = %s", FeatureClass, FeatureModulePath)
  LuaModuleUsingFeature[FeatureClass] = true
end
local RecordClassUsingFeature = function(Class, Name, IsFromDeclare)
  if LuaModuleUsingFeature[Class] == true then
    return
  end
  if IsFromDeclare then
    InternalLogFormat("[Feature] RecordClassUsingFeature %s ClassName = %s (from declare)", Class, Name)
    LuaModuleUsingFeature[Class] = true
    return
  end
  local InheritanceStack = {}
  local ParentHasFeature = false
  local Current  while CurrentClass ~= nil and CurrentClass ~= CActorBase and CurrentClass.__inner_impl do
    table.insert(InheritanceStack, CurrentClass)
    if LuaModuleUsingFeature[CurrentClass] then
      ParentHasFeature = true
      break
    else
      CurrentClass = CurrentClass.__inner_impl.__super
    end
  end
  if ParentHasFeature then
    for _, C in ipairs(InheritanceStack) do
      if not LuaModuleUsingFeature[C] then
        InternalLogFormat("[Feature] RecordClassUsingFeature %s Path = %s (from require)", Class, Name)
        LuaModuleUsingFeature[Class] = true
      end
    end
  end
end
function CombineClass.DeclareFeature(Class, FeatureConfig, ClassName)
  local RPCTypes = {
    "ServerRPC",
    "ClientRPC",
    "MulticastRPC",
    "ReplayRPC"
  }
  local function CopyTable(st)
    local tab = {}
    for k, v in pairs(st or {}) do
      if type(v) ~= "table" then
        tab[k] = v
      else
        tab[k] = CopyTable(v)
      end
    end
    return tab
  end
  local GetFeatureDefines = function(_ClassName, _FeatureConfig)
    local FinalFeatureDefines = {}
    table.move(_FeatureConfig, 1, #_FeatureConfig, #FinalFeatureDefines + 1, FinalFeatureDefines)
    local ExtraFeatureDefines = LuaClassExtraFeatures[_ClassName]
    if ExtraFeatureDefines then
      for _, FeatureDefine in ipairs(ExtraFeatureDefines) do
        local Name, Path = ExtractFeatureDefine(FeatureDefine)
        local IndexDefinedInMainClass = -1
        local MainClassFeatureName, MainClassFeaturePath
        for Index, MainClassFeatureDefine in ipairs(_FeatureConfig) do
          MainClassFeatureName, MainClassFeaturePath = ExtractFeatureDefine(MainClassFeatureDefine)
          if MainClassFeatureName == Name then
            IndexDefinedInMainClass = Index
            break
          end
        end
        if IndexDefinedInMainClass <= 0 then
          table.insert(FinalFeatureDefines, FeatureDefine)
          InternalLogFormat("[Feature] GetFeatureDefines (Class: %s) add extra feature define %s = %s", _ClassName, Name, Path)
        else
          FinalFeatureDefines[IndexDefinedInMainClass][Name] = Path
          InternalLogFormat("[Feature] GetFeatureDefines (Class: %s) feature define %s = %s is exist, will override to %s", _ClassName, Name, MainClassFeaturePath, Path)
        end
      end
    end
    return FinalFeatureDefines
  end
  local IsLuaSubClassOf = function(ClassImplement, TargetClass)
    while ClassImplement ~= nil do
      if ClassImplement.__super == TargetClass then
        return true
      end
      ClassImplement = ClassImplement.__super_impl
    end
    return false
  end
  local GetReplicatedPropName = function(PropChain, PropName)
    local StrPropChain = table.concat(PropChain, ".")
    if PropName ~= nil then
      StrPropChain = StrPropChain .. "." .. PropName
    end
    return string.format("#[Feature(%s)]", StrPropChain)
  end
  local GetReplicatedPropChain = function(PropName)
    local InnerStr = string.match(PropName, "#%[Feature%((.+)%)%]")
    if not InnerStr then
      return
    end
    local StringUtil = require("common.string_util")
    return StringUtil.Split(InnerStr, ".")
  end
  local GetReplicatedPropsIncludeSuperClass = function(ClassImplement)
    local GetRepInfoOverrided = function(PropName, _FeatureConfig)
      local PropChain = GetReplicatedPropChain(PropName)
      if PropChain == nil then
        return
      end
      for _, Info in ipairs(_FeatureConfig) do
        for FeatureName, OverrideInfo in pairs(Info) do
          if PropChain[1] == FeatureName then
            return OverrideInfo
          end
          break
        end
      end
    end
    local Current    local RepTable = {}
    local Level = 0
    while CurrentClassImplement ~= nil do
      if CurrentClassImplement.GetLifetimeReplicatedProps ~= nil then
        local TempRepTable = CurrentClassImplement.GetLifetimeReplicatedProps() or {}
        for _, RepInfo in ipairs(TempRepTable) do
          local PropName = RepInfo[1]
          local OverrideInfo = GetRepInfoOverrided(PropName, ClassImplement.__FeatureConfig)
          if OverrideInfo == nil then
            if not TableUtil.FindTable(RepTable, function(i, v)
              return v[1] == PropName
            end) then
              table.insert(RepTable, RepInfo)
            end
          else
            InternalLogFormat("[Feature] GetReplicatedPropsIncludeSuperClass Prop = %s OverrideInfo = %s", PropName, OverrideInfo)
          end
        end
        if 0 < Level then
          break
        end
      end
      Level = Level + 1
      CurrentClassImplement = CurrentClassImplement.__super_impl
    end
    return RepTable
  end
  local ParseRPCMetaData = function(RootClassImplement, KeyChain)
    local Result = {}
    for _, RPCType in ipairs(RPCTypes) do
      if #KeyChain == 0 then
        local RootClassRPCInfo = RootClassImplement[RPCType]
        if RootClassRPCInfo then
          Result[RPCType] = CopyTable(RootClassRPCInfo)
        end
      else
        local Stack = {}
        local CurrentClassImplement = RootClassImplement
        while CurrentClassImplement ~= nil do
          if CurrentClassImplement[RPCType] then
            table.insert(Stack, CurrentClassImplement[RPCType])
          end
          CurrentClassImplement = CurrentClassImplement.__super_impl
        end
        for i = #Stack, 1, -1 do
          local RPCInfo = Stack[i]
          if not Result[RPCType] then
            Result[RPCType] = CopyTable(RPCInfo)
          else
            TableUtil.OverrideTable(Result[RPCType], RPCInfo)
          end
        end
      end
    end
    return Result
  end
  local function ParseFeatureMetaData(RootClassImplement, KeyChain)
    local ParseFeatureConfig = function(_Tree, _FeatureConfig, _KeyChain)
      if not _FeatureConfig then
        return
      end
      for _, ConfigItem in ipairs(_FeatureConfig) do
        for FeatureKey, FeatureModulePath in pairs(ConfigItem) do
          if type(FeatureModulePath) == "string" then
            do
              local _, FeatureClass = xpcall(require, utility.ErrorMessageHandler, FeatureModulePath)
              if FeatureClass then
                if Client then
                  RecordFeatureClassForUnload(FeatureClass, FeatureModulePath)
                end
                table.insert(_KeyChain, FeatureKey)
                local NewFeatureMetaData = ParseFeatureMetaData(FeatureClass.__inner_impl, _KeyChain)
                NewFeatureMetaData.__                NewFeatureMetaData.__ModulePath = FeatureModulePath
                table.insert(_Tree.__Feature, NewFeatureMetaData)
                table.remove(_KeyChain, #_KeyChain)
              end
            end
            break
          end
          if FeatureModulePath == false then
            local NewFeatureMetaData = {}
            NewFeatureMetaData.__            NewFeatureMetaData.__ModulePath = FeatureModulePath
            NewFeatureMetaData.__CancelParent = true
            InternalLogFormat("[Feature] ParseFeatureMetaData Key = %s cancel parent feature", FeatureKey)
            table.insert(_Tree.__Feature, NewFeatureMetaData)
          end
          break
        end
      end
    end
    KeyChain = KeyChain or {}
    local Tree = {}
    Tree.__ReplicatedProps = GetReplicatedPropsIncludeSuperClass(RootClassImplement)
    Tree.__RPC = ParseRPCMetaData(RootClassImplement, KeyChain)
    Tree.__ClassImplement = RootClassImplement
    Tree.__KeyChain = CopyTable(KeyChain)
    Tree.__Feature = {}
    ParseFeatureConfig(Tree, RootClassImplement.__FeatureConfig, KeyChain)
    local CurrentClassImplement = RootClassImplement.__super_impl
    while CurrentClassImplement ~= nil do
      if IsLuaSubClassOf(CurrentClassImplement, CFeatureBase) then
        ParseFeatureConfig(Tree, CurrentClassImplement.__FeatureConfig, KeyChain)
        CurrentClassImplement = CurrentClassImplement.__super_impl
      else
        break
      end
    end
    return Tree
  end
  local function IterateFeatureMetaData(FeatureMetaData, Callback, CancelCallback)
    for _, SubFeatureMetaData in ipairs(FeatureMetaData.__Feature) do
      local Key = SubFeatureMetaData.__FeatureKey
      if SubFeatureMetaData.__ModulePath ~= false then
        Callback(Key, SubFeatureMetaData)
        IterateFeatureMetaData(SubFeatureMetaData, Callback)
      elseif CancelCallback then
        CancelCallback(Key, SubFeatureMetaData)
      end
    end
  end
  local HookReplicatedProps = function(ActorClassImplement, FeatureMetaData)
    local RepTableRecords = {}
    local RepTable = CopyTable(FeatureMetaData.__ReplicatedProps)
    for _, RepInfo in ipairs(RepTable) do
      RepTableRecords[RepInfo[1]] = true
    end
    local InternalHookReplicatedProps = function(Key, SubFeatureMetaData)
      for _, OriginProp in ipairs(SubFeatureMetaData.__ReplicatedProps) do
        local KeyChain = SubFeatureMetaData.__KeyChain
        local FinalProp = CopyTable(OriginProp)
        local OriginPropName = OriginProp[1]
        local FinalPropName = GetReplicatedPropName(KeyChain, OriginPropName)
        local OriginOnRepFuncName = "OnRep_" .. OriginPropName
        local FinalOnRepFuncName = "OnRep_" .. FinalPropName
        if ActorClassImplement[FinalOnRepFuncName] == nil then
          ActorClassImplement[FinalOnRepFuncName] = function(this, OldValue)
            local Instance = this
            for _, Field in ipairs(KeyChain) do
              Instance = Instance[Field]
            end
            if Instance[OriginOnRepFuncName] ~= nil then
              Instance[OriginOnRepFuncName](Instance, OldValue)
            end
          end
        end
        FinalProp[1] = FinalPropName
        if not RepTableRecords[FinalProp] then
          table.insert(RepTable, FinalProp)
          RepTableRecords[FinalProp] = true
        end
      end
    end
    IterateFeatureMetaData(FeatureMetaData, InternalHookReplicatedProps)
    LogTree(string.format("[Feature] GetLifetimeReplicatedProps <%s>", ClassName), RepTable)
    ActorClassImplement.__OriginGetLifetimeReplicatedProps = ActorClassImplement.GetLifetimeReplicatedProps
    function ActorClassImplement.GetLifetimeReplicatedProps()
      return RepTable
    end
  end
  local GetRPCName = function(KeyChain, FuncName)
    local StrKeyChain = table.concat(KeyChain, ".")
    if FuncName ~= nil then
      StrKeyChain = StrKeyChain .. "." .. FuncName
    end
    return string.format("#[FeatureRPC(%s)]", StrKeyChain)
  end
  local HookRPC = function(ActorClassImplement, FeatureMetaData)
    local InternalCancelHookRPC = function(Key, SubFeatureMetaData)
      local GetParentActorClassImplWithSameNameFeature = function(_ClassImplement, FeatureName)
        if not _ClassImplement then
          return
        end
        local CurrentClassImplement = _ClassImplement.__super_impl
        while CurrentClassImplement ~= nil do
          if CurrentClassImplement.__FeatureConfig then
            for _, Config in ipairs(CurrentClassImplement.__FeatureConfig) do
              if Config[FeatureName] then
                return CurrentClassImplement
              end
            end
          end
          CurrentClassImplement = CurrentClassImplement.__super_impl
        end
      end
      local ParentActorClassImplement = GetParentActorClassImplWithSameNameFeature(ActorClassImplement, Key)
      if not ParentActorClassImplement then
        return
      end
      InternalLogFormat("[Feature] InternalCancelHookRPC find same name feature Key = %s", Key)
      for _, RPCType in ipairs(RPCTypes) do
        if ParentActorClassImplement[RPCType] then
          local FinalRPCFuncNamesToDelete = {}
          for FinalRPCFuncName, RPCParam in pairs(ParentActorClassImplement[RPCType]) do
            local KeyChain = RPCParam.__KeyChain
            if KeyChain and KeyChain[1] == Key then
              table.insert(FinalRPCFuncNamesToDelete, FinalRPCFuncName)
            end
          end
          for _, FinalRPCFuncName in ipairs(FinalRPCFuncNamesToDelete) do
            if ParentActorClassImplement[RPCType][FinalRPCFuncName] then
              ParentActorClassImplement[RPCType][FinalRPCFuncName] = nil
            end
            if ParentActorClassImplement[FinalRPCFuncName] then
              ParentActorClassImplement[FinalRPCFuncName] = nil
            end
            InternalLogFormat("[Feature] InternalCancelHookRPC Cancel parent Hook RPC func: %s", FinalRPCFuncName)
          end
        end
      end
    end
    local InternalHookRPC = function(Key, SubFeatureMetaData)
      local InternalGetRPCFunc = function(_ClassImplement, _FuncName)
        local CurrentClassImplement = _ClassImplement
        while CurrentClassImplement ~= nil do
          if CurrentClassImplement.__OriginRPCFunc and CurrentClassImplement.__OriginRPCFunc[_FuncName] then
            return CurrentClassImplement.__OriginRPCFunc[_FuncName]
          end
          local Func = CurrentClassImplement[_FuncName]
          if Func then
            if not CurrentClassImplement.__OriginRPCFunc then
              CurrentClassImplement.__OriginRPCFunc = {}
            end
            CurrentClassImplement.__OriginRPCFunc[_FuncName] = Func
            return Func
          end
          CurrentClassImplement = CurrentClassImplement.__super_impl
        end
      end
      InternalCancelHookRPC(Key, SubFeatureMetaData)
      for RPCType, RPCInfo in pairs(SubFeatureMetaData.__RPC) do
        if not ActorClassImplement[RPCType] then
          ActorClassImplement[RPCType] = {}
        end
        local ClassImplement = SubFeatureMetaData.__ClassImplement
        local KeyChain = SubFeatureMetaData.__KeyChain
        for OriginRPCFuncName, RPCParam in pairs(RPCInfo) do
          local FinalRPCFuncName = GetRPCName(KeyChain, OriginRPCFuncName)
          local OriginRPCFunc = InternalGetRPCFunc(ClassImplement, OriginRPCFuncName)
          if OriginRPCFunc then
            RPCParam.__KeyChain = CopyTable(KeyChain)
            ActorClassImplement[RPCType][FinalRPCFuncName] = RPCParam
            InternalLogFormat("[Feature] Hook RPC func: %s KeyChain = %s", FinalRPCFuncName, table.concat(KeyChain, "."))
            ActorClassImplement[FinalRPCFuncName] = function(this, ...)
              local Instance = this
              for i = 1, #KeyChain do
                local Field = KeyChain[i]
                Instance = Instance[Field]
              end
              OriginRPCFunc(Instance, ...)
            end
            ClassImplement[OriginRPCFuncName] = function(this, ...)
              this.Owner[FinalRPCFuncName](this.Owner, ...)
            end
          else
            LogWarning("[Feature] Hook RPC func failed: %s KeyChain = %s", FinalRPCFuncName, table.concat(KeyChain, "."))
          end
        end
      end
    end
    IterateFeatureMetaData(FeatureMetaData, InternalHookRPC, InternalCancelHookRPC)
  end
  local HookActorInstanceEntry = function(ActorClassImplement, FeatureMetaData)
    local OriginPostConstruct = ActorClassImplement._PostConstruct
    if IsDevelopment then
      assert(OriginPostConstruct ~= nil, "_PostConstruct must be declared when using lua feature")
    end
    function ActorClassImplement._PostConstruct(this)
      local HookReplicatedPropsGetterSetter = function(Feature)
        local mt = getmetatable(Feature)
        local OriginIndex, OriginNewIndex = mt.__index, mt.__newindex
        local ReplicatedPropsMap = Feature.__ReplicatedPropsMap
        LogTree(string.format("[Feature] HookReplicatedPropsGetterSetter <%s>", ClassName), ReplicatedPropsMap)
        local newmt = {}
        function newmt.__index(t, key, cache)
          if ReplicatedPropsMap and ReplicatedPropsMap[key] then
            local value = t.Owner[ReplicatedPropsMap[key]]
            return value
          elseif OriginIndex then
            return OriginIndex(t, key, cache)
          else
            return t[key]
          end
        end
        function newmt.__newindex(t, key, value)
          if ReplicatedPropsMap and ReplicatedPropsMap[key] then
            t.Owner[ReplicatedPropsMap[key]] = value
          elseif OriginNewIndex then
            return OriginNewIndex(t, key, value)
          else
            rawset(t, key, value)
          end
        end
        setmetatable(Feature, newmt)
      end
      local function InstantiateFeature(ActorInstance, CurrentInstance, CurrentFeatureMetaData)
        for _, SubFeatureMetaData in ipairs(CurrentFeatureMetaData.__Feature) do
          local Key = SubFeatureMetaData.__FeatureKey
          if CurrentInstance[Key] == nil then
            if SubFeatureMetaData.__ModulePath ~= false then
              local _, FeatureClass = xpcall(require, utility.ErrorMessageHandler, SubFeatureMetaData.__ModulePath)
              if FeatureClass then
                if Client then
                  RecordFeatureClassForUnload(FeatureClass, SubFeatureMetaData.__ModulePath)
                end
                local Feature = FeatureClass(SubFeatureMetaData)
                local CacheInitialValueFromCtor = {}
                for _, PropInfo in ipairs(SubFeatureMetaData.__ReplicatedProps) do
                  local OriginPropName = PropInfo[1]
                  if Feature[OriginPropName] ~= nil then
                    table.insert(CacheInitialValueFromCtor, {
                      OriginPropName,
                      Feature[OriginPropName]
                    })
                    Feature[OriginPropName] = nil
                  end
                end
                InternalLogFormat("[Feature] InstantiateFeature Key = %s -> %s", Key, SubFeatureMetaData.__ModulePath)
                Feature.Owner = ActorInstance
                local KeyChain = SubFeatureMetaData.__KeyChain
                Feature.__KeyChain = CopyTable(KeyChain)
                Feature.__ReplicatedPropsMap = {}
                for _, PropInfo in ipairs(SubFeatureMetaData.__ReplicatedProps) do
                  local OriginPropName = PropInfo[1]
                  local FinalPropName = GetReplicatedPropName(KeyChain, OriginPropName)
                  Feature.__ReplicatedPropsMap[OriginPropName] = FinalPropName
                end
                HookReplicatedPropsGetterSetter(Feature)
                for _, Config in ipairs(CacheInitialValueFromCtor) do
                  Feature[Config[1]] = Config[2]
                end
                CurrentInstance[Key] = Feature
                if CurrentInstance.Features == nil then
                  CurrentInstance.Features = {}
                end
                table.insert(CurrentInstance.Features, Feature)
                InstantiateFeature(ActorInstance, Feature, SubFeatureMetaData)
              end
            else
              CurrentInstance[Key] = false
              InternalLogFormat("[Feature] InstantiateFeature Key = %s cancel, ignore", Key)
            end
          else
            InternalLogFormat("[Feature] InstantiateFeature Key = %s has been overrided by child class, ignore", Key)
          end
        end
      end
      InstantiateFeature(this, this, FeatureMetaData)
      if OriginPostConstruct then
        OriginPostConstruct(this)
      end
    end
  end
  local ClassImplement = Class.__inner_impl
  if IsDevelopment then
    assert(type(ClassImplement) == "table", "Param \"Class\" must be a lua class")
  end
  ClassImplement.__FeatureConfig = GetFeatureDefines(ClassName, FeatureConfig)
  local IsDeclarationForActorClass = not IsLuaSubClassOf(Class.__inner_impl, CFeatureBase)
  if IsDeclarationForActorClass then
    InternalLogFormat("[Feature] ===== DeclareFeature for <%s>", ClassName)
    local FeatureMetaData = ParseFeatureMetaData(ClassImplement)
    LogTree(string.format("[Feature] ===== DebugFeatureMetaData for <%s>", ClassName), FeatureMetaData, {__ClassImplement = true})
    HookReplicatedProps(ClassImplement, FeatureMetaData)
    HookRPC(ClassImplement, FeatureMetaData)
    HookActorInstanceEntry(ClassImplement, FeatureMetaData)
    if Client then
      RecordClassUsingFeature(Class, ClassName, true)
    end
  end
  return Class
end
local LuaModuleRedirectFunc = function(Path)
  if LuaModuleRedirectLoaded[Path] then
    return LuaModuleRedirectLoaded[Path]
  end
  local Module
  local RedirectInfo = LuaModuleRedirectMap[Path]
  if RedirectInfo then
    if type(RedirectInfo) == "string" then
      InternalLogFormat("require %s redirect -> %s", Path, RedirectInfo)
      Module = OriginRequire(RedirectInfo)
    elseif type(RedirectInfo) == "function" then
      InternalLogFormat("require %s redirect from function", Path)
      Module = RedirectInfo(Path, OriginRequire)
    end
    if Module ~= nil then
      LuaModuleRedirectLoaded[Path] = Module
    end
  end
  if Module == nil then
    Module = OriginRequire(Path)
  end
  if string.find(Path, "Controller") then
    print(bWriteLog and string.format("LuaModuleRedirectFunc %s -> %s", Path, Module))
  end
  if Client and Module and type(Module) == "table" and Module._PostConstruct and Module.__inner_impl and type(Module.__inner_impl) == "table" then
    RecordClassUsingFeature(Module, Path, false)
  end
  return Module
end
local UnloadRecordClassUsingFeature = function()
  local ModuleInfosToUnload = {}
  for ModulePath, Module in pairs(_G.package.loaded) do
    local ClassName = LuaModuleUsingFeature[Module]
    if ClassName then
      table.insert(ModuleInfosToUnload, {ModulePath = ModulePath, Module = Module})
    end
  end
  for _, Info in ipairs(ModuleInfosToUnload) do
    local ModulePath = Info.ModulePath
    local Module = Info.Module
    if _G.package.loaded[ModulePath] then
      InternalLogFormat("[Feature] UnloadRecordClassUsingFeature %s (%s) in package.loaded", ModulePath, Module)
      _G.package.loaded[ModulePath] = nil
    end
  end
  LuaModuleUsingFeature = {}
end
function CombineClass.HookLuaRequire(IsHook)
  InternalLogFormat("CombineClass.HookLuaRequire %s", IsHook)
  if IsHook then
    _G.require = LuaModuleRedirectFunc
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    LogLuaRepInfo = STExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("LogLuaRepInfo") > 0
    InternalLogFormat("CombineClass.HookLuaRequire LogLuaRepInfo = %s", LogLuaRepInfo)
  else
    InternalLogFormat("CombineClass.RestoreLuaRequire")
    _G.require = OriginRequire
    for Path, _ in pairs(LuaModuleRedirectLoaded) do
      InternalLogFormat("require %s restore redirect", Path)
    end
    LuaModuleRedirectMap = {}
    LuaModuleRedirectLoaded = {}
    UnloadRecordClassUsingFeature()
    LuaClassExtraFeatures = {}
    LogLuaRepInfo = false
  end
end
function CombineClass.AddLuaRequireRedirect(Path, Redirect)
  LuaModuleRedirectMap[Path] = Redirect
end
function CombineClass.HasLuaRequireRedirect(Path)
  return LuaModuleRedirectMap[Path] ~= nil
end
function CombineClass.AddLuaClassExtraFeatures(ClassName, FeatureDefineList)
  if not LuaClassExtraFeatures[ClassName] then
    LuaClassExtraFeatures[ClassName] = {}
  end
  for _, FeatureDefine in ipairs(FeatureDefineList) do
    local Name, Path = ExtractFeatureDefine(FeatureDefine)
    table.insert(LuaClassExtraFeatures[ClassName], FeatureDefine)
    InternalLogFormat("[Feature] CombineClass.AddLuaClassExtraFeatures %s: %s = %s", ClassName, Name, Path)
  end
end
function CombineClass.SetFeatureDynamic(LuaFeatureClass)
  local ClassImplement = LuaFeatureClass.__inner_impl
  if not ClassImplement then
    return LuaFeatureClass
  end
  function ClassImplement.OnPostLuaHook(this, Owner)
    this.    if this:HasAuthority() then
      this:OnLuaFeatureInfoReady()
    end
  end
  function ClassImplement.OnLuaFeatureInfoReady(this)
    local LuaFeatureInfo = this.LuaFeatureInfo
    InternalLogFormat("[Feature] CombineClass.SetFeatureDynamic OnLuaFeatureInfoReady Name = %s", LuaFeatureInfo.Name)
    local Key = LuaFeatureInfo.Name
    local Feature = this
    Feature.IsDynamicLuaFeature = true
    local CurrentInstance = this.Owner
    CurrentInstance[Key] = Feature
    if CurrentInstance.Features == nil then
      CurrentInstance.Features = {}
    end
    table.insert(CurrentInstance.Features, Feature)
  end
  return LuaFeatureClass
end
local EnableLuaClassIndexCache = not Client or Client.CanEnableLuaClassIndexCache()
local ClassCombinedWithFeatures = function(base, featuresmap)
  local classImplement = {}
  classImplement.__super_impl = base.__inner_impl
  classImplement.__super = base
  local base_mt = getmetatable(base)
  local class = {}
  class.__inner_impl = classImplement
  local class_index = function(t, k, cache)
    local impl = classImplement
    local ret
    while impl do
      ret = impl[k]
      if ret ~= nil then
        if EnableLuaClassIndexCache and cache ~= false then
          rawset(t, k, ret)
        end
        return ret
      end
      impl = impl.__super_impl
    end
    if k == "__BroadcastFeatureCall" then
      return function(FuncName, ...)
        for feature, _ in pairs(featuresmap) do
          if t[feature] and t[feature][FuncName] then
            t[feature][FuncName](t[feature], ...)
          end
        end
      end
    end
    return nil
  end
  local instance_metatable = {__index = class_index}
  setmetatable(class, {
    __index = class_index,
    __newindex = function()
      error("Prevent __newindex with class!")
    end,
    __call = function(...)
      local r = base_mt.__call(...)
      setmetatable(r, instance_metatable)
      if classImplement.ctor then
        classImplement.ctor(r, ...)
      end
      for name, feature in pairs(featuresmap) do
        local feature_inst = feature(...)
        feature_inst.Owne        rawset(r, name, feature_inst)
      end
      return r
    end
  })
  return class
end
function CombineClass.GenerateNamedFeatureClass(BaseClass, Features)
  if IsDevelopment then
    assert(getmetatable(BaseClass) ~= nil, "getmetatable(BaseClass) ~= nil")
  end
  local NewClass = BaseClass
  local GenerateClass = function(ClassImpName)
    if IsDevelopment then
      assert(type(ClassImpName) == "string", "type(ClassImpName) == \"string\"")
    end
    local SubModule = Loader(ClassImpName)
    local ClassImp = SubModule()
    return ClassImp
  end
  local ValidFeatureMap = {}
  for FeatureName, SubClassModuleName in pairs(Features) do
    local Cls = GenerateClass(SubClassModuleName)
    if Cls then
      ValidFeatureMap[FeatureName] = Cls
    end
  end
  return ClassCombinedWithFeatures(NewClass, ValidFeatureMap)
end
return CombineClass