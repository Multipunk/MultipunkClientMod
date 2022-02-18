TestMod = {
    NpcId = nil,
    Protocol = nil,
    Idk = 0
}

TestMod.StringUtils = require("utils/string_utils")
TestMod.TempShitProtocol = require("protocol/TempShitProtocol")

function TestMod:new()

    registerForEvent("onInit", function()
        TestMod.Protocol = TestMod.TempShitProtocol:new(1, 2, TestMod.StringUtils)
        local spawnPosition = Game.GetPlayer():GetWorldTransform()
        TestMod.NpcId = exEntitySpawner.SpawnRecord('Character.Judy', spawnPosition)
    end)

    registerForEvent("onShutdown", function()
        exEntitySpawner.Despawn(Game.FindEntityByID(TestMod.NpcId))
        TestMod.NpcId = nil
    end)

    registerForEvent("onUpdate", function(delta)
        TestMod.Idk = TestMod.Idk + 1
        if (TestMod.Idk == 10) then
            TestMod.Idk = 0

            TestMod.Protocol:send(Game.GetPlayer():GetWorldPosition())
            local packet = TestMod.Protocol:recive()

            local wp = WorldPosition:new()
            wp:SetVector4(packet.position)
            local aips = AIPositionSpec:new()
            aips:SetWorldPosition(wp)

            -- AIPositionSpec.SetWorldPosition(test, packet.position)
            local cmd = AIMoveToCommand.new({movementTarget = aips, facingTarget = aips, ignoreNavigation = false, desiredDistanceFromTarget = 0.00, movementType = moveMovementType.Sprint, finishWhenDestinationReached = true, useStop = false, useStart = false})
            -- local cmd = AITeleportCommand.new({doNavTest = false, rotation = 1, position = packet.position})
            Game.FindEntityByID(TestMod.NpcId):GetAIControllerComponent():SendCommand(cmd)
            -- Game.GetPlayer():GetWorldOrientation()
            -- local cmd = AIRotateToCommand.new({ target = aips, angleTolerance = 10.0, angleOffset = 0.0, speed = 1.0 })
            -- Game.FindEntityByID(TestMod.NpcId):GetAIControllerComponent():SendCommand(cmd)
            print("sucess")
        end
    end)

end

return TestMod:new()
