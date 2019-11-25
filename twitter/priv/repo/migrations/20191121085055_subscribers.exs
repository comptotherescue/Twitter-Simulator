defmodule Twitter.Repo.Migrations.Subscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :userID, :string, primary_key: true
      add :follower, :string
  end

  end
end
