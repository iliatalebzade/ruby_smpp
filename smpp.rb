require 'socket'
require 'byebug'
require_relative 'smpp/command'
require_relative 'smpp/client'
require_relative 'smpp/param'
require_relative 'smpp/bind_transmitter'

module SMPP
  CONSTS = {
    SMPP_CLIENT_STATE_OPEN: 1,
    SMPP_VERSION_52: 52
  }.freeze
end
