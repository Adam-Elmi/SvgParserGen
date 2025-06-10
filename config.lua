local allow_typescript = false

local config = {
  default_output_type = allow_typescript and "tsx" or "jsx",
  default_output_location = "./generated",
  use_specified_location = true,
  specified_location = "./src/icons",
  import_as_default = false,
  default_component_name = "",
  use_same_name = true,
  template_attributes_to_include = {width = true, height = true},
  use_windows_format_path = true,
}

return config
