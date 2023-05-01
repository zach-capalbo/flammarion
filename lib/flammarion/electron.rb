# Extra electron stuff

# TODO Set application ID so that they're not grouped
module Flammarion
  module EngravingElectronExtensions
    # Currently only works with Electron. Returns a PNG image of the Engraving
    def snapshot(&block)
      if block_given?
        id = make_id
        callbacks[id] = Proc.new {|d| block.call(d.fetch('data', {}).fetch('data', []).pack('c*')) }
        send_json(action:'snapshot', id: id)
      else
        return_value = nil
        snapshot {|d| return_value = d}
        Timeout.timeout(10) do
          sleep(0.01) until return_value
        end
        return return_value
      end
    end

    def applicationId(id)
      js %|$remote.require('app').setAppUserModelId(#{id.to_s.inspect})|
    end
  end
end
