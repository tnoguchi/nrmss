require 'mechanize'
require 'nkf'

module Rakuten::RmsLogin
  @@config = {}
  mattr_accessor :config

  @@login_top_url = 'https://glogin.rms.rakuten.co.jp/?sp_id=1'
  @@agent = WWW::Mechanize.new
  @@agent.user_agent_alias = 'Windows IE 7'
  @@logged_in = false

  def self.log(str, options = {})
    puts str
  end

  def self.login(r_login_id, r_login_passwords, r_user_id, r_user_password)
    # STEP 1: R-Login IDの認証
    page_step1 = @@agent.get(@@login_top_url)
    if page_step1.forms.size != 1
      log("#{page_step1.forms.size}")
    end
    form_step1 = page_step1.forms.first
    page_step2 = nil	# STEP 2用


    r_login_passwords.to_a.flatten.each do |r_login_password|
      # id, passwordセット
      form_step1.fields.name("login_id").value = r_login_id.to_s
      form_step1.fields.name("passwd").value   = r_login_password.to_s
      page_step2 = @@agent.submit(form_step1, form_step1.buttons.first)

      # STEP 1 のログインが成功したかどうかをチェック
      if page_step2.forms.first.fields.name("business_id") &&
          page_step2.forms.first.fields.name("buz_login_id")
        break
      end
      
    end
    if page_step2
      form_step2 = page_step2.forms.first
      # id, passwordセット
      form_step2.fields.name("user_id").value     = r_user_id.to_s
      form_step2.fields.name("user_passwd").value = r_user_password.to_s
      results = @@agent.submit(form_step2, form_step2.buttons.first)

      # STEP 2 のログインが成功したかどうかをチェック
      begin
        if results.forms.first.fields.name('action').value == 'BizAuthAnnounce'
          @@logged_in = true
          return @@agent
        end
      rescue Exception
        return false
      end
    end
    return false
  end

  # ログイン状態でHTMLを取得し、その本文を返す
  #  url :: String
  #  return :: String
  def self.fetch(url)
    login(@@config['r_login_id'],
          @@config['r_password'],
          @@config['user_id'],
          @@config['user_r_login_id']) unless @@logged_in
    if @@logged_in
      @@agent.get(url).body
    else
      ""
    end
  end
end
