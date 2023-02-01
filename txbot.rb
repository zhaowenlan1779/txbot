#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'open3'
require 'time'

VERSION = "v0.1"

GHENDPOINT = "https://api.github.com"
#### Insert your username and personal access token here
USERNAME = "zhaobot"
TOKEN = ENV["BOT_TOKEN"]
##########################################################

module GithubAPI
def self.post(url, data)
    url = URI.parse("#{GHENDPOINT}#{url}")
    req = Net::HTTP::Post.new(url.path,{'Content-Type' => 'application/json', 'User-Agent' => "zhaowenlan1779/txbot-#{VERSION} Citra"})
    req.body = data
    req.basic_auth USERNAME, TOKEN
    http = Net::HTTP.new(url.host,url.port)
    http.use_ssl = true
    res = http.start{|http| http.request(req)}

    JSON.parse(res.body)
end

def self.get(url, data)
    url = URI.parse("#{GHENDPOINT}#{url}")
    req = Net::HTTP::Get.new(url.path,{'Content-Type' => 'application/json', 'User-Agent' => "zhaowenlan1779/txbot-#{VERSION} Citra"})
    req.body = data
    req.basic_auth USERNAME, TOKEN
    
    http = Net::HTTP.new(url.host,url.port)
    http.use_ssl = true
    res = http.start{|http| http.request(req)}
    JSON.parse(res.body)
end
end

def execute(command, dir=REPO_PATH, ignore_error=false)
    o, s = Open3.capture2(command, :chdir=>dir)
    unless s == 0
        puts "Command #{command} failed: exit code is #{s}."
        exit(1) unless ignore_error
    end
    puts o
    o
end

case ARGV[0]
when "version"
    puts "Txbot #{VERSION}"
    execute "ruby -v", "/"
    execute "git version", "/"
    execute "tx --version", "/"
when "execute"
    puts "Txbot #{VERSION} command: Execute"
    if Dir.exists?(REPO_PATH)
        puts "::group::Update repo"
    else
        puts "::group::Clone repo"
        execute "git clone git@github.com:#{REPO}.git #{REPO_PATH} --recursive", "/"
        execute "git remote add upstream https://github.com/#{UPSTREAM}.git"
    end
    execute "git fetch upstream"
    puts "::endgroup::"
    puts "::group::Create new branch"
    execute "git checkout upstream/master"
    branch = "tx-update-#{Time.now.strftime("%Y%m%d%H%M%S")}"
    execute "git checkout -b #{branch}"
    puts "::endgroup::"
    puts "::group::Pull translations"
    execute "tx status", TRANSLATIONS_PATH
    execute "rm --interactive=never *.ts", TRANSLATIONS_PATH
    execute "tx pull -t -a --minimum-perc 47", TRANSLATIONS_PATH, true
    puts "::endgroup::"
    puts "::group::Create commit"
    title = "Update translations (#{Time.now.strftime("%Y-%m-%d")})"
    execute "git add dist/languages/*.ts"
    execute "git status"
    execute "git commit -m \"#{title}\" --author \"#{AUTHOR}\""
    execute "git push origin #{branch}"
    puts "::endgroup::"
    # puts "::group::Create pull request"
    # GithubAPI::post("/repos/#{UPSTREAM}/pulls", {"title" => title, "body" => BODY, "head" => "#{USERNAME}:#{branch}", "base" => "master"}.to_json)
    # puts "::endgroup::"
    puts "All done!"
else
    puts "Unknown command!"
    puts
    puts "USAGE: txbot <command>"
    puts "Commands:"
    puts "version - show Txbot version"
    puts "execute - execute translation update"
end
