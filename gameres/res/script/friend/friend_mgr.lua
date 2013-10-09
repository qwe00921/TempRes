--------------------------------------------------------------
-- FileName: 	friend_mgr.lua
-- author:		zjj, 2013/08/23
-- purpose:		���ѹ�����
--------------------------------------------------------------

friend_mgr = {}
local p = friend_mgr;

DELETE_FRIEND = 1;
ACCEPT_FRIEND = 2;
REFUSE_FRIEND = 3;
APPLY_FRIEND  = 4;

--����ɹ�����id���
p.aleadyApplyId = {};

--���ͺ����б���Ϣ����
function p.ReqFriendList()
    WriteCon("**��������б�����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetUserFriends",uid,"");
end

--���ͺ��������б���Ϣ����
function p.ReqFriendApplyList()
    WriteCon("**������������б�����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetConfirmUsers",uid,"");
end

--���ͺ����Ƽ��б���Ϣ����
function p.ReqFriendRecommendList()
    WriteCon("**��������Ƽ��б�����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetRecommendUser",uid,"");
end

--�����б���Ϣ�ص�
function p.ShowFriendListUI( frienddata )
	dlg_friend.ShowFriendUI( frienddata );
end

--���������б���Ϣ�ص�
function p.ShowFriendApplyUI( applydata )
    dlg_friend.ShowFriendApplyUI( applydata );
end

--�����Ƽ��б���Ϣ�ص�
function p.ShowFriendRecommendUI( recommendata )
	dlg_friend.ShowRecommendUI( recommendata )
end

--���ѹ�������
function p.FriendAction( friendid , actionid )
	WriteCon("**���ѹ���**" );
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local param = "&friend_id=" .. friendid .. "&action_id=" .. actionid;
    WriteCon( "param=" .. param );
    SendReq("Friend","OperateFriend",uid, param);
end

--

--���ѹ��ܻص�
function p.FriendActionCallback( resultdata )

    if tonumber(resultdata.result) == 0 then
         WriteCon( "����ʧ��-----" .. resultdata.action );
         return;
    end
    --�޸ĺ�����
    dlg_friend.friendsNum = resultdata.friends_num;
    
	if tonumber( resultdata.action ) == DELETE_FRIEND then --ɾ��
	   p.ReLoadFriendListForDel( resultdata.friend_id , resultdata.friends_num );
	   
	elseif tonumber( resultdata.action ) == REFUSE_FRIEND then --�ܾ�
       p.ReLoadApplyList( resultdata.friend_id );
       
	elseif tonumber( resultdata.action ) == ACCEPT_FRIEND then --����
	   p.ReLoadApplyList( resultdata.friend_id );
	   
	elseif tonumber( resultdata.action ) == APPLY_FRIEND then --����
       p.ReLoadRecommendList( resultdata.friend_id);
       
	end
end

--�����Ƽ������б�
function p.ReLoadRecommendList(friend_id)
    p.aleadyApplyId[ #p.aleadyApplyId + 1] = friend_id;
    dlg_friend.ReloadRecommendUI();
end

--������������б�
function p.ReLoadApplyList( friend_id )
    --���ѽ���������Ѵ������б��Ƴ�
	p.DelFriendData( friend_id ,dlg_friend.applydata.confirms );
	dlg_friend.ReloadApplyUI();
end

--ɾ���������غ����б�
function p.ReLoadFriendListForDel( delFriendid , friends_num)
    --��ɾ�����ѴӺ����б����Ƴ�
	p.DelFriendData( delFriendid , dlg_friend.frienddata.friends); 
	
	dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), ToUtf8( "�Ѿ�ɾ������" ), p.OnCallback, p.layer );
	dlg_friend.ReloadFriendUI();
end

--ɾ��ָ��������Ϣ
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
