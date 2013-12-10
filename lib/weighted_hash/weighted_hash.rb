class WeightedHash
  attr_reader :scale

  def initialize(hash, total_weight = nil)
    @hash = {}
    parse!(hash)
    @scale = total_weight ? (total_weight.to_f / unscaled_weight) : 1
  end

  # Returns our total, scaled weight plus the total scaled weight of
  # our children.
  def total_weight
    (weighted_scalars.values + children.map(&:total_weight)).reduce(:+)
  end

  # Returns the simple weights (not WeightedHash children), unscaled
  def local_unscaled_weight
    scalars.values
  end

  # Gives us the unscaled weight of THIS object, but any children
  # whose weights are forced will be counted as scaled/forced.
  def unscaled_weight
    (scalars.values + children.map(&:total_weight)).reduce(:+)
  end

  # Completely scales and flattens all probabilities and children into
  # a single hash whose values are relatively appropriate (but are not
  # necessary normalized to 0.0..1.0)
  def probabilities
    values = (Array(WeightedHash.new(weighted_scalars)) + children).reduce(:+).to_hash
  end

  # Randomly select a hash key by its probability.
  def sample(target = nil)
    target ||= rand(0...total_weight)

    probabilities.each do |key, weight|
      return key if target < weight
      target -= weight
    end
  end

  # Hash of unscaled keys/weights for keys that do not have chlidren
  def scalars
    hash.select {|_, value| !value.is_a? WeightedHash }
  end

  # Hash of scaled keys/weights for keys that do not have chlidren
  def weighted_scalars
    Hash[scalars.map {|key,value| [key, value * scale]}]
  end

  # List of complex weights (WeightedHash children)
  def children
    hash.select {|_, value| value.is_a? WeightedHash }.map {|_, value| value}
  end

  # Cast WeightedHash back to a hash
  def to_hash
    hash
  end

  # Add another WeightedHash to this one. NO ATTEMPT IS MADE TO
  # NORMALIZE THE TWO HASHES TO EACH OTHER.
  def +(other)
    h = hash.dup
    other.probabilities.each do |key, value|
      if !hash[key].is_a? WeightedHash
        h[key] = (h[key] ? h[key] * scale : 0) + value
      end
    end
    self.class.new(h)
  end

  # Test for equality by flattening and comparing probabilities. (For
  # really tortuous math, this may start to fail due to floating-point
  # drift)
  def ==(other)
    probabilities == other.probabilities
  end

  # Randomly sample self for count times, then return a hash
  # containing each selected item and the number of times it was
  # selected. It should correlate to the probabilities hash.
  def histogram(count=1000)
    Hash.new(0).tap {|hist| count.times { hist[sample] += 1 }}
  end

  private

  def add_value(key, value)
    hash[key] = value
  end

  def add_values(key, subhash)
    hash[key] = self.class.new(subhash)
  end

  def add_weighted_values(key, total_weight, subhash)
    hash[key] = self.class.new(subhash, total_weight)
  end

  def parse!(values)
    values.each do |key, value|
      case value
      when Hash
        add_values(key, value)
      when Array
        add_weighted_values(key, *value)
      else
        add_value(key, value)
      end
    end
  end

  attr_reader :hash
end
