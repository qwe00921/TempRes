
dlg_drama_new = {}
local p = dlg_drama_new;
local ui = ui_dlg_drama_new

--[[
p.ID_CTRL_BUTTON_20					      = 20;
p.ID_CTRL_BUTTON_19					      = 19;
p.ID_CTRL_TEXT_18						       = 18;
p.ID_CTRL_COLOR_LABEL_17				  = 17;
p.ID_CTRL_PICTURE_ROLE_2				  = 3;
p.ID_CTRL_PICTURE_ROLE_1				  = 2;
p.ID_CTRL_PICTURE_BACKGROUND			= 1;
]]

p.layer = nil;
p.stepover = 0;
p.name = nil;
p.text = nil;
p.obj1 = nil;
p.obj2 = nil;


--显示UI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_drama_new.xui", layer, nil);
	
	p.layer = layer;
	p.Init();
	p.SetDelegate();
	p.ShowText();
end

--初始化控件
function p.Init()
	p.name = GetLabel(p.layer, ui.ID_CTRL_TEXT_18);
	p.text = GetLabel(p.layer, ui.ID_CTRL_TEXT_8);
	p.obj1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_ROLE_1);
	p.obj2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_ROLE_2);
end

--设置事件
function p.SetDelegate()
	local nextBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_19);
	nextBtn:SetLuaDelegate(p.OnBtnClick);
	
	local endBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_20);
	endBtn:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_19 == tag then
			p.ShowText();
		elseif ui.ID_CTRL_BUTTON_20 == tag then
			WriteCon("**====跳过====**");
			p.CloseUI();
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false )
	end
end

function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		--p.adList = nil;
		p.stepover = 0;
    end
end

function p.ShowText()
	p.stepover = p.stepover + 1;
	if p.stepover > 5 then
		WriteCon("**====结束====**");
		p.CloseUI();
		return;
	end
	if p.stepover == 5 then
		p.text:SetText(GetStr("drama_user_text5"));
	else
		p.text:SetText(GetStr("drama_user_text".. p.stepover));
	end
	p.name:SetText(GetStr("drama_user_name_".. math.mod(p.stepover, 2)+1));
	
	p.obj1:SetVisible(math.mod(p.stepover, 2)+1 == 1);
	p.obj2:SetVisible(math.mod(p.stepover, 2)+1 == 2);
end


