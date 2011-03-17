require 'rattler/back_end/parser_generator'

module Rattler::BackEnd::ParserGenerator

  # @private
  class AssertGenerator < ExprGenerator #:nodoc:

    def gen_basic(assert, scope={})
      generate assert.child, :assert, scope
    end

    def gen_assert(assert, scope={})
      gen_basic assert, scope
    end

    def gen_disallow(assert, scope={})
      @g << 'false'
    end

    def gen_skip(assert, scope={})
      gen_basic assert, scope
    end

    def gen_dispatch_action(assert, code, scope={})
      expr(:block) { gen_action assert, code.bind(scope, '[]'), scope }
    end

    def gen_direct_action(assert, code, scope={})
      expr(:block) { gen_action assert, "(#{code.bind scope, []})", scope }
    end

    def gen_token(assert, scope={})
      expr(:block) { gen_action assert, "''", scope }
    end

    def gen_intermediate(assert, scope={})
      generate assert.child, :intermediate_assert, scope
    end

    def gen_intermediate_assert(assert, scope={})
      gen_intermediate assert, scope
    end

    def gen_intermediate_skip(assert, scope={})
      gen_intermediate assert, scope
    end

    private

    def gen_action(assert, result_code, scope={})
      gen_intermediate assert, scope
      (@g << ' &&').newline << result_code
    end

  end

  # @private
  class NestedAssertGenerator < AssertGenerator #:nodoc:
    include Nested
    include NestedSubGenerating
  end

  def AssertGenerator.nested(*args)
    NestedAssertGenerator.new(*args)
  end

  # @private
  class TopLevelAssertGenerator < AssertGenerator #:nodoc:
    include TopLevel
    include TopLevelSubGenerating
  end

  def AssertGenerator.top_level(*args)
    TopLevelAssertGenerator.new(*args)
  end

end
