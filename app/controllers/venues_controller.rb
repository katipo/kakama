class VenuesController < ApplicationController
  include Swagger::Blocks

  before_filter :login_required
  before_filter :admin_required, :except => [:show]

  active_scaffold :venue do |config|
    config.columns = [:name, :description]
    columns[:name].required = true
  end

  # This must be included after active_scaffold config because it overrides
  # some of the methods added by the controller
  include DisplayDeleteErrors

  swagger_path "/#{self.controller_name}" do
    operation :get do |operation|
      key :description, 'Lists all records'
      key :notes, "This lists all records"
      key :tags, [
        'venues'
      ]

      ApplicationController.add_common_params(operation)

      parameter name: :page,
                in: :query,
                required: false,
                type: :integer,
                description: 'Page number'

    end

    operation :post do |operation|
      key :description, "Creates a record given it's attributes"
      ApplicationController.add_common_params(operation)

      key :tags, [
        'venues'
      ]
      parameter do
        key :name, :venue
        key :in, :body
        key :description, 'Record to create'
        key :required, true
        schema do
          property :record do
            key :'$ref', :Venue
          end
        end
      end

      response 200 do
        key :description, 'record created'
        schema do
          key :'$ref', :Venue
        end
      end
    end
  end

  swagger_path "/#{self.controller_name}/{id}" do
    operation :get do |operation|
      key :description, 'Fetches a record given an id'
      key :notes, ""

      key :tags, [
        'venues'
      ]

      ApplicationController.add_common_params(operation)

      parameter name: :id,
                in: :path,
                required: true,
                type: :string,
                description: 'Record ID'

      response 200 do
        key :description, 'record found'
        schema do
          key :type, :array
          items do
            key :'$ref', :Venue
          end
        end
      end
    end

    operation :put do |operation|
      key :description, "Updates a record given it's attributes"
      ApplicationController.add_common_params(operation)

      key :tags, [
        'venues'
      ]

      parameter name: :id,
                in: :path,
                required: true,
                type: :string,
                description: 'Record ID'

      parameter do
        key :name, :venue
        key :in, :body
        key :description, 'Record to update'
        key :required, true
        schema do
          property :record do
            key :'$ref', :Venue
          end
        end
      end

      response 200 do
        key :description, 'record updated'
      end
    end

    operation :delete do |operation|
      key :description, "Deletes a record given it's id"
      ApplicationController.add_common_params(operation)

      key :tags, [
        'venues'
      ]

      parameter name: :id,
                in: :path,
                required: true,
                type: :string,
                description: 'Record ID'

      response 200 do
        key :description, 'record destroyed'
      end
    end
  end
end
