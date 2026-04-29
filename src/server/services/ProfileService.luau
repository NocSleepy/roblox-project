--[[
    ALL OF THIS CODE WRITTEN BY Sleepy - me WITHOUT AI.
    THATS A RESPECT!
    THIS IS THE REASON THE CODE IS SO UGLY 😭
]]--

-- SERVICES AND VARIABLES --

-- @ROBLOX
local DSS: DataStoreService = game:GetService('DataStoreService')

-- @CUSTOM
-- Custom service section empty for not it gonna get added soon.

-- DATABASES
local PlayerData = DSS:GetDataStore('PlayerData')

-- TYPE DEFINITIONS --
-- @GLOBAL TYPES
export type service_t = {
    init_conf: () -> typeof(setmetatable({} :: any, {})),
    init_plr: (self: {}, player: Player) -> boolean?,
    load_async: (player: Player) -> (boolean, {any}?)
}


-- @LOCAL TYPES
type self_t = {
    Sessions: {[Player]: {progress: string, loaded: boolean, backup_loaded: boolean} },
    UpdateQueue: {[Player]: {InQueue: boolean, InProgress: boolean}},
    SaveQueue: {[Player]: {InQueue: boolean, InProgress: boolean}},

    -- RULES
    CURRENT_ATTEMPTS: {[Player]: {ATTEMPT: number}},
    MAX_ATTEMPT: number,
    AUTO_DATA_UPDATE_DURATION: number
}

-- TABLES --
local ProfileService: service_t = {}
ProfileService.__index = ProfileService

function ProfileService.init_conf(): typeof(setmetatable({} :: self_t, ProfileService))
    local self: self_t = {
        Sessions = {},
        UpdateQueue = {},
        SaveQueue = {},
        
        CURRENT_ATTEMPTS = {},

        -- RULES
        MAX_ATTEMPT = 5,
        AUTO_DATA_UPDATE_DURATION = 300
    }

    return setmetatable(self, ProfileService)
end

function ProfileService.init_plr(self, player: Player)
    if self.Sessions[player] == nil then
        self.Sessions[player] = {
            progress = "initialized player config",
            loaded = false,
            backup_loaded = false,
        }
    end

    if self.SaveQueue[player] == nil then
        self.SaveQueue[player] = {
            InQueue = false,
            InProgress = false
        }
    end

    if self.UpdateQueue[player] == nil then
        self.UpdateQueue[player] = {
            InQueue = false,
            InProgress = false
        }
    end

    if self.CURRENT_ATTEMPTS[player] == nil then
        self.CURRENT_ATTEMPTS[player] = { ATTEMPT = 0 }
    end
    return true
end

function ProfileService:load_async(player)
    local isGotProgressConfig = self.Sessions[player].progress:lower() == 'initialized player config'

    if not isGotProgressConfig then
        repeat
            wait()
        until isGotProgressConfig
    end

    -- first try to get the data

    local succ, data = pcall(function()
        return PlayerData:GetAsync(player.UserId)
    end)
end

return ProfileService