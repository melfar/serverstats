# gem install rack thin json

use Rack::ShowExceptions
use Rack::CommonLogger

require 'rack/request'
require 'rack/response'
require 'json'

module Rack
  class App
    def call(env)
      req = Request.new(env)

      Response.new.finish do |res|
        if req.params['q']
          q = JSON.parse(req.params['q'])
          #puts q.inspect
        
          responses = q['requestsArray'].map do |request|
            case request['request']['command']
              when 'getHistory':      cpu_info(request['request']['timeScale'].to_i)
              when 'getHardwareInfo': disk_info
            end
          end.compact
        
          res.write envelope(responses*',')
          puts envelope(responses*',')
        end
      end
    end
    
  private
    def cpu_info(timeScale)
      samples = $monitor.samples[0..timeScale/60]
      
      data = []
      samples.each do |s|
        data << "{t: #{s[:t]}, v1: #{s[:cpu] * 100}, v15: #{s[:rx]}, v16: #{s[:tx]}}"
      end

      "
        getHistory: 
        {
          samplesArray:
          [
            #{data*','}
          ]
        }
      "
    end

    def disk_info
      data = $monitor.disk_usage.map do |d|
        "
          {
            name:       '#{d[:name]}',
            freeBytes:  '#{d[:freeBytes]*1000}',
            totalBytes: '#{d[:totalBytes]*1000}'
          }
        "
      end
      
      "
        getHardwareInfo: 
        {
          volumeInfosArray:
          [
              #{data*','}
          ]
        }
      "
    end
      
    def envelope(content)
      "
          { 
            command: 'batchRequest',
            servermgr_info:
            {
              #{content}
            }
          }
      ".gsub("\n", '').gsub(/\s+/, ' ')
    end
  end

  class Monitor
    attr_accessor :samples, :cpu_usage, :traffic, :disk_usage
    
    def run
      loop do
        update_cpu_usage!
        update_traffic!
        update_disks_usage!
        @samples ||= []
        @samples.unshift({:t     => Time.now.to_i,
                          :cpu   => @cpu_usage,
                          :rx    => @traffic[0],
                          :tx    => @traffic[1],
                          :disks => @disk_usage})
        @samples.pop if @samples.size > 60*60*24*7
        puts @samples.first.inspect
        sleep 60
      end
    end
    
    def update_cpu_usage!
      ENV['LANG'] = 'C'
      raw = `mpstat 1 1`    
      @cpu_usage = 100.0 - raw.select {|line|
        line =~ /verage/ 
      }.map{ |line|
        line.split(/\s+/)[9]
      }.first.to_f
    end
    
    def update_traffic!
      ENV['LANG'] = 'C'
      raw = `sar -n DEV 5 2`
      multiplier = if raw['txbyt']
        1
      elsif raw['txkB']
        1000
      else
        0
      end

      @traffic = raw.select do |line| 
        line =~ /verage/ && line !~ /tx/ && line =~ /eth0/
      end.map do |line|
        line.strip.split(/\s+/)[4,2].map{|b| b.to_i*8 * multiplier }
      end.first
    end
    
    def update_disks_usage!
      ENV['LANG'] = 'C'
      raw = `df`
      @disk_usage = raw.select do |line|
        line =~ %r{/dev/hd.+|/dev/sd.+}
      end.map do |line|
        p = line.strip.split(/\s+/)
        {:name => p[0], :freeBytes => p[3].to_i, :totalBytes => p[1].to_i}
      end
    end
  end
  
end

$monitor = Rack::Monitor.new
Thread.new { $monitor.run }
run Rack::App.new
