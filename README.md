# 👷 skys_multijob

> A powerful multi-job system for FiveM servers, allowing players to hold multiple jobs simultaneously with configurable limits, prohibited groups, off-duty support, and a clean `ox_lib`-powered menu.

<div align="center">

![FiveM](https://img.shields.io/badge/FiveM-Resource-blue?style=for-the-badge&logo=fivem)
![Lua](https://img.shields.io/badge/Lua-5.4-purple?style=for-the-badge&logo=lua)
![Framework](https://img.shields.io/badge/Framework-QBX-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-GPL--3.0-green?style=for-the-badge)

</div>

---

## ✨ Features

- 💼 **Multiple Jobs** — Players can hold multiple jobs at the same time.
- 🔢 **Configurable Limits** — Define a maximum number of jobs per player (`false` for unlimited).
- 🚫 **Prohibited Groups** — Prevent conflicting jobs (e.g. Police + Ambulance) from being held simultaneously.
- 🔄 **Off-Duty System** — Built-in support for separate off-duty job variants via prefix (e.g. `off_police`).
- 🖥️ **Context Menu UI** — Clean and intuitive menu built with `ox_lib` context menus.
- 📉 **Unemployed Fallback** — Automatically handles the `unemployed` job status.
- 🛠️ **Developer API** — Full server-side export API for easy integration with other resources.
- 🌍 **Localization** — Multi-language support via `locales/` (English & Spanish included).
- ⚡ **Caching** — Results are cached for performance (multijob data, employees, etc.).

---

## 📦 Dependencies

| Resource | Required | Link |
| :------- | :------: | :--- |
| `ox_lib` | ✅ | [communityox/ox_lib](https://github.com/communityox/ox_lib) |
| `oxmysql` | ✅ | [communityox/oxmysql](https://github.com/communityox/oxmysql) |

---

## 💿 Installation

1. **Download** — Clone or download this repository into your server's `resources` folder:

   ```bash
   git clone https://github.com/Cocodrulo/skys_multijob [SkyStore]/skys_multijob
   ```

2. **Database** — Import the SQL schema into your database:

   ```bash
   mysql -u root -p your_database < multijob.sql
   ```

   Or import `multijob.sql` manually using your database manager. This creates the `player_multijob` table:

   ```sql
   CREATE TABLE `player_multijob` (
       `citizenid` VARCHAR(50) NOT NULL,
       `job`       VARCHAR(50) NOT NULL,
       `grade`     INT(11)    NOT NULL,
       PRIMARY KEY (`citizenid`, `job`),
       ...
   );
   ```

3. **Ensure** — Add the resource to your `server.cfg`:

   ```cfg
   ensure skys_multijob
   ```

---

## ⚙️ Configuration

Configuration is split across two files:

### `common/config/shared.lua` — Shared (client & server)

| Option | Description | Default |
| :----- | :---------- | :------ |
| `config.unemployedJob` | The fallback job when a player has no active job. | `'unemployed'` |
| `config.separateOffDuty` | Enable off-duty system using a job name prefix. | `true` |
| `config.offDutyPrefix` | Prefix used to identify off-duty job variants. | `'off'` |

### `common/config/server.lua` — Server-only

| Option | Description | Default |
| :----- | :---------- | :------ |
| `config.commandName` | The command players use to open the menu. | `'multijob'` |
| `config.maxJobs` | Maximum jobs per player (`false` = unlimited). | `3` |
| `config.prohibitedGroups` | Arrays of job names that can't be held together. | `{ {'police','ambulance'}, {'garbage','police'} }` |

#### Example — Prohibited Groups

```lua
config.prohibitedGroups = {
    { 'police', 'ambulance' }, -- Police and Ambulance can't be held at the same time
    { 'garbage', 'police' },   -- Garbage and Police can't be held at the same time
}
```

---

## 🚀 Usage

### Player Commands

| Command | Description |
| :------ | :---------- |
| `/multijob` | Opens the multi-job management menu (configurable name). |

### Menu Options

When opening the menu, players can:

- **Select a Job** — Switch their active job to one from their list.
- **Toggle Duty** — Toggle on/off duty for the current job (uses the off-duty prefix if `separateOffDuty` is enabled).
- **Remove a Job** — Remove a job from their multi-job list.

---

## 📤 Server Exports (API)

All exports are available server-side. Both online player sources and offline `citizenid` strings are supported where indicated.

| Export | Signature | Description | Availability |
| :----- | :-------- | :---------- | :----------- |
| `AddJob` | `AddJob(source, job, grade)` | Adds a job to the player's list. Updates the grade if already present. | Online & Offline |
| `RemoveJob` | `RemoveJob(source, job)` | Removes a job from the player's list. Falls back to `unemployed` if it was the active job. | Online & Offline |
| `SwitchJob` | `SwitchJob(source, job)` | Switches the player's active job to one from their list. | Online Only |
| `ToggleDuty` | `ToggleDuty(source, onDuty?)` | Toggles on/off duty. Pass `true`/`false` or `nil` to auto-detect. | Online Only |
| `GetPlayerMultijob` | `GetPlayerMultijob(citizenid)` | Returns the full list of jobs for a player. | Online & Offline |
| `GetEmployees` | `GetEmployees(job)` | Returns a dictionary (keyed by `citizenid`) of all players who have the specified job, including their character info and full grade data. | Online & Offline |

### Examples

```lua
-- Add a job to a player
local result = exports['skys_multijob']:AddJob(source, 'mechanic', 1)
if result.success then
    print('Job added!')
else
    print('Error:', result.code)
end

-- Check all employees of a job
-- Returns a dict keyed by citizenid
local employees = exports['skys_multijob']:GetEmployees('mechanic')
for citizenid, employee in pairs(employees) do
    print(citizenid, employee.charinfo.firstname, employee.charinfo.lastname)
    print(employee.job.label, employee.job.grade.name, employee.job.grade.salary)
end

-- Get all jobs a player holds
-- Returns a dict keyed by job name
local jobs = exports['skys_multijob']:GetPlayerMultijob(citizenid)
for jobName, job in pairs(jobs) do
    print(jobName, job.label, job.grade.name)
end
```

### `GetEmployees` Return Format

Returns a **dictionary keyed by `citizenid`**. Each entry is an `employee_entry`:

```lua
{
    ["ABC123"] = {
        citizenid = "ABC123",
        charinfo = {
            firstname   = "John",
            lastname    = "Doe",
            birthdate   = "1990-01-01",
            gender      = 0,
            nationality = "USA"
        },
        job = {
            name  = "mechanic",
            label = "Mechanic",
            grade = {
                name   = "Senior Mechanic",
                level  = 2,
                salary = 350
            }
        }
    },
    ...
}
```

### API Response Format

All write operations return an `api_response` table:

```lua
{
    success = true | false,
    code    = "job_added" | "job_already_exists" | "max_jobs_reached" | ...,
    data    = nil -- optional extra data
}
```

---

## 🌍 Localization

Locale files are located in `locales/`. Currently supported:

| Language | File |
| :------- | :--- |
| 🇬🇧 English | `locales/en.json` |
| 🇪🇸 Spanish | `locales/es.json` |

To add a new language, duplicate an existing locale file and translate the values. The resource uses `ox_lib`'s locale system.

---

## 🏗️ Project Structure

```bash
skys_multijob/
├── client/
│   └── main.lua               # Client-side menu and event handlers
├── server/
│   ├── main.lua               # Server-side events, commands, and export registration
│   └── api.lua                # Core API logic (add/remove/switch job, duty, etc.)
├── common/
│   ├── config/
│   │   ├── shared.lua         # Shared configuration (client & server)
│   │   └── server.lua         # Server-only configuration
│   ├── frameworks/
│   │   ├── framework.lua      # Framework abstraction loader
│   │   └── qbx/               # QBX Core implementation
│   └── types.lua              # LuaLS type annotations
├── locales/
│   ├── en.json                # English translations
│   └── es.json                # Spanish translations
├── multijob.sql               # Database schema
└── fxmanifest.lua             # FiveM resource manifest
```

---

## 🔌 Framework Support

Currently supported frameworks:

| Framework | Status |
| :-------- | :-------- |
| **QBX Core** | ✅ Supported |

The framework layer is abstracted via `common/frameworks/framework.lua`, making it straightforward to add support for additional frameworks (e.g. ESX, QB-Core) by implementing the `server_framework` and `client_framework` interfaces defined in `common/types.lua`.

---

## 📜 License

This project is licensed under the **[GPL-3.0 License](LICENSE)**.
