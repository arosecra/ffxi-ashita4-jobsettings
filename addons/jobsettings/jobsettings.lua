
addon.name      = 'jobsettings';
addon.author    = 'arosecra';
addon.version   = '1.0';
addon.desc      = '';
addon.link      = '';

local imgui = require('imgui');
require('common');

local libs2imgui = require('org_github_arosecra/imgui');
local macros_configuration = require('org_github_arosecra/macros/macros_configuration');

local setting = require('setting');
local character_treenode = require('character_treenode');

local jobsettings_window = {
    is_open                 = false
};

local config = {
	runtime_config = {
		selections = T{},
		last_known_jobs = T{}
	}
}


local LoadFile = function(path)
    if not string.match(path, '.lua') then
        path = path .. '.lua';
    end
    local filePath = path;
	
    local func, loadError = loadfile(filePath);
    if (not func) then
        print (loadError);
        return nil;
    end

    local fileValue = nil;
    local success, execError = pcall(function ()
        fileValue = func();
    end);
    if (not success) then
        print (execError);
        return nil;
    end

    return fileValue;
end

ashita.events.register('load', 'jobsettings_load_cb', function ()
    macros_configuration.load();
	
	local func, err = LoadFile(AshitaCore:GetInstallPath() .. '/config/jobsettings/config')
	if func then
		config.settings = func
	else
		print(err)
	end
	
	print(config.settings)
end);

ashita.events.register('command', 'jobsettings_command_cb', function (e)
    if (not e.command:startswith('/jobsettings') and not e.command:startswith('/js')) then
		return;
    end
	
    local args = e.command:argsquoted();
            
	if args[2] == 'cycle' then
		local char_name = args[3]
		local setting_array_name = args[4]
		local sequence = config.settings.sequences[setting_array_name]
		local setting_values = sequence.Values
		
		local index = 0
		if config.runtime_config.selections[char_name] ~= nil and config.runtime_config.selections[char_name][setting_array_name] ~= nil then
            index = config.runtime_config.selections[char_name][setting_array_name]
        end
		
		index = index + 1
		if index > #sequence.Values then
			index = 1
		end
		
		if config.runtime_config.selections[char_name] == nil then
			config.runtime_config.selections[char_name] = {}
		end
		
        config.runtime_config.selections[char_name][setting_array_name] = index;
		local setting_value = sequence.Values[index]
		local macro_id = sequence[sequence.Values[index]]
        setting.run_macro(setting_array_name, setting_name, setting_value, char_name, macro_id);
	
	elseif #args == 1 then
		jobsettings_window.is_open = not jobsettings_window.is_open;
	end
    e.blocked = true;
end);

ashita.events.register('d3d_beginscene', 'jobsettings_beginscene_callback1', function (isRenderingBackBuffer)
	local memoryManager = AshitaCore:GetMemoryManager();
	local party = memoryManager:GetParty();
	
	for i=0,5 do
		local mainjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberMainJob(i));
		local subjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberSubJob(i));
		local name = party:GetMemberName(i);
        if mainjob ~= nil and name ~= nil then
			local last_known_job = config.runtime_config.last_known_jobs[name]
			if last_known_job == nil or last_known_job ~= mainjob then
				config.runtime_config.last_known_jobs[name] = mainjob
				setting.default_settings_for_char(config, name, mainjob, subjob);
			end
        end
	end
end);

ashita.events.register('d3d_present', 'jobsettings_present_cb', function ()
	
	local playerEntity = GetPlayerEntity();
    local memoryManager = AshitaCore:GetMemoryManager();
    local party = memoryManager:GetParty();
	if playerEntity == nil or party == nil then
		return;
	end
	
	local windowStyleFlags = libs2imgui.gui_style_table_to_var("imguistyle", "left_drawer", "window.style");
	libs2imgui.set_left_drawer_window(addon.name);
    if jobsettings_window.is_open then
        if imgui.Begin(addon.name, jobsettings_window.is_open, windowStyleFlags) then
			imgui.Text(addon.name)
			imgui.SameLine();
            imgui.SetCursorPosX(450);
            if(imgui.SmallButton("v")) then
                jobsettings_window.is_open = false;
            end
            imgui.Separator();
           
            local party = memoryManager:GetParty();
           
            for i=0,5 do
				local mainjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberMainJob(i));
				local subjob = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", party:GetMemberSubJob(i));
                local name = party:GetMemberName(i);

                if mainjob ~= nil and name ~= nil then --alter egos have no job
                
                    character_treenode.draw(config, name, mainjob, subjob);
                end
            end

            end
        imgui.End();
    end
end);