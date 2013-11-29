module ApiModel
  module RestMethods

    def api_host=(api_host)
      @api_host = api_host
    end

    def api_host
      @api_host || ""
    end

    def get_json(path, options={})
      # TODO - tidy this up...
      builder = options.delete(:builder) || self
      options[:api_host] = api_host

      HttpRequest.run(options.merge(path: path)).build_objects builder
    end

  end
end