--------------------------------------------------------------
-- FileName: 	friend_mgr.lua
-- author:		zjj, 2013/08/23
-- purpose:		好友管理器
--------------------------------------------------------------

friend_mgr = {}
local p = friend_mgr;

DELETE_FRIEND = 1;
ACCEPT_FRIEND = 2;
REFUSE_FRIEND = 3;
APPLY_FRIEND  = 4;

--申请成功好友id存放
p.aleadyApplyId = {};

--发送好友列表信息请求
function p.ReqFriendList()
    WriteCon("**请求好友列表数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetUserFriends",uid,"");
end

--发送好友申请列表信息请求
function p.ReqFriendApplyList()
    WriteCon("**请求好友申请列表数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetConfirmUsers",uid,"");
end

--发送好友推荐列表信息请求
function p.ReqFriendRecommendList()
    WriteCon("**请求好友推荐列表数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetRecommendUser",uid,"");
end

--好友列表信息回调
function p.ShowFriendListUI( frienddata )
	dlg_friend.ShowFriendUI( frienddata );
end

--好友申请列表信息回调
function p.ShowFriendApplyUI( applydata )
    dlg_friend.ShowFriendApplyUI( applydata );
end

--好友推荐列表信息回调
function p.ShowFriendRecommendUI( recommendata )
	dlg_friend.ShowRecommendUI( recommendata )
end

--好友功能请求
function p.FriendAction( friendid , actionid )
	WriteCon("**好友功能**" );
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local param = "&friend_id=" .. friendid .. "&action_id=" .. actionid;
    WriteCon( "param=" .. param );
    SendReq("Friend","OperateFriend",uid, param);
end

--

--好友功能回调
function p.FriendActionCallback( resultdata )

    if tonumber(resultdata.result) == 0 then
         WriteCon( "操作失败-----" .. resultdata.action );
         return;
    end
    --修改好友数
    dlg_friend.friendsNum = resultdata.friends_num;
    
	if tonumber( resultdata.action ) == DELETE_FRIEND then --删除
	   p.ReLoadFriendListForDel( resultdata.friend_id , resultdata.friends_num );
	   
	elseif tonumber( resultdata.action ) == REFUSE_FRIEND then --拒绝
       p.ReLoadApplyList( resultdata.friend_id );
       
	elseif tonumber( resultdata.action ) == ACCEPT_FRIEND then --接受
	   p.ReLoadApplyList( resultdata.friend_id );
	   
	elseif tonumber( resultdata.action ) == APPLY_FRIEND then --申请
       p.ReLoadRecommendList( resultdata.friend_id);
       
	end
end

--重载推荐好友列表
function p.ReLoadRecommendList(friend_id)
    p.aleadyApplyId[ #p.aleadyApplyId + 1] = friend_id;
    dlg_friend.ReloadRecommendUI();
end

--重载申请好友列表
function p.ReLoadApplyList( friend_id )
    --将已接受申请好友从申请列表移除
	p.DelFriendData( friend_id ,dlg_friend.applydata.confirms );
	dlg_friend.ReloadApplyUI();
end

--删除好友重载好友列表
function p.ReLoadFriendListForDel( delFriendid , friends_num)
    --将删除好友从好友列表中移除
	p.DelFriendData( delFriendid , dlg_friend.frienddata.friends); 
	
	dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "已经删除好友" ), p.OnCallback, p.layer );
	dlg_friend.ReloadFriendUI();
end

--删除指定好友信息
function  p.DelFriendData( delFriendid ,list )
    if delFriendid == nil then
       return;
    end
    for k, v in ipairs (list) do
        if tonumber(v.UserId) == tonumber( delFriendid ) then
            table.remove( list , k );
            break;
        end
    end
end

function p.OnCallback( result )
    
end
