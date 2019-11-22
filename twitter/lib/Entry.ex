defmodule Twitter.Entry do
    def main(args) do
        cond do
        length(args) == 2 ->
            numUser = Enum.at(args, 0)
            numMsg = Enum.at(args, 1)
            Twitter.Starter.start(String.to_integer(numUser), String.to_integer(numMsg))
        true -> IO.puts("Argument error!")
    end 
    end
end