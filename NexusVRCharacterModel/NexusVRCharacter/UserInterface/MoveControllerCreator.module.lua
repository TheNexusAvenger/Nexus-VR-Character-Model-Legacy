--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/MoveControllerCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



MoveControllerCreator:CreateMoveController(VRTouchpad,CharacterClass)
	Creates an Move controller given a VRTouchpad and CharacterClass
	RETURNS: MoveControllerClass

CLASS MoveControllerClass
	MoveControllerClass:UpdateController(ControllerCF)
		Updates controller with given Controller CFrame
	MoveControllerClass:Disconnect()
		Disconnects all events
	
--]]


local MoveControllerCreator = {}



local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local MAGNITUDE_THRESHOLD = Configuration.MoveControllerCreator.MAGNITUDE_THRESHOLD

local TouchpadThumbstickToInput = {
	["None"] = Enum.KeyCode.Thumbstick1,
	[Enum.VRTouchpad.Left] = Enum.KeyCode.Thumbstick1,
	[Enum.VRTouchpad.Right] = Enum.KeyCode.Thumbstick2,
}

local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local sin,cos,atan2 = math.sin,math.cos,math.atan2



local GlobalCharacterClass
local CurCharX,CurCharZ = 0,0
local ControllerX,ControllerY,ControllerMag,ControllerAngle = 0,0,0,0
local CurrentControllerLookAngle = 0
local CameraYLocked = false
RunService.RenderStepped:Connect(function(DeltaTime)
	if GlobalCharacterClass and ControllerMag > 0 then
		local FinalAngle = CurrentControllerLookAngle + ControllerAngle
		local TotalWalkspeed = GlobalCharacterClass.Humanoid.WalkSpeed * DeltaTime * ControllerMag
		local MoveX,MoveZ = sin(FinalAngle) * TotalWalkspeed,-cos(FinalAngle) * TotalWalkspeed
		
		CurCharX,CurCharZ = CurCharX + MoveX,CurCharZ + MoveZ
		GlobalCharacterClass:SetCharacterXZOffset(CurCharX,CurCharZ)
	end
end)
	
function MoveControllerCreator:CreateMoveController(VRTouchpad,CharacterClass)
	GlobalCharacterClass = CharacterClass
	local MoveControllerClass = {}
	local CharacterModel = CharacterClass.CharacterModel
	
	if VRTouchpad then
		VRService:SetTouchpadMode(VRTouchpad,Enum.VRTouchpadMode.Touch)
	else
		VRTouchpad = "None"
	end
	local ThumbstickInput = TouchpadThumbstickToInput[VRTouchpad]
	
	local Left,Right = Enum.VRTouchpad.Left,Enum.VRTouchpad.Right
	local LeftHand,RightHand = Enum.UserCFrame.LeftHand,Enum.UserCFrame.RightHand
	local function ValidInput()
		if VRTouchpad == "None" then
			if ThumbstickInput == TouchpadThumbstickToInput[Left] then
				return not VRService:GetUserCFrameEnabled(LeftHand)
			else
				return not VRService:GetUserCFrameEnabled(RightHand)
			end
		else
			return VRService:GetUserCFrameEnabled((VRTouchpad == Left and LeftHand or RightHand))
		end
	end
	
	local ControllerLookAngle = 0
	function MoveControllerClass:UpdateController(ControllerCF)
		ControllerLookAngle = atan2(ControllerCF.lookVector.X,-ControllerCF.lookVector.Z)
	end
	
	local function StartInput()
		if CameraYLocked == false then
			CameraYLocked = true
			CharacterClass:SetYPlaneLockWorldOffset(true)
		end
	end
	
	local function EndInput()
		ControllerX,ControllerY = 0,0
		ControllerMag = 0
		if (CurCharX ~= 0 or CurCharZ ~= 0) and CameraYLocked then
			CameraYLocked = false
			CharacterClass:SetYPlaneLockWorldOffset(false)
			local CurOffset = CharacterClass:GetWorldOffset()
			CharacterClass:SetCharacterXZOffset(0,0)
			CharacterClass:SetWorldXZOffset(CurCharX + CurOffset.X,CurCharZ + CurOffset.Z)
			CurCharX,CurCharZ = 0,0
		end
	end
	
	local UserInputEvent1 = UserInputService.InputEnded:Connect(function(Input)
		local KeyCode = Input.KeyCode
		if KeyCode == ThumbstickInput and ValidInput() then
			EndInput()
		end
	end)
	
	local UserInputEvent2 = UserInputService.InputChanged:Connect(function(Input)
		if Input.KeyCode == ThumbstickInput and ValidInput() then
			local X,Y = Input.Position.X,Input.Position.Y
			local Magnitude = ((X ^ 2) + (Y ^ 2)) ^ 0.5
			local Angle = atan2(X,Y)
			
			ControllerAngle = Angle
			CurrentControllerLookAngle = ControllerLookAngle
			if Magnitude > MAGNITUDE_THRESHOLD then
				StartInput()
				ControllerX,ControllerY = X,Y
				ControllerMag = Magnitude
			else
				EndInput()
			end
		end
	end)
	
	function MoveControllerClass:Disconnect()
		UserInputEvent1:Disconnect()
		UserInputEvent2:Disconnect()
	end
	
	return MoveControllerClass
end

return MoveControllerCreator
