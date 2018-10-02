#!/usr/bin/env ruby

require 'mysql2'

client = nil
for i in 1..30 do
  begin
    client = Mysql2::Client.new host: 'maria', username: 'test', password: 'example', database: 'demo'
  rescue
    puts 'oups'
    sleep 1
  else
    break
  end
end

results = client.query("SELECT 1+1 AS math")
results.each do |row|
  puts "my: %s" % row['math']
end
