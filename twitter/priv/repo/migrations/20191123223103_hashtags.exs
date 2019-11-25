defmodule Twitter.Repo.Migrations.Hashtags do
  use Ecto.Migration

  def change do
    create table(:hashtags) do
      add :tags, :string, primary_key: true
      add :tweet, :string
      add :handle, :string
    end
  end
end
