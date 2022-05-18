ShitUtils = {}

---@param position Vector4
---@return AIPositionSpec
function ShitUtils.ToPositionSpec(position)
	local worldPosition = WorldPosition:new()
	worldPosition:SetVector4(position)
	local positionSpec = AIPositionSpec:new()
	positionSpec:SetWorldPosition(worldPosition)
	return positionSpec
end

---@param position Vector4
---@param rotation EulerAngles
---@return Vector4
function ShitUtils.EulerAngleToPosition(position, rotation)
    local radius = 100
	local vector = Vector4.new(0, 0, 0, 1)
	vector.x = position.x + math.cos(math.rad(rotation.yaw + 90)) * radius
	vector.y = position.y + math.sin(math.rad(rotation.yaw + 90)) * radius
	vector.z = position.z
	return vector
end

local function ShitCompate(num1, num2, val)
    -- print (math.abs(num1 - num2))
    return math.abs(num1 - num2) < val
end

---@param rotation1 EulerAngles
---@param rotation2 EulerAngles
---@return boolean
function ShitUtils.EulerAnglesEuqials(rotation1, rotation2)
    local val = 10
    return ShitCompate(rotation1.pitch, rotation2.pitch, val) and ShitCompate(rotation1.roll, rotation2.roll, val) and ShitCompate(rotation1.yaw, rotation2.yaw, val)
	-- return  rotation1.pitch == rotation2.pitch and rotation1.roll == rotation2.roll and rotation1.yaw == rotation2.yaw
end

return ShitUtils