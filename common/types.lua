--- @class populated_multijob_entry
--- @field citizenid string
--- @field name string
--- @field label string
--- @field grade {name: string, level: number}

--- @class employee_entry
--- @field citizenid string
--- @field charinfo { firstname: string, lastname: string, birthdate: string, gender: number, nationality: string }
--- @field job {name: string, label: string, grade: {name: string, level: number}}

--- @class framework_job
--- @field name string
--- @field label string
--- @field payment number
--- @field type? string
--- @field onduty boolean
--- @field isboss boolean
--- @field grade {name: string, level: number}

--- @class framework_jobdata
--- @field name string
--- @field label string
--- @field type? string
--- @field grades { [number]: { name: string, level: number, salary: number, isboss?: boolean } }

--- @alias source number|string
--- @alias api_response { success: boolean, code: string, data?: any }

--- @class server_framework
--- @field onJobUpdate fun(cb: fun(src: number, job: framework_job)) Triggers the given function when someone job is updated
--- @field getJob fun(src: source): framework_job? Gets the player job from source
--- @field setJob fun(src: source, job: string, grade: number): boolean Sets the player job by it source
--- @field getJobData fun(job: string): framework_jobdata Gets the job data if exists
--- @field notify fun(src: source, text: string, type: "success"|"error"|"info") Send a notification to a player
--- @field getCitizenId fun(src: source): string Gets the citizen id from source
--- @field setJobDuty fun(src: source, onDuty: boolean): boolean Sets the player job duty

--- @class client_framework
--- @field getJobData fun(job: string): framework_jobdata Gets the job data if exists