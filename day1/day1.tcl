#!/bin/tclsh

package require sqlite3
sqlite3 db
db eval { attach database ':memory:' as db }

db eval {
  create table if not exists db.depths(
    id integer primary key autoincrement not null,
    depth integer
  )
}

#### Read input and populate sqlite table

set input [open input]
set depths [split [read $input] "\n"]
close $input

db eval begin
foreach depth $depths {
  db eval { insert into db.depths (depth) values ($depth) }
}
db eval commit

#### Part 1

db eval {
  with cte as (
    select
      id,
      depth - lag(depth, 1) over (order by id) as diff
    from db.depths
  ) select count(id) as count
    from cte
    where diff > 0
} {
  puts "part1: $count"
}

#### Part 2

db eval {
  with cte1 as (
    select
      id,
      sum(depth) over (order by id rows between 0 preceding and 2 following) as trio_sum
    from db.depths
  ), cte2 as (
    select
      id,
      trio_sum - lag(trio_sum, 1) over (order by id) as diff
    from cte1
  ) select count(id) as count
    from cte2
    where diff > 0
} {
  puts "part2: $count"
}
