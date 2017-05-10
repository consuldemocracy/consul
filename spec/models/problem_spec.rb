require 'rails_helper'

describe Problem do

  let(:problem) { Problem.new(title: 'hola') }

  it "should be valid" do
    expect(problem).to be_valid
  end

  describe "#title" do
    it "should not be valid without a title" do
      problem.title = nil
      expect(problem).to_not be_valid
    end
  end

  describe "#restriction" do
    it "should be valid whithout restriction" do
      problem.restriction = nil
      expect(problem).to be_valid
    end
  end

end
