# tf-idf

[Term Frequency–Inverse Document Frequency (tf-idf)](http://en.wikipedia.org/wiki/Tf%E2%80%93idf) is implemented to determine how important a word (or words) is to a document relative to a corpus. The following example will add four documents to a corpus and determine the weight of the word "crystal" and then the weight of the word "ruby" in each document.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cadmium_tfidf:
       github: cadmiumcr/tfidf
   ```

2. Run `shards install`

## Usage

```crystal
require "cadmium_tfidf"
```

```crystal
tfidf = Cadmium.tf_idf.new
tfidf.add_document("this document is about crystal.")
tfidf.add_document("this document is about ruby.")
tfidf.add_document("this document is about ruby and crystal.")
tfidf.add_document("this document is about crystal. it has crystal examples")

puts "crystal --------------------------------"
tfidf.tfidfs("crystal") do |i, measure, key|
  puts "document ##{i} is #{measure}"
end

puts "ruby --------------------------------"
tfidf.tfidfs("ruby") do |i, measure, key|
  puts "document ##{i} is #{measure}"
end

# =>  crystal --------------------------------
      document #0 is 1
      document #1 is 0
      document #2 is 1
      document #3 is 2
      ruby --------------------------------
      document #0 is 0
      document #1 is 1.2876820724517808
      document #2 is 1.2876820724517808
      document #3 is 0
```

## Contributing

1. Fork it (<https://github.com/cadmiumcr/tfidf/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watson](https://github.com/watzon) - creator and maintainer
