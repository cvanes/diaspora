#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MarkdownifyHelper do

  describe "#markdownify" do
    describe "not doing something dumb" do
      it "strips out script tags" do
        markdownify("<script>alert('XSS is evil')</script>").should == 
          "<p>alert(&#39;XSS is evil&#39;)</p>\n"
      end

      it 'strips onClick handlers from links' do
        omghax = '[XSS](http://joindiaspora.com/" onClick="$\(\'a\'\).remove\(\))'
        markdownify(omghax).should_not match(/ onClick/i)
      end
    end

    it 'does not barf if message is nil' do
      markdownify(nil).should == ''
    end

    it 'autolinks standard url links' do
      markdownify("http://joindiaspora.com/").should match /<p><a href="http:\/\/joindiaspora.com\/">http:\/\/joindiaspora.com\/<\/a><\/p>/
    end

    context 'when formatting status messages' do
      it "should leave tags intact" do
        message = Factory.create(:status_message, 
                                 :author => alice.person,
                                 :text => "I love #markdown")
        formatted = markdownify(message)
        formatted.should =~ %r{<a href="/tags/markdown" class="tag">#markdown</a>}
      end

      it "should leave mentions intact" do
        message = Factory.create(:status_message, 
                                 :author => alice.person,
                                 :text => "Hey @{Bob; #{bob.diaspora_handle}}!")
        formatted = markdownify(message)
        formatted.should =~ /hovercard/
      end

      it "should leave mentions intact for real diaspora handles" do
        new_person = Factory(:person, :diaspora_handle => 'maxwell@joindiaspora.com')
        message = Factory.create(:status_message, 
                                 :author => alice.person,
                                 :text => "Hey @{maxwell@joindiaspora.com; #{new_person.diaspora_handle}}!")
        formatted = markdownify(message)
        formatted.should =~ /hovercard/
      end
    end
  end
end
