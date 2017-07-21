module Sparrow
  class Rewriter
    def initialize(node, path)
      @path = path
      @map_def = node.loc
      @buffer = Parser::Source::Buffer.new('(string)')
      @buffer.source = File.open(path).read
      @rewriter = Parser::Source::Rewriter.new(@buffer)
    end

    def process
      @rewriter.transaction do
        @rewriter.replace(@map_def.keyword, 'module')
        @rewriter.replace(@map_def.name, namespace_string)
        @rewriter.replace(@map_def.end, end_string)
      end
      rewritten_source = @rewriter.process
      File.write(@path, rewritten_source)
    rescue Parser::ClobberingError
    end

    private

    def namespace_string
      namespace_fragments = @map_def.name.source.split('::')
      namespace_fragments_length = namespace_fragments.length
      rewrite_str = "#{namespace_fragments.shift}\n"
      class_name = namespace_fragments.pop
      namespace_fragments.each_with_index do |name, i|
        str = "  " * (i + 1)
        str << "module #{name}\n"
        rewrite_str << str
      end
      rewrite_str << ("  " * (namespace_fragments_length - 1)) + "class #{class_name}\n"
    end

    def end_string
      namespace_fragments_length = @map_def.name.source.split('::').length
      str = ""
      (namespace_fragments_length - 1).downto(0).each do |i|
        str << ("  " * i) + "end\n"
      end
      str
    end
  end
end
