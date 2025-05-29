local config = {
  optimize_with_svgo = true,
  default_output_type = "jsx",
  default_output_location = "./generated",
  use_specified_location = true,
  specified_location = "./src/icons",
  allow_typescript = true,
  prettify = false
}

function config.set(key, value)
  config[key] = value
end

function config.get(key)
  return config[key]
end

return config
