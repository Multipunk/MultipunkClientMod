NpcMovingUtils = require("NpcMovingUtils")
ShitUtils = require("ShitUtils.lua")

Multipunk = {
	DebugMode = true,
	PlayerEntityIds = {},
	-- LastPosition = Vector4.new(0, 0, 0, 1),
	-- LastRotation = EulerAngles.new(0, 0, 0),
}

registerHotkey("Test", "Test", function()
	local entity = Game.FindEntityByID(Multipunk.PlayerEntityIds[0])
	local position = Game.GetPlayer():GetWorldPosition()
	local pol = MovePolicies.new()
	pol:SetDestinationPosition(position)
	pol:SetMovementType(moveMovementType.Sprint)
	local mpc = entity:GetMovePolicesComponent()
	print(mpc:IsOnStairs())
	mpc:AddPolicies(pol)
end)

registerHotkey("RemoveAll", "RemoveAll", function()
	RemoveAll()
end)

function RemoveAll()
	local searchQuery = Game["TSQ_ALL;"]()
	searchQuery.maxDistance = 1000
	local success, parts = Game.GetTargetingSystem():GetTargetParts(Game.GetPlayer(), searchQuery)
	if success then
		local entities = {}
		for i, v in ipairs(parts) do
			local entity = v:GetComponent(v):GetEntity()
			-- print(entity:IsVehicle())
			if (entity:IsVehicle()) then
				entity:Dispose()
			end
			if (entity:IsNPC()) then
				entity:Dispose()
			end
		end
	end
end

function Multipunk:OnMove(position, rotation)
	local packet = {
		packetType = "ClientPlayerMovePacket",
		x = position.x,
		y = position.y,
		z = position.z,
		yaw = rotation.yaw,
		pitch = rotation.pitch
	}
	if Multipunk.DebugMode == false then
		ConnectionSend(json.encode(packet) .. "\n")		
	else
		packet["packetType"] = "ServerPlayerMovePacket"
		packet["id"] = 1337
		Multipunk:OnReceive(packet)
	end
end

function Multipunk:OnReceive(packet)
	-- print(packet)
	local packetType = packet["packetType"]
	if packetType == "ServerPlayerJoinPacket" then
		local playerId = packet["id"]
		local eid = Multipunk.PlayerEntityIds[playerId]
		if (eid == nil) then
			local spawnPosition = Game.GetPlayer():GetWorldTransform()
			eid = exEntitySpawner.SpawnRecord('Character.Judy', spawnPosition)
			Multipunk.PlayerEntityIds[key] = eid
		end
	end

   if packetType == "ServerPlayerLeavePacket" then
		local playerId = packet["id"]
		local eid = Multipunk.PlayerEntityIds[playerId]
		if (eid ~= nil) then
			exEntitySpawner.Despawn(Game.FindEntityByID(eid))
		end
   end

   if packetType == "ServerPlayerMovePacket" then
		local playerId = packet["id"]
		local eid = Multipunk.PlayerEntityIds[playerId]
		if (eid == nil) then
			local spawnPosition = Game.GetPlayer():GetWorldTransform()
			eid = exEntitySpawner.SpawnRecord('Character.Judy', spawnPosition)
			Multipunk.PlayerEntityIds[playerId] = eid
		end
		local position = Vector4.new(packet["x"], packet["y"], packet["z"], 1)
		local rotation = EulerAngles.new(0, packet["pitch"], packet["yaw"])
		local entity = Game.FindEntityByID(eid)
		Multipunk:MoveNPC(entity, position, rotation)
   end
end

function Multipunk:MoveNPC(entity, position, orientation)

	local dist = entity:GetWorldPosition():Distance(position)
	if (dist < 0.5) then
		if (ShitUtils.EulerAnglesEuqials(entity:GetWorldOrientation():ToEulerAngles(), orientation) == false) then
			NpcMovingUtils.Rotate(entity, orientation)
		end
	elseif (dist < 5) then
		NpcMovingUtils.WalkTo(entity, position)
	else
		NpcMovingUtils.TeleportTo(entity, position)
	end
end

function Multipunk:new()
	registerForEvent("onInit", function()
	   -- ConnectionConnect("127.0.0.1", 2077)
	end)

	registerForEvent("onShutdown", function()
		-- ConnectionDisconnect()
		for key, val in pairs(Multipunk.PlayerEntityIds) do
            exEntitySpawner.Despawn(Game.FindEntityByID(val))    
        end
        Multipunk.PlayerEntityIds = {}
	end)

	registerForEvent("onUpdate", function(delta)
		while true do
			local rec = ConnectionReceive()
			if (rec ~= nil and rec ~= "") then
				-- print(rec)
				local packet = json.decode(rec)
				Multipunk:OnReceive(packet)
			else
				break
			end
		end

		local position = Game.GetPlayer():GetWorldPosition()
		local rotation = Game.GetPlayer():GetWorldOrientation():ToEulerAngles()
		-- if position.x ~= Multipunk.LastPosition.x or position.y ~= Multipunk.LastPosition.y or position.z ~= Multipunk.LastPosition.z or rotation.pitch ~= Multipunk.LastRotation.pitch or rotation.roll ~= Multipunk.LastRotation.roll or rotation.yaw ~= Multipunk.LastRotation.yaw then
			Multipunk:OnMove(position, rotation)
		-- 	Multipunk.LastPosition = position
		-- 	Multipunk.LastRotation = rotation
		-- end
	end)
end

return Multipunk:new()
