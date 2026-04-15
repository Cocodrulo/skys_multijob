-- ====================|| VARIABLES || ==================== --

--- @type client_framework
local framework <const> = require('common.frameworks.framework')
local config <const> = require('common.config.shared')
lib.locale()

-- ====================|| FUNCTIONS || ==================== --

local openJobMenu = function (job, grade)
    local jobData = framework.getJobData(job)
    local currentJob = framework.getJob()
    local isCurrentJob = currentJob.name == job or config.separateOffDuty and currentJob.name:gsub(config.offDutyPrefix, '') == job

    local options = {}
    if isCurrentJob then
        options = {
            {
                title = locale('menu.remove_job'),
                description = locale('menu.remove_job_description'),
                icon = 'fa-solid fa-trash-can',
                onSelect = function ()
                    TriggerServerEvent('skys_multijob:server:removeJob', job)
                end
            },
            {
                title = locale('menu.toggle_duty'),
                description = locale('menu.toggle_duty_description'),
                icon = 'fa-solid fa-toggle-off',
                onSelect = function ()
                    TriggerServerEvent('skys_multijob:server:toggleDuty')
                end
            },
            {
                title = locale('menu.back'),
                description = locale('menu.back_description'),
                icon = 'fa-solid fa-arrow-left',
                onSelect = function ()
                    lib.showContext('multijob')
                end
            }
        }
    else
        options = {
            {
                title = locale('menu.select_job'),
                description = locale('menu.select_job_description'),
                icon = 'fa-solid fa-arrow-right-arrow-left',
                onSelect = function ()
                    TriggerServerEvent('skys_multijob:server:switchJob', job)
                end
            },
            {
                title = locale('menu.remove_job'),
                description = locale('menu.remove_job_description'),
                icon = 'fa-solid fa-trash-can',
                onSelect = function ()
                    TriggerServerEvent('skys_multijob:server:removeJob', job)
                end
            },
            {
                title = locale('menu.back'),
                description = locale('menu.back_description'),
                icon = 'fa-solid fa-arrow-left',
                onSelect = function ()
                    lib.showContext('multijob')
                end
            }
        }
    end

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
        local isCurrentJob = jobData.name == job.name or config.separateOffDuty and job.name:gsub(config.offDutyPrefix, '') == jobData.name
        table.insert(options, {
            title = isCurrentJob and jobData.label .. '(Actual)' or job.label,
            description = job.grade.name,
            icon = 'fa-solid fa-briefcase',
            onSelect = function ()
                openJobMenu(job.name, job.grade.level)
            end
        })
    end

    lib.registerContext({
        id = 'multijob',
        title = locale('menu.title'),
        options = options
    })

    lib.showContext('multijob')
end)
