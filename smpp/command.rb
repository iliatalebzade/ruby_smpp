module SMPP
  class Command
    attr_accessor :command_name, :kwargs

    def initialize(command_name, **kwargs)
      @command_name = command_name
      @kwargs = kwargs
    end
  end
end
