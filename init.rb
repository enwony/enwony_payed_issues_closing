Redmine::Plugin.register :enwony_payed_issues_closing do
  name 'Enwony Payed Issues Closing plugin'
  author 'Enwony enwony@gmail.com'
  description 'Allow close several issues with link to "payout" task'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  require_dependency 'payed_issues_listener'
end
