# encoding: utf-8

require 'odbc_utf8'

module SQLFunction
  def get_empls_birthday
    result = []
    sth = @db.run("select * from iam.vwEmplsBirthday order by 12")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end
  def get_empls_anniversary
    result = []
    sth = @db.run("select * from iam.vwEmplsAnniversary order by 12")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  def get_work_empls_tree
    result = []
    sth = @db.run("select * from iam.vwWorkEmplsTree order by RANK_1,RANK_2,RANK_3,RANK_4,RANK_5,RANK_6,RANK_7")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  def get_4_all_diff_histroy
    result = []
    sth = @db.run("select * from iam.vw4AllShowHistory q2 order by q2.login_iam_2, q2.login_iam, q2.updated_at, q2.created_at")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  def get_empls_move
    result = []
    sth = @db.run("select * from iam.vwEmplsMoveRss order by DATE_FOR_GROUP, action desc")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  def fn_clone_data
    @db.do("insert into ad.iat_ad_old (ID, LOGIN_, GROUP_, CREATED_AT) select ID, LOGIN_, GROUP_, CREATED_AT from ad.iat_ad_new")
  end

  def fn_last_ad_history_of_2_days
    result = []
    sth = @db.run("select *, CONVERT(varchar(19), DATE_TO_GROUP ,120) DATE_TO_GROUP_FRMT from ad.iat_ad_history h 
where h.DATE_TO_GROUP > 
  (select dateadd(day, datediff(day, 0, getdate()-2),0))
  and h.DATE_TO_GROUP > '21.08.2015 14:12:58'
  and h.DATE_TO_GROUP > '17.09.2015 13:06:31'
order by DATE_TO_GROUP desc, ACTION_ desc, LOGIN_ asc, GROUP_ asc")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  def get_last_update_minute
    result = []
    sth = @db.run("select DATEDIFF(MINUTE, (select top 1 VAR1 from ad.iat_ad_info where TYPE_ = 'last_update' order by CREATED_AT desc), GETDATE())")#")
    while row = sth.fetch
      result << row
    end; sth.drop
    result
  end
end

class ODBCHelper
  
  include SQLFunction

  def initialize(odbc_source_name)
    @db = ODBC.connect(odbc_source_name)
  end

  #вставка массивом
  def insert_by_part(table, args, *colums)
    raise "Error: 'args' is not Array (method: #{__method__})" unless args.is_a?(Array)
    raise "Error: 'colums' is not Array (method: #{__method__})" unless colums.is_a?(Array)
    raise "Error: 'args' not contain Array (method: #{__method__})" unless args[0].is_a?(Array)
    step = 750
    @db.transaction do |db_|
      0.step(args.count-1, step) do |i| # пачками запросы
        query_str = "insert into #{table} (#{colums.join(', ')}) " + args[i...i+step].map { |e| "select '#{e.join("', '")}'" }.join(' union all ')
        db_.do(query_str)
      end
    end
    @db.commit
  end

  #очистить таблицу
  def erase_table(table_name)
    @db.do("delete from #{table_name}")
  end

  def truncate_table(table_name)
    @db.do("truncate table #{table_name}")
  end

  #вставить одну строку
  def insert_row(table_name, args)
    raise "Error: 'args' is not Hash (method: #{__method__})" unless args.is_a?(Hash)
    @db.do("insert into #{table_name} (#{args.keys.join ','}) values ('#{args.values.join("', '")}')")
  end

  #селект все строки
  def get_all_rows(table_name)
    result = []
    sth = @db.run("select * from #{table_name}")
    while row = sth.fetch
      result << row
    end; sth.drop
    result
  end

  def get_all_rows_hash(table_name)
    result = []
    sth = @db.run("select * from #{table_name}")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  #селект строки с условием и сортировкой
  def get_row_where_order(table_name, where_coll_name, args, order_by_coll)
    raise "Error: 'args' is not Array (method: #{__method__})" unless args.is_a?(Array)
    raise "Error: 'order_by_coll' is not Hash (method: #{__method__})" unless order_by_coll.is_a?(Hash)
    result = []
    sth = @db.run("select * from #{table_name} where #{where_coll_name} in ('#{args.join(',')}')#{' order by ' + order_by_coll.map{|x| "#{x[0]} #{x[1]}"}.join(',') if order_by_coll}")
    while row = sth.fetch
      result << row
    end; sth.drop
    result
  end

  def get_row_hash_where_order(table_name, where_coll_name, args, order_by_coll)
    raise 'Error: "args" is not Array' unless args.is_a?(Array)
    raise 'Error: "order_by_coll" is not Hash' unless order_by_coll.is_a?(Hash)
    result = []
    sth = @db.run("select * from #{table_name} where #{where_coll_name} in ('#{args.join(',')}')#{' order by ' + order_by_coll.map{|x| "#{x[0]} #{x[1]}"}.join(',') if order_by_coll}")
    while row = sth.fetch_hash
      result << row
    end; sth.drop
    result
  end

  def close_connection
    @db.disconnect
  end
end

if $0 == __FILE__
    odbc_obj = ODBCHelper.new('uss1')
    r = odbc_obj.fn_last_ad_history_of_2_days; odbc_obj.close_connection
    p r
end