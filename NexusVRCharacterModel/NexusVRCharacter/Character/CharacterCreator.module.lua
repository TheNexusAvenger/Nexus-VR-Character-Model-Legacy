--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/CharacterCreator.module.lua
Author: TheNexusAvenger
Date: March 28th 2018



CharacterCreator:CreateCharacter(CharacterModel,IsLocalCharacter)
	Creates character from CharacterModel. Returned class depends on IsLocalCharacter
	RETURNS: LocalCharacterClass or CharacterClass
	
CLASS CharacterClass
	CharacterClass:UpdateRig(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
		Updates rig with given CFrames
	CharacterClass:SetLocalTransparencyModifier(TransparencyModifier,ForceWhenCharacterOffsetInUse)
		Sets LocalTransparencyModifier of limbs. If it is forced, then controllers won't override it
	CharacterClass:Disconnect()
		Disconnects all events and unanchores the limbs
	CharacterClass.CharacterModel
		CharacterModel of character class

CLASS LocalCharacterClass
	** Inherits all functions from CharacterClass
	CharacterClass:UpdatePositions(HeadsetCF,LeftControllerCF,RightControllerCF)
		Updates rig with given CFrames. Uses FootPlanterSolver for feet CFrames
	CharacterClass:SetWorldXZOffset(NewX,NewZ)
		Sets world X and Z coordinate offset of character. Used by controllers and camera
	CharacterClass:SetWorldYOffset(NewY)
		Sets world Y coordinate offset of character. Used by controllers and camera
	CharacterClass:SetCharacterXZOffset(NewX,NewZ)
		Sets world X and Z coordinate offset of character. Used by controllers
	CharacterClass:SetCharacterYOffset(NewY)
		Sets world y coordinate offset of character. Used by controllers
	CharacterClass:GetWorldOffset()
		Returns CFrame of world offset
		RETURNS: CFrame
	CharacterClass:GetCharacterOffset()
		Returns CFrame of character offset
		RETURNS: CFrame
	
--]]

local CharacterCreator = {}

local HeadCreator = require(script.Parent:WaitForChild("HeadCreator"))
local TorsoCreator = require(script.Parent:WaitForChild("TorsoCreator"))
local AppendageCreator = require(script.Parent:WaitForChild("AppendageCreator"))
local AppendageEndCreator = require(script.Parent:WaitForChild("AppendageEndCreator"))
local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))

local CFnew,CFAngles = CFrame.new,CFrame.Angles
local V3new = Vector3.new
local pi = math.pi

local PREVENT_LOCAL_ARM_DISCONNECTION = Configuration.CharacterCreator.PREVENT_LOCAL_ARM_DISCONNECTION
local DISCONNECT_NON_LOCAL_ARMS = Configuration.CharacterCreator.DISCONNECT_NON_LOCAL_ARMS
function CharacterCreator:CreateCharacter(Character,IsLocalCharacter)
	local CharacterClass = {}
	CharacterClass.CharacterModel = Character
	
	local Head = HeadCreator:CreateHead(Character)
	local Torso = TorsoCreator:CreateTorso(Character)
	local LeftArm,RightArm = AppendageCreator:CreateLeftArm(Character),AppendageCreator:CreateRightArm(Character)
	local LeftHand,RightHand = AppendageEndCreator:CreateLeftHand(Character),AppendageEndCreator:CreateRightHand(Character)
	local LeftLeg,RightLeg = AppendageCreator:CreateLeftLeg(Character),AppendageCreator:CreateRightLeg(Character)
	local LeftFoot,RightFoot = AppendageEndCreator:CreateLeftFoot(Character),AppendageEndCreator:CreateRightFoot(Character)
	
	local WorldOffset,CharacterOffset = CFnew(),CFnew()
	local TotalCharacterOffset = CFnew()
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local RemoteHandler
	while not Humanoid and Character.Parent do wait() Humanoid = Character:FindFirstChildOfClass("Humanoid") end
	if not Character.Parent or Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		return false
	end
	
	
	
	local Disconnected = false
	for _,Track in pairs(Humanoid:GetPlayingAnimationTracks()) do
		Track:Stop()
	end
	
	local AnimationPlayedConnection = Humanoid.AnimationPlayed:Connect(function(Track)
		Track:Stop()
	end)
	
	local function UpdateAccesories()
		for _,Ins in pairs(Humanoid:GetAccessories()) do
			local Handle = Ins:FindFirstChild("Handle")
			if Handle then
				local AccessoryWeld = Handle:FindFirstChild("AccessoryWeld")
				if AccessoryWeld and AccessoryWeld.Part1.Anchored == true then
					local C0,C1,Part1 = AccessoryWeld.C0,AccessoryWeld.C1,AccessoryWeld.Part1
					if Part1 then
						local Part1CF = Part1.CFrame
						
						Handle.CFrame = Part1CF * C1 * C0:inverse()
					end
				end
			end
		end
	end	
	
	local DisconnectArms = (IsLocalCharacter and not PREVENT_LOCAL_ARM_DISCONNECTION) or (not IsLocalCharacter and DISCONNECT_NON_LOCAL_ARMS)
	function CharacterClass:UpdateRig(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
		if Disconnected then return false end
		
		local HeadWorldCF = TotalCharacterOffset * HeadCF
		Head:UpdatePosition(HeadWorldCF)
		Torso:UpdatePosition(Head:GetNeckCFrame())	
		
		local LeftHandWorldCF = TotalCharacterOffset * LeftControllerCF
		local RightHandWorldCF = TotalCharacterOffset * RightControllerCF
		local LeftShoulderCF = Torso:GetLeftShoulderCFrame() 
		local RightShoulderCF = Torso:GetRightShoulderCFrame() 
		if DisconnectArms then
			LeftHand:UpdatePosition(LeftHandWorldCF)
			RightHand:UpdatePosition(RightHandWorldCF)
		else
			LeftHand:UpdatePosition(LeftHandWorldCF,LeftShoulderCF.p,LeftArm:GetAppendageLength())
			RightHand:UpdatePosition(RightHandWorldCF,RightShoulderCF.p,RightArm:GetAppendageLength())
		end
		
		local LeftHipCF = Torso:GetLeftHipCFrame()
		local RightHipCF = Torso:GetRightHipCFrame()
		
		LeftArm:UpdatePositions(LeftShoulderCF * LeftArm:GetAttachmentPosition(),LeftHand:GetAttachmentPosition())
		RightArm:UpdatePositions(RightShoulderCF * RightArm:GetAttachmentPosition(),RightHand:GetAttachmentPosition())
		
		LeftFoot:UpdatePosition(LeftFootCF,LeftHipCF.p,LeftLeg:GetAppendageLength())
		RightFoot:UpdatePosition(RightFootCF,RightHipCF.p,RightLeg:GetAppendageLength())
		
		LeftLeg:UpdatePositions(LeftHipCF * CFAngles(pi,pi,0),LeftFoot:GetAttachmentPosition())
		RightLeg:UpdatePositions(RightHipCF * CFAngles(pi,pi,0),RightFoot:GetAttachmentPosition())
		
		UpdateAccesories()
		if RemoteHandler then
			RemoteHandler:SendReplicationData(HeadWorldCF,LeftHandWorldCF,RightHandWorldCF,LeftFootCF,RightFootCF)
		end
	end
	
	local LastTransparency,ForceTransparency = 0,false
	local function SetLocalTransparencyModifier(TransparencyModifier)
		if ForceTransparency or not TransparencyModifier then
			TransparencyModifier = LastTransparency
		end
		
		Head:SetLocalTransparencyModifier(TransparencyModifier)
		Torso:SetLocalTransparencyModifier(TransparencyModifier)
		LeftArm:SetLocalTransparencyModifier(TransparencyModifier)
		LeftHand:SetLocalTransparencyModifier(TransparencyModifier)
		RightArm:SetLocalTransparencyModifier(TransparencyModifier)
		RightHand:SetLocalTransparencyModifier(TransparencyModifier)
		LeftLeg:SetLocalTransparencyModifier(TransparencyModifier)
		LeftFoot:SetLocalTransparencyModifier(TransparencyModifier)
		RightLeg:SetLocalTransparencyModifier(TransparencyModifier)
		RightFoot:SetLocalTransparencyModifier(TransparencyModifier)
	end
	
	function CharacterClass:SetLocalTransparencyModifier(TransparencyModifier,ForceWhenCharacterOffsetInUse)
		LastTransparency,ForceTransparency = TransparencyModifier,ForceWhenCharacterOffsetInUse
		SetLocalTransparencyModifier()
	end
	
	if IsLocalCharacter then
		RemoteHandler = require(script.Parent.Parent:WaitForChild("Replication"):WaitForChild("RemoteHandler"))
		
		local FootPlanter = require(script.Parent:WaitForChild("FootPlanter"))
		local FootPlanterSolver = FootPlanter:CreateSolver(Character:WaitForChild("LowerTorso"))
		local WorldX,WorldY,WorldZ = 0,0,0
		local OffsetX,OffsetY,OffsetZ = 0,0,0
		
		function CharacterClass:UpdatePositions(HeadsetCF,LeftControllerCF,RightControllerCF)
			if Disconnected then return end
			local LeftFootCF,RightFootCF = FootPlanterSolver:GetFeetCFrames()
			CharacterClass:UpdateRig(HeadsetCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
		end
		
		function CharacterClass:SetWorldXZOffset(NewX,NewZ)
			local DeltaX,DeltaZ = NewX - WorldX,NewZ - WorldZ
			
			WorldX,WorldZ = NewX,NewZ
			WorldOffset = CFnew(WorldX,WorldY,WorldZ)
			TotalCharacterOffset = WorldOffset * CharacterOffset
			
			FootPlanterSolver:OffsetFeet(V3new(DeltaX,0,DeltaZ))
		end
		
		function CharacterClass:SetWorldYOffset(NewY)
			local DeltaY = NewY - WorldY
			
			WorldY = NewY
			WorldOffset = CFnew(WorldX,WorldY,WorldZ)
			TotalCharacterOffset = WorldOffset * CharacterOffset
			
			FootPlanterSolver:OffsetFeet(V3new(0,DeltaY,0))
		end
		
		function CharacterClass:SetCharacterXZOffset(NewX,NewZ)
			OffsetX,OffsetZ = NewX,NewZ
			CharacterOffset = CFnew(OffsetX,OffsetY,OffsetZ)
			TotalCharacterOffset = WorldOffset * CharacterOffset
			
			if OffsetX == 0 and OffsetY == 0 and OffsetZ == 0 then
				SetLocalTransparencyModifier()
			else
				SetLocalTransparencyModifier(0)
			end
		end
		
		function CharacterClass:SetCharacterYOffset(NewY)
			OffsetY = NewY
			CharacterOffset = CFnew(OffsetX,OffsetY,OffsetZ)
			TotalCharacterOffset = WorldOffset * CharacterOffset
			
			if OffsetX == 0 and OffsetY == 0 and OffsetZ == 0 then
				SetLocalTransparencyModifier()
			else
				SetLocalTransparencyModifier(0)
			end
		end
		
		function CharacterClass:SetWorldYOffset(NewY)
			WorldY = NewY
			WorldOffset = CFnew(WorldX,WorldY,WorldZ)
			TotalCharacterOffset = WorldOffset * CharacterOffset
		end
		
		function CharacterClass:GetCharacterOffset()
			return CharacterOffset
		end
		
		function CharacterClass:GetWorldOffset()
			return WorldOffset
		end
	end
	
	local HumanoidConnection
	function CharacterClass:Disconnect()
		if Disconnected then return end
		
		Disconnected = true
		SetLocalTransparencyModifier(0)
		AnimationPlayedConnection:Disconnect()
		HumanoidConnection:Disconnect()
		
		Head:Disconnect()
		Torso:Disconnect()
		LeftArm:Disconnect()
		LeftHand:Disconnect()
		RightArm:Disconnect()
		RightHand:Disconnect()
		LeftLeg:Disconnect()
		LeftFoot:Disconnect()
		RightLeg:Disconnect()
		RightFoot:Disconnect()
	end
	
	HumanoidConnection = Humanoid.Died:Connect(function()
		CharacterClass:Disconnect()
	end)
	
	--function CharacterClass:SetScale(Scale)
	--	Head:SetScale(Scale)
	--	Torso:SetScale(Scale)
	--	LeftArm:SetScale(Scale)
	--	RightArm:SetScale(Scale)
	--	LeftHand:SetScale(Scale)
	--	RightHand:SetScale(Scale)
	--	LeftFoot:SetScale(Scale)
	--	RightFoot:SetScale(Scale)
	--	LeftLeg:SetScale(Scale)
	--	RightLeg:SetScale(Scale)
	--	FootPlanterSolver:SetScale(Scale)
	--end
	
	
	
	return CharacterClass
end

return CharacterCreator
