#!/usr/bin/env python
# -*- coding: utf-8 -*-

from wechat import WeChat
from ldap import OpenLdap
from mail import Email

class Main:
    def __init__(self):
        self.wechat = WeChat()
        self.openldap = OpenLdap()
        self.e_mail = Email()

    def get_wechat_uid_info(self, uid):
        #根据uid获取企业微信中该用户的属性值
        wechat_user_list = self.wechat.get_user_list()
        for info in wechat_user_list:
            for k_info, v_info in info.items():
                if k_info == 'userid':
                    v = v_info.lower()
                    if v == uid:
                        return info

    def get_wechat_gid_info(self, gid):
        #跟据部门id获取企业微信中该部门的属性值
        wechat_department_list = self.wechat.get_department_list()
        for info in wechat_department_list:
            for k_info, v_info in info.items():
                if k_info == 'id':
                    if v_info == gid:
                        return info

    def get_wechat_ugid(self, uid):
        #根据uid获取企业微信的部门id,用于排除添加某部门用户
        wechat_user_list = self.wechat.get_user_list()
        for info in wechat_user_list:
            for k_info, v_info in info.items():
                if k_info == 'userid':
                    v = v_info.lower()
                    if v == uid:
                        dep_id = info.get('department')
                        return dep_id

    def add_user(self):
        ldap_uid = self.openldap.get_ldap_uid()
        ldap_gid = self.openldap.get_ldap_gid()
        wechat_uid = self.wechat.get_wechat_userid()
        wechat_gid = self.wechat.get_wechat_gid()

        #添加用户组
        for w_gid in wechat_gid:
            #判断微信部门是否已经存在ldap组中
            if w_gid not in ldap_gid:
                #列表[id]转成字符串id
                gid = [str(x) for x in w_gid]
                gid_new = "".join(gid)
                wechat_gid_info = self.get_wechat_gid_info(int(gid_new))
                print(wechat_gid_info)
                # 不存在则向ldap添加部门信息
                def f(id, name):
                    return self.openldap.ldap_add_group(id, name)
                f(**wechat_gid_info)

        #添加用户
        for w_uid in wechat_uid:
            # 判断微信账号是否已经存在ldap中
            if w_uid not in ldap_uid:
                # 不存在则向ldap添加账号信息
                # 列表[uid]转成字符串'uid'
                uid = "".join(w_uid)
                #判断用户是否属于排除添加的部门:合作伙伴(:40)
                exclude = [40]
                wechat_dep_id = self.get_wechat_ugid(uid)
                if wechat_dep_id not in exclude:
                    #添加用户
                    wechat_uid_info = self.get_wechat_uid_info(uid)
                    def f(userid, name, mobile, email, position, department):
                        print('开始添加ldap用户:%s' % userid)
                        if self.openldap.ldap_add_user(userid, name, mobile, email, position, department):
                            print('开始发送邮件')
                            self.e_mail.send_mail(email, userid, name)
                    f(**wechat_uid_info)


if __name__ == "__main__":
    r = Main()
    r.add_user()
    #r.get_wechat_one_info('MeiCuiCui')
    #r.get_wechat_gid_info(40)
