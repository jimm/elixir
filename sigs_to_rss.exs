#!/usr/bin/env elixir
#
# usage: sigs_to_rss.exs [sigfile]
#
# Default sigfile is $pim/signatures.

defmodule SigsToRSS do
  @sigfile Path.join(System.get_env("pim"), "signatures")

  def generate(sigfile \\ @sigfile) do
    IO.puts(header())
    sigfile |> read_sigs |> Enum.map(&sig_to_item/1) |> Enum.map(&IO.puts/1)
    IO.puts(footer())
  end

  defp read_sigs(sigfile) do
    File.read!(sigfile)
    |> String.split("\n\n")
    |> Enum.map(&String.trim/1)
  end

  defp header do
    tstamp = format_utc_timestamp()

    """
    <!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN" "http://www.rssboard.org/rss-0.91.dtd">
    <rss version='0.91'>
      <channel>
        <title>Jim's Signature Collection</title>
        <link>http://www.jimmenard.com/sigs.html/</link>
        <description>Jim Menard's Signature Collection</description>
        <language>en-us</language>
        <webMaster>jim@jimmenard.com</webMaster>
        <managingEditor>jim@jimmenard.com</managingEditor>
        <pubDate>#{tstamp}</pubDate>
        <lastBuildDate>#{tstamp}</lastBuildDate>
    """
  end

  defp sig_to_item(sig) when is_binary(sig) do
    """
        <item>
          <title>.sig quote</title>
          <description><![CDATA[#{sig}]]></description>
          <link>http://www.jimmenard.com/sigs.html</link>
        </item>
    """
  end

  defp footer do
    """
      </channel>
    </rss>
    """
  end

  defp format_utc_timestamp do
    ts = :os.timestamp()

    {date = {year, month, day}, {hour, minute, second}} =
      :calendar.now_to_universal_time(ts)

    mstr =
      Enum.at(
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        month - 1
      )

    dstr =
      Enum.at(
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
        :calendar.day_of_the_week(date) - 1
      )

    :io_lib.format(
      "~s, ~2..0w ~s ~4w ~2w:~2..0w:~2..0w UTC",
      [dstr, day, mstr, year, hour, minute, second]
    )
    |> List.flatten()
    |> List.to_string()
  end
end

if length(System.argv()) == 0 do
  SigsToRSS.generate()
else
  SigsToRSS.generate(hd(System.argv()))
end
