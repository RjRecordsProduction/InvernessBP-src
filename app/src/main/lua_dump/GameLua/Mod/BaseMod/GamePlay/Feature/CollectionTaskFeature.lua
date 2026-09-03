local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UGameplayStatics = import("GameplayStatics")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local CollectionTaskFeature = {}
function CollectionTaskFeature:ctor()
  self.CollectionItems = {}
end
function CollectionTaskFeature:ReceiveBeginPlay()
  CollectionTaskFeature.__super.ReceiveBeginPlay(self)
  if not Client then
    if not self.Owner or not slua.isValid(self.Owner.Object) then
      print(bWriteLog and "CollectionTaskFeature:AddEvent failed")
      return
    end
    local uPlayerController = self.Owner
    self:AddControlEvent(uPlayerController, "OnPickupItem", self.OnPickUpItem, self)
    self:AddControlEvent(uPlayerController, "OnDropItem", self.OnDropItem, self)
    self:AddControlEvent(uPlayerController, "OnConsumeItem", self.OnConsumeItem, self)
    self:AddControlEvent(uPlayerController, "OnInitCollectionData", self.HandleCollectionDataInit, self)
    print(bWriteLog and "CollectionTaskFeature:AddEvent success")
  end
end
function CollectionTaskFeature:HandleCollectionDataInit(nItemID, nCollectedCount, nTotalCount)
  print(bWriteLog and "CollectionTaskFeature:HandleCollectionDataInit nItemId = ", nItemID, "nCollectedCount = ", nCollectedCount, "nTotalCount = ", nTotalCount)
  local uPlayerState = self.Owner.PlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "CollectionTaskFeature:HandleTaskDataInit uPlayerState is nil")
    return
  end
  if self.CollectionItems[nItemID] ~= nil then
    print(bWriteLog and "CollectionTaskFeature:HandleCollectionDataInit has init")
    return
  end
  if self.CollectionItems[nItemID] == nil then
    self.CollectionItems[nItemID] = {
      CollectedCount = nCollectedCount,
      CurCount = 0,
      TotalCount = nTotalCount
    }
  end
  uPlayerState:ReportSpecialCollection(nItemID, 0)
  if nTotalCount <= nCollectedCount then
    uPlayerState:ChangeCollectItemRecord(nItemID, true)
  end
  print(bWriteLog and "CollectionTaskFeature:HandleCollectionDataInit  init success")
end
function CollectionTaskFeature:OnDropItem(nItemID, nCount, uPlayerController)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "CollectionTaskFeature:OnDropItem Owner is nil")
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "CollectionTaskFeature:OnDropItem uPlayerState is nil")
    return
  end
  local tCollectionItem = self.CollectionItems[nItemID]
  if not tCollectionItem then
    print(bWriteLog and "CollectionTaskFeature:OnDropItem tCollectionItem is nil, nItemID is ", nItemID)
    return
  end
  tCollectionItem.CurCount = tCollectionItem.CurCount - nCount
  tCollectionItem.CollectedCount = tCollectionItem.CollectedCount - nCount
  uPlayerState:ReportSpecialCollection(nItemID, tCollectionItem.CurCount)
  if tCollectionItem.CurCount < tCollectionItem.TotalCount then
    uPlayerState:ChangeCollectItemRecord(nItemID, false)
  end
end
function CollectionTaskFeature:OnConsumeItem(nItemID, nCount, uPlayerController)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "CollectionTaskFeature:OnConsumeItem Owner is nil")
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "CollectionTaskFeature:OnConsumeItem uPlayerState is nil")
    return
  end
  local tCollectionItem = self.CollectionItems[nItemID]
  if not tCollectionItem then
    print(bWriteLog and "CollectionTaskFeature:OnConsumeItem tCollectionItem is nil, nItemID is ", nItemID)
    return
  end
  tCollectionItem.CurCount = tCollectionItem.CurCount - nCount
  tCollectionItem.CollectedCount = tCollectionItem.CollectedCount - nCount
  uPlayerState:ReportSpecialCollection(nItemID, tCollectionItem.CurCount)
  if tCollectionItem.CurCount < tCollectionItem.TotalCount then
    uPlayerState:ChangeCollectItemRecord(nItemID, false)
  end
end
function CollectionTaskFeature:OnPickUpItem(nItemID, nCount, uPlayerController)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "CollectionTaskFeature:OnPickUpItem Owner is nil")
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "CollectionTaskFeature:OnPickUpItem uPlayerState is nil")
    return
  end
  local tCollectionItem = self.CollectionItems[nItemID]
  if not tCollectionItem then
    print(bWriteLog and "CollectionTaskFeature:OnPickUpItem tCollectionItem is nil, nItemID is ", nItemID)
    return
  end
  tCollectionItem.CurCount = tCollectionItem.CurCount + nCount
  tCollectionItem.CollectedCount = tCollectionItem.CollectedCount + nCount
  uPlayerState:ReportSpecialCollection(nItemID, tCollectionItem.CurCount)
  if tCollectionItem.CollectedCount >= tCollectionItem.TotalCount then
    uPlayerState:ChangeCollectItemRecord(nItemID, true)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCollectionTaskFeature = class(CFeatureBase, nil, CollectionTaskFeature)
return CCollectionTaskFeature