Mix.install([:tzdata])

Calendar.put_time_zone_database(Tzdata.TimeZoneDatabase)

now = 
  DateTime.utc_now()
  |> DateTime.shift_zone!("Europe/Bratislava")
  |> DateTime.truncate(:second)

assigns = [
  name: "Alice",
  time: Time.to_iso8601(now)
]

typ = EEx.eval_file("image.typ.eex" , assigns: assigns)

File.write!("image.typ", typ)
