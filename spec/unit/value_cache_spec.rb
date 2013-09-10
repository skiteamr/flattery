require 'spec_helper.rb'

class FlatteryValueCacheTestHarness < Note
  include Flattery::ValueCache
end

describe Flattery::ValueCache do

  let(:resource_class) { FlatteryValueCacheTestHarness }
  after { resource_class.value_cache_options = {} }

  describe "##included_modules" do
    subject { resource_class.included_modules }
    it { should include(Flattery::ValueCache) }
  end

  describe "#before_save" do
    let(:processor_class) { Flattery::ValueCache::Processor }
    it "should be called when record created" do
      processor_class.any_instance.should_receive(:before_save).and_return(true)
      resource_class.create!
    end
    it "should be called when record updated" do
      instance = resource_class.create!
      processor_class.any_instance.should_receive(:before_save).and_return(true)
      instance.save
    end
  end

  describe "##value_cache_options" do
    before { resource_class.flatten_value flatten_value_options }
    subject { resource_class.value_cache_options }

    context "when set to empty" do
      let(:flatten_value_options) { {} }
      it { should be_empty }
    end

    context "when reset with nil" do
      let(:flatten_value_options) { {category: :name} }
      it "should clear all settings" do
        expect {
          resource_class.flatten_value nil
        }.to change {
          resource_class.value_cache_options
        }.to({})
      end
    end

    context "with simple belongs_to association" do

      context "when set by association name and attribute value" do
        let(:flatten_value_options) { {category: :name} }
        it { should eql({
          "category_name" => {
            association_name: :category,
            association_method: :name,
            changed_on: ["category_id"]
          }
        }) }
      end

      context "when given a cache column override" do
        let(:flatten_value_options) { {category: :name, as: :cat_name} }
        it { should eql({
          "cat_name" => {
            association_name: :category,
            association_method: :name,
            changed_on: ["category_id"]
          }
        }) }
      end

      context "when set using Strings" do
        let(:flatten_value_options) { {'category' => 'name', 'as' => 'cat_name'} }
        it { should eql({
          "cat_name" => {
            association_name: :category,
            association_method: :name,
            changed_on: ["category_id"]
          }
        }) }
      end

      context "when set by association name and invalid attribute value" do
        let(:flatten_value_options) { {category: :bogative} }
        it { should be_empty }
      end

    end

    context "with a belongs_to association having non-standard primary and foreign keys" do

      context "when set by association name and attribute value" do
        let(:flatten_value_options) { {person: :email} }
        it { should eql({
          "person_email" => {
            association_name: :person,
            association_method: :email,
            changed_on: ["person_name"]
          }
        }) }
      end

      context "when set by association name and invalid attribute value" do
        let(:flatten_value_options) { {person: :bogative} }
        it { should be_empty }
      end

    end

  end

end
