require File.dirname(__FILE__) + '/../spec_helper'

describe Mark do
  it "should clear score cache of stamp when creating" do
    stamp = Factory(:stamp)
    stamp.update_attribute(:score_cache, 123)
    stamp.marks.create!(:marked_on => Time.zone.today)
    stamp.reload.score_cache.should be_nil
  end
  
  it "should clear score cache of stamp when destroying" do
    stamp = Factory(:stamp)
    stamp.marks.create!(:marked_on => Time.zone.today)
    stamp.update_attribute(:score_cache, 123)
    stamp.marks.first.destroy
    stamp.reload.score_cache.should be_nil
  end
  
  it "image_path should use stamp image" do
    stamp = Stamp.new(:color => "blue")
    stamp_image = stamp.build_stamp_image(:photo_file_name => "foo.jpg")
    mark = stamp.marks.build
    mark.stamp = stamp
    mark.image_path.should == stamp_image.photo.url("blue").sub(/[^\.]+$/, "png")
  end
  
  it "should clear future month cache of stamp when creating" do
    stamp = Factory(:stamp)
    cache1 = stamp.month_caches.create!(:for_month => 2.months.ago)
    cache2 = stamp.month_caches.create!(:for_month => Time.now.beginning_of_month)
    stamp.marks.create!(:marked_on => Time.zone.today)
    MonthCache.exists?(cache1).should be_true
    MonthCache.exists?(cache2).should be_false
  end
end
