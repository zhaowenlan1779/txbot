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

#### Configuration
REPO = "zhaobot/yuzu"
UPSTREAM = "yuzu-emu/yuzu"
REPO_PATH = "/home/runner/yuzu"
TRANSLATIONS_PATH = "#{REPO_PATH}/dist/languages"
AUTHOR = "The yuzu Community <noreply-fake@community.yuzu-emu.org>"
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
        puts "Update repo..."
    else
        puts "Cloning repo..."
        execute "git clone git@github.com:#{REPO}.git #{REPO_PATH} --recursive", "/"
        execute "git remote add upstream https://github.com/#{UPSTREAM}.git"
    end
    execute "git fetch upstream"
    puts "Creating new branch..."
    execute "git checkout upstream/master"
    execute "git submodule update"
    branch = "tx-update-#{Time.now.strftime("%Y%m%d%H%M%S")}"
    execute "git checkout -b #{branch}"
    puts "Current status:"
    execute "tx status", TRANSLATIONS_PATH
    puts "Pulling translations..."
    execute "rm --interactive=never *.ts", TRANSLATIONS_PATH
    execute "tx pull -a --minimum-perc 47", TRANSLATIONS_PATH, true
    puts "Committing..."
    execute "git status"
    title = "Update translations (#{Time.now.strftime("%Y-%m-%d")})"
    execute "git add ."
    execute "git commit -m \"#{title}\" --author \"#{AUTHOR}\""
    puts "Pushing..."
    execute "git push origin #{branch}"
    puts "Creating pull request..."
    GithubAPI::post("/repos/#{UPSTREAM}/pulls", {"title" => title, "body" => BODY, "head" => "#{USERNAME}:#{branch}", "base" => "master"}.to_json)
    puts "All done!"
else
    puts "Unknown command!"
    puts
    puts "USAGE: txbot <command>"
    puts "Commands:"
    puts "version - show Txbot version"
    puts "execute - execute translation update"
end
