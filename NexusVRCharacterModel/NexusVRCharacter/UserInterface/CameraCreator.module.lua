--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/CameraCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



CameraCreator:CreateCamera()
	Creates a custom camera
	RETURNS: CameraClass
	
CLASS CameraClass
	CameraClass:SetScale(Scale)
		Sets scale for ScaleInput
	CameraClass:ScaleInput(CFrame)
		Scales a CFrame on the Y axis by the given scale
		RETURNS: CFrame
	CameraController:UpdateCamera(ScaledCFrame)
		Updates teh camera CFrame to the input CFrame

--]]

local CameraCreator = {}

local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local USE_THIRD_PERSON = Configuration.CameraCreator.USE_THIRD_PERSON
local THIRD_PERSON_OFFSET = Configuration.CameraCreator.THIRD_PERSON_OFFSET
local USE_HEADLOCKED_HACK = Configuration.CameraCreator.USE_HEADLOCKED_HACK

local CFnew = CFrame.new
local Head = Enum.UserCFrame.Head

function CameraCreator:CreateCamera()
	local CameraClass = {}
	local UserInputScale = 1
	
	local StarterGui = game:GetService("StarterGui")
	local Camera = game:GetService("Workspace").CurrentCamera
	Camera.HeadLocked = USE_HEADLOCKED_HACK --false
	Camera.CameraType = "Scriptable"
	
	delay(0.5,function()
		StarterGui:SetCore("VRLaserPointerMode", 0)
		StarterGui:SetCore("VREnableControllerModels", false)
	end)
	
	function CameraClass:SetScale(NewScale)
		UserInputScale = NewScale
	end
	
	function CameraClass:ScaleInput(CF)
		local X,Y,Z,A,B,C,D,E,F,G,H,I = CF:components()
		return CFnew(X,Y * UserInputScale,Z,A,B,C,D,E,F,G,H,I)
	end
	
	if USE_HEADLOCKED_HACK then
		--This function will be removed in the future
		local UserInputService = game:GetService("UserInputService")
		function CameraClass:UpdateCamera(ScaledCFrame)
			local NewCF = ScaledCFrame * UserInputService:GetUserCFrame(Head):inverse()
			if USE_THIRD_PERSON then
				Camera.CFrame = THIRD_PERSON_OFFSET * NewCF
			else
				Camera.CFrame = NewCF
			end
		end
	else
		function CameraClass:UpdateCamera(ScaledCFrame)
			if USE_THIRD_PERSON then
				Camera.CFrame = THIRD_PERSON_OFFSET * ScaledCFrame
			else
				Camera.CFrame = ScaledCFrame
			end
		end
	end
	
	return CameraClass
end

return CameraCreator
