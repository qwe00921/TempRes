--------------------------------------------------------------
-- FileName: 	mailbox_mgr.lua
-- author:		zjj, 2013/09/16
-- purpose:		邮件信息管理器
--------------------------------------------------------------

mailbox_mgr = {}
local p = mailbox_mgr;

--保存邮件信息
p.sysMail = nil;
p.prsMail = nil;
p.service = nil;

--加载所有邮件信息 
function p.LoadAllMail( )
	--WriteCon("**请求邮件数据**");
	local uid = GetUID();
	if uid == 0 or uid == nil then return end;
	--发起请求
	SendReq("Mail", "GetMailsInfo" , uid , "");
end

--删除邮件 
function p.ReqDelMial( ids )
    --WriteCon("**删除邮件**");
    local uid = GetUID();
    if uid == 0 or uid == nil then return end;
    local param = "&user_mail_ids=" .. ids;
    WriteCon( "param=" .. param );
    --发起请求
    SendReq("Mail", "Delete" , uid , param);
end

--获取单一邮件内容
function p.ReqGetOneMail( user_mail_id )
	--WriteCon("**获取单一邮件内容**");
    local uid = GetUID();
    if uid == 0 or uid == nil then return end;
    local param = "&user_mail_id=" .. user_mail_id;
    --发起请求
    SendReq("Mail", "GetMailInfo" , uid , param);
end

--发送邮件
function p.ReqSendMail( receive_id , title, content ,user_mail_group_id)
    --WriteCon("**获取单一邮件内容**");
    local uid = GetUID();
    if uid == 0 or uid == nil then return end;
    user_mail_group_id =  user_mail_group_id or 0;
    local param = "&receive_id="..receive_id.."&user_mail_group_id="..user_mail_group_id.."&title="..title.."&text="..content;
    WriteCon( "send param---------" .. param );
    --发起请求
    SendReq("Mail", "Send" , uid , param);
end

--更新删除后的邮件数据
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

--发送邮件回调
function p.SendSuccess()
    tip.ShowTip( GetStr( "send_mail_success" ));	
    dlg_mailbox_kf.CloseUI();
end

--成就请求回调，分类成就
function p.SaveData( mailData )
	if mailData == nil then
		WriteCon(" no sys mail");
		return
	end
	
    p.sysMail = mailData.system;
    p.prsMail = mailData.player;
    
    --默认显示系统邮件
    dlg_mailbox_mainui.ShowSysMail( p.sysMail );
end
