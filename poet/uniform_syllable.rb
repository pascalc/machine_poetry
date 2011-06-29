#!/usr/bin/env ruby

require_relative '../db/database_connect.rb'
require_relative '../db/couplet_db_maker.rb'

def random_doc(coll)
    r = rand(Couplet_DB_Maker::RAND_LIMIT)
    doc = coll.find_one({"random" => {"$gte" => r}})
    if doc.nil?
        return coll.find_one({"random" => {"$lte" => r}})
    end
    return doc
end

c = Database_Connect.new
c.database do |db|
    corpus = db[Couplet_DB_Maker::COUPLET_CORPUS]

    # First line is random
    first_line = random_doc(corpus)
    puts first_line["text"].capitalize

    # Select next 3 lines to have a similar amount of syllables
    uplimit = first_line["syllables"] + 1
    downlimit = first_line["syllables"] - 1

    candidates = corpus.find({"syllables" => {"$gt" => downlimit, "$lt" => uplimit}})
    candidates.to_a.shuffle.take(3).each { |doc| puts doc["text"] }
end
