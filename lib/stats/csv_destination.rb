require 'faster_csv'

class Stats::CsvDestination
  def initialize(filename)
    @filename = filename
  end

  def record(stats)
    FasterCSV.open(@filename, "a") do |csv|
      stats.each do |stat|
        csv << [stat.type, stat.id, stat.name, stat.date.to_f, stat.value]
      end
    end
  end
end
