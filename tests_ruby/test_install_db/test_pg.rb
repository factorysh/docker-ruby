#!/usr/bin/env ruby

require 'pg'

conn = PG.connect 'postgresql://test:example@pg/demo'

conn.exec 'SELECT 1+1 AS math' do |result|
  result.each do |row|
    puts 'pg: %s' % row.values_at('math')
  end
end
