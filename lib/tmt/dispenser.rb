module Tmt

  # Class can dose how many elements to return when is added limit
  class Dispenser

    attr_reader :limit

    # Input:
    #   collection - the array of elements to present
    #   default_limit - first 'default_limit' elements to present when limit variable is nil
    #   limit - this variable is used when it isn't nil
    def initialize(collection=[], default_limit=nil, limit=nil)
      @collection = collection
      @default_limit = default_limit
      if limit.to_s == "all"
        @limit = @collection.size
      elsif limit.to_s == ""
        @limit = @default_limit
      else
        @limit = limit.to_i
      end
    end

    # Return number of elements of @colleciton variable
    def size
      @collection.size
    end

    # Method return:
    #   - true when collection method doesn't show all elements
    #   - false in other situations
    def more?
      @limit < size
    end

    # when collection method shows all elements then method should return false
    def less?
      if @limit < size
        false
      else
        if @default_limit < size
          true
        else
          false
        end
      end
    end

    # Return array of not full collection
    def collection
      @collection.first(@limit)
    end

  end
end
