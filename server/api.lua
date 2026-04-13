-- ====================|| VARIABLES || ==================== --

--- @type server_framework
local framework <const> = require('common.frameworks.framework')
local config <const> = require('common.config.server')
local api = {}

-- ====================|| FUNCTIONS || ==================== --

--- Gets the size of a table
--- @param tbl table
--- @return number
local tableSize = function(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

--- Checks if the multijob contains any prohibited groups
--- @param multijob table
--- @param job string
--- @return boolean
local containsProhibitedGroups = function(multijob, job)
    for _, jobGroup in pairs(config.prohibitedGroups) do
        if not lib.table.contains(jobGroup, job) then goto continue end

        for _, singleJob in pairs(jobGroup) do
            if multijob[singleJob] then return true end
        end

        ::continue::
    end
    return false
end

--- Adds a job to the player multijob in the database
--- @param citizenid string
--- @param job string
--- @param grade number
local addMultijobToDatabase = function(citizenid, job, grade)
    exports.oxmysql.insert_async(nil, 'INSERT INTO player_multijob (citizenid, job, grade) VALUES (?, ?, ?)', {
        citizenid, job, grade
    })
    cache['multijob:' .. citizenid] = nil
end

--- Removes a job from the player multijob in the database
--- @param citizenid string
--- @param job string
local removeMultijobFromDatabase = function(citizenid, job)
    exports.oxmysql.query_async(nil, 'DELETE FROM player_multijob WHERE citizenid = ? AND job = ?', {
        citizenid, job
    })
    cache['multijob:' .. citizenid] = nil
end

--- Updates the grade of a job in the player multijob in the database
--- @param citizenid string
--- @param job string
--- @param grade number
local updateMultijobGradeInDatabase = function(citizenid, job, grade)
    exports.oxmysql.update_async(nil, 'UPDATE player_multijob SET grade = ? WHERE citizenid = ? AND job = ?', {
        grade, citizenid, job
    })
    cache['multijob:' .. citizenid] = nil
end

--- Creates a new API response
--- @param success boolean
--- @param code string
--- @param ... any
--- @return api_response
local response = function (success, code, ...)
    return { success = success, code = code, data = ... }
end

local startsWith = function (str, prefix)
    return str:sub(1, #prefix) == prefix
end

--- Gets the player multijob
--- @param citizenid string
--- @return populated_multijob_entry[]
api.getPlayerMultijob = function (citizenid)
    return cache('multijob:' .. citizenid, function()
        local multijob = exports.oxmysql.query_async(nil, 'SELECT * FROM player_multijob WHERE citizenid = ?', { citizenid })
        for _, job in ipairs(multijob) do
            local jobData = framework.getJobData(job.job)
            job.job = nil
            job.name = jobData.name
            job.label = jobData.label
            job.grade = jobData.grades[job.grade]
        end
        return multijob
    end, 10 * 60 * 1000)
end

--- Adds a job to the player multijob
--- @param source number
--- @param job string
--- @param grade number
--- @return api_response
api.addJob = function (source, job, grade)
    if job == config.unemployedJob then return response(false, 'cannot_add_or_modify_unemployed') end

    local jobData = framework.getJobData(job)
    if not jobData then return response(false, 'job_data_not_found') end

    local citizenid = framework.getCitizenId(source)
    if not citizenid then return response(false, 'citizenid_not_found') end

    local multijob = api.getPlayerMultijob(citizenid)
    if not multijob then return response(false, 'multijob_not_found') end

    if config.separateOffDuty and startsWith(jobData.name, config.offDutyPrefix) then return response(false, 'cannot_add_offduty_job') end

    if multijob[jobData.name] then
        if multijob[jobData.name].grade == grade then
            return response(false, 'job_already_exists')
        end

        if not jobData.grades[grade] then
            return response(false, 'invalid_grade')
        end

        updateMultijobGradeInDatabase(citizenid, jobData.name, grade)
        return response(true, 'job_updated')
    end

    if config.maxJobs and tableSize(multijob) >= config.maxJobs then return response(false, 'max_jobs_reached') end

    if containsProhibitedGroups(multijob, jobData.name) then return response(false, 'prohibited_job') end

    addMultijobToDatabase(citizenid, jobData.name, grade)
    return response(true, 'job_added')
end

--- Removes a job from the player multijob
--- @param source number
--- @param job string
--- @return api_response
api.removeJob = function (source, job)
    if job == config.unemployedJob then return response(false, 'cannot_remove_unemployed') end

    local jobData = framework.getJobData(job)
    if not jobData then return response(false, 'job_data_not_found') end

    local citizenid = framework.getCitizenId(source)
    if not citizenid then return response(false, 'citizenid_not_found') end

    local multijob = api.getPlayerMultijob(citizenid)
    if not multijob then return response(false, 'multijob_not_found') end

    if not multijob[jobData.name] then return response(false, 'job_not_found') end

    if framework.getJob(source).name == jobData.name then
        framework.setJob(source, config.unemployedJob, 0)
    end

    removeMultijobFromDatabase(citizenid, jobData.name)
    return response(true, 'job_removed')
end

--- Gets all employees of a job
--- @param job string
--- @return multijob_entry[]
api.getEmployees = function (job)
    return cache('employees:' .. job, function()
        return exports.oxmysql.query_async(nil, 'SELECT * FROM player_multijob WHERE job = ?', { job })
    end, 10 * 60 * 1000)
end

--- Switches the player's job
--- @param source number
--- @param job string
--- @return api_response
api.switchJob = function (source, job)
    local jobData = framework.getJobData(job)
    if not jobData then return response(false, 'job_data_not_found') end

    if config.separateOffDuty and startsWith(jobData.name, config.offDutyPrefix) then return response(false, 'cannot_switch_to_offduty_job') end

    local citizenid = framework.getCitizenId(source)
    if not citizenid then return response(false, 'citizenid_not_found') end

    local playerJob = framework.getJob(source)
    local multijob = api.getPlayerMultijob(citizenid)
    if not playerJob or not multijob then return response(false, 'player_job_not_found') end
    if not multijob[jobData.name] then return response(false, 'dont_have_job') end

    if playerJob.name == jobData.name and playerJob.grade.level == multijob[jobData.name].grade then return response(false, 'job_already_active') end

    framework.setJob(source, jobData.name, multijob[jobData.name].grade.level)
    return response(true, 'job_switched')
end

--- Toggles the player's job duty
--- @param source number
--- @param onDuty boolean
--- @return api_response
api.toggleDuty = function (source, onDuty)
    local playerJob = framework.getJob(source)
    if not playerJob then return response(false, 'player_job_not_found') end

    if playerJob.name == config.unemployedJob then
        return response(false, 'cannot_toggle_unemployed')
    end

    if onDuty == nil then onDuty = startsWith(playerJob.name, config.offDutyPrefix) end

    if config.separateOffDuty then
        if onDuty and not startsWith(playerJob.name, config.offDutyPrefix) then
            return response(false, 'duty_already_set')
        elseif not onDuty and startsWith(playerJob.name, config.offDutyPrefix) then
            return response(false, 'duty_already_set')
        end

        framework.setJob(source, onDuty and playerJob.name:gsub(config.offDutyPrefix, '') or config.offDutyPrefix .. playerJob.name, playerJob.grade.level)
    end

    if playerJob.onduty == onDuty then
        return response(false, 'duty_already_set')
    end

    framework.setJobDuty(source, onDuty)
    return response(true, 'duty_toggled')
end

return api
