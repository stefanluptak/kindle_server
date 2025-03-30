assigns = [
  day_name: day_name,
  date: date,
  part_of_day: part_of_day,
  season: season,
  generated_at: Calendar.strftime(now, "%d.%m.%Y o %H:%M")
]

typ = EEx.eval_file("image.typ.eex", assigns: assigns)

File.write!("image.typ", typ)
