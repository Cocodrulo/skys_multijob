
local config = require('common.config.shared')

config.commandName = 'multijob'

config.separateOffDuty = true
config.offDutyPrefix = 'off'

config.maxJobs = 3
config.prohibitedGroups = { -- Groups of jobs that cannot be held together
    { 'police', 'ambulance' },
    { 'garbage', 'police' }
}

return config
