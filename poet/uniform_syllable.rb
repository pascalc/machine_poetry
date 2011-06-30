#!/usr/bin/env ruby

require_relative '../db/database_connect.rb'
require_relative '../db/corpus/couplet_db_maker.rb'

def random
    rand(Couplet_DB_Maker::RAND_LIMIT)
end

def random_doc(coll)
    doc = coll.find_one({"random" => {"$gte" => random}})
    if doc.nil?
        return coll.find_one({"random" => {"$lte" => random}})
    end
    return doc
end

def clean(str)
    str.scan(/[a-zA-Z\'\-]+/).join(" ")
end

c = Database_Connect.new
c.database do |db|
    corpus = db[Couplet_DB_Maker::COUPLET_CORPUS]

    # First line is random
    first_line = random_doc(corpus)
    puts clean(first_line["text"]).capitalize

    # Select next lines to have a similar amount of syllables
    uplimit = first_line["syllables"] + 1
    downlimit = first_line["syllables"] - 1

    candidates = corpus.find({"syllables" => {"$gt" => downlimit, "$lt" => uplimit}})
    reps = ARGV[0].nil? ? 3 : ARGV[0].to_i-1
    reps.times { puts clean(candidates.next["text"]) }
end
