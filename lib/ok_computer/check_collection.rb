module OkComputer
  class CheckCollection
    attr_accessor :collection, :registrant_name, :display

    # Public: Initialize a new CheckCollection
    #
    # collection - a Hash of checks, with keys being unique names and values
    #   being Check instances
    def initialize(display)
      self.display = display
      self.collection = {}
    end

    # Public: Run the collection's checks
    def run
      OkComputer.check_in_parallel ? check_in_parallel : check_in_sequence
    end

    # Public: Returns a check or collection if it's in the check collection
    def fetch(name)
      collection[name]
    end

    # Public: The list of checks in the collection
    #
    # Returns an Array of the collection's values
    def checks
      collection.values
    end

    # Public: Registers a check into the collection
    #
    # Returns the check
    def register(name, check)
      check.collection = self
      collection[name] = check
    end

    # Public: Deregisters a check from the collection
    #
    # Returns the check
    def deregister(name)
      check = collection.delete(name)
      check.collection = nil
    end

    # Public: The text of each check in the collection
    #
    # Returns a String
    def to_text
      "#{display}\n#{checks.map{ |c| "\s\s#{c.to_text}"}.join("\n")}"
    end

    # Public: The JSON of each check in the collection
    #
    # Returns a String containing a JSON array of hashes
    def to_json(*args)
      # smooshing their #to_json objects into one JSON hash
      combined = {}
      checks.each do |check|
        combined.merge!(JSON.parse(check.to_json))
      end

      combined.to_json
    end

    # Public: Whether all the checks succeed
    #
    # Returns a Boolean
    def success?
      checks.all?(&:success?)
    end

    private

    def check_in_sequence
      checks.each(&:run)
    end

    def check_in_parallel
      threads = checks.map do |check|
        Thread.new { check.run }
      end
      threads.each(&:join)
    end
  end
end
