
local libs2config = require('org_github_arosecra/config');
local macros_configuration = require('org_github_arosecra/macros/macros_configuration');
local macros_runner = require('org_github_arosecra/macros/macrorunner');
local setting = {};

setting.default_settings_for_char = function(config, name, mainjob, subjob) 
        local settingsForJob = config.settings.jobs[mainjob]
		if settingsForJob ~= nil then
			settingsForJob:each(function(setting_array_name, setting_index)
				local sequence = config.settings.sequences[setting_array_name]

				if sequence ~= nil and sequence.Name ~= nil and sequence.Values ~= nil then
					for j=1,#sequence.Values do
						if sequence.Values[j] == sequence.Default then
							if config.runtime_config.selections[name] == nil then
								config.runtime_config.selections[name] = {}
							end
							config.runtime_config.selections[name][setting_array_name] = j;
							local macro_id = sequence[sequence.Values[j]]
							setting.run_macro(setting_array_name, sequence.Name, sequence.Values[j], name, macro_id);
						end
					end
				end
			
			end);
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