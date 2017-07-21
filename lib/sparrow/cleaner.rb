module Sparrow
  class Cleaner

    TYPES_WITH_CHILDREN = %i[splat kwsplat block_pass not break next
      preexe postexe match_current_line defined? arg_expr dstr dsym xstr regexp
      array hash pair irange erange mlhs masgn or_asgn and_asgn undef alias args
      super yield or and while_post until_post iflipflop eflipflop
      match_with_lvasgn begin kwbegin return lvasgn ivasgn cvasgn gvasgn optarg
      kwarg kwoptarg].freeze

    def initialize(file_paths)
      @corrected_files = []
      @file_paths = file_paths
    end

    def process
      @file_paths.each do |path|
        parse_and_correct(ast_from_file_path(path), path)
      end

      puts @corrected_files
    end

    def parse_and_correct(node, path)
      if node.type == :class
        if class_node_does_not_conform?(node)
          modify_file(node, path)
          @corrected_files << path
        end
      elsif node
        # traverse through the nodes
        node.children.compact.each do |node|
          parse_and_correct(node, path) if TYPES_WITH_CHILDREN.include?(node.type)
        end
      end
    end

    def class_node_does_not_conform?(node)
      node.loc.name.source =~ /::/
    end

    def ast_from_file_path(path)
      Parser::CurrentRuby.parse(File.open(path).read)
    end

    def modify_file(node, path)
      Rewriter.new(node, path).process
    end
  end
end
