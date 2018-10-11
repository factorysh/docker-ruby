#!/usr/bin/env ruby

require 'pg'

conn = nil
for i in 1..30 do
  begin
    conn = PG.connect 'postgresql://test:example@pg/demo'
  rescue
    puts 'oups'
    sleep 1
  else
    break
  end
end
conn.exec 'SELECT 1+1 AS math' do |result|
  result.each do |row|
    puts 'pg: %s' % row.values_at('math')
  end
end
