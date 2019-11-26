
import Ecto.Query
defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  test "greets the world" do
    assert Twitter.hello() == :world
  end

  test "registration check 1" do
    Twitter.Starter.engineStarter()
    Twitter.Starter.startRegistration(10)
    query = from u in "user_profile", select: u.userID
    :timer.sleep(1000)
    lst = Twitter.Repo.all(query)
    assert length(lst) == 10
    GenServer.cast(Process.whereis(String.to_atom(List.first(lst))), {:delete, lst})
    :timer.sleep(1000)
  end

  test "registration single user check 2" do
    Twitter.Starter.engineStarter()
    {:ok, _pid} = Twitter.Client.start_link()
    Process.register(_pid, String.to_atom("@adicool"))
    GenServer.cast(_pid, {:register, "@adicool"})
    query = from u in "user_profile", where: u.userID == "@adicool", select: u.userID
    :timer.sleep(1000)
    lst = Twitter.Repo.all(query)
    assert lst == ["@adicool"]
    GenServer.cast(Process.whereis(String.to_atom(List.first(lst))), {:delete, lst})
    :timer.sleep(1000)
  end

  test "registration single user check 3" do
    Twitter.Starter.engineStarter()
    query = from u in "user_profile", where: u.userID == "@adicool", select: u.userID
    :timer.sleep(1000)
    lst = Twitter.Repo.all(query)
    refute lst == ["@adicool"]
  end

  test "subcriber single user check 1" do
    Twitter.Starter.engineStarter()
    Twitter.Starter.subscriber(10)
    :timer.sleep(1000)
    query = from(u in "subscribers", select: u.follower)
    lst = Twitter.Repo.all(query)
    assert length(lst) == 20
    GenServer.cast(Process.whereis(String.to_atom(List.first(lst))), {:delete, lst})
    from(x in "subscribers") |> Twitter.Repo.delete_all
    :timer.sleep(5000)
  end


end
