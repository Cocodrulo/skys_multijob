-- ====================|| VARIABLES || ==================== --

--- @type client_framework
local framework <const> = require('common.frameworks.framework')
local config <const> = require('common.config.shared')

-- ====================|| FUNCTIONS || ==================== --

local openJobMenu = function (job, grade)
    local jobData = framework.getJobData(job)
    local toggleDuty = framework.getJob().name == job
    local options = {
        {
            title = lib.locale('menu.select_job'),
            description = lib.locale('menu.select_job_description'),
            icon = 'fa-solid fa-arrow-right-arrow-left',
            onSelect = function ()
                TriggerServerEvent('skys_multijob:server:switchJob', job)
            end
        },
        {
            title = lib.locale('menu.remove_job'),
            description = lib.locale('menu.remove_job_description'),
            icon = 'fa-solid fa-trash-can',
            onSelect = function ()
                TriggerServerEvent('skys_multijob:server:removeJob', job)
            end
        },
        {
            title = lib.locale('menu.toggle_duty'),
            description = lib.locale('menu.toggle_duty_description'),
            icon = 'fa-solid fa-toggle-off',
            disabled = toggleDuty,
            onSelect = function ()
                TriggerServerEvent('skys_multijob:server:toggleDuty')
            end
        },
        {
            title = lib.locale('menu.back'),
            description = lib.locale('menu.back_description'),
            icon = 'fa-solid fa-arrow-left',
            onSelect = function ()
                lib.showContext('multijob')
            end
        }
    }

    lib.registerContext({
        id = 'job_menu',
        title = string.format('%s (%s)', jobData.label, jobData.grades[grade].name),
        options = options
    })
    lib.showContext('job_menu')
end

-- ====================|| EVENTS || ==================== --

--- @param multijob populated_multijob_entry[]
RegisterNetEvent('skys_multijob:client:openMenu', function (multijob)
    local jobData = framework.getJob()
    local unemployedData = framework.getJobData(config.unemployedJob)

    local options = {
        {
            title = unemployedData.label,
            description = unemployedData.grades[0].name,
            icon = 'fa-solid fa-briefcase',
            onSelect = function ()
                openJobMenu(config.unemployedJob, 0)
            end
        }
    }

    for _, job in ipairs(multijob) do
        table.insert(options, {
            title = jobData.name == job.name and jobData.label .. '(Actual)' or job.label,
            description = job.grade.name,
            icon = 'fa-solid fa-briefcase',
            onSelect = function ()
                openJobMenu(job.name, job.grade.level)
            end
        })
    end

    lib.registerContext({
        id = 'multijob',
        title = lib.locale('menu.title'),
        options = options
    })

    lib.showContext('multijob')
end)
