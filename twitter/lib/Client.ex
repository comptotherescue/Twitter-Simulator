defmodule Twitter.Client do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__,"")
    end

    def init(state)do 
        {:ok, state}
    end

    def handle_cast({:register, tweet}, state)do
        
        handleName = "@User" <> inspect(self())
        IO.puts "Hawa"
        Process.register(self(), String.to_atom(handleName))
        GenServer.call(:E2 ,{:register, handleName, handleName, "UFL", 25, "abc@ufl.edu", "abc"})
        #GenServer.call(:E2, {:delete, handleName})
        GenServer.cast(:E2, {:subscribe, handleName, "@Adicool"})
        {:noreply, state}
    end
end