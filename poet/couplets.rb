#!/usr/bin/env ruby

require_relative "../db/database_connect.rb"
require_relative "../db/corpus/couplet_db_maker.rb"
require 'pp'

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
    str.scan(/[a-zA-Z\'\-,.!?]+/).join(" ")
end

def make_couplet(corpus,rhymes)
    couplet = []    

    #first_candidates = corpus.find({"text" => subject})
    #r = rand(first_candidates.count)
    #first_candidates.skip(r)
    #couplet << first_candidates.next

    couplet << random_doc(corpus)
    
    rhyming_ring = rhymes.find_one({"words" => couplet[0]["lastword"].downcase})
    second_line = nil
    if rhyming_ring.nil?
        puts "Couldn't rhyme anything with #{couplet[0]["lastword"]}, sorry!"
        exit
    else
        rhyming_words = rhyming_ring["words"]
        rhyming_words.select { |w| w != couplet[0]["lastword"] }.each do |w|
            syll = couplet[0]["syllables"]
            second_line = corpus.find_one({"syllables" => {"$gt" => syll - 2, "$lt" => syll + 2},
                                          "lastword" => /\b#{w}\b/i })
            break if second_line
        end
    end

    if second_line.nil?
        puts "Couldn't find any lines rhyming with #{couplet[0]["lastword"]}, sorry :("
        exit
    end
    couplet << second_line

    return couplet
end

poem = []

c = Database_Connect.new
c.database do |db|
    corpus = db[Couplet_DB_Maker::COUPLET_CORPUS]
    rhymes = db["rhymes"]
    
    c1 = make_couplet(corpus,rhymes)
    c2 = make_couplet(corpus,rhymes)

    poem << c1[0]
    poem << c2[0]
    poem << c1[1]
    poem << c2[1]
end

poem.map { |d| d["text"].join " " }.each { |l| puts l }
