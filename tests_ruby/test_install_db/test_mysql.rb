#!/usr/bin/env ruby

require 'mysql2'

client = Mysql2::Client.new host: 'maria', username: 'test', password: 'example', database: 'demo'

results = client.query("SELECT 1+1 AS math")
results.each do |row|
  puts "my: %s" % row['math']
end
