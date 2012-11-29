require 'yaml'

class Stats::LastRunInfo
  def initialize(filename)
    @filename = filename
  end

  def remember(id, value)
    data = load
    data[id] = value
    dump data
  end

  def recall(id)
    load[id]
  end

private

  def load
    if File.file? @filename
      File.open(@filename, "r") do |file|
        YAML.load(file) || {}
      end
    else
      {}
    end
  end

  def dump(data)
    File.open(@filename, "w") do |file|
      YAML.dump(data, file)
    end
  end
end
