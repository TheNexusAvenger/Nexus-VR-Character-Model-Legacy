--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/TorsoCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



TorsoCreator:CreateTorso(CharacterModel)
	Converts R15 Torso of given CharacterModel to TorsoClass
	RETURNS: TorsoClass
	
CLASS TorsoClass
	TorsoClass:UpdatePosition(NeckCF)
		Moves Torso based on Neck CFrame
	TorsoClass:SetLocalTransparencyModifier(TransparencyModifier)
		Sets LocalTransparencyModifier of the torso
	TorsoClass:GetLocalTransparencyModifier()
		Gets LocalTransparencyModifier of torso
		RETURNS: double
	TorsoClass:GetLeftShoulderCFrame()
		Gets CFrame of left shoulder
		RETURNS: CFrame
	TorsoClass:GetRightShoulderCFrame()
		Gets CFrame of right shoulder
		RETURNS: CFrame
	TorsoClass:GetLeftHipCFrame()
		Gets CFrame of left hip
		RETURNS: CFrame
	TorsoClass:GetRightHipCFrame()
		Gets CFrame of right hip
		RETURNS: CFrame
	TorsoClass:Disconnect()
		Disconnects all events

--]]

local TorsoCreator = {}


local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local MAX_TORSO_BEND = Configuration.TorsoCreator.MAX_TORSO_BEND

local Util = require(script.Parent:WaitForChild("Util"))

local CFnew,CFAngles = CFrame.new,CFrame.Angles
local atan2 = math.atan2



local function GetAngleX(CF)
	local LookVector = CF.lookVector
	local X,Y,Z = LookVector.X,LookVector.Y,LookVector.Z
	local XZ = ((X ^ 2) + (Z ^ 2)) ^ 0.5
	
	return atan2(Y,XZ)
end

local function CreateHead(Head,UpperTorso,LowerTorso)
	local TorsoClass = {}	
	
	local NeckRigAttachment = UpperTorso:WaitForChild("NeckRigAttachment")
	local LeftShoulderRigAttachment = UpperTorso:WaitForChild("LeftShoulderRigAttachment")
	local RightShoulderRigAttachment = UpperTorso:WaitForChild("RightShoulderRigAttachment")
	local UpperWaistRigAttachment = UpperTorso:WaitForChild("WaistRigAttachment")
	local LowerWaistRigAttachment = LowerTorso:WaitForChild("WaistRigAttachment")
	local LeftHipRigAttachment = LowerTorso:WaitForChild("LeftHipRigAttachment")
	local RightHipRigAttachment = LowerTorso:WaitForChild("RightHipRigAttachment")
	local NeckMotor,WaistMotor = Head:WaitForChild("Neck"),UpperTorso:WaitForChild("Waist")
	
	local CurrentScale = 1
	local NeckToTorsoOffset,UpperTorsoToCenterOffset,CenterToLowerTorsoOffset
	local LeftShoulderOffset,RightShoulderOffset
	local LeftHipOffset,RightHipOffset
	local function UpdateSizes(NewScale)
		local Scale = NewScale/CurrentScale
		CurrentScale = NewScale
		Util:ScaleDescendants(UpperTorso,Scale)
		Util:ScaleDescendants(LowerTorso,Scale)
		
		--UpperTorso.Size = UpperTorso.Size * NewScale
		--LowerTorso.Size = LowerTorso.Size * NewScale
		
		NeckToTorsoOffset = CFnew(-NeckRigAttachment.Position)
		UpperTorsoToCenterOffset = CFnew(UpperWaistRigAttachment.Position)
		CenterToLowerTorsoOffset = CFnew(-LowerWaistRigAttachment.Position)
		
		LeftShoulderOffset = CFnew(LeftShoulderRigAttachment.Position)
		RightShoulderOffset = CFnew(RightShoulderRigAttachment.Position)
		LeftHipOffset = CFnew(LeftHipRigAttachment.Position)
		RightHipOffset = CFnew(RightHipRigAttachment.Position)
	end
	UpdateSizes(1)
	
	local UpperTorsoCF,LowerTorsoCF = CFnew(),CFnew()
	function TorsoClass:UpdatePosition(NeckCF)
		local AngleUp = GetAngleX(NeckCF)
		local LowerTorsoTilt = 0
		if AngleUp > MAX_TORSO_BEND then
			LowerTorsoTilt = AngleUp - MAX_TORSO_BEND
		elseif AngleUp < -MAX_TORSO_BEND then
			LowerTorsoTilt = AngleUp + MAX_TORSO_BEND
		end
		
		UpperTorsoCF = NeckCF * NeckToTorsoOffset
		local CenterTorsoCF = UpperTorsoCF * UpperTorsoToCenterOffset * CFAngles(-LowerTorsoTilt,0,0)
		LowerTorsoCF = CenterTorsoCF * CenterToLowerTorsoOffset
		
		Util:MoveMotorC1ToPosition(NeckMotor,UpperTorsoCF)
		Util:MoveMotorC1ToPosition(WaistMotor,LowerTorsoCF)
	end
	
	function TorsoClass:SetLocalTransparencyModifier(TransparencyModifier)
		UpperTorso.LocalTransparencyModifier = TransparencyModifier
		LowerTorso.LocalTransparencyModifier = TransparencyModifier
	end
	
	function TorsoClass:GetLocalTransparencyModifier()
		return UpperTorso.LocalTransparencyModifier
	end
	
	--function TorsoClass:SetScale(Scale)
	--	UpdateSizes(Scale)
	--end
	
	function TorsoClass:GetLeftShoulderCFrame()
		return UpperTorsoCF * LeftShoulderOffset
	end
	
	function TorsoClass:GetRightShoulderCFrame()
		return UpperTorsoCF * RightShoulderOffset
	end
	
	function TorsoClass:GetLeftHipCFrame()
		return LowerTorsoCF * LeftHipOffset
	end
	
	function TorsoClass:GetRightHipCFrame()
		return LowerTorsoCF * RightHipOffset
	end
	
	function TorsoClass:Disconnect()
		
	end
	
	return TorsoClass
end




function TorsoCreator:CreateTorso(CharacterModel)
	local Head = CharacterModel:WaitForChild("Head")
	local UpperTorso = CharacterModel:WaitForChild("UpperTorso")
	local LowerTorso = CharacterModel:WaitForChild("LowerTorso")
	
	return CreateHead(Head,UpperTorso,LowerTorso)
end

return TorsoCreator
