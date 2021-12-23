require 'rails_helper'

RSpec.describe UserKeyword, type: :model do

  it { should belong_to(:keyword) }
  it { should belong_to(:user) }

end
