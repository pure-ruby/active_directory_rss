# -*- encoding: utf-8 -*-

require %-sinatra-
require %-haml-
require %-yaml-
require %-tilt/haml-
require %-sass/plugin/rack-
require_relative %-odbc_hlpr-

#### ROUTES ####
get("/version")                    {Sinatra::VERSION}
# get("/empls_move")                 {haml :empls}
get("/empls_move.rss")             {headers("Content-Type" => "application/rss+xml"); haml :empls_rss, :format => :xhtml}
get(%r{^(/ruby/rss/rss.rb|/rss)$}) {headers "Content-Type" => "application/rss+xml"; haml :ad_rss, :format => :xhtml}
get(%r{^(/|/ruby/rss/index.rb)$})  {headers("expires" => Time.new(2000).to_s, "pragma" => "no-cache", "content-type" => "text/html;charset=utf-8"); haml :ad_index, layout: true}
get("/empls_tree")                 {haml :empls_tree, layout: true}
get("/empls_4_diff")               {haml :empls_4_diff, layout: true}
get("/empls_anvrs")                {haml :empls_anvrs, layout: true}
get("/empls_birthday")             {haml :empls_birthday, layout: true}
not_found                          {haml :error_404}
error(500)                         {haml :error_500}
#
get("/test")                       { }
get("/123")                        { 1/0 }
#^^^ ROUTES ^^^#

helpers do
  def get_empls_anniversary_
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.get_empls_anniversary; odbc_obj.close_connection; r
  end
  def get_empls_birthday_
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.get_empls_birthday; odbc_obj.close_connection; r
  end
  def get_history
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.fn_last_ad_history_of_2_days; odbc_obj.close_connection; r
  end
  def get_empls_move_
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.get_empls_move; odbc_obj.close_connection; r
  end
  def get_last_update_minute_
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.get_last_update_minute; odbc_obj.close_connection; r
  end
  def get_4_all_diff_histroy_
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.get_4_all_diff_histroy; odbc_obj.close_connection; r
  end
  def get_work_empls_tree_
    odbc_obj = ODBCHelper.new(CONFIG['odbc_source_name'])
    r        = odbc_obj.get_work_empls_tree; odbc_obj.close_connection; r
  end
end