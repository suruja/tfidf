require "random"

module Cadmium
  class TfIdf
    include Cadmium::Util::StopWords

    # TODO: Figure out how to make this work with no key
    alias Document = NamedTuple(key: String, terms: Hash(String, Float64))

    @documents : Array(Document)
    @idf_cache : Hash(String, Float64)
    @stop_words : Array(String)
    @tokenizer : Cadmium::Tokenizer::Word

    def initialize(documents : Array(Document)? = nil, custom_stop_words : Array(String) = @@stop_words)
      @documents = documents || [] of Document
      @idf_cache = {} of String => Float64
      @stop_words = custom_stop_words
      @tokenizer = Cadmium::Tokenizer::Word.new
    end

    def tfidf(terms, d)
      if terms.is_a?(String)
        terms = @tokenizer.tokenize(terms)
      end

      terms.reduce(0.0) do |value, term|
        _idf = idf(term)
        _idf = _idf.infinite? ? 0.0 : _idf
        value + TfIdf.tf(term, @documents[d]) * _idf
      end
    end

    def add_document(text : String | Array(String), key = nil, restore_cache = false)
      key ||= Random::Secure.hex(4)
      @documents.push(build_document(text, key))

      if restore_cache
        @idf_cache.each { |(term, _)| idf(term, true) }
      else
        @idf_cache = {} of String => Float64
      end
    end

    def tfidfs(terms)
      Array(Float64).new(@documents.size, 0.0).map_with_index do |_, i|
        tfidf(terms, i)
      end
    end

    def tfidfs(terms, &block)
      tfidfs = Array(Float64).new(@documents.size, 0.0)

      @documents.each_with_index do |doc, i|
        tfidfs[i] = tfidf(terms, i)

        yield(i, tfidfs[i], doc[:key])
      end

      tfidfs
    end

    def stop_words=(value)
      @stop_words = value
    end

    def self.tf(term : String, document : Document)
      document[:terms].has_key?(term) ? document[:terms][term] : 0.0
    end

    def idf(term : String, force = false)
      if @idf_cache.has_key?(term) && !force
        return @idf_cache[term]
      end

      docs_with_term = @documents.reduce(0) { |count, doc| count + (document_has_term(doc, term) ? 1.0 : 0.0) }
      idf = 1 + Math.log(@documents.size / (1.0 + docs_with_term))
      @idf_cache[term] = idf
      idf
    end

    def list_terms(d)
      terms = [] of NamedTuple(term: String, tfidf: Float64)

      return terms unless @documents[d]?

      @documents[d][:terms].each do |(key, _)|
        terms.push({term: key, tfidf: tfidf(key, d)})
      end

      terms.sort_by { |x| -x[:tfidf] }
    end

    private def build_document(text, key)
      stopout = false

      if text.is_a?(String)
        text = @tokenizer.tokenize(text)
        stopout = true
      end

      text.reduce({key: key, terms: {} of String => Float64}) do |document, term|
        document[:terms][term] = 0.0 unless document[:terms].has_key?(term)
        if !stopout || @stop_words.includes?(term) == false
          document[:terms][term] = document[:terms][term] + 1.0
        end
        document
      end
    end

    private def document_has_term(document : Document, term)
      document[:terms].has_key?(term) && document[:terms][term] > 0.0
    end
  end
end
