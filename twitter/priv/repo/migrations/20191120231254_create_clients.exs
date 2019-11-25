defmodule Twitter.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:user) do
        add :userID, :string
        add :tweets, :string
        add :read, :integer
    end
  end
end
