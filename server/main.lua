-- ====================|| VARIABLES || ==================== --

local api <const> = require('server.api')
--- @type server_framework
local framework <const> = require('common.frameworks.framework')
local config <const> = require('common.config.server')

-- ====================|| EVENTS || ==================== --

RegisterServerEvent('skys_masterjob:server:switchJob', function (job)
    local src = source
    if not api.switchJob(src, job) then
        framework.notify(src, lib.locale('error.switch_job'), 'error')
    else
        local jobData = framework.getJobData(job)
        framework.notify(src, lib.locale('success.switch_job', jobData.label), 'success')
    end
end)

RegisterServerEvent('skys_masterjob:server:removeJob', function (job)
    local src = source
    if not api.removeJob(src, job) then
        framework.notify(src, lib.locale('error.remove_job'), 'error')
    else
        local jobData = framework.getJobData(job)
        framework.notify(src, lib.locale('success.remove_job', jobData.label), 'success')
    end
end)

RegisterServerEvent('skys_masterjob:server:toggleDuty', function (duty)
    local src = source
    if not api.toggleDuty(src, duty) then
        framework.notify(src, lib.locale('error.toggle_duty'), 'error')
    else
        local jobData = framework.getJobData(framework.getJob(src).name)
        framework.notify(src, lib.locale('success.toggle_duty', jobData.label), 'success')
    end
end)

framework.onJobUpdate(function(source, job)
    api.addJob(source, job.name, job.grade.level)
end)

-- ====================|| COMMANDS || ==================== --

lib.addCommand(config.commandName, { help = lib.locale('command.description') }, function(source)
    TriggerClientEvent('skys_multijob:client:openMenu', source, api.getPlayerMultijob(framework.getCitizenId(source)))
end)

-- ====================|| EXPORTS || ==================== --

exports('AddJob', api.addJob)
exports('RemoveJob', api.removeJob)
exports('SwitchJob', api.switchJob)
exports('ToggleDuty', api.toggleDuty)
exports('GetPlayerMultijob', api.getPlayerMultijob)
exports('GetEmployees', api.getEmployees)
