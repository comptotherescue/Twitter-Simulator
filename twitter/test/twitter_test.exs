
import Ecto.Query
defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

    test "registration check 1" do
      Twitter.Starter.engineStarter()
      Twitter.Starter.startRegistration(10)
      query = from u in "user_profile", select: u.userID
      :timer.sleep(1000)
      lst = Twitter.Repo.all(query)
      assert length(lst) == 10
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "registration single user check 2" do
      Twitter.Starter.engineStarter()
      {:ok, _pid} = Twitter.Client.start_link()
      Process.register(_pid, String.to_atom("@user1"))
      GenServer.cast(_pid, {:register, "@user1"})
      query = from u in "user_profile", where: u.userID == "@user1", select: u.userID
      :timer.sleep(1000)
      lst = Twitter.Repo.all(query)
      assert lst == ["@user1"]
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "registration single user check 3" do
      Twitter.Starter.engineStarter()
      query = from u in "user_profile", where: u.userID == "@user1", select: u.userID
      :timer.sleep(1000)
      lst = Twitter.Repo.all(query)
      refute lst == ["@user1"]
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
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
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "subcriber single user check 2" do
      Twitter.Starter.engineStarter()
      {:ok, _pid} = Twitter.Client.start_link()
      Process.register(_pid, String.to_atom("@user1"))
      GenServer.cast(_pid, {:subscribe, "@user1", ["@user5"]})
      :timer.sleep(2000)
      query = from(u in "subscribers", where: u.userID == "@user1", select: u.follower) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert lst == ["@user5"]
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "subcriber single user check 3" do
      Twitter.Starter.engineStarter()
      {:ok, _pid} = Twitter.Client.start_link()
      Process.register(_pid, String.to_atom("@user1"))
      GenServer.cast(_pid, {:subscribe, "@user1", ["@user5", "@user2","@user3"]})
      :timer.sleep(2000)
      query = from(u in "subscribers", where: u.userID == "@user1", select: u.follower) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert length(lst) == 3
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end
    
    test "tweet single user multiple subscribers check 1" do
      coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
      Process.register(coverge_progress.pid, :supervisor)
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@user1"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@user2"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@user3"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@user4"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@user1"})
      GenServer.cast(pid2, {:register, "@user2"})
      GenServer.cast(pid3, {:register, "@user3"})
      GenServer.cast(pid4, {:register, "@user4"})
      GenServer.cast(pid1, {:subscribe, "@user1", ["@user5", "@user2","@user3","@user4"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets", "@user1"})
      :timer.sleep(2000)
      query = from(u in "user", select: u.userID) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      Task.await(coverge_progress, 10000000)
      assert length(lst) == 4
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "tweet single user multiple subscribers mentions check 2" do
      coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
      Process.register(coverge_progress.pid, :supervisor)
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@user1"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@user2"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@user3"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@user4"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@user1"})
      GenServer.cast(pid2, {:register, "@user2"})
      GenServer.cast(pid3, {:register, "@user3"})
      GenServer.cast(pid4, {:register, "@user4"})
      GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets for @user2", "@user1"})
      :timer.sleep(2000)
      query = from(u in "user", where: u.userID == "@user2", select: u.tweets) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      Task.await(coverge_progress, 10000000)
      assert List.first(lst) == "Mentioned by: @user1 Tweet: Tweets for @user2"
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "tweet single user multiple subscribers check 3" do
      coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
      Process.register(coverge_progress.pid, :supervisor)
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@user1"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@user2"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@user3"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@user4"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@user1"})
      GenServer.cast(pid2, {:register, "@user2"})
      GenServer.cast(pid3, {:register, "@user3"})
      GenServer.cast(pid4, {:register, "@user4"})
      GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets", "@user1"})
      :timer.sleep(2000)
      query = from(u in "user", where: u.userID == "@user2", select: u.tweets) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      Task.await(coverge_progress, 10000000)
      refute List.first(lst) == "Tweets"
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "tweet multiple user multiple subscribers check 1" do
      coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(4) end)
      Process.register(coverge_progress.pid, :supervisor)
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@user1"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@user2"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@user3"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@user4"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@user1"})
      GenServer.cast(pid2, {:register, "@user2"})
      GenServer.cast(pid3, {:register, "@user3"})
      GenServer.cast(pid4, {:register, "@user4"})
      GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
      GenServer.cast(pid2, {:subscribe, "@user2", ["@user1","@user4"]})
      GenServer.cast(pid3, {:subscribe, "@user3", ["@user1","@user2"]})
      GenServer.cast(pid4, {:subscribe, "@user4", ["@user1", "@user3"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1", "@user1"})
      GenServer.cast(Process.whereis(String.to_atom("@user2")), {:tweet, "Tweets from user 2", "@user2"})
      GenServer.cast(Process.whereis(String.to_atom("@user3")), {:tweet, "Tweets from user 3", "@user3"})
      GenServer.cast(Process.whereis(String.to_atom("@user4")), {:tweet, "Tweets from user 4", "@user4"})
      :timer.sleep(2000)
      query = from(u in "user", select: u.tweets) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      Task.await(coverge_progress, 10000000)
      assert length(lst) == 12
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet multiple user multiple subscribers check 2" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(4) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid2} = Twitter.Client.start_link()
    Process.register(pid2, String.to_atom("@user2"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid2, {:register, "@user2"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
    GenServer.cast(pid2, {:subscribe, "@user2", ["@user1","@user4"]})
    GenServer.cast(pid3, {:subscribe, "@user3", ["@user1","@user2"]})
    GenServer.cast(pid4, {:subscribe, "@user4", ["@user1", "@user3"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1", "@user1"})
    GenServer.cast(Process.whereis(String.to_atom("@user2")), {:tweet, "Tweets from user 2", "@user2"})
    GenServer.cast(Process.whereis(String.to_atom("@user3")), {:tweet, "Tweets from user 3", "@user3"})
    GenServer.cast(Process.whereis(String.to_atom("@user4")), {:tweet, "Tweets from user 4", "@user4"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.userID == "@user2", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 2
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet multiple user multiple subscribers check 3" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(4) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid2} = Twitter.Client.start_link()
    Process.register(pid2, String.to_atom("@user2"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid2, {:register, "@user2"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
    GenServer.cast(pid2, {:subscribe, "@user2", ["@user1","@user4"]})
    GenServer.cast(pid3, {:subscribe, "@user3", ["@user1","@user2"]})
    GenServer.cast(pid4, {:subscribe, "@user4", ["@user1", "@user3"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1", "@user1"})
    GenServer.cast(Process.whereis(String.to_atom("@user2")), {:tweet, "Tweets from user 2", "@user2"})
    GenServer.cast(Process.whereis(String.to_atom("@user3")), {:tweet, "Tweets from user 3", "@user3"})
    GenServer.cast(Process.whereis(String.to_atom("@user4")), {:tweet, "Tweets from user 4", "@user4"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.userID == "@user2", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert lst -- ["Tweets from user 3", "Tweets from user 2"] == []
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet single user multiple subscribers hashtags check 1" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1, #Azadi", "@user1"})
    :timer.sleep(2000)
    query = from(u in "hashtags", select: u.tags) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 1
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "tweet single user multiple subscribers multiple hashtags check 2" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1, #Azadi #BoloAzadi #UFL #DOS", "@user1"})
    :timer.sleep(2000)
    query = from(u in "hashtags", select: u.tags) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 4
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "tweet multiple user multiple subscribers multiple hashtags check 3" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(2) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
    GenServer.cast(pid1, {:subscribe, "@user3", ["@user1","@user4"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1, #Azadi #BoloAzadi #UFL #DOS", "@user1"})
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 3, #Azadi #BoloAzadi #UFL #DOS", "@user1"})
    :timer.sleep(2000)
    query = from(u in "hashtags", select: u.tags) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 8
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "retweet single user multiple subscribers hashtags check 1" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3","@user4"]})
    GenServer.cast(pid1, {:subscribe, "@user3", ["@user1","@user4"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1, #Azadi", "@user1"})
    :timer.sleep(1000)
    GenServer.cast(Process.whereis(String.to_atom("@user3")), {:retweet, "@user3"})
    :timer.sleep(2000)
    query = from(u in "user", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 6
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "retweet single user multiple subscribers hashtags check 2" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user3"]})
    GenServer.cast(pid1, {:subscribe, "@user3", ["@user1","@user4"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets from user 1, #Azadi", "@user1"})
    :timer.sleep(1000)
    GenServer.cast(Process.whereis(String.to_atom("@user3")), {:retweet, "@user3"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.userID == "@user4", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert lst == ["Retweet: Tweets from user 1, #Azadi"]
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "tweet single user multiple subscribers with some subscribers offline check 1" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid2} = Twitter.Client.start_link()
    Process.register(pid2, String.to_atom("@user2"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid2, {:register, "@user2"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user2","@user3","@user4"]})
    GenServer.cast(Process.whereis(String.to_atom("@user2")), {:changestatus, "@user2", false})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets", "@user1"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.read == 1, select: u.userID) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 3
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet single user multiple subscribers with some subscribers offline check 2" do
    coverge_progress = Task.async(fn -> Twitter.Starter.converge_progress(1) end)
    Process.register(coverge_progress.pid, :supervisor)
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@user1"))
    {:ok, pid2} = Twitter.Client.start_link()
    Process.register(pid2, String.to_atom("@user2"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@user3"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@user4"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@user1"})
    GenServer.cast(pid2, {:register, "@user2"})
    GenServer.cast(pid3, {:register, "@user3"})
    GenServer.cast(pid4, {:register, "@user4"})
    GenServer.cast(pid1, {:subscribe, "@user1", ["@user2","@user3","@user4"]})
    GenServer.cast(Process.whereis(String.to_atom("@user2")), {:changestatus, "@user2", false})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@user1")), {:tweet, "Tweets", "@user1"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.read == 1, select: u.userID) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    Task.await(coverge_progress, 10000000)
    assert length(lst) == 3
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
  end
end