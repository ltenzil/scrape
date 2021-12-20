require 'rails_helper'

RSpec.describe UserKeyword, type: :model do

  it { should belong_to(:keyword) }
  it { should belong_to(:user) }

  pending "add some examples to (or delete) #{__FILE__}"
end
