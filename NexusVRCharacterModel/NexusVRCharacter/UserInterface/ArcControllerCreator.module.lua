--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/ArcControllerCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



ArcControllerCreator:CreateArcController(VRTouchpad,CharacterClass)
	Creates an Arc controller given a VRTouchpad and CharacterClass
	RETURNS: ArcControllerClass

CLASS ArcControllerClass
	ArcControllerClass:UpdateController(ControllerCF)
		Updates controller with given Controller CFrame
	ArcControllerClass:Disconnect()
		Disconnects all events
		
--]]


local ArcControllerCreator = {}



local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local GRAVITY = Configuration.ArcControllerCreator.GRAVITY
local MAX_SEGMENTS = Configuration.ArcControllerCreator.MAX_SEGMENTS
local TIME_DISTANCE_BETWEEN_SEGMENTS = Configuration.ArcControllerCreator.TIME_DISTANCE_BETWEEN_SEGMENTS
local BEAM_SIZE = Configuration.ArcControllerCreator.BEAM_SIZE
local BEAM_COLOR_VALID = Configuration.ArcControllerCreator.BEAM_COLOR_VALID
local BEAM_COLOR_INVALID = Configuration.ArcControllerCreator.BEAM_COLOR_INVALID
local BEAM_MAX_VELOCITY = Configuration.ArcControllerCreator.BEAM_MAX_VELOCITY
local MAGNITUDE_THRESHOLD = Configuration.ArcControllerCreator.MAGNITUDE_THRESHOLD
local ANGLE_THRESHOLD = Configuration.ArcControllerCreator.ANGLE_THRESHOLD

local TouchpadButtonToInput = {
	[Enum.VRTouchpad.Left] = Enum.KeyCode.ButtonL3,
	[Enum.VRTouchpad.Right] = Enum.KeyCode.ButtonR3,
}
local TouchpadThumbstickToInput = {
	[Enum.VRTouchpad.Left] = Enum.KeyCode.Thumbstick1,
	[Enum.VRTouchpad.Right] = Enum.KeyCode.Thumbstick2,
}

local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent:WaitForChild("Util"))

local CFnew,CFAngles = CFrame.new,CFrame.Angles
local V3new = Vector3.new
local V2new = Vector2.new
local pi,sin,cos,atan2,deg = math.pi,math.sin,math.cos,math.atan2,math.deg
local insert = table.insert



local function CreateLaserPointer(Parent)
	local Beacon = Instance.new("Part")
	Beacon.BrickColor = BrickColor.new("Bright green")
	Beacon.Material = "Neon"
	Beacon.Anchored = true
	Beacon.CanCollide = false
	Beacon.Size = Vector3.new(0.5,0.5,0.5)
	Beacon.Shape = "Ball"
	Beacon.TopSurface = "Smooth"
	Beacon.BottomSurface = "Smooth"
	Beacon.Parent = Parent
	
	local ConstantRing = Instance.new("ImageHandleAdornment")
	ConstantRing.Adornee = Beacon
	ConstantRing.Size = Vector2.new(2,2)
	ConstantRing.Image = "rbxasset://textures/ui/VR/VRPointerDiscBlue.png"
	ConstantRing.Parent = Beacon
	
	local MovingRing = Instance.new("ImageHandleAdornment")
	MovingRing.Adornee = Beacon
	MovingRing.Size = Vector2.new(2,2)
	MovingRing.Image = "rbxasset://textures/ui/VR/VRPointerDiscBlue.png"
	MovingRing.Parent = Beacon
	 
	local BeaconClass = {}
	function BeaconClass:Update(CenterCF)
		local Height = 0.4 + (-cos(tick() * 2)/8)
		local BeaconSize = 2 * (tick() % pi)/pi
		
		Beacon.CFrame = CenterCF * CFnew(0,Height,0)
		ConstantRing.CFrame = CFnew(0,-Height,0) * CFAngles(pi/2,0,0)
		MovingRing.CFrame = CFnew(0,-Height,0) * CFAngles(pi/2,0,0)
		MovingRing.Transparency = BeaconSize/2
		MovingRing.Size = V2new(BeaconSize,BeaconSize)
		
		Beacon.Transparency = 0
		ConstantRing.Visible = true
		MovingRing.Visible = true
	end
	
	function BeaconClass:Hide()
		Beacon.Transparency = 1
		ConstantRing.Visible = false
		MovingRing.Visible = false
	end
	BeaconClass:Hide()
	
	function BeaconClass:Destroy()
		Beacon:Destroy()
	end
	
	return BeaconClass
end

local CreateBeamPart do
	local function GetHeightOffset(VerticalVelocity,Time,X)
		return (VerticalVelocity * Time) + (0.5 * GRAVITY * (Time ^ 2))
	end
	
	local BeamParent
	local function GetArcPoints(CF,Velocity)
		local LookX,LookY,LookZ = CF.lookVector.X,CF.lookVector.Y,CF.lookVector.Z
		local AngleX,AngleY = atan2(LookY,((LookX ^ 2) + (LookZ ^ 2)) ^ 0.5),atan2(LookX,LookZ)
		
		local BaseCF = CFnew(CF.p) * CFAngles(0,AngleY,0)
		local VelX,VelY = cos(AngleX) * Velocity,sin(AngleX) * Velocity
		
		local EndPoints = {}
		local LastPoint = CF.p
		for i = 1,MAX_SEGMENTS do
			local Time = i * TIME_DISTANCE_BETWEEN_SEGMENTS
			local DistanceX = Time * VelX
			local EndPos = (BaseCF * CFnew(0,GetHeightOffset(VelY,Time,DistanceX),DistanceX)).p
			
			local EndHit,NewEndPos = Util:FindCollidablePartOnRay(LastPoint,EndPos - LastPoint,BeamParent)
			if EndHit then
				insert(EndPoints,NewEndPos)
			else
				insert(EndPoints,EndPos)
			end
			if EndHit then
				return EndPoints,true
			else
				LastPoint = NewEndPos
			end
		end
		
		return EndPoints,false
	end
	
	function CreateBeamPart(Segments,Parent)
		BeamParent = Parent
		
		local BasePart = Instance.new("Part")
		BasePart.Size = Vector3.new(0,0,0)
		BasePart.CanCollide = false
		BasePart.Anchored = true
		BasePart.Transparency = 1
		BasePart.Name = "NexusVR_Arc"
		BasePart.Parent = Parent
		
		local Beacon = CreateLaserPointer(BasePart)
		local FirstAttachment = Instance.new("Attachment")
		FirstAttachment.Parent = BasePart
		
		local BeamsAndAttachments = {}
		for i = 1, Segments do
			local NewAttachment = Instance.new("Attachment")
			NewAttachment.Parent = BasePart
			
			local NewBeam = Instance.new("Beam")
			NewBeam.Attachment0 = (BeamsAndAttachments[i - 1] and BeamsAndAttachments[i - 1][1] or FirstAttachment)
			NewBeam.Attachment1 = NewAttachment
			NewBeam.Enabled = false
			NewBeam.Segments = 1
			NewBeam.Width0 = BEAM_SIZE
			NewBeam.Width1 = BEAM_SIZE
			NewBeam.Parent = BasePart
			
			table.insert(BeamsAndAttachments,{NewAttachment,NewBeam})
		end
		
		local BeamClass = {}
		function BeamClass:Update(CF,BeamProjectVelocity)
			local Pos = CF.p
			local SegmentData,ReachedTarget = GetArcPoints(CF,BeamProjectVelocity)
			BasePart.CFrame = CFnew(Pos)
			
			local Look = CF.lookVector
			local AngleY = atan2(Look.X,Look.Z)
			local NewOrientation = V3new(0,deg(AngleY),90)
			FirstAttachment.Orientation = NewOrientation
			
			for i = 1, Segments do
				local BeamData = BeamsAndAttachments[i]
				local EndPos = SegmentData[i]
				local Attachment,Beam = BeamData[1],BeamData[2]
				Attachment.Orientation = NewOrientation
				
				if EndPos then
					Attachment.Position = EndPos - Pos
					Beam.Enabled = true
					Beam.Color = (ReachedTarget and BEAM_COLOR_VALID or BEAM_COLOR_INVALID)
				else
					Beam.Enabled = false
				end
			end
			
			if ReachedTarget then
				local EndCF = CFnew(SegmentData[#SegmentData])
				Beacon:Update(EndCF)
				return EndCF
			else
				Beacon:Hide()
			end
		end
		
		function BeamClass:Hide()
			Beacon:Hide()
			for i = 1, Segments do
				local BeamData = BeamsAndAttachments[i]
				BeamData[2].Enabled = false
			end
		end
		
		function BeamClass:Destroy()
			BasePart:Destroy()
			Beacon:Destroy()
		end
		
		return BeamClass
	end
end



function ArcControllerCreator:CreateArcController(VRTouchpad,CharacterClass)
	local ArcControllerClass = {}
	local PressInput,ThumbstickInput = TouchpadButtonToInput[VRTouchpad],TouchpadThumbstickToInput[VRTouchpad]
	local CharacterModel = CharacterClass.CharacterModel
	VRService:SetTouchpadMode(VRTouchpad,Enum.VRTouchpadMode.VirtualThumbstick)
	local Beam = CreateBeamPart(MAX_SEGMENTS,game:GetService("Workspace").CurrentCamera)
	
	
	
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
	
	local InputDown,BeamVisible = false,false
	local LastTargetCF
	function ArcControllerClass:UpdateController(ControllerCF)
		if BeamVisible then
			LastTargetCF = Beam:Update(ControllerCF,BEAM_MAX_VELOCITY)
		end
	end
	
	local UserInputEvent1 = UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == PressInput and ValidInput() then
			InputDown = true
		end
	end)
	
	local UserInputEvent2 = UserInputService.InputEnded:Connect(function(Input)
		if Input.KeyCode == PressInput and ValidInput() then
			InputDown = false
			BeamVisible = false
			if LastTargetCF then
				local NewX,NewY,NewZ = LastTargetCF.X,LastTargetCF.Y,LastTargetCF.Z
				local HeadCF = UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
				CharacterClass:SetWorldXZOffset(NewX - HeadCF.X,NewZ - HeadCF.Z)
				CharacterClass.PhysicsSolver:SetNewContext(LastTargetCF.p )
			end
			LastTargetCF = nil
			Beam:Hide()
		end
	end)
	
	local UserInputEvent3 = UserInputService.InputChanged:Connect(function(Input)
		if InputDown and Input.KeyCode == ThumbstickInput and ValidInput() then
			local X,Y = Input.Position.X,Input.Position.Y
			local Magnitude = ((X ^ 2) + (Y ^ 2)) ^ 0.5
			local Angle = atan2(X,Y)
			
			if Magnitude > MAGNITUDE_THRESHOLD and Angle > -ANGLE_THRESHOLD and Angle < ANGLE_THRESHOLD then
				BeamVisible = true
			elseif BeamVisible then
				BeamVisible = false
				Beam:Hide()
			end
		end
	end)
	
	function ArcControllerClass:Disconnect()
		UserInputEvent1:Disconnect()
		UserInputEvent2:Disconnect()
		UserInputEvent3:Disconnect()
		Beam:Destroy()
	end
	
	return ArcControllerClass
end

return ArcControllerCreator
