require 'time'
my_hash = Hash.new(0)
my_hash[:"1"] += 1
p my_hash

t = Time.strptime('11/12/08 10:47', '%m/%d/%Y %k:%M').hour
p t
