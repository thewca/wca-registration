RSpec.shared_examples 'optional field tests' do |payload|
  let(:registration) { payload }

  it 'should return 202' do
    run_test!
  end
end

RSpec.shared_examples 'payload error tests' do |payload|
  let(:registration) { payload }

  it 'should return 400' do
    run_test!
  end
end
