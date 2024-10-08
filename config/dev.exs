import Config

transcode_backend = case System.get_env("MIX_TARGET") do
  "nvidia" -> Membrane.ABRTranscoder.Backends.Nvidia
  "xilinx" -> Membrane.ABRTranscoder.Backends.U30
   _ -> nil
end

config :algora,
  mode: :dev,
  resume_rtmp: !System.get_env("RESUME_RTMP"),
  supports_h265: !System.get_env("SUPPORTS_H265"),
  transcode: System.get_env("TRANSCODE"),
  transcode_backend: transcode_backend

config :algora, :buckets,
  media: System.get_env("BUCKET_MEDIA"),
  ml: System.get_env("BUCKET_ML")

config :algora, :github,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :algora, :restream,
  client_id: System.get_env("RESTREAM_CLIENT_ID"),
  client_secret: System.get_env("RESTREAM_CLIENT_SECRET")

config :algora, :event_sink, url: System.get_env("EVENT_SINK_URL")

config :ex_aws,
  # debug_requests: true,
  json_codec: Jason,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")

config :ex_aws, :s3,
  scheme: "https://",
  host:
    (with url when url != nil <- System.get_env("AWS_ENDPOINT_URL_S3"),
          host <- URI.parse(url).host do
       host
     else
       _ -> nil
     end),
  region: System.get_env("AWS_REGION")

config :ex_aws, :hackney_opts,
  timeout: 300_000,
  recv_timeout: 300_000

# Configure your database
config :algora, Algora.Repo,
  url: System.get_env("DATABASE_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log: false

config :algora, Algora.Repo.Local,
  url: System.get_env("DATABASE_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  priv: "priv/repo",
  log: false

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :algora, AlgoraWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000") ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:tv, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:tv, ~w(--watch)]}
  ]

config :algora, AlgoraWeb.Embed.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("EMBED_PORT") || "4001")]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :algora, AlgoraWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg|json)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/algora_web/(live|views)/.*(ex)$",
      ~r"lib/algora_web/templates/.*(eex)$"
    ]
  ]

config :algora, :docs, url: "http://localhost:3000"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

config :reverse_proxy_plug, :http_client, ReverseProxyPlug.HTTPClient.Adapters.HTTPoison
