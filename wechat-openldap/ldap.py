#!/usr/bin/env python
# -*- coding: utf-8 -*-

from ldap3 import Server, Connection, ALL, SUBTREE, ALL_ATTRIBUTES
import random

class OpenLdap(object):
    #初始化ldap信息
    def __init__(self):
        self._ip = '172.31.57.1'
        self._port = 389
        self._user = 'cn=manager,dc=***,dc=cn'
        self._passwd = '***'
        self.user_ou = 'ou=员工'
        self.group_ou = 'ou=部门'
        self.dn = 'dc=***,dc=cn'
        self.s = Server(self._ip, self._port, get_info=ALL)
        self._conn = Connection(self.s, self._user, self._passwd, auto_bind=True)

    @property
    def conn(self):
        if not self._conn:
            print('ldap conn init ')
            self._conn = Connection(self.s, self._user, self._passwd, auto_bind=True)
        return self._conn

    def search_user_all(self):
        #查询ldap用户的所有属性信息
        l = self.conn
        entry_list = l.extend.standard.paged_search(search_base='%s,%s' %(self.user_ou,self.dn),
                                                    search_filter='(objectClass=inetOrgPerson)',
                                                    search_scope=SUBTREE,
                                                    attributes=ALL_ATTRIBUTES,
                                                    paged_size=5,
                                                    generator=False)
        #print(entry_list)
        return entry_list

    def search_group_all(self):
        #查询ldap用户组的所有属性信息
        l = self.conn
        entry_list = l.extend.standard.paged_search(search_base='%s,%s' %(self.group_ou,self.dn),
                                                    search_filter='(objectClass=posixGroup)',
                                                    search_scope=SUBTREE,
                                                    attributes=ALL_ATTRIBUTES,
                                                    paged_size=5,
                                                    generator=False)
        #print(entry_list)
        return entry_list

    def get_ldap_gid(self):
        # 获取ldap用户组的id
        ldap_all = self.search_group_all()
        ldap_departments = []
        for info in ldap_all:
            for key, value in info.items():
                if key == 'attributes':
                    for k_gid, v_gid in value.items():
                        if k_gid == 'gidNumber':
                            user = []
                            user.append(v_gid)
                            ldap_departments.append(user)
        return ldap_departments
        #print(ldap_departments)

    def get_ldap_uid(self):
        # 获取ldap用户uid
        ldap_all = self.search_user_all()
        ldap_users = []
        for info in ldap_all:
            for key, value in info.items():
                if key == 'attributes':
                    for k_uid, v_uid in value.items():
                        if k_uid == 'uid':
                            # 列表转字符串
                            y = "".join(v_uid)
                            user = []
                            user.append(y)
                            ldap_users.append(user)
        return ldap_users
        # print(ldap_users)

    def ldap_add_user(self, userid, username, mobile, mail, title, gidnumber):
        # 增加用户
        l = self.conn
        add_dn = "cn=%s,%s,%s" %(userid,self.user_ou,self.dn)
        objectclass = ['top', 'person', 'inetOrgPerson', 'posixAccount']
        uid_number = random.randint(100, 1000)
        l.add(add_dn,objectclass, {'mobile': mobile,
                                   'sn': username,
                                   'mail': mail,
                                   'userPassword': '%s@123' %userid,
                                   'title': title,
                                   'uid': userid,
                                   'gidNumber': gidnumber,
                                   'uidNumber': '%s' % uid_number,
                                   'homeDirectory': '/home/users/%s' % userid,
                                   'loginShell': '/bin/bash'
                                   })
        return 'true'

    def ldap_add_group(self, gidnumber, groupname):
        # 增加用户组
        l = self.conn
        add_dn = "cn=%s,%s,%s" %(groupname,self.group_ou,self.dn)
        objectclass = ['top', 'posixGroup']
        l.add(add_dn, objectclass, {'gidNumber': gidnumber})

    def ldap_del_user(self, userid):
        # 删除用户
        add_dn = "cn=%s,%s,%s" % (userid, self.user_ou, self.dn)
        l = self.conn
        l.delete(add_dn)

    def ldap_del_gurop(self, groupname):
        # 删除用户组
        add_dn = "cn=%s,%s,%s" % (groupname, self.group_ou, self.dn)
        l = self.conn
        l.delete(add_dn)


if __name__ == "__main__":
    ldap = OpenLdap()
    ldap.get_ldap_gid()
    #ldap.ldap_add_user('test3','测试3')
    #ldap.ldap_add_group('110', '部门测试6')
    #ldap.ldap_del_user('test 1')
    #ldap.ldap_del_gurop('部门测试6')
    #ldap.ldap_get_user()
