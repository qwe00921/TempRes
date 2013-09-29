--------------------------------------------------------------
-- FileName:    dlg_achievement.lua
-- author:      zjj, 2013/09/13
-- purpose:     成就界面
--------------------------------------------------------------

dlg_achievement = {}
local p = dlg_achievement;
p.layer = nil;
p.selectedAchievement = nil;

--显示UI
function p.ShowUI()
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
    layer:Init();   
    GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_achievement.xui", layer, nil);
    
    p.layer = layer;
    p.SetDelegate(layer);
    p.ShowAchievementList();
    p.SetCornerNum(1, 2,  3, 4);
end

function p.ShowAchievementList()
    local achievementList = GetListBoxVert( p.layer, ui_dlg_achievement.ID_CTRL_VERTICAL_LIST_ACHIEVEMENT);	
     for i=1 ,5 do
       local view = createNDUIXView();
       view:Init();
       LoadUI("achievement_view.xui", view, nil);
       local bg = GetUiNode(view,ui_achievement_view.ID_CTRL_PICTURE_BG);
       view:SetViewSize( bg:GetFrameSize());
       
       local getRewardBtn = GetButton( view , ui_achievement_view.ID_CTRL_BUTTON_GET_REWARD );
       getRewardBtn:SetLuaDelegate(p.OnAchivementUIEvent);
       
       achievementList:AddView( view );
     end
end

--设置事件处理
function p.SetDelegate(layer)
    --确定
    local backBtn = GetButton(layer,ui_dlg_achievement.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnAchivementUIEvent);
end

--设置角标数字 
function p.SetCornerNum(playNum, petNum,  missionNum, elseNum)
	
	local playerNumPic = GetImage( p.layer,ui_dlg_achievement.ID_CTRL_PICTURE_PLAYER_NUM );
	playerNumPic:SetPicture( GetPictureByAni("ui.achievement_corner_num", playNum - 1) );
	playerNumPic:AddActionEffect("ui_cmb.common_scale");
	
	local petNumPic = GetImage( p.layer,ui_dlg_achievement.ID_CTRL_PICTURE_PET_NUM );
    petNumPic:SetPicture( GetPictureByAni("ui.achievement_corner_num", petNum - 1) );
    petNumPic:AddActionEffect("ui_cmb.common_scale");
    
    local missionNumPic = GetImage( p.layer,ui_dlg_achievement.ID_CTRL_PICTURE_MISSION_NUM );
    missionNumPic:SetPicture( GetPictureByAni("ui.achievement_corner_num", missionNum - 1) );
    missionNumPic:AddActionEffect("ui_cmb.common_scale");
    
    local elseNumPic = GetImage( p.layer,ui_dlg_achievement.ID_CTRL_PICTURE_ELSE_NUM );
    elseNumPic:SetPicture( GetPictureByAni("ui.achievement_corner_num", elseNum - 1) );
    elseNumPic:AddActionEffect("ui_cmb.common_scale");

end
--事件处理
function p.OnAchivementUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_achievement.ID_CTRL_BUTTON_BACK == tag ) then   
            p.CloseUI();
            
        elseif (ui_achievement_view.ID_CTRL_BUTTON_GET_REWARD  == tag ) then
             p.selectedAchievement = uiNode:GetParent();
             dlg_msgbox.ShowOK( GetStr( "msg_title_tips" ), GetStr( "get_achievement_reward_success" ), p.OnMsgBoxCallback, p.layer );
        
        end                 
    end
end


function p.OnMsgBoxCallback(result)
     local achievementList = GetListBoxVert( p.layer, ui_dlg_achievement.ID_CTRL_VERTICAL_LIST_ACHIEVEMENT);    
     achievementList:RemoveView( p.selectedAchievement );
     p.selectedAchievement = nil;
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
    end
end