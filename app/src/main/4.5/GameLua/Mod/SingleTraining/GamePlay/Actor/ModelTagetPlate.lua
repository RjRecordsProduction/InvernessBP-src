local ModelTagetPlate = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function ModelTagetPlate:ctor()
  self.KeyID = 16011
  self.NewBie = false
end
function ModelTagetPlate:ReceiveBeginPlay()
  if Client then
    self.NewBie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SINGLETRAIN, self.KeyID)
    if slua.isValid(self.Object) then
      if self.NewBie then
        print(bWriteLog and "[YY-D] ModelTagetPlate:ReceiveBeginPlay PlateID = " .. self.PlateID)
        self:AddCommonEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW_ARROW, self.HandleArrowHide, self)
        local uPlayerController = GameplayData.GetPlayerController()
        if slua.isValid(uPlayerController) and uPlayerController.CheckExistSoundTraining then
          if not uPlayerController:CheckExistSoundTraining() then
            self.TargetArrow:SetVisibility(true, true)
          end
        else
          self.TargetArrow:SetVisibility(false, true)
        end
      else
        self.TargetArrow:SetVisibility(false, true)
      end
    end
  end
  self.bHasHide = true
  self.bHasActive = false
end
function ModelTagetPlate:HandleArrowHide(_, __, nModelID, bShow, nState)
  print(bWriteLog and "ModelTagetPlate:HandleArrowHide nModelID = " .. tostring(nModelID) .. " bShow = " .. tostring(bShow) .. " nState = " .. tostring(nState))
  if (nModelID == self.PlateID or nModelID < 0) and bShow ~= nil and nState ~= nil then
    if 1 == nState then
      self.TargetArrow:SetVisibility(bShow, true)
    elseif 2 == nState then
      if self.NewBie then
        self.NewBie = false
        DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SINGLETRAIN, self.KeyID)
      end
      self.TargetArrow:SetVisibility(bShow, true)
      self.bHasActive = true
    elseif 3 == nState and not self.bHasActive then
      self.TargetArrow:SetVisibility(bShow, true)
    end
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CModelTagetPlate = class(CActorBase, nil, ModelTagetPlate)
return CModelTagetPlate