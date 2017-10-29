module MatrixQQ
  class Matrix
    SIGN = %i[
      all
      account_data
      to_device
      presence
      rooms
      leave
      join
      invite
      device_lists
      changed
      left
    ].freeze

    class << self
      SIGN.each { |i| attr_accessor i }
    end
    SIGN.each { |i| Matrix.send (i.to_s + '='), [] }

    attr_reader :dbus, :info
    attr_accessor :qq_dbus

    def initialize(dbus)
      @dbus = DBus.new dbus
      reg
    end

    def reg
      SIGN.each do |i|
        @dbus.obj.on_signal i.to_s do |json|
          info = parse json
          Matrix.send(i).each do |func|
            uuid = SecureRandom.uuid
            puts "Start #{func.name} -- #{uuid}" if $VERBOSE
            func.new(@dbus, @qq_dbus, info.dup).run
            puts "End #{func.name} -- #{uuid}" if $VERBOSE
          end
        end
      end
    end

    private

    def parse(json)
      JSON.parse json
    end
  end
end
