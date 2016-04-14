class Bot
  attr_reader :command, :jid

  def initialize(command)
    @command = command.strip
    @jid = nil
  end

  def call
    send(command_method).merge(command: command)
  end

  def error
    { result: 'Wrong command. Available commands: /list, /status jid' }
  end

  def list
    workers = Sidekiq::Workers.new
    return { result: 'Sorry, jobs list are empty :(' } if workers.size.zero?

    { result: build_jids_list(workers) }
  end

  def status
    return { result: "Incorrect jid: #{jid}" } if Sidekiq::Status::status(jid).nil?

    {
      result: 'Great, lets see the progress of choosen Job!',
      progress: Sidekiq::Status::at(jid),
      progress_message: Sidekiq::Status::message(jid)
    }
  end

  private

  def command_method
    if command.match(/^\/list/)
      :list
    elsif command.match(/^\/status/)
      @jid ||= command.match(/(^\/status\s)(?<jid>\w+)/)[:jid]
      :status
    else
      :error
    end
  end

  def build_jids_list(workers)
    separator = ', ' if workers.size > 1
    result = 'This is the list of current Job ids: '

    result.tap do |string|
      workers.each do |process_id, thread_id, work|
        string << "#{work["payload"]["jid"]}#{separator}"
      end
    end
  end
end
