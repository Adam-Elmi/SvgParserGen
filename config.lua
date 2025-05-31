local allow_typescript = false

local config = {
  optimize_with_svgo = true,
  default_output_type = allow_typescript and "tsx" or "jsx",
  default_output_location = "",
  use_specified_location = true,
  specified_location = "./src/icons",
  import_as_default = false,
  default_component_name = "",
  use_same_name = true,
  template_attributes_to_include = {width = true, height = true},
  use_windows_format_path = true,
  accepted_extensions = {
    svg = true,
    jsx = true,
    tsx = true,
    astro = true
  },
  prettify = false
}


function config.set(key, value)
  config[key] = value
end

function config.get(key)
  return config[key]
end

return config
