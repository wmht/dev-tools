#!/usr/bin/env python
# -*- coding:utf-8 -*-

import requests
import json


class WeChat(object):
    #初始化企业微信信息
    def __init__(self):
        self.corpid = '************'      #企业ID
        self.secrete = '*************'    #通讯录secrete
        self.department_id = '1'
        self.fetch_child = '1'

    @property
    def get_token(self):
        #获取token
        url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=%s&corpsecret=%s" % (self.corpid, self.secrete)
        resp = requests.get(url)
        data = json.loads(resp.text)
        if data['errcode'] == 0:
            return data['access_token']
        else:
            print("获取 token 失败")

    def get_department_info(self):
        #获取部门信息
        url = 'https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=%s&id=' % self.get_token
        resp = requests.get(url)
        data = json.loads(resp.text)
        if data['errcode'] == 0:
            return data['department']
        else:
            print("获取部门列表失败")

    def get_wechat_gid(self):
        #获取企业微信部门id
        wechat_all = self.get_department_info()
        #print(wechat_all)
        wechat_gids = []
        for info in wechat_all:
            for k_userid, v_userid in info.items():
                if k_userid == 'id':
                    gid = []
                    gid.append(v_userid)
                    wechat_gids.append(gid)
        return wechat_gids
        #print(wechat_gids)

    def get_department_list(self):
        #获取部门主要属性并存为字典
        department_list = self.get_department_info()
        return [{
            'name': info.get('name', ''),
            'id': info.get('id', ''),
        } for info in department_list]


    def get_user_info(self):
        #获取用户信息
        url = 'https://qyapi.weixin.qq.com/cgi-bin/user/list?access_token=%s&department_id=%s&fetch_child=%s' % (self.get_token, self.department_id, self.fetch_child)
        resp = requests.get(url)
        data = json.loads(resp.text)
        if data['errcode'] == 0:
            return data['userlist']
        else:
            print("获取用户列表失败")

    def get_wechat_userid(self):
        #获取企业微信用户id
        wechat_all = self.get_user_info()
        wechat_userids = []
        for info in wechat_all:
            for k_userid, v_userid in info.items():
                if k_userid == 'userid':
                    y = v_userid.lower()
                    userid = []
                    userid.append(y)
                    wechat_userids.append(userid)
        return wechat_userids
        #print(wechat_userids)

    def get_user_list(self):
        #获取用户主要属性并存为字典
        user_list = self.get_user_info()
        return [{
                'name': info.get('name', ''),
                'userid': info.get('userid', '').lower(),
                'department': info.get('department', [0])[0],
                'mobile': info.get('mobile', ''),
                'position': info.get('position', ''),
                'email': info.get('email', ''),
            } for info in user_list]


if __name__ == "__main__":
    wx = WeChat()
    res= wx.get_wechat_gid()
    #res_user_info = wx.get_user_info()

    # aa = wx.get_user_list()
    # for a in aa:
    #     print(a)

    # bb = wx.get_department_list()
    # for b in bb:
    #     print(b)
    #print(res_user_list)
    print(res)
