local tempShitProtocol = {
    ClientId = nil,
    ServerId = nil,
    StringUtils = nil
}

tempShitProtocol.__index = tempShitProtocol

function tempShitProtocol:new(ClientId, ServerId, StringUtils)
    local obj = {
        ClientId = ClientId,
        ServerId = ServerId,
        StringUtils = StringUtils
    }
    setmetatable(obj, self)
    return obj
end

function tempShitProtocol:send(position, rotation)
    local file = io.open("net_test/" .. tostring(self.ClientId) .. ".txt", "w")
    file:write(tostring(position:ToString()))
    file:close()
end

function tempShitProtocol:recive()
    local file = io.open("net_test/" .. tostring(self.ServerId) .. ".txt", "r")
    local text = file:read("*a")
    file:close()
    local t = self.StringUtils:split(text)
    local vector = Vector4.new(tonumber(t[1]), tonumber(t[2]), tonumber(t[3]), tonumber(t[4]))
    return {position = vector, rotation = nil}
end

return tempShitProtocol
