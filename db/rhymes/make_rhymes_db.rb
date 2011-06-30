#!/usr/bin/env ruby

require 'gdbm'
require_relative '../database_connect.rb'

RHYMES_COLL = "rhymes"

old_db = GDBM.new("rhymes.db")

c = Database_Connect.new
c.database do |db|
    db.drop_collection(RHYMES_COLL)
    rhymes = db[RHYMES_COLL]
    rhymes.create_index("words")

    old_db.each_value do |v|
        if v.split.length > 1
            row = { "words" => v.downcase.split.select { |w| w =~ /^[a-zA-Z\'\-]+$/} }
            rhymes.insert(row)
        end
    end
end

puts "Successfully created collection: #{RHYMES_COLL}"
