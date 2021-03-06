module Fog
  module Compute
    class Brightbox
      class Real

        def map_cloud_ip(identifier, options = {})
          return nil if identifier.nil? || identifier == ""
          request(
            :expects  => [202],
            :method   => 'POST',
            :path     => "/1.0/cloud_ips/#{identifier}/map",
            :headers  => {"Content-Type" => "application/json"},
            :body     => MultiJson.encode(options)
          )
        end

      end
    end
  end
end