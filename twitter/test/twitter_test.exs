
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
      Process.register(_pid, String.to_atom("@adicool"))
      GenServer.cast(_pid, {:register, "@adicool"})
      query = from u in "user_profile", where: u.userID == "@adicool", select: u.userID
      :timer.sleep(1000)
      lst = Twitter.Repo.all(query)
      assert lst == ["@adicool"]
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "registration single user check 3" do
      Twitter.Starter.engineStarter()
      query = from u in "user_profile", where: u.userID == "@adicool", select: u.userID
      :timer.sleep(1000)
      lst = Twitter.Repo.all(query)
      refute lst == ["@adicool"]
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
      Process.register(_pid, String.to_atom("@adicool"))
      GenServer.cast(_pid, {:subscribe, "@adicool", ["@apuchand"]})
      :timer.sleep(2000)
      query = from(u in "subscribers", where: u.userID == "@adicool", select: u.follower) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert lst == ["@apuchand"]
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "subcriber single user check 3" do
      Twitter.Starter.engineStarter()
      {:ok, _pid} = Twitter.Client.start_link()
      Process.register(_pid, String.to_atom("@adicool"))
      GenServer.cast(_pid, {:subscribe, "@adicool", ["@apuchand", "@sonal_the_golu","@anagha_joshi"]})
      :timer.sleep(2000)
      query = from(u in "subscribers", where: u.userID == "@adicool", select: u.follower) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert length(lst) == 3
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end
    
    test "tweet single user multiple subscribers check 1" do
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@adicool"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@sonal_the_golu"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@anagha_joshi"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@nishshri"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@adicool"})
      GenServer.cast(pid2, {:register, "@sonal_the_golu"})
      GenServer.cast(pid3, {:register, "@anagha_joshi"})
      GenServer.cast(pid4, {:register, "@nishshri"})
      GenServer.cast(pid1, {:subscribe, "@adicool", ["@apuchand", "@sonal_the_golu","@anagha_joshi","@nishshri"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets", "@adicool"})
      :timer.sleep(2000)
      query = from(u in "user", select: u.userID) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert length(lst) == 4
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "tweet single user multiple subscribers mentions check 2" do
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@adicool"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@sonal_the_golu"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@anagha_joshi"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@nishshri"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@adicool"})
      GenServer.cast(pid2, {:register, "@sonal_the_golu"})
      GenServer.cast(pid3, {:register, "@anagha_joshi"})
      GenServer.cast(pid4, {:register, "@nishshri"})
      GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets for @sonal_the_golu", "@adicool"})
      :timer.sleep(2000)
      query = from(u in "user", where: u.userID == "@sonal_the_golu", select: u.tweets) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert List.first(lst) == "Mentioned by: @adicool Tweet: Tweets for @sonal_the_golu"
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "tweet single user multiple subscribers check 3" do
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@adicool"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@sonal_the_golu"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@anagha_joshi"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@nishshri"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@adicool"})
      GenServer.cast(pid2, {:register, "@sonal_the_golu"})
      GenServer.cast(pid3, {:register, "@anagha_joshi"})
      GenServer.cast(pid4, {:register, "@nishshri"})
      GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets", "@adicool"})
      :timer.sleep(2000)
      query = from(u in "user", where: u.userID == "@sonal_the_golu", select: u.tweets) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      refute List.first(lst) == "Tweets"
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
    end

    test "tweet multiple user multiple subscribers check 1" do
      Twitter.Starter.engineStarter()
      {:ok, pid1} = Twitter.Client.start_link()
      Process.register(pid1, String.to_atom("@adicool"))
      {:ok, pid2} = Twitter.Client.start_link()
      Process.register(pid2, String.to_atom("@sonal_the_golu"))
      {:ok, pid3} = Twitter.Client.start_link()
      Process.register(pid3, String.to_atom("@anagha_joshi"))
      {:ok, pid4} = Twitter.Client.start_link()
      Process.register(pid4, String.to_atom("@nishshri"))
      :timer.sleep(1000)
      GenServer.cast(pid1, {:register, "@adicool"})
      GenServer.cast(pid2, {:register, "@sonal_the_golu"})
      GenServer.cast(pid3, {:register, "@anagha_joshi"})
      GenServer.cast(pid4, {:register, "@nishshri"})
      GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
      GenServer.cast(pid2, {:subscribe, "@sonal_the_golu", ["@adicool","@nishshri"]})
      GenServer.cast(pid3, {:subscribe, "@anagha_joshi", ["@adicool","@sonal_the_golu"]})
      GenServer.cast(pid4, {:subscribe, "@nishshri", ["@adicool", "@anagha_joshi"]})
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya", "@adicool"})
      GenServer.cast(Process.whereis(String.to_atom("@sonal_the_golu")), {:tweet, "Tweets from golu", "@sonal_the_golu"})
      GenServer.cast(Process.whereis(String.to_atom("@anagha_joshi")), {:tweet, "Tweets from anagha", "@anagha_joshi"})
      GenServer.cast(Process.whereis(String.to_atom("@nishshri")), {:tweet, "Tweets from nishshri", "@nishshri"})
      :timer.sleep(2000)
      query = from(u in "user", select: u.tweets) 
      lst = Twitter.Repo.all(query)
      :timer.sleep(1000)
      assert length(lst) == 12
      from(x in "subscribers") |> Twitter.Repo.delete_all
      from(x in "user") |> Twitter.Repo.delete_all
      from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet multiple user multiple subscribers check 2" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid2} = Twitter.Client.start_link()
    Process.register(pid2, String.to_atom("@sonal_the_golu"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid2, {:register, "@sonal_the_golu"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
    GenServer.cast(pid2, {:subscribe, "@sonal_the_golu", ["@adicool","@nishshri"]})
    GenServer.cast(pid3, {:subscribe, "@anagha_joshi", ["@adicool","@sonal_the_golu"]})
    GenServer.cast(pid4, {:subscribe, "@nishshri", ["@adicool", "@anagha_joshi"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya", "@adicool"})
    GenServer.cast(Process.whereis(String.to_atom("@sonal_the_golu")), {:tweet, "Tweets from golu", "@sonal_the_golu"})
    GenServer.cast(Process.whereis(String.to_atom("@anagha_joshi")), {:tweet, "Tweets from anagha", "@anagha_joshi"})
    GenServer.cast(Process.whereis(String.to_atom("@nishshri")), {:tweet, "Tweets from nishshri", "@nishshri"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.userID == "@sonal_the_golu", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert length(lst) == 2
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet multiple user multiple subscribers check 3" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid2} = Twitter.Client.start_link()
    Process.register(pid2, String.to_atom("@sonal_the_golu"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid2, {:register, "@sonal_the_golu"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
    GenServer.cast(pid2, {:subscribe, "@sonal_the_golu", ["@adicool","@nishshri"]})
    GenServer.cast(pid3, {:subscribe, "@anagha_joshi", ["@adicool","@sonal_the_golu"]})
    GenServer.cast(pid4, {:subscribe, "@nishshri", ["@adicool", "@anagha_joshi"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya", "@adicool"})
    GenServer.cast(Process.whereis(String.to_atom("@sonal_the_golu")), {:tweet, "Tweets from golu", "@sonal_the_golu"})
    GenServer.cast(Process.whereis(String.to_atom("@anagha_joshi")), {:tweet, "Tweets from anagha", "@anagha_joshi"})
    GenServer.cast(Process.whereis(String.to_atom("@nishshri")), {:tweet, "Tweets from nishshri", "@nishshri"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.userID == "@sonal_the_golu", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert lst -- ["Tweets from anagha", "Tweets from golu"] == []
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
  end

  test "tweet single user multiple subscribers hashtags check 1" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya, #Azadi", "@adicool"})
    :timer.sleep(2000)
    query = from(u in "hashtags", select: u.tags) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert length(lst) == 1
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "tweet single user multiple subscribers multiple hashtags check 2" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya, #Azadi #BoloAzadi #UFL #DOS", "@adicool"})
    :timer.sleep(2000)
    query = from(u in "hashtags", select: u.tags) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert length(lst) == 4
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "tweet multiple user multiple subscribers multiple hashtags check 3" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
    GenServer.cast(pid1, {:subscribe, "@anagha_joshi", ["@adicool","@nishshri"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya, #Azadi #BoloAzadi #UFL #DOS", "@adicool"})
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Anagha, #Azadi #BoloAzadi #UFL #DOS", "@adicool"})
    :timer.sleep(2000)
    query = from(u in "hashtags", select: u.tags) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert length(lst) == 8
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "retweet single user multiple subscribers hashtags check 1" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi","@nishshri"]})
    GenServer.cast(pid1, {:subscribe, "@anagha_joshi", ["@adicool","@nishshri"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya, #Azadi", "@adicool"})
    :timer.sleep(1000)
    GenServer.cast(Process.whereis(String.to_atom("@anagha_joshi")), {:retweet, "@anagha_joshi"})
    :timer.sleep(2000)
    query = from(u in "user", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert length(lst) == 6
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

  test "retweet single user multiple subscribers hashtags check 2" do
    Twitter.Starter.engineStarter()
    {:ok, pid1} = Twitter.Client.start_link()
    Process.register(pid1, String.to_atom("@adicool"))
    {:ok, pid3} = Twitter.Client.start_link()
    Process.register(pid3, String.to_atom("@anagha_joshi"))
    {:ok, pid4} = Twitter.Client.start_link()
    Process.register(pid4, String.to_atom("@nishshri"))
    :timer.sleep(1000)
    GenServer.cast(pid1, {:register, "@adicool"})
    GenServer.cast(pid3, {:register, "@anagha_joshi"})
    GenServer.cast(pid4, {:register, "@nishshri"})
    GenServer.cast(pid1, {:subscribe, "@adicool", ["@anagha_joshi"]})
    GenServer.cast(pid1, {:subscribe, "@anagha_joshi", ["@adicool","@nishshri"]})
    :timer.sleep(2000)
    GenServer.cast(Process.whereis(String.to_atom("@adicool")), {:tweet, "Tweets from Aditya, #Azadi", "@adicool"})
    :timer.sleep(1000)
    GenServer.cast(Process.whereis(String.to_atom("@anagha_joshi")), {:retweet, "@anagha_joshi"})
    :timer.sleep(2000)
    query = from(u in "user", where: u.userID == "@nishshri", select: u.tweets) 
    lst = Twitter.Repo.all(query)
    :timer.sleep(1000)
    assert lst == ["Retweet: Tweets from Aditya, #Azadi"]
    from(x in "subscribers") |> Twitter.Repo.delete_all
    from(x in "user") |> Twitter.Repo.delete_all
    from(x in "user_profile") |> Twitter.Repo.delete_all
    from(x in "hashtags") |> Twitter.Repo.delete_all
  end

end