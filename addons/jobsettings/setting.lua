
local libs2config = require('org_github_arosecra/config');
local macros_configuration = require('org_github_arosecra/macros/macros_configuration');
local macros_runner = require('org_github_arosecra/macros/macrorunner');
local setting = {};

setting.default_settings_for_char = function(runtime_config, name, mainjob, subjob) 
    if runtime_config[name] == nil or runtime_config[name].MainJob ~= mainjob then
        runtime_config[name] = {};
        runtime_config[name].MainJob = mainjob;
        runtime_config[name].SubJob = subjob;
        local settings = libs2config.get_string_table(addon.name, mainjob, "Settings");
        settings:each(function(setting_array_name, setting_index)
            local setting_name = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting_array_name .. '.Name');
            local setting_values = libs2config.get_string_table(addon.name, "Settings", setting_array_name .. '.Values');
            local default_value = AshitaCore:GetConfigurationManager():GetString(addon.name, "Settings", setting_array_name .. '.Default');
            
            if setting_name ~= nil and setting_values ~= nil then
                setting.find_and_apply_default(runtime_config, name, setting_array_name, setting_name, setting_values, default_value);
            else
                print('Could not set default for ' .. setting_array_name);
            end
        end);
    end
end

setting.find_and_apply_default = function(runtime_config, name, setting_array_name, setting_name, setting_values, default_value)

    for j=0,#setting_values do
        if setting_values[j] == default_value then
            runtime_config[name][setting_name] = j;
            setting.run_macro(setting_array_name, setting_name, setting_values[j], name);
        end
    end
end

setting.run_macro = function(setting_array_name, setting_name, setting_value, name, macro_id)

    local parameters = T{Name = name}
    --local additional_parameters = libs2config.get_string_table(addon.name, "Settings", setting_array_name .. '.Parameters')
    --if additional_parameters ~= nil then
    --    --parameters = parameters:extend(additional_parameters)
	--
    --    additional_parameters:each(function(value, key)
    --        parameters[tostring(key)] = value;
    --    end);
    --end

    if macro_id ~= nil then
        local macro = macros_configuration.get_macro_by_id(macro_id)
        macros_runner.run_macro(macro, parameters);
    else
        print('Macro for ' .. setting_array_name .. ' was not found.');
    end
end

return setting;