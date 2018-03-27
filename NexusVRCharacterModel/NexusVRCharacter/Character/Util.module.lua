--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/Util.module.lua
Author: TheNexusAvenger
Date: March 27th 2018


	
Util:ScaleDescendants(Ins,Scale)
	Scales attachments by scale
Util:SolveJoint(OriginCF,TargetPos,Length1,Length2,PreventDisconnection)
	Solves a joint given an origin CFrame, target Vector3, limb length 1, and limb length 2
	Returns CFrame of joint, angle of first limb, and angle of second limb
	RETURNS: CFrame,double,double
Util:ClampCF(CF,ClampTo,ClampDistance)
	Clamps CFrame to origin CFrame and max distance
	RETURNS: CFrame
Util:MoveMotorC0ToPosition(Motor,Target)
	Moves Motor6D C0 so Part1's CFrame is at the target CFrame
Util:MoveMotorC1ToPosition(Motor,Target)
	Moves Motor6D C1 so Part1's CFrame is at the target CFrame
Util:CreateAnchoredPart(Part)
	Creates a new AnchoredPartClass from the given part
	RETURNS: AnchoredPartClass
	
CLASS AnchoredPartClass
	AnchoredPartClass:UpdateCFrame(CF)
		Moves part to the given CFrame
	AnchoredPartClass:Disconnect()
		Disconnects all events and destroys any created instances

--]]

local Util = {}

local CFnew = CFrame.new
local Vector3huge = Vector3.new(math.huge,math.huge,math.huge)
local RenderStepped = game:GetService("RunService").RenderStepped

function Util:ScaleDescendants(Ins,Scale)
	for _,Decendant in pairs(Ins:GetDescendants()) do
		if Decendant:IsA("Attachment") then
			Decendant.Position = Decendant.Position * Scale
		end
	end
end

local SolveJoint do
	--Function originally by WhoBloxxedWho. Minor modifications made.
	--From: https://devforum.roblox.com/t/r15-ik-foot-placement/68675/5
		
	local Forward,BlackVector = Vector3.new(0,0,-1),Vector3.new(0,0,0)
	local AxisFixForward,AxisFixBackward = Vector3.new(0,0,-0.001),Vector3.new(0,0,0.001)
	local pi = math.pi
	
	local max,min,acos = math.min,math.max,math.acos
	local CFnew,CFfromAxisAngle = CFrame.new,CFrame.fromAxisAngle
	
	function SolveJoint(OriginCF,TargetPos,Length1,Length2,PreventDisconnection)
		local LocalizedPosition = OriginCF:pointToObjectSpace(TargetPos)
		local LocalizedUnit = LocalizedPosition.unit
		local Hypotenuse = LocalizedPosition.magnitude
		
		local Axis = Forward:Cross(LocalizedUnit)
		if Axis == BlackVector then 
			if LocalizedPosition.Z < 0 then
				Axis = AxisFixBackward
			else
				Axis = AxisFixForward
			end
		end
		
		local PlaneRotation = acos(-LocalizedUnit.Z)
		local PlaneCF = OriginCF * CFfromAxisAngle(Axis,PlaneRotation)
		if Hypotenuse < max(Length2, Length1) - min(Length2, Length1) then
			local ShoulderAngle,ElbowAngle = -pi/2, pi
			if PreventDisconnection then
				return PlaneCF,ShoulderAngle,ElbowAngle
			else
				return PlaneCF * CFnew(0,0,max(Length2, Length1) - min(Length2, Length1) - Hypotenuse),ShoulderAngle,ElbowAngle
			end
		elseif Hypotenuse > Length1 + Length2 then
			local ShoulderAngle,ElbowAngle = pi/2, 0
			if PreventDisconnection then
				return PlaneCF,ShoulderAngle,ElbowAngle
			else
				return PlaneCF * CFnew(0, 0, Length1 + Length2 - Hypotenuse),ShoulderAngle,ElbowAngle
			end
		else
			local a1 = -acos((-(Length2 * Length2) + (Length1 * Length1) + (Hypotenuse * Hypotenuse)) / (2 * Length1 * Hypotenuse))
			local a2 = acos(((Length2  * Length2) - (Length1 * Length1) + (Hypotenuse * Hypotenuse)) / (2 * Length2 * Hypotenuse))
	
			return PlaneCF,a1 + pi/2,a2 - a1
		end
	end
end

function Util:SolveJoint(...)
	return SolveJoint(...)
end

function Util:ClampCF(CF,ClampTo,ClampDistance)
	local CFPos = CF.p
	local DeltaPos = CFPos - ClampTo
	local Distance = DeltaPos.magnitude
	
	if Distance > ClampDistance then
		local _,_,_,A,B,C,D,E,F,G,H,I = CF:components()
		DeltaPos = DeltaPos * (ClampDistance / Distance)
		return CFnew(ClampTo + DeltaPos) * CFnew(0,0,0,A,B,C,D,E,F,G,H,I)
	else
		return CF
	end
end

function Util:MoveMotorC0ToPosition(Motor,Target)
	local Part0CF,C1 = Motor.Part0.CFrame,Motor.C1
	local C0Target = Target * C1
	Motor.C0 = Part0CF:inverse() * C0Target
end

function Util:MoveMotorC1ToPosition(Motor,Target)
	local Part1CF,C0 = Motor.Part1.CFrame,Motor.C0
	local C0Target = Target * C0
	Motor.C1 = Part1CF:inverse() * C0Target
end

function Util:CreateAnchoredPart(Part)
	--This function is a bit hacky.
	local AnchoredPartClass = {}
	Part.Anchored = true
	
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.MaxForce = Vector3huge
	BodyPosition.Position = Part.Position
	BodyPosition.D = 50
	BodyPosition.Parent = Part
	
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.MaxTorque = Vector3huge
	BodyGyro.CFrame = Part.CFrame
	BodyGyro.D = 50
	BodyGyro.Parent = Part
	
	local OffsetCF = CFrame.new()
	local CF = CFrame.new()
	local function UpdatePartPos()
		BodyPosition.Position = CF.p
		BodyGyro.CFrame = CF
		
		local TargetCF = CF * OffsetCF
		Part.CFrame = TargetCF
		OffsetCF = Part.CFrame:inverse() * TargetCF
	end
	
	function AnchoredPartClass:UpdateCFrame(NewCF)
		CF = NewCF
		Part.Anchored = false
		UpdatePartPos()
	end
	
	local RenderSteppedEvent = RenderStepped:Connect(function()
		UpdatePartPos()
	end)
	
	function AnchoredPartClass:Disconnect()
		BodyPosition:Destroy()
		BodyGyro:Destroy()
		RenderSteppedEvent:Disconnect()
	end
	
	return AnchoredPartClass
end

return Util
