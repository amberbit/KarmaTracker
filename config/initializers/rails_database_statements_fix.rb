module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module DatabaseStatements

      # Converts an arel AST to SQL
      def to_sql(arel, binds = [])
        if arel.respond_to?(:ast)
          binds = binds.dup
          visitor.accept(arel.ast) do
            binds = [""] if binds.nil? || binds.empty?
            quote(*binds.shift.reverse)
          end
        else
          arel
        end
      end
    end
  end
end
