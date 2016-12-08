class ApiDocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'Kakama API documentation'
      key :description, 'Documentation for the API'
      key :termsOfService, ''
      contact do
        key :name, ''
      end
      license do
        key :name, 'GPL 3.0'
      end
    end
    tag do
      key :name, 'staff'
      key :description, 'Application users and staff being rostered'
    end
    tag do
      key :name, 'events'
      key :description, 'Occuring at venues between specific times'
    end
    tag do
      key :name, 'roles'
      key :description, 'Assigned to users to carry out at events'
    end
    tag do
      key :name, 'venues'
      key :description, 'Places where staff are assigned to events'
    end
    key :host, ENV['API_HOST_NAME'] || 'localhost:3000'
    key :basePath, '/'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    EventsController,
    Event,
    RolesController,
    Role,
    StaffController,
    Staff,
    VenuesController,
    Venue,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end