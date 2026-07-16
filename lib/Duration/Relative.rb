# Duration/Relative.rb
# Duration::Relative

module Duration
  module Relative
    def ago
      Time.now - self.to_seconds.to_f
    end

    def hence
      Time.now + self.to_seconds.to_f
    end
  end
end
