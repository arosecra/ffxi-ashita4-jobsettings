
addon.name      = 'jobsettings';
addon.author    = 'arosecra';
addon.version   = '1.0';
addon.desc      = '';
addon.link      = '';

local imgui = require('imgui');
require('common');

local libs2config = require('org_github_arosecra/config');
local libs2imgui = require('org_github_arosecra/imgui');
local jobs = require('org_github_arosecra/jobs');
local macros_configuration = require('org_github_arosecra/macros/macros_configuration');

local setting = require('setting');
local character_treenode = require('character_treenode');

local jobsettings_window = {
    is_open                 = { false }
};

local runtime_config = {

};

ashita.events.register('load', 'jobsettings_load_cb', function ()
    print("[jobsettings] 'load' event was called.");
	AshitaCore:GetConfigurationManager():Load(addon.name, 'jobsettings\\jobsettings.ini');
    macros_configuration.load();
end);

ashita.events.register('command', 'jobsettings_command_cb', function (e)
    if (not e.command:startswith('/jobsettings') and not e.command:startswith('/js')) then
		return;
    end
    jobsettings_window.is_open = not jobsettings_window.is_open;
    e.blocked = true;
end);

ashita.events.register('d3d_beginscene', 'jobsettings_beginscene_callback1', function (isRenderingBackBuffer)
	local memoryManager = AshitaCore:GetMemoryManager();
	local party = memoryManager:GetParty();
	
	for i=0,5 do
		local mainjob = jobs[party:GetMemberMainJob(i)];
		local subjob = jobs[party:GetMemberSubJob(i)];
		local name = party:GetMemberName(i);
        if mainjob ~= nil then
            setting.default_settings_for_char(runtime_config, name, mainjob, subjob);
        end
	end
end);


ashita.events.register('d3d_present', 'jobsettings_present_cb', function ()
	
	local playerEntity = GetPlayerEntity();
	if playerEntity == nil then
		return;
	end
	
	local windowStyleFlags = libs2imgui.gui_style_table_to_var("imguistyle", "left_drawer", "window.style");
	libs2imgui.set_left_drawer_window(addon.name);
    if jobsettings_window.is_open then
        if imgui.Begin(addon.name, jobsettings_window.is_open, windowStyleFlags) then
            imgui.SetCursorPosX(450);
            if(imgui.SmallButton("v")) then
                jobsettings_window.is_open = false;
            end
            imgui.Separator();
           
            local memoryManager = AshitaCore:GetMemoryManager();
            local party = memoryManager:GetParty();
           
            for i=0,5 do
                local mainjob = jobs[party:GetMemberMainJob(i)];
                local subjob = jobs[party:GetMemberSubJob(i)];
                local name = party:GetMemberName(i);

                if mainjob ~= nil then --alter egos have no job
                
                    character_treenode.draw(runtime_config, name, mainjob, subjob);
                end
            end

            end
        imgui.End();
    end
end);