module ScheduleAttributes
  class Serializer
    def self.load(hstore)
      IceCube::Schedule.from_hash(ActiveRecord::Coders::Hstore.load(hstore)) if hstore
    end

    def self.dump(schedule)
      schedule.to_hash if schedule
    end
  end
end
