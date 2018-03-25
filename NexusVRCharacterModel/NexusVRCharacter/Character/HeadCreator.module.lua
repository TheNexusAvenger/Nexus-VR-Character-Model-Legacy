--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/HeadCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018


	
HeadCreator:CreateHead(CharacterModel)
	Converts R15 Head of given CharacterModel to HeadClass
	RETURNS: HeadClass
	
CLASS HeadClass
	HeadClass:UpdatePosition(HeadsetCF)
		Moves head to the given CFrame 
	HeadClass:SetLocalTransparencyModifier(TransparencyModifier)
		Sets LocalTransparencyModifier of the head
	HeadClass:GetLocalTransparencyModifier()
		Gets LocalTransparencyModifier of head
		RETURNS: double
	HeadClass:GetNeckCFrame()
		Gets CFrame of neck
		RETURNS: CFrame
	HeadClass:Disconnect()
		Disconnects all events and unanchores the limbs

--]]

local HeadCreator = {}

local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local HEADSET_BACK_OFFSET = Configuration.HeadCreator.HEADSET_BACK_OFFSET
local HEADSET_DOWN_OFFSET = Configuration.HeadCreator.HEADSET_DOWN_OFFSET
local MAX_HEAD_ROTATION = Configuration.HeadCreator.MAX_HEAD_ROTATION
local MAX_HEAD_TILT = Configuration.HeadCreator.MAX_HEAD_TILT
	
local Util = require(script.Parent:WaitForChild("Util"))

local CFnew,CFAngles = CFrame.new,CFrame.Angles
local pi,atan2 = math.pi,math.atan2



local function GetAngleDelta(StartAngle,EndAngle)
	local Result = EndAngle - StartAngle
	while Result < pi do Result = Result + (pi * 2) end
	while Result > pi do Result = Result - (pi * 2) end
	return Result
end

local function GetAngleXY(CF)
	local LookVector = CF.lookVector
	local X,Y,Z = LookVector.X,LookVector.Y,-LookVector.Z
	local XZ = ((X ^ 2) + (Z ^ 2)) ^ 0.5
	
	return atan2(Y,XZ),atan2(X,Z)
end

local function CreateHead(Head)
	local HeadClass = {}	
	Head.Anchored = true
	
	local CurrentScale = 1
	local HeadsetOffset,HeadToNeckCFrame
	local OriginalHeadSize = Head.Size
	local function UpdateSizes(NewScale)
		local Scale = NewScale/CurrentScale
		CurrentScale = NewScale
		Util:ScaleDescendants(Head,Scale)
		
		--Head.Size = Head.Size * Scale		
		HeadsetOffset = CFnew(0,-HEADSET_DOWN_OFFSET * CurrentScale,HEADSET_BACK_OFFSET * CurrentScale)
		HeadToNeckCFrame = CFnew(0,-Head.Size.Y/2,0)
	end
	UpdateSizes(1)
	
	local NeckPos
	local CurrentNeckAngle,CurrentTiltAngle
	function HeadClass:UpdatePosition(HeadsetCF)
		local HeadCF = HeadsetCF * HeadsetOffset
		NeckPos = (HeadCF * HeadToNeckCFrame).p
		Head.CFrame = HeadCF
		
		local CurAngleX,CurAngleY = GetAngleXY(HeadCF)
		if not CurrentNeckAngle then
			CurrentNeckAngle = CurAngleY
		end
		
		if CurAngleX > MAX_HEAD_TILT then
			CurrentTiltAngle = CurAngleX - MAX_HEAD_TILT
		elseif CurAngleX < -MAX_HEAD_TILT then
			CurrentTiltAngle = CurAngleX + MAX_HEAD_TILT
		else
			CurrentTiltAngle = 0
		end
		
		local AngleXDelta = GetAngleDelta(CurrentNeckAngle,CurAngleY)
		if AngleXDelta > MAX_HEAD_ROTATION then
			CurrentNeckAngle = CurrentNeckAngle + (AngleXDelta - MAX_HEAD_ROTATION)
		elseif AngleXDelta < -MAX_HEAD_ROTATION then
			CurrentNeckAngle = CurrentNeckAngle + (AngleXDelta + MAX_HEAD_ROTATION)
		end
	end
	
	function HeadClass:SetLocalTransparencyModifier(TransparencyModifier)
		Head.LocalTransparencyModifier = TransparencyModifier
	end
	
	function HeadClass:GetLocalTransparencyModifier()
		return Head.LocalTransparencyModifier
	end
	
	--function HeadClass:SetScale(Scale)
	--	UpdateSizes(Scale)
	--end
	
	function HeadClass:GetNeckCFrame()
		if NeckPos then
			return CFnew(NeckPos) * CFAngles(0,-CurrentNeckAngle,0) * CFAngles(CurrentTiltAngle,0,0)
		else
			return CFnew()
		end
	end
	
	function HeadClass:Disconnect()
		Head.Anchored = false
	end
	
	return HeadClass
end




function HeadCreator:CreateHead(CharacterModel)
	local Head = CharacterModel:WaitForChild("Head")
	
	return CreateHead(Head)
end

return HeadCreator
