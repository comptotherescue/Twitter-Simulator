defmodule Twitter.User do
    use Ecto.Schema
  
    @primary_key {:userID, :string, autogenerate: false}
    schema "user" do
      field :tweets, :string
      field :read, :integer
    end


    def changeset(user, params \\ %{}) do
        user
        |> Ecto.Changeset.cast(params, [:userID, :tweets, :read])
        |> Ecto.Changeset.validate_required([:userID, :tweets, :read])

      end
  end