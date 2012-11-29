class Stats
  Stat = Struct.new(:type, :id, :name, :date, :value)

  def initialize
    @measures = []
  end

  def measure(source)
    @measures << source
  end

  def record_to(destination, last_run)
    destination.record(@measures.map { |m| m.measurements(last_run) }.flatten)
  end
end
