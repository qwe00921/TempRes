--------------------------------------------------------------
-- FileName: 	mailbox_mgr.lua
-- author:		zjj, 2013/09/16
-- purpose:		�ʼ���Ϣ������
--------------------------------------------------------------

mailbox_mgr = {}
local p = mailbox_mgr;

--�����ʼ���Ϣ
p.sysMail = nil;
p.prsMail = nil;
p.service = nil;

--���������ʼ���Ϣ 
function p.LoadAllMail( )
	--WriteCon("**�����ʼ�����**");
	local uid = GetUID();
	if uid == 0 or uid == nil then return end;
	--��������
	SendReq("Mail", "GetMailsInfo" , uid , "");
end

--ɾ���ʼ� 
function p.ReqDelMial( ids )
    --WriteCon("**ɾ���ʼ�**");
    local uid = GetUID();
    if uid == 0 or uid == nil then return end;
    local param = "&user_mail_ids=" .. ids;
    WriteCon( "param=" .. param );
    --��������
    SendReq("Mail", "Delete" , uid , param);
end

--��ȡ��һ�ʼ�����
function p.ReqGetOneMail( user_mail_id )
	--WriteCon("**��ȡ��һ�ʼ�����**");
    local uid = GetUID();
    if uid == 0 or uid == nil then return end;
    local param = "&user_mail_id=" .. user_mail_id;
    --��������
    SendReq("Mail", "GetMailInfo" , uid , param);
end

--�����ʼ�
function p.ReqSendMail( receive_id , title, content ,user_mail_group_id)
    --WriteCon("**��ȡ��һ�ʼ�����**");
    local uid = GetUID();
    if uid == 0 or uid == nil then return end;
    user_mail_group_id =  user_mail_group_id or 0;
    local param = "&receive_id="..receive_id.."&user_mail_group_id="..user_mail_group_id.."&title="..title.."&text="..content;
    WriteCon( "send param---------" .. param );
    --��������
    SendReq("Mail", "Send" , uid , param);
end

--����ɾ������ʼ�����
function p.RefreshForDel( deldata )
   for i=1, #deldata do
        local delid = deldata[i].id
        for k, v in ipairs( p.sysMail ) do
            if tonumber( v.id ) == delid then
                table.remove( p.sysMail , k);
                break ;
            end
        end
        for k, v in ipairs( p.prsMail ) do
            if tonumber( v.id ) == delid then
                table.remove( p.prsMail , k);
                break ;
            end
        end
   end
   dlg_mailbox_sys_detail.CloseUI();
   dlg_mailbox_person_detail.CloseUI();
   dlg_mailbox_mainui.ReloadUI();
   
end

--�����ʼ��ص�
function p.SendSuccess()
    tip.ShowTip( GetStr( "send_mail_success" ));	
    dlg_mailbox_kf.CloseUI();
end

--�ɾ�����ص�������ɾ�
function p.SaveData( mailData )
	if mailData == nil then
		WriteCon(" no sys mail");
		return
	end
	
    p.sysMail = mailData.system;
    p.prsMail = mailData.player;
    
    --Ĭ����ʾϵͳ�ʼ�
    dlg_mailbox_mainui.ShowSysMail( p.sysMail );
end
