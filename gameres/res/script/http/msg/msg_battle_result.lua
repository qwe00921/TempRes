

msg_battle_result = msg_base:new();
local p = msg_battle_result;
local super = msg_base;

--创新实例
function p:new()
	o = {}
	setmetatable( o, self );
    self.__index = self;
    o:ctor();	
	return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
	self.idMsg = MSG_BATTLE_RESULT;

end

function p:Init()
end

function p:Process()
	--if self.result == true then 
		--w_battle_mgr.QuitBattle();
		--local lResult = w_battle_mgr.GetReuslt();
		--if lResult == 1 then
		if w_battle_mgr.isbattlequit ~= true then  --中途退出标识
			quest_result.ShowUI(self);
		else
			w_battle_mgr.isbattlequit = false;
		end;


		if (w_battle_guid.IsGuid == true) and (w_battle_guid.guidstep == 3) then
			rookie_mask.ShowUI(3, 14)
		elseif (rookie_main.stepId == 8) then
			rookie_main.ShowLearningStep( 8, 2 );
		end; 
		--	dlg_userinfo.ShowUI();
		--	stageMap_main.OpenWorldMap();
		--end;
	
	--else
		--dlg_msgbox.ShowOK("错误提示",self.message,nil,p.layer);
	--	WriteConWarning( "**MSG_BATTLE_RESULT  error" );
	--end
end
