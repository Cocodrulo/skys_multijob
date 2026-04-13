
local config = require('common.config.shared')

config.commandName = 'multijob'

config.maxJobs = 3
config.prohibitedGroups = { -- Groups of jobs that cannot be held together
    { 'police', 'ambulance' },
    { 'garbage', 'police' }
}

return config
