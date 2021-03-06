# frozen_string_literal: true

RSpec.describe Redis::WeeklySet do
  let(:mock_class) do
    Class.new do
      include Redis::Objects

      weekly_set :weekly_active_users, expiration: 2_678_400 # about a month

      def id
        1
      end
    end
  end

  let(:homepage) { Homepage.new }

  before do
    stub_const 'Homepage', mock_class
    Timecop.travel(Time.local(2021, 4, 1))
    homepage.weekly_active_users.merge('user1', 'user2', 'user3')
    Timecop.travel(Time.local(2021, 4, 8))
    homepage.weekly_active_users.merge('user1', 'user2', 'user1', 'user4', 'user5')
    Timecop.travel(Time.local(2021, 4, 15))
    homepage.weekly_active_users.merge('user1', 'user1', 'user3', 'user1', 'user1')
  end

  context 'with global: true' do
    let(:mock_class) do
      Class.new do
        include Redis::Objects

        weekly_set :weekly_active_users, global: true
      end
    end

    let(:homepage) { Homepage }

    it 'supports class-level global sets of simple values' do
      expect(homepage.redis.scard('homepage::weekly_active_users:2021W13')).to eq 3
      expect(homepage.redis.scard('homepage::weekly_active_users:2021W14')).to eq 4
      expect(homepage.redis.scard('homepage::weekly_active_users:2021W15')).to eq 2
    end
  end

  describe 'timezone' do
    context 'when Time class is extended by Active Support' do
      it do
        allow(Time).to receive(:current).and_return(Time.now)
        homepage.weekly_active_users << 'user1'
        expect(Time).to have_received(:current).with(no_args)
      end
    end

    context 'when Time class is not extended by Active Support' do
      it do
        allow(Time).to receive(:now).and_return(Time.now)
        homepage.weekly_active_users << 'user1'
        expect(Time).to have_received(:now).with(no_args)
      end
    end
  end

  describe 'keys' do
    it 'appends new sets automatically with the current week' do
      expect(homepage.redis.scard('homepage:1:weekly_active_users:2021W13')).to eq 3
      expect(homepage.redis.scard('homepage:1:weekly_active_users:2021W14')).to eq 4
      expect(homepage.redis.scard('homepage:1:weekly_active_users:2021W15')).to eq 2
    end
  end

  describe '#members' do
    it 'returns members added this week' do
      expect(homepage.weekly_active_users.members).to contain_exactly('user1', 'user3')
    end
  end

  describe '#[]' do
    context 'with date' do
      let(:date) { Date.new(2021, 4, 1) }

      it 'returns the members added the week' do
        expect(homepage.weekly_active_users[date])
          .to contain_exactly('user1', 'user2', 'user3')
      end
    end

    context 'with date and length' do
      let(:date) { Date.new(2021, 4, 8) }

      it 'returns the members added within the duration' do
        expect(homepage.weekly_active_users[date, 2])
          .to contain_exactly('user1', 'user2', 'user3', 'user4', 'user5')
      end
    end

    context 'with range' do
      let(:range) do
        Date.new(2021, 4, 1)..Date.new(2021, 4, 8)
      end

      it 'returns the members counted within the duration' do
        expect(homepage.weekly_active_users[range])
          .to contain_exactly('user1', 'user2', 'user3', 'user4', 'user5')
      end
    end
  end

  describe '#delete_at' do
    it 'deletes the members on the week' do
      date = Date.new(2021, 4, 8)
      expect { homepage.weekly_active_users.delete_at(date) }
        .to change { homepage.weekly_active_users.at(date).length }
        .from(4).to(0)
    end
  end

  describe '#range' do
    let(:start_date) { Date.new(2021, 4, 1) }
    let(:end_date) { Date.new(2021, 4, 8) }

    it 'returns the members added within the duration' do
      expect(homepage.weekly_active_users.range(start_date, end_date))
        .to contain_exactly('user1', 'user2', 'user3', 'user4', 'user5')
    end
  end

  describe '#at' do
    let(:date) { Date.new(2021, 4, 8) }

    it 'returns a set object added the week' do
      expect(homepage.weekly_active_users.at(date).members)
        .to contain_exactly('user1', 'user2', 'user4', 'user5')
      expect(homepage.weekly_active_users.at(date).length)
        .to eq 4
    end
  end
end
