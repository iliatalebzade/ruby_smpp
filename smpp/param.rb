module SMPP
  class Param
    # Command parameter info class

    def initialize(**kwargs)
      raise KeyError, 'Parameter Type not defined' unless kwargs.key?(:type)

      valid_types = [Integer, String, Object, Symbol]
      unless valid_types.include?(kwargs[:type])
        raise ValueError, "Invalid parameter type: #{kwargs[:type]}"
      end

      valid_keys = [:type, :size, :min, :max, :len_field]
      kwargs.each_key do |k|
        raise KeyError, "Key '#{k}' not allowed here" unless valid_keys.include?(k)
      end

      @type = kwargs[:type]

      [:size, :min, :max, :len_field].each do |param|
        if kwargs.key?(param)
          instance_variable_set("@#{param}", kwargs[param])
        end
      end
    end

    def to_s
      # Shows type of Param in console
      "<Param of #{@type}>"
    end
  end
end
