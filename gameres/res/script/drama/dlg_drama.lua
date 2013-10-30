--------------------------------------------------------------
-- FileName: 	dlg_drama.lua
-- author:		
-- purpose:		剧情界面
--------------------------------------------------------------

dlg_drama = {}
local p = dlg_drama;
local ui = ui_dlg_drama;

p.layer = nil;
p.storyId = nil;

p.contentNode = nil;
p.npcNameNode = nil;
p.bgPicNode   = nil;
p.npcPicNodeL = nil;
p.npcPicNodeM = nil;
p.npcPicNodeR = nil;

p.contentStr = nil;     --当前对话内容
p.contentStrLn = nil;   --当前对话内容长度
p.contentIndex = nil;   --当前说话的索引，用于特效
p.timerId = nil;        --定时器ID
p.isActivity = false;

local act_zoom = "engine_cmb.zoom_in_out"; --呼吸效果

--显示UI
function p.ShowUI( storyId )
    if storyId == nil then
    	return;
    else
       p.storyId = storyId;	
    end
	p.isActivity = true;
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		drama_mgr.LoadDramaInfo( storyId );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_drama.xui", layer, nil);
	
	p.layer = layer;
	p.Init();
	p.SetDelegate();
	drama_mgr.LoadDramaInfo( storyId );
end

--初始化控件
function p.Init()
    --p.AddMaskImage();
    p.contentNode = GetColorLabel( p.layer, ui.ID_CTRL_COLOR_LABEL_TEXT );
    p.npcNameNode = GetLabel( p.layer, ui.ID_CTRL_TEXT_NPC_NAME );
    p.bgPicNode = GetImage( p.layer,ui.ID_CTRL_PICTURE_BG );
    
    p.npcPicNodeL = GetImage( p.layer,ui.ID_CTRL_PICTURE_L );
    p.npcPicNodeM = GetImage( p.layer,ui.ID_CTRL_PICTURE_M );
    p.npcPicNodeR = GetImage( p.layer,ui.ID_CTRL_PICTURE_R );
    
    --local contentBg = GetImage( p.layer,ui.ID_CTRL_PICTURE_CONTENT_BG );
    --contentBg:SetPicture( GetPictureByAni("drama.content_bg", 0) );
end

--增加蒙版：未使用
function p.AddMaskImage()
	local maskNode = GetImage( p.layer,ui.ID_CTRL_PICTURE_MASK );
	maskNode:SetPicture( GetPictureByAni("drama.mask", 0) );
end

--设置事件
function p.SetDelegate()
    --下一个对话
    local btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_CLICK);
    btn:SetLuaDelegate(p.BtnOnclick);
    
    --跳过剧情
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_SKIP);
    btn:SetLuaDelegate(p.BtnOnclick);
    
    --下一个对话：全屏
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_BG);
    btn:SetLuaDelegate(p.BtnOnclick);
end

--事件处理
function p.BtnOnclick(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
    
        --下一个剧情对话
        if ( ui.ID_CTRL_BUTTON_CLICK == tag ) or (ui.ID_CTRL_BUTTON_BG == tag) then
            if p.timerId ~= nil then
            	KillTimer( p.timerId );
            	p.timerId = nil;
            end
            drama_mgr.NextDramaInfo();
            
        --跳过剧情    
        elseif ( ui.ID_CTRL_BUTTON_SKIP == tag ) then  
            if p.timerId ~= nil then
                KillTimer( p.timerId );
                p.timerId = nil;
            end
            p.isActivity = false;
            p.CloseUI();
            after_drama.DoAfterDrama();
        end
    end
end

--内容对话特效
function p.DoEffectContent()
    if p.contentNode == nil then
    	return ;
    end
	
	local strText = GetSubStringUtf8( p.contentStr, p.contentIndex );
	WriteCon(contentStr);
	p.contentNode:SetText(strText);
	p.contentIndex = p.contentIndex + 1;
	if p.contentIndex > p.contentStrLn and p.timerId ~= nil then
		KillTimer( p.timerId );
		p.timerId = nil;
	end
end

--更新场景：NPC以及对话内容等
function p.ResetUI( dramaInfo )
    p.AddSilentNpcEffect();
	local bgPic = GetPictureByAni( "drama.bg_"..dramaInfo.picBg, 0);
    p.bgPicNode:SetPicture( bgPic );
    
    p.npcNameNode:SetText( dramaInfo.npcName );
    
    --对话内容
    p.contentStr = dramaInfo.talkText;
    p.contentStrLn = GetCharCountUtf8 ( p.contentStr );
    p.contentIndex = 1;
    if p.contentStr ~= nil and p.contentStrLn > 1 then
    	p.timerId = SetTimer( p.DoEffectContent, 0.01f );
    end
    
    --NPC图片以特效更新：左边NPC
    if tonumber( dramaInfo.picLeft ) ~= nil and tonumber( dramaInfo.picLeft ) ~= 0 then
    	bgPic = GetPictureByAni( "drama.npc_"..dramaInfo.picLeft, 0);
    	p.npcPicNodeL:SetPicture( bgPic );
    	if tonumber( dramaInfo.npcIdTalk ) == tonumber( dramaInfo.picLeft ) then
			p.AddNpcEffect( p.npcPicNodeL );
    	end
    end
    
    --NPC图片以特效更新：中间NPC
    if tonumber( dramaInfo.picMid ) ~= nil and tonumber( dramaInfo.picMid ) ~= 0 then
        bgPic = GetPictureByAni( "drama.npc_"..dramaInfo.picMid, 0);
        p.npcPicNodeM:SetPicture( bgPic );
        if tonumber( dramaInfo.npcIdTalk ) == tonumber( dramaInfo.picMid ) then
			p.AddNpcEffect( p.npcPicNodeM );
        end
    end
    
     --NPC图片以特效更新：右边NPC
    if tonumber( dramaInfo.picRight ) ~= nil and tonumber( dramaInfo.picRight ) ~= 0 then
        bgPic = GetPictureByAni( "drama.npc_"..dramaInfo.picRight, 0);
        p.npcPicNodeR:SetPicture( bgPic );
        if tonumber( dramaInfo.npcIdTalk ) == tonumber( dramaInfo.picRight ) then
			p.AddNpcEffect( p.npcPicNodeR );
        end
    end
end

--添加Npc特效
function p.AddNpcEffect( npcNode )
    npcNode:SetScale(1.01f);
    npcNode:SetMaskColor(ccc4(255,255,255,255));
	
	if not npcNode:FindActionEffect( act_zoom ) then
		npcNode:AddActionEffect( act_zoom );
	end
end

--清除NPC的当前特效：即不是当前说话NPC的默认效果
function p.AddSilentNpcEffect()
    p.npcPicNodeL:SetMaskColor(ccc4(160,160,160,255));
	p.npcPicNodeM:SetMaskColor(ccc4(160,160,160,255));
	p.npcPicNodeR:SetMaskColor(ccc4(160,160,160,255));
	
	p.npcPicNodeL:DelActionEffect( act_zoom );
	p.npcPicNodeM:DelActionEffect( act_zoom );
	p.npcPicNodeR:DelActionEffect( act_zoom );
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
	    p.isActivity = false;
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
    	p.layer = nil;
    	p.storyId = nil;
    	
        p.contentNode = nil;
        p.npcNameNode = nil;
        p.bgPicNode   = nil;
        p.npcPicNodeL = nil;
        p.npcPicNodeM = nil;
        p.npcPicNodeR = nil;
        
        p.contentStr = nil;     
        p.contentStrLn = nil;   
        p.contentIndex = nil; 
        
        p.timerId = nil;
        p.isActivity = false;
    end
end

function p.IsActivity()
	return p.isActivity;
end

