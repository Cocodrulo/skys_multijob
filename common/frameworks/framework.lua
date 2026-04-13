local frameworks <const> = {
    ["qbx_core"] = 'qbx'
}

for resource, framework in pairs(frameworks) do
    if GetResourceState(resource):find('start') then
        return require(("common.frameworks.%s.%s"):format(framework, lib.context))
    end
end

error("[FATAL ERROR]: NOT FRAMEWORK FOUND")
