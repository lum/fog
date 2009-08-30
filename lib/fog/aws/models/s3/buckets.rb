module Fog
  module AWS
    class S3

      def buckets
        Fog::AWS::S3::Buckets.new(:connection => self)
      end

      class Buckets < Fog::Collection

        def [](name)
          self[name] ||= begin
            get(name)
          end
        end

        def all
          data = connection.get_service.body
          owner = Fog::AWS::S3::Owner.new(data.delete('Owner').merge!(:connection => connection))
          data['Buckets'].each do |bucket|
            self[bucket['Name']] = Fog::AWS::S3::Bucket.new({
              :buckets    => buckets,
              :connection => connection,
              :owner      => owner
            }.merge!(bucket))
          end
          self
        end

        def create(attributes = {})
          bucket = new(attributes)
          bucket.save
          bucket
        end

        def get(name, options = {})
          remap_attributes(options, {
            :is_truncated => 'IsTruncated',
            :marker       => 'Marker',
            :max_keys     => 'MaxKeys',
            :prefix       => 'Prefix'
          })
          data = connection.get_bucket(name, options).body
          bucket = Fog::AWS::S3::Bucket.new({
            :buckets    => self,
            :connection => connection,
            :name       => data['Name']
          })
          self[bucket.name] = bucket
          objects_data = {}
          for key, value in data
            if ['IsTruncated', 'Marker', 'MaxKeys', 'Prefix'].include?(key)
              objects_data[key] = value
            end
          end
          objects = Fog::AWS::S3::Objects.new({
            :bucket       => bucket,
            :connection   => connection
          }.merge!(objects_data))
          data['Contents'].each do |object|
            owner = Fog::AWS::S3::Owner.new(object.delete('Owner').merge!(:connection => connection))
            objects[object['key']] = Fog::AWS::S3::Object.new({
              :bucket     => bucket,
              :connection => connection,
              :objects    => self,
              :owner      => owner
            }.merge!(object))
          end
          bucket
        end

        def new(attributes = {})
          Fog::AWS::S3::Bucket.new(
            attributes.merge!(
              :connection => connection,
              :buckets    => self
            )
          )
        end

      end

    end
  end
end