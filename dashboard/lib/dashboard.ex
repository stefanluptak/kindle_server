defmodule Dashboard do
  @moduledoc false
  alias Dashboard.Namesdays
  # styler:sort
  @type t :: %__MODULE__{
          season: String.t(),
          part_of_day: String.t(),
          day_name: String.t(),
          month_name: String.t(),
          full_date: String.t(),
          generated_at: String.t(),
          calendar: [{atom(), pos_integer()}],
          namesday: String.t(),
          days_until_matys_birthday: non_neg_integer(),
          days_until_moms_birthday: non_neg_integer(),
          days_until_dads_birthday: non_neg_integer(),
          days_until_school: non_neg_integer()
        }

  # styler:sort
  defstruct [
    :calendar,
    :day_name,
    :full_date,
    :generated_at,
    :month_name,
    :namesday,
    :part_of_day,
    :season,
    :days_until_matys_birthday,
    :days_until_moms_birthday,
    :days_until_dads_birthday,
    :days_until_school
  ]

  @spec new(DateTime.t() | nil) :: t()
  def new(now \\ nil) do
    now = now || now()
    today = DateTime.to_date(now)

    # styler:sort
    %__MODULE__{
      calendar: calendar(today),
      day_name: day_name(today),
      full_date: full_date(now),
      generated_at: Calendar.strftime(now, "%H:%M"),
      month_name: month_name(today),
      namesday: namesday(today),
      part_of_day: part_of_day(now),
      season: season(today),
      days_until_matys_birthday: days_until(today, 03, 13),
      days_until_moms_birthday: days_until(today, 08, 24),
      days_until_dads_birthday: days_until(today, 12, 05),
      days_until_school: days_until(today, 09, 01)
    }
  end

  @spec render(t()) :: String.t()
  def render(%__MODULE__{} = dashboard) do
    assigns = Map.from_struct(dashboard)
    typ = EEx.eval_file("../image.typ.eex", assigns: assigns)

    File.write!("image.typ", typ)
  end

  @spec calendar(Date.t()) :: []
  def calendar(today) do
    from =
      today
      |> Date.beginning_of_month()
      |> Date.beginning_of_week()

    to =
      today
      |> Date.end_of_month()
      |> Date.end_of_week()

    current_day = today.day
    current_month = today.month

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

  @spec namesday(Date.t()) :: String.t()
  def namesday(today) do
    String.upcase(Namesdays.get_name!(today))
  end

  @spec now :: DateTIme.t()
  def now do
    Calendar.put_time_zone_database(Tzdata.TimeZoneDatabase)

    DateTime.utc_now()
    |> DateTime.shift_zone!("Europe/Bratislava")
    |> DateTime.truncate(:second)
  end

  @spec day_of_week_index(Date.t()) :: pos_integer()
  defp day_of_week_index(today) do
    Date.day_of_week(today)
  end

  @spec day_name(Date.t()) :: String.t()
  def day_name(today) do
    Enum.at(
      [nil, "PONDELOK", "UTOROK", "STREDA", "ŠTVRTOK", "PIATOK", "SOBOTA", "NEDEĽA"],
      day_of_week_index(today)
    )
  end

  @spec month_name(Date.t()) :: String.t()
  def month_name(today) do
    Enum.at(
      [
        nil,
        "JANUÁR",
        "FEBRUÁR",
        "MAREC",
        "APRÍL",
        "MÁJ",
        "JÚN",
        "JÚL",
        "AUGUST",
        "SEPTEMBER",
        "OKTÓBER",
        "NOVEMBER",
        "DECEMBER"
      ],
      today.month
    )
  end

  @spec part_of_day(DateTime.t()) :: String.t()
  defp part_of_day(now) do
    {hour, _minute, _second} = now |> DateTime.to_time() |> Time.to_erl()

    cond do
      hour < 7 -> "NOC"
      hour < 9 -> "RÁNO"
      hour < 12 -> "DOOBEDA"
      hour < 18 -> "POOBEDE"
      hour < 21 -> "VEČER"
      true -> "NOC"
    end
  end

  @spec season(Date.t()) :: String.t()
  defp season(today) do
    {_year, month, day} = Date.to_erl(today)

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

  @spec full_date(Date.t()) :: String.t()
  defp full_date(today) do
    month_name = month_name(today)
    Calendar.strftime(today, "#{month_name} %Y")
  end

  @spec days_until(Date.t(), pos_integer(), pos_integer()) :: non_neg_integer()
  defp days_until(today, month, day) do
    this_year_date = Date.new!(today.year, month, day)
    diff = Date.diff(this_year_date, today)

    if diff >= 0 do
      diff
    else
      next_year_date = Date.new!(today.year + 1, month, day)
      Date.diff(next_year_date, today)
    end
  end
end
