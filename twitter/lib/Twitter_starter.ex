defmodule Twitter.Starter do
    use Supervisor
    def start(numNode, numRequest) do
        IO.puts "HI1"
        engineStarter()
        IO.puts "HI2"
        clientStarter(numNode, numRequest)
        :timer.sleep(5000)
        IO.puts "HI3"
      end

    def engineStarter do
      {:ok, _pid} = Twitter.Engine.start_link()
        IO.puts "Engine up"
        
    end

    def clientStarter(numNode, numRequest)do
    clientLst = []
    clientLst = Enum.map(1..numNode, fn x->
    {:ok, _pid} = Twitter.Client.start_link()
    handleName = "@User" <> inspect(_pid)
    Process.register(_pid, String.to_atom(handleName))
    handleName
    end)

    Enum.each(clientLst, fn x->
      IO.puts x
    IO.inspect GenServer.cast(Process.whereis(String.to_atom(x)), {:register, "Inqalab zindabad!", x, numRequest, clientLst})
    end)
    end
end
