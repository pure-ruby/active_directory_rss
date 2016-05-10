# encoding: utf-8

require %-rubygems-
require %-bundler/setup-

require %-yaml-
require_relative %-odbc_hlpr-
require_relative %-ldap_hlpr-

CONFIG = YAML.load_file('conf.yml')
LDAP_PATHS = ['OU=Users,OU=Tyumen,DC=corp,DC=tnk-bp,DC=ru'] # через запятую еще ветки

def get_ad_user_and_group
  ldap = LDAPHelper.new(CONFIG['dc_server'], CONFIG['user'], CONFIG['password'])
  ldap.user_info('*', LDAP_PATHS)
end

@DBStruct = Struct.new(:odbc_obj).new

def @DBStruct.update_and_save(ad_search_result)
  # перепсываем old
  odbc_obj.truncate_table('ad.iat_ad_old')
  odbc_obj.fn_clone_data
  # переписываем new
  odbc_obj.truncate_table('ad.iat_ad_new')
  odbc_obj.insert_by_part('ad.iat_ad_new', ad_search_result, 'LOGIN_', 'GROUP_')
end

def @DBStruct.set_info_of_update
  odbc_obj.insert_row('ad.iat_ad_info', {type_: 'last_update', var1: Time.now.strftime('%d.%m.%Y %T')})
end

def @DBStruct.save_diff
  diff = odbc_obj.get_all_rows('ad.iat_ad_diff')
  time_group = Time.now.strftime("%d.%m.%Y %T")
  diff.map! { |x| x << time_group }
  odbc_obj.insert_by_part('ad.iat_ad_history', diff, 'ACTION_', 'LOGIN_', 'GROUP_', 'DATE_TO_GROUP') if diff.count > 0
end

def main
  @DBStruct.odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])

  puts b = Time.now
  print "Search users..."
  u = get_ad_user_and_group
  puts " #{Time.now - b} sec."; b = Time.now
  print "Update DB..."
  @DBStruct.update_and_save(u)
  puts " #{Time.now - b} sec."
  @DBStruct.save_diff
  @DBStruct.set_info_of_update
end

desc "Update AD"
task :update do
  loop do
    begin
      main
    rescue
      puts $!
      File.open('log\upd_errors.log', 'a+') { |x| x.write "#{Time.now.strftime("%F %T")}\n#{$!}\n#{$!.backtrace.inspect}\n" }
    ensure
      @DBStruct.odbc_obj.close_connection if @DBStruct.odbc_obj
    end
    sleep 10800
  end
end
