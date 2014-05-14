require 'spec_helper'

describe ApplicationHelper do

  describe 'page title helpers' do
    it 'gives site name when no page-specific part was given' do
      expect(page_title).to eq 'Peddie Sound File'
    end

    it 'includes page-specific part if it was given' do
      set_title 'Page title'
      expect(page_title).to eq 'Page title - Peddie Sound File'
    end
  end

end
