require 'yaml'
require 'mail'

def sendEmail(destnationAddress, subject, body)
    # dfEbrnY26uMS
    # xapmufikwvztrxaf
    server_str = 'smtp.gmail.com'
    password_str = 'xapmufikwvztrxaf'
    port = 587
    address_str = 'kousen.fes.auto.mailer.noreply@gmail.com'

    mail = Mail.new do 
        from address_str
        to destnationAddress
        subject subject
        body body
    end

    mail.charset = 'utf8'

    mail.delivery_method :smtp, {address: server_str, 
                                port: port, 
                                domain: address_str.split('@')[1], 
                                user_name: address_str, 
                                password: password_str}
    
    mail.deliver!
    puts "[INFO] Sent Email...."
end

 
# 認証用メールを送信する
# @param email
# @param username 
# @param passcode
# @param access_key
# @param uuid
# @param expire
def sendAuthEmail(email, username, passcode, access_key, uuid)
    subject = "ユーザ認証のお願い【産技高専祭】"
    body = <<EOS

 #{username} 様

パスワード認証のパスコードが発行されました。以下のリンクを開いて、パスコードを入力してください。
有効期間は10分です。

パスコード : #{passcode}
URL : https://www.kousensai.jp/kousenuser/sinup/entry?accesskey=#{access_key}&uuid=#{uuid}

なお、パスコードが期限切れとなった場合、お手数ですが以下のリンクより再度パスコード発行の手続きお願い致します。

パスコード再発行URL : https://www.kousensai.jp/kousenuser/reset

============================
都立産業技術高専 高専祭実行委員会 広報部署

* このメールは自動返信です。お問い合わせには一切対応できません。
* お問い合わせには以下のメールアドレス、または、以下のフォームよりご連絡ください。

Email : kousensai.r3@gmail.com
フォーム : https://docs.google.com/forms/d/e/1FAIpQLScUdvHRpl3yCUlBOkbA3yVFoS79nrCiL0_owiUpbx4-87g5jw/viewform

* 上記のメールアドレスは、実行委員会全体のメールアドレスです。広報部署専用ではありませんので、Webシステム上の不具合については、なるべくGoogleフォームにご連絡ください。
EOS
    sendEmail(email, subject, body)
end