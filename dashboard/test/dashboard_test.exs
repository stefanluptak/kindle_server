defmodule DashboardTest do
  use ExUnit.Case

  describe "#new" do
  end

  describe "#namesday/1" do
    test "success" do
      assert Dashboard.namesday(~D[2025-03-30]) == "Vieroslava"
    end
  end

  describe "#calendar/1" do
    test "success" do
      now = ~U[2025-03-29 08:35:00Z]

      assert Dashboard.calendar(now) == [
               {:other_weekday, 24},
               {:other_weekday, 25},
               {:other_weekday, 26},
               {:other_weekday, 27},
               {:other_weekday, 28},
               {:weekend, 1},
               {:weekend, 2},
               {:weekday, 3},
               {:weekday, 4},
               {:weekday, 5},
               {:weekday, 6},
               {:weekday, 7},
               {:weekend, 8},
               {:weekend, 9},
               {:weekday, 10},
               {:weekday, 11},
               {:weekday, 12},
               {:weekday, 13},
               {:weekday, 14},
               {:weekend, 15},
               {:weekend, 16},
               {:weekday, 17},
               {:weekday, 18},
               {:weekday, 19},
               {:weekday, 20},
               {:weekday, 21},
               {:weekend, 22},
               {:weekend, 23},
               {:weekday, 24},
               {:weekday, 25},
               {:weekday, 26},
               {:weekday, 27},
               {:weekday, 28},
               {:today, 29},
               {:weekend, 30},
               {:weekday, 31},
               {:other_weekday, 1},
               {:other_weekday, 2},
               {:other_weekday, 3},
               {:other_weekday, 4},
               {:other_weekend, 5},
               {:other_weekend, 6}
             ]
    end
  end
end
