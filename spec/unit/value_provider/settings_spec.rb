require 'spec_helper.rb'

describe Flattery::ValueProvider::Settings do
  let(:settings_class) { Flattery::ValueProvider::Settings }
  let(:settings) { provider_class.value_provider_options }

  subject { settings }

  context "with a standard has_many association" do
    let(:provider_class) do
      class ::ValueProviderHarness < Category
        include Flattery::ValueProvider
        push_flattened_values_for name: :notes, as: :category_name
      end
      ValueProviderHarness
    end
    context "before resolution" do
      it { should be_a(settings_class) }
      its(:raw_settings) { should eql([
        {from_entity: :name, to_entity: :notes, as: 'category_name', method: :update_all}
      ]) }
      its(:resolved) { should be_false }
    end
    context "after resolution" do
      before { settings.settings }
      its(:resolved) { should be_true }
      its(:settings) { should eql({
        "name"=>{to_entity: :notes, as: :category_name, method: :update_all}
      }) }
    end
  end


end
