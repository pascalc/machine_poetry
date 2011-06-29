#!/usr/bin/env ruby

require_relative 'couplet_db_maker.rb'

if ARGV.length != 1
	puts "USAGE: make_couplet_db [raw_corpus.txt]"
	exit
end

Couplet_DB_Maker.new.make_db(ARGV[0])

puts "Successfully created couplet database."
