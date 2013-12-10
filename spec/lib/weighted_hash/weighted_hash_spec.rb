require 'spec_helper'

describe WeightedHash do
  let(:epsilon) { 0.000001 }

  it "exists" do # Sanity Check
    WeightedHash.should_not be_nil
  end

  context "with a single probability" do
    subject { WeightedHash.new({a: 5.0}) }

    its(:unscaled_weight) { should == 5.0 }
    its(:total_weight) { should == 5.0 }
    its(:probabilities) { should == {a: 5.0} }
    its(:scalars) { should == {a: 5.0} }
    its(:sample) { should eq(:a) }
  end

  context "with multiple probabilities" do
    subject { WeightedHash.new({a: 0, b: 1, c: 0}) }

    its(:unscaled_weight) { should == 1 }
    its(:total_weight) { should == 1 }
    its(:probabilities) { should == {a: 0, b: 1, c: 0} }
    its(:scalars) { should == {a: 0, b: 1, c: 0} }
    its(:sample) { should == :b }
  end


  context "with a large number of runs", slow: true do
    weights = {sweden: 3, peru: 2, portugal: 4, uk: 1 }
    probabilities = WeightedHash.new(weights).probabilities

    subject(:hash) { WeightedHash.new( weights ) }
    let(:iterations) { 100_000 }
    let(:epsilon) { iterations / 100 }
    let(:histogram) { hash.histogram(iterations) }

    its(:total_weight) { should == 10 }

    probabilities.keys.each do |thing|
      it "approximates probabilities for #{thing}" do
        histogram[thing].should be_within(epsilon).of(iterations * (probabilities[thing].to_f/hash.total_weight))
      end
    end
  end

  context "with a nested hash" do
    subject(:hash) { WeightedHash.new( { sweden: 0, peru: 0, cities: { london: 0, moab: 5, paris: 0 } } ) }

    it { should_not be_nil }

    its(:unscaled_weight) { should == 5 }
    its(:total_weight) { should == 5 }
    its(:probabilities) { should == {sweden: 0, peru: 0, london: 0, moab: 5, paris: 0} }
    its(:scalars) { should == {sweden: 0, peru: 0 } }
    its(:sample) { should == :moab }
  end

  context "with a insane Kevin and David hash", slow: true do
    weights = { sweden: {kalmar: 20, vaxjo: {oster: 8, soder: 6, norr: 6, vast: 0},  peru: 0, usa: { utah: { slc: 5, provo: { east_bay: 1, south_towne: 1, byu: 13, west_side: 1, tree_streets: { birch: 3, oak: 3, cottonwood: 3, ash: 4}}, lehi: 7, moab: 15, sigurd: 4, hurricane: 0 }}}}
    probabilities = WeightedHash.new(weights).probabilities


    before :all do
      @iterations = 100_000
      @epsilon =  @iterations / 100
      @hash = WeightedHash.new(weights)
      @histogram ||= @hash.histogram(@iterations)
    end

    it { @hash.total_weight.should == 100 }

    probabilities.each do |thing, weight|
      it "presents #{thing} about #{weight}% of the time" do
        @histogram[thing].should be_within(@epsilon).of(@iterations * (probabilities[thing].to_f/@hash.total_weight))
      end
    end
  end

  context "with multiple keys of the same value" do
    subject { WeightedHash.new({a: {c: 3, d: 5}, b: {c: 2, d: 4}})}

    its(:total_weight) { should == 14 }
    its(:probabilities) { should == {c: 5, d: 9} }
  end

  context "with scaled weights" do
    subject(:hash) { WeightedHash.new( {a: 1, b: 2}, 30.0) }

    its(:total_weight) { should be_within(epsilon).of(30.0) }
    its(:scale) { should be_within(epsilon).of 10.0 }

    it { hash.probabilities[:a].should be_within(epsilon).of 10.0 }
    it { hash.probabilities[:b].should be_within(epsilon).of 20.0 }

    context "with nested scaled weights" do
      subject { WeightedHash.new({a: 1, b: 2, c: [1, {d: 1, e: 1}] })}

      its(:total_weight) { should == 4 }
      its(:probabilities) { should == {a: 1, b: 2, d: 0.5, e: 0.5} }
    end
  end

  describe "#+" do
    let(:hash1) { WeightedHash.new({a: 1, b: 2, c: 3}) }
    let(:hash2) { WeightedHash.new({b: 4, c: 5, d: 6}) }
    let(:sum12) { WeightedHash.new({a: 1, b: 6, c: 8, d: 6}) }

    let(:hash3) { WeightedHash.new({a: {b: 1, c: 2}, d: { e: 4, f: 6 }}) }
    let(:hash4) { WeightedHash.new({g: {h: 3, i: 0}, d: { e: 5, j: 2 }}) }
    let(:sum34) { WeightedHash.new({a: {b: 1, c: 2}, d: { e: 9, f: 6, j: 2 }, g: {h: 3, i: 0}}) }

    it { (hash1 + hash2).should == sum12 }
    it { (hash3 + hash4).should == sum34 }
  end
end
