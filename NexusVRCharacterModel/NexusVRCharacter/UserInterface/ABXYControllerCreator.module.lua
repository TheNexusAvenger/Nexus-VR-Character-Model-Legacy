--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/ABXYControllerCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



ABXYControllerCreator:CreateABXYController(VRTouchpad,CharacterClass)
	Creates an ABXY controller given a VRTouchpad and CharacterClass
	RETURNS: ABXYController

CLASS ABXYController
	ABXYControllerClass:UpdateController(ControllerCF)
		Updates controller with given Controller CFrame
	ABXYControllerClass:Disconnect()
		Disconnects all events
	
--]]


local ABXYControllerCreator = {}



local TouchpadThumbstickToInput = {
	["None"] = Enum.KeyCode.Thumbstick1,
	[Enum.VRTouchpad.Left] = Enum.KeyCode.Thumbstick1,
	[Enum.VRTouchpad.Right] = Enum.KeyCode.Thumbstick2,
}

local Workspace = game:GetService("Workspace")
local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")





local CurCharY,CurVelocityY = 0,0
local GlobalCharacterClass,GlobalHumanoid
RunService.RenderStepped:Connect(function(DeltaTime)
	if CurVelocityY ~= 0 and GlobalCharacterClass then
		local JumpPower = GlobalHumanoid.JumpPower
		local Gravity = -Workspace.Gravity
		CurCharY = CurCharY + (CurVelocityY * DeltaTime)
		CurVelocityY = CurVelocityY + (DeltaTime * Gravity)
		
		if CurCharY < 0 then
			CurCharY = 0
			CurVelocityY = 0
			GlobalCharacterClass:SetYPlaneLockWorldOffset(false)
			GlobalHumanoid.Jump = false
		end
		GlobalCharacterClass:SetCharacterYOffset(CurCharY)
	end
end)
	

function ABXYControllerCreator:CreateABXYController(VRTouchpad,CharacterClass)
	GlobalCharacterClass = CharacterClass
	GlobalHumanoid = CharacterClass.Humanoid
	
	local ABXYControllerClass = {}
	local CharacterModel = CharacterClass.CharacterModel
	local Humanoid = CharacterClass.Humanoid
	
	if VRTouchpad then
		VRService:SetTouchpadMode(VRTouchpad,Enum.VRTouchpadMode.ABXY)
	else
		VRTouchpad = "None"
	end
	
	function ABXYControllerClass:UpdateController(ControllerCF)
		
	end
	
	local InputEvent1 = UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode.ButtonA then
			if CurVelocityY == 0 and CurCharY == 0 then
				CurVelocityY = Humanoid.JumpPower
				CharacterClass:SetYPlaneLockWorldOffset(true)
				GlobalHumanoid.Jump = true
			end
		end
	end)
	
	function ABXYControllerClass:Disconnect()
		InputEvent1:Disconnect()
	end
	
	return ABXYControllerClass
end

return ABXYControllerCreator
