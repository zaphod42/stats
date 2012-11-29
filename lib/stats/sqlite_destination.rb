require 'sqlite3'
require 'time'

class Stats::SqliteDestination
  INSERT = "INSERT INTO stats (type, id, name, date, value) VALUES (?, ?, ?, strftime('%Y-%m-%dT%H:%M:%SZ', ?), ?)"

  def initialize(database_file)
    @connection = SQLite3::Database.new(database_file)
    ensure_table_present
  end

  def record(stats)
    @connection.transaction do |conn|
      conn.prepare(INSERT) do |statement|
        stats.map(method(:stat_to_values)).each do |values|
          statement.execute(*values)
        end
      end
    end
  end

private

  def stat_to_values(stat)
    [stat.type, stat.id, stat.name, stat.date.utc.iso8601, stat.value]
  end

  def ensure_table_present
    if @connection.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='stats'").empty? 
      @connection.execute("CREATE TABLE stats (
                            type VARCHAR2(30),
                            id VARCHAR2(60),
                            name VARCHAR2(60),
                            date INTEGER,
                            value REAL
                          )")
    end
  end
end
