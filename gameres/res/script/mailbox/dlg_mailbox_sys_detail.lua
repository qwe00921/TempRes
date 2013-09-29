--------------------------------------------------------------
-- FileName: 	dlg_mailbox_sys_detail.lua
-- author:		zjj, 2013/09/22
-- purpose:		查看系统邮件界面
--------------------------------------------------------------

dlg_mailbox_sys_detail = {}
local p = dlg_mailbox_sys_detail;

p.layer = nil;
local ui = ui_dlg_mailbox_sys_detail;
p.mail = nil;

local reward_type = {
    card    = 1;
    skill   = 2;
    item    = 3;
    gold    = 4;
    rmb     = 5;
    pt      = 6;
}
--显示UI
function p.ShowUI( mail )
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_mailbox_sys_detail.xui", layer, nil);
	
	if mail ~= nil then
	   p.mail = mail;
	end
	
	p.layer = layer;
	p.SetDelegate();
    p.ShowMail( p.mail );
end

--设置事件处理
function p.SetDelegate()
	--返回
	local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnSysMailDetailUIEvent);
    
    --删除
    local delBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_DELETE );
    delBtn:SetLuaDelegate(p.OnSysMailDetailUIEvent);
    
end

--邮件显示
function p.ShowMail( mail )
    --时间
	local timeLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_SYSMAIL_TIME );
	timeLab:SetText( tostring( mail.created_at ));
	
	--主题
	local titleLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_SYSMAIL_TITLE );
	titleLab:SetText( tostring( mail.title ));
	
	--内容
	local contentLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_SYSMAIL_CONTENT );
	contentLab:SetText( tostring( mail.text ));
	
	--附件
	local rewardsInfo = p.InitReward();
	
	for i = 1, #mail.rewards do
	   rewardsInfo[i].icon:SetVisible( true );
	   rewardsInfo[i].name:SetVisible( true );
	   p.GetAndSetRewardName( rewardsInfo[i] , mail.rewards[i] );
	end
end

function p.GetAndSetRewardName( controls , reward  )

    if tonumber( reward.reward_type) == reward_type.card then
        local name = SelectCell( T_CARD, reward.reward_id , "name" );
        controls.name:SetText( name );
        
    elseif tonumber( reward.reward_type) == reward_type.skill then
        local name = SelectCell( T_SKILL, reward.reward_id , "name" );
        controls.name:SetText( name );
        
    elseif tonumber( reward.reward_type) == reward_type.item then
        local name = SelectCell( T_ITEM, reward.reward_id , "name" );
        controls.name:SetText( name );
        
    elseif tonumber( reward.reward_type) == reward_type.gold then
        controls.name:SetText( GetStr( "gold" ));
        
    elseif tonumber( reward.reward_type) == reward_type.rmb then
        controls.name:SetText( GetStr( "rmb" ));
        
    elseif tonumber( reward.reward_type) == reward_type.pt then
        controls.name:SetText( GetStr( "pt" ));
        
    end
end

function p.InitReward()
	local t = {icon = nil;name = nil;}
	local rewards = {};
	t.icon = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM1 );
	t.name = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME1 );
	rewards[1] = t;
    local t = {icon = nil;name = nil;}
	t.icon = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM2 );
    t.name = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME2 );
    rewards[2] = t;
    local t = {icon = nil;name = nil;}
    t.icon = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM3 );
    t.name = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME3 );
    rewards[3] = t;
    local t = {icon = nil;name = nil;}
    t.icon = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM4 );
    t.name = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME4 );
    rewards[4] = t;
    local t = {icon = nil;name = nil;}
    t.icon = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM5 );
    t.name = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME5 );
    rewards[5] = t;
    local t = {icon = nil;name = nil;}
    t.icon = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM6 );
    t.name = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME6 );
    rewards[6] = t;
    
    for i=1, 6 do
        rewards[i].icon:SetVisible( false );
        rewards[i].name:SetVisible( false );
    end
	return rewards;
end

--事件处理
function p.OnSysMailDetailUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
			
	    elseif ( ui.ID_CTRL_BUTTON_DELETE == tag ) then  
	        mailbox_mgr.ReqDelMial( p.mail.id );
	       
		end					
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()	
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
        p.mail = nil;
    end
end