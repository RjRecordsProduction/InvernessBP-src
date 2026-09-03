local LogicUgcFilterTag = {}
local AutoTagType = {
  [1] = 23,
  [2] = 24
}
function LogicUgcFilterTag:DefineAndResetData()
  self.ugc_tag_filters = nil
  self.SelectMainTag = nil
  self.SlectFineModTag = nil
  self.AllTagList = nil
  self.ugc_tag_select_filters = {}
  self.ugc_tag_tem_filters = {}
  self.ugc_sublebel_tem_filters = {}
  self.ugc_sublebel_filters = {}
  self.PrimaryTagList = nil
  self.FeatureTagList = nil
  self.SelectPrimarytypeTag = {}
  self.SelectFeatureTags = {}
  self.StorageTag = {}
  self.AllAutoTags = {}
  self.MainTitleID = 0
  self.OpenFilterIndex = nil
  self.OpenSublabels = false
  self.NowSelectTag = nil
end
function LogicUgcFilterTag:IsSelectTag(data, showPrimarytype)
  if showPrimarytype then
    if #self.SelectPrimarytypeTag >= 1 then
      return false, 49436
    end
    return true
  else
    if #self.SelectFeatureTags >= 2 then
      for k, v in ipairs(self.SelectFeatureTags) do
        if v.ID == data.ID then
          return true
        end
      end
      return false, 49436
    end
    return true
  end
end
function LogicUgcFilterTag:IsSelectMaxTag()
  return #self.SelectFeatureTags >= 2
end
function LogicUgcFilterTag:GetTemFiltersIndex(Type, bSameType)
  if not self.ugc_tag_tem_filters and #self.ugc_tag_tem_filters <= 0 then
    return 0
  end
  local Index = 0
  if bSameType then
    for k, v in ipairs(self.ugc_tag_tem_filters) do
      if v.Type == Type then
        if v.Type == 9 then
          if self:IsSelectOpenTag(v) then
            Index = Index - 1
          end
        else
          Index = Index + 1
        end
      end
    end
    return Index
  else
    local Tag = {}
    local TagIndex = {}
    for index, item in pairs(self.ugc_tag_tem_filters) do
      if not TagIndex[item.Type] then
        table.insert(Tag, item)
        TagIndex[item.Type] = true
      end
    end
    for k, v in pairs(Tag) do
      if v.Type == 9 and not self:IsSelectOpenTag(v) then
        table.remove(Tag, k)
      end
    end
    return #Tag
  end
end
function LogicUgcFilterTag:ClearFilterAllTags(index)
  if index == 1 then
    self.SelectPrimarytypeTag = {}
    self.SelectFeatureTags = {}
  elseif index == 2 then
    self.StorageTag = {}
  end
end
function LogicUgcFilterTag:ClearFilterSingleTag(Tag, index)
  if not Tag or not Tag.ID then
    return
  end
  if index == 1 then
    for k, v in ipairs(self.SelectPrimarytypeTag) do
      if v.ID == Tag.ID then
        table.remove(self.SelectPrimarytypeTag, k)
        break
      end
    end
    for k, v in ipairs(self.SelectFeatureTags) do
      if v.ID == Tag.ID then
        table.remove(self.SelectFeatureTags, k)
        break
      end
    end
  elseif index == 2 then
    local PrimaryType = self.StorageTag.SelectPrimarytypeTag or {}
    local FeatureType = self.StorageTag.SelectFeatureTags or {}
    for k, v in ipairs(PrimaryType) do
      if Tag.ID == v.ID then
        table.remove(PrimaryType, k)
        break
      end
    end
    for k, v in ipairs(FeatureType) do
      if Tag.ID == v.ID then
        table.remove(FeatureType, k)
        break
      end
    end
  end
end
function LogicUgcFilterTag:SetSelectfilters(data, index, showPrimarytype)
  if not self.StorageTag then
    self.StorageTag = {}
  end
  if not self.StorageTag.SelectPrimarytypeTag then
    self.StorageTag.SelectPrimarytypeTag = {}
  end
  if not self.StorageTag.SelectFeatureTags then
    self.StorageTag.SelectFeatureTags = {}
  end
  if index == 1 then
    if showPrimarytype then
      for k, Tag in pairs(self.SelectPrimarytypeTag) do
        if Tag.ID == data.ID then
          return
        end
      end
      table.insert(self.SelectPrimarytypeTag, data)
    else
      for k, Tag in pairs(self.SelectFeatureTags) do
        if Tag.ID == data.ID then
          return
        end
      end
      table.insert(self.SelectFeatureTags, data)
    end
  elseif index == 2 then
    local PrimaryType = {}
    local FeatureType = {}
    for k, v in pairs(self.SelectPrimarytypeTag) do
      table.insert(PrimaryType, v)
    end
    for k, v in pairs(self.SelectFeatureTags) do
      table.insert(FeatureType, v)
    end
    self.StorageTag.SelectPrimarytypeTag = PrimaryType
    self.StorageTag.SelectFeatureTags = FeatureType
  elseif index == 3 then
    if self.StorageTag.SelectPrimarytypeTag then
      local PrimaryType = {}
      for k, v in pairs(self.StorageTag.SelectPrimarytypeTag) do
        table.insert(PrimaryType, v)
      end
      self.SelectPrimarytypeTag = PrimaryType
    else
      self.SelectPrimarytypeTag = {}
    end
    if self.StorageTag.SelectFeatureTags then
      local FeatureType = {}
      for k, v in pairs(self.StorageTag.SelectFeatureTags) do
        table.insert(FeatureType, v)
      end
      self.SelectFeatureTags = FeatureType
    else
      self.SelectFeatureTags = {}
    end
  elseif index == 5 then
    if showPrimarytype then
      table.insert(self.StorageTag.SelectPrimarytypeTag, data)
    else
      table.insert(self.StorageTag.SelectFeatureTags, data)
    end
  end
end
function LogicUgcFilterTag:GetTemTagFeaturesTag()
  if #self.ugc_tag_tem_filters >= 1 then
    return self.ugc_tag_tem_filters[1].FeaturesTag
  else
    return nil
  end
end
function LogicUgcFilterTag:SetOpenFilterIndex(Index)
  self.OpenFilterend
function LogicUgcFilterTag:GetOpenFilterIndex()
  return self.OpenFilterIndex
end
function LogicUgcFilterTag:SetOpenSublabel(bool, Tag)
  if bool then
    self.OpenSublabels = bool
    self.NowSelect    return
  end
  self.OpenSublabels = bool
  self.NowSelectend
function LogicUgcFilterTag:GetOpenSublabel()
  return self.OpenSublabels, self.NowSelectTag
end
function LogicUgcFilterTag:IsSelectOpenTag(Tag)
  for k, v in pairs(self.ugc_sublebel_tem_filters) do
    if v.Type == Tag.ID then
      return true
    end
  end
  return false
end
function LogicUgcFilterTag:GetSearchTagID()
  if not self.StorageTag then
    return
  end
  local Tags = {}
  local PrimaryTags = self.StorageTag.SelectPrimarytypeTag or {}
  local FeatureTags = self.StorageTag.SelectFeatureTags or {}
  for _, v in ipairs(PrimaryTags) do
    table.insert(Tags, v.ID)
  end
  for _, v in ipairs(FeatureTags) do
    table.insert(Tags, v.ID)
  end
  return Tags
end
function LogicUgcFilterTag:GetSearchTag()
  local Tags = {}
  local Sublebels = {}
  for _, v in ipairs(self.ugc_tag_select_filters) do
    if v.Type ~= 9 then
      table.insert(Tags, v)
    end
  end
  for k, v in pairs(self.ugc_sublebel_filters) do
    table.insert(Sublebels, v)
  end
  return Tags, Sublebels
end
function LogicUgcFilterTag:GetSearchTemTag()
  local Tags = {}
  local Sublebels = {}
  for _, v in ipairs(self.SelectPrimarytypeTag) do
    table.insert(Tags, v)
  end
  for k, v in pairs(self.SelectFeatureTags) do
    table.insert(Sublebels, v)
  end
  return Tags, Sublebels
end
function LogicUgcFilterTag:GetSearchTags()
  local Tags = {}
  local Sublebels = {}
  for _, v in ipairs(self.ugc_tag_tem_filters) do
    if v.Type == 9 then
      if self:IsSelectOpenTag(v) then
        table.insert(Tags, v)
      end
    else
      table.insert(Tags, v)
    end
  end
  for k, v in pairs(self.ugc_sublebel_tem_filters) do
    table.insert(Sublebels, v)
  end
  return self.SelectPrimarytypeTag, self.SelectFeatureTags
end
function LogicUgcFilterTag:GetFilters(data, type)
  if not data or not next(data) then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local FilterTags = {}
  if type == 1 then
    local Tags = Config_UGC:GetTagConfig()
    for Tagkey, Tag in pairs(Tags) do
      for k, v in pairs(data) do
        if Tag.ID == v and Tag.isInvisible ~= 1 then
          table.insert(FilterTags, {
            ID = Tag.ID,
            Name = Tag.Name,
            Type = Tag.Type,
            TagDescriptionKey = Tag.TagDescriptionKey,
            SortNum = v
          })
        end
      end
    end
  elseif type == 2 then
    local Sublabels = Config_UGC:GetSublabelConfig()
    for Subkey, Sublabel in pairs(Sublabels) do
      for k, v in pairs(data) do
        if Sublabel.ID == k and Sublabel.isInvisible ~= 1 then
          table.insert(FilterTags, {
            ID = Sublabel.ID,
            Name = Sublabel.Name,
            Type = Sublabel.Type,
            TitleType = Sublabel.TitleType,
            SortNum = v
          })
        end
      end
    end
  end
  return FilterTags
end
function LogicUgcFilterTag:GetIDtoTags(IDdata, type)
  if not IDdata or not next(IDdata) then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local FilterTags = {}
  if type == 1 then
    local Tags = Config_UGC:GetTagConfig()
    for Tagkey, Tag in pairs(Tags) do
      for k, v in pairs(IDdata) do
        if Tag.ID == v then
          table.insert(FilterTags, {
            ID = Tag.ID,
            Name = Tag.Name,
            Type = Tag.Type,
            PrimaryType = Tag.PrimaryType
          })
        end
      end
    end
  elseif type == 2 then
    local Sublabels = Config_UGC:GetSublabelConfig()
    for Subkey, Sublabel in pairs(Sublabels) do
      for k, v in pairs(IDdata) do
        if Sublabel.ID == v then
          table.insert(FilterTags, {
            ID = Sublabel.ID,
            Name = Sublabel.Name,
            Type = Sublabel.Type
          })
        end
      end
    end
  end
  return FilterTags
end
function LogicUgcFilterTag:GetDisplayTagList(TagIDs, SubFeatureTagIDs)
  local sortTagList = self:GetIDtoTags(TagIDs, 1) or {}
  local featureTag = self:GetIDtoTags(SubFeatureTagIDs, 2) or {}
  if featureTag and next(featureTag) then
    local featureTagMap = {}
    for _, v in ipairs(featureTag) do
      if not featureTagMap[v.Type] then
        featureTagMap[v.Type] = {}
      end
      table.insert(featureTagMap[v.Type], v)
    end
    local i = 1
    while i <= #sortTagList do
      local sortTag = sortTagList[i]
      if featureTagMap[sortTag.ID] then
        table.remove(sortTagList, i)
        for _, feature in ipairs(featureTagMap[sortTag.ID]) do
          table.insert(sortTagList, i, feature)
          i = i + 1
        end
      else
        i = i + 1
      end
    end
  end
  self:SortTagListForDisplay(sortTagList)
  return sortTagList
end
function LogicUgcFilterTag:GetTagtoName(data)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Tags = Config_UGC:GetTagConfig()
  local Sublabels = Config_UGC:GetSublabelConfig()
  for k, v in pairs(Tags) do
    if v.Name == data.Name then
      return v, 1
    end
  end
  for k, v in pairs(Sublabels) do
    if v.Name == data.Name then
      return v, 2
    end
  end
end
function LogicUgcFilterTag:AddTagtoSublabel()
  if self.ugc_sublebel_filters and #self.ugc_sublebel_filters >= 1 then
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local Tags = Config_UGC:GetTagConfig()
    for k, subTag in pairs(self.ugc_sublebel_filters) do
      for k, Tag in pairs(Tags) do
        if Tag.ID == subTag.Type then
          self:SetSelectfilters(Tag, 5)
        end
      end
    end
  end
end
function LogicUgcFilterTag:SearchTopSetFilterTagForTabAll(filter_tags)
  self.SelectMainTag = filter_tags
end
function LogicUgcFilterTag:ReSetFilterTag()
  self.ugc_tag_filters = {}
end
function LogicUgcFilterTag:SetAllTagList()
  if not self.PrimaryTagList or not self.FeatureTagList then
    log(bWriteLog and "LogicUgcFilterTag:SetAllTagList")
    local config_ugc = require("client.slua.logic.ugc.config_ugc")
    self.PrimaryTagList = config_ugc:GetPrimaryTagList()
    self.FeatureTagList = config_ugc:GetFeatureTagList()
  end
  if not next(self.AllAutoTags) then
    self:GetAllAutoTags()
  end
end
function LogicUgcFilterTag:GetAllAutoTags()
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  local TagConfig = config_ugc:GetTagConfig()
  self.AllAutoTags = {}
  for k, Tags in pairs(TagConfig) do
    for _, AutoID in pairs(AutoTagType) do
      if Tags.Type == AutoID then
        table.insert(self.AllAutoTags, Tags)
        break
      end
    end
  end
end
function LogicUgcFilterTag:GetTagList()
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  local tagList = {}
  if not self.AllTagList then
    self.AllTagList = config_ugc:GetAllTagList()
  end
  for key, value in pairs(self.AllTagList) do
    if value.ID ~= 9 then
      table.insert(tagList, value)
    end
  end
  return tagList
end
function LogicUgcFilterTag:CheckSelectRecommendTag()
  local TableUtil = require("common.table_util")
  if TableUtil.CountTable(self.SelectPrimarytypeTag) + TableUtil.CountTable(self.SelectFeatureTags) >= 5 then
    return false
  else
    return true
  end
end
function LogicUgcFilterTag:GetSelectPrimarytypeTag()
  return self.SelectPrimarytypeTag
end
function LogicUgcFilterTag:GetSelectFeatureTags()
  return self.SelectFeatureTags
end
function LogicUgcFilterTag:GetStorageTags()
  if not self.StorageTag then
    return
  end
  if not self.StorageTag.SelectPrimarytypeTag and not self.StorageTag.SelectFeatureTags then
    return
  end
  return self.StorageTag
end
function LogicUgcFilterTag:GetAllTagList()
  local TableUtil = require("common.table_util")
  self:SetAllTagList()
  local PrimaryTag = TableUtil.CopyTable(self.PrimaryTagList)
  local FeatureTag = TableUtil.CopyTable(self.FeatureTagList)
  return PrimaryTag, FeatureTag
end
function LogicUgcFilterTag:CheckOldTag(Tags, Subtags)
  if (not Tags or not next(Tags)) and (not Subtags or not next(Subtags)) then
    return false
  end
  self:SetAllTagList()
  local newTagMap = {}
  for _, typeData in ipairs(self.PrimaryTagList or {}) do
    for _, tag in ipairs(typeData.Tags or {}) do
      newTagMap[tag.ID] = true
    end
  end
  for _, typeData in ipairs(self.FeatureTagList or {}) do
    for _, tag in ipairs(typeData.Tags or {}) do
      newTagMap[tag.ID] = true
    end
  end
  for _, tag in ipairs(self.AllAutoTags or {}) do
    if tag and tag.ID then
      newTagMap[tag.ID] = true
    end
  end
  for _, tagID in pairs(Tags) do
    if not newTagMap[tagID] then
      return true
    end
  end
  for _, subtagID in pairs(Subtags) do
    if not newTagMap[subtagID] then
      return true
    end
  end
  return false
end
function LogicUgcFilterTag:CheckAutoTag(AutoTags)
  if not AutoTags then
    return false
  end
  for k, ID in pairs(AutoTags) do
    for k, Tags in pairs(self.AllAutoTags) do
      if Tags.ID == ID then
        return true
      end
    end
  end
  return false
end
function LogicUgcFilterTag:GetAutoTag(TagID)
  if not self.AllAutoTags or #self.AllAutoTags <= 0 then
    self:GetAllAutoTags()
  end
  for k, Tags in pairs(self.AllAutoTags) do
    if Tags.ID == TagID then
      return Tags
    end
  end
  return nil
end
function LogicUgcFilterTag:GetAutoTags()
  return self.AllAutoTags
end
function LogicUgcFilterTag:GetPrimaryAndFeatureTagInfoByIDs(Tags)
  if not Tags then
    return {}, {}
  end
  self:SetAllTagList()
  local PrimaryTagInfo = {}
  local FeatureTagInfo = {}
  local TagIDMap = {}
  local bIsArray = false
  for k, v in pairs(Tags) do
    if type(k) == "number" and 1 <= k and k == math.floor(k) then
      bIsArray = true
      TagIDMap[v] = true
    else
      bIsArray = false
      break
    end
  end
  if not bIsArray then
    TagIDMap = {}
    for k, v in pairs(Tags) do
      TagIDMap[k] = v
    end
  end
  if self.PrimaryTagList then
    for _, typeData in ipairs(self.PrimaryTagList) do
      for _, tag in ipairs(typeData.Tags or {}) do
        if TagIDMap[tag.ID] then
          table.insert(PrimaryTagInfo, tag)
        end
      end
    end
  end
  if self.FeatureTagList then
    for _, typeData in ipairs(self.FeatureTagList) do
      for _, tag in ipairs(typeData.Tags or {}) do
        if TagIDMap[tag.ID] then
          table.insert(FeatureTagInfo, tag)
        end
      end
    end
  end
  return PrimaryTagInfo, FeatureTagInfo
end
function LogicUgcFilterTag:FilterPrimaryTags(Tags)
  if not Tags then
    return {}
  end
  self:SetAllTagList()
  local PrimaryTagInfo = {}
  local TagIDMap = {}
  for _, v in pairs(Tags) do
    TagIDMap[v.ID] = true
  end
  if self.PrimaryTagList then
    for _, typeData in ipairs(self.PrimaryTagList) do
      for _, tag in ipairs(typeData.Tags or {}) do
        if TagIDMap[tag.ID] then
          table.insert(PrimaryTagInfo, tag)
        end
      end
    end
  end
  return PrimaryTagInfo
end
function LogicUgcFilterTag:CheckAutoTagChange(Tags, Autotags)
  if not Tags or not next(Tags) then
    return false, Tags, nil
  end
  local autoTagTypeIDMap = {}
  for _, TypeID in ipairs(AutoTagType) do
    autoTagTypeIDMap[TypeID] = true
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local TagConfig = Config_UGC:GetTagConfig()
  local TagInfoMap = {}
  for _, TagInfo in pairs(TagConfig or {}) do
    TagInfoMap[TagInfo.ID] = TagInfo
  end
  local OldAutoTagMap = {}
  for _, TagID in ipairs(Tags) do
    local TagInfo = TagInfoMap[TagID]
    if TagInfo and autoTagTypeIDMap[TagInfo.Type] then
      OldAutoTagMap[TagInfo.Type] = TagInfo
    end
  end
  local NewAutoTagMap = {}
  if Autotags and next(Autotags) then
    for _, TagID in pairs(Autotags) do
      local TagInfo = TagInfoMap[TagID]
      if TagInfo and autoTagTypeIDMap[TagInfo.Type] then
        NewAutoTagMap[TagInfo.Type] = TagInfo
      end
    end
  end
  local AutoTagChangeList = {}
  local RemoveAutoTagMap = {}
  for _, TypeID in ipairs(AutoTagType) do
    local BeforeTag = OldAutoTagMap[TypeID]
    local AfterTag = NewAutoTagMap[TypeID]
    if BeforeTag and (not AfterTag or BeforeTag.ID ~= AfterTag.ID) then
      table.insert(AutoTagChangeList, {
        Type = TypeID,
        BeforeTag = BeforeTag,
              })
      RemoveAutoTagMap[BeforeTag.ID] = true
    end
  end
  if next(AutoTagChangeList) then
    local NewTags = {}
    for _, TagID in ipairs(Tags) do
      if not RemoveAutoTagMap[TagID] then
        table.insert(NewTags, TagID)
      end
    end
    return true, NewTags, AutoTagChangeList
  end
  return false, Tags, nil
end
local GetTagDisplayWeight = function(tag)
  if tag.PrimaryType and tag.PrimaryType ~= 0 then
    return 1
  elseif tag.Type == 23 then
    return 2
  elseif tag.Type == 24 then
    return 3
  else
    return 4
  end
end
local CompareTagForDisplay = function(a, b)
  return GetTagDisplayWeight(a) < GetTagDisplayWeight(b)
end
function LogicUgcFilterTag:SortTagListForDisplay(tagList)
  if not tagList or #tagList <= 1 then
    return tagList
  end
  table.sort(tagList, CompareTagForDisplay)
  return tagList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUgcFilterTag = class(CModuleBase, nil, LogicUgcFilterTag)
return CLogicUgcFilterTag