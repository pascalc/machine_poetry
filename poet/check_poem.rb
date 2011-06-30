#!/usr/bin/env ruby

while line = gets
  print line + "\t"
  puts `grep -n \"#{line.chomp}\" ../db/corpus/poetry_corpus.txt`
end