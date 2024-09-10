class FuncHelper
   
    def self.nil_or_empty_string?(variable)
        variable.nil? || (variable.is_a?(String) && variable.empty?)
      end
  
      def self.nil_or_less_zero?(variable)
        variable.nil? || !variable.is_a?(Numeric) || variable <0;
      end 

end
