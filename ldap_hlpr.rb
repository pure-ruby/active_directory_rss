# encoding: utf-8

require 'net/ldap'
require 'Unicode'

class LDAPHelper
  def initialize(host, port = 389, user, password)
    @ldap = Net::LDAP.new(host: host,
     auth: {
       method: :simple,
       username: user,
       password: password
       })
  end

  def user_info(login, paths)
    if @ldap.bind
      filter = Net::LDAP::Filter.eq('samaccountname', login)
      filter2 = Net::LDAP::Filter.eq('userAccountControl', '512')
      filter3 = Net::LDAP::Filter.eq('userAccountControl', '544')
      filter4 = Net::LDAP::Filter.eq('userAccountControl', '546')
       #не заблоченные
      return ldap_multi_base_search(filter & (filter2 | filter3 | filter4), paths) #66048 этих еще
    else
      raise 'Authentication failed!'
      # authentication failed, log failed!
    end
  end

  private

  def ldap_multi_base_search(filter, args)
    result = []
    args.each do |x|
      @ldap.search(base: x, filter: filter) do |object|
        login = object[:samaccountname][0].downcase
        object[:memberof].each { |y| result << [login, split_group_string(y)] }
      end
    end
    result
  end

  def split_group_string(str)
    temp_str = str.split(',').first
    Unicode::downcase(temp_str[3..-1].force_encoding('utf-8')) if temp_str[0..2].upcase == 'CN='
  end
end