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
      key :name, 'staffs'
      key :description, 'Staff Management'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://swagger.io'
      end
    end
    key :host, 'localhost:3000'
    key :basePath, '/'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    StaffController,
    Staff,
    EventsController,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end