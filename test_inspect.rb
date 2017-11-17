#!/usr/bin/env ruby
n = 600
while n >= 0
  n = n - 1
  system('tools/pg_inspector/inspect_pg.sh | grep "Boom" >> auto-pgi-log')
  sleep(60)
end
