require("protocol.TempShitSender")

TestMod = {
    description = "Checks if the player is naked!",
    Player = nil,
    ClientId = 2,
    ServerId = 1,
    NpcId = nil
}

function TestMod:new()

    registerForEvent("onInit", function()
        TestMod.Player = Game.GetPlayer()
        local spawnPosition = Game.GetPlayer():GetWorldTransform()
        TestMod.NpcId = exEntitySpawner.SpawnRecord('Character.Judy', spawnPosition)
    end)

    registerForEvent("onShutdown", function()
        exEntitySpawner.Despawn(Game.FindEntityByID(TestMod.NpcId))
        TestMod.Player = nil
        TestMod.NpcId = nil
    end)

    registerForEvent("onUpdate", function(delta)
        local vector = TestMod.Player:GetWorldPosition()
        local file = io.open("net_test/" .. tostring(TestMod.ClientId) .. ".txt", "w")
        file:write(tostring(vector:ToString()))
        file:close()

        local file = io.open("net_test/" .. tostring(TestMod.ServerId) .. ".txt", "r")
        local text = file:read("*a")
        file:close()
        local t = {}
        -- print(text)
        for k in string.gmatch(text, "%S+") do
            -- print(tonumber(k))
            table.insert(t, tonumber(k))
        end
        -- print(t[1])
        -- local vector = Vector4.new(0, 0, 0)
        local vector = Vector4.new(t[1], t[2], t[3], t[4])
        print(vector:ToString())
        local cmd = AITeleportCommand.new({doNavTest = false, rotation = 1, position = vector})
        Game.FindEntityByID(TestMod.NpcId):GetAIControllerComponent():SendCommand(cmd)
        print("sucess")

        -- TestMod.Sender:send(TestMod.Player:GetWorldPosition())
        -- print("Is the player naked this frame? " .. tostring(TestMod.Player:IsNaked()))
    end)

end

return TestMod:new()
