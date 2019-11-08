require 'spec_helper'

describe Tmt::Cfg do
  let(:cfg) { Tmt::Cfg.first }

  it "should not allow deletion of the configuration record" do
    expect do
      cfg.destroy
    end.to_not change(Tmt::Cfg, :count)
  end

  context "for file_size attribute" do
    it "should have only one entry" do
      cfg.should be_a(Tmt::Cfg)
      Tmt::Cfg.create(file_size: 5).should_not be_valid
      Tmt::Cfg.should have(1).item
    end

    it "should update an existing entry" do
      cfg.file_size.should_not eq(123)
      cfg.update(file_size: 123)
      cfg.reload.file_size.should eq(123)
    end

    it "should not update when value of file_size attribute is less than 0" do
      expect do
        cfg.update!(file_size: -0.01)
      end.to raise_error(ActiveRecord::RecordInvalid, /File size must be greater than or equal to 0/)
    end

  end

  context "for max_name_length attribute" do
    it "should update an existing entry" do
      cfg.max_name_length.should_not eq(1)
      cfg.update(max_name_length: 1)
      cfg.reload.max_name_length.should eq(1)
    end

    it "should not update when value of file_size attribute is less than 0" do
      expect do
        cfg.update!(max_name_length: -0.01)
      end.to raise_error(ActiveRecord::RecordInvalid, /Max name length must be greater than or equal to 1/)
    end

  end

end
