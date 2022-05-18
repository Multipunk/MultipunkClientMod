ShitUtils = require("ShitUtils.lua")

local NpcMovingUtils = {}

---@param entity entEntity
---@param position Vector4
---@return void
function NpcMovingUtils.WalkTo(entity, position)
	local activeCmdId = entity:GetAIControllerComponent():GetActiveCommandID("AIMoveToCommand")
	if activeCmdId ~= 0 then
		return
	end
	local positionSpec = ShitUtils.ToPositionSpec(position)
	local cmd = AIMoveToCommand.new({
			movementTarget = positionSpec,
			rotateEntityTowardsFacingTarget = false,
			ignoreNavigation = true,
			desiredDistanceFromTarget = 1.0,
			movementType = moveMovementType.Sprint,
			finishWhenDestinationReached = true,
			useStop = false,
			useStart = false
		})
	local aiControllerComponent = entity:GetAIControllerComponent();
	aiControllerComponent:SendCommand(cmd)
end

---@param entity entEntity
---@param position Vector4
---@return void
function NpcMovingUtils.TeleportTo(entity, position)
	local activeCmdId = entity:GetAIControllerComponent():GetActiveCommandID("AITeleportCommand")
	if activeCmdId ~= 0 then
		entity:GetAIControllerComponent():CancelCommandById(activeCmdId)
	end
	local cmd = AITeleportCommand.new({doNavTest = false, rotation = 1, position = position})
	entity:GetAIControllerComponent():SendCommand(cmd)
end

---@param entity entEntity
---@param rotation EulerAngles
---@return void
function NpcMovingUtils.Rotate(entity, rotation)
	local activeCmdId = entity:GetAIControllerComponent():GetActiveCommandID("AIRotateToCommand")
	if (activeCmdId) ~= 0 then
		return
	end
    local targetPosition = ShitUtils.EulerAngleToPosition(entity:GetWorldPosition(), rotation)
	local cmd = AIRotateToCommand.new({target = ShitUtils.ToPositionSpec(targetPosition), angleTolerance = 5.0, angleOffset = 0.0, speed = 1.0})
	entity:GetAIControllerComponent():SendCommand(cmd)
end

return NpcMovingUtils