# rubocop:disable Style/ClassAndModuleChildren
module PuppetX
  module Ploperations
    module ConsulData
      # methods used in multiple functions
      class Common
        # @summary Append API errors to an existing message
        #
        # Append API errors to an existing message
        #
        # @param message The message to which the errors should be appended
        # @param response The response object from the HTTP call
        # @return The original message with any errors appended
        def self.append_api_errors(message, response)
          errors = begin
                      JSON.parse(response.body)['errors']
                    rescue StandardError
                      nil
                    end
          message << " (api errors: #{errors})" if errors
        end

        # @summary Parse a url and ensure that a hostname can be extracted from it
        #
        # Parse a URI and ensure that a hostname can be extracted from it
        #
        # @param consul_url The url string that needs to be parsed
        # @return An object representing the url's parts
        def self.parse_consul_url(consul_url)
          uri = URI(consul_url)
          # URI is used here to just parse the consul_url into a host string
          # and port; it's possible to generate a URI::Generic when a scheme
          # is not defined, so double check here to make sure at least
          # host is defined.
          raise Puppet::Error, "Unable to parse a hostname from #{consul_url}" unless uri.hostname

          # Getting to here means no error was raised. Now we need to reference
          # the thing that we want returned to the caller: the uri variable.
          uri
        end
      end
    end
  end
end
