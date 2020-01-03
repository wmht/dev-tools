# !/usr/bin/python
# -*- coding: utf-8 -*-

import smtplib
from email.mime.text import MIMEText
from email.header import Header


class Email:
    def __init__(self):
        self.sender = 'lisi@***.cn'
        self.mail_url = 'smtp.***.cn'
        self.mail_port = 465
        self.sender_username = 'lisi@***.cn'
        self.sender_password = '********'

    def send_mail(self, email, username, sn):
        receiver = [email]
        mail_msg = """
        <p>LDAP账号可用于登入 Gitlab、rancher、jenkins、aliyun-vpn 等平台</p>
        <p>账号：%s</p>
        <p>密码：%s@123</p>
        <p>您可以访问后面的链接修改默认密码：<a href="http://ldap.***.cc">重置密码链接</a></p>
        <p></p>
        <p><b> 系统自动发送，勿回复！</b></p>
        """
        message = MIMEText(mail_msg % (username, username), 'html', 'utf-8')
        message['From'] = Header('运维组 %s' % self.sender, 'utf-8')
        message['To'] = Header('%s' % sn, 'utf-8')
        subject = 'LDAP 账号信息'
        message['Subject'] = Header(subject, 'utf-8')
        try:
            smtpobj = smtplib.SMTP_SSL()
            smtpobj.connect(self.mail_url, self.mail_port)
            smtpobj.login(self.sender_username, self.sender_password)
            smtpobj.sendmail(self.sender, receiver, message.as_string())
            smtpobj.quit()
            print('发送邮件成功')
        except smtplib.SMTPException as e:
            print('发送邮件失败', e)


if __name__ == "__main__":
    mail = Email()
    mail.send_mail('zhangsan@***.cn', 'zhangsan', '张三')

