require 'rails_helper'

RSpec.describe Keyword, type: :model do

  it { should have_many(:user_keywords) }
  it { should have_many(:users) }

  pending "add some examples to (or delete) #{__FILE__}"
end
