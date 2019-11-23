defmodule Twitter.Client do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__,[])
    end

    def init(state)do 
        {:ok, state}
    end

    def handle_cast({:register, tweet, handleName, numRequest, clientLst}, state)do
        IO.puts handleName
        GenServer.call(:E2 ,{:register, handleName, handleName, "UFL", 25, "abc@ufl.edu", "abc"})
        #GenServer.call(:E2, {:delete, handleName})
        #GenServer.cast(:E2, {:subscribe, handleName, handleName})
        GenServer.cast(:E2, {:tweet, handleName, tweet})
        {:noreply, state}
    end

    def handle_cast({:tweetrec, tweet, handleName}, state)do
        IO.puts tweet
        {:noreply, state}
    end
end