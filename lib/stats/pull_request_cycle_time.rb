require 'time'
require 'stats'
require 'simplehttp'
require 'json'

class Stats::PullRequestCycleTime
  def initialize(user, repo)
    @user = user
    @repo = repo
    @uri = URI.parse "https://api.github.com/repos/#{user}/#{repo}/pulls?state=closed&per_page=100"
  end

  def measurements(last_run)
    requests = pull_requests_after(oldest_pull_request_processed_from last_run)

    remember_latest_processed_in requests, last_run

    requests.map do |pull_request|
      closed = Time.parse(pull_request['closed_at'])
      opened = Time.parse(pull_request['created_at'])
      id = "#{@user}/#{@repo}/#{pull_request['number']}"
      Stats::Stat.new('pull_request_cycle_time',
                      id,
                      id,
                      closed,
                      closed - opened)
    end
  end

private

  def oldest_pull_request_processed_from(last_run)
    last_run.recall(last_run_id) || 0
  end

  def remember_latest_processed_in(requests, last_run)
    return if requests.empty?

    last_run.remember(last_run_id, requests.map { |pr| pr['number'] }.max)
  end

  def last_run_id
    "#{@user}/#{@repo}"
  end

  def pull_requests_after(oldest_pr)
    link = @uri
    pulls = [] 
    begin
      http = SimpleHttp.new link
      pulls.concat(JSON.parse http.get)
      link = next_link_from(http.response_headers['link'])
    end while link && !pulls.any?(&pr_is_before(oldest_pr))

    pulls.reject &pr_is_before(oldest_pr)
  end

  def pr_is_before(oldest_pr)
    Proc.new { |pr| pr['number'] <= oldest_pr }
  end

  def next_link_from(links)
    if next_link = links.split(', ').grep(/rel="next"/)[0]
      if url = next_link.match(/<([^>]+)>/)
        URI.parse url[1]
      end
    end
  end
end
