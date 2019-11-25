import Config

config :twitter, Twitter.Repo,
  database: "twitter_repo",
  username: "postgres",
  password: "abcd",
  hostname: "localhost"
  


config :logger, level: :info  

config :twitter, ecto_repos: [Twitter.Repo]

