require 'spec_helper'

describe 'semaphore' do
  let(:name) { 'default' }
  subject { Sidekiq::LimitFetch::Global::Semaphore.new name }

  it 'should have no limit by default' do
    subject.limit.should_not be
  end

  it 'should set limit' do
    subject.limit = 4
    subject.limit.should == 4
  end

  it 'should acquire and count active tasks' do
    3.times { subject.acquire }
    subject.probed.should == 3
  end

  it 'should acquire tasks with regard to limit' do
    subject.limit = 4
    6.times { subject.acquire }
    subject.probed.should == 4
  end

  it 'should acquire tasks with regard to process limit' do
    subject.process_limit = 4
    6.times { subject.acquire }
    subject.probed.should == 4
  end

  it 'should release active tasks' do
    6.times { subject.acquire }
    3.times { subject.release }
    subject.probed.should == 3
  end

  it 'should pause tasks' do
    3.times { subject.acquire }
    subject.pause
    2.times { subject.acquire }
    subject.probed.should == 3
    2.times { subject.release }
    subject.probed.should == 1
  end

  it 'should unpause tasks' do
    subject.pause
    3.times { subject.acquire }
    subject.unpause
    2.times { subject.acquire }
    subject.probed.should == 2
  end

  it 'should pause tasks for a limited time' do
    3.times { subject.acquire }
    subject.pause_for_ms 50
    2.times { subject.acquire }
    subject.probed.should == 3
    sleep(100.0 / 1000)
    2.times { subject.acquire }
    subject.probed.should == 5
  end
end
