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
    {:ok, _pid} = Twitter.Client.start_link()
    IO.inspect _pid
    IO.inspect GenServer.cast(_pid, {:register, "Inqalab zindabad!"})
    end
end
