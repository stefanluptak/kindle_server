defmodule Dashboard do
  @moduledoc false

  # styler:sort
  @type t :: %__MODULE__{
          season: String.t(),
          part_of_day: String.t(),
          day_name: String.t(),
          month_name: String.t(),
          full_date: String.t(),
          generated_at: String.t(),
          calendar: [{atom(), pos_integer()}]
        }

  # styler:sort
  defstruct [
    :calendar,
    :day_name,
    :full_date,
    :generated_at,
    :month_name,
    :part_of_day,
    :season
  ]

  @spec new(DateTime.t() | nil) :: t()
  def new(now \\ nil) do
    now = now || now()

    # styler:sort
    %__MODULE__{
      calendar: calendar(now),
      day_name: day_name(now),
      full_date: full_date(now),
      generated_at: Calendar.strftime(now, "%d.%m.%Y o %H:%M"),
      month_name: month_name(now),
      part_of_day: part_of_day(now),
      season: season(now)
    }
  end

  @spec render(t()) :: String.t()
  def render(%__MODULE__{} = dashboard) do
    assigns = Map.from_struct(dashboard)
    typ = EEx.eval_file("../image.typ.eex", assigns: assigns)

    File.write!("image.typ", typ)
  end

  @spec calendar(DateTime.t()) :: []
  def calendar(now) do
    from =
      now
      |> DateTime.to_date()
      |> Date.beginning_of_month()
      |> Date.beginning_of_week()

    to =
      now
      |> DateTime.to_date()
      |> Date.end_of_month()
      |> Date.end_of_week()

    current_day = now.day
    current_month = now.month

    Enum.map(Date.range(from, to), fn date ->
      if date.month == current_month do
        if date.day == current_day do
          {:today, date.day}
        else
          if Date.day_of_week(date) in [6, 7] do
            {:weekend, date.day}
          else
            {:weekday, date.day}
          end
        end
      else
        if Date.day_of_week(date) in [6, 7] do
          {:other_weekend, date.day}
        else
          {:other_weekday, date.day}
        end
      end
    end)
  end

  @spec now :: DateTIme.t()
  defp now do
    Calendar.put_time_zone_database(Tzdata.TimeZoneDatabase)

    DateTime.utc_now()
    |> DateTime.shift_zone!("Europe/Bratislava")
    |> DateTime.truncate(:second)
  end

  @spec day_of_week_index(DateTime.t()) :: pos_integer()
  defp day_of_week_index(now) do
    now
    |> DateTime.to_date()
    |> Date.day_of_week()
  end

  @spec day_name(DateTime.t()) :: String.t()
  def day_name(now) do
    Enum.at(
      [nil, "PONDELOK", "UTOROK", "STREDA", "ŠTVRTOK", "PIATOK", "SOBOTA", "NEDEĽA"],
      day_of_week_index(now)
    )
  end

  @spec month_name(DateTime.t()) :: String.t()
  def month_name(now) do
    Enum.at(
      [
        nil,
        "JANUÁR",
        "FEBRUÁR",
        "MAREC",
        "APRÍL",
        "MÁJ",
        "JÚN",
        "SEPTEMBER",
        "OKTÓBER",
        "NOVEMBER",
        "DECEMBER"
      ],
      month_index(now)
    )
  end

  @spec month_index(DateTime.t()) :: pos_integer()
  def month_index(%DateTime{} = now) do
    now.month
  end

  @spec part_of_day(DateTime.t()) :: String.t()
  defp part_of_day(now) do
    {{_year, _month, _day}, {hour, minute, _second}} = to_erl(now)

    cond do
      hour < 6 -> "NOC"
      hour == 6 and minute < 30 -> "NOC"
      hour < 9 -> "RÁNO"
      hour < 12 -> "DOOBEDA"
      hour < 17 -> "POOBEDE"
      hour < 20 -> "VEČER"
      true -> "NOC"
    end
  end

  @spec season(DateTime.t()) :: String.t()
  defp season(now) do
    {{_year, month, day}, {_hour, _minute, _second}} = to_erl(now)

    cond do
      month < 3 -> "ZIMA"
      month == 3 and day < 20 -> "ZIMA"
      month < 6 -> "JAR"
      month == 6 and day < 21 -> "JAR"
      month < 9 -> "LETO"
      month == 9 and day < 23 -> "LETO"
      month < 12 -> "JESEŇ"
      month == 12 and day < 21 -> "JESEŇ"
      true -> "ZIMA"
    end
  end

  @spec full_date(DateTime.t()) :: String.t()
  defp full_date(now) do
    month_name = month_name(now)
    Calendar.strftime(now, "%d. #{month_name} %Y")
  end

  @spec to_erl(DateTime.t()) :: :calendar.date()
  defp to_erl(now) do
    now
    |> DateTime.to_naive()
    |> NaiveDateTime.to_erl()
  end
end
