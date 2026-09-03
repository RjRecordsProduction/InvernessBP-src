local Class = require("class")
local Trait = {}
local local string_format = string.format
local local local local local local local local local local local local local DevCheck = IsEditor
local GetFilename = function(Depth)
  Depth = Depth or 3
  local Info = debug.getinfo(Depth)
  local StringUtil = require("common.string_util")
  local Tmp = StringUtil.Split(Info.short_src, "/")
  Tmp = Tmp[#Tmp]
  Tmp = StringUtil.Split(Tmp, ".")
  if Tmp[1] == "[C]" then
    return "[Anonymous Tail Trait]"
  end
  return Tmp[1]
end
local TraitClassImplMetatable = {
  __index = function(t, k)
    local OrigMeta = rawget(t, "__orig_meta")
    if OrigMeta and OrigMeta.__index then
      local OrigMetaIndexRet
      if type(OrigMeta.__index) == "function" then
        OrigMetaIndexRet = OrigMeta.__index(t, k)
      elseif type(OrigMeta.__index) == "table" then
        OrigMetaIndexRet = OrigMeta.__index[t]
      end
      if OrigMetaIndexRet then
        return OrigMetaIndexRet
      end
    end
    local Traits = rawget(t, "__traits")
    if not Traits then
      log_error("TraitClassImplMetatable __index Triggered while no __traits exist!")
      return nil
    end
    local TraitImpls = rawget(t, "__trait_impls")
    for _, TTrait in pairs(Traits) do
      if TraitImpls and TraitImpls[TTrait] and TraitImpls[TTrait][k] then
        if DevCheck then
          log(bWriteLog and string_format("[Trait] Class defined in [%s] Acessed Field [%s] of Trait defined in [%s] with independent implement table", t.__class_file or "[Anonymous Class]", tostring(k), TTrait.__trait_file or "[Anonymous Trait]"))
        end
        return TraitImpls[TTrait][k]
      elseif TTrait[k] then
        if DevCheck then
          log(bWriteLog and string_format("[Trait] Class defined in [%s] Acessed Field [%s] of Trait defined in [%s]", t.__class_file or "[Anonymous Class]", tostring(k), TTrait.__trait_file or "[Anonymous Trait]"))
        end
        return TTrait[k]
      end
    end
    return nil
  end
}
local SetTraitMetatable = function(ClassImplement, Metatable)
  local OringinMeta = getmetatable(ClassImplement)
  if OringinMeta then
    ClassImplement.__orig_meta = OringinMeta
  end
  setmetatable(ClassImplement, nil)
  setmetatable(ClassImplement, Metatable)
end
function Trait.Default()
  return function()
    log_error("[Trait] Default implementation should NEVER be invoked directly, override it in your class.")
  end
end
function Trait.IsImplementationOf(TraitClass, TTrait)
  if not TraitClass.__traits then
    return false
  end
  for _, v in pairs(TraitClass.__traits) do
    if v == TTrait then
      return true
    end
  end
  return false
end
function Trait.IsChildOf(ObjOrCls, Cls)
  if ObjOrCls == nil then
    return false
  end
  return ObjOrCls.__inner_impl == Cls.__inner_impl or Trait.IsChildOf(ObjOrCls.__super, Cls)
end
function Trait.TraitClass(Base, Static, ClassImplement, Traits)
  if DevCheck then
    ClassImplement.__class_file = GetFilename()
  end
  if Traits and next(Traits) then
    ClassImplement.__traits = Traits
    ClassImplement.__trait_impls = ClassImplement.__trait_impls or {}
    for _, TTrait in pairs(Traits) do
      if TTrait.__contain_override_funcs then
        for FieldName, FieldVal in pairs(TTrait.__inner_impl) do
          if not ClassImplement[FieldName] then
            ClassImplement[FieldName] = FieldVal
          end
        end
      end
    end
    setmetatable(ClassImplement.__traits, {
      __index = function(t, k)
        for _, Trait in pairs(t) do
          if Trait[k] then
            return Trait[k]
          end
        end
        return nil
      end
    })
    SetTraitMetatable(ClassImplement, TraitClassImplMetatable)
  end
  local RetClass = Class(Base, Static, ClassImplement)
  if DevCheck and Traits then
    local Reload = RequireBlackList("blacklist.reload.reload")
    Reload.CollectTrait(Traits)
    for _, TTrait in pairs(Traits) do
      for BoundName, Bound in pairs(TTrait.__bounds) do
        assert(Trait.IsChildOf(RetClass, Bound) or Trait.IsImplementationOf(RetClass, Bound), "Do Not Match Bound Class defined")
      end
    end
  end
  return RetClass
end
function Trait.Implement(CClass, TTrait, TraitImplTable)
  local ClassImplement = rawget(CClass, "__inner_impl")
  ClassImplement.__traits = ClassImplement.__traits or {}
  ClassImplement.__trait_impls = ClassImplement.__trait_impls or {}
  if ClassImplement.__traits[TTrait] then
    ClassImplement.__trait_impls[TTrait] = ClassImplement.__trait_impls[TTrait] or {}
    if TraitImplTable then
      for k, v in pairs(TraitImplTable) do
        ClassImplement.__trait_impls[TTrait][k] = v
      end
    end
  else
    ClassImplement.__traits[#ClassImplement.__traits + 1] = TTrait
    ClassImplement.__trait_impls[TTrait] = TraitImplTable
  end
  if TTrait.__contain_override_funcs then
    for FieldName, FieldVal in pairs(TraitImplTable) do
      if not ClassImplement[FieldName] then
        ClassImplement[FieldName] = FieldVal
      end
    end
  end
  SetTraitMetatable(ClassImplement, TraitClassImplMetatable)
  return CClass
end
function Trait.CreateTrait(BaseTrait, Static, TraitDescTable, bContainOverrideFuncs, Bounds)
  BaseTrait = BaseTrait or Trait.TraitPrototype
  if DevCheck then
    TraitDescTable.__trait_file = GetFilename()
  end
  if bContainOverrideFuncs then
    TraitDescTable.__contain_override_funcs = true
  end
  TraitDescTable.__bounds = Bounds or {}
  return Class(BaseTrait, Static, TraitDescTable)
end
setmetatable(Trait, {
  __call = function(TraitTable, ...)
    return TraitTable.CreateTrait(...)
  end
})
local TraitPrototype = {}
setmetatable(TraitPrototype, {
  __call = function()
  end
})
Trait.TraitPrototype = Class(TraitPrototype, nil, nil)
return Trait