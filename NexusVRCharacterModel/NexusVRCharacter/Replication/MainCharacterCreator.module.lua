--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/MainCharacterCreator.module.lua
Author: TheNexusAvenger
Date: March 29th 2018



MainCharacterCreator:CreateNetworkableCharacter(Character)
	Returns false if Character isn't R15, and CharacterClass if the Character is valid
	Will yield for 10 seconds if Humanoid isn't found
	RETURNS: false or CharacterClass (see NexusVRCharacterModel/NexusVRCharacter/Character/CharacterCreator.module.lua)
MainCharacterCreator:CreateLocalCharacter(Character)
	Returns false if Character isn't R15, and FullLocalCharacterClass if the Character is valid
	Will yield for 10 seconds if Humanoid isn't found
	RETURNS: false or FullLocalCharacterClass
	
CLASS FullLocalCharacterClass
	** Inherits all functions from LocalCharacterClass (see NexusVRCharacterModel/NexusVRCharacter/Character/CharacterCreator.module.lua)
	CharacterClass:SetYPlaneLockWorldOffset(Enabled)
		When true, the Y plane will be locked for the camera. Used by controllers
		For every time true is used, false must be used afterwards or it will not unlock. This is for stacked controls.
	CharacterClass:UpdatePositionsFromInput(HeadsetCF,LeftControllerCF,RightControllerCF)
		Updates CFrames of rig from headset and controller CFrames
	CharacterClass:UpdateUsingControllerInput()
		Updates CFrames of rig from the current input. Hands will default to side if controllers not detected.
	CharacterClass.Humanoid
		Humanoid of CharacterModel
	CharacterClass.Camera
		CameraClass of CharacterClass (see NexusVRCharacterModel/NexusVRCharacter/UserInterface/Camera.module.lua)
	CharacterClass.PhysicsSolver
		PhysicsSolverClass of CharacterClass (see NexusVRCharacterModel/NexusVRCharacter/UserInterface/PhysicsSolver.module.lua)
--]]

local MainCharacterCreator = {}

local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local CONTROL_METHOD = Configuration.MainCharacterCreator.CONTROL_METHOD
local INVALID_CHARACTER_WARNING = "Nexus VR Character Model requires R15"
local CHARACTER_SCALE_CALLIBRATION = Configuration.MainCharacterCreator.CHARACTER_SCALE_CALLIBRATION
local CONTROLLER_OFFSET = Configuration.MainCharacterCreator.CONTROLLER_OFFSET
local RECENTER_OFFSET = Configuration.MainCharacterCreator.RECENTER_OFFSET
local USE_THIRD_PERSON = Configuration.CameraCreator.USE_THIRD_PERSON

local Character = script.Parent.Parent:WaitForChild("Character")
local UserInterface = script.Parent.Parent:WaitForChild("UserInterface")
local CharacterCreator = require(Character:WaitForChild("CharacterCreator"))
local CameraCreator = require(UserInterface:WaitForChild("CameraCreator"))
local ArcControllerCreator = require(UserInterface:WaitForChild("ArcControllerCreator"))
local MoveControllerCreator = require(UserInterface:WaitForChild("MoveControllerCreator"))
local ABXYControllerCreator = require(UserInterface:WaitForChild("ABXYControllerCreator"))
local PhysicsSolver = require(UserInterface:WaitForChild("PhysicsSolver"))
local MessageCreator = require(UserInterface:WaitForChild("MessageCreator"))





local function IsCharacterValid(Character)
	Character:WaitForChild("Head",10)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local StartTime = tick()
	while not Humanoid and Character.Parent and tick() - StartTime < 10 do 
		wait()
		Humanoid = Character:FindFirstChildOfClass("Humanoid")
	end
	
	if not Humanoid then
		return false
	else
		return Humanoid.RigType == Enum.HumanoidRigType.R15
	end
end



function MainCharacterCreator:CreateNetworkableCharacter(Character)
	if not IsCharacterValid(Character) then
		return false
	end
	
	local CharacterClass = CharacterCreator:CreateCharacter(Character,false)
	return CharacterClass
end

function MainCharacterCreator:CreateLocalCharacter(CharacterModel)
	if not IsCharacterValid(CharacterModel) then
		MessageCreator:DisplayFullScreenMessage(INVALID_CHARACTER_WARNING)
		return false
	end
	
	local CharacterClass = CharacterCreator:CreateCharacter(CharacterModel,true)
	local Humanoid = CharacterModel:FindFirstChildOfClass("Humanoid")
	local LowerTorso = CharacterModel:WaitForChild("LowerTorso")
	local PhysicalHead = CharacterModel:WaitForChild("Head")
	
	local Camera = CameraCreator:CreateCamera()
	Camera:SetScale(CHARACTER_SCALE_CALLIBRATION)
	
	CharacterClass.Humanoid = Humanoid
	CharacterClass.Camera = Camera
	
	local Controller1,Controller2
	local GamePadController1,GamePadController2
	
	if CONTROL_METHOD == "Arc" then
		Controller1 = ArcControllerCreator:CreateArcController(Enum.VRTouchpad.Left,CharacterClass)
		Controller2 = ArcControllerCreator:CreateArcController(Enum.VRTouchpad.Right,CharacterClass)
		GamePadController1 = MoveControllerCreator:CreateMoveController(nil,CharacterClass)
		GamePadController2 = ABXYControllerCreator:CreateABXYController(nil,CharacterClass)
	elseif CONTROL_METHOD == "Move" then
		Controller1 = MoveControllerCreator:CreateMoveController(Enum.VRTouchpad.Left,CharacterClass)
		Controller2 = ABXYControllerCreator:CreateABXYController(Enum.VRTouchpad.Right,CharacterClass)
		GamePadController1 = MoveControllerCreator:CreateMoveController(nil,CharacterClass)
	end
	
	local HeightSolver = PhysicsSolver:CreateSolver(CharacterClass)
	CharacterClass.PhysicsSolver = HeightSolver
	
	local WorldOffsetYOverride
	local WorldOffsetYEnabledCount = 0
	function CharacterClass:SetYPlaneLockWorldOffset(Enabled)
		if Enabled then
			WorldOffsetYEnabledCount = WorldOffsetYEnabledCount + 1
		else
			WorldOffsetYEnabledCount = WorldOffsetYEnabledCount - 1
		end
		
		if WorldOffsetYEnabledCount > 0 then
			if not WorldOffsetYOverride then
				WorldOffsetYOverride = CharacterClass:GetWorldOffset().Y
			end
		else
			WorldOffsetYEnabledCount = 0
			WorldOffsetYOverride = nil
		end
	end
	
	function CharacterClass:UpdatePositionsFromInput(HeadsetCF,LeftControllerCF,RightControllerCF)
		local WorldOffset = CharacterClass:GetWorldOffset()
		local LeftControllerRelative = HeadsetCF:inverse() * LeftControllerCF
		local RightControllerRelative = HeadsetCF:inverse() * RightControllerCF
		
		HeadsetCF = Camera:ScaleInput(HeadsetCF) + RECENTER_OFFSET
		LeftControllerCF = HeadsetCF * LeftControllerRelative
		RightControllerCF = HeadsetCF * RightControllerRelative
		
		if WorldOffsetYOverride then
			local DeltaY = WorldOffsetYOverride - WorldOffset.Y
			Camera:UpdateCamera(CFrame.new(0,DeltaY,0) * WorldOffset * HeadsetCF)
		else
			Camera:UpdateCamera(WorldOffset * HeadsetCF)
		end	
		CharacterClass:UpdatePositions(HeadsetCF,LeftControllerCF,RightControllerCF)
		
		if Controller1 then Controller1:UpdateController(WorldOffset * LeftControllerCF) end
		if Controller2 then Controller2:UpdateController(WorldOffset * RightControllerCF) end
		if GamePadController1 then GamePadController1:UpdateController(WorldOffset * HeadsetCF) end
	end

	local VRService = game:GetService("VRService")
	local Head,LeftHand,RightHand = Enum.UserCFrame.Head,Enum.UserCFrame.LeftHand,Enum.UserCFrame.RightHand
	local LeftHandDisconnectedOffset = CFrame.new(-1.5,0.2,0) * CFrame.Angles(-math.pi/2,0,0)
	local RightHandDisconnectedOffset = CFrame.new(1.5,0.2,0) * CFrame.Angles(-math.pi/2,0,0)
	function CharacterClass:UpdateUsingControllerInput()
		local HeadsetCF = VRService:GetUserCFrame(Head)
		
		local LeftControllerCF,RightControllerCF
		if VRService:GetUserCFrameEnabled(LeftHand) then
			LeftControllerCF = VRService:GetUserCFrame(LeftHand) * CONTROLLER_OFFSET
		else
			local HandWorldCF = LowerTorso.CFrame * LeftHandDisconnectedOffset
			local HandLocalSpace = PhysicalHead.CFrame:inverse() * HandWorldCF
			LeftControllerCF = HeadsetCF * HandLocalSpace
		end
		if VRService:GetUserCFrameEnabled(RightHand) then
			RightControllerCF = VRService:GetUserCFrame(RightHand) * CONTROLLER_OFFSET
		else
			local HandWorldCF = LowerTorso.CFrame * RightHandDisconnectedOffset
			local HandLocalSpace = PhysicalHead.CFrame:inverse() * HandWorldCF
			RightControllerCF = HeadsetCF * HandLocalSpace
		end
		
		CharacterClass:UpdatePositionsFromInput(HeadsetCF,LeftControllerCF,RightControllerCF)
	end
	
	local OriginalDisconnectFunction = CharacterClass.Disconnect
	function CharacterClass:Disconnect()
		OriginalDisconnectFunction(CharacterClass)
		if Controller1 then Controller1:Disconnect() end
		if Controller2 then Controller2:Disconnect() end
		if GamePadController1 then GamePadController1:Disconnect() end
		if GamePadController2 then GamePadController2:Disconnect() end
		HeightSolver:Disconnect()
	end
	
	
	
	local function HideHeadAccessories()
		if not USE_THIRD_PERSON then
			for _,Ins in pairs(Humanoid:GetAccessories()) do
				local Handle = Ins:FindFirstChild("Handle")
				if Handle then
					local AccessoryWeld = Handle:FindFirstChild("AccessoryWeld")
					if AccessoryWeld and AccessoryWeld.Part1.Anchored == true then
						Handle.LocalTransparencyModifier = 1
					end
				end
			end
		end
	end
	HideHeadAccessories()
	CharacterModel.ChildAdded:Connect(HideHeadAccessories)
	
	CharacterClass:SetWorldXZOffset(LowerTorso.Position.X,LowerTorso.Position.Z)
	HeightSolver:SetNewContext(LowerTorso.Position - Vector3.new(0,2,0))
	VRService:RecenterUserHeadCFrame()	
	
	return CharacterClass
end

return MainCharacterCreator
