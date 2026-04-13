--- @class server_framework
local framework = {}

framework.onJobUpdate = function (cb)
    AddEventHandler("QBCore:Server:OnJobUpdate", cb)
end

framework.getJob = function (src)
    local Player = exports.qbx_core:GetPlayer(src) or type(src) == 'string' and exports.qbx_core:GetOfflinePlayer(src)
    return Player?.PlayerData?.job
end

framework.setJob = function (src, job, grade)
    return exports.qbx_core:SetJob(src, job, grade)
end

framework.getJobData = function (job)
    return exports.qbx_core:GetJob(job)
end

framework.notify = function (src, text, type)
    exports.qbx_core:Notify(src, text, type)
end

framework.getCitizenId = function (src)
    local Player = exports.qbx_core:GetPlayer(src) or type(src) == 'string' and exports.qbx_core:GetOfflinePlayer(src)
    return Player?.PlayerData?.citizenid
end

framework.setJobDuty = function (src, onDuty)
    return exports.qbx_core:SetJobDuty(src, onDuty)
end

return framework