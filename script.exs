Mix.install([:tzdata])

Calendar.put_time_zone_database(Tzdata.TimeZoneDatabase)

now =
  DateTime.utc_now()
  |> DateTime.shift_zone!("Europe/Bratislava")
  |> DateTime.truncate(:second)

day_of_week_index = String.to_integer(Calendar.strftime(now, "%u"))

day_name =
  Enum.at(
    [nil, "PONDELOK", "UTOROK", "STREDA", "ŠTVRTOK", "PIATOK", "SOBOTA", "NEDEĽA"],
    day_of_week_index
  )

month_index = String.to_integer(Calendar.strftime(now, "%m"))

month_name =
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
    month_index
  )

date = Calendar.strftime(now, "%d. #{month_name} %Y")

{{_year, month, day}, {hour, minute, _second}} =
  now |> DateTime.to_naive() |> NaiveDateTime.to_erl()

part_of_day =
  cond do
    hour < 6 -> "NOC"
    hour == 6 and minute < 30 -> "NOC"
    hour < 9 -> "RÁNO"
    hour < 12 -> "DOOBEDA"
    hour < 17 -> "POOBEDE"
    hour < 20 -> "VEČER"
    true -> "NOC"
  end

season =
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

assigns = [
  day_name: day_name,
  date: date,
  part_of_day: part_of_day,
  season: season,
  generated_at: Calendar.strftime(now, "%d.%m.%Y o %H:%M")
]

typ = EEx.eval_file("image.typ.eex" , assigns: assigns)

File.write!("image.typ", typ)
