class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    # Make a distinction between the APIs and API documentation paths.
    "apidocs/#{path}"
  end
end

Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/apidocs",
    # controller_base_path: '',
    # the URL base path to your API
    :base_path => "http://localhost:3000",
    # if you want to delete all .json files at each generation
    :clean_directory => false,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "Kakama API documentation",
        "description" => "Here is the documentation for the API",
        "termsOfServiceUrl" => "",
        "contact" => "",
        "license" => "AGPL 3.0",
        "licenseUrl" => "http://www.gnu.org/licenses/gpl-3.0.txt"
      }
    }
  }
})