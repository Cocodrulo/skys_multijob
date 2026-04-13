--- @class client_framework
local framework = {}

framework.getJobData = function (job)
    return exports.qbx_core:GetJob(job)
end

framework.getJob = function ()
    return exports.qbx_core:GetPlayerData().job
end

return framework