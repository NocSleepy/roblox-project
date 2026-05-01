--[[
    ALL OF THIS CODE WRITTEN BY Sleepy - Noctxy (same person btw) WITHOUT AI.
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
export type default_t = {
	Level: number,
	Token: number,
	Gem:   number,
	
	FirtTimeJoin: typeof(os.date()),
	LastTimeJoin: typeof(os.date()),
	
	Settings: {
		Sounds: {
			MasterVolume: 	number,
			MusicVolume: 	number,
			SoundVolume: 	number
		},
		
		Graphics: {
			ShadowOption: 	boolean,
			VignetteOption: boolean
		}
	},
	
	Data: {
		LastLoad: 		typeof(os.date()),
		
		FirstUpdate: 	typeof(os.date())?,
		LastUpdate: 	typeof(os.date())?,

		LastBackupLoad: typeof(os.date())?,

		FirstBackupUpdate: typeof(os.date())?,
		LastBackupUpdate: typeof(os.date())?,
		
		CheatSuspencion: number
	}
}

export type service_t = {
    init_conf:   () -> typeof(setmetatable({} :: any, {})),
	init_plr:    (player: Player) -> boolean?,
	get_default: () -> default_t,
	load_async:  (player: Player) -> (boolean, {any}?),
	fetch_async: (player: Player, data: {any}?) ->  boolean?
}

-- @LOCAL TYPES
type self_t = {
    Sessions:		{[Player]: {progress: string, loaded: boolean, backup_loaded: boolean} },
    UpdateQueue:	{[Player]: {InQueue: boolean, InProgress: boolean}},
    SaveQueue:		{[Player]: {InQueue: boolean, InProgress: boolean}},

    -- RULES
    CURRENT_ATTEMPTS: 			{[Player]: {ATTEMPT: number}},
    MAX_ATTEMPT: 				number,
    AUTO_DATA_UPDATE_DURATION:	number
}

-- TABLES --
local ProfileService: service_t = {}
ProfileService.__index = ProfileService

function ProfileService.init_conf(): typeof(setmetatable({} :: self_t, ProfileService))
    local self: self_t = {
        Sessions =    {},
        UpdateQueue = {},
        SaveQueue =   {},
        
        CURRENT_ATTEMPTS = {},

        -- RULES
        MAX_ATTEMPT = 5,
        AUTO_DATA_UPDATE_DURATION = 300
    }

    return setmetatable(self, ProfileService)
end

function ProfileService:init_plr(player: Player)
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

function ProfileService:get_default()
	return {
		Level = 1,
		Token = 0,
		Gem = 0,
		
		FirtTimeJoin = os.date(),
		LastTimeJoin = os.date(),
		
		Settings = {
			Sounds = {
				MasterVolume = 100,
				MusicVolume  = 100,
				SoundVolume  = 100
			},
			
			Graphics = {
				ShadowOption   = true,
				VignetteOption = true
			},
		},
		
		Data = {
			LastLoad       = os.date(),
			
			FirstUpdate    = nil,
			LastUpdate     = nil,
			
			LastBackupLoad = nil,
			
			FirstBackupUpdate = nil,
			LastBackupUpdate  = nil,
			CheatSuspencion   = 0
		}
	} :: default_t
end

function ProfileService:load_async(player)
    local isGotProgressConfig = self.Sessions[player].progress:lower() == 'initialized player config'

    if not isGotProgressConfig then
        -- error management gonna be added here soon.
    end

    if self.CURRENT_ATTEMPTS[player].ATTEMPT >= self.MAX_ATTEMPT then
		player:Kick(`THE ROBLOX DATA STORES MIGHT BE BROKEN BECAUSE THE DATA STORE FAILED TO LOAD PLEASE REJOIN TO TRY AGAIN IF THIS HAPPENS AGAIN CHECK THIS SITE: https://status.roblox.com THANKS FOR PLAYING OUR GAME HAVE A NICE DAY!`)
		return false, nil
    else
        self.CURRENT_ATTEMPTS[player].ATTEMPT += 1
    end

    local plrKey = "player_"..player.UserId

    -- first try to get the data

    local succ, data = pcall(function()
        return PlayerData:GetAsync(plrKey)
	end)
	
	if succ then
		if data ~= nil then
			return true, data
		elseif data == nil then
			local default = self:get_default()
			return true, default
		end
	else
		--self:try_backup() -- gonna be added soon!
		return false, nil
	end
	
	return false, nil
end

function ProfileService:fetch_async(player, data)
	-- empty for now new things gonna be added here soon!
	return nil
end

return ProfileService
