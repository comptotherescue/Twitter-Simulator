defmodule Twitter.HandleUsers do
    use Ecto.Schema
    
    schema "user_profile" do
        field :userID, :string
        field :first_name, :string
        field :last_name, :string
        field :age, :integer
        field :email, :string
        field :password, :string
        field :status, :boolean
      end
  end