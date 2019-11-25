defmodule Twitter.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:user) do
        add :userID, :string, primary_key: true
        add :tweets, :string
        add :read, :integer
    end
  end
end
