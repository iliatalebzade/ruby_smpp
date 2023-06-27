module SMPP
  module Errors
    class UnknownCommandError < StandardError
      # Raised when unknown command ID is received
    end

    class ConnectionError < StandardError
      # Connection error
    end

    class PDUError < RuntimeError
      # Error processing PDU
    end

    class MessageTooLong < StandardError
      # Text too long to fit 255 SMS
    end
  end
end
