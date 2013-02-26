require 'active_record'
require 'schedule_attributes/active_record'
require 'activerecord-postgres-hstore'

class ActiveRecord::Base
  extend ScheduleAttributes::ActiveRecord::Sugar

  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/schedule_attributes_spec')

  establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :port     => db.port,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end

ActiveRecord::Migration.execute "CREATE EXTENSION IF NOT EXISTS hstore"

ActiveRecord::Migration.drop_table :calendars

ActiveRecord::Migration.create_table :calendars do |t|
  t.hstore :schedule
  t.hstore :my_schedule
end

ActiveRecord::Migration.add_hstore_index :calendars, :schedule
ActiveRecord::Migration.add_hstore_index :calendars, :my_schedule

class CustomScheduledActiveRecordModel < ActiveRecord::Base
  self.table_name = :calendars
  has_schedule_attributes :column_name => :my_schedule

  def default_schedule
    s = IceCube::Schedule.new(Date.today.to_time)
    s.add_recurrence_rule IceCube::Rule.hourly
    s
  end

  def initialize(*args)
    super
    @can_access_default_schedule_in_initialize = my_schedule.next_occurrence
  end
end

class DefaultScheduledActiveRecordModel < ActiveRecord::Base
  self.table_name = :calendars
  has_schedule_attributes

  def initialize(*args)
    super
    @can_access_default_schedule_in_initialize = schedule.next_occurrence
  end
end
