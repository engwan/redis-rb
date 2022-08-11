#
# Run with
# $ ruby -Ilib benchmarking/ruby_patched.rb
#

require "redis/connection/ruby"
require "redis/connection/ruby_patched"
require 'redis'
require 'benchmark/ips'
require 'benchmark/memory'

DB = 9

$ruby = Redis.new(:db => DB, :driver => Redis::Connection::Ruby)
$patched_ruby = Redis.new(:db => DB, :driver => Patched::Redis::Connection::Ruby)

# make sure both are connected
$ruby.ping
$patched_ruby.ping

set_key = 'test:set'
$ruby.del(set_key)

5000.times do |index|
  name = "*" * 16
  $ruby.sadd(set_key, name + index.to_s)
end

Benchmark.ips do |x|
  x.report("Ruby") {
    $ruby.smembers(set_key)
  }

  x.report("Patched Ruby") {
    $patched_ruby.smembers(set_key)
  }

  x.compare!
end

Benchmark.memory do |x|
  x.report("Ruby") {
    $ruby.smembers(set_key)
  }

  x.report("Patched Ruby") {
    $patched_ruby.smembers(set_key)
  }

  x.compare!
end

$ruby.flushdb
