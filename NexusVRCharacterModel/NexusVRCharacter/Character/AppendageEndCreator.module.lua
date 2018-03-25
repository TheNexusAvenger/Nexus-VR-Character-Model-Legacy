--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/AppendageEndCreator.module.lua
Author: TheNexusAvenger
Date: March 25th 2018



AppendageEndCreator:CreateRightHand(CharacterModel)
	Converts R15 Right Hand of given CharacterModel to AppendageEndClass
	RETURNS: AppendageEndClass
AppendageEndCreator:CreateLeftHand(CharacterModel)
	Converts R15 Left Hand of given CharacterModel to AppendageEndClass
	RETURNS: AppendageEndClass
AppendageEndCreator:CreateRightFoot(CharacterModel)
	Converts R15 Right Foot of given CharacterModel to AppendageEndClass
	RETURNS: AppendageEndClass
AppendageEndCreator:CreateLeftFoot(CharacterModel)
	Converts R15 Left Foot of given CharacterModel to AppendageEndClass
	RETURNS: AppendageEndClass

CLASS AppendageEndClass
	AppendageEndClass:UpdatePosition(CF,(ClampTo,ClampDistance))
		Moves the appengage end to the given CF with the option of clamping it to a max distance from a given position
	AppendageEndClass:SetLocalTransparencyModifier(TransparencyModifier)
		Sets LocalTransparencyModifier of limb
	AppendageEndClass:GetLocalTransparencyModifier()
		Gets LocalTransparencyModifier of limb
		RETURNS: double
	AppendageEndClass:GetAttachmentPosition()
		Gets offset of attachment for attaching appendage
		RETURNS: Vector3
	AppendageEndClass:Disconnect()
		Disconnects all events and unanchores the limbs
		
--]]

local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local KEEP_MOTOR6DS = Configuration.AppendageEndCreator.KEEP_MOTOR6DS



local AppendageEndCreator = {}

local Util = require(script.Parent:WaitForChild("Util"))

local Attachments = {
	["RightHand"] = {
		"RightWristRigAttachment",
	},
	["LeftHand"] = {
		"LeftWristRigAttachment",
	},
	["RightFoot"] = {
		"RightAnkleRigAttachment",
	},
	["LeftFoot"] = {
		"LeftAnkleRigAttachment",
	},
}

local Motors = {
	["RightHand"] = {
		"RightWrist",
	},
	["LeftHand"] = {
		"LeftWrist",
	},
	["RightFoot"] = {
		"RightAnkle",
	},
	["LeftFoot"] = {
		"LeftAnkle",
	},
}

local CFnew,CFAngles = CFrame.new,CFrame.Angles
local pi = math.pi



local function CreateAppendageEnd(AppendageEndClass,AppendageEnd,RotateInput)
	local BackRigAttachment = AppendageEnd:WaitForChild(Attachments[AppendageEnd.Name][1])
	local Motor = AppendageEnd:WaitForChild(Motors[AppendageEnd.Name][1])
	local AnchoredAppengageEnd
	if not KEEP_MOTOR6DS then
		Motor.Part0 = nil
		Motor.Part1 = nil	
		AnchoredAppengageEnd = Util:CreateAnchoredPart(AppendageEnd)
	end
	
	
	
	local CurrentScale = 1
	local BackOffset
	local function UpdateSizes(NewScale)
		local Scale = NewScale/CurrentScale
		CurrentScale = NewScale
		Util:ScaleDescendants(AppendageEnd,Scale)
		
		--AppendageEnd.Size = AppendageEnd.Size * Scale
		BackOffset = CFrame.new(BackRigAttachment.Position)
	end
	UpdateSizes(1)
	
	local LastCF = CFnew()
	function AppendageEndClass:UpdatePosition(CF,ClampTo,ClampDistance)
		if ClampTo and ClampDistance then
			ClampDistance = ClampDistance + AppendageEnd.Size.Y
			CF = Util:ClampCF(CF,ClampTo,ClampDistance)
		end
		
		if RotateInput then
			CF = CF * CFAngles(pi/2,0,0) * CFnew(0,AppendageEnd.Size.Y/2,0)
		else
			CF = CF * CFnew(0,AppendageEnd.Size.Y/2,0) * CFAngles(0,pi,0)
		end
		
		local function Rotate(Motor,CF)
			if KEEP_MOTOR6DS then
				Util:MoveMotorC0ToPosition(Motor,CF)
			else
				AnchoredAppengageEnd:UpdateCFrame(CF)
			end
		end
		
		
		Rotate(Motor,CF)
		
		LastCF = CF
	end
	
	function AppendageEndClass:SetLocalTransparencyModifier(TransparencyModifier)
		AppendageEnd.LocalTransparencyModifier = TransparencyModifier
	end
	
	function AppendageEndClass:GetLocalTransparencyModifier()
		return AppendageEnd.LocalTransparencyModifier
	end
	
	--function AppendageEndClass:SetScale(Scale)
	--	UpdateSizes(Scale)
	--end
	
	function AppendageEndClass:GetAttachmentPosition()
		return (LastCF * BackOffset).p
	end
	
	function AppendageEndClass:Disconnect()
		if AnchoredAppengageEnd then AnchoredAppengageEnd:Disconnect() end
	end
	
	return AppendageEndClass
end

local function CreateBlankAppendageEnd(AppendageEndClass)
	local LastCF = CFrame.new()
	function AppendageEndClass:UpdatePosition(CF,ClampTo,ClampDistance)
		LastCF = CF
	end
	
	local LocalTransparency = 0
	function AppendageEndClass:SetLocalTransparencyModifier(TransparencyModifier)
		LocalTransparency = TransparencyModifier
	end
	
	function AppendageEndClass:GetLocalTransparencyModifier()
		return LocalTransparency
	end
	
	--function AppendageEndClass:SetScale(Scale)
	--	
	--end
	
	function AppendageEndClass:GetAttachmentPosition()
		return LastCF.p
	end
	
	function AppendageEndClass:Disconnect()
		
	end
	
	return AppendageEndClass
end





function AppendageEndCreator:CreateRightHand(CharacterModel)
	local AppendageEndClass = {}
	spawn(function()
		local Hand = CharacterModel:WaitForChild("RightHand",120)
		
		if Hand and Hand.Parent then
			local ExistingTransparency = AppendageEndClass:GetLocalTransparencyModifier()
			CreateAppendageEnd(AppendageEndClass,Hand,true)
			AppendageEndClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendageEnd(AppendageEndClass)
end

function AppendageEndCreator:CreateLeftHand(CharacterModel)
	local AppendageEndClass = {}
	spawn(function()
		local Hand = CharacterModel:WaitForChild("LeftHand",120)
		
		if Hand and Hand.Parent then
			local ExistingTransparency = AppendageEndClass:GetLocalTransparencyModifier()
			CreateAppendageEnd(AppendageEndClass,Hand,true)
			AppendageEndClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendageEnd(AppendageEndClass)
end

function AppendageEndCreator:CreateRightFoot(CharacterModel)
	local AppendageEndClass = {}
	spawn(function()
		local Foot = CharacterModel:WaitForChild("RightFoot",120)
		
		if Foot and Foot.Parent then
			local ExistingTransparency = AppendageEndClass:GetLocalTransparencyModifier()
			CreateAppendageEnd(AppendageEndClass,Foot,false)
			AppendageEndClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendageEnd(AppendageEndClass)
end

function AppendageEndCreator:CreateLeftFoot(CharacterModel)
	local AppendageEndClass = {}
	spawn(function()
		local Foot = CharacterModel:WaitForChild("LeftFoot",120)
		
		if Foot and Foot.Parent then
			local ExistingTransparency = AppendageEndClass:GetLocalTransparencyModifier()
			CreateAppendageEnd(AppendageEndClass,Foot,false)
			AppendageEndClass:SetLocalTransparencyModifier(ExistingTransparency)
		end
	end)
	
	return CreateBlankAppendageEnd(AppendageEndClass)
end

return AppendageEndCreator
