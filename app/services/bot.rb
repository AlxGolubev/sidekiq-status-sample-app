class Bot
  attr_reader :session_id, :user_message

  def initialize(session_id, user_message)
    @state = $redis.get(session_id)
    @session_id = session_id
    @user_message = user_message
  end

  def message
    return error unless respond_to? @state
    send(@state)
  end

  def error
    $redis.set(session_id, nil)

    {
      message: 'Sorry, Something went wrong.. Lets try again!',
      user_message: user_message
    }
  end

  def welcome
    { response: 'Hey, what is your name?', user_message: user_message }
  end

  def requesting
    if workers.size == 0
      $redis.set(session_id, 'waiting_for_jobs')
      return have_no_active_jobs
    end

    { response: build_jids_list(workers), user_message: user_message }
  end

  def have_no_active_jobs
    {
      response: 'Sorry, currently I do not have jobs for you',
      user_message: user_message
    }
  end

  def parting
    {
      response: 'Greate, lets see the progress of choosen Job!',
      user_message: user_message,
      partial: 'job_status',
      progress: Sidekiq::Status::at(user_message),
      job_message: Sidekiq::Status::message(user_message)
    }
  end

  def waiting_for_jobs
    return requesting unless Sidekiq::Workers.new.size.zero?

    {
      response: 'I am so sorry, jobs list still are empty',
      user_message: user_message
    }
  end

  private

  def build_jids_list(workers)
    separator = ', ' if workers.size > 1

    response = "Hi, #{user_message}. This is the list of current Job ids" +
                 '(in response send me one of the ids for checking job status): '

    response.tap do |string|
      workers.each do |process_id, thread_id, work|
        string << "#{work["payload"]["jid"]}#{separator}"
      end
    end
  end
end
