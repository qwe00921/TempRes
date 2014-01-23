
--新手引导

rookie_main = {};
local p = rookie_main;

p.userData = nil;

function p.getRookieStep(backData)
	if backData.result == false then
		dlg_msgbox.ShowOK("错误提示",backData.message,nil,p.layer);
		return;
	elseif backData.result == true then
		local stepId = tonumber(backData.user.Guide_id)
		p.userData = backData.user;
		if stepId == 0 then
			maininterface.ShowUI(backData.user);
		else
			p.ShowLearningStep( stepId )
		end
	end
end


--进入新手引导
function p.ShowLearningStep( step )
	WriteConErr("rookie step == "..step);

	if step == 1 then
		maininterface.ShowUI(p.userData);
	elseif step == 2 then
		maininterface.ShowUI(p.userData);
	elseif step == 3 then
		maininterface.ShowUI(p.userData);
	elseif step == 4 then
		maininterface.ShowUI(p.userData);
	elseif step == 5 then
		maininterface.ShowUI(p.userData);
	elseif step == 6 then
		maininterface.ShowUI(p.userData);
	elseif step == 7 then
		maininterface.ShowUI(p.userData);
	elseif step == 8 then
		maininterface.ShowUI(p.userData);
	elseif step == 9 then
		maininterface.ShowUI(p.userData);
	elseif step == 10 then
		maininterface.ShowUI(p.userData);
	elseif step == 11 then
		maininterface.ShowUI(p.userData);
	elseif step == 12 then
		maininterface.ShowUI(p.userData);
	elseif step == 13 then
		maininterface.ShowUI(p.userData);
	elseif step == 14 then
		maininterface.ShowUI(p.userData);
	end
end

--点击高亮区域回调
function p.MaskTouchCallBack( step )
	if step == 1 then
		
	elseif step == 2 then
		
	elseif step == 3 then
		
	elseif step == 4 then
		
	elseif step == 5 then
		
	elseif step == 6 then
		
	elseif step == 7 then
		
	elseif step == 8 then
		
	elseif step == 9 then
		
	elseif step == 10 then
		
	elseif step == 11 then
		
	elseif step == 12 then
		
	elseif step == 13 then
		
	elseif step == 14 then
		
	end
end

--获取高亮区域
function p.GetHighLightRect( step )
	return CCRectMake( 0, 0, 0, 0 );
end
