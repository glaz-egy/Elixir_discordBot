defmodule DiscordBot.Application do
  use Application

  defmodule Commands do
    use Alchemy.Cogs

    Cogs.def debag do
      {:ok, input} = Cogs.guild_id()
      Cogs.say(input)
    end

    Cogs.def dice do
      dices = 1..2 |> Enum.map(fn _ -> 1..6 |> Enum.random end)
      result = dices |> Enum.sum
      Cogs.say("[#{dices |> Enum.join(",")}] 合計:#{result}")
    end
    
    Cogs.def play(url) do
      {:ok, guild_id} = Cogs.guild_id()
      music_channel = Application.get_env(:discord_bot, :music_channel)
      Alchemy.Voice.join(guild_id, music_channel[guild_id])
      Alchemy.Voice.play_url(guild_id, url, [{:vol, 10}])
      Cogs.say "Now playing #{tracks}"
    end

    Cogs.def play do
      {:ok, guild_id} = Cogs.guild_id()
      music_channel = Application.get_env(:discord_bot, :music_channel)
      {:ok, trakfile} = File.read("../playlist.txt")
      tracks = String.split(trakfile, "\n")
      tracks = List.delete(tracks, "")
      Alchemy.Voice.join(guild_id, music_channel[guild_id])
      Enum.map(tracks, fn track ->
        Alchemy.Voice.play_url(guild_id, track, [{:vol, 10}])
        Cogs.say "Now playing #{track}"
        Alchemy.Voice.wait_for_end(guild_id)
      end)
    end

    """
    Cogs.def play(url) do
      {:ok, guild_id} = Cogs.guild_id()
      music_channel = Application.get_env(:discord_bot, :music_channel)
      Alchemy.Voice.join(guild_id, music_channel)
      Enum.map(tracks, fn track ->
        Alchemy.Voice.play_file(guild_id, track)
        Alchemy.Voice.wait_for_end(guild_id)
      end)
    end
"""
    Cogs.def add(url)do
      :ok = File.write("../playlist.txt", url<>"\n", [:append])
    end

    Cogs.def viewlist do
      {:ok, tracks} = File.read("../playlist.txt")
      Cogs.say("`"<>tracks<>"`")
    end

    Cogs.def delete(url) do
      {:ok, trakfile} = File.read("../playlist.txt")
      File.write("../playlist.txt", "")
      tracks = String.split(trakfile, "\n")
      tracks = List.delete(tracks, "")
      tracks = List.delete(tracks, url)
      Enum.map(tracks, fn track ->
        File.write("../playlist.txt", track<>"\n", [:append])
      end)
    end

    Cogs.def mleave() do
      {:ok, guild_id} = Cogs.guild_id()
      Alchemy.Voice.leave(guild_id)
    end

    Cogs.def dice(roll) do
      case Regex.run(~r/\A(\d|[1-9]\d+)d(\d|[1-9]\d+)\z/, roll) do
        [_, n, m] ->
          num = n |> String.to_integer
          face = m |> String.to_integer

          cond do
            num <= 0 || num > 100 ->
              Cogs.say("個数は1以上、100以下にしてください")
            face <= 0 || face > 1000 ->
              Cogs.say("面数は1以上、1000以下にしてください")
            true ->
              dices = 1..num |> Enum.map(fn _ -> 1..face |> Enum.random end)
              result = dices |> Enum.sum
              Cogs.say("[#{dices |> Enum.join(",")}] 合計:#{result}")
          end
        _ ->
          Cogs.say("ndmの形式で入力してください")
      end
    end
  end

  def start(_, _) do
    token = Application.get_env(:discord_bot, :discord_token)
    run = Alchemy.Client.start(token)
    Alchemy.Cogs.set_prefix(";")
    use Commands
    run
  end
end