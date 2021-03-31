

local libs2config = require('org_github_arosecra/config');
local setting = {};

setting.default_settings_for_char = function(runtime_config, name, mainjob, subjob) 
    if runtime_config[name] == nil or runtime_config[name].MainJob ~= mainjob then
        runtime_config[name] = {};
        runtime_config[name].MainJob = mainjob;
        runtime_config[name].SubJob = subjob;
        local settings = libs2config.get_string_table(addon.name, mainjob, "Settings");
        settings:each(function(setting, setting_index)
            local setting_name = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting .. '.Name');
            local setting_values = libs2config.get_string_table(addon.name, "Settings", setting .. '.Values');
            local default = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting .. '.Default');
            for j=0,#setting_values do
                if setting_values[j] == default then
                    runtime_config[name][setting_name] = j;
                end
            end
            
        end);
    end
end


return setting;