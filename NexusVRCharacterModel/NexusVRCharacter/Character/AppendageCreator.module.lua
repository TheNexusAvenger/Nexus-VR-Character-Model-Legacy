--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/AppendageCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018


	
AppendageCreator:CreateRightArm(CharacterModel)
	Converts R15 Right Arm of given CharacterModel to AppendageClass
	RETURNS: AppendageClass
AppendageCreator:CreateLeftArm(CharacterModel)
	Converts R15 Left Arm of given CharacterModel to AppendageClass
	RETURNS: AppendageClass
AppendageCreator:CreateRightLeg(CharacterModel)
	Converts R15 Right Leg of given CharacterModel to AppendageClass
	RETURNS: AppendageClass
AppendageCreator:CreateLeftLeg(CharacterModel)
	Converts R15 Right Leg of given CharacterModel to AppendageClass
	RETURNS: AppendageClass

CLASS AppendageClass
	AppendageClass:UpdatePositions(StartCF,TargetPos)
		Moves upper limb and lower limb based on starting CFrame and target position
	AppendageClass:SetLocalTransparencyModifier(TransparencyModifier)
		Sets LocalTransparencyModifier of limb
	AppendageClass:GetLocalTransparencyModifier()
		Gets LocalTransparencyModifier of limb
		RETURNS: double
	AppendageClass:GetAttachmentPosition()
		Gets offset of shoulder of limb to connect
		RETURNS: Vector3
	AppendageClass:GetAppendageLength()
		Gets max length of appendage
		RETURNS: double
	AppendageClass:Disconnect()
		Disconnects all events and unanchores the limbs

--]]

local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local KEEP_MOTOR6DS = Configuration.AppendageCreator.KEEP_MOTOR6DS



local AppendageCreator = {}

local Util = require(script.Parent:WaitForChild("Util"))

local Attachments = {
	["RightUpperArm"] = {
		"RightShoulderRigAttachment",
		"RightElbowRigAttachment",
		"RightElbowRigAttachment",
		"RightWristRigAttachment",
	},
	["LeftUpperArm"] = {
		"LeftShoulderRigAttachment",
		"LeftElbowRigAttachment",
		"LeftElbowRigAttachment",
		"LeftWristRigAttachment",
	},
	["RightUpperLeg"] = {
		"RightHipRigAttachment",
		"RightKneeRigAttachment",
		"RightKneeRigAttachment",
		"RightAnkleRigAttachment",
	},
	["LeftUpperLeg"] = {
		"LeftHipRigAttachment",
		"LeftKneeRigAttachment",
		"LeftKneeRigAttachment",
		"LeftAnkleRigAttachment",
	},
}

local Motors = {
	["RightUpperArm"] = {
		"RightShoulder",
		"RightElbow",
	},
	["LeftUpperArm"] = {
		"LeftShoulder",
		"LeftElbow",
	},
	["RightUpperLeg"] = {
		"RightHip",
		"RightKnee",
	},
	["LeftUpperLeg"] = {
		"LeftHip",
		"LeftKnee",
	},
}

local CFnew,CFAngles = CFrame.new,CFrame.Angles
local abs,atan2 = math.abs,math.atan2



local function GetAngleX(CF)
	local LookVector = CF.lookVector
	local X,Y,Z = LookVector.X,LookVector.Y,LookVector.Z
	local XZ = ((X ^ 2) + (Z ^ 2)) ^ 0.5
	
	return atan2(Y,XZ)
end

local function CreateAppendage(AppendageClass,UpperLimb,LowerLimb,AllowDisconnectingLimbs)
	local UpperRigAttachment = UpperLimb:WaitForChild(Attachments[UpperLimb.Name][1])
	local UpperMidleRigAttachment = UpperLimb:WaitForChild(Attachments[UpperLimb.Name][2])
	local LowerMiddleRigAttachment = LowerLimb:WaitForChild(Attachments[UpperLimb.Name][3])
	local LowerRigAttachment = LowerLimb:WaitForChild(Attachments[UpperLimb.Name][4])
	
	local UpperMotor = UpperLimb:WaitForChild(Motors[UpperLimb.Name][1])
	local LowerMotor = LowerLimb:WaitForChild(Motors[UpperLimb.Name][2])
	local UpperAnchoredPart,LowerAnchoredPart
	if not KEEP_MOTOR6DS then
		UpperMotor.Part0 = nil
		UpperMotor.Part1 = nil
		LowerMotor.Part0 = nil
		LowerMotor.Part1 = nil
		UpperAnchoredPart = Util:CreateAnchoredPart(UpperLimb)
		LowerAnchoredPart = Util:CreateAnchoredPart(LowerLimb)
	end
	
	local Length1,Length2 = 0,0
	local Offset1,Offset2 = 0,0
	local CurrentScale = 1
	local ShoulderOffset
	local function UpdateSizes(NewScale)
		local Scale = NewScale/CurrentScale
		CurrentScale = NewScale
		Util:ScaleDescendants(UpperLimb,Scale)
		Util:ScaleDescendants(LowerLimb,Scale)
		
		Length1 = abs(UpperRigAttachment.Position.Y - UpperMidleRigAttachment.Position.Y)
		Length2 = abs(LowerMiddleRigAttachment.Position.Y - LowerRigAttachment.Position.Y)
		Offset1 = (abs(UpperRigAttachment.Position.Y + UpperMidleRigAttachment.Position.Y)/2)
		Offset2 = (abs(LowerMiddleRigAttachment.Position.Y + LowerRigAttachment.Position.Y)/2)
		
		--UpperLimb.Size = UpperLimb.Size * Scale
		--LowerLimb.Size = LowerLimb.Size * Scale
		ShoulderOffset = CFnew(-UpperRigAttachment.Position.X,0,-UpperRigAttachment.Position.Z)
	end
	UpdateSizes(CurrentScale)
	
	function AppendageClass:UpdatePositions(StartCF,TargetPos)
		local Plane,ShoulderAngle,ElbowAngle = Util:SolveJoint(StartCF,TargetPos,Length1,Length2)
		local CFShoulderAngle,CFElbowAngle = CFAngles(ShoulderAngle,0,0),CFAngles(ElbowAngle,0,0)
		
		local UpperArmCFrame = Plane * CFShoulderAngle * CFnew(0,-(Length1/2) - Offset1,0)
		local CenterCFrame = Plane * CFShoulderAngle * CFnew(0,-Length1,0)
		local LowerArmCFrame = CenterCFrame * CFElbowAngle * CFnew(0,-(Length2/2) + Offset2,0)
		
		if KEEP_MOTOR6DS then
			Util:MoveMotorC0ToPosition(UpperMotor,UpperArmCFrame)
			Util:MoveMotorC0ToPosition(LowerMotor,LowerArmCFrame)
		else
			UpperAnchoredPart:UpdateCFrame(UpperArmCFrame)
			LowerAnchoredPart:UpdateCFrame(LowerArmCFrame)
		end
	end
	
	function AppendageClass:SetLocalTransparencyModifier(TransparencyModifier)
		UpperLimb.LocalTransparencyModifier = TransparencyModifier
		LowerLimb.LocalTransparencyModifier = TransparencyModifier
	end
	
	function AppendageClass:GetLocalTransparencyModifier()
		return UpperLimb.LocalTransparencyModifier
	end
	
	function AppendageClass:GetAttachmentPosition()
		return ShoulderOffset
	end
	
	--function AppendageClass:SetScale(Scale)
	--	UpdateSizes(Scale)
	--end
	
	function AppendageClass:GetAppendageLength()
		return Length1 + Length2
	end
	
	function AppendageClass:Disconnect()
		UpperLimb.Anchored = false
		LowerLimb.Anchored = false
		
		if UpperAnchoredPart then UpperAnchoredPart:Disconnect() end
		if LowerAnchoredPart then LowerAnchoredPart:Disconnect() end
	end
end

local function CreateBlankAppendage(AppendageClass)
	function AppendageClass:UpdatePositions(StartCF,TargetPos)
		
	end
	
	local LocalTransparency = 0
	function AppendageClass:SetLocalTransparencyModifier(TransparencyModifier)
		LocalTransparency = TransparencyModifier
	end
	
	function AppendageClass:GetLocalTransparencyModifier()
		return LocalTransparency
	end
	
	function AppendageClass:GetAttachmentPosition()
		return Vector3.new()
	end
	
	--function AppendageClass:SetScale(Scale)
	--	UpdateSizes(Scale)
	--end
	
	function AppendageClass:GetAppendageLength()
		return 1
	end
	
	function AppendageClass:Disconnect()
		
	end
	
	return AppendageClass
end





function AppendageCreator:CreateRightArm(CharacterModel)
	local AppendageClass = {}
	spawn(function()
		local UpperArm = CharacterModel:WaitForChild("RightUpperArm",120)
		local LowerArm = CharacterModel:WaitForChild("RightLowerArm",120)
		
		if UpperArm and LowerArm and UpperArm.Parent and LowerArm.Parent then
			local ExistingTransparency = AppendageClass:GetLocalTransparencyModifier()
			CreateAppendage(AppendageClass,UpperArm,LowerArm,true)
			AppendageClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendage(AppendageClass)
end

function AppendageCreator:CreateLeftArm(CharacterModel)
	local AppendageClass = {}
	spawn(function()
		local UpperArm = CharacterModel:WaitForChild("LeftUpperArm",120)
		local LowerArm = CharacterModel:WaitForChild("LeftLowerArm",120)
		
		if UpperArm and LowerArm and UpperArm.Parent and LowerArm.Parent then
			local ExistingTransparency = AppendageClass:GetLocalTransparencyModifier()
			CreateAppendage(AppendageClass,UpperArm,LowerArm,true)
			AppendageClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendage(AppendageClass)
end

function AppendageCreator:CreateRightLeg(CharacterModel)
	local AppendageClass = {}
	spawn(function()
		local UpperLeg = CharacterModel:WaitForChild("RightUpperLeg",120)
		local LowerLeg = CharacterModel:WaitForChild("RightLowerLeg",120)
		
		if UpperLeg and LowerLeg and UpperLeg.Parent and LowerLeg.Parent then
			local ExistingTransparency = AppendageClass:GetLocalTransparencyModifier()
			CreateAppendage(AppendageClass,UpperLeg,LowerLeg,false)
			AppendageClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendage(AppendageClass)
end

function AppendageCreator:CreateLeftLeg(CharacterModel)
	local AppendageClass = {}
	spawn(function()
		local UpperLeg = CharacterModel:WaitForChild("LeftUpperLeg",120)
		local LowerLeg = CharacterModel:WaitForChild("LeftLowerLeg",120)
		
		if UpperLeg and LowerLeg and UpperLeg.Parent and LowerLeg.Parent then
			local ExistingTransparency = AppendageClass:GetLocalTransparencyModifier()
			CreateAppendage(AppendageClass,UpperLeg,LowerLeg,false)
			AppendageClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendage(AppendageClass)
end

return AppendageCreator
