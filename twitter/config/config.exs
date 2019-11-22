import Config

config :twitter, Twitter.Repo,
  database: "twitter_repo",
  username: "postgres",
  password: "abcd",
  hostname: "localhost"
  

config :twitter, ecto_repos: [Twitter.Repo]

